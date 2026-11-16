import { type CallableRequest, onCall } from 'firebase-functions/v2/https';

import { createInvite } from './invites.js';
import { requireProToShare } from './pro_gate.js';
import {
  callerName,
  invalid,
  requireFits,
  requireObject,
  requireString,
  requireUid,
} from './requests.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';

/** What the app gets back: the invite link id for the copy. */
export interface SendCopyResult {
  readonly inviteId: string;
}

/**
 * Makes an invite link that gives whoever opens it their own copy of a
 * recipe or folder. The app sends the current changes of everything it
 * copies; the recipient's app imports them with new ids, so the copies
 * never affect each other (PRD 7.10).
 */
export const handleSendCopy =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<SendCopyResult> => {
    const uid = requireUid(request);
    const data = requireObject(request.data);
    const title = requireString(data, 'title');
    const changes = data.changes;
    if (!Array.isArray(changes) || changes.length === 0) {
      throw invalid('Expected changes to be a non-empty list');
    }
    requireFits(changes, 'changes');
    const { firestore, now } = stores();
    await requireProToShare(firestore, uid, now());

    const inviteId = await createInvite(
      firestore,
      {
        kind: 'copy',
        title,
        fromUid: uid,
        fromName: callerName(request),
        changes,
      },
      now(),
    );
    return { inviteId };
  };

/** Makes a send-a-copy invite link (PRD 7.10). */
export const sendCopy = onCall(handleSendCopy(defaultSharingStores));
