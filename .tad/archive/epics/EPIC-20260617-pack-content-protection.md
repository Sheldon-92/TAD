# Epic: Pack Content Protection System

**Epic ID**: EPIC-20260617-pack-content-protection
**Created**: 2026-06-17
**Owner**: Alex

---

## Objective
让 TAD 的能力包系统支持"下游定制 + 上游更新共存"。下游项目可以安全地修改 pack 文件（参数调整、新增引用）或永久 fork 一个 pack，而 tad.sh install 不会静默覆盖这些定制内容。

## Success Criteria
- [ ] tad.sh install 不会删除或覆盖下游项目已修改的 pack 文件
- [ ] 下游项目可以标记 pack 为 "forked"，完全跳过上游更新
- [ ] 安装/更新后有清晰的 pack 状态汇报（pristine/customized/forked/conflict）
- [ ] voice-studio 能安全地保留 ai-podcast-production 的项目特有内容

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Install Hash Manifest + Safety Fix | ✅ Done | HANDOFF-20260617-pack-content-protection-p1.md | 每个 pack 安装时记录文件哈希；sync-protocol 去 rm-rf |
| 2 | Modification Detection | ✅ Done | HANDOFF-20260617-pack-content-protection-p2.md | tad.sh 检测下游修改，拒绝覆盖已定制文件 |
| 3 | Conflict Resolution | ✅ Done | HANDOFF-20260618-pack-content-protection-p3.md | 双方都改了时展示 diff，用户逐文件决定 |
| 4 | Fork Support | ✅ Done | HANDOFF-20260618-pack-content-protection-p4.md | per-pack 策略标记，forked pack 完全跳过 |

### Phase Dependencies
All phases are sequential. Phase 2 depends on Phase 1 的哈希基础设施。Phase 3 依赖 Phase 2 的三方检测。Phase 4 基于 Phase 1-3 的 meta 文件。

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Install Hash Manifest + Safety Fix

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
为 pack 安装引入哈希清单（`.tad-pack-meta.yaml`），记录每个文件在安装时的 SHA-256 哈希。这是后续所有智能检测的基础。同时修复 sync-protocol.md 中的 `rm -rf` 和 `install.sh` 引用。

NOT in scope: 修改检测逻辑（Phase 2）、冲突解决 UI（Phase 3）、fork 机制（Phase 4）。

#### Input
- 当前 tad.sh 安装逻辑（copy_framework_files 函数）
- 当前 sync-protocol.md（仍引用 rm-rf + install.sh）
- 25 个能力包的 install.sh 模板

#### Output
- `.tad-pack-meta.yaml` 模板和生成逻辑
- tad.sh 在安装 pack 时自动生成 meta 文件
- sync-protocol.md 更新（去 rm-rf、去 install.sh 引用）
- 对已安装项目的迁移：首次运行时为现有 pack 生成 meta

#### Acceptance Criteria
- [ ] tad.sh install 在 .claude/skills/{pack}/ 下生成 .tad-pack-meta.yaml，含每个文件的 sha256 哈希
- [ ] sync-protocol.md 中不再有 `rm -rf` 和 `install.sh --force` 引用
- [ ] 已有下游项目首次运行 tad.sh 时，为现有 pack 生成 meta（当作 pristine baseline）
- [ ] install.sh 模板更新：生成 meta 文件
- [ ] 验证：干净测试项目安装后，.tad-pack-meta.yaml 存在且哈希正确

#### Files Likely Affected
- tad.sh (MODIFY — copy_framework_files 增加 meta 生成)
- .tad/templates/capability-pack-template/install.sh (MODIFY — 增加 meta 生成)
- .claude/skills/alex/references/sync-protocol.md (MODIFY — 去 rm-rf + install.sh)
- .tad/templates/pack-meta-template.yaml (CREATE)

#### Dependencies
None (first phase)

#### Notes
- 哈希算法选择：SHA-256（macOS 自带 shasum -a 256，无需额外依赖）
- meta 文件应包含：installed_version, installed_date, sync_policy (default: "upstream"), files 列表含路径+哈希
- 迁移策略：首次运行时如果 pack 存在但没有 meta，生成当前状态作为 baseline（视为 pristine）

### Phase 2: Modification Detection

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
tad.sh 在覆盖 pack 文件前，利用 Phase 1 的哈希清单检测下游是否修改了文件。未修改的文件安全覆盖；已修改的文件保留下游版本并警告。

NOT in scope: 双方都改了的冲突解决（Phase 3）、fork 标记（Phase 4）。

#### Input
- Phase 1 的 .tad-pack-meta.yaml（含安装时哈希）
- tad.sh 现有的 pack 安装逻辑

#### Output
- tad.sh 智能覆盖逻辑：pristine→overwrite, customized→preserve+warn
- 安装后 pack 状态汇总输出
- 更新后的 meta 文件（反映新安装的哈希）

#### Acceptance Criteria
- [ ] 修改 pack 文件后运行 tad.sh：修改的文件被保留，未修改的文件正常更新
- [ ] tad.sh 输出 pack 状态汇总："N packs updated, M packs have local modifications (preserved)"
- [ ] 新增的项目文件（不在上游的）不受影响（已有行为，确认不退化）
- [ ] meta 文件在覆盖后更新为新哈希
- [ ] 验证：修改 voice-studio 的 tts-production.md → 运行 tad.sh → 确认保留

#### Files Likely Affected
- tad.sh (MODIFY — 增加哈希比较 + 选择性覆盖逻辑)

