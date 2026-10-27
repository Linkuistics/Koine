#!/bin/bash
set -euo pipefail
PATH="$(cat docs/verification/menu-bar-samples/tool-path.txt)"
export PATH
{
    find .build/menu-samples/releases -type f -exec shasum -a 256 {} +
    shasum -a 256 scripts/vm-verify-menu-bar.sh scripts/signing-env.sh \
        scripts/vm-verify-lib.sh scripts/vm-menu-pointer-lib.sh \
        scripts/vm-window-resize-lib.sh scripts/vm-verify-desktop-lib.sh \
        scripts/vm-verify-enrollment-client.py scripts/vm-verify-client.sh \
        Taskfile.yml App/Info.plist \
        docs/verification/menu-bar-focus/activation-snapshot.m \
        docs/verification/window-resize/failure-observer-binary \
        docs/verification/menu-bar-samples/run.sh \
        docs/verification/menu-bar-samples/inventory.sh \
        docs/verification/menu-bar-samples/links.sh \
        docs/verification/menu-bar-samples/tool-path.txt \
        docs/verification/menu-bar-samples/tool-resolution.txt \
        docs/verification/menu-bar-samples/PLAN.md \
        Tests/scripts/vm-menu-sample.bats \
        /Applications/TestAnyware.app/Contents/MacOS/testanyware-app
    for tool in testanyware tart mise task jq ditto bash shasum; do
        shasum -a 256 "$(command -v "${tool}")"
    done
} | LC_ALL=C sort
