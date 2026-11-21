// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's one database connection, open for the app's lifetime.
///
/// SQLite on iOS and Android; WebAssembly SQLite on web, using
/// `web/sqlite3.wasm` and `web/drift_worker.js` (ENGINEERING.md §7). Tests
/// override this with `AppDatabase(NativeDatabase.memory())`.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The app's one database connection, open for the app's lifetime.
///
/// SQLite on iOS and Android; WebAssembly SQLite on web, using
/// `web/sqlite3.wasm` and `web/drift_worker.js` (ENGINEERING.md §7). Tests
/// override this with `AppDatabase(NativeDatabase.memory())`.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The app's one database connection, open for the app's lifetime.
  ///
  /// SQLite on iOS and Android; WebAssembly SQLite on web, using
  /// `web/sqlite3.wasm` and `web/drift_worker.js` (ENGINEERING.md §7). Tests
  /// override this with `AppDatabase(NativeDatabase.memory())`.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'352d8cdd38b1cdcf8ba1c4ee8d740bef04b04d17';

/// Records every local write in the change log for sync.
///
/// Loads this device's id and moves the clock past the last change, so it
/// is async. `bootstrap` waits for it before the first frame, so
/// repositories read it with `requireValue`.

@ProviderFor(changeRecorder)
final changeRecorderProvider = ChangeRecorderProvider._();

/// Records every local write in the change log for sync.
///
/// Loads this device's id and moves the clock past the last change, so it
/// is async. `bootstrap` waits for it before the first frame, so
/// repositories read it with `requireValue`.

final class ChangeRecorderProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChangeRecorder>,
          ChangeRecorder,
          FutureOr<ChangeRecorder>
        >
    with $FutureModifier<ChangeRecorder>, $FutureProvider<ChangeRecorder> {
  /// Records every local write in the change log for sync.
  ///
  /// Loads this device's id and moves the clock past the last change, so it
  /// is async. `bootstrap` waits for it before the first frame, so
  /// repositories read it with `requireValue`.
  ChangeRecorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changeRecorderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changeRecorderHash();

  @$internal
  @override
  $FutureProviderElement<ChangeRecorder> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChangeRecorder> create(Ref ref) {
    return changeRecorder(ref);
  }
}

String _$changeRecorderHash() => r'6942fe5361e077aa4afed89c14e9c6907be1836b';
