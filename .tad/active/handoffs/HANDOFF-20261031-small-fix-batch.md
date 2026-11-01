---
dispatch_id: p1-y4-fix-1
dispatch_history: p1-y3-1
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # code | yaml | research | e2e | mixed
e2e_required: no      # yes | no
research_required: no # yes | no
git_tracked_dirs: []  # 本仓文件夹制（禁 git 命令），无 git-tracked 生产目录口径
skip_knowledge_assessment: no
gate4_delta: []
risk_triggers: [platform]   # 改动面含框架脚本/规程/检查口径（platform）；无 security/data/money/ui/domain 面
look_first: ".tad/evidence/yolo/v409-basket/phase1-look.md"
real_paths:
  - id: RP1
    path: "维护者跑 salvage fixture 的真实路径：本机与 Mac 各跑一轮 --case salvage 并读行集"
    run: "VM: `PYTHONDONTWRITEBYTECODE=1 /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case salvage`（plain env，禁 GIT_DISCOVERY_ACROSS_FILESYSTEM）；Mac: ssh mac 在同步副本上同命令（见 §6 P1-S1）"
  - id: RP2
    path: "验证运行 surplus-execute 的真实路径：在本 harness 以证据副本调用 workflow，先看 Validate 期探针报告再决定是否继续"
    run: "named scenario walk — §6 P4-S3 步 3–4（副本调用＋探针报告核对＋缺项 fixture 红灯）"
  - id: RP3
    path: "读者消费 pack 台账的真实路径：只读 behavioral-eval-status.yaml 状态值，答出每包的验证等级与失败状态"
    run: "named scenario walk — §6 P3-S2 步 5（走查问题三问，答案只许来自状态值列，不许靠注释推断）"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-31
**Project:** TAD（EPIC-20261031-v409-basket）
**Task ID:** TASK-20261031-P1
**Handoff Version:** 4.0.8
**Epic:** EPIC-20261031-v409-basket.md (Phase 1/5)

---

## 激活自报（Alex · dispatch p1-y3-1）

- 角色：Alex（Solution Lead），由 conductor（Cora）派发执行 step Y3（Phase 1 设计），依 `.agents/skills/alex/references/conductor-dispatch-mode.md` 与 `handoff-creation-protocol.md` 至 step1d 止步：不做专家评审选择、不派 reviewer、不写 Gate 2 结论、不给自己的活写 verdict。Gate 2 双审由 conductor 后续独立派发。
- 已读原件：仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`＋命中 pattern 三件全文（gate-design／ac-verification／handoff-design 按标题清单）、`.tad/tasks/handoff-creation.md`、`.tad/templates/handoff-a-to-b.md`、`.tad/gates/gate-canonical-checklist.md`、conductor-protocol step_Y3、Epic 与 PLAN、BASKET、phase1-grounding、输入票八件与 DESIGN-20261031 全文、GATE4-20261031 相关节。
- Gate 1：Epic `## Requirement` 面即 PLAN Phase 1 节＋Phase Map（用户 2026-10-31 认切法、11:44「continue」开跑，记于 Epic 头部 Approved 行）；can design from it：四个 Step 的范围、既定修法与验收口径均可从输入件逐字取得，无须猜测。设计冲突一件已在 §4 D1 显名裁断（输入票头 Status 与票内收口节冲突，采「票面分诊先行」解）。
- 本 handoff 首行形态与 front matter 内 dispatch_id：原稿曾声称已按 T-1b 先行自守，但 Round 1 实测原 `dispatch_id: p1-y3-1` 在块外（原稿 L23，块闭合 L21），声称不成立；本修订已把当前 ID 与 `dispatch_history` 移入块内（见文末修订记录）。本文件仍为 T-1b 其后首份新合同与 AC9 活验收样本，复审须按 AC9 头形命令核三项并留痕。

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: Round 1 已由 conductor 独立派发并完成（两份 verdict 均为 FAIL）；本节状态为「设计修订已落、待 conductor 以新 dispatch 复审」，本修订步不自审自批。

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | 🔴 Round 1 FAIL／待复审 | 四 Step 组件与文件面在 §4 齐备；Round 1 的设计缺陷已逐项修订，结论待独立复审 |
| Components Specified | 🔴 Round 1 FAIL／待复审 | §4.2 已按 D9 的作用域化同步核验法修订；错误工具指定已删除 |
| Functions Verified | 🔴 Round 1 FAIL／待复审 | §5 MQ2 已更正 AC-08 `check()` 行号为 L31–33；其余引用待复审重核 |
| Data Flow Mapped | 🔴 Round 1 FAIL／待复审 | §5 MQ5 已把 gate SKILL 同步核验改为新增行作用域 diff，不再误引 drift-check.sh |

**Gate 2 结果**: 🔴 ROUND 1 FAIL — 两份独立评审已落盘：`.tad/evidence/yolo/v409-basket/p1-gate2-review-code.md`（consistency，P0×3／P1×3／P2×1／P3×2）与 `p1-gate2-review-domain.md`（domain，P0×1／P1×1／P2×3；P0 与代码面 P0-1 同根）。按 review-contract，`risk_triggers: [platform]` 的双审构成是 consistency + risk（platform 面），评审件落 `.tad/evidence/yolo/v409-basket/`；domain 件为 Round 1 实际记录，以盘面为准。本修订不出复审 verdict，须 conductor 后续独立派发，定稿后才交 Blake。

**风险卡触发项核对（gate-canonical Gate 2「Risk card」行）**: 本 Phase 无 L3 动作（无删除/密钥/公网/生产动作；ml-training 摘注册为目录移置＋再生，文件全保留可逆）；无跨仓写（Mac 腿仅在同步副本的 mktemp 沙箱内运行 fixture）；不引入新连接器/MCP/依赖；无金额；无对外发送。→ 非高风险，不附风险卡。

**Load points declared（Gate 2「Load points」行）**: 本 Phase 每件新增/修改条文的装载点位逐项写在 §4 对应决策行（D5/D9/D10/D13/D15）与 §7.2 各行末；指不出装载点的项不在本设计内。

**Pilot（Gate 2「Pilot declared」行）**: 不触发——四 Step 配方与验收方法互异，非 ≥3 同构单元；salvage 双平台腿为 2 个单元且方法同为行集对照，<3。记 n/a。

**Alex确认**: 设计要素已按原件成件；Gate 2 定稿后 Blake 可独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building

Phase 1「小修批」：把五张 2026-10-28 存量票、一件已评审的 AC-08 设计、三件框架落字与一件运行时探针口径，在一个 Phase 内按各自既定修法清账。四 Step：

- **Step 1 票面分诊与处置**：五票逐票以盘面证据分诊（属实／已修／作废当场关票），只有属实且未落地的才动手——checker-false-negative、handoff-creation-loadpoints、r4-distill-text-pack 三票票内收口节自记 CLOSED 且终局链证据在盘，分诊即核验关票；gate2-form-enforcement（T-1b）属实在册未落，按票面落一条 Gate 2 机械行；salvage 票属实未落，按更正后归因修 `mode_of()` 语义并双平台各跑一轮。
- **Step 2 AC-08 实现**：按 DESIGN-20261031 把 AC-08 检查改成四类分类＋collect-and-continue 全量报告；动工前先在 HANDOFF 修订行更正设计件 §1 两处数字并锁定 AC2 重跑底座（Gate 2 先锁两件，见 §4 D11）。
- **Step 3 框架落字三件**：G4-F3（surplus SKILL throw 句独立成条）；pack 台账小修五件（状态词表新增「无判别力」、verified 降格分级、补 2 行、compatibility 裁决写回注册表注释、ml-training 摘注册）；长证据文件分段落盘纪律入 `.tad/tasks/evidence-collection.md`。
- **Step 4 运行时探针口径**：surplus 两 workflow 脚本头部加运行时需求声明，执行入口 Validate 后、首个 agent 调用前加零成本能力探针；缺硬需求时在 Validate 期红灯，facade 可补的全局只报降级、不红灯。

### 1.2 Why We're Building It

**业务价值**：4.0.9 篮子的第一块——存量小件不清账，发版时每件都要重新裁断；检查器假阴性、台账误读、fixture 恒红、workflow 运行时死亡都是已实证、已定修法、只差落地的债。
**用户受益**：篮子内容逐件销账，用户点数 0，不需用户参与本 Phase 任何一步。
**成功的样子**：五票全部有终局状态（关票凭据在盘）；AC-08 新检查在记录集上给出完整报告与机械裁定；三件落字逐字可 grep 复核；探针在本 harness 的副本运行中于任何 agent 启动前给出能力报告。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：把「已裁定、未落地」的存量债按原裁定落地，并用盘面证据证明每件的终局状态——不是重新发明修法。

**不是要做的（避免误解）**：
- ❌ 不是重开五票的设计裁断（修法以票面原文为准；分诊只判「是否已落地」，不改判修法本身）
- ❌ 不是借机扩围（.bak 移除不在本 Phase；pack 分诊主体在 Phase 3；扫描面三查在 Phase 4；verdict 表形系统对齐 G4-F2 在 Phase 2）
- ❌ 不是给检查器/探针加机械执法（不注册任何 hook；探针是脚本内自检，不是拦截器）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？

只有Human确认你的理解正确后，才能开始实现。
```
（conductor 链内：此确认由 COMPLETION 的 Intent 回述节承载，Gate 3 对照本 §1.3 核。）

### 1.4 卸载记录（Offload Log）

| 时间 | 卸载项 | 依据 | 原文指针 | 回取方式 |
|---|---|---|---|---|
| 2026-10-31 15:47 UTC | 五票与 DESIGN 全文要点 | 已逐件全文读取并在 §2.1/§4 转成执行清单（逐字口径以票面为准） | `.tad/active/TICKET-20261028-*.md`、`.tad/active/TICKET-20261031-*.md`、`.tad/active/DESIGN-20261031-ac08-baseline.md` | 按 §7.3 Grounded Against 清单回读 |
| 2026-10-31 15:47 UTC | GATE4-20261031 的 FIX 对单与收口显名清单全文 | 只取 G4-F3 原文与 G4-F2 去向两点 | `.tad/evidence/surplus-execute-fix-20261031/GATE4-20261031.md` L125–170 | 按行号回读 |
| 2026-10-31 15:47 UTC | 技术研究席 pack 提案与流程提案全文 | 裁定已由 PM 落进两张 TICKET，本设计只认票面裁定 | tech-radar 仓 `consult/pack-efficacy-2026-10-31/`、`consult/tad-process-suggestions-2026-10-31/` | 跨仓回读（只读） |

### 1.5 Requirement (human's words)

Epic phase: 指向 Epic `## Requirement` 面——`.tad/active/PLAN-20261031-basket-epics.md` Phase 1 节与 EPIC-20261031-v409-basket.md `## Phase Map` 的 Phase 1 行；本 Phase 覆盖块＝Phase 1 四 Step 全体。

playback confirmed: "先不发4.0.9，我们多攒一些升级再发版"（用户 2026-10-31 定篮子方向）＋"continue"（2026-10-31 11:44 开跑令，记于 Epic 头部 Approved 行）

- **Done check**: 五票终局状态全有盘面凭据；AC-08 设计六条 AC 在新检查上全过；落字三件逐项 grep/diff 可复核；探针副本运行在 agent 启动前出报告且缺项 fixture 红灯——即 §9.1 全行 PASS。
- **Not wanted**: 不重裁已定修法；不扩围到 .bak／Phase 2–4 的活；不注册 hook；不改 §9.1 方法文法；不以手改 pack-registry.yaml 冒充摘注册（该文件由 scan-packs.sh 再生）。

