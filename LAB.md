# Workshop Lab — Copy-Paste Exercises

Six steps on this deliberately-flawed checkout app: **build a local knowledge graph (0) → Ideation → Refinement → Exploratory coverage → Defect risk profile → Development → CI/CD (1–4, with 2b and 2c) → Self-Learning (5)**, then a **Personal Adoption Roadmap**. The SDLC exercises build on each other (Refinement feeds exploration and Development; the defect risk profile picks the module Development and CI/CD work on) and each ends by saving its learnings; Step 5 turns those into an instant handoff brief. Everything indexes and embeds with a **local on-device model — your code never leaves your machine** — and it's scoped token-cheap for a whole room on personal keys.

**Pick your prompt — each SDLC exercise (1–4, 2b, 2c) has two versions:**
- **Claude Code Users** — AQE skills / orchestrator (`/qcsd-ideation-swarm`, `/exploratory-testing-advanced`, `qe-defect-predictor`, `qe-test-architect`, `qe-queen-coordinator`).
- **Non Claude Code Users** (Copilot, Codex, Gemini, …) — the same work as a generic step list via the AQE MCP tools.

Both write to the same report and end with **"Save learnings and persist patterns."** *(Step 0 is three terminal commands and step 5 is one prompt, so both are identical on every tool and have no split.)*

**Measured run times** (4 October 2026, AQE 3.14.8, Claude Code, unattended runs): Exercise 1 7.6 min / $2.59 · Exercise 2 1.7 min / $0.36 · Exercise 2b 5.0 min / $1.06 · Exercise 2c 3.1 min / $0.66 · Exercise 3 2.2 min / $0.52 · Exercise 4 1.2 min / $0.37 · Exercise 5 0.8 min / $0.32. About 22 minutes and $5.90 for the full set; interactive runs take longer because you approve tool calls.

**Before you start:** finish the [container setup](./docs/DEVCONTAINER.md) or the [README](./README.md) manual Setup (Node 22.13+ → clone → `npm install -g agentic-qe@latest` → `aqe init --auto --with-<your-tool>` → `npm install` → `aqe code index src/` → `npm install -g @huggingface/transformers@4.2.0`), then launch your agent here. **Don't skip `aqe init`** (it installs the agents, MCP config, and memory DB; container setup does this for you) and **run the exercises in order** (2b and 3 read 2's output; 3 and 4 act on 2c's ranking; 5 recalls what 0–4 saved). Paths are relative to the repo root.

---

## Exercise 0 — Warm-up: build the local knowledge graph + baseline (≈2 min)

> *Phase:* Setup · *Why:* before the fleet reasons about your code, give it a **map**. This runs entirely on your machine: static analysis plus a local embedding model, **no API key, no tokens**. Do it in your **terminal**, not through your coding agent.

```bash
aqe code index src/
aqe hg stats
aqe memory usage
```

**What you should see**

| Command | Expected on this repo |
|---------|----------------------|
| `aqe code index src/` | `Files indexed: 21` · `Nodes created: 102` · `Edges created: 117` · a few seconds |
| `aqe hg stats` | Manual setup: 140 nodes / 102 edges (function 80, file 26, module 22, test 12). Container setup: 110 nodes / 89 edges (function 68, module 21, file 21) |
| `aqe memory usage` | Entries 21 · Vectors 102 · Namespaces 1 |

The index and `hg stats` counts differ because they count different things: the indexer reports what it just created, `hg stats` reports every node type in the persisted graph. The manual and container totals differ because manual `aqe init --auto` runs its own project index first, which adds test and extra file nodes, while the container initialises with `--skip-code-index` and holds only `src/`. Both include all 21 source files. Measured on 4 October 2026 with agentic-qe 3.14.8.

