#!/bin/bash
set -euo pipefail
find .build/menu-samples/releases -type l -exec stat -f '%N -> %Y' {} + | LC_ALL=C sort
