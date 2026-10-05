# COMPLETION-20260915-tad-research-mechanism — TAD Research 机制落地

**Task ID**: `TASK-20260915-TAD-RESEARCH-MECHANISM` | **Owner**: Blake (OpenCode, `opencode-go/muse-spark-1.3-contributor`)
**Handoff**: `.tad/active/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md`
**Date**: 2026-09-15 | **Mode**: docs/protocol-only（未 push / tag / bump / release）
**Verdict**: **DONE — RG1–RG4 research track wrapper 落地，commit `f92cbc73`，Gate 2/3/4 全 PASS，待人类最终 CHECK。**

---

## SHAs

| Ref | SHA |
|---|---|
| Commit R | `f92cbc73` — `docs(research): land RG1-RG4 research track wrapper over deep engine (TASK-20260915-TAD-RESEARCH-MECHANISM)` |
| Parent | `c48e5620` |

R stat：12 files changed, 668 insertions(+), 10 deletions(-)。未 push。

## 落盘内容（R 内）

**新建**：`.tad/gates/research-gate-canonical-checklist.md`（RG SSOT，51 行）、`.tad/templates/research-charter.md`、`.tad/templates/research-critic-review.md`、`.agents/skills/alex/references/research-track-protocol.md` + `.claude` 镜像。
**修改**：双平台 `alex/SKILL.md`（`deep_execution` repoint 至 track wrapper）、双平台 `research-plan-protocol.md`（+5 行 header）、`.tad/config-workflow.yaml`（顶层 `research_track:`）、`.tad/templates/research-decision-brief.md`（Verdict-first 首行）。

## Gates

| Gate | 结论 | 载体 |
|---|---|---|
| Gate 1（问题/范围/AC） | PASS | HANDOFF §MQ + §9.1 |
| Gate 2（设计双审） | PASS（R1 双 CONDITIONAL → R2 修完） | `.tad/evidence/reviews/2026-09-15-gate2-review-tad-research-mechanism.md` |
| Gate 3 CODE 独立审 | PASS（14/14 AC 本机复现） | `.tad/evidence/reviews/2026-09-15-gate3-code-review-tad-research-mechanism.md` |
| Gate 3 SAFETY 独立审 | PASS（四维全过） | `.tad/evidence/reviews/2026-09-15-gate3-safety-review-tad-research-mechanism.md` |
| PM 盘上验 | PASS | commit 在盘，12 文件齐 |
| Gate 4（Alex 验收） | PASS | `.tad/evidence/reviews/2026-09-15-gate4-acceptance-tad-research-mechanism.md` |

## 设计要点（人类 CHECK 用）

- **Fuse 不 fork**：RG1–RG4 是套在现有 `*research --deep` 引擎外的门禁 wrapper，无第二套流水线。
- **Critic = 协议非新角色**（不同会话 + 对抗 prompt；同 session 自评记 DEGRADED）。
- **人只在 3 个真决策点介入**：charter 授权 / 收-深-转向 shortlist / 重大转向。
- **深度硬规矩**：关键结论双源验证、source 三级标注、终稿必有"最强反例"节、provenance（结论→来源→检索日期）、verdict 先行。
- **模型**：research/discuss 沿用 `opencode-go/deepseek-v4.1-flash`（用户确认不升级）。

## 待人类 CHECK

1. 设计方向是否符合预期（fuse 现有引擎，而非另起一套）；
2. 三个待定问题的答案是否接受；
3. 是否可以作为 TAD 正式机制记录（后续试点跑一遍 R0–R4 再沉淀）。
