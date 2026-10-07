#!/bin/bash
# Enumerates the native primitives, parameters, preparation, fallback and cleanup
# calls of the workspace provider's launch, URL, path and reveal paths, from its source and from the
# built bundle's own imports, and checks them against the authority trace: the
# launch path makes ONE launch request, NSWorkspace.openApplication(at:configuration:),
# with activation on as the trace declares (workspace:control AND desktop:control);
# the URL path makes ONE open request, NSWorkspace.open(_:withApplicationAt:configuration:),
# to an application it resolved itself, from a handler lookup that is given the scheme
# alone (never a part of the submitted URL), with the same configuration; the path root
# makes the same single open request, to the default application of the item as the
# system's file lookup answers it or to the named installation, resolves the item by that
# same walk and applies the same limit first, and reads its metadata only from the resolved
# spelling and only through metadata calls; the reveal root first resolves the caller's location by the
# descriptor walk (search-only single-component calls, no whole-path call, nothing listed or
# opened) and applies the application hand-off limit before any whole-path call addresses
# the location (and every application the provider discovers itself, a preferred copy, a default handler, the default
# browser and Finder, is resolved by the same walk and limited before its bundle is read from the resolved
# spelling, with no whole-path inspection of a registered location left), then makes ONE Finder selection request,
# NSWorkspace.selectFile(_:inFileViewerRootedAtPath:), in its two documented forms (an item,
# or the filesystem root as a root view), from a background queue, and nothing else; and no
# activation, hiding, raising, accessibility, event-posting, scripting or
# process-spawning call beside them. A focus change seen in a VM proves neither the
# presence nor the absence of a hidden call (docs/specs/workflow-providers.md,
# "Native call-path inspection"); this is the inspection that does.
# The recorded result: docs/verification/launch-vm.md
#
# usage: check-launch-call-path.sh [bundle]   (default: .build/app/Koine.app)
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
BUNDLE="${1:-${APP_BUNDLE}}"
SOURCES=(Providers/WorkspaceProvider/Logic Providers/WorkspaceProvider/Sources)
LIBRARY="${BUNDLE}/Contents/PlugIns/Workspace.koineprovider/libWorkspaceProvider.dylib"
[ -f "${LIBRARY}" ] || { echo "Error: ${LIBRARY} does not exist. Run: task app" >&2; exit 1; }

fail() { echo "FAILED: $*" >&2; exit 1; }

# What no launch path may contain: a Koine-selected effect the trace does not
# declare. Source patterns and, for the bundle, the Objective-C selectors and
# imported symbols they would compile to.
FORBIDDEN_SOURCE='\.activate\(|activate\(from|\.hide\(|\.unhide\(|hideOtherApplications|\.raise|AXUIElement|AXIsProcess|CGEvent|CGWindow|NSAppleScript|NSAppleEventDescriptor|Process\(\)|posix_spawn|\bsystem\(|\.terminate\(|\.forceTerminate|open(URL|URLs|File)\(|activateIgnoringOtherApps|NSWorkspace\.shared\.launchApplication|showFile|activateFileViewerSelecting|urlsForApplications\(toOpen|LSCopyDefault|requiresUniversalLinks|setDefaultApplication'
FORBIDDEN_BINARY='^(URLsForApplicationsToOpenURL:|setRequiresUniversalLinks:|setDefaultApplicationAtURL:[A-Za-z:]*|activateWithOptions:|activateFromApplication:|activateIgnoringOtherApps:|activate|hideOtherApplications|unhide|unhideAllApplications|terminate|forceTerminate|launchApplication:|openURL:|openURLs:|openFile:|activateFileViewerSelectingURLs:|_AX[A-Za-z]*|_CGEvent[A-Za-z]*|_CGWindow[A-Za-z]*|_kill|_posix_spawn[a-z_]*|_execv[a-z]*|_system)$'

# Every pattern is first seen to match something it must, or a clean read below
# would be the same observation as a broken instrument.
CONTROL="$(mktemp)"
trap 'rm -f "${CONTROL}"' EXIT
printf 'NSRunningApplication.current.activate()\nlet e = AXUIElementCreateSystemWide()\nCGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)\nNSWorkspace.shared.urlsForApplications(toOpen: u)\nconfiguration.requiresUniversalLinks = true\n' >"${CONTROL}"
[ "$(grep -c -E "${FORBIDDEN_SOURCE}" "${CONTROL}")" = 5 ] || fail "the source pattern does not match the control it must"
printf 'activateWithOptions:\n_AXUIElementCreateSystemWide\n_CGEventPost\nterminated\nURLsForApplicationsToOpenURL:\nsetRequiresUniversalLinks:\n' | grep -c -E "${FORBIDDEN_BINARY}" | grep -qx 5 ||
    fail "the binary pattern does not match the control it must"

