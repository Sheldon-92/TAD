# Idea: Self-Evolution Pruning + Skillify Last-Mile Repair

**ID:** IDEA-20260610-self-evolution-pruning-skillify-last-mile
**Date:** 2026-06-10
**Status:** promoted
**Scope:** medium

---

## Summary & Problem

Measured yield of the automated self-evolution loops is near zero: *dream 10 candidates → 1 accepted (recent window 0/6); *optimize/*evolve 8 PROPOSALs → 0 accepted (6 deferred, 2 rejected); *skillify auto-detection → 0 candidates in TAD master. Meanwhile every effective TAD upgrade (deny-list sync, Friction Protocol, progressive disclosure fix, Feedback Collector, Upgrade Lifecycle) was human-pain-driven. Root cause: these loops automate the side of the division of labor TAD's own thesis assigns to humans — value discovery. Traces record mechanical events; the value signal (felt pain) only exists in human experience, so log-mining generates plausibility-optimized noise and taxes the human as a noise filter (Alex startup STEPs 3.55-3.57).

EXCEPTION — the KA-gate-attached capture (skillify/workflow via the triple-question KA) is the one mechanism that produced real value, because its trigger IS human-felt pain during real work. Colin声音项目 generated 3 high-quality candidates (colab-drive-deploy, eval-page-generator, smart-interval). But the chain breaks AFTER capture — all 3 are stuck: "accepted" in frontmatter yet no artifact exists anywhere.

## Proposed Direction

**Retire** (the noise generators):
- *evolve, *optimize commands + their proposal pipeline
- dream auto-scanner (dream-scanner.sh / dream-validator.sh; keep manual *dream consolidation? — open question)
- Alex startup STEPs 3.55/3.56/3.57 review taxes (whichever correspond to retired mechanisms)
- Trace mining layer (trace-digest); KEEP trace emission as cheap post-hoc forensics (676KB, used in YOLO audits)

**Keep** (the proven chain):
- Gate KA triple-question capture (Q1 knowledge / Q2 skill / Q3 workflow)
- incidents/patterns/principles chain, violations.log

**Repair skillify's four breakpoints** (evidence: Colin 3 SCANDs):
1. **Self-acceptance**: discoverer wrote `status: accepted` + `verified: true` at creation — violates triple_question_draft_rule. Fix: frontmatter lint in pre-gate hook — discoverer MUST NOT set accepted.
2. **No materialization executor**: "accepted" is a status edit, not an action. None of the 3 accepted candidates produced a skill file or pack augmentation (ml-training pack has NO drive-first pattern; eval-page-generator & smart-interval skills don't exist). Fix: acceptance = action with AC ("skill file exists at path" / "pack augmented, grep-verifiable"), verified by the existing gate machinery.
3. **No reflux channel**: downstream SCANDs structurally cannot reach TAD master (sync is one-way; skillify-candidates is zero-touch deny-listed — correctly). Fix: TAD-master-side `*harvest` command — read-only scan of registered projects' skillify-candidates, centralized human review in master Alex. Merges IDEA-20260407-cross-project-skill-harvest. NOTE: harvest destination is NOT "master pack" by default — see Destination Taxonomy below.
4. **Review point misplaced**: human confirmation is bound to Alex startup in EACH project, but downstream work is mostly Blake-only sessions — the review never fires (Colin candidates sat since 06-03 while work continued daily). Fix: same as 3 — converge review to the master repo where the human actually lives.

## Destination Taxonomy — three tiers (user refinement, 2026-06-10)

The missing piece is not just a reflux channel — it's a FORMALIZATION FLOW with three distinct destinations. Most candidates should NOT go to master at all:

| Tier | Destination | Bar | Distribution |
|------|-------------|-----|--------------|
| **T1 Local formalization (DEFAULT)** | The project's OWN `.claude/skills/{slug}/` or `.claude/workflows/` | Pattern is real and reusable WITHIN that project | Stays in the project; never synced anywhere |
| **T2 Reference shelf** | Master repo reference library (e.g. `.tad/skill-library/` — NOT in sync set, NOT installed with TAD) | Special/idiosyncratic but instructive — "我们的参考" for future design work | Read-only inspiration for the human + master Alex; explicitly NOT something installers receive |
| **T3 Promote to distributable** | Master capability pack / shipped skill | Same bar as the existing Domain Pack vs Project-Knowledge rule: **≥2 different projects show the pattern** | Ships with TAD installs/sync |

- Colin examples mapped: smart-interval → likely T1 (project skill) or T2 (reference); eval-page-generator → was effectively T3 (became Feedback Collector — but via human channel); colab-drive-deploy → T3 candidate (augment ml-training pack) IF a second project corroborates, else T2.
- T1 is the urgent missing flow: a project-local "candidate → formal skill/workflow" ceremony (accept action + artifact AC + registration so the project's own agents actually load it). Today even local formalization has no executor — that's breakpoint 2 scoped per-project.
- T2 requires a new master dir OUTSIDE the sync set (deny-listed like evidence/) so references never leak into installs.
- Sync-safety constraint for T1: when master syncs `.claude/skills` into a project, project-local skills (slugs not in master set) MUST survive — verify current sync strategy doesn't delete/flag unknown skill dirs; if it does set-equality checks, add a local-skills exclusion.

## Open Questions

- Manual *dream (human-invoked consolidation) — keep or retire with the scanner?
- Trace emission scope after mining layer removal — minimal schema or unchanged?
- *harvest cadence — Alex startup scan vs explicit command only?
- T1 local formalization: who runs the accept ceremony in a Blake-only project — allow Blake to materialize after human says yes in-session (draft-then-confirm satisfied), or require a project Alex session?
- T2 reference shelf location + naming (.tad/skill-library/? references/harvested/?) and its index format
- T1→T3 graduation tracking: how do we notice "a second project just hit the same pattern"? (cheap option: harvest scan reports slug collisions across projects)
- What happens to the 8 deferred/rejected PROPOSALs and 6 rejected CANDs — archive as evidence of the negative result?
- colab-drive-deploy's target pack (ml-training) lives in .tad/capability-packs/ with CAPABILITY.md (not .claude/skills) — materialization path must handle both pack formats.

## Notes

- Yield data measured 2026-06-10 (this session): dream-state.yaml total_accepted: 0 / total_rejected: 6; .tad/evidence/proposals/ 8 files all deferred/rejected; Colin .tad/active/skillify-candidates/ 3 SCANDs status:accepted with zero artifacts.
- Strongest supporting case: eval-page-generator's value DID materialize — but via the human channel (Colin prototypes → *discuss → Feedback Collector Epic), not the pipeline. The mechanisms should reduce friction on the human channel, not replace it.
- Related: principles.md "Mechanical Enforcement Rejected on Single-User CLI" (soft-reminder tradeoff), YOLO audit "validation theater" finding (status-edit acceptance is the same failure class).
- Origin: 2026-06-10 evaluation session — user's verdict "每次 TAD 真正有效的升级都是我推动的", confirmed by measurement.

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: EPIC-20260610-self-evolution-pruning.md (2026-06-10)
