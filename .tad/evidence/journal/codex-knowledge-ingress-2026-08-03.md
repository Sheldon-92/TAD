# Codex knowledge ingress — implementation journal

Date: 2026-08-03
Handoff: HANDOFF-20260803-codex-knowledge-ingress.md

## New discoveries

- Codex CLI v0.146.0 could not reach an authenticated turn in the isolated
  workspace-write scratch probe; therefore hook delivery and PreCompact fire
  remain unmeasured. The safe reusable pattern is to preserve an explicit empty
  signal/envelope shape and label the runtime ledger partial rather than infer
  fields from documentation.
- The pre-gate arithmetic pattern `grep -c ... || echo 0` can emit `0\n0`
  under a no-match path. Normalizing the count with `|| true` and an explicit
  empty-to-zero guard prevents a valid Completion from becoming a false BLOCK.
- AC4's immutable baseline must remain pinned to the pre-edit commit after the
  implementation commit; the comparison script now reads the recorded baseline
  SHA rather than silently using the moving `HEAD`.

## Reusable implication

Hook consumers should receive a single self-contained, TTY-safe normalized
envelope. Platform-specific fields remain empty unless an authenticated probe
measures them; fixtures prove parser behavior, not runtime delivery.
