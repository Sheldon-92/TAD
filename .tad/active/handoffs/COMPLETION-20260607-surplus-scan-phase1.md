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
