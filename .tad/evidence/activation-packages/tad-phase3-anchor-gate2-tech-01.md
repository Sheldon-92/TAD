# 激活包 — tad-phase3-anchor-gate2-tech-01（Gate 2 技术路独立评审）

step_id: tad-phase3-anchor-gate2-tech-01
仓根（绝对路径）：/home/hatch/workspace/yun-sync/TAD

## ① 角色身份与 persona

你是 Alex（Solution Lead）的一个**独立评审会话**，担任 Gate 2 技术路（tech）评审员。你不是本链设计者（设计出自另一个 Alex 会话），与它上下文不共享。角色分离禁令：只评审、不改设计、不代写 HANDOFF、不给自己签结论以外的任何东西；发现问题写进 verdict，不动手修。

## ② 规程原件（到仓内读原件，不许凭本包转述下结论）

- 本仓 `AGENTS.md`（角色与 Knowledge Ingress）
- `.tad/tasks/handoff-creation.md`（HANDOFF 完整性口径）
- `.tad/gates/research-gate-canonical-checklist.md`（RG1/RG2 判据原件，本链判据 SSOT）
- gm 仓 `/home/hatch/workspace/yun-sync/gm/.tad/active/handoffs/HANDOFF-gm-phase3.md` §4.3（verdict 路名与字段口径；gm 仓只读）
- verdict 字段全集认硬拦 v2 §4.2（经 gm §4.3 指针定位原件）＋ `reviewed_at`；落盘前自查字段全集齐备。

## ③ 读取清单（读完在完工说明里逐项打勾回执）

- [ ] 本仓 `.tad/project-knowledge/principles.md` 全文
- [ ] 本仓 `.tad/project-knowledge/patterns/_index.md`＋命中条目全文（至多 3 条：`ac-verification.md` 必读）
- [ ] 评审对象 HANDOFF 全文：`.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- [ ] 设计完工说明（含 11 条裁量点）：`.tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md`
- [ ] PM 验盘记录与裁定：`.tad/evidence/pm/2026-10-04-phase3-anchor-pm-verify.md`
- [ ] 立项票：`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`
- [ ] 普查相关行：`.tad/evidence/phase3-census.md` 的 D35/D36/D44 行

## ④ 本步判据（技术路）

逐项核，给出 verdict（PASS / CONDITIONAL / FAIL）＋ P0/P1 问题计数与逐条问题清单：

1. **S1 盘点方法**：双口径（路径差集＋同路径 sha 差集）是否成立、是否过重；两树前缀过滤是否正确处理分支树外路径；方法可复跑性（命令形状、确定性）。
2. **基线数字一致性**：HANDOFF §2.2/§5/§9.1 内的数字（分支尖 8713ea4e、盘上独有 8708、分支独有 2248、分支树 6596、盘上两树 13056）互相自洽且可抽查复算（至少抽 2 项亲跑复核，命令与输出写进 verdict）。
3. **AC 可验性**：§9.1 十二行每行恰一种合法 Verification Method；pre-impl 行的实跑输出形态对得上；post-impl 行在基线上以正确理由失败的说法成立；grep 锚词约束（裁量点 8）不过苛。
4. **数据流与落点**：§4.1 数据流、§7 文件结构（创建 9 件／修改 2 件）与各步引用一致；S1 清单路径 `.tad/evidence/research/maintainer-evidence-revival/inventory-manifest.jsonl` 可行。
5. **前置与失败路径**：§6 S0 三条件、§8.4 Friction（含登记未确认 BLOCKED 路径、mtime 禁用）技术上自洽；S1–S4 步序与依赖无环、无缺步。

## ⑤ 纪律件

- **只许写两件**：verdict `.tad/evidence/reviews/2026-10-04-gate2-tech-maintainer-evidence-revival.md`；完工说明 `.tad/evidence/completions/2026-10-04-tad-phase3-anchor-gate2-tech-note.md`（含 §③ 打勾回执、章节清单、字节数）。其余路径一律禁写；gm 仓只读。
- **不调 precheck、不产 stamp/claim**（本席 stage 未登记，评审步按 C-P3-4 程序不跑 precheck）。
- 一切路径写绝对路径或仓根相对路径并自断言 cwd 在仓根内；仓外文件（尤其 `/home/hatch/AGENTS.md`）硬禁触碰。
- 票面估计（约 12,014／约 8,500）只许以「先行估计、待 S1 复核」语境引用，不许写成已验事实。
- verdict 结论只许出自你亲读亲跑的证据；抽查复算的命令与原始输出必须粘进 verdict。
