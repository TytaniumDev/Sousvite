import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/grocery_line_name.dart';

import '../fakes.dart';

typedef _F = GroceryFixtures;

void main() {
  group('groceryNameOf', () {
    test('uses the parsed name, else the whole line', () {
      expect(
        groceryNameOf(_F.line('a', recipeId: 'r', name: 'flour')),
        'flour',
      );
      expect(
        groceryNameOf(_F.line('salt to taste', recipeId: 'r')),
        'salt to taste',
      );
    });
  });
}
