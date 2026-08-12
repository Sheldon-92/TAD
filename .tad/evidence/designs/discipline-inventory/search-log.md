# Phase B — 留痕检索日志（search-log.md）

> 方法：每条纪律 3 关键词 × 4 语料（principles.md / patterns/ / incidents/ / violations.log）+ 归档语料（有界 ≤5）。
> 命中数为 `command grep -rn <kw> <corpus> | wc -l` 的行数。
> 语料为 `.tad/project-knowledge/`（183 条）+ incidents 25 + violations.log 2 行。
> ⚠️ 关键词检索有固有局限：中文纪律名（如「角色分离」「约束准入」）在语料中以英文/其它形式出现时，机械 grep 会 0 命中——正文逐条标注「关键词盲区」，实例载体以直接通读语料为准（AC11 阳性对照即为此设）。
> **AC10 闭合声明**：判为第 2/3/4 类的行（D07 知识评估、D09 配对测试、D12 约束准入），其四语料检索已用**实例聚焦关键词**重跑并确认全空（`verify.py empty` 可机械复核）。D08 跨模型审查原判第 3 类，经实例聚焦检索找到在场生效载体后改判第 1 类（非「全空」行）。

## D01 需求澄清

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 苏格拉底 | 0 | 0 | 0 | 0 | 0 |
| Socratic | 0 | 3 | 0 | 0 | 5 |
| 目标锚 | 0 | 0 | 0 | 0 | 0 |

> 关键词盲区：中文「苏格拉底」0 命中，英文 "Socratic" patterns=3。实例载体不在四语料，而在 Epic SC6（`.tad/active/epics/EPIC-20260812-discipline-weight-separation.md#L74`）。

## D02 需求闸

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| Gate 1 | 2 | 0 | 0 | 0 | 0 |
| 需求清晰 | 0 | 0 | 0 | 0 | 0 |
| 需求闸 | 0 | 0 | 0 | 0 | 0 |

> 关键词盲区：「需求闸」「需求清晰」0 命中，语料用英文 "Gate 1"。实例与 D01 同根（假设被当成批准）。

## D03 重量裁定

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| Adaptive Complexity | 0 | 0 | 0 | 0 | 0 |
| 重量裁定 | 0 | 0 | 0 | 0 | 0 |
| 升级理由 | 0 | 0 | 0 | 0 | 0 |

> 全部 0 命中。实例载体在 Epic 地基表（`.tad/active/epics/EPIC-20260812-discipline-weight-separation.md#L75`「本 Epic 5 单：不可撤销的对外发布 8 版 7 轮；可回滚的本机升级 4 版 3 轮」）。

## D04 专家审查

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 专家审查 | 0 | 0 | 0 | 0 | 2 |
| expert review | 2 | 18 | 1 | 0 | 5 |
| min 2 | 0 | 0 | 0 | 0 | 1 |

> 强命中。在场生效型实例载体：`principles.md#L33`「expert review found 4 P0 on a 15-min express edit」。

## D05 门禁

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| Gate 3 | 4 | 32 | 0 | 0 | 5 |
| 门禁 | 0 | 0 | 0 | 0 | 0 |
| Gate 4 | 3 | 32 | 4 | 0 | 5 |

> 强命中。在场生效型实例载体：L0.5 机械准入拦下三轮对抗审查（`LITE-20260811-2254-dependency-ops-skill.md` L561-566）。

## D06 启动扫描

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| urgent_security | 0 | 0 | 0 | 0 | 1 |
| 启动扫描 | 0 | 0 | 0 | 0 | 0 |
| 依赖演进 | 0 | 1 | 0 | 0 | 0 |

> 关键词盲区：实例载体在 EPIC-20260809（非四语料）`#L47`「`urgent_security` 检测停跑 28 天，期间 `gh` 的 4 个安全漏洞」。

## D07 知识评估

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 教训流失 | 0 | 0 | 0 | 0 | 0 |
| 知识流失 | 0 | 0 | 0 | 0 | 0 |
| 未蒸馏 | 0 | 0 | 0 | 0 | 0 |

