# Phase 1 Impl Review — Architecture Lens (native-capability-adoption / precompact-session-state-hook)

- Reviewer: backend-architect (architecture / blast-radius / completeness)
- Date: 2026-07-13
- Commit: e87547f (worktree wf_4d1c412a-719-3)
- Handoff: HANDOFF-20260712-precompact-session-state-hook.md (v2)
- Verdict: **PASS** (0 P0, 0 P1, 3 P2). Recommend merge; P2s are hardening notes, not blockers.

## What I verified (live, not paper)

Reproduced the hook in a fresh git repo + a spaced-path repo + a cloned repo with a real upstream. All exercised behaviorally, not just read:

- **Fail-open is real and discriminable.** Empty stdin, malformed JSON, missing git, missing mktemp, missing date — every path exits 0 and either writes `(unavailable: reason)` fields or a `.hook-debug.log` breadcrumb. Confirmed the deep tier live: `mv-failed` breadcrumb appears with the exact target path.
- **FR2 physical boundary holds.** The hook's only write targets are `precompact/` snapshot files, the prune inside that dir, `.hook-debug.log`, and the T1 `last-stdin.json` tee. It never touches session-state.md or any agent file. AC2(b) full-file diff + directory-wide md5 in the report corroborate.
- **FR4 branch placement correct + non-regressive.** `source==compact` branch sits BEFORE the non-startup early-exit guard. Live-tested all three source values: `startup` → full health summary (byte-identical to AC7 baseline, confirmed by diff), `resume` → `{}` (unchanged early-exit), `compact` → reminder line. No regression to the existing `output_empty` contract.
- **Modified/untracked counting is robust.** Tested staged-add (`A `), unstaged-modify (` M`), rename (`R  old -> new`), untracked (`??`) — the `^[^?[:space:]]\|^.[^?[:space:]]` regex classifies all correctly against `git status --porcelain` ground truth.
- **ahead/behind orientation correct.** `git rev-list --left-right --count @{upstream}...HEAD` emits behind<TAB>ahead; code assigns `BEHIND=$1, AHEAD=$2` — verified against a clone with 1 local commit (rendered "ahead 1 / behind 0"). No-upstream renders `?` (correct, not a fault marker).
- **Prune keeps newest 5 by name order, leaves `.hook-debug.log` untouched.** 7 sequential runs → exactly 5 snapshot-*.md remain; glob `snapshot-*.md` never matches the debug log. Prune runs AFTER the mv (torn-write safe by construction — each process writes a distinct filename).
- **Spaced-path safe.** The real repo path has spaces; the `list_dir $1` unquoted glob is safe because the glob *pattern* itself contains no spaces (it's relative), so word-splitting is benign.

## Architecture assessment

- **Independent-file-per-compaction design (arch F3 from v1) is the right call.** No shared writer → no read-modify-write race → the whole class of concurrency bugs that killed v1 is designed out, not patched. newest-wins reader rule + Session-as-diagnostic-only is internally consistent with T1(ii)'s "don't depend on session_id stability."
- **Relative-path convention (`SNAP_DIR=".tad/active/precompact"`) matches every existing hook** (pre-gate-check, post-write-sync, trace-step, notebook-dormant-sync all use `.tad/...` relative). Consistent; depends on Claude Code invoking hooks with cwd=project-root, same assumption the whole hook suite already makes.
- **Blast radius is minimal.** New PreCompact registration is additive (no other PreCompact hooks exist; empty matcher can't over-match anything else). startup-health.sh edit is a guarded pre-branch that provably doesn't alter the startup path. gitignore + template + CLAUDE.md edits are documentation-only. No production code path outside the hook suite is touched.
- **File-format-as-contract is honored.** Field names (When/Trigger/Session/Git HEAD/Git/Active handoffs/Active epics) match FR1 and the CLAUDE.md §4.5 consumer text exactly.

## Findings

### P2-1 — session_id path-traversal in filename fails safe but silently (hardening note)
`SID8=$(...session_id | cut -c1-8)` is interpolated raw into the snapshot filename. A session_id of `../../etc/x` yields `SID8="../../et"` → target `precompact/snapshot-{ts}-../../et.md`. Live-tested: the `mv` **fails** (intermediate `snapshot-{ts}-..` dir doesn't exist) → `log_skip "mv-failed"` → exit 0, nothing escapes `precompact/`, breadcrumb written. So this is NOT an escape vulnerability, and session_id is Claude-Code-controlled (a UUID), never attacker-supplied — hence P2 not P1. But a real UUID session would silently produce zero snapshots if any future Claude build used a session_id containing `/`. Cheap hardening: sanitize `SID8=$(printf '%s' "$SESSION_ID" | tr -cd 'A-Za-z0-9' | cut -c1-8)` before use. Turns a silent no-snapshot into a guaranteed-writable name.

### P2-2 — `AB_RAW` awk-splits a space-joined string that could mis-parse on locale/format drift
`AB_RAW=$(git rev-list ... | tr '\t' ' ')` then `awk '{print $1}'`/`$2`. Correct today. Note only: if git ever emits extra whitespace or a locale thousands-separator in the count, the awk field split still holds (awk collapses runs of whitespace), so this is low-risk — flagging only because ahead/behind is the single field where a silent wrong number (vs `?`) could mildly mislead recovery. No action required; documenting the assumption.

### P2-3 — completion report merge note is accurate and should be actioned at merge
The report (§Escalations) correctly flags that main's working dir has an uncommitted CLAUDE.md §7.5 (Memory Capture Layer) absent from the worktree base. I confirmed main's CLAUDE.md has both §4.5 (L47) and §7.5 (L87); the worktree edit is textually disjoint (§4.5 only). Merge should be clean but Conductor must verify the §4.5 three-layer block lands without clobbering §7.5. This is a process note, not a code defect.

## AC cross-check

| AC | Handoff intent | Independent verdict |
|----|----------------|---------------------|
| AC1 | script exists/exec/bash -n/registered | PASS — settings.json PreCompact[0] matcher "" timeout 10, confirmed |
| AC2a | live snapshot fields true | PASS (script-level) / PENDING-REAL-EVENT (honest_partial, pre-authorized) — synthetic + fresh-repo runs show correct fields vs live git |
| AC2b | session-state.md zero-touch | PASS — FR2 boundary verified; hook has no write path to it |
| AC3 | fail-open + discriminable | PASS — live-reproduced (unavailable) fields + mv-failed/mktemp-failed breadcrumbs |
| AC4 | prune 7→5 newest | PASS — reproduced independently |
| AC5 | torn-write resistance | PASS — distinct filenames + temp→mv make torn writes structurally impossible |
| AC6 | reminder mechanical | PASS — live grep -F match; startup path excluded |
| AC7 | no regression | PASS — startup output byte-identical (diff), resume path unchanged |
| AC8 | CLAUDE.md bounded | PASS — §4.5 three-layer block present, §7.5 untouched in worktree |
| AC9 | T1 records | PASS(structure)/PENDING(content) — synthetic probe marked `_synthetic:true`; real capture auto-lands via built-in tee |

## Bottom line

Architecture is sound: the independent-file design eliminates the v1 concurrency hazard by construction, blast radius is contained to the hook suite + docs, fail-open is genuine and discriminable, and every load-bearing AC verifies live. The two PENDING-REAL-EVENT items (AC2a live-compact, T1 content) are legitimately un-triggerable by a sub-agent and are pre-authorized honest_partial with an auto-capture mechanism (last-stdin.json tee) — no ceremony debt. The 3 P2s are hardening/process notes, none blocking. **Merge.**
