# Epic: Lite 成为 TAD 本体，full 逐步退场

**Created**: 2026-08-04
**Completed**: 2026-08-06
**Owner**: Alex
**Status**: ✅ **COMPLETE**（10 个 phase 交付，3 个作废，2 个移出）
**Trigger**: 2026-08-03 阅读助手在 Codex 空转烧 token；审计发现 lite 五天内自身膨胀 5.2×

## 结论（2026-08-06）

**目标达成**：lite 是默认通道，full 降为保留通道且完全可回滚。
**「迁移过程不重演 full 的膨胀」也达成**——两个 lite skill 从未因本 Epic 而变长：
`alex-lite` 319 → 334 行、`blake-lite` 371 → 378 行，净增 22 行，全部是**放开权限的例外条款**，
而同期删除的路由机器是 296 行。

**最强证据**：P5c-1 与 P6 两单**全程在 lite 内完成**，含 Epic 回填与知识蒸馏——
而这正是 P5a 之前 lite 做不到、必须启动 full（3.56× 固定读取开销）的那个动作。

**代价（诚实记录）**：≈2.85M token，其中约一半是设计侧初稿缺陷导致的返工。
详见 Known Issues 的成本结算条目——**结论是初稿质量问题，不是流程冗余**。

---

## Objective

让 lite（含 Standard 深度）成为 TAD 本体，full 退场——**且迁移过程本身不重演 full 的膨胀**。

这两半必须同时成立。只做前一半，lite 会在补齐 full 能力的过程中变成 full 2.0；
只做后一半，lite 补不齐能力，full 永远退不掉。

---

## 背景事实（审计实测，2026-08-04）

| 度量 | 出生 07-30 | 现在 08-04 | 倍数 |
|---|---|---|---|
| alex-lite 协议 | 3,852 字符 | 24,577 | 6.4× |
| blake-lite 协议 | 6,446 字符 | 29,257 | 4.5× |
| 每单强制读的外部文件 | 0 | ≈19,737（routing-contract 7,044 + brain-index 10,478 + patterns/_index 2,215） | — |
| **干活前固定读取量** | **≈10K 字符** | **≈74K 字符** | **7.4×** |
| MUST/必须/禁止/不得 | 12 | 76 | 6.3× |
| BLOCKING / 停 | 3 | 23 | 7.7× |

**对照 lite 立项目标**（HANDOFF-20260730-tad-lite-channel §1.2 原文）：
> full 流程过度消耗额度（**激活固定费 ~60K+40K** + 每周期 6-12 subagent spawn）

lite 的固定费已追上它当初要逃离的量级。

**实测基线**（`.tad/evidence/journal/tad-lite-channel-2026-07-30.md`）：
> Dogfood lite cycle completed at **~23K tokens**（8K real reviewer + 15K main flow）
> The real bottleneck is the single reviewer spawn (~8K), which is the **irreducible** cost

**膨胀机制**：七次加固 = 七次「发现漏洞 → 加约束」，**加 64 条、删 0 条**，
从未有一次问过「这条约束值不值它的每单成本」。这是增长机制问题，不是某条规则的错。

---

## Success Criteria

> ⚠️ **SC1 已于 2026-08-06 依 P4 实测拆分**（用户裁定）。原始 SC1「≤20K 字符」把
> **协议层**与**知识层**混在同一个数里，导致整个 P1–P3 都在追一个结构上不可达的目标。
> 实测后发现：按协议层单独算，目标**早已达成**；超标的是知识层，而知识层是资产不是膨胀。
> 原文保留于下方 SC1-orig 以备追溯。

| # | 判据 | 度量方式 |
|---|---|---|
| **SC1a** | **协议层**固定读取量回到出生量级 | 两 skill + CLAUDE.md ≤ **20K 字符**。**实测 2026-08-06：alex 侧 14,866 / blake 侧 16,964 → ✅ 已达标** |
| **SC1b** | **知识层**固定读取量可见、可解释 | principles + brain-index + MEMORY + patterns/_index + frontend-design = **45,256 字符**。**不设硬阈值**——知识是资产；但每一项须能说清为何必须无条件加载 |
| ~~SC1-orig~~ | ~~单位任务固定读取量 ≤ 20K 字符~~ | ❌ **已拆分**。原度量混层，且「74K」是 `wc -c` **字节**口径，与判据写的「字符」不同口径（差约 1.85 倍）。实测 chars 口径总量 = **62,220** |
| ~~SC2~~ | ~~端到端实测 ≤35K tokens~~ | ❌ **2026-08-06 废除**（判据本身是坏的，非未达标）。三条理由：<br>**(a) 基线不可信**——07-30 的 23K 中 15K 是「基于交互轮次的估算」（`cost-evidence.md` 原文自标），且被测对象是 823 字节的 `dogfood-throwaway` 玩具单。<br>**(b) 判据把两个优化方向相反的量混成一个数**——「通道固定开销」（该压到最低）与「验证成本」（该随风险上浮）。任何单一阈值都逼人做假权衡：要么为压数字砍审查，要么为保审查放弃指标。<br>**(c) 实测证伪**：2026-08-06 四单 reviewer 实测 `subagent_tokens` 合计 **≈1.41M**（12 轮）。最小的一单 P5c-1（实际改动 = 2 条 `cp`）花 **201,170**，为 SC2 上限的 5.7 倍——而那两轮抓到 3 个 P0。**这个数字大得对。**<br>→ 通道开销由 **SC1a** 承担（已达标）；验证成本**不设上限**，改为逐单记录（花了多少 / 抓到什么），使「贵得值不值」成为可判断的事。 |
| SC3 | 每条留下的约束都有事故载体 | 定价台账中 NO-CARRIER 条目 = **0** |
| SC4 | 升级清单从「4 类约 20 条」缩到保留领地 | 清单行数 ≤ **5** |
| SC5 | 新增约束必须过定价闸 | 闸存在，且 P2 之后每次改动都有台账记录 |
| SC6 | full 可退场 | 升级清单归零 + CLAUDE.md 路由改写 + full skills 归档 |


