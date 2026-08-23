---
gate3_verdict: pass
---

# COMPLETION: 退休 `*sync`，解除 TAD 与 14 个项目的关联

**From:** Blake (Terminal 2) ｜ **Handoff:** `HANDOFF-20260817-retire-sync-decouple-projects.md`
**Date:** 2026-08-22（实做）｜ **Task ID:** TASK-20260817-003
**基线 SHA:** `0566ee4d` ｜ **实现 Commit:** `65380b7c`
**Gate 3:** ✅ PASS（1 项 PARTIAL 已人裁定，见 §4）

---

## 1. 交付内容（FR-1..8 全覆盖）

| FR | 内容 | 实现 |
|---|---|---|
| FR-1 | 删 `.tad/sync-registry.yaml` | ✅ untracked 本地文件，`rm`；AC-1 = 0 |
| FR-2 | 删三协议文件（两侧 6 个） | ✅ `git rm` ×6；AC-2 = 0 |
| FR-3 | SKILL.md 三注册块 → 原位退休注释 | ✅ 注释占原块字节位（:1537-1540）；AC-3=0, AC-3b=1 |
| FR-4 | SKILL.md:3 description 去 `*sync` | ✅ AC-4 = 0 |
| FR-5 | CLAUDE.md 三处 `*sync` | ✅ 含 lite `publish+sync` 组合表述一并理顺；AC-5 = 0 |
| FR-6 | harvest-scan.sh 处置 | ✅ **方案 A**（见 §3）；AC-6 = 0 |
| FR-7 | sync-ops.md 处置 | ✅ **退休桩**（186→14 行）；见 §3 |
| FR-8 | `.agents` 镜像 | ✅ 全部 byte-identical；AC-N5 = 0 |

## 2. Acceptance Criteria — 15/15 PASS

脚本：`.tad/evidence/acceptance-tests/retire-sync-decouple-projects/AC-all-verify.sh`
报告：同目录 `acceptance-verification-report.txt`。全部 AC 双侧复核通过
（reviewer A 独立复跑：NOT_SATISFIED=0，PARTIALLY=1 仅 AC-7 as-written）。

| AC | 改前 | 改后 | 判定 |
|---|---|---|---|
| AC-1 | 1 | 0 | ✅ |
| AC-2 | 6 | 0 | ✅ |
| AC-3 | 3 | 0 | ✅ |
| AC-3b | 0 | 1 | ✅ |
| AC-4 | 1 | 0 | ✅ |
| AC-5 | 3 | 0 | ✅ |
| AC-6 | exit 0 但打印 ERROR | exit 0 + **无 ERROR** | ✅ |
| AC-7 | 13 | **3**（历史，人裁定） | ⚠️ §4 |
| AC-N1..N6 | — | 全绿 | ✅ |

## 3. 两处关键决策（§4.3/§4.4，实现前实测定案）

### §4.3 harvest-scan → **方案 A**（保留脚本，优雅跳过）

`*harvest` 在 `alex/SKILL.md:1365`（两侧）**确实调用** harvest-scan.sh →
方案 B 会连带弄坏 *harvest，故采 A。实现在 §4.1 顺序下验证：注册表删除后
脚本 exit 0、无 ERROR、打印「跨项目 harvest 已随 *sync 退休」，文本不含
`sync-registry` 字面量（该文件不在 AC-7 排除区）。原脚本缺失时打印
"ERROR" 却 exit 0——AC-6「不报错」按 stderr 无 ERROR 判定。

⚠️ **我最初的调用方查询有 bug**：`grep -rn ... | grep -v` 过滤器把
`harvest-scan.sh` 字面量的行（正是调用行）一起滤掉了，一度误判「无人调用」。
`git ls-files | xargs grep -ln` 才是权威。已入 journal（验证管道教训）。

### §4.4 sync-ops.md → **退休桩**（非删除）

