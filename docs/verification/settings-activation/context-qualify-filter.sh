#!/bin/bash
# Offline ASCII message-filter qualification; leaves original streams untouched.
set -euo pipefail
out="${1:?new output directory}"
mkdir "${out}"
evidence=docs/verification/settings-activation
predicate="$(cat "${evidence}/context-predicate.txt")"
# Derive the actual case-insensitive ASCII needles from the guest's predicate.
terms="$(jq -nr --arg p "${predicate}" '[ $p | scan("CONTAINS\\[c\\] \"([^\"]+)\"") | .[0] ] | join("|")')"
[ -n "${terms}" ]
shasum -a 256 "$0" "${evidence}/context-predicate.txt" \
    "${evidence}"/native-{01,02}/native-log/stream.jsonl.gz \
    "${evidence}"/native-{01,02}/native-path-records.jsonl >"${out}/inputs-before.sha256"
for attempt in 01 02; do
    raw="${evidence}/native-${attempt}/native-log/stream.jsonl.gz"
    filtered="${out}/${attempt}-filtered.jsonl"
    gzip -cd "${raw}" | jq -Rrc --arg terms "${terms}" \
        'fromjson? | select((.processImagePath | endswith("/Koine")) or ((.eventMessage // "" | ascii_downcase) | test($terms)))' >"${filtered}"
    jq -Sc . "${evidence}/native-${attempt}/native-path-records.jsonl" | LC_ALL=C sort >"${out}/${attempt}-reference.txt"
    jq -Sc '{timestamp, processID, processImagePath, senderImagePath, subsystem, category, messageType, eventMessage}' "${filtered}" | LC_ALL=C sort >"${out}/${attempt}-retained.txt"
    comm -23 "${out}/${attempt}-reference.txt" "${out}/${attempt}-retained.txt" >"${out}/${attempt}-missing.txt"
    [ ! -s "${out}/${attempt}-missing.txt" ]
    {
        printf 'attempt=%s\n' "${attempt}"
        printf 'raw_bytes='; gzip -cd "${raw}" | wc -c
        printf 'retained_bytes='; wc -c <"${filtered}"
        printf 'reference_records='; wc -l <"${out}/${attempt}-reference.txt"
        printf 'retained_records='; wc -l <"${filtered}"
        printf 'missing_reference_records='; wc -l <"${out}/${attempt}-missing.txt"
    } >"${out}/${attempt}-summary.txt"
    # The reconstructed input check freezes the compressed source and references.
done
shasum -a 256 -c "${out}/inputs-before.sha256" >"${out}/inputs-after.txt"
