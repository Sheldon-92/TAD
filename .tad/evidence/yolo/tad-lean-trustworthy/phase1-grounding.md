# Phase 1 Grounding — Trace producer §11 column-contract fix

**Conductor read at:** 2026-05-31 (YOLO Y2)
**Target:** `.tad/hooks/post-write-sync.sh` `emit_decision_points()` (lines 172-210)

## The bug (confirmed firsthand)
Line 173 comment: `Column contract: | # | Decision | Options | Chosen | Rationale | → $3 / $5 / $6.`
Line 188: `d=a[3]; c=a[5]; r=a[6]` — HARDCODED positional, assumes the 5-column shape.

`n=split($0, a, "|")` on a markdown row puts an empty a[1] before the first pipe and
empty trailing field after the last pipe. So:

- **5-col** `| # | Decision | Options | Chosen | Rationale |`
  → a[2]=#, a[3]=Decision, a[4]=Options, a[5]=Chosen, a[6]=Rationale.
  Current d=a[3]✓ c=a[5]=Chosen ✓ r=a[6]=Rationale ✓. **CORRECT.**
- **4-col** `| # | Decision | Chosen | Rationale |`
  → a[2]=#, a[3]=Decision, a[4]=Chosen, a[5]=Rationale, a[6]="".
  Current d=a[3]✓ c=a[5]=**Rationale** ✗ (should be a[4]=Chosen) r=a[6]=**empty** ✗.
  **CORRUPTED**: `chosen` holds the Rationale text, `rationale` is empty.

### Proof from real archived handoffs
- 4-col: `.tad/archive/handoffs/HANDOFF-20260531-research-engine-wire-phase4.md:145`
  header `| # | Decision | Chosen | Rationale |`. Row 5 Chosen="Right-moment trigger, not usage-count",
  Rationale="Some projects legitimately don't need research". The emitted trace event had
  chosen="Some projects legitimately don't need research" (= the Rationale cell) and empty rationale
  → the real Chosen value was DISCARDED. ~52% of the real decision corpus is column-shifted this way.
- 5-col: `.tad/archive/handoffs/HANDOFF-20260530-trace-instrumentation-fix.md:295`
  header `| # | Decision | Options Considered | Chosen | Rationale |` → parses correctly today.

## The fix (header-aware indexing)
Within the `## ... Decision Summary` section, detect the HEADER row (first `^\|` row whose trimmed
cells contain both a `Decision` cell and a `Chosen` cell, case-insensitive). Record the awk array
indices of the `Decision`, `Chosen`, `Rationale` cells. For subsequent DATA rows, read those indices
dynamically. This handles 4-col, 5-col, and any future column arrangement.

Requirements:
- Trim each cell (`gsub(/^[[:space:]]+|[[:space:]]+$/,"")`) before name-matching and before emit.
- Case-insensitive header match (tolower).
- Skip the separator row `^\|[-: |]+\|$` (existing logic).
- If NO header with both Decision+Chosen is found in the section → emit NOTHING (graceful skip, no junk).
  This is acceptable: every real §11 table has such a header; the old code relied on it too
  (via the `d=="Decision"||c=="Chosen"` skip). AC1.1 mandates graceful skip when a required column absent.
- Preserve the override-marker scan (lines 203-207, scans BOTH chosen+rationale for 用户选/user chose/
  human override/人类决策) — it stays correct once chosen/rationale read the right columns.
- Preserve `tr -d '\r\n' | cut -c1-200` truncation + `|| true` fail-open on every path.
- Preserve the per-(slug,day) dedup gate at call site (line 273) — do NOT touch.

## NOT in scope (HARD)
- Do NOT re-emit / repair historical corrupted events (append-only trace). Optionally add a one-line
  comment noting the fix date as a cutoff; that's all.
- Do NOT change the trace JSON schema or `trace_decision_point` signature.
- Do NOT touch `dream-scanner.sh` Pass C (it already reads chosen/rationale correctly; bug is upstream).
- Do NOT touch `emit_expert_findings` (170) or `emit_reflexions` (213).

## Dead-candidate purge (AC1.3)
Delete these 6 rejected content-free shells:
- `.tad/active/dream-candidates/CAND-2026-05-30-16115201.md` … `-16115206.md` (verified all status: rejected)
- After delete: reconcile counts in `.tad/active/dream-state.yaml` (total_rejected). Touch NO pending candidate.

## Verification corpus for AC1.2 (Blake runs at Gate 3 Layer 1)
Dry-run the patched emit_decision_points (extract the awk, feed each handoff) and confirm:
- 4-col handoff → row 5 emits chosen="Right-moment trigger, not usage-count", rationale="Some projects
  legitimately don't need research" (i.e. swapped back to correct).
- 5-col handoff → unchanged (still correct).
Paste both raw outputs in COMPLETION.

## Anti-self-trigger note
This grounding + the handoff describe a parser that matches `Decision`/`Chosen`. Do NOT write a literal
§11-shaped table with a `Chosen` header inside any evidence/review file the parser scans, or paraphrase
("the chosen-column") — see architecture.md "Parser Self-Trigger" 2026-05-30.
