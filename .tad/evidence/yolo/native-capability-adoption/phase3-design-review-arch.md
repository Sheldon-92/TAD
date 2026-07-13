# Phase 3 Design Review — Architecture Lens

**Handoff**: HANDOFF-20260713-native-capability-adoption-phase3.md
**Reviewer**: Architecture (backend/systems)
**Date**: 2026-07-13
**Verdict**: APPROVE WITH CHANGES (2 P1, 3 P2 — no P0)

## Domain Detection

Files to Modify are 2× SKILL.md (yaml-in-md protocol), 1× scan-log.yaml (data), 1× new spike
evidence dir. No .tsx/.jsx/.css, no auth/secrets. → **backend/systems architecture review**
(protocol state-machine design, single-writer boundary, spike-gate branch completeness,
Conductor/sub-agent tool boundary). Correct default.

## Verification Performed (not paper review)

| Claim in handoff | Verified against source | Result |
|---|---|---|
| scan protocol at L330-400, Step 1b today-guard L341-345, merge-write Step 4 L370 | Read SKILL.md L325-500 | ✅ accurate |
| Setup routine prompt inline-replicates scan + full-overwrite (L465-484) | Read L460-499 | ✅ CONFIRMED — L478 "Write results" has no merge/GC/preserve-rejected; it IS a full overwrite that would erase user reject decisions |
| STEP 3.9 `last_scan == null → skip`, suppress_if null clause | Read alex/SKILL.md L369-402 | ✅ accurate (L374 + L398) |
| scan-log.yaml `last_scan: null`, schema | cat | ✅ accurate |
| .agents mirror exists + currently byte-identical | ls + cmp | ✅ MIRROR-IDENTICAL |
| `claude` CLI present | which claude | ✅ /Users/sheldonzhao/.local/bin/claude |

The core architectural thesis is sound and well-grounded: **thin entry, thick protocol** —
delegate the cron body to the SKILL scan protocol instead of maintaining a second (already-drifted)
copy. The single-writer boundary (scan-log.yaml = sole output; REGISTRY.yaml untouched) is
correctly identified and guarded by AC8. The spike-gate two-branch design (PASS→cron / FAIL→degraded)
is complete — neither branch is a silent drop.

---

## P1 — Should fix before implementation

### P1-1 — Spike will almost certainly FAIL for the WRONG reason: preflight blocks scan on NotebookLM, not just gh-auth

The spike's whole purpose (FR3, Intent Statement) is to prove the *unknown*: "can a headless
session run the LLM-driven scan protocol including gh auth." The handoff frames the three spike
questions around **gh-auth (i)**, **skill-resolution (ii)**, **merge-write (iii)**, **last_scan
flip (iv)**. But the cron prompt commands the session to "execute `*research-github scan` 协议全步骤"
— and `scan` is a full sub-command, so it runs the **Preflight Check** (SKILL.md L19-36) FIRST.

Preflight runs FOUR checks unconditionally for `scan`:
1. `gh auth status` (the spike anticipates this — question i)
2. `test -x ~/.tad-notebooklm-venv/bin/notebooklm`  ← **not anticipated**
3. notebooklm version ≥ 0.3.4 via a `sort -V` pipeline  ← **not anticipated**
4. `test -f REGISTRY.yaml`

L35 note explicitly: "gh auth check is NOT required for: list, scan-log... **Required for all
other commands** (explore, notebook, search, refresh, **scan**, add)." The notebooklm binary/version
checks have no such carve-out — they gate every sub-command.

**Blast radius**: In a headless routine on a machine where the notebooklm venv is absent or
outdated, `on_fail_notebooklm` fires and scan never reaches Step 1b. The spike then records
`Verdict: FAIL` — but attributes it to gh-auth/skill-resolution when the real cause is an
**unrelated preflight dependency that scan does not actually need** (scan uses only `gh`, never
NotebookLM). This is a false-negative that will (a) route the Epic into the degraded branch for a
non-reason, and (b) permanently mis-diagnose "headless can't run LLM SKILLs" when the truth is
"the scan preflight over-requires NotebookLM."

