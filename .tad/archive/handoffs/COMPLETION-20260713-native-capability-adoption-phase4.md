# COMPLETION — Native Capability Adoption Phase 4 (YOLO)

**Handoff**: `.tad/active/handoffs/HANDOFF-20260713-native-capability-adoption-phase4.md`
(NOTE: handoff lives in the MAIN working dir — `.tad/active/` is untracked and does not
propagate into worktrees; read from `/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/`)
**Worktree**: `/Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_0019f033-1ce-1`
**Date**: 2026-07-13 | **Executor**: Blake (YOLO Phase 4) | **Task**: TASK-20260713-004

## Blake understanding declaration (handoff §1.3)

1. **问题**: 最小化接入两个已验证 native 能力 — (a) *design 协议教会何时用 AskUserQuestion
   per-option `preview`（具体文本 artifact 的 single-select 对比；preference/multiSelect 排除）；
   (b) 单文件 `.claude/rules` pilot（spike-gated + 四项测量），让非 TAD 流程的 hooks 编辑也拿到
   shell-portability 硬约束。
2. **使用方式**: 下次 *design 的 2-up/tournament 呈现带 side-by-side preview；任何读到
   `.tad/hooks/**` 文件的 session 自动注入 5 条硬约束。
3. **成功标准**: (a) wiring + 镜像 IDENTICAL（行为证据 observe-on-next-use, honest_partial）；
   (b) LOADED/INERT 实证（doc URL + retrieval date）→ LOADED → thin rule + fire/no-fire/
   parity/context-delta 四项测量落盘。

## Spike verdict (B1)

