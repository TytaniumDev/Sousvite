import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/sharing_service.dart';
import 'package:sousvite/features/sharing/application/recipe_sharing.dart';

import '../../../helpers/fakes/fake_recipe_repository.dart';
import '../../../helpers/fakes/fake_recipe_space_repository.dart';
import '../../../helpers/fakes/recipe_fixtures.dart';
import '../fakes.dart';

void main() {
  group(RecipeSharing, () {
    late FakeRecipeRepository repository;
    late FakeRecipeSpaceRepository spaces;
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
      spaces = FakeRecipeSpaceRepository();
      service = FakeSharingService();
      sharing = RecipeSharing(
        repository: repository,
        spaces: spaces,
        service: service,
      );
    });

    test('starts a joint share and moves the recipe into it', () async {
      final link = await sharing.shareJointly(const RecipeId('r1'));

      expect(link, SharingLinks.invite('joint1'));
      expect(service.jointSpaceIds, [null]);
      expect(await spaces.sharedSpaceOf(const RecipeId('r1')), 's_1');
    });

    test('invites more people to the share a recipe is in', () async {
      spaces.seed(const RecipeId('r1'), 's_9');

      await sharing.shareJointly(const RecipeId('r1'));

      expect(service.jointSpaceIds, ['s_9']);
      expect(await spaces.sharedSpaceOf(const RecipeId('r1')), 's_9');
    });

    test('fails to share a missing recipe jointly', () async {
      await expectLater(
        sharing.shareJointly(const RecipeId('nope')),
        throwsStateError,
      );
      expect(service.jointSpaceIds, isEmpty);
    });

    test("leaves a share, keeping its recipes as the user's own", () async {
      spaces
        ..seed(const RecipeId('r1'), 's_1')
        ..seed(const RecipeId('r2'), 's_1')
        ..seed(const RecipeId('r3'), 's_2');

      await sharing.leaveJointShare(const RecipeId('r1'));

      expect(service.left, ['s_1']);
      expect(await spaces.recipesInSharedSpace('s_1'), isEmpty);
      expect(await spaces.sharedSpaceOf(const RecipeId('r3')), 's_2');
    });

    test('does nothing when leaving a recipe that is not shared', () async {
      await sharing.leaveJointShare(const RecipeId('r1'));

      expect(service.left, isEmpty);
    });

    test('keeps the recipe shared when leaving fails', () async {
      spaces.seed(const RecipeId('r1'), 's_1');
      service.error = const SharingFailure(.unavailable);

      await expectLater(
        sharing.leaveJointShare(const RecipeId('r1')),
        throwsA(isA<SharingFailure>()),
      );
      expect(await spaces.sharedSpaceOf(const RecipeId('r1')), 's_1');
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