`publish-protocol.md` **不引用** it；但 `release-runbook/SKILL.md:22,24`、
`alex-lite/SKILL.md:411`、`blake-lite/SKILL.md:554`（各两侧 = 6 处）引用。
**删除会产生 6 处悬空引用**（reviewer B 逐处核验）；桩是 FR-7 明示选项，
且不触碰 lite（冻结）。`*publish` 不受影响——release-runbook:22 的 publish
路由指向独立的 publish-ops.md；sync 分支落在退休说明而非 404。桩文件不含
`sync-registry` 字面量。

## 4. ⚠️ AC-7：PARTIAL — 人已裁定（2026-08-22）

AC-7 字面期望 0；删除/桩化后**恰余 3 处**，全部为**历史记录**：
`.tad/config.yaml:342`（v2.4.0 变更日志）、`.tad/migrations/2.42.0-to-2.42.0.yaml`
（2026-08-15 完成的隐私迁移记录）、`.tad/project-knowledge/patterns/ac-verification.md:668`
（五版失败课记录）。

**人裁定：历史 3 处一字不动；value-proposition.md 改为退休后定位；AC-7 排除正则
请 Alex 以 addendum 补**（把配置变更日志 / 迁移记录 / 知识教训纳入）。
Gate 3 按 PARTIAL 记录此冲突。**不改判据、不改历史、不掩盖。** reviewer A/B
双独立确认：改后计数恰为 3、三文件逐一对应裁定、value-proposition 与
harvest-scan.sh 内 `sync-registry` 计数 = 0。

## 5. 超枚举范围的两类改动（如实记录，Alex 可 Gate 4 否决）

1. **同文件命令清单清理**（`alex/SKILL.md` 内，非 FR-3/4 字面范围）：
   :1633 greeting 块与 :1673-75 命令参考表仍列 `*sync/*sync-add/*sync-list` 为可用。
   按同日 value-proposition 裁定先例（活文本广告已退休命令 = 缺陷），
   同文件补完摘除（两侧）。AC 全部仍绿；若 Alex 认为越界，可 Gate 4 打回。
2. **`alex/SKILL.md:1365` *harvest 1_scan 措辞**（reviewer B P1-3，FR-6 影响半径内）：
   原文本承诺「table + COLLISIONS 输出」，脚本已不产出 → 改为退休说明 + 仅本仓库候选。

## 6. 跨文件残留（未动——超出 FR 枚举范围，交 Alex 另单）

| 位置 | 性质 | 优先级 |
|---|---|---|
| `tad-help/SKILL.md:70-72` | 用户可见命令广告（3 个已退休命令）| **高**（最可见） |
| `publish-protocol.md:205` | *publish step5 建议 "Run *sync" | **高**（最可达，真实用户会看到） |
| `intent-router-protocol.md:152,201-203` | 路由 skip-list + standby 触发 | 低（死但惰性） |
| `workflow-completion-trigger.md:22` | 括号示例 | 低 |
| `research-notebook/SKILL.md:1153` | **假阳性**——NotebookLM 自己的 *sync，与项目同步无关，**绝不能动** | 排除 |

→ 已记 NEXT.md。建议小单：tad-help + publish-protocol。

## 7. Layer 2 专家审查（2 名独立 subagent，均非自审）

| Reviewer | 范围 | Verdict |
|---|---|---|
| A — spec-compliance | 全部 AC + NFR + §4.2/§4.1 + 镜像 | **PASS**（NOT_SATISFIED=0, PARTIALLY=1 as-written） |
| B — scope/consumer | §8.3 消费者扫描 + §8.1 硬禁 + §8.2 停止条件 + 残留分类 | **CONDITIONAL PASS**（0 P0）|

证据：`.tad/evidence/reviews/blake/retire-sync-decouple-projects/layer2-reviewer-{a,b}-*.md`

### 7.1 P1 处置（B 提出，全部已复核处置）

| # | P1 | 处置 |
|---|---|---|
| 1 | AC-7 = 3 vs 0，排除正则不全 | 人裁定解决；Alex addendum；不改源文件 |
| 2 | migrations 记录 reason 末尾「*sync continues to read the local copy」现为假 | **记录不动**（人裁定历史不碰）；已列 §6 类残留提示 |
| 3 | SKILL.md:1365 承诺不存在输出 | **已修**（两侧镜像） |
| 4 | harvest-scan.sh 缺末尾换行 | **已修**（tail -c1 → 0x0a） |

