import { existsSync, readFileSync, rmSync, writeFileSync } from 'node:fs';

import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callFunction } from '../helpers/callable_client.js';
import { FakeUsdaApi, foodResponse, searchResponse } from './fake_usda_api.js';

// The emulator reads function secrets from functions/.secret.local. Tests
// write a fake key there unless a developer already has the file.
const secretFile = new URL('../../.secret.local', import.meta.url);
const fakeKey = 'emulator-fake-usda-key';

const readKey = (): string =>
  /^USDA_API_KEY=(.*)$/m.exec(readFileSync(secretFile, 'utf8'))?.[1] ?? '';

describe('usdaProxy on the emulator', () => {
  // Matches USDA_API_BASE_URL in functions/.env.demo-sousvite.
  const api = new FakeUsdaApi();
  let wroteSecret = false;
  let apiKey: string;

  beforeAll(async () => {
    if (!existsSync(secretFile)) {
      writeFileSync(secretFile, `USDA_API_KEY=${fakeKey}\n`);
      wroteSecret = true;
    }
    apiKey = readKey();
    await api.start(9510);
  });

  afterAll(async () => {
    await api.stop();
    if (wroteSecret) {
      rmSync(secretFile);
    }
  });

  it('rejects calls without App Check', async () => {
    const response = await callFunction(
      'usdaProxy',
      { action: 'food', fdcId: 2_345_678 },
      { appCheck: false },
    );

    expect(response.status).toBe(401);
    expect(api.received).toHaveLength(0);
  });

  it('searches through the fake upstream with the key', async () => {
    const response = await callFunction(
      'usdaProxy',
      { action: 'search', query: 'emulator cheddar' },
      { appCheck: true },
    );

    expect(response).toEqual({ status: 200, body: { result: searchResponse } });
    expect(api.received.at(-1)?.headers['x-api-key']).toBe(apiKey);
  });

  it('never sends the key to the client', async () => {
    const response = await callFunction(
      'usdaProxy',
      { action: 'food', fdcId: 2_345_678 },
      { appCheck: true },
    );
    const failure = await callFunction(
      'usdaProxy',
      { action: 'food', fdcId: 500 },
      { appCheck: true },
    );

    expect(response.body).toEqual({ result: foodResponse });
    expect(JSON.stringify(response)).not.toContain(apiKey);
    expect(failure.status).toBe(503);
    expect(JSON.stringify(failure)).not.toContain(apiKey);
  });

  it('answers a repeat from the cache', async () => {
    const data = { action: 'search', query: 'emulator gouda' };
    await callFunction('usdaProxy', data, { appCheck: true });
    const before = api.received.length;

    const response = await callFunction('usdaProxy', data, { appCheck: true });

    expect(response.body).toEqual({ result: searchResponse });
    expect(api.received).toHaveLength(before);
  });
});
