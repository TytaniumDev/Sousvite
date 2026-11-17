import type { Firestore } from 'firebase-admin/firestore';

/** A member's details that the others see in the share's header. */
export interface SpaceMember {
  readonly name: string | null;
}

/**
 * `spaces/{spaceId}` for a joint share (ENGINEERING.md §9.1). Only the
 * sharing functions write it; members read it.
 */
export interface SharedSpace {
  readonly kind: 'shared';

  /** The recipe or folder name when it was shared. */
  readonly name: string;
  readonly ownerUid: string;
  readonly memberUids: readonly string[];
  readonly members: Readonly<Record<string, SpaceMember>>;
}

/** Shared space ids start with this; private ones are `u_{uid}`. */
export const sharedSpacePrefix = 's_';

/** A new id for a shared space. */
export const newSharedSpaceId = (firestore: Firestore): string =>
  `${sharedSpacePrefix}${firestore.collection('spaces').doc().id}`;

/** Whether [data] is a shared space document. */
export const isSharedSpace = (
  data: FirebaseFirestore.DocumentData | undefined,
): data is SharedSpace => data?.kind === 'shared';
