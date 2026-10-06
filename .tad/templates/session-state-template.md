# TAD Session State
<!-- Auto-maintained by TAD agents. See .tad/templates/session-state-template.md -->
Last Updated: {YYYY-MM-DDTHH:MM:SSZ}
Hook Last Touched: <none>                  <!-- Updated by post-write-sync.sh hook -->
Last File Written: <none>                  <!-- Updated by post-write-sync.sh hook -->

## Active Agent
**Role**: {Blake | Alex}
**SKILL**: {.agents/skills/blake/SKILL.md | .agents/skills/alex/SKILL.md}

## Active Task
**Status**: {ACTIVE | COMPLETE | ABANDONED}
**Handoff**: {.tad/active/handoffs/HANDOFF-*.md | none}
**Priority**: {P0 | P1 | P2 | P3 | N/A}
**Mode** (Alex only): {analyze | bug | discuss | idea | learn | express | experiment | N/A}

## Current Position
{One line: e.g. "Ralph Loop → Layer 1 → Step 3/5 (lint)" or "Socratic Inquiry Round 3/5"}

## Completed ✅
{Brief bullets of what's done — update progressively}

## Next Action
{One line: what to do next}

## Big Picture (不要忘记)
**Goal**: {one-sentence task objective — from handoff §1 Executive Summary}
**Why Now**: {one-sentence user pain or strategic driver — from handoff §1 problem description}
**Key Constraint**: {most important constraint from handoff §10}
**Success When**: {completion criteria summary — copy from handoff ACs}

## 卸载记录（Offload Log）
{材料被卸载出当前上下文时逐件登记：时间｜卸载项｜依据｜原文指针｜回取方式；无卸载项写「无」，不许留空节}

<!-- Mechanical facts (git HEAD, branch, handoff/epic lists) are auto-snapshotted before every
     compaction to .tad/active/precompact/snapshot-*.md (newest-wins) by the PreCompact hook.
     This file stays 100% agent-written — the hook never touches it. See AGENTS.md role separation rules. -->
