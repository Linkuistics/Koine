/**
 * Stub answers for `workspaceLaunchApplication`, each transcribed from the
 * workspace spec's own tables ("Results and failure boundary", its outcome table,
 * and the Machine contract's "Errors and partial data", "Additional capability
 * requirements" and transport section). Nothing here is invented wire shape.
 */
const ROOT = 'workspaceLaunchApplication';
const STARTED_AT = '2026-09-30T05:06:07.123456Z';

const GUIDANCE = 'Notes is not installed; install it, then launch again.';

/** `kind: permission`, `permissionClass: capability`: the field's own capability first, then the additional one. */
const capabilityError = (path, requiredCapability, phase, requiredCapabilities = ['workspace:control', 'desktop:control']) => ({
  message: 'refused',
  path,
  extensions: { kind: 'permission', permissionClass: 'capability', requiredCapability, requiredCapabilities, phase },
});

const available = (process) => ({
  status: 200,
  body: { data: { [ROOT]: { status: 'AVAILABLE', value: { process }, dependency: null } } },
});

const dependency = (reason) => ({
  status: 200,
  body: {
    data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: { reason, guidance: GUIDANCE } } },
  },
});

export const PROCESS = { pid: 4242, startedAt: STARTED_AT };

export const LAUNCH_ANSWERS = {
  // "Available means native acknowledgment": a receipt with the observed identity.
  'available-process': () => available(PROCESS),
  // "Exit, ambiguity or unreadable start time produces `process: null`".
  'available-null-process': () => available(null),
  'available-slow': () => ({ ...available(PROCESS), delayMs: 40 }),

  // "Application absent/unregistered ... Dependency APPLICATION_NOT_INSTALLED; guidance names the app; no action."
  'dependency-not-installed': () => dependency('APPLICATION_NOT_INSTALLED'),
  // "Constrained bundle has another identifier: Dependency APPLICATION_IDENTITY_MISMATCH".
  'dependency-identity-mismatch': () => dependency('APPLICATION_IDENTITY_MISMATCH'),

  // "Missing/revoked client authority: permission / capability, before resource inspection": whole-mutation
  // preflight, HTTP 403, errors and no data, the denied action's response path, phase authorization.
  // A grant with desktop:control only: the first unmet member is the field's own capability.
  'denied-lacks-workspace': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  // A grant with workspace:control only: the first unmet member is the additional one; the set is unchanged.
  'denied-lacks-desktop': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'desktop:control', 'authorization')] },
  }),
  // A grant with neither: still the first unmet member, still the whole ordered set.
  'denied-lacks-both': () => ({
    status: 403,
    body: { errors: [capabilityError([ROOT], 'workspace:control', 'authorization')] },
  }),
  // "a mutation action whose grant was revoked after preflight": phase execution, HTTP 200, the action's path.
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
      errors: [{ message: 'native launch failed', path: [ROOT], extensions: { kind: 'failed' } }],
    },
  }),
  // "A `failed` error with an empty `path` and `data` null means the operation passed its deadline".
  'failed-deadline': () => ({
    status: 200,
    body: { data: null, errors: [{ message: 'deadline', path: [], extensions: { kind: 'failed' } }] },
  }),

  // "Invalid input ...: Existing input error at original response path, no `kind`; this field does not act."
  'input-error': () => ({
    status: 200,
    body: { data: { [ROOT]: null }, errors: [{ message: 'applicationPath must be absolute', path: [ROOT] }] },
  }),

  // "A published status remains authoritative if an error suppresses its branch; a null branch with an error is
  // not a different operation outcome." Publication denial (phase execution) at each field.
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
  // "Non-null propagation can also remove status or the entire result": the non-null status is denied, so
  // its nearest nullable parent, the result, is null.
  'suppressed-status': () => ({
    status: 200,
    body: {
      data: { [ROOT]: null },
      errors: [capabilityError([ROOT, 'status'], 'desktop:control', 'execution')],
    },
  }),

  // What the contract says cannot happen; a client must not read these as success or as absence.
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
  // A 200 whose body is not a GraphQL response object at all.
  'violation-not-a-response': () => ({ status: 200, body: 'not a graphql response' }),
  'violation-dependency-missing': () => ({
    status: 200,
    body: { data: { [ROOT]: { status: 'DEPENDENCY_UNAVAILABLE', value: null, dependency: null } } },
  }),
};
