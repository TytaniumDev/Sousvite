import 'package:data/data.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/account/sync/data/local_setting.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  group(LocalSetting, () {
    test('reads null until written, then the latest value', () async {
      final setting = LocalSetting(database.settingsDao, 'k');
      expect(await setting.read(), isNull);

      await setting.write('a');
      await setting.write('b');

      expect(await setting.read(), 'b');
      expect(await LocalSetting(database.settingsDao, 'other').read(), isNull);
    });
  });
}
