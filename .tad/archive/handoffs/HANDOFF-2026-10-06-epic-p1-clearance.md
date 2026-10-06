# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)

- **Task ID**: TASK-20261006-EPIC-P1-CLEARANCE
- **Handoff ID**: HANDOFF-2026-10-06-epic-p1-clearance
- **Created**: 2026-10-06
- **Created by**: Alex (Solution Lead)
- **Epic**: EPIC-20261006-tad-self-optimization — Phase 1「本体清账批」
- **Ticket**: `.tad/active/TICKET-20261006-epic-p1-clearance.md`
- **tad_scope**: full
- **step_kind**: design（本 HANDOFF 为 Phase 1 全批的总设计；实施由 Blake 按 §6 分 Phase 执行）
- **required_evidence_manifest**:
  - `.tad/active/epics/EPIC-20261006-tad-self-optimization.md`（Phase 1 节为范围正本）
  - `.tad/active/TICKET-20261006-epic-p1-clearance.md`（12 件范围与红线）
  - `docs/pm/open-cards/done-20261005-tad-closeout-batch.md`（遗留五条＝件 1.1–1.5 来源）
  - `.tad/evidence/pm/2026-10-05-gm-input-migration-genesis.md`（件 1.6 登记）
  - `.tad/evidence/pm/2026-10-05-gm-input-hooks-json-format.md`（件 1.7 登记）
  - `.tad/evidence/pm/2026-10-05-gm-input-driftcheck-registry-only.md`（件 1.8 登记）
  - `.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md`（A1/B1/D3 节＝件 1.9/1.10/1.11 来源；A2 并入件 1.1）
  - `.tad/evidence/pm/2026-10-05-closeout-batch-cf3-triage.md`（件 1.2/1.3 口径地基：四源互证分诊）
  - `.tad/evidence/pm/2026-10-05-closeout-batch-cf3-ruling.md`（PM 甲案裁定：patch 口径与扩面先例）

---

# Handoff Document for Agent B (Blake)
## TAD 本体自优化 Epic — Phase 1 本体清账批（12 件）

本批一次清掉 v3.0.1 收口批完事卡遗留五条、GM 刷新批三件本体输入、提案包判断采纳四件（A1 变形采纳/A2/B1/D3）。全批以**定案与口径成文**为主：多数件的交付物是「判据＋落点条文＋机械核查面」，不是功能开发。凡本设计与盘上实况冲突，以盘上实况为准并停步上报（见 §6 Phase 0 基线冻结）。

版本纪律：本链**不执行任何升版动作**；正文不复述当前版本号，版本只认 `.tad/version.txt`。发版衔接见 §10。

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

### 设计完整性自检

- [x] **Expert review complete (min 2)** — 待 Gate 2 双审（fit/tech 两路独立会话）；本节为送审稿
- [x] **All P0 resolved** — 设计内裁断点已全部给出结论（件 1 二选一已裁，见 §4.1；件 7 收敛方向与 GM 登记原倾向反向，理由在 §4.7 明记）
- [x] **Architecture complete** — 12 件逐件落点、改法、条文草案在 §4 全文给出
- [x] **Components specified** — 写集总表 §7 逐文件点名，含禁改面
- [x] **Functions verified** — 全部函数/命令引用经设计步亲测（§2 基线锚）
- [x] **Data flow mapped** — 件 6（installer→genesis→engine 消费链）、件 8（三层口径）各有流向说明
- [x] **Risk card** — 高风险触发项逐项核对如下，**全部未命中**，不附风险卡
- [x] **Load points declared** — 逐件装载点位表见下

### 高风险触发项逐项核对（Canonical Gate 2 判据）

| 触发项 | 核对结论 |
|---|---|
| L3 动作（删除、密钥、公网、生产） | 未命中：无删除（件 4 为路径字符串订正）、无密钥、无公网、无生产面 |
| 跨仓或跨席位写 | 未命中：写集全部在本仓内；下游存量处置（件 6 补登、件 7 旧式生成件）只成文口径，执行归 GM 刷新面，不在本链写集 |
| 引入新连接器、MCP 或依赖 | 未命中：只用仓内既有 shell/jq/date 工具面 |
| 不可逆动作 | 未命中：全部改动 git 可回滚；脚本行为变更均有 fixture 隔离实证（§9.1） |
| 涉及金额 | 未命中 |
| 对外动作 | 未命中：提交/推送/同步 GM 归 PM 收口，不在本链 |
| PM 判断为高风险者 | 留待 PM 判（设计席不自填） |

### 装载点位表（逐件：写下的东西在哪里被读到/触发）

| 件 | 产物 | 装载点位（装载面＋触发时点） |
|---|---|---|
| 1.1 | 校验器双类契约 | `capability-skill.sh validate/verify` 每次被能力构建与发版自检调用时 |
| 1.1/A2 | 发版自检 step | publish-protocol step3c3：每次发版走到 version 门之后必经 |
| 1.2 | 改面推导规则 | publish-protocol step3c 前言＋publish-ops §3：每次发版分诊时 |
| 1.3 | 史述面分类口径＋门条件 | publish-ops §3.1（查阅面）＋publish-protocol step3c minor/major 分支（拦截面）：每次 minor/major 发版 |
| 1.4 | 索引订正＋防再发句 | 索引本体＝session-state 读面；防再发句＝gate-execution Gate 4 收口步；机械见证＝state-surface check5 每次发版 |
| 1.5 | 计数定义句 | handoff 模板 §9.1 引导区：每次 HANDOFF 创建时；scan-packs 头注：每次读断言实现时 |
| 1.6 | genesis 形态＋锚定＋hop 义务 | tad.sh 初装路径（写）；migration-engine resolve_chain（每次升级读）；publish-protocol step3d（每版作者义务） |
| 1.7 | heredoc 对齐＋语义比对句 | tad.sh codex 安装生成时；语义比对句＝publish-ops §2.5 审计/巡查时点 |
| 1.8 | driftcheck (r) 分类＋三层对照 | driftcheck 每次巡查/发版 supporting check 运行时；头注对照表为判读面 |
| 1.9 | check6/check7 | state-surface-check 经 release-verify 在 publish-protocol step3e 每次发版调用 |
| 1.10 | 负证据纪律节 | evidence-collection.md：Gate 证据采集与评审引用规程时 |
| 1.11 | 根因模板＋指针句 | 模板被「Gate FAIL 响应」引用；指针句＝gate-execution Violation Handling 节首，每次 FAIL 处置时 |

---

## 📋 Handoff Checklist (Blake 必读)

- [ ] Step 0 路径断言：`pwd` 与全部写集路径均为 `/home/hatch/workspace/yun-sync/TAD` 仓内绝对路径；仓外同名文件（尤其 `~/AGENTS.md`）一律禁写禁读作数
- [ ] Phase 0 基线先冻结再动任何文件（§6）；基线与本设计 §2 锚值不符 → 停步上报，不自行调和
- [ ] 捕获纪律：命令输出直落本链证据目录 `.tad/evidence/epic-p1-clearance-20261006/`，禁共用 /tmp 固定名；隔离 fixture 用 `mktemp -d` 唯一目录
- [ ] shell 改动前已读 `.tad/project-knowledge/patterns/shell-portability.md`（无 `grep -P`、BSD 兼容、集合运算 `LC_ALL=C`）
- [ ] 红线：不动 `.gitignore`、不动 SC3 面、不改任何版本字面量、不实际改 168 件史述面（件 1.3 只定口径）
- [ ] 件 1.4 只改点名的四个路径子串；session-state 索引块其余文字一字不动
- [ ] 件 1.1 product-thinking 只改 frontmatter 两行，正文哈希须与基线一致（AC4）

