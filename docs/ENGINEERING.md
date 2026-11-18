# Sousvite: Engineering Design

| | |
|---|---|
| **Status** | Draft |
| **Owner** | Tyler |
| **Last updated** | 2026-11-13 |
| **Companion doc** | [PRD](PRD.md) |

---

## 1. Purpose

This document records the architecture and technology decisions for Sousvite, and the reasoning behind them. The PRD says *what* we build. This doc says *how*. When a decision changes, update this doc in the same pull request as the change.

Each decision is marked:

- **Decided:** chosen explicitly by Tyler.
- **Default:** the standard choice, picked during drafting and open to review.

## 2. Engineering principles

1. **Flutter everywhere.** One codebase for iOS, Android, and web. *(Decided)*
2. **Clean architecture.** Presentation, application, domain, and data layers, with dependencies pointing inward only. The domain knows nothing about Flutter, Drift, or Firebase. *(Decided)*
3. **Small, composable UI.** Screens are built from small widgets. Each widget rebuilds **only** when the data it renders changes. This is checked in tests, not just in review (see §5 and §15). *(Decided)*
4. **Offline first.** The local database is the source of truth. The UI never waits on the network to show or save data.
5. **Deterministic.** No AI or ML anywhere (PRD non-goal). Parsing, matching, and suggestions are rule-based, explainable, and testable.
6. **Small, reusable modules.** Logic lives in small pure-Dart packages with narrow public APIs and their own tests.
7. **Consistency over cleverness.** One way to do each thing (state, navigation, models, errors), enforced by lints and code review.

## 3. Decision summary

| Area | Choice | Status |
|---|---|---|
| UI framework | Flutter (iOS, Android, web) | Decided |
| Toolchain | Latest stable Flutter and Dart (3.50 and 3.14 today), pinned in `.fvmrc`; Material from `material_ui` (§16.1) | Decided |
| State management and DI | Riverpod 3 with code generation | Decided |
| Local database | Drift (SQLite; WebAssembly SQLite on web) | Decided |
| Sync model | Change log with per-field merge and hybrid logical clocks | Decided |
| Free sync transport | User's Google Drive (hidden app data folder) | PRD |
| Pro backend | Firebase: Auth, Firestore, Cloud Functions, Hosting | Decided |
| Sign-in | Optional; Google and Apple via Firebase Auth | PRD |
| USDA nutrition data | Generic foods bundled; branded foods fetched through our proxy and cached | Decided |
| Open Food Facts | Fetched online and cached | Decided |
| URL import | On device; web goes through a thin fetch proxy | Decided |
| Ingredient parsing | Our own rule-based Dart parser | Decided |
| Code structure | Pub workspace: Flutter app plus pure-Dart core packages | Decided |
| Testing | Unit (with fixtures), widget (with rebuild counts), golden, integration | Decided |
| Lints | `very_good_analysis` plus extra consistency rules in one root `analysis_options.yaml` (§16) | Decided |
| CI | GitHub Actions using `very_good_workflows`, added with the app scaffold PR | Decided |
| Mocking | `mocktail` (no code generation) | Decided |
| Routing | `go_router` | Default |
| Immutable models | `freezed` + `json_serializable` | Default |
| Subscriptions | RevenueCat (App Store, Play, web via Stripe) | Default |
| Crash and error reporting | Sentry (works on all three platforms) | Default |
| Release builds | fastlane on GitHub Actions; one Firebase project (no dev/prod split) | Decided |

## 4. Architecture

### 4.1 Layers

```
┌────────────────────────────────────────────────────────────┐
│ Presentation   widgets, screens, routes                    │
│                reads providers, never calls repositories   │
├────────────────────────────────────────────────────────────┤
│ Application    Riverpod providers / notifiers, use cases   │
│                orchestrates domain + repositories          │
├────────────────────────────────────────────────────────────┤
│ Domain         entities, value objects, repository         │
│                interfaces, pure logic (scaling, measuring, │
│                nutrition math). Pure Dart.                 │
├────────────────────────────────────────────────────────────┤
│ Data           Drift DB, repositories, sync engine,        │
│                transports (Drive, Firestore), HTTP clients │
└────────────────────────────────────────────────────────────┘
```

- Dependencies point inward. Data implements the repository interfaces that domain defines.
- Repositories expose **streams** (Drift watch queries), so every change flows to the UI automatically, whether it was made locally or arrived through sync.
- Writes go through use cases, which write to Drift **and** append to the change log in the same transaction (§7).

### 4.2 Module structure *(Decided)*

