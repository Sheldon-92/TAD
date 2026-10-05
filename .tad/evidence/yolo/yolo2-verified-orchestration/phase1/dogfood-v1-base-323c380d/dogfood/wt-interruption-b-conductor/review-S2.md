# Independent slice review (round 2) — interruption-b — S2

Reviewer model: claude-opus-5
Scope of review: `git diff 3baa842e..HEAD` (commit `e4bf041f`, 24 insertions / 14 deletions,
one file) against `.tad/scripts/yolo-recovery.mjs` **in this worktree**
(`/private/tmp/tad-yolo2-p1/wt-interruption-b`, 1200 lines). All line numbers below refer to that
file; all guide line numbers refer to the post-fix `.tad/guides/yolo-recovery.md`.

## Round-1 findings

**F1 — fabricated `result` value `CONTRACT_FAIL` — CLOSED.**
The literal is gone (`grep -n CONTRACT_FAIL .tad/scripts/yolo-recovery.mjs` → no match;
`grep -n CONTRACT_FAIL .tad/guides/yolo-recovery.md` → no match). The replacement text (guide
L360-L362) reads: "`result` has exactly three possible values: `PASS`, `USAGE_ERROR` (exit `2`) and
`HONEST_PARTIAL` (exit `1`). There is no separate "contract failure" value — a contract failure
reports `result: "HONEST_PARTIAL"` like any other." That is exactly the source: the only three
`result:` emission sites are L1114 (`honest ? 'HONEST_PARTIAL' : 'PASS'`, exit `honest ? 1 : 0`),
L1134 (`usage ? 'USAGE_ERROR' : 'HONEST_PARTIAL'`, exit `usage ? 2 : 1`) and L1169
(`'USAGE_ERROR'`, exit 2). The exit-code pairings in the new sentence are correct at both sites.

**F2 — wrong command attribution on `capsule_over_budget` — CLOSED.**
New text (guide L406): "Raised by every command that rewrites the derived files — `init`,
`checkpoint`, `verify`, `action-start`, `reconcile`, `resume`, `stop`. `status` can **not** raise it:
it hands `finish` a `null` packet and never writes `recovery.md`." Verified exhaustively against the
eight `finish(` call sites: `init` L852, `checkpoint` L900, `verify` L927, `action-start` L966,
`reconcile` L1054, `resume` L1082, `stop` L1093 all pass the `packet` returned by `writeDerived`;
`cmdStatus` L881 passes literal `null`, and `cmdStatus` (L871-L882) contains no `writeDerived` call.
The guard is `if (packet && packet.tokens > CAPSULE_TOKEN_BUDGET)` (L1099), so the seven-command list
is complete and the `status` exclusion is stated with the right mechanism.

## New verification

The fix rewrote 24 lines, so I re-derived the following independently. Rows 1-5 were **not**
verified by the round-1 reviewer (it checked only the budget number `2500` on the
`capsule_over_budget` row and the field list on the `init` row).

1. **`concurrent_writer_detected` (guide L386) — NEW claim, TRUE.** "Only the six commands that
   write a journal event can raise it — `init`, `checkpoint`, `verify`, `action-start`, `reconcile`,
   `stop`; `status` and `resume` never append." The throw is inside `appendEvent` (L599-L607). Its
   call sites are exactly six: L847 (`init`), L896 (`checkpoint`), L914 (`verify`), L956
   (`action-start`), L1050 (`reconcile`), L1089 (`stop`). `cmdStatus` and `cmdResume` contain none.
   Details `{expected_events, found_events}` match L606.