> 实例聚焦关键词四语料全空（教训流失/知识流失/未蒸馏）。原检索「蒸馏」「Knowledge Assessment」四语料亦为 0（仅归档命中，说明 KA 作为流程存在但无「防住过教训流失」的实例）。

## D08 跨模型审查

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 跨模型审查 | 0 | 0 | 0 | 0 | 0 |
| cross-model review | 0 | 4 | 0 | 0 | 0 |
| 同模型盲区 | 0 | 0 | 0 | 0 | 0 |

> 实例聚焦检索找到在场生效载体：`pack-evaluation.md#L20`「now quantified at ~44 catches the same-model loop missed」——Codex 跨模型审查浮出约 44 处同模型循环漏掉的错误。原检索「Codex」58 命中为平台名噪音，本次改用实例聚焦关键词，纠正 Epic 草稿「弱实例」的低估。

## D09 配对测试

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 配对测试 | 0 | 0 | 0 | 0 | 0 |
| pair testing | 0 | 0 | 0 | 0 | 2 |
| 真机测试 | 0 | 0 | 0 | 0 | 0 |

> 实例聚焦关键词四语料全空（配对测试/pair testing/真机测试），仅归档命中 2（历史提及，非实例）。

## D10 角色分离

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 角色分离 | 0 | 0 | 0 | 0 | 0 |
| Alex 写代码 | 0 | 0 | 0 | 0 | 0 |
| Terminal 隔离 | 0 | 0 | 0 | 0 | 1 |

> **关键词盲区（严重）**：三关键词全 0，但 violations.log 两条记录（2026-06-10、2026-08-02）均为角色分离的缺席致害实例。补检索：`Wrote implementation`→violations=1，`No-Code`→1，`destructive`→1。实例载体：`violations.log#L1`、`#L2` + `incidents/2026-06/alex-role-decay-direct-execution.md`。

## D11 Execution Mandate

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| Execution Mandate | 0 | 3 | 0 | 0 | 1 |
| mandate | 1 | 24 | 0 | 0 | 5 |
| 约束准入 | 0 | 2 | 0 | 0 | 3 |

> "mandate" 命中高。在场生效型实例载体：`EPIC-20260812-discipline-weight-separation.md#L83`「3b/3c/P4 实测：mandate 内零可避免运行时询问」。

## D12 约束准入

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| 约束膨胀 | 0 | 0 | 0 | 0 | 0 |
| constraint bloat | 0 | 0 | 0 | 0 | 0 |
| 约束 定价 | 0 | 0 | 0 | 0 | 0 |

> 实例聚焦关键词四语料全空（约束膨胀/constraint bloat/约束定价）。原检索「MUST」30 命中为通用词噪音。载体 `lite-constraint-ledger.md` 存在（archive=4），但无「拦住过约束膨胀」的在场生效实例——威慑型。

## D13 AC 可执行性检查

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| AC 空跑 | 0 | 0 | 0 | 0 | 0 |
| ac_dryrun | 0 | 0 | 0 | 0 | 0 |
| 可验证 | 0 | 0 | 0 | 0 | 0 |

> **关键词盲区**：三关键词全 0。缺席致害型实例载体在本 handoff §9.2 P0-4「9 条 AC 对敷衍产物 9/9 全绿（实跑证明）」。

## D14 Friction 反跳过

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| friction | 0 | 1 | 0 | 0 | 5 |
| 跳过 | 0 | 0 | 0 | 0 | 5 |
| skip reason | 0 | 0 | 0 | 0 | 0 |

> "跳过" 归档=5 但非本纪律实例。缺席致害型实例（与 D04 共享）：自审替代穿透缺陷（`alex-lite/SKILL.md#L336`「2026-07-30 首战 AC principal 缺陷即穿透自审存活至最后一道 gate」）。

## D15 Ralph Loop 自检

| 关键词 | principles | patterns | incidents | violations | 归档 |
|---|---|---|---|---|---|
| Ralph Loop | 0 | 2 | 0 | 0 | 5 |
| Layer 1 | 1 | 7 | 0 | 0 | 5 |
| 自检 | 0 | 0 | 0 | 0 | 5 |

> 在场生效型实例载体：`ac-verification.md#L24`「TypeScript type-checking failures (missing type declarations) are a recurring root cause of Blake Layer 1 failures」。
