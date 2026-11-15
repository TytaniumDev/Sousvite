import { HttpsError } from 'firebase-functions/v2/https';

import type { UsdaRequest } from './usda_request.js';

/** How long one upstream request may take. */
export const upstreamTimeoutMs = 10_000;

/**
 * The URL path and query for [request], relative to the API base URL.
 * Searches are limited to Branded Foods, since generic foods are bundled
 * with the app (ENGINEERING.md §11.1).
 */
export const upstreamPath = (request: UsdaRequest): string => {
  switch (request.action) {
    case 'search': {
      const query = new URLSearchParams({
        query: request.query,
        dataType: 'Branded',
        pageNumber: String(request.pageNumber),
        pageSize: String(request.pageSize),
      });
      return `foods/search?${query.toString()}`;
    }
    case 'food':
      return `food/${String(request.fdcId)}`;
  }
};

const errorFor = (status: number): HttpsError => {
  if (status === 404) {
    return new HttpsError('not-found', 'No such food');
  }
  if (status === 429) {
    return new HttpsError('resource-exhausted', 'USDA rate limit reached');
  }
  return new HttpsError('unavailable', `USDA answered ${String(status)}`);
};

/**
 * Sends requests to FoodData Central. The API key goes in a header, never
 * the URL, so it can't leak through logs or error messages.
 */
export class UsdaClient {
  constructor(
    /** The API root, such as `https://api.nal.usda.gov/fdc/v1/`. */
    private readonly baseUrl: string,
    /** The api.data.gov key, from the USDA_API_KEY function secret. */
    private readonly apiKey: string,
  ) {}

  /** Sends [request] and returns the response body as JSON text. */
  async send(request: UsdaRequest): Promise<string> {
    const base = this.baseUrl.endsWith('/') ? this.baseUrl : `${this.baseUrl}/`;
    let response: Response;
    try {
      response = await fetch(new URL(upstreamPath(request), base), {
        headers: { accept: 'application/json', 'x-api-key': this.apiKey },
        signal: AbortSignal.timeout(upstreamTimeoutMs),
      });
    } catch {
      throw new HttpsError('unavailable', 'Could not reach USDA');
    }
    if (!response.ok) {
      await response.body?.cancel();
      throw errorFor(response.status);
    }
    return response.text();
  }
}
