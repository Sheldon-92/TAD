# PM checkpoint — Gate 2 Round 4 Handoff Amendment (knowledge-seam-isolation)

- date: 2026-09-08
- role: Alex (Solution Lead, Terminal 1)
- channel: cursor
- model: gemini-3.8-flash-medium
- handoff: `.tad/active/handoffs/HANDOFF-20260908-knowledge-seam-isolation.md`
- status: `Ready-for-Gate2-Round4`
- prior_reviews:
  - Scope R3: `.tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-scope.md` (FAIL: 1 NEW-P0 [R3-NEW-P0-1], 1 P1, 2 P2)
  - Spec R3: `.tad/evidence/reviews/2026-09-08-gate2-r3-review-knowledge-seam-spec.md` (PASS: 0 P0, 3 advisory P1)

## 1. Summary of Actions
Per Human / PM mandate, Alex amended `HANDOFF-20260908-knowledge-seam-isolation.md` to clear Gate 2 Round 3 `R3-NEW-P0-1` and cheap-fix advisory P1/P2 items from the Round 3 Scope Review, advancing the handoff status to `Ready-for-Gate2-Round4`. **No code implementation in `tad.sh` or hook scripts was performed. Blake was not dispatched.**

### P0 Closure
1. **R3-NEW-P0-1 (AC1.4 vacuous main execution early exit)**:
   - Root cause: `tad.sh` terminates with a bare `main` invocation (line 2954) without a `BASH_SOURCE` guard. Sourcing `tad.sh` directly runs `main`, which exits before reaching the behavioral assertions, causing AC1.4 to falsely report exit 0 without executing the probe.
   - Fix: Replaced `source tad.sh` in §9.1 AC1.4 with a main-free loader pattern:
     ```bash
     TMPF=$(mktemp) && sed '/^main$/d' tad.sh > "$TMPF" && bash -c 'source "$0" >/dev/null 2>&1; derive_framework_top_files . | { grep -Fx "brain-index.md" && exit 1 || true; } && derive_framework_top_files . | { grep -Fx "sync-registry.yaml" && exit 1 || true; } && derive_framework_top_files . | grep -Fxq "version.txt"' "$TMPF"; RC=$?; rm -f "$TMPF"; exit $RC
     ```
   - Behavior: Functions are loaded without executing `main`. Baseline fails cleanly (exit 1 on `brain-index.md` leak), correctly discriminating against regression while passing (exit 0) post-implementation.

### P1 / P2 Advisory Enhancements
2. **P1-1 (AC5.1 quoting-variant skill preservation coverage)**:
   - Added sibling skills covering all YAML quoting forms: `c1` (bare `ownership: project-owned`), `c2` (single-quoted `'project-owned'`), and `c3` (double-quoted `"project-owned"`), plus `local/keep.txt`. Asserted all four survive `tad.sh` sync in §9.1 AC5.1.

3. **P2-1 (AC2.1 anchored grep)**:
   - Changed unanchored `grep -v 'README.md'` to exact match `grep -vx 'README.md'` in §9.1 AC2.1.

4. **P2-2 (AC6.2 workspace mutation protection)**:
   - Wrapped the doctor touch-staleness probe with backup and restoration:
     `cp -p .tad/brain-index.md .tad/brain-index.md.bak` ... `mv -f .tad/brain-index.md.bak .tad/brain-index.md` in §9.1 AC6.2 to avoid leaving the live repository dirty.

### Human Locks Maintained
- **Lock ①**: Option A pure isolation (only `README.md` installed on new projects; empty `patterns/` and `incidents/` subdirectories).
- **Lock ②**: Quarantine opt-in only via `tad.sh --quarantine-pk` (zero quarantine in `update` path).

## 2. Next Steps
- Handoff status updated to `Ready-for-Gate2-Round4`.
- Await Gate 2 Round 4 dual review.
- Do NOT implement `tad.sh` body. Do NOT dispatch Blake until Gate 2 achieves dual PASS.
