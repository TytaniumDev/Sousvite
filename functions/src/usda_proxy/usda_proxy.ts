import { getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { defineSecret, defineString } from 'firebase-functions/params';
import { logger } from 'firebase-functions/v2';
import { onCall } from 'firebase-functions/v2/https';

import {
  cacheKey,
  cacheTtlMs,
  FirestoreResponseCache,
  type ResponseCache,
} from './response_cache.js';
import { UsdaClient } from './usda_client.js';
import { parseUsdaRequest } from './usda_request.js';

/** The api.data.gov key (BUILD_PLAN.md §8.6). Never sent to the client. */
export const usdaApiKey = defineSecret('USDA_API_KEY');

/**
 * The FoodData Central API root. Emulator tests point it at a fake
 * upstream in `.env.demo-sousvite`.
 */
export const usdaApiBaseUrl = defineString('USDA_API_BASE_URL', {
  default: 'https://api.nal.usda.gov/fdc/v1/',
});

/** What the proxy needs, so tests can pass fakes. */
export interface UsdaProxyDependencies {
  readonly client: () => Pick<UsdaClient, 'send'>;
  readonly cache: () => ResponseCache;
}

/**
 * Handles one proxy call: validate, answer from the cache when it can,
 * otherwise ask USDA and cache the answer. Returns USDA's JSON unchanged.
 */
export const handleUsdaProxy =
  ({ client, cache }: UsdaProxyDependencies) =>
  async ({ data }: { data: unknown }): Promise<unknown> => {
    const request = parseUsdaRequest(data);
    const key = cacheKey(request);
    const cached = await cache().get(key);
    if (cached !== undefined) {
      return JSON.parse(cached) as unknown;
    }
    const body = await client().send(request);
    const parsed = JSON.parse(body) as unknown;
    try {
      await cache().set(key, body, cacheTtlMs[request.action]);
    } catch (error) {
      // A cache failure shouldn't fail the lookup.
      logger.warn('Could not cache a USDA response', { error });
    }
    return parsed;
  };

const firestore = () => getFirestore(getApps()[0] ?? initializeApp());

/**
 * Searches USDA Branded Foods and fetches foods by id for the app's
 * online nutrition lookups (ENGINEERING.md §11.1), adding the API key on
 * the server. App Check limits callers to our apps.
 */
export const usdaProxy = onCall(
  { enforceAppCheck: true, secrets: [usdaApiKey] },
  handleUsdaProxy({
    client: () => new UsdaClient(usdaApiBaseUrl.value(), usdaApiKey.value()),
    cache: () => new FirestoreResponseCache(firestore()),
  }),
);
