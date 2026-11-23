# shellcheck shell=bash
# Source-only VM start, exact stop and inventory evidence. Caller adoption,
# the slot budget and containment stay with the scenario and the finite caller.
# Payload shapes come from the tagged handlers:
# https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-cli/src/commands/vm.rs
# https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-vm/src/listing.rs
# shellcheck source=scripts/vm-guest-exec-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-guest-exec-lib.sh"

_lifecycle_root() {
    [[ -n "$1" && -f "$1/subject.json" ]] || {
        echo 'lifecycle evidence requires an initialized nonempty root' >&2
        return 125
    }
}

# The pinned identity as a JSON string. init_guest_evidence admits only plain
# identities, so the value needs no further quoting in a predicate.
_lifecycle_vm_json() {
    jq -ce '.vm | select(type == "string" and test("^[A-Za-z0-9][A-Za-z0-9_.-]*$"))' "$1/subject.json"
}

# start_guest_vm ROOT OPERATION BASE [WIDTHxHEIGHT[@2x]]
# One one-shot start of a macOS clone of an explicit golden BASE. The original
# bare --wait stays. The adapter appends the pinned --id and --json.
start_guest_vm() {
    local root="${1-}" operation="${2-}" base="${3-}" display="${4-}" vm predicate
    _lifecycle_root "${root}" || return
    if [[ ($# != 3 && $# != 4) || -z "${operation}" ||
        ! "${base}" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ||
        ($# == 4 && ! "${display}" =~ ^[1-9][0-9]*x[1-9][0-9]*(@2x)?$) ]]; then
        fail_guest_evidence "${root}" "${operation:-start-arguments}" \
            'expected ROOT OPERATION BASE [WIDTHxHEIGHT[@2x]]'
        return
    fi
    vm="$(_lifecycle_vm_json "${root}")" || {
        fail_guest_evidence "${root}" "${operation}" 'initialized VM identity is unreadable'
        return
    }
    # The agent endpoint is required: every later transport uses it.
    predicate="def port: type == \"number\" and floor == . and . > 0 and . <= 65535;
        def endpoint: type == \"object\" and keys == [\"host\", \"port\"]
            and (.host | type == \"string\" and length > 0) and (.port | port);
        def path: type == \"string\" and length > 0;
        def tpm: type == \"object\" and (
            (keys == [\"attached\", \"ppi_off\"] and .attached == true and (.ppi_off | type == \"boolean\"))
            or (keys == [\"attached\", \"reason\"] and .attached == false
                and (.reason == \"guest_does_not_need_one\" or .reason == \"host_cannot_supply_one\")));
        (keys - [\"tpm\"]) == [\"agent\", \"base\", \"id\", \"meta_path\", \"ok\", \"platform\",
            \"schema_version\", \"spec_path\", \"vnc\"]
        and .id == ${vm} and .platform == \"macos\" and .base == \"${base}\"
        and (.vnc | endpoint) and (.agent | endpoint)
        and (.spec_path | path) and (.meta_path | path)
        and ((has(\"tpm\") | not) or (.tpm | tpm))"
    set -- vm start --platform macos --wait --base "${base}"
    [[ -z "${display}" ]] || set -- "$@" --display "${display}"
    cli_guest_evidence "${root}" one-shot "${operation}" "${predicate}" -- "$@"
}

# stop_guest_vm ROOT OPERATION
# One evidence-class stop of the pinned clone. It stays callable after a latch
# and never clears it. The caller owns the single stop budget.
stop_guest_vm() {
    local root="${1-}" operation="${2-}" vm
    _lifecycle_root "${root}" || return
    if [[ $# != 2 || -z "${operation}" ]]; then
        fail_guest_evidence "${root}" "${operation:-stop-arguments}" 'expected ROOT OPERATION'
        return
    fi
    vm="$(_lifecycle_vm_json "${root}")" || {
        fail_guest_evidence "${root}" "${operation}" 'initialized VM identity is unreadable'
        return
    }
    cli_guest_evidence "${root}" evidence "${operation}" \
        "keys == [\"id\", \"ok\", \"schema_version\", \"stopped\"] and .id == ${vm} and .stopped == true" \
        -- vm stop "$(jq -r . <<<"${vm}")"
}

# inventory_guest_vms ROOT {read-poll,evidence} OPERATION {running,absent}
# One complete clone list. Only an untruncated list with exact rows can say
# that the pinned clone is running once or is absent.
inventory_guest_vms() {
    local root="${1-}" kind="${2-}" operation="${3-}" expected="${4-}" vm count predicate
    _lifecycle_root "${root}" || return
    if [[ $# != 4 || -z "${operation}" || ("${kind}" != read-poll && "${kind}" != evidence) ||
        ("${expected}" != running && "${expected}" != absent) ]]; then
        fail_guest_evidence "${root}" "${operation:-inventory-arguments}" \
            'expected ROOT read-poll|evidence OPERATION running|absent'
        return
    fi
    vm="$(_lifecycle_vm_json "${root}")" || {
        fail_guest_evidence "${root}" "${operation}" 'initialized VM identity is unreadable'
        return
    }
    count=0
    [[ "${expected}" != running ]] || count=1
    predicate="def optional_text: . == null or type == \"string\";
        def item: type == \"object\"
            and keys == [\"agent\", \"backend\", \"kind\", \"name\", \"pid\", \"platform\", \"vnc\"]
            and (.kind == \"golden\" or .kind == \"running\")
            and (.name | type == \"string\" and length > 0)
            and (.platform | type == \"string\") and (.backend | type == \"string\")
            and (.pid == null or (.pid | type == \"number\" and floor == .))
            and (.vnc | optional_text) and (.agent | optional_text);
        keys == [\"items\", \"ok\", \"returned\", \"schema_version\", \"total\", \"truncated\"]
        and (.items | type == \"array\" and all(.[]; item))
        and .truncated == false and .returned == .total and (.items | length) == .total
        and ([.items[] | select(.kind == \"running\" and .name == ${vm})] | length) == ${count}"
    cli_guest_evidence "${root}" "${kind}" "${operation}" "${predicate}" -- vm list --all
}
