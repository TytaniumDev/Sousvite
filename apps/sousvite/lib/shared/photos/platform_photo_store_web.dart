// coverage:ignore-file
// Runs only in a browser.

import 'package:sousvite/shared/photos/indexed_db_photo_store.dart';
import 'package:sousvite/shared/photos/photo_store.dart';

/// Photos in the browser's IndexedDB.
PhotoStore platformPhotoStore() => IndexedDbPhotoStore();