---

## 1. Task Overview

| # | 件 | 一句话 | 主落点 |
|---|---|---|---|
| 1.1 | 校验器定案＋A2 自检 | 校验器改为双类契约（裁断：改校验器）；受治集发版自检入 publish-protocol | `.tad/scripts/capability-skill.sh`、publish-protocol step3c3 |
| 1.2 | 版本口径恒久修订 | 改面推导规则成文，终结「封顶几处」的记忆口径 | publish-protocol step3c、publish-ops §3 |
| 1.3 | 史述面口径（硬约束件） | minor/major 时历史版本陈述的分类/豁免/登记形态＋可核查发版门条件 | publish-ops §3.1、publish-protocol step3c |
| 1.4 | check5 清理＋防再发 | session-state 索引四项失效引用定点改指归档；迁档衔接句入 Gate 4 规程 | `.tad/active/session-state.md`、gate-execution.md |
| 1.5 | AC11 计数口径订正 | 「登记面」定义句入模板与断言脚本头注 | handoff-a-to-b.md、scan-packs.sh |
| 1.6 | genesis manifest | 初装写 genesis 记录；engine 链首锚定；发版 hop 义务成文 | tad.sh、migration-engine.sh、publish-protocol step3d |
| 1.7 | hooks.json 收敛 | 生成器 heredoc 本身非法（亲测）→ 以存档件为正本反向对齐；语义比对口径成文 | tad.sh、publish-ops §2.5 |
| 1.8 | driftcheck (r) | 新增 registry-only 分类 (r) 与 B_dir 集；三层口径对照成文 | pack-registry-driftcheck.sh |
| 1.9 | 读单实存＋索引新鲜度断言 | state-surface 新增 check6（阻塞）/check7（分级） | state-surface-check.sh、AGENTS.md 注记行 |
| 1.10 | B1 负证据纪律 | 一句定义＋探针要求＋强度标注，入证据规程 | evidence-collection.md |
| 1.11 | D3 根因模板 | 定因/定界/验证三段模板 CREATE＋规程指针 | `.tad/templates/root-cause-report.md`、gate-execution.md |

执行分期见 §6：Phase 0 基线冻结 → Phase 1 脚本面（1.1/1.6/1.7/1.8/1.9）→ Phase 2 文面与定点（其余）→ Phase 3 总验。

---

## 📚 Project Knowledge（Blake 必读）

- principles：`.tad/project-knowledge/principles.md`（仓规：版本单源、正文不复述版本号）
- patterns 命中：gate-design、handoff-design、ac-verification、shell-portability、release-sync（至多读 3 条全文；shell 改动必读 shell-portability）
- 口径地基：CF-3 分诊与裁定（见 required_evidence_manifest）——件 1.2/1.3 的分类与先例以之为准，不另起炉灶
- 前例形态：v3.0.1 收口批 HANDOFF（`.tad/archive/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`）的 AC 文法与结构判据组

---

## 2. Background Context — 基线锚（设计步 2026-10-06 亲测，Blake Phase 0 逐项复核）

- **MQ-1 校验器**：`.tad/scripts/capability-skill.sh`（377 行）`validate_canonical` 现行硬规则：frontmatter 只许 name+description 两键、多键 exit 2；name/description 须一行标量（禁块标量）；根目录禁 CAPABILITY.md/README.md/CHANGELOG.md/install.sh；禁符号链接与占位符。全树实测 **PASS 22／FAIL 41**。登记面 25 pack 中：23 件败于「多键」（type/keywords/version 为投影承重元数据）、2 件败于禁入件（product-thinking、web-frontend 投影根有 README.md＋CHANGELOG.md——两包均为 authored-tree 形态：源包自带 SKILL.md 全树与 install.sh，投影即源树拷贝）。治理候选 alex/blake validate exit 0。
- **MQ-2 承重消费者**：driftcheck Set B 探针靠投影 SKILL.md 的 `type:` 行识别 pack；scan-packs 从 CAPABILITY.md 读 keywords 生成 registry；AGENTS.md 包指针表第二列＝registry description 截断。**删键路线（改投影契约）会同时打断三处消费者**，并推翻 v3.0.1 AC9 同构规则（SKILL＝CAPABILITY 删 status 行）。
- **MQ-3 版本门**：publish-protocol（`.agents/skills/alex/references/publish-protocol.md`，216 行）：step3c＝version 门（exit 1：patch→advisory WARN、minor/major→HARD BLOCK；exit 2 恒拦）、step3c2＝version-sweep（Must-Version Registry 断言在 release-verify.sh L565–578 区段）、step3d＝migration 门、step3e＝state-surface 收口。publish-ops（`.agents/skills/release-runbook/references/publish-ops.md`）§3 已有「Do not rely on a remembered file count」句，但无推导规则。
- **MQ-4 check5**：state-surface check5 只扫 session-state.md 头部索引块（blockquote）引用的 `.tad/*.md` 路径实存。四项失效引用与归档实指均已亲验在盘：platform-adapters COMPLETION 在 `.tad/archive/handoffs/EPIC-20260816-framework-health/`；其余三件（state-surface 链 HANDOFF＋COMPLETION、course-judgment HANDOFF）在 `.tad/archive/handoffs/`。
- **MQ-5 genesis**：migration-engine `resolve_chain` 以 SOURCE 的 `.tad/migrations/*.yaml` 建图逐 hop 查找，缺 hop → `REJECT: chain gap at %s` exit 2。源仓 manifest 集止于 `2.43.0-to-2.43.1.yaml`。空操作 manifest 有前例（delete: []／rename: []＋note）。tad.sh 初装时 CURRENT_VERSION＝"none"、engine 侧只 warn 跳过——初装仓从此无任何 manifest 锚，下一次升级必撞 chain gap（GM 登记实测两席）。
- **MQ-6 hooks.json**：**设计步亲测推翻登记原倾向**——生成器 heredoc（tad.sh L1299–1337，PLATFORM=codex 时无条件覆写）输出 668 B、含尾随逗号、`jq` 严格解析 exit 5（**非法 JSON**）；存档件 `.codex/hooks.json` 805 B、jq exit 0、三项 hooks 规范展开形。故收敛正本只能是存档件，生成器向存档件对齐；GM 登记「存档收敛为生成器同式」的原倾向因生成器输出本身非法而不可采（§4.7 明记此裁断）。
- **MQ-7 driftcheck**：源仓现跑 A=25／B_type=35／C=25；(b) 11 件为 skill-only（登记滞后，**不在本批范围**，批外登记）；现 (d) 对 product-thinking 的文案字面失实（称其无 SKILL.md，实际在盘、仅无 type 行探针不可见）；目标仓 C 集恒 ∅ 时 registry-only 形态假落 (c)。
- **MQ-8 索引新鲜度**：`.tad/brain-index.md` 第 2 行 `Generated: 2026-09-16 00:54`，设计日龄约 20 天。AGENTS.md Knowledge Ingress 节自注「no mechanical verifier currently joins the two lists」——件 1.9 即补此机械面，注记句同批订正（CF-4）。

---

## 3. Requirements

