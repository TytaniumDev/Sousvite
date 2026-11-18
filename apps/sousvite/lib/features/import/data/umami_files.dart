import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:sousvite/features/import/data/shared_file.dart';

/// Lets the user pick an Umami export and save one.
abstract interface class UmamiFiles() {
  /// The bytes of the zip file the user picks, or null if they cancel.
  Future<Uint8List?> pickArchive();

  /// The bytes of the zip file another app shared into this one, which
  /// the platform left at [path]. The file is removed once read. Null if
  /// it's gone.
  Future<Uint8List?> takeSharedArchive(String path);

  /// Offers [bytes] to the user to save as [fileName]. Returns false if
  /// they cancel.
  Future<bool> saveArchive(String fileName, Uint8List bytes);
}

// coverage:ignore-start
// Thin calls into the file_picker plugin, which needs a device or browser.
// LibraryUmamiTransfer's tests use a fake UmamiFiles instead.

/// The system file picker and save dialog, through file_picker.
class const SystemUmamiFiles() implements UmamiFiles {
  @override
  Future<Uint8List?> pickArchive() async {
    final file = await FilePicker.pickFile(
      type: .custom,
      allowedExtensions: const ['zip'],
    );
    return file == null ? null : await file.readAsBytes();
  }

  @override
  Future<Uint8List?> takeSharedArchive(String path) => takeSharedFile(path);

  @override
  Future<bool> saveArchive(String fileName, Uint8List bytes) async {
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/zip',
    );
    // Web downloads the file without a dialog, and so returns no location.
    return kIsWeb || saved != null;
  }
}

// coverage:ignore-end
