# Phase 1 Design Review — Architecture Lens

**Handoff**: HANDOFF-surplus-local-skill-capture.md (v3.1.0)
**Reviewer**: Backend/Systems Architecture (distribution-pipeline & isolation focus)
**Date**: 2026-07-05
**Domain auto-detect**: No frontend (.tsx/.jsx/.css), no API/DB/service, no auth/secrets in Files-to-Modify (`.gitignore`, `.claude/skills/save-skill/SKILL.md`, `.claude/skills/local/*`). → **Default: systems/distribution-architecture review.** The real architectural surface here is the framework's install/sync/publish isolation model.

**Verdict**: **CONDITIONAL PASS** — design is functionally sound and the load-bearing isolation invariant is verified correct, but the grounding record contains a factual inaccuracy that is marked ✅-verified and propagates to a sibling-epic contract, and the "3 isolation surfaces" framing overstates the actual defense depth.

---

## What I verified on the live repo (independent grounding)

| Check | Result | Meaning |
|---|---|---|
| Distribution source = `DOWNLOAD_URL=…/archive/refs/heads/main.tar.gz` (tad.sh L24) | ✅ GitHub archive tarball = **git-tree only** (no untracked/gitignored files) | The core isolation invariant HOLDS: a gitignored `local/` in the TAD repo can never enter the tarball → never reach `$src` → never hit the copy loop. This is the single most important claim and it is correct. |
| Main copy loop `for skill_dir in "$src"/.claude/skills/*/` (L804) + plain `cp -r` for non-pack skills (L~574) | ✅ | `save-skill` is a non-pack skill → whole-dir `cp -r`. A top-level `.claude/skills/local/` dir, **if present in `$src`**, WOULD be copied. Isolation therefore rests entirely on `local/` being absent from `$src`. |
| `grep -c 'skills/local' tad.sh` (AC11's literal target) | `0` | AC11 passes. |
| `grep -n "/local/" tad.sh` | **3 hits: L390, L607, L670** — `find … -not -path '*/local/*'` | tad.sh **DOES** special-case `local/` paths (in `copy_pack_skill_smart`). §2.2's claim "ZERO special-casing of skills/local" is **factually wrong**; AC11's grep string simply cannot see the `*/local/*` glob. |

---

## P0 — Blocking
None. The load-bearing isolation invariant (gitignored → absent from `main.tar.gz` → absent from `$src`) is verified true for both the tarball and git-clone distribution paths. No downstream-data-corruption or framework-breakage path exists. Blast radius is genuinely small.

---

## P1 — Should fix before acceptance

### P1-1: §2.2 grounding fact "ZERO special-casing of skills/local" is false, yet marked ✅ — and AC11 measures the wrong thing
- **Evidence**: tad.sh contains three `-not -path '*/local/*'` exclusions (L390, L607, L670) inside the pack-skill copy path. So tad.sh **does** treat `local/` specially. §2.2 row states "tad.sh + derive-sync-set.sh contain ZERO special-casing of `skills/local`" and MQ1/§7.3 present this as verified grounding.
- **Why it matters (blast radius)**: (a) The grounding table is TAD's "ground truth" record; an inaccurate ✅ fact is exactly the failure class principles.md warns about repeatedly. (b) §2.1 states the **sibling epic `*save-workflow` will reuse these conventions as its contract** — a wrong fact about the distribution pipeline propagates. (c) AC11 greps the literal `'skills/local'` → `0`, so it "passes" while proving nothing about the actual claim; Blake's completion evidence will enshrine "no special-casing" as verified. The AC is measuring the absence of a string, not the presence of the isolation property.
- **Fix**: Correct §2.2 to: "tad.sh has **no top-level-dir** special-casing of `.claude/skills/local/`; note `copy_pack_skill_smart` DOES exclude `*/local/*` for **nested** local dirs in pack skills (L390/L607/L670) — defense-in-depth for the nested case, not the top-level case this design uses." Re-point AC11 at the real invariant (see P1-2 fix).

### P1-2: "3 isolation surfaces" overstates defense depth — there is exactly ONE active defense, and it has no code-level guard
- **Evidence**: §4.1 lists three surfaces. On inspection: Surface 2 (`derive-sync-set.sh`) governs `.tad/` only and never touches `.claude/skills` — it is a non-threat, not a defense. Surface 3 (`release-verify.sh` FR7) merely **tolerates** target-side extras — it prevents nothing. Surface 1 (tad.sh) only protects **because** `local/` is absent from `$src`, which is 100% dependent on the gitignore. Net: the design has **one** load-bearing mechanism (gitignore → tarball exclusion), and two "not-a-threat" observations dressed as defense-in-depth.
- **Additional architectural gap**: TAD already reserves `*/local/*` as a non-distributed convention **at the code level** (the 3 exclusions above), but only for **nested** `local/` inside a skill dir. This design places output at the **top-level** `.claude/skills/local/` sibling dir, which deliberately forgoes that existing code guard and relies purely on gitignore. That is a legitimate choice (single discoverable location), but it should be made **honestly and explicitly**, not masked as multi-surface robustness.
- **Why it matters**: Single-point-of-failure isolation is fine for a single-user CLI, but the design doc should say so plainly so a future maintainer (or the sibling epic) doesn't assume redundant protection that isn't there. If the one gitignore line is ever dropped/edited, isolation silently fails with zero backup — and no AC would catch a working-tree `git add -f` or a non-git distribution.
- **Fix (low cost)**: (a) Reframe §4.1 as "one active isolation mechanism (gitignore→tarball) + two non-threat surfaces confirming no other pipeline touches it." (b) Add an AC that asserts the actual invariant rather than a string-absence, e.g. simulate the distribution source and confirm `local/` is not in it: `git ls-files '.claude/skills/local' | wc -l` = 0 **is** the right proxy — promote AC10 to the load-bearing isolation AC and label it as such (it currently reads as a mere "precondition"). (c) Optionally note that the existing `*/local/*` code convention is available as a fallback if top-level isolation ever proves fragile.

---

## P2 — Nice to fix

### P2-1: Downstream gitignore asymmetry is under-documented
The `.gitignore` line is added only to the TAD repo. Downstream installs get `save-skill/SKILL.md` but their `local/` is not gitignored (tad.sh does not copy `.gitignore` — correct). The design says committing local skills is "the project's choice," but the **shipped** SKILL.md gives downstream users no instruction on how to *opt into* gitignore isolation if they DON'T want local skills in their git. Add one line to the SKILL.md "TAD-repo note" telling downstream users they may add `.claude/skills/local/` to their own `.gitignore` if they want the same isolation. (TAD's own isolation guarantee holds regardless — `local/` is never in the TAD source — so this is completeness, not correctness.)

