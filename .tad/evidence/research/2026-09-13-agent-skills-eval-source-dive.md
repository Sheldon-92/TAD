---
research_complexity: comparison
research_decision_point: "For deciding whether TAD should steal ideas from darkrishabh/agent-skills-eval vs ignore it: what does the source actually implement vs OpenAI cookbook four axes and README marketing — honest fit vs TAD AC/eval, without wholesale import or npm runner in gates."
level: Deep (degraded: Local Wiki ingest/compile skipped; NotebookLM absent; Gemini forbidden; Codex adversarial off; human-preauthorized source dive)
date: 2026-09-13
channel: Cursor
model: cursor-grok-4.6-medium
parent: .tad/evidence/research/2026-09-13-openai-skill-eval-and-agent-skills-eval.md
inspected_sha: b60eebe3c6edaa917a284e13b9b0e9fa00f1c957
constraints: NO Gemini; NO Blake; NO TAD gate/product edits; NO push/tag; no live model spend
---

# Source dive: darkrishabh/agent-skills-eval

**Decision question**: Does this unofficial runner implement OpenAI’s Outcome / Process / Style / Efficiency axes, and is any of its machinery a thin TAD habit — or should we ignore it as a chat/judge A/B toy?

Parent note closed README-level claims and left **judge prompt, assertion schema, pass-rate formula** unverified. This file reads `src/` at the SHA above.

## Effort classification (Phase 0class)

- **Tier**: comparison (this repo vs cookbook four axes vs TAD AC/eval). Not a landscape survey.
- **dynamic seeds**: on. Extra web seeds not needed once tree + tests + CI were read.
- **adversarial (Codex+Gemini)**: **off** (comparison default + human `NO Gemini`).
- **Clone**: `git clone --depth 1` → `/tmp/agent-skills-eval` (deleted after write). Remote: `https://github.com/darkrishabh/agent-skills-eval`.

## Provenance (retrieved 2026-09-13)

| ID | Locator | Role |
|----|---------|------|
| R1 | `git rev-parse HEAD` = `b60eebe3c6edaa917a284e13b9b0e9fa00f1c957` | Inspected tree |
| R2 | commit subject `Prepare metadata release` 2026-05-06 17:58:39 -0700 | Latest **main** commit in clone |
| R3 | `gh api repos/darkrishabh/agent-skills-eval` | stars **734**, forks **35**, MIT, created 2026-05-06, `pushed_at` 2026-08-05, archived false, open_issues **14** |
| R4 | `npm view agent-skills-eval` | **0.1.1** published 2026-05-07; 0.1.0 on 2026-05-06. No git tags on GitHub |
| R5 | `package.json` version 0.1.1, author Rishabh Mehan | Matches npm |
| R6 | Parent S1 OpenAI cookbook four axes | Cross-check target |
| R7 | Parent S6 agentskills.io evaluating-skills | Adjacent spec (not re-fetched this session) |

**Unverified**: contents of Dependabot PRs (CI ran on `73a5c1e5…` 2026-08-05, not merged to `main` as of this pull). Live chat/judge quality. Whether agentskills.io *requires* dropping eval files on the baseline arm.

---

## 1. What the repo is (architecture)

Small **TypeScript ESM** CLI/SDK. **42 tracked files**. No agent runtime.

```
src/
  cli.ts                     # commander; OpenAI-compatible only
  evaluate-skills.ts         # discover → pool → aggregate → HTML
  run-eval.ts                # one eval × modes: target chat then judge
  grade.ts                   # LLM rubric + local tool_assertions
  skill.ts                   # SKILL.md + evals/evals.json parse
  discover.ts                # walk for SKILL.md + evals.json
  openai-compatible-provider.ts
  artifacts.ts / report.ts / console-reporter.ts / jsonl-reporter.ts
examples/basic-skill/        # one CSV “highest revenue month” fixture
test/{cli,skills}.test.mjs   # node:test against dist/; mock providers
```

**Runtime deps**: `commander`, `js-yaml` only. **Dev**: TypeScript, `@types/node`. **engines**: Node ≥18.

**Not present**: Codex/`codex exec`, Playwright, MCP client, tool *execution* loop, workspace mutation, git-delta graders, `should_trigger` CSV.

### Main loop (`evaluate-skills.ts`)