> *Heads-up:* if you have an LLM provider configured for AQE, indexing also runs an optional relationship-extraction pass that calls the model **once per file**. On this repo that is 21 calls. If you would rather not spend them, run the index before you export any provider key, or accept it once here. Lines reading `LLM relationship extraction failed` mean that pass was skipped. The graph is still complete; only the inferred design-pattern edges are missing.

---

## Exercise 1 — Ideation: gate the epic before any code

> *Phase:* Ideation · *Why:* apply the QE ideation lenses to the epic and render a release gate *before a line of code is written*.

> *Why the two extra lines:* in a full dry run (1 October 2026, AQE 3.14.1, Claude Code) the swarm's security auditor runs at maximum effort and, left alone, spent 30+ minutes and dozens of web fetches. Scoped to the files and without the security audit, the swarm finished in about 8 minutes for about $2.70, with all other reports and a GO / CONDITIONAL / NO-GO verdict. Re-run on 4 October 2026 with AQE 3.14.8: 7.6 minutes, $2.59.

**▸ Claude Code Users** — the orchestrated ideation swarm. `qcsd-ideation-swarm` is installed as a **skill**, not a command file, so if your Claude Code build does not offer it after a slash, ask for it by name instead ("Use the qcsd-ideation-swarm skill to ..."):

```
/qcsd-ideation-swarm

Analyze the guest-checkout epic in requirements/epic-checkout.md,
using requirements/user-stories.md and
requirements/acceptance-criteria.md for context.
Work from these files only, with no web research. Skip the
security audit: Exercise 4 covers security.
Save all reports under reports/01-ideation-swarm/.
Save learnings and persist patterns.
```

**▸ Non Claude Code Users** — the same assessment as explicit steps:

```
Assess the guest-checkout epic before any code is written. Read
requirements/epic-checkout.md (with requirements/user-stories.md and
requirements/acceptance-criteria.md for context). Work from these files
only, with no web research. Then:

1. Recommend the quality criteria that matter most (HTSM: capability,
   reliability, security, performance, usability, …)
2. Identify the top risks and score each by likelihood × impact
3. Validate requirements completeness and testability — flag gaps,
   contradictions, and unmeasurable acceptance criteria
4. Render a single GO / CONDITIONAL / NO-GO verdict with the top blockers
5. Save the assessment to reports/01-ideation-assessment.md
6. Save learnings and persist patterns
```

---

## Exercise 2 — Refinement: product factors on the checkout app

> *Phase:* Refinement · *Why:* break the product into its real elements (SFDIPOT) and turn them into prioritised test ideas — which Exercise 3 will use.

**▸ Claude Code Users** — the product-factors agent:

```
Use qe-product-factors-assessor to analyse the guest-checkout product
from requirements/epic-checkout.md and requirements/user-stories.md.
Produce a product-factors (SFDIPOT) assessment and save it to
reports/02-refinement-product-factors.md.
Save learnings and persist patterns.
```

**▸ Non Claude Code Users** — the same assessment as explicit steps:

```
Break the checkout product into its product factors before reasoning
about coverage. Read requirements/epic-checkout.md and
requirements/user-stories.md, then analyse the product across the
SFDIPOT dimensions:

  Structure, Function, Data, Interfaces, Platform, Operations, Time.

Then:
1. For each dimension, note what the requirements imply and produce
   prioritised test ideas
2. Save the assessment to reports/02-refinement-product-factors.md
3. Save learnings and persist patterns
```

---

## Exercise 2b — Exploratory coverage: charters from the product factors (≈20 min)

> *Phase:* Refinement · *Why:* product factors tell you *what* the product is made of; exploration tells you how it behaves. The agent drafts charters from Exercise 2's test ideas and runs a first, code-level pass. You pick the charter that matters and judge what it found.

**▸ Claude Code Users** — the exploratory-testing skill:

