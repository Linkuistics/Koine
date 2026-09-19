#!/bin/bash
# Runs inside the VM: a client that knows only the endpoint descriptor and a
# protected credential file. Prints the response body, then "HTTP <status>".
# An optional second argument is the GraphQL query, without double quotes.
# Exits 3 when there is no descriptor, and with curl's status when the
# endpoint cannot be reached.
set -euo pipefail

CREDENTIAL_FILE="$1"
DEFAULT_QUERY='{ koine { contractVersion ownGrant { clientLabel capabilities state } } }'
QUERY="${2:-${DEFAULT_QUERY}}"
D="$HOME/Library/Application Support/Koine"

if [ ! -f "$D/endpoint.json" ]; then
    echo "no descriptor"
    exit 3
fi

curl -s -m 5 -w '\nHTTP %{http_code}\n' \
    "http://127.0.0.1:$(jq -r .port "$D/endpoint.json")$(jq -r .path "$D/endpoint.json")" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $(cat "${CREDENTIAL_FILE}")" \
    -d "{\"query\":\"${QUERY}\"}"
