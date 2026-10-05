# Independent Slice Review — control S3

Reviewer model: opencode-go/deepseek-v4-flash

## Q1

Present with the exact heading. `yolo-recovery.md:394` reads `## 12. Worked Example`, matching the task's required heading verbatim, and it is the final section of the file (file ends at line 587; nothing follows). It is a copy-pasteable shell transcript: four fenced `bash` blocks (lines 411–444, 455–486, 502–535, 545–575) with `$` prompts, all fences balanced, and placeholders are clearly marked and declared up front (lines 400–407: `/path/to/repo`, `<run-dir>` expands to `.tad/evidence/yolo/<epic>/<phase>/run-1`, `<...>` marks real values).

## Q2

All four phases are shown with accurate shapes:
- **init** (12.1): flags `--run --handoff --goal-file` match source `cmdInit` (`need(flags,'run'|'handoff'|'goal-file')`, yolo-recovery.mjs:1000–1002). Result shape matches `renderStatus` (mjs:546–578): `RUN:`/`STATE:` header, `RUN DIR:`, `GOAL:`, `HANDOFF REVISION: <path> @ sha256 <rev>` (mjs:553), `WORKTREE: ... (base <base> → latest observed <head>)` (mjs:554), all five empty sections plus the "working tree observation" line (mjs:560–562), `LEGAL NEXT ACTION`/`WHY`/`OWNER`/`RESUME COMMAND` (mjs:572–575), and `Start slice S1: <statement>` with `why` verbatim from mjs:478–479. JSON line (guide:443) has exactly the field set and order of `finish()` (mjs:1389–1403): format/command/result/run_dir/state/reason/verified_slices/unverified_slices/blockers/legal_next_action/capsule_tokens.
- **checkpoint** (12.2): flags `--slice --reason --next` match mjs:1141–1143; `candidate` is in `CHECKPOINT_REASONS` (mjs:49). Candidate line `- S1  (checkpoint candidate, reason=candidate, next="…")` matches mjs:559. Legal-next-action text `Slice S1 is a CANDIDATE only. … verify --slice S1 --receipt <receipt.json>` matches mjs:468–470 verbatim, owner `conductor`. JSON shows `unverified_slices:["S1"]` (mjs:1400 maps `candidate_slices`) and `reason:null` (state ACTIVE).
- **verify** (12.3): flags `--slice --receipt` match mjs:1164–1165. Verified line `- S1  (receipt <rel path>, head <head>)` matches mjs:557. JSON `verified_slices:["S1"]`, `unverified_slices:[]` (mjs:348 deletes the checkpoint on verified) and next action `Start slice S2` (mjs:475–481) are correct.
- **resume** (12.4): `RECOVERY PACKET: <abs run dir>/recovery.md (<n> est. tokens, budget 2500)` matches mjs:1356 exactly (runDir absolute, `CAPSULE_TOKEN_BUDGET = 2500`, mjs:53), printed after the status block and before the JSON line (mjs:1355–1357, 1469). JSON line matches `finish('resume', …)`.

Spot-checks performed (≥5): init flags (mjs:1000–1002), checkpoint flags + reason whitelist (mjs:1141–1146), verify flags (mjs:1164–1165), status header line (mjs:548), VERIFIED receipt line format (mjs:557), JSON field set/order (mjs:1389–1403), RECOVERY PACKET line (mjs:1356). All accurate.

## Q3

Internally consistent and executable given the narrated preconditions. The one-commit story is coherent: the same `<commit-after-gate>` is `latest observed` in 12.2/12.3/12.4 and is the receipt's `verified_head` = current HEAD, which the source explicitly accepts (mjs:898–912: equality skips the ancestor check). The transcript contains **no git add/commit** of evidence or receipts anywhere; 12.3 (lines 496–500) explicitly states `.tad/evidence/` is gitignored and receipts stay untracked — verified against the worktree's `.gitignore:122` (`.tad/evidence/`). That is also why `git status --porcelain` stays clean while the receipt and ledger files exist, keeping the shown "0 uncommitted path(s)" observation (mjs:167–177, 560–562) truthful. Placeholders are distinct: `<base-commit>` (init baseline), `<commit-after-gate>` (the S1 work commit), `<handoff-sha256>`, `<n>` — no placeholder is reused for two different commits, and the relative run path in init/checkpoint/verify vs. the absolute one in the RESUME COMMAND/resume (mjs:539–544 builds an absolute `--run`) is the source's actual behavior.

## Q4

No fabrication found. Every flagged item checked out against source: the gitignore claim (`.gitignore:122`), the five files `init` writes (goal.json, handoff-frozen.md, journal.jsonl, checkpoint.json, recovery.md — mjs:1076–1089), the derived_state_conflict exit-1 + `--rebuild-derived` remedy (mjs:1345–1351), the conditional PROHIBITIONS statement about blind re-apply (mjs:634–636, correctly phrased conditionally), and the "receipt must have independent review / distinct written_by_id" narrative (mjs:924–926, 956–961). The section is append-only: it follows §11 with no existing text reworded or reordered (S1/S2 slices live above it; §12 content ends the file). The weakest nuance I checked is the 12.2 label "latest observed <commit-after-gate>" appearing before the Gate has passed — the label is anachronistic, but it names the same single commit and is consistent with the 12.3 explanation; not a defect.

verdict: PASS