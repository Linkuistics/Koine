# shellcheck shell=bash
# Source-only user-input resize helper; the caller supplies WINDOW_TITLE.

# drag_window_corner <x> <y> [title]: move the bottom-right corner by mouse input.
# An accessibility frame assignment does not enforce the user's minimum size.
drag_window_corner() {
    local frame x y w h i px py status
    frame="$(testanyware agent windows --json | jq -r --arg title "${3:-${WINDOW_TITLE}}" \
        '[.windows[] | select(.title == $title)][0] | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"')" || return
    read -r x y w h <<<"${frame}"
    x=$((x + w - 3)) y=$((y + h - 3))
    echo "Resize pointer: start=(${x}, ${y}) destination=($1, $2) held points=10 interval=0.15s down dwell=0.2s" >&2
    testanyware input move "${x}" "${y}" >/dev/null || return
    sleep 0.5
    # mouse-down sends a held-button mask at every coordinate; ordinary move
    # sends mask zero: https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-rfb/src/input.rs#L115-L146
    # Separate paced requests grew a fresh window where unpaced drag did not.
    # This is not a persistent connection or an isolated timing diagnosis.
    for ((i = 0; i <= 10; i++)); do
        px=$((x + ($1 - x) * i / 10))
        py=$((y + ($2 - y) * i / 10))
        if testanyware input mouse-down "${px}" "${py}" >/dev/null; then
            if [ "${i}" = 0 ]; then sleep 0.2; else sleep 0.15; fi
        else
            status=$?
            # A failed transport may have delivered input. Attempt release,
            # preserve the original error and let the caller fail the exercise.
            testanyware input mouse-up "${px}" "${py}" >/dev/null || true
            return "${status}"
        fi
    done
    testanyware input mouse-up "$1" "$2" >/dev/null || return
    sleep 1
}
