---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Mini-Handoff: AGENTS.md — Codex 原生角色切换

**From:** Alex | **To:** Blake | **Date:** 2026-05-02
**Type:** Express (skip Socratic, skip epic review)
**Priority:** P2

## 需求

创建项目根目录的 `AGENTS.md`，让 Codex 启动时自动加载 TAD 双角色。用户在 Codex 内说 "当 Alex" 或 "当 Blake" 即可切换，无需退出重开 session。

## 设计

`AGENTS.md` 结构：
1. **项目概述** — TAD 是什么，两个角色分别做什么（3-5 行）
2. **Alex 模式** — 引用 `.tad/codex/codex-alex-skill.md`（不复制全文，用 "Read and follow" 指令）
3. **Blake 模式** — 引用 `.tad/codex/codex-blake-skill.md`（同上）
4. **切换规则** — 用户说 "当 Alex / switch to Alex / Alex 模式" → 读取并激活 Alex SKILL；同理 Blake
5. **默认行为** — 如未指定角色，表现为通用 TAD 助手（读 NEXT.md 和 active handoffs 告知状态）

⚠️ **不要把 25KB/35KB 的 SKILL 全文粘贴到 AGENTS.md 里**——Codex 启动时读 AGENTS.md 会消耗 token。用"Read file then follow protocol"模式引用即可。

## 文件清单

| File | Action |
|------|--------|
| `AGENTS.md` (project root) | CREATE |
| `.tad/codex/README.md` | UPDATE — 加一行说明 AGENTS.md 是推荐入口 |

## Acceptance Criteria

- [ ] AC1: `AGENTS.md` 存在于项目根目录
- [ ] AC2: 包含 Alex 和 Blake 两个角色的引用路径
- [ ] AC3: 包含切换指令说明
- [ ] AC4: 不含 SKILL 全文（`wc -c < AGENTS.md` < 3000 bytes）
- [ ] AC5: Codex 启动时能读到 (`codex exec --full-auto "What roles are available in this project per AGENTS.md?"` 能回答 Alex + Blake)

## ⚠️ 实现前验证 (CR-P0-1)

"Read file then follow protocol" 引用模式在 Codex 上未验证。Blake 必须先测试：

```bash
# 创建一个极简 test-agents.md
echo '# Test Agent\nWhen user says "test mode", read .tad/codex/codex-blake-skill.md and tell me the first protocol name you find.' > /tmp/test-agents.md

# 在项目根放临时 AGENTS.md 测试
cp /tmp/test-agents.md AGENTS.md
codex exec --full-auto "test mode"
rm AGENTS.md  # 清理
```

- 如果 Codex 确实读取了 codex-blake-skill.md 并回答正确 → 用引用模式
- 如果 Codex 只看到 AGENTS.md 文字但没读引用文件 → **Fallback**: 在 AGENTS.md 内放一个 ~500 字的角色摘要（不是完整 SKILL，而是关键指令 + "for full protocol, read .tad/codex/codex-{role}-skill.md"）

## Acceptance Criteria (修订)

- [ ] AC1: `AGENTS.md` 存在于项目根目录
- [ ] AC2: 包含 Alex 和 Blake 两个角色定义
- [ ] AC3: 包含切换指令说明
- [ ] AC4: 文件大小合理 (`wc -c < AGENTS.md` < 5000 bytes)
- [ ] AC5: Codex 能识别角色 (`codex exec --full-auto "Per AGENTS.md, what roles are available?"` 回答 Alex + Blake)
- [ ] AC6 (关键): Codex 能加载 SKILL 内容 (`codex exec --full-auto "Act as Blake. What is your Layer 1 self-check protocol?"` 回答来自 codex-blake-skill.md 而非幻觉)

## Blake Instructions

Express — 无 Socratic、无 epic review。
1. 先跑 §验证 确认引用模式是否可行
2. 根据结果选择引用模式或 fallback 摘要模式
3. 创建 AGENTS.md + 更新 README
4. Layer 1 self-check → verify AC → expert review (≥1) → done