- **FR-1（件 1.1）** 校验器须对现行投影实态给出与消费者一致的判读：受治集（登记面 25 pack 投影＋alex/blake）在发布源上 validate 全过；非受治面严契约不回归、不静默放行。
- **FR-2（件 1.1/A2）** 发版流程须含一道以发布源为正控的校验器自检，任一受治件 validate 非零即阻塞发版。
- **FR-3（件 1.2）** 后续发版的版本字面改面须可由成文规则推导，不再依赖临时分诊或记忆中的固定件数。
- **FR-4（件 1.3）** minor/major 发版前，史述面处置须有分类口径、豁免登记形态与 100% 覆盖的可核查门条件；本批不实际改任何史述面。
- **FR-5（件 1.4）** state-surface check5 在发布源上须全过；迁档与索引更新的衔接须成文，使同类失效引用不复发。
- **FR-6（件 1.5）** pack 计数口径须有成文定义，目录数与登记数之分在模板与断言脚本两处同句可见。
- **FR-7（件 1.6）** 全新初装仓须在初装时落下 genesis 记录；其后升级在版本链无出厂 hop 时不得再报 chain gap REJECT；真 gap（链中段缺 hop、genesis 版本不符）仍须 REJECT。
- **FR-8（件 1.7）** 生成器产出的 hooks.json 须为合法 JSON 且与存档件逐字节一致；漂移判定须有成文的语义比对口径，覆盖下游旧式生成件。
- **FR-9（件 1.8）** driftcheck 须把「探针不可见的已登记形态」与「真缺件」分开判读；三层（源仓断言／目标仓 driftcheck／探针 frontmatter）对同一形态的判读须同口径成文。
- **FR-10（件 1.9）** 发版自检须断言激活读单无条件路径全实存（发布源）；生成型索引的新鲜度须可读、超阈告警但在本批口径下不硬拦发版；断言面须覆盖安装面（下游安装副本的路由与实存一致），不止发布源。
- **FR-11（件 1.10）** 证据规程须有负证据纪律条文：结论依赖「未发生」时附正向探针实证或显式强度标注。
- **FR-12（件 1.11）** Gate FAIL 后的根因报告须有三段式模板与规程指针，Blake 返工只按根因报告的修法执行。

---

## 4. Technical Design

### 4.1 件 1.1 — 校验器定案（裁断：改校验器）＋ A2 发版自检

**裁断：改校验器，不改投影契约。** 理由四条（Gate 2 双审须对此裁断给明确结论）：
1. 投影 frontmatter 的 type/keywords 是承重键（MQ-2：driftcheck 探针、scan-packs、AGENTS.md 指针表三处消费）；删键改契约会同时打断三处消费者。
2. 校验器两键规则成文于 canonical 切换（`.agents/skills/` 成为正本）之前，辖区当时是新 authored skill；切换后辖区变为派生投影树，规则未随辖区更新——是规则过期，不是投影违规。
3. 投影是机械派生物：逐件改 25 件投影等于把派生面当源头，下次 regen 即回潮；改校验器一处收敛。
4. 无任何发布规程引用 validate，改校验器不触动既有发版链；改投影契约则改变下游十余仓的装载面。

**改法（`.tad/scripts/capability-skill.sh` 的 `validate_canonical`）——双类契约：**
- **类别判定**：被检名在 pack-registry.yaml 登记面内 → Class P（pack 投影类）；否则 → Class A（authored/框架类）。registry 文件不可读时（目标仓形态），以被检 SKILL.md 含 `^type: (reference-based|deep-skill|orchestration-router)` 行作 Class P 的 fallback 判据。
- **Class P 规则**：允许键集 {name, description, version, type, keywords}；name/description 仍须恰一行标量（现行规则不变）；type 在源包 CAPABILITY.md 声明时为必备且须与 CAPABILITY 逐字全等、取值 ∈ {reference-based, deep-skill, orchestration-router}；keywords/version 在 CAPABILITY 声明时须与之逐字全等，keywords 须单行 flow 形（`^keywords: \[.*\]$`）；CAPABILITY.md 不可读（目标仓形态）时跳过镜像子检、只查 type 取值域。禁入件收窄为 {CAPABILITY.md, install.sh}；README.md/CHANGELOG.md 仅当源包为 authored-tree 形态（`.tad/capability-packs/<name>/SKILL.md` 在盘）时放行，否则仍禁。符号链接、占位符、name 形态等其余现行检查两类同行。
- **Class A 规则**：现行严契约一字不变（两键、禁入四件、禁块标量）。
- **连带**：product-thinking 投影 frontmatter 补齐——`.agents/skills/product-thinking/SKILL.md` 增 `type: deep-skill` 与 `keywords:` 两行，值逐字复制自其 CAPABILITY.md 对应行（Phase 0 冻结原文，Blake 照抄不转写），正文一字不动（AC4 以正文哈希核）。web-frontend 等其余投影在新规则下应直接转 PASS，不做任何改动。
- **usage 头注**：补两类契约与受治范围的说明段（含契约变更注记，供历史 acceptance 件重跑时按新契约判读，见 CF-1）。
- `verify` 子命令经 `validate_canonical` 继承新规，不另改。

**A2 自检落点**：publish-protocol 在 step3c2（version-sweep）之后、step3d 之前新增一步（编号 step3c3）：「Validator positive-control self-check（全发版类型恒阻塞）：对受治集逐一跑 `capability-skill.sh validate "$PWD" <name>`（双参数形态写死，<name> 逐件代入）——受治集＝pack-registry.yaml 登记面全名＋alex＋blake；任一非零即停版。」publish-ops §2.5 supporting checks 加一行指针指向 step3c3（单点成文、避免双写漂移）。
**受治集外排除（明示登记，不静默）**：alex-lite/blake-lite——Lite 通道已冻结（仓根 AGENTS.md 明文），其块标量 description 是 Lite 既有形态，不入受治集；save-skill 等工具技能——非发版认证面，validate 状态为批前既存，Class A 严契约保持不变（AC3 证明未被放行）。

### 4.2 件 1.2 — 版本口径恒久修订

**落点**：publish-protocol step3c 前言＋publish-ops §3 各加「改面推导规则」段（两处同义，publish-protocol 为正本表述、publish-ops 为 ops 镜像）：
> 版本字面改面由规则推导、永不靠记忆封顶：改面 ＝ Must-Version Registry 断言面 ∪ state-surface check1–3 断言面 ∪ 上一同型发版实际改面中未被前两面覆盖者 ∪ {`.tad/version.txt`, AGENTS.md 版本标记行}。每次发版先 detect-only 跑 version 门，逐 hit 分诊（live 改／收口回填／豁免），分诊记录落 `.tad/evidence/releases/<NEW>-version-triage.md`；patch 的 advisory 放行以当次分诊记录在盘为前提，无记录不放行。

**连带清扫**：Phase 0 在 publish-protocol、publish-ops 及发版相关模板内 grep 固定封顶表述（「封顶」「两处」「at most」类），命中点在 Phase 2 逐点改为指向推导规则；AC5 以零残留为判据（模式集以 Phase 0 冻结清单为准）。

### 4.3 件 1.3 — 史述面口径（硬约束件：只定口径，不改史述面）

