import { readFileSync } from 'node:fs';

import {
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from '@firebase/rules-unit-testing';

/** The emulator-only project id. Never a real project (BUILD_PLAN.md BE-0). */
export const demoProjectId = 'demo-sousvite';

const readRules = (fileName: string): string =>
  readFileSync(new URL(`../../../${fileName}`, import.meta.url), 'utf8');

/** The beta's Pro gate in both rules files (ENGINEERING.md §9.2). */
const gateOff = /function proRequired\(\) \{\s*return false;\s*\}/;

/**
 * Turns the Pro gate on in [rules], so tests can check the rules as they will
 * be at launch.
 */
const withProRequired = (rules: string): string => {
  if (!gateOff.test(rules)) {
    throw new Error('The rules no longer have the proRequired() switch');
  }
  return rules.replace(gateOff, 'function proRequired() { return true; }');
};

/**
 * Starts a rules test environment against the running emulators, loaded with
 * the repository's firestore.rules and storage.rules. Emulator hosts come from
 * the environment that `firebase emulators:exec` sets. With `proRequired`,
 * the Pro gate is turned on, as it will be at launch.
 */
export const rulesTestEnvironment = (
  options: { proRequired?: boolean } = {},
): Promise<RulesTestEnvironment> => {
  const rules = (fileName: string): string =>
    options.proRequired === true
      ? withProRequired(readRules(fileName))
      : readRules(fileName);
  return initializeTestEnvironment({
    projectId: demoProjectId,
    firestore: { rules: rules('firestore.rules') },
    storage: { rules: rules('storage.rules') },
  });
};
