# Build Record — R3 Group 2 Borrow-4 Trial Index

## Section A — Mechanical extraction & freeze (Blake, Phase 3 step 1, 2026-10-06)

Extractor: Blake (implementation session). Per HANDOFF §4.2 / §6 Phase 3
step 1, the extractor performed the mechanical extraction below and
therefore does NOT serve as builder or runner, and does not relay
question text to either role.

Pre-extraction count verification (on the R2 source files):

- `grep -cE '^- Q(3[3-9]|4[0-5])：' .tad/evidence/self-review-r2-20261006/g5-recall-question-set.md` = 13
- `grep -cE '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md` = 13

Extraction commands (verbatim, output redirected — no manual edits):

- `grep -E '^- Q(3[3-9]|4[0-5])：' .tad/evidence/self-review-r2-20261006/g5-recall-question-set.md > questions-subset-13.md`
- `grep -E '^[|] Q(3[3-9]|4[0-5]) ' .tad/evidence/self-review-r2-20261006/g5-recall-expected-set.md > expected-subset-13.md`

Frozen artifacts (sha256, frozen at extraction):

- `questions-subset-13.md`: `5f15be1faff20412ad82094a98011c81c2bf810a6723cfbd167881036c125419` (13 lines)
- `expected-subset-13.md`: `04acb2a7580567b817010e4da3a264754b60a6794e85fd0b49c4e7f32784368a` (13 lines)

Post-extraction derivation check (AC-G2-1 merged form): both `cmp`
comparisons silent — the subsets are byte-identical extractions of the
R2 sources.

Authority manifest (before): `authority-manifest-before.sha256` — 28
lines (25 incident files under `incidents/2026-05/` + `incidents/2026-06/`,
`incidents/_index.md`, `.tad/brain-index.md`,
`.tad/project-knowledge/patterns/_index.md`), computed via
`find … | LC_ALL=C sort | xargs sha256sum`. Corpus layout note: incident
files live in month subdirectories; all 25 stems verified unique, so
drawers key on stem.

## Section B — Trial index construction (builder sub-session appends below)

Builder: append the full wing/room/drawer tree with counts, the copy
commands used with byte-identity verification, and your reading
self-sign + forbidden-path declaration. Do not edit Section A.

## Section B — Builder Report (g2-borrow4-trial)

### B.1 Wing → Room → Drawer tree listing with counts

- Total wings: 8
- Total rooms: 16
- Total drawers: 25

#### Wing: ac-verification (rooms: 2, drawers: 3)
- Room: grep-count-commands (drawers: 2)
  - ac-verification-command-bug
  - ac-grep-count-reference-pack
- Room: region-marker-extraction (drawers: 1)
  - section-9-1-region-marker

#### Wing: gate-design (rooms: 1, drawers: 2)
- Room: reviewer-blind-spots (drawers: 2)
  - expert-reviewer-premise-check
  - layer2-audit-reviewer-name-drift

#### Wing: memory-and-learning (rooms: 1, drawers: 1)
- Room: self-triggering-parsers (drawers: 1)
  - parser-self-trigger

#### Wing: pack-build-rules (rooms: 2, drawers: 3)
- Room: parity-checks (drawers: 2)
  - codex-edition-parity
  - cross-agent-parity-check
- Room: skill-migration (drawers: 1)
  - scienceclaw-skill-decoupling

#### Wing: pack-evaluation (rooms: 3, drawers: 5)
- Room: pack-value-measurement (drawers: 2)
  - pack-value-non-monotonic
  - pack-value-cross-vendor
- Room: quality-and-rubric-review (drawers: 2)
  - scoring-rubrics-need-methodology-review
  - academic-research-pack-pilot
- Room: collision-detection (drawers: 1)
  - pack-collision-detection

#### Wing: principles-linked (rooms: 3, drawers: 5)
- Room: copy-set-deny-list (drawers: 2)
  - derived-copy-set-dotfiles
  - embedded-copy-drift-check
