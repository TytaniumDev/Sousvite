import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sousvite/shared/photos/file_photo_store.dart';
import 'package:sousvite/shared/photos/photo_store.dart';

/// Photos in a `photos` folder in the app's support directory, which the
/// user doesn't see and the system doesn't clear.
PhotoStore platformPhotoStore() => FilePhotoStore(
  // coverage:ignore-line
  getApplicationSupportDirectory().then((d) => Directory('${d.path}/photos')),
);
