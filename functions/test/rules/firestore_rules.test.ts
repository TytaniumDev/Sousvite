import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

import { rulesTestEnvironment } from '../helpers/rules_test_environment.js';

describe('firestore.rules', () => {
  let testEnv: RulesTestEnvironment;

  const as = (uid: string) => testEnv.authenticatedContext(uid).firestore();

  const privateSpace = (uid: string) => ({
    kind: 'private',
    ownerUid: uid,
    memberUids: [uid],
    createdAt: serverTimestamp(),
  });

  const batch = (uid: string) => ({
    deviceId: 'phone',
    uid,
    pushedAt: serverTimestamp(),
    hlcMax: '001731600000000-00000-phone',
    changes: [{ id: 'c1', field: 'title', value: 'Soup' }],
  });

  /** Writes [data] at [path] as an admin, bypassing the rules. */
  const seed = async (path: string, data: object): Promise<void> => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), path), data);
    });
  };

  const seedSpace = (spaceId: string, memberUids: string[]) =>
    seed(`spaces/${spaceId}`, {
      kind: memberUids.length > 1 ? 'shared' : 'private',
      ownerUid: memberUids[0],
      memberUids,
      createdAt: Timestamp.now(),
    });

  beforeAll(async () => {
    testEnv = await rulesTestEnvironment();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  describe('signed out', () => {
    it('denies reads', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(getDoc(doc(db, 'spaces/u_alice')));
    });

    it('denies writes', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(setDoc(doc(db, 'users/alice'), { a: 1 }));
    });
  });

  it('denies collections without rules', async () => {
    await assertFails(setDoc(doc(as('alice'), 'anything/doc'), { a: 1 }));
  });

  describe('users/{uid}', () => {
    const profile = {
      privateSpaceId: 'u_alice',
      transport: 'firestore',
      createdAt: serverTimestamp(),
    };

    it('lets a user create and read their own profile', async () => {
      await assertSucceeds(setDoc(doc(as('alice'), 'users/alice'), profile));
      await assertSucceeds(getDoc(doc(as('alice'), 'users/alice')));
    });

    it('denies another user', async () => {
      await assertFails(setDoc(doc(as('bob'), 'users/alice'), profile));
      await seed('users/alice', { privateSpaceId: 'u_alice' });
      await assertFails(getDoc(doc(as('bob'), 'users/alice')));
    });

    it('requires the private space id and server time', async () => {
      const db = as('alice');
      await assertFails(
        setDoc(doc(db, 'users/alice'), { ...profile, privateSpaceId: 'x' }),
      );
      await assertFails(
        setDoc(doc(db, 'users/alice'), {
          ...profile,
          createdAt: Timestamp.now(),
        }),
      );
      await assertFails(
        setDoc(doc(db, 'users/alice'), { ...profile, extra: true }),
      );
      await assertFails(
        setDoc(doc(db, 'users/alice'), { ...profile, transport: 'ftp' }),
      );
    });

    it('lets a user change only their transport', async () => {
      const db = as('alice');
      await setDoc(doc(db, 'users/alice'), profile);
      await assertSucceeds(
        updateDoc(doc(db, 'users/alice'), { transport: 'drive' }),
      );
      await assertFails(
        updateDoc(doc(db, 'users/alice'), { privateSpaceId: 'u_bob' }),
      );
    });

    it('never lets a client delete a profile', async () => {
      await seed('users/alice', { privateSpaceId: 'u_alice' });
      await assertFails(deleteDoc(doc(as('alice'), 'users/alice')));
    });

    it('lets users read but never write their entitlement', async () => {
      await seed('users/alice/private/entitlement', { pro: true });
      await assertSucceeds(
        getDoc(doc(as('alice'), 'users/alice/private/entitlement')),
      );
      await assertFails(
        getDoc(doc(as('bob'), 'users/alice/private/entitlement')),
      );
      await assertFails(
        setDoc(doc(as('alice'), 'users/alice/private/entitlement'), {
          pro: true,
        }),
      );
    });
  });

  describe('spaces/{spaceId}', () => {
    it('lets a user look up their private space before it exists', async () => {
      await assertSucceeds(getDoc(doc(as('alice'), 'spaces/u_alice')));
      await assertFails(getDoc(doc(as('alice'), 'spaces/u_bob')));
    });

    it('lets a user create only their own private space', async () => {
      await assertSucceeds(
        setDoc(doc(as('alice'), 'spaces/u_alice'), privateSpace('alice')),
      );
      await assertFails(
        setDoc(doc(as('alice'), 'spaces/u_bob'), privateSpace('bob')),
      );
      await assertFails(
        setDoc(doc(as('alice'), 'spaces/s1'), privateSpace('alice')),
      );
    });

    it('requires the exact private space shape', async () => {
      const db = as('alice');
      const space = privateSpace('alice');
      for (const bad of [
        { ...space, kind: 'shared' },
        { ...space, memberUids: ['alice', 'bob'] },
        { ...space, ownerUid: 'bob' },
        { ...space, createdAt: Timestamp.now() },
        { ...space, latestSnapshot: { path: 'x', hlc: 'y' } },
      ]) {
        await assertFails(setDoc(doc(db, 'spaces/u_alice'), bad));
      }
    });

    it('lets members read a space and others not', async () => {
      await seedSpace('s1', ['alice', 'bob']);
      await assertSucceeds(getDoc(doc(as('bob'), 'spaces/s1')));
      await assertFails(getDoc(doc(as('carol'), 'spaces/s1')));
    });

    it('lets members point the space at a new snapshot', async () => {
      await seedSpace('s1', ['alice', 'bob']);
      await assertSucceeds(
        updateDoc(doc(as('bob'), 'spaces/s1'), {
          latestSnapshot: { path: 'spaces/s1/snapshots/h.json.gz', hlc: 'h' },
        }),
      );
      await assertFails(
        updateDoc(doc(as('carol'), 'spaces/s1'), {
          latestSnapshot: { path: 'spaces/s1/snapshots/h.json.gz', hlc: 'h' },
        }),
      );
    });

    it('allows no other change to a space', async () => {
      await seedSpace('u_alice', ['alice']);
      const db = as('alice');
      await assertFails(
        updateDoc(doc(db, 'spaces/u_alice'), {
          memberUids: ['alice', 'bob'],
        }),
      );
      await assertFails(
        updateDoc(doc(db, 'spaces/u_alice'), {
          latestSnapshot: {
            path: 'spaces/other/snapshots/h.json.gz',
            hlc: 'h',
          },
        }),
      );
      await assertFails(deleteDoc(doc(db, 'spaces/u_alice')));
    });
  });

  describe('spaces/{spaceId}/batches', () => {
    it('lets members push and pull', async () => {
      await seedSpace('s1', ['alice', 'bob']);
      await assertSucceeds(
        addDoc(collection(as('alice'), 'spaces/s1/batches'), batch('alice')),
      );
      await assertSucceeds(
        getDocs(
          query(
            collection(as('bob'), 'spaces/s1/batches'),
            orderBy('pushedAt'),
          ),
        ),
      );
    });

    it('denies non-members', async () => {
      await seedSpace('s1', ['alice']);
      await assertFails(
        addDoc(collection(as('carol'), 'spaces/s1/batches'), batch('carol')),
      );
      await assertFails(getDocs(collection(as('carol'), 'spaces/s1/batches')));
    });

    it('denies a space that does not exist', async () => {
      await assertFails(
        addDoc(
          collection(as('alice'), 'spaces/u_alice/batches'),
          batch('alice'),
        ),
      );
    });

    it('requires the pusher uid, server time, and fields', async () => {
      await seedSpace('u_alice', ['alice']);
      const batches = collection(as('alice'), 'spaces/u_alice/batches');
      const good = batch('alice');
      for (const bad of [
        { ...good, uid: 'bob' },
        { ...good, pushedAt: Timestamp.now() },
        { ...good, changes: [] },
        { ...good, changes: 'none' },
        { ...good, extra: 1 },
        { uid: 'alice', pushedAt: serverTimestamp(), changes: good.changes },
      ]) {
        await assertFails(addDoc(batches, bad));
      }
    });

    it('never lets a batch change or be deleted', async () => {
      await seedSpace('u_alice', ['alice']);
      await seed('spaces/u_alice/batches/b1', {
        ...batch('alice'),
        pushedAt: Timestamp.now(),
      });
      const db = as('alice');
      await assertFails(
        updateDoc(doc(db, 'spaces/u_alice/batches/b1'), { hlcMax: 'x' }),
      );
      await assertFails(deleteDoc(doc(db, 'spaces/u_alice/batches/b1')));
    });
  });
});
