---
task_type: code
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .tad/hooks
---

# HANDOFF: Hook Code Hardening (Debt Bundle 2/2)

**From:** Alex | **To:** Blake | **Date:** 2026-05-31
**Priority:** P2 (telemetry/dream quality — no in-flight feature blocked)
**Type:** Standard TAD (code: shell + jq)

## 1. Executive Summary

Three hook-code defects in the self-evolution data layer, in 2 shell files. (A 4th item — Pass C dedup vs project-knowledge — was REMOVED post-review: backend-architect proved a grep probe is inert on all 31 real `.decision`/7 real `.chosen` values; semantic dedup needs a proper design, deferred to NEXT.md.)

**dream-scanner.sh Pass C/D (`.tad/hooks/lib/dream-scanner.sh`):**
- **(a) fromjson error leaks junk** (line ~183): `decision=$(... | jq -r '(.context | fromjson | .decision) // "unknown"')`. On MALFORMED `.context`, `fromjson` ERRORS → jq outputs nothing → `decision=""` (NOT `"unknown"`). Guard `[ "$decision" = "unknown" ] && continue` then does NOT fire → junk empty-decision candidate emitted. `// "unknown"` handles a missing key in VALID JSON, not a parse error.
- **(b) classify_scope mis-tags framework as project** (line ~109-122): when a `decision_point` event has `file=""` (common), classify_scope falls to the slug check; a framework override whose slug lacks `*capability-pack*|*skill*` defaults to `"project"`. Best-effort heuristic fix only (emission is out of scope; some cases unrecoverable — see §10).

**post-write-sync.sh expert_finding parser (`.tad/hooks/post-write-sync.sh` ~line 162):**
- **(d) parser self-trigger**: `emit_expert_findings` counts BOTH heading-form AND table-cell `| P<n> |`. Per "Parser Self-Trigger" (architecture.md 2026-05-30), prose/verdict-cells mentioning `P0` inflate counts → false priority class misleads `*evolve`. Tighten to heading-form-only requiring finding-id suffix.

## 3. Requirements
- R1: Malformed `.context` JSON in a `decision_point` OR `reflexion_diagnosis` event → candidate SKIPPED, no junk emit, hook stays exit-0.
- R2: Framework-scoped overrides classified `framework` when slug/decision-text carries a TAD-specific framework signal (best-effort; documented unrecoverable class remains).
- R3: `expert_review_finding` counts only heading-form numbered findings (`### P0-1`), excluding prose/verdict-cell mentions.
- R4: All changes preserve the hook contract: exit 0 always, parse paths `|| true`/`2>/dev/null`, BSD-safe regex (architecture.md 2026-04-03 + 2026-05-30).

## 4. Technical Design

### 4.1 bug(a) — fromjson error guard (Pass C AND Pass D)
Replace fragile `fromjson | .decision // "unknown"` with a `try`-guarded parse:
```sh
decision=$(echo "$event_json" | jq -r '(.context | (try fromjson catch null) | .decision?) // "unknown"' 2>/dev/null)
[ "$decision" = "unknown" ] || [ -z "$decision" ] && continue
```
(Reviewer-confirmed: `||`/`&&` are equal-precedence left-assoc → `continue` fires in BOTH unknown and empty cases. Verified on jq 1.7.1: malformed/missing-key/null/empty all yield `unknown` at exit 0.)
Apply the SAME `try fromjson catch null` to `chosen`/`rationale` (lines ~185-186) AND to Pass D's `confidence`/`revised_approach` fromjson (lines ~218/225) — same latent leak, same file, in scope.