#### Q→A log

- Q：五票票头 Status 全写 OPEN、其中三票票内收口节自记 CLOSED，设计以何为准？A（Alex 设计裁断，记 §4 D1）：不预判——Step 1 第一步即逐票分诊，凭终局链证据（设计/实施/复核件在盘＋改动面现状）定终局状态；证据不足的按未落地处置。此裁断属 design 类（执行口径），不改任何票的修法裁定。

#### Assumptions (not asked; Gate 4 lists them)

- A1：Mac 同步副本在 Blake 执行 Step 1 时已含本仓当日文件（Syncthing 常态）；若未同步，Mac 腿按 §8.4 Friction 的替身口径走（结论标 DEGRADED_WITH_APPROVAL 须有 conductor 记录，不许静默跳过）。
- A2：本 harness 的 Workflow 运行时在本 Phase 执行期内保持「有 workflow()/agent()、无原生 budget 全局」的现状（修复链实测）；探针设计按「硬需求缺失才红灯、facade 覆盖项只报降级」写，运行时构成变了也不误红。
- A3：pack-registry 再生（scan-packs.sh）在本仓可直接运行且幂等（脚本头注在盘）；再生若产生与本 Phase 无关的额外 diff，按 §10.2 约束停步上报，不许顺手提交式保留。

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] testing - fixture 断言、AC 干跑、基线对照
- [x] architecture - 检查器分类层、workflow 入口结构
- [ ] code-quality / security / ux / performance / api-integration / mobile-platform（不直接命中；shell 可移植性按 patterns/shell-portability.md 索引在册，Step 1 触 shell 文件时按 AGENTS.md 路由回读该 pattern 全文再动手）

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| principles.md | 6 条直接相关 | 见下方教训 1–3（行集 diff、逐类作用域化、装载点位纪律） |
| patterns/gate-design.md | 4 条直接相关 | consumer tolerance 必须配生产侧修复；检查器不执行被检文档命令；claims need carriers |
| patterns/ac-verification.md | 3 条直接相关 | AC 须在活主机干跑；known-GOOD/known-BAD 对照；空集断言先断非空 |
| patterns/handoff-design.md | 2 条直接相关 | 规则在 N 处副本须全改才算改；产物声称须有载体文件 |

**⚠️ Blake 必须注意的历史教训**：

1. **计数是烟雾报警、行集 diff 才是地面真相**（principles.md 2026-05-31）
   - 问题：grep -c 类全局计数把「合法移除」与「非法丢失」混成一个数字。
   - 解决方案：salvage 与 AC-08 两处对照一律用同 env 基线行集 diff（§4 D2、DESIGN §4.2），逐行归因，不许只报总数变化。

2. **判据按类作用域化；集合有界才可用否定表**（principles.md 2026-06-01 及 AMENDED）
   - 问题：全局下限对 must-cover 集合失明；无界集合上 deny-list 的 fail-open 面无限。
   - 解决方案：AC-08 分类逐路径逐类判（DESIGN §3.5 五步 fail-closed）；计数类 AC 必须先写明计数对象定义（本 handoff §9.1 pack 计数口径见 D6/D8）。

3. **对本项目自产形态的容忍必须配生产侧修复**（patterns/gate-design.md 2026-10-16 consumer tolerance）
   - 问题：检查器容忍了在野坏形态而生产侧不修，容忍永久化、新件继续以坏形态产出。
   - 解决方案：T-1b 即该对侧义务——Gate 2 清单增机械行管新合同（D9）；检查器容忍不撤销、只服务存量。本 handoff 自身先行自守该形态（见激活自报）。

4. **设计侧 AC 命令系统性地假设了不存在的机器**（patterns/ac-verification.md 2026-07-13）
   - 问题：未在活主机干跑的 AC 会假 FAIL、挂死或真空 PASS。
   - 解决方案：本 handoff §9.1 每行已在设计时于活基线干跑（Verified Output 列＋文末 AC Dry-Run Log）；Blake 在 Gate 3 重跑时若遇命令形态问题，先对照 Dry-Run Log 的基线输出判是命令坏了还是产物坏了。

5. **完成声称没有盘面载体就不成立**（patterns/gate-design.md 2026-06-10 Claims Need Carriers）
   - 问题：收口节写了 CLOSED 但票头 Status 没跟上，正是本批 Step 1 要分诊的病灶本身。
   - 解决方案：分诊关票必须同时改票头 Status 并引终局链证据路径（D1）；任何「已修」结论须有 `test -f` 级凭据。

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work

- 蒸馏三票终局链（2026-10-28，均有盘面件）：T-1 检查器假阴性定案甲（检查器面）已实施，改前副本 `.tad/hooks/lib/gate3-check.sh.bak-20261028-t1` 在盘，Gate 3 复核 CONDITIONAL（p0=0/p1=0/p2=1）后关票；T-2 handoff-creation 装载点三变更点已落（本设计实测：现行 `handoff-creation-protocol.md` L594 起 tiering 建议规则全文、L613 起回放自查句均在规程正文）；T-3 R4 文本包五点全落＋修复轮定点复核 PASS。衍生票 T-1b（gate2-form-enforcement）OPEN 未落——其 §1 自述「生产侧合规形态的文本早已齐备，缺的只是生产时的执法点」。
- surplus 修复链（EPIC-20261031）收口携带三项与本 Phase 相交：G4-F3（P3，SKILL 落位形态）、G4-F1 探针销项（已关，与 Step 4 的探针口径是两回事：那是归一函数的定向探针，本 Step 是 workflow 入口的运行时能力探针）、G4-F2（P2，verdict 表形对齐——**去向是 Phase 2**，本 Phase 不动，勿误领）。
- AC-08 设计件 DESIGN-20261031 已过独立 Alex 评审（设计成立）；评审携带 P2×2（§1 数字更正、AC2 底座未钉）＋P3×2（判定程序补 T-未枚举路由句、AC3/§8 退出码口径注）记于 SURPLUS-REPORT-2026-10-31 L75–77——P3×2 的落点在本 handoff §4 D12。
- pack 裁定 TICKET-20261031-pack-triage 与流程五条裁定 TICKET-20261031-process-suggestions 均为 PM 已裁件，本 Phase 只执行其中点名归小修批的部分（台账小修、第 2 条探针、第 4 条落盘纪律）。

### 2.2 Current State

（均为设计时 2026-10-31 实测，证据指针在 §7.3 与 phase1-look.md）

- salvage：`.tad/tests/backup-lifecycle-fixture.sh` L91 `mode_of()` 首选 BSD 式 `stat -f '%Lp'`；GNU coreutils 下该式不产出可直接采信的单一语义值（修订轮本机探针：对 chmod 600 与 644 的临时文件均输出 6 行——5 行文件系统转储＋末行数字；行数随 env／文件系统形态可变，fixture 内实测返回空），L213–216 的 mode 断言行基线为 `FAIL: salvage: diff file wrong ( mode=)`；同 env 基线行集 9 行 PASS=2／FAIL=7，其余 FAIL 为沙箱 git-discovery 级联（见 look 记录）。
- 检查器三票对象面现状与票内收口自述一致（三票的改动面均已在盘，见 §2.1）；五票票头 Status 均为 OPEN——状态面未同步是分诊要修的最后一公里。
- AC-08：脚本 `.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py` 共 180 行，`check()` 位于 L31–33（`def check` 在 L31，函数体内 `if not ok: sys.exit(1)` 在 L33）；记录集 `gate4-ac08-output.txt` 126 行、PASS 行 113；DESIGN §1.2 仍写「约 157 行」待更正。
- surplus SKILL：`.agents/skills/surplus/SKILL.md` 的 ledger×nested throw 句现位于 L115–119「Budget guard」条正文末尾，同条内，未独立成条。
- pack 台账：`.tad/capability-packs/behavioral-eval-status.yaml` 停更 2026-06-01，packs 段 24 行（verified 9／pending 14／no-fixture 1）；注册表 `pack-registry.yaml` 26 条目、L9 `synced_from_version` 注释仍为「Phase 2 consumer TBD」；ml-training 的 CAPABILITY.md 已带 `status: frozen`，目录与 `.agents/skills/ml-training/` 均在盘（eval 台账注「not installed as a skill」与盘面不符——台账行本身亦属待修）。`pack-registry-driftcheck.sh` 的修订轮基线实跑为 exit 1：(a) 无、(c) 无，唯一实质项是既存 (b) `production-observation`（另有 (d) 对同项的 advisory WARN）；该项不在本 Phase 写集内，AC8 改按基线 delta 判，不再要求 exit 0。
- 证据纪律：`.tad/tasks/evidence-collection.md`（478 行）无分段落盘条文（grep「分段」=0）。
- workflow：`.tad/workflows/claude/` 共 10 件；surplus-execute（694 行）`phase('Validate')` 在 L175、首个能力/参数 throw 在 L179 起、Execute 段 L492；surplus-scan（426 行）；两文件均无运行时需求声明（grep dispatch_id=0，无声明标记）。

### 2.3 Dependencies

- Mac 通道：`ssh -F /home/hatch/.ssh/config mac`（TOOLS.md 在册；设计时已探活，Darwin＋BSD stat 实测正常）。
- 本 harness 的 Workflow 工具（Step 4 副本运行的执行面）与仓内 invocation-specs 先例（`.tad/evidence/surplus-execute-fix-20261031/invocation-specs.md` 的 Copy-execution protocol）。
- scan-packs.sh（pack-registry 再生器）与 pack-registry-driftcheck.sh（`.tad/hooks/lib/`）——均为仓内既有脚本，不新增依赖。D9 的 canonical↔gate SKILL 同步不使用 `.tad/hooks/lib/drift-check.sh`：该脚本只查 handoff 生命周期 drift，不测门条文（见 D9 的作用域化行 diff）。

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1（Step 1）：五票逐票分诊并处置——三票核验关票（票头 Status 改 CLOSED 并引终局链凭据）、T-1b 落地、salvage 按语义字段修断言并双平台各跑一轮留证。
- FR2（Step 2）：AC-08 检查按 DESIGN-20261031 落地四类分类、collect-and-continue 全量报告、登记册数据化与 known-deviation 机械裁定；设计件 §1 两数先更正、AC2 底座先锁定。
- FR3（Step 3）：G4-F3 落位修正；pack 台账小修五件（词表/分级/补行/注释回写/摘注册）；分段落盘纪律入 evidence-collection 规程。
- FR4（Step 4）：surplus 两 workflow 加运行时需求声明与 Validate 期零成本探针，验法（缺硬需求在任何 agent 启动前红灯）实证在案。

### 3.2 Non-Functional Requirements

- NFR1：全部改动逐字可复核——每件落字类改动在 COMPLETION 附改前/改后对照或 diff 指针；计数类结论先写明计数对象定义。
- NFR2：不削弱任何既有检查语义（检查器容忍不撤销、AC-08 守卫不降格、fixture 其余断言不动）；负控行（AC15 的删登记翻转、AC17 的缺项红灯）必须实证「没放成橡皮章」。
- NFR3：零新依赖、零 hook 注册、零仓外写（Mac 沙箱与证据面除外）；同步目录内跑 python 带 PYTHONDONTWRITEBYTECODE=1；shell 改动遵守 patterns/shell-portability.md（动手前回读）。

### 3.3 Optimization Target (Optional — triggers Autoresearch Mode)

不设（本 Phase 无数值优化目标）。

---

## 4. Technical Design

Decisions, not code. 每条决策带接受方式（§9.1 行或 real_path id）。

### 4.0 Decisions

