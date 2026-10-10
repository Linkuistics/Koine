// Pure selected-wire design instrument. No provider/target/source/native calls.
import { strict as assert } from 'node:assert';
import { createHash } from 'node:crypto';
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
export const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
export const REPORT = 'docs/design/application-metadata-wire.json';
export const INPUTS = [
  'docs/design/application-metadata-subject.json',
  'docs/design/application-metadata-episode-certificate.json',
  'docs/design/application-metadata-owned-storage.json',
  'docs/design/desktop-workspace-native-schema-extension-host.graphql',
  'docs/design/workspace-search-schema.graphql',
  'docs/design/application-metadata-wire.graphql',
  'docs/verification/application-metadata-wire.md',
  'docs/specs/application-metadata-source-root.md',
  'docs/specs/workspace-search.md',
  'docs/design/architecture/native-metadata-wire.d2',
  'docs/design/architecture/diagrams.json',
  'scripts/application_metadata_wire.mjs',
  'scripts/test_application_metadata_wire.mjs',
  'scripts/check_application_metadata_wire_mutations.mjs',
  'Sources/KoineCore/Engine.swift',
  '.build/checkouts/GraphQL/Sources/GraphQL/Map/GraphQLJSONEncoder.swift',
  '.build/checkouts/GraphQL/Sources/GraphQL/GraphQLResult.swift',
  '.build/checkouts/GraphQL/Sources/GraphQL/Error/GraphQLError.swift',
  'Package.resolved', 'clients/contract-only/package.json',
  'clients/contract-only/package-lock.json',
  'clients/contract-only/node_modules/graphql/package.json',
  'Taskfile.yml',
];
// Freeze source/selection/dependencies before importing/reading the instrument's
// subjects. Cached schema state is valid only while these same digests remain.
const loadingHashes = digestInputs();
const {
  buildSchema, executeSync, getNamedType, getOperationAST, getVariableValues,
  GraphQLError, isListType, isNonNullType, isObjectType, Kind, parse, validate,
  valueFromASTUntyped,
} = await import('../clients/contract-only/node_modules/graphql/index.mjs');
const read = path => readFileSync(resolve(ROOT, path), 'utf8');
const schema = buildSchema(read('docs/design/desktop-workspace-native-schema-extension-host.graphql'));
const document = parse(read('docs/design/application-metadata-wire.graphql'));
assert.deepEqual(validate(schema, document), [], 'selection must validate against complete SDL');
const fragments = new Map(document.definitions.filter(d => d.kind === Kind.FRAGMENT_DEFINITION)
  .map(d => [d.name.value, d]));
const APP_SOURCES = ['INDEXED_APPS', 'RUNNING_APPS', 'REGISTRATION'];
export const unknown = Object.freeze({ unknown: true });
class TokenUpper {
  constructor(bytes) { this.bytes = bytes; }
}

export function upperString(utf8Bytes) {
  assert.ok(Number.isSafeInteger(utf8Bytes) && utf8Bytes >= 0, 'invalid UTF-8 bound');
  return new TokenUpper(2 + 6 * utf8Bytes);
}

// Matches the read default compact GraphQLJSONEncoder policy, including \/.
// Counts independently; no encoder is invoked by this calculation.
export function stringBytes(value) {
  let bytes = 2;
  for (const char of value) {
    const code = char.codePointAt(0);
    assert.ok(code < 0xd800 || code > 0xdfff, 'lossless scalar required');
    if (code < 32) bytes += [8, 9, 10, 12, 13].includes(code) ? 2 : 6;
    else if (char === '"' || char === '\\' || char === '/') bytes += 2;
    else bytes += Buffer.byteLength(char);
  }
  return bytes;
}

function sumKnown(values) {
  if (values.some(v => v === null)) return null;
  return values.reduce((a, b) => a + b, 0);
}

export function countBytes(value) {
  if (value === unknown) return null;
  if (value instanceof TokenUpper) return value.bytes;
  if (value === null) return 4;
  if (typeof value === 'string') return stringBytes(value);
  if (typeof value === 'boolean') return value ? 4 : 5;
  if (typeof value === 'number') {
    assert.ok(Number.isInteger(value) && value >= -2147483648 && value <= 2147483647,
      'only GraphQL Ints in this model');
    return String(value).length;
  }
  if (Array.isArray(value)) {
    return sumKnown([2, Math.max(0, value.length - 1), ...value.map(countBytes)]);
  }
  assert.ok(value && typeof value === 'object', 'unsupported/absent JSON value');
  const fields = Object.entries(value);
  return sumKnown([2, Math.max(0, fields.length - 1),
    ...fields.map(([key, child]) => sumKnown([stringBytes(key), 1, countBytes(child)]))]);
}

