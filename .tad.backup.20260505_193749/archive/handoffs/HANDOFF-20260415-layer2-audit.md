---
task_type: code
e2e_required: no
research_required: no
---

# Handoff (Express): Layer 2 Audit — Alex Gate 4 红字警告

**From:** Alex | **To:** Blake | **Date:** 2026-04-15
**Priority:** P1
**Handoff Type:** Express (scope < 1h, single-file impact); expert review min 1 (per AR-001: express ≠ review-exempt)
**Context:** Epic 1 取消后的替代方向——"装烟雾报警器不装自动灭火系统"

---

## 1. Why

Epic 1（Mechanical Enforcement）已取消，但原问题——Blake 可能跳 Layer 2 expert review——没有被解决，只是从"机械拦截"改为"软提醒"。本 handoff 补上监督层：Alex 在 `*accept` 执行业务检查之后、Knowledge Assessment 之前，**自动检查 Blake 是否真产出了 Layer 2 reviewer artifacts**，缺失就在验收报告里红字警告。**不阻塞**（与 2026-04-15 决策一致），**不是 hook**（不走 PreToolUse，无 dogfood paradox 风险）。

目标：让"Blake 声称做了 Layer 2 但没产出 artifacts"这种情况**在 Alex 验收时被你看见**，而不是悄无声息通过。

## 2. What

### 2.1 新增 shell 脚本

`.tad/hooks/lib/layer2-audit.sh`（工具脚本，**不是** PreToolUse hook，**不注册**到 settings.json）：

**接口**：
```bash
bash .tad/hooks/lib/layer2-audit.sh <handoff-slug>
```

**逻辑**：
1. 参数校验：slug 非空、无 `..`、无 `/`、无 shell 元字符（`[a-zA-Z0-9_-]+` 白名单）
2. 检查 `.tad/evidence/reviews/blake/${slug}/` 目录存在
3. 检查该目录下至少有 1 个 `.md` 文件且该文件 ≥ 500 字节（用 `stat -f%z` macOS / `stat -c%s` linux，含 portability fallback）
4. 通过 → exit 0 + stdout 打印 "Layer 2 audit PASS: {file_count} reviewer artifacts found"
5. 失败 → exit 1 + stderr 红字（`\033[31m...\033[0m`）打印具体缺失原因（目录不存在 / 无 md 文件 / 文件过小）

**约束**：
- 纯 POSIX bash + `stat` + `find`，不依赖 jq/yq/perl（避免 dep-guard 类陷阱）
- stderr 默认带 ANSI 颜色（TTY 时）；`NO_COLOR` 环境变量存在时降级为纯文本（`if [ -z "${NO_COLOR:-}" ] && [ -t 2 ]`）
- 脚本 30-50 行内完事

### 2.2 Alex SKILL.md 修改

`.claude/skills/alex/SKILL.md` 的 `acceptance_protocol` 在 step4（业务检查）与 step7（Knowledge Assessment）之间插入新 step：

```yaml
step4c:
  name: "Layer 2 Audit (红字警告，不阻塞)"
  action: |
    从当前 handoff 文件名提取 slug（HANDOFF-YYYYMMDD-<slug>.md 或 COMPLETION-YYYYMMDD-<slug>.md 格式）。
    运行: bash .tad/hooks/lib/layer2-audit.sh <slug>
    读取 exit code + stderr：
    - exit 0 → 验收报告正常显示 "✅ Layer 2 artifacts verified: .tad/evidence/reviews/blake/<slug>/"
    - exit 1 → 验收报告在显眼位置插入:
      ```
      ⚠️ LAYER 2 AUDIT FAIL
      Blake completion report 声称做了 Layer 2 review，但 .tad/evidence/reviews/blake/<slug>/
      未发现 reviewer artifacts（原因见脚本 stderr）。
      人类验收员请确认：Blake 是否真跑了 expert review？
      如确认跳过，考虑要求 Blake 补做或记录原因。
      ```
    继续执行 step7（不阻塞验收）——是否接受由人类判断。
  blocking: false
```

