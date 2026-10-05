# TAD Research 机制设计（v0.1 草稿）

> 起草：TAD thin-PM side · 2026-09-15
> 状态：草稿，待用户评审挑刺。先试点再沉淀。

## 0. 一句话定位

TAD Build 管"把事情做出来"，TAD Research 管"把事情想清楚"。
Research 的产出不是代码，是**可行动的决策依据 + 可维护的知识**。

"够深"的定义：**决策人看完可以直接行动，不需要再亲手验证一遍。** 达不到这个，就是薄。

## 1. 角色

- **Alex（兼 Research Lead）**：研究全程主导。写 charter、写 plan、执行轮次、综合 verdict。研究本质是 solution 思考，不引入新角色，保持 TAD 角色少。
- **Critic（对抗评审人）**：独立会话、独立样本，专职挑刺。对标 Build 的 Gate 3 独立双审。由 Alex 角色的不同会话担任，但开场必须明确"这一轮你是 Critic，不是 Research Lead"。
- **人**：R0 立项拍板、每轮"继续/收"决策、最终 CHECK（判断类结论只能人拍板）。

## 2. 五个闸

### R0 立项（Charter）——最重要的闸

输入不许是"题目"，必须是"问题"。Charter 必须写清四件事：

1. 这项研究服务哪个决策 / 必须回答哪个问题（没有就打回）；
2. 什么叫够深——本次的具体验收线（例：覆盖 3 个候选方案的成本/精度 tradeoff，每项 ≥2 独立来源）；
3. 明确不查什么（防漫游）；
4. Source 策略（去哪找：一手优先还是社区优先）。

产出：`RESEARCH-CHARTER.md`。人拍板后才进 R1。

### R1 方案评审（Plan）

Alex 出研究方案：问题拆解、初始假设、source 策略、轮次预算（默认 3 轮）。
人（或 PM）评审通过后开查。防止"漫游二十分钟交综述"。

### R2 分轮深挖（Rounds）——"一层一层"的发动机

- 每轮有固定简报：本轮查什么、去哪查、回答哪个子问题。
- 轮末交 memo：`ROUND-n.md`——本轮发现 / 还缺什么 / 新冒出的问题。
- 每轮结束必须做"继续/收"决策（人或 PM）：**下一轮的简报从上一轮的"缺口"生成**——这就是一层一层的来源。
- 停止规则（三者任一即收）：charter 问题答完；新一轮挖不出新东西（边际收益归零）；轮次预算用完。

### R3 对抗评审（Adversarial）——对标 Gate 3

独立 Critic 会话，干三件事：

1. **Source 抽查**：引用的 source 是否真说了那个话（抽查，不是全信）；
2. **反例搜寻**：找出支持反方的最强证据；
3. **缺口分析**：charter 里还有哪些问题没答完。

结论：PASS / CONDITIONAL（列清单打回去补）/ FAIL（重开轮次）。

### R4 综合落盘（Synthesis）——对标 Gate 4

Alex 综合：

- **Verdict 先行**：结论第一句，不超过三句话；
- 置信度分级 + "还有哪些不知道"；
- 落成**互相链接的 wiki 页**（不是单个文档），+ `SOURCES.md`（每条结论→来源→检索日期的 provenance）。

最后人做 CHECK（对标 CHECK_REQUIRED）：判断类结论只能人拍板。

## 3. 深度硬规矩（所有研究通用）

1. 关键结论双源验证；单源结论必须标低置信。
2. Source 分级标注：primary（官方文档/代码/论文）> secondary（博客/媒体）> tertiary（社交/传闻）。
3. 终稿必须有"能推翻本结论的最强反例"一节（没有就打回 R2）。
4. Provenance：每条结论可追溯到来源与检索日期。
5. Verdict 先行：先给结论再摆证据。

## 4. 产出物与落盘

```
docs/research/<topic>/
  RESEARCH-CHARTER.md   # R0
  RESEARCH-PLAN.md      # R1
  ROUND-1.md …          # R2 memos
  CRITIC-REVIEW.md      # R3
  VERDICT.md            # R4（verdict 先行）
  SOURCES.md            # provenance
  wiki/<slug>.md        # 互相链接的 wiki 页
```

沿用 NJ 研究已验证的落盘习惯（docs/research + .tad/evidence/research/SOURCES.md），在其上加 charter/plan/round/critic 四件套。

## 5. 与 TAD Build 的关系

- Research 可独立存在（纯研究任务）；
- 也可以是 Build 的前置（Epic 的 Phase 0）：R4 的 verdict 直接喂给 Alex 做设计（Gate 1/2）。

## 6. 模型与通道（用户已定）

- research/discuss：`opencode-go/deepseek-v4.1-flash`（够用，不升级）；
- 长任务默认走 grokbox；开跑卡带 role/channel/model/env（沿用透明度卡）；
- Critic 与 Research Lead 必须不同会话（对标 Alex/Blake 角色分离）。

## 7. 落地路径

1. **先试点**：下一个真实研究任务完整跑一遍 R0–R4；
2. **跑完复盘**：哪些闸是真卡住东西的、哪些是走过场的；
3. **沉淀成机制**：写进 TAD 框架文档，必要时进 preflight/检查单。

## 8. 待定问题（等你拍）

1. Critic 是否需要独立的新角色名，还是 "Alex 会话 + 开场声明" 就够？
2. R2 每轮的"继续/收"决策，人每轮参与会不会太重？是否 PM 代决策、只在收或重大转向时找人？
3. Wiki 页之间的链接维护，人肉还是半自动？（这是借 WeKnora Wiki Mode 方法最直接的一点）