echo "== Source: the native calls of the launch path"
grep -rn -E 'NSWorkspace|NSRunningApplication|OpenConfiguration|configuration\.' "${SOURCES[@]}" | grep -v -E '^\S+:[0-9]+:\s*(///|//)' || true

echo
echo "== Source: exactly one launch request, and the parameters it carries"
REQUESTS="$(grep -rn -E 'NSWorkspace\.shared\.openApplication\(' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${REQUESTS}"
[ "$(grep -c . <<<"${REQUESTS}")" = 1 ] || fail "the launch path does not make exactly one openApplication request"
for setting in \
    'activates = true' 'createsNewApplicationInstance = false' 'hides = false' 'hidesOthers = false' \
    'isForPrinting = false' 'promptsUserIfNeeded = false' 'arguments = \[\]' 'environment = \[:\]' 'appleEvent = nil' \
    'allowsRunningApplicationSubstitution = substitutingRunningCopy'; do
    grep -rq -E "configuration\.${setting}" "${SOURCES[@]}" || fail "the request no longer sets ${setting}"
done
[ "$(grep -rho -E 'configuration\.[A-Za-z]+ =' "${SOURCES[@]}" | sort -u | wc -l | tr -d ' ')" = 10 ] ||
    fail "the request sets a parameter this check does not name"

echo
echo "== Source: exactly one open request (a URL or a path), to an application resolved beforehand"
OPENS="$(grep -rn -E 'NSWorkspace\.shared\.open\(' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${OPENS}"
[ "$(grep -c . <<<"${OPENS}")" = 1 ] || fail "the URL and path roots do not share exactly one open request"
grep -q -E 'open\(\[url\], withApplicationAt: application, configuration: configuration\)' <<<"${OPENS}" ||
    fail "the URL open request is not addressed to an explicit application with the shared configuration"
[ "$(grep -rc -E 'openConfiguration\(substitutingRunningCopy:' "${SOURCES[@]}" | awk -F: '{s+=$2} END {print s}')" -ge 3 ] ||
    fail "the launch and URL requests no longer take their configuration from the one helper"

echo
echo "== Source: the default handler is looked up by the scheme alone, or for the item being opened"
LOOKUPS="$(grep -rn -E 'urlForApplication\(toOpen:' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${LOOKUPS}"
[ "$(grep -c . <<<"${LOOKUPS}")" = 2 ] || fail "handler discovery is not exactly two lookups: a scheme and an item"
grep -q 'urlForApplication(toOpen: schemeOnly)' <<<"${LOOKUPS}" || fail "the web lookup is not given the scheme-only URL"
grep -q 'urlForApplication(toOpen: url)' <<<"${LOOKUPS}" || fail "the item lookup is not given the item's own URL"
SCHEME_ONLY="$(grep -rn -E 'schemeOnly = ' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${SCHEME_ONLY}"
grep -q -F 'URL(string: "\(scheme.rawValue):")' <<<"${SCHEME_ONLY}" || fail "the scheme-only URL is built from more than the scheme"
[ "$(grep -c . <<<"${SCHEME_ONLY}")" = 1 ] || fail "more than one URL is built for a scheme lookup"
# The item lookup's argument is the file URL the provider built from a validated local path.
ITEM_LOOKUP_FUNCTION="$(grep -n -E 'func defaultApplication\(toOpen url: URL\)' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift || true)"
[ "$(grep -c . <<<"${ITEM_LOOKUP_FUNCTION}")" = 1 ] || fail "the item lookup is not one function taking a URL"
grep -rq -E 'URL\(fileURLWithPath: path\.text, isDirectory: facts\.isDirectory\)' "${SOURCES[@]}" ||
    fail "the item URL is no longer built from the validated local path"

echo
echo "== Source: the item is inspected only through the calls the metadata probe measured prompt-free"
# The item's own metadata is read from the resolved spelling's bytes. No whole-path stat or realpath addresses the
# caller's item: the walk found it, and the limit passed it, before this read.
READ_FACTS="$(awk '/func readPathFacts\(of location: ResolvedLocation\)/ {on=1} on {print} on && /^    }$/ {exit}' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift)"
echo "${READ_FACTS}"
[ -n "${READ_FACTS}" ] || fail "the item's metadata read is not one native function"
# Both metadata reads (the item's and a supplied application's) build their URL by the one helper, from the resolved bytes.
FILE_SYSTEM_URL="$(awk '/private func fileSystemURL\(of location: ResolvedLocation\)/ {on=1} on {print} on && /^    }$/ {exit}' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift)"
echo "${FILE_SYSTEM_URL}"
grep -q -F 'location.resolved.bytes' <<<"${FILE_SYSTEM_URL}" || fail "the metadata URL is not built from the resolved spelling's bytes"
if grep -E 'location\.literal|realpath\(|l?stat\(|path\.text' <<<"${FILE_SYSTEM_URL}" | grep -v -E '^\s*//'; then
    fail "the metadata URL addresses the caller's spelling or makes a whole-path call"
