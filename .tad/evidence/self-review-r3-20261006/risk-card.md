# 派发风险卡 — 自查批 R3（补充件三改法落地批）

> 模板：`.tad/templates/dispatch-risk-card.md`；判据：`.tad/gates/gate-canonical-checklist.md` Gate 2「Risk card」项。

## 0. 头信息

| 字段 | 填写 |
|---|---|
| 任务 / task_id | TASK-20261006-SELF-REVIEW-R3（票 TICKET-20261006-self-review-r3） |
| 关联 HANDOFF（路径） | `/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md` |
| 触发项（逐项核对，命中任一即高风险） | **命中两项**：① 改动发布门判定脚本（`.tad/hooks/lib/state-surface-check.sh`、`runtime-freshness-verify.sh`——发版放行面，按 L3/生产面论）；② 改动仓根 `AGENTS.md`（全席装机的源文件，错误随下一版本点扩散全席）。未命中：跨仓/跨席位写（单仓）、引入新连接器/MCP/依赖（无）、密钥/公网/金额（无）、不可逆动作（全改动 git 可回滚，HANDOFF §4.4） |
| 填写人 / 日期 | Alex（设计步）/ 2026-10-06 |
| git gc | 本链不含 git gc，模板 gc 专项 ASM 不适用（显式声明，非遗漏） |

**dogfood 声明（本批自指）**：本批即风险卡机制的当批 dogfood——本卡不是事后补票，
随设计步与 HANDOFF 同批落盘、进 Gate 2 审。组 1 的 fixture 亦为自指 dogfood：
新断言的负控直接取自催生本批的事故原文（`git show a1c3dffd^:AGENTS.md` 头部块），
断言的第一课学生就是它要防的那次事故本身。

## 1. 最坏损失与对应需求（每条一行）

| # | 利害关系人 | 最坏损失（具体事件） | 对应需求 REQ（系统必须保证……） |
|---|---|---|---|
| 1 | 发版执行者／全席 | check8 误报合法文本 → 发版收口被假红拦住 → 执行者学会绕过或弱化检查 → 真事故（旧话再随版扩散全席）无人拦 | REQ1：check8 的判红面必须被三层构造（辖区枚举／锚定抽取／逐字豁免）机械限定，误伤面须由 fixture 的 exempt/outside 两树实证为零 |
| 2 | TAD PM／发版门 | 新台账建了却没真进 freshness 校验面（枚举漏登或缺文件被静默跳过） → C-12 以「已建」名义假关账，OC/Cursor 新鲜度继续无人守 | REQ2：新面入闸必须 fail-closed 可证——缺文件/坏行必 exit 2、总量增量恰为登记行数（19），由两棵控制树与增量断言实证 |
| 3 | TAD PM（Gate 4 判读者） | 组 2 实验被污染（builder 见过题面或 runner 见过期望集） → 召回虚高 → 据污染数据把借 4 误判立项，后续整条 Epic 建在假证据上 | REQ3：实验的盲法与冻结必须有机械凭据（读物自签＋三件 sha256 冻结＋权威面前后清单），任一凭据破裂本轮判读即 INVALID 且不得支持立项 |
| 4 | 全席装机一致性 | AGENTS.md 改写误伤 check3/check8 锚面或 Deferred 其余两件 → 状态面检查转红或 C-5/C-11 被顺手改字 | REQ4：改写后活仓 state-surface 必须仍 exit 0，且改写以逐字稿＋per-term 断言（AC-G3-5）锁定只动 C-12 |

## 2. 证伪式假设表（本卡核心）

| REQ | 假设 ASM（可证伪句） | 证伪信号（出现什么现象即假设不成立） | 信号出现时的动作（停 / 回滚 / 报人） |
|---|---|---|---|
| REQ1 | ASM-1：假设「三层豁免法足以把 check8 的误报面限定在『受治块内、命中旧文模式、未逐字登记』的交集内」 | fixture 五树中 exempt 或 outside 任一树出现 `FAIL check8`，或 outside 树退出码为 1 | **停**：Phase 2 不提交；回设计——先收缩辖区/模式集重验，仍不成立则本组降级为「不实施、保留 step3e 人工回读」（票面预置结论），报 PM 裁 |
| REQ2 | ASM-2：假设「显式清单扩登＋必备守卫能让两份新台账的入闸状态被机械证明（在面则必被解析，缺失则必响）」 | missing-cursor 控制树退出码 ≠ 2；或实施后 freshness 汇总 `Total` 增量 ≠ 19；或 BLOCK/WARN 行中出现 `[opencode]`/`[cursor]` 条目 | **停**：Phase 1 不提交；不许以改台账日期/状态或改校验器判据表凑绿（HANDOFF NFR3 明令）；回 Alex 复核枚举改法，报 PM |
| REQ3 | ASM-3：假设「builder/runner 的禁读清单＋三件哈希冻结＋权威面前后清单，足以使本轮实验数据无污染」 | run-trace/build-record 的读物自签与盘面证据矛盾（任一禁读路径被打开）；或跑题后任一冻结件 sha256 与冻结值不符；或 authority manifest 前后 diff 非空 | **作废**：本轮判读记 INVALID 并在 experiment-report 首行标明成因；数据不得用于支持立项；是否重跑由 PM 另票决定（新票须预登记新判据），报 PM |

（REQ4 无独立 ASM：其保证由 AC-G3-5 逐字断言＋AC-G1-1 活仓复跑机械覆盖，属可直接验证项，不占假设表额度。）
