# Gate 2 Synthesis — HANDOFF-20260908-research-route-local-wiki

**Date:** 2026-09-08
**Owner:** Alex (Solution Lead, OpenCode harness — charter §3.7 compliant)
**Handoff:** `.tad/active/handoffs/HANDOFF-20260908-research-route-local-wiki.md` (v1.0)
**Task ID:** TASK-20260908-research-route-local-wiki
**Mode:** Gate 2 dual-review. No Blake. No implementation.

## Review panel (2 independent lens, both in-harness OpenCode subagents)

| Leg | Lens | Session | Carrier |
|---|---|---|---|
| Leg-1 | Spec-compliance / design completeness + AC verifiability | `ses_f7d967a75ffecEeXhvbiib85Ar` | `leg1-spec-compliance-review.md` |
| Leg-2 | Blast-radius / consumer completeness + safety (code-reviewer lens) | `ses_f7d967a57ffeC5lR9VX2CLYcWr` | `leg2-blast-radius-review.md` |

Charter §3 reviewer rule: Gate 2 needs ≥2 independent reviews with evidence on disk; Alex self-PASS does not count.
Charter §3.7: Gate 2 dual-review must execute inside OpenCode (not Cursor) — satisfied (both legs are OpenCode subagent sessions).
Payload note (charter §3, human D-06): handoff `task_type: mixed` but payload is doc/pointer routing (no buildable code touched). Panel covers both bars anyway: Leg-2 is the code-reviewer lens (consumer scan, parity, scope), Leg-1 is the spec-compliance lens. No deviation from the code-touching bar.

## Convergent verdict: CONDITIONAL (= Gate 2 NOT PASS)

Both legs independently returned **CONDITIONAL**. Convergent P0 set (found by BOTH legs independently):

- **P0-A (ROW-06 false-FAIL):** `git status --porcelain docs/pm/ docs/pm-charter.md` already returns `M docs/pm/intent.md` + `M docs/pm/now.md` pre-implementation, and `docs/pm-charter.md` does not exist in this repo (path silently ignored → vacuous clause). Blake cannot go green by correct behavior. Fix: re-baseline ROW-06 (record baseline + assert no NEW diffs) and drop-or-document the nonexistent charter path; update AC8 to match.
- **P0-B (§5 drops learn-path):** §5 "Cat 5" lists 5 protocols, omits `learn-path-protocol.md` (File 15 & 16, fully specified in §4), mislabeled "Cat 5" instead of "AC 5", with no §6 ROW covering it. Blake could skip it with all gates green (false-PASS). Fix: rename → AC5, append learn-path + criterion, add grep ROW on both mirrors.

Convergent P1 set (fix before Blake, either leg — deduplicated):

- **P1-1 (count):** headline "26 files" vs 28 numbered file-instances in §4 (29 if the missing research-github `.agents` mirror is added). Recount + correct §2/§5/§8.
- **P1-2 (mirror):** §4 File 27&28 omits existing `.agents/skills/research-github/SKILL.md`; undispositioned `.tad/capability-packs/academic-research/SKILL.md`; frontmatter staleness at research-github lines 3/11 unnamed. Add explicit old→new for both mirrors.
- **P1-3 (ROW-05 under-cover):** AC7 claims 12-pair parity, ROW-05 diffs 2 pairs. Extend ROW-05 to all mirror pairs or narrow AC7.
- **P1-4 (AC1 AGENTS.md):** "AGENTS.md 保持对齐" has no ROW and AGENTS.md contains no NotebookLM-default text. Delete clause or add mechanical ROW.
- **P1-5 (quick-ref line 169):** `.tad/guides/tool-quick-reference-alex.md:169` (`*research-github notebook` row) unnamed in File 21 spec. Add explicit bullet.
- **P1-6 (paraphrase inventory):** exact-string inventory complete (9/9 tracked hits covered; untracked scan clean — only the handoff itself), but paraphrase sites (`1_find_notebook`, `research_notebook_awareness`, REGISTRY.yaml consumers) exist outside §2/§4. Add explicit out-of-scope list with reachability reasons, minimum: adaptive-complexity-protocol.md, status-panoramic-protocol.md, research-github residual hits.
- **P1-7 (research/ write scope):** §1.3 says `research/` untouched but §4.2/§4.3 invoke writeful `ingest.sh`/`generate.py`. Add one scoping sentence (READ-ONLY except lint.sh/search.py dry verification) or list generatable paths as in-scope with revert protocol.
- **P1-8 (AC3/AC6 rows):** no §6 ROW for Step 3.8 scan or blake quick-ref section. Add grep rows (incl. positive-pattern rows for `primary: Local Wiki` / `check_wiki`).

P2 observations (Alex triage, Blake-tolerable): nondev-execution-track.md:290 triage note; research-github SHIM already half-migrated (extend-not-create); research/CLAUDE.md File 2 already compliant (verify-and-hold); ROW-05 `diff -u` brittleness is intended (parity rule) — procedural mitigation only.

## Positive confirmations (both legs / Alex pre-check)

- §3 tiers match `.tad/config-workflow.yaml:787-791` byte-for-byte (local_wiki / notebooklm_research / claude_websearch).
- Stale-pointer quotes verified present pre-impl: CLAUDE.md:44, alex SKILL L397/L475 ×2 mirrors, blake 1_5b_notebook_check L587/598 ×2 mirrors; `1_5b_research_check` 0 hits (correct create-gate baseline).
- Fallback assets exist: `.tad/cross-model/setup-notebooklm.sh` + `.tad/research-notebooks/REGISTRY.yaml`.
- `research/canon/lint.sh` + `research/scripts/generate.py` + `research/scripts/search.py` exist (Alex pre-check).
- Pre-change parity clean: alex/blake/research-plan/research-github mirror pairs all `diff -q` exit 0.
- Circular-trigger safety: Iron Rule + routing table stay in SKILL body (§4.2 + §📚 lines 104-105). No P0.
- Untracked exact-string collision scan: clean (only the handoff itself).

## Gate 2 checklist record

| Item | Status | Note |
|---|---|---|
| Expert review complete (min 2) | ✅ PASS | 2 independent in-harness legs, carriers on disk (this dir) |
| All P0 resolved | ❌ FAIL | P0-A (ROW-06), P0-B (learn-path) open |
| Architecture | ✅ Pass | §3 matches SSOT byte-for-byte |
| Components | ✅ Pass (sampled) | Exact-string inventory 9/9 covered; paraphrase exhaustion → P1-6 |
| Functions | ✅ Pass | lint/generate/search exist; 1_5b create-gate baseline correct |
| Data Flow | ✅ Pass | check→probe→fallback chain with commands |

## Decision

**Gate 2: FAIL (CONDITIONAL).** Design direction approved; Blake NOT released. Required: handoff rev2 fixing P0-A + P0-B (minimum), P1-1–P1-8 addressed in text, then delta re-review of the two P0s (re-run Leg E1–E7 commands) before Blake dispatch. No implementation performed. No Blake contact.

## Evidence paths

- `.tad/evidence/reviews/alex/research-route-local-wiki/leg1-spec-compliance-review.md`
- `.tad/evidence/reviews/alex/research-route-local-wiki/leg2-blast-radius-review.md`
- `.tad/evidence/reviews/alex/research-route-local-wiki/gate2-synthesis.md` (this file)