The repo is a [pub workspace](https://dart.dev/tools/pub/workspaces): one root `pubspec.yaml` lists the member packages. They share one lockfile and one `pub get`.

```
apps/
  sousvite/                Flutter app. Features as folders:
                           library, recipe, editor, import, nutrition,
                           cooking, grocery, experiments, sharing,
                           settings, account
packages/
  units/                   Quantity, Unit, Amount, conversion, scaling,
                           measurable rounding, fraction-glyph formatting.
                           Pure Dart with no repo dependencies.
  domain/                  Entities, value objects, repository interfaces,
                           pure logic. No Flutter, Drift, or Firebase.
                           Re-exports units.
  data/                    Drift schema, DAOs, repository implementations
  sync/                    Change log, hybrid logical clock, merge,
                           transports (Google Drive, Firestore)
  ingredient_parser/       "1 ½ cups rolled oats, chopped" → structured line
  recipe_import/           URL (schema.org) and Umami import/export
  nutrition/               Food matching, unit → gram conversion, totals
  measuring/               Measuring-tool decomposition, smart step text
  design_system/           Theme, tokens, shared small widgets
tools/
  usda_builder/            CLI that builds the bundled USDA SQLite file
functions/                 Firebase Cloud Functions (TypeScript)
```

Rules:

- `units` depends on nothing in the repo. It is the shared vocabulary for amounts, so the UI and the domain use the same `Quantity` type *(Decided: Tyler, 2026-11-14)*.
- `domain` depends only on `units`, and re-exports it, so `package:domain/domain.dart` still gives every unit type. Pure packages (`ingredient_parser`, `recipe_import`, `nutrition`, `measuring`) depend only on `domain` within the repo, except that `recipe_import` uses `ingredient_parser` to split the lines it imports. Outside it they take pure Dart libraries only, and only when the alternative is writing a parser by hand: `recipe_import` uses `package:html` to read recipe pages and `package:archive` (its web-safe `archive.dart`) for Umami's zip files. Anything that does I/O (HTTP, files) is passed in as a function, so the packages stay testable without a network.
- `design_system` may depend on `units` (never on `domain`), so widgets such as `AmountText` take a `Quantity` directly.
- `sync` depends only on `domain` and never on Drift. `data` depends on `sync` for the change model and clock (its `ChangeRecorder` writes the change log), and implements the local store the sync engine defines, so the engine is tested without a database.
- Only `apps/sousvite` depends on Flutter, except for `design_system`.
- Features are folders inside the app, not packages, to avoid glue code between them.
- Each feature folder mirrors the layers: `presentation/`, `application/`, and feature-specific `data/` when needed.

## 5. UI composition and rebuild discipline *(Decided)*

The goal is that a change to one field rebuilds only the widgets that show that field.

**Rules:**

1. **One widget, one concern.** A widget that renders a recipe's title watches only the title. A widget that shows one ingredient line watches only that line.
2. **Granular providers.** Providers are keyed by id with `family`, such as `ingredientLineProvider(lineId)`. Lists pass **ids** down, never whole objects, so a change to one item doesn't rebuild its siblings or its parent.
3. **`select()` for fields.** `ref.watch(recipeProvider(id).select((r) => r.title))` rebuilds only when the title changes.
4. **Value equality everywhere.** Entities are `freezed` classes with `==` and `hashCode`, so `select()` and Drift streams don't emit for no-op changes. Drift queries feeding providers use `distinct()`.
5. **`const` constructors** wherever possible (enforced by lints).
6. **No widget-returning helper methods.** Extract a widget class instead, so Flutter can skip rebuilding it.
7. **Keys on list items** (`ValueKey(id)`), so reordering sections and steps moves widgets rather than rebuilding them.
8. **Animations and timers stay local.** Cooking-mode timers live in their own small widget and provider, so a ticking clock doesn't rebuild the step text.

**Enforcement:** Widget tests use a small `BuildCounter` test helper to assert rebuild counts. For example, after editing one ingredient's amount, only that line's widget and the nutrition summary rebuild (§15).

## 6. State management: Riverpod 3 *(Decided)*

- Code generation (`@riverpod`) for all providers, for consistent naming and compile-time safety.
- **Repository providers** expose the data layer, and tests override them with fakes.
- **Stream providers** wrap Drift watch queries, and the UI handles `AsyncValue` loading, error, and data states consistently through a shared `AsyncValueView` widget.
- **Notifiers** hold transient UI state, such as editor drafts, the cooking-mode step index, and grocery-list selection.
- `autoDispose` is the default. Keep-alive is used only for app-wide state (auth, settings, the sync status).
- Riverpod is the only DI mechanism. No `get_it` and no global singletons.

## 7. Local data: Drift *(Decided)*

- SQLite on iOS and Android. On web, SQLite compiled to WebAssembly, stored in the Origin Private File System (falling back to IndexedDB).
- The database is the single source of truth. The UI reads only from it.
- **Full-text search** (FTS5) indexes recipe titles, ingredient names, and folder names (PRD 7.1). Triggers keep the `recipe_search` table current on every write, local or synced, and each typed word matches the start of a word, ignoring accents.
- **Amounts** are exact rational numbers (numerator and denominator), not floats, so ⅓ cup × 3 is exactly 1 cup.
- **Units** (`packages/units/`): each unit belongs to a family (US volume, metric volume, US mass, metric mass, count) and counts a whole number of the family's smallest unit, so conversion within a family is exact. US to metric is approximate and always ends in **measurable rounding**: friendly cup fractions (¼, ⅓, ½, ⅔, ¾), tablespoons to ½, teaspoons to ⅛, metric to 0.5, 1, or 5 depending on size, ounces and pounds to ¼, counts to ¼ or ½. A friendly amount may be at most 5% off before rounding falls back to a smaller unit. Rounding applies only to scaled or converted amounts; unscaled amounts show as written.
- **Ordering** of sections, steps, and ingredients uses fractional index keys, so moving one item changes one row and merges cleanly during sync.
- **Migrations** are versioned with Drift's schema tooling and tested with generated schema snapshots.

### 7.1 Core entities

| Entity | Notes |
|---|---|
| `Recipe` | Title, photo ref, servings, times, notes, source URL and attribution |
| `IngredientLine` | Raw text plus parsed quantity, unit or count word, name, preparation; sort key; optional section |
| `StepSection` | Named section ("Prep"), sort key |
| `Step` | Text, sort key, section |
| `Folder`, `FolderEntry` | Many-to-many (a recipe can be in several folders) |
| `NutritionMatch` | Ingredient line → food id, source (USDA or Open Food Facts), gram weight, user-confirmed flag |
| `Food`, `FoodNutrient`, `FoodPortion` | Bundled USDA data (read-only) plus cached branded and Open Food Facts foods |
| `RecipeVersion` | Snapshot of a recipe at a point in history |
| `Experiment` | Copy of a recipe version with change description, notes, share flag, outcome |
| `GroceryList`, `GroceryItem` | Items link back to source ingredient lines for combining, and keep the line's unit or count word, so "3 cloves garlic" and "2 cloves garlic" add up to "5 cloves garlic" |
| `MeasuringTool` | Tools the user owns (PRD 7.5) |
| `UserRecipePrefs` | Per-user serving size and units, kept separate from the recipe so joint shares don't overwrite them |
| `ChangeLog`, `SyncState` | See §8 |
| `LocalValues` | Values that stay on this device and never sync, such as its device id |

The bundled USDA database ships as a separate, read-only SQLite file, so app updates can replace it without migrations. The app opens it as its own connection from the asset's bytes (an in-memory file system, so the same code runs on native SQLite and WebAssembly) rather than attaching it to the main database; `DriftFoodRepository` reads the local cache first, then the bundled file.

### 7.2 Recipe photos

- Photos are not in the database. `Recipe.photoRef` names one, and a `PhotoStore` (`app/lib/shared/photos/`) keeps the bytes: one JPEG file per photo in the app's support folder on iOS and Android, and an IndexedDB object store on web. The database stays small, and photo sync (MEDIA-2) moves files on its own schedule.
- Every saved photo is shrunk to at most 1600 px on its longest side, turned upright, and saved as a JPEG. Picking asks the system picker for a JPEG of that size, which also converts iPhone HEIC photos.
- `photoRef` is a photo id (a uuid) for a photo saved on this device, or an `https` address for an imported photo that couldn't be downloaded (offline, or a site that blocks reads from web pages). Import tries to download the photo first, so it shows offline. On web, a photo still at its address shows through an `<img>` element when the site blocks reading it.
- A photo that is replaced, or whose recipe is deleted, stays in the store: recipe history (`RecipeVersion`) may still point at it. Synced photos are never deleted either (§9.1); cleaning up photos nothing points at is left for later.
- **Photo sync:** after each space syncs, `PhotoSync` (`app/lib/features/account/sync/application/`) looks at the photo ids its current recipes show. A photo on this device is uploaded to the space's `BlobStore` (Drive app folder, or Cloud Storage for Sousvite cloud and joint shares); one only on the server is downloaded. Ids that are done are remembered per transport in `local_values`, so each photo moves once, and switching sources uploads them again. A photo no device has uploaded yet is tried on the next sync. `https` addresses are not synced.

## 8. Sync *(Decided)*

### 8.1 Model: a change log with per-field merge

Every local write produces **change records** in the same transaction as the write:

```
Change {
  id            unique id
  entity        "recipe" | "ingredient_line" | ...
  entityId
  field         "title" | "quantity" | "sortKey" | "_deleted" | ...
  value         JSON
  hlc           hybrid logical clock timestamp
  deviceId
  spaceId       which library or share this belongs to
}
```

- **Hybrid logical clocks (HLC)** give every change a timestamp that is ordered consistently across devices, even when their clocks disagree.
- **Merge rule:** for each `(entity, entityId, field)`, the change with the highest HLC wins. Edits to different fields never conflict. Editing a recipe's title on a phone and its steps on a laptop keeps both edits.
- **Deletes** are tombstones (`_deleted = true`), so a delete and an offline edit resolve predictably.
- **Never silently discard.** When a concurrent edit loses on a long text field (notes, step text), the losing value is kept in the recipe's history, so it can be recovered. This addresses the PRD's sync-conflict risk.
- Applying remote changes is idempotent, and the same changes arriving twice is harmless.
- **In `packages/data`:** each entity kind has an `EntityCodec` that maps it to its change log fields. Repositories write through `ChangeRecorder` and record only the fields that differ from the stored row (`ChangeSet.setChanged`), so saving a whole entity never overwrites another device's edit to a field it did not touch. Remote changes reach the tables through a `MaterializingApplier` per entity kind, which rebuilds the row from the winning value of each field and writes it once every required field has arrived.
- **Full backup, never pruned.** The cloud always holds everything needed to rebuild the whole library: a recipe's first changes carry every field, and later changes carry each edit. Changes are **kept forever**, so the log is a complete edit-by-edit backup. Recipe data is small (a few MB for a large library), so this costs almost nothing.
- **Snapshots** of the current state are written after every 200 pushed changes or once a day, whichever comes first. They only let new devices start fast; they never replace the log. A new device reads the latest snapshot, then the changes after it.

### 8.2 Transports

The sync engine is transport-agnostic. One interface, two implementations:

```dart
abstract interface class SyncTransport {
  Future<void> push(List<Change> changes);
  // Each batch carries the cursor that resumes after it. No cursor starts
  // from the latest snapshot.
  Stream<({List<Change> changes, SyncCursor cursor})> pull({SyncCursor? since});
  Future<void> writeSnapshot(Snapshot snapshot);
}
```

The engine (`packages/sync/lib/src/engine/`) talks to the database through a `LocalStore` interface that `packages/data` implements. It pushes only this device's own changes, merges each pulled batch in one local transaction, and saves the cursor in that transaction, so an interrupted sync resumes without loss. The app writes a snapshot after every 200 pushed changes or daily (§8.1), and switching transports is `replay()`: a snapshot of the current state into the new transport. The app pushes and pulls before it writes a snapshot, and a snapshot that fails is reported and tried again on the next sync, so it never holds back the log.

| | Google Drive (free) | Sousvite cloud (Pro at launch; everyone in the beta) |
|---|---|---|
| Storage | Hidden `appDataFolder` in the user's Drive (`drive.appdata` scope). Counts against the user's own Google storage (15 GB free); recipe data is a few MB | Firestore, with snapshot files in Cloud Storage (§9.1) |
| Layout | `changes/{deviceId}/{seq}.json`: append-only, one file per push, never deleted. `snapshots/{hlc}.json.gz`, plus `latest.json` pointing at the newest | `spaces/{spaceId}/batches/{batchId}`: one document per push (§9.1) |
| Freshness | Poll on app open, on resume, and every few minutes while active | Realtime listener |
| Sign-in | Google only | Google or Apple |

- **Drive limits:** Drive API calls are free to us, and Google's per-user rate limits are far above what polling uses. Going over returns a retryable 403 or 429 and is never billed, so the transport backs off exponentially.
- **Drive on web:** the browser gets a Google access token that expires after about an hour, with no refresh token. The web app asks Google Identity Services for a new token silently when it expires. If Google needs the user to click, sync pauses and `SyncStatusIcon` shows "Sign in again" instead of interrupting with a popup. Web syncs only while a tab is open.

Because both carry the same change log, **switching transports** means replaying the local state into the new transport, with nothing to convert (PRD 7.8). Both transports run against the same shared test suite (§15).

### 8.3 Recipe history

Each **Save** in the recipe editor writes one `RecipeVersion` (§7.1) in the same transaction: the full recipe as it was saved, with its time and device. The history timeline lists these versions, and restoring one is a normal edit that sets every field back, so it syncs like any other change and is itself undoable. Versions are entities, so they sync and are backed up like recipes. The losing side of a concurrent long-text edit (§8.1) appears in the same timeline. Because the change log is never pruned, finer history can be rebuilt from it later if versions per Save turn out too coarse.

### 8.4 Spaces and sharing

- A **space** is a set of entities that sync together. Each user has a private space, and each joint share is its own space with members.
- Joint shares always live in Firestore, even for Drive-sync users (PRD 7.12).
- **Share jointly:** the recipe or folder moves into a new shared space, and membership is enforced by Firestore security rules.
- **Which space a recipe is in** is itself a change: the field `_space` on the `recipe` entity, whose value is the shared space id or null for the user's own library. The latest one wins, like any field, so a stale device can't move a recipe back. Moving (`RecipeSpaceRepository`) records every field of the recipe and its parts again in the new space, so its members get the whole recipe, then the `_space` change: in the shared space when moving in, so every member learns it, and in the private space only when moving out, so the others keep it. From then on `DriftRecipeRepository` records each edit of the recipe or its parts in the recipe's space. Folder entries, experiments, and preferences stay private.
- **Invite links** pick the recipients (Tyler, 2026-11-16): sharing makes a link (`https://sousvite.web.app/invite/{id}`, valid 14 days) that the sharer sends through any app. Opening it in the app (signed in) shows whether it's a joint share or a copy, then accepts it. This works for Apple users with hidden emails and for people who don't have the app yet. Invites are stored in `invites/{inviteId}`, written and read only by the sharing functions (`functions/src/sharing/`).
- **Send a copy:** the sender's app sends every entity of the recipe in its change log encoding (`RecipeSnapshotCodec`). Accepting returns them to the recipient's app, which saves them with new ids (`copyRecipe`) as its own recipe, so they sync to the recipient's other devices like any recipe. There is no server inbox.
- **Leaving or deleting** a joint share removes the user from the space and keeps a local copy for the others (PRD 7.10). The leaver's app moves the share's recipes back to their own library first (`moveToOwnLibrary`); deleting then removes their copy only.
- **Experiments in shared recipes** stay in the creator's private space unless "Share with others" is on, and then they move into the shared space with their working recipe and base version. Turning it off moves them back for the creator only; the others keep the shared copy. Other versions (history) stay private.
- **View-only links:** the app publishes the recipe as plain text (`shareLinks/{linkId}`), and the `shareLinkPage` function renders it at `/r/{linkId}` on Firebase Hosting, with the source credited and `noindex`. Publishing again replaces it, and the owner can turn a link off.
- **Pro check:** at launch, a share syncs only while at least one member has Pro. The entitlement is stored server-side and enforced by rules and the sharing functions (§9.2). **During the beta the gate is off**, so sharing works for everyone.

## 9. Backend: Firebase *(Decided)*

| Service | Use |
|---|---|
| Firebase Auth | Google and Apple sign-in. Signed-out users have no account at all. |
| Firestore | Change logs for Sousvite cloud sync, shared spaces, membership, invites, view-only links (§9.1) |
| Cloud Functions | Fetch proxy for web URL import, USDA API proxy (hides the API key), send-a-copy, share links, subscription webhooks |
| Cloud Storage | Recipe photos for Sousvite cloud users and shares; sync snapshot files |
| Hosting | Flutter web app and view-only recipe pages |
| App Check | Limits the proxies to our apps. Release builds attest with App Attest (iOS), Play Integrity (Android), and reCAPTCHA Enterprise (web); debug builds use the debug provider (`lib/app/services/app_check.dart`) |

- **Security rules** are the access boundary. They're written alongside the schema and tested with the Firestore emulator.
- **Functions toolchain** *(Default)*: TypeScript on Node.js 24 (the newest Cloud Functions runtime), ES modules, `firebase-functions` v2 APIs, region `us-central1` (next to Cloud Storage) with a `maxInstances` cap set globally in `functions/src/index.ts`. Each function is a folder under `functions/src/<name>/`, exported from `index.ts` with one line. Tests mirror `src/` under `functions/test/` and use Vitest with a 90% coverage gate; rules tests live in `functions/test/rules/` and use `@firebase/rules-unit-testing`. Lints follow the Dart side's approach (§16): ESLint with `typescript-eslint`'s strict type-checked rules, snake_case file names, sorted imports, and Prettier formatting with single quotes. TypeScript stays on 6.0 until `typescript-eslint` supports 7.
- **Emulators:** tests and local runs use the `demo-sousvite` project id, so they never touch the real `sousvite` project and need no credentials. `npm test` in `functions/` builds, starts the emulators, and runs every test.
- **Subscriptions** *(Default)*: RevenueCat handles App Store, Google Play, and web (Stripe) billing, and a webhook writes the Pro entitlement to Firestore.
- **Cost control:** batched change writes, snapshots so devices don't read full histories, and listeners scoped to the spaces a user belongs to.
- Photos for Drive-sync users are stored in their Drive app folder.

### 9.1 Server data layout

Recipes are never stored as recipe documents on the server. Each space's change log is the source of truth, and devices rebuild recipes from it (§8.1). This keeps writes to one per push and keeps the server out of the merge.

```
users/{uid}                          Profile: privateSpaceId, chosen transport, createdAt.
                                     The owner reads and writes it.
users/{uid}/private/entitlement      { pro: bool, expiresAt } written only by the
                                     subscription webhook (PRO-1). Clients read their own.
spaces/{spaceId}                     { kind: "private" | "shared", ownerUid, memberUids[],
                                       latestSnapshot: { path, hlc, batchId }, createdAt }
spaces/{spaceId}/batches/{batchId}   One push: { deviceId, uid, pushedAt (server time),
                                       hlcMax, changes: [Change...] }. Never updated or
                                     deleted. Pull orders by pushedAt, then batchId.
invites/{inviteId}                   Invite links for a joint share or a copy (§8.4).
                                     Written and read only by the sharing functions.
shareLinks/{linkId}                  View-only link: the recipe as plain text, owner, on/off.
                                     Written by functions only; shareLinkPage renders it.
usdaCache/{key}                      USDA proxy cache (§11.1). Functions only.
```

Cloud Storage holds `spaces/{spaceId}/snapshots/{hlc}.json.gz` (a snapshot can pass Firestore's 1 MiB document limit) and `spaces/{spaceId}/photos/{photoId}`. Both are written once and never changed or deleted by the app: a new photo gets a new id, and old photos stay because recipe history can show them. Photos must be images under 10 MB. The web app downloads both from their download URLs, so the bucket's CORS (`storage.cors.json`, set by the backend deploy) must list the web app's origins; without it every download fails in the browser. Drive users keep photos in their app folder as `photos/{photoId}`. In `packages/sync`, `BlobStore` has a Drive and a Cloud Storage implementation (MEDIA-2) that share one contract suite.

- A user's private space id on the server is `u_{uid}`, so a device can find it without a query. On the device it stays `private` (DATA-2), and the Firestore transport maps between the two, so signing in never rewrites local changes.
- A push with more changes than fit in one document (about 500 or 900 KB) splits into several batches.
- **Rules:** a member of `memberUids` can read the space, create batches with their own `uid` and a server `pushedAt`, and never update or delete a batch. Only the owner of a private space is a member. Shared-space membership changes go through the sharing functions.
- **Delete account** removes `users/{uid}`, the private space with its batches and snapshots, their invites and share links, and the user from every shared space's `memberUids` (PRD 7.9).

### 9.2 Beta: no Pro gate

During the beta, Sousvite cloud sync and sharing work for **everyone**, so real server costs can be measured before the Pro price is set (PRD 7.12). The gate is one switch on each side:

- `firestore.rules` has `function proRequired() { return false; }`, and every Pro check is written as `!proRequired() || hasPro(...)`. Turning the gate on is a rules deploy.
- The app's `entitlements` provider returns `BetaEntitlements`, which reports Pro for everyone. PRO-1 replaces it with the RevenueCat implementation when the gate turns on.

Everything Pro-only is still built and tested with the gate both on and off, so turning it on is a one-line change on each side.

## 10. Accounts and auth

- Signing in is optional. Signed out, the app runs entirely on Drift with a local device id.
- Google sign-in requests the `drive.appdata` scope only when Drive sync is turned on.
- **Signing in later** attaches the existing local data to the account and uploads it through the chosen transport (PRD 7.9).
- **Apple users** can use only Sousvite cloud sync, since Drive needs a Google account.
- **Sign-in callout:** while signed out, the library shows a dismissible card, and Settings shows a row, saying that signing in with Google gives free backup and sync through the user's own Google Drive. Dismissing the card hides it for 30 days.
- **Default transport during the beta:** Sousvite cloud for everyone. A **Sync source** setting in Settings (marked Beta) lets Google users switch to Drive and back (APP-SYN). Switching runs `replay()` into the new transport (§8.2), so nothing is lost. The app picks the transport in one provider, `syncTransportProvider`, so the rest of the app never knows which one is active.

## 11. Nutrition *(Decided)*

### 11.1 Data sources

- **Bundled:** USDA FoodData Central *Foundation Foods* and *SR Legacy* (generic ingredients), with nutrients and household portions. `tools/usda_builder` turns the official CSV releases into a compact SQLite file, about 9 MB on disk and under 2 MB compressed (schema in `tools/usda_builder/README.md`). The file is committed to the repo as a normal file (no Git LFS) and regenerated only with the tool. On web it's downloaded once on first launch and cached.
- **Online, then cached:** USDA *Branded Foods* through our Cloud Function proxy, and Open Food Facts via its public API. Looked-up foods are saved to Drift, so recipes using them keep working offline.
- The USDA proxy is the `usdaProxy` callable function (`functions/src/usda_proxy/`), with App Check enforced. It takes `{action: 'search', query, pageNumber?, pageSize?}` (Branded Foods only; page size 25 by default, at most 50) or `{action: 'food', fdcId}`, and returns FoodData Central's JSON unchanged. The `USDA_API_KEY` secret goes upstream in a header and never reaches the client. Responses are cached in the server-only `usdaCache` Firestore collection (searches 7 days, foods 30 days, case-insensitive searches share an entry), and a TTL policy on `expiresAt` deletes old entries. Errors: `invalid-argument`, `not-found`, `resource-exhausted` (USDA's rate limit), `unavailable`.
- **Licensing:** USDA data is public domain. Open Food Facts data is ODbL (share-alike), so we keep attribution and keep OFF data separate from our own data.

### 11.2 Matching and math

- Matching is deterministic: normalize the ingredient name, apply a synonym table ("scallion" → "green onion"), then rank candidates by token overlap, preferring generic USDA foods. The word lists and weights live in `packages/nutrition/lib/src/matching/match_vocabulary.dart`; a fixture of common ingredients (`packages/nutrition/test/fixtures/matching/`) measures accuracy in CI against the 90% target (PRD §8).
- Every match records its source and can be changed by the user. Unmatched lines are flagged, never guessed silently (PRD 7.4).
- **Automatic matching:** imported recipes (URL and Umami) are matched as they're saved, and "Fix all" (on a recipe's unmatched note) and "Match nutrition for all recipes" (Settings) match the unmatched lines of one recipe or the whole library. Only *clear* matches are saved (`FoodMatched.isClear`: score ≥ `clearScore`, or ≥ `clearNamedScore` when the food's leading name segment is all in the ingredient, both in `match_vocabulary.dart`, tuned on Tyler's Umami recipes) and only when the line's weight can be worked out. Everything else stays unmatched for the user, and lines that already have a match are never changed. The app's `AutoMatch` (`features/nutrition/application/auto_match.dart`) matches against `FoodRepository.genericFoods()`.
- **Unit → grams:** weights convert directly. Volumes use the food's USDA portion data first, and a curated density table second. Counts ("2 eggs") use USDA portions.
- Totals are computed in `packages/nutrition` as pure functions: batch totals, then per serving using each user's serving size.

