/**
 * Stub answers for `workspaceRevealPath`, whose result is `WorkspaceRevealResult`: the open
 * roots' status/value/dependency shape with the receipt `{ path }` ("Submitted absolute
 * path") in place of `{ process }`. The dependency reasons transcribed from the failure
 * table: "Path missing or dangling link | Dependency `PATH_NOT_FOUND`; no action" and
 * "Application absent/unregistered, including missing constrained copy or Finder |
 * Dependency `APPLICATION_NOT_INSTALLED`; guidance names the app; no action". A false
 * acknowledgment is "`failed`", an invalid input "Existing input error at original response
 * path, no `kind`; this field does not act".
 *
 * The guidance sentences are placeholders: the documents give no text. Nothing here is
 * invented wire shape; nothing here was observed on a real wire.
 */
import { capabilityError } from './launch-stubs.mjs';

export const ROOT = 'workspaceRevealPath';

const GUIDANCE = {
  PATH_NOT_FOUND: 'Nothing was found at that path; check it, then reveal it again.',
  APPLICATION_NOT_INSTALLED: 'Finder is not available; nothing was revealed.',
};

const available = (path) => ({
  status: 200,
  body: { data: { [ROOT]: { status: 'AVAILABLE', value: { path }, dependency: null } } },
});

const dependency = (reason) => ({
  status: 200,
  body: {
    data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: { reason, guidance: GUIDANCE[reason] } } },
  },
});

/** The path the stub echoes; the test sets it to the path it sent, or to something else to see the echo copied unchanged. */
export const echo = { path: '/tmp/koine test/notes (1).txt' };

export const REVEAL_ANSWERS = {
  'available': () => available(echo.path),
  'dependency-path-not-found': () => dependency('PATH_NOT_FOUND'),
  'dependency-finder-not-installed': () => dependency('APPLICATION_NOT_INSTALLED'),

  'denied-lacks-workspace': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  'denied-lacks-desktop': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'desktop:control', 'authorization')] },
  }),
  'denied-revoked-before-dispatch': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [capabilityError([ROOT], 'workspace:control', 'execution')] },
  }),

  // "Native error/false acknowledgment, timeout, or prerequisite lost after submission | failed".
  'failed-false-acknowledgment': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [{ message: 'Finder did not acknowledge selecting the item.', path: [ROOT], extensions: { kind: 'failed' } }],
    },
  }),
  'failed-inspection-denied': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [{ message: 'metadata could not be read', path: [ROOT], extensions: { kind: 'failed' } }],
    },
  }),
  'failed-deadline': () => ({
    status: 200,
    body: { data: null, errors: [{ message: 'deadline', path: [], extensions: { kind: 'failed' } }] },
  }),

  'input-error': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'path must be absolute', path: [ROOT] }] },
  }),

  // Publication denial (phase execution) at each field; the published status stays authoritative.
  'suppressed-value': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'AVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'value'], 'workspace:control', 'execution')],
    },
  }),
  // `path` is non-null: its denial removes the receipt, not the result.
  'suppressed-path': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'AVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'value', 'path'], 'desktop:control', 'execution')],
    },
  }),
  'suppressed-dependency': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'dependency'], 'workspace:control', 'execution')],
    },
  }),
  'suppressed-status': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [capabilityError([ROOT, 'status'], 'workspace:control', 'execution')],
    },
  }),

  // Answers the contract says cannot happen: each is a violation, never success or absence.
  'null-root-no-error': () => ({ status: 200, body: { data: { [ROOT]: null } } }),
  'both-branches': () => ({
    status: 200,
    body: {
      data: {
        [ROOT]: {
          status: 'AVAILABLE', value: { path: '/x' }, dependency: { reason: 'PATH_NOT_FOUND', guidance: 'g' },
        },
      },
    },
  }),
  'available-without-value': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'AVAILABLE', value: null, dependency: null } } },
  }),
  'receipt-without-path': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'AVAILABLE', value: {}, dependency: null } } },
  }),
  'unknown-status': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'SELECTED', value: { path: '/x' }, dependency: null } } },
  }),
  'dependency-with-value': () => ({
    status: 200,
    body: {
      data: {
        [ROOT]: {
          status: 'DEPENDENCY_UNAVAILABLE', value: { path: '/x' }, dependency: { reason: 'PATH_NOT_FOUND', guidance: 'g' },
        },
      },
    },
  }),
  'not-a-response': () => ({ status: 200, body: { hello: 'world' } }),
};
