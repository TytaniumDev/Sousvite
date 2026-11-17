import 'package:data/data.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// A fresh database for one device in the browser. The name is unique per
/// run, so earlier runs' databases are never reused.
AppDatabase openE2eDatabase(String name) => AppDatabase(
  driftDatabase(
    name: 'e2e_${name}_${DateTime.now().microsecondsSinceEpoch}',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ),
);
