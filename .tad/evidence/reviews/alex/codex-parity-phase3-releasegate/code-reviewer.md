# Code Review (Blue-Team) — HANDOFF-20260601-codex-parity-phase3-releasegate (DRAFT)

**Reviewer:** code-reviewer (Alex pre-handoff Layer)
**Artifact:** design spec / handoff DRAFT (Phase 3 FINALE, Codex-parity Epic)
**Date:** 2026-06-01
**Scope:** the 5 required reads only. Verified empirically against the live repo where possible.

---

## 1. Critical (P0)

### P0-1 — The graduation `mv` (Step 1) BREAKS the pin-file co-location → permanent fail-CLOSED HARD BLOCK on every minor+ release

This is the highest-impact bug, and it is the inverse of the gate's purpose (it would block *every* release, not heal drift).

`parity-check.sh` resolves its pin file **relative to its own directory** and treats a missing pin file as a fatal `exit 1` (fail-CLOSED — correct for a LIVE gate):

```sh
# parity-check.sh L205-207, L253-256
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PIN_FILE="$SCRIPT_DIR/parity-criterion.md"
...
else
  echo "  ERROR: pin file not found at $PIN_FILE (required for LIVE gate)" >&2
  exit 1
fi
```

Step 1 / §7 / Grounded-Against all say **move only `parity-check.sh`** to `.tad/hooks/lib/codex-parity-check.sh`. The handoff **never mentions `parity-criterion.md`** — verified:

```
$ grep -n 'parity-criterion\|PIN_FILE\|pin file\|SCRIPT_DIR' HANDOFF-...phase3...md
70: ...NOT in scope: changing the parity criterion logic...
234: ...10.5 Don't touch the parity criterion logic...
# → only the "logic, don't touch" mentions; the FILE move is unaddressed
```

After the `mv`, `SCRIPT_DIR` resolves to `.tad/hooks/lib/`, but `parity-criterion.md` still lives in `.tad/evidence/spikes/codex-parity/` (confirmed present there, 5037 bytes). So `[ -f "$PIN_FILE" ]` is false → `exit 1` → the release gate reads this as **parity FAIL** → minor+ HARD BLOCK. The "self-healing release gate" would brick `*publish` on its first real run.

Worse: Step 1's own verification ("Verify it still runs from the new path") will likely be run from the spike dir or with the pin file still adjacent during testing, masking the defect until a real release.

**Required fix (must be in the handoff before it ships):**
- `mv` BOTH `parity-check.sh` AND `parity-criterion.md` to `.tad/hooks/lib/` (keep them co-located), OR
- pin `PIN_FILE` to an explicit stable path (not `$SCRIPT_DIR`-relative) and move the pin file there.
- Add an AC that runs the graduated check **from `.tad/hooks/lib/` with the spike dir absent/renamed** and asserts `exit 0` on the current parity editions (proves the pin file followed).

### P0-2 — Self-heal writes live editions per-edition BEFORE the final gate → half-applied / uncommitted-regen state on a partial heal or a later block

§4 mutates the **live** edition inside the per-edition loop (L83 `mv /tmp/<ed>.regen -> live`), then runs the final gate afterward (L85-90). Failure modes the handoff's FOCUS-1 questions raise are real:

- **(a) heal-then-block:** alex regen reaches parity → `mv` to live; blake regen does NOT reach parity → final gate `pass = false` → minor+ HARD BLOCK. Now **live-alex on disk is a freshly regenerated file**, the working tree is dirty, the release is aborted, and there is **no rollback step**. The repo is left in a half-applied state (one edition replaced, release not shipped, uncommitted change in the tree). The next operator sees a modified `codex-alex-skill.md` with no commit explaining it.
- **(b) partial heal:** same as (a) — the design has no "all-or-nothing" staging. It should regen **both** to scratch, gate **both** scratch outputs, and only then `mv` both to live (atomic batch), so a single-edition failure never mutates live.
- **(c) bad-regen-overwrites-good-live:** the §4 inline comment *"if regen itself non-parity, leave live as-is"* (L84) means a non-parity regen does NOT overwrite — that specific ordering is safe **only if** the per-edition `mv` is strictly guarded by `parity-check == 0` (L83 shows it is). But this is asserted in prose, not yet implemented; the guard MUST be a hard precondition in code, and the design should still move to scratch-gate-then-batch-mv to fully eliminate the window.

