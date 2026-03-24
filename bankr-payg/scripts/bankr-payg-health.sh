#!/usr/bin/env bash
# Check if the Bankr PAYG API is healthy.
# Usage: ./bankr-payg-health.sh

set -euo pipefail

BASE_URL="${BANKR_PAYG_URL:-https://bankr-payg.onrender.com}"

response=$(curl -s -w "\n%{http_code}" "${BASE_URL}/health" \
  --connect-timeout 10 --max-time 10)

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" =~ ^2 ]]; then
  echo "$body"
else
  echo "Error (HTTP $http_code): $body" >&2
  exit 1
fi
