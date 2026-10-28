#!/bin/bash
# Relative regular-file and symlink endpoint inventory, on host or guest.
set -euo pipefail
cd "${1:?bundle directory}"
find . -type f -exec shasum -a 256 {} + | LC_ALL=C sort
find . -type l -exec stat -f '%N -> %Y' {} + | LC_ALL=C sort