### P2-2: `_example.md` fixture becomes a discoverable "skill" via `_index.md`
The Gate-3 fixture writes `_example.md` and an `_index.md` line. In any environment where `local/` exists, the SKILL.md load path (read `_index.md` → match → Read) will surface `_example` as a real local skill. It is gitignored so it stays in Blake's evidence env only (never distributed) — low impact — but Step 1/using-local-skills should either skip `_`-prefixed entries or the fixture should be clearly marked as a non-skill sample. Minor.

### P2-3: `_index.md` non-atomic write window — make the recovery rule explicit in Step 5
MQ5 correctly identifies `local/<name>.md` as source-of-truth and `_index.md` as derived, with a single-write interruption window. Acceptable for a single-user CLI. Make the idempotent recovery a **written instruction** in SKILL.md Step 5 ("if the index line for an existing local file is missing, re-running Step 5 is safe and repairs it") rather than only living in the handoff, so the self-healing property survives into the shipped artifact.

---

## Design strengths (worth keeping)
- The upstream-cut isolation insight (§11.1) is architecturally correct and the best available choice: cutting at the git layer is more complete than any in-pipeline deny-list, and it's zero-code — this genuinely echoes the "every copy granularity" principle by making granularity irrelevant.
- Grounding depth is high (file:line citations, dry-run baselines). The one inaccuracy (P1-1) is the exception, not the rule.
- Scope discipline is strong: NFR3 + AC11/AC14 correctly fence off tad.sh/derive-sync-set/publish. Respecting the blake skillify `forbidden_implementations` boundary via runtime `MUST NOT be auto-invoked` (AC5) is the right call.
- Single-file SKILL.md with body-resident constraints correctly applies the circular-trigger-test principle.

---

## Summary for Conductor
Accept after addressing **P1-1** (correct the false "ZERO special-casing" grounding fact and re-aim AC11 at the real invariant) and **P1-2** (honestly reframe the isolation as one active defense; promote AC10 to the load-bearing isolation assertion). Both are documentation/AC-accuracy fixes, not implementation changes — the actual isolation behavior is verified sound. P2s are polish and can ship in the same pass or defer. No P0; blast radius is small and the primary distribution path (GitHub archive tarball) provably excludes gitignored `local/`.
