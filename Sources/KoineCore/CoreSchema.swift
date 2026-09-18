/// The core's served SDL. Each stage adds only the fields it makes real; the
/// target shapes are in docs/design/desktop-schema.graphql.
let coreSchemaSDL = #"""
"""
koine-desktop/1. Descriptions expose authority requirements; discovery never grants authority.
"""
schema { query: Query mutation: Mutation }

type Query {
  "Authenticated caller metadata. No provider capability required."
  koine: Koine!
  "koine:manage. Never returns bearer credentials."
  koineManagement: KoineManagement
}

type Mutation {
  "koine:manage. Credential is returned once after durable creation."
  koineCreateGrant(input: KoineCreateGrantInput!): KoineCreatedGrant
  "koine:manage. Idempotent for an already revoked grant; never grants authority."
  koineRevokeGrant(grantId: ID!): KoineGrant
}

type Koine {
  contractVersion: String!
  instanceId: String!
  "Equality token for the served schema; compare, do not interpret."
  schemaDigest: String!
  "Caller only; null only for the non-exportable in-process console principal."
  ownGrant: KoineGrant
  "Names available to request. Listing them supplies no authority."
  availableCapabilities: [String!]!
}

input KoineCreateGrantInput {
  clientLabel: String!
  capabilities: [String!]!
}

type KoineGrant {
  grantId: ID!
  clientLabel: String!
  capabilities: [String!]!
  state: KoineGrantState!
}

enum KoineGrantState { ACTIVE REVOKED }

type KoineCreatedGrant {
  grant: KoineGrant!
  "One-time 32-byte random bearer secret encoded as unpadded base64url."
  credential: String!
}

"All fields require koine:manage."
type KoineManagement {
  grants: [KoineGrant!]!
}
"""#
