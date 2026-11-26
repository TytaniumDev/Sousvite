import 'package:domain/domain.dart';
import 'package:nutrition/nutrition.dart';
import 'package:sousvite/features/grocery/application/grocery_amounts.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// Combines a list's items into entries grouped by store section.
///
/// Items become one entry when their names share a [groceryKey] ("2
/// onions" and "1 onion"), or when the recipe lines they came from matched
/// the same food in [matches] ("sugar" and "granulated sugar") and the
/// user hasn't separated them (`GroceryItem.combinesByFood`). Amounts are
/// added by [groceryAmounts], which weighs them with the matches, or with
/// [densityOf] the entry's name, to put cups and grams together. An item's
/// section is the one stored on it, else the one [StoreSection.of] finds
/// for its name.
///
/// [items] must be in list order. Sections follow the store's walking order
/// ([StoreSection.values]), then sections the user named, alphabetically,
/// with "Other" last.
GroceryView combineGroceryItems(
  List<GroceryItem> items, {
  Map<IngredientLineId, NutritionMatch> matches = const {},
}) {
  FoodId? foodOf(GroceryItem item) =>
      item.combinesByFood ? matches[item.sourceIngredientLineId]?.foodId : null;

  final groups = _group(items, foodOf);
  final entries = <String, GroceryEntry>{};
  final entryKeys = <String, String>{};
  final entryKeysByFood = <FoodId, String>{};
  for (final group in groups) {
    final entry = _entry(group, matches);
    entries[entry.key] = entry;
    for (final item in group) {
      entryKeys[groceryKey(item.name)] = entry.key;
      if (foodOf(item) case final food?) entryKeysByFood[food] = entry.key;
    }
  }

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
    entryKeys: entryKeys,
    entryKeysByFood: entryKeysByFood,
  );
}

/// [items] split into groups that combine: items join a group when they
/// share its name key or its food, and two groups an item shares both
/// with become one. Groups and their items keep list order.
List<List<GroceryItem>> _group(
  List<GroceryItem> items,
  FoodId? Function(GroceryItem item) foodOf,
) {
  // Union-find over item indexes: each group is named by its first item.
  final parent = List.generate(items.length, (index) => index);
  int root(int index) {
    var at = index;
    while (parent[at] != at) {
      at = parent[at] = parent[parent[at]];
    }
    return at;
  }

  void join(int a, int b) {
    final (ra, rb) = (root(a), root(b));
    if (ra < rb) parent[rb] = ra;
    if (rb < ra) parent[ra] = rb;
  }

  final firstByName = <String, int>{};
  final firstByFood = <FoodId, int>{};
  for (final (index, item) in items.indexed) {
    join(index, firstByName.putIfAbsent(groceryKey(item.name), () => index));
    if (foodOf(item) case final food?) {
      join(index, firstByFood.putIfAbsent(food, () => index));
    }
  }
  final groups = <int, List<GroceryItem>>{};
  for (final (index, item) in items.indexed) {
    (groups[root(index)] ??= []).add(item);
  }
  return groups.values.toList();
}

/// One entry for a [group] of items. Its key is the first item's name key,
/// which stays put while that item is on the list. Its name is the
/// shortest one in the group, so "sugar" names sugar and granulated sugar.
GroceryEntry _entry(
  List<GroceryItem> group,
  Map<IngredientLineId, NutritionMatch> matches,
) {
  final name = group
      .map((item) => item.name.trim())
      .reduce((a, b) => b.length < a.length ? b : a);
  final density = densityOf(name);
  return GroceryEntry(
    key: groceryKey(group.first.name),
    name: name,
    items: group,
    amounts: groceryAmounts(
      group,
      gramsOf: (item) => _gramsOf(item, matches, density),
    ),
    sourceRecipeIds: {for (final item in group) ?item.sourceRecipeId}.toList(),
    storeSection: _section(
      group
          .map((item) => item.storeSection)
          .firstWhere((section) => section != null, orElse: () => null),
      name,
    ),
  );
}

/// How much [item] weighs: exactly for a weight, else from its line's
/// match, else from the item's [density] for a volume. Null when none of
/// those knows.
double? _gramsOf(
  GroceryItem item,
  Map<IngredientLineId, NutritionMatch> matches,
  double? density,
) {
  final amount = Amount(item.quantity!, item.unit);
  if (item.unit?.dimension == .mass) return amount.approximateValueIn(.gram);
  final matched = matches[item.sourceIngredientLineId]?.gramWeight;
  if (matched != null && matched > 0) return matched;
  final milliliters = amount.approximateValueIn(.milliliter);
  return milliliters == null || density == null ? null : milliliters * density;
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
