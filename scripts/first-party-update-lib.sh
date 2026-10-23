#!/bin/bash
# The few steps that turn this tree's first-party provider source into a bundle that
# states `first-party-selection-v1`, as every newly published first-party update must:
# sourced by scripts/build-selection-real.sh (the selection acceptance's real updates)
# and scripts/build-compat-pairs.sh (the per-user 1.0.1 workspace variant). The product
# source is never edited: each step works on a copy, and a substitution that changes
# nothing is an error. The caller sets WORK (a scratch directory) and runs from the
# root of the tree whose Providers/ it copies.

FEATURE='first-party-selection-v1'

# edit <bundle> <python statements over the manifest dict `m`>
edit() {
    python3 - "$1/manifest.json" "$2" <<'PY'
import json, sys
path, statements = sys.argv[1], sys.argv[2]
with open(path) as file:
    m = json.load(file)
exec(statements)
with open(path, "w") as file:
    json.dump(m, file, indent=2)
PY
}

# A copy that builds as the repository's providers do. The substitution must change it.
# substitute <file> <from> <to>
substitute() {
    python3 - "$1" "$2" "$3" <<'PY'
import sys
path, old, new = sys.argv[1:4]
with open(path) as file:
    text = file.read()
if old not in text:
    raise SystemExit(f"{path} does not contain {old!r}: the substitution would change nothing")
with open(path, "w") as file:
    file.write(text.replace(old, new))
PY
}

# tree <name>: a copy of what the provider build definitions read, under ${WORK}/<name>
tree() {
    local root="${WORK}/$1"
    mkdir -p "${root}/scripts" "${root}/App"
    cp -R Providers "${root}/Providers"
    cp scripts/signing-env.sh "${root}/scripts/"
    cp App/Info.plist "${root}/App/"
    echo "${root}"
}

# state_feature_in_workspace <tree>: the descriptor of the workspace provider in <tree>
# requires the feature beside the one it already requires.
state_feature_in_workspace() {
    substitute "$1/Providers/WorkspaceProvider/Logic/WorkspaceProvider.swift" \
        'requiredFeatures: [ProviderDescriptor.additionalCapabilitiesFeature, workspaceNativeDisclosuresFeature]' \
        "requiredFeatures: [ProviderDescriptor.additionalCapabilitiesFeature, workspaceNativeDisclosuresFeature, \"${FEATURE}\"]"
}