**Recommended fix** (design-level, choose one):
- (a) Cron prompt should invoke the scan **protocol steps directly** (Step 1–5), explicitly
  skipping the notebooklm preflight legs, since scan's only real dependency is `gh`. This matches
  the existing architectural reality that scan never calls notebooklm.
- (b) OR carve notebooklm checks out of preflight for `scan`/`scan-log` (parallel to the existing
  gh-auth carve-out at L35) — scan genuinely does not use notebooklm, so this is a latent bug
  independent of this phase.
- (c) At minimum: FR3 / §8.4 Friction Preflight must add a FIFTH friction row for the notebooklm
  preflight dependency, and the spike-evidence Verdict must distinguish "FAIL: preflight-notebooklm
  (not a headless-capability signal)" from "FAIL: gh-auth-invisible-in-headless (the real question)."
  Without this, the Verdict conflates two failure classes — the exact anti-pattern principles.md
  warns about (coverage gate blind to which population failed).

This is the highest-value finding: the spike's evidence value collapses if it can't tell these apart.

### P1-2 — Fixture GC edge case: null previous last_scan makes the fixture NON-discriminative under one plausible reading

§4.3 designs the merge-write discriminator: seed a `rejected` fixture with
`first_seen: 2026-07-13`; probe should PRESERVE it → proves merge-write; if it disappears →
full-overwrite leak → FAIL(iii). The stated rationale: "GC 规则只删 `first_seen < previous last_scan`
的 rejected（previous 为 null → 必须保留）."

