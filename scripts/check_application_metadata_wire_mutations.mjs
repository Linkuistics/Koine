// Every mutant is a disposable source copy and must fail behavioral tests.
import { strict as assert } from 'node:assert';
import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, resolve } from 'node:path';
import { digestInputs, INPUTS, ROOT } from './application_metadata_wire.mjs';

const model = 'scripts/application_metadata_wire.mjs';
const selection = 'docs/design/application-metadata-wire.graphql';
const files = INPUTS.filter(path => !path.includes('/node_modules/'));
const mutations = [
  ['slash-escaping', model, " || char === '/'", ''],
  ['control-escaping', model, '? 2 : 6', '? 2 : 2'],
  ['key-quotes-colon', model, 'stringBytes(key), 1,', '0, 0,'],
  ['alias-collapse', model, 'node.alias?.value ?? node.name.value', 'node.name.value'],
  ['fragment-omission', model, 'walk(fragment.selectionSet);', 'continue;'],
  ['error-omission', model, 'body.errors = result.errors.map(e => e.toJSON())',
    'body.errors = undefined'],
  ['unknown-to-zero', model, 'if (value === unknown) return null;',
    'if (value === unknown) return 0;'],
  ['alias-row-loss', model, 'rows: rows.map(row => [...row])',
    'rows: rows.slice(128).map(row => [...row])'],
  ['outside-loss', model, 'outsidePaths: subject.queryPathsOutsideDirectorySubject,',
    'outsidePaths: subject.queryPathsOutsideDirectorySubject.slice(1),'],
  ['actual-zero', model, '      actualResponseBytes: null,\n',
    '      actualResponseBytes: 0,\n'],
  ['path-row-mismatch', model, 'return [bytes, stringBytes(', 'return [bytes + 1, stringBytes('],
  ['at-cap-rejection', model, 'originalBytes > 8388608', 'originalBytes >= 8388608'],
  ['guard-path-loss', model, '    path: [],\n', ''],
  ['permission-field-loss', selection, '    event\n', ''],
];
const before = digestInputs();
for (const [name, path, from, to] of mutations) {
  const directory = mkdtempSync(resolve(tmpdir(), 'koine-wire-mutation-'));
  try {
    for (const file of files) {
      const destination = resolve(directory, file);
      mkdirSync(dirname(destination), { recursive: true });
      copyFileSync(resolve(ROOT, file), destination);
    }
    const modules = resolve(directory, 'clients/contract-only/node_modules');
    mkdirSync(modules, { recursive: true });
    symlinkSync(resolve(ROOT, 'clients/contract-only/node_modules/graphql'),
      resolve(modules, 'graphql'), 'dir');
    const destination = resolve(directory, path);
    const source = readFileSync(destination, 'utf8');
    assert.equal(source.split(from).length, 2, `mutation ${name} must target exactly one site`);
    writeFileSync(destination, source.replace(from, to));
    const result = spawnSync(process.execPath,
      ['--test', 'scripts/test_application_metadata_wire.mjs'],
      { cwd: directory, encoding: 'utf8', timeout: 30000 });
    assert.equal(result.error, undefined, `mutation ${name} execution failed`);
    assert.equal(result.signal, null, `mutation ${name} died by signal`);
    assert.notEqual(result.status, 0, `mutation survived: ${name}`);
    assert.match(result.stdout + result.stderr, /AssertionError/,
      `mutation ${name} must fail a behavioral assertion, not a syntax/import error`);
    console.log('REJECTED ' + name);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}
assert.deepEqual(digestInputs(), before, 'subjects changed during mutation controls');
console.log('All 14 isolated wire controls rejected; inputs unchanged; native PENDING.');
