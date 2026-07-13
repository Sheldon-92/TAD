# Phase 1 Impl Review (code-reviewer) — precompact-session-state-hook [YOLO]

- Reviewer: code-reviewer
- Handoff: `.tad/active/handoffs/HANDOFF-20260712-precompact-session-state-hook.md` (v2)
- Worktree: `/Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_4d1c412a-719-3`
- Commit: `e87547f` — 23 files changed, 522 insertions(+), 2 deletions(-)
- Verdict: **PASS (0 P0, 0 P1, 3 P2)** — recommend merge; P2s are hardening notes, not blockers.

## Method

Not paper review. I re-ran every behavioral AC against the actual scripts in the worktree
(snapshot generation, AC3 fault injection via sed-swapped git, AC4 7-run prune, AC5 20-way
concurrency, AC6 compact-vs-startup branch, AC8 CLAUDE.md line-set diff), inspected the full
hook source, `common.sh` helper contract, `settings.json`, `.gitignore`, and confirmed the
diff matches the completion report.

## AC Verification (independently re-run)

| AC | Verdict | How I verified |
|----|---------|----------------|
| AC1 exists/exec/`bash -n`/registered | PASS | `bash -n` clean both scripts; `jq .hooks.PreCompact[0]` → matcher `""`, cmd correct, timeout 10 |
| AC2a snapshot fields correct | PASS (script-level) / PENDING-REAL-EVENT | Synthetic stdin → fields match live git (`cf88b7f`/`e87547f`, branch, 5 mod/3 untracked). Live `/compact` capture legitimately deferred (sub-agent cannot trigger interactive compact); honest-partial pre-authorized by grounding |
| AC2b session-state.md zero-touch | PASS | Hook source contains NO write path to session-state.md (grep: only safety comments). Physical boundary is structural, not conventional |
| AC3 fail-open + discriminable | PASS | sed-swapped git→nonexistent: exit 0, snapshot written with `(unavailable: git-rev-parse-failed)` / `(unavailable: git-status)` fields. Deeper tiers (mktemp/mkdir/date fail) → exit 0 + `.hook-debug.log` breadcrumb |
| AC4 prune 7→5 | PASS | 7 distinct-name runs → exactly 5 remain, oldest survivor is newest-5 by `LC_ALL=C sort` |
| AC5 torn-write, 20 concurrent | PASS | Same-stdin 20-way concurrency: 0 leftover `.snapshot-tmp.*`, every file exactly 8 lines, single target name (atomic `mv`) |
| AC6 reminder branch | PASS | `source==compact` → reminder line present; `source==startup` → normal health summary, no reminder |
| AC7 no regression | PASS | Evidence baseline vs post-edit startup output byte-identical; compact branch inserted BEFORE the non-startup early-exit guard (L20 < L25); `output_response "SessionStart" <ctx>` matches pre-existing 2-arg contract |
| AC8 CLAUDE.md bounded | PASS | Diff = 2 modified lines (self-check header, Read step) + Layer-0 block added; semantics only-add, no deletion of existing rules |
| AC9 T1 records | PASS (structure) / PENDING (content) | `probe-stdin.json` honestly marked `"_synthetic": true`; `T1-answers.md` present; built-in tee auto-captures first real event |

## Code Quality

Strong. FR7 write discipline is correctly implemented: assemble-in-temp → single atomic `mv`;
no `set -e`; every `$()` has an output-neutral fallback; the `grep -c` "prints 0 but exits 1"
BSD trap is explicitly handled (`|| true` then empty→`?` normalization). The two-lane jq/grep
field extractor degrades gracefully. The `EXIT` trap cleans the temp on mid-death. Snapshot
dir is correctly gitignored and confirmed not tracked; snapshot never touches any
agent-maintained file. shellcheck -S warning is clean (exit 0).

## Findings

### P2-1 — Active-handoff/epic COUNT over-counts on filenames containing spaces
`list_dir()` derives `count` from a space-joined name string (`tr ' ' '\n' | grep -c .`),
not from the file list. I reproduced: a handoff named `HANDOFF-with space.md` yields count=4
for 3 real files. Not exploitable in practice — TAD handoff/epic filenames are conventionally
hyphenated, no spaces — and the field is diagnostic (readers use newest-wins), so a miscount
never breaks recovery. Cheap fix if touched later: count files directly
(`ls -1 $1 2>/dev/null | grep -c .`) and keep the space-joined string only for display.

### P2-2 — T1 probe tees raw stdin to a git-TRACKED evidence path (not gitignored)
The built-in probe writes real PreCompact stdin to
`.tad/evidence/hooks/precompact-snapshot/last-stdin.json`, which sits under the tracked
evidence tree (unlike the snapshot dir, which is gitignored). Real stdin contains
`transcript_path` + `session_id` + `cwd` — low-sensitivity, but if the first real `/compact`
capture is committed it lands in the public repo as auditable session metadata. Consider
adding `last-stdin.json` to `.gitignore` (the committed `probe-stdin.json` synthetic fixture
already documents the field shape, so the live capture need not be tracked).

### P2-3 — `chmod 644` / `mv` failures are silent past the breadcrumb tier
`chmod 644 "$TMP" || true` and the prune `rm -f ... || true` swallow errors by design
(correct for fail-open). Only the top-tier failures (mkdir/mktemp/mv/temp-assembly) emit a
`.hook-debug.log` line. A prune that silently stops deleting would let the dir grow unbounded
with no breadcrumb. Acceptable given fail-open priority and the low blast radius (disk noise,
not data loss) — noting for completeness, not requesting a change.

## Diff-vs-Report Consistency

Completion report claims match reality: 23 files changed / 522 insertions / 2 deletions
(verified via `git diff HEAD~1 --stat`). FR4 reminder text is verbatim-identical to the
handoff spec. The report's honest-partial framing (AC2a live-event, T1 content) is accurate
and pre-authorized — not validation theater; the script-level behavior is fully proven, only
the interactive-trigger capture is deferred to the human's next real `/compact`.

## Recommendation

MERGE. Zero P0/P1. The three P2s are optional hardening (P2-2 the most worth doing — one
`.gitignore` line to avoid committing live session metadata). Residual real-world unknown
(does CLI 2.1.172 fire PreCompact on auto-compact) is correctly gated per handoff §8.4 and
not a code defect.
