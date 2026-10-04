#!/usr/bin/env bash
# Sourced before any mutation: refuse an AQE development checkout or another repo.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
node -e 'const p=require("./package.json"); if(p.name!=="checkout-demo" || !p.private) { console.error("Refusing setup outside the checkout-demo tutorial repository."); process.exit(1) }'
test -f LAB.md && test -f seed/aqe-seed-patterns.json || {
  echo 'Tutorial LAB.md / seed files missing; refusing setup.' >&2
  exit 1
}
if [ -L .agentic-qe ] || [ -L .agentic-qe/memory.db ]; then
  echo 'Refusing linked AQE data: the tutorial must not write another workspace memory.' >&2
  exit 1
fi
