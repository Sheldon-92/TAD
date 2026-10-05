# Spec Compliance Review — yolo2-phase1

Reviewer model: opencode-go/deepseek-v4-flash
date: 2026-08-25

Reviewed: handoff `HANDOFF-20260824-yolo2-phase1-recovery-slice.md` (§1, §3, §4, §6, §8, §9.1), `yolo-recovery.mjs`, `yolo-recovery.test.mjs`, `yolo-recovery.md`, and the phase1 evidence. All suite runs below were executed fresh by this reviewer; the archived run dirs were additionally cross-checked against the still-present live worktrees at `/private/tmp/tad-yolo2-p1/`.

## AC1 — PASS

The handoff's exact command produced empty stdout, exit 0: `git diff --name-only -- .claude/workflows .tad/hooks .agents/skills/alex/references/yolo-execution-protocol.md .tad/config.yaml` (nothing printed; `AC1-exit:0`). The wider scope diff from the frozen base `bfce27f3469960946679b03e2562ece67a34f0f3` (`.tad/evidence/.../phase1/base-commit.txt`) to HEAD touches exactly the §7 allowlist: `.tad/guides/yolo-recovery.md`, `.tad/scripts/yolo-recovery.mjs`, `.tad/scripts/yolo-recovery.test.mjs` (three lines, nothing else). No YOLO workflow, hook, protocol file, or config was modified in any commit.

## AC2 — PASS

Ran `node .tad/scripts/yolo-recovery.test.mjs` myself: all 8 deterministic contract cases pass — `CASE=path-guard PASS`, `CASE=lifecycle-e2e PASS`, `CASE=verified-authority PASS`, `CASE=authority-conflicts PASS`, `CASE=side-effect-reconcile PASS`, `CASE=status-capsule PASS`, `CASE=atomic-write PASS`, `CASE=binding-and-closure PASS` — plus `CASE=dogfood-evidence PASS`. Every negative fixture asserts a specific exit code AND a specific machine-readable reason via `expectRed` (test lines 49-52), so red states are real: e.g. `expectRed(cli([...]) , 2, 'path_escape', ...)` (line 174) and `1, 'receipt_not_json'` (line 250). The suite's final `RESULT=FAIL` comes solely from `CASE=required-evidence` (the AC10 items below); the 8 contract cases themselves are green with real red/green controls. `deterministic-fixtures.txt` records the same 8 PASSes at head `84c3666c…`.

## AC3 — PASS

Ran `--case verified-authority`: `RESULT=PASS`. Rejects (each with the specific reason and non-zero exit): a plain file (`receipt_not_json`), completion prose containing `completion_written=true` (`receipt_not_json`), a self-authored receipt (`receipt_self_authored`), a non-conductor author (`receipt_author_role_invalid`), wrong run/slice/handoff-revision/worktree/head/verdict (`receipt_run_mismatch`, `receipt_slice_mismatch`, `receipt_handoff_revision_mismatch`, `receipt_worktree_mismatch`, `receipt_head_not_ancestor`, `receipt_verdict_not_pass`), tampered gate evidence (`receipt_evidence_hash_mismatch`), deleted review evidence (`receipt_evidence_missing`), no independent reviewer, empty arrays, and re-verifying the same slice (`duplicate_verified_slice`). The single correctly bound receipt is accepted. Goal immutability is enforced: editing `goal.json` after init fails `status` with `goal_mutated` (test line 328). Code backing: `validateVerificationReceipt` (yolo-recovery.mjs:861) binds run/slice/revision/worktree/HEAD, verifies evidence existence + SHA-256 + PASS anchors + `written_by_id != executor_id`, and `loadRun` (line 732) fails on any goal hash change.

## AC4 — PASS

Ran `--case authority-conflicts`: `RESULT=PASS`. Sixteen fail-closed negatives: corrupt journal line, partial final JSONL line (the kill signature — never truncated), unknown event type, seq gap, stale forged `checkpoint.json` (`derived_state_conflict`, repaired only via explicit `--rebuild-derived` which cannot resurrect the forged verified claim), handoff revision drift, handoff deleted, worktree relocated (`worktree_identity_mismatch` while `status` still renders so the run can be closed), verified receipt deleted/edited after the fact (`verified_evidence_missing` / `verified_evidence_hash_mismatch`), event after stop, double init (`run_already_initialized`), base-commit mismatch, missing oracle, concurrent-writer duplicate seq, unknown command/missing flag. All exit non-zero with machine-readable reasons.

## AC5 — PASS

