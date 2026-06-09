# Epic: TAD Cross-Platform Unification — One SKILL, Every Runtime

**Epic ID**: EPIC-20260608-cross-platform-unification
**Created**: 2026-06-08
**Owner**: Alex
**Target Release**: v2.26.0

---

## Objective

消除 TAD 的双版本架构（Claude Code 完整版 + Codex 压缩版），改为统一架构：同一套 SKILL.md 文件，安装时根据平台放到对应路径（`.claude/skills/` 或 `.agents/skills/`），生成对应的配置文件（settings.json 或 hooks.json）。这基于 2026-06-08 的深度研究发现：Codex CLI 现已具备 hooks、skills、subagent、ask_user_question 等全部能力，与 Claude Code 功能对等。

**为什么现在做**：
- 2026-04-27 Codex Adaptation Epic 基于"Codex 能力不足"假设建了压缩版体系，现在这个假设已不成立
- 压缩版 SKILL 丢失 72-85% 内容，导致 Codex 体验远差于 Claude Code
- 双版本维护成本高（每次更新需 regen + review + commit），且漂移不可避免
- 用户实际痛点：安装后 Codex 里身份识别慢、功能残缺

## Success Criteria

- [ ] 同一套 SKILL.md 在 Claude Code 和 Codex 均可完整加载和执行
- [ ] `tad.sh --platform codex` 安装后，`$alex` 或"当 Alex"均可激活完整 Alex 角色
- [ ] `.tad/codex/codex-{alex,blake}-skill.md` 及 launcher 脚本全部删除
- [ ] *sync 支持多平台目标项目（自动检测 .claude/ 或 .agents/ 路径）
- [ ] YOLO 模式在 Codex 上可用（subagent ≥2 并发，有 evidence 证明并行执行）
- [ ] Dogfood：在 TAD 自己项目上完成一次 Codex 闭环（Alex Codex → Handoff → Blake Codex → Gate 3/4）

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | **Installer + Skill Routing** | ✅ Done | HANDOFF-20260608-cross-platform-phase1.md | tad.sh 统一安装 + SKILL 平台路径分发 + AGENTS.md 生成 + 平台注释 |
| 2 | **Hooks + Sync + Cleanup** | ✅ Done | HANDOFF-20260608-cross-platform-phase2.md | 双格式 hooks 配置 + *sync 多平台支持 + 删除旧 Codex 体系 |
| 3 | **Dogfood + Documentation** | ✅ Done | HANDOFF-20260608-cross-platform-phase3.md | --platform both + dogfood 验证 + YAML 修复 + 文档更新 |

### Phase Dependencies

- **P1 → P2**: 安装器改完才能改 sync 流程（sync 依赖安装器的路径逻辑）
- **P2 → P3**: 旧代码清理完才能做干净的 dogfood
- P3 内部：先 dogfood 验证，再写文档（不为没验证的东西写文档）

### Derived Status

Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Installer + Skill Routing

**Status:** ⬚ Planned
**Execution:** pending

#### Scope

修改 tad.sh 安装器，让它根据 `--platform` 参数将 SKILL 文件安装到正确路径。为 Codex 安装生成 AGENTS.md。在 SKILL.md 中添加平台工具名注释。NOT in scope: hooks 配置生成（Phase 2）、*sync 改造（Phase 2）、旧代码删除（Phase 2）。

#### Input

- 现有 tad.sh 安装器（已支持 `--platform codex` 参数）
- 现有 `.claude/skills/alex/SKILL.md` 和 `.claude/skills/blake/SKILL.md`（完整版）
- 现有 `platform-codes.yaml`（平台配置）
- 现有 `AGENTS.md`（Codex 角色切换文件）
- 深度研究报告：Codex CLI 最新能力对照表

#### Output

- tad.sh：`--platform codex` 时将 SKILL 复制到 `.agents/skills/{alex,blake}/SKILL.md`
- tad.sh：`--platform codex` 时生成/更新 AGENTS.md（指向 `.agents/skills/` 路径）
- SKILL.md：关键工具引用处添加平台注释（如 `<!-- Claude Code: AskUserQuestion / Codex: ask_user_question -->`）
- platform-codes.yaml：更新 Codex 的 extra_deny（不再排斥 `.claude/skills/alex` 和 `.claude/skills/blake`）
- AGENTS.md 模板：更新为指向 `.agents/skills/` 路径