| # | Decision | Lands in | Accepted by |
|---|---|---|---|
| D1 | 五票分诊先行：逐票凭终局链证据定状态（已修→关票同步票头；属实未落→按票面修法处置；证据不足→按未落地处置并在 COMPLETION 记分诊依据）。分诊表落 COMPLETION §Step 1 | 五票票头＋COMPLETION | AC10＋AC11＋AC18 |
| D2 | salvage 对照口径＝同 env 基线行集对照：改前在本机 plain env 录全行集（设计已录，见 §9.1 AC1 基线），改后同 env 重跑，许变行只有 mode 断言行（FAIL→PASS）；基线 PASS 行不许回退；他行变化逐行归因入 COMPLETION | `.tad/tests/backup-lifecycle-fixture.sh`＋证据 | AC1 |
| D3 | salvage 修法形态：`mode_of()` 按运行时探针分派（先试 GNU `stat -c`、再 BSD `stat -f`），或等价的「输出形态校验后才采信」写法；判据是输出为纯数字 mode 才算数。**不许**按文件系统类型分期望、**不许**整段 stat 文本比对 | 同上 L91 一带 | AC2＋AC1 |
| D4 | salvage 的 macOS 腿：经 ssh mac 在同步副本上先以改前快照录基线行集、再跑改后文件，行集对照口径同 D2；改前快照由 Blake 在动工前先把现行 fixture 复制进本 Phase 证据根（防改后无基线） | 证据根 `salvage-mac-baseline.txt`／`salvage-mac-after.txt`（与 Required Evidence Manifest 同名） | AC3 |
| D5 | G4-F3 落位：throw 句从 Budget guard 条正文拆出、独立成条，文字逐字不动；新条位置紧随 Budget guard 条之后。装载点位：`.agents/skills/surplus/SKILL.md` 源面（副本面由同步机制处理，不手改 `.claude/` 投影） | `.agents/skills/surplus/SKILL.md` | AC7 |
| D6 | pack 台账词表与分级在 `behavioral-eval-status.yaml` 头注 STATUS SEMANTICS 内落字：新增状态值 `no-discriminative-power`（验过、无干净 delta）；`verified` 行表述降格为 `verified-discriminative` 并在头注写明其语义＝单 fixture 存在性证据、`verified-in-use` 为预留等级（真实任务回放＋触发率证据，本 Phase 不产生）。web-backend、data-engineering 两行状态改 `no-discriminative-power`、原注释保留。计数口径：台账行数以 packs: 段下条目行为准 | `.tad/capability-packs/behavioral-eval-status.yaml` | AC5 |
| D7 | 补行与 ml-training 行处置：agent-computer-interface、ai-podcast-production 各补一行，状态值按盘面事实定（有 fixture 写 pending 并注 fixture 名；无 fixture 写 no-fixture 并注依据）；ml-training 行随摘注册同步处置——行不删，状态改注「deregistered（2026-10-31，见 TICKET-20261031-pack-triage）」保留史迹 | 同上 | AC6 |
| D8 | compatibility 回写与摘注册机制：registry 是 scan-packs.sh 再生物——回写注释必须改在再生器可保留处：改 `scan-packs.sh` 的表头模板行使 L9 注释输出裁定文本，再跑再生使在册注释更新（不许手改 registry 冒充）；ml-training 摘注册＝将其源包移出扫描面至 `.tad/capability-packs-retired/ml-training/`（文件全保留、字节不动），再生后注册表条目 26→25。driftcheck 不以 exit 0 为条件：基线 exit 1，唯一实质项为既存 (b) `production-observation`；改后 (a)/(c) 仍须为空、(b) 只能剩该项、不得出现 ml-training 或新项，exit 仍可为 1。该项不在本 Phase 写集内，不许吸纳。移置前先 grep 全仓 `capability-packs/ml-training` 引用并在 COMPLETION 逐条交代（patterns/handoff-design「move/archive must repoint references」） | `.tad/scripts/scan-packs.sh`、`.tad/capability-packs/pack-registry.yaml`（再生）、`.tad/capability-packs-retired/ml-training/`（新） | AC8＋AC5 |
| D9 | T-1b 机械行：`gate-canonical-checklist.md` Gate 2 节增唯一键 `handoff-header-form` 行（核心含新合同三核验点——首行 `---`、`dispatch_id` 在 front matter 内、§9.1 形态 A——与存量豁免），同核同步 `.agents/skills/gate/SKILL.md` Gate 2 派生块。同步核验只对该行：两边抽行，去前导空白／`- [ ]`／canonical 尾 `Why ME:` 后逐字 diff 须空；**不用** `drift-check.sh`（只测 handoff 生命周期），不以全节 diff 为条件，既有差异不扩围。关票见 AC18。装载点位：Gate 2 评审进入时读 canonical Gate 2 节（SKILL 为同步面） | `.tad/gates/gate-canonical-checklist.md`＋`.agents/skills/gate/SKILL.md`＋T-1b 票（仅票头＋凭据行） | AC9＋AC18 |
| D10 | 分段落盘纪律落点：`.tad/tasks/evidence-collection.md` 增一节通行款——>约 8KB 的证据/verdict/答卷类文件必须分段落盘、每段验字节、回执自报总字节数与章节清单、收尾自查文件尾无截断标记，缺任一项收口不成立。装载点位：evidence-collection 是证据采集规程本体，凡产证据的链在收口时读它 | `.tad/tasks/evidence-collection.md` | AC13 |
| D11 | AC-08 Gate 2 先锁两件（本 Phase 内、实施动工前完成并记入 HANDOFF 修订行）：① 设计件 §1 两数更正——「约 157 行」改「126 行」、PASS 数按 113 落字（改设计件属本 Phase 显名授权面）；② AC2 重跑底座锁定——捕获件＝Gate 4 轮记录集四件（gate4-ac08-output.txt、gate4-acceptance-report.md、baseline.json、repair-entry-scope-baseline.json），重建法＝在证据根建 scratch 树、按 AC-08.py 既有 `--root` 指向 scratch、用其 REAL 回退读基线证据（脚本头注口径），命令原文写入修订行 | `.tad/active/DESIGN-20261031-ac08-baseline.md`＋本 handoff 修订行 | AC12＋AC15 |
| D12 | DESIGN 评审 P3×2 在本设计内定落点：① §3.5 决策程序第 1 步后补 T-未枚举路由句——「T 目录内未枚举新路径报 T-未枚举、计入 diff 集、不定 FAIL，定性归 Gate」（即 DESIGN §3.2 既有口径的程序化落字，实施时逐字对回）；② §8 开放问题 1（R 类 FLAG 退出码）由 Blake 在实现时二选一锁死并在 COMPLETION 与脚本头注同时落字——设计倾向照 DESIGN：计入 exit 1，轮转误报由登记册轮转条目逐模式豁免 | AC-08.py 实现＋COMPLETION | AC14＋AC15 |
| D13 | 探针语义分工（Step 4 承重决策）：需求声明分两类——**硬需求**（agent、phase：缺失＝无 facade 可补，Validate 期红灯）；**facade 覆盖项**（budget、workflow()：已有定版 facade/内联回退，只报一行降级注记、不红灯——与修复链「原生逐字委托、缺失走等价回退」的定版语义一致，不许把已修好的回退再判成红灯）。探针位置在 Validate 期、首个 agent() 调用之前；探针自身零 agent、零 token | 两 workflow 脚本 | AC16＋AC17＋RP2 |
| D14 | 需求声明形态：两脚本头部注释块各加一段 `runtime-requirements:` 声明（全局名＋类别＋缺失后果三项齐），surplus-scan 同步同形态（其硬需求只有 agent/phase，声明面从简但结构同构）。声明是给评审与未来 harness 读的契约面，探针按声明执行、不另设隐藏清单 | 两 workflow 脚本头部 | AC16 |
| D15 | 探针的装载/触发点位：探针代码段随脚本 Validate 期执行（脚本被调用即触发，无外部注册）；口径落字入 surplus SKILL 的运行说明面一句（探针存在与红灯语义），使口径在规程面可查 | 两 workflow 脚本＋`.agents/skills/surplus/SKILL.md` | AC16 |
| D16 | Step 2 的实现边界：改造限 AC-08.py 本体＋同目录新增 `scope-registry.json` 种子＋旧脚本留 `AC-08.py.prev` 至本 Phase Gate 4 通过；其余 AC-01…AC-07、trace-writer、wrapper、PM 写入行为一概不动（DESIGN §6 范围外逐字守） | AC-08 证据目录 | AC14＋AC15 |

### 4.1 Architecture Overview

四 Step 写集两两不重叠（Step 1：五票＋fixture；Step 2：AC-08 证据目录＋设计件；Step 3：surplus SKILL＋pack 两文件＋scan-packs＋evidence-collection；Step 4：两 workflow＋surplus SKILL 一句口径——与 Step 3 同文件不同节，串行实施防同文件并发改）。全 Phase 是「既定修法的落地＋证据化」，无新系统、无新依赖；唯一的机制新增是 Step 4 的探针段与 Step 2 的分类层，两者都以既有定版（facade 语义、DESIGN 分类表）为据。

### 4.2 Component Specifications

#### Step 1 组件（票面分诊与 salvage）
- **对象**：五票票头与收口节、`.tad/tests/backup-lifecycle-fixture.sh` 的 `mode_of()`（L91）及其 salvage 断言行（L213–216 一带）。
- **实施要点**：分诊表先行（每票：票头状态／收口自述／终局链件在盘与否／改动面现状／分诊结论／动作）；三票关票只改票头 Status 行与一行关票凭据，不动票面正文史迹；T-1b 的实施在 Step 3 的 D9（同属落字面，与 pack 台账同批串行）；salvage 改 `mode_of()` 一处，fixture 其余行逐字不动。

#### Step 2 组件（AC-08）
- **对象**：`AC-08.py`（重写 check 为记录式 collect-and-continue；分类器按 DESIGN §3.5 五步；登记册加载与 schema 校验；SUMMARY＋JSON 侧车输出）、新 `scope-registry.json`（种子仅两条硬编码豁免＋E1 traces 模式，字段按 DESIGN §3.6）、`AC-08.py.prev`（旧脚本留置）。
- **实施要点**：既有检查点行文法与顺序不变（DESIGN §5 对照表）；T 类收紧（E 目录逐件对清单）是有意差异，COMPLETION 须显名；退出码 0/1/2 语义按 DESIGN §4.1。

#### Step 3 组件（落字三件）
- **对象**：`.agents/skills/surplus/SKILL.md`（D5、D15 各一处）、`behavioral-eval-status.yaml`（头注＋行处置）、`scan-packs.sh` 表头模板＋再生后的 `pack-registry.yaml`、`.tad/capability-packs-retired/ml-training/`（移置）、`gate-canonical-checklist.md`＋`.agents/skills/gate/SKILL.md`（D9）、`.tad/tasks/evidence-collection.md`（D10）。
- **实施要点**：每件落字附改前/改后对照；registry 只许再生改、不许手改；canonical 与 gate SKILL 的同步只以 D9 新增行（含唯一键 `handoff-header-form`）经归一化后的作用域 diff 为凭，不跑 drift-check.sh、不要求两份 Gate 2 全节一致。

#### Step 4 组件（探针）
- **对象**：`.tad/workflows/claude/surplus-execute.workflow.js`、`.tad/workflows/claude/surplus-scan.workflow.js` 的头部声明与 Validate 期探针段。
- **实施要点**：探针段只做能力探测与报告（读全局在不在、按 D13 分工红灯或注记），不改既有 facade、Validate 参数校验与执行逻辑；语法校验用 ac-verification 在册的 wrapped-body 法（把脚本体包进 async 函数后 `node --check`），不许拿 `node --check` 直验 workflow 文件当门。

