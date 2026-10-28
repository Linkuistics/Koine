#!/usr/bin/env bats

setup() {
    export sample_root="${BATS_TEST_TMPDIR}/repo"
    export calls="${BATS_TEST_TMPDIR}/calls"
    export fixture_evidence="${sample_root}/docs/verification/settings-activation"
    mkdir -p "${fixture_evidence}" "${sample_root}/bin" "${sample_root}/.build/settings-activation/diagnostic/Koine.app"
    cp "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/run.sh" "${sample_root}/run.sh"
    cp "${BATS_TEST_DIRNAME}/../../docs/verification/settings-activation/inventory.sh" "${fixture_evidence}/inventory.sh" 2>/dev/null || true
    cd "${sample_root}"
    printf 'subject\n' > .build/settings-activation/diagnostic/Koine.app/subject
    ln -s subject .build/settings-activation/diagnostic/Koine.app/current
    shasum -a 256 .build/settings-activation/diagnostic/Koine.app/subject > "${fixture_evidence}/diagnostic-subjects.sha256"
    if [ -f "${fixture_evidence}/inventory.sh" ]; then
        bash "${fixture_evidence}/inventory.sh" .build/settings-activation/diagnostic/Koine.app > "${fixture_evidence}/diagnostic-bundle.txt"
    fi
    : > "${calls}"
    cat > bin/mise <<'SH'
#!/bin/bash
echo scenario >> "${calls}"
echo 'fixture' > .build/vm-verify/menu-bar-fixture.log
echo "${scenario_status:-0}" > "${KOINE_K4_OUT}/scenario.exit"
case "${mutate:-none}" in
add) echo added > "${KOINE_APP_BUNDLE}/extra" ;;
link) ln -sf other "${KOINE_APP_BUNDLE}/current" ;;
interrupt) kill -TERM "$PPID" ;;
esac
if [ "${scenario_status:-0}" != 0 ]; then exit 201; fi
SH
    cat > bin/testanyware <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "${calls}"
if [[ "$*" == 'file exec --json bash /Users/admin/k12-inventory.sh '* ]]; then
    if [ "${installed_changed:-0}" = 1 ]; then
        jq -n '{ok:true,exit_code:0,timed_out:false,stdout:"changed\n"}'
    else
        jq -n --rawfile output "${fixture_evidence}/diagnostic-bundle.txt" \
          '{ok:true,exit_code:0,timed_out:false,stdout:$output}'
    fi
else
    echo '{"ok":true}'
fi
SH
    chmod +x bin/*
    export PATH="${sample_root}/bin:${PATH}"
}

@test "an early scenario failure still audits the installed endpoint and stops the guest" {
    export scenario_status=1
    run bash run.sh diagnostic 01
    [[ "${status}" == 201 ]]
    [[ -s .build/settings-activation/diagnostic/01/installed-after.json ]]
    [[ "$(cat .build/settings-activation/diagnostic/01/audit.exit)" == 0 ]]
    [[ "$(tail -1 "${calls}")" == 'vm stop koine-k12-diagnostic-01 --json' ]]
}

@test "an added bundle file fails the complete inventory audit" {
    export mutate=add
    run bash run.sh diagnostic 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/diagnostic/01/audit.exit)" == 1 ]]
    [[ -s .build/settings-activation/diagnostic/01/bundle-diff.txt ]]
}

@test "a changed symlink fails the complete inventory audit" {
    export mutate=link
    run bash run.sh diagnostic 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/diagnostic/01/audit.exit)" == 1 ]]
    [[ -s .build/settings-activation/diagnostic/01/bundle-diff.txt ]]
}

@test "a changed installed endpoint fails even after a passing scenario" {
    export installed_changed=1
    run bash run.sh diagnostic 01
    [[ "${status}" != 0 ]]
    [[ "$(cat .build/settings-activation/diagnostic/01/audit.exit)" == 1 ]]
    [[ -s .build/settings-activation/diagnostic/01/installed-diff.txt ]]
}

@test "an interrupted attempt collects trace and artifacts before stopping without replay" {
    export mutate=interrupt
    run bash run.sh diagnostic 01
    [[ "${status}" == 143 ]]
    [[ -f .build/settings-activation/diagnostic/01/trace-download.txt ]]
    [[ -f .build/settings-activation/diagnostic/01/menu-bar-fixture.log ]]
    [[ -f .build/settings-activation/diagnostic/01/host-after.txt ]]
    [[ "$(grep -c '^scenario$' "${calls}")" == 1 ]]
    [[ "$(tail -1 "${calls}")" == 'vm stop koine-k12-diagnostic-01 --json' ]]
}
