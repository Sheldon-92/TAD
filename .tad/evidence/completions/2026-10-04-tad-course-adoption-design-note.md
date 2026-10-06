# 完工说明 — 课程判断落地链 · 设计步（Alex）

- step_id：`tad-course-adoption-design-01`
- 角色：Alex（Solution Lead）
- 日期：2026-10-04
- 产物：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`
- 状态：设计成件，Gate 2 PENDING（双审待 PM 另派独立会话；本步不自判 Gate）

## HANDOFF 字节数与章节清单

- 字节数：**46,329 B**（落盘后 `wc -c` 实测）
- 章节在册（`grep '^# \|^## '` 实测）：Quality Chain Metadata（L1）／标题块（L18）／🔴 Gate 2 节（L32）／📋 Handoff Checklist（L51）／§1 Task Overview（L65，含 1.1–1.5：四项总表、总纲立论、Intent、非范围不采清单、Gate 结构六行）／📚 Project Knowledge（L110，四条摘录）／§2 Background（L139，含装载面盘点表与四项现状基线）／§3 Requirements（L174，FR1–FR4＋NFR1–NFR4）／§4 Technical Design（L196，4.1 装载架构图、4.2–4.5 四组件逐项五段、4.6 冲突点名 CF-1…CF-5、4.7 风险与回滚）／§5 MQ1–MQ5（L417）／§6 Implementation Steps（L492，Phase 1 按文件分遍＋Phase 2 自证/dogfood/收口）／§7 File Structure（L538）／§8 Testing Requirements（L564）／§9 Acceptance Criteria＋§9.1（L584/L591，AC1–AC15 逐行可跑）／§9.2 Expert Review Status（L613）／§10 Important Notes（L630）／§12 Sub-Agent 使用记录（L651）

## 四项落点速览表

| 项 | 落点文件与节位 | 条文形态 | 装载点位（何时被读到） | 验证（§9.1 行） |
|----|---------------|----------|------------------------|------------------|
| C1 风险卡证伪式假设表 | CREATE `.tad/templates/dispatch-risk-card.md`（裁剪版：头信息＋损失/REQ 简表＋假设表）；Canonical Gate 2 清单末增一项；Alex SKILL 义务块（L57–94）末增一行 | 模板全文＋清单项＋义务行，草案均逐字在 HANDOFF §4.2 | 义务行：Alex 每次激活必读首部块（触发）；Canonical 项：Gate 2 评审读 SSOT 时（检查）；模板：填卡时按条文点名路径打开（表单） | AC1/AC2/AC3/AC4＋AC13/AC15（dogfood 实填＋独立 judge 判可证伪） |
| C2 量规 E 维证据纪律 | Canonical Gate 3 §9.1 项增 E 维子款（证据指针＋自报不符否决）；Gate 4 项增自报不符句；Alex SKILL 义务块增一行。Blake SKILL 本体明示不改（靠其 SSOT 指针装载） | 子款增补，不动既有项本体 | Canonical 为两 skill 共同 SSOT 指针目标，Gate 3 评审与 Gate 4 验收执行时必读；义务行在 Alex 激活时常驻 | AC5/AC6/AC7 |
| C3 权威顺序短文 | 仓根 `AGENTS.md`「Memory authority」小节（L75）之后新增 `### File authority order` 一节（全文 14 行） | 一条短文（四顺位＋不许静默覆盖一句）；同步表与瘦身句不入 | `AGENTS.md` 由三 harness 会话启动原生读取，Critical Rules 区在文件前半 | AC8（四顺位行号升序）/AC9（全文 ≤188 行，守短文上限） |
| C4 装载点位一句 | Canonical 卷首增装载纪律一行；Gate 2 清单末增「Load points declared」常查项；Gate 3 §9.1 项增位置断言子款 | 一句本体＋设计侧常查项＋实施侧常查款 | 句在 SSOT 卷首（任何 Gate 执行第一屏）；Gate 2 项使设计评审逐单必查；Gate 3 子款使实施评审必查，本链 AC4/AC7/AC8 即 dogfood | AC10/AC11/AC12 |

全链硬约束：四件 MODIFY 纯增补（AC14：`git diff` 删除行数 = 0）；义务型新增文字带行号上限断言（≤120），防重演「写进大文件尾巴 = 没写」事故（patterns/gate-design.md 2026-08-14 条）。

