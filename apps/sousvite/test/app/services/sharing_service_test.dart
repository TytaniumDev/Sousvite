import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/sharing_service.dart';

void main() {
  group(SharingLinks, () {
    test('puts invites and pages on the web app', () {
      expect(
        SharingLinks.invite('abc').toString(),
        'https://sousvite.web.app/invite/abc',
      );
      expect(
        SharingLinks.page('xyz').toString(),
        'https://sousvite.web.app/r/xyz',
      );
    });
  });

  group(UnavailableSharingService, () {
    const service = UnavailableSharingService();
    final unavailable = throwsA(
      isA<SharingFailure>().having(
        (f) => f.reason,
        'reason',
        SharingFailureReason.unavailable,
      ),
    );

    test('fails every call as unavailable', () async {
      await expectLater(service.shareJointly(name: 'x'), unavailable);
      await expectLater(
        service.sendCopy(title: 'x', entities: const []),
        unavailable,
      );
      await expectLater(service.previewInvite('i'), unavailable);
      await expectLater(service.acceptInvite('i'), unavailable);
      await expectLater(service.leaveShare('s'), unavailable);
      await expectLater(
        service.publishLink(
          const SharedRecipePage(title: 'x', ingredients: [], steps: []),
        ),
        unavailable,
      );
      await expectLater(service.unpublishLink('l'), unavailable);
    });

    test('is the service without Firebase', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(sharingServiceProvider),
        isA<UnavailableSharingService>(),
      );
    });
  });

  group(SharingFailure, () {
    test('names its reason', () {
      expect(
        const SharingFailure(.expired, 'cause').toString(),
        'SharingFailure(expired): cause',
      );
    });
  });

  group(InvitePreview, () {
    test('compares by value', () {
      const a = InvitePreview(kind: .copy, title: 't', fromName: 'n');
      expect(a, const InvitePreview(kind: .copy, title: 't', fromName: 'n'));
      expect(
        a.hashCode,
        const InvitePreview(kind: .copy, title: 't', fromName: 'n').hashCode,
      );
      expect(a, isNot(const InvitePreview(kind: .joint, title: 't')));
      expect(
        const AcceptedJointShare(spaceId: 's', title: 't').hashCode,
        const AcceptedJointShare(spaceId: 's', title: 't').hashCode,
      );
    });
  });
}
