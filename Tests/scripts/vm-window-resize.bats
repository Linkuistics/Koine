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
  }
}

# Catches replacing a held-button path with down at the start and up at the end,
# or targeting the rounded outermost pixel instead of the qualified resize zone.
@test "resize prepares the selected corner and requests a complete held-button drag" {
  drag_window_corner 740 940
  [[ "$(cat "${calls}")" == $'agent windows --json\ninput move 517 749\ninput drag 517 749 740 940 --steps 100' ]]
}

@test "an explicit title selects the ordinary-window control without changing its destination" {
  drag_window_corner 1400 780 Untitled
  [[ "$(cat "${calls}")" == $'agent windows --json\ninput move 1250 582\ninput drag 1250 582 1400 780 --steps 100' ]]
}

@test "a failed pointer preparation never starts a drag even in a conditional caller" {
  testanyware() {
    echo "$*" >>"${calls}"
    if [[ "$*" == 'agent windows --json' ]]; then
      echo '{"ok":true,"windows":[{"title":"Koine Settings","positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}'
    else
      return 7
    fi
  }
  if drag_window_corner 740 940; then
    return 1
  fi
  [[ "$(wc -l <"${calls}" | tr -d ' ')" == 2 ]]
}

@test "a rejected drag is returned to a conditional caller rather than hidden by sleep" {
  testanyware() {
    echo "$*" >>"${calls}"
    if [[ "$*" == 'agent windows --json' ]]; then
      echo '{"ok":true,"windows":[{"title":"Koine Settings","positionX":40,"positionY":40,"sizeWidth":480,"sizeHeight":712}]}'
    elif [[ "$*" == 'input drag '* ]]; then
      return 7
    fi
  }
  run drag_window_corner 740 940
  [[ "${status}" == 7 ]]
}
