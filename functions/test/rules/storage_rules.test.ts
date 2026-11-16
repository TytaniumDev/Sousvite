import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, setDoc, Timestamp } from 'firebase/firestore';
import {
  deleteObject,
  getBytes,
  ref,
  uploadBytes,
  uploadString,
} from 'firebase/storage';
import { afterAll, beforeAll, beforeEach, describe, it } from 'vitest';

import { rulesTestEnvironment } from '../helpers/rules_test_environment.js';

describe('storage.rules', () => {
  let testEnv: RulesTestEnvironment;

  const as = (uid: string) => testEnv.authenticatedContext(uid).storage();

  const gzip = { contentType: 'application/gzip' };
  const snapshot = 'spaces/s1/snapshots/h.json.gz';

  beforeAll(async () => {
    testEnv = await rulesTestEnvironment();
  });

  beforeEach(async () => {
    await testEnv.clearStorage();
    await testEnv.clearFirestore();
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), 'spaces/s1'), {
        kind: 'shared',
        ownerUid: 'alice',
        memberUids: ['alice', 'bob'],
        createdAt: Timestamp.now(),
      });
    });
  });

  afterAll(async () => {
    await testEnv.cleanup();
  });

  describe('signed out', () => {
    it('denies reads', async () => {
      const storage = testEnv.unauthenticatedContext().storage();
      await assertFails(getBytes(ref(storage, snapshot)));
    });

    it('denies writes', async () => {
      const storage = testEnv.unauthenticatedContext().storage();
      await assertFails(
        uploadBytes(ref(storage, snapshot), new Uint8Array([1]), gzip),
      );
    });
  });

  it('denies paths without rules', async () => {
    await assertFails(
      uploadString(ref(as('alice'), 'users/alice/photo.jpg'), 'x'),
    );
  });

  describe('spaces/{spaceId}/snapshots', () => {
    it('lets members write and read snapshots', async () => {
      await assertSucceeds(
        uploadBytes(ref(as('alice'), snapshot), new Uint8Array([1]), gzip),
      );
      await assertSucceeds(getBytes(ref(as('bob'), snapshot)));
    });

    it('denies non-members', async () => {
      await assertFails(
        uploadBytes(ref(as('carol'), snapshot), new Uint8Array([1]), gzip),
      );
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await uploadBytes(
          ref(context.storage(), snapshot),
          new Uint8Array([1]),
          gzip,
        );
      });
      await assertFails(getBytes(ref(as('carol'), snapshot)));
    });

    it('requires gzipped JSON files', async () => {
      await assertFails(
        uploadBytes(ref(as('alice'), snapshot), new Uint8Array([1]), {
          contentType: 'text/plain',
        }),
      );
      await assertFails(
        uploadBytes(
          ref(as('alice'), 'spaces/s1/snapshots/h.txt'),
          new Uint8Array([1]),
          gzip,
        ),
      );
    });

    // Only create is allowed. The emulator evaluates an overwrite as a
    // create, so overwriting is not tested here; in production it is an
    // update and denied. Snapshot names are their HLC, so an overwrite would
    // hold the same state anyway.
    it('never lets a snapshot be deleted', async () => {
      await uploadBytes(ref(as('alice'), snapshot), new Uint8Array([1]), gzip);
      await assertFails(deleteObject(ref(as('alice'), snapshot)));
    });
  });
});