fi
grep -q -F 'fileSystemURL(of: location)' <<<"${READ_FACTS}" || fail "the item's metadata is not read from the resolved spelling's URL"
if grep -E 'location\.literal|realpath\(|l?stat\(|path\.text' <<<"${READ_FACTS}" | grep -v -E '^\s*//'; then
    fail "the item's metadata read addresses the caller's spelling or makes a whole-path call"
fi
INSPECTION="$(grep -E 'resourceValues\(forKeys' <<<"${READ_FACTS}" | grep -v -E '^\s*//' || true)"
echo "${INSPECTION}"
grep -q 'forKeys: \[.isApplicationKey, .contentTypeKey, .isAliasFileKey\]' <<<"${INSPECTION}" || fail "the item's resource keys are not the measured three"
if grep -rn -E 'contentsOfDirectory|enumerator\(|contents\(atPath|Data\(contentsOf|String\(contentsOf|FileHandle|fopen\(|open\(path|opendir|readdir' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the workspace provider reads a directory or a file's contents"
fi
echo "none read"

echo
echo "== Source: a reveal resolves its target by the descriptor walk, and the hand-off limit comes before any whole-path call"
WALK=Providers/WorkspaceProvider/Logic/LocationWalk.swift
REVEAL=Providers/WorkspaceProvider/Logic/RevealPath.swift
# What the walk may not call: a whole-path or listing or content call. Seen first to match what it must.
# (An empty argument list is the `stat()` struct initializer, not a call.)
WHOLE_PATH='(^|[^A-Za-z_.])(stat|lstat|realpath|open|opendir|readdir|readlink|access|fopen|mkdir|unlink)\([^)]'
printf 'let s = stat(path, &b)\nrealpath(path, nil)\nopen(path, O_RDONLY)\nopendir(p)\nreaddir(d)\nreadlink(p, &b, 9)\n' >"${CONTROL}"
[ "$(grep -c -E "${WHOLE_PATH}" "${CONTROL}")" = 6 ] || fail "the whole-path pattern does not match the control it must"
if grep -n -E "${WHOLE_PATH}" "${WALK}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the walk makes a whole-path, listing or content call"
fi
echo "the walk's calls:"
grep -o -E '(openat|fstatat|fstat|readlinkat|fpathconf|Darwin\.close)\(' "${WALK}" | sort | uniq -c
for call in 'openat(' 'fstatat(' 'fstat(' 'readlinkat(' 'fpathconf('; do
    grep -q -F "${call}" "${WALK}" || fail "the walk no longer makes ${call}"
done
grep -q -E 'private static let searchOnly = O_SEARCH' "${WALK}" || fail "the walk's handles are not search-only (O_SEARCH)"
if grep -n -E 'O_RDONLY|O_WRONLY|O_RDWR|O_CREAT|O_TRUNC|O_NOFOLLOW' "${WALK}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the walk opens with a read, write or create mode"
fi
echo "search-only handles; no read, write or create mode"
[ "$(grep -c -E 'AT_SYMLINK_NOFOLLOW' "${WALK}")" -ge 1 ] || fail "the walk does not examine an entry without following its link"
[ "$(grep -c -E 'func resolveLocation\(_ path: String\) -> LocationResolution \{ LocationWalk\.resolve\(path\) \}' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift)" = 1 ] ||
    fail "the adapter's resolution is not the walk and nothing else"
# The planner's order: the target stage (resolve, then the limit, checked below in the stage itself), then the one
# whole-path call (the root rule's lstat), then Finder.
line() { grep -n -F "$1" "${REVEAL}" | head -1 | cut -d: -f1; }
SETTLE_REVEAL="$(line 'settleTarget(path, unaccomplished: "revealed", native: native)')"
ROOT="$(line 'native.isFilesystemRoot(literalPath: path.text)')"
FINDER="$(line 'selectInstallation(finder, forAction: "revealed", native: native)')"
for found in "${SETTLE_REVEAL}" "${ROOT}" "${FINDER}"; do [ -n "${found}" ] || fail "the reveal planner no longer has one of the target stage, root decision, Finder"; done
[ "${SETTLE_REVEAL}" -lt "${ROOT}" ] && [ "${ROOT}" -lt "${FINDER}" ] ||
    fail "the reveal planner's order is not target stage, root decision, Finder"
