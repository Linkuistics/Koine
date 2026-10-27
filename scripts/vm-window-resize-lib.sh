# shellcheck shell=bash
# Source-only user-input resize helper; the caller supplies WINDOW_TITLE.

# drag_window_corner <x> <y> [title]: move the bottom-right corner by mouse input.
# An accessibility frame assignment does not enforce the user's minimum size.
drag_window_corner() {
    local frame x y w h
    frame="$(testanyware agent windows --json | jq -r --arg title "${3:-${WINDOW_TITLE}}" \
        '[.windows[] | select(.title == $title)][0] | "\(.positionX | floor) \(.positionY | floor) \(.sizeWidth | floor) \(.sizeHeight | floor)"')" || return
    read -r x y w h <<<"${frame}"
    # This candidate uses the three-pixel inset observed working in exploration.
    # Fresh-guest qualification remains open in docs/verification/menu-bar-vm.md.
    x=$((x + w - 3)) y=$((y + h - 3))
    echo "Resize pointer: start=(${x}, ${y}) destination=($1, $2) steps=100" >&2
    testanyware input move "${x}" "${y}" >/dev/null || return
    sleep 0.5
    # A drag sends interpolation points with the button held, unlike down/up:
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-rfb/src/input.rs#L171-L194
    testanyware input drag "${x}" "${y}" "$1" "$2" --steps 100 >/dev/null || return
    sleep 1
}