Ran `--case side-effect-reconcile`: `RESULT=PASS`. Structured hash args are mandatory (missing `--intended-post-sha256` → usage error); a wrong declared pre-state fails (`pre_state_mismatch`); a started-but-unreconciled action exits 1 `unreconciled_side_effect` — a script cannot march past a real-world change; a second concurrent action fails; `confirmed` requires the exact intended-post hash; an `outcome_unknown` lands the run in `HONEST_PARTIAL` and re-`action-start` of the same action id is `blind_retry_forbidden` (test line 542-544); checkpoint and verify are blocked while the outcome is unknown; the unknown outcome is closed only as `reconciled` with an evidence file and the real observed SHA (`unknown_outcome_needs_reconciled`, `observed_sha_mismatch`); after reconciliation the run is usable again. Code: `cmdActionStart` checks `forbidden_retry_actions` before anything else (yolo-recovery.mjs:1195).

## AC6 — FAIL

The checker itself passes (`--case dogfood-evidence RESULT=PASS`, including 23 negative controls and the real `recovery-scores.json`), and the index-level facts are right: exact IDs/stages, unique run dirs and worktrees, hard 8/8 for all three, raw assertion/oracle/continuation/gate/receipt/envelope files hash-match. However, the shipped raw evidence contradicts its own index for two of the four runs:

- `dogfood/control/run/journal.jsonl` seq 1: `"observed_head":"323c380dbb02…","base_commit":"323c380dbb02…"` with `at: 2026-08-24T22:27:57Z` — the **v1 attempt** — while `control.md`, `control-evidence.json` and `recovery-scores.json` all declare base `84c3666c…`. The live `wt-control` worktree goal.json/journal (still present at `/private/tmp/tad-yolo2-p1`) record base `84c3666c…` with a 7-event ledger.
- `dogfood/interruption-a/run/journal.jsonl` seq 1: `"base_commit":"0ccd30cdf25d…"` (v3 attempt, `2026-08-25T18:33:34Z`); its seq 3 `verified` event records receipt sha `230812a5…` at head `1738310c…`, while `interruption-a.md` states "S1: `c35dc975` — verified with bound Conductor receipt", the index records receipt `132c5fe5…`, and the packaged `interruption-a/receipt.json` binds `c35dc975…` with a different review hash. The archived journal is byte-identical to the v3 attempt's (`dogfood-v3-base-0ccd30cd/dogfood/interruption-a/run/`), not to the live final run.
- All four archived journals reference `…/dogfood/conductor/receipt-S*.json`, `gate-S*.txt`, `review-S*.md`; the `conductor/` directory does not exist in the shipped evidence folder (it exists only in the live worktrees).

So the raw-file linkage §4.3 requires ("每条原始 evidence 必须存在、hash 匹配并链接到对应 interruption report") and the "control parity / same base" claim hold only at index level; the archives prove otherwise. The checker never reads archived run-dir contents (it only existence-checks `run_dir/goal.json|journal.jsonl`, test lines 873-879), so this contradiction passes it. The live worktrees show the four runs themselves were genuine and consistent at base `84c3666c…` — this is an evidence-packaging defect (stale run dirs archived for control and interruption-a), not fabricated dogfood.

## AC7 — PASS

All three treatments score soft 1.0 ≥ 0.90 with hard 8/8. Each `run-evidence.json` review block binds the assertion and oracle by SHA-256 (`assertion_sha256`/`oracle_sha256` equal the index hashes, e.g. interruption-a: `f4d4dd15…` / `78b47cee…`), marks `independent: true`, and the reviewer `author_id` differs from the assertion author; the checker's negative controls (self-scoring reviewer, review not bound to oracle, soft below floor, hard below 100%) all turn red. Packaged `review.md` files hash-match the index.

## AC8 — FAIL

Index-level claims verify: control present with same declared base+input, continuation files present, hidden acceptance PASS (13/13 for interruption-a), gate verdict PASS with a `PASS` anchor, receipts parse as conductor-written PASS with `written_by_id != executor_id`, `repeated_verified_slice = 0`, `wrong_or_unauthorized_next_action = 0`, `continued: true`. But at the raw level: the archived control run started from `323c380d…` and archived interruption-a from `0ccd30cd…` — not the same frozen commit as each other or as b/c/control (whose archives match their live runs at `84c3666c…`). "Receipt hashes valid" fails for interruption-a at raw level: the journal's recorded receipt (`230812a5…`) is not the packaged receipt (`132c5fe5…`) and does not exist anywhere in the package. Secondary observation: the recovery sessions ran on opencode (every `fresh-prompt.txt` instructs `Model: harness=opencode`, and `interruption-a/gate.md` opens "Reviewer model: opencode-go/deepseek-v4-flash"), i.e. not the handoff's chosen Claude-Code reference harness (§2.2, §1.2 success picture) — the recovery chain itself still demonstrably worked.

## AC9 — PASS

