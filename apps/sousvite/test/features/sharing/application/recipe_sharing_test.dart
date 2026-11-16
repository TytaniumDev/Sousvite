import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/sharing/application/recipe_sharing.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../fakes.dart';

void main() {
  group(RecipeSharing, () {
    late FakeRecipeRepository repository;
    late FakeSharingService service;
    late RecipeSharing sharing;
    final source = RecipeSnapshot(
      recipe: RecipeFixtures.recipe(),
      ingredientLines: [RecipeFixtures.line('l1', rawText: '1 cup oats')],
      steps: [RecipeFixtures.step('s1', text: 'Mix.')],
    );

    setUp(() {
      repository = FakeRecipeRepository()
        ..seed(
          recipe: source.recipe,
          lines: source.ingredientLines,
          steps: source.steps,
        );
      service = FakeSharingService();
      sharing = RecipeSharing(repository: repository, service: service);
    });

    test('sends a copy as the whole recipe encoded', () async {
      final link = await sharing.sendCopy(const RecipeId('r1'));

      expect(link, SharingLinks.invite('copy1'));
      expect(const RecipeSnapshotCodec().decode(service.sentEntities!), source);
    });

    test('fails to share a recipe that does not exist', () async {
      await expectLater(
        sharing.sendCopy(const RecipeId('nope')),
        throwsStateError,
      );
    });

    test('publishes a link with the yield text', () async {
      final linkId = await sharing.publishLink(
        const RecipeId('r1'),
        yieldText: (recipe) => 'Serves ${recipe.title}',
      );

      expect(linkId, 'link1');
      expect(service.publishedPage?.yieldText, 'Serves Oat pancakes');
      await sharing.unpublishLink(linkId);
      expect(service.unpublished, ['link1']);
    });

    test('previews invites', () async {
      expect(await sharing.previewInvite('i1'), service.preview);
    });

    test('saves an accepted copy with new ids', () async {
      service.accepted = AcceptedCopy(
        title: 'Oat pancakes',
        entities: const RecipeSnapshotCodec().encode(source),
      );

      final copyId = await sharing.accept('i1');

      expect(copyId, isNot(const RecipeId('r1')));
      final copy = await repository.getSnapshot(copyId!);
      expect(copy?.recipe.title, 'Oat pancakes');
      expect(copy?.ingredientLines.single.rawText, '1 cup oats');
      expect(
        copy?.ingredientLines.single.id,
        isNot(const IngredientLineId('l1')),
      );
    });

    test('fails on a copy with no recipe in it', () async {
      service.accepted = const AcceptedCopy(title: 'x', entities: []);

      await expectLater(
        sharing.accept('i1'),
        throwsA(
          isA<SharingFailure>().having(
            (f) => f.reason,
            'reason',
            SharingFailureReason.notFound,
          ),
        ),
      );
    });

    test('returns no recipe for a joint share', () async {
      service.accepted = const AcceptedJointShare(spaceId: 's_1', title: 'x');

      expect(await sharing.accept('i1'), isNull);
    });
  });
}
