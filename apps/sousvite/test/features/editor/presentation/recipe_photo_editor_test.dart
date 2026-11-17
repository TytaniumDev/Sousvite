import 'dart:typed_data';

import 'package:domain/domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sousvite/app/providers/repositories.dart';
import 'package:sousvite/features/editor/application/editor_draft.dart';
import 'package:sousvite/features/editor/presentation/recipe_photo_editor.dart';
import 'package:sousvite/shared/photos/photos.dart';

import '../../../helpers/fakes/fake_photo_picker.dart';
import '../../../helpers/fakes/fake_photo_store.dart';
import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../../../helpers/helpers.dart';

void main() {
  const recipeId = RecipeId('r1');
  late FakeRecipeRepository recipes;
  late FakePhotoStore store;
  late FakePhotoPicker picker;

  setUp(() {
    recipes = FakeRecipeRepository();
    store = FakePhotoStore();
    picker = FakePhotoPicker();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    String? photoRef,
    PhotoPicker? photoPicker,
  }) async {
    recipes.seed(recipe: RecipeFixtures.recipe().copyWith(photoRef: photoRef));
    await tester.pumpApp(
      const Scaffold(body: RecipePhotoEditor(recipeId: recipeId)),
      overrides: [
        recipeRepositoryProvider.overrideWithValue(recipes),
        photoStoreProvider.overrideWithValue(store),
        photoPickerProvider.overrideWithValue(photoPicker ?? picker),
        recipePhotosProvider.overrideWithValue(
          RecipePhotos(
            store: store,
            download: (_) async => Uint8List(0),
            newId: () => 'new-photo',
            shrink: (bytes) async {
              if (bytes.isEmpty) throw const PhotoFailure();
              return bytes;
            },
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(RecipePhotoEditor)),
    );
  }

  String? draftPhoto(ProviderContainer container) => container
      .read(editorDraftProvider(recipeId))
      .value
      ?.draft
      .recipe
      .photoRef;

  testWidgets('adds a chosen photo to the draft', (tester) async {
    final container = await pump(tester);
    expect(find.byType(Image), findsNothing);
    picker.next = Uint8List.fromList([1, 2]);

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();

    expect(picker.requests, [PhotoSource.library]);
    expect(store.photos['new-photo'], [1, 2]);
    expect(draftPhoto(container), 'new-photo');
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Change photo'), findsOneWidget);
  });

  testWidgets('takes a photo with the camera', (tester) async {
    final container = await pump(tester);
    picker.next = Uint8List.fromList([3]);

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    expect(find.text('Remove photo'), findsNothing);
    await tester.tap(find.text('Take a photo'));
    await tester.pumpAndSettle();

    expect(picker.requests, [PhotoSource.camera]);
    expect(draftPhoto(container), 'new-photo');
  });

  testWidgets('offers no camera where there is none', (tester) async {
    await pump(tester, photoPicker: FakePhotoPicker(canTakePhoto: false));

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();

    expect(find.text('Take a photo'), findsNothing);
    expect(find.text('Choose a photo'), findsOneWidget);
  });

  testWidgets('keeps the photo when the user cancels', (tester) async {
    final container = await pump(tester, photoRef: 'old');

    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();

    expect(draftPhoto(container), 'old');
    expect(store.photos, isEmpty);
  });

  testWidgets('says so when the file is not a photo', (tester) async {
    final container = await pump(tester);
    picker.next = Uint8List(0);

    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose a photo'));
    await tester.pumpAndSettle();

    expect(
      find.text("That photo couldn't be opened. Try another one."),
      findsOneWidget,
    );
    expect(draftPhoto(container), isNull);
  });

  testWidgets('removes the photo from the draft', (tester) async {
    final container = await pump(tester, photoRef: 'old');
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove photo'));
    await tester.pumpAndSettle();

    expect(draftPhoto(container), isNull);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Add photo'), findsOneWidget);
  });
}