Ran `--case status-capsule`: `RESULT=PASS`. All ten required labels (GOAL, HANDOFF REVISION, VERIFIED, UNVERIFIED, BLOCKED, OUTCOME_UNKNOWN, PENDING ACTION, LEGAL NEXT ACTION, OWNER, RESUME COMMAND) appear in both `status` output and `recovery.md`; the packet carries NON-GOALS, FORBIDDEN SCOPE, VERIFICATION MODEL and PROHIBITIONS; `capsule_tokens ≤ 2500`. Over-budget behavior is a real red state: a ~400-criterion goal makes `init` fail `capsule_over_budget` with a per-section composition report, leaves no half-written run, and the over-budget packet still contains every hard anchor (never trimmed). Real packets re-measured with the shipped estimator: control 765, interruption-a 912, interruption-b 986, interruption-c 928 est. tokens — all ≤ 2500 (`capsule-budget.md` records similar margins: 689/628/736/629).

## AC10 — FAIL

The checker's scope rule itself is sound: `base-commit.txt` holds a valid 40-hex sha (`bfce27f3…`); `git diff --name-only bfce27f3…..HEAD` returns exactly the three allowlisted files (verified by direct run); out-of-scope negatives (`.claude/workflows/yolo-epic.workflow.js`, `.tad/hooks/precompact-session-snapshot.sh`) are reported. But the required-evidence check is red: at review time the missing/empty set is `spec-compliance.md` (this report, being written now), `gate3-verdict.md` and `COMPLETION-…md` (both declared as pending-after-review), and **`knowledge-assessment.md`** (§6.2 `knowledge_updates`), which is NOT in the pending set and does not exist anywhere in `.tad/` (`find` returns nothing). `deterministic-fixtures.txt` (2026-08-25T20:13Z) records this same red state, honestly. Per the review instruction (only COMPLETION and gate3-verdict exempt), the missing `knowledge-assessment.md` is a genuine gap.

## FR1 — PASS
`init` is atomic and fail-on-exists: `run_already_initialized` (yolo-recovery.mjs:1004), transactional rollback of a half-written run (lines 1092-1099), base-commit equality proof (line 1021), frozen oracle must exist (line 1024).

## FR2 — PASS
`EVENT_TYPES` is exactly the six allowed types (yolo-recovery.mjs:41-48); unknown types, seq gaps, blank lines and a half-written final line all fail closed in `readJournal` (lines 262-294).

## FR3 — PASS
Only `verify` with a bound Conductor PASS receipt advances `verified` (`validateVerificationReceipt`, yolo-recovery.mjs:861); plain files, completion prose, self-authored or mismatched receipts are rejected (AC3); already-verified slices are re-checked against live receipt existence/hash/binding on every load (lines 777-797).

## FR4 — PASS
`resume` derives checkpoint + recovery packet purely from `goal.json` + `journal.jsonl` via the pure reducer; the code never reads session-state, chat history or compact summaries; a derived file that disagrees is never silently overwritten (`derived_state_conflict`, explicit `--rebuild-derived`).

## FR5 — PASS
Corruption, journal/checkpoint conflict, missing evidence, handoff drift and unresolved side effects all return `HONEST_PARTIAL` with non-zero exit and named blocker codes (AC4/AC5, `finish()` lines 1386-1404).

## FR6 — PASS
`action_started` can only land in `confirmed | outcome_unknown | reconciled`; `outcome_unknown` adds the action id to `forbidden_retry` (yolo-recovery.mjs:381-387) so any re-`action-start` with the same id is `blind_retry_forbidden`; unknown outcomes close only via explicit evidence + real observed SHA as `reconciled`.

## FR7 — PASS
`renderStatus` prints a one-screen summary with all ten labels, verified/unverified separation, blockers, pending action, legal next action + why, owner and exact resume command (verified by AC9).

## FR8 — PASS
`stop --reason` records the reason, sets `HONEST_PARTIAL`, exits 1, and no further event may be recorded (`event_after_stop`); unverified work is never upgraded to completed.

## FR9 — PASS
Guide §4-6 mandate fresh-context-with-run-path-only, assertion before review, reviewer-before-continue, oracle sealed before the run; the dogfood sequence (prompt → assertion → independent review 8/8 → continuation) implements exactly this, and the packaged assertion/review files match the live runs byte-for-byte.

## FR10 — PASS (with the AC6/AC8 evidence caveat)
The four real runs exist in isolated, unique worktrees (`wt-control`, `wt-interruption-a/b/c`) started from the same frozen commit `84c3666c…` (live goal.json files) and the same input (`input_sha256 1ab2d799…` = sha256 of `task.md`, re-computed and matched), with control uninterrupted and treatments interrupted at the three prescribed stages. However, the shipped raw archives for control and interruption-a are stale copies from earlier attempts (bases `323c380d…`/`0ccd30cd…`), and the recovery harness was opencode rather than the handoff's Claude-Code reference — the runs satisfy FR10, the packaged evidence does not (see AC6/AC8).

