# Slide update handoff for Lalit

Deck reviewed: [HUSTEF2026-Agentic-QCSD-Tutorial_4.pptx](https://docs.google.com/presentation/d/1Ee9y8tHL4n8rWdCikyhNwlpWEVxXr6wT/edit).
This note proposes edits; the presentation itself has not been changed.

## Slide 4 — replace setup instructions

Change the heading to **“Setup in your workshop workspace”**. Present two paths:

**Recommended: Codespaces or DevPod + Docker**

1. Open the tutorial repo in Codespaces, or `devpod up . --provider docker`.
2. Wait for setup, then run `bash .devcontainer/prepare-workshop.sh`.
3. Run `bash .devcontainer/verify.sh` and `npm run test:run`.
4. Sign in to your agent inside the container; trust the workspace and approve AQE MCP.
5. Open `LAB.md` and inspect Exercise 0's prepared baseline.

Link to `docs/DEVCONTAINER.md` in the tutorial repository. Keep manual setup as
the alternative, but change **`agentic-qe@3.14.1` → `agentic-qe@latest`** and
**“Node 20 or newer / EBADENGINE expected” → “Node 22.13 or newer and npm 10+”**.
Container tooling includes latest AQE, Claude Code CLI, Codex CLI, and GitHub CLI.
The local embedder is installed before the container's seed import.

Replace “Everything after this runs against your laptop” with:

> Work in your own workshop workspace. DevPod runs locally through Docker;
> Codespaces runs on GitHub. Agent exercises use your own model access and tokens.

Speaker note: use a fresh tutorial workspace; never point it at an existing AQE
development checkout or copy over its learning database. On manual setup,
install the embedder and prepare the local baseline before adding provider keys.

## Slide 5 — distinguish baseline counters and hosting

Keep **21 files / 102 nodes / 117 edges** as the observed index-command output,
and **21 entries / 102 vectors** as the memory-usage baseline. These were
reproduced with AQE 3.14.8. Replace “the same graph, counted by node type” with:

> `aqe hg stats` shows the persisted hypergraph separately. Check every source
> file is present; its totals differ from the index command's counters.

Observed persisted graph: **110 nodes / 89 edges**, with 21 file nodes, 21 module
nodes, and 68 function nodes. Avoid promising those totals across future AQE
releases; the readiness check verifies all source paths instead.

Replace “Your code never leaves the machine” with:

> This baseline uses static analysis and local embeddings inside your workspace.
> It needs no provider key. In Codespaces, the workspace is hosted by GitHub.
> Later agent exercises use your selected model provider.

Speaker note: a container has already prepared Exercise 0. Inspect its output
instead of reinitializing memory. Preparation makes a backup before initial
index/seed writes and does not repeat them after successful completion.

## Slides 10, 11 and any repeated fleet-count claims

Remove stale hard-coded **“60 QE agents”** unless we establish which count the
slide means. The fresh AQE 3.14.8 initialization installed **53 `qe-*.md` files**
and **86 skill entrypoints**. These file counts do not prove a runtime fleet size
or the number of agents in a particular swarm. Suggested wording:

> A specialized QE agent fleet and skills spanning the QCSD lifecycle.

Keep the phase architecture, but verify per-swarm headcounts against the skills
installed in the latest package before retaining the numerical labels.

## Slides 18, 21, 23, 25, 27 and 29 — add a setup prerequisite note

The named agents and the `qcsd-ideation-swarm` and
`exploratory-testing-advanced` skill files were present in the fresh container.
Add a single shared note, or cover it verbally before Exercise 1:

> Your chosen agent must be signed in inside this workspace. Approve the AQE
> MCP server and verify the skills load before starting the timed exercises.

Do not imply that host-machine login automatically carries into a container.
Manual configuration flags for other agents remain in README.

## Slides 32–33 — make the memory fallback explicit

Keep the instruction to list recalled findings before composing the brief.
Add this fallback box:

> If AQE memory recall returns no checkout findings, use your saved reports from
> Exercises 1–4. Label the brief **REPORTS-BASED**, and say that memory recall was
> unavailable. Do not present it as evidence that the memory loop succeeded.

Latest-version evidence: AQE 3.14.8 stored all six seed patterns with
384-dimensional embeddings in SQLite (76 patterns total). Its MCP server
completed a handshake and exposed 91 tools, but the tested graph-namespace and
semantic checkout queries returned **zero entries**. Stored seed data and
successful agent-side recall are separate gates. The container smoke check
prints this limitation; adding `--require-recall` makes that check fail.

## What can remain as written

- Slide 29's existing coverage numbers were reproduced: **61.62% overall**;
  payment-retry **100% statements / 97.29% branches**. The code's intentional
  idempotency and jitter flaws remain available for the exercises.
- The epic, stories, acceptance criteria, output paths, and exercise order are unchanged.
- The catalog, cart, unit tests, and static QCSD work need no Stripe credentials.
  Actual payment checkout requires participants' own Stripe **test-mode** keys;
  optional app demonstrations should say this before opening checkout.

## Facilitator preflight before 6 October

Create a fresh workspace, allow latest tool updates, and run preparation,
readiness, tests, and the MCP smoke check. Record the actual AQE/agent versions
used that day. Test sign-in and one scoped agent exercise with your own account;
the automated container checks deliberately do not spend model tokens.

Local DevPod/Docker and Dev Container CLI startup were exercised on Apple
Silicon. GitHub Codespaces creation could not be exercised with the available
GitHub token (missing Codespaces scope); confirm the browser-based Codespaces
path from the PR branch before recommending it to the whole room.