**Required fix:** restructure §4 to: (1) regen both to `/tmp`, (2) gate both `/tmp` outputs, (3) only if BOTH pass, batch-`mv` both to live and stage, (4) on any failure leave live untouched and block. Add an explicit "live editions are never mutated unless BOTH regens pass" invariant + an AC that forces a partial-heal (alex passes, blake fails) and asserts **live is byte-unchanged** and the tree is clean after the block.

---

## 2. Recommendations (P1)

### P1-1 — layer2-audit "suffix-normalize (strip `-reviewer`/`-review`)" is the wrong direction and creates false-positive / precedence hazards

FOCUS-3 is well-founded. Verified against the actual L72 case logic and the two lists:

- The file is `spec-compliance.md` → `name=spec-compliance` (no suffix). The KNOWN entry is `spec-compliance-reviewer` (L32). Stripping `-reviewer`/`-review` from the **filename** does nothing (it has no suffix). To make them meet you must strip the suffix off the **KNOWN-list side** (or normalize both to a stem) — the handoff's "strip a trailing suffix before comparing" is ambiguous about which side and, taken literally on the filename, **does not fix the reported case**.
- If you normalize by stripping `-review`/`-reviewer` from BOTH the filename and a copy of the known list, you introduce collisions:
  - `self-review` is in `SUBSTITUTION_HEURISTICS_LIST` (L38). Stripping `-review` → `self`. A future legit file `self.md`? unlikely, but the precedence (substitution vs known) now depends on strip order.
  - A Blake file named `code-review.md` (common) strips to `code`, which does **not** match `code-reviewer` stripped-to `code-reviewer`... unless you also strip the known side, at which point `code-review.md` → `code` == `code-reviewer`→`code` and it now **counts as a distinct reviewer** — arguably desirable, but it's a behavior change beyond the one name this handoff scopes, and it widens what counts as a "real" reviewer (anti-theater regression risk: `code-review.md` is exactly the file the 2026-05-27 entry flagged as a naming-convention artifact).

**Recommendation:** prefer the handoff's stated fallback — **add `spec-compliance` (and `code-review`, `architecture-review` if Blake uses them) explicitly to `KNOWN_REVIEWERS_LIST`**. It is one line, has zero collision surface, and matches the project's own 2026-05-27 architecture.md resolution ("prefer (a): standardize / extend the known list"). If a normalization is still wanted, scope it as a separate express and pin the exact strip rule + a false-positive test (`self-review` must still classify as substitution, not reviewer). The handoff currently states a preference (suffix-normalize) that is both under-specified and contradicts the cited prior-art's preferred fix.

Empirical baseline (pre-impl) confirmed:
```
DISTINCT_COUNT=1
WARN: unknown reviewer name(s)...: spec-compliance
WARN: 1 distinct reviewer ... found: code-reviewer
```

### P1-2 — fail-CLOSED switch is asserted but not located in an implementable artifact

FOCUS-4: the graduated `parity-check.sh` is **already fail-CLOSED** at the check level (`exit 1` on parse/pin/boundary error; header L2-4 say so). Good. But §4/10.3 describe an additional release-layer obligation: *"any parse/boundary error during `*publish` → treat as parity FAIL → block (minor+)."* That is a property of the **`codex_parity_gate` wrapper**, which does not yet exist — Step 3 says "implement per §4." The handoff asserts the mode but the switch is the wrapper's exit-code handling, which is **specified in prose only**. The risk: `codex exec` returning non-zero (network, auth, 175s timeout) must map to BLOCK on minor+, NOT to "skip and proceed." Two distinct error classes need explicit handling:
- **codex unavailable** (`command -v codex` = 0) → documented: check existing editions + block on drift. ✓ clear.
- **codex present but `codex exec` fails / times out mid-regen** → NOT addressed. Currently §4 would fall through to "gate on live" (which may still be at old parity → PASS → ships WITHOUT a fresh regen). That is a fail-OPEN hole: a broken regen tool silently degrades the self-heal to a no-op.

**Recommendation:** add an explicit error arm: `codex present AND regen command exit != 0` → treat as parity-unreachable → BLOCK (minor+) / advisory (patch), and add an AC simulating `codex exec` failure (e.g. stub a `codex` that exits 1) asserting the gate blocks rather than shipping stale editions.

### P1-3 — `regen-procedure.md` "Headless Invocation" still shows `claude -p`, contradicting Decision 3 / 10.4