### 4.2 bug(b) — classify_scope robustness (TAD-specific keywords only)
Extend `classify_scope` with an optional 3rd arg `decision_text`. ⚠️ **Reviewer P1-2: do NOT add generic words** (`*sync*` matches data-sync; `*schema*` matches any DB/API project) — over-classifying to `framework` is WORSE than under-classifying, because framework candidates fan out cross-project in `*evolve`. Use only TAD-specific tokens:
```sh
classify_scope() {
  local file_field="$1" slug_field="$2" decision_text="${3:-}"
  case "$file_field" in *.claude/skills/*|*.tad/hooks/*) echo framework; return ;; esac
  case "$slug_field" in *capability-pack*|*skill*|*hook*|*trace*|*evolve*|*dream*|*registry*) echo framework; return ;; esac
  case "$decision_text" in *"trace schema"*|*emission*|*观测式*|*发射机制*) echo framework; return ;; esac
  echo project
}
```
Pass C call site (line ~187): `scope=$(classify_scope "$file" "$slug" "$decision")`. When still ambiguous → `project`.

### 4.3 bug(d) — expert_finding heading-only (REPLACE, not augment)
Current code (post-write-sync.sh **line 162**) uses heading-OR-cell alternation. **REPLACE the whole regex** with heading-only + finding-id suffix:
```sh
re="^#+[[:space:]]*P${n}-[0-9]"
```
AND **rewrite the stale comment on lines ~160-161** (it describes the old `| P0 |` cell behavior — paraphrase the label tokens per self-trigger discipline, e.g. "counts numbered heading findings like P-zero-dash-one, not cells/prose").
- Counts `### P0-1`, `#### P1-2`; excludes `| P0 |` cells, bare `### P0`/`### P0:` section headers, prose.
- ⚠️ **Known recall gap (accepted, human 2026-05-31)**: a finding written as `### P0:` (colon, no number) or `### P0 ` will NOT count. Blake review files MUST use the `Pn-m` finding-id form. Noted in §10.

## 6. Files to Modify
1. `.tad/hooks/lib/dream-scanner.sh` — (a) try-guard fromjson at lines ~183, 185-186 (Pass C) + ~218, 225 (Pass D); (b) classify_scope 3rd arg + TAD-specific keywords (lines ~109-122) + Pass C call site ~187. **No generate_candidate change** (dedup removed).
2. `.tad/hooks/post-write-sync.sh` — (d) REPLACE line 162 regex → `^#+[[:space:]]*P${n}-[0-9]` AND rewrite lines ~160-161 comment.

**Grounded Against** (Alex step1c actual reads, 2026-05-31):
- `.tad/hooks/lib/dream-scanner.sh` (lines 7 `set -uo pipefail` — no `set -e`; 80-107 generate_candidate; 109-122 classify_scope; 175-230 Pass C/D — all read)
- `.tad/hooks/post-write-sync.sh` (line 8 "No set -e"; lines 139-210 emit_expert_findings + emit_decision_points — read)

## 9. Acceptance Criteria
- [ ] AC1: Malformed-context fixture for BOTH a `decision_point` AND a `reflexion_diagnosis` (`context:"not-json"`) → dream-scanner emits 0 candidates from them (no junk); exit 0.
- [ ] AC2: A `decision_point` override with `file=""` + slug `trace-instrumentation-fix` + decision text containing `发射机制` → candidate `scope_tag: framework`.
- [ ] AC2b: A project-scoped override whose decision text contains the bare word `sync` (data-sync, not TAD) → candidate `scope_tag: project` (NOT framework — confirms generic-word pruning).
- [ ] AC3: expert_finding on a review fixture with `### P0-1` heading AND a `| P0 |` cell AND prose "no P0 issues" → counts 1 (heading only).
- [ ] AC4: `bash -n` passes on both files; dream-scanner exit code 0 on all fixtures (advisory contract).

