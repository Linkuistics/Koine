#!/bin/bash
# Runs IN THE GUEST (scripts/vm-verify-open-path.sh uploads and runs it): the disposable
# fixtures workspaceOpenPath is accepted against. Nothing here is part of Koine, and nothing
# is under Desktop, Documents or Downloads (the protected folders, whose default-handler
# lookup is pending a human decision). The names are the host script's constants; it checks
# every path it submits against what exists here before it relies on the case.
#
#   /tmp/koine-open-path/plain note.txt   a temporary text file (/tmp is itself a symlink)
#   ~/open-path-fx/                       everything else
#   ~/.config/modaliser/                  the configuration directory (Client settings)
#
# Run as: vm-open-path-fixtures.sh <make-alias binary> (the alias maker is compiled by the host script).
set -euo pipefail

ALIAS_MAKER="${1:?usage: vm-open-path-fixtures.sh <make-alias binary>}"
FX="${HOME}/open-path-fx"

# Idempotent: the agent's exec channel can run a command twice, and the second run meets
# the first run's directory with no permissions (`locked`), which must be reopened to be removed.
chmod -R u+rwx "${FX}" 2>/dev/null || true
rm -rf /tmp/koine-open-path "${FX}" "${HOME}/.config/modaliser"

mkdir -p /tmp/koine-open-path "${FX}" "${FX}/markers" "${HOME}/.config/modaliser"
printf 'a temporary text file\n' >"/tmp/koine-open-path/plain note.txt"

cd "${FX}"
# --- documents, a directory and a document package ---------------------------------------
printf 'a plain text document\n' >"real-note.txt"
mkdir -p "A Folder"
printf 'inside the folder\n' >"A Folder/inner note.txt"
mkdir -p "Package Doc.rtfd"
printf '{\\rtf1\\ansi a document package}\n' >"Package Doc.rtfd/TXT.rtf"

# --- literal characters: spaces and shell punctuation, Unicode in the decomposed form ----
printf 'shell punctuation stays literal\n' >"lit \$HOME ~ * ? [x] ; & ' \" # % ! (1).txt"
printf 'unicode\n' >"$(printf 'cafe\xcc\x81 \xe6\x97\xa5\xe6\x9c\xac.txt')"

# --- links --------------------------------------------------------------------------------
ln -s "real-note.txt" "link-to-note.txt"
ln -s "A Folder" "link-to-dir"
mkdir -p "Link Target"
printf 'inside the linked folder\n' >"Link Target/linked note.txt"
ln -s "Link Target" "link-to-folder"
ln -s "does-not-exist-anywhere" "link-to-nowhere"
ln -s "/Applications/Zed.app" "link-to-app"

# --- source scripts, with and without executable bits ----------------------------------------
for ext in swift py js; do
    printf '// a source script with an executable bit\nprint("src")\n' >"src-exec.${ext}"
    printf '// a source script without one\nprint("src")\n' >"src-plain.${ext}"
    chmod 0755 "src-exec.${ext}"
    chmod 0644 "src-plain.${ext}"
done

# --- refused payloads: programs and Finder alias files ----------------------------------------
cp /bin/ls "prog-machO"
printf 'MZ\0\0 not a real program, a Windows executable by type\n' >"setup.exe"
"${ALIAS_MAKER}" "${FX}/real-note.txt" "${FX}/alias-to-note"
"${ALIAS_MAKER}" "/Applications/Zed.app" "${FX}/alias-to-app"
"${ALIAS_MAKER}" "${FX}/A Folder" "${FX}/alias-to-folder"

# --- dependencies: no handler, and a path whose inspection is denied -------------------------
printf 'no application knows this type\n' >"no-handler.unknownzzz"
mkdir -p "locked"
printf 'unreachable\n' >"locked/secret.txt"
chmod 000 "locked"

# --- the handlers' reactions (disclosed, not prevented) --------------------------------------
# Each script only writes a marker file, so that what a handler did can be read afterwards.
printf '#!/bin/bash\ndate +%%s > "%s/markers/term-command"\n' "${FX}" >"react-term.command"
printf '#!/bin/bash\ndate +%%s > "%s/markers/term-command-plain"\n' "${FX}" >"react-term-plain.command"
printf '#!/bin/bash\ndate +%%s > "%s/markers/shell-script"\n' "${FX}" >"react-shell.sh"
printf '#!/bin/bash\ndate +%%s > "%s/markers/shell-script-plain"\n' "${FX}" >"react-shell-plain.sh"
chmod 0755 "react-term.command" "react-shell.sh"
chmod 0644 "react-term-plain.command" "react-shell-plain.sh"
plist() {
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict><key>URL</key><string>%s</string></dict></plist>\n' "$1"
}
plist "http://koine-url.test:8765/from-webloc" >"loc-http.webloc"
printf 'the target of a location document\n' >"fileloc target.txt"
plist "file://${FX}/fileloc%20target.txt" >"loc-file.fileloc"

# --- the configuration directory ---------------------------------------------------------------
printf '(define settings-fixture "a disposable configuration directory")\n' >"${HOME}/.config/modaliser/config.scm"

# What exists, one line each, for the transcript.
find /tmp/koine-open-path "${FX}" "${HOME}/.config/modaliser" -maxdepth 1 -print0 2>/dev/null | sort -z | xargs -0 ls -ldO 2>/dev/null || true
