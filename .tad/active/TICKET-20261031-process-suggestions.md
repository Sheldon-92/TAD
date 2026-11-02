# Ticket: 技术研究席流程面五条提案的裁定与去向

- **Status**: OPEN（裁定已下；去向已分派，见下，随各批次执行）
- **Owner**: TAD PM（Muse 侧 TAD 席位，裁定属主）

## 来源

技术研究席受用户 2026-10-31 嘱为 TAD 升级提流程面建议，成件 `consult/tad-process-suggestions-2026-10-31/proposal.md`（tech-radar/main 2f6d6255），五条均出自当日实跑。TAD PM 裁定：**五条全采**，去向如下。
- 输入补件（2026-10-31 同日）：`consult/tad-process-suggestions-2026-10-31/references.md`（tech-radar/main a86d760a）——五条逐条配外部参考 23 处（带日期与成色）＋溢出发现一节（ADR／OPA／SLSA／错误预算／Pact，供执行时自取）；各条立项/设计时以此为参考输入。

## 裁定与去向（2026-10-31）

1. **扫描/立项前「活状态三查」硬门**（人供前置／来源活状态／引用件在盘）：采。与扫描面递延三条（HANDOFF §10.3）、GM 转入的 AC8 回放集同源合流——即扫描面 Epic 的核心判据，不另开链；三例样本作 Epic 的回放验法。
2. **workflow 脚本运行时需求声明＋开跑零成本探针**：采。进小修批：TAD workflow 脚本头部加运行时需求声明（全局/能力清单），执行入口在 Validate 后、Execute 前加零成本能力探针，探不过校验阶段红灯。验法照提案（surplus-execute 在缺全局的 harness 应于任何 agent 启动前红灯）。
3. **框架升级后「项目自有产物对账」**：采，执行主体定**独立核对**（不采执行者自查——消失事件正是执行面看不见自己）。落法：发版规程在升级收口加一步——升级前对 File Ownership 的 project-owned 面做清单快照、升级后独立读者逐项 diff、缺件红灯。首次活用于 4.0.9 下游升级（发版已递延，见 MEMORY 2026-10-31 用户令）。
4. **长证据文件分段落盘纪律**：采。升为通行证据纪律落字（>约 8KB 分段落盘＋每段验字节＋回执带总字节数与章节清单＋收尾自查无截断标记）；本席 AGENTS.md 已有同源教训条（2026-10-02），本条是把它落进框架证据规则——随小修批/蒸馏批次落字。
5. **判据回放集第一套用现成 P4 卷**：采。不另立项——并入 R4 输入面（与 Osmani 采纳项①判者考题集同源），R4 开设计时把 P4 的 15 题＋四轮成绩件登记为第一套回放基线。

## 逐条执行回写（2026-11-01，closeout-cleanup-1；release-recon-4.0.9 D8 处置）

| 条 | 执行状态 | 凭据（`disk-read`） |
|---|---|---|
| 1 三查硬门 | ✅ 已执行毕 | 随 EPIC-20261031-v409-basket Phase 4（扫描面）落地，2026-11-01 收口、Gate 4 CONDITIONAL PASS（p0=0）；报告 `.tad/evidence/yolo/v409-basket/phase4-gate-report.md`，BASKET 第 4 行 ✅ |
| 2 运行时需求声明＋零成本探针 | ✅ 已执行毕 | 随 Phase 1 小修批落地：`.tad/workflows/claude/surplus-execute.workflow.js` 头部 `runtime-requirements:` 声明与探针在盘；phase1-gate-report AC16／AC17 PASS |
| 3 框架升级后项目自有产物对账 | ⬜ 未毕（属实） | 落法已定（发版规程升级收口步、独立核对），首次活用于 4.0.9 下游升级；发版递延中，待首用 |
| 4 长证据分段落盘纪律 | ✅ 已执行毕 | `.tad/tasks/evidence-collection.md`「Segmented Write Discipline」节在盘（该节文末注记自述 Added 2026-10-31、Phase 1 small-fix batch、出自本票） |
| 5 P4 判据回放集 | ⬜ 未毕（属实） | 已并入 R4 输入面，待 R4 开设计时登记为第一套回放基线 |

## 连带调整

- pack 分诊补验窗口原锚「v4.0.10 发版收口」；用户 2026-10-31 令 4.0.9 递延、多攒升级再发版，分诊主体顺势并入 4.0.9 篮子，**窗口改锚 4.0.9 发版收口**（TICKET-20261031-pack-triage 已同步修订口径以本条为准）。
