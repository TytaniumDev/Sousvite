import type { Request } from 'firebase-functions/v2/https';
import { onRequest } from 'firebase-functions/v2/https';

import { renderMissingPage, renderRecipePage } from './recipe_page.js';
import { parseSharedRecipe } from './shared_recipe.js';
import { defaultSharingStores, type SharingStores } from './sharing_stores.js';

/** The parts of an HTTP response the page handler uses. */
export interface PageResponse {
  status(code: number): this;
  set(field: string, value: string): this;
  send(body: string): unknown;
}

/** Link ids are Firestore auto ids. */
const linkIdPattern = /^\/r\/([A-Za-z0-9]{1,64})\/?$/;

/**
 * Serves `/r/{linkId}`, which Hosting rewrites to this function: the
 * view-only page for a published recipe, or a not-found page.
 */
export const handleShareLinkPage =
  (stores: () => SharingStores) =>
  async (request: Request, response: PageResponse): Promise<void> => {
    const linkId = linkIdPattern.exec(request.path)?.[1];
    const link =
      linkId === undefined
        ? undefined
        : (await stores().firestore.doc(`shareLinks/${linkId}`).get()).data();
    response.set('Content-Type', 'text/html; charset=utf-8');
    if (link === undefined) {
      response
        .set('Cache-Control', 'no-store')
        .status(404)
        .send(renderMissingPage());
      return;
    }
    // Short CDN caching keeps repeat views cheap, while a republished or
    // turned-off link updates within minutes.
    response
      .set('Cache-Control', 'public, max-age=60, s-maxage=300')
      .status(200)
      .send(renderRecipePage(parseSharedRecipe(link.recipe)));
  };

/** View-only recipe pages for links anyone can open (PRD 7.10). */
export const shareLinkPage = onRequest(
  handleShareLinkPage(defaultSharingStores),
);