#### Dependencies
Phase 1 (requires .tad-pack-meta.yaml infrastructure)

#### Notes
- 性能考虑：25 个 pack × 平均 5 个文件 = 125 次哈希比较，耗时可忽略
- 非交互模式（--yes）：保留所有已修改文件，输出日志
- 新上游文件（存在于源但不在目标）：正常复制安装

### Phase 3: Conflict Resolution

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
处理"双方都改了"的场景：下游修改了文件，同时上游也更新了同一文件。展示 diff，让用户逐文件决定。

NOT in scope: fork 标记（Phase 4）。

#### Input
- Phase 2 的修改检测逻辑
- 三方信息：installed_hash (meta) vs current_target_hash vs new_source_hash

#### Output
- 三方冲突检测逻辑
- 交互式 diff 展示 + 用户选择
- 非交互模式的默认策略（保留本地）

#### Acceptance Criteria
- [ ] 检测到三方冲突（本地改了 + 上游也改了）时展示 diff
- [ ] 用户可选择：保留本地 / 用上游 / 查看 diff 后手动 merge
- [ ] 非交互模式（--yes）默认保留本地，输出 CONFLICT 日志
- [ ] 不影响 Phase 2 的简单场景（仅本地改了 → 仍然 preserve）
- [ ] 验证：模拟双方修改 → 运行 tad.sh → 确认冲突提示正确

#### Files Likely Affected
- tad.sh (MODIFY — 增加三方检测 + 交互 UI)

#### Dependencies
Phase 2 (requires modification detection)

#### Notes
- diff 展示：用 `diff -u` 生成 unified diff，简洁可读
- 考虑 `tad.sh --resolve=local|upstream|ask` 参数
- 三方检测本质：如果 installed_hash != current_hash AND installed_hash != source_hash → 真冲突

### Phase 4: Fork Support

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
支持下游项目"永久 fork"一个 pack。forked pack 完全跳过上游更新，直到手动 unfork。

NOT in scope: pack 内容 merge 工具（超出 TAD 框架范围）。

#### Input
- Phase 1-3 的 .tad-pack-meta.yaml 基础设施
- tad.sh 现有安装逻辑

#### Output
- `tad.sh --fork-pack <name>` 命令
- `tad.sh --unfork-pack <name>` 命令
- forked pack 在安装时完全跳过
- 安装汇总中单独列出 forked packs

#### Acceptance Criteria
- [ ] `--fork-pack` 在 .tad-pack-meta.yaml 中标记 sync_policy: forked
- [ ] forked pack 运行 tad.sh 时完全跳过（不覆盖任何文件）
- [ ] `--unfork-pack` 恢复为 upstream 策略，重新生成 baseline 哈希
- [ ] 安装汇总区分 forked packs："2 packs forked (skipped)"
- [ ] 验证：fork ai-podcast-production → 运行 tad.sh → 确认零修改

#### Files Likely Affected
- tad.sh (MODIFY — fork/unfork 命令 + 安装逻辑判断)

#### Dependencies
Phase 1 (requires .tad-pack-meta.yaml)

#### Notes
- unfork 时需要重新以当前文件为 baseline 生成哈希（否则所有文件都显示为"已修改"）
- 考虑 `tad.sh --list-packs` 查看所有 pack 状态
- fork 信息存储在下游项目，不影响 TAD 源

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: tad.sh `generate_pack_meta()` + install.sh meta generation + sync-protocol rm-rf removal + release-verify.sh filter (commit 7833fc6)
- Phase 2: `copy_pack_skill_smart()` — 5-case decision tree (new/pre-meta/forked/migrated/fresh_install) + per-file hash comparison + PACK_STATS summary + source-hashing fix (commit 70ea84e)
- Phase 3: `resolve_conflict()` — three-way conflict detection (source_hash vs installed_hash) + interactive diff + --resolve=local|upstream|ask + .tad-conflict-backup + non-TTY fallback (commit 0fd448c)
- Phase 4: `fork_pack()` / `unfork_pack()` / `list_packs()` — --fork-pack/--unfork-pack/--list-packs commands + resolve_pack_dir cross-platform + name validation (commit afb8762)

### Decisions Made So Far
- 采用类似 dpkg conffile 的哈希记录方式（不是 git-based merge）
- 三方信息：installed_hash / current_hash / source_hash
- 下游修改默认保留（安全优先）
- 支持永久 fork（per-pack sync_policy）
- 验证策略：干净测试项目 + voice-studio 真实场景

### Known Issues / Carry-forward
- 现有 14 个下游项目没有 meta 文件，Phase 1 需要迁移逻辑
- *sync 已不再使用（pull-based 模型），但 sync-protocol.md 仍需修复以防万一
- voice-studio 的 ai-podcast-production 已经是 customized 状态，Phase 2 后才能正确处理

### Next Phase Scope
Epic COMPLETE — all 4 phases delivered.

---

## Notes
- 触发来源：voice-studio 的 ai-podcast-production pack 在 v2.30.0 sync 后被降级（3 个项目特有文件被删，tts-production.md 被回退）
- 核心洞察（来自用户）：问题不只是 rm-rf，而是下游 agent 会合理地修改 pack 文件（参数调整 + 新增内容），需要从架构层面支持"定制共存"
- 类比：Linux dpkg/rpm 的 conffile 处理机制
- 证据：commit 13f64fb, 6f81f41, 39ca5c8