### 4.3 Data Models

- eval-status 行形态：`  <pack-name>:      <status>      # <注释>`；status 取值集改后为 pending／verified-discriminative／no-discriminative-power／no-fixture／deregistered（注记形态）。登记面计数口径：注册数＝pack-registry.yaml 中 `packs:` 段 `  - name:` 条目数且源包有 CAPABILITY.md 者（模板 §9.1 计数口径注）。
- scope-registry.json 条目字段：`path|pattern`、`class`（X|R）、`owner`、`guard`、`granted_by`、`date`（DESIGN §3.6 逐字）。
- AC-08-report.json：全部结果记录＋计数矩阵（verdict×类）＋diff 全集＋known-deviation 裁定与余集（DESIGN §4.4）。

### 4.4 API Specifications

N/A（无 API 面；workflow 脚本的 args 契约不变，探针不新增必填 arg）。

### 4.5 User Interface Requirements

N/A（无 UI 面）。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"、"我们的方案"？

**回答**：
- [x] 是 → 本 Phase 全部对象都是既有存量（五票、AC-08、SKILL、台账、workflow），设计已逐件回盘读取原件，无一凭记忆。

#### 搜索证据
设计时实读清单即证据：五票全文、DESIGN 全文、GATE4 相关节、两 TICKET 裁定件、fixture L80–100 与 L194–265、AC-08.py 头 50 行与行数、surplus SKILL L95–135、registry L1–30、eval-status 头注与 packs 段、两 workflow 头部与关键行号；distill-tickets 目录与 .bak 件以 `ls` 实证在盘（清单见 §7.3 与 phase1-look.md）。

#### 决策说明
- **找到了什么**：三票的终局链件齐全（t1/t2/t3 的 design/impl/review 件）；AC-08 的 `--root` 重建口径写在脚本头注；探针的 facade 分工写在修复链定版里。
- **决定**：✅ 全面复用既有裁定与定版，不新造修法；分诊制（D1）就是为「票头与收口冲突」这一实测现状设的。

### MQ2: 函数存在性验证

**问题**：设计中调用了哪些函数/入口？它们都存在吗？

#### 函数清单

| 函数/入口 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| `mode_of()` | `.tad/tests/backup-lifecycle-fixture.sh` | 91 | `stat -f '%Lp' … \|\| stat -c '%a'` | ✅ 实读 |
| `check()`（fail-fast 出口） | `…/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py` | 31–33 | `def check` 在 L31；`if not ok: sys.exit(1)` 在 L33 | ✅ 实读（修订轮以 `grep -n` 复核；L14/L18 的 exit 属校验 helper，不属 check 体） |
| `approved_scope_exemption()`（硬编码豁免） | 同上 AC-08.py | 脚本内（DESIGN §3.3/§5 指认） | 两条路径＋守卫 | ✅ 经 DESIGN 与评审件双证 |
| `phase('Validate')` / 首个 throw 群 | `.tad/workflows/claude/surplus-execute.workflow.js` | 175 / 179–188 | Validate 段入口与能力/参数 throw | ✅ 实读 |
| `pack-eval-runner.sh --all`（台账契约，本 Phase 不跑） | `.tad/scripts/pack-eval-runner.sh` | — | eval-status 头注 CONTRACT 行 | ✅ 头注在盘 |
| `scan-packs.sh`（registry 再生器） | `.tad/scripts/scan-packs.sh` | 头注 | 「Auto-generate … Idempotent」 | ✅ 实读 |

### MQ3: 数据流完整性

**问题**：后端计算/返回了哪些字段？前端都显示了吗？

**回答**：无前后端面；对应问题是「派生面与源面是否同步」，对照如下：

| 派生面 | 源面 | 同步方向 | 本 Phase 的守法 |
|--------|------|---------|----------------|
| `pack-registry.yaml` | 各包 CAPABILITY.md＋`scan-packs.sh` 模板 | 源→再生（单向，禁手改派生面） | D8：改模板后再生 |
| `.agents/skills/gate/SKILL.md` 的 Gate 2 条文 | `.tad/gates/gate-canonical-checklist.md` | canonical→SKILL 同步；本 Phase 只核 D9 新增行的作用域 diff | D9 |
| `.claude/skills/surplus/SKILL.md` 投影 | `.agents/skills/surplus/SKILL.md` | 同步机制处理 | D5：只改源面 |
| `behavioral-eval-status.yaml` | conductor 的 eval 实跑结果（本 Phase 无新实跑） | 人工维护的决策状态面 | D6/D7：只改词表与既定行，不伪造验证结果 |

**Human验证点**：四组同步方向均已点名；Blake 若发现第五组派生关系（如 workflow 的其他投影面），停步上报（§10.4）。

### MQ4: 视觉层级

**回答**：
- [x] 无不同状态的用户可见面 → 跳过（台账状态值是文本词表，其「可区分性」由 D6 的状态语义定义与 RP3 走查承载）

### MQ5: 状态同步

#### 状态存储位置

| 数据 | 存储位置1 | 存储位置2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| 五票终局状态 | 票头 Status 行（读者面） | 票内收口节＋终局链证据件（凭据面） | 分诊关票时同改 | 凭据→票头（D1） |
| pack 验证状态 | behavioral-eval-status.yaml（决策面） | pack-registry.yaml（派生面，不载验证状态） | 本 Phase 一次性对齐 | 单向，无回写 |
| AC-08 豁免 | scope-registry.json（数据面，本 Phase 新建） | AC-08.py（消费面） | 运行间增改、运行中只读 | 数据→代码（DESIGN §3.6 治理） |

✅ 主状态已逐项标注；同步时机明确；不存在双写竞争面。

---

## 6. Implementation Steps（分Phase）

## 6.1 Micro-Tasks

| # | File | Operation | Verification Command | Est. Time |
|---|------|-----------|---------------------|-----------|
| 1 | （证据根） | 快照改前 fixture ＋录本机基线行集 | `cp .tad/tests/backup-lifecycle-fixture.sh .tad/evidence/yolo/v409-basket/fixture-pre-fix.sh` | 5 min |
| 2 | 五票票头 | 三票分诊关票（Status 行＋关票凭据行） | `grep -H "Status" .tad/active/TICKET-20261028-*.md` | 15 min |
| 3 | `.tad/tests/backup-lifecycle-fixture.sh` | 改 `mode_of()` 语义分派（D3） | §9.1 AC2 探针命令 | 15 min |
| 4 | `.tad/active/DESIGN-20261031-ac08-baseline.md` | §1 两数更正（D11①） | `grep -n "126 行" <file>` | 5 min |
| 5 | `.agents/skills/surplus/SKILL.md` | throw 句独立成条（D5） | §9.1 AC7 awk 段界命令 | 10 min |
| 6 | `.tad/capability-packs/behavioral-eval-status.yaml` | 头注词表＋两行降格/改判＋补 2 行＋ml-training 行注记（D6/D7） | §9.1 AC5/AC6 grep 与 awk 计数 | 20 min |
| 7 | `.tad/scripts/scan-packs.sh`＋registry | 表头模板回写→再生→ml-training 移置→再再生（D8） | §9.1 AC8 grep＋driftcheck 基线对账（只许既存 (b) `production-observation`） | 25 min |
| 8 | `.tad/gates/gate-canonical-checklist.md`＋gate SKILL＋T-1b 票头 | Gate 2 机械行＋同行同步＋关票凭据（D9） | §9.1 AC9 唯一键行作用域 diff＋AC18 | 20 min |
| 9 | `.tad/tasks/evidence-collection.md` | 分段落盘纪律成节（D10） | §9.1 AC13 grep 三项 | 15 min |
| 10 | AC-08.py＋scope-registry.json | 分类＋全量报告改造（D12/D16） | §9.1 AC14/AC15 | 90 min |
| 11 | 两 workflow 脚本 | 需求声明＋Validate 期探针（D13/D14） | §9.1 AC16 grep＋wrapped-body 语法检 | 45 min |
| 12 | （运行） | 副本探针运行＋缺项 fixture（RP2/AC17） | §6 P4-S3 步 3–4 | 30 min |

### Phase 1: Step 1 — 票面分诊与 salvage（预计 1.5 小时）

#### 交付物
- [ ] 五票分诊表（落 COMPLETION 对应节）与三票关票后的票头
- [ ] salvage 改后 fixture＋双平台行集对照证据

#### 实施步骤
1. 快照改前 fixture 进证据根；在本机 plain env 录基线行集（设计已录一份在 §9.1 AC1，Blake 仍须自录一份当轮基线入证据根，两份对不上先停步查因）。
2. 逐票分诊：核终局链件在盘（design/impl/review 件 `test -f`）、改动面现状（checker 三票的对象面现状与收口自述逐项对）；三票关票＝票头 Status 改 `CLOSED（分诊核验关票 2026-10-31，凭据见下行）` 并加一行终局链凭据指针；T-1b 不在本步动（其实施在 P3-S2）；salvage 票分诊结论＝属实未落。
3. 改 `mode_of()`（D3）：语义值（纯数字 mode）才采信的分派；动手前回读 patterns/shell-portability.md 全文（AGENTS.md 路由）；fixture 其余行不动。
4. 本机同 env 重跑 `--case salvage` 全行集，与基线逐行 diff 入证据（D2 口径）；再跑 `--case all` 一轮确认其他 case 无回退（基线同法先录）。
5. Mac 腿：ssh mac 在同步副本上，先以快照文件（同步过去的 fixture-pre-fix.sh 副本或 Mac 侧同步到的改前版本）录基线行集，再跑改后文件，行集对照入证据（D4）。Mac 侧命令在副本仓内以相对路径跑，PYTHONDONTWRITEBYTECODE 不涉及（纯 shell）。
6. salvage 票头 Status 更新为「已修待 Gate 验」形态并附双平台证据指针（关票动作留 Phase 收口，票头先记实施凭据）。

#### 验证方法
- §9.1 AC1/AC2/AC3 全行；RP1 由 Gate 3 run reviewer 按 §9.1 同命令重跑。

#### 🆕 Phase 1 完成证据（Blake必须提供）
- [ ] 分诊表（五票逐票结论＋凭据路径）
- [ ] 双平台行集 diff 件（VM 与 Mac 各一份）
- [ ] `mode_of` 改前/改后对照

### Phase 2: Step 2 — AC-08 实现（预计 2.5 小时）

#### 交付物
- [ ] 新 AC-08.py＋scope-registry.json＋AC-08.py.prev
- [ ] 记录集重跑的完整报告（含 SUMMARY 与 AC-08-report.json）
- [ ] 设计件 §1 更正与本 handoff 的 AC2 底座锁定修订行

#### 实施步骤
1. 先锁两件（D11）：更正 DESIGN §1 两数；把 AC2 底座（捕获件四件＋--root 重建命令原文）写进本 handoff 的修订行（追加在文末 Gate Rounds 后或 §10 修订注，形态自选但须可 grep 到「AC2 底座」）。
2. 按 DESIGN §3–§5 改造：分类器（§3.5 五步，含 D12① 的 T-未枚举路由）、collect-and-continue、登记册加载/校验、文本 SUMMARY＋JSON 侧车、旧口径对照行。
3. R 类 FLAG 退出码二选一锁死（D12②），脚本头注与 COMPLETION 同步落字。
4. 在 scratch 树按底座重建记录集环境，跑 DESIGN §7 六条（AC1–AC6 对应本 handoff AC15 的六个子断言）：fixture 全集报告、E1 收编对照（删登记翻转负控）、四类七子断言、无静默跳段、豁免在数据、文本行集兼容。
5. 旧脚本留 `AC-08.py.prev`；新旧输出行集 diff 入证据。