---

## Phase Map

| # | Phase | Status | 性质 | Key Deliverable |
|---|-------|--------|------|-----------------|
| 1a | 定价闸（协议） | ✅ Done | 元规则（小） | 约束准入节（51 行 ×2）+ 空台账。commit `4b29dc2`（本地未 push）。Gate 4 PASS |
| **1a-fix** | 修订扫描语义 | ✅ Done | 缺陷修复（小） | 前置过滤容错 + 逃逸检测 + 就地转终态 + 禁静默续期。commit `910ab6c`。Gate 4 PASS |
| ~~1b~~ | ~~存量定价审计（整单）~~ | ❌ **作废** | — | 两轮 Gate 2 均 FAIL，两名对抗 reviewer 各自造出全绿伪造交付（成本 30→15 分钟）。拆为 1b-1 / 1b-2 |
| **1b-2** | 7 条 DEEP 判定 | ✅ **Done** | 判断域（Alex 搜读 + 人拍板） | `.tad/evidence/audits/P1b-deep-verdicts.md`。砍除名单 = 5 NO-CARRIER + 2 SUPERSEDED |
| **1b-1** | 日期正则修复 | ✅ **Done** | 机械（Blake） | 5 文件 6 行。Gate 4 PASS（Alex 独立重算 + 功能实证：`2027-13-99`/`2027-01-32` 真报 MALFORMED）。**未 commit**，发布归人 |
| **2+3** | 砍路由机器（**合并**） | ✅ **Done** | 减法（最大一刀） | 9 文件、**296 行删除 + 31 行新增**。Gate 4 PASS（7 digest 独立重算 + **逐行读 diff** + 零越权）。固定读取量 **84K → 57.9K 字符**。未 commit |
| ~~3~~ | ~~砍档位 + provenance 降级~~ | ➡️ **并入 P2** | — | 删 Route Contract 会让 `route_level` 悬空；先补后删是浪费，且整节删除比外科手术更好验 |
| **4** | 实测 + 领地复核 | ✅ **Done** | 度量（全只读） | `.tad/evidence/audits/P4-measurements.md`（四段机械测量）。**首次真实测量本 Epic 基线**。commit `f98a295`。契约 v1 FAIL → v2 CONDITIONAL → v3 PASS（修 5 P0 + 9 P1 + 7 P2）。**走 lite 通道完成**——即 P2-AC5 的自验收 |
| **5a** | 修 alex-lite 写权限自相矛盾 | ✅ **Done** | 减法（1 行语义） | `修改 LITE 契约之外的任何文件` → 三项例外（台账 / project-knowledge / epics）。Gate 4 PASS（md5 独立重算 `cbe9a26f…`）。**契约 v1 FAIL → v2 → v3，双专家各两轮，累计修 5 P0 + 4 P1** |
| **5b** | 把 full 独占的五项能力交给 lite | ✅ **Done** | 减法（2 节替换） | 读工具编排文档 / 读 registry / 自由 spawn / 写 session-state / 人授权后 commit·push。Gate 4 PASS（两 md5 独立重算 + 前缀 md5 证节外未动 + gitignore 盲区 mtime 实证）。契约 v1→v2，双专家各两轮 |
| ~~5~~ | ~~补齐真缺口（其余）~~ | ➡️ **2026-08-06 移出本 Epic** | — | C1 已作废（改 principles 是 full/lite 共享层，不服务本 Epic 目标）。**剩余 C4（闸边际单价）/ C5（领地真实穿透）是度量而非交付**，不构成 full 退场的前置。移出，需要时另立单 |
| **5c-1** | `.agents/` 镜像补齐 P5a+P5b | ✅ **Done** | 同步（2 文件 cp） | 两平台 Forbidden 现完全一致（`cmp` 逐字节确认）。Gate 4 PASS。**全程走 lite 通道完成**——含本行的 Epic 回填，即 P5a 权限的最终验证 |
| ~~5c-2~~ | ~~`*deps` 知识缺口~~ | ❌ **2026-08-06 作废 —— 不摘，随 full 一起退场** | 决策已下 | 调查结论：`*publish` 知识在 `release-runbook` skill（26,370 chars）、`*research` 在 `.tad/guides/tool-quick-reference-alex.md`（11,270）——**两者 P5b 已放开读，不需要搬流程**。唯 `*deps` 在 full `references/deps-protocol.md`（7,497 chars，P5b 明确排除）。<br>**决策理由**：`*deps` 的价值在 **full Alex 启动时的自动扫描提示**，而 lite 没有启动扫描（那正是它轻的原因）。摘了知识 lite 也不会主动查依赖，只会在人开口时查；而人开口时一张普通 LITE 单就够。**为一个用不上的入口保留知识，正是本 Epic 一直在砍的东西。** |
| ~~5.5~~ | ~~建机械防线~~ | ➡️ **2026-08-06 移出本 Epic** | 安全 | Gate 2 实证：`permissions.deny` 为空、`Bash(git push:*)` 预授权、Write/Edit hook 默认全 ALLOW。**但这与 lite/full 无关——full 通道下同样敞开**，不是本 Epic 造成的、也不阻塞 full 退场。移出，单独立 Epic |
| **6** | full 退场 | ✅ **Done** | 收尾（路由层降级） | `CLAUDE.md` 110→123 行，四处纯增量：默认通道 = lite，full 降为**保留通道**。**三个 full skill 一字节未动**（兑现 AC4「归档而非删除、可回滚」，回滚 = `git checkout CLAUDE.md`）。Gate 4 PASS：md5 `3f3e7e39…` 独立重算 + change-shape 三断言（`numstat 17 4` / `-U0 hunk 4` / 123 行）+ §7 @import 链锚定未动。契约 v1→v2，双轮审查修 3 P0 + 5 P1 + 2 P2。**全程走 lite 通道完成** |