**落点**：publish-ops §3 新增 §3.1「Historical version references — minor/major triage」＋publish-protocol step3c 的 minor/major 分支加门条件句。分类规则（源 CF-3 分诊类别，恒久化）：
- **L 活面**：Registry 断言面、state-surface check1–3 面、发版前例面——随 bump 逐行枚举改。
- **H1 版本事件陈述**：陈述某已发布版本发生的事件（removed in vX、ARCHIVED 头注、旧版说明行）——永不改写，整类豁免。
- **H2 版本下限陈述**：形如「vX.Y+」且升版后仍为真——豁免。
- **H3 版次落款／欢迎行**：禁机械换号——豁免；是否另立新行属编辑决定，由收口方自决并记入分诊记录。
- **F 夹具钉版值**：豁免；例外——夹具目的本身即断言现行版本者按 L 类。
- **D 文档历史节／CHANGELOG 既往条目**：豁免。
- **未归类 hit**：停步逐件分诊，结论记入当次分诊记录并注明新先例；不得当场归入既有类蒙混。

**可核查发版门条件（写入 step3c minor/major 分支）**：minor/major 发布前必须存在 `.tad/evidence/releases/<NEW>-version-triage.md`，覆盖当次 version 门 detect-only 的 100% hits、逐件带类别与依据；存在未分类 hit 即硬拦、与 exit 2 同级。本 Phase 只落口径文与分诊记录的字段形态（字段：path:line／hit 原文／类别／依据或先例指针），不生成任何实际分诊记录、不动任何史述面文件。首次适用即 Phase 2 的 minor 发版（CF-5）。

### 4.4 件 1.4 — check5 四项清理＋防再发

**清理法：定点改索引行路径，不再生成。** session-state.md 头部索引块中以下四个路径子串逐一改为归档实指（行内其余文字一字不动）：
1. `.tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md` → `.tad/archive/handoffs/EPIC-20260816-framework-health/COMPLETION-2026-09-15-platform-adapters-p1p3.md`
2. `.tad/active/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md` → `.tad/archive/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md`
3. `.tad/active/handoffs/COMPLETION-2026-10-04-tad-state-surface-closeout.md` → `.tad/archive/handoffs/COMPLETION-2026-10-04-tad-state-surface-closeout.md`
4. `.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md` → `.tad/archive/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`

Phase 0 先 grep 索引块核对四子串与盘面逐字一致；任一子串与本清单不符 → 停步上报，不即兴改写（保历史真实：改的是指针，不是历史叙述）。
**防再发**：`.tad/tasks/gate-execution.md` Gate 4 节末加收口衔接句：「链收口迁档 HANDOFF/COMPLETION 至 `.tad/archive/` 时，同一步把 session-state 索引块中该链的路径回写为归档路径；state-surface check5 为其机械见证，在下一次发版 step3e 拦截遗漏。」（落 gate-execution 而非 Canonical 清单的理由：避免清单与 gate skill 同步副本的双写面扩大；check5 已是机械见证，规程句只补动作衔接。）

### 4.5 件 1.5 — AC11 计数口径订正

**定义句（两处同句）**：「pack 计数以登记面为准：登记面 ＝ pack-registry.yaml 条目且源包有 CAPABILITY.md 的 pack 集合；目录数不是登记数——无 CAPABILITY.md 的目录（如 agent-computer-interface）不计入登记数。凡计数类 AC 必须在方法文中写明计数对象定义。」
**落点**：①`.tad/templates/handoff-a-to-b.md` §9.1 引导区（L527 起）加注记段；②`.tad/scripts/scan-packs.sh` 断言节（登记⊆投影断言处）头注加同句（断言实现本就以 CAPABILITY.md 为登记判据，口径随码同行）。

### 4.6 件 1.6 — genesis manifest（三件套）

**消费面盘清（设计步亲测）**：engine `resolve_chain` 以 SOURCE 的 `.tad/migrations/*.yaml` 建图、逐 hop 找 `mf_from == current`，无 → REJECT exit 2；源仓 manifest 集止于 2.43.0→2.43.1，其后版本无出厂 hop。故缺口有两段：初装仓无锚（本件主治）、以及**源仓自身欠后续版本的 hop 文件**（由第三件套的发版义务治）。
1. **installer 写 genesis**：tad.sh 新增 `write_genesis_manifest()`，在初装流程（CURRENT_VERSION＝"none" 达成的分支）`.tad/version.txt` 写入之后调用；仓内现存三处 version.txt 写点（设计步见 L2673/2724/2853 区段），Blake 须逐一判定哪些是初装可达路径并在 COMPLETION 中记录落点选择。内容形态：
   ```yaml
   schema_version: 1
   kind: genesis
   installed_version: "<TARGET_VERSION>"
   installed_at: "<ISO-8601 UTC>"
   install_form: "<source|download>"   # 映射 installer 既有形态标记，不新增 CLI
   installer: "tad.sh"
   note: |
     Genesis anchor: this repository was fresh-installed at the version above.
     It has no pre-genesis migration history. Written once by the installer;
     upgrades never rewrite it.
   ```
   已存在则绝不覆写（保 provenance）。文件名 `genesis.yaml` 无 `-to-` 段、对链图天然惰性（resolve_chain 只按 from/to 组图，不会选它作 hop）——此惰性须由 AC12 实证，不只靠论证。
2. **engine 链首锚定**：`resolve_chain` 签名加 TARGET 参数（main 调用处传入）。在某 hop 查无（found＝0）时：若已消费 hop 数为 0（链首）且 `$TARGET/.tad/migrations/genesis.yaml` 存在且其 `installed_version` ＝ from → 打印 `NOTE: genesis-anchored at <from> — no shipped hop; zero-operation pass` 并以空链成功返回（main 既有 "No manifests found" 成功路径接续）；`installed_version` ≠ from 或 genesis 不存在 → 原 REJECT 不变。链中段（已消费 ≥1 hop 后）缺 hop → REJECT 不变，真 gap 信号保留。installed_version 解析用 grep/sed 便携写法（无 `grep -P`）。
3. **发版 hop 义务**：publish-protocol step3d 加句：「每个 release 必须随版船载 `.tad/migrations/{prev}-to-{new}.yaml`；无 delete/rename 时用空操作形态（前例 2.43.0-to-2.43.1：`delete: []`／`rename: []`＋note）。」同段加存量口径句：「存量初装仓的 genesis 补登，只许凭在盘初装证据（如 install-checks 报告）按同形态补写，installed_version 以证据为准；无证据不补、不追溯造假清单。补登执行属下游刷新面，不在本链写集。」
**源仓卫生**：发布源 `.tad/migrations/genesis.yaml` 必须恒不存在——它会随 copy_framework_files 传播到目标仓、伪造锚（AC12 含 absent 断言）。

### 4.7 件 1.7 — hooks.json 收敛（裁断与 GM 登记原倾向反向，理由明记）

**裁断：以存档件为正本，生成器向存档件对齐。** GM 登记原倾向「存档件收敛为生成器同式」不可采：生成器现行输出含尾随逗号、`jq` 严格解析 exit 5，是非法 JSON——向它对齐等于把全下游的 hooks 配置改成坏的（MQ-6）。存档件（805 B、jq exit 0、三 hooks 规范展开形）是唯一合法正本。
**改法**：①tad.sh codex 分支 heredoc（L1299–1337 区段）输出体改为与 `.codex/hooks.json` 现行字节逐字一致（Blake 以 Phase 0 冻结的存档件字节为模板照抄 heredoc，不凭记忆重排）；heredoc 上方加注：「Canonical copy: repo-root `.codex/hooks.json` — edit both together; drift judged semantically per publish-ops §2.5.」②`.codex/hooks.json` 本体一字不动。③语义比对口径句入 publish-ops §2.5：
> hooks.json 的漂移判定以语义为准：对生成器再生件与存档件作规范化 JSON 比对（`jq -S` 规范形的值序列）；值序列一致即非漂移，字节排版差不单独作漂移；任一值不同即漂移。下游仓的旧式生成件同此口径。