#### Acceptance Criteria

- [ ] AC1: `bash tad.sh --platform claude-code` 后，`.claude/skills/alex/SKILL.md` 存在且为完整版（≥340KB）
- [ ] AC2: `bash tad.sh --platform codex` 后，`.agents/skills/alex/SKILL.md` 存在且与 `.claude/skills/alex/SKILL.md` 内容一致（`diff` 无差异）
- [ ] AC2b: `bash tad.sh --platform codex` 后，`.agents/skills/blake/SKILL.md` 存在且与 `.claude/skills/blake/SKILL.md` 内容一致（`diff` 无差异）— Codex review fix: Blake 对等覆盖
- [ ] AC2c: `.agents/skills/alex/references/` 和 `.agents/skills/blake/references/` 目录下文件与 `.claude/skills/` 对应目录一致 — Codex review fix: references 文件覆盖
- [ ] AC3: `bash tad.sh --platform codex` 后，项目根目录 `AGENTS.md` 存在且指向 `.agents/skills/` 路径
- [ ] AC4: `grep -c '<!-- Claude Code:.*Codex:' .claude/skills/alex/SKILL.md` ≥ 5（至少 5 处平台注释）
- [ ] AC4b: `grep -c '<!-- Claude Code:.*Codex:' .claude/skills/blake/SKILL.md` ≥ 3 — Codex review fix: Blake 平台注释
- [ ] AC5: platform-codes.yaml 的 codex.extra_deny 不再包含 `.claude/skills/alex` 和 `.claude/skills/blake`
- [ ] AC6: `bash tad.sh --platform codex --yes` 在非交互模式下正常执行（无 TTY 问题）
- [ ] AC7: tad.sh 在安装时检测 Codex CLI 版本，若 hooks/skills 不可用则输出明确警告（不阻塞安装，但告知用户功能受限）— Codex review fix: 版本门禁

#### Files Likely Affected

- `tad.sh` (MODIFY — 安装路径逻辑、AGENTS.md 生成、Codex 版本检测)
- `.tad/platform-codes.yaml` (MODIFY — Codex extra_deny 更新)
- `AGENTS.md` (MODIFY — skill 路径指向更新)
- `.claude/skills/alex/SKILL.md` (MODIFY — 添加平台工具注释)
- `.claude/skills/alex/references/*.md` (MODIFY — 添加平台工具注释)
- `.claude/skills/blake/SKILL.md` (MODIFY — 添加平台工具注释)
- `.claude/skills/blake/references/*.md` (MODIFY — 添加平台工具注释)

#### Dependencies

None (Phase 1 is the starting point)

#### Notes

- tad.sh 已有 `--platform` 参数和 `resolve_platform()` 函数，改动是增量的
- AGENTS.md 模板需要更新 skill 路径但保留触发词表
- 平台注释策略：只在工具名首次出现处加注释，避免噪音

### Phase 2: Hooks + Sync + Cleanup

**Status:** ⬚ Planned
**Execution:** pending

#### Scope

为 Codex 安装生成 hooks.json 配置文件。修改 *sync 支持多平台目标项目。删除整个 `.tad/codex/` 压缩版体系及相关脚本。NOT in scope: YOLO 在 Codex 上的验证（Phase 3）、文档更新（Phase 3）。

#### Input

- Phase 1 完成后的安装器和 SKILL 路由
- 现有 `.claude/settings.json` hooks 配置
- 现有 *sync 协议（Alex SKILL.md sync_protocol）
- 现有 `.tad/codex/` 目录（待删除）

#### Output

- tad.sh：`--platform codex` 时生成 `.codex/hooks.json`（从 settings.json hooks 转换）
- *sync：检测目标项目平台，同步到正确路径
- `.tad/codex/` 全部删除（codex-alex-skill.md, codex-blake-skill.md, launcher 脚本等）
- 删除 `codex-parity-check.sh`、`regen-codex-editions.sh`
- 更新 portable-rules.md（不再需要 SKILL Transform 规则）

#### Acceptance Criteria

