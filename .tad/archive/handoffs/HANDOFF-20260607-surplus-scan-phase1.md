---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Surplus Burn Mode — Phase 1 (Scan + Value-Score + Ranked Plan)

**From:** Alex (Terminal 1) · **To:** Blake (Terminal 2) · **Date:** 2026-06-07 · **Priority:** P2
**Epic:** EPIC-20260607-surplus-burn-mode.md (Phase 1/2)
**Status:** Expert Review Complete (2 experts, all P0 resolved) — Ready for Implementation

## 1. Executive Summary

Build the **read-only "find & rank" half** of the `*surplus` mode. A workflow scans TAD's
backlog sources + one OBJECTIVES-driven generator, ranks every candidate **value-first**
(expected value = value × confidence; density only as efficiency tiebreaker), tags
risk/safety (agent tag **OR** mechanical path-match), and writes a ranked
`SURPLUS-PLAN-{date}.md` **plus a machine-readable `.json` sidecar** for Phase 2. A minimal
`surplus` SKILL wires `*surplus --plan` (scan only — NO execution, NO mutation beyond the
two plan artifacts).

**Why:** user has large unused weekly Claude usage; wants Alex to surface highest-value
work to consume it productively. Phase 1 is the safe, immediately-useful foundation.

## 2. Requirements (from Socratic 2026-06-07)

- **Value-first** ranking, NOT token-burn theater → drop vacuous candidates AND never let cheap trivia outrank high-value work.
- Sources: existing backlog + Alex-generated new directions + research/self-evolution. **NOT cross-project.**
- Output is a human-readable ranked plan (+ JSON sidecar); `--plan` executes nothing.

## 3. Technical Design

### 3.1 `.claude/workflows/surplus-scan.workflow.js` (CREATE)
Model after the **real** workflow conventions: `meta` is a pure literal; JS not TS; args
parsed via `Object.keys` loop (loop-discover); **`parallel()` takes an array of thunks
`() => agent(...)`** (see `epic-audit.workflow.js` — loop-discover does NOT show `parallel`);
**NO `Date.now()` / `Math.random()` / `new Date()`** (forbidden — date is passed in via args).

- **meta:** `name: 'surplus-scan'`, description, phases `[{title:'Scan'},{title:'Generate'},{title:'Rank'}]`.
- **args:** `{ sources?: [paths], output_path?: string, objectives_path?: string, date?: string }`.
  **Correct defaults (P0-4 / P2-4 fix):**
  - `.tad/active/ideas/` (*.md)
  - `.tad/active/dream-candidates/` (*.md)
  - `.tad/active/epics/` (*.md — parked/planned phases)
  - `.tad/evidence/proposals/` (***.yaml**, not .md)
  - `NEXT.md` (***repo root***, not .tad/active/)
  - generator source: `OBJECTIVES.md` (repo root)
  - **A missing source dir/file → skip + `log()` it, never throw.**
- **Phase Scan** (`parallel` barrier — justified: readers are independent, all needed before rank):
  one reader thunk per source. Each returns candidates via `agent(..., {schema})`:
  ```
  { id, title, source, summary,
    value: 1-5, confidence: 0.0-1.0, token_cost: "S"|"M"|"L",
    cost_rationale: string, value_rationale: string,   // P2-3: persist WHY
    deliverable: string (CONCRETE artifact/AC — REQUIRED, non-empty),
    target_paths: [string],                             // for mechanical safety check
    safety_flag: boolean, risk_tag: "safe"|"needs-human" }
  ```
  **token_cost anchors — put these IN the reader prompt (P0-2):**
  `S` = single file, no new abstraction, ~<30k tokens · `M` = 2-4 files, moderate ·
  `L` = new workflow / Epic-phase / SAFETY-adjacent / >~100k tokens.
- **Phase Generate** (runs AFTER Scan — pipeline, NOT a barrier peer; P0-3/P0-4 fix):
  ONE generator agent receives the already-scanned candidate titles as `priorText` (loop-discover
  prior-findings pattern, lines 103-107) and is instructed: "propose only NEW directions absent
  from the list below; each MUST cite a specific OBJECTIVES KR it advances." **Cap: max 5.**
  Drop any generated item with no KR linkage (P2-1). Generated items get `source: "generated"`.