## 12. Ingredient parsing *(Decided)*

`packages/ingredient_parser` is a small, rule-based parser:

```
"1 ½ cups rolled oats, chopped"
  → quantity: 3/2, unit: cup, name: "rolled oats", preparation: "chopped"
```

- Handles Unicode and ASCII fractions, mixed numbers, ranges ("2–3"), metric and US units with aliases ("tbsp", "T", "Tbsp."), sizes ("1 large egg"), parentheticals ("1 (15 oz) can"), and "to taste" lines with no amount.
- Output keeps the original text, and users can correct any field (PRD 7.3).
- `parseIngredientLine(String)` returns a `ParsedLine`. Besides quantity, range end, unit, name, and preparation it reports a `countWord` ("clove", "can", "bunch") for count units the `Unit` enum doesn't have, kept as text so any word works (Tyler's decision) and stored as `IngredientLine.countWord`, singular and lowercase, plus `size`, a container `package` size, and an `alternate` amount in another unit. A count word with nothing after it is the ingredient ("5 cloves").
- **Corpus testing:** `packages/ingredient_parser/test/fixtures/` holds real lines and hand-written cases with expected results; its README defines the format and how results are compared. CI prints the pass rate and fails below the floor in `corpus_test.dart` (98%, raised as the parser improves). Every parsing bug becomes a new fixture.

