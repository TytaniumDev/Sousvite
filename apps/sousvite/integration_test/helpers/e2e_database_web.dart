import 'package:data/data.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sousvite/app/providers/sqlite/web_file_uri.dart';

/// A fresh database for one device in the browser. The name is unique per
/// run, so earlier runs' databases are never reused.
AppDatabase openE2eDatabase(String name) => AppDatabase(
  driftDatabase(
    name: 'e2e_${name}_${DateTime.now().microsecondsSinceEpoch}',
    web: DriftWebOptions(
      sqlite3Wasm: webFileUri('sqlite3.wasm'),
      driftWorker: webFileUri('drift_worker.js'),
    ),
  ),
);
