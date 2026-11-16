import type { Request } from 'firebase-functions/v2/https';
import { beforeEach, describe, expect, it } from 'vitest';

import {
  handleShareLinkPage,
  type PageResponse,
} from '../../src/sharing/share_link_page.js';
import {
  handlePublishLink,
  handleUnpublishLink,
} from '../../src/sharing/share_links.js';
import {
  callFrom,
  clearSharing,
  type TestSharingStores,
  testSharingStores,
} from '../helpers/sharing_test_stores.js';

const recipe = {
  title: 'Lasagna',
  yield: 'Serves 6',
  sourceName: null,
  sourceUrl: 'https://example.com/lasagna',
  ingredients: [{ title: null, items: ['1 lb ricotta'] }],
  steps: [{ title: 'Prep', items: ['Boil the noodles.'] }],
};

class FakeResponse implements PageResponse {
  code = 0;
  headers: Record<string, string> = {};
  body = '';

  status(code: number): this {
    this.code = code;
    return this;
  }

  set(field: string, value: string): this {
    this.headers[field] = value;
    return this;
  }

  send(body: string): this {
    this.body = body;
    return this;
  }
}

describe('view-only links', () => {
  let stores: TestSharingStores;
  let publish: ReturnType<typeof handlePublishLink>;
  let unpublish: ReturnType<typeof handleUnpublishLink>;
  let page: ReturnType<typeof handleShareLinkPage>;

  beforeEach(async () => {
    stores = testSharingStores();
    await clearSharing(stores.firestore);
    publish = handlePublishLink(() => stores);
    unpublish = handleUnpublishLink(() => stores);
    page = handleShareLinkPage(() => stores);
  });

  const open = async (path: string): Promise<FakeResponse> => {
    const response = new FakeResponse();
    await page({ path } as Request, response);
    return response;
  };

  it('publishes a recipe page anyone can open', async () => {
    const { linkId } = await publish(callFrom('alice', { recipe }));

    const response = await open(`/r/${linkId}`);

    expect(response.code).toBe(200);
    expect(response.headers['Content-Type']).toBe('text/html; charset=utf-8');
    expect(response.body).toContain('<h1>Lasagna</h1>');
    expect(response.body).toContain('<li>1 lb ricotta</li>');
  });

  it('republishes the same link with the latest version', async () => {
    const { linkId } = await publish(callFrom('alice', { recipe }));

    const again = await publish(
      callFrom('alice', {
        linkId,
        recipe: { ...recipe, title: 'Better lasagna' },
      }),
    );

    expect(again.linkId).toBe(linkId);
    expect((await open(`/r/${linkId}/`)).body).toContain('Better lasagna');
  });

  it("refuses to change someone else's link", async () => {
    const { linkId } = await publish(callFrom('alice', { recipe }));

    await expect(
      publish(callFrom('mallory', { linkId, recipe })),
    ).rejects.toMatchObject({ code: 'not-found' });
    await expect(
      unpublish(callFrom('mallory', { linkId })),
    ).rejects.toMatchObject({ code: 'not-found' });
  });

  it('turns a link off', async () => {
    const { linkId } = await publish(callFrom('alice', { recipe }));

    await expect(unpublish(callFrom('alice', { linkId }))).resolves.toEqual({
      deleted: true,
    });

    const response = await open(`/r/${linkId}`);
    expect(response.code).toBe(404);
    expect(response.body).toContain('Recipe not found');
  });

  it('shows not found for addresses that are not links', async () => {
    expect((await open('/r/../../etc')).code).toBe(404);
    expect((await open('/somewhere')).code).toBe(404);
  });

  it.each([
    [{}],
    [{ recipe: 'nope' }],
    [{ recipe: { ...recipe, title: '  ' } }],
    [{ recipe: { ...recipe, title: 3 } }],
    [{ recipe: { ...recipe, ingredients: 'nope' } }],
    [{ recipe: { ...recipe, steps: [null] } }],
    [{ recipe: { ...recipe, steps: [{ title: null, items: 'nope' }] } }],
    [{ recipe: { ...recipe, steps: [{ title: null, items: [3] }] } }],
    [{ recipe: { ...recipe, sourceUrl: 'javascript:alert(1)' } }],
  ])('refuses bad data %j', async (data) => {
    await expect(publish(callFrom('alice', data))).rejects.toMatchObject({
      code: 'invalid-argument',
    });
  });
});
