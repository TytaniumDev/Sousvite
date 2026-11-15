import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { upstreamPath, UsdaClient } from '../../src/usda_proxy/usda_client.js';
import { FakeUsdaApi, foodResponse, searchResponse } from './fake_usda_api.js';

const apiKey = 'test-usda-key';

describe('upstreamPath', () => {
  it('searches Branded Foods only', () => {
    expect(
      upstreamPath({
        action: 'search',
        query: 'cheddar cheese',
        pageNumber: 2,
        pageSize: 10,
      }),
    ).toBe(
      'foods/search?query=cheddar+cheese&dataType=Branded&pageNumber=2&pageSize=10',
    );
  });

  it('gets a food by id', () => {
    expect(upstreamPath({ action: 'food', fdcId: 42 })).toBe('food/42');
  });
});

describe('UsdaClient', () => {
  const api = new FakeUsdaApi();
  let root: string;
  let client: UsdaClient;

  beforeAll(async () => {
    root = await api.start();
    client = new UsdaClient(root, apiKey);
  });

  afterAll(async () => {
    await api.stop();
  });

  it('returns the search response', async () => {
    const body = await client.send({
      action: 'search',
      query: 'cheddar',
      pageNumber: 1,
      pageSize: 25,
    });

    expect(JSON.parse(body)).toEqual(searchResponse);
  });

  it('sends the key in a header, never the URL', async () => {
    await client.send({ action: 'food', fdcId: 2_345_678 });

    const request = api.received.at(-1);
    expect(request?.headers['x-api-key']).toBe(apiKey);
    expect(request?.url).not.toContain(apiKey);
  });

  it('works with a base URL that has no trailing slash', async () => {
    const noSlash = new UsdaClient(root.slice(0, -1), apiKey);

    const body = await noSlash.send({ action: 'food', fdcId: 2_345_678 });

    expect(JSON.parse(body)).toEqual(foodResponse);
  });

  it.each([
    [404, 'not-found'],
    [429, 'resource-exhausted'],
    [500, 'unavailable'],
  ])('maps a %i to %s', async (status, code) => {
    const fdcId = status === 404 ? 1 : status;

    await expect(client.send({ action: 'food', fdcId })).rejects.toMatchObject({
      code,
    });
  });

  it('reports an unreachable API as unavailable', async () => {
    const offline = new UsdaClient('http://127.0.0.1:9/fdc/v1/', apiKey);

    await expect(
      offline.send({ action: 'food', fdcId: 1 }),
    ).rejects.toMatchObject({ code: 'unavailable' });
  });

  it('returns food responses unchanged', async () => {
    const body = await client.send({ action: 'food', fdcId: 2_345_678 });

    expect(JSON.parse(body)).toEqual(foodResponse);
  });
});