#### 验证方法
- §9.1 AC12/AC14/AC15；六条子断言逐条留运行输出件。

#### 🆕 Phase 2 完成证据（Blake必须提供）
- [ ] 记录集重跑报告全文＋JSON 侧车
- [ ] 六条子断言的逐条输出
- [ ] 行集 diff（新旧输出）

### Phase 3: Step 3 — 框架落字三件（预计 1.5 小时）

#### 交付物
- [ ] surplus SKILL 落位修正（D5）＋探针口径一句（D15 的落字部分，与 Step 4 串行同文件）
- [ ] pack 台账小修全件（D6/D7/D8）
- [ ] Gate 2 机械行（D9）与分段落盘纪律（D10）

#### 实施步骤
1. G4-F3：拆句成条，逐字对照 GATE4-20261031 的 FIX 对单第 12 项 (i) 原文。
2. 台账：先改头注词表（D6），再逐行处置（2 行改判、9 行降格表述、补 2 行、ml-training 行注记）。
3. registry 面：先 grep 全仓 ml-training 源包路径引用并记录；改 scan-packs.sh 表头模板（compatibility 注释输出裁定文本：字段保留为元数据、Phase 2 兼容检查待办已裁、理由一句、指向 TICKET-20261031-pack-triage）；移置源包目录；跑再生；跑 pack-registry-driftcheck.sh 并按 D8 的基线 delta 对账（不要求 exit 0；(a)/(c) 须为空，(b) 只许既存 `production-observation`，不得有 ml-training 或新项）。
4. T-1b：canonical Gate 2 节增带唯一键 `handoff-header-form` 的机械行（核心行文含三核验点、新合同适用面与存量豁免），把同一核心行同步到 gate SKILL 的 Gate 2 派生块；按 AC9 对两行做归一化作用域 diff，结果须为空。不跑 drift-check.sh，不以两份 Gate 2 全节 diff 为完成条件。
5. 落盘纪律：evidence-collection 增节（D10 四要件齐）。
6. 本 handoff 即 AC9 的活验收样本：COMPLETION 中显名「本 handoff 首行与 front matter 形态已按新机械行自核」一行，并附 AC9 头形命令的输出指针（正式核验留痕在 Gate 2 首轮与复审记录）。
7. T-1b 关票：仅在第 4 步作用域 diff 为空且 Gate 2 复审已对本 handoff 头形留合规痕后，把 T-1b 票头 Status 改为 CLOSED 并加一行关票凭据（指向 Gate 2 首轮＋复审记录、canonical 与 gate SKILL 的唯一键行位）；任一凭据未成立则不关票、停步回 conductor（AC18）。

#### 验证方法
- §9.1 AC5–AC10、AC13、AC18；RP3 走查三问（答案只许来自状态值列）。

#### 🆕 Phase 3 完成证据（Blake必须提供）
- [ ] 每件落字的改前/改后对照（或 diff 指针）
- [ ] 再生前后 registry 条目数与 driftcheck 输出＋基线 delta 对账（既存 (b) 单项须显名，不得写成 exit 0）
- [ ] ml-training 引用 grep 清单与逐条交代

### Phase 4: Step 4 — 运行时探针口径（预计 1.5 小时）

#### 交付物
- [ ] 两脚本的需求声明＋探针段
- [ ] 副本运行的探针报告证据（本 harness）与缺项 fixture 红灯证据

#### 实施步骤
1. 两脚本头部加 `runtime-requirements:` 声明段（D14：全局名＋类别＋缺失后果）。
2. Validate 期、首个 agent() 调用前加探针段（D13 分工）：硬需求缺失→throw 红灯并点名缺项；facade 覆盖项缺失→一行降级注记续行。探针段不许调用 agent/phase 本身做探测（零成本口径：只读全局存在性）。
3. 副本运行（RP2）：按修复链 Copy-execution protocol——把改后 surplus-execute 逐字复制进本 Phase 证据根、跑前跑后 sha256 对账；以探针观察型调用运行（沿 invocation-specs 的探针调用形态：构造使执行在 Validate 后即止的 args），核探针报告出现在任何 agent 活动之前、且 budget 缺失只报降级不红灯。
4. 缺项 fixture：构造缺 agent 的运行时描述喂探针段（仓外测床形态，照 G4-F1 定向探针先例：逐字抽出探针段在 /tmp 测床以缺项描述运行），须红灯点名 agent；测床件与输出入证据，测床不入仓。
5. wrapped-body 语法检两脚本（ac-verification 在册法）。

#### 验证方法
- §9.1 AC16/AC17；RP2 由 Gate 3 按同走查复核（副本哈希对账行必查）。

