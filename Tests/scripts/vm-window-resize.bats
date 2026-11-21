#!/usr/bin/env bats

setup() {
  source "${BATS_TEST_DIRNAME}/../../scripts/vm-window-resize-lib.sh"
  export WINDOW_TITLE='Koine Settings'
  export calls="${BATS_TEST_TMPDIR}/calls"
  : >"${calls}"
  sleep() { :; }
  testanyware() {
    printf '%s\n' "$*" >>"${calls}"
    if [[ "$*" == 'agent windows --json' ]]; then
      echo '{"ok":true,"windows":[{"title":"Untitled","positionX":650,"positionY":80,"sizeWidth":603,"sizeHeight":505},{"title":"Koine Settings","positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}'
    fi
    if [[ "${reject:-}" == "$*" ]]; then return 7; fi
  }
}

# Catches sending only endpoints, releasing the button during interpolation,
# or targeting the outermost rounded corner instead of the observed resize zone.
@test "resize sends a held-button path through the selected corner to its destination" {
  drag_window_corner 740 940
  [[ "$(sed -n '2,4p' "${calls}")" == $'input move 517 749\ninput mouse-down 517 749\ninput mouse-down 539 768' ]]
  grep -qx 'input mouse-down 628 844' "${calls}"
  [[ "$(tail -n 2 "${calls}")" == $'input mouse-down 740 940\ninput mouse-up 740 940' ]]
  [[ "$(grep -c '^input mouse-down ' "${calls}")" == 11 ]]
  [[ "$(wc -l <"${calls}" | tr -d ' ')" == 14 ]]
}

@test "an explicit title selects the ordinary-window corner without changing its destination" {
  drag_window_corner 1400 780 Untitled
  [[ "$(sed -n '2,4p' "${calls}")" == $'input move 1250 582\ninput mouse-down 1250 582\ninput mouse-down 1265 601' ]]
  [[ "$(tail -n 2 "${calls}")" == $'input mouse-down 1400 780\ninput mouse-up 1400 780' ]]
}

@test "a failed pointer preparation never presses the button in a conditional caller" {
  reject='input move 517 749'
  if drag_window_corner 740 940; then return 1; fi
  [[ "$(wc -l <"${calls}" | tr -d ' ')" == 2 ]]
}

@test "a failed initial down attempts release and preserves the failure" {
  reject='input mouse-down 517 749'
  run drag_window_corner 740 940
  [[ "${status}" == 7 ]]
  [[ "$(tail -n 2 "${calls}")" == $'input mouse-down 517 749\ninput mouse-up 517 749' ]]
  [[ "$(wc -l <"${calls}" | tr -d ' ')" == 4 ]]
}

@test "a failed held point releases there and stops instead of masking the error" {
  reject='input mouse-down 606 825'
  run drag_window_corner 740 940
  [[ "${status}" == 7 ]]
  [[ "$(tail -n 2 "${calls}")" == $'input mouse-down 606 825\ninput mouse-up 606 825' ]]
  [[ "$(wc -l <"${calls}" | tr -d ' ')" == 8 ]]
}

@test "a failed final release is returned rather than hidden by sleep" {
  reject='input mouse-up 740 940'
  run drag_window_corner 740 940
  [[ "${status}" == 7 ]]
}

# Execute the real scenario's resize section, substituting only the strict
# transports, observations and slow scrolling. The section's own guards, its
# local decisions and its exclusive content write run unchanged. These
# controls catch false acceptance in its guards; the helper request tests
# above cover the actual input path separately.
exercise_resize_section() {
  local section
  export resize_frame_count="${BATS_TEST_TMPDIR}/frame-count"
  echo 0 >"${resize_frame_count}"
  WINDOW_TITLE='Koine Settings' MIN_WIDTH=440 MIN_HEIGHT=320
  LOG="${BATS_TEST_TMPDIR}/scenario.log"
  step() { :; }
  settings_window() { :; }
  settings_expect_front() { :; }
  settings_sleep() { :; }
  settings_capture() { :; }
  settings_calibrate_window_scroll() { :; }
  settings_reveal() { :; }
  drag_window_corner() { echo "$1" >"${resize_frame_count}"; }
  settings_fail() { echo "FAILED: $*" >&2; exit 1; }
  settings_stop() { echo "FAILED: ${*:2} ($1)" >&2; exit "$1"; }
  settings_require() { if [[ "$1" == 1 ]]; then settings_fail "${@:2}"; fi; settings_stop "$@"; }
  settings_local_failure() { settings_stop 125 "$2"; }
  # The real local decision, without its receipt.
  settings_state() { jq -e "$2" >/dev/null <<<"$3"; }
  settings_frame() {
    local n
    n="$(cat "${resize_frame_count}")"
    if [[ "${n}" == 740 ]]; then
      echo '40 40 703 903'
      return "${frame_error:-0}"
    fi
    echo '40 40 440 352'
  }
  settings_element() {
    printf '{"platformRole":"AXScrollArea","sizeHeight":%s}\n' "${content_height:-320}"
  }
  section="$(awk '/^step "The window resizes:/ {selected=1} /^step "Shortcuts,/ {selected=0} selected' \
    "${BATS_TEST_DIRNAME}/../../scripts/vm-verify-menu-bar.sh")"
  [[ -n "${section}" ]] || return 99
  eval "${section}"
}

@test "the scenario refuses a failed frame read even when it emitted valid geometry" {
  frame_error=7
  run exercise_resize_section
  [[ "${status}" != 0 ]]
}

@test "the scenario refuses content below 320 even when the outer frame is 440 by 352" {
  content_height=288
  run exercise_resize_section
  [[ "${status}" != 0 ]]
}

@test "the scenario accepts the observed minimum only with at least 320 content pixels" {
  run exercise_resize_section
  [[ "${status}" == 0 ]]
}