echo "reveal planner order: target stage (line ${SETTLE_REVEAL}), root decision (${ROOT}), Finder (${FINDER})"
if grep -n -E 'readPathFacts|realpath|resourceValues|\.path\b' "${REVEAL}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the reveal planner addresses the caller's location by a call the limit does not precede"
fi
echo "the reveal planner makes no other path call"
# The target stage both operations share: the walk, then the limit, in that order, before anything else.
TARGET=Providers/WorkspaceProvider/Logic/TargetStage.swift
line_in() { grep -n -F "$2" "$1" | head -1 | cut -d: -f1; }
STAGE_RESOLVE="$(line_in "${TARGET}" 'native.resolveLocation(path.text)')"
STAGE_LIMIT="$(line_in "${TARGET}" 'HandOffLimit.refusal(')"
[ -n "${STAGE_RESOLVE}" ] && [ -n "${STAGE_LIMIT}" ] && [ "${STAGE_RESOLVE}" -lt "${STAGE_LIMIT}" ] ||
    fail "the target stage's order is not resolve, then limit"
if grep -n -E 'readPathFacts|realpath|stat\(|resourceValues|\.path\b' "${TARGET}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the target stage makes a path call of its own"
fi
echo "target stage order: resolve (line ${STAGE_RESOLVE}), limit (${STAGE_LIMIT})"
echo
echo "== Source: an open settles its target by that stage, then reads the resolved object's metadata, then the payload policy, then the handler"
OPEN=Providers/WorkspaceProvider/Logic/OpenPath.swift
SETTLE="$(line_in "${OPEN}" 'settleTarget(path, unaccomplished: "opened", native: native)')"
FACTS="$(line_in "${OPEN}" 'native.readPathFacts(of: location)')"
POLICY="$(line_in "${OPEN}" 'refusalReason(for: facts, native: native)')"
HANDLER="$(line_in "${OPEN}" 'selectPathHandler(target, native: native)')"
INSTALLATION="$(line_in "${OPEN}" 'selectInstallation(application, forAction: "opened", native: native)')"
for found in "${SETTLE}" "${FACTS}" "${POLICY}" "${HANDLER}" "${INSTALLATION}"; do
    [ -n "${found}" ] || fail "the open planner no longer has one of target stage, metadata read, payload policy, handler, installation"
done
[ "${SETTLE}" -lt "${FACTS}" ] && [ "${FACTS}" -lt "${POLICY}" ] && [ "${POLICY}" -lt "${INSTALLATION}" ] && [ "${POLICY}" -lt "${HANDLER}" ] ||
    fail "the open planner's order is not target stage, metadata, payload policy, then the application"
echo "open planner order: target stage (line ${SETTLE}), metadata (${FACTS}), payload policy (${POLICY}), installation (${INSTALLATION}), handler (${HANDLER})"
if grep -n -E 'realpath|resourceValues|[^A-Za-z]stat\(' "${OPEN}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the open planner addresses the caller's location by a call of its own"
fi
echo "the open planner makes no other path call"

echo
echo "== Source: a supplied application is resolved by the walk and limited, its bundle read from the resolved spelling, and its candidates resolved and compared by identity"
# Stage 2 of the spec's order: a constrained launch's and a named open's `applicationPath`. The chosen copy is resolved,
# then refused at the limit, and only then is its bundle read; the registered candidates follow, each resolved by the
# same walk and compared by device and inode, their own metadata never read, and the selected registration is limited.
APPLICATION_STAGE=Providers/WorkspaceProvider/Logic/ApplicationStage.swift
A_RESOLVE="$(line_in "${APPLICATION_STAGE}" 'native.resolveLocation(path)')"
A_LIMIT="$(line_in "${APPLICATION_STAGE}" 'HandOffLimit.refusal(of: found')"
A_READ="$(line_in "${APPLICATION_STAGE}" 'native.readApplicationBundle(of: chosen)')"
A_LISTED="$(line_in "${APPLICATION_STAGE}" 'native.registeredApplications(bundleIdentifier')"
A_CANDIDATE="$(line_in "${APPLICATION_STAGE}" 'native.resolveLocation(registered.path)')"
A_SELECTED="$(line_in "${APPLICATION_STAGE}" 'HandOffLimit.refusal(of: copy')"
for found in "${A_RESOLVE}" "${A_LIMIT}" "${A_READ}" "${A_LISTED}" "${A_CANDIDATE}" "${A_SELECTED}"; do
    [ -n "${found}" ] || fail "the supplied-application stage no longer has one of resolve, limit, bundle read, registered copies, candidate resolution, selected limit"
done
[ "${A_RESOLVE}" -lt "${A_LIMIT}" ] && [ "${A_LIMIT}" -lt "${A_READ}" ] && [ "${A_READ}" -lt "${A_LISTED}" ] &&
    [ "${A_LISTED}" -lt "${A_CANDIDATE}" ] && [ "${A_CANDIDATE}" -lt "${A_SELECTED}" ] ||
    fail "the supplied-application stage's order is not resolve, limit, bundle read, registered copies, candidates, selected limit"