### 2.3 Slug 提取 helper（inline 在 SKILL，或可选独立小脚本）

Slug 提取规则：
- 从当前 session 正在验收的 handoff 文件名提取
- Pattern: `^(HANDOFF|COMPLETION)-\d{8}-(.+)\.md$` → slug = $2
- 若无法提取（非标准文件名）→ audit 脚本报 "slug unresolvable, skipping"，Alex 验收报告记录"Layer 2 audit N/A: non-standard handoff filename"——不阻塞

## 3. Acceptance Criteria

| # | AC | 验证方法 |
|---|----|---------|
| AC1 | **脚本基础**：`layer2-audit.sh` 创建 + `chmod +x` + `bash -n` 语法通过 + 脚本头含 `set -euo pipefail` + `IFS=$'\n\t'` + **runtime stat detection**（`stat --version &>/dev/null` 判 GNU，否则 BSD fallback，**不硬编码 flavor**） | `ls -l` + `bash -n` + `grep -c "set -euo pipefail" layer2-audit.sh` ≥1 + 在同一脚本测 `if stat --version &>/dev/null` 分支 |
| AC2 | **Slug 白名单严格锚定**：正则为 `^[a-zA-Z0-9_]([a-zA-Z0-9_-]*[a-zA-Z0-9_])?$`——锚定首尾、禁首尾 `-`（防 `find`/`stat` argv-flag 注入）、禁空串、禁单 `-`；非法输入 → exit 1 + stderr 明确错误 + stderr 中的 slug 回显截断到 64 字符（`${slug:0:64}`，防长度攻击）；所有 `find`/`stat` 调用都用 `--` 分隔符隔离参数 | 5 个 smoke/negative test: 合法 / `..` / `/` / 空串 / 首字符 `-` |
| AC3 | **PASS 路径**：目录存在 + 有 ≥1 ≥**200 字节**（从 500 降到 200——Blake 写短而真实的 review 比长而灌水的更常见） md 文件 → exit 0 + **stderr 完全干净**（no output）+ stdout `Layer 2 audit PASS: N reviewer artifacts found` | 1 fixture dir 跑脚本，captue stderr 必须为空 |
| AC4 | **FAIL 路径 + 5 fixture**：`(a)` 目录不存在 / `(b)` 存在但无 md / `(c)` 有 md 但都 <200 字节 / `(d)` 目录含 symlink 指向 md（应遵循 symlink，若目标 ≥200B 则 PASS，否则 FAIL 且 stderr 说明"symlinked target too small"）/ `(e)` 目录只有 `.hidden.md` dotfile（dotfile 不算数，FAIL "only dotfiles"）——每种 exit 1 + stderr 红字（TTY+NO_COLOR 未设时）+ 具体缺失说明；stderr 消息含 `size-check is smoke-alarm heuristic` 脚注提醒人类验收员 | 5 个 negative fixture，结果入 `test-results.tsv` |
| AC5 | **Alex SKILL step4c 插入 + 对称白名单正则**：新 step 在 step4 与 step7 之间；**SKILL 中 slug 提取正则 `^(HANDOFF\|COMPLETION)-\d{8}-([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])\.md$`**——与脚本白名单对称，SKILL 层就拒非法 slug（不是等脚本 exit 1 才发现）；提取失败时 Alex 验收报告记"Layer 2 audit N/A: non-standard handoff filename"不阻塞 | `grep -n 'step4c\|step4:\|step7:' .claude/skills/alex/SKILL.md` + 正则字面匹配 |
| AC6 | **Dogfood — 基于 fixture 非自证**：Blake 构造 2 个独立 fixture 目录（**不是**本 handoff 的真实 slug）——`.tad/evidence/fixtures/layer2-audit/dogfood-pass/` 塞 1 个 ≥200B 假 review；`.tad/evidence/fixtures/layer2-audit/dogfood-fail/` 留空——分别用临时 slug `dogfood-pass` / `dogfood-fail` 跑脚本，验证 exit code + stderr 内容与预期一致，**不依赖本 handoff 自己的 reviews 目录**。本 handoff 真实 slug 的 reviews 路径由 AC7 contract 担保 | `test-results.tsv` 记录 dogfood-pass exit 0 stderr 空 + dogfood-fail exit 1 stderr 含 "directory missing" |
| AC7 | **Alex↔Blake Slug Contract（新增）**：Blake 写 reviewer artifacts 时 **MUST** 用路径 `.tad/evidence/reviews/blake/<exact-slug-from-handoff-filename>/`——slug 严格取自当前 handoff 文件名正则捕获组 $2（`HANDOFF-YYYYMMDD-<slug>.md`），**不可**缩写、不可加后缀、不可改大小写。本 handoff 的 slug = `layer2-audit`（路径应为 `.tad/evidence/reviews/blake/layer2-audit/`）。Contract 明文写入 Blake SKILL `completion_protocol.step3c` 的 Evidence Manifest 说明段 | 本 handoff 的 Blake review 落在 `.tad/evidence/reviews/blake/layer2-audit/` + `grep 'slug-from-handoff-filename' .claude/skills/blake/SKILL.md` ≥1 |
| AC8 | **零 hook 注册**：`git diff .claude/settings.json` 无输出；脚本**不**在 `.claude/settings.json` 任何 matcher 中被引用 | `git diff` + `grep -c layer2-audit .claude/settings.json` = 0 |