1. `discoverSkills` — recursive walk; skip `node_modules`/`.git`/`dist`/`.next`; keep dirs with `SKILL.md` **and** `evals/evals.json`.
2. `loadSkill` — parse frontmatter + body; optional `strict` kebab-name / dir match / description length.
3. Modes: `baseline ? ["with_skill","without_skill"] : ["with_skill"]`. **CLI default `baseline: false`** (`cli.ts` ~148).
4. Bounded pool, default **concurrency 4** (up to **2×** HTTP: target + judge per case).
5. Per skill: `benchmark.json` via `buildBenchmark`.
6. HTML report unless `report: false`.
7. **Headline `passed`/`failed` only from `with_skill` assertion counts** (`evaluate-skills.ts` 254–258). Baseline arm does not affect `process.exitCode` (`cli.ts` 165: `failed > 0`).

### Chat A/B (`run-eval.ts`)

**with_skill**: system = XML wrapping **full `SKILL.md` body** plus `references/*.md|mdx` and script **shebang/manifest** (not full script unless `includeScriptBodies`). User = `evals[].prompt`. Eval `files[]` inlined as XML (`OpenAICompatibleProvider.capabilities.attachments === false`).

**without_skill**: **no system skill**. **Eval files are not attached** (`run-eval.ts` 191: `evalFiles = mode === "with_skill" ? readEvalFiles(...) : []`). Same prompt string. Same tools / `tool_choice` / params.

Then **one** `complete` / `completeChat` — **no follow-up tool results**. If the model returns `tool_calls`, they are stored; tools are **not executed**.

### Judge (`grade.ts`)

Default prompt (lines 124–154): “You are grading an agentskills.io evaluation run.” Strict JSON `assertion_results[]` with `passed` + `evidence`. Fail-closed: unparseable JSON → all rubric assertions FAIL (2 attempts). `passed === true` only (not truthy). Judge `summary` **recomputed locally**.

If `assertions` empty and `expected_output` set, runtime synthesizes one assertion from expected text (`run-eval.ts` 221–226). If **both** empty: only `tool_assertions` grade; if those also empty, `pass_rate` is **1** (`summarize`: `total === 0 ? 1`).

