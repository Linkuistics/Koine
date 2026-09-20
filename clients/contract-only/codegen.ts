import type { CodegenConfig } from '@graphql-codegen/cli';

/**
 * The schema is the introspection response captured from the running notarized
 * Koine this client was generated against (`capture/`); the documents are the
 * contract's published client operations, read from where the contract publishes
 * them so that no copy can drift from them. Generation therefore validates the
 * five operations against the served schema, and fails if any does not.
 */
const config: CodegenConfig = {
  schema: './capture/introspection.json',
  documents: '../../docs/design/desktop-operations.graphql',
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
