// Tests catch omitted bytes/aliases/fields/errors and fabricated native values.
import { strict as assert } from 'node:assert';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import {
  buildReport, countBytes, encodeReference, executeFixture, fieldsComplete,
  finalGuard, fixture, projectResponse, stringBytes, unknown, upperString,
} from './application_metadata_wire.mjs';

test('escape counts include slashes, control bytes, UTF-8 and punctuation', () => {
  const cases = [['', 2], ['a/b', 6], ['"\\', 6], ['\u0001', 8],
    ['\b\t\n\f\r', 12], ['é', 4], ['😀', 6]];
  for (const [text, bytes] of cases) {
    assert.equal(stringBytes(text), bytes);
    assert.equal(Buffer.byteLength(encodeReference(text)), bytes);
  }
  assert.equal(countBytes({ x: [null, true, false, -2147483648] }), 35);
  assert.equal(countBytes({}), 2);
  assert.equal(countBytes([]), 2);
  assert.equal(countBytes(upperString(129)), 776);
});

test('unknown wire values cannot be turned into zero or an empty response', () => {
  assert.equal(countBytes({ data: { apps: unknown } }), null);
  assert.throws(() => upperString(-1));
  assert.throws(() => countBytes(Number.NaN));
  assert.throws(() => countBytes(2147483648));
});

test('independent encoder agrees for every control byte and mixed nested JSON values', () => {
  for (let n = 0; n < 32; n++) {
    const body = { data: { ['k/"' + n]: [String.fromCodePoint(n) + 'é😀', null,
      n % 2 === 0, -n, { path: '/\\"' }] } };
    assert.equal(countBytes(body), Buffer.byteLength(encodeReference(body)));
  }
});

test('complete selection includes every reachable application and permission field', () => {
  fieldsComplete('CompleteApplicationWire');
  fieldsComplete('SingleApplicationWire');
  assert.throws(() => fieldsComplete('ApplicationSourcesWire'), /items/);
});

test('collector merges repeated fragments and response keys but repeats distinct aliases', () => {
  const input = fixture();
  const projected = projectResponse('CompleteApplicationWire', input);
  const executed = executeFixture('CompleteApplicationWire', input);
  assert.deepEqual(projected, JSON.parse(JSON.stringify(executed.body)));
  assert.equal(executed.roots, 2);
  assert.equal(executed.items, 4);
  assert.deepEqual(Object.keys(projected.data), ['alpha', 'beta']);
  assert.equal(projected.data.alpha.first[0].label, 'A/"é😀');
  assert.equal(countBytes(projected), Buffer.byteLength(encodeReference(executed.body)));
  const one = projectResponse('CompleteApplicationWire', input, { includeSecond: false });
  assert.deepEqual(Object.keys(one.data), ['alpha']);
  assert.equal(executeFixture('CompleteApplicationWire', input,
    { includeSecond: false }).roots, 1);
  assert.equal(countBytes(projected), 2 * countBytes(one) - 11);
});

test('FAILED emits errors at each selected items alias; source-only does not', () => {
  const failed = fixture('FAILED');
  const result = executeFixture('CompleteApplicationWire', failed);
  assert.deepEqual(result.body.errors.map(e => e.path),
    [['alpha', 'first'], ['alpha', 'second'], ['beta', 'first'], ['beta', 'second']]);
  assert.equal(result.body.errors[0].locations.length, 2);
  assert.equal(result.body.data.alpha.first, null);
  assert.equal(result.body.errors[0].extensions.kind, 'failed');
  assert.equal(countBytes(result.body), Buffer.byteLength(encodeReference(result.body)));
  assert.equal(executeFixture('ApplicationSourcesWire', failed).body.errors, undefined);
  for (const status of ['BLOCKED', 'UNAVAILABLE', 'UNKNOWN']) {
    const body = executeFixture('CompleteApplicationWire', fixture(status)).body;
    assert.equal(body.errors, undefined);
    assert.equal(body.data.alpha.first, null);
  }
});

test('independent roots can publish different snapshots and failure paths', () => {
  const alpha = fixture();
  const beta = fixture('FAILED');
  const result = executeFixture('CompleteApplicationWire', alpha, {}, 'ordinary', { beta });
  assert.equal(result.roots, 2);
  assert.equal(result.body.data.alpha.first.length, 1);
  assert.equal(result.body.data.beta.first, null);
  assert.deepEqual(result.body.errors.map(e => e.path), [['beta', 'first'], ['beta', 'second']]);
  const ordinaryBeta = fixture('PARTIAL');
  ordinaryBeta.items[0].name = 'Another independent name';
  const projected = projectResponse('CompleteApplicationWire', alpha, {}, { beta: ordinaryBeta });
  const execution = executeFixture('CompleteApplicationWire', alpha, {}, 'ordinary',
    { beta: ordinaryBeta });
  assert.deepEqual(projected, JSON.parse(JSON.stringify(execution.body)));
  assert.equal(projected.data.beta.first[0].name, 'Another independent name');
});

