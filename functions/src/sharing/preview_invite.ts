import { type CallableRequest, onCall } from 'firebase-functions/v2/https';

import { type InviteKind, readInvite } from './invites.js';
import { requireObject, requireString, requireUid } from './requests.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';

/** What the app shows before the user accepts an invite. */
export interface InvitePreview {
  readonly kind: InviteKind;
  readonly title: string;
  readonly fromName: string | null;
}

/**
 * Says what an invite link offers, so the recipient sees whether it is a
 * joint share or a copy before accepting (PRD 7.10).
 */
export const handlePreviewInvite =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<InvitePreview> => {
    requireUid(request);
    const inviteId = requireString(requireObject(request.data), 'inviteId');
    const { firestore, now } = stores();
    const { kind, title, fromName } = await readInvite(
      firestore,
      inviteId,
      now(),
    );
    return { kind, title, fromName };
  };

/** Describes an invite link before it is accepted. */
export const previewInvite = onCall(handlePreviewInvite(defaultSharingStores));
