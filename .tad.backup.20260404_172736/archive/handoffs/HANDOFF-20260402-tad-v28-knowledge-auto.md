# Mini-Handoff: *optimize 扩展 — Project Knowledge 自动提议

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-020
**Epic:** EPIC-20260402-tad-v28-self-evolving.md (Phase 2 补充)

---

## 1. What We're Building

扩展 *optimize 命令，让它不只提议修改 Domain Pack，也能提议更新 project-knowledge。

同时加一个 Hook：Gate 通过但 project-knowledge 没更新时提醒。

## 2. 两个改动

### 2.1 扩展 *optimize（Alex SKILL.md）

在现有 optimize_protocol 的 step2（聚合失败模式）之后，增加：

```yaml
step2b:
  name: "识别项目特有经验"
  action: |
    从 trace 数据中识别项目特有的模式（不是 Domain Pack 通用问题）：
    1. 反复出现的搜索词修改（用户总是改搜索范围 → 说明默认范围不对）
    2. 反复出现的工具替换（总是换工具 → 说明推荐工具不适合这个项目）
    3. 项目特有的失败模式（只在这个项目出现，不是跨项目共性）
    
    对每个发现，生成 project-knowledge 提议：
    {
      "target": ".tad/project-knowledge/{category}.md",
      "type": "add_knowledge",
      "content": "### {标题} - {date}\n- **Context**: ...\n- **Discovery**: ...\n- **Action**: ...",
      "evidence": "基于 trace 数据的具体引用"
    }
```

在 step4（人审批）中，project-knowledge 提议和 Domain Pack 提议一起展示：

```
Alex: "基于执行 trace，建议更新："
  
  📦 Domain Pack 修改:
  1. product-definition.yaml → 竞品分析加定价验证
  
  📚 项目知识更新:
  2. project-knowledge/search-patterns.md → 中文产品搜索必须包含小红书
  
  逐个审批...
```

### 2.2 Hook：Gate 通过但 Knowledge 未更新时提醒

在 post-write-sync.sh 的 COMPLETION 检测分支中，增加 Knowledge Assessment 提醒：

现有提醒：
```
"COMPLETION report detected. You MUST run /gate 3..."
```

增强为：
```
"COMPLETION report detected. You MUST run /gate 3 before sending results to Alex. 
Gate 3 includes Knowledge Assessment — if you learned anything project-specific, 
record it to .tad/project-knowledge/ BEFORE running Gate 3."
```

这只是提醒加强（prompt-only），不是硬约束。硬约束在 Gate 3 的 Knowledge Assessment 表格（已有，必须填 Yes/No）。

## 3. AC

- [ ] AC1: *optimize step2b 识别项目特有经验
- [ ] AC2: project-knowledge 提议和 Domain Pack 提议一起在 step4 展示
- [ ] AC3: post-write-sync.sh COMPLETION 提醒增加 Knowledge Assessment 提示
- [ ] AC4: 现有 *optimize 功能不受影响
- [ ] AC5: 必须走 Ralph Loop + Gate 3

## 4. Notes

- ⚠️ 小改动 — 只扩展 *optimize 的 step2 和 step4，加一行 Hook 提醒
- ⚠️ project-knowledge 提议用 Accumulated Learnings 格式（Context/Discovery/Action）

**Handoff Created By**: Alex
