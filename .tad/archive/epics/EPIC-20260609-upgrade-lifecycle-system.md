# Epic: TAD 升级生命周期系统 — 无垃圾、不误删、深入骨髓

**Epic ID**: EPIC-20260609-upgrade-lifecycle-system
**Created**: 2026-06-09
**Owner**: Alex
**Source Idea**: .tad/active/ideas/IDEA-20260609-upgrade-lifecycle-system.md (promoted 2026-06-09)

---

## Objective

建立统一的 Migration 机制：每个版本附带结构化 migration manifest（delete/rename/merge/verify），由共享执行引擎驱动 tad.sh 远程升级和 *sync 本地同步两条路径，使升级后"新文件在、旧文件清、用户文件永不触碰"，并通过 *publish 门禁保证未来每个版本都不会遗漏 manifest。

## Success Criteria

- [ ] 远程用户从任意受支持旧版本（起点由 Phase 1 取证确定）升级到最新版后：废旧文件 0 残留、重命名文件无新旧并存、ZERO_TOUCH 目录 byte-identical 未动
- [ ] tad.sh 与 *sync 使用同一个 migration 执行引擎（无双实现漂移）
- [ ] *publish 在"有文件删除/重命名但无 manifest"时真实阻断过至少一次（门禁实拦截演练，防验证剧场）
- [ ] E2E fixture 测试套件覆盖：升级正确性 + 幂等重跑 + 用户修改文件跳过 + 链式跨版本，可重复执行
- [ ] 14 个注册项目真实升级一轮 + diff -rq 双向验证全 PASS
- [ ] 3 个 merge-strategy 项目（my-openclaw-agents / toy / 内存管理）的 CLAUDE.md marker 遗留问题解决

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Manifest Schema 设计 + 回溯取证 | ✅ Done | HANDOFF-20260609-migration-schema-phase1.md | Migration manifest schema v1 + 回溯起点决定（DR）+ 用户修改检测方案 |
| 2 | Migration 执行引擎 + Fixture Harness | ✅ Done | HANDOFF-20260609-migration-engine-phase2.md | 共享引擎 lib（chain/delete/rename/verify/幂等）+ E2E fixture 测试框架 |
| 3 | 双调用方接入（tad.sh + *sync） | ✅ Done | HANDOFF-20260610-dual-caller-integration-phase3.md | tad.sh 升级路径 + *sync 路径统一走引擎 |
| 4 | Merge 能力 + Marker 标准化 | ✅ Done | HANDOFF-20260610-merge-capability-phase4.md | manifest merge 类型执行 + CLAUDE.md marker 约定 + 3 遗留项目修复 |
| 5 | *publish 门禁 + 历史 Migration 回溯生成 | ✅ Done | HANDOFF-20260610-publish-gate-phase5.md | release-verify migration 模式 + git tag diff 批量生成历史 manifest |
| 6 | 回归与验收 | ✅ Done | HANDOFF-20260610-acceptance-phase6.md | fixture 全跑 + 14 项目真实升级 + 门禁实拦截演练 |

### Phase Dependencies
顺序执行：1 → 2 → 3 → 4 → 5 → 6。其中 Phase 4 与 Phase 5 理论上可并行（都依赖 Phase 3），但同时只允许 1 个 Active phase（CLAUDE.md 规则），按序执行。

### Derived Status
- **Status**: Complete
- **Progress**: 6/6

---

## Phase Details

### Phase 1: Manifest Schema 设计 + 回溯取证

**Status:** ✅ Done
**Execution:** manual (human-relayed to Blake, Terminal 2)

#### Scope
设计 `.tad/migrations/{from}-to-{to}.yaml` 的 manifest schema v1：delete / rename / merge / verify 四个 section 的字段定义、路径约束（显式枚举、禁止通配符）、链式升级的版本链解析规则。取证确定回溯起点（git tag 列表 + 已知在野最老版本 v2.19.1 + GitHub clone/release 数据如可得）。设计"用户修改检测"方案（候选：发布版本 hash 库 / git tag 内容对照 / 简化为"与当前发布版不一致即跳过"）。**NOT in scope**: 任何执行代码、tad.sh 修改、实际 manifest 文件生成。