- [ ] AC1: `bash tad.sh --platform codex` 后，`.codex/hooks.json` 存在且 schema 符合 Codex 官方格式（event → matcher group → handlers 层级）— Codex review fix: 不只检查存在性
- [ ] AC1b: hooks.json 中每个 handler 的 command 路径指向实际存在的 `.tad/hooks/lib/*.sh` 脚本 — Codex review fix: 行为可验证性
- [ ] AC1c: hooks 转换 spec 文档化：Claude Code settings.json 字段 → Codex hooks.json 字段的映射表写入 `.tad/guides/hooks-platform-mapping.md` — Codex review fix: 转换规范化
- [ ] AC2: `.tad/codex/codex-{alex,blake}-skill.md` 不再存在
- [ ] AC3: `.tad/codex/codex-tad-{alex,blake}.sh` 不再存在
- [ ] AC4: `.tad/hooks/lib/codex-parity-check.sh` 不再存在
- [ ] AC4b: 删除前验证无其他文件引用 `.tad/codex/` 路径（`grep -r '.tad/codex/' --include='*.md' --include='*.yaml' --include='*.sh'` 仅返回 archive/ 下的历史引用）— Codex review fix: 删除前依赖检查
- [ ] AC5: *sync 对 `--platform codex` 注册的项目，同步 SKILL 到 `.agents/skills/`
- [ ] AC5b: sync-registry.yaml 中现有项目自动添加 `platform: claude-code` 默认值（不改变现有行为）— Codex review fix: 迁移兼容
- [ ] AC6: *publish 不再运行 codex-parity-check（gate 已删除）
- [ ] AC7: portable-rules.md 的 "Strip → Replace" 和 "Transform Rules" 部分已删除或标记为 deprecated

#### Files Likely Affected

- `tad.sh` (MODIFY — hooks.json 生成)
- `.tad/codex/` (DELETE — 整个目录)
- `.tad/hooks/lib/codex-parity-check.sh` (DELETE)
- `.tad/codex/regen-codex-editions.sh` (DELETE)
- `.tad/portable-rules.md` (MODIFY — 删除 Transform 规则)
- `.claude/skills/alex/SKILL.md` (MODIFY — 删除 publish_protocol.step3b codex parity gate)
- `.tad/sync-registry.yaml` (MODIFY — 添加 platform 字段 per project)
- `.tad/guides/hooks-platform-mapping.md` (CREATE — hooks 字段映射 spec)

#### Dependencies

Phase 1 (安装路径逻辑必须先就位)

#### Notes

- hooks.json 转换 spec（AC1c）需覆盖：event 名映射、matcher 语法差异、handler type 支持度（Claude Code 的 `type: prompt` 在 Codex 是否有等价）、timeout/statusMessage 字段
- *sync 需要在 sync-registry.yaml 中记录每个项目的 platform 标识，现有项目默认 claude-code（AC5b）
- 删除操作需确保 git tracked，不遗漏
- 删除前跑依赖检查（AC4b），确认无活跃引用

### Phase 3: Dogfood + Documentation

**Status:** ⬚ Planned
**Execution:** pending

#### Scope

在 TAD 自己的项目上完成一次完整的 Codex 闭环验证。验证 YOLO 模式在 Codex 上是否可用。更新所有相关文档。NOT in scope: 新功能开发（只验证和文档化已有功能）。

#### Input

- Phase 1 + 2 完成后的统一安装系统
- TAD 项目本身作为 dogfood 目标
- Codex CLI（已安装）

#### Output

- Dogfood 报告：Codex 闭环测试结果
- YOLO 验证报告：subagent 并行在 Codex 上的实际表现
- INSTALLATION_GUIDE.md 更新
- CHANGELOG.md v2.26.0 条目
- README.md 更新（Codex 使用说明）

#### Acceptance Criteria

