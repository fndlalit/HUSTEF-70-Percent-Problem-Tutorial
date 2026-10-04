#!/usr/bin/env bash
# Explicit participant action, never a restart hook: indexing and seed import write memory.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/check-workspace.sh"
test -f .agentic-qe/memory.db || { echo 'Run post-create.sh first.' >&2; exit 1; }
MARKER=.agentic-qe/devcontainer-workshop-prepared
if [ -f "$MARKER" ]; then
  echo 'Workshop baseline already prepared; preserving your graph and learned patterns.'
  bash .devcontainer/verify.sh
  exit 0
fi

# SQLite backup includes committed WAL content. Keep a timestamped copy before writes.
mkdir -p .agentic-qe/backups
BACKUP=".agentic-qe/backups/pre-workshop-$(date -u +%Y%m%dT%H%M%SZ)-$$.db"
sqlite3 .agentic-qe/memory.db ".backup '$BACKUP'"
test "$(sqlite3 -readonly "$BACKUP" 'PRAGMA integrity_check;')" = ok
printf 'Pre-workshop memory backup: %s\n' "$BACKUP"

# Indexing with a provider key can make paid LLM calls. Prepare a purely local baseline.
# A minimal child environment excludes every provider credential/endpoint rather
# than maintaining a list of key names. Parent-shell credentials stay untouched.
env -i HOME="$HOME" PATH="$PATH" aqe code index src/
aqe hg stats
aqe memory usage
aqe learning import -i seed/aqe-seed-patterns.json
aqe learning stats
# Verification must succeed before the completion marker is written.
bash .devcontainer/verify.sh
date -u +%FT%TZ > "$MARKER"
