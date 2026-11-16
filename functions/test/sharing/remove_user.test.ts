import { beforeEach, describe, expect, it } from 'vitest';

import { handleAcceptInvite } from '../../src/sharing/accept_invite.js';
import { removeUserFromSharing } from '../../src/sharing/remove_user.js';
import { handleSendCopy } from '../../src/sharing/send_copy.js';
import { handleShareJointly } from '../../src/sharing/share_jointly.js';
import { handlePublishLink } from '../../src/sharing/share_links.js';
import {
  callFrom,
  clearSharing,
  type TestSharingStores,
  testSharingStores,
} from '../helpers/sharing_test_stores.js';

describe('removeUserFromSharing', () => {
  let stores: TestSharingStores;

  beforeEach(async () => {
    stores = testSharingStores();
    await clearSharing(stores.firestore);
  });

  it("removes the user's sharing data and leaves their shares for the others", async () => {
    const shareJointly = handleShareJointly(() => stores);
    const acceptInvite = handleAcceptInvite(() => stores);
    const shared = await shareJointly(callFrom('alice', { name: 'Lasagna' }));
    await acceptInvite(callFrom('bob', { inviteId: shared.inviteId }));
    const alone = await shareJointly(callFrom('alice', { name: 'Soup' }));
    const copy = await handleSendCopy(() => stores)(
      callFrom('bob', { title: 'Pie', entities: [{}] }),
    );
    const link = await handlePublishLink(() => stores)(
      callFrom('alice', {
        recipe: { title: 'Soup', ingredients: [], steps: [] },
      }),
    );
    await stores.firestore
      .doc('spaces/u_alice')
      .set({ kind: 'private', ownerUid: 'alice', memberUids: ['alice'] });

    await removeUserFromSharing(stores, 'alice');

    const doc = (path: string) => stores.firestore.doc(path).get();
    expect((await doc(`spaces/${shared.spaceId}`)).data()).toMatchObject({
      ownerUid: 'bob',
      memberUids: ['bob'],
    });
    expect((await doc(`spaces/${alone.spaceId}`)).exists).toBe(false);
    expect((await doc(`invites/${shared.inviteId}`)).exists).toBe(false);
    expect((await doc(`invites/${copy.inviteId}`)).exists).toBe(true);
    expect((await doc(`shareLinks/${link.linkId}`)).exists).toBe(false);
    // Private spaces are removed with the account, not by sharing.
    expect((await doc('spaces/u_alice')).exists).toBe(true);
  });
});