### Phase Dependencies

```
P1 定价闸 ──► P2 砍路由 ──► P3 砍档位 ──► P4 实测/复核 ──► P5 补缺口 ──► P6 退场
   │                                          │
   └── 必须最先：不立闸，砍完会长回来          └── 只有它能定义 P5 范围
```

**顺序的硬理由**：

- **P1 先于一切**：五天 +64 条 / 删 0 条已证明增长率。不立闸，P2 砍掉的东西会以别的形式长回来。
- **减法（P2/P3）先于加法（P5）**：08-01 那次 +250 行就是「补齐路由能力」补出来的——
  当时也是在做正确的事。不先立闸 + 减重，补齐必然重演。
- **P4 在 P5 之前**：三块保留领地（Epic 协调 / hooks·settings / release·publish·sync）
  是我从文档推的，**不是实战验过的**。先打一遍再决定补什么，避免补了不需要的。

---

## Phase Details

### Phase 1a: 定价闸（协议）

**拆分理由（2026-08-05，Gate 2 两轮后）**：原 P1 把「立闸」（协议文本，小）与
「存量审计」（34 节载体核验，判断域）压在一张单里。两轮 Gate 2 共 13 个 P0，
**几乎全部长在审计的机械核验层**（AC4/AC5/AC8），而闸本身的 AC 从 v2 起一直干净。

根因：**「Blake 有没有认真找过载体」不是可 grep 的东西**——两名 reviewer 各自演示了
绕过方式（选窄关键词即可"合法"证明无载体；写死搜索目录会漏掉路由机器自己的设计文档）。
每补一个洞就长一个新洞，因为在机械化一个判断。撞在既有原则
`AI/Human Judgment Domain Awareness`：判断域的问题交给独立视角，不塞进机器断言。

#### Scope
往 alex-lite / blake-lite 各加一节「约束准入」+ 建立**只有表头的空台账**。
**闸对新增约束立即生效**；存量回填是 P1b。**不删改任何现有约束**。

#### Output
- 两个 skill 的「约束准入」节（六态定义 + 反合理化钩子 + 到期复查规则 + 台账自身豁免）
- `.tad/evidence/audits/lite-constraint-ledger.md`：表头 + 用途说明，无数据行

#### Acceptance Criteria
见 `HANDOFF-20260805-lite-pricing-gate-protocol.md` §5（7 条，全部机械可验）

#### Files Likely Affected
`.claude/skills/{alex,blake}-lite/SKILL.md`、`.agents/` 镜像（经 `release-verify.sh parity --fix`）、
`.tad/evidence/audits/lite-constraint-ledger.md`（新建，仅表头）

---

### Phase 1a-fix: 修订 §4.1 扫描语义（P1b 的前置阻塞）

**来源**：Gate 3 code-reviewer 上报 2 条 P1，Alex 在 Gate 4 用合成台账**独立复现确认**。
Blake 行为正确——发现契约缺陷后**停下上报而非自行修改规格**。

#### 已确认缺陷（两条，同一根因）

落地的扫描命令按**整行** grep `review-by`：

```
awk -v t="$(date +%F)" '/review-by/ { if (match($0,/review-by [0-9-]+/)) {
  d=substr($0,RSTART+10,10); if (d<t) print "OVERDUE: " $0 } }' {台账}
```

| 缺陷 | 复现 |
|---|---|
| **僵旗（永久 OVERDUE）** | 决策 3 规定 append-only、RETIRED 只追加不擦原行 → 被处置掉的那条原始 `PROVISIONAL: review-by <过期日>` 行**永远留在文件里、永远被报超期** |
| **假阳性** | 约束摘要列只要含 `review-by <日期>` 字样，整行即被扫出（实测：一条 `HAS-CARRIER` 行因摘要提及旧日期而被报 OVERDUE） |

**根因是两条自家决策打架**：决策 3（append-only 不擦原行）× 扫描按整行匹配。

