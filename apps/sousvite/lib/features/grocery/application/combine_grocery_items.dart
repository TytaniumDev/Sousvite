import 'package:domain/domain.dart';
import 'package:sousvite/features/grocery/application/grocery_amounts.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// Combines a list's items into entries grouped by store section.
///
/// Items whose names share a [groceryKey] ("2 onions" and "1 onion") become
/// one entry, with amounts added by [groceryAmounts]. An item's section is
/// the one stored on it, else the one [StoreSection.of] finds for its name.
///
/// [items] must be in list order. Sections follow the store's walking order
/// ([StoreSection.values]), then sections the user named, alphabetically,
/// with "Other" last.
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

GroceryEntry _entry(String key, List<GroceryItem> items) {
  final name = items.first.name.trim();
  return GroceryEntry(
    key: key,
    name: name,
    items: items,
    amounts: groceryAmounts(items),
    sourceRecipeIds: {for (final item in items) ?item.sourceRecipeId}.toList(),
    storeSection: _section(
      items
          .map((item) => item.storeSection)
          .firstWhere((section) => section != null, orElse: () => null),
      name,
    ),
  );
}

/// The section to group under: [stored] if the item has one, else the
/// keyword table's. Null for "Other".
String? _section(String? stored, String name) {
  final section = stored ?? StoreSection.of(name).name;
  return section == StoreSection.other.name ? null : section;
}

int _compareSections(String? a, String? b) => switch ((a, b)) {
  (null, null) => 0,
  (null, _) => 1,
  (_, null) => -1,
  (final a?, final b?) => switch ((
    StoreSection.byName(a),
    StoreSection.byName(b),
  )) {
    (final a?, final b?) => a.index.compareTo(b.index),
    (_?, null) => -1,
    (null, _?) => 1,
    (null, null) => a.toLowerCase().compareTo(b.toLowerCase()),
  },
};
