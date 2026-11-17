import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sousvite/app/services/firebase_sharing_service.dart';
import 'package:sousvite/app/services/sharing_service.dart';

class _MockFunctions() extends Mock implements FirebaseFunctions;

class _MockCallable() extends Mock implements HttpsCallable;

class _MockResult()
    extends Mock
    implements HttpsCallableResult<Map<Object?, Object?>>;

void main() {
  group(FirebaseSharingService, () {
    late _MockFunctions functions;
    late _MockCallable callable;
    late FirebaseSharingService service;

    setUp(() {
      functions = _MockFunctions();
      callable = _MockCallable();
      service = FirebaseSharingService(functions);
      when(() => functions.httpsCallable(any())).thenReturn(callable);
    });

    void answer(Map<Object?, Object?> data) {
      final result = _MockResult();
      when(() => result.data).thenReturn(data);
      when(() => callable.call<Map<Object?, Object?>>(any<Object?>()))
          .thenAnswer((_) async => result);
    }

    Object? sentTo(String name) {
      verify(() => functions.httpsCallable(name)).called(1);
      return verify(
        () => callable.call<Map<Object?, Object?>>(captureAny<Object?>()),
      ).captured.single;
    }

    test('starts a joint share', () async {
      answer({'spaceId': 's_1', 'inviteId': 'i1'});

      final result = await service.shareJointly(name: 'Soup', spaceId: 's_1');

      expect(result.spaceId, 's_1');
      expect(result.invite, Uri.parse('https://sousvite.web.app/invite/i1'));
      expect(sentTo('shareJointly'), {'name': 'Soup', 'spaceId': 's_1'});
    });

    test('sends a copy', () async {
      answer({'inviteId': 'i2'});
      final entities = [
        {'entity': 'recipe'},
      ];

      final link = await service.sendCopy(title: 'Soup', entities: entities);

      expect(link, SharingLinks.invite('i2'));
      expect(sentTo('sendCopy'), {'title': 'Soup', 'entities': entities});
    });

    test('previews an invite', () async {
      answer({'kind': 'joint', 'title': 'Soup', 'fromName': null});

      expect(
        await service.previewInvite('i1'),
        const InvitePreview(kind: InviteKind.joint, title: 'Soup'),
      );
      expect(sentTo('previewInvite'), {'inviteId': 'i1'});
    });

    test('accepts joint and copy invites', () async {
      answer({'kind': 'joint', 'spaceId': 's_1', 'title': 'Soup'});
      expect(
        await service.acceptInvite('i1'),
        const AcceptedJointShare(spaceId: 's_1', title: 'Soup'),
      );

      answer({
        'kind': 'copy',
        'title': 'Soup',
        'entities': [
          {'entity': 'recipe'},
        ],
      });
      final copy = await service.acceptInvite('i2');
      expect(copy, isA<AcceptedCopy>());
      expect((copy as AcceptedCopy).entities, hasLength(1));
      expect(copy.title, 'Soup');
    });

    test('leaves a share and turns off a link', () async {
      answer({});

      await service.leaveShare('s_1');
      expect(sentTo('leaveShare'), {'spaceId': 's_1'});

      await service.unpublishLink('l1');
      expect(sentTo('unpublishLink'), {'linkId': 'l1'});
    });

    test('publishes a link', () async {
      answer({'linkId': 'l1'});
      const page = SharedRecipePage(
        title: 'Soup',
        ingredients: [],
        steps: [
          SharedSection(title: null, items: ['Boil.']),
        ],
      );

      expect(await service.publishLink(page, linkId: 'l0'), 'l1');
      expect(sentTo('publishLink'), {'recipe': page.toJson(), 'linkId': 'l0'});
    });

    test('turns function errors into sharing failures', () async {
      Future<SharingFailureReason> reasonFor(
        String code, [
        Object? details,
      ]) async {
        when(() => callable.call<Map<Object?, Object?>>(any<Object?>()))
            .thenThrow(
              FirebaseFunctionsException(
                code: code,
                message: 'x',
                details: details,
              ),
            );
        try {
          await service.leaveShare('s');
        } on SharingFailure catch (failure) {
          return failure.reason;
        }
        throw StateError('Expected a failure');
      }

      expect(
        await reasonFor('unauthenticated'),
        SharingFailureReason.signedOut,
      );
      expect(
        await reasonFor('failed-precondition', {'reason': 'expired'}),
        SharingFailureReason.expired,
      );
      expect(
        await reasonFor('not-found', {'reason': 'shareEnded'}),
        SharingFailureReason.shareEnded,
      );
      expect(
        await reasonFor('permission-denied', {'reason': 'proRequired'}),
        SharingFailureReason.proRequired,
      );
      expect(
        await reasonFor('invalid-argument', {'reason': 'tooLarge'}),
        SharingFailureReason.tooLarge,
      );
      expect(await reasonFor('not-found'), SharingFailureReason.notFound);
      expect(await reasonFor('unavailable'), SharingFailureReason.unavailable);
    });
  });
}
