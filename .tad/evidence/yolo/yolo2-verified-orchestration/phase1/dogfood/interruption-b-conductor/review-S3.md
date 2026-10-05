# Independent Slice Review — interruption-b S3

Reviewer model: opencode-go/deepseek-v4-flash

Files examined: task.md (slice spec), `.tad/guides/yolo-recovery.md` §12 (lines 369-429), `.tad/scripts/yolo-recovery.mjs` (1481 lines), `.gitignore`, `git show d52d4137` (the S3 commit).

## Q1

PASS. The section exists at line 369 with the exact heading `## 12. Worked Example` (grep: single match; `git show d52d4137` diff adds the heading verbatim). It is a copy-pasteable bash code fence with clearly-marked, enumerated placeholders (`<WORKTREE>`, `<RUN_DIR>`, `<HANDOFF_PATH>`, `<GOAL_SPEC_PATH>`, `<RUN_ID>`, `<SLICE_ID>`, `<RECEIPT_PATH>`, `<COMMIT>` — guide lines 371-376). Appended at EOF (file ends at line 429, after the section's trailing paragraph).

## Q2

Mostly PASS, with one inaccurate output shape (details in Q4). All four commands and their flags match the CLI's USAGE block exactly: `init --run --handoff --goal-file` (mjs:1426, needs at mjs:1000-1002), `checkpoint --run --slice --reason before-stop --next` (mjs:1428; `before-stop` is a legal CHECKPOINT_REASONS value, mjs:49), `verify --run --slice --receipt` (mjs:1429), `resume --run` (mjs:1434). Spot-checks against source: (1) init's `RUN: <RUN_ID> STATE: ACTIVE` matches renderStatus mjs:549; (2) init JSON `{"format":"yolo-recovery-status-v1","command":"init","result":"PASS","state":"ACTIVE",...}` matches finish() mjs:1389-1394 and STATUS_FORMAT mjs:39; (3) the checkpoint journal line `{"seq":2,"type":"checkpointed",...,"payload":{"slice","reason","next"}}` matches appendEvent mjs:720 and cmdCheckpoint's payload mjs:1150-1151; (4) verify JSON `verified_slices` matches mjs:1399; (5) resume's `RECOVERY PACKET: <RUN_DIR>/recovery.md (<n> est. tokens, budget 2500)` matches cmdResume mjs:1356 verbatim including CAPSULE_TOKEN_BUDGET=2500 (mjs:53). The checkpoint "result shape" is shown as the journal append rather than the status JSON — acceptable as "what a checkpoint looks like", though it omits checkpoint's own JSON status line.

## Q3

PASS. The sequence init → checkpoint → verify → resume is executable: step 0's "checked out at exactly the declared base commit" satisfies the init `base_commit_mismatch` check (mjs:1021-1023), and no binding/honest_partial blocker can arise in this minimal run. The transcript contains NO `git add`/`git commit` at all, so no evidence or receipt path is ever staged — consistent with `.gitignore:122` `.tad/evidence/` (confirmed live: `git check-ignore -v .tad/evidence/yolo` → `.gitignore:122`). Placeholders are distinct and never reused for two different values: `<COMMIT>` appears only as `observed_head`/`verified_head`, `<RUN_ID>` is stable across init/resume, `<SLICE_ID>` names the same slice throughout, and `<RECEIPT_SHA>`/`<RECEIPT_PATH>` are separate concepts.

## Q4

FAIL — two fabrications found, plus one terminology drift.

1. Verify output line (guide line 409): `VERIFIED: [<SLICE_ID>] (receipt .../<SLICE_ID>.json, sha256 <RECEIPT_SHA>)`. The CLI's status VERIFIED line is `  - ${v.slice}  (receipt ${v.receipt_path}, head ${v.verified_head})` (mjs:557) — it prints the receipt path and `head <verified_head>`, never a sha256. A receipt sha256 is emitted only in the journal event payload and in recovery.md's VERIFIED section (mjs:598), not in verify's stdout. The transcript swaps `head` for a field the source does not emit on that line, and also reformats the `- <slice>` bullet as `[<SLICE_ID>]`. As a rendering of "what a receipt-backed verify looks like", this line is inaccurate.

2. Guide lines 405-406: "The receipt's verified_head must equal the current HEAD (verify accepts verified_head == HEAD)." The source deliberately accepts `verified_head` equal to HEAD OR any ancestor of HEAD — "Accept the gated commit or any ancestor of the current HEAD; the delta is recorded in the journal rather than refused" (mjs:893-897, enforced at mjs:898-912, failing only via `receipt_head_not_ancestor`). "must equal" is a behavioral claim the source contradicts.

3. Minor: "Only a receipt can advance last_verified" (guide line 402) — `last_verified` appears nowhere in the source (grep of yolo-recovery.mjs: no match; the field set is `verified`/`verified_slices`, mjs:427-428). Intent is right; the term is invented.

Append-only is confirmed: `git show d52d4137 -- .tad/guides/yolo-recovery.md` = +64 insertions, 0 deletions, no rewording of prior sections; §12 is the final section and the file ends there.

verdict: FAIL

---

## Re-review (round 2)

Examined: current `.tad/guides/yolo-recovery.md` §12 (lines 369-432) and the fix commit `git show 8977be6e` (diff confined to the legend and the step-3 comment/verify line — append-only, no other text touched).

### Fix 1 — verify output line

PASS. Guide line 412 now reads `#   VERIFIED: - <SLICE_ID>  (receipt <RECEIPT_PATH>, head <GATED_HEAD>)`, which matches `renderStatus` verbatim: `  - ${v.slice}  (receipt ${v.receipt_path}, head ${v.verified_head})` (mjs:557). The sha256 fabrication is gone, the `- <slice>` bullet form is restored, and `head <verified_head>` is present with `<GATED_HEAD>` as its placeholder. The receipt path printed by status is the repo-relative path stored from `v.repoRelPath` (mjs:963, 1171), i.e. exactly what the operator passed via `--receipt` — so `<RECEIPT_PATH>` is accurate.

### Fix 2 — ancestor acceptance rule

PASS. Guide lines 406-409 now state: verify accepts `verified_head` if it "equals the current HEAD or is an ancestor of it (the delta is recorded in the journal); a commit that is neither fails with `receipt_head_not_ancestor`". This matches the source: exact-HEAD equality was relaxed to accept the gated commit or any ancestor (mjs:893-897), enforcement via `git merge-base --is-ancestor` with `receipt_head_not_ancestor` on failure (mjs:898-912, error raised at mjs:906), and the delta is recorded in the journal as `observed_head_at_verify` / `dirty_paths_at_verify` (mjs:1174-1177). `receipt_head_not_ancestor` is the exact reason string. The legend (lines 376-377) now defines `<GATED_HEAD>` as "the commit the Gate and reviewer passed (an ancestor of, or equal to, HEAD)", and every legend placeholder is used at least once; `<RECEIPT_SHA>` was removed from both legend and transcript.

### Surrounding transcript spot-check

No new defect. Init (lines 385-391), checkpoint journal line (396-400), verify JSON with `verified_slices` (414-415), and resume block (420-427) are unchanged from round 1 and still match the source (USAGE mjs:1426-1434; appendEvent mjs:720; finish() mjs:1399; cmdResume RECOVERY PACKET line mjs:1356 with budget 2500 = CAPSULE_TOKEN_BUDGET mjs:53). Still no `git add`/`git commit` anywhere; evidence paths remain gitignored (`.gitignore:122`). One residual imprecision: the resume block's `VERIFIED:   [<SLICE_ID>]` (line 422) remains a condensed rendering of the `- <slice> (receipt …, head …)` bullet — it elides details but adds no false field, and the section itself labels the block "the one-screen status above" (line 430), so I do not treat it as a fabrication. The round-1 "minor" item (`last_verified` terminology, line 403) is untouched but was not among the named defects.

verdict: PASS