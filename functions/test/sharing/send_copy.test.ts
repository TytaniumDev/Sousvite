import { beforeEach, describe, expect, it } from 'vitest';

import { handleAcceptInvite } from '../../src/sharing/accept_invite.js';
import { handlePreviewInvite } from '../../src/sharing/preview_invite.js';
import { handleSendCopy } from '../../src/sharing/send_copy.js';
import {
  callFrom,
  clearSharing,
  type TestSharingStores,
  testSharingStores,
} from '../helpers/sharing_test_stores.js';

const entities = [
  { entity: 'recipe', entityId: 'r1', fields: { title: 'Lasagna' } },
];

describe('send a copy', () => {
  let stores: TestSharingStores;
  let sendCopy: ReturnType<typeof handleSendCopy>;
  let acceptInvite: ReturnType<typeof handleAcceptInvite>;

  beforeEach(async () => {
    stores = testSharingStores();
    await clearSharing(stores.firestore);
    sendCopy = handleSendCopy(() => stores);
    acceptInvite = handleAcceptInvite(() => stores);
  });

  it('gives the copy to each person who opens the link', async () => {
    const { inviteId } = await sendCopy(
      callFrom('alice', { title: 'Lasagna', entities }, 'Alice'),
    );

    const expected = { kind: 'copy', title: 'Lasagna', entities };
    expect(await acceptInvite(callFrom('bob', { inviteId }))).toEqual(expected);
    expect(await acceptInvite(callFrom('carol', { inviteId }))).toEqual(
      expected,
    );
  });

  it('says what the link offers before accepting', async () => {
    const { inviteId } = await sendCopy(
      callFrom('alice', { title: 'Lasagna', entities }, 'Alice'),
    );

    await expect(
      handlePreviewInvite(() => stores)(callFrom('bob', { inviteId })),
    ).resolves.toEqual({ kind: 'copy', title: 'Lasagna', fromName: 'Alice' });
  });

  it.each([
    [{ title: 'Lasagna' }],
    [{ title: 'Lasagna', entities: [] }],
    [{ title: 'Lasagna', entities: 'nope' }],
    [{ entities }],
  ])('refuses bad data %j', async (data) => {
    await expect(sendCopy(callFrom('alice', data))).rejects.toMatchObject({
      code: 'invalid-argument',
    });
  });

  it('refuses a copy too large for one document', async () => {
    const huge = [{ value: 'x'.repeat(1024 * 1024) }];

    await expect(
      sendCopy(callFrom('alice', { title: 'Lasagna', entities: huge })),
    ).rejects.toMatchObject({
      code: 'invalid-argument',
      details: { reason: 'tooLarge' },
    });
  });
});
