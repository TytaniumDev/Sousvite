// coverage:ignore-file
// Reads files the platform hands over on iOS and Android. Tests use a fake
// UmamiFiles instead.

import 'dart:io';

import 'package:flutter/foundation.dart';

/// The bytes of the file at [path], which another app shared into this
/// one. The file is a copy the platform made for the app (in the iOS inbox
/// or the Android cache), so it's deleted once read. Null if it's gone.
Future<Uint8List?> takeSharedFile(String path) async {
  final file = File(path);
  if (!file.existsSync()) return null;
  final bytes = await file.readAsBytes();
  await file.delete();
  return bytes;
}
