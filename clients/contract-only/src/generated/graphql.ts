import type { DocumentTypeDecoration } from '@graphql-typed-document-node/core';
export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  DesktopProcessStart: { input: string; output: string; }
  Reference: { input: string; output: string; }
};

/** All fields require desktop:read. */
export type DesktopApplication = {
  __typename?: 'DesktopApplication';
  bundleIdentifier: Maybe<Scalars['String']['output']>;
  name: Scalars['String']['output'];
  ref: Scalars['Reference']['output'];
  windows: Array<DesktopWindow>;
};

/** Control-authorized output; it does not expose read-protected window state. */
export type DesktopFocusReceipt = {
  __typename?: 'DesktopFocusReceipt';
  /** The submitted target, under the mutation's control authority. */
  ref: Scalars['Reference']['output'];
};

export type DesktopObservation =
  | 'CURRENT'
  | 'REMEMBERED';

export type DesktopProcessIdentity = {
  pid: Scalars['Int']['input'];
  startedAt: Scalars['DesktopProcessStart']['input'];
};

/** All fields require desktop:read. */
export type DesktopWindow = {
  __typename?: 'DesktopWindow';
  observation: DesktopObservation;
  ref: Scalars['Reference']['output'];
  title: Scalars['String']['output'];
};

export type Koine = {
  __typename?: 'Koine';
  /** Names available to request. Listing them supplies no authority. */
  availableCapabilities: Array<Scalars['String']['output']>;
  contractVersion: Scalars['String']['output'];
  instanceId: Scalars['String']['output'];
  /** Caller only; null only for the non-exportable in-process console principal. */
  ownGrant: Maybe<KoineGrant>;
  /** Equality token for the served schema; compare, do not interpret. */
  schemaDigest: Scalars['String']['output'];
};

export type KoineCreateGrantInput = {
  capabilities: Array<Scalars['String']['input']>;
  clientLabel: Scalars['String']['input'];
};

export type KoineCreatedGrant = {
  __typename?: 'KoineCreatedGrant';
  /** One-time 32-byte random bearer secret encoded as unpadded base64url. */
  credential: Scalars['String']['output'];
  grant: KoineGrant;
};

export type KoineGrant = {
  __typename?: 'KoineGrant';
  capabilities: Array<Scalars['String']['output']>;
  clientLabel: Scalars['String']['output'];
  grantId: Scalars['ID']['output'];
  state: KoineGrantState;
};

export type KoineGrantRequest = {
  __typename?: 'KoineGrantRequest';
  clientLabel: Scalars['String']['output'];
  comparisonCode: Scalars['String']['output'];
  /** Present only after approval; scoped to this request. */
  grant: Maybe<KoineGrant>;
  requestId: Scalars['ID']['output'];
  requestedCapabilities: Array<Scalars['String']['output']>;
  state: KoineGrantRequestState;
};

export type KoineGrantRequestReceipt = {
  __typename?: 'KoineGrantRequestReceipt';
  comparisonCode: Scalars['String']['output'];
  requestId: Scalars['ID']['output'];
};

export type KoineGrantRequestState =
  | 'APPROVED'
  | 'DENIED'
  | 'EXPIRED'
  | 'PENDING';

export type KoineGrantState =
  | 'ACTIVE'
  | 'REVOKED';

/** All fields require koine:manage. */
export type KoineManagement = {
  __typename?: 'KoineManagement';
  grants: Array<KoineGrant>;
  /** Read on each request. Reading never asks the user for consent. */
  osPermissions: Array<KoineOsPermission>;
  providers: Array<KoineProviderStatus>;
  requests: Array<KoineGrantRequest>;
};

export type KoineOsPermission = {
  __typename?: 'KoineOSPermission';
  granted: Scalars['Boolean']['output'];
  owner: Scalars['String']['output'];
  permission: Scalars['String']['output'];
};

export type KoineProviderState =
  | 'ACTIVE'
  | 'FAILED'
  | 'INCOMPATIBLE'
  | 'REJECTED';

export type KoineProviderStatus = {
  __typename?: 'KoineProviderStatus';
  diagnostic: Maybe<Scalars['String']['output']>;
  provider: Scalars['String']['output'];
  schemaVersion: Scalars['String']['output'];
  state: KoineProviderState;
  version: Scalars['String']['output'];
};

export type KoineRequestGrantInput = {
  capabilities: Array<Scalars['String']['input']>;
  clientLabel: Scalars['String']['input'];
  /** Canonical lower-case SHA-256 hex digest of a 32-byte random bearer secret. */
  credentialDigest: Scalars['String']['input'];
};

export type Mutation = {
  __typename?: 'Mutation';
  /** desktop:control. Focuses exactly this window or reports why it did not; never a substitute. */
  desktopFocusWindow: Maybe<DesktopFocusReceipt>;
  /** koine:manage. Approves only a subset of the immutable requested capabilities. */
  koineApproveGrantRequest: Maybe<KoineGrant>;
  /** koine:manage. Credential is returned once after durable creation. */
  koineCreateGrant: Maybe<KoineCreatedGrant>;
  /** koine:manage. Denies a pending request. */
  koineDenyGrantRequest: Maybe<KoineGrantRequest>;
  /** Anonymous enrollment only; cannot be mixed with other root actions. */
  koineRequestGrant: Maybe<KoineGrantRequestReceipt>;
  /** koine:manage. Idempotent for an already revoked grant; never grants authority. */
  koineRevokeGrant: Maybe<KoineGrant>;
};


export type MutationDesktopFocusWindowArgs = {
  ref: Scalars['Reference']['input'];
};