Cross-check against actual GC logic (SKILL.md L379-381):
```
GC: remove entries with status: rejected AND first_seen < previous last_scan date
```
Previous `last_scan` is `null`. The comparison `first_seen < null` is **undefined behavior at the
protocol level** — an LLM executing this could reasonably interpret it three ways:
1. null → treat as "no previous scan" → nothing qualifies for GC → fixture preserved (handoff's assumption)
2. null → treat as epoch/-infinity → `2026-07-13 < -inf` = false → preserved (same outcome, different path)
3. null → treat as +infinity / "always older" → `first_seen < inf` = true → fixture **GC'd** → **false FAIL(iii)**

Reading #3 is not far-fetched; it produces a false negative that fails a *correct* merge-write.
More importantly: the fixture's `first_seen: 2026-07-13` **equals today**, and after the probe
runs, the new `last_scan` becomes 2026-07-13 too. So even the discriminative power is thin —
`first_seen < last_scan` is `2026-07-13 < 2026-07-13` = false regardless, so a full-overwrite and a
correct merge-write can produce the *same* "fixture present" result if the writer re-seeds pending
entries. The fixture proves "not-full-overwrite" only if the probe's own scan does NOT re-discover
the fake repo (it won't, it's fake) AND the writer copies forward existing rejected entries.

**Recommended fix**: Make the fixture unambiguously discriminative — set `first_seen` to a date
**strictly before** a non-null sentinel, and seed `last_scan` to a real prior date (e.g.
`2026-07-06`) rather than null for the fixture run, so the GC comparison is well-defined and the
preserve-vs-GC decision is a clean binary. Document the exact expected GC outcome for THAT seeded
state. Alternatively, add a SECOND fixture that SHOULD be GC'd (`rejected`, `first_seen` well before
a seeded prior `last_scan`) so the test discriminates in BOTH directions — presence-only of one
entry can pass a broken writer that never GCs anything (see principles.md "fixture must discriminate
in both directions").

Note this trades against AC1/AC9 which assert `last_scan: null` as baseline. Reconcile by seeding
the fixture-run scan-log as a scratch copy, or re-null after evidence capture (Micro-task 7 already
removes the fixture; extend it to restore `last_scan` handling per branch).

---

## P2 — Nice to fix / flag for Blake

### P2-1 — AC5 verification is non-discriminative (can pass a half-done edit)

AC5: `sed -n '/## Setup: Scheduled Routine/,$p' ... | grep -c 'gh search repos' == 0`. This proves
the string `gh search repos` was removed, but the *delegation* requirement (FR2) is that the prompt
must instead say "Read SKILL → run scan non-interactive → merge-write → only scan-log." A prompt
that deletes the inline logic but forgets to add the delegation instruction ALSO scores 0.
AC6 (`grep -ci 'merge'` ≥ 1 in cron-prompt.md) partially covers this, but only for the standalone
file, not the in-SKILL Setup section. Suggest AC5 add a positive assertion: the Setup prompt must
contain a "non-interactive" declaration and a "Read ... SKILL" / delegation phrase.

### P2-2 — AC13 scope check has a grep-filter leak

AC13 filters `git status --porcelain` through `grep -v -e 'research-github' -e 'alex' -e 'scan-log'
-e 'cron-github-scan'`. The token `alex` is broad — any incidental path containing "alex" passes
the scope gate silently. Low real risk here, but the pattern is the "allow-list by substring" class
principles.md flags. Prefer anchoring to full expected paths, or invert to assert the changed set
EQUALS the §7 file list (`diff` of sorted expected vs actual) rather than filter-and-count-zero.

### P2-3 — `spike-evidence.md` Verdict grep depends on `^Verdict:` at line start with no trailing text tolerance

AC7: `grep -cE '^Verdict: (PASS|FAIL)' == 1`. If Blake writes `Verdict: FAIL — preflight (i)` the
regex `(PASS|FAIL)` still matches as a substring so it's fine; but `grep -c` counts matching LINES
and the handoff elsewhere wants the failed question number ON the Verdict line (§6.1 task 6). Ensure
the FAIL-reason annotation stays on the same line OR the count could become 2 if a second "Verdict:"
appears in prose. Minor; just note the Verdict line must be unique.

---

## Design Completeness Assessment

| Dimension | Status |
|---|---|
| Architecture complete (both branches specified) | ✅ PASS |
| Single-writer boundary correct + guarded | ✅ PASS (AC8) |
| Conductor/sub-agent tool boundary explicit | ✅ PASS (FR5, §8.4, §10.1 — Blake never calls CronCreate; well-anchored) |
| Spike is behavioral not structural | ✅ PASS (last_scan flip + fixture preservation are behavioral) — but see P1-1/P1-2 on discriminative integrity |
| honest_partial for un-taken branch | ✅ PASS (NOT_APPLICABLE_WITH_REASON convention specified per row) |
| Data flow mapped | ✅ PASS (MQ3 verified against real consumer) |
| Regression protection (interactive path) | ✅ PASS (AC4 second count ≥ 1, §8.2 regression) |
| Mirror parity | ✅ PASS (AC10 cmp) |
| Spike dependency preflight fully enumerated | ❌ P1-1 (notebooklm preflight leg missing from Friction Preflight) |
| Fixture discriminates both directions | ⚠️ P1-2 (single-direction, null-comparison ambiguity) |

## Summary

Strong, well-grounded design; the delegation thesis and single-writer boundary are correct and the
two-branch spike-gate leaves no silent drop. Two P1s both concern **spike evidence integrity** — the
exact place this Epic has been burned before (Phase 2 INERT, YOLO Validation Theater): P1-1 the scan
preflight requires NotebookLM which will produce a false-FAIL that mis-diagnoses the headless
question; P1-2 the merge-write fixture is only weakly discriminative under a null previous-last_scan.
Fixing both makes the PASS/FAIL Verdict trustworthy, which is the entire point of a spike-gated
phase. No P0 — nothing here breaks the architecture or the tool-boundary contract.
