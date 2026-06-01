# DR-20260601: Codex-Edition Parity Architecture — Automated Regeneration (B)

**Status**: Accepted (human-authorized 2026-06-01)
**Touches**: `.tad/codex/` (Codex-edition SKILLs), `.tad/portable-rules.md`, release process (`release-runbook` SKILL + `*publish`)
**Epic**: EPIC-20260601-codex-edition-parity.md (architecture decision for all 3 phases)
**Decided by**: Human (explicit), via Alex `*analyze` Socratic (2 rounds / 7 questions) + architecture research

## Context
The Codex CLI edition of TAD (`.tad/codex/codex-alex-skill.md`, `codex-blake-skill.md`) lets
Codex-CLI users run the full Alex+Blake TAD methodology. It was built early and has since
**drifted**: probe (2026-06-01) shows the entire `deliverable` non-dev execution track
(17 mentions in Claude Alex) and `research_complexity` (research-engine wiring, 5 mentions)
are **completely absent** from the Codex edition. The release process only bumps the
`TAD vX.Y.Z` version string (release-runbook items 15-18) + runs a presence/dry-run smoke
test — it never re-ports protocol content. Result: Codex users run an early-TAD snapshot.

User requirement (Socratic): **full feature parity** + **≤5 min near-zero per-release human
cost** + **semantic-coverage parity criterion** + **hard-block release on drift** + must
defend against {constraint-rule loss, gate-bypass, maintenance-tax collapse, UX degradation}.

Key enabling finding: `.tad/portable-rules.md` already **codifies the strip into deterministic
rules** — a Strip→Replace transform table + a Preserve-NEVER-Delete inventory + size targets
(Alex ≤100KB, Blake ≤40KB). So the "judgment" that made stripping manual is largely already
documented → automated regeneration is feasible and defensible.

## Options Considered

| | A — Manual strip + drift gate | **B — Automated regen + hard gate (CHOSEN)** | C — Re-architect: Codex reads full SKILL |
|---|---|---|---|
| Per-release human | ❌ High (hand re-port) | ✅ Near-zero (regen by rules) | ✅✅ Zero (no copy) |
| vs ≤5min constraint | ❌ Violates | ✅ Meets | ✅ Meets |
| Full parity | ⚠️ Relies on diligence | ✅ Regen-from-source each release → structurally cannot drift | ✅ Same file |
| Constraint-loss risk | Medium | Low (preserve-list checklist + grep guards + semantic gate) | Low (nothing deleted) |
| UX-degradation risk | Low | Low (transform table pre-bakes replacements) | ⚠️ High (82 AskUserQuestion mentions need runtime override) |
| Size reality | 35KB ✅ | 35KB ✅ | ❌ **319KB** (4× the proven-feasible 76KB stdin ceiling) |
| Fatal flaw | Violates zero-human req | Must build reliable regen + semantic gate (real work) | 319KB direct-read infeasible + 82 runtime substitutions unproven |

**Measured facts (2026-06-01):** full Alex SKILL = **319KB / 82 AskUserQuestion mentions**;
full Blake = 102KB / 3; current Codex editions 35KB / 25KB; known-feasible stdin injection
= 76KB @ gpt-5.5.

## Decision: B — Automated Regeneration + Hard-Block Drift Gate
- **A rejected**: violates the ≤5min / near-zero-human hard requirement.
- **C rejected**: full Alex SKILL is **319KB**, 4× the proven-feasible 76KB injection ceiling,
  and would require Codex to reliably override **82** AskUserQuestion call-sites at runtime —
  token-expensive every session + reliability unproven. (May be revisited only if a future
  spike proves both size handling and runtime-substitution fidelity.)
- **B chosen**: regenerate the Codex editions from the current Claude source each release by
  applying `portable-rules.md`'s transform table + preserve list, guarded by grep checks and a
  semantic-coverage gate. Regen-from-source means drift is structurally impossible; output stays
  ~35KB within targets and within the proven injection ceiling. The codified rules + preserve
  list directly defend the constraint-loss risk; the pre-baked replacements defend UX
  degradation; an automated regen defends the maintenance-tax risk.

## Rationale for spike-first execution
B retains two mechanism unknowns: (1) can an LLM-driven regen reliably pass all guards +
semantic coverage at near-zero human cost? (2) what exactly is the mechanizable
"semantic-coverage" parity criterion the release gate enforces? Per project pattern
(architecture.md "Epic Architecture: Spike-Driven Pivots"), these are resolved in a Phase-1
Light-TAD spike with an explicit pivot threshold before P2/P3 commit.

## Critical constraint (single-user-CLI lesson)
The "hard-block on drift" is a **release-time** check inside `*publish` / release-runbook —
NOT a `settings.json` PreToolUse/SessionStart auto-hook. Per architecture.md
"Mechanical Enforcement Rejected on Single-User CLI" (2026-04-15), a fail-closed daily-work
hook is forbidden. The block fires only when shipping a release (minor+ = hard block,
patch = advisory), matching the existing "Codex Adapter Smoke Test" convention.

## Consequences
- New per-release step: regenerate (or verify) Codex editions; gate blocks minor+ release on drift.
- `portable-rules.md` transform table becomes load-bearing (the regen contract) — changes to it
  are semver-relevant to the Codex edition.
- Codex editions become **derived artifacts** (regenerated), not hand-maintained sources.

## Phase 1 Spike Finalized (2026-06-01)

**Verdict:** B viable — proceed to P2. Regen passes all 3 parity layers (22 covered, 9 expected-absent, 0 missing). Parity-check discriminates (exit 1 on drifted live, exit 0 on regen). Headless reliability UNPROVEN — carried as explicit P2 residual risk.
