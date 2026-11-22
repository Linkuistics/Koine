#!/bin/bash
# The mutation controls of settings-scenario-controls-k164. Run from the
# repository root. Each case changes one copied file and runs the control that
# names the fault. The run exits 1 if any control misses its mutation. The
# surface scans carry their own mutations inside their tests.
set -u
scenario=Tests/scripts/vm-settings-scenario.bats
ui=Tests/scripts/vm-ui-evidence.bats
click=Tests/scripts/vm-click-evidence.bats
lib=scripts/vm-settings-scenario-lib.sh
main=scripts/vm-verify-menu-bar.sh
backend=scripts/vm-guest-exec.py
verify=scripts/vm-verify-lib.sh
input=scripts/vm-input-evidence-lib.sh
missed=0

# mutate NAME FILE OLD NEW FILTER SUITE...
mutate() {
    local name="$1" file="$2" old="$3" new="$4" filter="$5" work log
    shift 5
    work="$(mktemp -d)"
    mkdir -p "${work}/docs/verification/settings-activation"
    cp -R scripts Tests App "${work}/"
    cp -R docs/verification/settings-activation/ordering-scenario-evidence \
        "${work}/docs/verification/settings-activation/"
    OLD="${old}" NEW="${new}" python3 -I -c '
import os, pathlib, sys
path = pathlib.Path(sys.argv[1])
text = path.read_text()
if text.count(os.environ["OLD"]) != 1:
    sys.exit("the mutation target is not unique: " + os.environ["OLD"])
path.write_text(text.replace(os.environ["OLD"], os.environ["NEW"]))' "${work}/${file}" || {
        echo "== ${name}: NOT APPLIED"
        missed=1
        rm -rf "${work}"
        return
    }
    log="$(cd "${work}" && bats --filter "${filter}" "$@" 2>&1)"
    echo "== ${name}"
    grep -E '^(not )?ok ' <<<"${log}"
    if ! grep -q '^not ok ' <<<"${log}"; then
        echo "NOT DETECTED: ${name}"
        missed=1
    fi
    rm -rf "${work}"
}

mutate reveal-bound-61 "${lib}" 'index <= 60' 'index <= 61' 'exhausted reveal makes' "${scenario}"
mutate reveal-bound-59 "${lib}" 'index <= 60' 'index <= 59' 'exhausted reveal makes' "${scenario}"
mutate calibration-bound-29 "${lib}" 'index <= 30' 'index <= 29' 'the calibration sends' "${scenario}"
mutate calibration-bound-31 "${lib}" 'index <= 30' 'index <= 31' 'the calibration sends' "${scenario}"
mutate add-bound-14 "${lib}" 'tries >= 15' 'tries >= 14' 'missing Add button' "${scenario}"
mutate add-bound-16 "${lib}" 'tries >= 15' 'tries >= 16' 'missing Add button' "${scenario}"
mutate textedit-extra-read "${main}" 'settings_await_textedit_window textedit-window
' 'settings_await_textedit_window textedit-window
settings_windows textedit-extra >/dev/null
' 'TextEdit call makes' "${scenario}"
mutate on-screen-mode "${lib}" '"$2" optional-vertical)" || return' '"$2" optional)" || return' \
    'element modes' "${scenario}"
mutate calibration-mode "${lib}" "calibrate-before '.id==\"grant-label\"' position-y" \
    "calibrate-before '.id==\"grant-label\"' optional" 'element modes' "${scenario}"
mutate reveal-position-mode "${lib}" '"${operation}-${index}-position" "${condition}" position-y' \
    '"${operation}-${index}-position" "${condition}" optional-vertical' 'element modes' "${scenario}"
mutate silent-launch-count "${main}" 'settings_expect_koine_count silent-launch-windows 0' \
    'settings_expect_koine_count silent-launch-windows 1' 'window at the silent launch' "${scenario}"
mutate failed-read-as-negative "${lib}" '"$2" optional-vertical)" || return' \
    '"$2" optional-vertical)" || return 1' 'clean on-screen negative' "${scenario}"
mutate typed-status-3-clean "${backend}" '    if cli_status != 0:
        return f"CLI exit {cli_status}"' '    if cli_status == 3:
        return ""
    if cli_status != 0:
        return f"CLI exit {cli_status}"' 'typed .*_NOT_FOUND' "${ui}" "${click}"
mutate held-unavailable-as-clean "${lib}" 'if outcome != "clean":' \
    'if outcome not in {"clean", "unavailable"}:' 'clean drag reports' "${scenario}"
mutate held-partial-as-clean "${lib}" 'outcome = "partial"' 'outcome = "clean"' \
    'clean drag reports' "${scenario}"
mutate root-mode-755 "${backend}" 'os.chmod(root, 0o700)' 'os.chmod(root, 0o755)' \
    'consent run' "${scenario}"
mutate password-in-transcript "${lib}" 'settings_input() {
' 'settings_input() {
    echo "input: $*"
' 'consent run' "${scenario}"
mutate password-redacted "${input}" '    cli_guest_evidence "${root}" one-shot "${operation}" "${predicate}" -- input "${action}" "$@"' \
    '    [[ "${action}" != type ]] || set -- REDACTED
    cli_guest_evidence "${root}" one-shot "${operation}" "${predicate}" -- input "${action}" "$@"' \
    'consent run' "${scenario}"
mutate cleanup-trap-restored "${verify}" 'vm-verify-menu-bar.sh | vm-verify-menu-bar-prefix.sh) ;;' \
    'vm-verify-menu-bar.sh | vm-verify-menu-bar-prefix.sh) trap cleanup EXIT ;;' \
    'failed library load' "${scenario}"
mutate prefix-keeps-cleanup "${verify}" 'vm-verify-menu-bar.sh | vm-verify-menu-bar-prefix.sh) ;;' \
    'vm-verify-menu-bar.sh) ;;' 'failed library load' "${scenario}"
mutate other-script-loses-stop "${verify}" '*) trap cleanup EXIT ;;' '*) ;;' \
    'failed library load' "${scenario}"
echo "missed=${missed}"
exit "${missed}"
