# Phase 4 Impl Review — Architecture Lens

**Reviewer**: backend-architect (YOLO Phase 4 impl review)
**Date**: 2026-07-13
**Commit**: fcd6643 (worktree wf_0019f033-1ce-1)
**Handoff**: HANDOFF-20260713-native-capability-adoption-phase4.md
**Scope**: architecture quality, blast radius, implementation completeness

---

## Verdict

**PASS — 0 P0, 0 P1, 3 P2.** Every AC independently re-verified in the worktree.
The diff is additive-only, blast radius is minimal, and the two behavioral claims
that cannot fire in-session are honestly labeled `observe-on-next-use`. This is a
clean, low-risk delivery. The P2s are refinement observations, not blockers.

## Independent verification (not trusting the completion table)

| Check | Method | Result |
|-------|--------|--------|
| Mirror byte-identity | `diff -q .agents ... .claude ...` | IDENTICAL ✓ |
| Line-set FORWARD-missing empty | re-derived `LC_ALL=C comm -23` before/after | EMPTY ✓ (additions-only confirmed) |
| Thin-rule caps | `wc -l/-c` | 25 lines / 1370 B (≤60 / ≤4096) ✓ |
| Frontmatter parses + scope key | `yq` on frontmatter | `- ".tad/hooks/**"` PARSE-OK ✓ |
| Zero code touched | `git diff --name-only HEAD~1 \| grep -c '\.js$'` | 0 ✓ |
| Spike verdict well-formed | `grep -cE 'Verdict: (LOADED\|INERT)'` + URL + retrieval | 1 / 2 / 2 ✓ |
| AC1/AC3 tokens | use_when=1 never_when=1 multiSelect=2 preference=2 | all ≥ baseline ✓ |
| Content parity 5 constraints | cross-checked each vs source `patterns/shell-portability.md` | 5/5 traceable to real source entries (2026-04-03, 06-17, 05-31, 06-09, 04-24) ✓ |
| AC14 four sections | `grep -qiE '^#+ .*<token>'` | fire-test / no-fire / parity / context all present ✓ |

Blast radius: 3 source-of-record files (design-protocol ×2 mirror + rules pilot) +
4 evidence files. No workflow/hook/skill-body code touched. Insertion sits cleanly
between `step1_5c.skip_conditions` and `step2` — the `preview_usage_rule` block and
the step-4 wiring are non-adjacent and non-overlapping (arch P1-2 from handoff honored),
which is exactly why the line-set diff is explainable.

## Findings

### P2-1 — `.claude/rules` fires on READ, but the stated value is protecting hook EDITS (design gap, honestly flagged but under-mitigated)

The rule's whole purpose (handoff §1.2b) is to inject shell-portability constraints
when a non-TAD session **edits** `.tad/hooks/**`. But the verified harness semantics
(spike + docs) are that path-scoped rules load when a matching file is **READ**, not
on write/new-file creation. The two most dangerous cases are exactly the ones that
slip through:
- creating a **brand-new** hook file (no prior read → rule never loads)
- a blind `Edit`/`Write` to an existing hook without a preceding `Read`

Blake documented this limitation faithfully in three places (rule file footer, spike
§3, measurement "Known limitation") — that honesty is why this is P2 not P1. But the
mitigation ("read the target hook file before editing it") is a soft convention that
depends on the very non-TAD/"直接帮我" sessions this feature targets to remember an
instruction they never loaded. Net: the pilot delivers real value for the read-then-edit
path and is correctly measured, but the availability gap for new-file/blind-edit is
larger than "a footnote." Recommend the Epic-level distillation capture this as an
explicit *scope boundary* of the `.claude/rules` mechanism (not a TODO for this phase):
path-scoped rules are a read-triggered safety net, structurally incapable of covering
create-from-scratch — which is fine for a pilot, but must not be oversold when deciding
whether to expand to more rule files.

### P2-2 — Content parity is a point-in-time snapshot with no drift guard (sync-note is advisory only)

The rule file is a hand-maintained thin excerpt of 5 of the 15 entries in
`patterns/shell-portability.md`, tied to the source only by a prose "Sync note." This
is the correct call for a single-file pilot (per the anti-drift grounding), and each
constraint is currently traceable to a real source entry. But there is no mechanical
link: if a source entry's guidance changes (e.g., the 2026-06-17 `|| true` entry gets
amended), nothing flags the excerpt as stale. This is the same drift class the project's
own release-sync principles warn about (allow-list/snapshot goes stale silently). For a
1-file pilot this is acceptable and P2, but the *decision to expand* should be gated on
either (a) a `release-verify`-style check that each excerpted constraint's first line
still `grep`s in the source file, or (b) accepting the excerpt as a deliberately-frozen
"top-5 hazards" list decoupled from source edits. Flagging so the expansion decision is
made with eyes open, not as a defect in this phase.

### P2-3 — Committed trace-file noise left in the worktree working tree (housekeeping)

`git status --porcelain` in the worktree shows `?? .tad/evidence/traces/2026-07-13.jsonl`
still present (the headless-probe side-effect Blake correctly identified and chose not to
commit). The REGISTRY.yaml flip was properly reverted, and leaving an untracked trace file
uncommitted is the right call. This is pure housekeeping (P2): the stray file is harmless
and gitignore-adjacent, but a follow-up `rm` or confirming it's covered by `.gitignore`
would leave the worktree clean. No impact on the delivered artifacts.

## Architecture strengths (worth preserving in distillation)

1. **Spike-first discipline paid off twice** — not only confirmed LOADED on the exact
   2.1.172 that burned Phase 2, but adjudicated a *contradicting community report*
   (issue #17204) empirically rather than by doc-trust. The discriminative-token probe
   design (`THIN EXCERPT` present in exactly 1 file, symmetric fire=YES/no-fire=NO) is a
   genuinely reusable anti-Validation-Theater technique.
2. **Additions-only edit** keeps the line-set diff trivially explainable and the mirror
   sync a pure copy — zero risk of clobbering unrelated protocol prose.
3. **Behavioral Evidence Ledger** cleanly separates PROVEN-in-session (rule fires on read)
   from observe-on-next-use (Alex uses preview next *design), which is the honest
   partial the handoff mandated.

## Recommendation

Merge. The 3 P2s are refinement/scope-boundary notes for the Epic distillation and the
future "expand rules?" decision — none block Phase 4 acceptance.