2. **`run_in_honest_partial` (guide L387) — NEW claim, TRUE.** "the three work commands — and only
   those three — refuse: `checkpoint`, `verify`, `action-start`. `reconcile` is deliberately exempt
   … and `status` / `resume` / `stop` always run." `refuseIfHonestPartial` is called at exactly three
   sites: L886 (`'checkpoint'`), L905 (`'verify'`), L939 (`'action-start'`). `cmdReconcile`,
   `cmdStatus`, `cmdResume`, `cmdStop` never call it. The signal column ("`details.command` naming
   which of the three you tried, `details.blockers`, `details.required` = the one legal next action")
   matches L863-L869 byte-for-byte in shape: `{ command, blockers: state.blockers, required:
   state.legal_next_action.action }`.

3. **`path_escape` label set (guide L376) — NEW, exhaustive and exact.** The row now lists
   `run_dir`, `--handoff`, `--goal-file`, `--target`, `--receipt`, `--evidence`, `oracle_path`, and
   `gate_evidence.path` / `review_evidence.path`. `assertInside` (L142) is reached from exactly two
   places — `resolveRunDir` L178 (`'run_dir'`) and `resolveInRepo` L185, whose eight call sites carry
   labels `'--receipt'` (L691), `` `${label}.path` `` → `gate_evidence.path` / `review_evidence.path`
   (L744 + L757-L758), `'--handoff'` (L799), `'--goal-file'` (L800), `'oracle_path'` (L822),
   `'--target'` (L948), `'--evidence'` (L991, L1035). The guide's set is complete with no extras.
   `UsageError` ⇒ exit `2` as claimed; confirmed live: `status --run /etc` →
   `{"result":"USAGE_ERROR","reason":"path_escape","details":{"label":"run_dir",…}}`.

4. **`init`-freeze row exit-code split (guide L380) — NEW claim, TRUE.** "Two are usage errors (exit
   `2`): `goal_file_not_json` … and `goal_file_field_missing`." Source: L812 `throw new
   UsageError('goal_file_not_json', { message: String(err.message).slice(0, 200) })` — a truncated
   parse `message` and no path, exactly as the row now says; L816 `throw new
   UsageError('goal_file_field_missing', { field: key })`. "The rest are contract failures (exit
   `1`)": `base_commit_mismatch` L820 `{declared, head}`, `oracle_missing` L823 `{path}`,
   `goal_file_missing` L806 `{path}`, `handoff_missing` L805 `{path}` — all `ContractError`. Correct
   on every one.

5. **`receipt_evidence_*` detail shapes (guide L404) — NEW claim, TRUE on all four.** "always
   `field` (`gate_evidence` or `review_evidence`)": both `checkEvidence` invocations pass those two
   literals (L757-L758) and every throw in the closure carries `field: label`.
   `receipt_evidence_empty` L736 `{field}` only ✓; `receipt_evidence_malformed` L741 `{field, entry:
   e}` — the whole entry object, not a path ✓; `receipt_evidence_missing` L746 `{field, path}` ✓;
   `receipt_evidence_hash_mismatch` L750 `{field, path, declared, actual}` ✓.

6. **`receipt_*_mismatch` / `duplicate_verified_slice` row (guide L403) — TRUE.** `got`/`want` pairs
   at L713 (`run`), L714 (`slice`), L716 (`handoff_revision`), L719 (`worktree`);
   `receipt_head_mismatch` L722 is the one carrying `{got, current_head}`; `duplicate_verified_slice`
   in the `verify` path is L731 `{ slice }` — "carries only the `slice`" ✓.

7. **Preamble paragraph 2 (guide L367-L372) — NEW, TRUE.** "`reason` is the first blocker code —
   `stopped` or `outcome_unknown`, falling back to the literal `honest_partial`": L1119
   `reason: honest ? (state.blockers[0] ? state.blockers[0].code : 'honest_partial') : null`, and the
   only two `blockers.push` sites are L374 (`code: 'stopped'`) and L376 (`code: 'outcome_unknown'`).
   "never one of the strings in the table below" — checked: neither `stopped`, `outcome_unknown` nor
   `honest_partial` appears as a reason literal in any of the 34 rows. "a `1` from … `reconcile
   --outcome outcome_unknown`" — L346-L352 pushes the action onto `unknownActions`, L378-L379 sets
   `state = 'HONEST_PARTIAL'`, so `finish` (L1054 → L1112) returns exit `1` ✓. Saying "Two `reason`
   values" is right rather than three: `HONEST_PARTIAL` is entered only via `stopped ||
   unknownActions.length > 0`, both of which push a blocker, so the `'honest_partial'` fallback is
   unreachable.

8. **Error-line field absence (guide L363-L365) — TRUE.** `errorResult` (L1126-L1139) emits
   `run_dir: null` and simply has no `verified_slices` / `legal_next_action` keys. Confirmed live on
   three invocations, e.g. `bogus` →
   `{…,"result":"USAGE_ERROR","run_dir":null,"state":"USAGE_ERROR","reason":"unknown_command",…}`
   with neither field present.

**Pipe-count / rendering check.** Guide L374-L409 is the table: 36 lines, all 36 begin with `|`, all
36 end with `|`, and every one of the 36 contains exactly 5 `|` characters (header + delimiter + 34
data rows) — i.e. every row renders as exactly 4 columns. No cell contains an unescaped interior
pipe. Command:
`awk 'NR>=374&&NR<=409{n=gsub(/\|/,"|"); if(n!=5) print NR" pipes="n}'` → no output.

**New false claims found:** none. Three wording nits, none rising to a false statement about the
CLI, none load-bearing:
- L403 "the four `receipt_*_mismatch` reasons each carry `got` vs `want`, except
  `receipt_head_mismatch`" — the family listed in column 1 has five `*_mismatch` members, so "four …
  except X" is loose phrasing; but the count 4 is exactly right for the `got`/`want` carriers and
  every detail shape asserted is correct, so no reader is misinformed about any field.
- L363 "On that error line `run_dir` is `null`" holds for every reason routed through `errorResult`
  (all table reasons). The one hand-built line, `no_command` (L1169), omits `run_dir` entirely rather
  than nulling it. In context the sentence is describing the contract-failure line it just
  introduced, so I do not count it.
- L365 "re-run `status` or `resume` to get them back" is good advice for command-level failures but
  will not help for the load-time refusals (`worktree_identity_mismatch`, `handoff_revision_drift`,
  `goal_mutated`), where `status` fails identically. Guidance, not a claim about emitted values.

## Round-1 "lesser imprecisions"

All four were addressed by this fix; none should now be counted.
1. *`init` row said "the rest carry `path` or `field`" but `goal_file_not_json` carries only
   `message`* — **addressed**: the row now says it "carries a truncated parse `message` rather than a
   path" (guide L380), matching L812.
2. *receipt-binding row said "each carries `got` vs `want`" but `duplicate_verified_slice` carries
   `{slice}`* — **addressed**: "`duplicate_verified_slice` carries only the `slice`" (L403), matching
   L731.
3. *evidence-pointer row said `receipt_evidence_malformed` gives the entry's `path`* — **addressed**:
   "carries the offending `entry` object rather than a path" (L404), matching L741.
4. *"`init`-time work commands" was an odd label for the three `refuseIfHonestPartial` callers* —
   **addressed**: rewritten to "the three work commands — and only those three — refuse:
   `checkpoint`, `verify`, `action-start`", plus an explicit note that `reconcile` is exempt (L387),
   matching L886/L905/L939.

## Scope

`git diff --name-only 3baa842e..HEAD` → `.tad/guides/yolo-recovery.md` only. No change to
`.tad/scripts/yolo-recovery.mjs` or any other file. Hunk headers place every changed line in the new
file at L359-L372, L376, L380-L383, L386-L387, L403-L404, L406. `## 11. Troubleshooting` spans
L354-L412 (`## 10. Command Reference` L314, `## 12. Worked Example` L413), so all 24 inserted and 14
deleted lines fall strictly inside S2. S1 (`## 10.`), S3 (`## 12.`) and every pre-existing section are
byte-identical.

independent: true
verdict: PASS