**后果比表面严重**：扫描输出会**单调增长且永不消失** → 一年后全是噪音 →
噪音 = 被忽略 = 等于没扫，**正好摧毁这个机制存在的理由**（与 R3/R4 论证的
"低活跃期触发退化"是两个独立的失效路径，此条更快发作）。

#### Scope
只改两个 lite skill「约束准入」节里的扫描命令语义 + `.agents/` 镜像。
**不动其余任何条款**；台账仍为空（P1b 才回填）。

#### 修订方向（不预设实现）
- 锚定**状态列**（`cut -d'|' -f9`）而非整行 —— 直接解决假阳性
- 加**处置感知**：同一 (skill, 节, 约束摘要) 若存在更晚的终态行
  （HAS-CARRIER / NO-CARRIER / SUPERSEDED / RETIRED）→ 该键不再报超期
- ⚠️ 仍须避开本机 awk 的中文比较缺陷 —— **键的比较不能用 awk 字符串相等**

#### Acceptance Criteria（写契约时展开）
必须含**合成台账探针**：僵旗场景与假阳性场景各一，修订前应命中、修订后应静默
（正负双向对照，见 P1a 教训 2）

---

### ~~Phase 1b: 存量定价审计~~ ❌ 本节已被 2026-08-05 的拆单取代

> ⚠️ **以下内容为历史记录，不再是计划。** 实际执行见 Phase Map 的 1b-1 / 1b-2 两行。
> 整批「回填台账 34/39 行」**已取消**——三版契约均被对抗 reviewer 造出全绿伪造交付，
> 且诚实执行需读 74 文件 / 约 24 万 token（单 session 装不下）。
> 判断层改由 Alex 搜读 + 人拍板（`P1b-deep-verdicts.md`），机械层只剩一处正则（已 Gate 4 PASS）。
> 台账改为**随 P2/P3/P5 自然生长**。

#### Scope（历史）
把 2026-08-04 审计（Alex 初判）核验并落成台账 34 行。**这是判断域任务，不是机械任务。**

#### 验收模型（与 P1a 根本不同）
- Blake 交：台账 34 行 + 每行 NO-CARRIER 的反证搜索记录（**全仓 `git grep`，不手选目录**——
  R2 实证：写死 `.tad/evidence/ .tad/logs/` 会漏掉 `.tad/archive/handoffs/` 下路由机器
  自己的原始设计文档，那是"认真做也会踩的坑"）
- 验收靠 **fresh reviewer 对高风险行独立抽查**（自选关键词重跑），**不靠 grep 证明"认真找过"**
- 高风险行 = 决定 P2 砍除范围的那几行，首推 Route Contract

#### ⚠️ 必须携带的 1a-fix 残余修复（Gate 4 独立复现确认，2026-08-05）

1a-fix 的新扫描命令仍有一处**静默漏**：`{2}-{2}` 只校验位数不校验取值范围，
故 `PROVISIONAL: review-by 2027-13-99` 被判为"合法且未超期"→ **既不 OVERDUE 也不 MALFORMED，
完全静默**。Gate 4 已独立复现（非 Blake 单方报告）。

- **触发面**：有人把日期打错。当前台账 0 数据行，不可触发；**P1b 回填产生第一批
  PROVISIONAL 行后即可触发**
- **修法**（一行）：正则的月/日段收紧为 `(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])`，
  非法日期即落入 MALFORMED 分支
- **约束**：改的是「约束准入」节内既有文本，不新增 MUST；两 skill 逐字节相同 + `parity --fix` 镜像
- **AC 必带**：合成探针含 `2027-13-99`，修订前静默 / 修订后 MALFORMED（正负双向）

**其余已记但不阻塞的残余**（Blake Completion 列出，P2 级）：前置过滤 token 碰撞、
台账前言缺反续期禁令、AC 注释边界枚举。

#### 日落条件：让这套机制用它自己的规则审判自己（1a-fix Gate2 对抗审查提出，2026-08-05 采纳）

「约束准入」节自身已须在台账占一行（决策 4，闸付自己的通行费）。**把那一行的状态设为**
`PROVISIONAL: review-by {P1b 完成 + 6 个月}`，**载体条件写成**：
「到期前，本扫描机制至少真实拦下过一次超期 PROVISIONAL」。

- 拦下过 → 有载体，改判 HAS-CARRIER
- 没拦下过 → 按本节自己的默认动作（复查默认 = 删除）走向 RETIRED，**整套到期机制自行退场**

**⚠️ 两条必须一并写进 P1b 的那行台账**（1a-fix Gate2-R2 对抗审查，2026-08-05）：

**(1) 「拦下过」必须有逐字 grep 锚——否则日落条件是它自己制度的例外。**
本节强制每条约束的"挡什么失败模式"栏附反引号 grep 锚，而日落条件若只写自然语言，
六个月后复查者可指着任意 RETIRED 行说"这行大概率超期过"——**台账不记录
"被扫描标记 OVERDUE 后才处置"与"到期前就正常处置"的区别，两者长得一样**。
约定：扫描真命中时，处置者在 Completion 写固定前缀 `SCAN-CAUGHT:` + 原始 OVERDUE 输出；
日落条目的载体路径写 `grep -r 'SCAN-CAUGHT:' .tad/evidence/`。
→ 从"凭印象举证"变成"跑一条 grep 有或没有"，与本节对其它条目的要求一致。

