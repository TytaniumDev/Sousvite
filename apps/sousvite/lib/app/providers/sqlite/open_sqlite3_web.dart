// coverage:ignore-file
// Runs only in the browser; widget tests run on the Dart VM.

import 'package:sqlite3/wasm.dart';

/// SQLite in WebAssembly, from the same `web/sqlite3.wasm` Drift uses.
Future<CommonSqlite3> openSqlite3() =>
    WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