echo "supplied-application order: resolve (line ${A_RESOLVE}), limit (${A_LIMIT}), bundle read (${A_READ}), registered copies (${A_LISTED}), candidates (${A_CANDIDATE}), selected limit (${A_SELECTED})"
[ "$(grep -c -F 'readApplicationBundle(' "${APPLICATION_STAGE}")" = 1 ] ||
    fail "a bundle is read in the supplied-application stage other than the chosen copy's"
[ "$(grep -c -E 'copy\.identity == chosen\.identity' "${APPLICATION_STAGE}")" = 1 ] ||
    fail "the candidates are not compared with the chosen copy by the walk's device and inode"
if grep -n -E 'inspectApplication|readPathFacts|realpath|resourceValues|[^A-Za-z]stat\(' "${APPLICATION_STAGE}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the supplied-application stage addresses a location by a call of its own"
fi
echo "the stage makes no path call of its own, and reads one bundle"
APPLICATION_READ="$(awk '/func readApplicationBundle\(of location: ResolvedLocation\)/ {on=1} on {print} on && /^    }$/ {exit}' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift)"
echo "${APPLICATION_READ}"
[ -n "${APPLICATION_READ}" ] || fail "the application bundle read is not one native function"
grep -q -F 'fileSystemURL(of: location)' <<<"${APPLICATION_READ}" || fail "the application bundle is not read from the resolved spelling"
if grep -E 'location\.literal|realpath\(|l?stat\(|path\.text|isMissing' <<<"${APPLICATION_READ}" | grep -v -E '^\s*//'; then
    fail "the application bundle read addresses the caller's spelling, makes a whole-path call or reads a missing file as absence"
fi
grep -q -F 'forKeys: [.isApplicationKey]' <<<"${APPLICATION_READ}" || fail "the bundle's resource key is not the measured one"
echo "the bundle's metadata is read from the resolved spelling's bytes, as one resource value and the identifier"
ROOT_CALL="$(grep -n -A12 -F 'func isFilesystemRoot(literalPath path: String)' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift | grep -c -E 'lstat\(')"
[ "${ROOT_CALL}" = 2 ] || fail "the root decision is not exactly two lstat calls, the literal path and /"
echo "the root decision: lstat of the literal text and of /, after the limit"

echo
echo "== Source: a discovered application is resolved by the walk and limited, then its bundle read from the resolved spelling, and no location is addressed by a whole-path call before the limit"
# Stages 3 and 4 of the spec's order: the identifier's preferred copy (an unconstrained launch or named open), the default
# handler of a document or of a web scheme, and Finder's registration. Each discovery read reports a location; the one
# stage resolves it by the walk, refuses an over-limit spelling, and only then reads the bundle.
DISCOVERED_STAGE=Providers/WorkspaceProvider/Logic/DiscoveredStage.swift
D_RESOLVE="$(line_in "${DISCOVERED_STAGE}" 'native.resolveLocation(discovered.path)')"
D_LIMIT="$(line_in "${DISCOVERED_STAGE}" 'HandOffLimit.refusal(of: location')"
D_READ="$(line_in "${DISCOVERED_STAGE}" 'native.readApplicationBundle(of: found)')"
for found in "${D_RESOLVE}" "${D_LIMIT}" "${D_READ}"; do
    [ -n "${found}" ] || fail "the discovered-application stage no longer has one of resolve, limit, bundle read"
done
[ "${D_RESOLVE}" -lt "${D_LIMIT}" ] && [ "${D_LIMIT}" -lt "${D_READ}" ] ||
    fail "the discovered-application stage's order is not resolve, limit, bundle read"
echo "discovered-application order: resolve (line ${D_RESOLVE}), limit (${D_LIMIT}), bundle read (${D_READ})"
[ "$(grep -c -F 'readApplicationBundle(' "${DISCOVERED_STAGE}")" = 1 ] || fail "the discovered-application stage reads other than the one bundle"
if grep -n -E 'inspectApplication|readPathFacts|realpath|resourceValues|[^A-Za-z]stat\(' "${DISCOVERED_STAGE}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the discovered-application stage addresses a location by a call of its own"
fi
# Every discovered application goes through that stage, after its own discovery read: seen to be exactly the three callers.
CALLERS="$(grep -rn -E 'settleDiscoveredApplication\(' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' | grep -v 'func settleDiscoveredApplication' || true)"
echo "${CALLERS}"
[ "$(grep -c . <<<"${CALLERS}")" = 3 ] || fail "the discovered-application stage does not have exactly three callers (a preferred copy, a web handler, an item handler)"
SELECTION=Providers/WorkspaceProvider/Logic/Selection.swift
line_before() { # file, discovery-read text, stage text: the discovery read comes first
    local read stage
    read="$(line_in "$1" "$2")"
    stage="$(line_in "$1" "$3")"
    [ -n "${read}" ] && [ -n "${stage}" ] && [ "${read}" -lt "${stage}" ]
}
line_before "${SELECTION}" 'native.registeredApplication(bundleIdentifier: request.bundleIdentifier)' 'settleDiscoveredApplication(registered' ||
    fail "a preferred copy is not found before it is resolved"
