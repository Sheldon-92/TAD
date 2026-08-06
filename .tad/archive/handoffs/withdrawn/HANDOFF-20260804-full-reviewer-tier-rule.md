---
task_type: yaml
e2e_required: no
research_required: no
---

# Handoff Document for Agent B (Blake)
## full 通道 reviewer 的 model 纪律（不含档位强制）

**Created**: 2026-08-04
**Version**: v3（人裁定推翻前提后重写 — 去掉档位强制，只保留兼容性纪律）
**Author**: Alex (Solution Lead)
**Channel**: full TAD（**强制** — R0 判定 F1：`gate_ac_reviewer`，`override_allowed: false`）
**Priority**: P2
**Gate 2 Status**: ⬚ R3 PENDING（v3 为重写，需重新审）

---

## 1. Task Overview

### 1.1 ⚠️ v3 的前提变更（人裁定 2026-08-04）

v1/v2 的目标是把 lite 的**强档要求**移植进 full。Gate 2 R2 发现：`strong_tier` 的定义
（强档 = 旗舰档 opus/fable/gpt-5/v4-pro；小档 = haiku/mini/v4-flash）**把 Sonnet 类均衡档
漏在两份清单之外**，而兜底条款是"判定不确定 → 按非强档 → 走三选一"。R2 的 reviewer
自报 `model=claude-sonnet-5`，**它自己就是被该规则覆盖的 Gate 2 reviewer** —— 按 v2 规则，
那次审查本应触发三选一。交叉印证：`acceptance-protocol.md:123` 逐字称 Sonnet 为 `mid-tier`。

人裁定：**「因为我们要兼容各种模型和 harness 工具，不用非要调用强档」**。

**接受，且方向正确**：TAD 的目标是跨 harness/模型通用。一条"reviewer 必须是旗舰档"的规则
本身反兼容 —— 它把有旗舰档权限的用户和其他人分成两等，后者永久卡在三选一里，
撞 L1「高噪声 gate 训练操作者忽略它」。

**随之作废的先前裁定**（均为"强档要求"的下游，v3 不再涉及）：
「一单一次 / 一个 provenance 上下文一次」、「full 通道全部 reviewer 算生产关键」。

### 1.2 但事故里有一半不该跟着扔

2026-08-04 evidence-replayability-check 单，full Blake 在 alias-mapped（DeepSeek 中转）会话里
给 Agent tool 传了 `model: opus`。两名 reviewer env 实证 `ANTHROPIC_MODEL=deepseek-v4-flash`。

**实际错误不是"没用强档"，是这三条：**

| # | 错误 | v3 是否处置 |
|---|---|---|
| 1 | 在 alias-mapped 路由上传 `model` 覆盖 —— **无效**（聚合器任意重映射）且**污染证据**（留下看似强档的 SKU 名） | ✅ 本单核心 |
| 2 | 写死 SKU 名 `opus` —— 正是 2026-08-03 词汇通用化单消灭的东西 | ✅ 本单守卫 |
| 3 | 档位凭据取自**请求**而非 reviewer **实际自报** | ✅ 本单明确 |

框架实测 **0 处 SKU 硬编码**（`grep -cE 'opus|sonnet|haiku|fable|gpt-5|v4-pro|v4-flash'`
在 blake、alex 各 0）—— 问题是 full **缺规则**，agent 在真空里即兴，即兴就抓见过的 SKU 名。

### 1.3 Intent

**不强制任何档位。** 只要求：不做无效且污染证据的 model 覆盖、不写死 SKU、
档位以实际自报为准并可事后审计。经济档 reviewer 只**留痕**不**拦截**
（smoke alarm not fire suppressor —— 与 ①号单的 advisory 同型）。

---

## 2. Grounding（Alex 实测；G1–G6 经 Gate 2 R1+R2 四名专家独立复核字节级精确）

