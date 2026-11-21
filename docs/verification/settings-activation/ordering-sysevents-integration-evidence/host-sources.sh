#!/bin/bash
# Record the sources of the k156 absence boundary as JSON: the messages that
# the host AppleScript formatter writes for a bare -1728 and -1719, with and
# without a locale, the denial message raised with -1719, the two MacErrors.h
# definitions of the host SDK and the digest of the cited presentation. No
# Apple event reaches System Events. Usage: host-sources.sh SCRATCH > OUTPUT
set -euo pipefail
scratch="$1"
mkdir "${scratch}"
formatter() {
    local literal
    for literal in 'error number -1728' 'error number -1719' 'item 5 of {1, 2}' \
        'error "System Events got an error: testanyware-agent is not allowed assistive access." number -1719'; do
        printf 'locale %s: osascript -s so -e %s\n' "$1" "${literal}"
        if [[ "$1" == none ]]; then
            env -i /usr/bin/osascript -s so -e "${literal}" 2>&1 || :
        else
            /usr/bin/osascript -s so -e "${literal}" 2>&1 || :
        fi
    done
}
{
    formatter "${LANG:-unset}"
    formatter none
} >"${scratch}/formatter-lines.txt"
sdk="$(xcrun --show-sdk-path)"
header="${sdk}/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/Headers/MacErrors.h"
grep -n -E 'errAEIllegalIndex|errAENoSuchObject' "${header}" >"${scratch}/header-lines.txt"
deck=https://bpb-us-e1.wpmucdn.com/sites.psu.edu/dist/4/24696/files/2023/07/psumac2023-DYQWYU-Scripting-the-unscriptable-GUI-Scripts-in-macOS.pdf
curl -sSL -o "${scratch}/deck.pdf" "${deck}"
jq -n --rawfile formatter "${scratch}/formatter-lines.txt" \
    --arg header "${header}" --arg header_sha "$(shasum -a 256 "${header}" | cut -d' ' -f1)" \
    --arg sdk_version "$(xcrun --show-sdk-version)" --rawfile header_lines "${scratch}/header-lines.txt" \
    --arg deck "${deck}" --arg deck_sha "$(shasum -a 256 "${scratch}/deck.pdf" | cut -d' ' -f1)" \
    --arg host "$(sw_vers -productVersion) ($(sw_vers -buildVersion))" \
    --arg recorded "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '{
    recorded: $recorded, host: $host,
    sources: [
      {source: "/usr/bin/osascript formatter", lines: ($formatter | rtrimstr("\n") | split("\n"))},
      {source: $header, sdk: $sdk_version, sha256: $header_sha, lines: ($header_lines | rtrimstr("\n") | split("\n"))},
      {source: $deck, page: 51, slide: 29, sha256: $deck_sha}
    ]}'