```
/exploratory-testing-advanced

Using the test ideas in reports/02-refinement-product-factors.md,
write three time-boxed exploratory charters for the guest checkout
and run a first pass of each against src/app/checkout,
src/components/CheckoutForm.tsx and src/lib/. Label every finding
EXECUTED, STATIC or INFERRED; list the questions a human must answer.
Save to reports/02b-exploratory-charters.md.
Save learnings and persist patterns.
```

**▸ Non Claude Code Users** — the same as explicit steps:

```
Turn the refinement ideas into exploratory coverage for the guest checkout:

1. Read reports/02-refinement-product-factors.md
2. Write three time-boxed exploratory charters (mission, scope, risks,
   heuristics such as FEW HICCUPPS, and a test tour for each)
3. For each charter, explore the code in src/app/checkout,
   src/components/CheckoutForm.tsx and src/lib/ and record what you find,
   labelling each finding EXECUTED, STATIC or INFERRED
4. List the open questions only a human tester can answer
5. Save to reports/02b-exploratory-charters.md
6. Save learnings and persist patterns
```

> *Your part:* pick the one charter you would run first on a real team and say why. Then read its findings: which are evidence and which are guesses? If you have Stripe test keys in `.env`, `npm run dev` lets you run that charter against the live checkout at `http://localhost:3000`.

---

## Exercise 2c — Defect risk profile: where will the bugs be? (≈15 min)

> *Phase:* Refinement → Development · *Why:* before writing tests, decide where they pay off. The defect predictor ranks the modules by defect risk, and you check whether its ranking agrees with Exercise 3's choice of `payment-retry.ts`.

**▸ Claude Code Users** — the defect predictor:

```
Use qe-defect-predictor to build a defect risk profile for every
module in src/lib/ and src/components/CheckoutForm.tsx from
complexity, coupling and coverage (npm run test:coverage).
Rank the modules, give the top three risk factors for each with its
evidence class, and say whether src/lib/payment-retry.ts belongs at
the top of the list, and why.
Save to reports/02c-defect-risk-profile.md.
Save learnings and persist patterns.
```

**▸ Non Claude Code Users** — the same as explicit steps:

```
Build a defect risk profile for the checkout app:

1. Run npm run test:coverage and read the per-file coverage
2. For every module in src/lib/ and for src/components/CheckoutForm.tsx,
   assess complexity, coupling and coverage
3. Rank the modules from highest to lowest defect risk, with the top three
   risk factors for each, labelled EXECUTED, STATIC or INFERRED
4. Say whether src/lib/payment-retry.ts belongs at the top, and why
5. Save to reports/02c-defect-risk-profile.md
6. Save learnings and persist patterns
```

> *Your part:* coverage says `payment-retry.ts` is already at 100% of statements. If the profile still ranks it high, what is the reason, and do you agree? If it ranks something else higher, would you change the target for Exercises 3 and 4?

---

## Exercise 3 — Development: generate tests from the refinement ideas

> *Phase:* Development · *Why:* turn Exercise 2's product-factors ideas into real, runnable tests for the highest-risk module.

**▸ Claude Code Users** — the test architect:

```
Use qe-test-architect to generate a comprehensive test file for the
payment-retry logic in src/lib/payment-retry.ts. Use the test ideas in
reports/02-refinement-product-factors.md as input, and include
property-based tests for the module's invariants.
Save the test file as tests/lib/payment-retry.architect.test.ts and a
short rationale to reports/03-development-tests.md.
Save learnings and persist patterns.
```

**▸ Non Claude Code Users** — the same as explicit steps:

```
Generate tests for the payment-retry logic in src/lib/payment-retry.ts:

1. Read reports/02-refinement-product-factors.md and src/lib/payment-retry.ts
2. Write a comprehensive vitest test file covering the happy path, edge
   cases, error paths, and the module's invariants (use property-style
   tests where useful — e.g. idempotency, backoff bounds, retry limits)
3. Make sure the file imports from src/lib/payment-retry.ts and runs
4. Save the test file as tests/lib/payment-retry.architect.test.ts and a
   short rationale to reports/03-development-tests.md
5. Save learnings and persist patterns
```

