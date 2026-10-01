#!/bin/bash
# Enumerates the native primitives, parameters, preparation, fallback and cleanup
# calls of the workspace provider's launch and URL paths, from its source and from the
# built bundle's own imports, and checks them against the authority trace: the
# launch path makes ONE launch request, NSWorkspace.openApplication(at:configuration:),
# with activation on as the trace declares (workspace:control AND desktop:control);
# the URL path makes ONE open request, NSWorkspace.open(_:withApplicationAt:configuration:),
# to an application it resolved itself, from a handler lookup that is given the scheme
# alone (never a part of the submitted URL), with the same configuration; and no
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
echo "== Source: exactly one URL open request, to an application resolved beforehand"
OPENS="$(grep -rn -E 'NSWorkspace\.shared\.open\(' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${OPENS}"
[ "$(grep -c . <<<"${OPENS}")" = 1 ] || fail "the URL path does not make exactly one open request"
grep -q -E 'open\(\[url\], withApplicationAt: application, configuration: configuration\)' <<<"${OPENS}" ||
    fail "the URL open request is not addressed to an explicit application with the shared configuration"
[ "$(grep -rc -E 'openConfiguration\(substitutingRunningCopy:' "${SOURCES[@]}" | awk -F: '{s+=$2} END {print s}')" -ge 3 ] ||
    fail "the launch and URL requests no longer take their configuration from the one helper"

echo
echo "== Source: the default handler is looked up by the scheme alone"
LOOKUPS="$(grep -rn -E 'urlForApplication\(toOpen:' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${LOOKUPS}"
[ "$(grep -c . <<<"${LOOKUPS}")" = 1 ] || fail "handler discovery is not a single lookup"
grep -q 'urlForApplication(toOpen: schemeOnly)' <<<"${LOOKUPS}" || fail "the lookup is not given the scheme-only URL"
SCHEME_ONLY="$(grep -rn -E 'schemeOnly = ' "${SOURCES[@]}" | grep -v -E ':[0-9]+:\s*//' || true)"
echo "${SCHEME_ONLY}"
grep -q -F 'URL(string: "\(scheme.rawValue):")' <<<"${SCHEME_ONLY}" || fail "the scheme-only URL is built from more than the scheme"
[ "$(grep -c . <<<"${SCHEME_ONLY}")" = 1 ] || fail "more than one URL is built for a lookup"

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
strings "${LIBRARY}" | grep -qx 'URLForApplicationToOpenURL:' || fail "the bundle does not carry the scheme handler lookup"
[ "$(strings "${LIBRARY}" | grep -c -x -E 'set(Activates|AllowsRunningApplicationSubstitution|AppleEvent|Arguments|CreatesNewApplicationInstance|Environment|ForPrinting|Hides|HidesOthers|PromptsUserIfNeeded):' | sort -u)" -ge 10 ] ||
    fail "the bundle lacks one of the ten configuration setters"
echo "Forbidden selectors and imported symbols:"
if { strings "${LIBRARY}"; nm -u "${LIBRARY}"; } | sed 's/^ *//' | grep -E "${FORBIDDEN_BINARY}"; then
    fail "the bundle imports or names a call the authority trace does not declare"
fi
echo "  none"
echo
echo "PASSED: one launch request and one URL open request to an explicitly resolved handler, found by the scheme alone, with activation as their declared effect, and no other activation, input, scripting or process call"