- [ ] AC1: 在 Codex 中用 `$alex` 或"当 Alex"激活 Alex，完成苏格拉底提问 + handoff 创建
- [ ] AC2: 在 Codex 中用 `$blake` 或"当 Blake"激活 Blake，读取 handoff 并执行实现
- [ ] AC3: Blake 在 Codex 中完成 Gate 3（hooks 正常触发、Layer 2 expert review 正常运行）
- [ ] AC4: Alex 在 Codex 中完成 Gate 4 验收
- [ ] AC5: YOLO 模式在 Codex 中启动 subagent（≥2 并发且有 evidence 证明并行执行）。若 Codex subagent 行为与预期不符，Phase 3 判定为 FAIL 并回 Phase 1/2 修复，不接受"记录失败原因"作为 PASS — Codex review fix: YOLO 硬性 gate
- [ ] AC6: INSTALLATION_GUIDE.md 包含 Codex 安装和使用章节
- [ ] AC7: CHANGELOG.md 包含 v2.26.0 统一架构变更记录

#### Files Likely Affected

- `INSTALLATION_GUIDE.md` (MODIFY)
- `CHANGELOG.md` (MODIFY)
- `README.md` (MODIFY)
- `.tad/evidence/` (CREATE — dogfood 报告)

#### Dependencies

Phase 2 (旧代码清理完才能做干净的验证)

#### Notes

- Dogfood 选一个真实但低风险的 TAD 改进任务
- YOLO 验证可能发现 Codex subagent 和 Claude Code Agent tool 的行为差异
- 如果 dogfood 发现阻断性问题，回 Phase 1/2 修复后再重试

---

## Context for Next Phase

### Completed Work Summary
- Phase 1 (2026-06-08): tad.sh TARGET_SKILL_DIR 路由 + verify 适配 + Codex 版本检测 + 平台切换警告 + platform-codes.yaml deny 更新 + AGENTS.md 路径更新 + Alex/Blake SKILL 平台注释 (commit 3f3dca5)
- Phase 2 (2026-06-08): hooks.json heredoc 生成 (4 handlers) + hooks-platform-mapping.md spec + sync-registry 14 项目 platform 字段 + Alex SKILL step3b 删除 + .tad/codex/ 12 文件删除 (-3882 lines) + release-runbook 清理 + deprecation.yaml v2.26.0 条目 (commit 8743546)
- Phase 3 (2026-06-08): --platform both 支持 + dogfood 验证（$alex 65s 激活成功，.agents/skills/ 自动发现确认）+ YAML frontmatter 修复 (ai-agent-architecture, web-ui-design) + AGENTS.md 简化 + INSTALLATION_GUIDE/CHANGELOG/README 更新 (commit a91cfdc)

### Decisions Made So Far
- 2026-06-08: 深度研究确认 Codex CLI 已具备全部所需能力（hooks, skills, subagent, ask_user_question）
- 2026-06-08: 决定删除整个压缩版体系，改为统一 SKILL + 平台路由
- 2026-06-08: 工具名差异用平台注释处理，不抽象化
- 2026-06-08: hooks 配置两份都维护（settings.json + hooks.json）
- 2026-06-08: *sync 需要改造支持多平台目标

### Known Issues / Carry-forward
- Codex `ask_user_question` 工具的 UI 行为可能与 Claude Code `AskUserQuestion` 略有差异（标签页 vs 选项列表）
- Codex subagent `max_threads = 6` 限制可能影响 YOLO 大规模并行
- AGENTS.md 的 `project_doc_max_bytes` 默认 32KB，SKILL 通过 skills 系统加载不受限
- Codex review (2026-06-08, INSUFFICIENT → 修复后): 7 条改进已整合到 Phase 1-3 AC 中。核心修复：Blake 对等 AC、hooks 行为验证、YOLO 硬性 gate、删除前依赖检查、sync-registry 迁移兼容、hooks 转换 spec、Codex CLI 版本门禁

### Next Phase Scope
Phase 3: Codex 闭环 dogfood 验证 + YOLO subagent 测试 + 文档更新 (INSTALLATION_GUIDE, CHANGELOG, README)

---

## Notes

### 研究基础
本 Epic 基于 2026-06-08 的深度研究，该研究颠覆了 2026-04-27 Codex Adaptation Epic 的核心假设。
详见：本次 Alex 会话中的"Codex CLI 最新能力研究报告"。

### 与旧 Epic 的关系
- 前任：EPIC-20260427-codex-cli-adaptation（已完成，在 .tad/archive/epics/）
- 本 Epic 实质上是对前任的"推倒重来"——基于平台能力趋同这一新事实
