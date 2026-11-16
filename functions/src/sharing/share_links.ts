import { FieldValue } from 'firebase-admin/firestore';
import {
  type CallableRequest,
  HttpsError,
  onCall,
} from 'firebase-functions/v2/https';

import {
  optionalString,
  requireObject,
  requireString,
  requireUid,
} from './requests.js';
import { parseSharedRecipe } from './shared_recipe.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';

/** What the app gets back: the link id, shown at `/r/{linkId}`. */
export interface PublishLinkResult {
  readonly linkId: string;
}

const requireOwnLink = async (
  stores: SharingStores,
  uid: string,
  linkId: string,
): Promise<FirebaseFirestore.DocumentReference> => {
  const ref = stores.firestore.doc(`shareLinks/${linkId}`);
  const link = (await ref.get()).data();
  if (link?.ownerUid !== uid) {
    throw new HttpsError('not-found', 'No such link', {
      reason: 'linkNotFound',
    });
  }
  return ref;
};

/**
 * Publishes a recipe at a view-only link anyone can open, even without the
 * app (PRD 7.10). With `linkId`, republishes the caller's existing link so
 * it shows the recipe's latest version. Free for everyone (PRD 7.12).
 */
export const handlePublishLink =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<PublishLinkResult> => {
    const uid = requireUid(request);
    const data = requireObject(request.data);
    const recipe = parseSharedRecipe(data.recipe);
    const existing = optionalString(data, 'linkId');
    const resolved = stores();
    const ref =
      existing === undefined
        ? resolved.firestore.collection('shareLinks').doc()
        : await requireOwnLink(resolved, uid, existing);
    await ref.set({
      ownerUid: uid,
      recipe,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { linkId: ref.id };
  };

/** Turns off one of the caller's view-only links. */
export const handleUnpublishLink =
  (stores: () => SharingStores) =>
  async (request: CallableRequest<unknown>): Promise<{ deleted: true }> => {
    const uid = requireUid(request);
    const linkId = requireString(requireObject(request.data), 'linkId');
    const ref = await requireOwnLink(stores(), uid, linkId);
    await ref.delete();
    return { deleted: true };
  };

/** Publishes or updates a view-only recipe link. */
export const publishLink = onCall(handlePublishLink(defaultSharingStores));

/** Turns off a view-only recipe link. */
export const unpublishLink = onCall(handleUnpublishLink(defaultSharingStores));