## 13. Smart step text and measuring guidance

`packages/measuring` holds two pure modules:

- **Smart step text:** finds mentions of each ingredient in step text (name plus synonyms and head noun, longest match first) and inserts the scaled amount. Replacements are visible and editable (PRD risk table). `smartSteps` matches a line's whole name, the end of its name ("oats" for "rolled oats"), its alternatives ("ghee" for "butter or ghee"), and its name without a trailing count word ("garlic" for "garlic cloves"), singular and plural alike. A short form two lines share is skipped. Each line's amount goes at its first mention in the recipe, replacing a leading "the" or "your", and shows the line's full name: "add the garlic" becomes "add 6 garlic cloves". Mentions that already have an amount, are partial ("half the flour", "the remaining flour"), or name something made from the ingredient ("the flour mixture") stay as written. Each `StepMention` keeps the text it replaced, so the editor can undo it, the scaled amount, which the app rounds like the ingredient list, and the line's count word, which the app shows as the unit ("add 6 cloves garlic") with `pluralOf` from the domain after amounts above one.
- **Measuring decomposition:** turns an amount into the fewest tools the user owns, as a small search over their cups and spoons with a rounding tolerance. For example, ¾ cup → ½ cup + ¼ cup, and 5 tsp → 1 Tbsp + 2 tsp. `decompose` allows the same 5% tolerance as measurable rounding; among plans with the fewest fills it picks the closest, then the one with the fewest different tools, then larger tools. It returns each tool once with a fill count (2 × 1 tsp), largest first. Metric volumes are converted to the US tools; masses and counts get no plan. The tool set is passed in: settings owns the default set.
- **Step timers:** finds the times in a step ("bake 20 to 25 minutes", "1 hour 15 minutes", "half an hour") and returns each one's text, position, and shortest and longest duration, so cooking mode can offer a `TimerChip` and choose which end of a range to count down from. "Overnight" counts as 8 to 12 hours. Intervals ("every 5 minutes"), limits on their own ("up to 3 hours"), days (storage, not cooking), and vague times ("a few minutes") are left out.