// Independent encoder oracle: native JSON.stringify plus default slash escaping.
export function encodeReference(value) {
  return JSON.stringify(value).replaceAll('/', '\\/');
}

function operationContext(name, supplied) {
  const operation = getOperationAST(document, name);
  assert.ok(operation, 'named operation missing');
  const variables = getVariableValues(schema, operation.variableDefinitions ?? [], supplied);
  assert.equal(variables.errors, undefined, 'invalid variable values');
  return { operation, variables: variables.coerced };
}

function included(node, variables) {
  for (const directive of node.directives ?? []) {
    const condition = valueFromASTUntyped(directive.arguments[0].value, variables);
    if (directive.name.value === 'skip' && condition === true) return false;
    if (directive.name.value === 'include' && condition === false) return false;
  }
  return true;
}

// Group by response key, recursively union child selections. Fragment names are
// visited once per object collection; equal field occurrences retain node lists.
function collect(typeName, sets, variables) {
  const grouped = new Map();
  const visited = new Set();
  function walk(set) {
    for (const node of set.selections) {
      if (!included(node, variables)) continue;
      if (node.kind === Kind.FIELD) {
        const key = node.alias?.value ?? node.name.value;
        if (!grouped.has(key)) grouped.set(key, []);
        grouped.get(key).push(node);
      } else {
        let fragment = node;
        if (node.kind === Kind.FRAGMENT_SPREAD) {
          if (visited.has(node.name.value)) continue;
          visited.add(node.name.value);
          fragment = fragments.get(node.name.value);
        }
        if (!fragment.typeCondition || fragment.typeCondition.name.value === typeName) {
          walk(fragment.selectionSet);
        }
      }
    }
  }
  for (const set of sets) walk(set);
  return grouped;
}

function unwrap(type) { return isNonNullType(type) ? type.ofType : type; }

function project(type, value, sets, variables) {
  if (value === null || value === unknown) return value;
  type = unwrap(type);
  if (isListType(type)) return value.map(child => project(type.ofType, child, sets, variables));
  if (!isObjectType(type)) return value;
  const output = {};
  for (const [key, nodes] of collect(type.name, sets, variables)) {
    const field = nodes[0].name.value;
    if (field === '__typename') { output[key] = type.name; continue; }
    assert.ok(Object.hasOwn(value, field), `missing supplied ${type.name}.${field}`);
    const children = nodes.map(n => n.selectionSet).filter(Boolean);
    output[key] = project(type.getFields()[field].type, value[field], children, variables);
  }
  return output;
}

export function projectResponse(name, snapshot, supplied = {}, perRoot = {}) {
  const { operation, variables } = operationContext(name, supplied);
  const data = {};
  for (const [key, nodes] of collect('Query', [operation.selectionSet], variables)) {
    data[key] = project(schema.getType('WorkspaceApplicationsResult'),
      Object.hasOwn(perRoot, key) ? perRoot[key] : snapshot,
      nodes.map(node => node.selectionSet), variables);
  }
  return { data };
}

export function fieldsComplete(name) {
  const { operation, variables } = operationContext(name, {});
  function check(type, sets, root = false) {
    type = getNamedType(type);
    if (!isObjectType(type)) return;
    const grouped = collect(type.name, sets, variables);
    const fields = new Set([...grouped.values()].map(nodes => nodes[0].name.value));
    if (!root) for (const field of Object.keys(type.getFields())) {
      assert.ok(fields.has(field), `unselected ${type.name}.${field}`);
    }
    for (const nodes of grouped.values()) {
      const field = nodes[0].name.value;
      if (field !== '__typename') check(type.getFields()[field].type,
        nodes.map(n => n.selectionSet).filter(Boolean));
    }
  }
  check(schema.getQueryType(), [operation.selectionSet], true);
}

function longestEnum(typeName) {
  return schema.getType(typeName).getValues().map(v => v.name)
    .reduce((a, b) => stringBytes(a) >= stringBytes(b) ? a : b);
}

function saturationGuidance() {
  const reasons = schema.getType('WorkspaceDiscoveryReason').getValues().map(v => v.name);
  return 'Additional details omitted. ' + APP_SOURCES.map(source =>
    source + ':' + reasons.join(',')).join(';');
}