## 设计步关键判断（供 Gate 2 参考）

1. **WS-0 在本仓无载体文件**（grep 坐实：仅命中判断正本、本票、本步激活包）。C4 的「并入 WS-0」落法 = 并入本仓实际装载面 Canonical SSOT，不新建 WS-0 文件——新文件本身没有装载点位，直接违反 C4。已点名为 CF-5 交 Gate 2 裁。
2. **五处冲突全部点名**（HANDOFF §4.6 CF-1…CF-5）：Gate 2 增项 vs 判断拒四元组入清单的边界、Canonical MECE 说明过期、Alex SKILL 体积、AGENTS.md 发布面传播、C4 的 WS-0 映射。裁定前 Blake 不许动对应落点（§10.1）。
3. **风险卡落盘位置自查修正**：设计初稿一处写「与 HANDOFF 同目录」、另一处写 `.tad/evidence/risk-cards/`，成件自查时统一为证据目录（评审与 Gate 4 的读取面），两处已改齐。
4. **不采项零夹带**：量规只取 E 维转写为判据（六维表不入本体）；风险卡模板只取假设表与损失简表（故障树/就绪清单/连接器审查节有 AC2 负控守门）；权威顺序只取短文（同步表不入）；六问与成对实测未出现在任何落点。

## 读取清单打勾回执

- [x] 激活壳 `~/workspace/skills/tad-alex/SKILL.md`（全文）
- [x] 仓根 `/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（全文）——Step 0 路径断言：pwd 与 `git rev-parse --show-toplevel` 均为该仓根，目标文件逐项在盘
- [x] ③-1 本票 `.tad/active/TICKET-20261004-course-judgment-adoption.md`（全文）
- [x] ③-2 判断正本 `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`（全文）
- [x] ③-3 提案原件五件逐件读毕：研究正文 `2026-10-04-fall-courses-tad-proposals.md`（全文）、模板一 `templates/gate3-rubric.md`（全文）、模板二 `templates/dispatch-risk-card.md`（全文）、模板三 `templates/review-six-questions.md`（全文）、交接单 `2026-10-04-tad-proposals-handoff.md`（全文）
- [x] ③-4 `.tad/project-knowledge/principles.md`（全文）＋`patterns/_index.md`（全文）；命中条目 3 条：`patterns/gate-design.md`（Claims Need Carriers 与位置断言两条全文）、`patterns/handoff-design.md`（装载/渐进加载条目）、`patterns/ac-verification.md`（索引与条目结构）
- [x] ③-5 落点候选规程面逐件读原件：`.tad/gates/gate-canonical-checklist.md`（全文）、`.tad/tasks/handoff-creation.md`（全文）、`.tad/tasks/gate-execution.md`（全文）、`.tad/tasks/evidence-collection.md`（全文）、`.tad/templates/handoff-a-to-b.md`（结构全文＋§9/§9.1/§9.2 原文段）、`.tad/templates/completion-report.md`（结构）、`.agents/skills/alex/SKILL.md`（义务块 L57–94、Handoff Creation Protocol L1061、SSOT 指针 L1147 原文段）、`.agents/skills/blake/SKILL.md`（结构＋SSOT 指针 L1110–1111）、`.tad/brain-index.md`（WS-0 路由查无）、既有 HANDOFF 范例 `HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（头部与 Gate 2 节体例）
- [x] WS-0/装载面盘上核查（grep 实测，结论见上「关键判断 1」与 HANDOFF §2.1/§2.2）

## 纪律自证

- 本步只写两件：本完工说明与 HANDOFF 本体；零 git 写操作（`git status` 实测仅见 HANDOFF 一件新增，完工说明落盘后为第二件）；未改任何规程本体文件。
- HANDOFF 正文未复述版本号；条文草案中的文件引用均为路径与节位。
- 基线干跑：§9.1 的 AC8/AC14 命令已在设计步原样实跑（ORDER_FAIL／0，均为预期基线结果），其余行基线值以 grep 实测记入 §9.1 Verified Output 列与 §2.2。

## 下一步（归 PM）

PM 派 Gate 2 双审（tech／fit 两路独立会话）→ 合并裁定（含 CF-1…CF-5 逐项裁定回填 HANDOFF §4.6/Gate 2 节）→ 派 Blake 按 Phase 1/2 实施。
