# Phase 1 Design Review — backend-architect (YOLO Y4)

Verdict: **CONDITIONAL PASS**. Design sound (header-name→dynamic index), contract stable, fail-closed
preserved, narrow scope correct. One concrete shipping regression must be reversed.

## P0
- **P0 §6 Step 5 / §4.2 instruct REMOVING the `d=="Decision"||c=="Chosen"` data-row header-skip guard.**
  Premise "header branch already ate the header" is FALSE for multi-table §11 sections. Header-lock is
  first-table-wins (havehdr never re-locks), so a 2nd table's header row is processed as a DATA row and
  emitted as a junk `Decision <SEP> Chosen <SEP> Rationale` event — a Parser Self-Trigger (2026-05-30 lesson).
  IN-CORPUS, not hypothetical: `HANDOFF-20260425-phase5-evolve-data-capture.md` (§11.1+§11.2) and
  `HANDOFF-20260425-phase6a-process-quality-foundation.md`. Per-(slug,day) dedup gates the whole CALL, not rows.
  Empirical diff on phase5: new algo emits an EXTRA junk row old algo did not.
  FIX (verified): KEEP a case-insensitive guard in the data-row branch:
    `dl=tolower(d); cl=tolower(c); if (d=="" || c=="" || (dl=="decision" && cl=="chosen")) next`
  Result: junk row gone; 4-col 9 rows / 5-col 7 rows unchanged. Strike the "remove the guard" instruction.

## P1
- **P1 trailing non-Decision tables under "Decision Summary" (e.g. phase5 §11.3 Disposition Status `| Epic ID | Item | Disposition | Notes |`) emit junk in BOTH old+new algos** (insec stays 1 under ###, rows read at stale locked di/ci). Pre-existing, not a regression, but FR3 "no junk" not achieved. FIX: add multi-table file to AC1.2 dry-run corpus; either scope-out with evidence in COMPLETION, or re-lock havehdr per Decision+Chosen header (also fixes P0 more elegantly).

## P2
- expert_findings (heading-count, no columns) + reflexions (key:value name-keyed) are genuinely positional-safe
  → narrow scope to decision_points is CORRECT, not a latent inconsistency. Affirm with one COMPLETION line.

## Clean (no finding)
- Contract stable: trace_decision_point signature + JSON {decision,chosen,rationale} + TRACE_DETAIL=full unchanged.
  Fix changes VALUES of args 1-3 only, not event SHAPE. dream-scanner Pass C / *optimize / *evolve unaffected.
- Fail-closed: ||true baseline 14; awk envelope `2>/dev/null` + `[ -n "$rows" ] || return 0` preserved; BSD-awk OK
  (tolower/split/gsub POSIX); every malformed input → exit 0 empty.
- Append-only historical corruption: leave-as-is + cutoff comment is RIGHT (no migration). Cutoff comment must
  NOT contain a literal Decision/Chosen table (self-trigger) — §6 Step 2 correctly uses a[3]/a[5]/a[6] phrasing.
