---
handoff: HANDOFF-20260531-research-engine-wire-phase4
agent: blake
date: 2026-05-31
gate3_verdict: partial
gate3_partial_reason: "AC4.4 is PARTIAL-by-construction — the live *research-plan dogfood (seed_origin>=1 fire criterion) is an Alex command, Gate-4-deferred. All other ACs (4.1/4.1b/4.2/4.3/4.5/4.6) PASS."
---

# COMPLETION: Research Engine — Wire Triggering + Lifecycle + Dogfood (Phase 4)

## Summary
Wired the deep-research engine's effort-scaling ladder, added a non-blocking SessionStart
dormant-recompute hook, archived the empty-shell notebook, and applied the human-authorized
DR-20260531 AR-001 carve-out. No STOP/escalation: all wiring stayed within the 3 sanctioned
SAFETY lines (L487, L488, L6185 prose); no other forbidden line touched.

## Files Changed
| File | Change |
|------|--------|
| `.claude/skills/alex/SKILL.md` | (a) NEW `a0_class` Phase 0class effort-scaling classification step (per-item, before Phase 0c) setting `run_dynamic_seeds`/`run_adversarial_challenge`, displayed+overridable; (b) persist `research_complexity` to findings frontmatter at Phase 4 Step 3; (c) rewired Phase 0c/4c/5b challenge gates to read `run_adversarial_challenge`; (d) gated Step 2.5 + per-seed dynamic deepening on `run_dynamic_seeds`; (e) preflight now runs always so 4c/5b cached vars survive `run_adversarial_challenge=off`; (f) SAFETY carve-out on forbidden L487/L488 + anti_rationalization must-scan prose (~L6185), each citing DR-20260531 |
| `.claude/skills/research-notebook/SKILL.md` | Documented passive SessionStart recompute (hook + lib) in `status_field_semantics` + `state_transitions` |
| `.tad/hooks/lib/notebook-lifecycle.sh` | NEW — `recompute_notebook_dormancy()`: yq-guarded, atomic temp+mv, per-entry, BSD-safe date, threshold from config, exit 0 always |
| `.tad/hooks/notebook-dormant-sync.sh` | NEW — SessionStart hook (stdin JSON, source-check, sources lib, non-blocking, emits `{}`, exit 0) |
| `.claude/settings.json` | Registered `notebook-dormant-sync.sh` as 2nd SessionStart hook |
| `.tad/research-notebooks/REGISTRY.yaml` | Archived `ai-agent-tutorials` (status→archived, body preserved); file yq-normalized once (idempotent thereafter) |
| `.tad/evidence/acceptance-tests/research-engine-wire-phase4/` | NEW — classification-smoke.md, dormant-recompute-smoke.md, dogfood-runbook.md, forbidden-baseline.txt |

## Layer 1 Results (each AC grep + result)
| AC | Check | Result |
|----|-------|--------|
| AC4.1 | `grep -c 'run_dynamic_seeds\|run_adversarial_challenge\|research_complexity'` >= 6 | **26** PASS |
| AC4.1b | Phase 0c reads run_adversarial_challenge | 3 PASS |
| AC4.1b | Phase 4c reads run_adversarial_challenge | 2 PASS |
| AC4.1b | Phase 5b reads run_adversarial_challenge | 2 PASS |
| AC4.1b | Step 2.5 reads run_dynamic_seeds | 2 PASS |
| AC4.1b | Phase 4 Step 1 baseline NOT gated (explicit "runs for ALL tiers" note) | 1 PASS |
| AC4.1b | preflight runs regardless of run_adversarial_challenge (cached-var survives off) | implemented (Phase 0c Step 2 "ALWAYS") PASS |
| AC4.2 | `bash -n notebook-dormant-sync.sh` | exit 0 PASS |
| AC4.2 | `bash -n notebook-lifecycle.sh` | exit 0 PASS |
| AC4.2 | `grep -cE '^[[:space:]]*exit 1'` hook | **0** PASS |
| AC4.2 | `grep -c '"deny"'` hook | **0** PASS |
| AC4.2 | hook last line `exit 0` | PASS |
| AC4.2 | no bare `exit 1`/`deny` even in comments (§10 paraphrase) | NONE PASS |
| AC4.3 | `awk '/id: "ai-agent-tutorials"/,/source_count/' \| grep -c 'status: archived'` = 1 | **1** PASS; body preserved |
| AC4.5 | count `NOT_via_alex_auto\|forbidden_implementations` = 17 (kept) | **17** PASS |
| AC4.5(a) | FORWARD line-set: baseline lines missing = only the 3 amended (L487/L488/L6185) + 3 rewired gate-step prose labels (mandated by §4.1, not forbidden_implementations entries) | PASS |
| AC4.5(b) | REVERSE line-set: post-impl new lines = exactly the 1:1 amended replacements | PASS |
| AC4.5(c) | 2 forbidden lines each `grep -F 'DR-20260531'` | **2** PASS |
| AC4.5(d) | `NOT_via_alex_auto: true` anchor byte-identical | INTACT PASS |
| AC4.5 | AR-001 `express=review-exempt` pattern untouched | untouched PASS |
| AC4.6 | temp-copy multi-entry test | PASS (below) |

## AC4.6 Test Output (temp copy of normalized live registry)
Setup: `web-ui-design-rebuild` last_queried -> 2026-02-15 (~104d > 30); 15 others recent; `ai-agent-tutorials` archived.
```
recompute exit=0
byte-diff (pre vs post):
120c120
<     status: active
---
>     status: dormant
YAML: VALID
ai-agent-tutorials: archived (skipped — not touched)
web-ui-design-rebuild: 2026-02-15  dormant (flipped)
```
EXACTLY one entry flipped, 16 others byte-identical, valid YAML, archived skipped.

Hook via real stdin: `echo '{"source":"startup"}' | bash notebook-dormant-sync.sh` -> `{}` exit 0;
`{"source":"resume"}` -> `{}` exit 0 (no-op). Live registry unmutated by today's run (all <30d).

## Design note (formatting)
mikefarah yq v4 strips blank lines + normalizes comment spacing on its FIRST touch of a file,
then is byte-stable (idempotent). The §4.3 archive edit (mandated via yq) performed that one-time
normalization on the live REGISTRY, so the hook's per-flip diffs are byte-surgical from here on.
This is why AC4.6 shows a single-line diff. Trade-off accepted per §4.2 (yq mandated, no sed fallback).

## STOP / Escalation
None. All wiring fit within the 3 sanctioned SAFETY lines. The 3 Phase 0c/4c/5b gate-step prose
labels were reworded (mandated by §4.1 "rewire gates"); these are protocol gate labels, NOT
`forbidden_implementations` entries, and each retains the `NOT_via_alex_auto constraint` citation
(now "satisfied via DR-20260531 carve-out"), so the AC4.5 line-set diff is clean.

## AC4.4 status
PARTIAL-by-construction. Blake delivered: (a) classification-smoke.md (3-tier manual trace), and
(b) dogfood-runbook.md with all preflight bash commands dry-run-verified (paths, notebook-id
37cfefa5-…, template, OBJECTIVES.md, codex+gemini both available, baseline seed_origin=0). The live
`*research-plan` run + seed_origin>=1 fire criterion is Gate-4-deferred to Alex (terminal isolation).
