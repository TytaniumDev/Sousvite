import { getApps, initializeApp } from 'firebase-admin/app';
import { type Firestore, getFirestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';

/** Deletes every file whose path starts with a prefix. */
export type DeleteFiles = (prefix: string) => Promise<void>;

/**
 * Where sharing reads and writes. Separate from the functions so tests can
 * pass emulator-backed stores and a fixed clock.
 */
export interface SharingStores {
  readonly firestore: Firestore;

  /** Removes a space's snapshot files from Cloud Storage. */
  readonly deleteFiles: DeleteFiles;

  /** The current time, so tests can expire invites. */
  readonly now: () => Date;
}

/** The stores the deployed functions use. */
export const defaultSharingStores = (): SharingStores => {
  // The emulators point the Admin SDK at themselves through the
  // environment, so this needs no options.
  const app = getApps()[0] ?? initializeApp();
  return {
    firestore: getFirestore(app),
    deleteFiles: (prefix) =>
      getStorage(app).bucket().deleteFiles({ prefix, force: true }),
    now: () => new Date(),
  };
};