**(2) 「没拦下过」有两种，判决相同但必须诚实区分留档。**
① 台账被正常动过、扫描真跑过，只是无超期行可抓（验证过，暂未用上）
② 六个月内无人碰过台账，扫描**从未触发**（低活跃稳态，本 Epic 追求的目标状态）
两者都判 RETIRED——**不给日落条件自己开后门**，呼应"禁止静默续期"的精神。
但处置行的"挡什么失败模式"栏必须写明是哪一种
（例："六个月内台账零新增行，扫描零次真实触发" vs "扫描运行 N 次，均无超期"），
否则未来看台账的人会把"从没被考过"误读成"已被证明没用"。

**价值**：「这道闸值不值得留」不再是未来某次对话里的主观争论，而是台账上一条会自己到期的记录。
零新增机制、复用既有台账与复查纪律、元一致。

已知残余风险（前几轮已论证并接受，此处不重开）：两个触发点都绑在「有人动台账」或
「Epic 还在跑」上，低活跃期退化——**而低增长正是本 Epic 追求的稳态**。

#### 已知陷阱（R2 实证，写进 P1b 契约时必须带上）
- 关键词若允许 Blake 自由拟定 → 可选窄词跑空结果"合法"证明无载体 → 关键词须取自约束描述中的真实术语，且每行 ≥2 个
- 若只校验「NO-CARRIER 行数 == 反证记录条数」→ 纯计数，挡不住走过场
- 若不强制"砍除名单非空" + AC8 给 NO-CARRIER 附加成本 → **最省事的合规输出是全标 PROVISIONAL，
  全绿交付而砍除名单为空**（激励反转，R2 P0-D）

---

### Phase 2: 砍路由机器

#### Scope
移除 08-01 引入的三层路由装置。**这是本 Epic 最大的一刀。**

**砍**（台账 NO-CARRIER）：
- R0 Route preflight（BLOCKING 读 routing-contract.yaml）
- 17 字段 RouteDecision + revision 链 + base_revision 校验 + 陈旧检测
- R2 11 状态 14 转移状态机
- R1 Standard profile 表 + `design-profile.json` / `execution-profile.json`
- escalated_review 全套（逐字记录 + NOT_via_suggestion + 额度出口话术）
- 升级清单第 1-3 类中「停并建议转 full」的分支

**留**：
- F0 那几条真正不可逆的（支付/认证/批量删除/生产部署/依赖 pin/release·publish·sync/破坏性 VCS）
  → **降级为「安全停：停下来问人」，不是「路由到 full」**
- 保留领地清单（≤5 行，见 P4 复核）
- Standard 作为**深度旋钮**保留（多加一层独立视角），不作为通道

#### Acceptance Criteria
- AC1 `routing-contract.yaml` 不再被任何 lite skill 强制读取（grep 无 BLOCKING 读取指令）
- AC2 两个 skill 的固定读取量合计 ≤ 30K 字符（本阶段中间目标，SC1 最终 ≤20K）
- AC3 F0 七类逐条仍在 skill 中，且行为是「停，问人」——逐条 grep 可验
- AC4 升级清单 ≤5 行
- AC5 **自验收判据**：本 Epic 剩余 phase 的 handoff，按改后的判据应可走 lite
  （P3 开单时实地检验；若仍被判 full，P2 未达成）

#### Notes
⚠️ 这一单命中 `routing_contract`（F1）→ 按**现行**判据必须走 full。
**明确记录：这是刻意的最后几次 full 使用之一，不绕过、不造特例机制。**

---

### Phase 3: 砍档位 + provenance 降级

#### Scope
- 移除两个 skill 的「Reviewer 档位规则」节（各 ~27 行）——
  依据：用户 2026-08-04 裁定「我们要兼容各种模型和 harness 工具，不用非要调用强档」
- Model 行捕获纪律（~25 行 + 8 条 shell 命令）降级为**一行自报**：
  `harness / model / route`，保留可审计性，去掉机械捕获配方
  （档位规则是它的主消费者；消费者走了，配方失去理由）

#### Acceptance Criteria
- AC1 两个 skill 均无「强档」判定逻辑（grep `强档` = 0）
- AC2 Model 行仍在 Completion 模板中，但不含 env/jq/config.toml/agents 捕获命令
- AC3 flash-审-flash 那次事故在台账中改记为「已知取舍」，不静默删除
- AC4 本单实地检验 P2-AC5：**这一单是否成功走了 lite**

---

### Phase 4: 实测 + 领地复核

#### Scope
只读为主。两件事：

**A. 实测 SC1/SC2**——用一个真实任务端到端跑 lite，量固定读取量与总 token，对照 07-30 的 23K 基线。

**B. 领地复核**——三块推定的保留领地，用真实任务各打一次，确认 lite 是真接不住还是只是没试过：
1. Epic / 多阶段协调（现仅 Series 行，blake-lite 不消费）
2. hooks / settings*.json 类全局注册改动（注册后全 session 生效，无回滚验证）
3. release / publish / sync 分发（release-verify / parity / 14 下游项目）

