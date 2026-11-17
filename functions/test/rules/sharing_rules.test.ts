import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  where,
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
      await setDoc(doc(db, 'invites/abc'), {
        kind: 'joint',
        spaceId: 's_1',
        fromUid: 'alice',
      });
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

  const as = (uid: string) => testEnv.authenticatedContext(uid).firestore();

  it('keeps invites and links functions-only, even for their creator', async () => {
    await assertFails(getDoc(doc(as('alice'), 'invites/abc')));
    await assertFails(getDoc(doc(as('bob'), 'invites/abc')));
    await assertFails(setDoc(doc(as('bob'), 'invites/new'), { kind: 'copy' }));
    await assertFails(getDoc(doc(as('alice'), 'shareLinks/link')));
    await assertFails(setDoc(doc(as('alice'), 'shareLinks/x'), {}));
  });

  it('denies clients creating shared spaces or joining one', async () => {
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
  });

  it('lets users list only the spaces they are a member of', async () => {
    const spaces = (uid: string) => collection(as(uid), 'spaces');
    await assertSucceeds(
      getDocs(
        query(spaces('alice'), where('memberUids', 'array-contains', 'alice')),
      ),
    );
    await assertFails(
      getDocs(
        query(spaces('bob'), where('memberUids', 'array-contains', 'alice')),
      ),
    );
    await assertFails(getDocs(spaces('alice')));
    await assertFails(
      getDocs(
        query(
          collection(testEnv.unauthenticatedContext().firestore(), 'spaces'),
          where('memberUids', 'array-contains', 'alice'),
        ),
      ),
    );
  });
});
