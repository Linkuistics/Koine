#!/usr/bin/env bats

setup() {
  export sample_root="${BATS_TEST_TMPDIR}/repo"
  export calls="${BATS_TEST_TMPDIR}/calls"
  mkdir -p "${sample_root}/docs/verification/menu-bar-samples" "${sample_root}/bin"
  cp "${BATS_TEST_DIRNAME}/../../docs/verification/menu-bar-samples/run.sh" "${sample_root}/run.sh"
  cd "${sample_root}"
  printf 'subject\n' > subject
  shasum -a 256 subject > docs/verification/menu-bar-samples/subjects-before.sha256
  printf '#!/bin/bash\nshasum -a 256 subject\n' > docs/verification/menu-bar-samples/inventory.sh
  printf '#!/bin/bash\n:\n' > docs/verification/menu-bar-samples/links.sh
  : > docs/verification/menu-bar-samples/links-before.txt
  : > "${calls}"
  cat > bin/mise <<'SH'
#!/bin/bash
echo scenario >> "${calls}"
echo '== fixture' > .build/vm-verify/menu-bar-fixture.log
echo "${scenario_status:-0}" > "${KOINE_K4_OUT}/scenario.exit"
if [ "${mutate:-0}" = 1 ]; then echo changed > subject; fi
if [ "${scenario_status:-0}" != 0 ]; then exit 201; fi
SH
  cat > bin/testanyware <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "${calls}"
if [ "${observer_error:-0}" = 1 ] && [[ "$*" == 'file exec --json chmod '* ]]; then exit 7; fi
echo '{"ok":true}'
SH
  chmod +x bin/*
  export PATH="${sample_root}/bin:${PATH}"
  printf '%s\n' "${PATH}" > docs/verification/menu-bar-samples/tool-path.txt
}

@test "invalid attempt is refused before scenario or VM cleanup" {
  run bash run.sh 05 0.4.0
  [[ "${status}" == 2 ]]
  [[ ! -s "${calls}" ]]
}

@test "a successful attempt records both exits and artifacts, cleans up, and refuses overwrite" {
  run bash run.sh 01 0.3.0
  [[ "${status}" == 0 ]]
  [[ "$(cat .build/menu-samples/results/01/scenario.exit)" == 0 ]]
  [[ "$(cat .build/menu-samples/results/01/task.exit)" == 0 ]]
  [[ -f .build/menu-samples/results/01/menu-bar-fixture.log ]]
  [[ "$(tail -1 "${calls}")" == 'vm stop koine-k4-01 --json' ]]
  ! grep -q activation-snapshot "${calls}"
  run bash run.sh 01 0.3.0
  [[ "${status}" != 0 ]]
  [[ "$(grep -c '^scenario$' "${calls}")" == 1 ]]
}

@test "scenario failure collects read-only native and window evidence before cleanup without retry" {
  export scenario_status=1
  run bash run.sh 02 0.4.0
  [[ "${status}" == 201 ]]
  [[ "$(cat .build/menu-samples/results/02/scenario.exit)" == 1 ]]
  [[ "$(cat .build/menu-samples/results/02/task.exit)" == 201 ]]
  [[ "$(grep -c '^scenario$' "${calls}")" == 1 ]]
  [[ "$(sed -n '2,4p' "${calls}")" == $'file upload docs/verification/window-resize/failure-observer-binary /Users/admin/k4-activation-snapshot\nfile exec --json chmod +x /Users/admin/k4-activation-snapshot; /Users/admin/k4-activation-snapshot\nagent windows --json' ]]
  [[ "$(tail -1 "${calls}")" == 'vm stop koine-k4-02 --json' ]]
  ! grep -Eq '^(input|agent window-focus|agent window-close)' "${calls}"
}

@test "failed native observation still retains the scenario failure and stops its clone" {
  export scenario_status=1 observer_error=1
  run bash run.sh 03 0.4.0
  [[ "${status}" == 201 ]]
  [[ -f .build/menu-samples/results/03/failure-windows.json ]]
  [[ "$(tail -1 "${calls}")" == 'vm stop koine-k4-03 --json' ]]
}

@test "a changed subject fails collection despite a successful scenario and still stops its clone" {
  export mutate=1
  run bash run.sh 04 0.3.0
  [[ "${status}" != 0 ]]
  [[ "$(cat .build/menu-samples/results/04/scenario.exit)" == 0 ]]
  [[ -f .build/menu-samples/results/04/ended.txt ]]
  [[ "$(cat .build/menu-samples/results/04/audit.exit)" == 1 ]]
  [[ -s .build/menu-samples/results/04/subjects-after.sha256 ]]
  [[ -s .build/menu-samples/results/04/inventory-diff.txt ]]
  [[ -f .build/menu-samples/results/04/links-after.txt ]]
  [[ "$(tail -1 "${calls}")" == 'vm stop koine-k4-04 --json' ]]
}

@test "the frozen PATH selects observation tools even when caller PATH is shadowed" {
  mkdir other-bin
  printf '#!/bin/bash\necho wrong >> "${calls}"\nexit 99\n' > other-bin/testanyware
  chmod +x other-bin/testanyware
  export PATH="${sample_root}/other-bin:${PATH}"
  run bash run.sh 01 0.3.0
  [[ "${status}" == 0 ]]
  ! grep -q wrong "${calls}"
  [[ "$(tail -1 "${calls}")" == 'vm stop koine-k4-01 --json' ]]
}