**C. 闸自身的边际单价**（P1 R1 reviewer 建议，2026-08-04 采纳）——
实测「添加一条新约束平均花多少 token / 几轮」。依据 TAD 既有原则
`Measure Before Optimizing`：闸自身的成本目前是**未测量的量**，
而 P1 的设计默认它免费。若闸比它省下的还贵，P1 需回炉。

#### Acceptance Criteria
- AC1 实测报告落盘，含固定读取量字符数 + 总 token，与 23K 基线并列
- AC2 三块领地各有一次真实尝试记录，结论为「接得住 / 接不住 + 具体缺什么」
- AC3 SC1/SC2 达标或给出**具体差距**（不得以「大致达到」结案）
- AC4 P5 范围直接从 AC2 的「接不住」项导出
- AC5 定价闸边际单价实测落盘，并入 SC2 口径（不得假设其为零）

#### ✅ 结果（2026-08-06，commit `f98a295`）

交付物：`.tad/evidence/audits/P4-measurements.md`（四段，全部可独立重算）。
契约：`LITE-20260805-2259-p4-measurements.md`（已归档）。**全程走 lite 通道**——
安全停清单未拦下 P4 主体，即 **P2-AC5 的自验收通过**。

**AC1 ✅ 固定读取量实测（chars / bytes 双口径）**

| 层 | chars | 占比 |
|---|---|---|
| `principles.md` | **22,533** | 36.2% |
| blake-lite SKILL | 13,243 | 21.3% |
| `brain-index.md` | 9,920 | 15.9% |
| `MEMORY.md` | 7,016 | 11.3% |
| `CLAUDE.md` | 3,721 | 6.0% |
| `frontend-design.md` | 3,594 | 5.8% |
| `patterns/_index.md` | 2,193 | 3.5% |
| **合计-项目内** | **62,220** | （77,755 bytes） |
| 合计-实际注入（含 `~/.claude/CLAUDE.md`） | 62,719 | （78,682 bytes） |

**三条结论**：
1. **口径错误**：历史记录的 45,144 / 57,837 / 74K 全是 `wc -c` **字节**，而 SC1 写的是**字符**。
2. **分层错位**：协议层 16,964 chars（**已达 SC1 原目标**），知识层 45,256 chars = **72.7%**。
   P1–P3 三个 phase 砍的都是那 27% 里的一部分，**73% 从未被碰过**。
3. **最大单项是一条 `@import`**：`principles.md` 22,533 chars 被 `CLAUDE.md` 无条件全量加载，
   比整个 blake-lite skill 大 70%；而 pattern 文件走的是 L1.5 按需（索引 + ≤3 个）。

**AC2 ⚠️ 部分完成 —— 领地复核仅做「只读推演」**（用户 2026-08-05 明确选择该范围）：

| 假想任务 | 判定 | 依据 |
|---|---|---|
| T1 改 `.tad/hooks/` + `.claude/settings.json` | 命中条目 **3** | 全局注册面 |
| T2 `*publish` 发布 + 同步下游 | 命中条目 **1** | release·publish·sync |
| T3 在 `.tad/active/epics/` 建 Epic | **未命中** | 该路径不在清单任一条文中 |

⚠️ **推演只能证明「清单会不会拦」，不能证明「拦了之后 lite 还能不能干活」。** 后者未测。
⚠️ **且推演漏了第二道边界**——见 §Known Issues 的「Forbidden 与安全停清单不一致」。

**AC3 ✅ 具体差距已给出** → SC1 拆分为 SC1a（已达标）/ SC1b（45,256，不设阈值）。
**AC4 ✅ P5 范围已导出** → 见下方 Phase 5 候选清单。
**AC5 ⚠️ 未实测** —— 本单不新增约束，故无「加一条约束」的现场可测。C 段改为**历史回算**
（4 commit 体量 + 4 slug 各 2 份审查载体 + 台账数据行 0/0/0/3）。**真实边际单价仍未测量**，
顺延至 P5（下一次真正新增约束时现场计量）。

**SC2（端到端 token）本单未测** —— 交付物只测文件体量，端到端 token 需 harness 侧读数。

---

### Phase 5: 补齐真缺口

#### Scope
**由 P4 结果导出。** 每一项补齐必须过 P1 的定价闸。

#### 候选清单（2026-08-06 从 P4 导出，按证据强度排序）

| # | 候选 | 类型 | 证据 |
|---|------|------|------|
| ~~C1~~ | ~~`principles.md` 改索引 + 按需加载~~ | ❌ **2026-08-06 作废** | **跑偏**：`principles.md` 是 **full 与 lite 共享**的知识层，减它减的是两个通道的共同开销，**不服务于「lite 取代 full」**。且 SC1 已在 P4 证明定错（协议层早已达标）。真要做属独立的知识库维护单。用户识别：「我们不是要做 Alex Lite 和 Blake Lite 吗？你相当于改了 full 的流程」 |
| **C2** | `alex-lite` Forbidden「修改 LITE 契约之外的任何文件」使 Alex 无法维护 Epic 状态 | **P6 硬障碍** | 2026-08-06 现场：P4 验收后 Alex 无法更新本 Epic，被迫启动 full 通道 |
| **C3** | Forbidden 与安全停清单对同一动作给出相反答案 | 一致性缺陷 | T3 判「未命中」（放行），Forbidden 判「禁止」。B 段只测了前者 |
| **C4** | 定价闸边际单价（P4-AC5 顺延） | 度量 | 下次真正新增约束时现场计量 |
| **C5** | 三块领地的**真实**穿透测试（P4 只做了只读推演） | 度量 | AC2 部分完成，命中安全停清单第 1/3 条需人逐块授权 |