test('publication permission errors preserve extensions, indexed path and null propagation', () => {
  const result = executeFixture('SingleApplicationWire', fixture('PARTIAL'), {}, 'permission');
  assert.equal(result.body.data.apps.items, null);
  assert.deepEqual(result.body.errors[0].path, ['apps', 'items', 0, 'applicationPath']);
  assert.deepEqual(result.body.errors[0].extensions, {
    kind: 'permission', permissionClass: 'capability', phase: 'dispatch',
    requiredCapability: 'workspace:read',
  });
  assert.equal(countBytes(result.body), Buffer.byteLength(encodeReference(result.body)));
});

test('indexed long scalar witness retains 129-byte names and honest nullable flags', () => {
  const input = fixture();
  Object.assign(input.items[0], { applicationPath: '/' + 'a'.repeat(1499),
    name: 'N'.repeat(129), metadataSource: 'INDEXED_ITEM',
    uiElement: null, backgroundOnly: null, installationState: 'UNKNOWN' });
  const body = executeFixture('SingleApplicationWire', input).body;
  assert.equal(Buffer.byteLength(body.data.apps.items[0].name), 129);
  assert.equal(Buffer.byteLength(body.data.apps.items[0].applicationPath), 1500);
  assert.equal(body.data.apps.items[0].metadataSource, 'INDEXED_ITEM');
  assert.equal(body.data.apps.items[0].backgroundOnly, null);
  assert.equal(body.data.apps.items[0].installationState, 'UNKNOWN');
  assert.equal(countBytes(body), Buffer.byteLength(encodeReference(body)));
});

test('saturation keeps choices while encoding permission and all summarized reasons', () => {
  const input = fixture('PARTIAL', true);
  const body = executeFixture('SingleApplicationWire', input).body;
  assert.equal(body.data.apps.items.length, 1);
  assert.equal(body.data.apps.resultsTruncated, false);
  assert.equal(body.data.apps.sources.flatMap(x => x.diagnostics).length, 64);
  assert.equal(body.data.apps.sources[0].diagnostics.at(-1).reason, 'DIAGNOSTIC_LIMIT');
  assert.match(body.data.apps.sources[0].diagnostics.at(-1).guidance, /CALL_LIMIT/);
  assert.equal(countBytes(body), Buffer.byteLength(encodeReference(body)));
});

test('full selected body is replaced only above cap, never trimmed', () => {
  const atCap = { data: { x: 'x'.repeat(8388591) } };
  assert.equal(countBytes(atCap), 8388608);
  assert.equal(finalGuard(atCap).replaced, false);
  const above = { data: { x: 'x'.repeat(8388592) } };
  const rejected = finalGuard(above);
  assert.equal(rejected.replaced, true);
  assert.equal(rejected.body.data, null);
  assert.equal(rejected.body.errors[0].extensions.kind, 'failed');
  assert.deepEqual(rejected.body.errors[0].path, []);
  assert.equal(rejected.responseBytes, 174);
  assert.equal(rejected.originalBytes, 8388609);
  assert.ok(rejected.responseBytes < 8388608);
  const many = fixture();
  many.items = Array.from({ length: 2043 }, () => ({ ...many.items[0],
    name: '"'.repeat(1024),
    applicationPath: '/' + ['a'.repeat(250), ...Array(5).fill('a'.repeat(248))].join('/') + '.app',
    metadataSource: 'INDEXED_ITEM', installationState: 'UNKNOWN',
    uiElement: null, backgroundOnly: null }));
  const full = executeFixture('CompleteApplicationWire', many).body;
  assert.equal(finalGuard(full).replaced, true);
  assert.equal(full.data.alpha.first.length, 2043);
  assert.equal(full.data.beta.second.length, 2043);
});

test('report keeps every episode association and outside record; finals remain unknown', () => {
  const report = buildReport();
  const source = JSON.parse(readFileSync('docs/design/application-metadata-episode-certificate.json'));
  assert.deepEqual(report.episodeSpellings, source.episodeSpellings);
  const pathIndex = source.commonColumns.indexOf('resolvedRootBytes');
  assert.equal(report.episodeSpellings.length, 2043);
  assert.equal(new Set(report.episodeSpellings).size, 2043);
  assert.equal(report.outsidePaths.length, 149);
  for (const run of Object.values(report.runs)) {
    assert.equal(run.rows.length, 2043);
    assert.equal(run.actualResponseBytes, null);
    assert.equal(run.conditionalFullBytes > run.conditionalSingleBytes, true);
    assert.equal(run.rows.every(row => row.at(-1) === null), true);
    run.rows.forEach((row, index) => {
      assert.equal(row[0], source.commonRows[index][pathIndex]);
      assert.equal(row[1], Buffer.byteLength(encodeReference(source.episodeSpellings[index])));
      assert.equal(row[2], 2 + 6 * source.commonRows[index][pathIndex]);
      assert.equal(row[4], 4 * row[3]);
    });
  }
  assert.equal(report.nativeVerdict, 'PENDING');
  assert.equal(report.usefulSubjectCertificateEstablished, false);
  assert.equal(report.wholeJobGrossBytes, null);
  assert.equal(report.wholeJobAttempts, null);
  assert.equal(report.actualFinalResponseBytes, null);
  assert.equal(report.dimensions.maximumSavedNameBytes, 129);
  assert.equal(report.dimensions.maximumSavedRootBytes, 1500);
});
