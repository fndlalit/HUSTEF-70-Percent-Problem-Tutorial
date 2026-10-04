# Container verification and adversarial review

Verified 4 October 2026 against tutorial base
`42f7e0854ab24302122875ac90a6929b6ef763a3`.

| Check | Result |
|---|---|
| Docker build on Linux arm64 / Apple Silicon | Passed |
| Dev Container CLI 0.89.0 `up` and post-create | Passed |
| DevPod with Docker, isolated test workspace | Passed |
| Runtime tools | Node 22.23.2; AQE 3.14.8; Claude 2.1.289; Codex 0.160.0; gh 2.102.0 |
| `npm run test:coverage` | 12 files, 333 tests passed; 61.62% statements overall |
| `npx --no-install tsc --noEmit` | Passed |
| `npm run build` without Stripe credentials | Passed |
| `bash .devcontainer/smoke-app.sh` | Catalog, cart, missing-order HTTP 400 passed; no payment attempted |
| `bash .devcontainer/verify.sh` | All 21 source files indexed; 6/6 seeds with 384-dimensional embeddings; 76 patterns; integrity `ok` |
| MCP handshake/tool catalog | Passed; 91 tools |
| MCP seeded-data recall | Not qualified: tested queries returned zero entries; reports fallback documented |
| Re-run post-create and preparation | Test database SHA-256 unchanged; seed/graph verification passed |
| `bash .devcontainer/test-lifecycle.sh` | Wrong repository, linked memory, dangling env link, incomplete setup, failed install, failed verification, retry, and repeated preparation checks passed |
| Shell syntax and `git diff --check` | Passed |

The GitHub Actions workflow repeats the container build, fresh preparation,
MCP protocol check, unit coverage, TypeScript check, and app smoke check on Linux
amd64. The MCP protocol check explicitly reports empty recall; CI success must
not be described as qualification of the memory-learning exercise.
The first Linux amd64 run also passed all 333 tests and verified the 21 source
paths and six embedded seed patterns. CI uses current `actions/checkout` with
credential persistence disabled, and restores runner file ownership after Docker.

## Adversarial findings and resolution

1. AQE `--version` can create an empty `.agentic-qe` directory before init.
   Setup now reads package metadata for its version report.
2. Root-owned global npm packages blocked latest-tool updates by the workspace
   user. The image installs npm tools as `node`; post-create refreshes latest.
3. CLI import output said zero imported even when seed writes succeeded.
   Readiness verifies each seed name and embedding in SQLite instead.
4. A shallow graph counter alone could conceal skipped API routes. Readiness
   checks the persisted path for every source file, including both API routes.
5. Automatic setup could damage existing memory or overwrite `.env.local`.
   Init is gated on absent AQE data; partial setups stop; symlinks are refused;
   env files/links are preserved; preparation backs up before initial writes;
   no post-start mutation hook is installed.
6. Provider keys injected by Codespaces could make indexing spend tokens.
   Indexing receives a minimal child environment without provider credentials.
7. Passing setup could be mistaken for working Stripe payments or memory recall.
   Those limits are separated in participant docs and the slide handoff.

## Remaining acceptance limits

Actual Codespaces creation was unavailable because the current GitHub token
lacks Codespaces scope. The standards-based config is validated locally;
Lalit/Dragan should create a Codespace from the PR branch before the workshop.
Agent sign-in and paid QCSD exercises were not executed. External product
images may fail independently of the container. Intentional application defects
and the existing app dependency lockfile were preserved.

All database operations occurred only in the disposable tutorial test workspace
under `/private/tmp`, with backups before preparation. The local AQE development
checkout and its learning database were never mounted in these containers or
modified by these setup scripts.
