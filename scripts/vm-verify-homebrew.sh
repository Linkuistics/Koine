#!/bin/bash
# Verifies the PUBLISHED Homebrew cask end to end on a TestAnyware macOS clone
# whose Gatekeeper assessments are ENABLED: `brew install --cask` downloads the
# tagged release from GitHub, Homebrew quarantines it as a download, Gatekeeper
# accepts the notarized bundle with nothing stripped, Koine launches through the
# first-run dialog, and `brew uninstall --cask` quits and removes it. Everything
# Koine leaves under ~/Library is enumerated after a run, after a plain
# uninstall and after `--zap`, as are its defaults domain, the saved window state
# macOS keeps for it and its Background Task Management entry, so the
# cask's `zap` list and the README's uninstall sentences are measured rather
# than assumed. Nothing here runs the application on the host, and nothing here
# uses the locally built bundle: what is installed is what a user downloads. The
# procedure and its recorded evidence: docs/verification/homebrew-install-vm.md
#
# KOINE_VM_KEEP=1 leaves the VM running afterwards, for inspection.
# KOINE_VM_PASSWORD is the VM account's password (the golden image's default: admin).
set -euo pipefail

cd "$(dirname "$0")/.."
# shellcheck source=scripts/signing-env.sh
source scripts/signing-env.sh

# shellcheck disable=SC2034  # both read by vm-verify-lib.sh
KOINE_VM_LOG_PREFIX="homebrew-"
# Tall enough for the Security section of the Privacy & Security pane, as in
# vm-verify-notarized.sh: enable_developer_id needs it on screen.
KOINE_VM_DISPLAY="1920x2160"
# shellcheck source=scripts/vm-verify-lib.sh
source scripts/vm-verify-lib.sh
# shellcheck source=scripts/vm-verify-desktop-lib.sh
source scripts/vm-verify-desktop-lib.sh
# shellcheck source=scripts/vm-verify-gatekeeper-lib.sh
source scripts/vm-verify-gatekeeper-lib.sh

CASK="linkuistics/taps/koine"
BREW="/opt/homebrew/bin/brew"

# guest_long <name> <local script>: runs a script that outlasts the agent's 30s
# exec window — a Homebrew install, a cask download — detached in the guest, and
# polls for its exit status. Its transcript is echoed into this run's log, and
# its status is returned. guest() silently retries an exec that falsely times
# out, and these scripts can not be repeated: one run's reinstall was launched
# twice, and the second `brew install` truncated the log to "Not upgrading
# koine". So the launch takes a guard directory, and a retried launch that finds
# it already taken starts nothing.
guest_long() {
    local name="$1" script="$2" status
    testanyware file upload "${script}" "/Users/admin/${name}.sh" >/dev/null
    guest "mkdir \$HOME/${name}.started 2>/dev/null || exit 0; nohup bash -c 'bash \$HOME/${name}.sh > \$HOME/${name}.log 2>&1; echo \$? > \$HOME/${name}.exit' >/dev/null 2>&1 &"
    for _ in $(seq 1 180); do
        if guest "[ -e \$HOME/${name}.exit ]" >/dev/null 2>&1; then break; fi
        sleep 5
    done
    guest "cat \$HOME/${name}.log" | sed 's/^/  | /'
    status="$(guest "cat \$HOME/${name}.exit" 2>/dev/null | tr -d '[:space:]')"
    [ -n "${status}" ] || fail "${name} did not finish within 15 minutes"
    return "${status}"
}

# footprint <when>: every path under the account's Library that names Koine,
# enumerated rather than checked against the zap list, so a file the cask does
# not know about is found rather than missed.
footprint() {
    step "What Koine leaves in ~/Library: $1"
    FOOTPRINT="$(guest "find \$HOME/Library -maxdepth 3 \\( -iname '*koine*' -o -iname 'dev.antony.Koine*' \\) 2>/dev/null | sort" || true)"
    echo "${FOOTPRINT:-  (nothing)}"
    # cfprefsd can hold a domain it has not yet written to disk, so the domain
    # list is asked as well as the file tree.
    DEFAULTS_DOMAIN="$(guest "defaults domains | tr ',' '\\n' | grep -i koine" || true)"
    echo "Defaults domain: ${DEFAULTS_DOMAIN:-(none)}"
    # Saved window state is outside the name search: see the helper. It is
    # reported, not asserted, because its UUID is the machine's own and no cask
    # `zap trash:` path can name it.
    SAVED_STATE="$(guest "bash \$HOME/vm-verify-saved-state.sh" || true)"
    echo "Saved window state: ${SAVED_STATE:-(none)}"
}

# login_item <when>: Koine's Background Task Management entry, which is what
# SMAppService.mainApp registers — not a System Events login item.
login_item() {
    step "Koine's Background Task Management entry: $1"
    LOGIN_ITEM="$(guest "echo ${VM_PASSWORD} | sudo -S sfltool dumpbtm 2>/dev/null | grep -i -B3 -A8 'dev.antony.Koine'" || true)"
    echo "${LOGIN_ITEM:-  (no entry names dev.antony.Koine)}"
}

start_vm
enforce_gatekeeper
testanyware file upload scripts/vm-verify-saved-state.sh /Users/admin/vm-verify-saved-state.sh >/dev/null

step "Homebrew in the guest"
if ! guest "[ -x ${BREW} ]" >/dev/null 2>&1; then
    # Homebrew's installer takes `sudo -A` when SUDO_ASKPASS is set, which lets
    # it run unattended with the account's password supplied by a helper.
    cat >"${WORK}/install-homebrew.sh" <<EOF
