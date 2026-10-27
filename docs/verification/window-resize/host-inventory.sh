#!/bin/bash
set -euo pipefail
find .build/menu-interaction/Koine.app -type f -exec shasum -a 256 {} +
shasum -a 256 .build/menu-interaction/Koine-0.4.0-aarch64-apple-darwin.zip \
    scripts/vm-verify-menu-bar.sh scripts/signing-env.sh scripts/vm-verify-lib.sh \
    scripts/vm-menu-pointer-lib.sh scripts/vm-window-resize-lib.sh scripts/vm-verify-desktop-lib.sh \
    scripts/vm-verify-enrollment-client.py scripts/vm-verify-client.sh \
    Taskfile.yml App/Info.plist .build/window-resize/host-inventory.sh
