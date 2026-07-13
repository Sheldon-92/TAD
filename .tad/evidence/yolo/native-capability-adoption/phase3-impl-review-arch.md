# Phase 3 Implementation Review — Architecture Lens

**Reviewer**: Architecture (backend/systems)
**Handoff**: HANDOFF-20260713-native-capability-adoption-phase3.md
**Commit**: fada2f1 (worktree wf_a4ff2d3f-9c0-3)
**Date**: 2026-07-13
**Verdict**: PASS with 3 P2 advisories (no P0/P1 blockers)

---

## Scope Inspected

- 7 changed files (git diff HEAD~1): research-github SKILL.md (.claude + .agents mirror),
  cron-prompt.md, spike-evidence.md, scan-log.yaml, traces jsonl, phase3-completion.md
- FR1 (non-interactive today-guard), FR2 (delegating routine prompt), FR3 (headless spike),
  FR5 (Conductor boundary). FR4 correctly not-executed (PASS branch).
- Step 4 merge-write protocol (unchanged, per §10.1 mandate)

## Architecture Assessment

**Delegation design is correct.** FR2 removed the inline scan-logic copy (the full-overwrite
drift hazard flagged in the handoff) and replaced it with a thin prompt that Reads the SKILL and
delegates to the canonical scan protocol. Single source of truth restored — this is the right
"thin entry, thick protocol" call and directly retires a real, already-materialized drift bug
(the old inline copy full-overwrote scan-log.yaml, destroying user accept/reject decisions).

**Behavioral evidence is genuine, not validation theater.** The core observable — `last_scan`
null→2026-07-13 — was produced by a real `claude -p` probe making real gh API calls, verified in
the live scan-log.yaml (4 real updates + 4 real ai-agents candidates with plausible star counts).
Merge-write was proven discriminatively via the seeded rejected fixture (survived with first_seen
intact). Same-day re-run produced a byte-identical md5 (135367a7…), proving the guard exits without
rescan/write. This satisfies the Phase-2 INERT lesson: PROVE, don't cite docs.

**Blast radius tightly contained.** AC13 scope check = 0 leaks; alex/SKILL.md diff = 0 lines
(correct — PASS branch must not touch it); REGISTRY.yaml zero-diff (single-writer preserved);
.agents mirror cmp IDENTICAL. Out-of-scope hook drift (research-notebooks REGISTRY.yaml dormant
marking) was caught and rolled back — good hygiene, correctly escalated.

**Conductor/sub-agent boundary respected.** Zero CronCreate/CronDelete calls; registration +
one-shot verification correctly escalated as post-gate Conductor actions. The minimal-permission
set discovered under the sub-agent classifier denial is a genuine asset (ready-made cron perm config).

---

## Findings

### P2-1 — Non-interactive guard trigger is a soft, implicitly-contracted text signal
The FR1 branch fires only when the invoking prompt literally declares "non-interactive mode"
(SKILL.md L343-344). If a future cron prompt is reworded and drops that exact phrase, the guard
silently reverts to the AskUserQuestion path — which would hang or fail a headless session (the exact
failure FR1 exists to prevent). The coupling between cron-prompt.md's wording and the SKILL branch
condition is real but undocumented as a contract. Consistent with the single-user-CLI soft-reminder
principle (mechanical enforcement rejected), so P2 not P1 — but a one-line note in cron-prompt.md
("the literal phrase 'non-interactive mode' is load-bearing — the SKILL Step 1b branch keys on it")
would prevent silent regression. Consider also accepting a broader trigger (e.g. any headless/-p
context) rather than one exact phrase.

### P2-2 — cron-fires-at-all remains genuinely unproven (correctly escalated)
The spike proves headless-scan-works; it does NOT prove cron-triggers-on-schedule. The Epic's
actual success criterion (weekly automation keeping scan-log fresh unattended) is not yet met until
the Conductor's +5min one-shot cron fires. This is correctly escalated and not Blake's fault, but the
completion report's framing ("automation闭环") slightly overstates what is proven at gate time. The
gate should treat this phase as "headless-safe + ready-to-register", with the actual automation claim
deferred to the post-gate Conductor verification.

### P2-3 — Evidence prose reads as internally contradictory (cosmetic)
spike-evidence.md Q(ii) says `e2b-dev/awesome-ai-agents` was "skipped (already registered)" in
Discovery (Step 3), yet it appears in the `updates` list (Step 2). This is actually correct behavior
— registered lists get freshness-checked (updates) while only NEW lists are discovery candidates —
but to a zero-context reader the two statements read as a contradiction. A half-sentence clarifying
"registered lists appear in updates, not discovery" would remove the apparent conflict. No functional
impact.

---

## Non-Issues (verified, no action)
- AC5 (Setup section, 0 inline `gh search repos`): confirmed 0.
- AC10 mirror byte-identity: cmp IDENTICAL confirmed.
- Fixture cleanup: grep count 0 in final scan-log.yaml confirmed.
- Trace jsonl commit: repo convention, 3 evidence_created events, legitimate.
- Interactive path regression: AskUserQuestion today-guard preserved verbatim in Else branch.
