/**
 * Stub answers for `workspaceOpenPath`. The root returns the same
 * `WorkspaceOpenResult` as the launch and URL roots, so every shape is theirs, with
 * the path root's own differences transcribed from the same documents:
 *
 * - the dependency reasons: "Path missing or dangling link | Dependency
 *   `PATH_NOT_FOUND`; no action", "Existing path ... has no default opener | Dependency
 *   `NO_DEFAULT_HANDLER`; no chooser/action", and, for a named application, the
 *   launch's two ("Application absent/unregistered, including missing constrained
 *   copy | `APPLICATION_NOT_INSTALLED`", "Constrained bundle has another identifier |
 *   `APPLICATION_IDENTITY_MISMATCH`");
 * - an invalid input or a refused payload is an "Existing input error at original
 *   response path, no `kind`; this field does not act. The path is the root field's own,
 *   its alias if one was used", an execution error in an HTTP 200 answer. The client
 *   guide ("Opening a document or folder" item 1) says the same. One extra stub puts
 *   the same error one level down, at an argument, which no document says is served;
 *   it is there because the shared reading tolerates it (see the findings).
 *
 * The guidance sentences are placeholders: the documents say only that guidance exists
 * ("guidance names the app" for a missing application) and give no text. Nothing here
 * is invented wire shape; nothing here was observed on a real wire.
 */
import { PROCESS, capabilityError } from './launch-stubs.mjs';

export const ROOT = 'workspaceOpenPath';

const GUIDANCE = {
  PATH_NOT_FOUND: 'Nothing was found at that path; check it, then open it again.',
  NO_DEFAULT_HANDLER: 'No application is registered to open that item; name one, then open it again.',
  APPLICATION_NOT_INSTALLED: 'Zed is not installed; install it, then open the item again.',
  APPLICATION_IDENTITY_MISMATCH: 'The application at that path has a different identifier; check both, then open the item again.',
};

const available = (process) => ({
  status: 200,
  body: { data: { [ROOT]: { status: 'AVAILABLE', value: { process }, dependency: null } } },
});

const dependency = (reason) => ({
  status: 200,
  body: {
    data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: { reason, guidance: GUIDANCE[reason] } } },
  },
});

export const OPEN_PATH_ANSWERS = {
  // "file/folder submitted to its default or named app": a receipt with the handler's identity.
  'available-process': () => available(PROCESS),
  // "Exit, ambiguity or unreadable start time produces `process: null`".
  'available-null-process': () => available(null),

  // The four reasons, each as the outcome table words it.
  'dependency-path-not-found': () => dependency('PATH_NOT_FOUND'),
  'dependency-no-default-handler': () => dependency('NO_DEFAULT_HANDLER'),
  'dependency-not-installed': () => dependency('APPLICATION_NOT_INSTALLED'),
  'dependency-identity-mismatch': () => dependency('APPLICATION_IDENTITY_MISMATCH'),

  // "Missing client authority": whole-mutation preflight, HTTP 403, errors and no data, the denied action's
  // response path, phase authorization; the complete set in the spec's order, never sorted.
  'denied-lacks-workspace': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  'denied-lacks-desktop': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'desktop:control', 'authorization')] },
  }),
  'denied-lacks-both': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  'denied-revoked-before-dispatch': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [capabilityError([ROOT], 'workspace:control', 'execution')],
    },
  }),

  // "Native error/false acknowledgment, timeout ... after submission: failed; effects may have begun; no replay."
  'failed-at-action': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [{ message: 'native open failed', path: [ROOT], extensions: { kind: 'failed' } }],
    },
  }),
  // "Filesystem access denied without established consent cause | failed; do not infer absence".
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

  // "Invalid input or refused payload metadata | Existing input error at original response path, no `kind`".
  'input-error': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'path must be absolute', path: [ROOT] }] },
  }),
  // The same error one level down. Not described by any document; the shared reading tolerates it.
  'input-error-argument-path': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'path must be absolute', path: [ROOT, 'path'] }] },
  }),
  'input-error-application-path': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'bundleIdentifier is blank', path: [ROOT, 'application', 'bundleIdentifier'] }] },
  }),

  // Publication denial (phase execution) at each field; the published status stays authoritative.
  'suppressed-value': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'AVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'value'], 'workspace:control', 'execution')],
    },
  }),
  'suppressed-process': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'AVAILABLE', value: { process: null }, dependency: null } },
      errors: [capabilityError([ROOT, 'value', 'process'], 'desktop:control', 'execution')],
    },
  }),
  'suppressed-dependency': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'dependency'], 'workspace:control', 'execution')],
    },
  }),
  // A denied non-null `guidance` discards its nearest nullable parent, the dependency object, so the reason
  // (it could have been PATH_NOT_FOUND) goes with it: the status alone says nothing was submitted.
  'suppressed-dependency-guidance': () => ({
    status: 200,
    body: {
      data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } },
      errors: [capabilityError([ROOT, 'dependency', 'guidance'], 'desktop:control', 'execution')],
    },
  }),
  'suppressed-status': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [capabilityError([ROOT, 'status'], 'desktop:control', 'execution')],
    },
  }),

  // What the contract says cannot happen.
  'violation-null-root': () => ({ status: 200, body: { data: { [ROOT]: null } } }),
  'violation-both-branches': () => ({
    status: 200,
    body: {
      data: {
        [ROOT]: {
          status: 'AVAILABLE',
          value: { process: null },
          dependency: { reason: 'PATH_NOT_FOUND', guidance: 'x' },
        },
      },
    },
  }),
  'violation-not-a-response': () => ({ status: 200, body: 'not a graphql response' }),
  'violation-dependency-missing': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } } },
  }),
  'violation-unnamed-status': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'PATH_NOT_FOUND', value: null, dependency: null } } },
  }),
  // Another root's answer arriving for this one: the field asked for is absent.
  'violation-wrong-root': () => ({
    status: 200,
    body: { data: { workspaceOpenURL: { status: 'AVAILABLE', value: { process: null }, dependency: null } } },
  }),
};
