import 'dart:io';
import 'dart:typed_data';

import 'package:sousvite/shared/photos/photo_store.dart';

/// Saves each photo as a file in [_directory], on iOS and Android.
class const FilePhotoStore(final Future<Directory> _directory)
    implements PhotoStore {
  @override
  Future<void> write(String id, Uint8List bytes) async {
    final file = await _file(id);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  @override
  Future<Uint8List?> read(String id) async {
    final file = await _file(id);
    final bytes = file.existsSync() ? await file.readAsBytes() : null;
    return bytes;
  }

  @override
  Future<void> delete(String id) async {
    final file = await _file(id);
    if (file.existsSync()) await file.delete();
  }

  /// The file for [id]. Ids are uuids, but anything that could leave the
  /// folder is refused.
  Future<File> _file(String id) async {
    if (id.isEmpty || id.contains(RegExp(r'[/\\]')) || id.startsWith('.')) {
      throw ArgumentError.value(id, 'id', 'is not a photo id');
    }
    return File('${(await _directory).path}${Platform.pathSeparator}$id.jpg');
  }
}