## 14. Recipe import *(Decided)*

- **URL import** runs on the device in `packages/recipe_import`. It reads schema.org `Recipe` JSON-LD first, microdata second, and falls back to simple heuristics, then runs each ingredient line through the parser.
- `readRecipePage` returns an unsaved `RecipeSnapshot`. A heading line among the ingredients ("For the sauce:") starts an ingredient section. The parser's count word goes in the line's `countWord`. A line has no field for a size, so the name keeps it as written ("large egg"), and the raw text keeps the rest. Cost notes ("($0.20)") are dropped.
- On iOS and Android the app fetches the page itself, with the same `Sousvite/1.0` User-Agent as the proxy.
- **Share sheet:** both platforms turn a shared link into the deep link `sousvite://open/import?shared=<text>`, which the router opens as the import screen and starts importing. On iOS a share extension (`ios/ShareExtension/`) builds the link and opens the app, so it needs no App Group; on Android `MainActivity` rewrites the `ACTION_SEND` intent before Flutter reads it. Shared text often wraps the link in words, so import takes the first `http` or `https` link in it.
- **Sharing an Umami export:** a zip file shared to Sousvite goes straight to the Umami import, then the copy is deleted. On iOS the app declares zip as a document type (`CFBundleDocumentTypes`, not in place), so it shows in the share sheet's app row; iOS copies the file into `Documents/Inbox` and opens the app at its file URL, and `ImportRoutes.redirect` (the router's top-level redirect) sends any location ending in `.zip` to `/import?archive=<path>`. The share extension stays links only, so no App Group is needed. On Android `MainActivity` copies the `ACTION_SEND` zip into the cache and opens `sousvite://open/import?archive=<path>`.
- On **web**, browsers block cross-site requests, so the page is fetched through a Cloud Function proxy that returns the HTML. Parsing still happens on the client.
- The proxy is the `fetchProxy` callable function (`functions/src/fetch_proxy/`). App Check is enforced. It fetches only public addresses (every redirect hop and every DNS answer is checked, so it can't reach private or metadata addresses), follows at most 5 redirects, allows 10 seconds, and returns only HTML up to 5 MB as `{url, contentType, body}`, where `url` is the final URL after redirects. A failure is an `HttpsError` whose `details.reason` says why (`invalidUrl`, `blockedAddress`, `tooManyRedirects`, `upstreamStatus` with `details.status`, `unsupportedContentType`, `tooLarge`, `timeout`, `network`), so import can report failures by site. It identifies itself with a `Sousvite/1.0` User-Agent that links to the repo.
- Results always open in a review screen before saving, and failures are reported by site so we can see which sites need work (PRD 10).
- **Umami import and export** live in the same package, in `lib/src/umami/`, and use Umami's **HTML export** (a zip with one folder per recipe book and one `.html` page per recipe). Umami's JSON export drops notes and section headings, so import reads only the HTML and reports a JSON export as having no recipes. Checked against Tyler's real export (226 recipes): every recipe, book, note, section, and photo address comes through, and export then import gives back the same recipes.
  - **What transfers:** name, recipe book (as a folder), servings, total time, active time (as prep time), photo address (MEDIA-1 downloads it), ingredients and steps with their sections, and notes. A list item that is all bold or underlined is a section heading, and step numbers typed into the text ("1. ") are dropped.
  - **What doesn't:** Umami's tags, and the original source link, which neither export has. Export has no cook time, since Umami's page has no place for it, and a recipe in several folders is exported once, in its first folder.
  - **Import order and progress:** the app reads the zip in a background isolate, saves every recipe and its book folder, then downloads photos six at a time and saves each one onto its recipe. Recipes show in the library within seconds; the photos (about 200 for Tyler's library, each shrunk on device) take longer. A dialog that can't be dismissed shows the step and an "n of total" bar for the whole import, and asks the user to keep the app open, because iOS pauses the import in the background.
  - Export writes the same HTML layout, with names escaped the way Umami does (`#U` and four hex digits). Whether Umami's own import reads it back is not confirmed yet.

## 15. Testing *(Decided)*

| Level | What | Tools |
|---|---|---|
| Unit | Pure packages: parser corpus, importer fixtures (saved HTML pages), nutrition math, measuring, HLC and merge, use cases with fake repositories | `package:test`, `mocktail` |
| Sync | One shared contract suite run against both transports, plus randomized multi-device merge tests that check every device converges | `package:test`, Firestore emulator |
| Widget | Behavior of each widget **and rebuild counts**, using the `BuildCounter` helper (§5) | `flutter_test` |
| Golden | Design-system widgets and key screens, in light and dark themes | `alchemist` *(Default)* |
| Integration | A few end-to-end flows through the real app: import → edit → cook → grocery list; offline edit → sync on two devices; share jointly → edit → see on the other device. Devices share an in-memory cloud instead of Firebase. Web gates every PR; Android runs on pushes to `main` (`.github/workflows/e2e.yaml`) | `integration_test` |
| Database | Drift migrations against generated schema snapshots | `drift_dev` |
| Backend | Security rules and Cloud Functions | Firebase emulators, Vitest, `@firebase/rules-unit-testing` |

**Mocking** *(Decided)*: `mocktail` for mocks and stubs, since it needs no code generation. Prefer small hand-written fakes for repositories, and use `mocktail` for collaborators where a fake would be heavier than the test.

## 16. Code quality and CI

- **Lints** *(Decided)*: consistency is enforced by lints, not by convention. When a style rule can be checked by a lint, we turn the lint on instead of writing the rule down. The rules live in one root `analysis_options.yaml`: `very_good_analysis` as the base, plus `use_primary_constructors`, `migrate_design_widgets`, `prefer_expression_function_bodies`, `avoid_annotating_with_dynamic`, `use_decorated_box`, `use_if_null_to_convert_nulls_to_bools`, `prefer_void_to_null`, `unnecessary_async`, `unnecessary_await_in_return`, `avoid_futureor_void`, `unsafe_variance`, `no_dynamic_casts`, `annotate_redeclares`, `avoid_null_checks_in_equality_operators`, and `no_runtimetype_tostring`. Each package's `analysis_options.yaml` includes the root file and adds only its own excludes and plugins (`riverpod_lint` in the app). Rules left off conflict with ones `very_good_analysis` enables (`omit_obvious_property_types`, `prefer_double_quotes`, `prefer_relative_imports`, `always_specify_types`, `unnecessary_final`) or flag our design (`avoid_classes_with_only_static_members` for token classes, `one_member_abstracts` for service interfaces). An `// ignore:` always carries a comment saying why.
- **Formatting:** `dart format`, checked in CI.
- **CI** *(Decided)*: GitHub Actions, added in the app scaffold PR, built on Very Good Ventures' reusable [`very_good_workflows`](https://github.com/VeryGoodOpenSource/very_good_workflows). Every package gets a job from their `dart_package` or `flutter_package` workflow (format, analyze, tests, and a coverage gate). Our own steps add code-generation freshness checks and a web build. Mobile builds and Firebase Hosting preview deploys follow once the app runs.
- **Deploys** *(Decided)*: every push to `main` deploys the web app to Firebase Hosting on the single `sousvite` project (`.github/workflows/deploy_web.yaml`, https://sousvite.web.app) with the `FIREBASE_SERVICE_ACCOUNT` secret; without the secret the build runs and the deploy is skipped with a warning. Cloud Functions, Firestore rules and indexes, and Storage rules deploy from `.github/workflows/deploy_functions.yaml` on pushes to `main` that change them (and by hand), with the same secret and the extra roles in BUILD_PLAN §8.1. The Widgetbook deploys to GitHub Pages (`.github/workflows/widgetbook.yaml`, https://tytaniumdev.github.io/Sousvite/) when it or the design system changes. Hosting sets no cross-origin isolation headers, because they would block recipe photos from other sites; Drift picks a storage mode that works without them.
- **Widgetbook** *(Decided)*: `apps/widgetbook` shows every `design_system` component with knobs, in the four themes and at 100% to 200% text. Use cases are written by hand as `WidgetbookComponent` lists, one file per component, because `widgetbook_generator` still needs `build` 4 and `analyzer` below 14 while the workspace is on `build` 5. Its themes come from a `ThemeAddon` that sets `material_ui`'s `Theme`, since Widgetbook's `MaterialThemeAddon` takes Flutter's deprecated `ThemeData`.
- **Coverage gate** *(Default)*: 90% for the pure packages, where most logic lives, and 70% for the app, where goldens and integration tests carry part of the load. These numbers will be tuned in the scaffold PR.
- **Not used:** the Very Good CLI starter template, because it is built around Bloc and we use Riverpod.
- **Merging:** PRs merge automatically once CI is green.

### 16.1 Toolchain and language *(Decided)*

We track the latest stable Flutter and Dart and use nothing that is deprecated. The baseline, checked against the Flutter 3.41–3.50 and Dart 3.10–3.14 release notes:

- **Versions:** Flutter 3.50 with Dart 3.14, pinned in `.fvmrc` and read by CI. Every package's SDK constraint is `^3.14.0`.
- **Material and Cupertino are packages.** `package:flutter/material.dart` and `cupertino.dart` are deprecated (3.47, formally in 3.50). Import `package:material_ui/material_ui.dart` (and `package:cupertino_ui/cupertino_ui.dart` if we ever need Cupertino widgets). New `flutter create` projects do the same.
- **Localization delegates** come from `material_ui`: `[AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates]`. The legacy delegates in `flutter_localizations` are deprecated. `flutter gen-l10n` still imports `flutter_localizations` in its generated file, so the app keeps that dependency for codegen only; never import it in our code.
- **Variable fonts:** since 3.41 `FontWeight` drives a variable font's `wght` axis and takes any value from 1 to 1000. Set weight with `FontWeight` only, never `FontVariation.weight`. Other axes (Newsreader's optical size) still use `FontVariation`.
- **Constructors:** primary constructors (Dart 3.13) everywhere, enforced by `use_primary_constructors`. Each field's doc comment goes on its parameter. The lint also asks for an empty `()` on classes and enums with no constructor (static-only token classes, interfaces, Drift tables, plain enums); we accept that for one consistent rule. Other constructors (factories, private named ones) use the concise syntax (`factory(...)`, `const new _(...)`). `SpringCurve` is the one exception to `const`: it computes its `duration` once in a field initializer, so it is a non-`const` primary constructor with a commented `// ignore:`.
- **Dot shorthands** (Dart 3.10, no lint exists yet): use them for enum values and static members when the type is obvious from the context, as in `themeMode: .system` or `labelType: extended ? .none : .all`. Keep the type name where the context is `dynamic` or `Object`, such as `expect(...)` and annotations.
- **Null-aware elements:** `[?maybeItem]` instead of `if (x != null) x`.
- **Web:** `dart:js_interop` and `package:web` only; `dart:html`, `dart:js`, and `package:js` are deprecated.
- **Android:** project files match the 3.50 `flutter create` template (AGP 9.3, Gradle 9.5, Kotlin 2.4, Java 17).
- **Upgrading:** bump `.fvmrc`, run `flutter pub upgrade --major-versions`, then `dart migrate` (Dart 3.14) and `dart fix --apply` in each package, then read the release notes for breaking changes and update this section.

## 17. Other defaults *(open to review)*

| Area | Choice | Why |
|---|---|---|
| Routing | `go_router` | Official, URL-based (needed for web and share links), deep links |
| Models | `freezed` + `json_serializable` | Value equality (needed for §5), immutable copies, JSON for sync |
| Errors | Typed result values in the domain; exceptions only at layer boundaries | Predictable, testable error handling |
| Localization | ARB files with `flutter gen-l10n` and `material_ui` delegates (§16.1), English only at launch | Avoids retrofitting strings later |
| Crash reporting | Sentry | One tool across iOS, Android, and web |
| Subscriptions | RevenueCat | Handles both stores and web billing |

## 18. Open questions

1. **Umami format:** confirm the export format against real files before building import and export.
2. **Drive sync cadence:** tune the polling interval against Drive API quotas during the beta.
