import { FieldValue } from 'firebase-admin/firestore';
import {
  type CallableRequest,
  HttpsError,
  onCall,
} from 'firebase-functions/v2/https';

import { requireObject, requireString, requireUid } from './requests.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';
import { isSharedSpace } from './spaces.js';

/**
 * Removes [uid] from the shared space [spaceId]. The others keep the share;
 * if the owner leaves, the next member becomes the owner. When the last
 * member leaves, the space, its change log, its snapshots, and its invites
 * are deleted. Leaving a space you're not in does nothing.
 */
export const leaveSpace = async (
  stores: SharingStores,
  uid: string,
  spaceId: string,
): Promise<void> => {
  const { firestore, deleteFiles } = stores;
  const spaceRef = firestore.doc(`spaces/${spaceId}`);
  const emptied = await firestore.runTransaction(async (transaction) => {
    const space = (await transaction.get(spaceRef)).data();
    if (space === undefined) {
      return false;
    }
    if (!isSharedSpace(space)) {
      throw new HttpsError(
        'failed-precondition',
        'Only joint shares can be left',
        { reason: 'notShared' },
      );
    }
    if (!space.memberUids.includes(uid)) {
      return false;
    }
    const remaining = space.memberUids.filter((member) => member !== uid);
    if (remaining.length === 0) {
      return true;
    }
    transaction.update(spaceRef, {
      memberUids: FieldValue.arrayRemove(uid),
      [`members.${uid}`]: FieldValue.delete(),
      ...(space.ownerUid === uid ? { ownerUid: remaining[0] } : {}),
    });
    return false;
  });
  if (!emptied) {
    return;
  }
  const invites = await firestore
    .collection('invites')
    .where('spaceId', '==', spaceId)
    .get();
  await Promise.all(invites.docs.map((invite) => invite.ref.delete()));
  await firestore.recursiveDelete(spaceRef);
  await deleteFiles(`spaces/${spaceId}/`);
};

/**
 * Leaves a joint share. The app keeps its local copy of the recipes, moved
 * back into the user's own library (PRD 7.10).
 */
export const handleLeaveShare =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<{ left: true }> => {
    const uid = requireUid(request);
    const spaceId = requireString(requireObject(request.data), 'spaceId');
    await leaveSpace(stores(), uid, spaceId);
    return { left: true };
  };

/** Leaves a joint share (PRD 7.10). */
export const leaveShare = onCall(handleLeaveShare(defaultSharingStores));
