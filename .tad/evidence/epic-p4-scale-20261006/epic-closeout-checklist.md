# Epic 总收口清单件 — EPIC-20261006 自优化 Epic（Phase 4 件收官备料，2026-10-06，Blake 按 §10 骨架成件）

PM 总收口时照单执行。版本终值：**v3.2.0**（PM 裁断 D-4 已采纳：P3 minor 与 P4 内容并入一个对外 minor，序列 3.1.0→3.2.0 一步；终裁与执行均归 PM）。

## 统一发版 9 步（每步留证）

1. **升版与分诊**：bump `.tad/version.txt` 至 `3.2.0`；按件 1.3 口径做 minor 全量分诊，以 §「minor 预检基线」为起点逐项处置（live 改／史述面豁免须逐项有据），分诊记录落 `.tad/evidence/releases/3.2.0-version-triage.md`。判据：`release-verify.sh version` 口径下豁免外 stale ＝ 0。
2. **当版 hop 随船**：`.tad/migrations/3.1.0-to-3.2.0.yaml` 入仓；在发版提交点以在船断言实测（临时指发版提交验 `HOP present and well-formed (3.1.0-to-3.2.0)`，沿 P2 件 2.9 形态）。
3. **step3f 活体回归**：三家按发版清单实跑并登记。⚠️ 前置：P3 挂账 Codex PASS 基线补跑排 2026-10-10（配额恢复后）——总收口时点须在其落地之后，或由 PM 以裁定明示豁免并记入完事卡，不得静默跳过。
4. **brain-index 收口再生**：按本链新入 publish-protocol 的 step3g 实跑 `brain-index-gen.sh`＋check7 回读（age 0d、无 WARN），记录留分诊件——此为该周期步的首次真实行使。
5. **发版校验全套**：release-verify（现行口径全步，含 step3f 与校验器自检）、state-surface 全检，均须 exit 0／PASS。
6. **打 tag**：`v3.2.0` 打在发版提交上；按承接 D step5 三要素断言验（本地在位／远端在位／指向发版提交）。
7. **push 与远端验**：经 grokbox 通道推 main＋tag＋maintainer-evidence（证据先走收口同步脚本），`git ls-remote` 逐项对尖。
8. **知会 GM**：附远端尖值、版本终值（v3.2.0）、「刷新路径已补 brain-index 生成步」（件 4.2）三事，请 GM 发**一轮**全席刷新令（sequencing 口径：这是 Epic 唯一一次下游刷新）。⚠️ 前置核对：件 4.2 的 tad.sh 刷新路径接线（本链 Phase 1 步 4）须已落地——本件成件时点该步因增补 B5 串行序（等 tadsh-backup-fix 链实施提交）暂跳中；若收口时仍未落地，先补接线＋AC14/AC15 fixture 再发版，不得带缺口知会。
9. **Epic 总完事卡与挂账总清点**：Epic Phase Map 四行全 ✅ 回写、总完事卡落 `docs/pm/open-cards/`；挂账逐项销/转——含 CF-7 与 driftcheck (b) 11 件（去向建议见下两段）、本链遗留（Codex 基线、(b) 级 worktree 去向、pack 历史议题、node_modules 同步排除建议转 GM/infra）。

## minor 预检基线（AC26，本链 Phase 3 实测回填）

- 命令（可复跑）：`bash .tad/hooks/lib/release-verify.sh version . 3.2.0 3.1.0`（正口径：tracked 文件集、字面 `3.1.0`、zero-touch 过滤＋Version Exclusion Contract 后）。
- 结果（2026-10-06）：**59 hits／34 文件**（exit 1＝detect 命中，属预检预期）。粗筛对照：裸 `git grep '3\.1\.0'` 为 69 hits／41 文件，差额为正口径过滤掉的 zero-touch 面与契约豁免行。
- 件 1.3 史述面口径适用注记：59 件中大部为史述面——`docs/legacy/` 的 2025 年「v3.1」升级文档群（20 hits／4 文件，系旧版本线叙述、与现行 3.1.0 仅字面同形）、链务记录（open-cards/done 卡与各 Gate 卡）、`.tad/migrations/3.0.2-to-3.1.0.yaml`（上版 hop 本体）、`openapi: 3.1.0`（OpenAPI 规范版本、非 TAD 版本）等，分诊时按史述面豁免处置并逐项留据；live 改面为版本源与现行声明集（`.tad/version.txt`、`.tad/TAD-VERSION`、`tad.sh` TARGET_VERSION、`package.json`、`.tad/config.yaml`、pack-registry、AGENTS.md／README／ROADMAP／NEXT／PROJECT_CONTEXT／INSTALLATION_GUIDE／MULTI-PLATFORM 现行声明行、alex/blake/tad-help SKILL 标记等），以分诊记录为准逐项销。

## CF-7 去向建议（两段历史 hop 缺口：2.43.1→3.0.0、3.0.0→3.0.1；只建议，PM 裁）

建议**以裁定关闭、不回造 hop 文件**。理由：hop 文件的消费者是 migration engine 对「正跨越该段的装机」的升级判读；两段的目标版本均已被全席越过（现行基线 3.1.0），且初装面有 genesis 锚兜底（件 1.6），回造历史 hop 无活消费者、只增台账噪音。附带条件：若 PM 盘点发现仍有装机停在 3.0.0 之前，则该段改判「补造」并另立小单。裁定落 `.tad/evidence/pm/` 后 CF-7 自观察项销账。

## driftcheck (b) 11 件去向建议（P1 完事卡遗留①；只建议，PM 裁）

建议**不并入本次统一发版批，转入下一轮 PM 自查批的设计输入**：逐件以 driftcheck 复跑定活/死（在册形态是否仍与盘面矛盾），活者逐件定案、死者批量销账。理由：11 件为批外存量、与本 Epic 四段无耦合，夹带进收官批会重演「收口批变杂物批」；自查批正是其归口（与 R1→Epic 的来路同构）。
