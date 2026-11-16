// coverage:ignore-file
// Runs only in a browser: the VM tests can't load dart:js_interop. The
// PhotoStore contract is tested on FilePhotoStore and the test fake.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:sousvite/shared/photos/photo_store.dart';
import 'package:web/web.dart' as web;

/// Saves photos in the browser's IndexedDB, on web.
class IndexedDbPhotoStore() implements PhotoStore {
  static const _databaseName = 'sousvite_photos';
  static const _storeName = 'photos';

  Future<web.IDBDatabase>? _database;

  @override
  Future<void> write(String id, Uint8List bytes) async {
    final store = await _store('readwrite');
    await _result(store.put(bytes.toJS, id.toJS));
  }

  @override
  Future<Uint8List?> read(String id) async {
    final store = await _store('readonly');
    final result = await _result(store.get(id.toJS));
    if (result == null || result.isUndefinedOrNull) return null;
    return (result as JSUint8Array).toDart;
  }

  @override
  Future<void> delete(String id) async {
    final store = await _store('readwrite');
    await _result(store.delete(id.toJS));
  }

  Future<web.IDBObjectStore> _store(String mode) async {
    final database = await (_database ??= _open());
    return database.transaction(_storeName.toJS, mode).objectStore(_storeName);
  }

  Future<web.IDBDatabase> _open() async {
    final request = web.window.indexedDB.open(_databaseName, 1);
    request.onupgradeneeded = ((web.Event _) {
      (request.result! as web.IDBDatabase).createObjectStore(_storeName);
    }).toJS;
    return (await _result(request))! as web.IDBDatabase;
  }

  /// Waits for [request] to finish.
  static Future<JSAny?> _result(web.IDBRequest request) {
    final completer = Completer<JSAny?>();
    request
      ..onsuccess = ((web.Event _) => completer.complete(request.result)).toJS
      ..onerror = ((web.Event _) => completer.completeError(
        StateError('IndexedDB: ${request.error?.message}'),
      )).toJS;
    return completer.future;
  }
}
