# Phase A — 独立机械枚举 + 与 Epic 草稿差异比对

> 顺序纪律：本文件第 1、2 节为**先读三来源独立枚举**的产物；第 3 节才读 Epic 草稿 11 行做差异比对（防 Preview Anchoring，见 `principles.md` "AI/Human Judgment Domain Awareness"）。

## 1. 独立机械枚举（先于 Epic 草稿）

「什么构成纪律」判准（§6 Phase A 第 2 步，同时满足）：
- (a) 语气含 `MUST`/`MANDATORY`/`BLOCKING`/`必须`/`禁止`/`不得` 之一，或是一个具名的 Gate/检查点
- (b) 被违反时有可观测后果（有人会发现、有东西会红、有记录会留下）

- **来源1** CLAUDE.md §3 规则0–5（+§2 重量裁定 +§4 Terminal 隔离）：N=6
- **来源2** full SKILL（alex+blake）gates/protocols/forbidden：N=13
- **来源3** lite SKILL（alex-lite+blake-lite）脊柱+内置约束：N=10
- 去重合并 合计=15

### 枚举出的 15 条纪律（去重后）

| ID | 纪律 | 来源 | full 形态 | lite 形态 |
|---|---|---|---|---|
| D01 | 需求澄清 | both | 规则0 苏格拉底提问 BLOCKING 3–5轮 | L1 目标锚 ≤1问 ≤2轮「不问是常态」 |
| D02 | 需求闸 | full | Gate 1 需求清晰（显性关卡） | 无（L0/L1 全 Alex 自评，无人复核） |
| D03 | 重量裁定 | both | Adaptive Complexity：Alex 评估、人裁定 | §2.5 明写「文件数/协议密度均不构成升级理由」→ 主动删除 |
| D04 | 专家审查（多视角） | both | 规则1 min 2 并行 + P0 修复 | L2.5 契约审查 + L3 实现审查（1 个 reviewer 串行多轮） |
| D05 | 门禁 | both | Gate 3/4 显性关卡 | L3.5 Lite Technical Gate（溶进脊柱当步骤） |
| D06 | 启动扫描 | full | alex STEP 3.5b 依赖演进 / 3.8 研究图景 / 3.55 僵尸 handoff | 无 |
| D07 | 知识评估 | both | 规则5 Knowledge Assessment BLOCKING | Knowledge Closeout 明写不阻塞 |
| D08 | 跨模型审查 | full | cross_model_awareness（NOT_via_alex_auto） | 无协议规定 |
| D09 | 配对测试 | full | pair testing（STEP 3.6） | 无 |
| D10 | 角色分离 | both | CLAUDE.md §4 Terminal 隔离 | 跨角色请求消歧（alex-lite + blake-lite） |
| D11 | Execution Mandate | lite | 无（full 是逐命令审批） | lite 独有：精确 mandate + CAS 锁 |
| D12 | 约束准入 | lite | 无 | lite 独有：新增 MUST 前必须定价 |
| D13 | AC 可执行性检查 | both | step1d ac_dryrun | L2.25 AC 空跑 |
| D14 | Friction 反跳过 | both | alex/blake friction protocol | 隐含（Forbidden 禁自审替代） |
| D15 | Ralph Loop 自检 | both | Layer 1 自检 + Layer 2 专家链 | L2 AC 自验（Blake 自己跑 AC 命令） |

### 排除项（满足 (a) 但判为「不构成纪律」，说明为何排除）

| 项 | 为何排除 |
|---|---|
| 意图路由（intent_router_protocol，blocking:true） | 是**路由机制**不是质量纪律：它决定走哪条协议，不防任何质量失败。可观测后果是「走错流程」，但那是机制正确性问题，不是「纪律防住过什么」 |
| 有界知识加载/预检（L1.5/L0.75，禁止无界加载） | 是**重量控制**不是质量纪律：它防的是 context/成本膨胀，正是本 Epic 想分离出去的「重量」一侧，归属 D03 重量裁定的旋钮对象，不单列 |

## 2. 枚举要点备注（判准应用时的边界情况）

- **D02 需求闸 vs D05 门禁**：机械来源里 CLAUDE.md §3 只显式列了 Gate 2/3/4，Gate 1（需求清晰）在 alex 的 gate 体系里。二者「防什么」不同（D02 防「做错东西」在动手之前，D05 防「做得不对」在动手之后），故分列——与 Epic 草稿的分列一致，但此处是独立按「防什么」切分的，非沿用。
- **D04 专家审查 vs D15 Ralph Loop 自检**：D04 是独立 sub-agent 的**审查**（视角独立），D15 是执行者自己的**机器自检**（build/test/lint/AC 命令）。二者机理不同（独立视角 vs 自证），分列。
- **D14 Friction 反跳过**：full 有明文的 `tad_friction_protocol`（"missing tool is NEVER a skip reason"）；lite 没有同名字段，但 Forbidden 里「以自审替代 reviewer spawn」等条目承载同一纪律。故标 `both`，lite 侧为隐含形态。
- **D10 角色分离**：Epic 11 行完全遗漏，但它是 violations.log 两条记录（2026-06-10、2026-08-02）都指向的纪律，且 lite 有专门的「跨角色请求消歧」节。这是本枚举最大的一个 Epic 遗漏项。

