import 'package:design_system/design_system.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/recipe/presentation/recipe_photo.dart';
import 'package:sousvite/shared/photos/photos.dart';
import 'package:sousvite/shared/photos/stored_photo_image.dart';

import '../../../helpers/fakes/fake_photo_store.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const recipeId = RecipeId('r1');
  late FakeRecipeRepository recipes;
  late FakePhotoStore store;

  setUp(() {
    recipes = FakeRecipeRepository();
    store = FakePhotoStore();
  });

  Future<void> pump(
    WidgetTester tester, {
    String? photoRef,
    double width = 400,
  }) async {
    tester.view.physicalSize = Size(width, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    recipes.seed(recipe: RecipeFixtures.recipe().copyWith(photoRef: photoRef));
    await tester.pumpApp(
      const Scaffold(body: RecipePhoto(recipeId: recipeId)),
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        photoStoreProvider.overrideWithValue(store),
      ],
    );
    await tester.pump();
  }

  testWidgets('shows nothing for a recipe without a photo', (tester) async {
    await pump(tester);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the stored photo full width on phones', (tester) async {
    await pump(tester, photoRef: 'p1');
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, StoredPhotoImage(store, 'p1'));
    expect(find.byType(ClipRRect), findsNothing);
    expect(tester.getSize(find.byType(AspectRatio)).width, 400);
  });

  testWidgets('rounds the corners on wider screens', (tester) async {
    await pump(tester, photoRef: 'p1', width: 1200);
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, AppRadii.borderLg);
    expect(
      tester.getSize(find.byType(AspectRatio)).height,
      lessThanOrEqualTo(RecipePhoto.maxHeight),
    );
  });

  testWidgets('hides a photo that is not on this device', (tester) async {
    await pump(tester, photoRef: 'missing');
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(find.byType(RawImage), findsNothing);
  });
}