**LOADED** — documented `paths:` YAML-list frontmatter works on CLI 2.1.172.
3/3 isolated fixture tests (control / fire / no-fire, sentinel-token probes) + docs citation
(code.claude.com/docs/en/memory + adjudicated GitHub issue #17204, both retrieved 2026-07-13).
Full raw records: `phase4-rules-spike.md`. → B2/B3 executed (no degradation path needed).

## Files changed

| File | Op | Track |
|------|----|-------|
| `.claude/skills/alex/references/design-protocol.md` | MODIFIED (additions only): `preview_usage_rule` block between step1_5c and step2 + step1_5c step 4 extension | A1/A2 |
| `.agents/skills/alex/references/design-protocol.md` | MODIFIED (mirror sync, byte-identical) | A3 |
| `.claude/rules/shell-portability.md` | NEW (25 lines / 1370 bytes, thin excerpt: 5 constraints + pointer + sync note) | B2 |
| `.tad/evidence/yolo/native-capability-adoption/phase4-rules-spike.md` | NEW (B1 evidence) | B1 |
| `.tad/evidence/yolo/native-capability-adoption/phase4-rules-measurement.md` | NEW (B3 four measurements) | B3 |
| `.tad/evidence/yolo/native-capability-adoption/phase4-lineset-diff.txt` | NEW (C1 archive) | C1 |
| `.tad/evidence/yolo/native-capability-adoption/phase4-completion.md` | NEW (this report) | — |

`.claude/rules/` has no `.agents` counterpart (Claude-native feature) — intentionally NOT
mirrored, per handoff §10.2.

## Layer 1 checks

| Check | Result | Detail |
|-------|--------|--------|
| `npx tsc --noEmit` | NOT_APPLICABLE_WITH_REASON | Repo root has NO tsconfig.json; tsc 6.0.3 exits 1 printing usage help (no project given). Identical on untouched baseline — the only tracked .ts files are archived research fixtures under `.tad/active/research/` with their own sub-project configs. This phase's diff contains ZERO code files (`git diff --name-only | grep -c '\.js$'` = 0; only .md changed), so no type surface was touched. |
| `npm test` | PASS (exit 0) | `echo "No tests yet"` — repo has no test suite; §9.1 AC commands are the verification layer (all executed below). |
| `npm run lint` | NOT_AVAILABLE | No `lint` script in package.json ("if available" condition not met). |

## AC verification table (§9.1 — raw outputs)

| # | Criterion | Expected | Actual | Status |
|---|-----------|----------|--------|--------|
| AC0a | baseline preview count | 0 | `0` | PASS (pre-impl) |
| AC0b | rules dir absent | No such file | `ls: .claude/rules: No such file or directory` | PASS (pre-impl) |
| AC0c | mirror identical | IDENTICAL | `IDENTICAL` | PASS (pre-impl) |
| AC0d | tournament anchor | 1 hit | `146:          4. Use the merged_design from the result…` | PASS (pre-impl) |
| AC1 | use_when / never_when / multiSelect counts | all ≥1 | `1` / `1` / `2` | PASS |
| AC2 | example block contains preview | ≥1 | `4` | PASS |
| AC3 | `preference` token (baseline 0) | ≥2 | `2` | PASS |
| AC4 | step 4 → skip_conditions range mentions preview | ≥1 | `3` | PASS |
| AC5 | zero `.js$` in diff | 0 | `0` | PASS |
| AC6 | scope lock: tracked diff only design-protocol.md ×2; untracked only §7.1 files | empty / listed | tracked: `(empty)` after excluding design-protocol.md; untracked: `?? .claude/rules/` + `?? .tad/evidence/yolo/native-capability-adoption/` | PASS (see Friction: REGISTRY.yaml hook side-effect reverted) |
| AC7 | mirror identical post-impl | IDENTICAL | `IDENTICAL` | PASS |
| AC8 | lineset diff archived, FORWARD-missing explainable | EXISTS | `EXISTS`; FORWARD-missing = EMPTY (additions only — original step-4 line kept byte-identical) | PASS |
| AC9 | spike verdict exactly 1 + URL ≥1 + retrieval ≥1 | 1 / ≥1 / ≥1 | `1` / `2` / `2` | PASS |
| AC10 | frontmatter parses, scope key present | PARSE-OK, non-NO-SCOPE-KEY | `- ".tad/hooks/**"` + `PARSE-OK` (yq) | PASS |
| AC11 | thin-rule caps | ≤60 lines, ≤4096 B | `25` lines, `1370` bytes | PASS |
| AC12 | 5 constraints in deliverable, sourced | 5 RULE-OK, 0 MISS | 5× `RULE-OK`, 0 MISS; each constraint carries source entry date | PASS |
| AC13 | pointer + sync note | ≥1 | `1` | PASS |
| AC14 | 4 measurement sections | 4 SEC-OK | `SEC-OK: fire-test / no-fire / parity / context` | PASS |
| AC15 | behavioral honesty | no file-existence-as-behavior claims | see Behavioral Evidence Ledger below | PASS |

## Behavioral Evidence Ledger (AC15 anti-Validation-Theater)

| Claim | Evidence class | Status |
|-------|---------------|--------|
| `.claude/rules` path-scoping WORKS on 2.1.172 | REAL EVENT — 3/3 isolated fixture probes (spike) + 3/3 in-repo probes incl. verbatim constraint-#5 quote and discriminative `THIN EXCERPT` token (fire=YES / no-fire=NO, same token) | PROVEN in-session |
| rule fires on real `.tad/hooks/**` edit sessions going forward | Rules trigger on READS (docs-verified); real-edit-session observation is future | observe-on-next-use (limitation documented: read-triggered, not write-triggered) |
| Alex uses preview at next *design 2-up/tournament | protocol text only — cannot fire in this session | PENDING-REAL-EVENT / observe-on-next-use (honest_partial, per handoff §10.2) |

## Friction Status

| Friction Point | Status | Note |
|----------------|--------|------|
| `.claude/rules` INERT risk on 2.1.172 | RESOLVED — spike verdict LOADED | Degradation matrix not needed; FR6/FR7 delivered |
| fire-test not triggerable in-session | RESOLVED — headless `claude -p` sub-sessions gave REAL fire/no-fire events | Better than the PENDING fallback the handoff allowed |
| Official docs access | READY — WebFetch OK | 2 sources cited with retrieval dates |
| Handoff not visible in worktree | WORKED AROUND | `.tad/active/` untracked → read from main working dir path |
| Headless probe side-effects | RESOLVED | SessionStart/lifecycle hooks in probe sub-sessions flipped 2 notebook statuses in `.tad/research-notebooks/REGISTRY.yaml` (active→dormant) and emitted `.tad/evidence/traces/2026-07-13.jsonl`. REGISTRY.yaml restored via `git checkout --`; trace file left on disk, NOT committed (session noise, not a deliverable). |

## Escalations

- None requiring design decisions. Two observations for Conductor:
  1. `npx tsc --noEmit` is structurally N/A at this repo root (no tsconfig) — the Layer 1
     template's tsc gate cannot pass on this repo for any phase; suggest the workflow treat
     it as conditional.
  2. Headless `claude -p` probes inside the repo trigger the repo's own lifecycle hooks
     (REGISTRY staleness flip). Future in-repo fire-tests may prefer `--strict-mcp-config`/
     hook-disabled invocation or fixture dirs only.

## Sub-Agent usage record (handoff §12)

| Sub-Agent | Called | Note |
|-----------|--------|------|
| parallel-coordinator | NO | 2 serial tracks, <1h — per handoff §10.3 |
| bug-hunter | NO | no anomalous fire-test behavior |
| test-runner | NO | no test suite; §9.1 commands run directly |

(Headless `claude -p` probe sub-sessions were measurement instruments, not reviewer/expert
sub-agents — none called, per YOLO Phase constraints.)

## Knowledge Assessment (candidate raw journal notes for Alex distillation)

- **Probe design**: asking a sub-session "is rule X in context?" is confoundable when
  CLAUDE.md @imports contain sibling content (first no-fire probe false-YES via
  patterns/_index.md). A DISCRIMINATIVE token present ONLY in the artifact under test
  (`grep -rl` = exactly 1 file first) turns the probe into a clean binary. Symmetric
  fire/no-fire on the SAME token is the convincing pair.
- **Community-vs-docs conflict**: issue #17204 claims `paths:` broken; did not reproduce on
  2.1.172 with YAML-list form. Empirical fire-test on the exact local version beats both
  doc trust and issue trust.
- **Headless in-repo probes have side effects**: repo lifecycle hooks run in probe
  sub-sessions and mutate tracked files — diff-scope checks (AC6) catch this; revert noise
  before commit.