`regen-procedure.md` L133-139 documents the headless path as `claude -p ...`, with the `codex exec` form only as an "Or via Codex" afterthought. Decision #3 and 10.4 explicitly say `claude -p` FAILs on the 326KB input (analysis, not file) and the release gate MUST use `codex exec`. Step 1 says "update `regen-procedure.md` to the stable path" but does **not** say to fix the headless-invocation tool ordering. If the release gate copies this section, it inherits the broken `claude -p` form.

**Recommendation:** Step 1 must also swap the "Headless Invocation" block to lead with `codex exec --full-auto` and demote/annotate `claude -p` as KNOWN-FAILING for this input size (cite Decision 3). Add it to the file-modify checklist for `regen-procedure.md`.

### P1-4 — Step 1 does not enumerate all references to the spike path; broad-grep is missing

Per the project's own "Cleanup Handoff Scope-Estimation Drift" and "Downstream Consumers Grep" lessons, a path `mv` needs a broad grep. The handoff updates `regen-procedure.md` + a spike pointer, but a repo grep finds the spike path string in: `regen-procedure.md`, `EPIC-...codex-edition-parity.md`, `architecture.md`, plus several archived handoffs/reviews (archive is acceptable to leave as historical). The **EPIC file** (active) and **regen-procedure Step D L61** (`bash .tad/evidence/spikes/codex-parity/parity-check.sh ...`) are live references that will dangle.

**Recommendation:** add an AC: `grep -rn 'spikes/codex-parity/parity-check.sh' .tad/active .tad/hooks .claude` returns only intentional pointer lines (archive excluded). Update the active EPIC + regen-procedure Step D invocation to the new path.

---

## 3. Suggestions (P2)

- **P2-1 (AC6 grep is correct but brittle):** the AC6 pattern `grep -c 'WARN.*1 distinct'` matches the live output (`...WARN: 1 distinct reviewer...`) — verified returns `1` pre-impl, expected `0` post-impl. ✓ runnable. Suggestion: anchor on the more stable machine line `WARN_REVIEWER_COUNT=1` (the script prints it) rather than the human prose `1 distinct`, which is more refactor-resistant.
- **P2-2 (AC8 is fine):** `grep -c parity .claude/settings.json` = `0` verified; note `grep -c` exits non-zero on 0 matches, so don't chain it with `&&`. As written (bare command, read the number) it's correct.
- **P2-3 (AC1 insufficient):** `test -f .tad/hooks/lib/codex-parity-check.sh && echo ok` only proves the file moved — it does NOT prove the pin-file dependency (P0-1) followed. Strengthen AC1 to actually *run* the graduated check on the live editions from the new path with the spike dir temporarily renamed.
- **P2-4 (P1-2 awk fix verifiability):** Step 2 "header comment lines must not self-count" has no AC command. Add one: run `parse_safety_counts` on a file whose **header** contains a SAFETY token (e.g. the `<!-- ... -->` provenance header) and assert the header section contributes 0 to owner tallies. This is the project's recurring "parser self-trigger / self-count" class (architecture.md 2026-05-30) — it deserves a concrete dogfood, not just "confirm P2 editions still PASS" (a no-regression check can pass while the self-count bug persists if no header token exists today).
- **P2-5 (atomic mv + trap):** when implementing the batch-`mv` (P0-2 fix), use a temp-then-`mv` within the same filesystem and a cleanup trap so a crash mid-stage doesn't leave a partial live edition — mirrors the project's "atomic archive via mv" and "atomic temp+mv" patterns.

---

## 4. Overall: **CONDITIONAL PASS**

The Epic-finale design is coherent and the self-heal concept is sound, but **two P0s must be resolved in the handoff before it ships to Blake**:

1. **P0-1** (pin-file not moved with the script) would turn the "self-healing gate" into an unconditional release blocker on the first real `*publish` — empirically confirmed the script `exit 1`s when `parity-criterion.md` is not adjacent. This is a release-stopping defect hiding behind a Step-1 verification that won't catch it.
2. **P0-2** (per-edition live mutation before the final gate) leaves a half-applied, uncommitted regen state on any partial heal or downstream block — restructure to scratch→gate-both→batch-mv with a "live untouched unless both pass" invariant.

P1-1 (fix direction/false-positives in layer2-audit normalize — prefer the additive `KNOWN_REVIEWERS` edit), P1-2 (explicit `codex exec` failure → BLOCK arm), P1-3 (fix `claude -p` in regen-procedure headless block), and P1-4 (broad-grep AC for the moved path) should also be folded in before handoff. With P0-1 and P0-2 fixed and P1-1..P1-4 addressed, this is ready for implementation.