## 4. Required Evidence Manifest

```yaml
required_evidence:
  expert_review:
    - path: ".tad/evidence/reviews/blake/layer2-audit/code-reviewer.md"
      min_bytes: 500
      # Express 最低 1 专家 (AR-001)
  completion:
    - path: ".tad/active/handoffs/COMPLETION-20260415-layer2-audit.md"
      anchor_regex: "^Overall: (PASS|FAIL|PARTIAL-GO)$"
  gate_verdict:
    - path: ".tad/evidence/gates/layer2-audit/gate3-verdict.tsv"
      must_contain: "PASS"
  fixtures:
    - path: ".tad/evidence/fixtures/layer2-audit/test-results.tsv"
      # 6 条 test case 结果（AC2-AC4 覆盖的 smoke + negative）
```

## 5. Out of Scope

- 不改 `.claude/settings.json`
- 不创建 PreToolUse hook / UserPromptSubmit hook
- 不引入新依赖（jq/yq/perl/python 全免）
- 不做 Blake SKILL 修改（Blake 不需要知道 Alex 在背后审计）
- 不做 Gate 3 自动化集成（只改 Gate 4 / Alex *accept）
- 不做历史 handoff 回溯审计

## 6. Blake Implementation Phases

### Phase A（~15 min）
1. 写 `.tad/hooks/lib/layer2-audit.sh`（AC1-AC4）
2. 建 6 个 smoke/negative test fixture，跑一遍结果入 `test-results.tsv`

### Phase B（~15 min）
3. 编辑 `.claude/skills/alex/SKILL.md` 插入 step4c（AC5）
4. 本地 YAML lint 确认 SKILL 语法完整

### Phase C（~15 min）
5. Layer 2 review（min 1 expert: code-reviewer）——focus 脚本 portability (macOS/Linux stat)、ANSI 颜色降级、slug 白名单注入防护
6. 整合 P0 发现

### Phase D（~10 min）
7. 写 COMPLETION report + Gate 3 verdict
8. Message to Alex

## 7. 📚 Project Knowledge — Blake 必读

| # | 条目 | Why 相关 |
|---|------|---------|
| 1 | **Hook Shell Portability: No grep -P on macOS - 2026-04-03** | `layer2-audit.sh` 的 stat 调用必须 portable（`stat -f%z` BSD / `stat -c%s` GNU），用 `stat --version &>/dev/null && ... || ...` 检测 |
| 2 | **Mechanical Enforcement Rejected on Single-User CLI - 2026-04-15** | 本 handoff 是该决策的配套替代方案——不碰 hook、不 register 到 settings.json、不阻塞验收 |
| 3 | **Express Handoff is NOT Review-Exemption (AR-001) - 2026-04-14** | Express ≠ no review；必须跑 ≥1 code-reviewer，不可跳 |

