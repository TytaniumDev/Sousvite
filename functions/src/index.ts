// Entry point for every Cloud Function. Each function lives in its own
// folder under src/ and is exported here with one line, in alphabetical
// order (BUILD_PLAN.md §3.2).
import { setGlobalOptions } from 'firebase-functions/v2';

// Same region as Cloud Storage. maxInstances caps cost if a client misbehaves.
setGlobalOptions({ region: 'us-central1', maxInstances: 10 });

export { deleteAccount } from './delete_account/delete_account.js';
export { fetchProxy } from './fetch_proxy/fetch_proxy.js';
export { acceptInvite } from './sharing/accept_invite.js';
export { leaveShare } from './sharing/leave_share.js';
export { previewInvite } from './sharing/preview_invite.js';
export { sendCopy } from './sharing/send_copy.js';
export { shareJointly } from './sharing/share_jointly.js';
export { shareLinkPage } from './sharing/share_link_page.js';
export { publishLink, unpublishLink } from './sharing/share_links.js';
export { usdaProxy } from './usda_proxy/usda_proxy.js';
