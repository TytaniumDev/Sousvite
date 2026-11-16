import { getApps, initializeApp } from 'firebase-admin/app';
import { type Auth, getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { logger } from 'firebase-functions/v2';
import {
  type CallableRequest,
  HttpsError,
  onCall,
} from 'firebase-functions/v2/https';

import { removeUserFromSharing } from '../sharing/remove_user.js';
import type { SharingStores } from '../sharing/sharing_stores.js';

/** Where the account's data lives on the server. */
export interface AccountStores extends SharingStores {
  readonly auth: Auth;
}

/**
 * Every Firestore document tree that belongs to one user. Tasks that store
 * per-user data on the server (SYN-5 private spaces, PRO-1 entitlements,
 * SHR-1 shares) add their paths here, so deleting an account always
 * removes it (PRD 7.9).
 */
export const userDocumentPaths = (uid: string): readonly string[] => [
  `users/${uid}`,
];

/**
 * Deletes the caller's server data and then their Firebase user. Separate
 * from the function so tests can pass emulator-backed stores. The app keeps
 * its local copy.
 */
export const handleDeleteAccount =
  (stores: () => AccountStores) =>
  async (request: CallableRequest<unknown>): Promise<{ deleted: true }> => {
    const uid = request.auth?.uid;
    if (uid === undefined) {
      throw new HttpsError('unauthenticated', 'Sign in to delete your account');
    }
    const resolved = stores();
    const { auth, firestore } = resolved;
    await removeUserFromSharing(resolved, uid);
    for (const path of userDocumentPaths(uid)) {
      await firestore.recursiveDelete(firestore.doc(path));
    }
    try {
      await auth.deleteUser(uid);
    } catch (error) {
      // Already gone, as when a retry follows a call that timed out after
      // deleting the user. The data above is gone either way.
      if ((error as { code?: unknown }).code !== 'auth/user-not-found') {
        throw error;
      }
    }
    logger.info('Account deleted', { uid });
    return { deleted: true };
  };

/**
 * Deletes the signed-in user's account and everything Sousvite stores for
 * them on the server (PRD 7.9, required by both app stores). Being signed in
 * is the only requirement, since a user can delete only their own account.
 */
export const deleteAccount = onCall(
  { timeoutSeconds: 120 },
  handleDeleteAccount(() => {
    // The emulators point the Admin SDK at themselves through the
    // environment, so this needs no options.
    const app = getApps()[0] ?? initializeApp();
    return {
      auth: getAuth(app),
      firestore: getFirestore(app),
      deleteFiles: (prefix: string) =>
        getStorage(app).bucket().deleteFiles({ prefix, force: true }),
      now: () => new Date(),
    };
  }),
);
