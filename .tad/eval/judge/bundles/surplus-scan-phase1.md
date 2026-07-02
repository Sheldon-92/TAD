
# HANDOFF: surplus-scan-phase1

---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

---

## §9.1 Spec Compliance Checklist (excerpt)
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

---

## §6 Implementation Steps (head)
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

---

## §9.2 Expert Review Audit Trail
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

---


# COMPLETION: surplus-scan-phase1

---
gate3_verdict:
---

# Completion Report: Surplus Burn Mode — Phase 1 (Scan + Value-Score + Ranked Plan)

**From:** Blake (Terminal 2) · **To:** Alex & Human · **Date:** 2026-06-07
**Handoff:** HANDOFF-20260607-surplus-scan-phase1.md · **Epic:** EPIC-20260607-surplus-burn-mode.md (Phase 1/2)
**Status:** Implementation complete — Layer 1 ACs PASS — Gate 3 pending (Conductor)

---

## 1. What Was Done

Built the read-only "find & rank" half of `*surplus`, exactly per §3:

1. **CREATE `.claude/workflows/surplus-scan.workflow.js`** — 3-phase workflow:
   - **meta** is a pure literal; `name: 'surplus-scan'`; phases `Scan`/`Generate`/`Rank`.
   - Args parsed via `Object.keys` loop (loop-discover convention): `sources`, `output_path`, `objectives_path`, `date`.
   - **Defaults (P0-4 corrected):** `.tad/active/ideas/*.md`, `.tad/active/dream-candidates/*.md`, `.tad/active/epics/*.md`, `.tad/evidence/proposals/*.yaml`, `NEXT.md` (repo root); generator reads `OBJECTIVES.md` (repo root). Missing source → reader returns `[]` + `log()`, never throws.
   - **Scan** = `parallel()` barrier of thunks `() => agent(..., {schema})`, one reader per source. Reader schema carries all fields incl. `cost_rationale`/`value_rationale`/`target_paths`. S/M/L token-cost anchors embedded in the reader prompt.
   - **Generate** runs downstream of Scan (pipeline, not a barrier peer): ONE generator gets scanned titles as `priorText`, must cite an OBJECTIVES KR per item, capped at 5, KR-less items dropped, all tagged `source: 'generated'`.
   - **Rank** (plain JS, no agents): dedup-by-normalized-title keep-higher-expected_value + log; anti-theater drop of vacuous deliverables; staleness drop (`status: archived|completed|promoted`); `cost_numeric` S/M/L→1/3/8; `expected_value = value × confidence`; `density = expected_value / cost_numeric`; **sort expected_value DESC then density DESC** (value-first); mechanical SAFETY override (`agent_flag OR pathMatchesSafety(deliverable, target_paths)`); `auto_eligible = risk==='safe' && value>=3 && source!=='generated'`. Degenerate case (0 ranked) renders header + "0 ranked, N dropped" gracefully.
   - Returns `{ plan_path, json_path, plan_markdown, sidecar_json, total, dropped, stale, auto_eligible, needs_human, generated }`.

2. **CREATE `.tad/templates/surplus-plan-template.md`** — header + totals + S/M/L legend; table cols `# | Task | Source | Value | Cost | Conf | ExpVal | Density | Risk | Auto? | Deliverable | Why`; separate `🔒 Needs You (not auto-eligible)` section.

3. **CREATE `.claude/skills/surplus/SKILL.md`** — frontmatter `name: surplus`; `--plan`/bare stamps date + invokes `Workflow({name:'surplus-scan', ...})`; budget arg prints the exact Phase-2 notice then runs scan path; body states NO execution / NO mutation beyond the two plan artifacts.

4. **MODIFY `.claude/skills/alex/SKILL.md`** — exactly two one-line adds: `surplus:` in the `commands:` table (right after `skillify:`) and a `*surplus --plan` bullet in `on_start` (after the `*sync` line). Zero contact with any SAFETY zone.

---

## 2. Layer 1 (Static) AC Results

