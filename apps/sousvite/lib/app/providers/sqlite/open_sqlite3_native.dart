import 'package:sqlite3/sqlite3.dart';

/// The platform's SQLite, bundled with the app by `sqlite3`'s build hook.
Future<CommonSqlite3> openSqlite3() async => sqlite3;
