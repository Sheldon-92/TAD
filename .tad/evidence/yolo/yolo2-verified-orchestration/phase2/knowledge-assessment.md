# Knowledge Assessment - YOLO2 Phase 2

**Task:** `TASK-20260827-YOLO2-P2-COMPLETION`
**Date:** 2026-08-29

## Answers

1. **Did a fresh executor miss the same anchor twice with knowable input?** No. The final run's assertion rubric reached 8/8 and >=0.90; earlier false failures were caused by runner message truncation, which was fixed and rerun.
2. **Did the Supervisor choose a locally valid but globally incoherent slice?** Yes, during the first driver design. The dogfood driver initially modeled two slices under one success criterion; Codex correctly rejected S2 as scope drift. The driver was corrected to freeze one success criterion per slice and the full set was rerun.
3. **Did a deterministic check pass while hidden acceptance failed?** Yes, the initial hidden oracle had unsupported `mention`, `preserved`, `assert.equal`, and `result for []` phrasings. Correct executions were initially reported false. The oracle was completed and the full frozen set was rerun.
4. **Did budget/accounting or re-entry state need information absent from the packet?** Yes. Codex `exec resume` has no `--sandbox` option and requires a config override; runner cwd also had to be the repository root for target writes. These are now bound in runner records and run manifests.
5. **Is the finding novel relative to existing knowledge?** Yes. The raw-native-event versus synthetic-tool-policy mismatch is recorded in `.tad/project-knowledge/security.md` as `Native Tool Boundary Requires Raw-Event Enforcement - 2026-08-27`.

6. **Did final validation reveal a new implementation/process finding?** Yes. The AC-B proof is intentionally anchored to `96bbfada..HEAD`; a valid parallel local-wiki commit on the shared branch therefore becomes an honest YOLO2 scope failure even though it is unrelated to the product files. This is recorded in `.tad/evidence/journal/yolo2-phase2-completion-2026-08-29.md`.

## Gate Impact

The knowledge entries are complete. They do not waive the failed AC-B scope proof or the resulting Group-0/Layer-2 block.
