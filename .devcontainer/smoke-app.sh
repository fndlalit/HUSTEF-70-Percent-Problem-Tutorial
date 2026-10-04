#!/usr/bin/env bash
# Exercise the no-key app surfaces without calling Stripe or making a payment.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."
LOG="$(mktemp)"
PAGE="$(mktemp)"
if curl -s http://127.0.0.1:3000/ > /dev/null; then
  echo 'Port 3000 is already in use; stop that server before the smoke check.' >&2
  exit 1
fi
node node_modules/next/dist/bin/next dev --hostname 0.0.0.0 --port 3000 > "$LOG" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2>/dev/null || true; wait "$SERVER_PID" 2>/dev/null || true; rm -f "$LOG" "$PAGE"' EXIT
ready=0
for _ in $(seq 1 90); do
  if curl -fsS http://127.0.0.1:3000/ > /dev/null 2>&1; then ready=1; break; fi
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then cat "$LOG"; exit 1; fi
  sleep 1
done
if [ "$ready" != 1 ]; then cat "$LOG"; exit 1; fi
curl -fsS http://127.0.0.1:3000/ -o "$PAGE"
rg -q 'Premium Wireless Headphones' "$PAGE"
curl -fsS http://127.0.0.1:3000/cart -o "$PAGE"
rg -q 'cart' "$PAGE"
test "$(curl -sS -o /dev/null -w '%{http_code}' http://127.0.0.1:3000/api/orders)" = 400
echo 'Catalog, cart, and missing-order validation: OK (no payment attempted)'
