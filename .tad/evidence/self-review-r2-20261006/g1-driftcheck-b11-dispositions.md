# 组 1 · driftcheck (b) 类 11 件定案表（2026-10-06）

基线（Step 0 实测）：driftcheck (a) 空、(b) 恰 11 件、(c) 空；Set A 25 / B_type 36 / B_dir 25 / C 25。

## 逐件三查与定案

三查口径：投影查＝`.agents/skills/<name>/SKILL.md` 在否＋type 探针命中因；登记查＝pack-registry.yaml 条目／源包目录／CAPABILITY.md；消费查＝AGENTS.md pack 指针表／brain-index Skills 索引／scan-packs 登记面三面 grep。

| # | 件 | 投影查 | 登记查 | 消费查 | 判 | 处置 |
|---|---|---|---|---|---|---|
| 1 | agent-computer-interface | 在（type: reference-based） | registry 无；源包目录在（仅 install.sh、无 CAPABILITY.md；scan-packs.sh L198 注释正以此件为例说明「无 CAPABILITY.md 的目录不计入登记数」） | AGENTS.md 指针表 **在**（1 行）；brain-index 在；登记面无 | **活**（以 pack 形态被指针表路由消费） | **补登记**：补 `.tad/capability-packs/agent-computer-interface/CAPABILITY.md`（元数据取自投影 frontmatter 原值＋登记恢复注记），scan-packs 重生成 registry（恰 +8 行） |
| 2 | agent-skill-evolution | 在（reference-based） | 全无（无源包目录） | AGENTS.md 无；brain-index 在；登记面无 | 活（skill-only 正当） | **声明锚** |
| 3 | hw-circuit-design | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 4 | hw-enclosure | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 5 | hw-firmware | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 6 | hw-testing | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 7 | mobile-development | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 8 | mobile-release | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 9 | mobile-testing | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 10 | mobile-ui-design | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |
| 11 | supply-chain-security | 在 | 全无 | 同上 | 活（skill-only 正当） | **声明锚** |

活/死分布：**活 11（补登记 1＋声明锚 10）、死 0、注销 0**。skill-only 10 件均为完整多文件技能（每件 7–10 个文件），自始以 skill 形态著述与消费（frontmatter 供模型按名/关键词选取、brain-index Skills 索引在册），无源包属其正当形态而非缺失；伪造源包骨架补登记会制造空壳 pack，故走声明锚。

## 声明锚与口径修订

- 声明锚：`.tad/capability-packs/skill-only-declarations.txt`（10 件逐行声明＋口径头注）。
- driftcheck 修订（`.tad/hooks/lib/pack-registry-driftcheck.sh`）：新增 Set S（读声明文件，缺文件＝空集、下游未采声明的仓行为不变）；(b) 改为 B_type\(A∪S)；新增 advisory 段 **(s)** 列已声明件（与 (r) 同等待遇：advisory、never drift）；(d) 的 skill-only WARN 排除已声明件，并新增 stale-declaration WARN（声明了但无 type 可见投影时告警，防声明文件腐烂）。
- 与 HANDOFF 分支文字「使其归 (r) 类」的语义对齐注记：(r) 的定义要求 registry 在册（A∩(B_dir∪C)），已声明 skill-only 件按定义不在 A 内、无法字面归 (r)；本批以独立 (s) 段实现同一语义目标（脱离 (b) 漂移类、归 advisory 类、never drift），差异与理由在此明记。

## 终值（AC6）

复跑 driftcheck：Set A 26 / B_type 36 / B_dir 26 / C 26 / S 10；(a) 空、**(b) 空**、(c) 空、(r) 空、(s) 恰声明 10 件、(d) 无 WARN；exit 0。

## fixture 正负控（AC7，ac17 同形态）

隔离 fixture 树（/tmp/r2-driftfix，脚本副本＋伪造 registry/技能/源包）四景全过：phantom-pack（登记有、投影与源包皆无）→ 仍入 (c)；regonly-pack（登记＋源包在、技能无 type）→ 归 (r) 不误报；declared-one（未登记、已声明）→ 归 (s) 不入 (b)；undeclared-one（未登记、未声明）→ 仍入 (b)（负控：声明是承重件、非全局放行）。fixture exit 1（由 (b)/(c) 触发，符合预期）。
