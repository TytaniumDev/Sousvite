import type { Timestamp } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { beforeEach, describe, expect, it } from 'vitest';

import { handleAcceptInvite } from '../../src/sharing/accept_invite.js';
import { inviteLifetimeDays } from '../../src/sharing/invites.js';
import { handleLeaveShare } from '../../src/sharing/leave_share.js';
import { handleShareJointly } from '../../src/sharing/share_jointly.js';
import {
  callFrom,
  clearSharing,
  type TestSharingStores,
  testSharingStores,
} from '../helpers/sharing_test_stores.js';

describe('joint shares', () => {
  let stores: TestSharingStores;
  let shareJointly: ReturnType<typeof handleShareJointly>;
  let acceptInvite: ReturnType<typeof handleAcceptInvite>;
  let leaveShare: ReturnType<typeof handleLeaveShare>;

  beforeEach(async () => {
    stores = testSharingStores();
    await clearSharing(stores.firestore);
    shareJointly = handleShareJointly(() => stores);
    acceptInvite = handleAcceptInvite(() => stores);
    leaveShare = handleLeaveShare(() => stores);
  });

  const space = async (spaceId: string) =>
    (await stores.firestore.doc(`spaces/${spaceId}`).get()).data();

  const startShare = () =>
    shareJointly(callFrom('alice', { name: 'Lasagna' }, 'Alice'));

  describe('shareJointly', () => {
    it('creates a shared space with the caller as owner and only member', async () => {
      const { spaceId, inviteId } = await startShare();

      expect(spaceId).toMatch(/^s_/);
      expect(await space(spaceId)).toMatchObject({
        kind: 'shared',
        name: 'Lasagna',
        ownerUid: 'alice',
        memberUids: ['alice'],
        members: { alice: { name: 'Alice' } },
      });
      const invite = (
        await stores.firestore.doc(`invites/${inviteId}`).get()
      ).data();
      expect(invite).toMatchObject({
        kind: 'joint',
        spaceId,
        title: 'Lasagna',
        fromUid: 'alice',
        fromName: 'Alice',
      });
      const expiresAt = invite?.expiresAt as Timestamp | undefined;
      expect(expiresAt?.toMillis()).toBe(
        stores.now().getTime() + inviteLifetimeDays * 86_400_000,
      );
    });

    it('makes another invite for a share the caller is in', async () => {
      const { spaceId, inviteId } = await startShare();

      const again = await shareJointly(
        callFrom('alice', { name: 'Lasagna', spaceId }),
      );

      expect(again.spaceId).toBe(spaceId);
      expect(again.inviteId).not.toBe(inviteId);
    });

    it('refuses to invite to a share the caller is not in', async () => {
      const { spaceId } = await startShare();

      await expect(
        shareJointly(callFrom('mallory', { name: 'Lasagna', spaceId })),
      ).rejects.toMatchObject({
        code: 'not-found',
        details: { reason: 'notMember' },
      });
    });

    it('refuses callers who are not signed in', async () => {
      await expect(
        shareJointly(callFrom(undefined, { name: 'Lasagna' })),
      ).rejects.toMatchObject({ code: 'unauthenticated' });
    });

    it.each([
      [undefined],
      [{}],
      [{ name: '' }],
      [{ name: 'x'.repeat(201) }],
      [[]],
    ])('refuses bad data %j', async (data) => {
      await expect(
        shareJointly(callFrom('alice', data)),
      ).rejects.toBeInstanceOf(HttpsError);
    });
  });

  describe('acceptInvite', () => {
    it('adds the caller to the share, once', async () => {
      const { spaceId, inviteId } = await startShare();

      const result = await acceptInvite(callFrom('bob', { inviteId }, 'Bob'));
      await acceptInvite(callFrom('bob', { inviteId }, 'Bob'));

      expect(result).toEqual({ kind: 'joint', spaceId, title: 'Lasagna' });
      expect(await space(spaceId)).toMatchObject({
        ownerUid: 'alice',
        memberUids: ['alice', 'bob'],
        members: { alice: { name: 'Alice' }, bob: { name: 'Bob' } },
      });
    });

    it('stores no name when the sign-in has none', async () => {
      const { spaceId, inviteId } = await startShare();

      await acceptInvite(callFrom('bob', { inviteId }));

      expect(await space(spaceId)).toMatchObject({
        members: { bob: { name: null } },
      });
    });

    it('refuses an invite that does not exist', async () => {
      await expect(
        acceptInvite(callFrom('bob', { inviteId: 'nope' })),
      ).rejects.toMatchObject({
        code: 'not-found',
        details: { reason: 'inviteNotFound' },
      });
    });

    it('refuses an expired invite', async () => {
      const { inviteId } = await startShare();
      stores.setNow(new Date(stores.now().getTime() + 15 * 86_400_000));

      await expect(
        acceptInvite(callFrom('bob', { inviteId })),
      ).rejects.toMatchObject({
        code: 'failed-precondition',
        details: { reason: 'expired' },
      });
    });

    it('refuses an invite to a share everyone left', async () => {
      const { spaceId, inviteId } = await startShare();
      await stores.firestore.doc(`spaces/${spaceId}`).delete();

      await expect(
        acceptInvite(callFrom('bob', { inviteId })),
      ).rejects.toMatchObject({
        code: 'not-found',
        details: { reason: 'shareEnded' },
      });
    });
  });

  describe('leaveShare', () => {
    it('removes the member and keeps the share for the others', async () => {
      const { spaceId, inviteId } = await startShare();
      await acceptInvite(callFrom('bob', { inviteId }, 'Bob'));

      await expect(leaveShare(callFrom('bob', { spaceId }))).resolves.toEqual({
        left: true,
      });

      expect(await space(spaceId)).toMatchObject({
        ownerUid: 'alice',
        memberUids: ['alice'],
        members: { alice: { name: 'Alice' } },
      });
    });

    it('hands ownership to the next member when the owner leaves', async () => {
      const { spaceId, inviteId } = await startShare();
      await acceptInvite(callFrom('bob', { inviteId }, 'Bob'));

      await leaveShare(callFrom('alice', { spaceId }));

      expect(await space(spaceId)).toMatchObject({
        ownerUid: 'bob',
        memberUids: ['bob'],
      });
    });

    it('deletes the share, its changes, snapshots, and invites when the last member leaves', async () => {
      const { spaceId, inviteId } = await startShare();
      await stores.firestore
        .doc(`spaces/${spaceId}/batches/one`)
        .set({ uid: 'alice', changes: [] });

      await leaveShare(callFrom('alice', { spaceId }));

      expect(await space(spaceId)).toBeUndefined();
      expect(
        (await stores.firestore.doc(`spaces/${spaceId}/batches/one`).get())
          .exists,
      ).toBe(false);
      expect(
        (await stores.firestore.doc(`invites/${inviteId}`).get()).exists,
      ).toBe(false);
      expect(stores.deletedPrefixes).toEqual([`spaces/${spaceId}/`]);
    });

    it('does nothing for a share the caller is not in, or one that is gone', async () => {
      const { spaceId } = await startShare();

      await leaveShare(callFrom('mallory', { spaceId }));
      await leaveShare(callFrom('mallory', { spaceId: 's_gone' }));

      expect((await space(spaceId))?.memberUids).toEqual(['alice']);
      expect(stores.deletedPrefixes).toEqual([]);
    });

    it('refuses to leave a private space', async () => {
      await stores.firestore
        .doc('spaces/u_alice')
        .set({ kind: 'private', ownerUid: 'alice', memberUids: ['alice'] });

      await expect(
        leaveShare(callFrom('alice', { spaceId: 'u_alice' })),
      ).rejects.toMatchObject({
        code: 'failed-precondition',
        details: { reason: 'notShared' },
      });
    });
  });
});
