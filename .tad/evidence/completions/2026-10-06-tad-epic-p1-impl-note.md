# 实施完工说明 — TASK-20261006-EPIC-P1-CLEARANCE（Epic Phase 1 本体清账批）

- 执行：Blake，2026-10-06。判据：HANDOFF-2026-10-06-epic-p1-clearance（开工锚 53,861 B／`9c3cc3ff…`；含 PM 裁断 §7 扩展注记后终态 54,502 B／`5cc953955d…`）。
- 总结论：12 件全落盘；AC1–AC21、AC22（附注）实测通过，AC23 部分通过并已在 COMPLETION 明示待 PM 裁断。git 零写。

## 写集逐件字节变化（before＝git HEAD，after＝完工盘面）

| 文件 | before B | after B | sha256(after) |
|---|---|---|---|
| `.tad/scripts/capability-skill.sh` | 11,665 | 16,848 | `0f16defaaf7245d870f9544eb561f0a3441c739e6b56224be1ac7fa375c3050c` |
| `.agents/skills/product-thinking/SKILL.md` | 6,652 | 6,826 | `e53ef7320c3678fb9f8d8b8f7c9801cf50b0046d478b75948b1e4d264ff2644a` |
| `.tad/capability-packs/agent-orchestration/CAPABILITY.md`（PM 扩展） | 9,797 | 9,900 | `9334c20823e30fd12eb8fa53dbc53c0083e84e8485d867f0aa5cd49bd41c8e78` |
| `.tad/capability-packs/web-frontend/CAPABILITY.md`（PM 扩展） | 5,571 | 5,632 | `152f5bf0de5f83073b387bd59bc3fb7c69ad97fb053984ed5ccf947790577b61` |
| `.tad/capability-packs/web-testing/CAPABILITY.md`（PM 扩展） | 7,677 | 7,801 | `a94ceb56f5d775336ae75cd193d9bc36075578d3c3fede608ce6bc8d5d662b58` |
| `.agents/skills/alex/references/publish-protocol.md` | 11,015 | 13,538 | `f8edd5d19b328e1baad5da229cd03baf1a7409a21cd59b8a9c964d9c97ed9fc3` |
| `.agents/skills/release-runbook/references/publish-ops.md` | 6,572 | 9,362 | `834b66ed7ca7164de0fc391095e2cc43cbb2c264e8d548b53b15cfcb4fd1a204` |
| `.tad/active/session-state.md`（本地状态文件，不在 HEAD 内） | 3,711（由四子串长度差推得） | 3,746 | `325a10b13308229209d0f092ef42e0d7baa951829deec12f3881085c5b2733c2` |
| `.tad/tasks/gate-execution.md` | 9,316 | 9,900 | `ca4d7c10d499929d7642278ef1fea4de9cd5bd5ab874166ffd6a9504c8c6bc44` |
| `.tad/templates/handoff-a-to-b.md` | 24,445 | 24,766 | `516fca0468f311c9a6bb3a2b07c9702291857a843cdbfedfc4206cf62961254d` |
| `.tad/scripts/scan-packs.sh` | 8,022 | 8,317 | `3e5a3f2d525e9afe7435a388601d709f611de63c4d6bb6a6e9a4d6cd422d7fbe` |
| `tad.sh` | 128,219 | 130,897 | `6ffc4ed6aa2e8a74cdaf0a900a7406d736ac9b2230729884a5d6f3f241094093` |
| `.tad/hooks/lib/migration-engine.sh` | 44,248 | 45,241 | `19ec3230bc37a2c8576644228eefb8572ac2e9defc221a7aae1028a214a5fbcc` |
| `.tad/hooks/lib/pack-registry-driftcheck.sh` | 5,655 | 8,266 | `6522707dd6e866886161e0517d8c0debf9126a2d69f76c32987fede4b770ccaf` |
| `.tad/hooks/lib/state-surface-check.sh` | 7,916 | 11,826 | `dee23f6cf02532e05622252c390332143b78a4e910f78483cec72d1e08d7dc05` |
| `.tad/tasks/evidence-collection.md` | 11,250 | 12,428 | `f3b9fd0e76f49911a6ca855ebd8c68a353309dfcd84d48396a4517ab178ec047` |
| `AGENTS.md`（仓根） | 12,742 | 12,779 | `b85a4bee6f461a34c1669376d17694c82e2325a5ba0e6abec65e970288404bbd` |
| `.tad/templates/root-cause-report.md`（CREATE） | — | 1,549 | `4bcb49bee99723046273669b5589d84e063ff4552a4c2b6d618fd1ebe158dfb0` |

