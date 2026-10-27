#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../../scripts/vm-menu-pointer-lib.sh"
  export calls="${BATS_TEST_TMPDIR}/calls"
  : >"${calls}"
  sleep() { :; }
  fail() { echo "$*" >&2; exit 1; }
  testanyware() {
    printf '%s\n' "$*" >>"${calls}"
    if [[ "$*" == 'screen size --json' ]]; then
      echo '{"ok":true,"width":1920,"height":1080}'
    fi
  }
}

@test "menu-bar centre at y=7 retains its target and never sends -1" {
  click_centre '100, 0, 22, 15'
  run grep -q -- '-1' "${calls}"
  [[ "${status}" != 0 ]]
  grep -qx 'input move 111 7' "${calls}"
  grep -qx 'input click 111 7' "${calls}"
}

@test "ordinary frame retains the old approach and centre" {
  click_centre '100, 40, 80, 20'
  grep -qx 'input move 128 42' "${calls}"
  grep -qx 'input click 140 50' "${calls}"
}

@test "display corners retain their targets with a distinct on-screen approach" {
  for point in '0 0' '1919 0' '0 1079' '1919 1079'; do
    read -r x y <<<"${point}"
    : >"${calls}"
    click_at "${x}" "${y}"
    grep -qx "input click ${x} ${y}" "${calls}"
    awk '$1 == "input" && $2 == "move" {if ($3 < 0 || $3 >= 1920 || $4 < 0 || $4 >= 1080) exit 1}' "${calls}"
    [[ "$(grep '^input move' "${calls}" | sort -u | wc -l | tr -d ' ')" == 2 ]]
  done
}

@test "invalid frame observations fail before any pointer input" {
  for frame in '' '100, 0, 22' '1, -1, 20, 20' '1, 2, 0, 20' \
    '1, 2, 20, 0' '1, 2, 20, 20, 99' '1, 2, 2.5, 20' \
    '1, null, 20, 20' '1920, 0, 20, 20' '0, 1080, 20, 20' \
    '1, 2, 999999999999999999999999, 20'; do
    : >"${calls}"
    run click_centre "${frame}"
    [[ "${status}" != 0 ]]
    run grep -q '^input ' "${calls}"
    [[ "${status}" != 0 ]]
  done
}

@test "pointer transport failure stops before the click even in a conditional caller" {
  testanyware() { echo "$*" >>"${calls}"; return 7; }
  if click_at 100 100; then
    return 1
  fi
  run grep -q '^input click' "${calls}"
  [[ "${status}" != 0 ]]
}

@test "missing or malformed display dimensions never send pointer input" {
  for dimensions in '{}' '{"ok":false,"width":1920,"height":1080}' \
    '{"ok":true,"width":null,"height":1080}' \
    '{"ok":true,"width":1,"height":1080}' \
    '{"ok":true,"width":1920.5,"height":1080}' \
    '{"ok":true,"width":1920,"height":"1080"}' 'not JSON'; do
    testanyware() {
      echo "$*" >>"${calls}"
      echo "${dimensions}"
    }
    : >"${calls}"
    run click_at 10 10
    [[ "${status}" != 0 ]]
    run grep -q '^input ' "${calls}"
    [[ "${status}" != 0 ]]
  done
}

@test "an out-of-display destination is refused rather than moved to another target" {
  for point in '-1 10' '1920 10' '10 1080' 'hello 10'; do
    read -r x y <<<"${point}"
    : >"${calls}"
    run click_at "${x}" "${y}"
    [[ "${status}" != 0 ]]
    run grep -q '^input ' "${calls}"
    [[ "${status}" != 0 ]]
  done
}

@test "a failed move stops the action even when the caller tests its status" {
  for failure in first second; do
    : >"${calls}"
    testanyware() {
      echo "$*" >>"${calls}"
      if [[ "$*" == 'screen size --json' ]]; then
        echo '{"ok":true,"width":1920,"height":1080}'
      elif [[ "$*" == 'input move 88 92' && "${failure}" == first ]] ||
        [[ "$*" == 'input move 100 100' && "${failure}" == second ]]; then
        return 7
      fi
    }
    if click_at 100 100; then
      return 1
    fi
    run grep -q '^input click' "${calls}"
    [[ "${status}" != 0 ]]
  done
}
