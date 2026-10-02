import { readFileSync } from 'node:fs';
import type { CodegenConfig } from '@graphql-codegen/cli';
import { Kind, parse, visit, type DocumentNode, type FragmentDefinitionNode } from 'graphql';

/**
 * The schema is the introspection response captured from the running signed
 * Koine this client was generated against (`capture/`); the documents are the
 * contract's published client operations, read from where the contract
 * publishes them so that no copy can drift from them.
 *
 * `desktop-operations.graphql` is used whole: all five of its operations are
 * served. `workspace-operations.graphql` is a *design* file: besides the two
 * operations this client uses (`LaunchInstalledApplication`, `OpenSearchURL`,
 * `OpenDocumentOrDirectory`; the captured server now serves all three of their
 * roots) it declares an operation whose root the captured server does not serve
 * yet (`RevealPath`). The documents do not say how a client picks the served subset,
 * so this file decides: the client names the operations it uses, below, and takes
 * each one's text from the published file byte-for-byte together with the
 * fragments it spreads (transitively). Every selected definition is then
 * validated by graphql-codegen against the captured schema, and generation fails
 * if one does not validate, exactly as before. A name listed here that the
 * published file no longer declares also fails generation. Operations not listed
 * are reported, with whether their root field is served, but never generated.
 */
const DESKTOP_OPERATIONS = '../../docs/design/desktop-operations.graphql';
const WORKSPACE_OPERATIONS = '../../docs/design/workspace-operations.graphql';
const WORKSPACE_OPERATIONS_USED: readonly string[] = [
  'LaunchInstalledApplication',
  'OpenSearchURL',
  'OpenDocumentOrDirectory',
];

function servedRootFields(): ReadonlySet<string> {
  const introspection = JSON.parse(readFileSync('./capture/introspection.json', 'utf8')) as {
    data: { __schema: { types: { name: string; fields: { name: string }[] | null }[] } };
  };
  const roots = new Set<string>();
  for (const type of introspection.data.__schema.types) {
    if (type.name === 'Query' || type.name === 'Mutation') {
      for (const field of type.fields ?? []) roots.add(field.name);
    }
  }
  return roots;
}

function pickPublished(path: string, used: readonly string[]): string {
  const text = readFileSync(path, 'utf8');
  const document: DocumentNode = parse(text);

  const fragments = new Map<string, FragmentDefinitionNode>();
  const operations = new Map<string, (typeof document.definitions)[number]>();
  for (const definition of document.definitions) {
    if (definition.kind === Kind.FRAGMENT_DEFINITION) fragments.set(definition.name.value, definition);
    else if (definition.kind === Kind.OPERATION_DEFINITION && definition.name !== undefined) {
      operations.set(definition.name.value, definition);
    }
  }

  const wanted = new Set<(typeof document.definitions)[number]>();
  const queue: (typeof document.definitions)[number][] = [];
  for (const name of used) {
    const operation = operations.get(name);
    if (operation === undefined) {
      throw new Error(`${path} no longer declares the operation ${name} that this client uses`);
    }
    queue.push(operation);
  }
  while (queue.length > 0) {
    const definition = queue.pop();
    if (definition === undefined || wanted.has(definition)) continue;
    wanted.add(definition);
    visit(definition, {
      FragmentSpread(node) {
        const fragment = fragments.get(node.name.value);
        if (fragment === undefined) {
          throw new Error(`${path}: fragment ${node.name.value} is spread but not declared`);
        }
        queue.push(fragment);
      },
    });
  }

  // Report, never generate, the operations this client does not use, and say
  // whether the captured server serves their root fields.
  const served = servedRootFields();
  for (const [name, operation] of operations) {
    if (used.includes(name) || operation.kind !== Kind.OPERATION_DEFINITION) continue;
    const roots = operation.selectionSet.selections.flatMap((s) => (s.kind === Kind.FIELD ? [s.name.value] : []));
    const unserved = roots.filter((root) => !served.has(root));
    process.stderr.write(
      `codegen: ${path}: ${name} not generated (${unserved.length > 0 ? `root not served by the captured schema: ${unserved.join(', ')}` : 'root served, but not used by this client'})\n`,
    );
  }

  // The text of each selected definition, cut from the published file by source
  // location: no re-printing, so nothing is reformatted or re-ordered.
  return document.definitions
    .filter((definition) => wanted.has(definition))
    .map((definition) => {
      const loc = definition.loc;
      if (loc === undefined) throw new Error(`${path}: a definition has no source location`);
      return text.slice(loc.start, loc.end);
    })
    .join('\n\n');
}

const config: CodegenConfig = {
  schema: './capture/introspection.json',
  documents: [DESKTOP_OPERATIONS, pickPublished(WORKSPACE_OPERATIONS, WORKSPACE_OPERATIONS_USED)],
  ignoreNoDocuments: false,
  generates: {
    './src/generated/graphql.ts': {
      plugins: ['typescript', 'typescript-operations', 'typed-document-node'],
      config: {
        documentMode: 'string',
        strictScalars: true,
        useTypeImports: true,
        avoidOptionals: true,
        enumsAsTypes: true,
        scalars: {
          ID: 'string',
          Reference: 'string',
          DesktopProcessStart: 'string',
        },
      },
    },
  },
};

export default config;
