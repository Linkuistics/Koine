# shellcheck shell=bash
# Source-only user-input resize helper; the caller supplies WINDOW_TITLE.
# shellcheck source=scripts/vm-physical-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-physical-evidence-lib.sh"

# drag_window_corner <x> <y> [title]: move the bottom-right corner by mouse input.
# An accessibility frame assignment does not enforce the user's minimum size.
drag_window_corner() {
    local frame x y w h i px py sx sy status destination_x="$1" destination_y="$2"
    if [[ "${KOINE_VM_EVIDENCE_ROOT+x}" ]]; then
        _physical_coordinates "${destination_x}" "${destination_y}" || {
            _physical_fail "not a resize destination: ${destination_x}, ${destination_y}"
            return "$?"
        }
        destination_x=$((10#${destination_x})) destination_y=$((10#${destination_y}))
        frame="$(_physical_resize_frame "${3:-${WINDOW_TITLE}}")" || return
    else
        frame="$(testanyware agent windows --json | jq -r --arg title "${3:-${WINDOW_TITLE}}" \
            '[.windows[] | select(.title == $title)][0] | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"')" || return
    fi
    read -r x y w h <<<"${frame}"
    x=$((x + w - 3)) y=$((y + h - 3))
    # One pixel toward the destination on each axis that moves.
    sx=$(((destination_x > x) - (destination_x < x)))
    sy=$(((destination_y > y) - (destination_y < y)))
    echo "Resize pointer: start=(${x}, ${y}) destination=($1, $2) anchor=(${sx}, ${sy}) held points=11 interval=0.15s down dwell=0.2s" >&2
    _physical_pointer resize-prepare move "${x}" "${y}" >/dev/null || return
    # Each wait is checked: a failed wait stops the drag before the next point
    # or the release. Its operation is not resize-down-N, so the held state
    # still comes from the held points alone.
    _physical_sleep resize-prepare-wait 0.5 || return
    # mouse-down sends a held-button mask at every coordinate; ordinary move
    # sends mask zero: https://github.com/Linkuistics/TestAnyware/blob/v3.0.0/cli-rs/crates/testanyware-rfb/src/input.rs#L115-L146
    # Separate paced requests grew a fresh window where unpaced drag did not.
    # This is not a persistent connection or an isolated timing diagnosis.
    # On macOS 27.2.1 with TestAnyware 3.0.0, the resize begins at the first
    # held movement and measures from there. A read after each held point
    # showed it: the step from the press to point 1 was lost (issue #21). So
    # point 1 is the anchor, one pixel from the press. The ten points after it
    # carry the same one-pixel shift, and the corner ends at the destination.
    # scripts/vm-probe-resize-drag.sh compares this drag with the one before.
    for ((i = 0; i <= 11; i++)); do
        if [ "${i}" = 0 ]; then
            px="${x}" py="${y}"
        else
            px=$((x + sx + (destination_x - x) * (i - 1) / 10))
            py=$((y + sy + (destination_y - y) * (i - 1) / 10))
        fi
        if _physical_pointer "resize-down-${i}" mouse-down "${px}" "${py}" >/dev/null; then
            if [ "${i}" = 0 ]; then
                _physical_sleep "resize-hold-${i}-wait" 0.2 || return
            else
                _physical_sleep "resize-hold-${i}-wait" 0.15 || return
            fi
        else
            status=$?
            # Strict failure stops input, including release. Preserve uncertain
            # held input for the finite caller's exact-clone containment. Other
            # existing consumers retain their legacy best-effort release.
            if [[ ! "${KOINE_VM_EVIDENCE_ROOT+x}" ]]; then
                testanyware input mouse-up "${px}" "${py}" >/dev/null || true
            fi
            return "${status}"
        fi
    done
    _physical_pointer resize-release mouse-up "${px}" "${py}" >/dev/null || return
    _physical_sleep resize-release-wait 1
}
