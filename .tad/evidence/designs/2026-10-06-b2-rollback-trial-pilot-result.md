# 承接 B 试点记录 — 件 2.6 回退还原一环（试点宿主＝Epic Phase 3 链）

- 评估正本：`.tad/evidence/designs/2026-10-06-b2-change-evidence-trial-evaluation.md`（结论「采回退还原一环」，试点＝Phase 3 首链）；规程正本：HANDOFF §4.5。
- 执行：Blake，2026-10-06，grokbox 骨架隔离副本 `/home/box/p3-skeleton-pilot`（名称含 p3-skeleton，不在下游真实仓路径内）。时点：本链 Phase 1–3 实施完成、Gate 3 派发之前 ✔。
- 原始日志：grokbox `/home/box/p3-probe-logs/pilot.log`（sha256 `17ab52ef…71a4`）、`pilot-apply.log`（`a0b59ee7…27b`）、三份清单 `pilot-before.txt`/`pilot-applied.txt`/`pilot-after.txt`（before 与 after 两份 sha256 同为 `1888e01d…72fd`）。

## 1. 对象与比对面

- 变更集＝HANDOFF §7 写集的 MODIFY＋CREATE 全集；比对面按 §4.5 排除面收敛为 **16 路径**：MODIFY 6（tad.sh、AGENTS.md、patterns/_index.md、state-surface-check.sh、publish-protocol.md、publish-ops.md）＋CREATE 10（插件、.cursor/hooks.json、两垫片、清单＋三实例、两份权限样例）。
- 排除面逐项列明（不入比对）：zero-touch 件；证据面 `.tad/evidence/**` 本链自产件（Phase 0/1 记录、live-regression、regression-runs、首跑裁断件——其 MODIFY 以承接 A 整轮 PASS 为前提且本轮未发生）；本 HANDOFF/COMPLETION/试点记录等链务件；骨架/源树的其余文件（安装器整树同步的非本链面）。
- 「变更前」面：Phase 0 基线锚（`.tad/evidence/designs/2026-10-06-p3-phase0-probes.md` §0）＋骨架仓基线提交归档。注记：骨架基线提交含 Phase 0 探针残留（探针版 .cursor/hooks.json、OC-5 的 opencode.json、探针 txt 三件），与真实仓基线不符，试点开始时已按 Phase 0 基线锚校正删除（校正动作本身构成 (iv) 的一条分诊记录，见 §3）。

## 2. 执行规程（逐字，实际执行形态）

1. **before 清单**：骨架基线归档解入 pilot 目录（探针残留按上注校正），对 16 路径逐个记 `路径＋sha256`（不存在记 ABSENT），存 `pilot-before.txt`。
2. **apply**：(a) 安装器实装——pilot 内跑实施完成态源树的 `tad.sh --source <源树> --platform codex --yes --force`（含两投影族落位与自检段）；(b) 逐件置入腿——安装器不强制同步的本链件（合并管理面 publish-protocol/publish-ops、project-knowledge 四件＋_index、tad.sh 本体）自源树逐件拷入。置入后 16 路径与源树逐个 cmp，须零不符（`pilot-applied.txt` 与 before 的 diff＝16 行全动，判别力自证）。
3. **rollback**：(a) 投影件走安装器 rollback 路径——抽 `rollback_opencode_hooks_projection`/`rollback_cursor_hooks_projection` 以 created 旗＝1（两件 apply 前不存在）执行，移除两投影件；(b) MODIFY 六件自 before 洁净副本逐件还原；(c) 其余 CREATE 八件逐件移除（空目录顺带 rmdir）。
4. **还原比对**：对 16 路径重采清单（`pilot-after.txt`），与 before 清单逐行 diff。
5. **计时**：脚本化全程（归档→apply→rollback→比对）墙钟实测 8 秒（2026-10-06T12:28:31Z→12:28:39Z）；含两轮诊断迭代与面校正的首次总投入约 25 分钟（见 §3 分诊 1/2，两轮均留痕于 pilot.log 的先行轮次）。

## 3. 结果与差异分诊（(iv) 的输入）

- **比对结果：before 与 after 逐行全等（diff 0 行，两份清单 sha256 相同）**——回退还原在本链变更集上成立。
- 分诊 1（试点面缺陷，非产品缺陷）：首轮 apply 被 cursor_hooks_preflight FATAL 拦截——pilot before 面残留探针版 hooks.json（骨架基线污染）。此拦截本身即 ASM-2 的实证（分歧不覆盖）。校正面后重跑通过。
- 分诊 2（机制面刻画，非缺陷）：安装器对合并管理面（skill 参考件）与 project-knowledge 面不做强制同步（`--yes` 下 resolve=local 保留本地版），故 apply 须含逐件置入腿——回退还原的规程形态因此为「安装器 rollback（投影件）＋逐件还原/移除（其余件）」的复合形态，与 §4.5 预写一致。
- 分诊 3：structural 复核（release-verify `structural`，源树↔新装目标）唯一差异为目标侧自产 `.tad/migrations/genesis.yaml`（安装器创世锚，Phase 1 既定形态），非本链文件、非漂移。
- 不可分诊差异：**0**。

## 4. 四维回填

| 维 | 回填值 | 判读 |
|---|---|---|
| (i) 增量检出 | 试验完成；比对面可构造（Phase 0 基线锚＋归档）；回滚路径在中间态可执行（分歧 FATAL 是 apply 侧保护、非回滚阻塞）；真排除「部分升级中间态回退还原缺陷」——16 路径回退后与变更前逐行全等（清单指针见文件头）。附带刻画两条（分诊 1/2）为增量信息产出。 | **不翻负** |
| (ii) 成本比 | 试点墙钟：脚本化稳态周期 8 秒；首次含诊断总投入约 25 分钟。Gate 3 双审总工时：**待 Gate 3 后回填**（分母未发生）。 | **待回填态**（AC21 中间态；收口前必须以终值判读：若以稳态周期为分子，比值量级远低于 20%；若以首次总投入为分子，须与 Gate 3 实测工时对算后由 PM 判读——两口径均已在盘，不预判） |
| (iii) 重叠度 | 与既有机制的重叠逐项：安装器自带 rollback 覆盖面（投影件与快照面）——本试点 (a) 腿即复用之，重叠为「复用」非「重复建设」；Gate 3 评审面审内容正确性、不审状态可还原性，交集仅在 diff 呈现；release-verify structural 验装后字节同一性，与本试点的「回退后同一性」同法不同时点。估占比约六至七成，与 2.6 评估预估一致，无显著背离；增量部分（回退后状态等值断言）构成独立价值。 | **不翻负**（本维翻负须 PM 点名，记录呈 PM） |
| (iv) 误报 | 还原差异 0；过程异常 3 条全部分诊归因（试点面污染／合并策略刻画／创世锚自产），无不可分诊差异。 | **不翻负** |

## 5. 结论行

**试点成立（(ii) 维待 Gate 3 工时回填终值后确认）：维持『采』，转常设与否报 PM 裁。** (i)(iii)(iv) 三维不翻负；(ii) 维按 §4.5 允许的待回填态在盘，链收口（Gate 4）前回填终值并复核结论行——若终值比值 >20%，结论行自动改判「试点翻负：『采』自动降为『缓』，报 PM 另裁」。