| # | 文件 | 行 | 逐字 / 事实 |
|---|------|-----|------|
| G1 | `blake/SKILL.md` | 919 / **928** / 966 | `      3_layer2_loop:` / `        priority_groups:`（**缩进 8 空格**）/ `      4_gate3_v2:`（各唯一） |
| G2 | `blake/SKILL.md` | 1414–1415 | `REQUIRED OUTPUT (first line of every reviewer report):` + `Model: harness={claude-code\|codex\|other} \| model={运行时自报 ID} \| route={host\|native\|unknown}` ← **既有凭证条款，逐字保留，本单依赖它** |
| G3 | `blake/SKILL.md` | 1420–1423 | capture-by-harness 配方（含 `agents/*.toml`、`缺 env/文件/键 = native fail-soft`）← 既有，本单**引用不复制** |
| G4 | `alex/SKILL.md` | 681 | `cross_model_awareness:` —— 该串全文 **4 处**（37/136/681/705），**`^cross_model_awareness:` 顶格唯一 = 1**。锚点 MUST 带 `^` |
| G5 | `handoff-creation-protocol.md` | 788–789 | 同 G2（Alex 侧副本，1 处） |
| G6 | `handoff-creation-protocol.md` | 530 / **537** | `    step3:` / `    step3_agent_team:` —— 后者 `activation` 逐字 `This step REPLACES step3 when ALL conditions met: 1. process_depth in ["full","standard"] 2. Agent Teams feature is available (env var set)`；实测 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` ⇒ **full 通道下只钉 step3 = 钉在死分支，两处都要改** |

**基线计数**（判别力依据，四名专家各自复现）：
`reviewer_model_discipline:` 在 blake、alex 各 **0**；`MUST NOT 传 model 覆盖` 各 **0**；
`REQUIRED OUTPUT (first line` 在 blake、hcp 各 **1**；
**SKU 名在 blake、alex 各 0** ← AC5 满格判别力。
⚠️ `agents/*.toml` 在 blake **已有 1 处**（G3，L1420，与本单无关）→ 任何针对它的 AC 必须带位置约束（R2 P1）。

---

## 3. Design

### 3.1 规则文本（两个角色 SKILL 各一份）

> 与 lite 的关系：lite 的「Reviewer 档位规则」含**档位强制 + 三选一 + 降级授权**三部分，
> 本单**故意不移植**（人裁定 §1.1）。只取其中与兼容性相关的纪律，并新增经济档 advisory。
> ⚠️ 做 lite↔full 漂移比对时**不得**把档位强制补回来 —— 这是有意的通道差异。

```yaml
reviewer_model_discipline:
  # full 通道 reviewer 的 model 纪律。不强制档位（人裁定 2026-08-04：跨模型/harness 兼容优先）。
  no_tier_mandate: "本通道不要求 reviewer 达到任何特定档位。经济档 reviewer 只留痕不拦截——档位信息用于事后审计，不作为 gate 条件"
  no_sku_hardcode: "档位按能力档位理解，不按 SKU。任何示例名（旗舰档如 opus/fable/gpt-5/v4-pro；经济档如 haiku、gpt-*-mini、v4-flash）随版本演进，只可出现在本块的说明文字里，MUST NOT 进入任何 spawn 调用或判定表达式"
  route_determination: "spawn 前对自身会话判定 route，复用既有 REQUIRED OUTPUT 条款的 capture-by-harness 配方（本 SKILL 内已有，勿复制）。env/文件/键存在且解析出非 native host → route = 该 host（等同 alias-mapped）；缺 env/文件/键 = native fail-soft；无法确定 → route=unknown，按 alias-mapped 保守处理"
  no_model_override_on_alias_mapped: "route 为 alias-mapped 或 unknown 时 MUST NOT 向 sub-agent 传 model 覆盖——聚合器可任意重映射，覆盖无效，且会在证据里留下看似强档的 SKU 名（2026-08-04 实测：请求 opus，reviewer env 自报 deepseek-v4-flash）。route=native 时允许显式指定，但仍受 no_sku_hardcode 约束"
  provenance: "档位以 reviewer **实际自报**的 Model 行为准，不以请求的 SKU 为准（既有 REQUIRED OUTPUT 条款提供该行）"
  economy_tier_advisory: "若 reviewer 自报的 model 属经济档，在 Completion 记一行 advisory：`REVIEWER-ECONOMY-TIER: {model}`——非阻塞，仅留痕。依据 2026-08-02 实测：经济档审查漏掉了系统性缺陷（retry-budget 比例导致的静默丢失），该风险已知且由人承担"
```

---

## 4. 文件清单

| 文件 | 改动 |
|------|------|
| `.claude/skills/blake/SKILL.md` | 1 |
| `.claude/skills/alex/SKILL.md` | 2 |
| `.claude/skills/alex/references/handoff-creation-protocol.md` | 3a + 3b |
| `.agents/skills/{blake,alex}/SKILL.md` + `.agents/skills/alex/references/handoff-creation-protocol.md` | 4（parity 自动生成，**不手改**） |

**Non-Goals**：
- ❌ 改 `blake-lite` / `alex-lite`（lite 保留自己的档位强制，本单不动它）
- ❌ 改既有 REQUIRED OUTPUT / capture-by-harness 条款（G2/G3/G5 逐字保留，本单**引用**它们）
- ❌ 改 `gate/SKILL.md` / `acceptance-protocol.md`（Gate 4 面见 §7 队列项）
- ❌ 直接编辑 `.agents/`
- ❌ **任何 SKU 名进入 `no_sku_hardcode` 值行之外的位置**（头号 Non-Goal，AC5 守卫）
- ❌ 引入任何档位**强制**（人裁定；advisory 留痕 ≠ 强制）
- ❌ `git push`（本地 commit 允许且必需）

---

## 6. Implementation Steps

> ⚠️ 本节是 Layer 2 reviewer 的 REQUIRED READ 之一（`blake/SKILL.md:1401` 模板规定读 §6 + §9 且禁止扩读）。

**改动 1 — `blake/SKILL.md`：`priority_groups:`（G1，L928）之前**
插入 §3.1 的 `reviewer_model_discipline:` 块，**精确 8 空格缩进**（与 `priority_groups:` 同级）。

**改动 2 — `alex/SKILL.md`：`^cross_model_awareness:`（G4，L681）之前**
插入同一份块，**顶格**。锚点 MUST 用 `^cross_model_awareness:`（该串 4 处，顶格唯一）。

**改动 3a — `handoff-creation-protocol.md` step3（G6，L530–536 区间内）**
**改动 3b — `handoff-creation-protocol.md` step3_agent_team（G6，L537 起区间内）** ⚠️ **两处都要**
各追加一行：
```
      reviewer_model: "spawn 前按本 SKILL 的 reviewer_model_discipline 处理：先判 route；alias-mapped/unknown MUST NOT 传 model 覆盖；档位以 reviewer 实际自报为准，不强制档位"
```
⚠️ 3b 不可省：`step3_agent_team` 在 full 通道整体取代 step3（G6 逐字 + env 实测 = 1）。

**改动 4 — 镜像（自动）**：`bash .tad/hooks/lib/release-verify.sh parity --fix .`

---

## 7. Blake 执行纪律

1. 两块**去缩进后逐字相同**（AC6 验证）——缩进必然不同，不是字节相同。
2. **不改 lite**；**不改既有 REQUIRED OUTPUT / capture 条款**（本单引用它们，不复制）。
3. **不手改 `.agents/`**；**禁 `rg`**。
4. **`git add` 钉死显式路径，不用 `-A`**；证据生成完再 commit，**此后不得再补 commit**
   （AC7(c) 血径断言会 FAIL —— 见 `patterns/ac-verification.md` 2026-08-04 条目）。
5. **允许本地 commit，禁止 `git push`**。
6. Layer 2 至少 2 名 distinct reviewer。**本单 dogfood**：跑 `route_determination` 判定自身 route，
   原始输出落证据；若 route≠native，验证自己**没有**传 model 覆盖（AC8）。

**队列项（本单不做）**：Gate 4 面的 reviewer model 纪律 —— `gate/SKILL.md` 的
`Required_Judge` + 四个 structural subagent 均无自报条款（实测 `REQUIRED OUTPUT` 计数 0/0）。
R2 专家指出其中 judge（校准冻结）与 structural subagent 是**两类问题**，应拆开处理。已入 NEXT.md ⑤。

---

## 8. Expert Review Status

### v1/v2 历史（前提已被推翻，仅存追溯）

| 轮 | Reviewer | verdict | P0 |
|---|---|---|---|
| R1 | backend-architect / code-reviewer | CONDITIONAL / **FAIL** | 7 |
| R2 | spec-compliance-reviewer / bug-hunter | CONDITIONAL / CONDITIONAL | 1 |

R2 的那个 P0（`strong_tier` 对 Sonnet 未定义，reviewer 用自己当证据）**直接导致人推翻前提** →
v3 去掉档位强制。v1/v2 中围绕"强档要求"的全部机制（三选一、REVIEWER-TIER-DEGRADED、
grant_scope / grant_not_inherited / grant_direction、provenance 三元组继承）**整体删除**，
其对应的 P0/P1 处置随之失效，不再列出。

**v3 继承下来的、与前提无关的修复**（R1/R2 成果，逐条保留）：
`^cross_model_awareness:` 顶格锚点（不带 `^` 会让正确实现 FALSE FAIL，dry-run 证明）｜
改动 3 拆 3a/3b（`step3_agent_team` 死分支，env 实测）｜
AC 区间收紧至 `priority_groups` + 精确缩进断言（宽区间对 16 空格错误缩进会误 PASS，dry-run 证明）｜
SKU 遏制 AC（头号 Non-Goal 原本零覆盖）｜
去缩进 diff AC（存在性 grep 证明不了"两块相同"，实测 10 个词塞进一行注释即全绿）｜
AC8(b) baseline 钉死 `31a96aa`（实测 `7442bb7` 之后 lite 有 308 行改动）｜
`agents/*.toml` 自泄漏（blake:1420 既有，AC 须带位置约束）｜
§6 = Implementation Steps（reviewer 模板只读 §6+§9 且禁止扩读）。

### Round 3

⬚ PENDING — v3 是重写（规则块从 8 键降为 6 键、语义从"强制"变"纪律+advisory"），需重新审。

---

## 9. Acceptance Criteria

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

> 全部 `grep -F`（禁 `rg`）。`<b>`=`.claude/skills/blake/SKILL.md`，`<a>`=`.claude/skills/alex/SKILL.md`，
> `<h>`=`.claude/skills/alex/references/handoff-creation-protocol.md`。

| AC | Verification Method | Expected Evidence |
|---|---|---|
| AC1 | `ln=$(grep -nF 'reviewer_model_discipline:' <b>\|cut -d: -f1)`；`a=$(grep -n '^      3_layer2_loop:' <b>\|cut -d: -f1)`；`b=$(grep -n '^        priority_groups:' <b>\|cut -d: -f1)`；断言 `a<ln && ln<b`。**且** `grep -c '^        reviewer_model_discipline:$' <b>` == 1 | 两者成立。⚠️ 上界必须是 `priority_groups`(928) 不是 `4_gate3_v2`(966)，且必须有精确 8 空格断言——R1 dry-run 证明宽区间会放行 16 空格的错误嵌套 |
| AC2 | `ln=$(grep -nF 'reviewer_model_discipline:' <a>\|cut -d: -f1)`；`c=$(grep -n '^cross_model_awareness:' <a>\|cut -d: -f1)`；断言 `[ -n "$c" ] && [ "$ln" -lt "$c" ]`。**且** `grep -c '^reviewer_model_discipline:$' <a>` == 1 | 两者成立。⚠️ 锚点 MUST 带 `^`（该串 4 处；不带 `^` 会让正确实现 FALSE FAIL，R1 dry-run 证明） |
| AC3 | 两个 SKILL **各自**命中六键：`no_tier_mandate`、`no_sku_hardcode`、`route_determination`、`no_model_override_on_alias_mapped`、`provenance`、`economy_tier_advisory` | 各 6/6 |
| AC4 | 两个 SKILL 各自命中：`不要求 reviewer 达到任何特定档位`、`MUST NOT 向 sub-agent 传 model 覆盖`、`实际自报`、`REVIEWER-ECONOMY-TIER`、`非阻塞`、`按 alias-mapped 保守处理` | 各 6/6（语义核心，防抄成空壳）。⚠️ **不查 `agents/*.toml`**——该串在 `<b>`:1420 既有（G3），纯存在性检查必自泄漏（R2 P1）；本单 `route_determination` 改为**引用**既有配方，不复制其措辞 |
| AC5 | **头号 Non-Goal 守卫**：`for f in <b> <a>; do grep -nE 'opus\|sonnet\|haiku\|fable\|gpt-5\|v4-pro\|v4-flash' $f; done` —— 每条命中的行号 `l` 必须满足 `l >= s`（`s` = 该文件 `no_sku_hardcode:` 所在行）且 `l < e`（`e` = 其后第一个同缩进 key 行） | baseline **0 行命中**（实测）。⚠️ 下界用 **`>=`**：`no_sku_hardcode` 的值是单行标量，SKU 名就落在 key 自身那一行；严格 `>` 会让合规实现 FALSE FAIL（R2 P1-1 最小复现证明） |
| AC6 | 两块**去缩进后逐字相同**：各自 `awk` 抽出 `reviewer_model_discipline:` 起至下一个同缩进 key 前的区块 → `sed 's/^ *//'` → `diff` | 空输出。⚠️ AC3/AC4 证明不了这一点（R1 实测：把关键词塞进一行注释即全绿） |
| AC7 | (a) `grep -Fq 'reviewer_model:' <h>` 且行号落在 `^    step3:` 与 `^    step3_agent_team:` 之间；(b) `<h>` 中 `reviewer_model:` **出现 2 次**且第二处行号 > `^    step3_agent_team:` 行号；(c) commit 血径 `git show --name-status --format='' HEAD \| awk '$1=="M"{print $2}' \| LC_ALL=C sort` 恰为本单 6 个文件 | 三者成立。⚠️ (b) 缺失 = 规则钉在死分支（G6） |
| AC8 | **既有条款存活 + 无附带损伤**：(a) `grep -cF 'REQUIRED OUTPUT (first line of every reviewer report):'` 在 `<b>`==1 且在 `<h>`==1；(b) lite sentinel 四处 `awk '/ESCALATION-LIST-BEGIN/,/ESCALATION-LIST-END/' \| md5 \| sort -u` **恰一行** == `4c55bcb6563f24dc78449fb19ff76067`；(c) `git diff --stat 31a96aa -- .claude/skills/blake-lite/ .claude/skills/alex-lite/ .agents/skills/blake-lite/ .agents/skills/alex-lite/` **为空** | 三者成立。⚠️ (c) baseline 钉死 `31a96aa`（实测该点 lite 四目录 diff = 0；误钉 `7442bb7` 会有 308 行改动使 AC 在起点即 FAIL） |
| AC9 | **dogfood**：Blake 在 Completion 记录本会话 `route_determination` 的**原始输出**；若 route≠native，附证据证明 spawn 调用**未传 model 覆盖**；各 reviewer 的自报 Model 行抄进 Completion；自报为经济档时须有 `REVIEWER-ECONOMY-TIER:` advisory 行 | 原始输出落 `.tad/evidence/acceptance-tests/full-reviewer-model-discipline/`。**判别力**：不留 route 判定原始输出即 FAIL（否则"route 是 native"不可证伪） |
| AC10 | parity：**先** `parity .` 存证当前 drift，**再** `parity --fix .`，**再** `parity .` PASS；`cmp -s` 三对文件全部退出 0 | 三次原始输出全部存证 |

**Required Evidence Manifest**：
- `.tad/evidence/acceptance-tests/full-reviewer-model-discipline/` —— AC1–AC10 原始输出
- `.tad/evidence/reviews/blake/full-reviewer-model-discipline/` —— Layer 2 reviewer 产物（slug 逐字）

---

## 10. 重要提示

### 10.1 关键警告

- **示例 SKU 名只能出现在 `no_sku_hardcode` 的值行里**，不得进入任何其他位置（AC5 是唯一守卫）。
- **不得引入任何档位强制**。人已裁定跨模型/harness 兼容优先；advisory 留痕 ≠ 强制。

### 10.2 已知约束与残余风险

- **经济档 reviewer 的盲区风险由人承担且已知**：2026-08-02 实测，经济档审查漏掉了系统性缺陷
  （retry-budget 比例导致的静默丢失，当时在生产运行）。v3 只留痕不拦截 —— 这是人在
  「兼容性 vs 档位保障」之间的明确取舍。`REVIEWER-ECONOMY-TIER:` advisory 使该风险可事后统计；
  若累积数据显示经济档审查的逃逸率显著更高，应带实测数据重新评估，而非现在就假设需要强制。
- **lite ↔ full 通道差异是有意的**：lite 保留档位强制 + 三选一，full 不要。
  做漂移比对时**不得**把 lite 的档位强制补进 full。
- **Gate 4 面未覆盖**（§7 队列项）：`gate/SKILL.md` 的 judge + 四个 structural subagent
  均无自报条款。R2 专家指出 judge（校准冻结）与 structural subagent 是两类问题，应拆开。
- **`deny_ref: "L684"` 会被改动 2 推歪**：alex frontmatter 中唯一仍准确的行号锚点。见 B4。

---

## 11. 预注册降级分支

| # | 触发 | 处置 |
|---|------|------|
| B1 | `priority_groups` 前缩进层级与预期（8 空格）不符 | 停，报告人；不自行改写 Layer 2 结构 |
| B2 | `alex/SKILL.md` 顶格插入破坏 YAML 解析 | 停，报告人；**不得**为过 AC 改成非顶格 |
| B3 | `parity --fix` 后 cmp 不一致 | 停，报告人；不得手改 `.agents/` |
| B4 | 改动 2 后 `deny_ref: "L684"` 失准 | 同 commit 内更新为新行号，或在 Completion 记为已知债务；不得为规避此问题改成非顶格 |
| B5 | 本单自身在 alias-mapped 会话执行 | 按本单正在立的规矩先行执行（自举：规则文本随 handoff 送达）：**MUST NOT 传 model 覆盖**，照常 spawn，reviewer 自报什么就记什么 |

---

*TAD v2.39.0 — full channel（F1 强制）— v3（人裁定后重写：去档位强制）*
