import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sousvite/features/library/application/library_scope.dart';

part 'library_filter.g.dart';

/// What the user typed into the search field of the page showing [scope].
/// Each page keeps its own search.
@riverpod
class LibraryQuery() extends _$LibraryQuery {
  @override
  String build(LibraryScope scope) => '';

  // A setter would read oddly at call sites: `notifier.update(text)`.
  // ignore: use_setters_to_change_properties
  void update(String query) => state = query;
}

/// Whether the search field of the page showing [scope] has words in it.
@riverpod
bool isSearching(Ref ref, LibraryScope scope) => ref.watch(
  libraryQueryProvider(scope).select((query) => query.trim().isNotEmpty),
);
