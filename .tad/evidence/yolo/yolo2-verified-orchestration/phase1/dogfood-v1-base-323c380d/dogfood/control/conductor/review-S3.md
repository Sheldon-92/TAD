# Independent slice review — control — S3 (`## 12. Worked Example`)
Reviewer model: claude-opus-5

## Q1 — Does the section meet its slice spec in substance?

Yes. `.tad/guides/yolo-recovery.md:459-683` is a six-step transcript (12.1 freeze → 12.2 `init` →
12.3 work + `checkpoint` → 12.4 Conductor receipt → 12.5 `verify` → 12.6 interruption + `resume`),
covering the full `init`-through-`resume` arc the spec demands, and it explicitly shows all three
required artefacts: what a checkpoint looks like (the `UNVERIFIED: - S1 (checkpoint candidate,
reason=candidate, next="...")` line plus the CANDIDATE-only legal-next-action), what a
receipt-backed verify looks like (the full 12-field receipt JSON plus the resulting VERIFIED line
and status JSON), and what `resume` prints back (full status block, `RECOVERY PACKET:` line, status
JSON). Placeholders are consistently marked `<LIKE_THIS>` and enumerated up front, and all six code
fences are balanced (12 fence markers in the appended region, 24 file-wide). I verified this is a
real transcript and not a plausible-looking mock-up by replaying it end to end.

## Q2 — Is every technical claim actually true against the CLI source?

Yes. I cloned the worktree into a scratch directory (the worktree itself was never written to) and
executed the example verbatim, substituting placeholders. (1) `init` with the guide's `goal-spec.json`
shape succeeded at exit 0 and reproduced the §12.2 status block line for line — banner, `RUN:/STATE:`,
`GOAL:`, `HANDOFF REVISION: <path> @ sha256 <sha>`, the `(base X → latest observed X)` form, the
`working tree observation: 0 uncommitted path(s) — observation only, never authority` line, and
`LEGAL NEXT ACTION: Start slice S1: ...` with the exact `WHY:` string from `deriveLegalNextAction`
(`yolo-recovery.mjs:` slice branch) and `OWNER: executor`. (2) `checkpoint --reason candidate`
reproduced §12.3's UNVERIFIED line and the exact CANDIDATE-only next-action/`OWNER: conductor`
strings. (3) The §12.4 receipt is exactly the 12 keys of `RECEIPT_REQUIRED` (`:679-683`) — I pasted
it with real hashes and `verify` accepted it at exit 0, reproducing §12.5's VERIFIED line and a
status JSON whose key order (`format,command,result,run_dir,state,reason,verified_slices,
unverified_slices,blockers,legal_next_action,capsule_tokens`) matches the guide's line exactly.
(4) `resume` reproduced §12.6 including the `RECOVERY PACKET: <...>/recovery.md (<N> est. tokens,
budget 2500)` line, and the claim that this line is the only output `resume` adds over `status` is
correct (`cmdResume` `:1085-1087`; `cmdStatus` passes a null packet `:881`). (5) Supporting prose
claims check out: `<CONDUCTOR_ID>` must differ from `<EXECUTOR_ID>` (`receipt_self_authored`
`:727-729`), nothing may be committed between capturing `<VERIFIED_HEAD>` and `verify`
(`receipt_head_mismatch` `:721-723`), the run dir must live under `.tad/evidence/yolo/`
(`RUN_ROOT_REL` `:52`, `resolveRunDir` `:174-180`), `git rev-parse HEAD` must equal `<BASE_COMMIT>`
or `init` refuses (`base_commit_mismatch` `:820-822`), and the `derived_state_conflict` →
`resume --rebuild-derived` repair matches `:1069-1075`. One fidelity defect: §12.2's `init`
transcript ends at the closing banner and jumps to `$ echo $?` without showing the trailing
single-line status JSON, which the real run does emit and which §9 and §11 both assert is always the
last line (§12.3 elides with `...`, §12.5/12.6 show it in full). Cosmetic omission in displayed
output only — every command line, flag and file shown is correct.

## Q3 — Is anything fabricated?

No. Every command line in the transcript executed successfully as written; every JSON field name in
the goal-spec and the receipt exists in the source (`GOAL_REQUIRED` field checks at `:812-817` for
the goal file, `RECEIPT_REQUIRED` `:679-683` for the receipt, `slices[].id/.statement` consumed in
`deriveLegalNextAction`); the two rendered status JSON lines match real output byte-for-byte modulo
placeholders; no invented flag, reason string or exit code appears. `shasum -a 256` and `git
rev-parse HEAD` are real host commands, not tool subcommands.

## Q4 — Was any pre-existing guide content deleted or reworded?

No. `git diff 323c380..HEAD` = `1 file changed, 373 insertions(+)`, one append hunk
`@@ -308,3 +308,376 @@`, zero deleted lines, no second file. I also confirmed the pre-frozen
`action-b.md` one-line patch was NOT applied in this control run — the line "Runtime: Node
built-ins only, no npm packages, no lockfile change." is unchanged, as it should be for `control`.

independent: true
verdict: PASS
