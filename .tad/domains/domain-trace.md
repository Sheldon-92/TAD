# Domain Pack 执行 Trace 记录（Stage 1 接线面）

> 来源：IDEA-20260402-self-evolving-domain-pack 的 Stage 1（执行 Trace 记录基础设施）。
> 本文件是接线说明正本：记录器实址、事件 schema、已接线的运行路径、验证方法。
> **Stage 2（失败模式聚合＋quality_criteria 提议）与 Stage 3（step 设计自动优化）未做**，
> 不在本件射程内——trace 只是后续阶段的数据基础，本文件不得被引为「自优化已上线」。

## 记录器

- 实址：`.tad/scripts/domain-trace.py`（Python 标准库，无依赖）。
- 落盘：`.tad/evidence/domain-traces/{domain}/{YYYY-MM-DD}.jsonl`，一行一事件（JSONL）。
  仓根由记录器自身文件位置推导，与调用方 CWD 无关。
- 子命令：`run`（计时执行一步并记录，退出码透传）、`record`（直接追加一事件，
  供已接线路径调用）、`validate`（全量 schema 校验，违规 exit 1）。

## 事件 schema

| 字段 | 含义 |
|---|---|
| `ts` | UTC ISO-8601 秒级时间戳 |
| `domain` | pack slug（如 `hw-testing`、`agent-memory`） |
| `run_id` | 同一次运行的分组 id |
| `step_id` | 步 / fixture / 断言标识 |
| `tool_calls` | 该步的工具/命令调用（字符串列表） |
| `duration_ms` | 该步墙钟耗时（整数毫秒） |
| `success` | 布尔，仅 `status == "success"` 时为 true |
| `status` | `success` / `failure` / `skipped` |
| `failure_reason` | failure/skipped 时为原因字符串；success 时为 null |

## 已接线的运行路径（观测式，非命令式）

设计依据：patterns/memory-and-learning.md 的 trace-instrumentation-fix 教训——
命令式发射（靠 agent 记得调 helper）实证 1/328 触发率、结构性不可靠；
故本件采用**观测式**：运行路径本身在执行时顺带发射，agent 无需记得任何调用。

1. **pack 行为评测路径**：`.tad/scripts/pack-eval-runner.sh` 每次 `assert_one`
   断言后（单件模式与 `--all` 批量模式）自动发射一事件：
   `domain`＝fixture 的 pack 主体，`step_id`＝fixture 名，
   `status` 由断言返回码映射（0→success，1→failure，2→skipped），
   `duration_ms` 为断言实测耗时，failure/skipped 的 reason 为裁定行原文。
   发射全程 `|| true` 守护、输出丢弃——**永不改变裁定与退出码**（承该脚本
   advisory-never-fail-closed 契约）。`DOMAIN_TRACE=0` 可关。
2. **shell 执行的 pack 步**：经记录器 `run` 子命令包装执行：
   `python3 .tad/scripts/domain-trace.py run --domain <pack> --step <id> -- <cmd...>`
   命令的 stdout/stderr 原样透传，退出码透传，失败原因记
   `exit_code N: <stderr 末行>`。

## 未覆盖面（显名边界）

- agent 在会话内直接执行的 pack 步（读 SKILL.md 后的人工/工具步）尚无 hook 级
  自动捕获；现行可达路径是上面两条。把 PostToolUse 观测扩展到 pack 步
  属后续阶段工作，本件不宣称已覆盖。
- 本件只**记录**：不聚合、不提议、不改任何 pack 内容。

## 验证

```bash
PYTHONDONTWRITEBYTECODE=1 python3 .tad/scripts/domain-trace.py validate
# → 每文件事件数 + "validate: OK (N events, M files, 0 violations)"
```
