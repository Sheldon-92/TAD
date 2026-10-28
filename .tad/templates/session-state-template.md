# TAD Session State
<!-- Auto-maintained by TAD agents. See .tad/templates/session-state-template.md -->
trust: unverified
<!-- 信任标记约定（六面）：标记形态为一行 `trust: disk-verified <YYYY-MM-DDThh:mm TZ> by <角色或检查名>`
     或 `trust: unverified`；TZ 为标记所在机器的本地时区缩写，由 `date '+%Y-%m-%dT%H:%M %Z'` 生成时随附。
     进 WARN 检查的面（四面）：session-state 活文件（`.tad/active/session-state.md` 头部）、`NEXT.md` 头部、
     `ROADMAP.md` 头部、`AGENTS.md` 头部/版本声明处——由 state-surface-check 的 trust 检查扫。
     只落标记约定的面（两面）：`docs/pm/now.md` 头部、Epic `## Run` 块内——这两面不进检查，
     不得在任何文本中冒称已被信任检查覆盖。
     写者规则：只许当轮真正拿盘面核对过该面的人写 `disk-verified`；未核对顺手抄前＝违规。 -->
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
{One line: e.g. "Ralph Loop → Layer 1 → Step 3/5 (lint)" or "Requirement clarification — block 3/5"}

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
