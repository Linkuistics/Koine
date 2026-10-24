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

export type KoineCapabilityDisclosure = {
  __typename?: 'KoineCapabilityDisclosure';
  /** The capability name, as listed in availableCapabilities and held by grants. */
  capability: Scalars['String']['output'];
  /** Plain text stating the capability's reach, including any other capability it needs. */
  disclosure: Scalars['String']['output'];
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
  /** What a person must be told about each capability's reach wherever it is granted or reviewed, one entry per capability that has a disclosure and whether or not its provider is active. Show it beside the capability in grant creation, request approval and the grant list. Serving it supplies no authority. */
  capabilityDisclosures: Array<KoineCapabilityDisclosure>;
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
  /** Requires workspace:control AND desktop:control. Launch or request reactivation of any registered installed app, not only configured shortcuts. Do not force a new instance; reuse a running copy unless applicationPath constrains the installation. Native acknowledgment is not a window-focus guarantee. Missing app is typed dependency absence; acknowledgment wait ends after three seconds or earlier cancellation, possibly after effects begin, with failed and no replay. The core request deadline may answer first. Koine resolves applicationPath and every registered copy it compares component by component, and copies compare by the device and inode that resolution finds. APPLICATION_NOT_INSTALLED keeps its meaning: no registration for the identifier, an applicationPath or unconstrained registered location that resolution finds missing, a present non-application, or a present constrained copy that is not registered; a whole-path ELOOP, ENAMETOOLONG or nil never establishes it, and a cycle or impossible name at an application location is failed. A constrained launch compares registered copies in order until one matches: one found missing or different is skipped; one whose resolution fails before the match is failed. A chosen or selected application location whose literal, link-expanded or resolved spelling is PATH_MAX (1,024) bytes or more, not counting its NUL, is failed before its metadata or any request: v1 does not hand such locations to applications. Link-budget exhaustion and unacquired native facts are failed. Established no-identifier remains mismatch for a named selector. */
  workspaceLaunchApplication: Maybe<WorkspaceOpenResult>;
  /** Requires workspace:control AND desktop:control. Open one literal absolute document/directory path in its default or named installed app. Refuse native application-bundle, Unix/Windows executable and Finder-alias metadata after symlink resolution; no content sandbox or race-free classification. Script/source documents can use default editors. A handler can execute scripts or follow location documents to other schemes/targets. No executable selector, argv, environment or shell expansion. Missing path/app/default handler is typed dependency absence; wait ends after three seconds or earlier cancellation, possibly after effects begin, with failed and no replay. The core deadline may answer first. Koine resolves the path first, then any applicationPath or discovered application, component by component. For the path, missing components, dangling links, established cycles and established impossible components are PATH_NOT_FOUND; an application location keeps APPLICATION_NOT_INSTALLED as for launch, and a stale default handler NO_DEFAULT_HANDLER. Link-budget exhaustion and other resolution errors are failed. An extant target, applicationPath or selected application whose literal, link-expanded or resolved spelling is PATH_MAX (1,024) bytes or more, not counting its NUL, is failed before any request: v1 does not hand such locations to applications. Each is refused at its own stage: a target before its metadata or handler lookup; an applicationPath before its metadata or registration lookup; a selected application (the matching registration, preferred copy or default handler) after the registration or handler lookup that found it, before its metadata. Below that limit, a nil default handler for a resolved target is NO_DEFAULT_HANDLER and a completed no-type report is not a refusal. Preserve target bytes and selected application identity. */
  workspaceOpenPath: Maybe<WorkspaceOpenResult>;
  /** Requires workspace:control AND desktop:control. Accept the ASCII RFC 3986 section 3 URI grammar, including optional query/fragment, with HTTP(S) scheme, host, valid percent escapes and no credentials/whitespace/backslashes/control characters; Unicode requires caller encoding and IDNA host labels. Preserve bytes without repair. Resolve by scheme alone and address that default browser explicitly; no universal-link app dispatch or suggestions proxy. The browser may act on the page. Missing handler is typed dependency absence; wait ends after three seconds or earlier cancellation, possibly after effects begin, with failed and no replay. The core deadline may answer first. */
  workspaceOpenURL: Maybe<WorkspaceOpenResult>;
  /** Requires workspace:control AND desktop:control. Reveal one literal absolute path in Finder without opening its contents. Native acknowledgment is not observed selection. Missing path/Finder is typed dependency absence; false acknowledgment or ambiguous failure is failed, never automatic replay. Wait ends after three seconds or earlier cancellation, ignoring late acknowledgment; the core deadline may answer first. Koine resolves the path component by component: missing components, dangling links, established cycles and established impossible components are PATH_NOT_FOUND; link-budget exhaustion and other resolution errors are failed. An extant location, or Finder's own, whose literal, link-expanded or resolved spelling is PATH_MAX (1,024) bytes or more, not counting its NUL, is failed before any Finder request. A link to the root, without a trailing slash, is selected as the link. Preserve submitted target bytes. */
  workspaceRevealPath: Maybe<WorkspaceRevealResult>;
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


export type MutationWorkspaceOpenPathArgs = {
  application: InputMaybe<WorkspaceApplicationInput>;
  path: Scalars['String']['input'];
};


export type MutationWorkspaceOpenUrlArgs = {
  url: Scalars['String']['input'];
};


export type MutationWorkspaceRevealPathArgs = {
  path: Scalars['String']['input'];
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
  /** Applications that the Spotlight index lists: one fixed query for application bundles over the Spotlight index with no search scope set, run once per call. Each choice has the path, display name and bundle identifier that the index reports, with source INDEXED_APPS. Copies of one identifier stay separate choices. Nothing is registered, resolved, launched or inspected, and the index can omit or lag applications, so a result is no inventory of the disk: category completeness is always UNKNOWN. An empty index answer is UNKNOWN with null items, never an empty inventory. A gathering that does not finish in three seconds, or one with more than 2048 items, is FAILED with null items and no prefix, and each selected items alias raises failed. Installation state, running state and bundle flags are not part of this release. All reachable fields require workspace:read. */
  workspaceApplications: Maybe<WorkspaceApplicationsResult>;
  /** Value-only Foundation lookup; null/omitted defaults to ten named pairs. Explicit nonempty unique requests <=10; HOME/Desktop/Documents/Downloads/Movies/Music/Pictures USER only; APPLICATIONS USER/LOCAL/SYSTEM. Never lists or inspects contents. All reachable fields require workspace:read. */
  workspaceSpecialLocations: Maybe<WorkspaceSpecialLocationsResult>;
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


export type QueryWorkspaceSpecialLocationsArgs = {
  requests: InputMaybe<Array<WorkspaceLocationRequest>>;
};

export type WorkspaceApplicationChoice = {
  __typename?: 'WorkspaceApplicationChoice';
  /** Absolute path of the bundle as the index reported it. It is not checked, resolved or opened, so it is not a bundle-directory identity and promises no installed or launchable application. Pass it with bundleIdentifier to workspaceLaunchApplication, which resolves it again. */
  applicationPath: Scalars['String']['output'];
  /** The bundle identifier that the index reports, or null when it reports none that Koine can pass on. */
  bundleIdentifier: Maybe<Scalars['String']['output']>;
  /** The localised display name that the index reports, or null when it reports none that Koine can pass on. Never taken from the path. */
  name: Maybe<Scalars['String']['output']>;
  sources: Array<WorkspaceDiscoverySource>;
};

/** A registered application bundle present at inspection, even if in the Trash. Requires a bundle identifier; bundle-less programs have no named-selector route. No executable, argv, environment or shell input. */
export type WorkspaceApplicationInput = {
  /** Optional absolute path constraining selection to a registered bundle with this identifier, compared by native file identity after symlink resolution. Never substitute another copy when supplied; otherwise running-copy substitution is allowed. */
  applicationPath: InputMaybe<Scalars['String']['input']>;
  /** Nonblank native bundle identifier, not a display name or process identity. */
  bundleIdentifier: Scalars['String']['input'];
};

export type WorkspaceApplicationsResult = {
  __typename?: 'WorkspaceApplicationsResult';
  items: Maybe<Array<WorkspaceApplicationChoice>>;
  resultsTruncated: Scalars['Boolean']['output'];
  sources: Array<WorkspaceDiscoveryCoverage>;
  status: WorkspaceDiscoveryStatus;
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

export type WorkspaceDiscoveryAvailability =
  | 'AVAILABLE'
  | 'BLOCKED'
  | 'UNAVAILABLE'
  | 'UNKNOWN';

export type WorkspaceDiscoveryCompleteness =
  | 'COMPLETE'
  | 'PARTIAL'
  | 'UNKNOWN';

export type WorkspaceDiscoveryConsent =
  | 'UNKNOWN';

export type WorkspaceDiscoveryCoverage = {
  __typename?: 'WorkspaceDiscoveryCoverage';
  availability: WorkspaceDiscoveryAvailability;
  /** UNKNOWN for app/settings inventory and filesystem contents of starting values. */
  category: WorkspaceDiscoveryCompleteness;
  declaredDomain: Scalars['String']['output'];
  diagnostics: Array<WorkspaceDiscoveryDiagnostic>;
  examined: Scalars['Int']['output'];
  /** Completeness of checked finite observations, not atomicity or internal health. */
  observations: WorkspaceDiscoveryCompleteness;
  source: WorkspaceDiscoverySource;
};

export type WorkspaceDiscoveryDiagnostic = {
  __typename?: 'WorkspaceDiscoveryDiagnostic';
  affectsCoverage: Scalars['Boolean']['output'];
  guidance: Scalars['String']['output'];
  permission: Maybe<WorkspaceDiscoveryPermissionHint>;
  reason: WorkspaceDiscoveryReason;
  source: WorkspaceDiscoverySource;
  /** Only an independently identified location/pane; never parsed from error text. */
  subject: Maybe<Scalars['String']['output']>;
};

export type WorkspaceDiscoveryPermission =
  | 'AUTOMATION'
  | 'PROMPT_RISK';

export type WorkspaceDiscoveryPermissionHint = {
  __typename?: 'WorkspaceDiscoveryPermissionHint';
  consent: WorkspaceDiscoveryConsent;
  event: Maybe<WorkspaceSettingsEvent>;
  permission: WorkspaceDiscoveryPermission;
  /** Fixed target com.apple.systempreferences for Automation; established target or declared source otherwise. */
  target: Scalars['String']['output'];
};

export type WorkspaceDiscoveryReason =
  | 'CALL_LIMIT'
  | 'CAPACITY_LIMIT'
  | 'CHANGED_DURING_DISCOVERY'
  | 'DIAGNOSTIC_LIMIT'
  | 'ENTRY_LIMIT'
  | 'INSPECTION_FAILED'
  | 'METADATA_UNKNOWN'
  | 'NO_NATIVE_VALUE'
  | 'PROMPT_RISK'
  | 'SETUP_UNSUPPORTED'
  | 'SOURCE_UNAVAILABLE'
  | 'TARGET_CHANGED'
  | 'TARGET_NOT_RUNNING'
  | 'TIME_LIMIT'
  | 'UNREPRESENTABLE_VALUE'
  | 'VALUE_LIMIT';

export type WorkspaceDiscoverySource =
  | 'FOUNDATION_LOCATIONS'
  | 'INDEXED_APPS'
  | 'REGISTRATION'
  | 'RUNNING_APPS'
  | 'SETTINGS_RUNTIME';

/** Inspect sources, uncertainty and independent GraphQL errors together. */
export type WorkspaceDiscoveryStatus =
  | 'AVAILABLE'
  | 'BLOCKED'
  | 'FAILED'
  | 'PARTIAL'
  | 'UNAVAILABLE'
  | 'UNKNOWN';

export type WorkspaceLocationDomain =
  | 'LOCAL'
  | 'SYSTEM'
  | 'USER';

export type WorkspaceLocationKind =
  | 'APPLICATIONS'
  | 'DESKTOP'
  | 'DOCUMENTS'
  | 'DOWNLOADS'
  | 'HOME'
  | 'MOVIES'
  | 'MUSIC'
  | 'PICTURES';

export type WorkspaceLocationRequest = {
  domain: WorkspaceLocationDomain;
  kind: WorkspaceLocationKind;
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

/** Finder acknowledgment under workspace:control AND desktop:control; selection is not independently observed. */
export type WorkspaceRevealReceipt = {
  __typename?: 'WorkspaceRevealReceipt';
  /** Requires workspace:control AND desktop:control. Submitted absolute path; a directory is selected in its parent, and root is shown as a root view. */
  path: Scalars['String']['output'];
};

/** Requires workspace:control AND desktop:control throughout. Absent an error at or below this result, AVAILABLE has value only and DEPENDENCY_UNAVAILABLE has dependency only. A published status still describes the action when an error suppresses its branch; inspect data and error paths. */
export type WorkspaceRevealResult = {
  __typename?: 'WorkspaceRevealResult';
  /** Requires workspace:control AND desktop:control. Non-null exactly for DEPENDENCY_UNAVAILABLE absent an error at or below this result; this action submitted no domain request. */
  dependency: Maybe<WorkspaceDependencyUnavailable>;
  /** Requires workspace:control AND desktop:control. Selects the outcome; publication errors may suppress the selected branch or propagate through this result. */
  status: WorkspaceOperationStatus;
  /** Requires workspace:control AND desktop:control. Non-null exactly for AVAILABLE absent an error at or below this result. */
  value: Maybe<WorkspaceRevealReceipt>;
};

export type WorkspaceSettingsEvent =
  | 'READ'
  | 'REVEAL';

export type WorkspaceSpecialLocation = {
  __typename?: 'WorkspaceSpecialLocation';
  /** UID of Koine's account, not the client's account. */
  accountIdentifier: Scalars['String']['output'];
  contentsAvailability: WorkspaceDiscoveryAvailability;
  domain: WorkspaceLocationDomain;
  kind: WorkspaceLocationKind;
  /** OS-known absolute local value; no existence, access, listing or consent guarantee. */
  location: Scalars['String']['output'];
  sources: Array<WorkspaceDiscoverySource>;
};

export type WorkspaceSpecialLocationsResult = {
  __typename?: 'WorkspaceSpecialLocationsResult';
  /** Frozen list for AVAILABLE/PARTIAL; otherwise null. FAILED raises failed at each selected items alias; BLOCKED/UNAVAILABLE/UNKNOWN give ordinary null. */
  items: Maybe<Array<WorkspaceSpecialLocation>>;
  resultsTruncated: Scalars['Boolean']['output'];
  sources: Array<WorkspaceDiscoveryCoverage>;
  status: WorkspaceDiscoveryStatus;
};

export type DiscoveryCoverageFragment = { __typename?: 'WorkspaceDiscoveryCoverage', source: WorkspaceDiscoverySource, declaredDomain: string, availability: WorkspaceDiscoveryAvailability, observations: WorkspaceDiscoveryCompleteness, category: WorkspaceDiscoveryCompleteness, examined: number, diagnostics: Array<{ __typename?: 'WorkspaceDiscoveryDiagnostic', source: WorkspaceDiscoverySource, reason: WorkspaceDiscoveryReason, subject: string | null, affectsCoverage: boolean, guidance: string, permission: { __typename?: 'WorkspaceDiscoveryPermissionHint', permission: WorkspaceDiscoveryPermission, target: string, event: WorkspaceSettingsEvent | null, consent: WorkspaceDiscoveryConsent } | null }> };

export type NativeStartingLocationsQueryVariables = Exact<{
  requests: InputMaybe<Array<WorkspaceLocationRequest> | WorkspaceLocationRequest>;
}>;


export type NativeStartingLocationsQuery = { __typename?: 'Query', locations: { __typename?: 'WorkspaceSpecialLocationsResult', status: WorkspaceDiscoveryStatus, resultsTruncated: boolean, items: Array<{ __typename?: 'WorkspaceSpecialLocation', kind: WorkspaceLocationKind, domain: WorkspaceLocationDomain, accountIdentifier: string, location: string, contentsAvailability: WorkspaceDiscoveryAvailability, sources: Array<WorkspaceDiscoverySource> }> | null, sources: Array<{ __typename?: 'WorkspaceDiscoveryCoverage', source: WorkspaceDiscoverySource, declaredDomain: string, availability: WorkspaceDiscoveryAvailability, observations: WorkspaceDiscoveryCompleteness, category: WorkspaceDiscoveryCompleteness, examined: number, diagnostics: Array<{ __typename?: 'WorkspaceDiscoveryDiagnostic', source: WorkspaceDiscoverySource, reason: WorkspaceDiscoveryReason, subject: string | null, affectsCoverage: boolean, guidance: string, permission: { __typename?: 'WorkspaceDiscoveryPermissionHint', permission: WorkspaceDiscoveryPermission, target: string, event: WorkspaceSettingsEvent | null, consent: WorkspaceDiscoveryConsent } | null }> }> } | null };

export type NativeApplicationsQueryVariables = Exact<{ [key: string]: never; }>;


export type NativeApplicationsQuery = { __typename?: 'Query', apps: { __typename?: 'WorkspaceApplicationsResult', status: WorkspaceDiscoveryStatus, resultsTruncated: boolean, items: Array<{ __typename?: 'WorkspaceApplicationChoice', name: string | null, applicationPath: string, bundleIdentifier: string | null, sources: Array<WorkspaceDiscoverySource> }> | null, sources: Array<{ __typename?: 'WorkspaceDiscoveryCoverage', source: WorkspaceDiscoverySource, declaredDomain: string, availability: WorkspaceDiscoveryAvailability, observations: WorkspaceDiscoveryCompleteness, category: WorkspaceDiscoveryCompleteness, examined: number, diagnostics: Array<{ __typename?: 'WorkspaceDiscoveryDiagnostic', source: WorkspaceDiscoverySource, reason: WorkspaceDiscoveryReason, subject: string | null, affectsCoverage: boolean, guidance: string, permission: { __typename?: 'WorkspaceDiscoveryPermissionHint', permission: WorkspaceDiscoveryPermission, target: string, event: WorkspaceSettingsEvent | null, consent: WorkspaceDiscoveryConsent } | null }> }> } | null };

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

export type OpenSearchUrlMutationVariables = Exact<{
  url: Scalars['String']['input'];
}>;


export type OpenSearchUrlMutation = { __typename?: 'Mutation', workspaceOpenURL: { __typename?: 'WorkspaceOpenResult', status: WorkspaceOperationStatus, value: { __typename?: 'WorkspaceOpenReceipt', process: { __typename?: 'WorkspaceProcessIdentity', pid: number, startedAt: string } | null } | null, dependency: { __typename?: 'WorkspaceDependencyUnavailable', reason: WorkspaceDependencyReason, guidance: string } | null } | null };

export type OpenDocumentOrDirectoryMutationVariables = Exact<{
  path: Scalars['String']['input'];
  application: InputMaybe<WorkspaceApplicationInput>;
}>;


export type OpenDocumentOrDirectoryMutation = { __typename?: 'Mutation', workspaceOpenPath: { __typename?: 'WorkspaceOpenResult', status: WorkspaceOperationStatus, value: { __typename?: 'WorkspaceOpenReceipt', process: { __typename?: 'WorkspaceProcessIdentity', pid: number, startedAt: string } | null } | null, dependency: { __typename?: 'WorkspaceDependencyUnavailable', reason: WorkspaceDependencyReason, guidance: string } | null } | null };

export type RevealPathMutationVariables = Exact<{
  path: Scalars['String']['input'];
}>;


export type RevealPathMutation = { __typename?: 'Mutation', workspaceRevealPath: { __typename?: 'WorkspaceRevealResult', status: WorkspaceOperationStatus, value: { __typename?: 'WorkspaceRevealReceipt', path: string } | null, dependency: { __typename?: 'WorkspaceDependencyUnavailable', reason: WorkspaceDependencyReason, guidance: string } | null } | null };

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
export const DiscoveryCoverageFragmentDoc = new TypedDocumentString(`
    fragment DiscoveryCoverage on WorkspaceDiscoveryCoverage {
  source
  declaredDomain
  availability
  observations
  category
  examined
  diagnostics {
    source
    reason
    subject
    affectsCoverage
    guidance
    permission {
      permission
      target
      event
      consent
    }
  }
}
    `, {"fragmentName":"DiscoveryCoverage"}) as unknown as TypedDocumentString<DiscoveryCoverageFragment, unknown>;
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
export const NativeStartingLocationsDocument = new TypedDocumentString(`
    query NativeStartingLocations($requests: [WorkspaceLocationRequest!]) {
  locations: workspaceSpecialLocations(requests: $requests) {
    status
    items {
      kind
      domain
      accountIdentifier
      location
      contentsAvailability
      sources
    }
    sources {
      ...DiscoveryCoverage
    }
    resultsTruncated
  }
}
    fragment DiscoveryCoverage on WorkspaceDiscoveryCoverage {
  source
  declaredDomain
  availability
  observations
  category
  examined
  diagnostics {
    source
    reason
    subject
    affectsCoverage
    guidance
    permission {
      permission
      target
      event
      consent
    }
  }
}`) as unknown as TypedDocumentString<NativeStartingLocationsQuery, NativeStartingLocationsQueryVariables>;
export const NativeApplicationsDocument = new TypedDocumentString(`
    query NativeApplications {
  apps: workspaceApplications {
    status
    items {
      name
      applicationPath
      bundleIdentifier
      sources
    }
    sources {
      ...DiscoveryCoverage
    }
    resultsTruncated
  }
}
    fragment DiscoveryCoverage on WorkspaceDiscoveryCoverage {
  source
  declaredDomain
  availability
  observations
  category
  examined
  diagnostics {
    source
    reason
    subject
    affectsCoverage
    guidance
    permission {
      permission
      target
      event
      consent
    }
  }
}`) as unknown as TypedDocumentString<NativeApplicationsQuery, NativeApplicationsQueryVariables>;
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
export const OpenSearchUrlDocument = new TypedDocumentString(`
    mutation OpenSearchURL($url: String!) {
  workspaceOpenURL(url: $url) {
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
}`) as unknown as TypedDocumentString<OpenSearchUrlMutation, OpenSearchUrlMutationVariables>;
export const OpenDocumentOrDirectoryDocument = new TypedDocumentString(`
    mutation OpenDocumentOrDirectory($path: String!, $application: WorkspaceApplicationInput) {
  workspaceOpenPath(path: $path, application: $application) {
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
}`) as unknown as TypedDocumentString<OpenDocumentOrDirectoryMutation, OpenDocumentOrDirectoryMutationVariables>;
export const RevealPathDocument = new TypedDocumentString(`
    mutation RevealPath($path: String!) {
  workspaceRevealPath(path: $path) {
    status
    value {
      path
    }
    dependency {
      reason
      guidance
    }
  }
}
    `) as unknown as TypedDocumentString<RevealPathMutation, RevealPathMutationVariables>;