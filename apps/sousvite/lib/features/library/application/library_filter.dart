import 'package:domain/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_filter.g.dart';

/// The folder the library shows, or null for every recipe.
@riverpod
class LibraryFolder() extends _$LibraryFolder {
  @override
  FolderId? build() => null;

  // A setter would read oddly at call sites: `notifier.select(id)`.
  // ignore: use_setters_to_change_properties
  void select(FolderId? folderId) => state = folderId;
}

/// What the user typed into the library's search field.
@riverpod
class LibraryQuery() extends _$LibraryQuery {
  @override
  String build() => '';

  // A setter would read oddly at call sites: `notifier.update(text)`.
  // ignore: use_setters_to_change_properties
  void update(String query) => state = query;
}
