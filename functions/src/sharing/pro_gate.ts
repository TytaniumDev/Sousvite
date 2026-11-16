import type { Firestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';

/**
 * Whether sharing needs Pro. Off during the beta, so everyone can share and
 * real server costs can be measured (ENGINEERING.md §9.2). Matches
 * `proRequired()` in firestore.rules; turn both on together.
 */
export const proRequired = false;

/**
 * Whether [uid] has an active Pro entitlement, as written by the
 * subscription webhook (PRO-1) to `users/{uid}/private/entitlement`.
 */
export const hasPro = async (
  firestore: Firestore,
  uid: string,
  now: Date,
): Promise<boolean> => {
  const snapshot = await firestore
    .doc(`users/${uid}/private/entitlement`)
    .get();
  const data = snapshot.data();
  if (data?.pro !== true) {
    return false;
  }
  const expiresAt = data.expiresAt as { toMillis(): number } | undefined;
  return expiresAt === undefined || expiresAt.toMillis() > now.getTime();
};

/**
 * Throws unless [uid] may start a share: always during the beta, and only
 * with Pro once [required] is on. Recipients never need Pro (PRD 7.12).
 */
export const requireProToShare = async (
  firestore: Firestore,
  uid: string,
  now: Date,
  required: boolean = proRequired,
): Promise<void> => {
  if (required && !(await hasPro(firestore, uid, now))) {
    throw new HttpsError('permission-denied', 'Sharing needs Sousvite Pro', {
      reason: 'proRequired',
    });
  }
};