### 7.2 §8.2 停止条件 — 均未触发

- 无第四类能力被连带删除（reviewer B 确认 step4 路由表无 *sync handler 曾存在）
- `*publish` 未因 sync-ops 桩失效（独立 publish-ops.md 完好）
- harvest-scan 调用方仅 *harvest（未比预期多）；依赖注册表仅作 yq 元数据（非调用）

## 8. Friction Status

| 项 | 状态 | 说明 |
|---|---|---|
| §4.3/§4.4 决策依赖 | READY | 实现前全仓扫描定案（含修正自身 grep bug） |
| Layer 2 reviewer | READY | 2 名独立 subagent |
| AC-7 判据缺口 | PARTIAL | 人裁定 + Alex addendum 待办（非静默通过） |
| Evidence 入 git | NOT_APPLICABLE | `.tad/evidence` 被 .gitignore 覆盖（既有策略），落盘保留 |

无 BLOCKED 行。

## 9. Implementation Decisions

| # | 决策 | 上下文 | 选择 | 上报？ |
|---|---|---|---|---|
| 1 | harvest-scan 方案 | 有调用者 → B 会弄坏 *harvest | A（保留+优雅跳过） | 否 — §4.3 分支规则明确 |
| 2 | sync-ops 桩 vs 删 | 6 处引用 + lite 冻结 | 桩 | 否 — FR-7 明示选项 |
| 3 | AC-7 = 3 | 手写 AC 排除正则不全 + NFR3 冲突 | 人裁定：历史保留 | ✅ 人已答 |
| 4 | SKILL.md 同文件命令清单清理 | 活文本广告已退休命令 | 摘除（如实记录） | 记录，Gate 4 可否决 |
| 5 | SKILL.md:1365 措辞 | FR-6 影响半径内承诺不存在输出 | 改（reviewer B P1-3） | 记录 |

## 10. Reflexion History

无 reflexion（Layer 1 一次通过，零重试）。

## 11. Knowledge Assessment

**Q1: 有值得追溯的发现吗？** ✅ **Yes**

Journal: `.tad/evidence/journal/retire-sync-decouple-projects-20260822.md`

1. **grep -v 过滤器把调用方一起滤掉了** —— 验证管道先自测，`git ls-files | xargs grep -ln` 为权威。
2. **「活清单 ≠ 历史记录」** —— 退休/删除能力时三分类：活文档要改、历史轨迹保留、跨文件残留列单不擅动。
3. **「不报错」要按效果判**（stderr 无 ERROR），不只按退出码（原脚本 exit 0 也在打印 ERROR）。
4. **「tad.sh 不读注册表」只覆盖安装器** —— 全仓 `git ls-files | xargs grep` 才见 *harvest 侧消费者。

**Q2: 有可复用工作模式吗？** ❌ No —— 标准 Ralph Loop。

**Q3: 有 workflow 模式吗？** ❌ No —— 两 reviewer 并行属常规 Layer 2。

**Skillify Candidate:** No —— 本单为既有机制退役 + 文件删除，非 ≥3 步可复用新工作流。

## 12. ⚠️ 给 Gate 4 的两件事（handoff §6 原话 + 本单新增）

1. **handoff 已预告**：本单无法在实现时验证「*sync 真的从 TAD 生活中消失」——
   行为学证据在下一张真实单上取：**不再出现 *sync 出单/执行**。
2. **新增（本单特有）**：AC-7 排除正则补丁（addendum）与 §6 残留单（tad-help +
   publish-protocol 优先）需要 Alex 决定是否另立。
3. **FR-1 不可从 git 验证**（reviewer B P2-2）：注册表 untracked，删除不进 diff——
   请以 AC-1（`ls`）为唯一证据，勿在 fresh clone 上误判 FR-1 被跳过。