#### Acceptance Criteria
- AC1 每项新增约束在台账中有完整三项（成本 / 挡什么 / 载体）
- AC2 补齐后**协议层**读取量仍满足 SC1a（≤20K chars）——**补齐不得以膨胀为代价**
- AC3 补完后安全停清单对应行被删除（补一条删一行）
- AC4 C2/C3 必须处置：Alex 要么获得 Epic 维护权，要么 Epic 维护明确划归 Blake——
  **不得留在「谁都不能改」的状态**

---

### Phase 6: full 退场

#### Scope
升级清单归零后收尾：CLAUDE.md 路由改写、full skills（alex/blake/gate）归档、
下游安装物同步。

#### Acceptance Criteria
- AC1 升级清单行数 = 0（或仅剩 F0 安全停，不再有「转 full」分支）
- AC2 CLAUDE.md 不再把 lite 描述为「例外通道」
- AC3 SC1–SC5 全部达标，逐项附证据路径
- AC4 full skills 归档而非删除（可回滚）

---

## Epic 执行约束（对本 Epic 自身）

来自 2026-08-04 的教训：当日 8 轮 Gate 2 / 约 16 次专家审查，换 17 行交付——
比 阅读助手 的比例还差。一个「省 token」的 Epic 若执行成本高于收益，按自己的标准即失败。

0. **每次为 P1b–P6 起草新 handoff 前，先跑一次台账超期扫描**，把结果（有无超期 PROVISIONAL）
   记入该单的 Gate 2 检查表。依据 Gate2-R3 对抗审查：到期复查必须绑定在
   **Epic 结构本身保证会发生**的事件上（5 次），而不是"希望有人想起来"。
   命令见 alex-lite / blake-lite「约束准入」节。这是脚手架；永久触发点是闸内的"追加前先扫"。
1. **每张 handoff ≤10 AC，且每条 AC 必须实跑验证过判别力**（实现前 FAIL + 围栏双向对照）。
   ~~≤15KB~~ **已作废（2026-08-05，P1a 实测）**：P1a 定稿 21.6KB 超标，但逐段查下来
   没有冗余——占最大块的是 8 条 AC 的命令与"为什么不能改写成 X"的注释，
   而那正是防止 Blake 把缺陷改回来的东西。**字节数是错的度量**：
   107KB/27AC 之所以糟，是因为既读不完又验不动，不是因为字节大。
   改用「AC 条数 + 每条都实跑过」作为约束。
2. **Gate 2 走到第三轮 = 契约形状错了** → 停下来拆单，不再改一版
3. **一次一个 Active phase**，发现相邻问题记进 NEXT.md，不塞进当前单
4. **P1/P2 是仅有的必须走 full 的 phase**；P3 起应走 lite（这是 P2-AC5 的检验点）
5. 每个 phase 的 Completion 必须记录**本 phase 实际消耗**，Epic 结束时汇总

---

## ⚠️ P1b 的三条结论（2026-08-05，改变后续 phase）

**1. D5/D6 是 SUPERSEDED，不是 NO-CARRIER —— Alex 08-04 初判错误。**
Reviewer 档位规则**有真载体**：`.tad/evidence/research/2026-08-02-model-diversity-audit-results.md`
（flash 审 flash 盲区实测，只读审查 GATE PASS vs 执行探针盲审 FAIL **P0×1 + P1×6**）。
P3 照砍，但**台账必须记 SUPERSEDED 并填载体路径**——让六个月后的人区分
「有依据但被裁定退场」与「从来没有依据」。用户 2026-08-05 复核确认。

**2. D7 的载体只支撑降级版。** `2026-08-02-multi-model-portability-verification.md` 第 4 条
建议加 `Model:` 字段、明写「**成本一行**」。现行 25 行纪律 + 8 条 shell 命令是后来长出来的，无载体。
→ P3 的「降级为一行自报」与载体方向一致。**反向证据**：2026-08-05 一名 reviewer 为遵守该纪律
去 grep 环境变量，触发凭据外泄告警——这条纪律本身诱导了一次安全事件。

**3. 审计方法论（P2/P3/P5 复用）：先读约束自称的出处，再用关键词补搜。**
第一轮 7 组关键词搜 5 个事故区目录 **全部零命中**，若就此结案会把 D5/D6 误判为 NO-CARRIER
——那份研究文件通篇没有「强档」二字。**事故记录用事故的语言写，约束用约束的语言写，
术语不匹配是常态。** 两 skill 全文 `依据|教训|实测|违规|盲区|事故` 仅 6 处命中，逐一追溯即定案。

---

## Known Issues / Carry-forward

