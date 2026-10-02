#!/bin/bash
# Enumerates the native primitives, parameters, preparation, fallback and cleanup
# calls of the workspace provider's launch, URL and path paths, from its source and from the
# built bundle's own imports, and checks them against the authority trace: the
# launch path makes ONE launch request, NSWorkspace.openApplication(at:configuration:),
# with activation on as the trace declares (workspace:control AND desktop:control);
# the URL path makes ONE open request, NSWorkspace.open(_:withApplicationAt:configuration:),
# to an application it resolved itself, from a handler lookup that is given the scheme
# alone (never a part of the submitted URL), with the same configuration; the path root
# makes the same single open request, to the default application of the item as the
# system's file lookup answers it or to the named installation, and inspects the item
# only through metadata calls; and no
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
FORBIDDEN_SOURCE='\.activate\(|activate\(from|\.hide\(|\.unhide\(|hideOtherApplications|\.raise|AXUIElement|AXIsProcess|CGEvent|CGWindow|NSAppleScript|NSAppleEventDescriptor|Process\(\)|posix_spawn|\bsystem\(|\.terminate\(|\.forceTerminate|open(URL|URLs|File)\(|activateIgnoringOtherApps|NSWorkspace\.shared\.launchApplication|showFile|selectFile|urlsForApplications\(toOpen|LSCopyDefault|requiresUniversalLinks|setDefaultApplication'
FORBIDDEN_BINARY='^(URLsForApplicationsToOpenURL:|setRequiresUniversalLinks:|setDefaultApplicationAtURL:[A-Za-z:]*|activateWithOptions:|activateFromApplication:|activateIgnoringOtherApps:|activate|hideOtherApplications|unhide|unhideAllApplications|terminate|forceTerminate|launchApplication:|openURL:|openURLs:|openFile:|selectFile:[A-Za-z:]*|_AX[A-Za-z]*|_CGEvent[A-Za-z]*|_CGWindow[A-Za-z]*|_kill|_posix_spawn[a-z_]*|_execv[a-z]*|_system)$'

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
INSPECTION="$(grep -n -E 'realpath\(|[^a-zA-Z.]stat\(|resourceValues\(forKeys' Providers/WorkspaceProvider/Sources/NativeWorkspace.swift | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${INSPECTION}"
grep -q 'forKeys: \[.isApplicationKey, .contentTypeKey, .isAliasFileKey\]' <<<"${INSPECTION}" || fail "the item's resource keys are not the measured three"
if grep -rn -E 'contentsOfDirectory|enumerator\(|contents\(atPath|Data\(contentsOf|String\(contentsOf|FileHandle|fopen\(|open\(path|opendir|readdir' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//'; then
    fail "the workspace provider reads a directory or a file's contents"
fi
echo "none read"

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
echo "Selectors that reach the workspace (open requests, handler lookup and the configuration):"
strings "${LIBRARY}" | grep -E '^(openApplicationAtURL:configuration:completionHandler:|openURLs:withApplicationAtURL:configuration:completionHandler:|URLForApplicationToOpenURL:|set(Activates|AllowsRunningApplicationSubstitution|AppleEvent|Arguments|CreatesNewApplicationInstance|Environment|ForPrinting|Hides|HidesOthers|PromptsUserIfNeeded):)$' | sort -u | sed 's/^/  /'
strings "${LIBRARY}" | grep -qx 'openApplicationAtURL:configuration:completionHandler:' || fail "the bundle does not carry the open request"
strings "${LIBRARY}" | grep -qx 'openURLs:withApplicationAtURL:configuration:completionHandler:' || fail "the bundle does not carry the URL open request"
strings "${LIBRARY}" | grep -qx 'URLForApplicationToOpenURL:' || fail "the bundle does not carry the handler lookup"
[ "$(strings "${LIBRARY}" | grep -c -x -E 'set(Activates|AllowsRunningApplicationSubstitution|AppleEvent|Arguments|CreatesNewApplicationInstance|Environment|ForPrinting|Hides|HidesOthers|PromptsUserIfNeeded):' | sort -u)" -ge 10 ] ||
    fail "the bundle lacks one of the ten configuration setters"
echo "Forbidden selectors and imported symbols:"
if { strings "${LIBRARY}"; nm -u "${LIBRARY}"; } | sed 's/^ *//' | grep -E "${FORBIDDEN_BINARY}"; then
    fail "the bundle imports or names a call the authority trace does not declare"
fi
echo "  none"
echo
echo "PASSED: one launch request and one open request (URL or path) to an explicitly resolved handler, found by the scheme alone or for the item opened, with activation as their declared effect, items inspected by measured metadata calls only, and no other activation, input, scripting or process call"
