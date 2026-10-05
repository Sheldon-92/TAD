# Gate 4 Verification — v2.44.0 publish (publish-only transaction)

**Verdict**: ✅ **PASS** — `v2.44.0` live at the exact mandated state. No further action.
**Verifier**: Alex (Terminal 1), independent recompute 2026-09-04. **Method**: read-only
`ls-remote` + local object checks; Blake's evidence reviewed, not re-executed.

## 1. Independent recompute (all ✅)

| Check | Expected (mandate §1 + A1 §10) | Observed |
|---|---|---|
| `refs/heads/main` | `40cf3234…` (FF from `2af31d1e`) | `40cf3234ade45a5ef1fdf0afc729b2537347a1ca` ✅ |
| `refs/tags/v2.44.0` (annotated) | exists, tag obj | `b9ac39c8d92308923e203a730e658753acff84f8` ✅ |
| `refs/tags/v2.44.0^{}` (peeled) | `40cf3234…` | `40cf3234…` ✅ |
| Local `40cf3234` | commit, child of `f8af5be4` | commit ✅ (hash equality ⇒ content equality) |
| No `--force` needed/used | FF clean | Blake log: `2af31d1e..40cf3234` clean FF ✅ |
| §7 untouched | prestate intact | AC7 sha unchanged per FINAL §3 ✅ |

## 2. Functional acceptance (Gate 4 v2 scope — evidence review only)

- AC1 `PASS-PER-A1` (raw exit 1 + 14-row classification + human sign-off — the designed path, not a waiver).
- AC2–AC8 all PASS per FINAL §5; gate table §4 complete (parity/migration/denylist 0, sweep L1 12/12, pack-drift advisory pre-existing).
- Scope == mandate: 9 accepted commits + release commit; no sync, no extra paths.

## 3. Knowledge Assessment (blocking)

- A. Blake implementation knowledge: N/A — publish transaction, no product code; the three product tracks' knowledge was assessed in their own Gate 3/4s.
- B. New discovery during acceptance: **Yes** — version-gate exclusion debt (grep heuristic vs accumulating historical refs).
  - File: `.tad/project-knowledge/patterns/release-sync.md`
  - Entry: `### A Version-Staleness Grep Gate Without a Maintained Exclusion Contract Ends Every Release in Override - 2026-09-04`
- Distillation note (Alex as stranger): journal = STOPPED §3 + FINAL §4–§6; unfillable fields: none — Blake's classification was complete, no questions routed back.

## 4. Archive + follow-ups

- Archived: `HANDOFF-20260904-publish-v2440-bundle.md`, `COMPLETION-…-STOPPED.md`, `COMPLETION-…-FINAL.md`, this note.
- Follow-ups (still local, untouched): B-track design, lite-mute P2 handoff, P1 version-gate exclusion-contract update (separate design flow), ROADMAP:27 `v2.43.1 | Published` docs correction.
- Accepted SHAs: local+remote `40cf3234`, tag obj `b9ac39c8`. Nothing pushed beyond mandate. No remote cleanup needed.
