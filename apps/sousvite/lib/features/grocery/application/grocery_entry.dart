import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'grocery_entry.freezed.dart';

/// One amount of a grocery entry, in one unit or count word. An entry
/// made of items that don't add up shows each, such as "1 cup + 2 cloves".
/// `approximate` is true for a total worked out from the items' weights,
/// such as cups and grams of sugar as cups.
typedef GroceryAmount = ({
  Quantity quantity,
  Unit? unit,
  String? countWord,
  bool approximate,
});

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

    /// The key of the entry each item name went into, by the name's
    /// `groceryKey`.
    @Default({}) Map<String, String> entryKeys,

    /// The key of the entry each matched food went into.
    @Default({}) Map<FoodId, String> entryKeysByFood,
  }) = _GroceryView;

  /// The entry a new line named [name], matched to [foodId], would combine
  /// with, or null when it would start a new one.
  GroceryEntry? entryFor(String name, {FoodId? foodId}) {
    final key =
        (foodId == null ? null : entryKeysByFood[foodId]) ??
        entryKeys[groceryKey(name)];
    return key == null ? null : entries[key];
  }

  /// Whether the list has nothing on it.
  bool get isEmpty => entries.isEmpty;

  /// The groups and order of rows, for the list to watch.
  GroceryLayout get layout =>
      GroceryLayout(sections: sections, checkedKeys: checkedKeys);
}