line_before "${SELECTION}" 'native.defaultApplication(forWebScheme: scheme)' 'settleDiscoveredApplication(handler' ||
    fail "a web handler is not found before it is resolved"
line_before "${OPEN}" 'native.defaultApplication(toOpen: target)' 'settleDiscoveredApplication(handler' ||
    fail "an item handler is not found before it is resolved"
echo "each caller makes its discovery read, then the stage"
# The old whole-path inspection of a registered location is gone, from the adapter and from the seam. Seen first to match.
printf 'func inspectApplication(at path: String) -> ApplicationInspection {\nnative.inspectApplication(at: handler.path)\n' >"${CONTROL}"
[ "$(grep -c -E 'inspectApplication' "${CONTROL}")" = 2 ] || fail "the inspection pattern does not match the control it must"
if grep -rn -E 'inspectApplication|ApplicationInspection' "${SOURCES[@]}"; then
    fail "the whole-path inspection of a registered application location is still there"
fi
echo "no whole-path inspection of a registered location remains"
# What whole-path calls the adapter still makes: the reveal root rule's two lstat calls, after the limit on the literal, and the
# Info.plist's stat and access, on the resolved spelling after the limit. No realpath, and no errno but ENOENT read as absence.
NATIVE_FILE=Providers/WorkspaceProvider/Sources/NativeWorkspace.swift
printf 'realpath(path, nil)\nlet r = stat(p, &s)\nlstat(p, &s)\naccess(p, R_OK)\n' >"${CONTROL}"
[ "$(grep -c -E '(^|[^A-Za-z_.])(realpath|stat|lstat|access)\([^)]' "${CONTROL}")" = 4 ] || fail "the whole-path pattern does not match the control it must"
ADAPTER_CALLS="$(grep -n -E '(^|[^A-Za-z_.])(realpath|stat|lstat|access)\([^)]' "${NATIVE_FILE}" | grep -v -E '^[0-9]+:\s*//' || true)"
echo "${ADAPTER_CALLS}"
[ "$(grep -c . <<<"${ADAPTER_CALLS}")" = 4 ] || fail "the adapter makes a whole-path call other than the root rule's two lstat and the Info.plist's stat and access"
INFO_PLIST="$(awk '/private func infoPlistDenial\(in bundle: URL\)/ {on=1} on {print} on && /^    }$/ {exit}' "${NATIVE_FILE}")"
[ "$(grep -c -E '(^|[^A-Za-z_.])(stat|access)\([^)]' <<<"${INFO_PLIST}")" = 2 ] || fail "the Info.plist's stat and access are not in the one function"
if grep -n -E 'realpath' "${NATIVE_FILE}" | grep -v -E '^[0-9]+:\s*//'; then fail "the adapter still calls realpath"; fi
IS_MISSING="$(awk '/private func isMissing\(_ error: Error\)/ {on=1} on {print} on && /^    }$/ {exit}' "${NATIVE_FILE}")"
[ -n "${IS_MISSING}" ] || fail "isMissing is not one function"
if grep -E 'ELOOP|ENAMETOOLONG|ENOTDIR' <<<"${IS_MISSING}" | grep -v -E '^\s*//'; then
    fail "an errno that names more than a missing file is read as absence"
fi
if grep -rn -E 'ELOOP|ENAMETOOLONG' "${NATIVE_FILE}" Providers/WorkspaceProvider/Logic/Selection.swift "${DISCOVERED_STAGE}" "${APPLICATION_STAGE}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "an errno of a long or cyclic location is handled outside the walk"
fi
echo "no ELOOP or ENAMETOOLONG is mapped to absence in the adapter or a stage; the walk alone decides absence"