- **⚠️ lite 的唯一防线可能在主力模型上从未起过作用**（2026-08-05 发现，用户裁定 P4 验证）：
  `.tad/evidence/research/2026-08-02-multi-model-portability-verification.md` 记载
  「**reviewer spawn 是 DeepSeek 的已证失效点** —— DeepSeek 有『planner 从不调 subagent』的
  公开实测先例；弱模型跑 Blake 时，『禁止自审替代』的 prompt 级禁令可能**静默失效**」。
  同文件坐实 **2026-08-02 一张 LITE 单 401 轮、100% 跑在 deepseek-v4-flash 上**。
  而 2026-08-05 两名 Gate 2 reviewer 各自独立得出「lite 的唯一真防线是独立 reviewer」。
  → **若属实，lite 的质量基础不是『仪式轻但防线在』，而是『防线可能从未起过作用』。**
  **P4 实测时验**：查历史 LITE 单 Completion 中 reviewer 行是否真有独立产出。

- **本 Epic 自身成本已结算**（2026-08-06 终结）：P1 阶段 ≈1.44M + 2026-08-06 四单 reviewer
  实测 `subagent_tokens` ≈**1.41M**（12 轮），累计 **≈2.85M token**。

  **结论：不是流程冗余，是初稿质量。** 同日产出 11 版契约、Gate 2 报出约 15 个 P0，
  绝大多数是 Alex 自造的缺陷——AC 锁出口未锁入口、把路径无关的禁令改成 glob 砍掉半道防线、
  引用知识条目只读标题不读 mitigation（同日犯两次）、自造的备份文件连续两单打挂自己的 AC、
  AC6 的写法违反同一份契约里自己定的格式规则。**若初稿写对，验证成本低一个数量级。**

  ⚠️ **因此禁止把这笔账记成「审查太贵」**——那 12 轮抓到的 P0 里至少 4 个是
  「AC 看起来在守、实际零判别力」，**无一由自查发现**；砍掉审查，它们会原样发到 14 个下游。
  该改进的是设计侧初稿，不是验证层。相关蒸馏见
  `ac-verification.md` §`An Aggregate-Only Check Locks the Exit...`、
  §`Replacing a Path-Agnostic Prohibition...`、§`Before Trusting a Guard, Measure Whether
  Its Trigger Condition Can Even Occur...`，及 `handoff-design.md` §`A Change That Makes a
  Dormant Defect Reachable Owns That Defect`。

- **到期扫描的长尾盲区**（Gate2-R4 P1，已在 P1a 协议文本中明记为接受的残余风险）：
  两个触发点都绑在「有人动台账」或「Epic 还在跑」上。**两个时钟是独立的**——
  PROVISIONAL 的到期是日历时间，与是否有人追加无关。低增长期扫描不触发，
  **而低增长正是本 Epic 追求的稳态：机制在它成功时最弱**。
  可选闭合（P6 或之后再评估，本 Epic 不做）：挂一行到 `release-runbook` 发布前检查清单——
  那是唯一独立于上述两个时钟之外的既有仪式。

- **自锁**：P2 要改的 `routing_contract` 正是 F1 匹配词，改它必须走 full。
  已在 P2-Notes 明确记录为刻意选择，不造特例机制绕过。
- **表 B 三块领地是文档推断**，非实战结论 → P4-B 专门验证，不在 P1-P3 依赖它。
  ⚠️ **2026-08-06 更新**：P4-B 只做了**只读推演**（用户选定范围），
  证明了「清单会不会拦」，**未证明「拦了之后 lite 还能不能干活」**。→ P5-C5。

- 🔴 **Forbidden 与安全停清单对同一动作给出相反答案**（2026-08-06 现场发现，P5-C2/C3）：
  `alex-lite` 的 Forbidden 写着「修改 LITE 契约之外的任何文件」，而安全停清单
  只列三类（不可逆操作 / SAFETY 面 / 全局注册面）。对「在 `.tad/active/epics/` 写文件」
  这一动作：**清单判放行（T3 未命中），Forbidden 判禁止**。
  后果是 P4 验收完成后 **Alex 无法更新本 Epic 的状态**，被迫启动 full 通道——
  而 full 的固定读取量实测 **≈221,281 chars，是 lite（62,220）的 3.56 倍**，
  其中 `alex/SKILL.md` 单文件 **92,548 chars，比整个 lite 通道的全部固定读取量还大 49%**。
  **为改一行 Epic 进度付 3.5 倍开销，正是本 Epic 要消灭的形态。**
  这是 P6（full 退场）的**硬阻塞**：lite 若不能维护 Epic 状态，full 就退不掉。

- **B 段的方法论盲区（可复用）**：推演只测了「安全停清单」一条规则，
  而实际约束 lite 的是**两条**规则的合取。设计只读推演类验证时，
  必须先枚举**所有**可能拦截该动作的规则源，否则「未命中」结论会被误读为「可以做」。
- **已交付但未 push**：commit `31a96aa`（Gate 3 证据可重放性 advisory 项）。
  与本 Epic 方向一致（减少证据重采），保留。
- **已作废**：NEXT.md 中 ③（轮次上限）由 lite 既有 Repair Loop 熔断覆盖，不再单列；
  ⑤（Gate 4 模型面）属严谨性非成本，移出本 Epic。
- **②a/②d**（blake full 的 npm/pyyaml 硬编码）：full 退场后自然消失，
  不在本 Epic 单独处理；若 P4 发现 full 仍需长期存在，再回收。

---

## Notes

**这个 Epic 的核心不是「砍」，是「立闸」。**
砍是一次性的；闸决定五天后 lite 会不会重新长回 788 行。
P1 最小、最不起眼，但它是唯一防止本 Epic 白做的东西。
