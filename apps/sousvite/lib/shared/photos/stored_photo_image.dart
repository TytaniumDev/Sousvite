import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:sousvite/shared/photos/photo_store.dart';

/// Shows the photo saved in [store] as [id]. Equal for the same photo, so
/// the image cache keeps one copy and a rebuild doesn't reload it.
///
/// A photo that isn't on this device fails to load, and widgets show
/// their placeholder.
@immutable
class const StoredPhotoImage(
  /// Where the photo is saved.
  final PhotoStore store,

  /// The photo's id.
  final String id,
) extends ImageProvider<StoredPhotoImage> {
  @override
  Future<StoredPhotoImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    StoredPhotoImage key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(
    codec: _load(key, decode),
    scale: 1,
    debugLabel: 'StoredPhotoImage($id)',
  );

  static Future<ui.Codec> _load(
    StoredPhotoImage key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await key.store.read(key.id);
    if (bytes == null) {
      throw StateError('Photo ${key.id} is not on this device.');
    }
    final codec = await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    return codec;
  }

  @override
  bool operator ==(Object other) =>
      other is StoredPhotoImage &&
      identical(other.store, store) &&
      other.id == id;

  @override
  int get hashCode => Object.hash(identityHashCode(store), id);

  @override
  String toString() => 'StoredPhotoImage($id)';
}
