#!/bin/bash
# One raw transport per phase; collection never replays an unsuccessful request.
set -euo pipefail
phase="${1:?enable or dump}"
out="${KOINE_K4_OUT:?attempt output directory}"
case "${phase}" in
enable)
    # shellcheck disable=SC2016 # Command substitutions execute only in the guest.
    command='set -e; test ! -e /Users/admin/settings-events.json; test ! -e /Users/admin/settings-events.json.complete; defaults write dev.antony.Koine KoineSettingsEventBuffer -string /Users/admin/settings-events.json; test "$(defaults read dev.antony.Koine KoineSettingsEventBuffer)" = /Users/admin/settings-events.json; echo KOINE_EVENTS_ENABLED'
    ;;
dump) command='set -e; chmod +x /Users/admin/settings-event-dump; /Users/admin/settings-event-dump /Users/admin/settings-events.json' ;;
*) exit 2 ;;
esac
testanyware file exec --json "${command}" >"${out}/events-${phase}.json" 2>"${out}/events-${phase}.stderr"
jq -e '.ok == true and .exit_code == 0 and .timed_out == false' "${out}/events-${phase}.json" >/dev/null
if [ "${phase}" = enable ]; then
    jq -e '(.stdout | rtrimstr("\n")) == "KOINE_EVENTS_ENABLED"' "${out}/events-enable.json" >/dev/null
fi
if [ "${phase}" = dump ]; then
    jq -r '.stdout' "${out}/events-${phase}.json" >"${out}/events.json"
    jq -e '
        . as $root |
        .format == "koine-settings-events/1" and .dropped == 0 and
        (.records | length) <= .capacity and
        (.records | map(.sequence) == [range(1; length + 1)]) and
        .records[0].event == "buffer.started" and .records[-1].event == "buffer.dump" and
        ([.records[] | select(.event == "callback.settings") | .selection] as $selections |
            ($selections | length) > 0 and
            $selections == [range(1; ($selections | length) + 1)] and
            all($selections[]; . as $selection |
                [$root.records[] | select(.selection == $selection) | .event |
                    select(. == "callback.settings" or . == "show.enter" or
                           . == "window.makeKeyAndOrderFront.before" or . == "window.makeKeyAndOrderFront.after" or
                           . == "application.activate.before" or . == "application.activate.after")] ==
                ["callback.settings", "show.enter", "window.makeKeyAndOrderFront.before",
                 "window.makeKeyAndOrderFront.after", "application.activate.before", "application.activate.after"]))
    ' "${out}/events.json" >/dev/null
fi
