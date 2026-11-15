import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/grocery/application/excluded_ingredients.dart';

void main() {
  group(ExcludedIngredients, () {
    const recipeId = RecipeId('soup');
    const lineId = IngredientLineId('salt');

    test('includes every line until one is toggled', () {
      final container = ProviderContainer.test();
      final provider = excludedIngredientsProvider(recipeId);
      final subscription = container.listen(provider, (_, _) {});

      expect(subscription.read(), isEmpty);

      container.read(provider.notifier).toggle(lineId);
      expect(subscription.read(), {lineId});

      container.read(provider.notifier).toggle(lineId);
      expect(subscription.read(), isEmpty);
    });
  });
}
