# SOURCE-MAP (private — never committed, never exported)

Frozen: 2026-09-08 by Blake P1 build. Canonical source root:
`/home/box/云同步` (== `realpath(dirname(REPO_ROOT))`; the handoff author's
`/Users/sheldonzhao/云同步` is the same cloud-sync root on a different host).

Live hashes are pinned in `manifests/sources.json`. `verify-sources`
recomputes path / mode / SHA256 and FAILs (exit 1) on any content or identity
mismatch without rewriting the baseline; a missing file or bad argument exits
2. Symlinks are never followed. Full text is never printed.

## Per-source records

### date —
- frozen sha256 `607b29297f2c524f1448b2b84f9bc42026543df4573e1b83d1f8feba1f61f475` (cited for verify-sources对照; full text never printed) agent-workshop/.tad/evidence/reviews/alex-acceptance.md
- sha256 `607b2929…f475`, mode 644, regular file, no symlink.
- read_status: hash-only. The harness refused content display for this path,
  so no paragraph is excerpted here; the decision moment below comes from the
  handoff §6.1 contract (in-repo, allowed): first-round date-validity
  implementation and acceptance, illegal date not yet flagged.
- reconstruction: reconstructed. Assumption: pre-state project files were not
  provided; the case input is a minimal synthetic delivery-date record.

### rename —
- frozen sha256 `8992fe3d19cc7691251e95f28d58daf9d1ba70ba55c83287c1a39e7db445b7c9` (cited for verify-sources对照; full text never printed) 买卖/.tad/evidence/journal/site-rebrand-express-2026-08-20.md
- sha256 `8992fe3d…445b7c9`, mode 644, regular file, no symlink.
- read_status: read (pp. §§1–2, minimal paraphrase, no business data copied).
  Decision moment: before the brand/SKU update, the old persisted state still
  exists — storage key plus SKU prefix — and must be migrated, never silently
  dropped. Supporting facts: (a) cleanup has three layers and the
  abbreviation/prefix layer doubles as persistence keys; (b) grep-count
  assertions can be satisfied by comments, so effect needs runtime proof.
- reconstruction: reconstructed. Assumption: original shop code not provided;
  synthetic shop is created, minimal, fictional.

### evidence —
- frozen sha256 `2fc3e41c8ca1ac391c1790f86857ea657e4f51085add190040f9970377789b5b` (cited for verify-sources对照; full text never printed) Terminal-Mission-Control/.tad/evidence/gates/20260901-phase7-gate4-r3.md
- sha256 `2fc3e41c…7789b5b`, mode 644, regular file, no symlink.
- read_status: hash-only (same harness refusal; no excerpt). Decision moment
  from handoff §6.1: a claimed-passing evidence bundle received but not
  accepted; only checkable synthetic evidence is given, never a conclusion.
- reconstruction: reconstructed. Assumption: original evidence files and the
  prior conclusion were not provided; the synthetic pack is checkable by
  inspection.

### sync —
- frozen sha256 `c68f8fd1b0e245ba41d55442055120d7fed2929b6c19a79b163071d51a85c9d2` (cited for verify-sources对照; full text never printed) dual-mac-workspace-sync/.tad/evidence/journal/syncthing-lab-phase2-2026-08-25.md
- sha256 `c68f8fd1…51a85c9d2`, mode 644, regular file, no symlink.
- read_status: hash-only (same harness refusal; no excerpt). Decision moment
  from handoff §6.1: before starting sync; legacy config and capacity are
  discoverable states, not the incident outcome.
- reconstruction: reconstructed. Assumption: legacy config/capacity snapshot
  not provided; synthetic node config is minimal with discoverable markers.

### filter —
- frozen sha256 `df42a60a656ceb64e63d5a85bd2ee66cc5c9ca6ef3f1f51d4324284306f69f62` (cited for verify-sources对照; full text never printed) 买卖/.tad/evidence/journal/clinic-segment-correction-2026-08-20.md
- sha256 `df42a60a…4306f69f62`, mode 644, regular file, no symlink.
- read_status: read (§§1–2, minimal paraphrase; fictionalized below — no
  medical classification fact is treated as ground truth). Decision moment: a
  definition conflict is frozen and undecided; allowed cleanup (filter words,
  same sample set, reasons citing a provided external spec) must be
  distinguished from sample-changing drift (retrieval words). Supporting
  fact: necessary conditions must not be confused with common spellings.
- reconstruction: reconstructed. Assumption: original corpus not provided and
  not needed; the row set is fully provided in the case input with a complete
  fictional spec.

### routine —
- frozen sha256 `a913fa7207c96fc4ad9bf1181d07e43ca8024166dd4fbfc7745e6478c222fd38` (cited for verify-sources对照; full text never printed) grok-cloud/.tad/archive/handoffs/COMPLETION-20260904-mechanical-exit-wake.md
- sha256 `a913fa72…c222fd38`, mode 644, regular file, no symlink.
- read_status: hash-only (same harness refusal; no excerpt). Decision moment
  from handoff §6.1: a clearly scoped documentation update; must neither wire
  behavior nor refuse the normal edit.
- reconstruction: reconstructed. Assumption: original doc/wiring pre-state not
  provided; synthetic files are created and minimal.

## Reconstruction ratio
6/6 cases reconstructed (0/6 original replay). No post-hoc correction is
presented as prior input anywhere in the bundle; every case.json carries
`reconstruction: reconstructed` plus its own assumptions list.
