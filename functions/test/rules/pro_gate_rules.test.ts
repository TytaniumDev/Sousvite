import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  addDoc,
  collection,
  doc,
  serverTimestamp,
  setDoc,
  Timestamp,
} from 'firebase/firestore';
import { ref, uploadBytes } from 'firebase/storage';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

import { rulesTestEnvironment } from '../helpers/rules_test_environment.js';

/**
 * The rules with the Pro gate on, as they will be at launch (ENGINEERING.md
 * §9.2). The beta runs with it off, which the other rules tests cover.
 */
describe('rules with the Pro gate on', () => {
  let testEnv: RulesTestEnvironment;

  const day = 24 * 60 * 60 * 1000;

  const seed = async (path: string, data: object): Promise<void> => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), path), data);
    });
  };

  const push = (uid: string) =>
    addDoc(
      collection(
        testEnv.authenticatedContext(uid).firestore(),
        `spaces/u_${uid}/batches`,
      ),
      {
        deviceId: 'phone',
        uid,
        pushedAt: serverTimestamp(),
        hlcMax: 'h',
        changes: [{ id: 'c1' }],
      },
    );

  const uploadSnapshot = (uid: string) =>
    uploadBytes(
      ref(
        testEnv.authenticatedContext(uid).storage(),
        `spaces/u_${uid}/snapshots/h.json.gz`,
      ),
      new Uint8Array([1]),
      { contentType: 'application/gzip' },
    );

  beforeAll(async () => {
    testEnv = await rulesTestEnvironment({ proRequired: true });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.clearStorage();
    for (const uid of ['alice', 'bob', 'carol']) {
      await seed(`spaces/u_${uid}`, {
        kind: 'private',
        ownerUid: uid,
        memberUids: [uid],
        createdAt: Timestamp.now(),
      });
    }
    await seed('users/alice/private/entitlement', {
      pro: true,
      expiresAt: Timestamp.fromMillis(Date.now() + day),
    });
    await seed('users/bob/private/entitlement', {
      pro: true,
      expiresAt: Timestamp.fromMillis(Date.now() - day),
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  it('lets a Pro user sync', async () => {
    await assertSucceeds(push('alice'));
    await assertSucceeds(uploadSnapshot('alice'));
  });

  it('denies a user whose Pro expired', async () => {
    await assertFails(push('bob'));
    await assertFails(uploadSnapshot('bob'));
  });

  it('denies a user who never had Pro', async () => {
    await assertFails(push('carol'));
    await assertFails(uploadSnapshot('carol'));
  });
});
