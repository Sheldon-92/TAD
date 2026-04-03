# Handoff: TAD v2.8 Phase 3 — Cross-Project Aggregation

**From:** Alex | **To:** Blake | **Date:** 2026-04-02
**Task ID:** TASK-20260402-019
**Epic:** EPIC-20260402-tad-v28-self-evolving.md (Phase 3/5)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. What We're Building

`*evolve` 命令 — 在 TAD 主项目中聚合所有下游项目的 trace 数据，分析跨项目的共性问题，提议 TAD 框架级修改（SKILL.md / Hook / Gate / Domain Pack）。

**区别**：
- `*optimize`（Phase 2）：单个项目内优化 Domain Pack
- `*evolve`（本 Phase）：跨项目优化 TAD 方法论本身

## 2. 必读

- `.tad/spike-v3/domain-pack-tools/v28-research-synthesis.md` — Meta-Harness 跨候选分析
- `.tad/sync-registry.yaml` — 10 个注册项目的路径
- `.claude/commands/tad-alex.md` — *optimize 实现（Phase 2 产出）

## 3. Technical Design

### 3.1 Trace 收集

`*evolve` 从所有注册项目收集 trace：

```
读取 .tad/sync-registry.yaml → 获取 10 个项目路径
对每个项目:
  读取 {project_path}/.tad/evidence/traces/*.jsonl
  合并到内存中的聚合数据集
```

**不复制文件** — 直接读取远程路径。TAD 主项目可以访问所有下游项目（同一台机器）。

### 3.2 跨项目分析

聚合后分析：

1. **跨项目共性失败**：同一个 Domain Pack step 在多个项目中失败
   → "competitive_analysis.deep_analyze 在 menu-snap 和 Sober Creator 都跳过了"
   → 提议修改 product-definition.yaml 的该 step

2. **框架级问题**：Gate 被跳过、Ralph Loop 未执行等（从 trace 缺失推断）
   → "3/10 项目的 task_completed trace 后没有 Gate 3 evidence"
   → 提议加强 Hook enforcement

3. **Domain Pack 使用热度**：哪些 pack 最常用、哪些从未用过
   → 优先优化高频 pack

### 3.3 提议类型

`*evolve` 的提议范围比 `*optimize` 大：

| *optimize 提议 | *evolve 提议 |
|---------------|-------------|
| 修改单个 domain.yaml | 修改 domain.yaml（跨项目共性） |
| — | 修改 Alex/Blake SKILL.md |
| — | 修改 Hook 脚本 |
| — | 修改 Gate 检查项 |
| — | 新增 Domain Pack capability |

提议格式复用 Phase 4 的 PROPOSAL YAML，增加 `scope: "framework"` 字段。

### 3.4 应用 + 同步

接受的框架级提议：
1. 在 TAD 主项目中应用修改
2. 提醒用户运行 `*sync` 推送到所有下游项目
3. 不自动 sync — 人确认后手动执行

## 4. Implementation

### Step 1: Alex SKILL.md 新增 *evolve 命令

```yaml
evolve: "Cross-project trace aggregation — analyze all projects and propose TAD framework improvements"
```

### Step 2: evolve_protocol（~40 行）

```yaml
evolve_protocol:
  trigger: "用户输入 *evolve"
  prerequisite: "必须在 TAD 主项目中执行（检查 .tad/sync-registry.yaml 存在）"

  steps:
    step1:
      name: "收集跨项目 Trace"
      action: |
        读取 .tad/sync-registry.yaml 获取项目列表
        对每个项目路径做安全校验：
          - realpath 解析后必须在 /Users/ 下（防止路径遍历）
          - 路径必须包含 .tad/ 目录（确认是 TAD 项目）
          - 校验失败 → 跳过该项目 + 警告
        对校验通过的项目读取 .tad/evidence/traces/*.jsonl
        统计：每个项目的 trace 条数、类型分布、时间范围
        如果总 trace < 10 条：输出 "Not enough data" 并退出

    step2:
      name: "跨项目模式分析"
      action: |
        识别：
        1. 在 2+ 个项目中出现的相同失败模式
        2. 框架级缺陷（Gate 跳过、Ralph Loop 缺失）
        3. Domain Pack 使用热度排名
        4. 跨项目的 quality_criteria 有效性对比

    step3:
      name: "生成框架级提议"
      action: |
        对每个发现生成 PROPOSAL YAML：
        - scope: "framework"
        - target: SKILL.md / Hook / Gate / domain.yaml
        - evidence: 跨项目聚合数据
        写入 .tad/evidence/proposals/

    step4:
      name: "人审批"
      action: |
        同 *optimize — AskUserQuestion 展示提议
        framework 级提议额外警告："此修改将通过 *sync 影响所有项目"

    step5:
      name: "应用 + 提醒 sync"
      action: |
        接受的提议应用到 TAD 主项目
        输出："框架修改已应用。运行 *sync 推送到所有项目。"
```

### Step 3: 测试

由于 trace 数据很少，测试用 mock 数据：
1. 在 2 个项目的 traces/ 下写入模拟 trace
2. 运行 *evolve
3. 验证能读取跨项目数据、生成提议

## 5. AC

- [ ] AC1: Alex SKILL.md 有 *evolve 命令
- [ ] AC2: *evolve 读取 sync-registry.yaml 获取项目列表
- [ ] AC3: *evolve 读取多个项目的 trace 数据
- [ ] AC4: 聚合分析识别跨项目共性模式
- [ ] AC5: 生成 PROPOSAL YAML（scope: "framework"）
- [ ] AC6: AskUserQuestion 审批（含"影响所有项目"警告）
- [ ] AC7: 应用后提醒 *sync
- [ ] AC8: 数据不足时提示（<10 条）
- [ ] AC9: 只能在 TAD 主项目执行（检查 registry 存在）
- [ ] AC10: 必须走 Ralph Loop + Gate 3

## 6. Notes

- ⚠️ *evolve 只在 TAD 主项目执行（不在下游项目）
- ⚠️ 不自动 sync — 人确认后手动 *sync
- ⚠️ 框架级修改影响范围大，审批时必须明确警告
- ⚠️ 当前 trace 数据很少，可能需要 mock 测试

**Handoff Created By**: Alex