## 8. Gate 2 (Alex 自填)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 脚本接口 + SKILL 接入点 + slug 提取规则全部定义 |
| Components Specified | ✅ | 1 脚本 + 1 SKILL 编辑 + 6 fixture |
| Functions Verified | ✅ | `stat` / `find` / ANSI escape 均为标准 POSIX 工具 |
| AC Testable | ✅ | 7 条 AC 全有具体验证方法 |
| No Dogfood Paradox Risk | ✅ | 无 hook 注册、无 fail-closed 依赖栈、Alex bash 调用失败时正常降级 |

**Gate 2 verdict (v1)**：⚠️ CONDITIONAL PASS → **v2 post-review**：✅ PASS

（2 专家并行审：code-reviewer 2 P0 / security-auditor 0 P0 + 3 MUST P1 + 其他 P1/P2——9 项 resolution map 详见 §9.1；hook-layer 回引建议全部 reject 与 2026-04-15 决策一致）

v1→v2 AC 调整：原 7 条 → 8 条（新增 AC7 Slug Contract；原 AC7 零 hook 注册 → AC8）

## 9. Expert Review Status

Alex-side parallel expert review 已完成（global minimum_experts: 2 仍适用；AR-001 的"≥1" 是 floor 非 override）。

| Reviewer | Verdict (v1) | P0 | 整合状态 |
|----------|--------------|-----|---------|
| code-reviewer | CONDITIONAL PASS | 2 | ✅ 全部整合到 v2 |
| security-auditor | CONDITIONAL PASS | 0 (3 MUST-level P1) | ✅ 3 MUST 全部整合 |

### 9.1 Resolution Map

| # | Source | Issue | Resolution |
|---|--------|-------|-----------|
| 1 | code-P0-1 | AC6 dogfood 自证（本 handoff 的 review 目录存在=PASS 恒真） | AC6 改为 fixture-based（dogfood-pass / dogfood-fail 两独立目录），不依赖本 handoff 真实 slug |
| 2 | code-P0-2 | Alex 提 slug vs Blake 写 review 目录名无契约 | 新增 **AC7 Slug Contract**：Blake MUST 用 handoff 文件名正则 $2 作为 review 目录名，写进 Blake SKILL |
| 3 | sec-P1-1 (MUST) | 白名单 `[a-zA-Z0-9_-]+` 未锚定；首字符 `-` 会被 find/stat 当 flag | AC2 正则改为 `^[a-zA-Z0-9_]([a-zA-Z0-9_-]*[a-zA-Z0-9_])?$` 严格锚定+禁首尾 `-` |
| 4 | sec-P1-4 (MUST) | SKILL 中 `(.+)` greedy 与脚本白名单不对称 | AC5 SKILL 正则对称白名单 `([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])`，SKILL 层预先拒非法 slug |
| 5 | sec-P2-3 (MUST) | 脚本缺 bash 卫生头 | AC1 强制 `set -euo pipefail` + `IFS=$'\n\t'` |
| 6 | sec-P1-3 | `--` 分隔符 + path 前缀 guard | AC2 明文要求所有 find/stat 调用用 `--` 隔离 |
| 7 | sec-P1-2 | Slug 回显未长度截断 | AC2 stderr 回显 `${slug:0:64}` 截断 |
| 8 | sec-P1-5 | Fixture 缺 symlink + dotfile | AC4 扩展到 5 fixture（加 symlink + dotfile-only） |
| 9 | code-P1 | 500 字节过严 / stderr 要干净 / stat 硬编码 flavor | AC3 降到 200B + PASS 时 stderr 空 + AC1 runtime stat 检测 |

### 9.2 Explicit Rejections（保留 out-of-scope）

security-auditor 明确 reject 回引机械强制/HMAC/fail-closed——与 2026-04-15 决策一致，**不整合**。

---

**Alex 签名**：范围清晰、无机械强制、替代监督层就位。Blake 可独立完成。