#### 🆕 Phase 4 完成证据（Blake必须提供）
- [ ] 探针报告输出件（副本运行）＋副本 sha256 对账行
- [ ] 缺项 fixture 的红灯输出
- [ ] 两脚本语法检输出

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/scope-registry.json  # AC-08 豁免登记册（数据面，DESIGN §3.6）
.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py.prev        # 旧脚本留置（改造前复制）
.tad/capability-packs-retired/ml-training/                                                    # ml-training 源包移置目的地（目录整体）
（证据件一律落 .tad/evidence/yolo/v409-basket/ 下，清单见 §9 的 Required Evidence Manifest）
```

### 7.2 Files to Modify
```
.tad/active/TICKET-20261028-checker-false-negative.md      # 分诊关票：仅票头 Status＋关票凭据行（D1）
.tad/active/TICKET-20261028-handoff-creation-loadpoints.md # 同上
.tad/active/TICKET-20261028-r4-distill-text-pack.md        # 同上
.tad/active/TICKET-20261028-gate2-form-enforcement.md      # D9 落地并经 Gate 2 复审留痕后关票：仅票头 Status＋关票凭据行（AC18）
.tad/active/TICKET-20261028-backup-fixture-tmpfs-stat.md   # 实施凭据回填票头（关票留收口）
.tad/tests/backup-lifecycle-fixture.sh                     # mode_of() 一处（D3）；装载点位：fixture 运行即触发
.tad/active/DESIGN-20261031-ac08-baseline.md               # §1 两数更正（D11①，本 Phase 显名授权面）
.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py  # 分类＋全量报告改造（D12/D16）
```

Step 3/4 面：

```
.agents/skills/surplus/SKILL.md                            # D5 拆句成条＋D15 探针口径一句（两处，串行）
.tad/capability-packs/behavioral-eval-status.yaml          # 头注词表＋行处置（D6/D7）；装载点位：台账读者与 pack-eval 契约
.tad/scripts/scan-packs.sh                                 # 表头模板的 compatibility 注释行（D8）
.tad/capability-packs/pack-registry.yaml                   # 仅由 scan-packs.sh 再生产出（禁手改）
.tad/gates/gate-canonical-checklist.md                     # Gate 2 节增机械行（D9）；装载点位：Gate 2 评审进入时
.agents/skills/gate/SKILL.md                               # D9 同步面（只核唯一键行的作用域 diff）
.tad/tasks/evidence-collection.md                          # 分段落盘纪律成节（D10）；装载点位：证据收口时
.tad/workflows/claude/surplus-execute.workflow.js          # 需求声明＋探针段（D13/D14）
.tad/workflows/claude/surplus-scan.workflow.js             # 同上（从简同构）
```

### 7.3 Grounded Against (Alex step1c, 2026-10-31)

**Grounded Against**（Alex step1c 实际 Read 过的源文件，head 50 或所注范围）：
- `.tad/active/TICKET-20261028-checker-false-negative.md`（全文，read at 2026-10-31 15:47 UTC）
- `.tad/active/TICKET-20261028-handoff-creation-loadpoints.md`（全文，同上）
- `.tad/active/TICKET-20261028-r4-distill-text-pack.md`（全文，同上）
- `.tad/active/TICKET-20261028-gate2-form-enforcement.md`（全文，同上）
- `.tad/active/TICKET-20261028-backup-fixture-tmpfs-stat.md`（全文，同上）
- `.tad/active/DESIGN-20261031-ac08-baseline.md`（全文，同上）
- `.tad/active/TICKET-20261031-pack-triage.md` / `TICKET-20261031-process-suggestions.md`（全文，同上）
- `.tad/tests/backup-lifecycle-fixture.sh`（head 30＋L80–100＋L194–265，同上）
- `.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py`（head 50，同上；全文行数 180 经 wc 实测）
- `.agents/skills/surplus/SKILL.md`（L95–135，同上）
- `.tad/capability-packs/pack-registry.yaml`（L1–30，同上）
- `.tad/capability-packs/behavioral-eval-status.yaml`（L1–60，packs 段全 24 行经 awk 计数复核，同上）
- `.tad/capability-packs/ml-training/CAPABILITY.md`（head 15，同上）
- `.tad/scripts/scan-packs.sh`（head 25，同上）
- `.tad/workflows/claude/surplus-execute.workflow.js`（head 40＋L118/L175/L179–203/L492/L598 定点，同上）
- `.tad/workflows/claude/surplus-scan.workflow.js`（head 25，同上）
- `.tad/tasks/evidence-collection.md`（head 40；全文 478 行经 wc，同上）
- `.agents/skills/gate/SKILL.md`（head 30，同上）
- `.tad/evidence/surplus-execute-fix-20261031/GATE4-20261031.md`（L125–170，同上）
- `.tad/evidence/tiering-log.md`（head 21，同上）
- `.tad/capability-packs/skill-only-declarations.txt`（head 10，同上）

---

## 8. Testing Requirements

### 8.1 Unit Tests
- salvage：fixture 自带断言即单元面（AC1/AC2/AC3）。
- AC-08：DESIGN §7 的 fixture 类标准即单元面（AC15 子断言）。

### 8.2 Integration Tests
- 探针副本运行（AC17/RP2）＝ workflow 入口的集成面；台账 RP3 走查＝读者面集成验。

### 8.3 Edge Cases
- 基线行集在 Blake 当轮自录时与设计所录不一致（环境漂移）：停步查因再继续，不许挑一份顺眼的用（§6 P1-S1 步 1）。
- scan-packs 再生产出无关 diff（他包 CAPABILITY 近期变动）：按 §10.2 停步上报，不许顺手保留。
- Mac 同步未达：见 §8.4 替身口径。

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Mac 同步副本未含当日改后 fixture | Step 1 Mac 腿（AC3） | 等同步达后重跑，或经 ssh 把改后文件直送 Mac 的 scratch 目录运行（文件内容经 conductor 知悉） | DEGRADED_WITH_APPROVAL（conductor 记录在案）后以 scratch 直送形态跑，结论口径不变 | 无记录的跳过 → AC3 不成立、Gate 3 不得 PASS |
| 本 VM 跑 fixture 的 env 口径漂移 | Step 1 基线与重跑（AC1） | 一律 plain env（基线所录口径；带 GIT_DISCOVERY_ACROSS_FILESYSTEM 的一次运行曾 600 秒超时、其后同命令约 12 秒跑完且行集一致，超时不可复现——不论何 env，须与基线同口径才可比） | 无 | 环境口径与基线不一致 → 行集对照无效 |
| 本 harness Workflow 运行时构成变化（budget 全局出现等） | Step 4 副本运行（AC17） | 按 D13 分工读报告：facade 项在场记「原生委托」形态，探针结论仍成立 | 无（硬需求缺失的红灯面由 fixture 承载，不依赖 harness 构成） | 把 facade 在场误判为探针失效 → Gate 3 复核纠正 |
| Gate 2 双审未定稿 | Blake 开工前置 | 等 conductor 路由（handoff 状态以 Epic ## Run 指针为准） | 无 | 未定稿开工 = 越序，Gate 3 不认 |

**Status Enum**: `READY` / `BLOCKED` / `DEGRADED_WITH_APPROVAL` / `EQUIVALENT_SUBSTITUTE` / `NOT_APPLICABLE_WITH_REASON`

## 8.5 Feedback Collection (Non-Code Artifacts)

N/A（代码与规程文本面，无需人判读的非代码产物）。

## 8.6 🆕 Test Evidence Required
Blake必须提供：
- [ ] §9.1 每行的运行输出或走查记录（落证据根，清单见 Required Evidence Manifest）
- [ ] 双平台行集对照件
- [ ] 副本运行的 sha256 对账行

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] §9.1 全行 PASS（Gate 3 逐行执行）
- [ ] RP1–RP3 各有 run 行或合规 not-run 记录
- [ ] Required Evidence Manifest 所列证据件全在盘
- [ ] 五票终局状态与 COMPLETION 分诊表一致

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | salvage 本机行集对照（D2）：改后同 env 重跑，mode 断言行 FAIL→PASS，其余行 verdict 与基线逐行一致（变化行在 COMPLETION 逐行归因） | pre-impl-verifiable | `PYTHONDONTWRITEBYTECODE=1 /bin/bash .tad/tests/backup-lifecycle-fixture.sh --case salvage`（plain env），输出与证据根基线行集逐行 diff | 改后行集含 `PASS: salvage: the diff file sits beside the backup bytes`；基线 2 条 PASS 行仍 PASS；diff 仅 mode 行翻转（或其余变化全有归因） | 基线已录（2026-10-31）：9 行 PASS=2 FAIL=7；目标行现为 `FAIL: salvage: diff file wrong ( mode=)`——以正确理由失败 |
| AC2 | mode_of 语义探针（D3）：对 chmod 600 与 644 两临时文件，salvage 所用 mode 取值路径只输出纯数字且与 chmod 值相等（GNU 本机） | pre-impl-verifiable | 从改后 fixture 抽 mode_of 定义在 /tmp 测床定义后对两文件调用（测床法同 G4-F1 先例），断言输出 `600`／`644` | 两次输出各为单行纯数字且相等 | 现行链已知 BAD 已证：修订轮直调对 600 与 644 均输出多行文件系统转储（本机各 6 行：5 行转储＋末行数字；行数随 env／文件系统形态可变），不是单一语义值；fixture 内实测返回空 |
| AC3 | salvage macOS 腿（D4）：Mac 上改前快照基线与改后行集对照，口径同 AC1 | post-impl-verifiable | ssh mac 在同步副本仓内跑快照件与改后件各一轮 `--case salvage`，两份行集落证据根后逐行 diff | `salvage-mac-baseline.txt`／`salvage-mac-after.txt` 在盘（与 Required Evidence Manifest 同名）；mode 行翻 PASS；其余行变化逐行归因 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC4 | fixture 无回退：`--case all` 改后与改前（快照件）同 env 各跑一轮，非 salvage case 的行集 verdict 不回退 | post-impl-verifiable | 两轮 `--case all` 输出落证据后逐行 diff（salvage 行除外） | 非 salvage 行 verdict 集合与基线一致 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC5 | pack 台账词表与计数（D6）：头注含 `no-discriminative-power` 与 verified-discriminative 分级语义；两个状态值计数均作用域化到 `packs:` 段条目行（头注措辞不入计数） | pre-impl-verifiable | `grep -c "no-discriminative-power" .tad/capability-packs/behavioral-eval-status.yaml`；`awk '/^packs:/{f=1;next} f{print}' <同文件> \| grep -cE ': +verified-discriminative( \|$)'`；`awk '/^packs:/{f=1;next} f&&/^  [a-z]/{n++} END{print n}' <同文件>` | 三值依次 ≥2、=9、=26（第二值只数 packs 段内的 9 条 verified-discriminative 状态行） | 修订轮字面复核：三命令基线依次 0／0／24。原稿所记 9 是另一命令对裸 `verified` 的计数、26 是 registry 条目数，均不是本行三命令的基线输出；registry 改后 25 由 AC8 承，不混入本行 |
| AC6 | 补行在位（D7）：agent-computer-interface 与 ai-podcast-production 各有一行，状态值与盘面 fixture 事实相符 | pre-impl-verifiable | `grep -nE '^  (agent-computer-interface\|ai-podcast-production):' .tad/capability-packs/behavioral-eval-status.yaml` | 两行各一行，状态为 pending（注 fixture 名）或 no-fixture（注依据） | 设计已核：packs 段 24 行全文已读，两名均不在——以正确理由缺失 |
| AC7 | G4-F3 落位（D5）：throw 句独立成条且逐字不变；Budget guard 条正文止于 “…circuit-breaker semantics.” | pre-impl-verifiable | `awk '/^- \*\*Budget guard\*\*/{f=1} f{print} /ledger mode does not support nested workflow/{exit}' .agents/skills/surplus/SKILL.md` 段界走查＋`grep -c "ledger mode does not support nested workflow" <同文件>` | grep 计数 =1；走查显示 throw 句为独立条目、Budget guard 条内不再含该句 | 基线已录：该句现位于 L119、Budget guard 条（L115–119）正文内——落位未合 |
| AC8 | compatibility 回写与摘注册（D8）：registry L9 注释为裁定文本；再生后条目 25；ml-training 源包在 retired 路径字节保留；driftcheck 按既存基线 delta 对账（不要求 exit 0） | pre-impl-verifiable | `grep -n "synced_from_version" .tad/capability-packs/pack-registry.yaml`；`grep -c '^  - name:' <同文件>`；`test -f .tad/capability-packs-retired/ml-training/CAPABILITY.md`；`bash .tad/hooks/lib/pack-registry-driftcheck.sh` | 注释含「已裁」与票号指针、无「consumer TBD」；条目数 25；retired 件在盘；driftcheck 的 (a)/(c) 为空、(b) 仅既存 `production-observation`、(d) 仅同项 WARN，无 ml-training 或其他新项；exit 可仍为 1 且只能由该既存 (b) 导致 | 基线已录：L9 现为 `… # reserved for cross-version compatibility checks (Phase 2 consumer TBD)`、条目 26、retired 件不在盘；driftcheck 修订轮实跑 exit 1，(a)/(c) 无、唯一实质项 (b) `production-observation` |
| AC9 | T-1b 机械行（D9）：canonical 与 gate SKILL 各增唯一键机械行；本 handoff 为活样本且头形可直接判 | pre-impl-verifiable | `grep -n "handoff-header-form" .tad/gates/gate-canonical-checklist.md`；`grep -n "handoff-header-form" .agents/skills/gate/SKILL.md`；`diff <(grep -F "handoff-header-form" .tad/gates/gate-canonical-checklist.md \| sed -E 's/^ *//; s/^- \[ \] //; s/ *Why ME:.*$//') <(grep -F "handoff-header-form" .agents/skills/gate/SKILL.md \| sed -E 's/^ *//; s/^- \[ \] //; s/ *Why ME:.*$//')`；`awk 'NR==1{first=$0} /^dispatch_id:/ && !d{d=NR} NR>1 && /^---$/ && !c{c=NR} END{print "first=" first; print "dispatch_line=" d; print "frontmatter_close=" c; print (d>1 && d<c ? "header-form: PASS" : "header-form: FAIL")}' .tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md`；`grep -cF "\| # \| Acceptance Criterion \| Verification Type \| Verification Method \| Expected Evidence \| Verified Output (Alex step1d) \|" .tad/active/handoffs/HANDOFF-20261031-small-fix-batch.md` | 两文件各恰一行、含三点；作用域 diff 空；头形 `header-form: PASS`；形态 A 表头计数 =1；首轮与复审均留三项痕 | 基线：两处唯一键皆无；原稿头形 FAIL（23／21、表头合），修订后子检 PASS（2／23）；机械行未落地前整体仍正确失败 |
| AC10 | 分诊关票（D1）：三票票头 Status 为 CLOSED 且各带终局链凭据指针行 | post-impl-verifiable | `grep -H "Status" .tad/active/TICKET-20261028-checker-false-negative.md .tad/active/TICKET-20261028-handoff-creation-loadpoints.md .tad/active/TICKET-20261028-r4-distill-text-pack.md` | 三行均含 CLOSED 与 `.tad/evidence/yolo/distill-tickets/` 指针 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC11 | salvage 票头回填：票头记实施凭据（双平台证据指针），状态形态与 COMPLETION 分诊表一致 | post-impl-verifiable | `grep -A2 "Status\|状态" .tad/active/TICKET-20261028-backup-fixture-tmpfs-stat.md \| head -6` | 票头含双平台证据路径与「待 Gate 验」形态表述 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC12 | DESIGN §1 两数更正（D11①）：「约 157 行」消失，126 行／113 PASS 必须落在 DESIGN §1 内且与盘面记录集一致 | pre-impl-verifiable | `grep -c "157" .tad/active/DESIGN-20261031-ac08-baseline.md`；`grep -c "^PASS" .tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/gate4-ac08-output.txt`；`wc -l < 同目录 gate4-ac08-output.txt`；`awk '/^## 1\./{f=1} /^## 2\./{f=0} f' .tad/active/DESIGN-20261031-ac08-baseline.md \| grep -c '126'`；`awk '/^## 1\./{f=1} /^## 2\./{f=0} f' <同文件> \| grep -c '113'` | 五值依次 0、113、126、≥1、≥1；后两值只统计 §1（自 `## 1.` 起、至 `## 2.` 前），两数落在他节不算 | 基线已录：前三值依次 1、113、126；§1 作用域内 `126` 与 `113` 计数均为 0，唯一 `157` 在 DESIGN L19 的 §1.2 待更正句——以正确理由失败 |
| AC13 | 分段落盘纪律（D10）：evidence-collection 新增节含四要件（分段／验字节／总字节数与章节清单／无截断标记自查）与 8KB 门槛 | pre-impl-verifiable | `grep -c "分段" .tad/tasks/evidence-collection.md`；`grep -n "8KB\|8 KB" <同文件>` | grep ≥1 且门槛行在盘、四要件同节可读出 | 基线已录：grep「分段」= 0——以正确理由失败 |
| AC14 | AC-08 结构（D12/D16）：check 不再 fail-fast；登记册为数据文件且字段齐；旧脚本留置 | post-impl-verifiable | `awk 'BEGIN{incheck=0;found=0} /^def check\(/ {incheck=1;next} incheck && /^def / {incheck=0} incheck && /sys\.exit/ {print NR ": " $0; found=1} END{if(!found) print "check-body sys.exit: none"}' .tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py`；`test -f <同目录>/scope-registry.json`；`test -f <同目录>/AC-08.py.prev`；登记册字段走查（owner/guard/granted_by/date） | 第一命令只抽 `check()` 函数体（自 `def check(` 起、至下一顶层 `def` 前），输出须恰为 `check-body sys.exit: none`；全量跑完后的结算性退出不在该作用域内，不与 fail-fast 混判；两文件在盘；种子恰 3 条（2 豁免＋1 R 模式） | 基线已由同一 awk 实跑：输出 `33:     if not ok: sys.exit(1)`，证明现行 check 体确有 fail-fast；scope-registry.json 与 AC-08.py.prev 均不在盘——以正确理由失败 |
| AC15 | AC-08 验收六条（DESIGN §7 逐字）：全集报告／E1 收编对照（含删登记翻转负控）／四类七子断言／无静默跳段／豁免在数据不在代码／文本行集兼容 | post-impl-verifiable | 按 DESIGN-20261031 §7 表六行逐条执行其「验证形态」列（fixture／command／path-check），底座按 D11② 锁定口径（命令原文在 handoff 修订行） | 六条子断言逐条 PASS 且输出件在证据根；负控（删登记）翻转成立 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC16 | 需求声明（D14/D15）：两 workflow 头部各有 runtime-requirements 声明段（全局名＋类别＋缺失后果）；surplus SKILL 有探针口径一句 | pre-impl-verifiable | `grep -c "runtime-requirements" .tad/workflows/claude/surplus-execute.workflow.js .tad/workflows/claude/surplus-scan.workflow.js`；`grep -c "探针" .agents/skills/surplus/SKILL.md` | 两脚本计数各 ≥1；SKILL 计数 ≥1（D15 落字后） | 基线已录：两脚本声明段计数 0/0、SKILL「探针」计数 0——以正确理由失败 |
| AC17 | 探针行为（D13）：副本运行在本 harness 于任何 agent 活动前出探针报告（budget 缺失只报降级、不红灯、续行）；缺 agent 的测床 fixture 红灯点名 | post-impl-verifiable | RP2 走查：按 §6 P4-S3 步 3 以证据副本调用并保存输出；步 4 测床运行保存输出；两件入证据根后走查（报告时序与点名） | 副本输出中探针报告行先于任何 agent 活动行；测床输出含红灯与 `agent` 点名 | (post-impl — Blake runs at Gate 3 v2 Layer 1) |
| AC18 | T-1b 关票凭据（D1/D9）：票头终局状态与 D9 落地及 Gate 2 活样本留痕一致，不再只关其余四票 | post-impl-verifiable | `grep -H "Status" .tad/active/TICKET-20261028-gate2-form-enforcement.md`；`grep -n "handoff-header-form" .tad/gates/gate-canonical-checklist.md .agents/skills/gate/SKILL.md` | 票头 Status 含 CLOSED；票头关票凭据行同时指向 Gate 2 首轮与复审记录（本 handoff 头形核验）和 canonical／gate SKILL 的唯一键行位；除票头 Status 与该凭据行外，票面历史正文不改 | 基线已录：票头为 `Status: OPEN（待分诊）`，无对应关票凭据行；两处唯一键行均不存在——以正确理由失败 |

