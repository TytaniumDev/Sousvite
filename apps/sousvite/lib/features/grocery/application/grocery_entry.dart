import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'grocery_entry.freezed.dart';

/// One amount of a grocery entry, in one unit or count word. An entry
/// made of items in different units shows each, such as "1 cup + 2 Tbsp".
typedef GroceryAmount = ({Quantity quantity, Unit? unit, String? countWord});

/// One row on the grocery list: every item with the same name, combined
/// across recipes and manual additions (PRD 7.7).
@freezed
abstract class const GroceryEntry._() with _$GroceryEntry {
  const factory({
    /// The normalized name the items were combined by. Stable while the
    /// entry exists, so it doubles as the row's key.
    required String key,

    /// The name shown, as the first item spelled it.
    required String name,

    /// The items this entry combines, in list order.
    required List<GroceryItem> items,

    /// The combined amounts, one per unit or count word, in the order they
    /// first appear.
    required List<GroceryAmount> amounts,

    /// The recipes the items came from, without repeats. Empty when every
    /// item was added by hand.
    required List<RecipeId> sourceRecipeIds,

    /// The store section the entry is grouped under, or null for "Other".
    String? storeSection,
  }) = _GroceryEntry;

  /// Whether every item in the entry is checked off.
  bool get checked => items.every((item) => item.checked);
}

/// Unchecked entries that share a store section.
@freezed
abstract class GrocerySection with _$GrocerySection {
  const factory({
    /// The store section, or null for entries with none ("Other").
    required String? name,

    /// Keys of the section's entries, in list order.
    required List<String> entryKeys,
  }) = _GrocerySection;
}

/// Which rows the screen shows and in what groups, without the rows'
/// contents. The list watches only this, so checking off an item rebuilds
/// its row alone unless it moves between groups.
@freezed
abstract class GroceryLayout with _$GroceryLayout {
  const factory({
    /// Sections of unchecked entries, in display order.
    required List<GrocerySection> sections,

    /// Keys of checked entries, in list order.
    required List<String> checkedKeys,
  }) = _GroceryLayout;
}

/// The grocery list as the screen shows it: unchecked entries grouped by
/// store section, then the checked ones (DESIGN_SYSTEM.md §10.6).
@freezed
abstract class const GroceryView._() with _$GroceryView {
  const factory({
    /// Sections of unchecked entries, in display order.
    required List<GrocerySection> sections,

    /// Keys of checked entries, in list order.
    required List<String> checkedKeys,

    /// Every entry by its key.
    required Map<String, GroceryEntry> entries,
  }) = _GroceryView;

  /// Whether the list has nothing on it.
  bool get isEmpty => entries.isEmpty;

  /// The groups and order of rows, for the list to watch.
  GroceryLayout get layout =>
      GroceryLayout(sections: sections, checkedKeys: checkedKeys);
}