export function fixture(status = 'AVAILABLE', saturated = false) {
  const diagnostic = {
    source: 'INDEXED_APPS', reason: 'PROMPT_RISK', subject: '/declared/fixture',
    affectsCoverage: true, guidance: 'Declared fixture / "é😀\u0001',
    permission: { permission: 'PROMPT_RISK', target: '/declared/fixture',
      event: null, consent: 'UNKNOWN' },
  };
  const diagnostics = saturated ? Array.from({ length: 63 }, () => ({ ...diagnostic })) :
    [diagnostic];
  if (saturated) diagnostics.push({ ...diagnostic, reason: 'DIAGNOSTIC_LIMIT',
    subject: null, permission: null, guidance: saturationGuidance() });
  return {
    status,
    items: ['AVAILABLE', 'PARTIAL'].includes(status) ? [{
      applicationPath: '/declared/A.app', name: 'A/"é😀', bundleIdentifier: 'test.fixture',
      metadataSource: 'BUNDLE_RESOURCE', installationState: 'UNKNOWN',
      uiElement: null, backgroundOnly: false,
      runningActivationPolicies: ['REGULAR', 'UNKNOWN'], sources: APP_SOURCES,
    }] : null,
    sources: APP_SOURCES.map((source, index) => ({
      source, declaredDomain: `Declared ${source} fixture`, availability: 'AVAILABLE',
      observations: 'UNKNOWN', category: 'UNKNOWN', examined: index,
      diagnostics: index === 0 ? diagnostics : [],
    })),
    resultsTruncated: false,
  };
}

export function executeFixture(name, snapshot, variables = {}, mode = 'ordinary', perRoot = {}) {
  let roots = 0;
  let items = 0;
  const result = executeSync({ schema, document, operationName: name,
    variableValues: variables,
    rootValue: {},
    fieldResolver(source, args, context, info) {
      if (info.parentType.name === 'Query') {
        roots++;
        return Object.hasOwn(perRoot, info.path.key) ? perRoot[info.path.key] : snapshot;
      }
      if (info.parentType.name === 'WorkspaceApplicationsResult' && info.fieldName === 'items') {
        items++;
        if (source.status === 'FAILED') throw new GraphQLError('Application discovery failed.',
          { extensions: { kind: 'failed' } });
      }
      if (mode === 'permission' && info.fieldName === 'applicationPath') {
        throw new GraphQLError('Capability denied.', { extensions: {
          kind: 'permission', permissionClass: 'capability', phase: 'dispatch',
          requiredCapability: 'workspace:read',
        } });
      }
      return source[info.fieldName];
    },
  });
  // Explicit serialized GraphQLResult shape; no errors: [] field is invented.
  const body = {};
  if (Object.hasOwn(result, 'data')) body.data = result.data;
  if (result.errors?.length) body.errors = result.errors.map(e => e.toJSON());
  return { body, roots, items };
}

export function finalGuard(body) {
  const originalBytes = Buffer.byteLength(encodeReference(body));
  const replaced = originalBytes > 8388608;
  const response = replaced ? { data: null, errors: [{
    message: 'The response exceeds 8388608 bytes. '
      + 'Select fewer fields; any requested action has already run.',
    path: [],
    extensions: { kind: 'failed' },
  }] } : body;
  return { replaced, body: response, originalBytes,
    responseBytes: Buffer.byteLength(encodeReference(response)) };
}

function itemEnvelope(pathBytes) {
  return {
    applicationPath: upperString(pathBytes), name: upperString(1024),
    bundleIdentifier: upperString(512), metadataSource: longestEnum('WorkspaceApplicationMetadataSource'),
    installationState: longestEnum('WorkspaceApplicationInstallationState'),
    uiElement: false, backgroundOnly: false,
    runningActivationPolicies: schema.getType('WorkspaceApplicationActivationPolicy')
      .getValues().map(v => v.name),
    sources: APP_SOURCES,
  };
}

