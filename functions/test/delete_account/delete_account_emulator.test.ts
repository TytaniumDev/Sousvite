import { describe, expect, it } from 'vitest';

import { callFunction } from '../helpers/callable_client.js';

describe('deleteAccount on the emulator', () => {
  it('refuses calls that are not signed in', async () => {
    const response = await callFunction(
      'deleteAccount',
      {},
      { appCheck: false },
    );

    expect(response.status).toBe(401);
    expect(response.body).toMatchObject({
      error: { status: 'UNAUTHENTICATED' },
    });
  });
});
