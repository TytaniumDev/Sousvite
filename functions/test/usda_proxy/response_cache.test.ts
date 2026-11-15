import { type App, deleteApp, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';

import {
  cacheKey,
  FirestoreResponseCache,
  maxCachedBytes,
} from '../../src/usda_proxy/response_cache.js';
import { demoProjectId } from '../helpers/rules_test_environment.js';

describe('cacheKey', () => {
  const search = {
    action: 'search',
    query: 'Cheddar',
    pageNumber: 1,
    pageSize: 25,
  } as const;

  it('ignores the letter case of a search', () => {
    expect(cacheKey(search)).toBe(cacheKey({ ...search, query: 'cheddar' }));
  });

  it('separates different pages', () => {
    expect(cacheKey(search)).not.toBe(cacheKey({ ...search, pageNumber: 2 }));
  });

  it('separates foods', () => {
    expect(cacheKey({ action: 'food', fdcId: 1 })).not.toBe(
      cacheKey({ action: 'food', fdcId: 2 }),
    );
  });
});

// Runs against the Firestore emulator that `npm test` starts.
describe('FirestoreResponseCache', () => {
  let app: App;
  let now: number;
  let cache: FirestoreResponseCache;

  beforeAll(() => {
    app = initializeApp({ projectId: demoProjectId }, 'response-cache-test');
  });

  beforeEach(async () => {
    now = Date.UTC(2026, 10, 14);
    const firestore = getFirestore(app);
    await firestore.recursiveDelete(
      firestore.collection(FirestoreResponseCache.collection),
    );
    cache = new FirestoreResponseCache(firestore, () => now);
  });

  afterAll(async () => {
    await deleteApp(app);
  });

  it('misses an entry it never stored', async () => {
    expect(await cache.get('missing')).toBeUndefined();
  });

  it('returns what it stored', async () => {
    await cache.set('key', '{"a":1}', 1000);

    expect(await cache.get('key')).toBe('{"a":1}');
  });

  it('misses an expired entry', async () => {
    await cache.set('key', '{"a":1}', 1000);
    now += 1000;

    expect(await cache.get('key')).toBeUndefined();
  });

  it('skips bodies too large for a document', async () => {
    await cache.set('key', 'x'.repeat(maxCachedBytes + 1), 1000);

    expect(await cache.get('key')).toBeUndefined();
  });
});
