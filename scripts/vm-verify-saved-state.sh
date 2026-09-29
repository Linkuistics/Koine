#!/bin/bash
# Runs IN the guest, uploaded by scripts/vm-verify-homebrew.sh. Prints the
# saved window state macOS keeps for Koine, with the files in it, or nothing.
# From macOS 26 AppKit does not write ~/Library/Saved Application State/<bundle
# id>.savedState. It writes <uuid>.savedState inside talagent's Daemon
# Container, and ApplicationMapping.plist beside it is an array alternating a
# signing identity with that UUID, so a name search never finds Koine's.
set -euo pipefail
shopt -s nullglob
for mapping in "$HOME"/Library/Daemon\ Containers/*/Data/Library/Saved\ Application\ State/ApplicationMapping.plist; do
    dir="$(dirname "${mapping}")"
    plutil -convert json -o - "${mapping}" |
        jq -r '. as $a | range(0; length)
               | select(($a[.] | objects | .protected.signingIdentifier) == "dev.antony.Koine")
               | $a[. + 1]' |
        while read -r uuid; do
            state="${dir}/${uuid}.savedState"
            [ -e "${state}" ] || continue
            echo "${state}"
            find "${state}" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort | sed 's/^/  /'
        done
done