echo
echo "== Source: the receipt's two executable identities are acquired by the walk, in one representation, and by no whole-path primitive"
# Observation's third step compares the live process's executable (`proc_pidpath`) with the retained application object's
# (`executableURL`). Neither route calls `inspectApplication`, so no stage converts them: each is read as bytes, resolved by the
# walk, and compared as the walk's device and inode. The hand-off limit never applies to either: the action was acknowledged.
EXECUTABLE=Providers/WorkspaceProvider/Logic/ExecutableIdentity.swift
OBSERVATION=Providers/WorkspaceProvider/Logic/Observation.swift
NATIVE_SEAM=Providers/WorkspaceProvider/Logic/Native.swift
# What neither route may use: the old identity type, a symlink-resolving or pathname resource call. Seen first to match.
IDENTITY_PRIMITIVES='fileIdentity\(ofPath|FileIdentity\b|resolvingSymlinksInPath|realpath\(|fileResourceIdentifier|volumeIdentifier|standardizedFileURL'
printf 'fileIdentity(ofPath: p)\nFileIdentity(volume: v, file: f)\nurl.resolvingSymlinksInPath()\nrealpath(p, nil)\nvalues.fileResourceIdentifier\nvalues.volumeIdentifier\nurl.standardizedFileURL\n' >"${CONTROL}"
[ "$(grep -c -E "${IDENTITY_PRIMITIVES}" "${CONTROL}")" = 7 ] || fail "the identity-primitive pattern does not match the control it must"
if grep -rn -E "${IDENTITY_PRIMITIVES}" "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "a receipt identity still uses the old identity type, a symlink-resolving call or a pathname resource value"
fi
echo "no fileIdentity(ofPath:), FileIdentity, resolvingSymlinksInPath, realpath or file/volume resource identifier remains"
LIVE_IDENTITY="$(awk '/func liveExecutableIdentity\(of pid: Int32\)/ {on=1} on {print} on && /^    }$/ {exit}' "${NATIVE_FILE}")"
RETAINED_URL="$(awk '/^func identityOfExecutable\(at url: URL\)/ {on=1} on {print} on && /^}$/ {exit}' "${NATIVE_FILE}")"
RETAINED_PROPERTY="$(awk '/var executableIdentity: ObjectIdentity\? \{/ {on=1} on {print} on && /^    }$/ {exit}' "${NATIVE_FILE}")"
echo "${LIVE_IDENTITY}"
echo "${RETAINED_URL}"
echo "${RETAINED_PROPERTY}"
for body in "${LIVE_IDENTITY}" "${RETAINED_URL}" "${RETAINED_PROPERTY}"; do
    [ -n "${body}" ] || fail "a receipt identity route is not the one function or property this check names"
done
grep -q -F 'proc_pidpath(' <<<"${LIVE_IDENTITY}" || fail "the live identity is not read from the kernel's path (proc_pidpath)"
grep -q -F 'ExecutableIdentity.of(path:' <<<"${LIVE_IDENTITY}" || fail "the live identity is not acquired by the walk"
grep -q -F 'withUnsafeFileSystemRepresentation' <<<"${RETAINED_URL}" || fail "the retained identity is not read from the URL's own filesystem bytes"
grep -q -F 'ExecutableIdentity.of(path:' <<<"${RETAINED_URL}" || fail "the retained identity is not acquired by the walk"
grep -q -F 'identityOfExecutable(at:' <<<"${RETAINED_PROPERTY}" || fail "the retained object's identity is not its executable URL's"
if grep -E 'resourceValues|\.path\b|String\(|realpath|l?stat\(|HandOffLimit|pathMax' <<<"${LIVE_IDENTITY}${RETAINED_URL}${RETAINED_PROPERTY}" | grep -v -E '^\s*//'; then
    fail "a receipt identity route decodes its path, addresses it by a whole-path call or applies the hand-off limit"
fi
[ "$(grep -c -F 'proc_pidpath(' "${NATIVE_FILE}")" = 1 ] || fail "the kernel's executable path is read other than once"
[ "$(grep -rho -F 'ExecutableIdentity.of(path:' "${SOURCES[@]}" | wc -l | tr -d ' ')" = 2 ] ||
    fail "the walk is not the one acquisition of exactly the two receipt identities"
# The rule itself: the walk, and never the hand-off limit.
grep -q -F 'LocationWalk.resolve(path' "${EXECUTABLE}" || fail "the receipt identity rule does not resolve by the walk"
grep -q -F 'guard case .present(let location)' "${EXECUTABLE}" || fail "the receipt identity rule does not yield an identity for a present location alone"
if grep -n -H -E 'HandOffLimit|pathMax|byteCount|\.count|refusal|\.failed' "${EXECUTABLE}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the receipt identity rule applies a length or turns an outcome into a refusal"
fi
# One representation: both sides of the comparison are the walk's `ObjectIdentity`, and nothing else is.
[ "$(grep -c -E 'ObjectIdentity\?' "${NATIVE_SEAM}")" = 2 ] || fail "the native seam does not declare exactly the two identities as ObjectIdentity"
grep -q -F 'claimed == live' "${OBSERVATION}" || fail "observation no longer compares the two identities"
echo "both identities are read as bytes, resolved by the walk with no length limit, and compared as ObjectIdentity (device and inode)"

