#!/usr/bin/env bash
# Focused failure/preservation tests with fake tooling, never a real learning DB.
set -euo pipefail
SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT
mkdir -p "$FIXTURE/.devcontainer" "$FIXTURE/bin"
cp "$SOURCE/post-create.sh" "$SOURCE/prepare-workshop.sh" "$SOURCE/check-workspace.sh" "$FIXTURE/.devcontainer/"
mkdir -p "$FIXTURE/seed"
mkdir -p "$FIXTURE/global/agentic-qe"
printf '{"version":"latest-test-double"}\n' > "$FIXTURE/global/agentic-qe/package.json"
printf '{"name":"checkout-demo","private":true}\n' > "$FIXTURE/package.json"
touch "$FIXTURE/LAB.md" "$FIXTURE/seed/aqe-seed-patterns.json"
cat > "$FIXTURE/bin/npm" <<'MOCK'
#!/usr/bin/env bash
if [ "${1:-}" = root ]; then echo "$FAKE_GLOBAL"; fi
exit "${NPM_FAIL:-0}"
MOCK
printf '#!/usr/bin/env bash\nexit 0\n' > "$FIXTURE/bin/sudo"
cat > "$FIXTURE/bin/sqlite3" <<'MOCK'
#!/usr/bin/env bash
if [ "$1" = -readonly ]; then echo ok; exit 0; fi
# Simulate a successful backup only; no SQLite database is used by these tests.
if [[ "$2" == .backup* ]]; then dest="${2#*\'}"; dest="${dest%\'}"; cp "$1" "$dest"; fi
MOCK
cat > "$FIXTURE/bin/aqe" <<'MOCK'
#!/usr/bin/env bash
if [ "$1" = --version ]; then echo latest-test-double; exit 0; fi
TRACE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/trace"
printf '%s\n' "$*" >> "$TRACE"
if [ "$1" = init ]; then mkdir -p .agentic-qe; printf 'fake database' > .agentic-qe/memory.db; fi
if [ "$1" = code ] && [ -n "${ANTHROPIC_API_KEY:-}" ]; then exit 99; fi
exit 0
MOCK
printf '#!/usr/bin/env bash\nexit "${VERIFY_FAIL:-0}"\n' > "$FIXTURE/.devcontainer/verify.sh"
chmod +x "$FIXTURE/bin/"*
export PATH="$FIXTURE/bin:$PATH" TRACE="$FIXTURE/trace" FAKE_GLOBAL="$FIXTURE/global"
cd "$FIXTURE"

# Running in the AQE development repo (or any other package) must fail before npm.
printf '{"name":"agentic-qe"}\n' > package.json
if bash .devcontainer/post-create.sh; then exit 1; fi
test ! -e "$TRACE"
printf '{"name":"checkout-demo","private":true}\n' > package.json

# Failed dependency install must not initialize memory or create env configuration.
if NPM_FAIL=1 bash .devcontainer/post-create.sh; then exit 1; fi
test ! -e .agentic-qe
test ! -e .env.local

# A fresh setup initializes once and reruns preserve participant files byte-for-byte.
bash .devcontainer/post-create.sh
test "$(wc -l < "$TRACE")" -eq 1
printf 'participant secret placeholder\n' > .env.local
cp .env.local original-env
cp .agentic-qe/memory.db original-db
bash .devcontainer/post-create.sh
test "$(wc -l < "$TRACE")" -eq 1
cmp .env.local original-env
cmp .agentic-qe/memory.db original-db

# Linked AQE data must be refused, including a dangling link.
mv .agentic-qe held-fake-aqe
ln -s held-fake-aqe .agentic-qe
if bash .devcontainer/post-create.sh; then exit 1; fi
rm .agentic-qe
mv held-fake-aqe .agentic-qe

# Even a dangling .env.local link is left untouched.
mv .env.local held-env
ln -s nonexistent-participant-env .env.local
bash .devcontainer/post-create.sh
test -L .env.local
test ! -e nonexistent-participant-env
rm .env.local
mv held-env .env.local

# Partial setup is never silently replaced. This is a fake fixture, not a DB.
mv .agentic-qe/memory.db held-fake-db
if bash .devcontainer/post-create.sh; then exit 1; fi
test ! -e .agentic-qe/memory.db
mv held-fake-db .agentic-qe/memory.db

# A failed verification leaves no marker; retry works and credentials stay local.
if VERIFY_FAIL=1 ANTHROPIC_API_KEY=fake bash .devcontainer/prepare-workshop.sh; then exit 1; fi
test ! -e .agentic-qe/devcontainer-workshop-prepared
ANTHROPIC_API_KEY=fake bash .devcontainer/prepare-workshop.sh
test -f .agentic-qe/devcontainer-workshop-prepared
cp "$TRACE" original-trace
bash .devcontainer/prepare-workshop.sh
cmp "$TRACE" original-trace
cmp .agentic-qe/memory.db original-db
echo 'Lifecycle preservation, incomplete setup, dependency failure, and retry checks: OK'
