# Phase 4 Implementation Review — code-reviewer

**Reviewer**: code-reviewer (YOLO Phase 4 impl review)
**Date**: 2026-07-13
**Handoff**: HANDOFF-20260713-native-capability-adoption-phase4.md
**Worktree**: `.claude/worktrees/wf_0019f033-1ce-1` @ commit `fcd6643`
**Verdict**: **PASS** — 0 P0, 0 P1, 2 P2 (advisory)

---

## Summary

Two small native-capability adoptions, both implemented cleanly and honestly:
- **Track A** (protocol text): `preview_usage_rule` guidance block + step1_5c step-4
  preview wiring in `design-protocol.md`, additions-only, mirrored byte-identically to
  `.agents/`.
- **Track B** (spike-gated rules pilot): B1 spike verdict LOADED (empirically verified on
  CLI 2.1.172 with 3/3 isolated fixture probes + docs citation), thin 25-line rule file,
  4 measurements archived.

I independently re-ran every §9.1 AC command against the worktree. **All 15 ACs reproduce
exactly the values claimed in the completion report.** The diff matches the completion
report's "Files changed" table 1:1 (7 files, 475 insertions, additions only). No code files
touched (`.js$` count = 0). No scope leakage.

This is high-quality YOLO work. Notably strong: the spike used a *discriminative* sentinel
token present in exactly one file to avoid the CLAUDE.md-@import confound, and the
completion report honestly discloses the first no-fire probe was confounded and discarded —
the opposite of Validation Theater.

---

## AC Re-Verification (independent re-run, not trusting the report)

| # | Claimed | Re-run actual | Match |
|---|---------|---------------|-------|
| AC1 | 1 / 1 / 2 | `1` / `1` / `2` | ✅ |
| AC2 | 4 | `4` | ✅ |
| AC3 | 2 | `2` | ✅ |
| AC4 | 3 | `3` | ✅ |
| AC5 | 0 | `0` | ✅ |
| AC6 | tracked empty / untracked §7.1 only | empty after excluding deliverables | ✅ |
| AC7 | IDENTICAL | `IDENTICAL` (diff -q mirror) | ✅ |
| AC8 | EXISTS, FORWARD-missing EMPTY | file present; FORWARD-missing section empty | ✅ |
| AC9 | 1 / 2 / 2 | `1` / `2` / `2` | ✅ |
| AC10 | PARSE-OK, scope key present | `- ".tad/hooks/**"` + PARSE-OK (yq) | ✅ |
| AC11 | 25 lines / 1370 B | `25` / `1370` (≤60 / ≤4096) | ✅ |
| AC12 | 5 RULE-OK, 0 MISS | 5× RULE-OK, 0 MISS | ✅ |
| AC13 | 1 | `1` | ✅ |
| AC14 | 4 SEC-OK | fire-test / no-fire / parity / context all hit | ✅ |
| AC15 | honest | Behavioral Ledger cross-checks; no file-existence-as-behavior | ✅ |

## Diff-vs-report fidelity

- `git log -1 --stat`: 7 files, +475, **additions only** — exactly matches report table.
- Working tree: only `.tad/evidence/traces/2026-07-13.jsonl` untracked — matches report's
  disclosed headless-probe side-effect (trace left on disk, NOT committed).
- Track A line-set diff (C1 archive) reproduced: FORWARD-missing EMPTY (original step-4
  line kept byte-identical), REVERSE-added = only the new preview block + step-4 extension.
- `.claude/rules/` correctly NOT mirrored to `.agents/` (Claude-native feature), disclosed
  per handoff §10.2.

## Content-parity spot check (Track B)

Cross-read the 5 rule-file constraints against source
`patterns/shell-portability.md`. All 5 are faithful, non-fabricated excerpts with correct
source-entry dates:
- #1 → 2026-04-03 (grep -P) ✅
- #2 → 2026-06-17 (grep no-match ERR trap) ✅
- #3 → 2026-05-31 (comm/sort LC_ALL=C CJK) ✅
- #4 → 2026-06-09 (gate-marker swallow) ✅
- #5 → 2026-04-24 (slug bracket-class) ✅

No drift, no rewording of facts. Sync note + pointer present.

---

## Findings

### P0 — none

### P1 — none

### P2-1 (advisory) — AC4 range robustness relies on ordering, not fragile now
The AC4 verifier `sed -n '/Use the merged_design/,/skip_conditions/p' | grep -c 'preview'`
happens to terminate at `skip_conditions` *before* the `preview_usage_rule` block, so it
counts exactly the 3 step-4 preview mentions (not the ~20 in the guidance block). This is
correct as implemented, but the clean result depends on the block being inserted AFTER
`skip_conditions`. It was — verified. No action needed; noted only so a future edit that
relocates the guidance block above `skip_conditions` would inflate AC4 and should re-scope
the range. Not a defect in this delivery.

### P2-2 (advisory, already escalated by Blake) — headless in-repo probes mutate tracked files
Blake's `claude -p` fire-test sub-sessions triggered the repo's own SessionStart/lifecycle
hooks, flipping 2 notebook statuses in `.tad/research-notebooks/REGISTRY.yaml` and emitting
a trace file. Blake reverted REGISTRY.yaml (`git checkout --`) and the commit is clean — I
confirmed the worktree shows only the untracked trace jsonl. Handled correctly and
disclosed. Forward recommendation (Blake already raised it): future in-repo fire-tests
should use fixture dirs only or hook-disabled invocation. No impact on this phase's
deliverables.

---

## Behavioral honesty (AC15) — verified genuine, not theater

The Behavioral Evidence Ledger correctly separates:
- PROVEN in-session: `.claude/rules` path-scoping WORKS on 2.1.172 (3/3 fixture + 3/3
  in-repo discriminative-token probes, symmetric fire=YES / no-fire=NO).
- observe-on-next-use: rule firing on real future `.tad/hooks/**` *edit* sessions
  (read-triggered limitation honestly documented in the rule file itself).
- PENDING-REAL-EVENT: Alex using preview at next *design (protocol text cannot fire
  in-session) — honest_partial, per handoff §10.2.

No claim overreaches its evidence class. The read-vs-write trigger limitation is disclosed
in three places (spike, measurement, rule file body) — exemplary honesty.

---

## Recommendation

**PASS Gate 3.** All ACs met and independently reproduced; diff matches report; content
parity faithful; behavioral claims honestly scoped. The 2 P2 items are advisory only and do
not block. No P0/P1 fixes required.
