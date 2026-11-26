import 'package:domain/domain.dart';
import 'package:sousvite/features/grocery/application/grocery_entry.dart';

/// One name a grocery entry took in only because its lines matched the
/// same food ("granulated sugar" in a "sugar" entry), with the items that
/// carry it.
typedef GroceryFoodMerge = ({String name, List<GroceryItem> items});

/// The names in [entry] other than its own, in the order they first
/// appear. Items of another name are in the entry only through a food
/// match, so separating them undoes exactly that merge.
List<GroceryFoodMerge> groceryFoodMerges(GroceryEntry entry) {
  final ownKey = groceryKey(entry.name);
  final merges = <String, GroceryFoodMerge>{};
  for (final item in entry.items) {
    final key = groceryKey(item.name);
    if (key == ownKey) continue;
    merges
        .putIfAbsent(key, () => (name: item.name.trim(), items: []))
        .items
        .add(item);
  }
  return merges.values.toList();
}
