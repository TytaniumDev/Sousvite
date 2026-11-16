import { type CallableRequest, HttpsError } from 'firebase-functions/v2/https';

/** The longest share or recipe title the functions store. */
export const maxTitleLength = 200;

/**
 * The most bytes of JSON one copy or one view-only recipe may hold, which
 * keeps each document under Firestore's 1 MiB limit with room to spare.
 */
export const maxPayloadBytes = 900 * 1024;

/** The signed-in caller, or an `unauthenticated` error. */
export const requireUid = (request: CallableRequest<unknown>): string => {
  const uid = request.auth?.uid;
  if (uid === undefined) {
    throw new HttpsError('unauthenticated', 'Sign in to share');
  }
  return uid;
};

/**
 * The caller's display name from their sign-in, shown to the people they
 * share with. Apple can leave it out, so the app has a fallback word.
 */
export const callerName = (
  request: CallableRequest<unknown>,
): string | null => {
  const name = request.auth?.token.name as unknown;
  return typeof name === 'string' && name.trim() !== '' ? name.trim() : null;
};

/** The request's data as a plain object, or an `invalid-argument` error. */
export const requireObject = (data: unknown): Record<string, unknown> => {
  if (typeof data !== 'object' || data === null || Array.isArray(data)) {
    throw invalid('Expected an object');
  }
  return data as Record<string, unknown>;
};

/** A non-empty string field, at most [maxLength] characters. */
export const requireString = (
  data: Record<string, unknown>,
  field: string,
  maxLength = maxTitleLength,
): string => {
  const value = data[field];
  if (
    typeof value !== 'string' ||
    value.trim() === '' ||
    value.length > maxLength
  ) {
    throw invalid(
      `Expected ${field} to be a string of 1 to ${String(maxLength)} characters`,
    );
  }
  return value.trim();
};

/** Like [requireString], but the field may be left out. */
export const optionalString = (
  data: Record<string, unknown>,
  field: string,
  maxLength = maxTitleLength,
): string | undefined =>
  data[field] === undefined ? undefined : requireString(data, field, maxLength);

/** Throws `invalid-argument` if [value] is more JSON than one document holds. */
export const requireFits = (value: unknown, field: string): void => {
  if (Buffer.byteLength(JSON.stringify(value)) > maxPayloadBytes) {
    throw new HttpsError('invalid-argument', `${field} is too large`, {
      reason: 'tooLarge',
    });
  }
};

/** An `invalid-argument` error with [message]. */
export const invalid = (message: string): HttpsError =>
  new HttpsError('invalid-argument', message);
