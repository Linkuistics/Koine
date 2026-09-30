#!/bin/bash
# Builds the pre-extension host, framework, fixtures and desktop provider from a
# RELEASED revision of this repository, not from the working tree: the old side of
# every old/new pair. The revision is the release tag v0.1.0 unless
# KOINE_BASELINE_REVISION names another; it must be a revision this repository
# holds. The released sources are copied into a tree of their own with a build
# directory of their own, so nothing built there sees the working tree.
#
# `task compat:baseline` runs this by itself; scripts/build-compat-pairs.sh calls
# it for the pairs, and any cross-version check that needs the old host uses the
# same build (docs/verification/binary-compatibility.md).
#
# usage: build-baseline-host.sh [debug|release]   (prints the pairs directory)
set -euo pipefail

cd "$(dirname "$0")/.."
CONFIGURATION="${1:-debug}"
REVISION="${KOINE_BASELINE_REVISION:-v0.1.0}"
PAIRS="$(pwd)/.build/compat/${CONFIGURATION}"
TREE="${PAIRS}/baseline/src"

# The released revision's files, by commit, from whichever VCS this checkout is.
if [ -d .jj ]; then
    COMMIT="$(jj log --ignore-working-copy --no-graph -r "${REVISION}" -T 'commit_id' 2>/dev/null)"
    list_files() { jj file list --ignore-working-copy -r "${COMMIT}"; }
    show_file() { jj file show --ignore-working-copy -r "${COMMIT}" "$1"; }
else
    COMMIT="$(git rev-parse --verify "${REVISION}^{commit}")"
    list_files() { git ls-tree -r --name-only "${COMMIT}"; }
    show_file() { git show "${COMMIT}:$1"; }
fi
if [ -z "${COMMIT}" ]; then
    echo "Error: this repository holds no revision ${REVISION}." >&2
    exit 1
fi

# A tree already extracted at this commit is reused with its build directory, so
# the released sources are compiled once.
if [ "$(cat "${TREE}/.koine-baseline-revision" 2>/dev/null || true)" != "${COMMIT}" ]; then
    rm -rf "${TREE}"
    mkdir -p "${TREE}"
    list_files | while IFS= read -r path; do
        mkdir -p "${TREE}/$(dirname "${path}")"
        show_file "${path}" >"${TREE}/${path}"
    done
    # Modes are not part of `jj file show`: the scripts run in the tree.
    find "${TREE}" -name '*.sh' -o -name '*.py' | xargs chmod +x
    echo "${COMMIT}" >"${TREE}/.koine-baseline-revision"
fi
echo "baseline: ${REVISION} (${COMMIT})" >&2

scripts/build-compat-tree.sh "${CONFIGURATION}" "${TREE}" "${PAIRS}/baseline"
echo "${PAIRS}"
