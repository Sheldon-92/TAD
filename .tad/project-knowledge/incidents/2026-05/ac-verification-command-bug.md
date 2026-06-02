# AC Verification Command Bug: grep -ocE | sort -u | wc -l

**Date:** 2026-05-27
**Linked to:** L2 ac-verification "Alex Handoff AC Design Rules"

---

### AC Verification Command Bug: grep -ocE | sort -u | wc -l - 2026-05-27
- **Context**: HANDOFF-20260527-vimax-pattern-upgrade-video-creation §9.1 AC15 specified `grep -ocE 'pattern' file | sort -u | wc -l` expecting count of unique pattern signal matches.
- **Discovery**: This command ALWAYS returns 1 for a single-file query, regardless of actual match content. Because `grep -c` outputs ONE number (line count for the file), `sort -u` on a single number trivially returns 1 line, `wc -l` counts 1. The intended semantics (count unique distinct match strings) requires `grep -oE 'pattern' file | sort -u | wc -l` (without `-c`, so each MATCH is on its own line). Blake's completion report inherited the same buggy command and reported "4" — Gate 4 raw-recompute caught the bug, but only by chance (Alex re-ran with `-oE` alone to investigate).
- **Action**: When AC requires "count unique distinct pattern signals", use `grep -oE 'a|b|c' file | sort -u | wc -l` (drop `-c`). Never combine `grep -c` with `sort -u | wc -l`. Add this to Alex step1d dry-run sanity check: any AC with `-oc` flags + `sort -u | wc -l` pipeline should be flagged for re-derivation.
- **Grounded in**: .tad/active/handoffs/HANDOFF-20260527-vimax-pattern-upgrade-video-creation.md:AC15, .tad/active/handoffs/COMPLETION-20260527-vimax-pattern-upgrade-video-creation.md
