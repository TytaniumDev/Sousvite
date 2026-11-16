import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  setDoc,
} from 'firebase/firestore';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

import { rulesTestEnvironment } from '../helpers/rules_test_environment.js';

describe('firestore.rules: sharing', () => {
  let testEnv: RulesTestEnvironment;

  beforeAll(async () => {
    testEnv = await rulesTestEnvironment();
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await setDoc(doc(db, 'invites/abc'), { kind: 'joint', spaceId: 's_1' });
      await setDoc(doc(db, 'inbox/bob/items/one'), { title: 'Pie' });
      await setDoc(doc(db, 'shareLinks/link'), { ownerUid: 'alice' });
      await setDoc(doc(db, 'spaces/s_1'), {
        kind: 'shared',
        ownerUid: 'alice',
        memberUids: ['alice'],
      });
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  const as = (uid?: string) =>
    (uid === undefined
      ? testEnv.unauthenticatedContext()
      : testEnv.authenticatedContext(uid)
    ).firestore();

  describe('invites', () => {
    it('lets anyone signed in read an invite by its id', async () => {
      await assertSucceeds(getDoc(doc(as('bob'), 'invites/abc')));
    });

    it('denies reading signed out, listing, and writing', async () => {
      await assertFails(getDoc(doc(as(), 'invites/abc')));
      await assertFails(getDocs(collection(as('bob'), 'invites')));
      await assertFails(
        setDoc(doc(as('bob'), 'invites/new'), { kind: 'copy' }),
      );
      await assertFails(deleteDoc(doc(as('bob'), 'invites/abc')));
    });
  });

  describe('inbox', () => {
    it('lets the owner read and delete their items', async () => {
      await assertSucceeds(getDocs(collection(as('bob'), 'inbox/bob/items')));
      await assertSucceeds(deleteDoc(doc(as('bob'), 'inbox/bob/items/one')));
    });

    it('denies everyone else, and writes by the owner', async () => {
      await assertFails(getDoc(doc(as('alice'), 'inbox/bob/items/one')));
      await assertFails(deleteDoc(doc(as('alice'), 'inbox/bob/items/one')));
      await assertFails(
        setDoc(doc(as('bob'), 'inbox/bob/items/two'), { title: 'Fake' }),
      );
    });
  });

  describe('functions-only documents', () => {
    it('denies clients writing shared spaces and reading or writing links', async () => {
      await assertFails(
        setDoc(doc(as('alice'), 'spaces/s_2'), {
          kind: 'shared',
          ownerUid: 'alice',
          memberUids: ['alice'],
        }),
      );
      await assertFails(
        setDoc(
          doc(as('bob'), 'spaces/s_1'),
          { memberUids: ['alice', 'bob'] },
          { merge: true },
        ),
      );
      await assertFails(getDoc(doc(as('alice'), 'shareLinks/link')));
      await assertFails(setDoc(doc(as('alice'), 'shareLinks/x'), {}));
    });
  });
});
