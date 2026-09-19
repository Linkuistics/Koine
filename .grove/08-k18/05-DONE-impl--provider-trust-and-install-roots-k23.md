# provider-trust-and-install-roots-k23

## Goal

Admit provider bundles only from Koine-owned roots and only with an approval
record, verify signatures before any code loads, and wire the resident
application to its roots.

## Context

- Spec: "Loading and trust".
- The three decisions the human made in `native-provider-contribution-k8`, in
  the stage brief's notes. They bind this leaf.
- Read `loader-compatibility-checks-and-status-k22`'s commit for the
  pre-`dlopen` sequence and the status machinery.

## Done when

- The loader reads two roots supplied by the host, never the current directory
  or a client-supplied path: a root sealed inside the application bundle, and a
  per-user installed root under Koine's data location. It resolves each
  bundle's canonical location and refuses one that escapes its root.
- A bundle is staged as an immutable versioned copy before verification and
  loading, so an update cannot race the check.
- Before `dlopen`, the loader verifies the bundle's code signature, and that of
  its private dependencies, against the approval record for its provider ID. An
  in-application bundle's record is built in: its provider ID and Koine's own
  Team ID. A per-user bundle's record is a documented file the user places;
  Koine writes no such record itself and has no UI or GraphQL operation for it.
  An unapproved bundle, an unsigned or ad-hoc signed bundle, a bundle signed by
  another identity, and an update whose identity differs from its record are
  each `REJECTED` with a diagnostic, and a test shows no initializer ran.
  Koine never strips quarantine or disables a signing check to make one load.
- The resident application passes its roots to the server. It ships no
  provider yet; the in-application root is present and empty until
  `desktop-path-k9`. `App/Koine.entitlements` stays empty.
- `docs/specs/machine.md` states the three decisions where they apply: one
  loader for the bundled provider, the approval record without an install UI,
  and that independently signed third-party providers are not loadable until a
  later increment adds the library-validation entitlement with its own
  signed-build verification. Reconcile the ADR set if a decision clears its bar.
- The README documents the per-user root, the approval-record file and how a
  first-party provider is installed or upgraded.

## Notes

The mismatched-identity case needs no second Developer ID certificate: an
ad-hoc signed fixture is a different identity. Signature verification works in
an unsigned test process; what a test process cannot show is library validation
in the hardened runtime, which `signed-app-provider-vm-verification-k25` owns.

The install and approve UI is a later increment outside this stage. If it can
be stated precisely when this leaf ends, say so in the stage brief's horizon
rather than building any of it.

## Decisions (running log)

- **A provider bundle is a shallow code-signing bundle.** `codesign` refuses a
  directory with no `Info.plist` ("bundle format unrecognized"); with an
  `Info.plist` at the bundle's root naming the dylib as `CFBundleExecutable`,
  one signature seals the dylib, `manifest.json` and `schema.graphql`. This
  keeps k22's flat layout, and the manifest that names the provider ID the
  approval is keyed on is authenticated, not only the binary. Tried in the
  scratchpad: sealing, the Team ID requirement, and tamper detection all work.
- **The signing identity in an approval record is a Team ID**, checked as the
  code requirement `anchor apple generic and certificate leaf[subject.OU] =
  "<team>"`. An ad-hoc or unsigned bundle cannot satisfy it. The Team ID is
  validated (ten upper-case alphanumerics) before it enters a requirement
  string.
- **Approval record location.** `<root>/<providerId>.approval.json` in the
  per-user root, `{"providerId", "teamIdentifier"}`. The bundled root takes its
  records from the host, never from a file.
- **Staging is content-addressed**: `<staging>/<bundle name>-<sha256 prefix>`,
  read-only. The digest is the version, so a malformed manifest still stages,
  an unchanged bundle reuses its copy (and its dyld image path, which k22's
  same-image rule needs), and an update can never overwrite a copy in use. The
  signature is verified on the staged copy every start, so reuse trusts nothing.
  Superseded copies are not pruned: two servers may share a staging directory
  (the tests do), and a copy costs one bundle per upgrade.
- **Every image in the validated dependency closure is verified individually**
  against the same requirement, as well as the bundle seal: a nested image is
  sealed by hash, which says who sealed it, not who signed it.
- **Roots are a `ProviderRoot` value, not a URL**: `.bundled(url, approvals:)`
  or `.installed(url)`. Where a root's approvals come from is part of what the
  host says about it, so a file in the bundled root can never approve anything.
  A root that does not exist holds no bundles (the per-user root is the user's
  to create; the sealed one may lose its empty directory in transit).
- **The in-application root is `Contents/PlugIns`**, the platform's place for
  loadable bundles (`Bundle.builtInPlugInsURL`). Its approvals pair a list of
  shipped provider IDs in `AppDelegate` with the Team ID of the process's own
  signature, so `KOINE_SIGNING_IDENTITY` keeps working and an unsigned
  development run approves nothing.
- **Signature verification must not run on the Swift concurrency pool in
  bulk.** `SecStaticCodeCheckValidity` blocks on work it dispatches; with every
  pool thread a test blocked there, the suite hung (sampled: all sixteen
  cooperative threads in `Security::Dispatch::Group::wait`). The application
  constructs the server on the main thread; the tests construct it through
  `offPool`. Stated on `KoineServer.init`.
- **k22's `library-outside-bundle` variant now escapes through `/`**: checks run
  on the staged copy, where its old relative path led nowhere.
- **ADR.** "One loader" is added to `koine-server-and-native-providers` with its
  rejected alternative: hard to reverse, surprising, a real trade-off. The
  approval record and the missing entitlement are version-1 limits a later
  increment lifts, so they are stated in the spec only.
- **The leaf's one in-session review was spent on the trust path** (a fresh
  context asked to break staging, approval and signature checking). It found no
  way for unapproved code to reach `dlopen`. Applied, all mechanical: two images
  of the host's architecture in one file are refused; the bundled-framework
  check compares names without case and fails closed; a staged copy must be a
  directory, not a link; the digest carries the executable bit; the process's
  own Team ID is read only from a signature that still validates. Accepted
  trade-offs, not changed: the approval record sits beside the bundle (the
  human's decision; the install UI is where approval becomes the user's act);
  revocation is not checked (it needs the network at every start) and any
  Apple-issued certificate of the Team ID satisfies a record, since the record
  names a team; a named system library need not exist on disk (the dyld shared
  cache holds them, and the hardened `Koine.app` has no fallback paths);
  leftover staged copies.