> *Tip:* after this runs, `npm test -- --run tests/lib/payment-retry.architect.test.ts` to see the generated tests actually execute.

---

## Exercise 4 — CI/CD: verify the module and decide on release

> *Phase:* CI/CD · *Why:* generate nothing new — *measure, scan, gate, and recommend*. The release decision on code that now has tests.

**▸ Claude Code Users** — the queen-coordinator orchestrates the verification fleet:

```
Use qe-queen-coordinator to run a verification-only quality assessment of
src/lib/payment-retry.ts (do NOT generate tests). Analyse coverage gaps
with risk scoring, security-scan the module, apply a 90% quality gate,
and give a GO / CONDITIONAL / NO-GO deployment recommendation with the
top blockers.
Save the consolidated report to reports/04-cicd-quality-assessment.md.
Save learnings and persist patterns.
```

**▸ Non Claude Code Users** — the same as explicit steps:

```
Run a verification-only quality assessment of src/lib/payment-retry.ts
and decide on release. Do NOT generate tests — assess what exists:

1. Analyse coverage gaps with risk scoring
2. Review the module for security issues
3. Apply a quality gate at a 90% threshold
4. Give a deployment recommendation (GO / CONDITIONAL / NO-GO) with the
   top release blockers, if any
5. Save the consolidated report to reports/04-cicd-quality-assessment.md
6. Save learnings and persist patterns
```

> *Expected coverage:* `npm run test:coverage` reports **61.62% overall** on `src/`, and
> **100% of statements / 97.29% of branches on `src/lib/payment-retry.ts`** — before Exercise 3
> adds a single test. Coverage alone clears 90%, but the verdict can still be NO-GO: in the 4 October 2026
> run on AQE 3.14.8 the agent scored the gate 6 of 8 criteria and blocked release on the missing
> idempotency key. Read the module and compare. If you see roughly
> **38%** overall, your clone predates the test-scope fix — `git pull` and re-run.

> *Note:* this app keeps its testable logic in `src/lib/` (payment, Luhn, validation, rate-limiting, email) — there is **no `src/services/`**. Scoped to one file so the run finishes fast; widen to `src/lib/` for a broader verification.

---

## Exercise 5 — Self-Learning: put the fleet's memory to work (≈10 min)

> *Why:* every exercise above ended with **"Save learnings and persist patterns."** Now feel the payoff — the fleet didn't just file those away, it can hand them back **consolidated, on demand**. That's institutional knowledge working *for* you. Same prompt for every tool.

```
Recall from AQE memory what the fleet learned about this checkout app
across Exercises 1–4 — payment retry, cart state, checkout form
accessibility, and request validation.

First list what you recalled: each pattern's name and one line on what it
says. Then consolidate that into a one-page brief — top risks, testability
gaps, contradictions, and the release verdict — framed as either:
  • an onboarding brief for someone joining the project today, or
  • a handoff document for the next person enhancing the checkout app.

Where memory returns nothing for a topic, take it from reports/01 to 04
and label that part REPORTS-BASED.

Save the brief to reports/05-handoff-brief.md.
```

> *Read the list before the brief.* It should name this codebase — `payment-retry.ts`, `CartContext.tsx`, `CheckoutForm.tsx`. A list of generic testing patterns (AAA unit tests, risk-based coverage) means the recall went wide: the store holds AQE's own 70 foundational patterns alongside the ones from your exercises. Re-run naming the module you care about, or take the reports route below.

> *What to expect:* in the 4 October 2026 run (AQE 3.14.8, Claude Code) memory returned five patterns from the `learning` namespace, one per exercise that stored learnings: requirements contradictions, product factors, defect risk, payment-retry tests and the CI/CD verdict. The six seed patterns were not returned by the memory query, so cart state, form accessibility and request validation came mostly from the reports and were labelled REPORTS-BASED. A brief built only from reports is a valid result; say so in the brief rather than presenting it as memory recall.

