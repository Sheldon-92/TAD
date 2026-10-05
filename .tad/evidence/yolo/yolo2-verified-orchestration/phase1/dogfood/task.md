# Guide Maintenance Task — yolo-recovery reference guide

**Target file (the ONLY file you may modify):** `.tad/guides/yolo-recovery.md`
inside YOUR worktree.

The guide currently explains the flow but has no quick reference material.
Add three sections, in this order, appended at the END of the file, without
changing, reordering or deleting any existing text.

## Slice S1 — Command Reference

Add a section headed exactly `## 10. Command Reference`.

It must contain a markdown table with **one row per CLI command**, with columns:
command | required flags | optional flags | exit codes it can produce.

Derive every row by reading `.tad/scripts/yolo-recovery.mjs` in this worktree.
Do not guess flags or exit codes.

## Slice S2 — Troubleshooting

Add a section headed exactly `## 11. Troubleshooting`.

It must contain a markdown table with columns:
failure reason | symptom | signal you see | remedy.

Use the *exact* machine-readable reason strings the CLI can emit (they appear in
`.tad/scripts/yolo-recovery.mjs`). Cover the failure modes an operator is most
likely to hit. Do not invent reason strings that the source does not contain.

## Slice S3 — Worked Example

Add a section headed exactly `## 12. Worked Example`.

A copy-pasteable shell transcript of one minimal run, from `init` through
`resume`, using clearly-marked placeholder paths. Show what a checkpoint looks
like, what a receipt-backed verify looks like, and what `resume` prints back.

## Constraints

- Only `.tad/guides/yolo-recovery.md` may be modified.
- Do NOT modify `.tad/scripts/**`, `.claude/**`, `.tad/hooks/**`, `.agents/**`,
  or any config, workflow or lockfile.
- Do NOT delete or reword existing guide content.
- Keep all markdown code fences balanced.