### 4.8 件 1.8 — driftcheck (r) 分类＋三层口径对照

**改法（`.tad/hooks/lib/pack-registry-driftcheck.sh`，advisory 定位与 SAFETY 头注不变）**：
- 新增 **Set B_dir**：对 A∪C 每个名查 `.agents/skills/<name>/SKILL.md` 在盘性（投影目录实存集）；现 Set B 改称 **B_type**（type 探针命中集）。
- **(c) 收窄**：A ∖ (B_dir ∪ C) 才判 drift（登记了却无源包、无投影目录＝真幻影）。
- **新增 (r) registry-only**：A ∩ (B_dir ∪ C) ∖ B_type →「已登记、投影或源包实存、仅 type 探针不可见」——advisory 打印，永不置 drift。现行 (d) 中字面失实的 product-thinking 文案随此消除。
- **(d) 收窄**：source-only 改判 C ∖ B_dir（源包在、投影目录真缺）；B_type ∖ C 的 skill-only 维持 (d) 侧（(b) 既有判读不变，属登记滞后存量、不在本批范围）。
- **C 集不可得形态**：目标仓无 `.tad/capability-packs/` 时，输出须显式打印一行「Set C unavailable in this repo form — (c) judged against projection dirs only」，(c) 只按 B_dir 判。
- 头注同步更新分类定义，并写入下表缩版。

**三层口径对照（成文正本在本节；driftcheck 头注放缩版）**：

| 形态 | scan-packs 断言（源仓，发版面） | driftcheck（巡查面，恒 advisory） | type 探针 |
|---|---|---|---|
| P1 完整投影（目录＋type 行） | PASS | 在册，无报 | 可见 |
| P2 探针不可见投影（目录在、无 type 行，如现行 product-thinking） | PASS（只查在盘） | (r) advisory，不判 drift | 不可见 ≠ 缺失 |
| M2 源包在、投影目录缺 | **FAIL exit 1**（真缺件，红在发版面） | (d) source-only WARN | — |
| M1 登记无源无投影目录 | 源仓内由 registry 生成流程兜底、不应出现 | (c) drift（唯一的 drift 格） | — |

注：件 1.1 的镜像规则落地后，product-thinking 在发布源转为 P1、(r) 在源仓为空——(r) 是为下游存量副本与未来 authored 变体保留的分类格，不是为空造格（见 §5 Q5）。

### 4.9 件 1.9 — 读单实存断言＋索引新鲜度（分级）＋安装面覆盖

**落点**：`.tad/hooks/lib/state-surface-check.sh` 新增 check6/check7（经 release-verify 的 state-surface 转调在 publish-protocol step3e 每次发版到达）；脚本头注清单同步补两行。
- **check6 读单实存（阻塞）**：清单不许在脚本内写死（防清单腐化——AGENTS.md L57–58 自注的正是两表无人机械对齐）。实现：从仓根 AGENTS.md 的 `## Knowledge Ingress` 节提取反引号包裹的 `.tad/…` 路径，去重；跳过含「If」条件行（条件装载件）、含 `*` 的 glob 记号与以 `/` 结尾的目录记号；提取规则另补一句排除口径：「Before editing」类条件句行不入无条件集（此类行为先读后改的前置条件指令、非无条件装载件，后续提取不计入）。现行无条件集按提取实跑冻结为**五件**，点名写死：`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`、`.tad/brain-index.md`、`.tad/project-knowledge/frontend-design.md`、`.tad/project-knowledge/patterns/shell-portability.md`（第五件出自「Before editing any shell file…」句所在行，仓根 AGENTS.md L50–51；该行为「Before editing」类条件句行，因现行提取规则未含上述排除口径而被实跑计入，本批冻结集按实得五件收录，其后提取按排除口径执行）。逐一 `test -f`，缺一 FAIL 并点名。
- **check7 索引新鲜度（分级判读）**：读 `.tad/brain-index.md` 前 20 行内首个 `Generated:` 行，取日期部（现行格式 `Generated: 2026-09-16 00:54`，取前 10 字符）算年龄天数（便携 date 换算，守 shell-portability，无 `grep -P`）。恒打印 `INFO check7: brain-index generated <date>, age <n>d`；年龄 ＞ 14 天 → WARN 行（不计入 fail；阈值理由：知识面周级更新节奏、现龄约 20 天应告警）；`Generated:` 行缺失或不可解析 → FAIL（年龄不可读属形态缺陷、阻塞正当，且不会因单纯陈旧而恒红）。阈值作脚本头注区常量（`BRAIN_INDEX_WARN_AGE_DAYS=14`），Phase 4 复产落地后可议升 FAIL，本批不升。与 tad.sh `--doctor` 的既有 WARN 面分工：doctor 管运行面（mtime 对比、任意仓、恒 exit 0），check7 管发版面（Generated 日期、发布源），不重复造面。
- **安装面覆盖（跨侧核验补入的设计点）**：跨侧复核已确认 brain-index 在 VM 发布源与 grokbox 副本均实存（同字节、tracked）；技术研究席「不存在」的 sighting 未能在这两侧复现，未证假设指向下游安装面。设计步已亲测安装机制：brain-index.md 在 tad.sh 的 `TAD_TOP_DENY` 名单内（与 sync-registry.yaml 并列），**安装/同步集恒不携带此文件**；目标侧靠 `brain-index-gen.sh` 本地生成，现行唯一自动调用点在 quarantine 流程且带 `|| true`（失败静默）。即：安装面 AGENTS.md 路由指向 brain-index，而该文件在目标仓是否实存取决于一次可静默失败的生成——路由与实存可以不一致，这正是 sighting 的最可能出处。
  - **Phase 0 核查点（先证后改）**：在 §6 的初装 fixture 中核三件事并落基线记录——(i) 初装完成后目标树 `.tad/brain-index.md` 是否实存；(ii) 目标侧 AGENTS.md Knowledge Ingress 路由与 (i) 是否一致；(iii) brain-index-gen.sh 在目标侧手动可跑通否（排除生成器本身坏死）。
  - **处置（按 Phase 0 结论二选一，设计先定规则）**：若 (i) 为缺——本批在 tad.sh 初装流程 `copy_framework_files` 之后加一步目标侧生成：调用目标树内 `brain-index-gen.sh` 生成 brain-index，失败以可见 WARN 输出（禁 `|| true` 静默吞），使「路由所指必实存」在安装面成立；生成器本身坏死（(iii) 不通）则停步上报，不在本批扩面修生成器。若 (i) 实存在——不改 installer，只把本核查点结论记入 COMPLETION 并转 PM 备案（断言面以 fixture 覆盖即足）。
  - **断言面口径**：check6/check7 本体跑发布源（发版门）；安装面由本批 fixture（AC23）覆盖——对初装副本在其根目录重跑 check6 提取与实存判定，全过才算「安装面路由与实存一致」。后续把安装面纳入常规断言属 Phase 2/3 测量面议题，本批不扩。

### 4.10 件 1.10 — B1 负证据纪律（条文定稿）

