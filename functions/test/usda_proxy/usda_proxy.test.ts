import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';

import type { ResponseCache } from '../../src/usda_proxy/response_cache.js';
import { handleUsdaProxy, usdaProxy } from '../../src/usda_proxy/usda_proxy.js';
import type { UsdaRequest } from '../../src/usda_proxy/usda_request.js';
import { demoProjectId } from '../helpers/rules_test_environment.js';
import { FakeUsdaApi, foodResponse } from './fake_usda_api.js';

class MemoryCache implements ResponseCache {
  readonly entries = new Map<string, string>();
  failWrites = false;

  get(key: string): Promise<string | undefined> {
    return Promise.resolve(this.entries.get(key));
  }

  set(key: string, body: string): Promise<void> {
    if (this.failWrites) {
      return Promise.reject(new Error('cache down'));
    }
    this.entries.set(key, body);
    return Promise.resolve();
  }
}

const search = { action: 'search', query: 'cheddar' };

describe('handleUsdaProxy', () => {
  const setUp = () => {
    const cache = new MemoryCache();
    const send = vi.fn<(request: UsdaRequest) => Promise<string>>(() =>
      Promise.resolve('{"foods":[]}'),
    );
    const handle = handleUsdaProxy({
      client: () => ({ send }),
      cache: () => cache,
    });
    return { cache, send, handle };
  };

  it('asks USDA on a miss and caches the answer', async () => {
    const { cache, send, handle } = setUp();

    expect(await handle({ data: search })).toEqual({ foods: [] });
    expect(send).toHaveBeenCalledWith({
      action: 'search',
      query: 'cheddar',
      pageNumber: 1,
      pageSize: 25,
    });
    expect([...cache.entries.values()]).toEqual(['{"foods":[]}']);
  });

  it('answers a repeat from the cache', async () => {
    const { send, handle } = setUp();

    await handle({ data: search });
    await handle({ data: { ...search, query: 'CHEDDAR' } });

    expect(send).toHaveBeenCalledTimes(1);
  });

  it('still answers when the cache fails', async () => {
    const { cache, handle } = setUp();
    cache.failWrites = true;

    expect(await handle({ data: search })).toEqual({ foods: [] });
  });

  it('refuses an invalid request without asking USDA', async () => {
    const { send, handle } = setUp();

    await expect(handle({ data: { action: 'search' } })).rejects.toMatchObject({
      code: 'invalid-argument',
    });
    expect(send).not.toHaveBeenCalled();
  });
});

// Runs the deployed wiring in-process, with the secret and base URL from the
// environment, a fake upstream, and the Firestore emulator for the cache.
describe('usdaProxy', () => {
  const api = new FakeUsdaApi();

  beforeAll(async () => {
    vi.stubEnv('USDA_API_BASE_URL', await api.start());
    vi.stubEnv('USDA_API_KEY', 'in-process-key');
    vi.stubEnv('GCLOUD_PROJECT', demoProjectId);
  });

  afterAll(async () => {
    vi.unstubAllEnvs();
    await api.stop();
  });

  it('fetches a food through the real client and cache', async () => {
    const request = {
      data: { action: 'food', fdcId: 2_345_678 },
      rawRequest: {},
      acceptsStreaming: false,
    } as unknown as Parameters<typeof usdaProxy.run>[0];

    expect(await usdaProxy.run(request)).toEqual(foodResponse);
    expect(api.received.at(-1)?.headers['x-api-key']).toBe('in-process-key');
  });
});
