import { FieldValue } from 'firebase-admin/firestore';
import {
  type CallableRequest,
  HttpsError,
  onCall,
} from 'firebase-functions/v2/https';

import { readInvite } from './invites.js';
import {
  callerName,
  requireObject,
  requireString,
  requireUid,
} from './requests.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';
import { isSharedSpace } from './spaces.js';

/**
 * What accepting gives the app: the space to start syncing for a joint
 * share, or the copied entities to import with new ids.
 */
export type AcceptInviteResult =
  | { readonly kind: 'joint'; readonly spaceId: string; readonly title: string }
  | {
      readonly kind: 'copy';
      readonly title: string;
      readonly entities: readonly unknown[];
    };

/**
 * Accepts an invite link. A joint invite adds the caller to the share's
 * members; accepting twice is harmless. A copy invite returns the copy,
 * which the app saves into the user's own library, from where it syncs to
 * their other devices like any recipe.
 */
export const handleAcceptInvite =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<AcceptInviteResult> => {
    const uid = requireUid(request);
    const inviteId = requireString(requireObject(request.data), 'inviteId');
    const { firestore, now } = stores();
    const invite = await readInvite(firestore, inviteId, now());

    switch (invite.kind) {
      case 'joint': {
        const spaceRef = firestore.doc(`spaces/${invite.spaceId}`);
        await firestore.runTransaction(async (transaction) => {
          const space = (await transaction.get(spaceRef)).data();
          if (!isSharedSpace(space)) {
            throw new HttpsError('not-found', 'This share has ended', {
              reason: 'shareEnded',
            });
          }
          if (space.memberUids.includes(uid)) {
            return;
          }
          transaction.update(spaceRef, {
            memberUids: FieldValue.arrayUnion(uid),
            [`members.${uid}`]: { name: callerName(request) },
          });
        });
        return { kind: 'joint', spaceId: invite.spaceId, title: invite.title };
      }
      case 'copy':
        return { kind: 'copy', title: invite.title, entities: invite.entities };
    }
  };

/** Accepts a joint-share or copy invite link (PRD 7.10). */
export const acceptInvite = onCall(handleAcceptInvite(defaultSharingStores));
