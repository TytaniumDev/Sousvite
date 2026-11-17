import { getApps, initializeApp } from 'firebase-admin/app';
import { type Firestore, getFirestore } from 'firebase-admin/firestore';
import type { CallableRequest } from 'firebase-functions/v2/https';

import type { SharingStores } from '../../src/sharing/sharing_stores.js';
import { demoProjectId } from './rules_test_environment.js';

/** The emulator's Firestore, through the Admin SDK. */
export const adminFirestore = (): Firestore =>
  getFirestore(getApps()[0] ?? initializeApp({ projectId: demoProjectId }));

/** Sharing stores over the emulator, with a settable clock. */
export interface TestSharingStores extends SharingStores {
  /** Every prefix passed to deleteFiles, in order. */
  readonly deletedPrefixes: string[];

  /** Moves the clock to [time]. */
  setNow(time: Date): void;
}

/** Fresh [TestSharingStores], starting at 2026-11-16 noon UTC. */
export const testSharingStores = (): TestSharingStores => {
  let time = new Date('2026-11-16T12:00:00Z');
  const deletedPrefixes: string[] = [];
  return {
    firestore: adminFirestore(),
    deleteFiles: (prefix) => {
      deletedPrefixes.push(prefix);
      return Promise.resolve();
    },
    now: () => time,
    deletedPrefixes,
    setNow: (value) => {
      time = value;
    },
  };
};

/** Clears every collection sharing writes to. */
export const clearSharing = async (firestore: Firestore): Promise<void> => {
  for (const collection of [
    'spaces',
    'invites',
    'inbox',
    'shareLinks',
    'users',
  ]) {
    await firestore.recursiveDelete(firestore.collection(collection));
  }
};

/** A callable request from [uid] (signed out when undefined) with [data]. */
export const callFrom = (
  uid: string | undefined,
  data: unknown,
  name?: string,
): CallableRequest<unknown> =>
  ({
    data,
    auth:
      uid === undefined
        ? undefined
        : { uid, token: name === undefined ? {} : { name } },
    rawRequest: {},
    acceptsStreaming: false,
  }) as unknown as CallableRequest<unknown>;
