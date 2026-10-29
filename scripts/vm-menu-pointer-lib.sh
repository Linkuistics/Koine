# shellcheck shell=bash
# Source-only pointer helpers: no bundle, transcript or VM lifecycle side effects.
# The caller supplies fail(); focused checks substitute the transport, not geometry.
# shellcheck source=scripts/vm-physical-evidence-lib.sh
source "${BASH_SOURCE[0]%/*}/vm-physical-evidence-lib.sh"

# click_at <x> <y>: a menu tracks the pointer, so approach before clicking.
# Validate the destination; bounding applies only to the synthetic approach.
click_at() {
    local x="$1" y="$2" size dimensions width height approach_x approach_y
    [[ "${x}" =~ ^[0-9]{1,5}$ && "${y}" =~ ^[0-9]{1,5}$ ]] || {
        _physical_fail "not a pointer target: ${x}, ${y}"
        return "$?"
    }
    x=$((10#${x})) y=$((10#${y}))
    # v2.7.0 screen size returns logical width/height, in input coordinates.
    # https://github.com/Linkuistics/TestAnyware/blob/v2.7.0/cli-rs/crates/testanyware-cli/src/commands/screen.rs
    size="$(_physical_cli read-poll menu-display '
        all(.width, .height; type == "number" and . == floor and . >= 2 and . <= 65535)' screen size)" || return
    dimensions="$(jq -er '
        select(.ok == true) | [.width, .height]
        | select(all(.[]; type == "number" and . == floor and . >= 2 and . <= 65535))
        | @tsv' <<<"${size}")" || {
        _physical_fail "display decoding failed: ${size}"
        return "$?"
    }
    read -r width height <<<"${dimensions}"
    [[ -n "${width}" && -n "${height}" ]] || {
        _physical_fail "no usable display size: ${size}"
        return "$?"
    }
    ((x < width && y < height)) || {
        _physical_fail "pointer target outside ${width}x${height}: ${x}, ${y}"
        return "$?"
    }
    approach_x=$((x >= 12 ? x - 12 : 0))
    approach_y=$((y >= 8 ? y - 8 : 0))
    # The top-left pixel still needs a distinct approach within this display.
    if ((approach_x == x && approach_y == y)); then approach_x=1; fi
    echo "Pointer: approach=(${approach_x}, ${approach_y}) target=(${x}, ${y}) display=${width}x${height}" >&2
    _physical_pointer menu-approach move "${approach_x}" "${approach_y}" >/dev/null || return
    sleep 0.3
    _physical_pointer menu-target move "${x}" "${y}" >/dev/null || return
    sleep 0.3
    _physical_pointer menu-click click "${x}" "${y}" >/dev/null || return
    sleep 1
}
# click_centre <"x, y, w, h" as System Events prints position then size>
click_centre() {
    local frame="$1" x y w h
    # Validate fields separately and reject missing/extra fields before arithmetic.
    [[ "${frame}" =~ ^([0-9]{1,5}),[[:space:]]*([0-9]{1,5}),[[:space:]]*([0-9]{1,5}),[[:space:]]*([0-9]{1,5})$ ]] || {
        _physical_fail "not a frame: ${frame}"
        return "$?"
    }
    x=$((10#${BASH_REMATCH[1]})) y=$((10#${BASH_REMATCH[2]}))
    w=$((10#${BASH_REMATCH[3]})) h=$((10#${BASH_REMATCH[4]}))
    ((w > 0 && h > 0)) || {
        _physical_fail "empty frame: ${frame}"
        return "$?"
    }
    echo "Pointer source frame: ${frame}" >&2
    click_at "$((x + w / 2))" "$((y + h / 2))"
}
