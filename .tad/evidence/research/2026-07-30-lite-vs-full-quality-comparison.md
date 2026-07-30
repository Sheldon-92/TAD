# Full TAD vs Lite 通道：质量保障对照研究

**日期**: 2026-07-30
**研究对象**: 首个真实 LITE 单 `LITE-20260730-1137-calendar-write`（全屋智能化项目，Codex/k3 API billing 环境）
**材料**: alex-lite 会话实录、LITE handoff 原件（含 Completion）、Gate 3 首轮 fresh review（FAIL）原文、rerun verdict（PASS）原文、lite-discoveries journal、Blake 侧 787 行复盘
**核对方式**: 复盘的每个关键 claim 均与一手证据交叉核对（首轮 FAIL 的 P1 内容、AC 矩阵、清场后 Google 直读、commits），无出入
**问题**: lite 砍掉了 full TAD 的哪些质量机制？在这个真实案例里，被砍掉的部分有没有造成质量泄漏？剩下的机制靠什么保住了质量？

---

## 1. 逐机制对照表

| Full TAD 质量机制 | Lite 的处置 | 本案实测结果 | 判定 |
|---|---|---|---|
| 苏格拉底提问（3-5 轮，目标共定义） | 砍为 ≤1 轮功能岔路题 | 问了 4 个功能形态题（用户跳过）；**全程无目标/动机问题**；拆两单建议是 Alex 主动提的且正确 | ⚠️ 靠用户补位保住（见 §3.1） |
| 设计期专家审查（min 2，Gate 2） | 砍掉（escalated L0.5 = Blake 自审） | **唯一实测泄漏点**：AC1–AC6 执行 principal 契约缺陷在设计期产生，L0.5 自审未抓到，存活至最后一道 gate（见 §2） | ❌ 泄漏，被下游防线接住 |
| Gate 3 独立验证（subagent 实证） | 保留为 1 名强制 fresh reviewer | **有效**：真机功能全绿仍判 FAIL，抓到 2 个 P1（AC principal 冲突 + Butler 规则混脏 CLAUDE.md）；第二轮独立复核修复 | ✅ 保住，且是唯一独立防线 |
| Gate 4 人类验收 | 保留（AC10 user-gated 真机终判 + 归档拍板） | 有效：4 类真机专属缺陷（日期锚定 2024、无工具假成功、标题严格匹配、systemd 组快照）全在 AC10 暴露并修复 | ✅ 保住 |
| 契约先行（handoff 为唯一契约） | 保留为一页纸 LITE 契约 | 契约质量高：安全不变量、find 语义、诚实契约、"血的教训"6 项配套全部写入且被执行 | ✅ 保住 |
| 范围纪律（scope discipline） | 保留（"不做什么"清单） | 全程多次擦到提醒调度器，0 夹带；reviewer 独立确认 scheduler absent | ✅ 保住 |
| 知识捕获 | 保留（lite-discoveries journal） | 产出 2 条高质量 discovery + 用户点名的完整复盘 | ✅ 保住 |
| Terminal 隔离 / 角色分离 | 单 terminal，人输命令切角色 | Alex 未写码、Blake 未重设计、拍板点齐全；无角色泄漏 | ✅ 保住（验证了"独立视角=干净上下文"假设） |
| 诚实汇报纪律 | 保留（诚实契约条款） | 轻微泄漏：12:08 用"已完成"描述缺 AC10+Gate 3 的状态；两轮 FAIL 证据均如实落盘未覆盖 | ⚠️ 措辞级泄漏，无实质危害 |
| Epic 协议 | 未定义（epics 目录在升级清单上） | 用户要求宏观 Epic → alex-lite 写入 `.tad/active/epics/` 正式 Epic，靠 escalated_review 记录 verbatim 兜住 | ⚠️ 未定义行为，需补规则 |

## 2. 唯一实测泄漏点的解剖：AC principal 契约缺陷

**缺陷**: handoff v1 的 AC1 指定 `sudo -u justin-voice toolbox-run`（UID 988 无 dispatcher grant，Jarvis 生产路径是进程内 loader）；AC2–AC6 未指定已授权 principal。按原文执行 = `grant not found`，契约不可运行。

**产生点**: alex-lite 设计期（写 AC 时按想象的调用路径写，未逐条验证可执行性）。

**穿透了哪些防线**:
1. escalated L0.5（Blake 设计期自审）——检查了 grants/gate/权限/路径，**却没检查自己接的契约里 AC 命令的可执行性**。自审盲区的教科书案例：审查者与契约执行者同心智模型。
2. 机器 AC + 真机 AC10——功能路径全绿，掩盖契约失真（"功能能用"≠"契约可执行"）。