echo
echo "== Source: exactly one Finder selection request, in its two documented forms, and nothing else for a reveal"
SELECTS="$(grep -rn -E 'selectFile\(' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${SELECTS}"
[ "$(grep -c . <<<"${SELECTS}")" = 2 ] || fail "the reveal path does not make its selection request in exactly two forms"
grep -q -F 'NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/")' <<<"${SELECTS}" ||
    fail "the filesystem-root form is not the documented root view"
grep -q -F 'NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")' <<<"${SELECTS}" ||
    fail "the item form is not the documented selection in the main viewer"
[ "$(grep -c -E 'func revealPath\(' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift)" = 1 ] ||
    fail "the reveal request is not one native function"
grep -q -F 'DispatchQueue.global(qos: .userInitiated).async' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift ||
    fail "the synchronous reveal request no longer runs on a global queue"
# The path handed to the request is the validated path the provider inspected, as written.
grep -rq -E 'native\.revealPath\(target, filesystemRoot: filesystemRoot, completion: completion\)' Providers/WorkspaceProvider/Logic ||
    fail "the reveal request is not given the inspected path"

echo
echo "== Source: nothing beside them activates, hides, raises, posts events, scripts, spawns or terminates"
if grep -rn -E "${FORBIDDEN_SOURCE}" "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the launch path contains a call the authority trace does not declare"
fi
echo "none"

echo
echo "== Bundle: ${LIBRARY}"
echo "Imported Objective-C classes:"
nm -u "${LIBRARY}" | grep OBJC_CLASS | sed 's/^ *_OBJC_CLASS_\$_/  /' | sort
echo "Selectors that reach the workspace (open requests, the Finder selection, handler lookup and the configuration):"
strings "${LIBRARY}" | grep -E '^(openApplicationAtURL:configuration:completionHandler:|openURLs:withApplicationAtURL:configuration:completionHandler:|URLForApplicationToOpenURL:|selectFile:inFileViewerRootedAtPath:|set(Activates|AllowsRunningApplicationSubstitution|AppleEvent|Arguments|CreatesNewApplicationInstance|Environment|ForPrinting|Hides|HidesOthers|PromptsUserIfNeeded):)$' | sort -u | sed 's/^/  /'
strings "${LIBRARY}" | grep -qx 'openApplicationAtURL:configuration:completionHandler:' || fail "the bundle does not carry the open request"
strings "${LIBRARY}" | grep -qx 'openURLs:withApplicationAtURL:configuration:completionHandler:' || fail "the bundle does not carry the URL open request"
strings "${LIBRARY}" | grep -qx 'URLForApplicationToOpenURL:' || fail "the bundle does not carry the handler lookup"
strings "${LIBRARY}" | grep -qx 'selectFile:inFileViewerRootedAtPath:' || fail "the bundle does not carry the Finder selection request"
[ "$(strings "${LIBRARY}" | grep -c -x -E 'set(Activates|AllowsRunningApplicationSubstitution|AppleEvent|Arguments|CreatesNewApplicationInstance|Environment|ForPrinting|Hides|HidesOthers|PromptsUserIfNeeded):' | sort -u)" -ge 10 ] ||
    fail "the bundle lacks one of the ten configuration setters"
echo "Descriptor walk calls the bundle imports (search-only, single-component):"
# `openat` is variadic in C, so Swift reaches it through its Darwin overlay's wrapper, `Darwin.openat(_:_:_:)`.
for symbol in '_\$s6Darwin6openat[A-Za-z0-9_$]*' '_fstatat' '_fstat' '_readlinkat' '_fpathconf'; do
    nm -u "${LIBRARY}" | grep -q -E "^[[:space:]]*${symbol}([^A-Za-z0-9_]|$)" || fail "the bundle does not import ${symbol}"
    echo "  ${symbol}"
done
if nm -u "${LIBRARY}" | grep -E '^[[:space:]]*_(opendir|readdir|fdopendir|getdirentries|fopen|readlink)([^A-Za-z0-9_]|$)'; then
    fail "the bundle imports a listing or whole-path call the walk does not make"
fi
echo "Forbidden selectors and imported symbols:"
if { strings "${LIBRARY}"; nm -u "${LIBRARY}"; } | sed 's/^ *//' | grep -E "${FORBIDDEN_BINARY}"; then
    fail "the bundle imports or names a call the authority trace does not declare"
fi
echo "  none"
echo
echo "PASSED: one launch request, one open request (URL or path) and one Finder selection request (in its two documented forms) to an explicitly resolved handler, found by the scheme alone or for the item opened, with activation as the launch's declared effect, a reveal's target resolved by the descriptor walk (search-only single-component calls) before the hand-off limit and any whole-path call, other items inspected by measured metadata calls only, the receipt's two executable identities each acquired by that walk as the walk's device and inode with no length limit, and no other activation, input, scripting or process call"
