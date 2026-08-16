# Code Review — trace-relative-path (2026-08-16)

**Reviewer**: code-reviewer (Layer 2, subagent)
**Object**: `.tad/hooks/lib/common.sh` `record_trace()` — +9 lines relative-path conversion
**Handoff**: HANDOFF-20260816-trace-relative-path (rev2)
**Verdict**: ✅ **PASS** — no P0, no P1

## 三个承重点核对（全部兑现）

| # | 承重点 | 证据 |
|---|--------|------|
| 1 | 转换必须在 stat(L111)之后 | 代码顺序：L110 size=0 → L111 stat → L112-120 转换块；size 用原始路径取得 |
| 2 | case 模式变量加引号 `"$_repo_root"/*` | L118；本仓库路径含空格已实测 case 模式 |
| 3 | 插在 jq 分支(L113)之前，一处覆盖两条输出路径 | 转换块在 `if [ "$HAS_JQ" = true ]` 之前；jq 分支 L126 `--arg file "$file_path"` 与无-jq fallback L160 `safe_path=$file_path` 共用转换后的值 |

## 六项边界行为核对（全部保持）

| 场景 | 结果 | 验证方式 |
|------|------|----------|
| 不在 git 仓库内 | 保持原值不报错 | 未 git init 沙箱实跑 (AC7) |
| git 二进制不可用 | 保持原值不报错 | PATH shim exit 127 实跑 (AC13)，stderr 为空 |
| 路径不在任何仓库内 (/tmp/x) | 保持原值 | 实跑 (AC6)，stderr 为空 |
| 符号链接分歧 (/tmp vs /private/tmp) | 保持绝对（已知降级）| 实跑 (AC14) |
| file_path 为空 | 整块跳过无 file 键 | 实跑 (AC15) |
| 跨仓库写入 | 保持绝对（已知残留 §7.1）| 实跑 (AC12) |

## 备注（非阻塞，4 条）

- **A（回灌 handoff）**：handoff §2 承重点 2 声称"本仓库路径含空格，不加引号会漏匹配 →
  路径保持绝对"。bash 实测 case 模式**不分词**，unquoted `$_repo_root/*` 同样 MATCH——
  quoted 仍是正确写法，但该承重点的**机理描述不准确**；且 AC4 无法判别引号变体（两种写法都过）。
  建议 Alex 在 Gate 4 回灌 handoff 文档，将机理改为"引用一致性/防御性正确写法"。
- B：`git rev-parse` 每次调用 fork 一个子进程，record_trace 高频调用下有微小开销；当前 trace
  写入频率低，不构成性能问题，不需要缓存。
- C：`local _repo_root=""` 与 `if [ -n "$file_path" ]` 的双重守卫清晰；空路径时整块跳过，
  无多余 fork。
- D：转换后 `file_path` 为相对路径，`size_bytes` 已在转换前用原始路径取得——不变量保持。

## 独立性与范围
- 未修改任何被审查文件；scratch 沙箱已清理；真实 trace jsonl 校验和前后一致。
- 审查基于 `git diff ef887fbe -- .tad/hooks/lib/common.sh` + record_trace() 全函数阅读 +
  沙箱实跑验证。