| AC# | Description | Method | Expected | Result | Verdict |
|-----|-------------|--------|----------|--------|---------|
| AC1 | Scan workflow valid JS | `node --check` | exit 0 | bare check exits 1 (top-level `return`) — **same as loop-discover & epic-audit exemplars**; body VALID when wrapped as runtime async fn (exit 0) | PASS* (see Note A) |
| AC2 | Registered as 'surplus-scan' | `grep -c "name: 'surplus-scan'"` | ≥1 | 1 | PASS |
| AC3 | No forbidden time/random APIs | `grep -cE "Date\.now\(\)\|Math\.random\(\)\|new Date\(\)"` | 0 | 0 | PASS |
| AC4 | 6 distinct schema fields | `grep -oE ... \| sort -u \| wc -l` | 6 | 6 | PASS |
| AC7 | Generated never auto-eligible | grep auto_eligible logic | ≥1 | `r.source !== 'generated'` at L292 (single-quote JS equiv of spec double-quote) | PASS |
| AC8 | Template required columns | grep ExpVal/Density/Risk/Auto | each ≥1 | ExpVal=1 Density=1 Risk=2 Auto=1 | PASS |
| AC10 | Mechanical SAFETY check present | `grep -ciE "safety\|principles"` | ≥1 | 24 (+ `safety_flag = agentFlag OR mech` confirmed in source) | PASS |
| AC11 | surplus SKILL frontmatter | `head -5 \| grep -c "^name: surplus"` | 1 | 1 | PASS |
| AC12 | SKILL scan-only / Phase-2 notice | `grep -c "Phase 2"` | ≥1 | 6 | PASS |
| AC13 | `*surplus` registered in alex | `grep -c "surplus:"` | ≥1 | 1 | PASS |
| AC14 | alex SAFETY anchors invariant | grep NOT_via_alex_auto + anti_rat BEGIN | 2 AND 2 | 2 AND 2 | PASS |
| AC15 | Existing workflows untouched | `git diff --name-only ... \| grep -v surplus-scan \| wc -l` + present | 0 + present | 0 other touched; surplus-scan present (untracked `??`) | PASS |

\* **Note A (AC1):** The literal AC1 method `node --check ... must exit 0` is **impossible for any workflow file in this repo** — `node --check` rejects the top-level `return` statement that the workflow runtime convention requires (the runtime wraps the body in a function before exec). Verified empirically: `loop-discover`, `epic-audit`, `tournament-design`, and `surplus-scan` ALL exit 1 under bare `node --check`. The handoff explicitly mandates following the loop-discover/epic-audit convention, so this file is correct by-convention. Validity confirmed via the runtime-faithful check: wrapping the body (sans the `export const meta` ESM line) in `async function __wf(){ ... }` with injected globals → `node --check` exit 0. Recommend Conductor amend AC1's verification method to the wrapped check (the bare check is a known false-FAIL for the workflow convention).

### Deferred ACs (require live Workflow runtime — Conductor Gate 3)

| AC# | Why deferred |
|-----|--------------|
| AC5 | Anti-theater behavioral fixture (vacuous DROPPED) — needs live Rank execution |
| AC6 | Value-first behavioral fixture (v5/L above v2/S) — needs live Rank execution |
| AC9 | JSON sidecar emitted + `jq .` valid — needs live `--plan` run |
| AC16 | Read-only git-status before/after — needs live `--plan` run |
| AC17 | Live scan produces ranked plan — needs live `--plan` run |

The Rank logic is written for readability so a reviewer can confirm by reading: value-first sort (`ranked.sort` — expected_value DESC, density DESC tiebreaker), anti-theater (`isVacuous` drop loop), and the `value >= 3` auto-floor (`auto_eligible` line).

---

## 3. Deviations / Surprises vs Spec

1. **`writeFile` is NOT a runtime primitive (sandbox).** §3.1 Rank.9 says the workflow "writes" the .md + .json. But the CRITICAL CONSTRAINT (and the loop-discover/epic-audit exemplars) forbid filesystem/Node APIs — no existing workflow writes files; they return data and the caller persists it. Reconciliation: the workflow now **returns** `plan_markdown` + `sidecar_json` (plus `plan_path`/`json_path` targets), and the `surplus` SKILL writes the two files via the Write tool (documented in SKILL step 3). The Phase-2 contract (`json_path` content) is unchanged. This is the only design adaptation; it strengthens sandbox compliance without changing the artifacts produced.

