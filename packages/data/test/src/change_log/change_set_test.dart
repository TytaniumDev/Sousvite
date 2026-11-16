import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:sync/sync.dart';
import 'package:test/test.dart';

void main() {
  group(ChangeSet, () {
    test('records one pending change per field, in order', () {
      final changes = ChangeSet()
        ..set('recipe', 'r1', {'title': 'Soup', 'notes': null})
        ..set('ingredient_line', 'l1', {'name': 'salt'}, spaceId: 's1');

      expect(changes.pending, [
        (
          entity: 'recipe',
          entityId: 'r1',
          field: 'title',
          value: 'Soup',
          spaceId: null,
        ),
        (
          entity: 'recipe',
          entityId: 'r1',
          field: 'notes',
          value: null,
          spaceId: null,
        ),
        (
          entity: 'ingredient_line',
          entityId: 'l1',
          field: 'name',
          value: 'salt',
          spaceId: 's1',
        ),
      ]);
    });

    test('records a delete as the sync tombstone field', () {
      final changes = ChangeSet()..delete('recipe', 'r1');

      expect(changes.pending.single.field, Change.deletedField);
      expect(changes.pending.single.value, isTrue);
    });

    test('does not let callers edit what was recorded', () {
      final changes = ChangeSet()..set('recipe', 'r1', {'title': 'Soup'});

      expect(changes.pending.clear, throwsUnsupportedError);
    });

    group('setChanged', () {
      final codec = StepSectionCodec();
      const section = StepSection(
        id: StepSectionId('s1'),
        recipeId: RecipeId('r1'),
        name: 'Prep',
        sortKey: SortKey('a'),
      );

      test('records every field of a new entity and clears its tombstone', () {
        final changes = ChangeSet()..setChanged(codec, section);

        expect(changes.pending.map((change) => change.field), [
          'recipeId',
          'name',
          'sortKey',
          Change.deletedField,
        ]);
        expect(changes.pending.last.value, isFalse);
        expect(changes.pending.first.entity, 'step_section');
        expect(changes.pending.first.entityId, 's1');
      });

      test('records only the fields that changed', () {
        final changes = ChangeSet()
          ..setChanged(
            codec,
            section.copyWith(name: 'Bake'),
            before: section,
            spaceId: 'shared',
          );

        expect(changes.pending, [
          (
            entity: 'step_section',
            entityId: 's1',
            field: 'name',
            value: 'Bake',
            spaceId: 'shared',
          ),
        ]);
      });

      test('compares structured values by content', () {
        final codec = IngredientLineCodec();
        final line = IngredientLine(
          id: const IngredientLineId('l1'),
          recipeId: const RecipeId('r1'),
          rawText: '2 cups flour',
          sortKey: const SortKey('a'),
          quantity: Quantity(2),
        );

        final changes = ChangeSet()
          ..setChanged(codec, line.copyWith(), before: line);

        expect(changes.pending, isEmpty);
      });
    });
  });
}
