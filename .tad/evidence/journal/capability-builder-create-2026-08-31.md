# Journal — Capability Builder Phase 1 Create (2026-08-31)

## What Happened

Implemented `TASK-20260831-CAPABILITY-BUILDER-CREATE` per handoff `HANDOFF-20260831-capability-builder-phase1-create.md` (Gate 2 PASS).

- Created framework Builder router `.claude/skills/capability-builder/SKILL.md` (69 lines) with non-circular `create` trigger, mandatory `references/create-protocol.md` load, and `evolve`/`package` as `STOPPED_WITH_REASON` future phases.
- Created `references/create-protocol.md` (118 lines) encoding state machine `REQUESTED → JUSTIFIED → DESIGNED → MATERIALIZED_CANONICAL → BEHAVIOR_PROVEN → PROJECTED → GATE_3_READY` and named stops/blocks.
- Mirrored both to `.agents/skills/capability-builder/` via `cp` (byte-identical, `diff -rq` PASS).
- Preserved legacy research: `cp` pre-change `capability-upgrade/SKILL.md` (SHA 69026199d9…) to `references/legacy-pack-research.md` in both trees, verified baseline == reference.
- Replaced `capability-upgrade/SKILL.md` with compatibility router (new work → `capability-builder create`, existing pack → `LEGACY_PACK_OUT_OF_SCOPE`, no old scaffold).
- Implemented `.tad/scripts/capability-skill.sh` (BSD-safe, exit 0/1/2/3/4) with validate/project/verify, containment, symlink chain guards, temp sibling + verify + rename, divergent refusal, missing parent creation, and `--help`.
- Extended `.tad/scripts/pack-eval-runner.sh` to parse `skill:` (new `parse_skill` + `parse_pack_raw`), dual-field detection → `SKIP (bad fixture: conflicting subject fields)`, subject resolution `skill → pack → path`, preserving legacy `pack:` byte-identical.
- Updated `CLAUDE.md` routing row only (single row diff: old `能力包升级` → new `能力构建` with `capability-builder create` + `capability-upgrade` LEGACY).
- Created isolated fixture-project `.agents/skills/example-skill` (minimal valid Skill, 1403 bytes) and `fixtures/example-skill.md` (`skill: example-skill`, `EXAMPLE_RULE_ALPHA|THRESHOLD_42|EXIT_99`, `min_discriminative: 3`).
- Captured fresh CONTROL (0/3 → FAIL) and WITH (3/3 → PASS) from identical `prompt/task.md`, recorded `run-manifest.json` with prompt/skill/fixture/output hashes, harness/model/provenance, and recomputed verdicts.
- Projected only after validation+behavior, verified byte identity; divergent and all structural invalid cases refuse without mutation or temp residue (28 cases, exit classes asserted).
- Created acceptance driver `run-acceptance.sh` with modes `projection|structural|eval-compat|behavior|routing|claude-routing|scope|all`.
- Ran all §9.1 literal commands: AC1–AC12 all PASS; builder/upgrade mirrors PASS; obsolete scaffold absent; protected manifests identical (434 lines).

## Surprises / Fixes

- `hash_tree` initially included absolute path in `shasum` output, causing manifest vs driver recompute divergence (relative vs absolute). Fixed to content-only hash (`cut -d' ' -f1` before sort).
- `parse_pack` fallback caused skill-only to be misclassified as dual; added `parse_pack_raw` (frontmatter only) for dual detection.
- `run-acceptance.sh` used unicode variable names (`control状態`) invalid in bash; renamed to ASCII.
- `.tad/evidence` is gitignored; explicit `git add -f` required for acceptance-tests dir — verified no yolo2 riders staged via `git diff --cached --name-only`.

## Decisions

- Helper exit codes: 0 success, 1 usage, 2 invalid/path, 3 divergent, 4 I/O — implementation-owned but stable and tested.
- Helper project creates missing `.claude`/`skills` parents only after containment/symlink checks; cleans empty parents on failure.
- Eval runner keeps `PACK <subject>` prefix for both legacy and new fixtures; `subject` resolved via `skill → pack → path`.

## Knowledge Assessment

- New discovery: Yes. Hash-tree path-normalization and pack-raw vs pack-resolved distinction are generalizable.
- Will distill via Alex Gate 4 (patterns/shell-portability or ac-verification?).
