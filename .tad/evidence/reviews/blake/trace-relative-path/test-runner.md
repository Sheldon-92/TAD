# Test Runner Review — trace-relative-path (2026-08-16)

**Reviewer**: test-runner (Layer 2, subagent)
**Object**: `.tad/evidence/acceptance-tests/trace-relative-path/` AC suite
**Verdict**: ⏳ **CONDITIONAL** → 修复后待复核（F1 P0 + F2/F3/F4 P1）

## Round 1 (CONDITIONAL)

### 实测结果表（正确实现）
AC-01 负控真实（改前红、改后守卫不覆盖）｜AC-02..08 / 10..15 全绿（rc=0）｜AC-09 等效验证绿
（count grew 5->6，file 相对路径）｜zsh 抽查 AC-02..06 绿

### 判别力测试（破坏性变体，均为 /tmp 副本）
- 错序（转换移 stat 前）→ **AC3 红**（size_bytes=0 vs 11）—— AC3 是唯一判别配置 ✅
- jq 分支内插入 → **AC5 红**（no-jq fallback 保持绝对）✅
- 完全损坏（`record_trace(){ echo TOTALLY BROKEN; }`）→ AC2/3/6/7/14 红；
  **AC15 假绿** ✗（F1）
- 漏 `2>/dev/null` → AC7 假绿（fatal 泄漏）✗（F1）
- 引号缺陷（case 去引号）→ 无判别配置（bash/zsh/BSD sh case 不分词）—— 备注 F5

### 发现的 P0/P1
- **F1 (P0)**：AC-07/13/14/15 的 `2>"$ERR"` 在 `$(…)` 外侧 → stderr 断言失效 + AC15 误绿
- **F2 (P1)**：AC-09 族相对路径 + 无数字守卫 → 错 cwd 静默假绿 + 嵌套 trace 污染
- **F3 (P1)**：AC10 路径过滤致"1 file"恒真；AC11 只查 ?? 漏 M tracked 修改
- **F4 (P1)**：baseline-red.txt 曾被未守卫 AC1 覆盖为相对路径（已重建真红）

## Round 2（修复后复核，待 test-runner 确认）
- F1：stderr 重定向移入 `( … ) 2>"$ERR"` 内部；AC15 补 ts/type schema 判定 → broken 实测红
- F2：`cd "$ROOT"` + is_num 守卫 → 错 cwd 不再假绿
- F3：AC10 全量 numstat 按路径排除 env jsonl；AC11 按状态码分流（??/M 双白名单）
- F4：真红基线已重建并可复现；AC1 加写保护

（本文档为实测记录；详细结论以 test-runner 原始报告为准。）