2. **AC1 false-FAIL under bare `node --check`** — see Note A above. Not a defect in this file; a verification-method mismatch shared by every workflow in the repo.

3. **AC7 quote style** — spec greps for `source !== "generated"` (double quotes); JS source uses single quotes `'generated'`. Semantically identical; the constraint (generated never auto-eligible) holds.

---

## 4. Knowledge Assessment

- **Reusable discovery (candidate for project-knowledge / patterns):** *A `node --check` AC on a workflow file is a structural false-FAIL.* TAD workflow files use top-level `return` (runtime wraps the body), which `node --check` always rejects. Any future workflow AC must verify syntax via the **wrapped** form (`async function __wf(){ <body sans export-meta line> }`), not bare `node --check`. This generalizes the existing `ac-verification.md` "dry-run discipline" pattern to the workflow file class. Suggest adding one line to `.tad/project-knowledge/patterns/ac-verification.md` if Gate 3 agrees.
- **Sandbox seam reaffirmed:** workflows must remain pure compute (no FS/Node API). The "render content in workflow, persist in SKILL" split is the correct seam and matches loop-discover's return-data convention — worth noting in `hook-contracts.md` / workflow conventions if not already captured.
- **No new SAFETY-zone logic introduced.** alex/SKILL.md edits are 2 one-line additions in non-SAFETY zones; anchors invariant (AC14 2/2).

---

## 5. Files Changed

- CREATE `.claude/workflows/surplus-scan.workflow.js`
- CREATE `.tad/templates/surplus-plan-template.md`
- CREATE `.claude/skills/surplus/SKILL.md`
- MODIFY `.claude/skills/alex/SKILL.md` (commands table + on_start, 2 one-line adds)
- CREATE `.tad/active/handoffs/COMPLETION-20260607-surplus-scan-phase1.md` (this report)

---


# TRACE EVENTS (slug=surplus-scan-phase1, sorted by ts)

/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-07.jsonl:{"ts":"2026-06-08T03:54:53Z","type":"decision_point","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"{\"decision\":\"Budget\",\"chosen\":\"invocation-time param, not built-in\",\"rationale\":\"matches \\\"跑到预算上限停\\\"; building the mode needs no budget number\"}","outcome":"invocation-time param, not built-in","slug":"surplus-scan-phase1"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-07.jsonl:{"ts":"2026-06-08T03:54:53Z","type":"decision_point","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"{\"decision\":\"Mode name\",\"chosen\":\"`*surplus`\",\"rationale\":\"clear (\\\"surplus usage\\\"); rename trivial if user prefers\"}","outcome":"`*surplus`","slug":"surplus-scan-phase1"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-07.jsonl:{"ts":"2026-06-08T03:54:53Z","type":"decision_point","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"{\"decision\":\"Phase split\",\"chosen\":\"scan(P1) / execute(P2)\",\"rationale\":\"P1 read-only + standalone-useful + low-risk → ship first\"}","outcome":"scan(P1) / execute(P2)","slug":"surplus-scan-phase1"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-07.jsonl:{"ts":"2026-06-08T03:54:53Z","type":"decision_point","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"full","context":"{\"decision\":\"Ranking metric\",\"chosen\":\"value-density = (value×conf)/cost\",\"rationale\":\"value-first per Socratic; consumption is the result not the goal\"}","outcome":"value-density = (value×conf)/cost","slug":"surplus-scan-phase1"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-07.jsonl:{"ts":"2026-06-08T03:54:53Z","type":"handoff_created","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260607-surplus-scan-phase1.md","size_bytes":9554,"slug":"surplus-scan-phase1"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-08.jsonl:{"ts":"2026-06-08T04:24:38Z","type":"task_completed","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/COMPLETION-20260607-surplus-scan-phase1.md","size_bytes":8937,"slug":"surplus-scan-phase1"}

---