// Conditional shape dimensions, never new product quotas or native observations.
function conditionalCoverage() {
  const d = {
    source: longestEnum('WorkspaceDiscoverySource'), reason: longestEnum('WorkspaceDiscoveryReason'),
    subject: upperString(8192), affectsCoverage: false, guidance: upperString(1024),
    permission: { permission: longestEnum('WorkspaceDiscoveryPermission'), target: upperString(8192),
      event: longestEnum('WorkspaceSettingsEvent'), consent: 'UNKNOWN' },
  };
  return APP_SOURCES.map((source, i) => ({ source, declaredDomain: upperString(1024),
    availability: longestEnum('WorkspaceDiscoveryAvailability'),
    observations: longestEnum('WorkspaceDiscoveryCompleteness'),
    category: longestEnum('WorkspaceDiscoveryCompleteness'), examined: 2147483647,
    diagnostics: i === 0 ? Array.from({ length: 64 }, () => d) : [],
  }));
}

function snapshotEnvelope(items) {
  return { status: longestEnum('WorkspaceDiscoveryStatus'), items,
    sources: conditionalCoverage(), resultsTruncated: false };
}

export function buildReport() {
  assert.deepEqual(digestInputs(), loadingHashes, 'subject changed after instrument load');
  const subject = JSON.parse(read('docs/design/application-metadata-subject.json'));
  const episodes = JSON.parse(read('docs/design/application-metadata-episode-certificate.json'));
  const storage = JSON.parse(read('docs/design/application-metadata-owned-storage.json'));
  assert.deepEqual(subject.episodeSpellings, episodes.episodeSpellings);
  assert.deepEqual(subject.episodeSpellings, storage.episodeSpellings);
  assert.equal(episodes.commonRows.length, 2043);
  assert.equal(subject.queryPathsOutsideDirectorySubject.length, 149);
  fieldsComplete('CompleteApplicationWire');
  fieldsComplete('SingleApplicationWire');
  const pathIndex = episodes.commonColumns.indexOf('resolvedRootBytes');
  const nameIndex = episodes.commonColumns.indexOf('maximumObservedNameBytes');
  assert.ok(pathIndex >= 0 && nameIndex >= 0);
  const choice = schema.getType('WorkspaceApplicationChoice');
  const fragment = fragments.get('ApplicationChoiceWire').selectionSet;
  const rows = episodes.commonRows.map((row, index) => {
    const bytes = row[pathIndex];
    assert.ok(Number.isInteger(bytes) && bytes > 0 && bytes <= 8192);
    const selected = project(choice, itemEnvelope(bytes), [fragment], {});
    const upper = countBytes(selected);
    return [bytes, stringBytes(subject.episodeSpellings[index]),
      countBytes(upperString(bytes)), upper, 4 * upper, null];
  });
  // Source order associations are validated, and every row survives both runs.
  const runs = {};
  for (const name of ['en-AU,en', 'de']) {
    assert.equal(episodes.runs[name].rows.length, rows.length);
    assert.equal(storage.runs[name].rows.length, rows.length);
    const items = episodes.commonRows.map(row => itemEnvelope(row[pathIndex]));
    runs[name] = {
      rows: rows.map(row => [...row]),
      conditionalSingleBytes: countBytes(projectResponse('SingleApplicationWire', snapshotEnvelope(items))),
      conditionalFullBytes: countBytes(projectResponse('CompleteApplicationWire', snapshotEnvelope(items))),
      actualResponseBytes: null,
    };
  }
  const examples = {};
  for (const status of ['AVAILABLE', 'PARTIAL', 'FAILED', 'BLOCKED', 'UNAVAILABLE', 'UNKNOWN']) {
    const result = executeFixture('CompleteApplicationWire', fixture(status, status === 'PARTIAL'));
    const bytes = countBytes(result.body);
    assert.equal(bytes, Buffer.byteLength(encodeReference(result.body)));
    examples[status] = { bytes, rootObservations: result.roots, itemsSelections: result.items,
      errorPaths: result.body.errors?.map(e => e.path) ?? [],
      errorLocationCounts: result.body.errors?.map(e => e.locations?.length ?? 0) ?? [] };
  }
  const permission = executeFixture('SingleApplicationWire', fixture(), {}, 'permission');
  examples.permission = { bytes: countBytes(permission.body),
    body: permission.body };
  const indexed = fixture();
  Object.assign(indexed.items[0], { applicationPath: '/' + 'a'.repeat(1499),
    name: 'N'.repeat(129), metadataSource: 'INDEXED_ITEM',
    uiElement: null, backgroundOnly: null, installationState: 'UNKNOWN' });
  const indexedBody = executeFixture('SingleApplicationWire', indexed).body;
  examples.indexed = { bytes: countBytes(indexedBody), nameBytes: 129, pathBytes: 1500,
    nativeObservation: false };
  const quotaItems = Array.from({ length: 2048 }, () => itemEnvelope(8192));
  const quotaSingle = countBytes(projectResponse('SingleApplicationWire', snapshotEnvelope(quotaItems)));
  const quotaFull = countBytes(projectResponse('CompleteApplicationWire', snapshotEnvelope(quotaItems)));
  return {
    schemaVersion: 1, nativeVerdict: 'PENDING', usefulSubjectCertificateEstablished: false,
    wholeJobGrossBytes: null, wholeJobAttempts: null, actualFinalResponseBytes: null,
    responseGate: 8388608,
    encoding: 'Compact default GraphQLJSONEncoder: UTF-8 + slash/control escaping; exact counter.',
    conditionalAssumptions: [
      'Final retained paths equal the saved resolved targets; this is not native capture.',
      'Every saved episode can contribute a choice; identity merges may reduce multiplicity.',
      'Final names <=1024 and identifiers <=512 UTF-8 bytes; no regional value is invented.',
      'Three application source groups, total 64 diagnostics, declaredDomain <=1024 and '
        + 'permission target <=8192 bytes are explicit conditional dimensions, not new quotas.',
      'Conditional totals describe successful data only; all real error values must also be supplied.',
    ],
    unknownInputs: ['actual final ordinary/indexed scalars', 'actual source/domain/permission payloads',
      'actual emitted error messages/extensions/locations/paths',
      '149 outside source/root outcomes and resulting choices',
      'actual output conversion/publication allocation/copy/ARC operations'],
    dimensions: { episodesPerRun: rows.length, outsidePaths: 149,
      maximumSavedNameBytes: Math.max(...episodes.commonRows.map(row => row[nameIndex])),
      maximumSavedRootBytes: Math.max(...episodes.commonRows.map(row => row[pathIndex])) },
    episodeSpellings: [...subject.episodeSpellings],
    columns: ['conditionalSavedFinalPathBytes', 'literalSpellingEncodedBytes',
      'conditionalPathStringUpper', 'singleSelectedChoiceUpper', 'fourAliasChoiceUpper',
      'actualSelectedChoiceBytes'],
    runs, outsidePaths: subject.queryPathsOutsideDirectorySubject,
    conditionalQuotaSuccessfulData: { choices: 2048, pathBytes: 8192,
      singleBytes: quotaSingle, fullBytes: quotaFull, provesAllSelectionsFit: false },
    fixtures: examples,
    maximumCanonicalSaturationGuidanceBytes: Buffer.byteLength(saturationGuidance()),
    replacementBody: finalGuard({ data: { fixture: 'x'.repeat(8388608) } }),
  };
}

