# Workshop container — Codespaces or local Docker

For the **6 October 2026** tutorial, this is an alternative to the manual Setup
in README. It uses the same app and exercises, **latest published AQE**, and local
embedder **4.2.0**. Node 22 satisfies AQE's engine requirement. The presentation
mentions AQE 3.14.1; this container and the updated manual setup use the latest
release instead (3.14.8 at verification on 4 October 2026).

## GitHub Codespaces

1. Open the repository → **Code → Codespaces → Create codespace on main**.
   Before this PR is merged, select its `codex/workshop-devcontainer` branch.
2. Allow the container build and setup to finish. Select a 4-core machine with
   8 GB RAM if available. Your own GitHub Codespaces allowance/billing applies.
3. In the terminal run:

   ```bash
   bash .devcontainer/prepare-workshop.sh
   bash .devcontainer/verify.sh
   node .devcontainer/verify-mcp.mjs
   npm run test:run
   ```

4. Sign in to your coding agent **inside the container**. Run `claude` for
   Claude Code, trust the workspace and approve the `agentic-qe` MCP server.
   Codex CLI is also installed: run `aqe init --auto --with-codex` deliberately
   if choosing Codex, then `codex login --device-auth`. This configuration step
   is manual so a restart cannot overwrite your chosen agent configuration.
   Other agents use the matching README setup flag and their own authentication.
5. Open **LAB.md**. The preparation command already performed Exercise 0 and
   loaded the six checkout seed patterns; inspect the output as your baseline.

The first preparation downloads the embedding model. Do this **before arriving**;
neither first-time setup nor agent use is offline. Indexing and embeddings run
inside the container. In Codespaces that means on GitHub's machine; agent
exercises still use your chosen model provider and tokens.

## DevPod + Docker on your laptop

Start Docker Desktop (or your Linux Docker daemon), install DevPod, then:

```bash
git clone https://github.com/fndlalit/HUSTEF-70-Percent-Problem-Tutorial
cd HUSTEF-70-Percent-Problem-Tutorial
# Before merge: git switch codex/workshop-devcontainer
devpod provider add docker   # once; skip if already configured
devpod up . --provider docker --id hustef-70-percent
```

Run the same preparation, verification and sign-in steps in the new workspace.
The image supports Linux amd64 and arm64 (Apple Silicon uses Linux containers);
there is no forced amd64 emulation. Allow at least 8 GB RAM and 32 GB disk.
Alternatively, open this clone in VS Code and choose **Dev Containers: Reopen
in Container** with the Dev Containers extension installed.

## Run the subject app

```bash
npm run dev -- --hostname 0.0.0.0 --port 3000
```

Open port **3000** in the editor's Ports view. In Codespaces keep its visibility
**Private**; its forwarded URL is HTTPS. In local DevPod use the forwarded
localhost address. If port 3000 is already occupied on your laptop, choose a
different local forwarded port. Do not change the app port without updating
the forwarding configuration.

The catalog, cart, tests, static analysis, and QCSD exercises need **no Stripe
keys**. A real checkout requires your own Stripe **test-mode** publishable and
secret keys in the ignored `.env.local` file (see `.env.example`), or Codespaces
secrets; restart Next.js after setting them. Placeholder keys are not working
credentials. Never use live keys or real card data for this deliberately flawed
app. Without keys the Stripe checkout/payment route is expected to fail; a
green environment check does not claim a completed payment.

Product images load from an external placeholder host and may be unavailable.
Orders live in process memory; restarting Next.js loses those demo orders.
Kafka is a test abstraction using an injected send function, so no broker,
PostgreSQL, Redis, Rust, or Docker socket is needed in the workspace.

## What setup changes and preserves

- The image installs latest AQE, Claude Code, Codex, and GitHub CLI, plus Transformers 4.2.0.
  The base Node 22 image receives upstream maintenance updates.
- `post-create.sh` refreshes AQE, Claude Code, Codex, and GitHub CLI to latest even with a cached Docker image,
  runs `npm ci` against the committed app lockfile and initializes
  AQE only if `.agentic-qe` does not exist. It creates an empty private `.env.local`
  only if absent. It never installs dependencies or rewrites memory on resume.
- `prepare-workshop.sh` is an explicit first-run action that indexes `src/`,
  warms the embedding model, and imports the seed. After successful verification,
  a marker makes subsequent runs a no-op. It creates a timestamped SQLite backup
  before these writes and checks integrity afterward. It does not erase existing data.
- `verify.sh` checks tooling, exercise assets, all source files in the graph,
  all six seed patterns with embeddings, and the existing database read-only.
  Run tests/coverage separately; verification never runs a paid agent exercise.
- Reports and AQE's SQLite database remain in your workspace across restarts.
  Back up/export work before deleting a Codespace or DevPod workspace. A model
  cached in the container home may need downloading again after a rebuild.

Transformers is the same explicit local-embedding opt-in described in README,
including its dependency advisory caveat. If your policy forbids it, use manual
setup with a trusted embedding endpoint rather than this default image.

## Troubleshooting

- **Incomplete `.agentic-qe`:** setup stops instead of repairing or deleting it.
  Ask a facilitator to inspect it. Never delete a learning database to make a
  setup check green.
- **Import says `Imported: 0`:** see TROUBLESHOOTING.md. SQLite is authoritative;
  verify the actual six seed patterns, not that misleading import counter.
- **Model download fails:** check proxy/network access to npm and Hugging Face,
  then rerun preparation. The completion marker is only written after success.
- **Agent signed in on the host only:** container credentials are separate.
  Use its login flow, or supply your own provider key as a Codespaces secret.
- **Graph counts differ:** counts can vary with the index pass and configured
  providers. Check all 21 source files are indexed; do not treat one total as
  proof that every file was included.
- **MCP memory on non-Claude agents:** TROUBLESHOOTING.md describes a limitation
  observed on AQE 3.14.1. Do not assume a newer version behaves identically;
  verify recall on your chosen agent, and use LAB.md's reports fallback if needed.
  On AQE 3.14.8 our isolated MCP handshake exposed 91 tools, but both a glob
  query of the graph namespace and a semantic payment-retry query returned zero
  entries despite the verified SQLite seed. The MCP smoke check reports this
  limitation explicitly; `--require-recall` makes it fail. This is transport
  validation, not proof that Exercise 5 can recall your agent's learnings.

References: [port forwarding in Codespaces](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace),
[Dev Container configuration](https://containers.dev/implementors/json_reference/).