**落点**：`.tad/tasks/evidence-collection.md`，在 Capture Path Discipline 节之后、Pattern Recognition Protocol 节之前，新节全文：
> ## Negative Evidence Discipline （负证据纪律）
> A finding that something did NOT happen — no log line, no file, no event, an empty search result — is evidence only as strong as the probe behind it.
> 1. **Probe before you conclude.** When a conclusion depends on an absence, first run a positive probe that WOULD have detected the thing had it occurred (a known-bad token against the endpoint, a canary record through the pipeline, a control query with a known hit), and file the probe and its result next to the conclusion. A silent log proves nothing when the failing path was never shown to write log lines.
> 2. **Label the strength.** If no positive probe is possible, the conclusion must carry an explicit evidence-strength label — `probed` / `observed-absent` / `assumed` — wherever it is filed. An unlabeled absence claim does not pass Gate review.
> Instance: 2026-10-05 BrowserSkill pairing diagnosis — failed authorize exchanges write no daemon log lines; absence in the log was misread as "the client never sent a request" until a fake-token probe (HTTP 401 returned, log still silent) proved the probe channel works and the log is blind on that path.

### 4.11 件 1.11 — D3 根因报告模板（全文草案）＋规程指针

**CREATE `.tad/templates/root-cause-report.md`，全文如下**（Blake 照此落盘，不改结构）：
> # Root-Cause Report — \<chain / task name\>
>
> （落盘：`.tad/evidence/reviews/<task>-root-cause.md` 或链证据目录。Gate FAIL 后、任何返工派发之前由 Alex 出具。）
>
> - 失败点：\<Gate / 步骤 ＋ verdict 文件指针\>
> - 日期 / 出具人：\<date\> / Alex
>
> ## 1. 定因 (Root cause)
> 一句话根因。其下：证据链——哪些盘上事实支持此根因（路径＋行号，或命令输出落盘指针）；被排除的候选根因及排除依据。根因必须落在机制 / 设计 / 规程层，不许停在「执行者疏忽」。
>
> ## 2. 定界 (Blast radius)
> 同一根因还影响哪些链、文件、下游？逐项列「受影响 / 不受影响 ＋ 判据」。已按错误理解做过的动作（如逐条补丁）哪些回退、哪些保留，逐项给结论。
>
> ## 3. 验证 (Verification of the fix)
> 设计级修法一句话；凭什么保证不再复发——修法改变了哪个装载点位 / 判据 / 机器检查，使同类失败下次被机器或清单拦住、而非靠自觉。修法的验收判据（命令 / fixture）在本节预先写明，实施后逐条复算。
>
> ## 填写指引
> - 三段缺一不可；定因段无盘上证据指针的报告不成立。
> - Blake 不按评审报告逐条打补丁：返工只执行本报告的修法；修法未覆盖的评审条目逐条标注「由修法覆盖 / 不覆盖＋理由」。
> - 同一 Gate 连 FAIL 3 次或累计重跑 ≥5 次时，本报告另须回答复发三问：前 N 轮为何没过、旧修法为何无效、本次凭什么不复发。

**规程指针**：`.tad/tasks/gate-execution.md` 的 Violation Handling Protocol 节首加小节「Root-Cause-First（先根因，后返工）」：
> On any Gate FAIL, rework does not start from the review's line items. Alex first files a root-cause report using `.tad/templates/root-cause-report.md` （定因 / 定界 / 验证）; Blake implements that report's fix design. Patching review items one by one without a root-cause report is a process violation.

---

## 5. 🆕 强制问题回答（Evidence Required）

- **Q1 件 1.1 为何不是「改投影契约」？** 投影 type/keywords 有三处承重消费者（MQ-2）；且 25 件投影逐一手改必被下次 regen 回潮。改校验器一处、受治集当场全过、Class A 严契约不回归（AC1/AC3 双向实证）。
- **Q2 件 1.6 genesis 文件名为何不带 `-to-`？** resolve_chain 只按 from/to 组图，无 `-to-` 段的文件永不被选作 hop（惰性）；且 engine 锚定逻辑显式按 `kind: genesis` 语义读取，与「恰好没被选中」是双保险。AC11/AC12 实证。
- **Q3 件 1.9 check7 为何超阈只 WARN 不 FAIL？** Epic 明注：Phase 4 复产落地前，硬拦会让发版恒红、逼出空改日期的假新鲜。分级线划在「读得出年龄」与否：可读＋超阈＝告警（信息真实、代价为零）；不可读＝形态缺陷，阻塞正当。
- **Q4 件 1.3 为何只定口径不顺手改面？** 168 件史述面的实改必须等一次真实 minor 发版、按当次 detect-only 全量 hits 逐件分诊才有意义；在无发版事件时批量改历史陈述是无判据的文本手术，且票面红线明示不改。口径先行正是为那一次提供判据与门。
- **Q5 件 1.8 (r) 在源仓落地后为空，为何不算多余？** (r) 的辖区是目标仓 driftcheck：下游存量副本的 product-thinking 尚无 type 行（件 1.1 的镜像修复只及发布源，下游靠刷新传播），在其被刷新前 (r) 是唯一不误报的判读；分类先于存量清零存在，是判读表的完整性要求。

---

## 6. Implementation Steps（分 Phase）

证据目录：`.tad/evidence/epic-p1-clearance-20261006/`（本链全部捕获直落此目录）。

### Phase 0 — 基线冻结（动任何文件之前）
1. 复算 §2 全部锚值并落 `baseline.md`：validate 全集计数与 25 pack 逐件首错、driftcheck 全文输出、state-surface 全文输出、check5 四项原文行、session-state 索引块原文、product-thinking 投影 SKILL.md 正文（frontmatter 之下部分）sha256、`.codex/hooks.json` sha256 与字节数、brain-index Generated 行、件 1.2 封顶表述 grep 命中清单、件 1.4 四子串逐字核对结果。任一锚与 §2/MQ 不符 → 停步上报 PM。
2. 初装 fixture 预跑（`mktemp -d` 隔离目录，tad.sh 以本仓为 source 全新初装）：记录三件事——genesis 不存在（件 1.6 改前基线）、模拟升级报 chain gap REJECT 原文、目标树 brain-index 实存与否（件 1.9 核查点 (i)(ii)(iii)）。fixture 目录路径记入 baseline.md。

### Phase 1 — 脚本面（件 1.1 校验器／1.6 engine＋tad.sh／1.7 heredoc／1.8 driftcheck／1.9 check6/7）
1. 逐脚本改前先 `bash -n` 基线、改后 `bash -n` 复核；每脚本改完即跑其对应 AC 的正控与负控（不等到 Phase 3）。
2. 件 1.9 若 Phase 0 核查点 (i) 为缺，按 §4.9 处置在 tad.sh 初装流程加目标侧生成步（可见 WARN、禁静默吞）；(iii) 不通则停步上报。
3. 顺序约束：件 1.6 的 tad.sh 改动（genesis 写＋可能的 brain-index 生成步）与件 1.7 的 heredoc 改动同在 tad.sh——同一文件只许一轮连续编辑，动手前重读现行文本，不许两件并行改。

### Phase 2 — 文面与定点（件 1.1 连带／1.2／1.3／1.4／1.5／1.10／1.11＋CF-4）
1. product-thinking frontmatter 两行照 Phase 0 冻结的 CAPABILITY 原行抄入；publish-protocol 一次编辑内完成 step3c3 新增、step3c 前言与门条件句、step3d 两句（同文件多处改动一轮完成、逐处留 grep 锚）。
2. 件 1.4 四子串定点替换后立即跑 state-surface-check 全量（check5 应转 PASS）。
3. CF-4：仓根 AGENTS.md Knowledge Ingress 节末注记句订正为指向 check6 的表述（仅该句；版本标记行与节内其余文字不动）。

