import { leaveSpace } from './leave_share.js';
import type { SharingStores } from './sharing_stores.js';

/**
 * Removes everything sharing stores for [uid], for account deletion
 * (PRD 7.9): leaves every joint share (the others keep it), and deletes the
 * user's invites and view-only links.
 */
export const removeUserFromSharing = async (
  stores: SharingStores,
  uid: string,
): Promise<void> => {
  const { firestore } = stores;
  const spaces = await firestore
    .collection('spaces')
    .where('memberUids', 'array-contains', uid)
    .get();
  // Filtered here rather than in the query, which would need a composite
  // index. Private spaces can't be left; deleting the account removes them.
  const shared = spaces.docs.filter((space) => space.data().kind === 'shared');
  for (const space of shared) {
    await leaveSpace(stores, uid, space.id);
  }

  const [invites, links] = await Promise.all([
    firestore.collection('invites').where('fromUid', '==', uid).get(),
    firestore.collection('shareLinks').where('ownerUid', '==', uid).get(),
  ]);
  await Promise.all(
    [...invites.docs, ...links.docs].map((document) => document.ref.delete()),
  );
};
