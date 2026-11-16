import { FieldValue } from 'firebase-admin/firestore';
import {
  type CallableRequest,
  HttpsError,
  onCall,
} from 'firebase-functions/v2/https';

import { createInvite } from './invites.js';
import { requireProToShare } from './pro_gate.js';
import {
  callerName,
  optionalString,
  requireObject,
  requireString,
  requireUid,
} from './requests.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';
import { isSharedSpace, newSharedSpaceId } from './spaces.js';

/** What the app gets back: the share's space and a new invite for it. */
export interface ShareJointlyResult {
  readonly spaceId: string;
  readonly inviteId: string;
}

/**
 * Starts a joint share, or invites more people to one. Without `spaceId`,
 * creates a shared space with the caller as its only member; the app then
 * moves the recipe or folder into it by pushing its changes there
 * (ENGINEERING.md §8.4). With `spaceId`, the caller must be a member.
 * Either way returns a new invite link id.
 */
export const handleShareJointly =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<ShareJointlyResult> => {
    const uid = requireUid(request);
    const data = requireObject(request.data);
    const name = requireString(data, 'name');
    const existingSpaceId = optionalString(data, 'spaceId');
    const { firestore, now } = stores();
    const fromName = callerName(request);

    let spaceId: string;
    if (existingSpaceId === undefined) {
      await requireProToShare(firestore, uid, now());
      spaceId = newSharedSpaceId(firestore);
      await firestore.doc(`spaces/${spaceId}`).create({
        kind: 'shared',
        name,
        ownerUid: uid,
        memberUids: [uid],
        members: { [uid]: { name: fromName } },
        createdAt: FieldValue.serverTimestamp(),
      });
    } else {
      const space = (
        await firestore.doc(`spaces/${existingSpaceId}`).get()
      ).data();
      if (!isSharedSpace(space) || !space.memberUids.includes(uid)) {
        throw new HttpsError('not-found', 'No such share', {
          reason: 'notMember',
        });
      }
      spaceId = existingSpaceId;
    }

    const inviteId = await createInvite(
      firestore,
      { kind: 'joint', spaceId, title: name, fromUid: uid, fromName },
      now(),
    );
    return { spaceId, inviteId };
  };

/** Starts a joint share or makes another invite link for one (PRD 7.10). */
export const shareJointly = onCall(handleShareJointly(defaultSharingStores));
