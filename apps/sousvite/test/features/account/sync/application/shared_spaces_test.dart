import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sousvite/app/services/auth_service.dart';
import 'package:sousvite/features/account/account.dart';
import 'package:sousvite/features/account/sync/application/shared_spaces.dart';
import 'package:sousvite/features/account/sync/data/space_memberships.dart';

import '../../fakes.dart';

void main() {
  group('sharedSpaceIdsProvider', () {
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await firestore.doc('spaces/s_1').set({
        'kind': 'shared',
        'memberUids': [tyler.id],
      });
    });

    ProviderContainer container({AuthUser? user}) => ProviderContainer.test(
      overrides: [
        authServiceProvider.overrideWithValue(FakeAuthService(user)),
        spaceMembershipsProvider.overrideWithValue(SpaceMemberships(firestore)),
      ],
    );

    /// Waits until [c] has read the user and their memberships.
    Future<void> load(ProviderContainer c) async {
      c.listen(sharedSpaceIdsProvider, (_, _) {});
      await c.read(authUserProvider.future);
      await c.read(sharedSpaceMembershipsProvider.future);
    }

    test('lists the shares the signed-in user is in', () async {
      final c = container(user: tyler);
      await load(c);
      expect(c.read(sharedSpaceIdsProvider), ['s_1']);
    });

    test('is empty while signed out', () async {
      final c = container();
      await load(c);
      expect(c.read(sharedSpaceIdsProvider), isEmpty);
    });

    test('is empty without Firebase', () async {
      final c = ProviderContainer.test(
        overrides: [
          authServiceProvider.overrideWithValue(FakeAuthService(tyler)),
        ],
      );
      expect(c.read(spaceMembershipsProvider), isNull);
      await load(c);
      expect(c.read(sharedSpaceIdsProvider), isEmpty);
    });
  });
}
