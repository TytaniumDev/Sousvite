import { describe, expect, it } from 'vitest';

import {
  defaultPageSize,
  maxPageSize,
  maxQueryLength,
  parseUsdaRequest,
} from '../../src/usda_proxy/usda_request.js';

describe('parseUsdaRequest', () => {
  it('normalizes a search and fills in paging', () => {
    expect(
      parseUsdaRequest({ action: 'search', query: '  cheddar \n cheese ' }),
    ).toEqual({
      action: 'search',
      query: 'cheddar cheese',
      pageNumber: 1,
      pageSize: defaultPageSize,
    });
  });

  it('keeps paging the app asks for', () => {
    expect(
      parseUsdaRequest({
        action: 'search',
        query: 'oats',
        pageNumber: 3,
        pageSize: maxPageSize,
      }),
    ).toMatchObject({ pageNumber: 3, pageSize: maxPageSize });
  });

  it('reads a food request', () => {
    expect(parseUsdaRequest({ action: 'food', fdcId: 2_345_678 })).toEqual({
      action: 'food',
      fdcId: 2_345_678,
    });
  });

  it.each([
    ['not an object', 'oats'],
    ['null', null],
    ['an unknown action', { action: 'delete' }],
    ['a missing query', { action: 'search' }],
    ['a blank query', { action: 'search', query: '   ' }],
    [
      'a long query',
      { action: 'search', query: 'a'.repeat(maxQueryLength + 1) },
    ],
    ['page 0', { action: 'search', query: 'oats', pageNumber: 0 }],
    ['a fractional page', { action: 'search', query: 'oats', pageNumber: 1.5 }],
    [
      'a huge page size',
      { action: 'search', query: 'oats', pageSize: maxPageSize + 1 },
    ],
    ['a string page size', { action: 'search', query: 'oats', pageSize: '5' }],
    ['a missing fdcId', { action: 'food' }],
    ['a negative fdcId', { action: 'food', fdcId: -1 }],
    ['a string fdcId', { action: 'food', fdcId: '123' }],
  ])('refuses %s', (_, data) => {
    expect(() => parseUsdaRequest(data)).toThrow(
      expect.objectContaining({ code: 'invalid-argument' }),
    );
  });
});