#### Input
- IDEA-20260609-upgrade-lifecycle-system.md（机制骨架 + 设计原则）
- principles.md 相关 SAFETY entries（deny-list、diff -rq、granularity 对称）
- git tags v1.0.0–v2.27.0、sync-registry（14 项目全部 2.27.0）
- Notebook: "AI Agent Framework Installers — Landscape 2026"（同类工具 migration 机制参考）

#### Output
- Schema 设计文档 + 字段示例（.tad/evidence/designs/migration-manifest-schema-v1.md）
- DR：回溯起点决定（.tad/decisions/DR-20260609-migration-backfill-depth.md）
- DR：用户修改检测方案选型
- v2.26→v2.27 一个手写示例 manifest（作为 schema 的 fixture）

#### Acceptance Criteria
- [ ] Schema 文档定义全部 4 个 section（delete/rename/merge/verify），每个字段有类型 + 约束 + 示例
- [ ] Schema 明确禁止通配符/模糊匹配：约束以可 grep 的规则写出（如 `path 必须以 .tad/ 或 .claude/ 开头且不含 * ? [`）
- [ ] 回溯起点 DR 引用 ≥2 个证据来源（git tag 列表、principles 在野版本记录）
- [ ] 用户修改检测 DR 对比 ≥2 个候选方案并给出选择理由
- [ ] 示例 manifest `.tad/migrations/2.26.0-to-2.27.0.yaml` 存在且通过 schema 自检（人工 review 级）
- [ ] ZERO_TOUCH 目录列表在 schema 中显式引用 derive-sync-set.sh `--zero-touch` 输出（公共 flag 接口，不抄写内部变量）

#### Files Likely Affected
- .tad/evidence/designs/migration-manifest-schema-v1.md (CREATE)
- .tad/decisions/DR-20260609-migration-backfill-depth.md (CREATE)
- .tad/migrations/2.26.0-to-2.27.0.yaml (CREATE — 示例)

#### Dependencies
None (can execute independently)

#### Notes
- "宁漏删，绝不误删"是 schema 的最高约束：delete 路径必须显式枚举 + ZERO_TOUCH 双重拦截
- Schema 是长期契约 — merge 字段这次就定义（即使 Phase 4 才实现执行），避免未来 schema 破坏性变更
- Completed: 2026-06-09, Handoff: HANDOFF-20260609-migration-schema-phase1.md, Commit: eab1fd8
- Gate 4: 15/15 AC PASS（Alex 独立重算，gate4_delta 空）；额外交付 DR-3（deprecation.yaml 吸收裁决，超出原计划 2 个 DR）

### Phase 2: Migration 执行引擎 + Fixture Harness

**Status:** ✅ Done
**Execution:** manual (human-relayed to Blake, Terminal 2)

#### Scope
实现共享执行引擎（建议 `.tad/hooks/lib/migration-engine.sh`）：版本检测 → migration 链解析（from→to 链式） → delete/rename 执行（含用户修改检测跳过 + 报告） → 升级后验证（新文件在 + 旧文件清 + ZERO_TOUCH 未动） → 幂等保证。同时建 E2E fixture harness：从旧版 git tag 构造 fixture 安装环境 → 跑引擎 → 断言。**NOT in scope**: merge 执行（报"需手动处理"）、tad.sh / *sync 接入、历史 manifest 批量生成。

#### Input
- Phase 1 的 schema 文档 + 示例 manifest + 两个 DR
- 现有 derive-sync-set.sh（--zero-touch / --transient flags）、release-verify.sh、tad.sh verify_install_complete

#### Output
- migration-engine.sh（可独立调用：`bash migration-engine.sh --from <v> --to <v> --target <dir> [--dry-run]`）
- fixture harness 脚本 + ≥4 个 fixture 用例（正常升级 / 幂等重跑 / 用户修改跳过 / 链式跨版本）
- 升级报告输出格式（删除了什么、跳过了什么及原因、验证结果）

