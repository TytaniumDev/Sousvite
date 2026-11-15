import { getApps, initializeApp } from 'firebase-admin/app';
import { type Auth, getAuth } from 'firebase-admin/auth';
import { type Firestore, getFirestore } from 'firebase-admin/firestore';
import type { CallableRequest } from 'firebase-functions/v2/https';
import { HttpsError } from 'firebase-functions/v2/https';
import { beforeAll, beforeEach, describe, expect, it } from 'vitest';

import {
  deleteAccount,
  handleDeleteAccount,
} from '../../src/delete_account/delete_account.js';
import { demoProjectId } from '../helpers/rules_test_environment.js';

const requestFrom = (uid?: string): CallableRequest<unknown> =>
  ({
    data: {},
    auth: uid === undefined ? undefined : { uid, token: {} },
    rawRequest: {},
    acceptsStreaming: false,
  }) as unknown as CallableRequest<unknown>;

describe('deleteAccount', () => {
  let auth: Auth;
  let firestore: Firestore;

  beforeAll(() => {
    const app = getApps()[0] ?? initializeApp({ projectId: demoProjectId });
    auth = getAuth(app);
    firestore = getFirestore(app);
  });

  beforeEach(async () => {
    await firestore.recursiveDelete(firestore.collection('users'));
    const { users } = await auth.listUsers();
    await auth.deleteUsers(users.map((user) => user.uid));
  });

  const createUserWithData = async (uid: string): Promise<void> => {
    await auth.createUser({ uid });
    await firestore.doc(`users/${uid}`).set({ pro: false });
    await firestore.doc(`users/${uid}/devices/phone`).set({ name: 'Phone' });
  };

  const userExists = async (uid: string): Promise<boolean> =>
    auth.getUser(uid).then(
      () => true,
      () => false,
    );

  const handle = handleDeleteAccount(() => ({ auth, firestore }));

  it('deletes the user and their data, and leaves other users alone', async () => {
    await createUserWithData('alice');
    await createUserWithData('bob');

    await expect(handle(requestFrom('alice'))).resolves.toEqual({
      deleted: true,
    });

    expect(await userExists('alice')).toBe(false);
    expect((await firestore.doc('users/alice').get()).exists).toBe(false);
    expect(
      (await firestore.doc('users/alice/devices/phone').get()).exists,
    ).toBe(false);
    expect(await userExists('bob')).toBe(true);
    expect((await firestore.doc('users/bob/devices/phone').get()).exists).toBe(
      true,
    );
  });

  it('succeeds when the user is already gone, so retries are safe', async () => {
    await firestore.doc('users/carol').set({ pro: false });

    await expect(handle(requestFrom('carol'))).resolves.toEqual({
      deleted: true,
    });
    expect((await firestore.doc('users/carol').get()).exists).toBe(false);
  });

  it('refuses callers who are not signed in', async () => {
    await expect(handle(requestFrom())).rejects.toMatchObject({
      code: 'unauthenticated',
    });
    await expect(handle(requestFrom())).rejects.toBeInstanceOf(HttpsError);
  });

  it('passes on other errors from Auth', async () => {
    const failingAuth = {
      deleteUser: () => Promise.reject(new Error('Auth is down')),
    } as unknown as Auth;

    await expect(
      handleDeleteAccount(() => ({ auth: failingAuth, firestore }))(
        requestFrom('dave'),
      ),
    ).rejects.toThrow('Auth is down');
  });

  it('runs as a callable function against the emulators', async () => {
    await createUserWithData('erin');

    await expect(deleteAccount.run(requestFrom('erin'))).resolves.toEqual({
      deleted: true,
    });
    expect(await userExists('erin')).toBe(false);
  });
});
