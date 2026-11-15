import { HttpsError } from 'firebase-functions/v2/https';

/** Search USDA Branded Foods by name. */
export interface UsdaSearchRequest {
  readonly action: 'search';
  /** Trimmed, with runs of whitespace collapsed. */
  readonly query: string;
  /** 1-based page. */
  readonly pageNumber: number;
  readonly pageSize: number;
}

/** Get one food, with its nutrients, by FoodData Central id. */
export interface UsdaFoodRequest {
  readonly action: 'food';
  readonly fdcId: number;
}

/** A request the app can make through the USDA proxy. */
export type UsdaRequest = UsdaSearchRequest | UsdaFoodRequest;

export const maxQueryLength = 200;
export const defaultPageSize = 25;
export const maxPageSize = 50;
export const maxPageNumber = 100;

const invalid = (message: string): HttpsError =>
  new HttpsError('invalid-argument', message);

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

const integerIn = (
  value: unknown,
  name: string,
  fallback: number,
  max: number,
): number => {
  if (value === undefined) {
    return fallback;
  }
  if (
    !Number.isInteger(value) ||
    (value as number) < 1 ||
    (value as number) > max
  ) {
    throw invalid(`${name} must be a whole number from 1 to ${String(max)}`);
  }
  return value as number;
};

const parseSearch = (data: Record<string, unknown>): UsdaSearchRequest => {
  const { query } = data;
  if (typeof query !== 'string') {
    throw invalid('query must be a string');
  }
  const normalized = query.trim().replace(/\s+/g, ' ');
  if (normalized === '' || normalized.length > maxQueryLength) {
    throw invalid(`query must be 1 to ${String(maxQueryLength)} characters`);
  }
  return {
    action: 'search',
    query: normalized,
    pageNumber: integerIn(data.pageNumber, 'pageNumber', 1, maxPageNumber),
    pageSize: integerIn(
      data.pageSize,
      'pageSize',
      defaultPageSize,
      maxPageSize,
    ),
  };
};

const parseFood = (data: Record<string, unknown>): UsdaFoodRequest => {
  const { fdcId } = data;
  if (!Number.isSafeInteger(fdcId) || (fdcId as number) < 1) {
    throw invalid('fdcId must be a positive whole number');
  }
  return { action: 'food', fdcId: fdcId as number };
};

/** Checks the data the app sent and normalizes it into a UsdaRequest. */
export const parseUsdaRequest = (data: unknown): UsdaRequest => {
  if (!isRecord(data)) {
    throw invalid('Expected an object');
  }
  switch (data.action) {
    case 'search':
      return parseSearch(data);
    case 'food':
      return parseFood(data);
    default:
      throw invalid('action must be "search" or "food"');
  }
};
