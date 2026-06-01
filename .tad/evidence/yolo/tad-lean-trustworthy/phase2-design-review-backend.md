# Phase 2 Design Review — backend-architect (YOLO Y4)

Verdict: **CONDITIONAL PASS**. 0 P0. Architecture sound + drift-check NOT validation theater (grounded in real
ai-voice drift, bidirectional ground-truth, advisory, AC2.3 injected-mismatch round-trip = calibration).

## P1
- **P1-2 (sharpest) ai-voice minimal CAPABILITY.md → downstream landmine.** References live only under
  `.claude/skills/ai-voice-production/references/`; a video-creation-mirrored body's bare `references/` pointers
  DANGLE on Tier-1 load (resolve to non-existent `.tad/capability-packs/ai-voice-production/references/`). AND no
  install.sh → `*sync` b2 never installs it downstream, yet synced registry advertises it → downstream Tier1 fail
  (source not synced) + Tier2 fail (never installed) + Tier3 `gh api .../ai-voice-production/install.sh` → 404.
  FIX (preferred): full source-dir-ification THIS phase — create CAPABILITY.md + install.sh (mirror video-creation)
  + copy references/ into the source dir. Closes dangling-ptr + downstream-404 at once (~10 min boilerplate).
- **P1-3 hardcoded 19-name allowlist rots** (every new framework skill = spurious (b)-flag → false exit 1; the
  "shared-files false-flag" trap, architecture.md 2026-04-24). Better discriminator already available: capability
  packs declare `type: reference-based|deep-skill|orchestration-router` in SKILL.md frontmatter; framework skills
  don't. FIX: Set B = `grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)' .claude/skills/*/SKILL.md`
  → NO allowlist, never rots.
- **P1-4 empty-glob/fresh-clone unspecified.** `.claude/skills/*/SKILL.md` literal-glob on no-match + set -e → crash
  or bogus name. FIX: nullglob / `2>/dev/null` + empty-set handling; fresh-clone (skills absent) → Set B empty →
  (b) empty → exit 0. Add §8.3 edge case. Use `LC_ALL=C sort` for comm input.

## P2
- P2-1 forbidden_implementations precedent (same as cr P1-1) — reword to post-write-sync.sh:6-11 style.
- P2-2 AC2.5 idempotency = two POST-16-state runs, not the 14→16 transition; make §6 Step2→AC2.5 ordering explicit.
- P2-3 registry is git-committed + synced (alex/SKILL.md:6000); nothing hand-edits it (sole writer = scan-packs) →
  no clobber risk, but new-entry correctness is load-bearing (propagates to 13+ projects). AC2.1 stays load-bearing.
- ml-training source-only is downstream-safe BECAUSE it has install.sh (distinct from ai-voice) — add 1 sentence to §10.2.

5-Q answers: (1) ml-training no breakage, self-heals via install.sh; (2) minimal unsound downstream → fix P1-2;
(3) drift-check robust except P1-3/P1-4; (4) no clobber; (5) NOT theater (calibrated by AC2.3).
