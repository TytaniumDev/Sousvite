import 'package:domain/domain.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// Combines a list's items into entries grouped by store section.
///
/// A stand-in for GRO-1's combining in `packages/domain`
/// (docs/BUILD_PLAN.md §6.3): it merges items whose names match exactly,
/// ignoring case and spacing, and adds amounts only when their units are the
/// same or convert exactly (2 Tbsp into ⅛ cup). GRO-1 adds plurals ("onion"
/// and "onions") and store sections from its keyword table, then replaces
/// this function.
///
/// [items] must be in list order. Sections are sorted by name with "Other"
/// (no section) last.
GroceryView combineGroceryItems(List<GroceryItem> items) {
  final itemsByKey = <String, List<GroceryItem>>{};
  for (final item in items) {
    itemsByKey.putIfAbsent(groceryKey(item.name), () => []).add(item);
  }

  final entries = {
    for (final MapEntry(:key, :value) in itemsByKey.entries)
      key: _entry(key, value),
  };

  final keysBySection = <String?, List<String>>{};
  final checkedKeys = <String>[];
  for (final entry in entries.values) {
    if (entry.checked) {
      checkedKeys.add(entry.key);
    } else {
      keysBySection.putIfAbsent(entry.storeSection, () => []).add(entry.key);
    }
  }
  final sectionNames = keysBySection.keys.toList()..sort(_compareSections);

  return GroceryView(
    sections: [
      for (final name in sectionNames)
        GrocerySection(name: name, entryKeys: keysBySection[name]!),
    ],
    checkedKeys: checkedKeys,
    entries: entries,
  );
}

/// The key items are combined by: the name in lower case, with runs of
/// whitespace collapsed.
String groceryKey(String name) =>
    name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

GroceryEntry _entry(String key, List<GroceryItem> items) {
  final totals = <Unit?, Quantity>{};
  for (final item in items) {
    final quantity = item.quantity;
    if (quantity == null) continue;
    final amount = Amount(quantity, item.unit);
    // Add to the first total this converts into exactly, in that unit.
    final (unit, converted) = totals.keys
        .map((unit) => (unit, _convert(amount, unit)))
        .firstWhere(
          (pair) => pair.$2 != null,
          orElse: () => (item.unit, quantity),
        );
    totals.update(
      unit,
      (total) => total + converted!,
      ifAbsent: () => converted!,
    );
  }
  return GroceryEntry(
    key: key,
    name: items.first.name.trim(),
    items: items,
    amounts: [
      for (final MapEntry(key: unit, value: quantity) in totals.entries)
        (quantity: quantity, unit: unit),
    ],
    sourceRecipeIds: {for (final item in items) ?item.sourceRecipeId}.toList(),
    storeSection: items
        .map((item) => item.storeSection)
        .firstWhere((section) => section != null, orElse: () => null),
  );
}

int _compareSections(String? a, String? b) => switch ((a, b)) {
  (null, null) => 0,
  (null, _) => 1,
  (_, null) => -1,
  (final a?, final b?) => a.toLowerCase().compareTo(b.toLowerCase()),
};

/// [amount] counted in [unit], or null when it doesn't convert exactly.
Quantity? _convert(Amount amount, Unit? unit) {
  if (amount.unit == unit) return amount.quantity;
  if (unit == null) return null;
  return amount.convertTo(unit)?.quantity;
}
