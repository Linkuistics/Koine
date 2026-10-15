#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh
probe_root=".build/search-evidence"
stage="${probe_root}/source"
mkdir -p "${stage}/Providers" "${stage}/scripts" "${stage}/App"
rm -rf "${stage}/Providers/WorkspaceProvider" "${probe_root}/Koine.app"
cp scripts/signing-env.sh "${stage}/scripts/"
cp App/Info.plist "${stage}/App/"
cp -RL Providers/WorkspaceProvider "${stage}/Providers/"
cp docs/verification/search-discovery/probe.swift "${stage}/Providers/WorkspaceProvider/Sources/SearchEvidence.swift"
sed -i '' 's/func start() async throws {}/func start() async throws { try await SearchEvidence.run() }/' \
  "${stage}/Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift"
rg -q 'try await SearchEvidence.run' "${stage}/Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift"
framework="$(scripts/stage-provider-framework.sh release)"
cp -R "${APP_BUNDLE}" "${probe_root}/Koine.app"
"${stage}/Providers/WorkspaceProvider/build.sh" "$(dirname "${framework}")" "${probe_root}/Koine.app/Contents/PlugIns"
codesign --force --options runtime --sign "${SIGNING_IDENTITY}" "${probe_root}/Koine.app/Contents/PlugIns/Workspace.koineprovider"
codesign --force --options runtime --entitlements App/Koine.entitlements --sign "${SIGNING_IDENTITY}" "${probe_root}/Koine.app"
codesign --verify --strict --deep "${probe_root}/Koine.app"
ditto -c -k "${probe_root}/Koine.app" "${probe_root}/Koine.zip"