export type MutationKoineApproveGrantRequestArgs = {
  capabilities: Array<Scalars['String']['input']>;
  requestId: Scalars['ID']['input'];
};


export type MutationKoineCreateGrantArgs = {
  input: KoineCreateGrantInput;
};


export type MutationKoineDenyGrantRequestArgs = {
  requestId: Scalars['ID']['input'];
};


export type MutationKoineRequestGrantArgs = {
  input: KoineRequestGrantInput;
};


export type MutationKoineRevokeGrantArgs = {
  grantId: Scalars['ID']['input'];
};

export type Query = {
  __typename?: 'Query';
  /** desktop:read. An absent process is ordinary null. */
  desktopApplication: Maybe<DesktopApplication>;
  /** desktop:read. A stale or wrong-kind reference raises unavailable. */
  desktopApplicationByReference: Maybe<DesktopApplication>;
  /** desktop:read. A stale or wrong-kind reference raises unavailable. */
  desktopWindow: Maybe<DesktopWindow>;
  /** Authenticated caller metadata. No provider capability required. */
  koine: Koine;
  /** Proof of the submitted secret, or its resulting active grant; own request only. */
  koineGrantRequest: Maybe<KoineGrantRequest>;
  /** koine:manage. Never returns bearer credentials. */
  koineManagement: Maybe<KoineManagement>;
};


export type QueryDesktopApplicationArgs = {
  process: DesktopProcessIdentity;
};


export type QueryDesktopApplicationByReferenceArgs = {
  ref: Scalars['Reference']['input'];
};


export type QueryDesktopWindowArgs = {
  ref: Scalars['Reference']['input'];
};

export type DesktopChoicesQueryVariables = Exact<{
  process: DesktopProcessIdentity;
}>;


export type DesktopChoicesQuery = { __typename?: 'Query', desktopApplication: { __typename?: 'DesktopApplication', ref: string, name: string, windows: Array<{ __typename?: 'DesktopWindow', ref: string, title: string, observation: DesktopObservation }> } | null };

export type FocusDesktopWindowMutationVariables = Exact<{
  ref: Scalars['Reference']['input'];
}>;


export type FocusDesktopWindowMutation = { __typename?: 'Mutation', desktopFocusWindow: { __typename?: 'DesktopFocusReceipt', ref: string } | null };

export type RequestDesktopGrantMutationVariables = Exact<{
  input: KoineRequestGrantInput;
}>;


export type RequestDesktopGrantMutation = { __typename?: 'Mutation', koineRequestGrant: { __typename?: 'KoineGrantRequestReceipt', requestId: string, comparisonCode: string } | null };

export type PollOwnGrantRequestQueryVariables = Exact<{ [key: string]: never; }>;


export type PollOwnGrantRequestQuery = { __typename?: 'Query', koineGrantRequest: { __typename?: 'KoineGrantRequest', state: KoineGrantRequestState, grant: { __typename?: 'KoineGrant', grantId: string, capabilities: Array<string>, state: KoineGrantState } | null } | null };

export type InspectOwnConnectionQueryVariables = Exact<{ [key: string]: never; }>;


export type InspectOwnConnectionQuery = { __typename?: 'Query', koine: { __typename?: 'Koine', contractVersion: string, instanceId: string, schemaDigest: string, ownGrant: { __typename?: 'KoineGrant', capabilities: Array<string>, state: KoineGrantState } | null } };

export class TypedDocumentString<TResult, TVariables>
  extends String
  implements DocumentTypeDecoration<TResult, TVariables>
{
  __apiType?: NonNullable<DocumentTypeDecoration<TResult, TVariables>['__apiType']>;
  private value: string;
  public __meta__?: Record<string, any> | undefined;

  constructor(value: string, __meta__?: Record<string, any> | undefined) {
    super(value);
    this.value = value;
    this.__meta__ = __meta__;
  }

  override toString(): string & DocumentTypeDecoration<TResult, TVariables> {
    return this.value;
  }
}

export const DesktopChoicesDocument = new TypedDocumentString(`
    query DesktopChoices($process: DesktopProcessIdentity!) {
  desktopApplication(process: $process) {
    ref
    name
    windows {
      ref
      title
      observation
    }
  }
}
    `) as unknown as TypedDocumentString<DesktopChoicesQuery, DesktopChoicesQueryVariables>;
export const FocusDesktopWindowDocument = new TypedDocumentString(`
    mutation FocusDesktopWindow($ref: Reference!) {
  desktopFocusWindow(ref: $ref) {
    ref
  }
}
    `) as unknown as TypedDocumentString<FocusDesktopWindowMutation, FocusDesktopWindowMutationVariables>;
export const RequestDesktopGrantDocument = new TypedDocumentString(`
    mutation RequestDesktopGrant($input: KoineRequestGrantInput!) {
  koineRequestGrant(input: $input) {
    requestId
    comparisonCode
  }
}
    `) as unknown as TypedDocumentString<RequestDesktopGrantMutation, RequestDesktopGrantMutationVariables>;
export const PollOwnGrantRequestDocument = new TypedDocumentString(`
    query PollOwnGrantRequest {
  koineGrantRequest {
    state
    grant {
      grantId
      capabilities
      state
    }
  }
}
    `) as unknown as TypedDocumentString<PollOwnGrantRequestQuery, PollOwnGrantRequestQueryVariables>;
export const InspectOwnConnectionDocument = new TypedDocumentString(`
    query InspectOwnConnection {
  koine {
    contractVersion
    instanceId
    schemaDigest
    ownGrant {
      capabilities
      state
    }
  }
}
    `) as unknown as TypedDocumentString<InspectOwnConnectionQuery, InspectOwnConnectionQueryVariables>;