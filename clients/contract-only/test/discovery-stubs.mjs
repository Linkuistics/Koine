/**
 * Stub answers for the two read roots of Koine 0.4.0, `workspaceSpecialLocations` and
 * `workspaceApplications`, asked under the aliases `locations` and `apps` that the published
 * `NativeStartingLocations` and `NativeApplications` operations give them. Their results are
 * `WorkspaceSpecialLocationsResult` and `WorkspaceApplicationsResult` in
 * `docs/design/workspace-discovery-schema.graphql`: a `status`, `items` (a list or null), `sources`
 * (the coverage of each source) and `resultsTruncated`.
 *
 * Every shape is transcribed from that SDL and from the search spec's result table: an empty
 * finished gathering is `UNKNOWN` with null items, a failed one is `FAILED` with an error at `items`,
 * and a positive index answer keeps category completeness `UNKNOWN`. Nothing here was observed on a
 * real wire.
 */

const coverage = (source, observations, category, examined) => ({
  source,
  declaredDomain: source === 'INDEXED_APPS' ? 'indexed local applications' : 'default special locations',
  availability: observations === 'UNKNOWN' && examined === 0 ? 'UNKNOWN' : 'AVAILABLE',
  observations,
  category,
  examined,
  diagnostics: [],
});

const LOCATION_PAIRS = [
  ['HOME', 'USER'], ['DESKTOP', 'USER'], ['DOCUMENTS', 'USER'], ['DOWNLOADS', 'USER'], ['MOVIES', 'USER'],
  ['MUSIC', 'USER'], ['PICTURES', 'USER'], ['APPLICATIONS', 'USER'], ['APPLICATIONS', 'LOCAL'], ['APPLICATIONS', 'SYSTEM'],
];

export const locationItems = () =>
  LOCATION_PAIRS.map(([kind, domain]) => ({
    kind,
    domain,
    accountIdentifier: '501',
    location: `/Users/admin/${kind.toLowerCase()}-${domain.toLowerCase()}`,
    contentsAvailability: 'UNKNOWN',
    sources: ['FOUNDATION_LOCATIONS'],
  }));

export const applicationItems = () => [
  { name: 'Safari', applicationPath: '/Applications/Safari.app', bundleIdentifier: 'com.apple.Safari', sources: ['INDEXED_APPS'] },
  { name: 'Notes', applicationPath: '/System/Applications/Notes.app', bundleIdentifier: 'com.apple.Notes', sources: ['INDEXED_APPS'] },
  { name: 'Zed', applicationPath: '/Applications/Zed.app', bundleIdentifier: 'dev.zed.Zed', sources: ['INDEXED_APPS'] },
];

const ok = (alias, result) => ({ status: 200, body: { data: { [alias]: result } } });
const denial = (alias, phase) => ({
  status: phase === 'authorization' ? 403 : 200,
  body: {
    ...(phase === 'authorization' ? {} : { data: { [alias]: null } }),
    errors: [
      {
        message: 'workspace:read is required',
        path: [alias],
        extensions: {
          kind: 'permission', permissionClass: 'capability', phase,
          requiredCapability: 'workspace:read', requiredCapabilities: ['workspace:read'],
        },
      },
    ],
  },
});

export const DISCOVERY_ANSWERS = {
  'locations-available': () =>
    ok('locations', {
      status: 'AVAILABLE', items: locationItems(), resultsTruncated: false,
      sources: [coverage('FOUNDATION_LOCATIONS', 'COMPLETE', 'COMPLETE', 10)],
    }),
  // The index answered with applications: positive results keep category completeness UNKNOWN.
  'apps-partial': () =>
    ok('apps', {
      status: 'PARTIAL', items: applicationItems(), resultsTruncated: false,
      sources: [coverage('INDEXED_APPS', 'PARTIAL', 'UNKNOWN', 3)],
    }),
  // A finished gathering with nothing in it is not "no applications": UNKNOWN, null items.
  'apps-unknown': () =>
    ok('apps', {
      status: 'UNKNOWN', items: null, resultsTruncated: false,
      sources: [coverage('INDEXED_APPS', 'UNKNOWN', 'UNKNOWN', 0)],
    }),
  // An unfinished gathering (the time limit) is FAILED, and `items` raises the failure.
  'apps-failed': () => ({
    status: 200,
    body: {
      data: {
        apps: {
          status: 'FAILED', items: null, resultsTruncated: false,
          sources: [{ ...coverage('INDEXED_APPS', 'UNKNOWN', 'UNKNOWN', 0), diagnostics: [{ source: 'INDEXED_APPS', reason: 'TIME_LIMIT', subject: null, affectsCoverage: true, guidance: 'The index did not finish in time.', permission: null }] }],
        },
      },
      errors: [{ message: 'The index did not finish in time.', path: ['apps', 'items'], extensions: { kind: 'failed' } }],
    },
  }),
  'apps-denied-preflight': () => denial('apps', 'authorization'),
  'locations-denied-preflight': () => denial('locations', 'authorization'),
  'apps-denied-revoked': () => denial('apps', 'execution'),

  // Answers that break a rule the contract states.
  'null-root': () => ok('apps', null),
  'no-root': () => ({ status: 200, body: { data: {} } }),
  'unknown-status': () =>
    ok('apps', { status: 'COMPLETE', items: [], resultsTruncated: false, sources: [] }),
  'available-without-items': () =>
    ok('apps', { status: 'AVAILABLE', items: null, resultsTruncated: false, sources: [coverage('INDEXED_APPS', 'COMPLETE', 'COMPLETE', 0)] }),
  'sources-not-a-list': () =>
    ok('apps', { status: 'PARTIAL', items: applicationItems(), resultsTruncated: false, sources: null }),
};