- **Phase Rank** (plain JS, no agents):
  1. Dedup: normalized title (lowercase/trim) **+** if two share normalized title, keep higher expected_value; log merges (P0-3).
  2. **Anti-theater filter (load-bearing):** drop candidates whose `deliverable` is empty/vacuous
     ("explore"/"investigate"/"improve X" with no artifact). Log `dropped` count.
  3. **Staleness filter (P1-4):** drop candidates whose source file contains `status: archived|completed|promoted`, or whose title matches an archived Epic/COMPLETION.
  4. `cost_numeric` = S/M/L → 1/3/8.
  5. **expected_value = value × confidence.** `density = expected_value / cost_numeric` (tiebreaker only).
  6. **Sort: expected_value DESC, then density DESC** (value-first; efficiency breaks ties) — P0-1.
  7. **Mechanical SAFETY override (P1-3, defense-in-depth):** `safety_flag = agent_safety_flag OR
     pathMatchesSafetyList(deliverable, target_paths)`. SAFETY list: `principles.md`,
     `alex/SKILL.md`/`blake/SKILL.md` SAFETY anchors, `security|auth|token|encrypt|password`,
     `delete|rm -`, any path outside the repo. `safety_flag === true` ⇒ `risk_tag = "needs-human"`.
  8. **auto_eligible** = `risk_tag === "safe"` AND `value >= 3` AND `source !== "generated"`
     (generated items are never auto-eligible — P2-2; value floor prevents trivia auto-run — P0-1).
  9. Write `output_path` (default `.tad/active/SURPLUS-PLAN-{date}.md`) from template +
     **a `.json` sidecar at the same stem** (`SURPLUS-PLAN-{date}.json`) with structured rows (P1-2).
     Degenerate case (0 ranked / all dropped) → render header + "0 ranked, N dropped" gracefully (P2-5).
- Return `{ plan_path, json_path, total, dropped, stale, auto_eligible, needs_human, generated }`.

### 3.2 `.tad/templates/surplus-plan-template.md` (CREATE)
Header: date, totals (total / dropped / stale / auto-eligible / needs-human), S/M/L→1/3/8 legend.
Table: `| # | Task | Source | Value | Cost | Conf | ExpVal | Density | Risk | Auto? | Deliverable | Why |`
Then a separate **"🔒 Needs You (not auto-eligible)"** section listing safety/needs-human/generated rows.

### 3.3 `.claude/skills/surplus/SKILL.md` (CREATE — scan path only)
- Frontmatter `name: surplus`, description, trigger.
- `*surplus --plan` / bare `*surplus`: SKILL **stamps the date string** (date lives at this boundary,
  keeping the workflow free of `Date.now()` — P2-4), invokes
  `Workflow({name:'surplus-scan', args:{date:'<stamp>', output_path:'.tad/active/SURPLUS-PLAN-<stamp>.md'}})`,
  then displays the ranked plan + summary. Same date string used in filename + artifact header.
- Any budget arg (`*surplus +2M`): print **"⏳ Auto-execution is Phase 2 — not yet wired. Showing ranked plan only."** then run scan path.
- SKILL body explicitly states: Phase 1 does NO execution, NO mutation except the two plan artifacts.

### 3.4 `.claude/skills/alex/SKILL.md` (MODIFY — one-line adds only)
- Add to `commands:` table: `surplus: Find + rank highest value-density backlog work (--plan); auto-burn surplus usage (Phase 2)`
- Add one bullet to `on_start` menu.
- ⚠️ DO NOT touch any SAFETY zone (`anti_rationalization_registry`, `forbidden_implementations`,
  `cross_model_awareness`, `NOT_via_alex_auto`, gate prose). Use targeted Edits on the commands list + greeting only.

## 6. Files to Modify / Create

- CREATE `.claude/workflows/surplus-scan.workflow.js`
- CREATE `.tad/templates/surplus-plan-template.md`
- CREATE `.claude/skills/surplus/SKILL.md`
- MODIFY `.claude/skills/alex/SKILL.md` (commands table + on_start only)