**AC Dry-Run Log**（Alex step1d 实际 dry-runs at 2026-10-31 15:47–16:05 UTC；命令以 raw 形态先行、入表时按表格转义）：
- AC1: ✅ pre-impl，raw cmd 同 §9.1，基线输出 PASS=2 FAIL=7（含签名行 `diff file wrong ( mode=)`），与预期形态 match
- AC2: ✅ pre-impl 基线探针，当前链输出多行转储（修订轮对 600／644 各实测 6 行，行数随 env 变）——known-BAD 成立；改后分支为 post-impl 复核
- AC3/AC4/AC10/AC11/AC14/AC15/AC17/AC18: ✅ post-impl，命令形态经 `bash -n` 级语法核（fixture/脚本均为仓内既有 CLI 形态，参数面已对 --help/头注）；AC4 的 `--case all` 与 AC1 同入口
- AC5: ✅ pre-impl，修订轮字面复跑 0／0／24；原稿 9／24／26 非同组输出（9＝裸 `verified`、26＝registry），已更正；作用域化第二命令基线同为 0
- AC6: ✅ pre-impl，packs 段全文目视核（24 行清单在 §2.2），两名缺失确认
- AC7: ✅ pre-impl，grep 定位 L119、段界 L115–119 已录
- AC8: ✅ pre-impl，L9 与条目 26 已录；driftcheck 实跑 exit 1（唯一实质项 (b) `production-observation`）；AC8 改按基线 delta 判
- AC9: ✅ pre-impl，两文件唯一键行均不存在；头形原稿 FAIL（23／21）、修订后 PASS（2／23），形态 A 表头 =1；行未落地前整体仍正确失败
- AC12: ✅ pre-impl，盘面记录集 113 PASS／126 行实测；DESIGN 全文 `157` 计数 =1（L19），且新增 §1 作用域计数 `126`／`113` 均为 0，设计件未改确认
- AC13: ✅ pre-impl，grep = 0
- AC14: ✅ 修订轮基线作用域探针已实跑：限定 `check()` 函数体的 awk 输出 L33 的 `sys.exit(1)`；全文件其他 exit 不冒充 check 体证据，改后判据为同命令输出 `check-body sys.exit: none`
- AC16: ✅ pre-impl，两脚本 grep 0/0
- AC18: ✅ pre-impl 基线已录：T-1b 票头 OPEN、无关票凭据行，canonical 与 gate SKILL 的唯一键行均不存在
- Advisory tail：`verify-ac-commands.sh` 已于设计时与 Gate 2 修订轮各实跑一次（均 exit 0，2 WARN＋1 INFO），逐项对账——RULE B×2（AC5/AC6）：表中 `\|` 为 markdown 渲染转义，可运行形态为裸 `|`（本表干跑即以裸形态执行，输出已录）；RULE D INFO（AC16）：「探针」计数对象是 SKILL 与 workflow 两文件、非本 handoff 自身，且 SKILL 基线计数实测 = 0，无自泄漏。Gate 2 consistency 评审仍按 canonical 口径复跑 linter 并做字面 baseline 实跑。

**Volume gate (step1b_5)**: 81,652 B / 18 AC 行（限 81,920 B / 20 行）——两阈值均未超，静默通过，无须人裁分拆。Code bound 实测：max=15、total=42、open=0，合 bound。

## Required Evidence Manifest（Blake 必须产出，落 `.tad/evidence/yolo/v409-basket/`）

```yaml
evidence_root: .tad/evidence/yolo/v409-basket/
expert_reviews: []        # Gate 2 由 conductor 派发，不归 Blake
gate_verdicts: []         # 同上
completion: COMPLETION-20261031-small-fix-batch.md（落 .tad/active/handoffs/ 旁或证据根，按 COMPLETION 模板原件）
blake_must_produce:
  - fixture-pre-fix.sh（改前快照）
  - salvage-vm-baseline.txt / salvage-vm-after.txt（行集全文）
  - salvage-mac-baseline.txt / salvage-mac-after.txt（行集全文）
  - ac08-rerun-report.txt（记录集重跑全文）/ AC-08-report.json 副本
  - ac08-six-checks.txt（DESIGN §7 六条逐条输出）
  - probe-copy-run.txt（副本探针运行输出）＋副本文件本体（surplus-execute-copy.workflow.js）与 sha256 对账行
  - probe-missing-agent.txt（测床红灯输出）
  - pack-ledger-diff.txt（台账与 registry 改前/改后对照汇总）
fixture_results: [AC15 六条, AC17 缺项 fixture]
knowledge_updates: COMPLETION 的 Knowledge Assessment 节（skip_knowledge_assessment: no）
```

---

## 9.2 Expert Review Status (Alex 必填)

> 原 Y3 设计步按 conductor-dispatch-mode 止于 step1d，未自选评审人或自填结论。Gate 2 Round 1 后由 conductor 独立派发两份评审；本节现据盘面回填实际记录。`p1-y4-fix-1` 只做设计修订，不把 findings 写成已复审通过。

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| consistency（dispatch `p1-y4-cr-1`） | FAIL：P0×3、P1×3、P2×1、P3×2；文件 `.tad/evidence/yolo/v409-basket/p1-gate2-review-code.md` | 文末「设计修订记录（Gate 2 Round 1）」逐项处置表 | Addressed in revision — re-review pending |
| domain（dispatch `p1-y4-dom-1`） | FAIL：P0×1（与 consistency P0-1 为同一唯一项）、P1×1、P2×3；文件 `.tad/evidence/yolo/v409-basket/p1-gate2-review-domain.md` | 文末「设计修订记录（Gate 2 Round 1）」逐项处置表 | Addressed in revision — re-review pending |

### Lenses

1. **consistency** — always（矛盾、被改行的消费者、§9.1 每行字面命令的 baseline 实跑，含 `## AC dry-run (baseline)` 表）。
2. **risk（platform 面）** — `risk_triggers: [platform]` 非 `[none]`，按 review-contract 不取 fit；第二 lens 核平台／OS／shell／harness 与框架落地面。Round 1 实际第二份记录自报 lens 为 domain（见 Audit Trail），findings 已处置；复审构成由 conductor 按原件派发，本修订不改写 Round 1 记录。

### Overall Assessment (post-integration)

- Round 1 双份 verdict 均为 FAIL；全部唯一 findings 已在修订版中逐项处置，但尚未经独立复审，故整体状态仍为 **FAIL／待复审**，不得交 Blake 实施。

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ pack-registry.yaml 是再生物：任何手改都会在下一次 scan-packs 时被冲掉并制造假绿——台账类 AC 一律以「改源＋再生」验。
- ⚠️ salvage 基线行集对环境敏感：env 口径（plain env、禁 GIT_DISCOVERY_ACROSS_FILESYSTEM）与基线不一致时行集对照整体无效，先对 env 再对行。
- ⚠️ AC-08 记录集是哈希锁定的归档证据：重跑只读，scratch 重建在证据根下，不许就地跑出写副作用。

### 10.2 Known Constraints
- 文件夹制：仓内禁一切 git 命令；`git ls-files` 类 AC 在本仓无意义，本 handoff 已全部改用文件系统口径（patterns/ac-verification 2026-07-12 真空教训）。
- .bak 移除（BASKET 第 6 行）不在本 Phase；执行中遇 `.bak` 件只读不处理。
- scan-packs 再生产出与本 Phase 无关的 diff 时停步上报 conductor，不许顺手保留或回滚他面包。
- 同文件串行：surplus SKILL 被 Step 3（D5）与 Step 4（D15）各改一处，Blake 须串行落，不许并行子任务同改一文件。

### 10.3 🆕 Sub-Agent使用建议

Blake应该考虑使用：
- [ ] **parallel-coordinator** — Step 间写集不重叠，Step 1 与 Step 2 可并行推进（Step 3/4 因 surplus SKILL 同文件须串行）
- [ ] **test-runner** — 每 Step 完成后跑对应 §9.1 行
- [ ] bug-hunter / refactor-specialist — 不预设，遇失败时按 COMPLETION 记录

### 10.4 若遇下列情形（回 Alex/conductor，不许自裁）
- 分诊发现某票终局链证据与收口自述矛盾（如实施件缺失）：该票按未落地处置并把矛盾写进 COMPLETION 分诊表，不许替收口节圆场。
- ml-training 引用 grep 发现活消费者（如某 SKILL 正文指名其源包路径为承重输入）：停该件、上报 conductor，摘注册等裁断。
- 探针在副本运行中对 facade 覆盖项报出红灯（与 D13 分工不符）：属设计-实现不一致，停步回 Alex，不许改探针口径自行对齐。

---

## 设计修订记录（Gate 2 Round 1 · dispatch p1-y4-fix-1）

### 激活自报（Alex · p1-y4-fix-1）