set -euo pipefail
printf '#!/bin/sh\necho %s\n' '${VM_PASSWORD}' > \$HOME/askpass.sh
chmod 700 \$HOME/askpass.sh
export SUDO_ASKPASS=\$HOME/askpass.sh NONINTERACTIVE=1
/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
rm -f \$HOME/askpass.sh
EOF
    guest_long install-homebrew "${WORK}/install-homebrew.sh" || fail "Homebrew did not install in the guest"
fi
guest "${BREW} --version | head -1"

step "brew install --cask ${CASK}"
cat >"${WORK}/cask-install.sh" <<EOF
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1
${BREW} install --cask ${CASK}
EOF
guest_long cask-install "${WORK}/cask-install.sh" || fail "brew install --cask failed"
guest "[ -d ${INSTALLED} ]" || fail "the cask installed no ${INSTALLED}"
INSTALLED_VERSION="$(guest "/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${INSTALLED}/Contents/Info.plist")"
echo "Installed version: ${INSTALLED_VERSION}"
[ "${INSTALLED_VERSION}" = "${MARKETING_VERSION}" ] ||
    fail "the cask installed ${INSTALLED_VERSION}, not this tree's ${MARKETING_VERSION}"

step "Homebrew quarantined the download, and nothing stripped it"
QUARANTINE_BEFORE="$(guest "xattr -p com.apple.quarantine ${INSTALLED}" 2>&1 || true)"
echo "Quarantine on the bundle: ${QUARANTINE_BEFORE}"
if [ -z "${QUARANTINE_BEFORE}" ] || grep -q 'No such xattr' <<<"${QUARANTINE_BEFORE}"; then
    fail "the installed bundle carries no quarantine, so the launch below would prove nothing"
fi

step "Gatekeeper's verdict on the installed bundle"
ASSESSMENT="$(guest "spctl -a -t execute -vv ${INSTALLED} 2>&1")" || fail "Gatekeeper rejected the installed bundle: ${ASSESSMENT}"
echo "${ASSESSMENT}"
grep -q 'source=Notarized Developer ID' <<<"${ASSESSMENT}" ||
    fail "accepted under a rule other than the notarized one"
! grep -q 'override=' <<<"${ASSESSMENT}" ||
    fail "accepted only because assessments are off, which is what this run exists to avoid"
guest "xcrun stapler validate ${INSTALLED} 2>&1" || fail "the installed bundle carries no stapled ticket"

# macOS's default "close windows when quitting" makes AppKit save no window
# state, so a footprint measured under it would never show
# ~/Library/Saved Application State. Window restoration is turned on for the
# account, so the footprint is the most any user's posture produces.
guest "defaults write -g NSQuitAlwaysKeepsWindows -bool true"

first_launch_quarantined
grep -q 'none was detected' <<<"${DIALOG_TREE}" ||
    fail "the first-run dialog does not report that Apple checked the app; this is not the notarized path"
await_service
guest "cat \"${DATA}/endpoint.json\"; echo"

step "Enable login launch in the window, so uninstall has a registration to leave or take"
echo "Before: $(value_of '.id=="login-launch-status"')"
click '.id=="login-launch"'
[ "$(value_of '.id=="login-launch"')" = 1 ] || fail "the login-launch toggle did not turn on"
echo "After:  $(value_of '.id=="login-launch-status"')"
login_item "installed, running, login launch on"
footprint "installed and running"

step "brew uninstall --cask koine, with Koine running"
cat >"${WORK}/cask-uninstall.sh" <<EOF
export HOMEBREW_NO_AUTO_UPDATE=1
${BREW} uninstall --cask koine
EOF
guest_long cask-uninstall "${WORK}/cask-uninstall.sh" || fail "brew uninstall --cask failed"
guest "! pgrep -f ${INSTALLED}/Contents/MacOS" >/dev/null || fail "Koine still runs after uninstall"
guest "[ ! -e ${INSTALLED} ]" || fail "${INSTALLED} is still there after uninstall"
echo "Koine quit and ${INSTALLED} removed."
footprint "after a plain uninstall"
guest "[ -d \"${DATA}\" ]" || fail "a plain uninstall removed Koine's data directory; only --zap should"
login_item "after a plain uninstall"

step "Reinstall, then brew uninstall --zap --cask koine"
guest_long cask-reinstall "${WORK}/cask-install.sh" || fail "the second brew install --cask failed"
guest "[ -d ${INSTALLED} ]" || fail "the reinstall put no ${INSTALLED} back, so --zap below would uninstall nothing"
cat >"${WORK}/cask-zap.sh" <<EOF
export HOMEBREW_NO_AUTO_UPDATE=1
${BREW} uninstall --zap --cask koine
EOF
guest_long cask-zap "${WORK}/cask-zap.sh" || fail "brew uninstall --zap --cask failed"
guest "[ ! -e ${INSTALLED} ]" || fail "${INSTALLED} is still there after --zap"
footprint "after --zap"
[ -z "${FOOTPRINT}" ] || fail "--zap left paths naming Koine under ~/Library"
[ -z "${DEFAULTS_DOMAIN}" ] || fail "--zap left Koine's defaults domain"
login_item "after --zap"

step "Result"
echo "brew install --cask ${CASK} installed ${MARKETING_VERSION}, Gatekeeper accepted it as"
echo "notarized with its quarantine intact, Koine launched and served, and uninstall and"
echo "--zap removed it. Transcript: ${LOG}"
