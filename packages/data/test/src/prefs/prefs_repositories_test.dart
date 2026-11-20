import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

/// A test device with the prefs, tools, and settings repositories.
final class _Device(super.id, super.space) extends TestDevice {
  late final prefs = DriftUserRecipePrefsRepository(
    database,
    recorder: recorder,
  );
  late final tools = DriftMeasuringToolRepository(database, recorder: recorder);
  late final settings = DriftAppSettingsRepository(
    database,
    recorder: recorder,
  );

  @override
  Map<String, EntityApplier> get appliers => {
    ...prefs.appliers,
    ...tools.appliers,
    ...settings.appliers,
  };
}

MeasuringTool _tool(String id, Unit unit, int numerator, [int d = 1]) =>
    MeasuringTool(
      id: MeasuringToolId(id),
      capacity: Quantity(numerator, d),
      unit: unit,
    );

void main() {
  late InMemorySyncSpace space;
  late List<_Device> devices;

  _Device device(String id) {
    final created = _Device(id, space);
    devices.add(created);
    return created;
  }

  setUp(() {
    space = InMemorySyncSpace();
    devices = [];
  });

  tearDown(() async {
    for (final device in devices) {
      await device.database.close();
    }
  });

  group(DriftUserRecipePrefsRepository, () {
    const recipeId = RecipeId('r1');
    final prefs = UserRecipePrefs(recipeId: recipeId, servings: Quantity(2));

    test('is null until saved, then reads back', () async {
      final phone = device('phone');
      expect(await phone.prefs.watchPrefs(recipeId).first, isNull);

      await phone.prefs.savePrefs(prefs);
      await phone.prefs.savePrefs(
        prefs.copyWith(unitSystem: UnitSystem.metric),
      );

      expect(
        await phone.prefs.watchPrefs(recipeId).first,
        prefs.copyWith(unitSystem: UnitSystem.metric),
      );
      final unitChanges = [
        for (final change in await phone.changes())
          if (change.field == 'unitSystem') change.value,
      ];
      expect(unitChanges, ['original', 'metric']);
    });

    test('syncs to another device', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      await phone.prefs.savePrefs(prefs);
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(await laptop.prefs.watchPrefs(recipeId).first, prefs);
    });

    test('waits for the serving size', () {
      final codec = UserRecipePrefsCodec();
      expect(codec.decode('r1', {'unitSystem': 'us'}), isNull);
      expect(
        codec.decode('r1', {
          'servings': {'n': 1, 'd': 1},
        }),
        UserRecipePrefs(recipeId: recipeId, servings: Quantity(1)),
      );
    });
  });

  group(DriftMeasuringToolRepository, () {
    test('lists tools by unit, largest first', () async {
      final tools = device('phone').tools;
      final quarterCup = _tool('c4', Unit.cup, 1, 4);
      final cup = _tool('c1', Unit.cup, 1);
      final teaspoon = _tool('t1', Unit.teaspoon, 1);
      final halfTeaspoon = _tool('t2', Unit.teaspoon, 1, 2);
      for (final tool in [halfTeaspoon, quarterCup, teaspoon, cup]) {
        await tools.saveTool(tool);
      }

      expect(await tools.watchTools().first, [
        cup,
        quarterCup,
        teaspoon,
        halfTeaspoon,
      ]);
    });

    test('deletes a tool, on every device', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      await phone.tools.saveTool(_tool('c1', Unit.cup, 1));
      await phone.tools.saveTool(_tool('c2', Unit.cup, 1, 2));
      await phone.engine.sync();
      await laptop.engine.sync();
      expect(await laptop.tools.watchTools().first, hasLength(2));

      await phone.tools.deleteTool(const MeasuringToolId('c1'));
      await phone.engine.sync();
      await laptop.engine.sync();

      expect(await laptop.tools.watchTools().first, [
        _tool('c2', Unit.cup, 1, 2),
      ]);
    });

    test('waits for capacity and unit', () {
      expect(MeasuringToolCodec().decode('c1', {'unit': 'cup'}), isNull);
    });
  });

  group(DriftAppSettingsRepository, () {
    test('emits the defaults until something is saved', () async {
      expect(
        await device('phone').settings.watchSettings().first,
        const AppSettings(),
      );
    });

    test('saves both settings and records only the unit system', () async {
      final phone = device('phone');
      const settings = AppSettings(
        theme: ThemePreference.dark,
        unitSystem: UnitSystem.metric,
      );

      await phone.settings.saveSettings(settings);
      await phone.settings.saveSettings(settings);

      expect(await phone.settings.watchSettings().first, settings);
      expect(
        [for (final change in await phone.changes()) change.field],
        ['unitSystem'],
      );
    });

    test('syncs the unit system but not the theme', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      await laptop.settings.saveSettings(
        const AppSettings(theme: ThemePreference.light),
      );
      await phone.settings.saveSettings(
        const AppSettings(
          theme: ThemePreference.dark,
          unitSystem: UnitSystem.us,
        ),
      );

      await phone.engine.sync();
      await laptop.engine.sync();

      expect(
        await laptop.settings.watchSettings().first,
        const AppSettings(
          theme: ThemePreference.light,
          unitSystem: UnitSystem.us,
        ),
      );
    });

    test('saves jarred garlic and records only that field', () async {
      final phone = device('phone');

      await phone.settings.saveSettings(const AppSettings(jarredGarlic: true));

      expect(
        await phone.settings.watchSettings().first,
        const AppSettings(jarredGarlic: true),
      );
      expect(
        [for (final change in await phone.changes()) change.field],
        ['jarredGarlic'],
      );
    });

    test('syncs jarred garlic', () async {
      final phone = device('phone');
      final laptop = device('laptop');
      await phone.settings.saveSettings(const AppSettings(jarredGarlic: true));

      await phone.engine.sync();
      await laptop.engine.sync();

      expect(
        await laptop.settings.watchSettings().first,
        const AppSettings(jarredGarlic: true),
      );
    });

    test('ignores synced settings it cannot read', () {
      expect(SyncedSettingsCodec().decode('user', {}), isNull);
      expect(
        SyncedSettingsCodec().decode('user', {'jarredGarlic': 'yes'}),
        isNull,
      );
    });

    test('reads synced settings with only some fields', () {
      expect(
        SyncedSettingsCodec().decode('user', {'jarredGarlic': true}),
        const AppSettings(jarredGarlic: true),
      );
      expect(
        SyncedSettingsCodec().decode('user', {'unitSystem': 'us'}),
        const AppSettings(unitSystem: UnitSystem.us),
      );
    });
  });
}