- Room: role-and-extraction-discipline (drawers: 2)
  - alex-role-decay-direct-execution
  - progressive-disclosure-extract
- Room: audit-validation-theater (drawers: 1)
  - ad-hoc-dead-code-audit

#### Wing: research-methodology (rooms: 2, drawers: 3)
- Room: cli-orchestration-constraints (drawers: 2)
  - codex-agents-md-auto-load
  - gemini-cli-constraints
- Room: source-import-quality (drawers: 1)
  - chattts-consistency-pattern

#### Wing: shell-portability (rooms: 2, drawers: 3)
- Room: sed-path-normalization (drawers: 2)
  - anchorless-tad-sed
  - line-anchored-blockquote-sed
- Room: routing-label-grep (drawers: 1)
  - claude-md-routing-label-conflicts

Wing derivation: each incident's wing is the slug of the L2 pattern file named in its `linked:` field in incidents/_index.md, normalized to the pattern slug; incidents whose `linked:` points to an L1 principle were placed in the wing `principles-linked`. Derived wing count: 8 (ac-verification, gate-design, memory-and-learning, pack-build-rules, pack-evaluation, principles-linked, research-methodology, shell-portability).

Routing file check: trial-index/routing.md contains exactly 25 drawer lines (one per drawer, each stem appearing exactly once in the file), and every drawer line is at most 160 characters (observed maximum: 146 characters).

### B.2 Copy commands used + byte-identity verification result

Copy commands used (verbatim `cp`, one copy per incident file, flat into drawers/, `_index.md` not copied):

```sh
SRC=/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/incidents
DST=/home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/trial-index/drawers
for f in "$SRC"/2026-05/*.md "$SRC"/2026-06/*.md; do cp "$f" "$DST/"; done
```

Byte-identity verification: for each of the 25 source incident files, `sha256sum` of the source was compared with `sha256sum` of the corresponding copy in trial-index/drawers/. Result: TOTAL=25, FAIL=0 — all 25 copies verified byte-identical to their sources (each pair reported OK with matching sha256).

### B.3 Reading self-sign

Files I actually read during this build:

1. /home/hatch/workspace/yun-sync/TAD/AGENTS.md
2. /home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/incidents/_index.md
3. All 25 drawer copies in /home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/trial-index/drawers/ (these copies were my reading basis for writing the routing hooks):
   - ac-grep-count-reference-pack.md
   - ac-verification-command-bug.md
   - academic-research-pack-pilot.md
   - ad-hoc-dead-code-audit.md
   - alex-role-decay-direct-execution.md
   - anchorless-tad-sed.md
   - chattts-consistency-pattern.md
   - claude-md-routing-label-conflicts.md
   - codex-agents-md-auto-load.md
   - codex-edition-parity.md
   - cross-agent-parity-check.md
   - derived-copy-set-dotfiles.md
   - embedded-copy-drift-check.md
   - expert-reviewer-premise-check.md
   - gemini-cli-constraints.md
   - layer2-audit-reviewer-name-drift.md
   - line-anchored-blockquote-sed.md
   - pack-collision-detection.md
   - pack-value-cross-vendor.md
   - pack-value-non-monotonic.md
   - parser-self-trigger.md
   - progressive-disclosure-extract.md
   - scienceclaw-skill-decoupling.md
   - scoring-rubrics-need-methodology-review.md
   - section-9-1-region-marker.md
4. /home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/trial-index/routing.md (my own output, re-read only for mechanical validation of drawer-line count, line length, and stem uniqueness)

I also listed directory names (without reading file contents) for the corpus directory and the output directory to confirm layout and file counts.

Forbidden-path declaration: I did NOT open, read, grep, or list the contents of any of the following forbidden paths:
- /home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/questions-subset-13.md
- /home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/expected-subset-13.md
- anything under /home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r2-20261006/
- /home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md and its SUPPLEMENT files
- the existing content of build-record.md (this Section B was appended blind, without reading the prior content)

— End of Section B —
