# EPIC-20261031-v409-basket 规划（Cora 成形稿，2026-10-31，用户纠正切法后修订）

- 切法口径（用户 2026-10-31 当面纠正）：4.0.9 篮子整体是**一条 Epic**（单一结果＝攒厚并备妥 v4.0.9），原稿五件「Epic」实为本 Epic 的五个 **Phase**，每 Phase 内部分 Step。初稿切大了，本稿改正。
- 篮子正本：`.tad/active/BASKET-4.0.9.md`（内容与用户点数以篮子为准，本规划只定 Phase 切法与顺序）。
- Epic 完成定义：五 Phase 收口（Phase 5 以口径裁定为界，见该节）＋发版前程毕 → 进发版链发 v4.0.9。每 Phase 走全链：Alex 设计（HANDOFF，Phase 级）→Gate 2→Blake 实施（COMPLETION）→Gate 3 独立双审→Gate 4 独立 Alex 验收→Phase 收口（迁档＋KU 转写）；Epic 整体收口出 EPIC-COMPLETION＋蒸馏报告。

## Phase 1 · 小修批

修法已定、无待裁口径的存量小件打包清账。用户点数 0。

- **Step 1 票面分诊与处置**：10-28 四票（检查器假阴性、handoff 创建装载点、R4 蒸馏文本包、T-1b Gate 2 表单强制）＋salvage 断言修法票。每票先分诊（属实／已修／作废，凭盘面证据），属实的按票面既定修法处置；salvage 含 GNU/Linux 与 macOS 双平台各跑一次留证（macOS 腿走 mac 通道）。
- **Step 2 AC-08 实现**：按 `DESIGN-20261031-ac08-baseline.md` 落地；Gate 2 先锁两件——§1 两处数字更正（126 行/113 PASS）、AC2 重跑底座（捕获件＋--root 重建法）。
- **Step 3 框架落字三件**：G4-F3（surplus SKILL throw 句独立成条）；pack 台账小修（新增「无判别力」状态、verified 降格分级、补 2 行、compatibility 裁决写回注册表注释、ml-training 摘注册）；长证据文件分段落盘纪律入框架证据规则。
- **Step 4 运行时探针口径**：TAD workflow 脚本头部加运行时需求声明；执行入口 Validate 后加零成本能力探针（探不过校验阶段红灯）；surplus 两脚本先行落地，验法＝在缺全局的 harness 应于任何 agent 启动前红灯。

## Phase 2 · 蒸馏批次

surplus 修复链的知识收口，文档面为主。用户点数 0。

- **Step 1 候选落盘**：四条蒸馏候选（副本执行＋哈希对账、fixture 禁自引用、裁定归一层双层模式、verdict 表形对齐）逐条过蒸馏规程落 patterns/判据面。
- **Step 2 表形系统对齐**：verdict 表格形状与 gate3-check.sh 校验口径对齐（G4-F2 系统修法）——动检查器口径，Gate 3 双审。
- 与 Phase 1 的关系：内容独立、文件面不重叠；串行排 Phase 1 后（同仓单写者纪律），conductor 可按文件面冲突实况在 Phase 1 的 Step 3/4 间隙调度。

## Phase 3 · pack 分诊

裁定正本 TICKET-20261031-pack-triage（技术研究席提案、全盘采纳）。用户点数 1（Gate 4）。台账词表等小修已在 Phase 1 Step 3 先行，本 Phase 不重复。

- **Step 1 收紧重验**：web-backend、data-engineering 按 pack 独有规则号/阈值收紧判别式，runner 复跑；再无 delta 降级为参考文档退出 pack 体系。
- **Step 2 基线失败派生补验**：pending 12＋新补行 2，先跑对照组、专挑其做错/做漏处建 fixture 后补验；窗口锚 4.0.9 发版收口，到期未验自动转观察。
- **Step 3 触发层抽测＋成本读数**：verified-discriminative 9 个中抽 3 个测真实任务下加载率；抽 2–3 个真实任务记带包/不带包 token 与轮次差。

## Phase 4 · 扫描面

输入：HANDOFF §10.3 递延三条＋流程五条第 1 条（三查硬门）＋AC8 回放集。用户点数 1（Gate 4）。

- **Step 1 三查硬门**：扫描/派发分支 0 加人供前置查、来源活状态查、引用件在盘查，任一不过降 needs-human 并显名（递延三条之「立论源须活状态件」「status 不明默认 needs-human」并入本 Step 判据）。
- **Step 2 刷新类 diff 告警**：刷新类候选逐条与上轮 diff，资格翻转显名告警（递延第三条）。
- **Step 3 回放验**：三查改后的扫描器重跑回放集——AC8 七行集＋扫描三例样本（jev 人供前置、gap-queue-52 叙述立论、EPIC-20260927 引用缺位）必须全数在分支 0 被拦或降级。

## Phase 5 · 签认层（🔴 待口径对齐）

输入：TICKET-20261031-attestation-integrity＋运行不变量两层（已登记入其设计输入）。用户点数 2（口径对齐＋Gate 4）。

- 口径对齐前不设计、不实施。待对齐三问：验到什么程度算数、程序错与诚信错怎么分、机器对账卡在哪一步。
- 对齐后补全 Step 切法（构成三件：验收机械对账入规程步、签认层分类入词表、证据资格原则入判据面）再走全链。**本 Phase 不挡发版**：若口径对齐晚于其余 Phase 清空，签认层移出本 Epic、顺延下一版（移篮须在 BASKET 登记并报用户）。

## 发版前程（Epic 外，规程步，发版链内）

- step3f 四面轻链＋独立读检；真链回归首轮（OpenCode，备改判 Cursor；同轮 Codex 信任审查）；支持成色首轮标注（L0–L3＋证据日期）；存量五面对账（独立核对）；装载预算首版读数；downstream 台账刷新（step3e.3）。齐后按 publish-protocol 发 v4.0.9，推 main＋打 tag 前向用户摆校验结果。

## 顺序

Phase 1 → 2 → 3 → 4 →（Phase 5 口径齐后插入）→ 发版前程 → v4.0.9。用户点数总计仍为篮子口径 7。
