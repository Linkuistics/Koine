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

export type KoineProviderOrigin =
  | 'BUNDLED'
  | 'PER_USER';

export type KoineProviderSelection =
  | 'NOT_SELECTED'
  | 'SELECTED'
  | 'UNAVAILABLE';

export type KoineProviderState =
  | 'ACTIVE'
  | 'FAILED'
  | 'INCOMPATIBLE'
  | 'REJECTED';

export type KoineProviderStatus = {
  __typename?: 'KoineProviderStatus';
  /** Opaque identity of origin plus canonical installed bundle location, unique within this startup. Null only for a synthetic row. Not a resource reference. */
  candidateId: Maybe<Scalars['String']['output']>;
  diagnostic: Maybe<Scalars['String']['output']>;
  /** Where the bundle is physically installed. Null for a synthetic row; never inferred from composition position. */
  origin: Maybe<KoineProviderOrigin>;
  provider: Scalars['String']['output'];
  /** Stable, open diagnostic code for a refusal or selection explanation. Null for a healthy selected row with nothing competing or missing. */
  reason: Maybe<Scalars['String']['output']>;
  schemaVersion: Scalars['String']['output'];
  /** The frozen choice for the same provider identity, or null if there is none. A selected row points to itself, even after a later failure. */
  selectedCandidateId: Maybe<Scalars['String']['output']>;
  /** Whether this candidate is the frozen choice for its provider identity. Synthetic rows are UNAVAILABLE. */
  selection: Maybe<KoineProviderSelection>;
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
  /** Requires workspace:control AND desktop:control. Launch or request reactivation of any registered installed app, not only configured shortcuts. Do not force a new instance; reuse a running copy unless applicationPath constrains the installation. Native acknowledgment is not a window-focus guarantee. Missing app is typed dependency absence; acknowledgment wait ends after three seconds or earlier cancellation, possibly after effects begin, with failed and no replay. The core request deadline may answer first. */
  workspaceLaunchApplication: Maybe<WorkspaceOpenResult>;
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


export type MutationWorkspaceLaunchApplicationArgs = {
  application: WorkspaceApplicationInput;
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

/** A registered application bundle present at inspection, even if in the Trash. Requires a bundle identifier; bundle-less programs have no named-selector route. No executable, argv, environment or shell input. */
export type WorkspaceApplicationInput = {
  /** Optional absolute path constraining selection to a registered bundle with this identifier, compared by native file identity after symlink resolution. Never substitute another copy when supplied; otherwise running-copy substitution is allowed. */
  applicationPath: InputMaybe<Scalars['String']['input']>;
  /** Nonblank native bundle identifier, not a display name or process identity. */
  bundleIdentifier: Scalars['String']['input'];
};

/** Pre-submission prerequisite failure; no successful value accompanies it. */
export type WorkspaceDependencyReason =
  | 'APPLICATION_IDENTITY_MISMATCH'
  | 'APPLICATION_NOT_INSTALLED'
  | 'NO_DEFAULT_HANDLER'
  | 'PATH_NOT_FOUND';

/** A failed prerequisite, under workspace:control AND desktop:control. Not a stale issued reference or execution error. */
export type WorkspaceDependencyUnavailable = {
  __typename?: 'WorkspaceDependencyUnavailable';
  /** Requires workspace:control AND desktop:control. Human explanation and recovery; never a shell command to execute automatically. */
  guidance: Scalars['String']['output'];
  /** Requires workspace:control AND desktop:control. Closed reason for not submitting this action. */
  reason: WorkspaceDependencyReason;
};

/** Native launch/open acknowledgment under workspace:control AND desktop:control, not proof of rendered content or foreground state. No installed path, bundle identifier or default-handler metadata is disclosed. */
export type WorkspaceOpenReceipt = {
  __typename?: 'WorkspaceOpenReceipt';
  /** Requires workspace:control AND desktop:control. Optional observation of the completion callback's application: stable positive PID, matching kernel start reads and executable file identity, equal native application object, non-terminated at the checks. Any unavailable value or mismatch yields null. Not atomic effect binding; never a PID-only, launch-date or foreground fallback. */
  process: Maybe<WorkspaceProcessIdentity>;
};

/** Requires workspace:control AND desktop:control throughout. Absent an error at or below this result, AVAILABLE has value only and DEPENDENCY_UNAVAILABLE has dependency only. A published status still describes the action when an error suppresses its branch; inspect data and error paths. */
export type WorkspaceOpenResult = {
  __typename?: 'WorkspaceOpenResult';
  /** Requires workspace:control AND desktop:control. Non-null exactly for DEPENDENCY_UNAVAILABLE absent an error at or below this result; this action submitted no domain request. */
  dependency: Maybe<WorkspaceDependencyUnavailable>;
  /** Requires workspace:control AND desktop:control. Selects the outcome; publication errors may suppress the selected branch or propagate through this result. */
  status: WorkspaceOperationStatus;
  /** Requires workspace:control AND desktop:control. Non-null exactly for AVAILABLE absent an error at or below this result. */
  value: Maybe<WorkspaceOpenReceipt>;
};

/** AVAILABLE is native acknowledgment; DEPENDENCY_UNAVAILABLE certifies this action submitted no domain request. Neither status overrides publication errors. */
export type WorkspaceOperationStatus =
  | 'AVAILABLE'
  | 'DEPENDENCY_UNAVAILABLE';

/** Observed process incarnation for this action, under workspace:control AND desktop:control. May exit immediately; not a desktop reference. */
export type WorkspaceProcessIdentity = {
  __typename?: 'WorkspaceProcessIdentity';
  /** Requires workspace:control AND desktop:control. Positive process identifier; use only with startedAt. */
  pid: Scalars['Int']['output'];
  /** Requires workspace:control AND desktop:control. Exact kernel process start instant, YYYY-MM-DDTHH:MM:SS.ffffffZ; copy with pid into the desktop process input under desktop:read. */
  startedAt: Scalars['String']['output'];
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

export type WorkspaceOpenOutcomeFragment = { __typename?: 'WorkspaceOpenResult', status: WorkspaceOperationStatus, value: { __typename?: 'WorkspaceOpenReceipt', process: { __typename?: 'WorkspaceProcessIdentity', pid: number, startedAt: string } | null } | null, dependency: { __typename?: 'WorkspaceDependencyUnavailable', reason: WorkspaceDependencyReason, guidance: string } | null };

export type LaunchInstalledApplicationMutationVariables = Exact<{
  application: WorkspaceApplicationInput;
}>;


export type LaunchInstalledApplicationMutation = { __typename?: 'Mutation', workspaceLaunchApplication: { __typename?: 'WorkspaceOpenResult', status: WorkspaceOperationStatus, value: { __typename?: 'WorkspaceOpenReceipt', process: { __typename?: 'WorkspaceProcessIdentity', pid: number, startedAt: string } | null } | null, dependency: { __typename?: 'WorkspaceDependencyUnavailable', reason: WorkspaceDependencyReason, guidance: string } | null } | null };

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
export const WorkspaceOpenOutcomeFragmentDoc = new TypedDocumentString(`
    fragment WorkspaceOpenOutcome on WorkspaceOpenResult {
  status
  value {
    process {
      pid
      startedAt
    }
  }
  dependency {
    reason
    guidance
  }
}
    `, {"fragmentName":"WorkspaceOpenOutcome"}) as unknown as TypedDocumentString<WorkspaceOpenOutcomeFragment, unknown>;
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
export const LaunchInstalledApplicationDocument = new TypedDocumentString(`
    mutation LaunchInstalledApplication($application: WorkspaceApplicationInput!) {
  workspaceLaunchApplication(application: $application) {
    ...WorkspaceOpenOutcome
  }
}
    fragment WorkspaceOpenOutcome on WorkspaceOpenResult {
  status
  value {
    process {
      pid
      startedAt
    }
  }
  dependency {
    reason
    guidance
  }
}`) as unknown as TypedDocumentString<LaunchInstalledApplicationMutation, LaunchInstalledApplicationMutationVariables>;