export function digestInputs() {
  const paths = new Set(INPUTS);
  function visit(path) {
    for (const entry of readdirSync(resolve(ROOT, path), { withFileTypes: true })) {
      const child = path + '/' + entry.name;
      if (entry.isDirectory()) visit(child);
      else if (entry.isFile() && /\.(mjs|js)$/.test(child)) paths.add(child);
    }
  }
  visit('clients/contract-only/node_modules/graphql');
  const digests = Object.fromEntries([...paths].sort().map(path => [path,
    createHash('sha256').update(readFileSync(resolve(ROOT, path))).digest('hex')]));
  digests['runtime:node'] = createHash('sha256').update(readFileSync(process.execPath)).digest('hex');
  return digests;
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  assert.ok(['--write', '--check'].includes(process.argv[2]), 'use --write or --check');
  const before = digestInputs();
  const output = { ...buildReport(), inputHashes: before, frozenBeforeAfter: true };
  const after = digestInputs();
  assert.deepEqual(after, before, 'input changed during measurement');
  if (process.argv[2] === '--write') {
    writeFileSync(resolve(ROOT, REPORT), JSON.stringify(output) + '\n');
  } else {
    // Compare the saved JSON value, not GraphQL-js's internal null prototypes.
    assert.deepEqual(JSON.parse(read(REPORT)), JSON.parse(JSON.stringify(output)),
      'per-item report/input hashes changed');
  }
  console.log(JSON.stringify({ result: process.argv[2],
    episodesPerRun: output.dimensions.episodesPerRun, runs: Object.keys(output.runs),
    outsidePaths: output.outsidePaths.length, actualResponseBytes: null,
    nativeVerdict: output.nativeVerdict }));
}
