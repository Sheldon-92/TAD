---
task_type: mixed
e2e_required: yes
research_required: no
git_tracked_dirs: [".claude/skills/blake"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Phase 3 — Blake Integration + E2E Validation

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Project:** TAD | **Task ID:** TASK-20260504-004
**Epic:** EPIC-20260504-notebooklm-research-director.md (Phase 3/3 — FINAL)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 |
|--------|------|
| Architecture Complete | ✅ |
| Components Specified | ✅ |

**Gate 2 结果**: ✅ PASS (compact Phase — scope well-defined from Phase 0-2)

---

## 1. Overview

Phase 3 收尾整个 Epic。三件事：
1. Blake SKILL 加 NotebookLM 只读 + note 通道
2. 在内容副业项目上跑 E2E 验证（真实 notebook、真实数据）
3. 跨项目 REGISTRY 概念验证

---

## 2. Requirements

### P3.1: Blake SKILL — NotebookLM 只读 + note 通道

在 Blake SKILL.md 中添加一个新段落（在现有 `develop_command` 附近，或作为独立 section）：

```yaml
notebooklm_access:
  description: "Blake can query existing notebooks for implementation context"
  scope: "read-only + note creation ONLY"
  
  allowed:
    - "*research-notebook ask 'question'" # query existing research
    - "*research-notebook fulltext <id>"   # read source content
    - "*research-notebook guide <id>"      # source summary
    - "*research-notebook topics"          # notebook overview
    - "*research-notebook ingest <file>"   # feed implementation findings back
    - "*research-notebook list"            # see available notebooks
    - "*research-notebook use <id>"        # switch active notebook for queries
    - "*research-notebook language get/set/list" # output language control
    - "*research-notebook quiz"            # generate learning quiz from notebook
    - "*research-notebook flashcards"      # generate flashcards from notebook
  
  forbidden:
    - "*research-notebook create"          # Alex creates notebooks
    - "*research-notebook research"        # Alex directs research
    - "*research-notebook report"          # Alex generates reports
    - "*research-notebook configure"       # Alex sets persona/mode
    - "*research-notebook consolidate"     # Alex manages portfolio
    - "*research-notebook curate"          # Alex manages lifecycle
    - "*research-notebook archive"         # Alex manages lifecycle
    - "*research-notebook add"             # Alex manages sources
    - "*research-notebook sync"            # Alex reconciles with cloud
  
  when_to_use: |
    During *develop, if Blake needs context that might exist in a research notebook:
    1. Check: is there a relevant notebook? → *research-notebook list
    2. Query: ask the notebook a specific implementation question
    3. After implementation: if Blake discovers something noteworthy,
       use *research-notebook ingest to feed the finding back
  
  terminal_isolation: |
    Blake accesses NotebookLM via the same CLI (*research-notebook commands).
    This does NOT violate terminal isolation — Blake is using a shared tool,
    not communicating with Alex. The notebook is the shared knowledge asset.
```

### P3.2: E2E Validation on 内容副业 Project

在内容副业项目（`~/01-on progress programs/内容副业/`）上实际测试新功能。使用真实的现有 notebook。

**测试场景：**

```
E2E-1: Research Director 激活扫描
  → cd ~/01-on\ progress\ programs/内容副业/
  → 读取 .tad/research-notebooks/REGISTRY.yaml
  → 模拟 Alex STEP 3.8: 扫描 REGISTRY，输出研究态势
  → 预期: "📚 Research: 1 active notebook (AI Agent Security)"
  → 验证: 输出格式正确，notebook 数量准确

E2E-2: source fulltext (真实源)
  → notebooklm source list -n <内容副业 notebook ID>
  → notebooklm source fulltext <first_source_id> -n <notebook_id>
  → 预期: 获得源的全文内容
  → 验证: 内容非空，长度合理

E2E-3: ask --source targeting (定向查询)
  → notebooklm ask "恐怖播客的核心受众是谁" --source <specific_id> -n <notebook_id> -c 00000000-0000-0000-0000-000000000000
  → 预期: 回答只引用指定源的内容
  → 验证: 回答非空，exit code 0

E2E-4: generate report + download (完整 pipeline)
  → notebooklm generate report "总结这个 notebook 的核心发现，给出 3 个可操作建议" -n <notebook_id> --retry 3 --wait
  → notebooklm download report --latest -n <notebook_id> ~/01-on\ progress\ programs/内容副业/.tad/evidence/research/e2e-test-report.md
  → 预期: markdown 报告下载成功
  → 验证: 文件非空，包含标题和内容

E2E-5: language set + 中文输出验证
  → notebooklm language get --local (记录当前设置)
  → notebooklm language set zh_Hans
  → notebooklm ask "summarize the main topics" -n <notebook_id> -c 00000000-0000-0000-0000-000000000000
  → 预期: 回答是中文
  → 清理: 恢复原语言设置

E2E-6: ingest 知识回流 (用 E2E-4 的报告)
  → 如果 E2E-4 成功:
    notebooklm source add ~/01-on\ progress\ programs/内容副业/.tad/evidence/research/e2e-test-report.md -n <notebook_id>
  → 等待 30s
  → notebooklm ask "你知道我们之前生成的研究报告里提到了什么可操作建议吗" -n <notebook_id> -c 00000000-0000-0000-0000-000000000000
  → 预期: 回答引用报告内容 → 知识回流 E2E 确认
  → 清理: notebooklm source delete <added_source_id> -n <notebook_id> --yes
```

### P3.3: 跨项目 REGISTRY 概念验证

不需要完整实现。只需在 E2E 报告中回答这个设计问题：

```
问题: 内容副业项目的 REGISTRY.yaml 只追踪了 1 个 notebook (ai-agent-security-phase0b)，
     但 NotebookLM 云端有 ~10 个该项目相关的 notebook。
     *research-notebook sync 能否发现这些未注册的 notebook？
     如果不能，Phase 4 需要什么来实现跨项目全局管理？

验证方法:
  → notebooklm list (获取云端所有 notebook)
  → 对比 REGISTRY.yaml 的 notebooks 列表
  → 在 E2E 报告中记录差异 + 建议
```

---

## 3. Files to Modify

| # | File | Action | Scope |
|---|------|--------|-------|
| 1 | `.claude/skills/blake/SKILL.md` | Edit | 加 ~30 行 notebooklm_access section |
| 2 | `.tad/evidence/e2e/EPIC-20260504-e2e-validation.md` | Create | E2E 测试结果报告 |

---

## 4. Acceptance Criteria

- [ ] AC1: Blake SKILL has `notebooklm_access` section with allowed/forbidden lists
- [ ] AC2: E2E-1 (activation scan) 输出正确
- [ ] AC3: E2E-2 (fulltext) 获得真实源内容
- [ ] AC4: E2E-3 (ask --source) 定向查询成功
- [ ] AC5: E2E-4 (report pipeline) markdown 报告下载成功
- [ ] AC6: E2E-5 (language) 中文输出验证 + 恢复
- [ ] AC7: E2E-6 (ingest 回流) 报告内容可被 ask 引用
- [ ] AC8: P3.3 跨项目 REGISTRY 差异分析完成
- [ ] AC9: 所有 E2E 测试结果记录在 `.tad/evidence/e2e/EPIC-20260504-e2e-validation.md`
- [ ] AC10: E2E 测试后所有清理完成（语言恢复、测试源删除）

---

## 5. Important Notes

### 5.1 Auth 前置
所有 E2E 测试前先跑: `~/.tad-notebooklm-venv/bin/notebooklm auth check --test`
如果 auth 失效 → STOP，通知用户。

### 5.2 不要修改内容副业项目的 REGISTRY
E2E 测试用的 notebook 是只读验证。不要更新内容副业的 REGISTRY.yaml。
E2E-6 添加的测试源必须在测试后删除。

### 5.3 E2E 用哪个 notebook
内容副业 REGISTRY 只有 ai-agent-security-phase0b (32cb8d9f)。
但云端有 True Crime notebook (c4f2aae5) 内容更丰富（Phase 0 spike 用的也是这个）。
建议: 用 c4f2aae5 做 E2E（5 源 + 丰富历史），在报告中注明。

---

## 📚 Project Knowledge

Blake 必须注意:
- 所有 CLI 用绝对路径 `~/.tad-notebooklm-venv/bin/notebooklm`
- Stale conversation 用 `-c 00000000-0000-0000-0000-000000000000`
- Knowledge loop ~30s processing time（Phase 1 验证过）
- `notebooklm rename` 不存在（Phase 2 已知）

---

## 9.2 Expert Review

Compact Phase — 用户要求直接做完。Blake SKILL 改动小（~30 行 allowed/forbidden），E2E 是验证不是开发。Gate 3 Layer 2 至少 1 expert (code-reviewer) 审查 Blake SKILL 改动。
