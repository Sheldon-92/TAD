# Code Quality Knowledge

Project-specific code quality learnings accumulated through TAD workflow.

---

## Foundational: Code Quality Standards

> Established at project inception.

(No foundational entries yet — populate during knowledge bootstrap or first handoff.)

---

## Accumulated Learnings

### Recurring failure: tsc missing type — 2026-05-19
- **Context**: Detected by dream-scanner from v2 trace analysis. Pattern 'tsc: missing type' appeared in ≥2 reflexion_diagnosis events across TAD handoff cycles.
- **Discovery**: TypeScript type-checking failures (missing type declarations) are a recurring root cause of Blake Layer 1 failures. This pattern triggers reflexion cycles that could be avoided with upfront type completeness checks in handoff ACs.
- **Action**: When writing handoff ACs for TypeScript projects, include an explicit AC: "npx tsc --noEmit passes with zero errors before Layer 1." Consider adding type coverage threshold to Gate 3 v2 checklist.

### AC grep-count for reference-based pack files — 2026-05-27
- **Context**: Upgrading video-creation pack with vimax-patterns.md. Alex wrote AC8/AC13 as `grep -c 'vimax-patterns.md' SKILL.md` expecting `= 1`.
- **Discovery**: Reference filenames in reference-based capability packs naturally appear in 2 locations: (1) Context Detection table row, (2) Quick Rule Index section heading. All existing references follow this pattern (storytelling.md, audio-design.md, etc.). ACs using `grep -c 'filename'` should expect `= 2`, not `= 1`.
- **Action**: When writing ACs for pack reference additions, use `grep -c 'filename' SKILL.md` with expected `= 2` (or `≥ 1` if only checking existence). Dry-run the grep against an existing reference filename to confirm the expected count before shipping handoff.

### Bash heredoc Python injection via unvalidated CLI args — 2026-05-28
- **Context**: Phase 4 academic-search.sh script. Code-reviewer P0: `--limit` parameter assigned from user input (`LIMIT="$2"`) without integer validation, then interpolated into Python heredocs via `${LIMIT}` inside `python3 -c "... [:${LIMIT}]"`.
- **Discovery**: When bash `${VAR}` is expanded inside a heredoc containing embedded Python/awk/perl code, the variable content becomes part of the target language's source code. A malicious `--limit` value like `5]; import os; os.system("id"); x=[0` would execute arbitrary Python. This applies to any bash script that interpolates user input into embedded language blocks.
- **Action**: Always validate CLI numeric arguments with `[[ "$var" =~ ^[0-9]+$ ]]` before interpolating into any embedded language (Python/awk/perl). For string arguments, prefer passing via environment variable (`LIMIT=$var python3 -c "import os; limit=int(os.environ['LIMIT'])"`) instead of heredoc interpolation.
- **Grounded in**: .tad/evidence/reviews/blake/academic-research-pack-phase4/code-review.md (P0-1)

### Reading provenance rules ≠ following them during pack builds — 2026-05-29
- **Context**: Building ml-training capability pack. Handoff §12 Project Knowledge explicitly cited "Per-Tool Numeric Thresholds Require Research Provenance, Not Interpolation" from architecture.md. Despite reading this rule, Blake fabricated 7 numbers across 5 reference files (full fine-tune VRAM 60-120GB, GPT-SoVITS ~8-12GB, Lambda pricing $1.10-2.49/hr, VoxCPM2 recommended data 10-30 min, dataset Recommended column, base model selection table).
- **Discovery**: Citing a provenance rule in the handoff is necessary but not sufficient. The builder still interpolates from LLM training data when the research file has a gap, especially for "obvious" numbers that feel correct. Active per-number cross-referencing during writing — not just reading the rule beforehand — is needed. The failure pattern: research provides a range for the METHOD → builder assigns specific numbers to individual TOOLS within that range.
- **Action**: For capability pack builds, add a mandatory self-check step: after writing each reference file, grep for all numeric values and verify each against deep-ask-findings.md. Numbers not found → mark as "data not available from research — verify before use" rather than interpolating.
- **Grounded in**: HANDOFF-20260529-ml-training-build.md, code-reviewer P0-1 through P0-7

### mikefarah yq `-i` Normalizes Once Then Is Idempotent — Plan the One-Time Reformat — 2026-05-31
- **Context**: research-engine-wire-phase4 §4.2/§4.3 mandated structure-aware REGISTRY.yaml edits via `yq -i` (per-entry, atomic temp+mv) with an AC4.6 requirement that all non-edited entries stay byte-identical. First `yq -i` touch produced a 43-45 line diff (stripped blank lines, normalized inline-comment spacing, re-folded long multiline strings) — NOT the single targeted status line.
- **Discovery**: mikefarah yq v4 reformats the WHOLE file on its first write, then is byte-stable: every subsequent `yq -i` edit changes ONLY the targeted node. There is no reliable blank-line/comment-preservation flag in yq v4. So a byte-identical-others AC is satisfiable ONLY relative to an already-yq-normalized file. The clean resolution: perform the one-time normalization as part of a mandated edit (here, the §4.3 archive edit), after which any recurring automated editor (the SessionStart dormant hook) produces byte-surgical diffs forever. Verify idempotency explicitly: normalize a temp copy, snapshot, run a second edit, `diff` must show only the one line.
- **Action**: When a handoff mandates yq for recurring structure-aware edits AND requires byte-identity of untouched entries, (1) expect+accept a one-time whole-file normalization, (2) trigger it via a single mandated edit up front, (3) prove idempotency with a normalize→snapshot→edit→diff test, (4) run the AC4.6-style byte test against a copy of the NORMALIZED file, not the raw original. Never reach for line-based sed to dodge the reformat — that reintroduces the multi-entry corruption risk the yq mandate exists to prevent.
- **Grounded in**: .tad/hooks/lib/notebook-lifecycle.sh, .tad/evidence/acceptance-tests/research-engine-wire-phase4/dormant-recompute-smoke.md
