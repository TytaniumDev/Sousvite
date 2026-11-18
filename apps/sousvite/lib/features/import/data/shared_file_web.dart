// coverage:ignore-file
// Runs only in a browser.

import 'package:flutter/foundation.dart';

/// Browsers can't share files into the app, so there is never one to read.
Future<Uint8List?> takeSharedFile(String path) async => null;
