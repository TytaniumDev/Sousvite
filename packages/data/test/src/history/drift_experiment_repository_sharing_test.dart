import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

import '../../helpers/test_device.dart';

const _shareId = 's_soup';
const _soupId = RecipeId('soup');

/// One person's device in a joint share: their own library syncs through
/// their own space, and the share through [share].
final class _Device(
  super.id,
  super.space, {
  required final InMemorySyncSpace share,
}) extends TestDevice {
  late final recipes = DriftRecipeRepository(database, recorder: recorder);
  late final spaces = DriftRecipeSpaceRepository(database, recorder: recorder);
  late final history = DriftExperimentRepository(
    database,
    recorder: recorder,
    recipes: recipes,
    now: () => DateTime.utc(2026, 11, 17).add(Duration(minutes: time++)),
  );

  @override
  Map<String, EntityApplier> get appliers => {
    ...recipes.appliers,
    ...history.appliers,
  };

  late final _shareEngine = SyncEngine(
    store: DriftLocalStore(database, deviceId: id, appliers: appliers),
    transport: InMemoryTransport(share),
    clock: clock,
    transportKey: 'memory:$_shareId',
    spaceId: _shareId,
  );

  Future<void> syncAll() async {
    await engine.sync();
    await _shareEngine.sync();
  }
}

RecipeSnapshot _soup() => RecipeSnapshot(
  recipe: Recipe(
    id: _soupId,
    title: 'Soup',
    servings: Quantity(4),
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  ),
  steps: const [
    RecipeStep(
      id: RecipeStepId('t1'),
      recipeId: _soupId,
      text: 'Simmer.',
      sortKey: SortKey('a'),
    ),
  ],
);

void main() {
  late InMemorySyncSpace share;
  late List<_Device> devices;
  late _Device alice;
  late _Device bob;

  _Device device(String id) {
    final created = _Device(id, InMemorySyncSpace(), share: share);
    devices.add(created);
    return created;
  }

  setUp(() async {
    share = InMemorySyncSpace();
    devices = [];
    alice = device('alice');
    bob = device('bob');
    await alice.recipes.saveSnapshot(_soup());
    await alice.spaces.moveToSharedSpace(_soupId, _shareId);
    await alice.syncAll();
    await bob.syncAll();
  });

  tearDown(() async {
    for (final device in devices) {
      await device.database.close();
    }
  });

  group('DriftExperimentRepository in a joint share', () {
    test('keeps experiments private by default', () async {
      final experiment = await alice.history.startExperiment(_soupId);
      await alice.history.saveExperiment(experiment.copyWith(notes: 'Hot'));
      await alice.syncAll();
      await bob.syncAll();

      expect(await bob.history.watchExperiments(_soupId).first, isEmpty);
      expect(await bob.recipes.getRecipe(experiment.workingRecipeId), isNull);
      expect(
        await alice.spaces.sharedSpaceOf(experiment.workingRecipeId),
        isNull,
      );
    });

    test('shares an experiment with others, and its later edits', () async {
      final started = await alice.history.startExperiment(_soupId);
      final shared = started.copyWith(sharedWithOthers: true);
      await alice.history.saveExperiment(shared);
      await alice.history.saveExperiment(shared.copyWith(notes: 'Spicier'));
      await alice.syncAll();
      await bob.syncAll();

      final seen = (await bob.history.watchExperiments(_soupId).first).single;
      expect(seen.notes, 'Spicier');
      expect(seen.sharedWithOthers, isTrue);
      expect(await bob.history.getVersion(seen.baseVersionId), isNotNull);
      expect(await bob.recipes.getSnapshot(seen.workingRecipeId), isNotNull);
      expect(await bob.spaces.sharedSpaceOf(seen.workingRecipeId), _shareId);
    });

    test('keeps it with the others when sharing is turned off', () async {
      final started = await alice.history.startExperiment(_soupId);
      final shared = started.copyWith(sharedWithOthers: true);
      await alice.history.saveExperiment(shared);
      await alice.syncAll();
      await bob.syncAll();

      await alice.history.saveExperiment(
        shared.copyWith(sharedWithOthers: false, notes: 'Mine again'),
      );
      await alice.syncAll();
      await bob.syncAll();

      expect(await alice.spaces.sharedSpaceOf(started.workingRecipeId), isNull);
      final bobs = (await bob.history.watchExperiments(_soupId).first).single;
      expect(bobs.sharedWithOthers, isTrue);
      expect(bobs.notes, isEmpty);
    });
  });
}
