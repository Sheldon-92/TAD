# Gate 3 Report — Local Wiki Native Browser Capture

**Date:** 2026-09-02
**Product commit:** `7cce3f78`
**Final evidence fix:** `f235e377` (AC1 scan self-leak only)
**Verdict:** PASS

## Layer 1

- Native Node suite: 12/12 PASS.
- Importer + retrieval Python suite: 24/24 PASS.
- Canon lint: PASS.
- Generator: two consecutive `--emit all` outputs identical; worktree remained clean.
- Real isolated Chrome/CDP rendered-page smoke test: PASS.
- Public YouTube probe: `experimental_degraded`; deterministic YouTube extraction/import
  remains PASS and the handoff expressly permits this honest live disposition.

## Layer 2

- Code reviewer: PASS, P0=0, P1=0, P2=0.
- Test/security reviewer: PASS, P0=0, P1=0, P2=0.
- `layer2-audit.sh local-wiki-phase3r-native-capture`: PASS, two distinct reviewers.

## Scope and independence

The product contains no runtime or product-document reference to the external
`下载md插件/web-to-markdown` project. Its two previously touched files were restored to
SHA-256 `7f873c78a850ed491c087373d18eedf4e3a6f5fedd134627a84f3b05770eee73`
and `f8e3556ab78f68fbd78dfba038b89e109e02225e4e6a7be0b95c3eff6ea5d95f`.

All nine acceptance criteria are satisfied. The live YouTube result is a declared experimental
limitation, not a hidden fallback or a claim of live success.

Final mainline replay confirmed the literal AC1 repository scan returns zero. The test preserves
the same negative dependency assertion by constructing its forbidden names at runtime rather than
self-leaking those names into the scanned tree.

`audit-yolo.sh` is informationally incompatible with the corrective `phase3r-*` naming: it
parses `phase3r-grounding.md` as a phase identifier and searches for synthetic
`phasephase3r-grounding.md-*` paths. This structural false failure is recorded but does not
override the direct artifact, test, and reviewer checks above.
