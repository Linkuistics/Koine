# shellcheck shell=bash
# Source-only pointer helpers: no bundle, transcript or VM lifecycle side effects.
# The caller supplies fail(); focused checks substitute the transport, not geometry.

# click_at <x> <y>: a menu tracks the pointer, so approach before clicking.
# Validate the destination; bounding applies only to the synthetic approach.
click_at() {
    local x="$1" y="$2" size width height approach_x approach_y
    [[ "${x}" =~ ^[0-9]{1,5}$ && "${y}" =~ ^[0-9]{1,5}$ ]] || {
        fail "not a pointer target: ${x}, ${y}"
        return 1
    }
    x=$((10#${x})) y=$((10#${y}))
    size="$(testanyware screen size --json)" || return
    read -r width height <<<"$(jq -er '
        select(.ok == true) | [.width, .height]
        | select(all(.[]; type == "number" and . == floor and . >= 2 and . <= 65535))
        | @tsv' <<<"${size}")"
    [[ -n "${width}" && -n "${height}" ]] || {
        fail "no usable display size: ${size}"
        return 1
    }
    ((x < width && y < height)) || {
        fail "pointer target outside ${width}x${height}: ${x}, ${y}"
        return 1
    }
    approach_x=$((x >= 12 ? x - 12 : 0))
    approach_y=$((y >= 8 ? y - 8 : 0))
    # The top-left pixel still needs a distinct approach within this display.
    if ((approach_x == x && approach_y == y)); then approach_x=1; fi
    echo "Pointer: approach=(${approach_x}, ${approach_y}) target=(${x}, ${y}) display=${width}x${height}" >&2
    testanyware input move "${approach_x}" "${approach_y}" >/dev/null || return
    sleep 0.3
    testanyware input move "${x}" "${y}" >/dev/null || return
    sleep 0.3
    testanyware input click "${x}" "${y}" >/dev/null || return
    sleep 1
}
# click_centre <"x, y, w, h" as System Events prints position then size>
click_centre() {
    local frame="$1" x y w h
    # Validate fields separately and reject missing/extra fields before arithmetic.
    [[ "${frame}" =~ ^([0-9]{1,5}),[[:space:]]*([0-9]{1,5}),[[:space:]]*([0-9]{1,5}),[[:space:]]*([0-9]{1,5})$ ]] || {
        fail "not a frame: ${frame}"
        return 1
    }
    x=$((10#${BASH_REMATCH[1]})) y=$((10#${BASH_REMATCH[2]}))
    w=$((10#${BASH_REMATCH[3]})) h=$((10#${BASH_REMATCH[4]}))
    ((w > 0 && h > 0)) || {
        fail "empty frame: ${frame}"
        return 1
    }
    echo "Pointer source frame: ${frame}" >&2
    click_at "$((x + w / 2))" "$((y + h / 2))"
}
