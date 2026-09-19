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
  "Proof of the submitted secret, or its resulting active grant; own request only."
  koineGrantRequest: KoineGrantRequest
  "koine:manage. Never returns bearer credentials."
  koineManagement: KoineManagement
}

type Mutation {
  "Anonymous enrollment only; cannot be mixed with other root actions."
  koineRequestGrant(input: KoineRequestGrantInput!): KoineGrantRequestReceipt
  "koine:manage. Approves only a subset of the immutable requested capabilities."
  koineApproveGrantRequest(requestId: ID!, capabilities: [String!]!): KoineGrant
  "koine:manage. Denies a pending request."
  koineDenyGrantRequest(requestId: ID!): KoineGrantRequest
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

input KoineRequestGrantInput {
  clientLabel: String!
  "Canonical lower-case SHA-256 hex digest of a 32-byte random bearer secret."
  credentialDigest: String!
  capabilities: [String!]!
}

type KoineGrantRequestReceipt {
  requestId: ID!
  comparisonCode: String!
}

type KoineGrantRequest {
  requestId: ID!
  clientLabel: String!
  comparisonCode: String!
  requestedCapabilities: [String!]!
  state: KoineGrantRequestState!
  "Present only after approval; scoped to this request."
  grant: KoineGrant
}

enum KoineGrantRequestState { PENDING APPROVED DENIED EXPIRED }

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
  requests: [KoineGrantRequest!]!
  grants: [KoineGrant!]!
  providers: [KoineProviderStatus!]!
  "Read on each request. Reading never asks the user for consent."
  osPermissions: [KoineOSPermission!]!
}

type KoineProviderStatus {
  provider: String!
  version: String!
  schemaVersion: String!
  state: KoineProviderState!
  diagnostic: String
}

enum KoineProviderState { ACTIVE INCOMPATIBLE REJECTED FAILED }

type KoineOSPermission {
  permission: String!
  owner: String!
  granted: Boolean!
}
"""#
