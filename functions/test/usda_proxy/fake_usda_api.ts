import { createServer, type IncomingHttpHeaders, type Server } from 'node:http';
import type { AddressInfo } from 'node:net';

/** A request the fake API received. */
export interface ReceivedRequest {
  readonly url: string;
  readonly headers: IncomingHttpHeaders;
}

/** A search response in FoodData Central's shape, trimmed. */
export const searchResponse = {
  totalHits: 1,
  currentPage: 1,
  totalPages: 1,
  foods: [
    {
      fdcId: 2_345_678,
      description: 'CHEDDAR CHEESE',
      dataType: 'Branded',
      brandOwner: 'Example Dairy',
    },
  ],
};

/** A food response in FoodData Central's shape, trimmed. */
export const foodResponse = {
  fdcId: 2_345_678,
  description: 'CHEDDAR CHEESE',
  dataType: 'Branded',
  servingSize: 28,
  servingSizeUnit: 'g',
  foodNutrients: [{ nutrient: { id: 1003, name: 'Protein' }, amount: 25 }],
};

/**
 * A stand-in for the FoodData Central API under `/fdc/v1/`, recording every
 * request. Food 2345678 exists; other foods are 404; `/food/429` and
 * `/food/500` answer with those statuses.
 */
export class FakeUsdaApi {
  readonly received: ReceivedRequest[] = [];

  private readonly server: Server = createServer((request, response) => {
    const url = request.url ?? '';
    this.received.push({ url, headers: request.headers });
    const path = url.split('?')[0];
    const reply = (status: number, body: unknown) => {
      response.writeHead(status, { 'content-type': 'application/json' });
      response.end(JSON.stringify(body));
    };
    if (path === '/fdc/v1/foods/search') {
      reply(200, searchResponse);
    } else if (path === '/fdc/v1/food/2345678') {
      reply(200, foodResponse);
    } else if (path === '/fdc/v1/food/429') {
      reply(429, { error: 'rate limited' });
    } else if (path === '/fdc/v1/food/500') {
      reply(500, { error: 'oops' });
    } else {
      reply(404, { error: 'not found' });
    }
  });

  /** Listens on [port] (any free port for 0) and returns the API root. */
  async start(port = 0): Promise<string> {
    await new Promise<void>((resolve) => {
      this.server.listen(port, '127.0.0.1', resolve);
    });
    const { port: actual } = this.server.address() as AddressInfo;
    return `http://127.0.0.1:${String(actual)}/fdc/v1/`;
  }

  async stop(): Promise<void> {
    this.server.closeAllConnections();
    await new Promise((resolve) => this.server.close(resolve));
  }
}
