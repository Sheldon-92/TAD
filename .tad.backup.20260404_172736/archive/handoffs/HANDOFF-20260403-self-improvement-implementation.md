# Mini-Handoff: self_improvement_design 补充 — 具体实现方案设计

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-001

---

## 1. Problem

self_improvement_design capability 的 step5（generate_blueprint）说"Implementation guide（在具体运行环境中怎么实现）"，但只是蓝图的一个小节。缺少逼用户**设计出可落地的实现方案**的步骤。

## 2. 必读研究

📖 **`.tad/spike-v3/domain-pack-tools/agent-self-improvement-research.md`**

Alex 研究了 5 种运行环境的真实实现：OpenClaw（.learnings/ 自动推送）、LangSmith（Promptim + Annotation Queue）、Firebase RC（remoteConfig + A/B）、Langfuse（不可变版本 + 可移动 label）、企业级（7 阶段管线）。

**核心发现**：没有全自动。所有系统都是"trace → 浮现异常 → 人或保守阈值决定 → 配置部署 → 即时回滚"。

参考方案库的数据来自这份研究，不是编的。

## 3. 补充：在 step4（safety）和 step5（blueprint）之间插入新 step

```yaml
      - id: design_runtime_implementation
        action: |
          针对 agent 的具体运行环境，设计自我优化的完整实现方案。
          必须回答以下每一个问题（不能跳过）：

          **执行环境识别**：
          - agent 跑在哪里？（iOS app / OpenClaw runtime / 云服务 / CLI / 浏览器）
          - 有什么技术约束？（语言、框架、可用存储、网络状态）

          **trace 存储实现**：
          - 用什么存？（SQLite / 文件 / 云数据库 / API）
          - 代码怎么写？（给出具体的伪代码或函数签名）
          - 数据量预估？（每天 N 条 × M 字段 = 多大）
          - 清理策略？（保留多久、怎么归档）

          **分析循环实现**：
          - 谁来执行分析？（app 内后台任务 / cron job / 云函数 / 人手动触发）
          - 多久跑一次？（每 N 次执行 / 每天 / 每周）
          - 分析代码在哪跑？（设备端 / 服务器端 / Claude API 调用）
          - 分析结果存哪？（和 trace 一起 / 单独的 proposals 表）

          **变更应用实现**：
          - prompt 修改怎么生效？（版本化文件 / 数据库字段 / 远程配置）
          - 新旧版本怎么切换？（A/B 测试 / 灰度发布 / 直接替换）
          - 回滚怎么操作？（版本回退命令 / 配置开关 / 代码 revert）

          **人审批实现**：
          - 审批界面在哪？（管理后台 / CLI / Slack bot / 邮件）
          - 审批流程怎么触发？（分析完自动推送 / 人主动查看）
          - 不审批会怎样？（提议过期 / 自动应用 / 永远等待）

          **参考方案库**（根据运行环境选择最接近的，然后定制）：

          | 运行环境 | trace 存储 | 分析执行 | 变更应用 | 人审批 |
          |---------|-----------|---------|---------|--------|
          | iOS/Android App | SQLite/CoreData | 服务端云函数 | Remote Config | 管理后台 Web UI |
          | OpenClaw Runtime | .learnings/ markdown | Hook 检测错误→阈值推送 | 写入系统 prompt 文件 | 无（阈值自动：3次+2任务+30天） |
          | Claude Code (TAD) | .tad/evidence/ JSONL | *optimize 命令 | Edit YAML | AskUserQuestion |
          | 独立 API 服务 | Postgres/MongoDB | cron job/Lambda | prompt 版本表+A/B | Slack webhook |
          | LangChain/LangGraph | LangSmith/Langfuse | callback+eval | graph state | dashboard UI |
          | Web App | localStorage+API | 后端分析服务 | feature flag | admin dashboard |

          步骤：
          1. 从参考方案库选择最接近的运行环境
          2. 对 4 个维度逐一定制
          3. 每个维度给出技术选型 + 伪代码
          4. 标注和参考方案的差异

          每个答案必须具体到"用什么技术、写什么代码、存在哪里"。
          "待定"或"后续决定"= FAIL。
        tool_ref: null
        quality: "4 个实现维度每个有技术方案 + 伪代码。参考方案库有对应选择。"
        output_file: "self-improvement-design.md (append)"
```

## 3. 同时更新 quality_criteria

新增：
```yaml
      - "实现方案指定了具体的运行环境技术栈"
      - "trace 存储有伪代码或函数签名"
      - "分析循环有明确的执行者和触发机制"
      - "变更应用有版本化和回滚方案"
      - "人审批有具体的界面和流程"
```

## 4. AC

- [ ] AC1: 新 step `design_runtime_implementation` 插入在 safety 和 blueprint 之间
- [ ] AC2: 4 个实现维度全覆盖（存储/分析/应用/审批）
- [ ] AC3: quality_criteria 新增 5 条实现相关标准
- [ ] AC4: 现有 steps 不变
- [ ] AC5: YAML 语法正确
- [ ] AC6: 必须走 Ralph Loop + Gate 3

**Handoff Created By**: Alex
