# shellcheck shell=bash
# Source-only keyboard/text/scroll migration seam. Explicit roots select strict
# evidence; unset retains existing VM consumers until complete scenario adoption.
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

# scenario_input OPERATION {key KEY [--modifiers CSV]|type TEXT|scroll X Y --dy=N}
# Only transport/payload is confirmed here, not the downstream UI consequence.
scenario_input() {
    local operation="${1-}" action="${2-}" root="${KOINE_VM_EVIDENCE_ROOT:-}" predicate=''
    if [[ ! "${KOINE_VM_EVIDENCE_ROOT+x}" ]]; then
        shift
        testanyware input "$@"
        return "$?"
    fi
    [[ -n "${root}" && -f "${root}/subject.json" ]] || {
        echo 'input evidence requires an initialized nonempty root' >&2
        return 125
    }
    if [[ $# -ge 2 && -n "${operation}" ]]; then
        shift 2
        # Payloads and comma-delimited modifiers follow the immutable release.
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/input.rs
        # https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/main.rs
        case "${action}" in
        key)
            if [[ $# == 1 || ($# == 3 && "$2" == --modifiers && "$3" =~ ^[^,]+(,[^,]+)*$) ]] &&
                [[ -n "$1" && "$1" != -* ]]; then
                predicate="$(jq -rn --arg key "$1" --arg mods "${3-}" '
                    ".key == \($key | tojson) and .modifiers == \((if $mods == "" then [] else $mods | split(",") end) | tojson)"')" || {
                    fail_guest_evidence "${root}" "${operation}" 'key predicate encoding failed'
                    return "$?"
                }
            fi
            ;;
        type)
            if [[ $# == 1 && "$1" != -* ]]; then
                # jq length counts Unicode scalars, as Rust str.chars().count().
                predicate="$(jq -rn --arg text "$1" '
                    ".text == \($text | tojson) and .chars == \($text | length)"')" || {
                    fail_guest_evidence "${root}" "${operation}" 'text predicate encoding failed'
                    return "$?"
                }
            fi
            ;;
        scroll)
            local dy="${3-}"
            dy="${dy#--dy=}"
            if [[ $# == 3 && "$1" =~ ^(0|[1-9][0-9]{0,4})$ && "$2" =~ ^(0|[1-9][0-9]{0,4})$ &&
                "$3" =~ ^--dy=-?(0|[1-9][0-9]{0,9})$ ]] &&
                (($1 <= 65535 && $2 <= 65535 && dy >= -2147483648 && dy <= 2147483647)); then
                predicate=".x == $1 and .y == $2 and .dx == 0 and .dy == ${dy}"
            fi
            ;;
        esac
    fi
    if [[ -z "${predicate}" ]]; then
        fail_guest_evidence "${root}" "${operation:-input-arguments}" 'invalid keyboard/text/scroll arguments'
        return "$?"
    fi
    cli_guest_evidence "${root}" one-shot "${operation}" "${predicate}" -- input "${action}" "$@"
}
