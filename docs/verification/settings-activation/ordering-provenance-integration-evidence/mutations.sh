#!/bin/bash
# The mutation controls of settings-clone-provenance-k182. Run from the
# repository root. Each case changes one copied file and runs the controls that
# name the guard. The run exits 1 if any control misses its mutation.
set -u
exec_suite=Tests/scripts/vm-guest-exec.bats
audits=Tests/scripts/vm-settings-audits.bats
backend=scripts/vm-guest-exec.py
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

# The start reply in the adapter.
mutate start-reply-ignored "${backend}" \
    'return f"the clone spec mapping differs from the start reply: {differences}"' 'return ""' \
    'one start reply' "${exec_suite}"
mutate start-agent-ignored "${backend}" \
    'for name, value in (("agent", mapping["agent"]), ("spec_path", spec["path"]))' \
    'for name, value in (("spec_path", spec["path"]),)' 'one start reply' "${exec_suite}"
mutate start-spec-path-ignored "${backend}" \
    'for name, value in (("agent", mapping["agent"]), ("spec_path", spec["path"]))' \
    'for name, value in (("agent", mapping["agent"]),)' 'one start reply' "${exec_suite}"
mutate second-start-accepted "${backend}" 'elif len(starts) > 1:' 'elif False:' \
    'one start reply' "${exec_suite}"
mutate record-without-start "${backend}" '{**mapping, "start": start, "ordinal": ordinal}' \
    '{**mapping, "ordinal": ordinal}' 'the clone provenance records' "${exec_suite}"

# The k180 adapter guards whose text k182 changed.
mutate provenance-before-start "${backend}" 'if not starts:' 'if False:' \
    'provenance refuses before' "${exec_suite}"
mutate unbound-guest-transport "${backend}" 'elif starts:' 'elif False:' \
    'needs a provenance record' "${exec_suite}"
mutate second-provenance-replaces "${backend}" '                    write_json(
                        root / PROVENANCE,' '                    (root / PROVENANCE).unlink(missing_ok=True)
                    write_json(
                        root / PROVENANCE,' 'the clone provenance records' "${exec_suite}"

# The check after each attempt.
mutate after-executables-skipped "${backend}" 'after = executable_problem(executables)' 'after = ""' \
    'a change during an attempt' "${exec_suite}"
mutate after-spec-skipped "${backend}" 'after = provenance_problem(root, vm)' 'after = ""' \
    'a change during an attempt' "${exec_suite}"
mutate after-reason-dropped "${backend}" 'reason = f"after the attempt, {after}" if after else ""' \
    'reason = ""' 'a change during an attempt' "${exec_suite}"

# The record in the finite caller.
mutate record-fields-unchecked "${caller}" \
    'problems = [] if set(record) == PROVENANCE_FIELDS else ["fields"]' 'problems: list[str] = []' \
    'without its endpoint' "${audits}"
mutate spec-digest-unchecked "${caller}" 'and digest(spec.get("sha256"))' 'and True' \
    'without its endpoint' "${audits}"
mutate record-agent-unchecked "${caller}" 'problems.append("agent")' 'pass' \
    'without its endpoint' "${audits}"
mutate record-environment-unchecked "${caller}" 'problems.append("environment")' 'pass' \
    'without its endpoint' "${audits}"
mutate record-state-unchecked "${caller}" 'problems.append("state")' 'pass' \
    'without its endpoint' "${audits}"
mutate record-config-unchecked "${caller}" 'problems.append("config")' 'pass' \
    'without its endpoint' "${audits}"
mutate record-start-unchecked "${caller}" 'problems.append("start")' 'pass' \
    'without its endpoint' "${audits}"
mutate record-ordinal-unchecked "${caller}" 'problems.append("ordinal or vm")' 'pass' \
    'without its endpoint' "${audits}"
mutate start-attempt-unchecked "${caller}" \
    'begun not in starts or outcomes[begun] != "clean"' 'False' 'without its endpoint' "${audits}"
mutate start-reply-uncompared "${caller}" 'different.append("start reply")' 'pass' \
    'without its endpoint' "${audits}"

exit "${missed}"