- 角色：Alex（Solution Lead），按 conductor-protocol `step_Y4` 第 5a 条做 Gate 2 设计修订；只改本 HANDOFF，不写实现、不派 subagent、不自出 verdict。模式／对象自检：Alex design-fix，本文件。
- 激活路径：已加载 `~/workspace/skills/tad-alex/SKILL.md` 薄壳并进仓读原件：`AGENTS.md`、principles、patterns 索引及三件命中 pattern、brain-index 路由、handoff/gate 规程、canonical Gate 2、conductor-protocol step_Y4、conductor-dispatch-mode、Epic 与全部派发输入件。
- 修订输入：`p1-gate2-review-code.md`（`p1-y4-cr-1`，FAIL）与 `p1-gate2-review-domain.md`（`p1-y4-dom-1`，FAIL），均在 `.tad/evidence/yolo/v409-basket/`。下表逐条处置 14 条 source findings；两条 P0 同根，分别销账。
- 个人实测摘要：头形原稿 21／23，修订后 awk 2／23／PASS、形态 A 表头 =1；driftcheck exit 1、唯一实质项 (b) `production-observation`；AC5 字面值 0／0／24（作用域化第二命令 0；9／26 出处另复现）；`mode_of` 对 600／644 各 6 行（可变）；AC-08 fail-fast 在 L33、记录输出 126／113，DESIGN §1 内两数计数 0；`drift-check.sh` 的 `gate` 计数 =0，唯一键两处皆无，合成同核行作用域 diff 为空。

### Findings 逐项处置表

| Finding | 处置 | 改动位置 | 个人复核证据 |
|---|---|---|---|
| Code P0-1 — dispatch 行在 front matter 块外，样本自守声称失真 | 接受：当前 ID 改 `p1-y4-fix-1` 并移入块内，下一行记 history，删块外旧行；自守声称改实 | 文件头、激活自报、Gate 2 节、AC9 | 两 verdict 定位一致；修订后见实测摘要 |
| Domain P0-1 — AC9 没有能判出样本头形的方法 | 接受：AC9 新增本 HANDOFF 头形 awk 与形态 A 表头 grep，不再只靠记录留痕散文 | AC9、§6 Phase 3 步 6、Dry-Run Log | 头形命令实跑 PASS；行未落地时 AC9 仍正确失败 |
| Code P0-2 — AC8 的 driftcheck exit 0 在基线不可达 | 接受：不吸纳既存项；AC8 改基线 delta oracle（(a)/(c) 空、(b) 只许该项、无新项，exit 可 1） | §2.2、D8、MT7、§6 P3 步 3／证据、AC8、日志 | 实跑见实测摘要 |
| Code P0-3 — D9 指定 drift-check.sh 测不了门条文同步 | 接受：删该验收工具；改唯一键 `handoff-header-form` 两行归一化作用域 diff，不以全节 diff 为条件 | §2.3、D9、§4.2、MQ3、MT8、§6 P3 步 4、§7.2、AC9 | 实读四子检、`gate` =0；余见实测摘要 |
| Code P1-1 — AC5 基线 9／24／26 与字面三命令不符 | 接受并改正：AC5 与 Dry-Run Log 改记字面基线 0／0／24，并显名 9／26 的真实出处 | AC5、Dry-Run Log | 本轮字面复跑 0／0／24；另跑裸 `verified` =9、registry =26 |
| Domain P1-1 — AC5 的 verified-discriminative 计数未作用域化 | 接受：第二子命令先 awk 截 `packs:` 段再计数，头注不污染 =9 | AC5 | 作用域化基线 =0，口径已分开 |
| Code P1-2 — Mac 证据件名分裂 | 接受并改正：统一为 Manifest 的 `salvage-mac-baseline.txt`／`salvage-mac-after.txt` | D4、AC3 | 三处逐字对读，D4／AC3／Manifest 已同名 |
| Code P1-3 — T-1b 无写集／无 AC 承载，D9 误引 AC10 | 接受：§7.2 增票头写集；新增 AC18；D1 改引 AC10＋AC11＋AC18，D9 改引 AC9＋AC18 | D1、D9、MT8、§6 P3 步 7／验证、§7.2、AC18 | 票头 OPEN、唯一键皆无，正确失败 |
| Code P2-1 — AC-08 `check()` 行号误记 L26–28 | 接受并改正：统一改 L31–33，并注 L14／L18 属校验 helper | §2.2、MQ2 | 本轮 grep／实读：`def check` L31、check 体 exit L33 |
| Domain P2-1 — AC14 的全文件 grep 不判别 check 体作用域 | 接受：改状态 awk 只抽 `check()` 体；结算退出不在域内，期望显式 `check-body sys.exit: none` | AC14、Dry-Run Log | 同一 awk 基线命中 L33 |
| Domain P2-2 — AC12 不验两数落在 DESIGN §1 | 接受并改正：新增 §1 作用域 awk（`## 1.` 至 `## 2.` 前）分别计数 `126` 与 `113` | AC12、Dry-Run Log | 本轮作用域计数均为 0；全文件前三值 1／113／126 |
| Domain P2-3 — Gate 2 lens 与证据路径陈述违 review-contract | 接受：构成改 consistency + risk（platform），证据根改 yolo 本 Epic 根，实际 domain 件不改写 | Gate 2 节、§9.2 | 回读 contract：fit 仅 `[none]`、Cora 链落 yolo |
| Code P3-1 — RP2 指针多含实施步 2 | 接受并改正：RP2 与 Microtask 12 均改指 §6 P4-S3 步 3–4 | front matter RP2、Microtask 12 | 与 §6 Phase 4 步 3（副本调用）／步 4（缺项 fixture）逐项对读 |
| Code P3-2 — AC2 把基线行数钉为 5 行 | 接受并改正：改记多行转储、行数随 env／文件系统变；本轮数值只作实例，不作判据 | §2.2、AC2、Dry-Run Log | 本轮抽现行 `mode_of` 对 600／644 各实跑 6 行，定性 known-BAD 不变 |

### 修订结论（非 verdict）

- 14 条 source findings 全部接受并已在本 HANDOFF 内改正；无「不接受」项，无须附反证驳回。
- 本节只证明设计修订已逐项落字与基线已复核，不构成 Gate 2 复审结论。复审须由 conductor 以新 dispatch 独立派发；在复审定稿前，本 HANDOFF 仍不得交 Blake 实施。

---

## Gate Rounds

<!-- GATE-ROUNDS-BEGIN -->
GATE-ROUNDS-SCHEMA: v1
（派生定义逐字抄录自 gate/SKILL.md NO-PROGRESS 块：G2/G3/G4 计数与 TOTAL_ROUNDS 由下表行派生，无存储计数器；同一 Gate 同一 verdict 类别连续达阈触发 NO-PROGRESS CIRCUIT BREAKER 的口径以 gate/SKILL.md 原文为准，本表只记账。）

| 时间 | Gate | verdict | 类别 | 记录者 |
|---|---|---|---|---|
| 2026-10-31 15:47 UTC | design | DRAFT-COMPLETE | design-boundary | Alex (p1-y3-1) |
| 2026-10-31 16:00 UTC | G2-domain | FAIL (p0=1) | review | domain-reviewer (p1-y4-dom-1) |
| 2026-10-31 16:02 UTC | G2-code | FAIL (p0=3) | review | code-reviewer (p1-y4-cr-1) |
| 2026-10-31 16:17 UTC | G2-fix | REVISED (14 findings 全销向复审) | design-boundary | Alex (p1-y4-fix-1) |
| 2026-10-31 16:20 UTC | G2-code-rereview | CONDITIONAL (p0=0) | review | code-reviewer (p1-y4-cr-2) |
| 2026-10-31 16:21 UTC | G2-domain-rereview | PASS (p0=0) | review | domain-reviewer (p1-y4-dom-2) |
| 2026-10-31 | G2 | CONDITIONAL PASS (p0=0，合成) | gate | Cora（记账补行：本表 Round 1 各行由 conductor 据双面 verdict 补记，源 N1 路由） |
| 2026-10-31 16:11 UTC | G3-spec | CONDITIONAL (p0=0) | review | verifier (p1-y7-g3spec-1) |
| 2026-10-31 16:23 UTC | G3-code | CONDITIONAL (p0=0) | review | verifier (p1-y7-g3code-1) |
| 2026-10-31 | G3 | CONDITIONAL (p0=0，合成；四行未满足路由 Gate 4) | gate | Cora（记账补行，据双面 verdict） |
| 2026-10-31 16:31 UTC | G4 | CONDITIONAL PASS (p0=0；四裁定齐、C1–C3 收口条件) | gate | Alex (p1-y7-g4-1) |
<!-- GATE-ROUNDS-END -->

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-10-31
**Version**: 4.0.8

---

## 修订行（Phase 1 实施步 p1-y5-1，2026-10-31）：AC2 底座锁定（D11②）

- **AC2 底座**——捕获件四件（Gate 4 轮记录集，均在 `.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/`）：
  1. `gate4-ac08-output.txt`（Gate 4 轮旧检查实跑输出，全文件 126 行、PASS 113 行）
  2. `gate4-acceptance-report.md`（Gate 4 验收报告，含完整 FAIL 集人工担保原文）
  3. `baseline.json`（原始基线：targets 10、hashes 2099、status 56 行、head `ad030cb7675985be6054c83f51c558fef22acb09`）
  4. `repair-entry-scope-baseline.json`（repair-entry 捕获：non_target_hashes 2089 条、ignored_hashes 55725 条、external_delta_from_task_start 1 条）
- 重建法：scratch 树建于 VM 本地 `~/workspace/vm-local/ac08-scratch-p1/`（不入同步证据根——约 5.8 万条捕获路径的字节重建入同步树会引发同步风暴与磁盘压力，位置偏差在此显名；方法口径不变：`--root` 指向 scratch、基线证据经脚本头注的 REAL 回退读真实仓）。命令原文（实施步实际执行式）：
  ```bash
  git clone ~/workspace/vm-local/tad-src-408 ~/workspace/vm-local/ac08-scratch-p1
  git -C ~/workspace/vm-local/ac08-scratch-p1 checkout ad030cb7675985be6054c83f51c558fef22acb09
  git -C ~/workspace/vm-local/ac08-scratch-p1 apply /home/hatch/workspace/yun-sync/TAD/.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/task-delta.diff
  PYTHONDONTWRITEBYTECODE=1 python3 ~/workspace/vm-local/ac08-overlay-p1.py ~/workspace/vm-local/ac08-scratch-p1
  PYTHONDONTWRITEBYTECODE=1 python3 /home/hatch/workspace/yun-sync/TAD/.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py --root ~/workspace/vm-local/ac08-scratch-p1
  ```
- 已知重建残差（实施步实测）：ignored 捕获中 10619 条在当前树无字节源（2026-10-23 磁盘清理后已删，以 `.opencode/node_modules/` 为主），Leg-1（本底座）重跑对该批按缺失计数并逐类归因；AC2 的机械全称判定另由 Leg-2 受控 fixture 记录集完成（等价替代，理由与逐条结果见证据根 `ac08-six-checks.txt`）。
## 勘误 — AC7 梗概句（2026-10-31，EPIC-20261031 Phase 2 蒸馏批）

- **勘误对象**：本文件 §9.1 的 AC7 行梗概语「Budget guard 条正文止于 “…circuit-breaker semantics.”」与条文不符。`.agents/skills/surplus/SKILL.md` 的 Budget guard 条（L115–119）实际止于 “…and marks totals estimated with `(ledger est.)` when any charge was an estimate.”；“circuit-breaker semantics” 是该条内中段的短语，不是条尾。
- **误差来源**：梗概语把条内中段短语误作条尾。源裁定 AMEND2-20261031-gate3.md §6 第 12 项 (i) 从未作此主张——误差在本文件 AC7 行的转述环节产生，不在源裁定。
- **不影响面**：AC7 的承重判据是其 Expected Evidence 三项（throw 句独立成条、全仓计数 =1、走查形态），三项均已达成；Phase 1 Gate 4 对 AC7 的 PASS 与其余裁定不因本勘误改变。
- **形态（K-7）**：本节为文末勘误追加，AC7 行原文一字未改；本节之前全部字节的 sha256 与改前全文件哈希一致（由 Phase 2 HANDOFF AC13 前缀守卫机械验证）。
