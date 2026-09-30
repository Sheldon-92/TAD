---
task_id: TASK-20260929-AGENT-EVAL-HILLCLIMB-L2
task_type: docs
express: false
skip_knowledge_assessment: yes
e2e_required: no
research_required: no
status: READY_FOR_GATE4
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-20260929-agent-eval-hillclimb-l2-hybrid

**Task ID**: `TASK-20260929-AGENT-EVAL-HILLCLIMB-L2`
**From:** Alex (Terminal 1)
**To:** Blake — Gate 3 land DONE 2026-09-30 (OpenCode / opencode-go/muse-spark-1.3-contributor). Status now `READY_FOR_GATE4`. Pathspec/AC history below preserved unchanged.
**Created**: 2026-09-29
**Channel / model**: Cursor / grok-4.7-medium @grokbox
**Design**: `.tad/evidence/designs/2026-09-29-agent-eval-hillclimb-l2-hybrid.md`
**Prior discuss**: `.tad/evidence/discuss/2026-09-29-agent-eval-vehicle-choice.md` §5
**Mode**: docs-only. No product edit this turn. No git push.

Gate 2 dual review **PASS** on disk (spec + scope, P0=0). Blake appends the L2 entry, updates the index line, and adds the one pack cross-ref **only after** the human says `当 Blake`.

---

## Gate 3 land — DONE 2026-09-30 (Blake, OpenCode / opencode-go/muse-spark-1.3-contributor)

- **Landed**: 3-file pathspec verbatim from design (pack-evaluation.md append +7, _index.md Pack Evaluation line replaced hook len 86, ai-evaluation/SKILL.md +1 cross-ref line after `No overlap.`). No edits to `references/`, `principles.md`, `gate-design.md`, `agent-skill-evolution`, `pack-registry.yaml`, or anything else.
- **AC**: all 14 design acceptance checks PASS (must-appear 1–5, 7–11 incl. hook `86` and `grep -c` = `1`; must-be-empty 6, 12, 13 incl. design negative grep `见过的题上变绿` in `references/`; out-of-scope `git diff --exit-code` clean).
- **Evidence**: `.tad/evidence/impl/2026-09-29-gate3-selfcheck-agent-eval-hillclimb-l2.md` (AC table) + `.tad/evidence/reviews/2026-09-29-gate3-review-agent-eval-hillclimb-l2.md` (independent Layer2-style re-run, PASS P0=0).
- **Status**: `READY_FOR_GATE4`. Local commit only, no push, no tags.

---

## ✅ Gate 2: Design Completeness — PASS

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三处 pathspec 闭合；双审 PASS |
| Components Specified | ✅ | paste-ready 草稿在设计文 |
| Functions Verified | N/A | 无代码调用 |
| Data Flow Mapped | N/A | 文档追加 |
| Expert dual review | ✅ | Spec + Scope，P0=0 |
| All P0 resolved | ✅ | 两份审查均 P0=0 |

**Gate 2 结果**: **PASS**（2026-09-29，Cursor / grok-4.7-medium @grokbox）。

过程 Gate 2 证据（独立双审，P0 clear）：
- `.tad/evidence/reviews/2026-09-29-gate2-review-agent-eval-hillclimb-l2-spec.md` — Reviewer A PASS (P0=0; P1 advisory closed by restoring design negative grep as AC §3 item 13)
- `.tad/evidence/reviews/2026-09-29-gate2-review-agent-eval-hillclimb-l2-scope.md` — Reviewer B PASS (P0=0)

Blake 落地仍须人说 `当 Blake`。本文件不自动派 Blake，不改三处 pathspec 产品文件。

---

## 1. Intent

把 hillclimb 的方法句放进已有 L2 `pack-evaluation.md`，让 Blake 的索引钩子能打开该文件；`ai-evaluation` 只留一句指针，不变成爬坡工作流。

**不是要做的**：

- 不改 `principles.md`，不把家放到 `gate-design.md`
- 不新建 skill / pack，不改 `agent-skill-evolution`，不改 `pack-registry.yaml`
- 不改 `*experiment`，不新开 hillclimb slash
- 不改 PM 文案，不写 `/claude-api` 命令名
- 不把失败样例或评测指南正文搬进 pack `references/`

成功的样子：三处 pathspec 与设计文草稿逐字一致，设计文里的验收命令通过，范围外 `git diff` 为空。

## 2. Pathspec

| # | Path | Edit |
|---|------|------|
| 1 | `.tad/project-knowledge/patterns/pack-evaluation.md` | 文末追加设计文「Exact paste-ready L2 entry」整段 |
| 2 | `.tad/project-knowledge/patterns/_index.md` | 只替换 Pack Evaluation 那一行（设计文给出的 ≤120 字符钩子） |
| 3 | `.agents/skills/ai-evaluation/SKILL.md` | 在 `No overlap.` 那句后插入设计文那一行交叉引用。`references/` 零编辑 |

## 3. Acceptance criteria

与设计文相同。落地后运行：

1. `grep -F 'Declare Improvement Only Past a Noise Floor, on a Held-Out Headline, One Variable per Round' .tad/project-knowledge/patterns/pack-evaluation.md`
2. `grep -F '见过的题上变绿' .tad/project-knowledge/patterns/pack-evaluation.md`
3. `grep -F '结构绿冒充行为绿' .tad/project-knowledge/patterns/pack-evaluation.md`
4. `grep -F '无负对照即剧场' .tad/project-knowledge/patterns/pack-evaluation.md`
5. `grep -F 'can-this-set-detect-the-change' .tad/project-knowledge/patterns/pack-evaluation.md`
6. `grep -F 'can-this-set-detect-the-change' .tad/project-knowledge/patterns/gate-design.md` 必须无输出
7. `grep -F '噪声地板' .tad/project-knowledge/patterns/_index.md`
8. `grep -F 'held-out' .tad/project-knowledge/patterns/_index.md`
9. `grep -F '一轮一改' .tad/project-knowledge/patterns/_index.md`
10. `python3 -c "import pathlib; line=next(l for l in pathlib.Path('.tad/project-knowledge/patterns/_index.md').read_text().splitlines() if l.startswith('- [Pack Evaluation]')); hook=line.split(' — ',1)[1]; assert len(hook)<=120, len(hook); print(len(hook))"`
11. `grep -c 'patterns/pack-evaluation.md' .agents/skills/ai-evaluation/SKILL.md` 输出 `1`
12. `grep -RIn 'patterns/pack-evaluation.md' .agents/skills/ai-evaluation/references` 必须无输出
13. `grep -RIn '见过的题上变绿' .agents/skills/ai-evaluation/references` 必须无输出
14. `git diff --exit-code -- .tad/project-knowledge/principles.md .tad/project-knowledge/patterns/gate-design.md .agents/skills/agent-skill-evolution .tad/capability-packs/pack-registry.yaml`

## 4. Friction preflight

无。docs-only，无新工具、无密钥、无外部 CLI。Gate 2 双审已 PASS → 状态 `READY_FOR_BLAKE`。仍须人说 `当 Blake` 才改三处 pathspec。

## 5. Project knowledge Blake must read before editing

- `.tad/project-knowledge/patterns/pack-evaluation.md`（沿用既有 `failure_mode` 的 Naive default / Why wrong 句式；负对照即剧场）
- `.tad/project-knowledge/patterns/_index.md` 文首格式：钩子 ≤120 字符
- `.agents/skills/ai-evaluation/SKILL.md` 第 25 行分界：`Pack = evaluation judgment. Your workflow system = process constraints. No overlap.`

READY_FOR_BLAKE