自产件（不计写集表）：本链 HANDOFF §7 扩展注记、`.tad/evidence/epic-p1-clearance-20261006/` 全目录、`.tad/evidence/completions/COMPLETION-2026-10-06-epic-p1-clearance.md`、本说明。

**AC22 附注（批前既存脏面）**：开工时点仓内已有非本链变更集——旧链 handoff/completion 在 `.tad/active/handoffs/` 的迁档删除群、`NEXT.md` 与 `docs/pm/{now,acceptance,auth,intent,ops-knowledge}.md`、`docs/CODEX-USER-GUIDE.md` 的修改、`.tad/TAD-POINTER.md` 与多张 `docs/pm/open-cards/` 未跟踪件等（PM 与他链在飞面）。本链未触碰、未代为清理；AC22 的封口判断只对本链变更集成立，逐件即上表＋自产件。

## fixture 证据路径（全 mktemp 隔离）

- 改前初装基线：`/tmp/epic-p1-fix0-VeLuem`（日志 `baseline-install-fixture.log`／`baseline-upgrade-fixture.log`／`baseline-fixture-checks.txt`）
- 改后初装（AC10/14/23）：`/tmp/epic-p1-fix1-dnggC8`（`install-after-fixture.log`、`ac10-*`、`ac14-ac15-hooks.txt`、`ac23-install-surface.txt`）
- 升级（AC11）：`/tmp/epic-p1-fix2-eo1oHp`（`ac11-upgrade-fixture.log`）；engine 正负控：`/tmp/epic-p1-engpos-*`、`/tmp/epic-p1-engmis-*`、`/tmp/epic-p1-engmid-*`（`ac11-engine-controls.txt`）
- 校验器负控（AC2）：`/tmp/epic-p1-ac2-wXk9SL`；driftcheck 三形态（AC17）：`/tmp/epic-p1-drift-*`；check7 分级（AC19）：`/tmp/epic-p1-check7-qPEANl`；hooks 语义比对（AC15）：`/tmp/epic-p1-hooks-U3dG84`；scan-packs 隔离断言（AC22）：`/tmp/epic-p1-scanpacks-KJP0aJ`

## 遗留登记句（供 PM 收口与后续批次）

1. AC23 判读待 PM 裁断：初装副本的四件 project-knowledge 读单路径因 installer 的 zero-touch 知识接缝设计（Option A）不在安装供给面内；若 PM 认定安装面路由一致性应覆盖项目自著面，则需另立设计（种子件或路由条件化），不在本链扩面。
2. CF-2 维持批外：driftcheck (b) 11 件 skill-only 登记滞后未治，源仓 driftcheck 总 exit 仍为 1（仅 (b) 所致），属登记面事项、报 PM 另行处置。
3. 仓内 `.tad/capability-packs/pack-registry.yaml` 仍含三包（agent-orchestration／web-frontend／web-testing）的旧 keywords——它是 scan-packs 派生件，本链按写集纪律未在仓内重跑生成；发版收口按 publish-protocol 跑 scan-packs regen 时自然对齐（隔离副本已验证生成值与投影一致）。
4. check7 现行 brain-index 年龄 20 天、WARN 在位：索引复产属 Epic Phase 3 件，本链只建分级断言、不复产。
5. 件 1.7 裁定与 GM 登记原倾向反向（生成器原输出非法 JSON、存档件为正本），PM 收口知会 GM 时须一并带明（HANDOFF §4.7／合并裁定既定）。
6. 本链不执行升版：发版（patch 提议）由 PM 在 Gate 4 后按 publish-protocol 收口执行，届时件 1.2 推导规则与件 1.3 口径首次实地适用，并须按 CF-5 在票面写明分诊记录要求。