> *What you will see along the way:* lines mentioning `brain.rvf` or `VECTOR_SPACE_UNVERIFIED`, and possibly `brain.rvf.corrupt-NNNN` files in `.agentic-qe/`. Both are expected. The optional vector index is skipped and AQE falls back to SQLite, which is the authoritative store — your patterns are saved either way.

> *If nothing comes back:* run `aqe learning stats`. It should read **`Total: 76`** or more — AQE's own foundational patterns plus the six seed patterns, and it grows as the exercises store learnings (168 after all exercises in the 4 October run). If it reads `Total: 28`, the embedder was installed after the store was first opened: the six seed patterns are stored, so carry on. If it reads `Total: 0`, setup step 5 was skipped, so nothing was ever persisted: install the embedder and run `aqe learning import -i seed/aqe-seed-patterns.json`. Short on time, consolidate from what you already have instead: *"Read reports/01 through reports/04 and write the same one-page brief to reports/05-handoff-brief.md."* See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) if you want the detail.

> *Not on Claude Code?* Claude Code captures and recalls learnings automatically through the ReasoningBank hooks. Other tools route the same work through the `memory_store` / `memory_query` MCP tools. If your agent recalls nothing there, load the seed brain above and check that `aqe learning stats` reads 76 or more before debugging anything else.

**Why this is the benefit.** You didn't re-read four reports — the fleet reconstructed the project's institutional knowledge in seconds from what each exercise saved, and a new teammate or the next run inherits all of it instantly. *(In Claude Code this capture is automatic — the ReasoningBank hooks + the `AQE Learning: N patterns loaded…` banner.)* That's the self-learning loop: agents that **remember** beat agents that start cold.

---

## After the runs — Apply PACTS

PACTS is the Agentic QE framework's evaluation lens ([agentic-qe.dev/framework](https://agentic-qe.dev/framework)). For each report, ask:

- **Proactive?** Did it flag risk *before* you asked, or only answer the prompt?
- **Autonomous?** Did it decide what to inspect, or wait for your steers?
- **Collaborative?** Did it connect findings across concerns (and across exercises), or treat each in a silo?
- **Targeted?** Was the analysis fit to *this* checkout flow, or generic checklists?
- **Structured?** Can you trace every conclusion to the agent that made it, the input it read and the reason it gave, or do you have to take it on trust?

In pairs, score each report 0–3 per property. Share the most surprising weakness.

> **Compare engines.** If your pair has both a Claude Code user and a non-Claude-Code user, diff the two reports for the same exercise: did the orchestrated swarm surface anything the step-list version missed (or vice versa)? That gap *is* the value of the orchestration layer.

---

## Your Adoption Roadmap — leave with a plan, not just reports

The point isn't the reports — it's what you do Monday. Fill this in for *your* context (≈10 min, in pairs):

1. **My context** — team, stack, and where quality hurts most today: ______
2. **The 70% I want back** — which clerical testing activity eats my team's time that an agent could take over *first*? ______
3. **First 3 agents I'll adopt** — pick from the fleet in `.claude/agents/v3/` (e.g. `qe-requirements-validator`, `qe-product-factors-assessor`, `qe-test-architect`, `qe-queen-coordinator`): ______
4. **First QCSD phase I'll start with** — Ideation gate, Refinement, Development, or CI/CD? ______
5. **One success metric (2 weeks)** — how will I know it worked? (e.g. contradictions caught *in refinement*, coverage on the riskiest module, faster GO/NO-GO calls): ______
6. **My first step on Monday** — the single smallest thing I'll actually do: ______

> Keep it small: one agent, one phase, one repo, one metric. The full fleet (60 agents and 86 skills, MIT-licensed) is already on your machine from `aqe init`, nothing held back. Start where the pain is.
