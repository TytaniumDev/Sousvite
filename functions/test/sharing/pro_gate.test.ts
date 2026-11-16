import { Timestamp } from 'firebase-admin/firestore';
import { beforeEach, describe, expect, it } from 'vitest';

import { hasPro, requireProToShare } from '../../src/sharing/pro_gate.js';
import {
  clearSharing,
  type TestSharingStores,
  testSharingStores,
} from '../helpers/sharing_test_stores.js';

describe('Pro gate', () => {
  let stores: TestSharingStores;

  beforeEach(async () => {
    stores = testSharingStores();
    await clearSharing(stores.firestore);
  });

  const setEntitlement = (uid: string, data: object) =>
    stores.firestore.doc(`users/${uid}/private/entitlement`).set(data);

  it('reads the entitlement the webhook writes', async () => {
    const now = stores.now();
    await setEntitlement('forever', { pro: true });
    await setEntitlement('active', {
      pro: true,
      expiresAt: Timestamp.fromMillis(now.getTime() + 1000),
    });
    await setEntitlement('expired', {
      pro: true,
      expiresAt: Timestamp.fromMillis(now.getTime() - 1000),
    });
    await setEntitlement('free', { pro: false });

    expect(await hasPro(stores.firestore, 'forever', now)).toBe(true);
    expect(await hasPro(stores.firestore, 'active', now)).toBe(true);
    expect(await hasPro(stores.firestore, 'expired', now)).toBe(false);
    expect(await hasPro(stores.firestore, 'free', now)).toBe(false);
    expect(await hasPro(stores.firestore, 'nobody', now)).toBe(false);
  });

  it('lets everyone share during the beta', async () => {
    await expect(
      requireProToShare(stores.firestore, 'nobody', stores.now()),
    ).resolves.toBeUndefined();
  });

  it('needs Pro to share once the gate is on', async () => {
    await setEntitlement('pro', { pro: true });

    await expect(
      requireProToShare(stores.firestore, 'pro', stores.now(), true),
    ).resolves.toBeUndefined();
    await expect(
      requireProToShare(stores.firestore, 'nobody', stores.now(), true),
    ).rejects.toMatchObject({
      code: 'permission-denied',
      details: { reason: 'proRequired' },
    });
  });
});