### Phase 3 — 总验与收口件
1. §9.1 全部 AC 逐条实跑、输出落证据目录；fixture 类在 `mktemp -d` 内重演（Phase 0 的初装 fixture 在改后条件下重跑，验 genesis 正负控与安装面 check6）。
2. 全量回归：`bash -n` 全部改动脚本、scan-packs 断言、driftcheck、state-surface 全量、release-verify version detect-only（结果须与基线一致、无本链引入的新 stale 面）。
3. 写 COMPLETION（`.tad/evidence/completions/COMPLETION-2026-10-06-epic-p1-clearance.md`）：含 tad.sh genesis 落点选择记录、件 1.9 核查点结论、AC 逐条结果指针。

---

## 7. File Structure — 写集总表

**MODIFY（14）**
| 文件 | 件 |
|---|---|
| `.tad/scripts/capability-skill.sh` | 1.1 双类契约＋头注 |
| `.agents/skills/product-thinking/SKILL.md` | 1.1 frontmatter 两行（正文禁动） |
| `.agents/skills/alex/references/publish-protocol.md` | 1.1 step3c3／1.2 前言／1.3 门条件句／1.6 step3d |
| `.agents/skills/release-runbook/references/publish-ops.md` | 1.2 §3／1.3 §3.1／1.7 §2.5 语义句＋step3c3 指针 |
| `.tad/active/session-state.md` | 1.4 四子串（其余禁动） |
| `.tad/tasks/gate-execution.md` | 1.4 Gate 4 衔接句／1.11 Violation Handling 指针 |
| `.tad/templates/handoff-a-to-b.md` | 1.5 §9.1 定义句 |
| `.tad/scripts/scan-packs.sh` | 1.5 头注（仅注释） |
| `tad.sh` | 1.6 genesis 写／1.7 heredoc／1.9 生成步（按 Phase 0 结论） |
| `.tad/hooks/lib/migration-engine.sh` | 1.6 resolve_chain 锚定 |
| `.tad/hooks/lib/pack-registry-driftcheck.sh` | 1.8 (r)＋B_dir＋头注 |
| `.tad/hooks/lib/state-surface-check.sh` | 1.9 check6/check7＋头注 |
| `.tad/tasks/evidence-collection.md` | 1.10 新节 |
| `AGENTS.md`（仓根） | CF-4 注记句一句 |

**CREATE（2＋证据件）**：`.tad/templates/root-cause-report.md`；`.tad/evidence/epic-p1-clearance-20261006/` 下基线与 AC 输出；`.tad/evidence/completions/COMPLETION-2026-10-06-epic-p1-clearance.md`。

**WRITE-SET EXPANSION — PM ruling, 2026-10-06（Projection-keywords adjudication）**：写集增列 `.tad/capability-packs/agent-orchestration/CAPABILITY.md`、`.tad/capability-packs/web-frontend/CAPABILITY.md`、`.tad/capability-packs/web-testing/CAPABILITY.md`，仅限将其 `keywords:` 行逐字回同步为对应现行投影 `.agents/skills/<name>/SKILL.md` 的 `keywords:` 行（type/version 同理以投影为准；三件实测仅 keywords 分歧）。设计依据同步：这三包以投影 SKILL.md 为现行有效源，CAPABILITY.md 向投影对齐；§4.1 的镜像判据（投影与 CAPABILITY 逐字全等）本身不变。

**FORBIDDEN（禁改/禁建）**：`.gitignore`；SC3 相关面；一切版本字面量（含 AGENTS.md 版本标记行——本链不升版）；168 件史述面任一文件（件 1.3 只成文）；`.tad/migrations/genesis.yaml` 在发布源**禁建**（见 §4.6 源仓卫生）；`.codex/hooks.json` 本体；product-thinking SKILL.md 正文；session-state 索引块四子串之外的文字；上表之外的任何文件（AC22 封口）。

---

## 8. Testing Requirements

- 全部 AC 均为 command／path-check／fixture 三种可实跑文法（§9.1），无散文判据；负控与正控成对：校验器（放行受治集＋拦造假）、engine（锚定通过＋真 gap 仍拦）、check7（超龄只 WARN＋不可读 FAIL）、driftcheck（三形态各归其格）、hooks 语义比对（改值判漂移＋改排版判不漂移）。
- fixture 隔离：一切安装/升级演练在 `mktemp -d` 唯一目录内进行，不污染仓面；捕获直落证据目录、禁 /tmp 固定名。
- 可移植性：新增 shell 逻辑逐条对照 shell-portability（无 `grep -P`、集合运算 `LC_ALL=C`、BSD date 兼容路径）；Gate 3 评审含 macOS 兼容复核行。

---

## 9. Acceptance Criteria

12 件全落 §9.1 逐条判据。汇总口径：脚本面每件正负控成对；文面每件 grep 锚＋零残留/零越界；全批以 AC22 写集封口与 AC23 安装面覆盖收尾。

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

