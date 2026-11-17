import 'package:data/data.dart';
import 'package:drift/native.dart';

/// A fresh in-memory database for one device, on Android and iOS.
AppDatabase openE2eDatabase(String name) =>
    AppDatabase(NativeDatabase.memory());