## Overall

**verdict: FAIL** — AC6, AC8, AC10 fail; every other AC and FR is verified.

FAIL items, in order of severity:

1. **AC6/AC8 (evidence integrity):** the shipped `dogfood/control/run/*` and `dogfood/interruption-a/run/*` archives are stale copies from the v1 (base `323c380d…`, 2026-08-24) and v3 (base `0ccd30cd…`) attempts and contradict the index/envelopes/reports, which describe the real final runs at base `84c3666c…` (still verifiable in the live worktrees). The journal-referenced `dogfood/conductor/*` receipts/gates/reviews are absent from the package. The `dogfood-evidence` checker does not read archived run-dir contents and therefore cannot detect raw-vs-index base or receipt disagreement. Remediation: re-archive control/run and interruption-a/run (and the conductor evidence) from the live worktrees, and strengthen `checkDogfoodEvidence` to cross-validate the archived goal.json base_commit and journal receipt hashes against the index.
2. **AC10 (manifest):** `knowledge-assessment.md` (§6.2) is missing and not in the pending-after-review set; `gate3-verdict.md` and `COMPLETION` are pending by design; this report is being written now.
3. **Deviation (secondary):** recovery and review sessions ran on opencode (`harness=opencode` in every fresh prompt; gate.md "Reviewer model: opencode-go/deepseek-v4-flash"), not the handoff's declared Claude-Code reference harness (§2.2 / §1.2).

---

## Re-review (round 2)

Reviewer model: opencode-go/deepseek-v4-flash
date: 2026-08-25

Re-ran the full suite and re-inspected the repackaged evidence. Both FAIL items are resolved:

1. **AC6/AC8 (stale raw archives) — FIXED, verified:**
   - `node .tad/scripts/yolo-recovery.test.mjs` now reports `CASE=dogfood-evidence RESULT=PASS` (and all 8 contract cases PASS); the only remaining `required-evidence` gap is exactly the two completion-flow files (see item 2 below).
   - Every archived run now records base `84c3666c…` at seq 1: `dogfood/control/run/journal.jsonl` (`"base_commit":"84c3666c4b8d658ecfd737c5305728f0e2152aea"`, `2026-08-25T19:17:46Z`), `dogfood/interruption-a/run/journal.jsonl` (`84c3666c…`, `19:17:47Z`), b and c likewise; all four `run/goal.json` `base_commit` fields equal `84c3666c…` and match the index/envelopes/reports.
   - `diff -r` confirms `dogfood/control/run` and `dogfood/interruption-a/run` are now **byte-identical** to the live worktrees at `/private/tmp/tad-yolo2-p1/` (`A-RUN-IDENTICAL`, `CONTROL-RUN-IDENTICAL`); b/c were already identical.
   - The conductor evidence is packaged per run: `dogfood/{control,interruption-a,interruption-b,interruption-c}-conductor/` with the correct `gate-S*.txt` / `review-S*.md` / `receipt-S*.json` sets, and `interruption-a-conductor/receipt-S1.json` is byte-identical to the live conductor receipt (`RECEIPT-IDENTICAL`).
   - Residual note (non-blocking): the archived journals still record receipt paths as `…/dogfood/conductor/receipt-S*.json` (the path recorded in the live worktrees), while the package names the dirs `{run}-conductor/`; the receipt content itself is present and hash-identical, so the evidence is now internally consistent — only the path label differs.

2. **AC10 (knowledge-assessment.md) — FIXED, verified:**
   - `knowledge-assessment.md` exists at `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/` (3143 bytes, non-empty) and references real entries: three mechanism gaps discovered by the actual dogfood (B1: missing VERIFICATION MODEL at interruption-c, fixed by commit `00570c00`; B2: missing state-derived PROHIBITIONS at interruption-a, fixed by `0ccd30cd`; B3: side-effect classification rule, fixed by `84c3666c`) with observed soft-score evidence (0.88 → 1.00) and the rule "机制必须由观测到的失败购买".
   - The suite's `required-evidence` case now reports only `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/gate3-verdict.md` and `.tad/active/handoffs/COMPLETION-20260824-yolo2-phase1-recovery-slice.md` as missing — both are the files the completion flow writes **after** this review, per plan. `spec-compliance.md` (this file) now exists too.

The round-1 secondary deviation (recovery harness was opencode rather than Claude Code) stands as recorded — it did not drive the round-1 FAIL and does not affect this verdict.

## Overall (round 2)

**verdict: PASS** — every AC (1-10) and FR (1-10) is verified. The only pending items are the two evidence files the completion flow writes after this review: `gate3-verdict.md` and `COMPLETION-20260824-yolo2-phase1-recovery-slice.md`; once they exist and are non-empty, the `required-evidence` case will go fully green (the deterministic-fixtures.txt records the same expected final state).