**Grounded Against** (Alex read at 2026-06-07; corrected per expert review):
- `.claude/workflows/loop-discover.workflow.js` (args/meta/validation + prior-findings dedup pattern L103-107)
- `.claude/workflows/epic-audit.workflow.js` (real `parallel()` thunk-array shape — the exemplar for fan-out)
- `OBJECTIVES.md` repo root (O2 alignment; KR format)
- backlog source paths CORRECTED: `.tad/active/ideas/`(26 .md), `.tad/active/dream-candidates/`(6 .md), `.tad/active/epics/`(3 .md), `.tad/evidence/proposals/`(~9 **.yaml**), `NEXT.md`(**repo root**)
- `.claude/skills/alex/SKILL.md` SAFETY anchors: `NOT_via_alex_auto: true` ×**2**, `anti_rationalization_registry:BEGIN` ×**2** (baselines for AC14)

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist
> All `grep -cE` use REAL ERE alternation `|` (NOT `\|` — escaped pipe is a literal char and was the false-PASS bug in review).

| AC# | Description | Verification Method | Expected |
|-----|-------------|---------------------|----------|
| AC1 | Scan workflow is valid JS | `node --check .claude/workflows/surplus-scan.workflow.js` | exit 0 |
| AC2 | Registered as 'surplus-scan' | `grep -c "name: 'surplus-scan'" .claude/workflows/surplus-scan.workflow.js` | ≥1 |
| AC3 | No forbidden time/random APIs | `grep -cE "Date\.now\(\)|Math\.random\(\)|new Date\(\)" .claude/workflows/surplus-scan.workflow.js` | 0 |
| AC4 | All 6 schema fields present (distinct) | `grep -oE "value|confidence|token_cost|deliverable|safety_flag|risk_tag" .claude/workflows/surplus-scan.workflow.js \| sort -u \| wc -l` | 6 |
| AC5 | Anti-theater filter is real (behavioral) | run fixture: 3 candidates {vacuous, trivial-cheap, valuable-expensive} through Rank → assert vacuous DROPPED | dropped≥1, vacuous absent from plan |
| AC6 | Ranking is value-first (behavioral) | same fixture → assert valuable-expensive (v5/L) ranks ABOVE trivial-cheap (v2/S) | exp_val order holds; v5 row above v2 row |
| AC7 | Generated items never auto-eligible | grep workflow for `source !== "generated"` in auto_eligible logic | ≥1 |
| AC8 | Plan template has required columns | `grep -c "ExpVal" t && grep -c "Density" t && grep -c "Risk" t && grep -c "Auto" t` (t=`.tad/templates/surplus-plan-template.md`) | each ≥1 |
| AC9 | JSON sidecar emitted | after live run: `test -f .tad/active/SURPLUS-PLAN-*.json && jq . .tad/active/SURPLUS-PLAN-*.json` | valid JSON, ≥1 row |
| AC10 | Mechanical SAFETY path check present | `grep -ciE "safety|principles\.md" .claude/workflows/surplus-scan.workflow.js` AND reviewer confirms `agent_flag OR path-match` | reviewer PASS + grep ≥1 |
| AC11 | surplus SKILL frontmatter | `head -5 .claude/skills/surplus/SKILL.md \| grep -c "^name: surplus"` | 1 |
| AC12 | SKILL scan-only; budget arg → Phase-2 notice | `grep -c "Phase 2" .claude/skills/surplus/SKILL.md` AND reviewer confirms no execution path | ≥1 + reviewer PASS |
| AC13 | `*surplus` registered in alex | `grep -c "surplus:" .claude/skills/alex/SKILL.md` | ≥1 |
| AC14 | alex SAFETY anchors invariant (baseline-diff) | `grep -c "NOT_via_alex_auto: true" alex/SKILL.md` AND `grep -c "anti_rationalization_registry:BEGIN" alex/SKILL.md` | 2 AND 2 (unchanged) |
| AC15 | Existing workflows untouched | `git diff --name-only -- .claude/workflows/ \| grep -v surplus-scan \| wc -l` = 0 AND surplus-scan IS in diff | 0 + present |
| AC16 | Read-only guarantee (behavioral) | `git status --porcelain .tad/active/ideas .tad/active/epics .tad/active/dream-candidates NEXT.md` before/after live `--plan` | only new path = SURPLUS-PLAN-* |
| AC17 | Live scan produces ranked plan | run `*surplus --plan` | `.tad/active/SURPLUS-PLAN-*.md` exists, ≥1 ranked row |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1 AC3 escaped-pipe → false-PASS on forbidden-API guard | §9.1 AC3 (real `|` alternation) | Resolved |
| code-reviewer | P0-2 AC4 escaped-pipe → false-FAIL | §9.1 AC4 (alternation + distinct count) | Resolved |
| code-reviewer | P0-3 AC11/AC12 wrong counts (anchors appear 2×) | §9.1 AC14 (baseline =2 AND =2) | Resolved |
| code-reviewer | P0-4 default source paths wrong (proposals/NEXT.md) | §3.1 + §6 corrected paths + graceful-skip | Resolved |
| code-reviewer | P1-1 parallel thunk shape not in exemplar | §3.1 (epic-audit cited for `parallel`) | Resolved |
| code-reviewer | P1-3/P1-5 anti-theater too soft (paper check) | §9.1 AC5/AC6 behavioral fixture | Resolved |
| code-reviewer | P1-5 read-only unverified | §9.1 AC16 git-status before/after | Resolved |
| backend-architect | P0-1 density formula floats trivia to top | §3.1 Rank.6 value-first sort + Rank.8 value≥3 floor | Resolved |
| backend-architect | P0-2 token_cost un-anchored | §3.1 S/M/L anchors in reader prompt | Resolved |
| backend-architect | P0-3 title dedup unsound | §3.1 Rank.1 dedup keep-higher + log | Resolved |
| backend-architect | P0-4 barrier defeats generator dedup | §3.1 Generate phase downstream (pipeline) | Resolved |
| backend-architect | P1-2 Phase-2 seam needs structured data | §3.1 Rank.9 JSON sidecar + AC9 | Resolved |
| backend-architect | P1-3 safety_flag single point of failure | §3.1 Rank.7 mechanical OR + AC10 | Resolved |
| backend-architect | P1-4 no staleness detection | §3.1 Rank.3 staleness filter | Resolved |
| backend-architect | P2-1/P2-2 generator scope creep | §3.1 Generate cap 5 + KR-required + never auto-eligible | Resolved |
| backend-architect | P2-3 persist scoring rationale | §3.1 schema cost_rationale/value_rationale + template "Why" col | Resolved |

