#!/bin/bash
# The mutation controls of settings-clone-provenance-k180. Run from the
# repository root. Each case changes one copied file and runs the controls that
# name the guard. The run exits 1 if any control misses its mutation.
set -u
exec_suite=Tests/scripts/vm-guest-exec.bats
scenario=Tests/scripts/vm-settings-scenario.bats
audits=Tests/scripts/vm-settings-audits.bats
backend=scripts/vm-guest-exec.py
lib=scripts/vm-settings-scenario-lib.sh
caller=scripts/settings-ordering-sequence.py
missed=0

# mutate NAME FILE OLD NEW FILTER SUITE...
mutate() {
    local name="$1" file="$2" old="$3" new="$4" filter="$5" work log
    shift 5
    work="$(mktemp -d)"
    cp -R scripts Tests App "${work}/"
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

# The declared executables.
mutate relative-cli-accepted "${backend}" 'if not path.is_absolute():
        raise ValueError(f"the declared' 'if False:
        raise ValueError(f"the declared' 'init refuses an undeclared' "${exec_suite}"
mutate linked-cli-followed "${backend}" 'identity = inspect_file(path)
    if not os.access' 'identity = inspect_file(path.resolve())
    if not os.access' 'init refuses an undeclared' "${exec_suite}"
mutate unrunnable-cli-accepted "${backend}" 'if not os.access(path, os.X_OK):' 'if False:' \
    'init refuses an undeclared' "${exec_suite}"
mutate undeclared-jq-searched "${backend}" 'text = os.environ.get(variable, "")' \
    'text = os.environ.get(variable, "") or f"/usr/bin/{name}"' 'init refuses an undeclared' "${exec_suite}"
mutate executable-check-skipped "${backend}" 'pre_dispatch = executable_problem(executables) or pre_dispatch' \
    'pre_dispatch = pre_dispatch' 'a changed, replaced or missing' "${exec_suite}"
mutate inode-ignored "${backend}" 'IDENTITY_FIELDS = ("path", "bytes", "sha256", "device", "inode")' \
    'IDENTITY_FIELDS = ("path", "bytes", "sha256", "device")' 'a changed, replaced or missing' "${exec_suite}"
mutate bare-cli-name "${backend}" 'argv = [cli, "file", "exec", "--vm", vm, "--json", "--", command]
    expected' 'argv = ["testanyware", "file", "exec", "--vm", vm, "--json", "--", command]
    expected' 'each attempt runs the declared' "${exec_suite}"
mutate bare-jq-name "${backend}" '[jq, "-e", f"[({predicate})] == [true]"]' \
    '["jq", "-e", f"[({predicate})] == [true]"]' 'each attempt runs the declared' "${exec_suite}"

# The clone provenance in the adapter.
mutate second-provenance-replaces "${backend}" \
    'write_json(root / PROVENANCE, {**spec_mapping(vm), "ordinal": ordinal})' \
    '(root / PROVENANCE).unlink(missing_ok=True)
                write_json(root / PROVENANCE, {**spec_mapping(vm), "ordinal": ordinal})' \
    'the clone provenance records' "${exec_suite}"
mutate provenance-before-start "${backend}" 'if not vm_started:' 'if False:' \
    'provenance refuses before' "${exec_suite}"
mutate provenance-after-guest "${backend}" 'elif guest_seen:' 'elif False:' \
    'provenance refuses before' "${exec_suite}"
mutate unbound-guest-transport "${backend}" 'elif vm_started:' 'elif False:' \
    'needs a provenance record' "${exec_suite}"
mutate spec-check-skipped "${backend}" 'pre_dispatch = provenance_problem(root, vm)' \
    'pre_dispatch = ""' 'a missing, changed or different spec' "${exec_suite}"
mutate path-blind-spec-check "${backend}" 'if recorded.get(key) != value]' \
    'if key == "agent" and recorded.get(key) != value]' 'a missing, changed or different spec' "${exec_suite}"
mutate lifecycle-as-guest "${backend}" 'return "--vm" in options' \
    'return "--vm" in options or options[1:2] == ["vm"]' 'k180' "${exec_suite}"
mutate configuration-unchecked "${backend}" 'if not empty_configuration(text.decode("utf-8")):' \
    'if False:' 'cannot evaluate' "${exec_suite}"
mutate comments-not-nested "${backend}" 'depth += 1 if pair == "/*" else -1' 'depth -= 1' \
    'cannot evaluate' "${exec_suite}"
mutate other-app-accepted "${backend}" 'if os.environ.get("TESTANYWARE_APP_SOCKET"):' 'if False:' \
    'cannot evaluate' "${exec_suite}"
mutate relative-state-accepted "${backend}" 'if variable and not Path(variable).is_absolute():' \
    'if False:' 'cannot evaluate' "${exec_suite}"
mutate relative-config-accepted "${backend}" 'if not file.is_absolute():' 'if False:' \
    'cannot evaluate' "${exec_suite}"
mutate missing-home-accepted "${backend}" 'if not Path(home).is_absolute():' 'if False:' \
    'cannot evaluate' "${exec_suite}"
mutate agentless-spec-accepted "${backend}" \
    'if not (isinstance(host, str) and host and type(port) is int and 0 < port < 65536):' \
    'if False:' 'cannot evaluate' "${exec_suite}"

# The scenario. Its targets hold literal shell text.
# shellcheck disable=SC2016
mutate provenance-not-recorded "${lib}" '    record_guest_provenance "${KOINE_VM_EVIDENCE_ROOT}" clone-provenance ||
        settings_stop "$?" "the provenance of the clone ${VM_ID} could not be recorded"
' '' 'k180' "${scenario}"
# shellcheck disable=SC2016
mutate scenario-jq-unpinned "${lib}" '    jq() { "${KOINE_JQ}" "$@"; }
' '' 'between the inventory' "${scenario}"
mutate provenance-failure-ignored "${lib}" 'clone-provenance ||
        settings_stop' 'clone-provenance ||
        : settings_stop' 'failed clone provenance' "${scenario}"

# The finite caller.
mutate frozen-executables-unchecked "${caller}" \
    'if len(items) != 1 or items[0]["path"] != "." or items[0]["kind"] != "file":' 'if False:' \
    'a receipt without both' "${audits}"
mutate frozen-relative-paths "${caller}" 'isinstance(path, str) and Path(path).is_absolute()' \
    'isinstance(path, str)' 'a receipt without both' "${audits}"
mutate executables-not-passed "${caller}" 'self.environment[variable] = cast(str, tree["root"])' \
    'pass' 'the run passes the frozen' "${audits}"
mutate subject-without-provenance "${caller}" \
    '("provenance", provenance_check(root, frozen, clone, absent)["result"]),' '' \
    'other frozen paths' "${audits}"
mutate missing-record-counted "${caller}" 'if len(records) != 1:' 'if len(records) > 1:' \
    'without a provenance record' "${audits}"
mutate attempt-cli-unchecked "${caller}" 'if words and words[0] != roots["testanyware"]:' 'if False:' \
    'other frozen paths' "${audits}"
mutate attempt-jq-unchecked "${caller}" 'if "jq" in request and request["jq"] != roots["jq"]:' 'if False:' \
    'other frozen paths' "${audits}"
mutate subject-executables-unchecked "${caller}" \
    'failed.append(f"subject.json records another {name} executable")' 'pass' \
    'other frozen paths' "${audits}"
mutate order-unchecked "${caller}" \
    'if min(starts) > ordinal or any(guest < ordinal for guest in guests):' 'if False:' \
    'ordered before' "${audits}"
mutate ordinal-unchecked "${caller}" '"ordinal": ordinal,
        "vm": clone,' '"ordinal": record.get("ordinal"),
        "vm": clone,' 'ordered before' "${audits}"
mutate spec-path-unchecked "${caller}" '"spec path": f"{state}/vms/{clone}.json",' \
    '"spec path": cast(Json, record.get("spec") or {}).get("path"),' 'other frozen paths' "${audits}"

exit "${missed}"
