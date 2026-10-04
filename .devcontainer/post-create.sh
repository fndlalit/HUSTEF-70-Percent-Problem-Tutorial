#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/check-workspace.sh"

# Do not echo environment variables: Codespaces can inject participant secrets.
sudo -n apt-get update -qq
sudo -n apt-get install -y --no-install-recommends gh
npm install -g --no-fund --no-audit agentic-qe@latest @anthropic-ai/claude-code@latest @openai/codex@latest
npm ci --no-fund --no-audit

# A rebuild/resume must never reinitialize a participant's existing learning DB.
if [ ! -e .agentic-qe ]; then
  aqe init --auto --skip-code-index
elif [ ! -f .agentic-qe/memory.db ]; then
  echo 'Incomplete existing AQE setup. Preserve .agentic-qe and ask a facilitator to inspect it.' >&2
  exit 1
else
  echo 'Preserving existing AQE setup and learning data.'
fi
node -e 'const p=require("node:child_process").execSync("npm root -g").toString().trim(); console.log(`Using AQE ${require(`${p}/agentic-qe/package.json`).version}`)'

# No fake payment keys, and no overwriting a participant's .env.local.
if [ ! -e .env.local ] && [ ! -L .env.local ]; then
  (umask 077; printf '# Optional: add your own Stripe TEST keys from .env.example.\n' > .env.local)
fi

printf '\nContainer ready. Next run: bash .devcontainer/prepare-workshop.sh\n'
printf 'Then: bash .devcontainer/verify.sh, sign in to your agent, and open LAB.md.\n'
