#!/bin/bash
# Record the primary sources of the k151 grammars and classifications as JSON:
# the host osascript(1) page, the AppleScript Language Guide page of error
# numbers, AppleEvents.h of the host SDK and the enrolment client. Each entry
# keeps a digest and the decisive lines. Usage: sources.sh SCRATCH > OUTPUT
set -euo pipefail
scratch="$1"
mkdir "${scratch}"
guide=https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_error_codes.html
curl -sSL -o "${scratch}/errors.html" "${guide}"
python3 -I -c '
import html, re, sys
text = re.sub(r"<[^>]+>", " ", open(sys.argv[1], encoding="utf-8").read())
text = re.sub(r"[ \t\r\n]+", " ", html.unescape(text))
for number in ("-1728", "-1719", "-1712", "-600"):
    index = text.find(" " + number + " ")
    end = re.compile(r"\.| -[0-9]+ ").search(text, index + len(number) + 2)
    print(text[index + 1 : end.start() + (end.group(0) == ".")])
' "${scratch}/errors.html" >"${scratch}/guide-lines.txt"
page=/usr/share/man/man1/osascript.1
man osascript | col -b | sed -n '/^ *-s flags$/,/output, which you don/p' >"${scratch}/page-lines.txt"
sdk="$(xcrun --show-sdk-path)"
header="${sdk}/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/AE.framework/Versions/A/Headers/AppleEvents.h"
grep -n 'errAEEventNotPermitted = ' "${header}" >"${scratch}/header-lines.txt"
client=scripts/vm-verify-enrollment-client.py
grep -n 'print(json.dumps' "${client}" >"${scratch}/client-lines.txt"
jq -n --arg guide "${guide}" --arg guide_sha "$(shasum -a 256 "${scratch}/errors.html" | cut -d' ' -f1)" \
    --rawfile guide_lines "${scratch}/guide-lines.txt" \
    --arg page "${page}" --arg page_sha "$(shasum -a 256 "${page}" | cut -d' ' -f1)" \
    --rawfile page_lines "${scratch}/page-lines.txt" \
    --arg header "${header}" --arg header_sha "$(shasum -a 256 "${header}" | cut -d' ' -f1)" \
    --arg sdk_version "$(xcrun --show-sdk-version)" --rawfile header_lines "${scratch}/header-lines.txt" \
    --arg client "${client}" --arg client_sha "$(shasum -a 256 "${client}" | cut -d' ' -f1)" \
    --rawfile client_lines "${scratch}/client-lines.txt" \
    --arg host "$(sw_vers -productVersion) ($(sw_vers -buildVersion))" \
    --arg recorded "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '{
    recorded: $recorded, host: $host,
    sources: [
      {source: $guide, sha256: $guide_sha, lines: ($guide_lines | rtrimstr("\n") | split("\n"))},
      {source: $page, sha256: $page_sha, lines: ($page_lines | rtrimstr("\n") | split("\n"))},
      {source: $header, sdk: $sdk_version, sha256: $header_sha, lines: ($header_lines | rtrimstr("\n") | split("\n"))},
      {source: $client, sha256: $client_sha, lines: ($client_lines | rtrimstr("\n") | split("\n"))}
    ]}'