| # | 件 | 验收判据 | Verification Method |
|---|---|---|---|
| AC1 | 1.1 | 受治集（registry 登记面全名＋alex＋blake，名单现场从 pack-registry.yaml 抽取）在发布源逐一跑 `capability-skill.sh validate "$PWD" <name>`（双参数形态写死，<name> 逐件代入名单）exit 0 | command |
| AC2 | 1.1 | 负控三连（mktemp 造件；三连逐件均以 `capability-skill.sh validate "$PWD" <name>` 双参数形态调用，<name> 代入造件名）：(a) Class P 件带白名单外键 → exit 2；(b) Class P 件 type 与 CAPABILITY 不符 → exit 2；(c) 非 authored-tree 的 Class P 件根置 README.md → exit 2 | fixture |
| AC3 | 1.1 | Class A 不回归：`capability-skill.sh validate "$PWD" save-skill` 仍 exit 2、`capability-skill.sh validate "$PWD" alex-lite` 仍 exit 2（双参数形态写死；严契约未被静默放行） | command |
| AC4 | 1.1 | product-thinking 投影 frontmatter 的 type/keywords 行与其 CAPABILITY 对应行逐字一致；投影正文（frontmatter 之下）sha256 ＝ Phase 0 基线 | command |
| AC5 | 1.2 | publish-protocol 与 publish-ops 均含改面推导规则锚段；两文件内 Phase 0 冻结的封顶表述模式集 grep 零命中 | command |
| AC6 | 1.3 | publish-ops §3.1 在盘且含 L/H1/H2/H3/F/D 六类与未归类停步条；step3c minor/major 分支含 100% 覆盖门条件句；Phase 0 冻结的史述面抽样 10 件路径 `git diff` 为空（本链零触碰史述面） | command |
| AC7 | 1.4 | state-surface-check 全量跑：check1–check5 全 PASS、脚本 exit 0 | command |
| AC8 | 1.4 | 四个归档路径逐一 `test -f` 在盘；gate-execution Gate 4 节含迁档回写衔接句 grep 锚 | command |
| AC9 | 1.5 | 登记面定义句在 handoff-a-to-b.md §9.1 引导区与 scan-packs.sh 断言节头注两处 grep 命中且同句 | command |
| AC10 | 1.6 | 初装 fixture（mktemp 隔离、本仓为 source）：genesis.yaml 在盘，字段齐（schema_version/kind/installed_version/installed_at/install_form），installed_version ＝ 目标 `.tad/version.txt`；重跑初装不覆写（内容哈希不变） | fixture |
| AC11 | 1.6 | 升级 fixture：以 AC10 副本模拟升级（version.txt 与 genesis.installed_version 同置一低 patch 值）→ engine 输出无 `REJECT: chain gap`、整体 exit 0；负控：genesis.installed_version 改为不符值 → REJECT 仍出现；链中段缺 hop 构造 → REJECT 仍出现 | fixture |
| AC12 | 1.6 | 发布源 `.tad/migrations/genesis.yaml` 不存在；migration-engine.sh 含 genesis 锚定逻辑与 NOTE 锚串 grep 命中 | path-check |
| AC13 | 1.6 | publish-protocol step3d 含 hop 义务句与存量补登口径句 grep 锚 | command |
| AC14 | 1.7 | fixture：在隔离目录实际走 tad.sh codex 生成路径产出 hooks.json（须演练真 heredoc，不许抄文件冒充）→ `jq -S .` 解析 exit 0 且与仓内 `.codex/hooks.json` `cmp` 逐字节一致 | fixture |
| AC15 | 1.7 | 语义比对负控对：(a) 改生成件一处 timeout 值 → §2.5 口径的规范化比对判不等；(b) 仅以 `jq` 重排生成件格式 → 判相等 | fixture |
| AC16 | 1.8 | driftcheck 发布源实跑：输出含 `(r)` 节；product-thinking 不出现在 (c) 段、无「无 SKILL.md」类失实文案；(c) 段为空 | command |
| AC17 | 1.8 | driftcheck fixture 三形态（mktemp 骨架仓）：(i) 登记名无源包无投影目录 → 落 (c) 且 drift 置位；(ii) 登记名有源包、投影目录在但 SKILL.md 无 type 行 → 落 (r)、不置 drift；(iii) 无 capability-packs 目录的仓 → 打印 Set C unavailable 声明行、(c) 只按 B_dir 判 | fixture |
| AC18 | 1.9 | state-surface 全量跑含 `PASS check6` 与 `INFO check7`（含年龄天数）行；check7 超阈时为 WARN 且脚本总 exit 不因此变 1（在 AC7 全过条件下 exit 0） | command |
| AC19 | 1.9 | check7 分级 fixture（mktemp 骨架）：brain-index 的 Generated 改为 400 天前 → 输出 WARN、该 check 不计 fail；删 Generated 行 → check7 FAIL | fixture |
| AC20 | 1.10 | evidence-collection.md 含「Negative Evidence Discipline」节锚与 positive probe／strength label 两要素 grep 命中；节位置在 Capture Path Discipline 之后 | command |
| AC21 | 1.11 | `.tad/templates/root-cause-report.md` 在盘且含定因/定界/验证三段标题与复发三问指引；gate-execution Violation Handling 节含模板指针行 grep 锚 | path-check |
| AC22 | 全批 | 写集封口：`git status --porcelain` 变更集 ⊆ §7 写集∪本链自产件（HANDOFF/证据/COMPLETION/票据状态）；全部改动 .sh 过 `bash -n`；scan-packs 断言 exit 0 | command |
| AC23 | 1.9 | 安装面覆盖 fixture：在 AC10 初装副本根目录按 check6 同法提取其 AGENTS.md 读单并逐一验实存——全过；副本 `.tad/brain-index.md` 实存（件 1.9 处置后应成立；若 Phase 0 证明改前已实存，本条转为回归断言并在 COMPLETION 注明） | fixture |

## 9.2 Expert Review Status (Alex 必填)

- Gate 2 双审（fit/tech）：**待派**（PM 收口本设计后派发）。双审须就两处裁断给明确结论：①件 1.1「改校验器」二选一；②件 1.7 收敛方向与 GM 登记原倾向反向的裁断。
- 设计自评已知弱点（先供评审打靶）：(a) 件 1.6 三处 version.txt 写点的初装可达性未在设计步逐一追踪，靠 Phase 0＋Blake 落点记录兜底；(b) 件 1.9 check6 的 AGENTS.md 节内提取对未来节文本格式变化敏感，提取规则已按现行格式写死并要求 Phase 0 冻结提取结果；(c) 件 1.8 (b) 存量 11 件未治，driftcheck 在源仓总 exit 仍可能因 (b) 为 1，AC16 只就 (c)/(r) 判读、不承诺总 exit。

---

## 10. Important Notes

### 冲突预检（CF）
- **CF-1**：件 1.1 改校验器与仓内 capability-builder 历史 acceptance 件（曾以旧契约引用 validate）——历史证据件不回改；校验器头注加契约变更注记，该套件日后重跑按新契约判读。登记不处置。
- **CF-2**：件 1.8 driftcheck (b) 11 件 skill-only（登记滞后）与 (c)/(r) 改判无依赖，本链不处置，批外登记报 PM。
- **CF-3**：件 1.6 改 `resolve_chain` 内部函数签名——engine 对外 CLI（--from/--to/--target/--source）不变；tad.sh 另有 source 引入 engine 的路径，Blake 改前须 grep 全部 `resolve_chain` 调用点并在 COMPLETION 记录。`bash -n`＋AC11 fixture 兜底。
- **CF-4**：AGENTS.md Knowledge Ingress 末注记句（「no mechanical verifier currently joins the two lists」）在 check6 落地后即过期——同批订正该句（写集已含），只动该句。
- **CF-5**：件 1.3 口径的首次适用是 Phase 2 的 minor 发版分诊——口径文内已自带分诊记录路径形态，PM 在 Phase 2 立项时须把「按 §3.1 出分诊记录」写进该链票面，防口径与执行脱节。
- **CF-6**：件 1.7 后 hooks.json 有两处同源文本（tad.sh heredoc 与存档件）——防再漂移靠 heredoc 上方注记＋publish-ops §2.5 语义比对，两件同改纪律在此注记落点声明，不另设机器闸（成本与收益不匹配，留 Phase 2 测量面议）。

### 发版衔接
- 本批收口后的发版提议沿 Epic 发版衔接表：**patch 升版**（提议号见 Epic，本链不执行 bump、不预改任何版本字面）。升版动作由 PM 在 Gate 4 后按 publish-protocol 收口步执行，届时件 1.2 推导规则与件 1.3 口径首次实地适用（patch 只走分诊记录＋advisory 口径）。
- 件 1.3 门条件自本批落地起对一切 minor/major 生效——满足 Epic 硬约束「1.3 先于任何 minor 升版定案」。
- human CHECK：本链无视觉面，Gate 4 后仍记「CHECK 待人」留痕，不代人签。

### 红线复述
只改 §7 点名面；仓外禁写；`.gitignore`／SC3 不动；不做任何 minor 升版动作；件 1.3 不实际改史述面；存量仓 genesis 补登不在本链执行（只成文口径）。

---

## 12. 🆕 Sub-Agent 使用记录

- 设计步：Alex（本席）单会话完成盘面亲测与本 HANDOFF；关键锚值全部来自设计步实跑命令（validate 全集、driftcheck、state-surface、jq 校验、deny 名单查证），见 §2 与设计完工说明 `.tad/evidence/completions/2026-10-06-tad-epic-p1-design-note.md`。
- 下一程：PM 验盘 → Gate 2 双审（fit/tech 独立会话）→ 合并裁定 → Blake 按 §6 实施 → Gate 3 双审 → Gate 4。