### 9.1 Spec Compliance Checklist (Verification)
| AC | Verification Method | Expected | Verified Output (Alex step1d) |
|----|--------------------|----------|-------------------------------|
| AC1 | run scanner on malformed-context fixtures (both event types) in a THROWAWAY trace dir; count new candidates from them | `0` new, exit `0` | post-impl |
| AC2 | fixture as AC2; `grep '^scope_tag:' <new CAND>` | `framework` | post-impl |
| AC2b | fixture decision text = `data sync between services`; `grep '^scope_tag:' <CAND>` | `project` | post-impl |
| AC3 | craft review fixture w/ all 3 forms; emitted `expert_review_finding` P0 count | `1` | post-impl |
| AC4 | `bash -n .tad/hooks/lib/dream-scanner.sh; bash -n .tad/hooks/post-write-sync.sh; echo $?` | `0` | pre-impl baseline: both `0` |

### AC Dry-Run Log (Alex step1d, 2026-05-31)
- AC4: ✅ pre-impl — `bash -n` on both current files exits 0 (baseline). Re-verify post-edit.
- AC1-AC3: post-impl (need Blake edits + crafted fixtures). jq `try fromjson catch null`, bash `||...&& continue` precedence, and BSD `^#+[[:space:]]*P${n}-[0-9]` ERE all reviewer-verified empirically. Fixtures → THROWAWAY path only.

## 10. Important Notes
- ⚠️ **Hook NEVER fail-closed** (architecture.md 2026-04-15 SAFETY): `.tad/hooks/lib/dream-scanner.sh` uses `set -uo pipefail` (NOT `set -e`, reviewer-confirmed) — the no-`set -e` is load-bearing; do NOT add `set -e`. Every new parse path keeps `|| true`/`2>/dev/null`; exit MUST stay 0. AC4 enforces.
- ⚠️ **BSD-safe regex**: `^#+[[:space:]]*P${n}-[0-9]` is POSIX-ERE (reviewer-verified identical on `/usr/bin/grep` BSD + GNU). No `grep -P`.
- ⚠️ **Emission OUT OF SCOPE** (architecture.md 2026-05-31): fix the SCANNER/CONSUMER only. Do NOT touch `trace-writer.sh`/`record_trace`/decision_point emission. bug(b) is a scanner-side heuristic.
- ⚠️ **bug(b) is a PARTIAL heuristic** (backend-architect P1-3): a framework override whose slug has no keyword AND whose decision text is generic (e.g. decision "Persona count") is UNRECOVERABLE without the file path emission omits. COMPLETION must state this, not claim "framework scope fully fixed."
- ⚠️ **bug(d) recall gap accepted**: `### P0:`/`### P0 ` (no `-digit`) won't count. Reviewers MUST use `Pn-m` finding-id headings.
- ⚠️ **Self-trigger discipline** (architecture.md 2026-05-30): this handoff + Blake's review/COMPLETION files quote `### P0-1`/`| P0 |` — PARAPHRASE in evidence files (e.g. "pipe-P-zero cell") so the tightened parser doesn't self-count. AC3 fixture + `fixture-results.md` live where the parser does NOT scan (`acceptance-tests/`, not `reviews/blake/<slug>/`).
- ⚠️ **Fixtures → `/tmp` or throwaway dir, NEVER `.tad/evidence/traces/`** (would pollute telemetry).

## 11. Decision Summary
| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | bug(c) dedup | (a) drop, defer (b) re-point title/discovery (c) keep | **(a) DROPPED from H2** | Human chose; backend-architect proved grep probe inert on all 31/7 real values — would be validation theater. Semantic dedup needs proper design → NEXT.md |
| 2 | expert_finding scope | heading-only vs heading+table | **heading-only `P<n>-[0-9]`** | Human chose; canonical fix (architecture.md 2026-05-30); recall gap accepted |
| 3 | bug(a) fromjson | try/catch vs empty-check | **try fromjson catch null + empty guard** | Robust against parse errors AND missing keys; reviewer-verified |
| 4 | bug(b) scope keywords | broad vs TAD-specific | **TAD-specific only (no `sync`/`schema`)** | backend-architect P1-2: over-classifying framework fans out cross-project, worse than under-classify |
| 5 | bug(b) approach | scanner-side heuristic vs emission file field | **scanner-side (partial)** | Emission out of scope; unrecoverable class documented |

