# Phase 1 Impl Review — Architecture Lens

**Handoff:** `.tad/active/handoffs/HANDOFF-surplus-local-skill-capture.md` (v3.1.0)
**Completion:** `COMPLETION-surplus-local-skill-capture.md` (in worktree)
**Impl location:** `.claude/worktrees/wf_bf151fb8-ca1-4` (commit `3100cfb`, NOT merged to main)
**Reviewer:** Backend/Systems Architecture (distribution-pipeline & isolation focus)
**Date:** 2026-07-06
**Verdict:** PASS (with P1 process gap) — faithful impl, 14/14 ACs re-verified PASS, clean commit scope, isolation invariant correct, small blast radius. One P1: both design-review P1 sets left unaddressed; §9.1 (the "PRIMARY" Gate-3 verifier) is blind to the core flow steps — no live defect only because the shipped artifacts happen to contain the right content.

## Verified independently (worktree)
- All 14 §9.1 ACs re-run post-impl: 14/14 PASS (AC1=3, AC2=2, AC3=1, AC4=12/2, AC5=1, AC6=2/3, AC7=1file/143L, AC8=1, AC9=exit0, AC10=0, AC11=0, AC12=7, AC13=1/1, AC14=0).
- Commit scope = 3 tracked files: `A save-skill/SKILL.md`, `M .gitignore` (+3), `A COMPLETION`. `local/*` correctly UNTRACKED (`git ls-files .claude/skills/local` empty).
- Isolation invariant: `git check-ignore local/_example.md` exit 0 via `.gitignore:13`. Gitignored → absent from main.tar.gz → absent from $src → never copied. HOLDS.
- NFR3: zero changes to tad.sh/derive-sync-set.sh/release-verify.sh/publish/alex/blake/CLAUDE.md.
- Shipped content vs missing ACs: Step-1 "nothing capturable → STOP" (L31) present; Step-6 Report (L90) present; `_example.md` has 5/5 schema headers. Content correct despite AC blindness.

## Blast radius
Small and correct. Isolation cut at most-upstream point (git→tarball), making copy-granularity irrelevant. Zero distribution-code edits. No downstream-corruption path: tad.sh copy is additive per-source-dir `cp -r`, no mirror-delete (downstream's own `local/` survives reinstall); `.gitignore` not copied to targets.

## P0 — Blocking
None. Complete against handoff; ACs pass on independent re-run; isolation sound on both distribution paths.

## P1 — Should fix

### P1-1: Design-review P1s never folded in; PRIMARY Gate-3 verifier blind to the core flow
Both reviews were CONDITIONAL PASS contingent on P1s (arch: "Accept AFTER addressing P1-1/P1-2"; CR: "Close P1-1/P1-2 by adding two AC rows"). Neither the handoff nor §9.1 was amended; the COMPLETION report never mentions them. The sharp ones (CR): §9.1 is declared "PRIMARY VERIFICATION SOURCE — Gate 3 executes each row," yet NO AC verifies FR1 Step-1 (Scan / "nothing capturable → STOP") or Step-6 (Report), and AC13 does not check the fixture's 5 body sections (only `local: true` + `_example` in index). A SKILL.md missing the scan-stop guard or a fixture missing all body sections would pass all 14 ACs — the "coverage gate blind to must-cover content / validation theater" pattern from principles.md (2026-06-01, 2026-05-15).
Mitigating fact (P1 not P0): I confirmed the shipped artifacts DO contain the checked content (L31 scan-stop, L90 Step-6; 5/5 schema headers) — no live defect. But §2.1 designates this spec as the reused contract for sibling epic `*save-workflow`; shipping the verifier with this blind spot means the next reuse gets no protection.
Fix (no impl change; passes on today's artifacts): add §9.1 rows (a) `grep -c 'nothing capturable' SKILL.md` ≥1 + Step-6 anchor; (b) `grep -cE '^## (When to use|When NOT to use|Steps|Example|Gotchas)$' local/_example.md` == 5.

## P2 — Nice to fix

### P2-1: AC11 + COMPLETION §3 measure string-absence, not the invariant (validation theater)
AC11 greps literal `skills/local` in tad.sh → 0, and the report enshrines "zero sync special-casing." But tad.sh HAS three `-not -path '*/local/*'` exclusions (L390/L607/L670) in `copy_pack_skill_smart` for NESTED pack-skill local dirs. The top-level sibling `local/` this design uses is covered only by the gitignore cut, so the invariant is sound — AC11 just proves the wrong thing. `git ls-files .claude/skills/local | wc -l == 0` (already AC10) IS the load-bearing isolation assertion — relabel it as such and re-aim AC11's prose.

### P2-2: `_example.md` fixture is discoverable as a real skill via `_index.md`
"Using local skills" load path does not skip `_`-prefixed entries, so where `local/` exists the fixture surfaces as a real skill. Gitignored → never distributed → low impact; load-path prose should note `_`-prefixed entries are samples. (Unaddressed design-review-arch P2-2.)

### P2-3: "3 isolation surfaces" overstates defense depth
Exactly ONE active defense (gitignore→tarball); Surface 2 (derive-sync-set, .tad/-only) is a non-threat, Surface 3 (release-verify FR7) only tolerates. Acceptable for single-user CLI, but state it plainly so the sibling epic doesn't assume redundant protection. Shipped SKILL.md L142 "never touches local/ on install/update" is accurate-in-practice, so framing nit not correctness bug.

## Design-review P2s that WERE addressed (credit)
- arch P2-3 idempotent index-recovery rule now in shipped SKILL.md L87-88.
- Fixture ran the skill's own Step 4-5 mechanics (on-demand mkdir, overwrite-guard, index append), not hand-fabricated.

## Summary for Conductor
Accept the implementation — faithful, scope-clean, isolation verified sound, small blast radius, 14/14 ACs pass on independent re-run. Before merge, close P1-1 by adding the two missing §9.1 rows (flow-step + fixture-schema anchors) so the verifier that becomes the `*save-workflow` contract actually covers FR1; the rows pass on today's artifacts, so this is a coverage fix, not rework. P2s are polish.