## 10. Important Notes

- **10.1 Anti-validation-theater (the whole point):** two-layer defense — drop vacuous deliverables (Rank.2) AND value-first sort + value≥3 auto-floor (Rank.6/8). A concrete-but-trivial task must NOT be auto-eligible.
- **10.2 Safety routing prep:** `safety_flag` = agent tag **OR** mechanical path-match (Rank.7). Phase 2 auto/needs-human routing depends entirely on this — do not weaken it.
- **10.3 Phase-2 seam:** the JSON sidecar is the contract Phase 2 consumes. Markdown is for humans only; Phase 2 must NOT parse Markdown.
- **10.4 No core surgery:** alex/SKILL.md edits = commands table + on_start only. If it feels bigger than 2 one-line adds, STOP and flag.
- **10.5 Read-only guarantee:** Phase 1 writes exactly TWO artifacts (plan .md + .json). It must not modify any backlog source.

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Mode name | `*surplus` | clear; rename trivial |
| 2 | Phase split | scan(P1)/execute(P2) | P1 read-only + standalone-useful + low-risk |
| 3 | Ranking | value-first (exp_val desc, density tiebreak) | Socratic value-first; defeats trivia-burn (backend-architect P0-1) |
| 4 | Budget | invocation-time param | matches "跑到预算上限停"; building needs no number |
| 5 | Generated work | never auto-eligible | unvetted; scope-creep guard (P2-2) |

## Required Evidence Manifest

```yaml
expert_reviews: .tad/evidence/reviews/blake/surplus-scan-phase1/   # ≥2 Layer 2 reviewers (task_type=mixed → Tier 1)
gate_verdicts: in COMPLETION report
completion: .tad/active/handoffs/COMPLETION-20260607-surplus-scan-phase1.md
fixture_results: .tad/evidence/yolo/surplus-scan-phase1/ (AC5/AC6 anti-theater + value-first fixture output)
knowledge_updates: project-knowledge if any discovery
```
