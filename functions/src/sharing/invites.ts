import type { Firestore } from 'firebase-admin/firestore';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';

/** How long an invite link works after it's made. */
export const inviteLifetimeDays = 14;

/** What opening an invite link gives the recipient (PRD 7.10). */
export type InviteKind = 'joint' | 'copy';

/** The fields every invite document has. */
interface InviteBase {
  readonly kind: InviteKind;

  /** What the recipient sees before accepting: the recipe or folder name. */
  readonly title: string;
  readonly fromUid: string;
  readonly fromName: string | null;
  readonly expiresAt: Timestamp;
}

/** `invites/{inviteId}` for a joint share: joins [spaceId]. */
export interface JointInvite extends InviteBase {
  readonly kind: 'joint';
  readonly spaceId: string;
}

/** `invites/{inviteId}` for send a copy: the copied entities. */
export interface CopyInvite extends InviteBase {
  readonly kind: 'copy';

  /**
   * Every entity of the copied recipe or folder, each as
   * `{ entity, entityId, fields }` in the app's change log encoding. The
   * recipient's app gives them new ids when it imports them.
   */
  readonly entities: readonly unknown[];
}

/** One invite document. */
export type Invite = JointInvite | CopyInvite;

/** The parts of an invite its creator decides. */
export type NewInvite =
  Omit<JointInvite, 'expiresAt'> | Omit<CopyInvite, 'expiresAt'>;

/**
 * Stores [invite] under a new random id, which is the secret part of the
 * link, and returns the id.
 */
export const createInvite = async (
  firestore: Firestore,
  invite: NewInvite,
  now: Date,
): Promise<string> => {
  const ref = firestore.collection('invites').doc();
  await ref.set({
    ...invite,
    createdAt: FieldValue.serverTimestamp(),
    expiresAt: Timestamp.fromMillis(
      now.getTime() + inviteLifetimeDays * 24 * 60 * 60 * 1000,
    ),
  });
  return ref.id;
};
