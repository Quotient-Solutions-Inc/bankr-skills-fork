#!/usr/bin/env bash
# Submit a forecast question to the Bankr PAYG API.
# Usage: BANKR_API_KEY=bk_... ./bankr-payg-forecast.sh "Will X happen by Y?"

set -euo pipefail

BASE_URL="${BANKR_PAYG_URL:-https://bankr-payg.onrender.com}"
API_KEY="${BANKR_API_KEY:?Set BANKR_API_KEY to your Bankr API key (bk_...)}"
QUESTION="${1:?Usage: bankr-payg-forecast.sh \"<question>\"}"

response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/forecast" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${API_KEY}" \
  -d "{\"question\": $(echo "$QUESTION" | jq -Rs '.')}" \
  --connect-timeout 10 --max-time 120)

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" =~ ^5 ]]; then
  # Retry once on 5xx
  sleep 2
  response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/forecast" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${API_KEY}" \
    -d "{\"question\": $(echo "$QUESTION" | jq -Rs '.')}" \
    --connect-timeout 10 --max-time 120)
  http_code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')
fi

if [[ "$http_code" =~ ^2 ]]; then
  echo "$body"
else
  echo "Error (HTTP $http_code): $body" >&2
  exit 1
fi
