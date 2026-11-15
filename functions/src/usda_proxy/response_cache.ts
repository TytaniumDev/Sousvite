import { createHash } from 'node:crypto';

import { type Firestore, Timestamp } from 'firebase-admin/firestore';

import type { UsdaRequest } from './usda_request.js';

/** Stores upstream responses as JSON text, keyed by request. */
export interface ResponseCache {
  /** The cached text for [key], or undefined when missing or expired. */
  get(key: string): Promise<string | undefined>;
  /** Caches [body] under [key] for [ttlMs]. */
  set(key: string, body: string, ttlMs: number): Promise<void>;
}

const day = 24 * 60 * 60 * 1000;

/** How long a response stays cached. Branded data changes about monthly. */
export const cacheTtlMs: Record<UsdaRequest['action'], number> = {
  search: 7 * day,
  food: 30 * day,
};

/**
 * Responses larger than this aren't cached: a Firestore document holds at
 * most 1 MiB.
 */
export const maxCachedBytes = 900_000;

/**
 * A stable cache key for [request]: the same search in any letter case
 * shares one entry.
 */
export const cacheKey = (request: UsdaRequest): string => {
  const normalized =
    request.action === 'search'
      ? { ...request, query: request.query.toLowerCase() }
      : request;
  return createHash('sha256').update(JSON.stringify(normalized)).digest('hex');
};

/**
 * A cache in the `usdaCache` Firestore collection, shared by every
 * instance. Clients can't read it (firestore.rules), and a TTL policy on
 * `expiresAt` deletes old entries (firestore.indexes.json).
 */
export class FirestoreResponseCache implements ResponseCache {
  constructor(
    private readonly firestore: Firestore,
    private readonly now: () => number = Date.now,
  ) {}

  static readonly collection = 'usdaCache';

  private doc(key: string) {
    return this.firestore
      .collection(FirestoreResponseCache.collection)
      .doc(key);
  }

  async get(key: string): Promise<string | undefined> {
    const snapshot = await this.doc(key).get();
    const data = snapshot.data();
    if (data === undefined) {
      return undefined;
    }
    const { body, expiresAt } = data as { body: string; expiresAt: Timestamp };
    // TTL deletion can lag by a day, so check expiry here too.
    return expiresAt.toMillis() > this.now() ? body : undefined;
  }

  async set(key: string, body: string, ttlMs: number): Promise<void> {
    if (Buffer.byteLength(body) > maxCachedBytes) {
      return;
    }
    await this.doc(key).set({
      body,
      expiresAt: Timestamp.fromMillis(this.now() + ttlMs),
    });
  }
}