## 3. 差异比对（此时才读 Epic 草稿 11 行处置结论）

Epic 草稿 11 行（`EPIC-20260812-discipline-weight-separation.md` 地基表）：

| 项 | 在初稿11行中? | 在本次枚举中? | 说明 |
|---|---|---|---|
| 需求澄清 | ✅ | ✅ (D01) | 一致 |
| 重量裁定 | ✅ | ✅ (D03) | 一致 |
| 需求闸 | ✅ | ✅ (D02) | 一致 |
| 多视角审查 | ✅ | ✅ (D04) | 一致 |
| 门禁 | ✅ | ✅ (D05) | 一致 |
| 启动扫描 | ✅ | ✅ (D06) | 一致 |
| 知识评估 | ✅ | ✅ (D07) | 一致 |
| 跨模型审查 | ✅ | ✅ (D08) | 一致 |
| 配对测试 | ✅ | ✅ (D09) | 一致 |
| Execution Mandate | ✅ | ✅ (D11) | 一致（Epic 标「保留，lite 优于 full」→ 需 AC13 重新质询） |
| 约束准入 | ✅ | ✅ (D12) | 一致（Epic 标「保留」→ 需 AC13 重新质询；注意术语为「约束准入」非「约束准入台账」） |
| **角色分离** | ❌ | ✅ (D10) | **Epic 遗漏**。CLAUDE.md §4 Terminal 隔离 + lite 跨角色请求消歧；violations.log 两条记录（2026-06-10 Alex 越权直执行、2026-08-02 Alex 写代码）均为其缺席致害型实例 |
| **AC 可执行性检查** | ❌ | ✅ (D13) | **Epic 遗漏**。alex step1d + lite L2.25；防「写进契约的 AC 无法验证」 |
| **Friction 反跳过** | ❌ | ✅ (D14) | **Epic 遗漏**。alex/blake friction protocol；防「缺工具就跳过必修步骤」 |
| **Ralph Loop 自检** | ❌ | ✅ (D15) | **Epic 遗漏**（或并入「门禁」）。Layer 1 机器自检与 Gate 关卡机理不同 |

**结论**：Epic 草稿 11 行全部被本次独立枚举覆盖（0 条遗漏的「既有行」）；本次枚举比草稿多出 **4 条**（D10/D13/D14/D15），均为 Epic 明确承认「至少漏过 3 类东西」中的遗漏项。

## 4. AC13 重新质询（Epic 旧标签逐条复核，不得默认沿用）

> AC13 要求：对 Epic 草稿已有标签（「门禁=地板」「Execution Mandate=保留」「约束准入=保留」）逐条重新质询。

| Epic 旧标签 | 重新质询结论 | 一句可证伪理由 |
|---|---|---|
| 门禁=地板 | **维持地板** | 判据闭合（固定闭集清单）+ 成本恒低（跑一次清单，不随后果缩放）；若某档位跳过门禁仍能靠其它纪律拦住同一失败类，则此判定被证伪 |
| Execution Mandate=保留 | **待判（非自动保留）** | 它防的是「橡皮图章式审批」；其价值取决于「逐命令审批 vs 一次性精确授权」哪个更能防「未授权越权」——目前仅 3b/3c/P4 三处实例，且全为自指；若无非自指实例证明其优于逐命令审批，则「保留」只是对 Alex 自设计机制的偏好（§10.1 利益冲突之二） |
| 约束准入=保留 | **待判（非自动保留）** | 它防的是「约束无限膨胀」；但「每次新增 MUST 都被迫定价」这一成本本身就是重量——若约束增长速度本身可被更轻的机制（如周期审计）替代，则「保留」过度定价；现有载体 `lite-constraint-ledger.md` 仅有 PROVISIONAL 生命周期，无「拦住过一起膨胀」的在场生效实例 |
| 跨模型审查=弱实例/待判 | **重新质询并推翻**：改判 1-留 | Epic 草稿标「弱实例：AC17 碰巧用了别的模型，是偶然不是制度」——本检索用实例聚焦关键词找到更强载体 `pack-evaluation.md#L20`「now quantified at ~44 catches the same-model loop missed」（Codex 跨模型审查浮出约 44 处同模型循环漏掉的错误）。实例强于草稿所述，但仍是**一次性对抗审查、非制度化协议**，故「留」=制度化，非已制度化 |
