import { FieldValue } from 'firebase-admin/firestore';
import {
  type CallableRequest,
  HttpsError,
  onCall,
} from 'firebase-functions/v2/https';

import type { Invite } from './invites.js';
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
 * share, or the inbox item holding a copy to import.
 */
export type AcceptInviteResult =
  | { readonly kind: 'joint'; readonly spaceId: string; readonly title: string }
  | { readonly kind: 'copy'; readonly itemId: string; readonly title: string };

const notFound = (reason: 'inviteNotFound' | 'shareEnded'): HttpsError =>
  new HttpsError('not-found', 'This invite no longer works', { reason });

/**
 * Accepts an invite link. A joint invite adds the caller to the share's
 * members; accepting twice is harmless. A copy invite puts the copy in the
 * caller's inbox (`inbox/{uid}/items`), which the app imports and deletes.
 */
export const handleAcceptInvite =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<AcceptInviteResult> => {
    const uid = requireUid(request);
    const inviteId = requireString(requireObject(request.data), 'inviteId');
    const { firestore, now } = stores();

    const invite = (await firestore.doc(`invites/${inviteId}`).get()).data() as
      Invite | undefined;
    if (invite === undefined) {
      throw notFound('inviteNotFound');
    }
    if (invite.expiresAt.toMillis() <= now().getTime()) {
      throw new HttpsError('failed-precondition', 'This invite has expired', {
        reason: 'expired',
      });
    }

    switch (invite.kind) {
      case 'joint': {
        const spaceRef = firestore.doc(`spaces/${invite.spaceId}`);
        await firestore.runTransaction(async (transaction) => {
          const space = (await transaction.get(spaceRef)).data();
          if (!isSharedSpace(space)) {
            throw notFound('shareEnded');
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
      case 'copy': {
        const item = firestore.collection(`inbox/${uid}/items`).doc();
        await item.set({
          title: invite.title,
          fromName: invite.fromName,
          changes: invite.changes,
          receivedAt: FieldValue.serverTimestamp(),
        });
        return { kind: 'copy', itemId: item.id, title: invite.title };
      }
    }
  };

/** Accepts a joint-share or copy invite link (PRD 7.10). */
export const acceptInvite = onCall(handleAcceptInvite(defaultSharingStores));
