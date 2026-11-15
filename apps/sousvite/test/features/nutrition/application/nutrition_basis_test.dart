import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/features/nutrition/application/nutrition_basis.dart';

import '../fakes.dart';

void main() {
  test('nutrition starts per serving and can switch to the batch', () {
    final container = ProviderContainer.test();
    final provider = nutritionBasisControllerProvider(
      NutritionFixtures.recipeId,
    );
    final subscription = container.listen(provider, (_, _) {});

    expect(subscription.read(), NutritionBasis.perServing);

    container.read(provider.notifier).select(.batch);

    expect(subscription.read(), NutritionBasis.batch);
  });
}
