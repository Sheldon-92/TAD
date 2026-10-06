# 设计完工说明 — Epic Phase 4「体量与知识复产」（TASK-20261006-EPIC-P4-SCALE 设计步）

**角色**：Alex（Solution Lead，原生 subagent，tad_alex 壳激活）
**日期**：2026-10-06
**主交付**：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p4-scale.md`（49,664 B／sha256 `4acb634139a127ceb17ff0d15d876950163851b0104c65822497899aa8f19f1d`，AC1–AC28 连续）

## 激活自报（已读原件）
- 薄壳 `~/workspace/skills/tad-alex/SKILL.md`；仓内：`AGENTS.md`（含 File authority order 与 Known Gaps）、`.tad/project-knowledge/principles.md`、patterns `_index.md`＋命中全文 3 件（handoff-design、release-sync；memory-and-learning 经索引判读未全文展开——本步记账设计主要锚 revival 链原件，如实注记）、`.tad/tasks/handoff-creation.md`、`.tad/tasks/gate-execution.md`（Gate 2 节）、`.tad/gates/gate-canonical-checklist.md`（Gate 2 八项为本步判据出处）、模板 `.tad/templates/handoff-a-to-b.md` 与 `dispatch-risk-card.md`。
- 票面与链内原件：P4 票、Epic 正本（Phase 4 节与 Success Criteria）、P3 HANDOFF（§4.5 承接 B 规程＋§9.1 形态）、P3 COMPLETION 与 carryB 裁定（转常设＋下链复核义务）、载体裁定 §20（D35 关键件定义与触发）、revival HANDOFF §4.5（usage log 字段口径）、技术研究席刷新定性件 §二（下游 brain-index 缺口）、R1 P5 节。
- `.tad/brain-index.md` 本身：直读失败（非法 UTF-8）——该失败即件 4.2 的第一手证据，已入 HANDOFF §2.2；路由功能改以生成器源码与目录实查替代完成。

## 实测要点（全量数字见 HANDOFF §2，此处只记结论）
1. **体量 524M 的构成与 R1 叙述不同**：发行面（tracked 树 17.25MiB／1,927 文件）健康；大头是 `.worktrees/` 孤儿副本 224M（git 元数据不在本机、四分支中三支 0 ahead、一支 2 ahead 但 ref 安全）、证据工作副本 133M（权威载体在 maintainer-evidence 分支 15,456 文件，磁盘副本有既存注记明文保留）、node_modules 62M（可再生＋本机运行时依赖）、git pack 56M（几乎全为载体分离前的历史大 blob）。R1 点名的跟踪态历史层五处合计 <2.5M——是整洁问题不是体量问题，设计已如实改判。
2. **brain-index 坏的不只是年龄**：生成器隔离干跑在两种 locale 下同位复现非法 UTF-8（byte 4158 区、15 个 NEL），根因定案为 `cut -c` 在 POSIX locale 下按字节截断劈裂多字节字符。只再生不修生成器＝复制坏编码——设计把「修生成器」排在「复产」之前，并以 `LC_ALL=C` 干跑作 fixture 判据。
3. **D35 双条件均未达且记账已停摆**：log 6 行（genesis 1＋usage 5）／2 链／28 件，最高件跨链 2 链（阈值 5）、行数 6（阈值 50）；P1–P3 三链追加 0 行。复产清单据实为空集，复产对象改为记账装载点（COMPLETION 模板节＋evidence-collection append 步＋本链 dogfood）。
4. **下游缺口定位精确**：`generate_target_brain_index()`（tad.sh:1142）只接初装路径，刷新路径无调用——本体侧补一处接线即可，执行与逐席验证归 GM（边界已写死入 AC17）。

## 设计决断（Gate 2 靶点，详见 HANDOFF §5）
- D-1 git pack 历史不重写（收益约 50M vs 全谱系失效）。
- D-2 `.worktrees` 删除 (a)/(b) 两级分级，(b) 级（与尖端有任何差集）本链绝不删。
- D-3 件 4.3 复产清单空集＋记账复活路线（与票面字面预期不同，以实测立论）。
- D-4 Epic 版本终值建议 3.2.0 一次并版（覆盖 Epic 原 P4 patch 提议，终裁归 PM）。
- D-5 node_modules 同步排除只记建议转 GM/infra，不动 `.stignore`。

## 风险与纪律
- §11 触发集命中三项（删除/不可逆受控/对外分发面），风险卡草案已随 HANDOFF §11 成文（ASM-1～3 证伪式），正式卡待 PM 派发前落盘。
- 件 4.1 删除强制走承接 B 常设回退验证（先在骨架证明可由 ref 全量物化还原、再删），并设 PM 确认停步点（Phase 0 后）。
- 本设计步只写 HANDOFF 与本说明两件；git 全程只读；仓外仅 /tmp 隔离干跑副本（已留置 /tmp/bi-dryrun，可弃）。

## 下一步
PM 派 Gate 2 独立双审（fit/tech）→ 条件核销后派 Blake 按 §6 五相位实施（Phase 0 后有 PM 删除确认停步点）→ Gate 3 双审 → Gate 4 → PM 按 §10 总收口清单统一发版。