#### Acceptance Criteria
- [ ] 引擎对示例 manifest 干跑（--dry-run）输出计划且不写任何文件（fixture 断言目录 mtime/内容不变）
- [ ] fixture: 正常升级后 `diff -rq` 断言旧文件清除 + 新文件存在，exit 0
- [ ] fixture: 同一升级重跑第二次 exit 0 且无额外变更（幂等）
- [ ] fixture: 构造用户修改过的框架文件 → 引擎跳过不删 + 报告中列出该文件（grep 断言报告行存在）
- [ ] fixture: v(N-2)→v(N) 链式升级按序执行两个 manifest（断言两者的 delete 都生效）
- [ ] 引擎对 ZERO_TOUCH 目录内任何路径的 delete/rename 指令 fail-closed 拒绝执行（fixture 用恶意 manifest 断言 exit 非 0）
- [ ] merge 类型条目输出"需手动处理"清单而非执行（fixture 断言）

#### Files Likely Affected
- .tad/hooks/lib/migration-engine.sh (CREATE)
- .tad/tests/migration-fixtures/ (CREATE — harness + 用例)
- .tad/migrations/ (MODIFY — fixture 用 manifest)

#### Dependencies
Phase 1

#### Notes
- 恶意 manifest fixture（ZERO_TOUCH 路径注入）是 load-bearing AC — 引用 principles "EXCLUSION assertion 是承重 AC"
- shell 可移植性遵守 patterns/shell-portability.md（macOS/BSD）
- Completed: 2026-06-10, Handoff: HANDOFF-20260609-migration-engine-phase2.md, Commit: fe11b95 + 7e2a945 (P0/P1 fixes)
- Gate 4: 19/19 AC PASS（Alex 实跑 fixture 14/14 全绿 + 独立 grep/bash-n 验证）；gate4_delta 空
- KA: APFS pwd -P case preservation → patterns/shell-portability.md

### Phase 3: 双调用方接入（tad.sh + *sync）

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
tad.sh 升级路径接入引擎：检测已安装版本 → 调用 migration 链 → 复制新文件（现有流程） → 三重验证。*sync 协议接入同一引擎（同步前先跑 migration）。两个调用方零双实现 — 引擎是唯一执行体。**NOT in scope**: merge 执行、*publish 门禁。

#### Input
- Phase 2 的 migration-engine.sh + fixture harness
- 现有 tad.sh（derive_framework_top_files / verify_install_complete）+ sync-protocol.md

#### Output
- tad.sh 升级流程含 migration 步骤（含 --non-interactive 兼容）
- *sync 协议更新（sync-protocol.md 引用引擎调用步骤）
- 升级报告在两条路径下输出一致

#### Acceptance Criteria
- [ ] fixture: 用旧版 tag 装出环境 → 跑新 tad.sh → 断言 migration 执行 + verify_install_complete PASS + 旧文件清除
- [ ] tad.sh 中不存在第二份 delete/rename 实现（grep 断言只有 engine 调用，无内联 rm 针对 migration 列表）
- [ ] *sync 对 1 个真实注册项目 dry-run：输出 migration 计划 + 同步计划，无写入
- [ ] 版本检测对"无 version.txt 的极老安装"降级为明确报错 + 建议 clean reinstall（fixture 断言报错文案）
- [ ] tad.sh 非交互模式（--yes / 非 TTY）下 migration 全程无 /dev/tty 阻塞（fixture 在非 TTY 下跑通）

#### Files Likely Affected
- tad.sh (MODIFY)
- .claude/skills/alex/references/sync-protocol.md (MODIFY)
- .tad/hooks/lib/migration-engine.sh (MODIFY — 如接入暴露接口缺口)

#### Dependencies
Phase 2

#### Notes
- principles "Never Hand-Write What an Existing Tool Already Does"：接入时修工具本体，不另写旁路脚本
- 每个 copy/delete 粒度必须有对应粒度的验证（granularity 对称原则）

