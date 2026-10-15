# shellcheck shell=bash
# Shared guest-only Finder observer for target and application V acceptance.
# shellcheck disable=SC2016
# observe: Finder's own account of what it shows, as JSON in OBS:
#   {windows: n, target: <front window's folder or null>, title: <its title or null>,
#    selected: [{path, kind, name}]}
# A read, so it is safe to repeat and `guest_text` may retry it.
observe() {
    OBS_RAW="$(guest_text 'osascript $HOME/finder-observe.applescript')"
    OBS="$(jq -Rn '
        [inputs | split("\t")] as $r
        | {windows: ([$r[] | select(.[0] == "WINDOWS") | .[1] | tonumber][0] // null),
           target: ([$r[] | select(.[0] == "TARGET") | .[1]][0] // null),
           title: ([$r[] | select(.[0] == "TITLE") | .[1]][0] // null),
           selected: [$r[] | select(.[0] == "SELECTED") | {path: .[1], kind: .[2], name: .[3]}]}' <<<"${OBS_RAW}")" ||
        fail "Finder's account could not be read: ${OBS_RAW}"
    jq -e '.windows != null' >/dev/null <<<"${OBS}" || fail "Finder's account is incomplete: ${OBS_RAW}"
}
# A Finder with no window: what each case starts from, so that any window and selection after
# the request is the request's doing.
close_finder_windows() {
    guest 'osascript -e '"'"'tell application "Finder" to close every window'"'"'' || true
    for _ in 1 2 3 4 5; do
        observe
        jq -e '.windows == 0' >/dev/null <<<"${OBS}" && return 0
        sleep 2
    done
    fail "Finder still shows a window after closing them: ${OBS}"
}
# The observer is a process of the test harness, which macOS asks about once: the first time
# it asks Finder anything, "testanyware-agent wants access to control Finder". That consent is
# the observer's and not Koine's, it is given here before Koine starts.
allow_observer() {
    testanyware file exec 'osascript $HOME/finder-observe.applescript >$HOME/obs-first.txt 2>&1' >/dev/null 2>&1 &
    local first=$! hit="null" tries=0
    while [ "${hit}" = null ]; do
        tries=$((tries + 1))
        [ "${tries}" -lt 20 ] || break
        hit="$(screen_buttons | jq -c '[.[] | select(.app == "UserNotificationCenter" and .label == "Allow")][0]')"
        [ "${hit}" != null ] || sleep 2
    done
    if [ "${hit}" != null ]; then
        echo "The observer's own consent dialog: $(screen_text UserNotificationCenter | cut -c1-200)"
        # shellcheck disable=SC2046
        testanyware input click $(jq -r '"\(.x) \(.y)"' <<<"${hit}") >/dev/null
        OBSERVER_CONSENT="asked and allowed"
    else
        OBSERVER_CONSENT="not asked (already granted in the image)"
    fi
    wait "${first}" || true
    sleep 2
    observe
    echo "Observer consent: ${OBSERVER_CONSENT}. Finder's account with no window open: $(jq -c . <<<"${OBS}")"
}