**Tool assertions** (local, no LLM): `tool-called` | `tool-not-called` | `tool-arg-equals` | `tool-arg-contains` | `tool-arg-matches` | `tool-call-count`. Combined **after** rubric results. **`deepEqual` uses `JSON.stringify`** (issue #31: key order). **No tests** in `test/*.mjs` mention `tool-called` / `runToolAssertions` (grep: 0).

Custom `gradingPrompt` can replace the default rubric text.

### Scoring / artifacts

Per mode: `timing.json` (`total_tokens` = prompt+completion; `duration_ms` = provider latency), `grading.json`, `outputs/response.txt`, `prompts.json`, optional `tool_calls.json`.

`benchmark.json` `run_summary`: mean/stddev of **per-eval pass_rate**, time, tokens; `delta` = with − without (means). **Not** a paired Wilcoxon; **not** OpenAI axes.

Skill `passRate` in CLI JSON = `with_skill` passed/(passed+failed); empty → 1.

### Fixtures

`examples/basic-skill`: one eval, CSV `evals/files/revenue.csv`, assertions “February” and “18”. **No** `tool_assertions`, **no** negative-control prompt, **no** process/style/efficiency rubric.

### CI

`.github/workflows/ci.yml`: Node 18/20/22, `npm ci`, typecheck, `npm test`, `npm pack --dry-run`. **No live API**. `CI=true` forces `iteration-1` wipe (`artifacts.ts` 179–184). Publish on GitHub Release + npm provenance. Dependabot weekly. Last **main** code: May 2026; Aug 2026 activity is Dependabot/CI on **unmerged** SHAs.

---

## 2. README vs code

| README / marketing | Code |
|--------------------|------|
| “Every eval runs both ways” | Only if `--baseline` / `baseline: true`. Default is with_skill only. |
| Quickstart `npx … --target --judge --baseline --strict` | **Requires** `OPENAI_BASE_URL` or `--base-url` **and** API key env. Missing either → throw. Default OpenAI URL is **not** assumed. |
| “same prompt twice… skill stripped” | Prompt string same; **files dropped** on without_skill. Skill A/B confounded with “got the CSV”. |
| “Judge sees expected_output and assertions” | Judge sees **assertions** (or promoted expected_output). `expected_output` is **not** a separate field in the default judge prompt unless promoted. |
| “Fully spec-compliant” including `assets/` | `skill.ts` loads `references/` + `scripts/`. **No `assets/` loader**. `allowed-tools` parsed onto `Skill.allowedTools` and **never used** in run/grade. |
| Scripts in context | Default: shebang line only (`includeScriptBodies` default false). |
| Tool-call assertions for “agents that call tools” | Wire `tool_calls` on **first** Chat Completions response. No MCP (open issue #28). No command JSONL. |
| JSONL all the way down | Optional `--log-format jsonl` event log. Artifacts are JSON files, not Codex JSONL. |
| Separated from any specific agent runtime | True: it is a **chat Completions** harness, not Claude/Codex/OpenCode. |

---

## 3. Cross-check vs OpenAI cookbook four axes (S1)

Cookbook meanings (parent S1): Outcome = task completed / app runs; Process = intended skill/tools/steps; Style = conventions; Efficiency = thrash / extra commands / tokens. Deterministic JSONL **first**; rubric **second**. Negative control (test-04). Real Codex workspace.

| Axis | This repo implements? |
|------|------------------------|
| **Outcome** | **Partial, LLM-mediated.** Free-text assertions on **chat text**. No `npm run`, no file-exists, no “app runs.” Example fixture is “did the model say February.” |
| **Process** | **No** skill-trigger detection. with_skill **forces** SKILL.md into system; the model cannot “choose” the skill like Codex `$skill`. `tool_assertions` can check **declared** function names on the **first** message only — not “did it run npm install.” |
| **Style** | **Only if you write style assertions** for the judge. No `--output-schema` second Codex pass. Same judge grades both arms independently (not a comparative pairwise judge). |
| **Efficiency** | **Telemetry only.** Tokens and latency stored and delta’d. **Not** an assertion unless you invent one. No command-count thrash check. |

Philosophical overlap: prove skill lift vs vibes; keep artifacts. **Not** a 1:1 of S1. Closer to parent **S6** (agentskills.io with/without + judge assertions) than to the Codex cookbook.

**Do not** confuse with **caohaotiantian** static “Outcome/Process/Style/Efficiency” file lints (parent §3.3). Those words do not appear as scored columns in this `src/`.

---

## 4. Failure modes (honest)

1. **A/B confound**: baseline lacks files → “skill lift” can be “had data.” Tests never assert without_skill prompt **omits** the CSV (`skills.test.mjs` only checks `prompts[0]` = first mode = with_skill).
2. **Judge = target** common in README (`gpt-4o-mini` both) → correlated errors; not independent review.
3. **Vacuous PASS**: zero assertions → `pass_rate = 1`.
4. **CI exit ignores baseline failures**: `without_skill` can FAIL every assertion while with_skill PASSes → exit 0.
5. **One-shot tools**: `tool_choice: required` can yield empty `content` + tool_calls; rubric then grades empty/error text unless assertions are tool-only.
6. **Provider errors swallowed**: `completeChat` catch returns `error` string as output; still sent to judge.
7. **Attachments `kind: missing`**: missing CSV becomes empty XML, still “attached.”
8. **Concurrency**: suite-end order nondeterministic; race on `completed === evals.length` assumed safe on one JS thread.
9. **Staleness**: 734 stars vs **~May 2026** code on `main`; no tags; Dependabot PRs not in inspected SHA.
10. **No tool-assertion unit tests.**

---

## 5. Honest fit vs TAD AC / eval

TAD already: verifiable AC, known-GOOD/known-BAD, traces/carriers, pack `discriminative_pattern` + CONTROL must FAIL, Layer 2 independent reviewers, trajectory rubric D1–D5 (`.tad/eval/`), process-tax-cut ≠ token Efficiency.

| This repo | TAD analogue | Fit |
|-----------|--------------|-----|
| Chat with/without SKILL.md | Pack WITH vs CONTROL fixtures | Same **idea**; TAD object is **protocol behavior**, not stuffing SKILL.md into `system`. |
| LLM judge + evidence strings | Blind judges; provenance-check pack-eval pattern | TAD already treats judge tables as **untrusted** until file cross-check. |
| Local `tool_assertions` | Deterministic graders / verify-delta Methods | **Closest technical cousin** — but TAD checks **repo/commands**, this checks **chat tool_calls JSON**. |
| `benchmark.json` delta | Not a Gate number | Would be **validation theater** if wired as Gate 3. |
| HTML report | Evidence markdown | Ignore. |
| `strict` frontmatter | Pack/skill authoring lint | Orthogonal to runtime Outcome. |

**TAD skills** (Alex/Blake SKILL.md, capability packs) are **loaded by harness routing**, not by this XML system prompt. Importing the runner would eval a **different product**.

---

## 6. Claim table (this dive)

| Claim | Result | Locator |
|-------|--------|---------|
| Unofficial MIT TS runner, npm 0.1.1 | ✅ | R3–R5 |
| Paired with/without exists | ✅ optional | `evaluate-skills.ts:140` |
| Judge JSON fail-closed | ✅ | `grade.ts` failClosed / 2 retries |
| pass_rate = passed/total, empty=1 | ✅ | `grade.ts:52-56` |
| Tool assertions local | ✅ | `grade.ts` runToolAssertions |
| Implements named Outcome/Process/Style/Efficiency | ❌ | no identifiers in `src/` |
| Codex JSONL / workspace mutation | ❌ | absent |
| Default baseline on | ❌ | CLI false |
| Full agentskills.io including assets + allowed-tools enforcement | ❌ / ⚠️ overclaim | no assets load; allowed-tools unused |
| Live eval quality | ⚠️ unverified | no spend |
| Merged Dependabot SHAs | ⚠️ not on inspected main | R3 vs CI `73a5c1e5` |

---

## 7. Decision brief (PM)

### What we learned

It is a **small Chat Completions A/B** with a **strict-JSON judge** and optional **local tool_call predicates**. Popular README, thin tests, **confounded baseline**, **no OpenAI four-axis scorer**, **no Codex**. Stars ≠ maintenance (main frozen at `b60eebe3`).

### Keep / ignore

- **Keep (mental model only)**: independent grading of two arms; fail-closed JSON; local checks before LLM; write prompts.json so you can see what the model saw.
- **Ignore as product**: npm CLI in TAD Gates, HTML reports, stuffing full skill as system, their exit-code semantics, “spec-complete” marketing.

### Do not import (explicit)

1. `agent-skills-eval` npm / `npx` into `.tad/gates/` or Gate 3.
2. Chat-judge `pass_rate` / `benchmark.json` delta as a Gate number.
3. with/without XML SKILL.md as a substitute for pack CONTROL fixtures.
4. Their default “judge = target model.”
5. `iteration-N` workspace as TAD evidence SSOT.
6. caohaotiantian 5-dim **or** this repo’s marketing as “OpenAI four axes.”
7. Tool-assertion types as a replacement for `codex exec --json` / AC Methods.

### Thin seeds (new vs parent — max 3)

Parent already has false-trigger row, deterministic-before-judge docs sentence, don’t map static 5-dim onto Outcome. **New from this SHA:**

1. **Hold-constant A/B**: if anyone later writes with/without skill evals, **files, tools, and prompt must match**; this repo drops files on the baseline arm — copy that and the “lift” is fake.
2. **tool_calls ≠ process axis**: a one-shot Chat Completions `tool_calls` array is not OpenAI Process (skill invoked / commands run). Don’t add MCP/tool-loop claims without a real agent loop (their #28).
3. **Empty-assertion vacuous 1.0**: same class as vacuous AC — `total===0 → pass_rate 1` must not be copied into TAD Gates.

**Still no Blake, no Gate rewrite, no runner.**

### Unknown / risks

- agentskills.io may *intend* baseline without files (unverified vs S6).
- Open issues (#31 stringify equality, #28 MCP, EvalPort receipts) not implemented on `main`.
- Clone deleted; re-read at `b60eebe3` to reproduce.

## Protocol notes / degradation

- Local Wiki: `research/canon` present; **no ingest this session** (single evidence path; avoid wiki churn).
- NotebookLM: missing.
- Phase 0c/4c: not run.
- Health (activation): session-state COMPLETE (prior skill-authoring Gate 4); several `HANDOFF-*` still under `.tad/active/handoffs/` (stale twins / v2.44.5) — **not cleaned** (out of scope).

## Paths

- This file: `.tad/evidence/research/2026-09-13-agent-skills-eval-source-dive.md`
- Parent: `.tad/evidence/research/2026-09-13-openai-skill-eval-and-agent-skills-eval.md`
- PM: `docs/pm/now.md`