## Audit Trail (Expert Review — code-reviewer + backend-architect)
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| backend-architect | P1-1: dedup probe inert on real data (validation theater) | bug(c) DROPPED from H2 (§1, §11 #1); deferred to NEXT.md | Resolved (removed) |
| code-reviewer | P0-1: duplicate `status:` YAML key from dedup change | Obviated — dedup/status_override removed entirely | Resolved (obviated) |
| backend-architect | P1-2: `*sync*`/`*schema*` over-classify framework (cross-project fan-out) | §4.2 — keywords pruned to TAD-specific; AC2b guards | Resolved |
| code-reviewer | P1-2: §4.4 must REPLACE regex + update stale comment | §4.3 explicit replace + comment rewrite | Resolved |
| backend-architect | P1-3: bug(b) partial heuristic, unrecoverable class | §10 + Blake instr (COMPLETION must state) | Resolved |
| backend-architect | P2-4: AC must exercise Pass D malformed reflexion too | §9 AC1 covers both event types | Resolved |
| code-reviewer/backend-architect | P2: bug(d) recall on `### P0:` | §10 documented; reviewers use `Pn-m` | Resolved (accepted) |
| both | P0: fail-closed under set -e | Refuted — `set -uo pipefail`, no `set -e` (§10 load-bearing note) | Resolved (refuted) |

## 12. Project Knowledge (Blake 必读历史教训)
- **A Parser Feeding a Review Queue Must Propagate VALUE** (architecture.md 2026-05-31): the parent incident; bug(c) dedup was the attempted cure but grep can't do semantic match — deferred.
- **Ad-hoc "Dead Code"/audit tools are themselves validation theater** (architecture.md 2026-05-30): the dedup probe nearly recapitulated this — review caught it. Don't ship a probe that passes a synthetic AC but never fires on real data.
- **Parser Self-Trigger** (architecture.md 2026-05-30): bug(d) IS this lesson; §10 self-trigger discipline applies to Blake's evidence files.
- **Double-Parse Pattern for String-Encoded JSON** (architecture.md 2026-05-20): single-pass jq with `try fromjson` is mandatory.
- **Hook Shell Portability** (architecture.md 2026-04-03): BSD-safe regex; exit 0 always; no `set -e`.

## Required Evidence Manifest
```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/hook-hardening/code-reviewer.md
  - .tad/evidence/reviews/blake/hook-hardening/<second-reviewer>.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict (pass|fail|partial)
completion: .tad/active/handoffs/COMPLETION-20260531-hook-hardening.md
fixture_results: .tad/evidence/acceptance-tests/hook-hardening/fixture-results.md
knowledge_updates: project-knowledge entry if any parser-hardening lesson surfaces
```

## Blake Instructions
- Standard TAD. Socratic done (Alex). Run Layer 1 (`bash -n` both files; run crafted fixtures) + Layer 2 (≥2 experts: code-reviewer REQUIRED + 1 shell/jq-savvy — backend-architect fits exit-0 contract + classify_scope false-classification risk).
- Implement → Gate 3 → write COMPLETION + gate3_verdict marker.
- **COMPLETION MUST state bug(b) is a partial heuristic** with a known unrecoverable class (slug+text both generic, file empty) — do NOT claim "framework scope fully fixed."
- **Fixtures → /tmp or throwaway dir, NEVER `.tad/evidence/traces/`**. AC1 must feed BOTH a malformed `decision_point` AND a malformed `reflexion_diagnosis`.
- **Paraphrase `P0`/`### P0-1`/`| P0 |` in review + COMPLETION files** (§10) — the tightened parser scans `reviews/blake/<slug>/`.
- If any fix requires touching emission (`trace-writer.sh`/`record_trace`) → STOP, escalate to Alex.