**被谁接住**: 首轮 fresh reviewer。其判定原文明确区分 "Functional PASS / contractual command invalid"，并拒绝两种作弊修法（为测试新增 UID 988 grant；静默替换 AC 命令）。

**Full TAD 反事实**: full 通道的设计期专家审查（handoff-review 明确含 AC runnability 检查项）大概率在实现前抓到，省去 Gate 3 首轮 FAIL + 契约重写（~23 分钟返工 + 两名 reviewer 中的第二名）。代价是前置 2 名专家审查（本环境为 API 实付费用）。

**结论**: 缺陷最终未入档、未上线——防线纵深生效。但 lite 的纵深只有 1 层：若该 reviewer 放水，失真契约会以"下次照契约执行必 false-fail"的形态永久入档。

## 3. 质量靠什么保住的——结构性答案

### 3.1 两根支柱，一根是设计、一根是幸存

- **设计支柱**: 强制 fresh reviewer（不可自审替代）。本案 2 个 P1 全部由它抓获，两轮 FAIL→PASS 证据链完整。这验证了 lite 设计时的核心赌注（独立视角来自干净上下文）。
- **幸存支柱**: 高参与度的专家用户。目标共定义缺失由用户主动补位（"拆成两单""写个宏观 Epic"都由用户驱动或确认）；真机验证由用户逐轮执行。**换一个需求模糊、参与度低的用户，⚠️ 项会变成 ❌**。

### 3.2 定量

| 指标 | 数值 |
|---|---|
| 最终交付缺陷（shipped defects） | 0 |
| 内部抓获 P1 | 2（100% 由保留的 fresh reviewer 抓获） |
| 非阻塞 P2 | 1（审计 OSError，如实保留为 follow-up，未伪装修复） |
| 范围外实现 | 0 |
| 契约缺陷返工 | ~23 min（13:27 发现 → 13:50 二轮 PASS） |
| 接单→Gate PASS | ~2h06m（大部分为真机缺陷的发现-修复循环，full TAD 同样需要） |
| 独立防线层数 | full: 3 层（设计期专家×2 + Gate3 + Gate4 review）→ lite: 1 层 |

### 3.3 对"质量到底有没有得到保证"的回答

**这一单：保住了，且主要不是靠运气**——是设计里刻意保留的那道强制 reviewer 起了作用，其余保住项（契约、范围、诚实、知识）也都是 lite 内置条款在起作用。**但保障余量从冗余变成了零冗余**：full TAD 三层独立视角，lite 只剩一层。本案该层扛住了；结构上它是单点。

这与 principles 的既有判断一致（Mechanical Enforcement Rejected on Single-User CLI：单人 CLI 用软约束+人审计）。单点防线对单人 CLI 可接受，前提是把两个最便宜的余量补回来：

1. **L0.5 AC 可执行性矩阵**（consumer × 真实路径 × principal × 验收方式）——给设计期缺陷一个实现前的检查点，成本≈几百 token，本案可提前 2 小时抓到 principal 缺陷；
2. **目标锚一问 + 方案速写确认**——把"用户补位"变成"流程内置"，降低对用户专家度的依赖，成本≈+2-3K token/单。

## 4. 与已拍板修订的映射

| 本研究发现的泄漏/薄弱点 | 对应修订（已拍板进 handoff） |
|---|---|
| AC principal 缺陷穿透 L0.5 自审 | L0.5 增加逐条 AC 可执行性矩阵 |
| 12:08 "已完成"措辞早 | 7 态状态词标准化 |
| 用户逐轮真机重试成本高 | user-gated AC 单步指令 + 助手自动查日志/读回核验 |
| Gate 发现缺陷后仍回人拍板（用户："你自己改啊"） | 6 条件自治修复规则 |
| 审计 OSError 类非阻塞缺口易被遗忘 | 非阻塞 finding 强制生成 follow-up，禁止静默写成已修复 |
| 目标共定义缺失靠用户补位 | L1 目标锚一问 + L2 前方案速写（本次新增拍板） |
| Epic-in-lite 未定义行为 | 轻量锚点规则（不碰正式 epics 目录） |
| "Express" 命名混淆 | alex-lite 消歧确认 |
| 复盘价值高但与省 token 冲突 | opt-in 复盘（用户点名才产出） |

## 5. 研究限制

- 单样本（n=1），且用户为框架作者本人（专家用户上限）；"幸存支柱"的脆弱性是推断，不是实测。
- token 成本未实测（Codex API billing 无逐轮 token 记录），~23K/单的 dogfood 数字来自 TAD 仓内验证，非本案。
- 反事实（full TAD 会提前抓到 principal 缺陷）基于 handoff-review 检查项的存在性推断，未做平行实验。