### Phase 4: Merge 能力 + Marker 标准化

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
实现 manifest merge 类型的执行：以 `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker 为边界，TAD 头部随版本更新、用户内容保留。标准化 marker 约定文档。修复 3 个 merge-strategy 项目（my-openclaw-agents / toy / 内存管理）缺 marker 的遗留。**NOT in scope**: 除 CLAUDE.md 外其他混合文件类型的 merge（schema 支持但执行报手动）。

#### Input
- Phase 1 schema 的 merge 字段定义
- Phase 3 接入后的引擎
- NEXT.md 记录的 3 项目遗留问题

#### Output
- 引擎 merge 执行（marker 存在 → 替换头部；marker 缺失 → 跳过 + 报告，不覆盖）
- marker 约定文档（写入 schema 设计文档或独立 guide）
- 3 个遗留项目 CLAUDE.md 补 marker 并验证 merge 生效

#### Acceptance Criteria
- [ ] fixture: 有 marker 的 CLAUDE.md merge 后 — 头部为新版本内容 + marker 下方用户内容 byte-identical
- [ ] fixture: 无 marker 的 CLAUDE.md → 不写入 + 报告列出（绝不误删原则延伸到"绝不覆盖"）
- [ ] 3 个遗留项目补 marker 后真实跑一次 merge，用户内容部分 diff 为空
- [ ] merge 幂等：同一文件重跑 merge 无变更

#### Files Likely Affected
- .tad/hooks/lib/migration-engine.sh (MODIFY)
- 3 个注册项目的 CLAUDE.md (MODIFY — 补 marker)
- .tad/evidence/designs/migration-manifest-schema-v1.md (MODIFY — marker 约定)

#### Dependencies
Phase 3

#### Notes
- 用户内容 byte-identity 是 merge 的 SAFETY 边界 — AC 必须 diff 断言而非目测

### Phase 5: *publish 门禁 + 历史 Migration 回溯生成

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
release-verify.sh 增加 migration 模式：对比上一 tag 与 HEAD 的 git ls-files 差集，检测删除/重命名文件；若存在且对应 manifest 缺失 → 阻断发版。按 Phase 1 DR 确定的回溯起点，用 git tag 间 diff 机械化批量生成历史 manifest + 人工抽检。**NOT in scope**: 门禁实拦截演练（Phase 6）。

#### Input
- Phase 1 回溯起点 DR、Phase 2/3 的引擎与接入
- 现有 release-verify.sh（structural / freshness 模式先例）+ publish-protocol.md

#### Output
- release-verify.sh migration 模式 + *publish 协议接入
- `.tad/migrations/` 下回溯起点至 2.27.0 的全部 manifest（机械生成 + 抽检标注）
- 生成脚本（可复用于未来发版辅助起草 manifest）

#### Acceptance Criteria
- [ ] migration 检测 scope 到 `git ls-files`（不扫 gitignored 垃圾 — principles 88% 噪音教训）
- [ ] fixture: 构造"删文件无 manifest"的工作树 → release-verify migration 模式 exit 非 0 且报缺失文件清单
- [ ] 历史 manifest 链完整：从回溯起点到 2.27.0 每个相邻 tag 对都有 manifest（脚本断言链无缺口）
- [ ] 抽检 ≥2 个历史 manifest：与对应 tag 对的 git diff --name-status 人工核对一致
- [ ] rename 检测优先 false-positive（宁可把删+增报成疑似 rename 要求人工确认，不静默漏报）

#### Files Likely Affected
- .tad/hooks/lib/release-verify.sh (MODIFY)
- .claude/skills/alex/references/publish-protocol.md (MODIFY)
- .tad/migrations/*.yaml (CREATE — 批量历史 manifest)
- .tad/hooks/lib/migration-draft.sh (CREATE — tag diff 生成辅助)

#### Dependencies
Phase 3（引擎可消费 manifest 后回溯才有意义；可与 Phase 4 换序）

#### Notes
- 门禁默认 warn 还是 hard-block？参照 v2.24 structural gate 先例：首版 warn，Phase 6 演练后转 hard-block — 留给 handoff 设计时定

### Phase 6: 回归与验收

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
全链路验收：fixture 套件全跑、14 个注册项目真实升级（*sync 路径）+ diff -rq 双向验证、远程路径用旧 tag fixture 模拟 tad.sh 升级、*publish 门禁实拦截演练（故意删文件不写 manifest → 验证真实阻断 → 恢复）。**NOT in scope**: 新功能。

#### Input
- Phase 1-5 全部产出

#### Output
- 验收报告（.tad/evidence/acceptance-tests/upgrade-lifecycle/）
- 门禁实拦截演练记录（阻断输出原文）
- 决定门禁 warn→hard-block 是否翻转

#### Acceptance Criteria
- [ ] fixture 套件全部 PASS（输出留档）
- [ ] 14/14 注册项目升级后 diff -rq 双向验证 PASS，ZERO_TOUCH 目录升级前后 byte-identical（抽 3 项目全量 diff 断言）
- [ ] 旧 tag（回溯起点）→ 2.27+ 的链式升级 fixture PASS
- [ ] 门禁演练：阻断输出原文存档，证明非纸面验证
- [ ] Gate 4 Knowledge Assessment 完成（三问）

#### Files Likely Affected
- .tad/evidence/acceptance-tests/upgrade-lifecycle/ (CREATE)

#### Dependencies
Phase 5

#### Notes
- 这是 Success Criteria 的最终对账 Phase — 每条 Success Criteria 在此映射到证据文件

---

## Context for Next Phase

### Completed Work Summary
**Phase 1 (2026-06-09, commit eab1fd8)**: Schema v1 定稿 — 4 section（delete/rename/merge/verify）+ 五步路径安全流水线（normalize → reject-forbidden → assert-prefix → realpath/symlink containment → ZERO_TOUCH via `--zero-touch` flag）+ Consumer Semantics Contract（FR1.5：unknown schema_version 硬失败；delete/rename/merge unknown-field fail-closed，verify warn-ignore；跨 section 路径冲突 = manifest 非法；执行顺序 rename→delete→merge→verify）。可运行 validator 片段（BSD 兼容，Steps 1-3）已嵌入 schema 文档，Phase 2 引擎可直接提取。
- **DR-1**: 回溯起点 = v2.19.0→v2.19.1（13 对 in scope，1 已交付，12 留给 Phase 5；pre-v2.19 = clean reinstall）
- **DR-2**: 用户修改检测 = Option D Always Backup（`.tad-backup/{from}-to-{to}/` 先备份再删；Option B git-show 对照留作 Phase 3 增强）。⚠️ Phase 3 注意：把 `.tad-backup/` 加入 derive-sync-set.sh TRANSIENT
- **DR-3**: deprecation.yaml = **吸收**。执行顺序契约：apply_deprecations（冻结于 v2.26.0）先跑 → 引擎后跑，cutover 在 v2.27.0，无重叠期。⚠️ Phase 3 顺手修 tad.sh:721 误导注释（"lexicographic" → 实际 sort -V）
- **示例 manifest**: 2.26.0-to-2.27.0.yaml（3 delete 全部溯源真实 git diff D 行 + 4 verify）
- **allow-list 前缀**: `.tad/ .claude/ .codex/ .agents/` + 根文件 `CLAUDE.md AGENTS.md tad.sh`（`.agents/` 是 Blake 基于 diff 证据的合理扩充）

### Decisions Made So Far
- 统一机制：tad.sh 与 *sync 共用一个 migration 引擎（Socratic 确认 2026-06-09）
- fail-safe 方向：宁漏删，绝不误删 — 显式枚举 + ZERO_TOUCH 双重拦截
- 用户修改文件：~~跳过 + 报告~~ → **AMENDED 2026-06-09 (Phase 2 Socratic, human ruled)**: Hybrid — git-show 检测，改过=跳过+报告；未改=备份后删；检测不可用=跳过+报告（DR-2 Amendment 为准）
- Merge 这次做，作为独立 Phase（含 3 遗留项目修复）
- 回溯深度：由实际 git tag + 在野版本证据定（Phase 1 出 DR）
- 验收三件套：E2E fixture + 14 项目真实升级 + 门禁实拦截

### Known Issues / Carry-forward
- 已知在野最老版本 v2.19.1（principles 记载）
- 3 个 merge-strategy 项目缺 CLAUDE.md marker（NEXT.md 遗留）
- 现有 .tad.backup.* 目录垃圾累积问题（本 Epic 不处理备份策略，但 migration 不得再增加垃圾）
- **Phase 3 carry-forward**: `.tad-backup/` 在 derive-sync-set 推导面之外，需显式排除（Phase 2 code-review CR-P1-3）
- **Phase 3 carry-forward**: tad.sh:721 comparator 注释 bug（"lexicographic" → 实际 sort -V）

### Next Phase Scope
Phase 3：双调用方接入（tad.sh + *sync）— tad.sh 升级路径 + *sync 路径统一走引擎，零双实现

---

## Notes
- 用户核心诉求："即便以后 Codex 到 3.0 4.0 5.0，这些东西已经深入骨髓了，不会出错" — 机制必须自我维持（门禁强制），不依赖记忆
- Socratic Inquiry 完整记录在 promote 会话（2026-06-09，2 轮 8 问，Full TAD）
