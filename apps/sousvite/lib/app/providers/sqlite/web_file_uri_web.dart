// coverage:ignore-file
// Runs only in the browser; widget tests run on the Dart VM.

import 'package:web/web.dart' as web;

/// The address of [path] in the web build, next to `index.html`.
///
/// Resolved against the document's base URL (`<base href>`), not the page's
/// address: on a deep link such as `/library/folders/<id>`, a bare
/// `sqlite3.wasm` would load `/library/folders/sqlite3.wasm`, which hosting
/// rewrites to `index.html`. `WasmSqlite3.loadFromUrl` resolves relative
/// URLs against the page's address, so callers pass this absolute one.
Uri webFileUri(String path) => Uri.parse(web.document.baseURI).resolve(path);
