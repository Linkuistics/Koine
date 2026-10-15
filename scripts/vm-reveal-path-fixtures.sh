#!/bin/bash
# Runs IN THE GUEST (scripts/vm-verify-reveal-path.sh uploads and runs it): the disposable
# fixtures workspaceRevealPath is accepted against. Nothing here is part of Koine, and nothing
# is under Desktop, Documents or Downloads. The names are the host script's constants; it
# checks every path it submits against what exists here before it relies on the case.
#
#   ~/reveal-fx/dir/   a directory of siblings, so that a selection is visibly one item of several:
#                      note.txt, other.txt, "sub folder", "Alias to note" (a real Finder alias file),
#                      a literal-punctuation file, a symlink to the note, a symlink to nowhere
#
# Run as: vm-reveal-path-fixtures.sh <make-alias binary> (the alias maker is compiled by the host script).
set -euo pipefail

ALIAS_MAKER="${1:?usage: vm-reveal-path-fixtures.sh <make-alias binary>}"
FX="${HOME}/reveal-fx"

# Idempotent: the agent's exec channel can run a command twice.
rm -rf "${FX}"
mkdir -p "${FX}/dir/sub folder"
cd "${FX}/dir"
printf 'the note\n' >"note.txt"
printf 'another file beside it\n' >"other.txt"
printf 'inside the sub folder\n' >"sub folder/inner.txt"
printf 'shell punctuation stays literal\n' >"lit \$HOME ~ * ? [x] ; & ' \" # % ! (1).txt"
ln -s "note.txt" "link-to-note.txt"
ln -s "does-not-exist-anywhere" "link-to-nowhere"
"${ALIAS_MAKER}" "${FX}/dir/note.txt" "${FX}/dir/Alias to note"

find "${FX}" -maxdepth 2 -print0 | sort -z | xargs -0 ls -ldO
