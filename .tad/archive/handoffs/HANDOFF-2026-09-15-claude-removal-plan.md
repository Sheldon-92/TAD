---
task_id: TASK-20260915-CLAUDE-REMOVAL
task_type: refactor            # code + config + docs; deletes one platform surface
express: false
skip_knowledge_assessment: no
e2e_required: yes              # installer + release-verify behaviors must be exercised
research_required: no
status: CLOSED        # 2026-10-04 PM 核定收口：Gate 4 遗留（R1 两处＋AC20 判据三处）已于链外闭合、盘面逐项亲验全过（核定记录 .tad/evidence/pm/2026-10-04-claude-removal-closeout-verification.md），Gate 4 依其 §7 自带判据升 PASS；收口件 COMPLETION-2026-10-04-claude-removal.md（迟补）；本件迁 .tad/archive/handoffs/
feedback_required: false
supersedes: HANDOFF-2026-09-15-claude-decouple-design.md
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-2026-09-15-claude-removal-plan

**Task ID**: `TASK-20260915-CLAUDE-REMOVAL`
**From:** Alex (Terminal 1) **To:** Blake (Terminal 2)
**Created**: 2026-09-15
**Status**: `CLOSED` — 2026-10-04 PM 核定收口：Gate 4（2026-09-16）CONDITIONAL 的遗留项（R1 两处＋AC20 判据三处）已于链外闭合，PM 盘面逐项亲验全过、AC20 命令原样实跑 0 命中，Gate 4 依其 §7 自带判据升 PASS。核定记录 `.tad/evidence/pm/2026-10-04-claude-removal-closeout-verification.md`；收口件 `COMPLETION-2026-10-04-claude-removal.md`（迟补）；本件迁入 `.tad/archive/handoffs/`。
**Version (locked)**: **v3.0.0 (major) — 一步落地**。人已拍板：不做 2.45.0 过渡版（理由见 §6.1）。
**Supersedes**: `HANDOFF-2026-09-15-claude-decouple-design.md`（决策简报，已按人拍板方向固化成本文件；旧文件标 `SUPERSEDED`）。
**Merged from**: `HANDOFF-2026-09-15-claude-removal-plan-codex.md`（Codex 独立方案的 5 条硬约束已并入本文件对应步骤，见下方「合并来源」段；该摘要文件保留为 provenance，不再是执行基线）。
**Mode**: **只出方案 / 不实现**（本文件是设计权威）。Blake 落地时：不 push / tag / bump，除非人单独授权发布。
**Channel**: Alex ≠ Blake。Dual Gate 2 在磁盘（§10）。Codex TAD 自定义 agent 未激活 → 审查走显式 subagent。

> **人已拍板的方向（本方案的前提，不再讨论）**：**彻底移除** Claude 路径——包括 Claude Code CLI 机制（`.claude/`、`--platform claude-code`、hooks 注册、workflows 运行时）与 Claude 模型绑定（opus/sonnet/haiku pin、`claude` 二进制 spawn）；只保留以 **Codex 为主的中立机制**。SSOT 反转为 `.agents/skills/`（理由见 §4.1）。

> **合并来源（两版方案 → 单一执行基线）**：本文件以 DeepSeek/Alex 的 S0→S9 执行骨架为基线，并入 Codex 版独立审查补出的 **5 条硬约束**。对照索引：
> 1. 历史 migration manifests 只读解析 `.claude` 路径，v3 **不得生成**自动删除用户 `.claude/**` 的新 manifest → §3.L / S7。
> 2. 旧 2.44.6 updater 可能自动传 `--platform both`，须 **fail-before-mutation** + 明确 `--platform codex` 恢复命令 → §3.M / S2。
> 3. SSOT 消费者清单补全（capability-pack installers、capability-skill.sh、pack 验证器、brain index、runtime freshness、pair driver）→ §4.4。
> 4. pair-driver 的 `claude -p --model sonnet` 与 YOLO harness profile 纳入 **硬性零残留 AC** → §3.G / V-P1 / AC16。
> 5. 下游 `.claude` 含用户 hooks/MCP/权限配置，**绝不自动递归删除**；升级安全 fixtures 覆盖 → §3.L / S0 / AC17。

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-15（Alex 设计；dual disk reviews 记于 §10）

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 目标架构 = `.agents/skills/` 唯一源 + `codex` 唯一 install target；`.claude/` 全删；parity 双树失效删除。§3.0 / §4。 |
| Components Specified | ✅ | 逐文件清单 §3；SSOT 方向 §4（含消费者全清单 §4.4）；升级安全/迁移/旧 updater 兼容 §3.L/§3.M；版本/分期/回滚 §6。 |
| Functions Verified | ✅ | HEAD `c32bde27` (v2.44.6) 实测：`.claude/skills` 与 `.agents/skills` 逐字节相同（见 §11）；所有 file:line 已核（含 5 条 Codex 约束的落点复核，见 §11）。 |
| Data Flow Mapped | ✅ | `$src/.agents/skills` → `$TARGET/.agents/skills` 单方向；release-verify `structural` 同方向；parity/platform-skills 删除。§4。 |
| Upgrade Safety Mapped | ✅ | 2.44.6→3.0.0 不在用户 `.claude/**` 上做任何自动删除（迁移链/引擎/deprecation/rollback 四处同批核验）。§3.L / AC17。 |
| Version Locked | ✅ | v3.0.0 一步落地（人已拍板，取消 2.45.0 过渡路径）。§6.1。 |

**Alex 确认**：本 handoff 是设计权威。Blake 不改架构、不改 SSOT 选择、不改版本策略；发现设计缺陷回 Alex。

---

## MQ (human lock)

1. **User**: TAD 框架维护者（grokbox 侧）。公开仓库 `github.com/Sheldon-92/TAD`，npm `tad-framework`。
2. **Problem**: TAD 在结构上是「Claude Code 主平台 + `.claude/skills` 唯一源」，不是对等多 target。用户已不用 Claude Code（日常 Cursor / Codex / OpenCode），拍板彻底移除该路径。2.44.6 已发版；本任务只出可执行方案。
3. **Scope (this task)**: 固化「彻底移除 **v3.0.0 一步落地**」的可执行 handoff：删除清单、SSOT 反转 + 消费者全清单、升级安全（迁移/旧 updater/用户 `.claude` 数据）、外部用户升级/Release Notes 文案、每步验证与回滚点、OpenCode 一等的定位。Codex 版 5 条约束已并入。
4. **Out**: 本文件**不实现**、**不 commit / push / tag / bump / release**；不动 `docs/pm/`（只读）；不动历史记录（CHANGELOG 旧条目 / `.tad/evidence` / `.tad/archive` / `docs/archive` / `docs/legacy` / `.tad/memory` / `.tad/migrations/*.yaml` / `tad-work/archive`）；不删下游用户数据。
5. **Success**: Blake 按 §6.2 顺序落地后，§8 的 grep 零残留全部 PASS；安装器 `--platform codex` 全绿；`--platform claude-code` / `--platform both` **fail-before-mutation** 且给出恢复命令；无 Claude 模型运行时调用（含 pair-driver `claude -p` 与 `JUDGE_MODEL_FAMILY='claude'`）；v3 不生成删除用户 `.claude/**` 的 migration manifest；升级 fixture 证明用户 `.claude/`（hooks/MCP/权限）字节不变；公开文档不再宣称 Claude Code 是一等平台。
6. **Teeth**: Alex ≠ Blake；installer-data-safety + release-sync + migration SAFETY 边界（§6.4）；所有承重结论有 file:line 证据；SSOT 反转与 installer/release-verify/消费者必须**同批**改（分票会自相矛盾）。

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS（本 lock + §8）。

---

## 1. Task Overview

### 1.1 真正的问题
TAD 的核心资产（两角色协议、四关、handoff、skill 库）绝大多数字节与 Claude 无关，但**物理住在 `.claude/`、并由 Claude Code 作为主平台驱动**。所以「移除 Claude」不能只删 `.claude/`——那等于删 skill 源。正确顺序是：

> **先把 skill 源反转到 `.agents/skills/`（§4），再把 `.claude/` 整棵删除（§3.A）。**

### 1.2 目标架构（before → after）

| 维度 | Before (v2.44.6) | After（本方案落地后） |
|------|------------------|----------------------|
| skill 唯一源 | `.claude/skills/`（`.agents/skills` 是派生镜像） | **`.agents/skills/`（唯一源，无镜像）** |
| install target | `claude-code` / `codex` / `both`，默认 `both` | **`codex`**（默认；矩阵只此一项；`claude-code` **与 `both`** = tombstone 报错，fail-before-mutation + 恢复命令） |
| hooks | `.claude/settings.json`（Claude 独有）+ `.codex/hooks.json` | **只 `.codex/hooks.json`（保留）** |
| workflows 运行时 | `.claude/workflows/*.workflow.js`（10 个） | **删除**（accepted limitation：Codex 无 worklow 等价物，见 §3.A.3） |
| Gate 3 审查模型 | `.claude/agents/*.md` pin opus/sonnet + haiku prompt hook | **去 pin**；审查走 harness 原生子代理（§3.F） |
| 命名标签 | `claude_websearch` / `claude_code_reviewer` | **`websearch` / `code_reviewer`**（§3.E） |
| 文档门面 | "two first-class runtimes: Claude Code and Codex" | **Codex-first，多 harness 中立**（§3.H/§3.J） |

### 1.3 明确不做（non-goals）
- ❌ **不分两版**：不做 2.45.0（deprecate）过渡版，直接 **v3.0.0** 删除（§6.1）。
- ❌ 不在本批把 **OpenCode 升为一等 install target**（§7；后续独立项，不在本移除批次）。
- ❌ 不把 TAD 做成 OpenCode 独占；目标是**中立 + 可扩展**。
- ❌ 不重写历史记录（CHANGELOG 旧条目 / evidence / archive / memory / `.tad/migrations/*.yaml` 历史 manifest）里的 `.claude/` 字面。
- ❌ **不生成任何删除下游 `.claude/**` 的新 migration manifest**（Codex 约束 1）；历史 manifest 仍可只读解析（§3.L）。
- ❌ 不在 `deprecation.yaml` 登记删除**下游** `.claude/skills`（见 §6.4 SAFETY：保持「不在升级时删用户树」的既有保证；Codex 约束 5）。
- ❌ 不删除 `.agents/skills/ai-prompt-engineering/**` 与 `.agents/skills/ai-evaluation/**` 里关于 Claude **模型**的领域知识（那是 capability pack 内容，不是绑定——design §2.B 明示保留）。
- ❌ 绝不自动递归删除下游 `.claude/`（含用户 hooks / MCP / 权限配置）；`.claude/` 的新旧处置全部是「保留、不动」（§3.L；Codex 约束 5）。

---

## 2. 审计基线（已核，HEAD `c32bde27` v2.44.6）

| 事实 | 证据 | 对本方案意义 |
|------|------|-------------|
| `.claude/skills` 与 `.agents/skills` **逐字节相同** | `diff -rq -x local .claude/skills .agents/skills` → 空；两边各 555 tracked 文件（`.claude` 多 `local/`，gitignored） | SSOT 反转**零内容风险**：直接以 `.agents/skills` 为源，删除 `.claude/skills` 不丢内容 |
| 安装器源路径固定 Claude | `tad.sh:1162-1164`（始终读 `$src/.claude/skills/*/`）、`tad.sh:2488-2493`（target 选择）、`tad.sh:1281-1318`（`both` 次级 copy） | §3.B 必须改读 `.agents/skills`；§4.1 |
| 平台矩阵 / 默认 | `tad.sh:514 KNOWN_PLATFORMS="claude-code codex both"`；`tad.sh:533` 默认 `both`；`bin/tad-install.mjs:153` 默认 `both`；`.tad/platform-codes.yaml:6-11` | §3.C |
| release-verify 源方向固定 | `.tad/hooks/lib/release-verify.sh:102-104`（"`.claude/skills` as the SOLE source of truth, direction FIXED Claude→Codex"）；`:564-570`；`platform-skills` `:913-1021` | §4.2/§4.3 |
| 标签无运行时读者 | `claude_websearch` 只在 `.tad/config-workflow.yaml:791` + 文档；`claude_code_reviewer` 全仓仅 `:796` | §3.E 改名 blast radius 极低 |
| 真模型绑定 ≥6 类 | `.claude/agents/*.md:4`、`.claude/settings.json:36`、`.claude/workflows/*.js`、`.tad/config-agents.yaml:326`、`.tad/scripts/yolo-harness-profiles.json:18-35`、`.tad/scripts/phase2-pair-driver.mjs:39,773,775,797` | §3.F/§3.G |
| `teammate_model` / `fallback_chains` **无代码读者** | 全仓 grep：仅 config 自述 + 文档 | §3.E/§3.F 改配置即可 |
| 双写恰好 6 源 × 2 镜像 = 12 文件 | `<!-- Claude Code: … / Codex: … -->` 命中 §3.H 表 | §3.H；`.claude` 侧随整树删除，实际改 6 个 `.agents` 源 |
| **升级不删下游 `.claude`（现状）** | `deprecation.yaml` 不列 `.claude/skills`；`tad.sh:1154-1157` 平台切换显式保留旧树 | §3.L/§6.4 保持该保证（Codex 约束 5） |
| **migration-draft 会把 `.claude/**` 批量删列入新 manifest** | `.tad/hooks/lib/migration-draft.sh:94` 的 `git diff ... -- .tad/ .claude/ ...`；若为 2.44.6→3.0.0 生成，会命中 ~571 条 `.claude/**` delete | **Codex 约束 1 的核心危险**：v3 必须把 `.claude/` 移出 draft scope，且不提交 3.0.0 删除 manifest（§3.L） |
| **migration-engine 历史 manifest 仍含 `.claude` 路径，须可只读解析** | `.tad/hooks/lib/migration-engine.sh:72` allow-list 含 `.claude/*`；`.tad/migrations/2.26.0-to-2.27.0.yaml:6-25` 与 `2.42.0-to-2.43.0.yaml:21-33` **删具体 `.claude/skills/**` 文件** | 引擎 allow-list **保留** `.claude/*`；只清 draft 生成面（§3.L；修正 §3.I7 原表述）。**`→3.0.0` 链本身是 gap（无 2.44.6 manifest）→ 实际不执行任何迁移删除**；切勿「补 gap」生成删除 manifest |
| **`call_migration_engine` 对 chain gap 是 WARN、非致命** | `tad.sh:1565-1577`（rc=2 → warn "consider a clean reinstall"，继续 copy）| 「不新增 3.0.0 manifest」= 保持既有 gap 行为，升级仍完成 |
| **旧 2.44.6 updater 检测 `both` 后自动透传 `--platform both`** | `.tad/scripts/tad-update.sh:119-132 detect_platform` → `:280 bash "$tmp_file" ... --platform "$platform"`；默认 both 安装同时有 `.claude/skills/alex` + `.agents/skills/alex` | **Codex 约束 2**：v3 收到 `both`/`claude-code` 必须 fail-before-mutation + 给恢复命令（§3.M / S2） |
| **平台校验早于快照与首个 mutation** | `tad.sh:528-536 resolve_platform`（Phase 3）在 `tad.sh:2485` 调用；`take_rollback_snapshot` 在 `:2702`、`NEED_ROLLBACK=1` 在 `:2698` | tombstone 放在 `validate_platform` 即天然 fail-before-mutation（§3.M 的 AC 即验证此序） |
| **runtime freshness 硬依赖 claude ledger** | `.tad/hooks/lib/runtime-freshness-verify.sh:12,32-36,169` 缺 `.tad/runtime-compat/claude-code.md` 即 exit 2 | **Codex 约束 3（runtime freshness）**：作为 SSOT/移除消费者显式登记（§4.4），并决定 ledger 保留策略（§3.J6） |
| **pack 验证器数据文件含 `.claude/skills` 锚点** | `.tad/capability-packs/pack-collisions.yaml:33,37,57,61,78,83`（`ref: ".claude/skills/..."`）、`.tad/scripts/collision-signatures.txt:16,20`、`.tad/capability-packs/behavioral-eval-status.yaml:20` | **Codex 约束 3（pack 验证器）**：随 S6 一并 repoint，否则碰撞扫描锚点全部失效（§3.I19） |
| **pair-driver 真 spawn `claude`** | `.tad/scripts/phase2-pair-driver.mjs:773 useClaude`、`:775 ['-p','--output-format','json','--model', TAD_JUDGE_MODEL \|\| 'sonnet']`、`:797 harness:'claude'`、`:39-40 JUDGE_MODEL_FAMILY 默认 'claude'` | **Codex 约束 4**：纳入硬零残留 AC（V-P1 / AC16） |
| 下游 `.claude/` 可能含用户资产 | `.claude/settings.json`（hooks）、`settings.local.json`、用户 MCP/权限配置、自定义 commands | **Codex 约束 5**：绝不递归删除；升级安全 fixture 断言字节不变（§3.L / AC17） |
| OpenCode 现状 = updater-only | `.opencode/commands/tad-update.md`；无 skill 加载契约 | §7（后续独立项） |

---

## 3. 移除清单（逐文件 / 逐配置）

> 记号：**[D]**=删除；**[M]**=修改；**[K]**=保留（不动或仅加 deprecated 说明）。每项附 file:line 与所属步骤（§6.2）。

### 3.0 前置：SSOT 反转（必做，先于删除）
SSOT 反转本身的详细设计在 **§4**；此处只列 `.claude/` 的最终处置。

### 3.A `.claude/` 整套 [D]（步骤 S7）

| # | 路径 | 说明 |
|---|------|------|
| A1 | `.claude/skills/**`（555 tracked） | skill 源已反转到 `.agents/skills`（§4.1）→ 整棵删除 |
| A2 | `.claude/settings.json` | 7 条 hook 注册（PreCompact/SessionStart/PreToolUse×3/PostToolUse×2）+ haiku prompt hook（`:36`）→ 删除 |
| A3 | `.claude/workflows/*.workflow.js`（10 个，~150KB） | Claude-only 运行时；Codex 无等价物。**accepted limitation**（design §8.3）：删除后 `detect-platform` 的 `workflow` 后端消失（§3.C.4）。若人后续要保留编排能力，另立 port 任务。 |
| A4 | `.claude/agents/security-auditor.md`、`spec-compliance-reviewer.md` | Gate 3 审查 agent 定义（含 `model: opus/sonnet`）；随树删除；替代=harness 原生子代理（§3.F） |
| A5 | `.claude/rules/shell-portability.md` | 是 `.tad/project-knowledge/patterns/shell-portability.md` 的 thin excerpt 镜像；删除（源仍在） |
| A6 | `.claude/commands/README.md` | stub（v2.8.1 已把 commands 合并进 skills）→ 删除 |
| A7 | `.claude/settings.json.v2-backup` | 遗留备份 → 删除 |
| A8 | `.claude/projects/**`、`.claude/settings.local.json`、`.claude/worktrees/**` | machine-local（gitignored，不在 repo 删除范围）；但 `memory-redirect.sh` 不再写 `.claude/settings.local.json`（§3.I） |
| A9 | `CLAUDE.md`（根，129 行） | Claude Code 路由文件 → 删除（中立路由是 `AGENTS.md`） |
| A10 | `research/CLAUDE.md` | 嵌套 Claude 路由 → **重命名 `research/AGENTS.md`**（保留内容，§3.J） |

> **SAFETY**：`tad.sh` 的 rollback 快照/恢复逻辑直接引用 `.claude/settings.json` / `.claude/workflows` / `.claude/skills`（§3.B.5），删除这些路径必须**同批**清理，否则 `snap_one` 会报错或 `restore` 逻辑悬空。

### 3.B `tad.sh` 安装器 [M]（步骤 S1–S3，按子项）

| # | file:line | 改动 |
|---|-----------|------|
| B1 | `tad.sh:1162-1208` | skill 拷贝主循环：`$src/.claude/skills/*/` → **`$src/.agents/skills/*/`**；deny 匹配源路径同步改 |
| B2 | `tad.sh:1209-1229` | `.claude/settings.json` + `.claude/workflows` 拷贝块 → **删除**（`codex` 平台本就有 `extra_deny`，现在整块无对象） |
| B3 | `tad.sh:1278-1318` | `both` 平台次级 Codex copy 块 → **删除**（不再有双树） |
| B4 | `tad.sh:1320-1337` | pack meta 生成：源 `$src/.claude/skills/$sn` → **`$src/.agents/skills/$sn`**；`meta_targets` 恒为 `$TARGET_SKILL_DIR` |
| B5 | `tad.sh:2488-2493` | `TARGET_SKILL_DIR`：恒 **`.agents/skills`**（删除 `codex`/else 分支） |
| B6 | `tad.sh:1153-1158` | 平台切换 remnant 警告 → **删除**（无他平台可切） |
| B7 | `tad.sh:1485-1512` | `verify_install_complete` skills 段：源改 `$src/.agents/skills`；目标恒 `.agents/skills`；删除 `"$PLATFORM" = "both"` 次级校验 |
| B8 | `tad.sh:1868-1878` | rollback：`ROLLBACK_PRE_TOP` 去掉 `.claude`；删除 `snap_one ".claude/settings.json"` / `".claude/workflows"` / `".claude/skills"`；保留 `.agents/skills`、`.codex/hooks.json`、`AGENTS.md`；删除 `snap_one "CLAUDE.md"` |
| B9 | `tad.sh:1871` | `snap_one "CLAUDE.md"` → 删除（S7 删文件后无对象） |
| B10 | `tad.sh:2064` | `rmdir "$TARGET_ROOT/.claude/skills"` → **删除**（rollback 站点消失；同时注意 installer-destructive-guard 的 `# RM-OK:` 计数——删站点安全，加站点才需 marker） |
| B11 | `tad.sh:811-818`（`resolve_pack_dir`） | 顺序反转：优先 `.agents/skills/$name`；错误消息同步；`fork/unfork` 错误文案（`:827,852`）改 |
| B12 | `tad.sh:872-874`（pack list） | `skill_base=".claude/skills"` → `.agents/skills`；报错文案同步 |
| B13 | `tad.sh:514,533-535,366` | `KNOWN_PLATFORMS="codex"`；默认 `codex`；usage 文案 `(codex)`；`claude-code` tombstone（§3.C.2） |
| B14 | `tad.sh:619-668` | `parse_platform_extra_deny/root_files` 保留（矩阵收敛后仍通用） |
| B15 | `tad.sh:1403-1404,2441-2457` | `project_opencode_command` **保留**（updater-only，中立机制） |
| B16 | 注释/prose 中的 `.claude/` 字面（44 处） | 逐条中性化（源引用、rollback 注释、self-check 注释） |

### 3.C 平台矩阵 & 默认 [M]（步骤 S2）

| # | 路径 | 改动 |
|---|------|------|
| C1 | `.tad/platform-codes.yaml:6-18` | `platforms:` 只留 **`codex`**（label `Codex CLI`，`extra_deny: []`，`extra_root_files: [AGENTS.md]`）；删除 `claude-code` 与 `both` 两个 key |
| C2 | `tad.sh:514,528-536,333-335` | 见 B13。`--platform claude-code` **与 `--platform both`** → **硬报错（tombstone）**，文案含迁移指引，**不静默回落、不静默映射**。校验位于 `validate_platform`（Phase 3，`main():2485`），早于 `take_rollback_snapshot`（`:2702`）→ 天然 **fail-before-mutation**（§3.M） |
| C3 | `bin/tad-install.mjs:128,153` | usage/默认：`claude-code, codex, both` → `codex`（默认 `codex`）；platforms 列表从 `platform-codes.yaml` 动态读（`:10-33`，自动只含 codex） |
| C4 | `.tad/hooks/lib/detect-platform.sh:22-38` | 删除 `workflow`（`.claude/workflows` 信号）分支；保留 `codex` / `none`；更新头部注释 |
| C5 | `.tad/scripts/tad-update.sh:116-129,248` | `detect_platform`：删除 `claude-code` / `both` 分支；只认 `.agents/skills/alex`；错误文案更新 |
| C6 | `AGENTS.md:148` | `TAD_PLATFORM=workflow\|codex\|none` → **`TAD_PLATFORM=codex\|none`** |
| C7 | `.tad/scripts/tad-update.sh:41,47-49,78-81,119-132,248-249` | 见 C5。usage 与 `--platform` 校验值收为 `codex`；v3 的 `detect_platform` 只要 `.agents/skills/alex` 存在即判 `codex`（即使 `.claude/skills/alex` 仍在）→ **v3 自带 updater 永不发送 `both`**。真正会发送 `both` 的是**旧 2.44.6 updater（本版无法改写）** → 由 v3 `tad.sh` tombstone 兜底，恢复命令见 §3.M |

**是否保留 `claude-code` legacy 别名：不保留（推荐）。理由**：
1. 别名必须安装 `.claude/skills` + `.claude/settings.json` + workflows——而这些资产本批**全部删除**。保留别名 = 保留一个指向已删资产的假 target（安装出来是坏的）。
2. 保留别名就必须保留双树 copy 方向（§3.B.1/B.3），**直接抵消 SSOT 反转的收益**，并让 parity 无法退休（§4.3）。
3. 现有用户不会因移除别名而丢文件：升级**不删**其 `.claude/`（§2 已核），只是不能从新版本重装 `.claude`。这正是「彻底移除」的应有语义。
4. 正确做法是 **tombstone**：`--platform claude-code` 明确失败 + 一行迁移指引（fail-closed），而不是静默跳过或回落到 codex。

### 3.D `.codex/hooks.json` — **[K] 保留（Codex 机制保留）**
- `.codex/hooks.json`（repo 内 1 个 tracked 文件；`git ls-files .codex/` = 仅此）是**保留下来的机制**，不动内容。
- 生成逻辑 `tad.sh:1355-1393` 保留；矩阵收敛后条件 `PLATFORM = codex || both` 简化为 `PLATFORM = codex`（恒真），但保留显式判断以便未来加 target。
- `SessionStart` matcher `startup|resume|compact`、`PostToolUse ^apply_patch$`、`^ask_user_question$` 均与 Claude 无关，保留。

### 3.E 标签改名 [M]（步骤 S4）

| # | 旧 → 新 | 位置 |
|---|---------|------|
| E1 | `claude_websearch` → **`websearch`** | `.tad/config-workflow.yaml:791`（`fallback_chains.research.secondary`）+ 注释 `:779,786`；`.tad/cross-model/capabilities.yaml:31,84,99,114,129`（`replaced_by`）+ 头注释 `:2` |
| E2 | `claude_code_reviewer` → **`code_reviewer`** | `.tad/config-workflow.yaml:796`（`code_review.primary`）；**补 `secondary`**（当前缺失，design §3.D4） |
| E3 | 补 `capabilities.yaml` 目录项 | `websearch`（=harness 原生 WebSearch/WebFetch）；`code_reviewer`（=harness 原生 code reviewer 子代理，Codex 草案 `gpt-5.5` 已存在） |
| E4 | SKILL/文档中的 `claude_websearch` 字面 | `.agents/skills/alex/SKILL.md`(L289,393,471,679,689,709,759,764,777,782,822,828)、`alex/references/{research-track-protocol.md:5,research-plan-protocol.md:24,104,106,adaptive-complexity-protocol.md:175,discuss-path-protocol.md:102}`、`.agents/skills/blake/SKILL.md`(L634,687,1086)、`blake/references/notebooklm-access.md:3`、`research-notebook/SKILL.md:7`、`.tad/guides/tool-quick-reference-{alex:6,10,blake:64}.md`、`.tad/project-knowledge/patterns/research-methodology.md:56`、`.tad/research-notebooks/REGISTRY.yaml:2`、`.tad/hooks/lib/notebook-lifecycle.sh:4`、`.tad/hooks/notebook-dormant-sync.sh:4`、`.tad/cross-model/setup-notebooklm.sh:13`、`research/CLAUDE.md:41`→(A10 后为 `research/AGENTS.md`)、`README.md:5` |

> ⚠️ **CHANGELOG.md 的 2.44.6 历史条目（L13,14,29）不改**（历史记录，§MQ Out）。
> ⚠️ 改名后 `capabilities.yaml` 头部「notebooklm_* 保留历史」注释里 `replaced_by` 目标同步改，但 notebooklm 条目本身保留。

### 3.F 模型 pin 去除 [M]（步骤 S4）

| # | 绑定 | 处置 |
|---|------|------|
| F1 | `.claude/agents/security-auditor.md:4 model: opus` | 随 `.claude/` 删除（A4） |
| F2 | `.claude/agents/spec-compliance-reviewer.md:4 model: sonnet` | 随 `.claude/` 删除（A4） |
| F3 | `.claude/settings.json:36 model: claude-haiku-4-5-20251001`（PreToolUse Write\|Edit，`type: prompt`，策略全 ALLOW）| 随 `.claude/settings.json` 删除（A2）。这是**唯一运行时真调 Claude 的 hook**，删除即消除 |
| F4 | `.claude/workflows/*.js` 内 `model:'sonnet'/'haiku'`（epic-audit/gate-review/loop-discover/surplus-scan/pack-upgrade）| 随 `.claude/workflows` 删除（A3） |
| F5 | `.tad/config-agents.yaml:326 teammate_model: "sonnet"` | 去 Claude 值。**无代码读者**（已核）→ 改为 harness 中立：`teammate_model: "inherit"`（或 `capability-tier: mid`）。**不引入新 key**（避免 schema 漂移）；`lead_model: "inherit"` 保留 |
| F6 | `.tad/eval/judge/README.md:5`（"model: sonnet — 校准绑定档位"）| 中性化为「strong-tier / harness 同档」措辞 |
| F7 | `.tad/references/openharness-architecture.md:706 model="claude-sonnet-4-20250514"` | 设计参考示例；中性化或保留（低优先，可留待后续） |
| F8 | `.tad/evidence/designs/codex-runtime-candidates/agents/*.toml.draft`（`gpt-5.5`/`gpt-5.4-mini`）| **draft-only，不激活**（`.tad/codex/README.md` 明示）；本批不动，但注意它们是「per-harness model map」的现成落点 |

### 3.G YOLO harness `claude` spawn [M]（步骤 S5）

| # | 路径 | 改动 |
|---|------|------|
| G1 | `.tad/scripts/yolo-harness-profiles.json:18-35` | 删除 `claude-code` profile（`runtime:"claude"`, `provider:"anthropic"`, `executable:"claude"`, `model:"claude-sonnet-4-20250514"`）；保留 `codex` / `opencode` / `opencode-deepseek` |
| G2 | `.tad/scripts/yolo-harness-runner.test.mjs:187,301,522,619,647-648` | 断言从「4 honest identities（含 claude-code）」→ 3；profile 列表与文件清单同步 |
| G3 | `.tad/scripts/phase2-pair-driver.mjs:39-40,773-778,797` | **删除 `useClaude` 分支与 `harness:'claude'`**；删除 `claude -p --output-format json --model ${TAD_JUDGE_MODEL \|\| sonnet} --permission-mode plan ...` 整条调用；`JUDGE_MODEL_FAMILY` 默认 `'claude'` → `'opencode'`（或缺失即报错，不静默回落 Claude）；judge 恒走 opencode 命令 |
| G4 | `.tad/scripts/yolo-recovery.mjs:2387` | `forbidden_scope` 内 `.claude/` → `.agents/` |
| G5 | `.tad/scripts/yolo-recovery.test.mjs:115,636,2669`、`yolo-round.test.mjs:99,483`、`yolo-harness-runner.test.mjs:490,574` | 测试 fixture 的 `.claude/` 作用域 → `.agents/`（否则测试红） |
| G6 | `.tad/scripts/phase2-pair-driver.mjs.bak`（worktree 内未跟踪） | 删除本地 `.bak`（含 `useClaude` 旧体）；**不得 commit**。零残留 grep 会命中它 → 加入 V-P1 扫描或先移除 |
| G7 | `.tad/scripts/yolo-harness-profiles.json`（整文件） | **硬性零残留 AC**：`! grep -n "claude" .tad/scripts/yolo-harness-profiles.json`（Codex 约束 4；见 V-P1 / AC16） |

> ⚠️ 这些是**实验/判定路径**，不是产品路径；但留红测试 = 污染质量信号，必须同步改。**Codex 约束 4 明确把 pair-driver `claude -p` 与 YOLO profile 纳入硬零残留 AC**——不是「低优先实验面」。

### 3.H 12 双写文件中性化 [M]（步骤 S8）

设计 doc 计数「6 源 × 2 镜像 = 12 文件」。删除 `.claude/skills` 后，实际只需改 **6 个 `.agents` 源文件**（`.claude` 侧随树消失）：

| # | 源文件（`.agents/skills/…`） | 行 | 现文 → 中性文 |
|---|------------------------------|----|--------------|
| H1 | `alex/SKILL.md` | 40 | `<!-- Claude Code: Skill tool / Codex: $skill-name or /skills -->` → `<!-- Platform binding: harness skill invocation (\`$skill-name\` / \`/skills\`) -->` |
| H2 | `alex/SKILL.md` | 231 | `<!-- Claude Code: AskUserQuestion / Codex: numbered-options text（见平台绑定交互决策条款） -->` → `<!-- Platform binding: interactive-decision tool or numbered-options text（见平台绑定交互决策条款） -->` |
| H3 | `alex/SKILL.md` | 387 | `<!-- Claude Code: Agent tool / Codex: subagent spawn -->` → `<!-- Platform binding: subagent spawn -->` |
| H4 | `blake/SKILL.md` | 46 | 同 H1 文案 |
| H5 | `blake/SKILL.md` | 200 | 同 H2 文案 |
| H6 | `blake/SKILL.md` | 772 | `<!-- Claude Code: .claude/settings.json hooks / Codex: .codex/hooks.json -->` → `<!-- Platform binding: harness hook config (\`.codex/hooks.json\`) -->` |
| H7 | `alex/references/handoff-creation-protocol.md` | 530 | 同 H6 文案 |
| H8 | `alex/references/idea-path-protocol.md` | 48 | 同 H2 文案 |
| H9 | `alex/references/bug-path-protocol.md` | 35 | 同 H2 文案 |
| H10 | `alex/references/learn-path-protocol.md` | 38 | 同 H2 文案 |

> 其余含 `Claude Code` 的 skill 内容（`ai-agent-architecture/references/context-compression.md:22`、`tool-management.md:28`；`video-creation/.../ai-asset-generation.md:382,664`；`agent-skill-evolution/.../skillopt-sleep-integration.md:14`；`ai-prompt-engineering/**`）是**领域知识/来源标注**，**不是双写绑定**，保留。
>
> > **Gate 3 裁决保留清单 R2（RETENTION，零代码改动；裁决 `.tad/evidence/reviews/2026-09-15-gate3-adjudication-claude-removal.md` §1）**：
> > - **R2-1** `.agents/skills/agent-computer-interface/SKILL.md:110,115,116,118,145,147` — `Claude in Chrome` 是真产品、`claude-code-tools-rules.md` 是真引用文件（路由表），补入本 §3.H 领域知识例外；V-P1 首条排除该 pack。
> > - **R2-2/R2-3** `.agents/skills/alex/references/deps-protocol.md:132`、`dependency-ops/SKILL.md:67` — `claude-code-cli` 是 `.tad/dependencies/REGISTRY.yaml:171` 真实登记依赖专名，保留；V-P1 首条排除这两个文件路径。
> > - **R2-4** `.tad/capability-packs/ai-agent-architecture/CHANGELOG.md:24` — pack 历史变更记录，§3.K 历史面，保留；V-P1 首条排除 `CHANGELOG.md`。
> > 保留成立强依赖 §6.3 命令同步（字面判据改准），不得"解释通过"。

### 3.I `.claude/skills` → `.agents/skills` 路径改写消费者 [M]（步骤 S6）

| # | 路径 | 改动 |
|---|------|------|
| I1 | `.tad/hooks/lib/skill-body-verify.sh:7,68,84,88,90,116,117,208,222,231` | `DEFAULT_SKILL`/`BLAKE_REFS`/`DEFAULT_ALEX_SKILL`/`DEFAULT_ALEX_REFS` → `.agents/skills/...`；mirror 对比改为「源=`.agents`，删除 `.claude` 对比」 |
| I2 | `.tad/hooks/lib/brain-index-gen.sh:238-239` | `SKILLS_DIR` → `.agents/skills` |
| I3 | `.tad/hooks/lib/pack-registry-driftcheck.sh:28,98` | `SKILLS_DIR` → `.agents/skills`；WARN 文案 |
| I4 | `.tad/hooks/lib/memory-redirect.sh:11,15,29,32` | 删除 `.claude/settings.local.json` + `~/.claude/projects/<slug>/memory` 重定向（Claude-only）；`mkdir -p .claude` → 去掉。**这是 Claude 独有记忆层，随移除一并下线** |
| I5 | `.tad/hooks/lib/drift-check.sh:165` | ALLOWLIST_REGEX 内 `.claude/skills/` → `.agents/skills/` |
| I6 | `.tad/hooks/lib/knowledge-blame.sh:20-21` | 同上 |
| I7 | `.tad/hooks/lib/migration-draft.sh:94`（**改**）；`.tad/hooks/lib/migration-engine.sh:72`（**保住不改**）| **约束 1 修正**：把 `.claude/`、`CLAUDE.md` 移出 `migration-draft.sh` 的 diff scope（`-- .tad/ .codex/ .agents/ AGENTS.md tad.sh`）；**引擎 `validate_path` 的 `.claude/*` allow-list 必须保留**，否则历史 manifest（`2.26.0-to-2.27.0.yaml` / `2.42.0-to-2.43.0.yaml` 删具体 `.claude/skills/**`）会被 REJECT、历史回放断裂。详见 §3.L |
| I8 | `.tad/hooks/lib/verify-ac-commands.sh:17`、`friction-status-check.sh:20` | 注释/prose 里的 `.claude/settings.json` → `.codex/hooks.json` |
| I9 | `.tad/scripts/capability-skill.sh:26,39,113,117,291,292,406,424` | **authority=`.agents/skills`（已如此）**；删除 projection 到 `.claude/skills`（`project` 子命令改为 tombstone 或移除）；symlink 检查与 parent 创建同步。（**Codex 约束 3 点名项**） |
| I10 | `.tad/scripts/pack-eval-runner.sh:211,578,594,617,623` | fixtures `.claude/skills/*/examples/*.md` → `.agents/skills/...` |
| I11 | `.tad/scripts/scan-collisions.sh:19,35` | `SKILLS_DIR="$REPO_ROOT/.claude/skills"` → `.agents/skills`；prose |
| I12 | `.tad/capability-packs/*/install.sh`（**26 个**，各 ~7 处）| 安装目标 `.claude/skills/${PACK}` / `$HOME/.claude/skills/...` → **`.agents/skills/${PACK}` / `$HOME/.agents/skills/...`**；「Claude Code not found (.claude/…)」检测文案 → `.agents/`。（**Codex 约束 3：capability-pack installers**） |
| I13 | `.tad/templates/capability-pack-template/install.sh:30-41` | 同上（模板，影响未来 pack） |
| I14 | `.tad/templates/skillify-candidate-template.md:7-8`、`session-state-template.md:9`、`acceptance-verification-guide.md:166,192`、`completion-report.md:126,128`、`deliverable-handoff.md:21` | `.claude/skills/...` → `.agents/skills/...`；`.claude/workflows/...` → 删除或改注「workflow 运行时已移除」 |
| I15 | `.tad/tests/detect-state-fixture.sh:99-152` | PARTIAL sentinel `.claude/commands` → 改用 `.agents/skills` 或 `.tad` 变体（保持 FRESH/PARTIAL 语义） |
| I16 | `.tad/tests/tad-update-fixture.sh`（多处）、`gate-exercise.sh:100-150`、`migration-fixtures/*.sh` | fixture 内 `.claude/skills` / `.claude/commands` → `.agents/skills`（或明确标注「历史 fixture，验证 v2.x 迁移」时保留，见 §3.K） |
| I17 | `tad:85-86`（根 v1.4 CLI）| `.claude/commands` 计数 → `.agents/skills` 计数（或标注 legacy 不维护） |
| I18 | `.tad/hooks/lib/runtime-freshness-verify.sh:12,32-36,169` | **Codex 约束 3（runtime freshness）**：claude ledger 消费点。J6 保留 `claude-code.md`（标 DEPRECATED/RETIRED）时，verifier 改为「缺 ledger 或 header 标 `RETIRED` 时跳过、不 exit 2」；否则移除 Claude 面后该门会永久 wiring BLOCK。release-sync-adjacent verifier 改动 → 走 §6.4 SAFETY |
| I19 | `.tad/capability-packs/pack-collisions.yaml:15-17,33,37,57,61,78,83`、`.tad/scripts/collision-signatures.txt:16,20`、`.tad/capability-packs/behavioral-eval-status.yaml:20`、`.tad/capability-packs/{academic-research,product-thinking,web-backend,web-ui-design}/README.md`、`web-ui-design/CAPABILITY.md:1180,1184`、`web-ui-design/SKILL.md:1180,1184` | **Codex 约束 3（pack 验证器）**：`.claude/skills` → `.agents/skills`。`pack-collisions.yaml` 的 `ref:` 是**碰撞扫描锚点**——不改则扫描指向已删路径、静默失效 |
| I20 | `.tad/hooks/lib/parity-criterion.md:85,97` | parity 退休（V6）后本文件成孤儿：**标 `ARCHIVED` 或随 S3 删除**，与 release-verify parity 段同批 |

### 3.J 公共文档 / 门面 [M]（步骤 S8）

| # | 路径 | 改动 |
|---|------|------|
| J1 | `README.md` | 安装段：`--platform both` 推荐 → 默认 `codex`；删除「Claude Code 一等平台」叙述；`:5` release blurb 的 `claude_websearch` → `websearch`（发布新版本时） |
| J2 | `INSTALLATION_GUIDE.md` | `--platform` 取值表、安装示例、卸载说明（Claude 面） |
| J3 | `docs/MULTI-PLATFORM.md` | 标题/Status 表/Runtime Model 图重写为 **Codex-first + 可扩展多 harness**；删除 "two first-class runtimes: Claude Code and Codex"；`Claude Code Adapter` 列改为「(removed in v3.0.0)」或删除 |
| J4 | `docs/CODEX-USER-GUIDE.md`、`docs/codex-guide.html` | 平台叙述同步 |
| J5 | `.tad/guides/hooks-platform-mapping.md` | 改为 **harness hook mapping**；「Claude Code → Codex」列标注历史/源已移除 |
| J6 | `.tad/runtime-compat/claude-code.md` | **加 DEPRECATED 头 + 保留**（它本就是「某 target 的台账」；记录移除缘由，符合 retire-not-delete）；不删 |
| J7 | `.tad/runtime-compat/codex.md:34` | 删除「`.claude` remains source of truth」→「`.agents/skills` is the sole source」 |
| J8 | `.tad/README.md:22`、`.tad/codex/README.md`（多处）| 目录说明/「same content as `.claude/…`」→ `.agents/skills` 单一源叙述 |
| J9 | `AGENTS.md`（根，中立路由）| 删除 "Both platforms (Claude Code and Codex)"（:29）、"Claude's @import is…"（:48）、"platform-equivalent of CLAUDE.md §…"（:53）、"Claude's native capture layer"（:74）；`:148` 见 C6 |
| J10 | `PROJECT_CONTEXT.md`、`NEXT.md` | 更新 live 状态里的 `.claude/skills` 路径引用（历史 EPIC 叙述保留） |
| J11 | `.tad/config-workflow.yaml` 头部/注释 | 移除 Claude 平台绑定表述 |

### 3.K 低优先 / 历史面 & 明确不动

**必须改（live，但可后置到 S6/S8 尾）**：
- `.tad/skills-config.yaml:12,22,27,96,393`、`.tad/manifest.yaml:87`（v1.4 legacy skills 元数据）→ 若仍被读取则 repoint `.agents/skills`；若判定已死（无消费者）→ 标注 `ARCHIVED` 或删除（**Blake 需先 grep 消费者**：目前消费者仅 `experiments/thin-tad-pilot/pilot.mjs` 与 archive docs → 建议标注 legacy，不阻塞）。
- `.tad/discipline-floor.md` / `discipline-floor-budget.md`（18+ 处 `.claude/skills`）→ 活承重台账；repoint `.agents/skills`，但**不要动引用的历史文本语义**（行号锚点会漂移 → 需重新摘录）。
- `.tad/agents/agent-a-architect.md:122,130,139,213`、`agent-b-executor.md:123,131,140,149,237`、`.tad/skills/{code-review,testing}/SKILL.md`（v1.4 legacy 角色定义）→ repoint 或标注 `ARCHIVED`。
- `.tad/portable-rules.md:9,16`（可移植规则描述「Settings `.claude/settings.json` CC-only」）→ 更新为已移除。

**明确不动（历史/权威记录，`.claude/` 字面允许残留）**：
- `CHANGELOG.md` 旧条目（含 2.44.6 及以前）；`.tad/evidence/**`；`.tad/archive/**`；`docs/archive/**`；`docs/legacy/**`；`docs/releases/**`；`tad-work/archive/**`；`scripts/archive/**`；`.tad/memory/**`；`.tad/migrations/*.yaml`；`.tad/eval/judge/bundles/**`；`.tad/active/**`（历史 handoff/epic/design/idea）；`.tad/project-knowledge/**` 的 Discovery/Grounded-in 文本；`.tad/spike-v3/**`；`.worktrees/**`（gitignored）。
- **领域知识例外（必须保留）**：`.agents/skills/ai-prompt-engineering/**`（含 `references/claude.md`）、`.agents/skills/ai-evaluation/**`（含 `anthropic:claude-sonnet` 示例）——design §2.B 明示「是领域知识，不是绑定」。**Gate 3 裁决追加（R2-1）**：`.agents/skills/agent-computer-interface/**`（`Claude in Chrome` 真产品 + `references/claude-code-tools-rules.md` 真引用文件的路由表）同类保留。
- **依赖专名例外（必须保留，R2-2/R2-3）**：`.agents/skills/alex/references/deps-protocol.md:132`、`.agents/skills/dependency-ops/SKILL.md:67` 的 `claude-code-cli` 是 `.tad/dependencies/REGISTRY.yaml:171` 真实登记项名，改写会与 registry 脱钩，保留。
- **pack 历史块例外（必须保留，R2-4）**：`.tad/capability-packs/**/CHANGELOG.md` 历史条目（含 `ai-agent-architecture/CHANGELOG.md:24 --agent=claude-code`）只读，改写历史 = 伪造变更史，保留。
- **历史/安全 fixture 例外（必须保留，I16 扩展，Gate 4 §7.3）**：`.tad/tests/migration-fixtures/{run-fixtures.sh,test-15-dual-caller-integration.sh}`（v2.27→v2.28 迁移回放语义）、`.tad/tests/tad-update-fixture.sh`（v2.43.1 updater 回归，预置用户 `.claude/` 树）、`.tad/tests/installer-data-safety-fixture.sh:509-512,926-927`（预置用户 `.claude/` 以断言 AC12/AC17 字节不变）内的 `.claude/` 字面为**故意保留**；V-P1 第二条以**文件名** carve-out，不得编辑 fixture 消命中。

### 3.L 迁移 manifest 与下游 `.claude/**` 升级安全 [M]（步骤 S7；Codex 约束 1 + 5）

> **两条不可协商的原则**：
> (a) 历史 migration manifest（`2.26.0-to-2.27.0.yaml`、`2.42.0-to-2.43.0.yaml` 等）**只读**——不改写、不重命名、仍可解析回放；
> (b) v3 **不得生成**任何自动删除下游 `.claude/**` 的新 manifest，且引擎/安装器**绝不递归删除**用户 `.claude/`。

| # | 路径 | 改动 |
|---|------|------|
| L1 | `.tad/hooks/lib/migration-draft.sh:94` | diff scope 去掉 `.claude/` 与 `CLAUDE.md`：`-- .tad/ .codex/ .agents/ AGENTS.md tad.sh`。**根因**：若为 `v2.44.6..v3.0.0` 生成 draft，`git diff` 会命中仓库内 ~571 条 `.claude/**` 删除，draft 会把它写成 `delete:` 条目 |
| L2 | `.tad/migrations/` | **不新增 `2.44.6-to-3.0.0.yaml`**（无 manifest = 升级不做任何删除）。若未来确需 manifest，只允许 `rename`/`verify`，且 `delete:` 中**零** `.claude/**` 条目。**注意**：当前 `2.44.6→3.0.0` 本就是 chain gap（`call_migration_engine` rc=2 → WARN，`tad.sh:1565-1577`），不新增 manifest 即维持现状——切勿为「填 gap」而生成删除 manifest |
| L3 | `.tad/hooks/lib/migration-engine.sh:72`（**保持不变**）| `validate_path` 的 `.claude/*` allow-list **必须保留**，否则历史 manifest（`2.26.0-to-2.27.0.yaml:6-25`、`2.42.0-to-2.43.0.yaml:21-33` 删具体 `.claude/skills/**` 文件）被 `REJECT`、老用户跨版本回放断裂（**修正 §3.I7 原表述**）|
| L4 | `.tad/deprecation.yaml` | **不加** `.claude/skills` / `.claude/settings.json` / `.claude/**` 条目（保持既有保证）；`*sync` 仍只清 TAD 自己写的历史 `.claude/commands/*.md` |
| L5 | `tad.sh:1834-1878`（`snap_one`/`take_rollback_snapshot`）、`:2047-2060`（rollback step 4）| 既有语义「**只在目录安装前不存在时**才整树删除 run-created 目录」保留；预存在的 `.claude/` 进 `ROLLBACK_PRE_TOP` → 永不整树删。S7 删 `snap_one ".claude/*"` 时**不得**新增任何 `.claude` 递归删除站点 |
| L6 | `.tad/tests/installer-data-safety-fixture.sh`、`.tad/tests/upgrade-acceptance.sh`、`.tad/tests/tad-update-fixture.sh` | **新增升级安全 case**：目标预置含 `.claude/skills/`、`.claude/settings.json`（用户 hooks）、`.claude/settings.local.json`、`.claude/.mcp.json` / 用户 MCP 与权限配置、`.claude/commands/<user>.md`；跑 2.44.6→3.0.0 升级；断言上述**用户资产字节不变**（`diff -rq`）且未被删除。**范围界定**：`deprecation.yaml` 对历史 TAD 自有 `.claude/commands/tad-*.md` 的既有清理属 pre-existing 行为、不在断言内（且 3.0.0 不新增此类条目） |
| L7 | 用户资产语义 | `.claude/` 是**用户/第三方混合归属**目录（同 `deprecation.yaml:26-39` 对 `.codex/` 的裁定）：TAD 只写过 skills/settings/workflows，用户可能叠加 hooks/MCP/权限。**默认：v3 对 `.claude/` 只保留、不写、不删**（唯一例外见 L6 范围界定） |

**验证点**：
```bash
# 不存在的 3.0.0 删除 manifest
! test -f .tad/migrations/2.44.6-to-3.0.0.yaml
# 没有新 manifest 删除 .claude/**
! grep -rn 'path: *"\.claude/' .tad/migrations/*3.0.0*.yaml 2>/dev/null
# draft 工具不再产出 .claude 删除条目（生成到临时目录检查）
#   bash .tad/hooks/lib/migration-draft.sh v2.44.6 v3.0.0 --output-dir /tmp/opencode/mig-check
#   ! grep -n 'path: *"\.claude/' /tmp/opencode/mig-check/2.44.6-to-3.0.0.yaml
# 历史 manifest 仍可解析（只读，不落盘）——用真实存在的链验证 .claude 路径不被 REJECT
bash .tad/hooks/lib/migration-engine.sh --from 2.26.0 --to 2.27.0 --target /tmp/opencode/x --source . --dry-run  # 期望可解析，不 REJECT
# 2.44.6→3.0.0 无 manifest → 保持 gap（WARN，不执行删除），不得新增
```

> **SAFETY（migration + installer-data-safety）**：L1–L5 是删除面/迁移面的组合改动；未过 §6.4 评审不得合入。负控：临时把 `.claude/` 加回 L1 scope → V-P6 必须 FAIL。

### 3.M 旧 2.44.6 updater `--platform both` 兼容 [M]（步骤 S2；Codex 约束 2）

**问题链**：默认安装（`--platform both`）的下游同时存在 `.claude/skills/alex` 与 `.agents/skills/alex`。**旧 2.44.6 updater 的 `detect_platform` 返回 `both`**（`.tad/scripts/tad-update.sh:123-124`），并在 apply 时**原样透传** `--platform both` 给下载到的新版 `tad.sh`（`:280`）。v3 已删除 `both` → 若不处理，升级会以「未知平台」失败，或更糟：先在旧 updater 侧产生 mutation。

**设计（fail-before-mutation + 明确恢复命令）**：

| # | 位置 | 要求 |
|---|------|------|
| M1 | `tad.sh:519-536` `validate_platform`/`resolve_platform` | `claude-code` **与 `both`** → tombstone：打印移除说明 + **可复制的恢复命令**，`exit 1`，**零写入**。不静默回落、不映射为 codex |
| M2 | 顺序保证 | tombstone 在 Phase 3（`main():2485`）执行，早于 `NEED_ROLLBACK=1`（`:2698`）/`take_rollback_snapshot`（`:2702`）/Phase 4 copy → 结构性 fail-before-mutation。必须有负控 fixture 断言 pre/post 零 mutation |
| M3 | tombstone 文案（恢复命令）| 旧本地 updater：`bash .tad/scripts/tad-update.sh --platform codex --yes`；npm 路径：`npx tad-framework@latest --platform codex`；curl 路径：`curl -fsSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh \| bash -s -- --platform codex --yes` |
| M4 | v3 自带 updater（`.tad/scripts/tad-update.sh`）| 见 C7：`.agents/skills/alex` 存在即判 `codex`，永不发送 `both`。旧 updater 不在本版控制范围 → 只能靠 M1 兜底 + release notes 引导（§5.2） |

**验证点**：
```bash
# tombstone + fail-before-mutation（负控）：预置 both 树，snapshot，执行，diff 为空
#   tad.sh --platform both --yes   → exit≠0，且目标目录 byte-identical（无 snapshot/备份/rm/copy）
#   tad.sh --platform claude-code --yes → exit≠0，同上
# recovery 命令可用（sandbox）：bash .tad/scripts/tad-update.sh --platform codex --yes → 正常 apply
```

---

## 4. SSOT 反转（installer 方向 + release-verify parity）

### 4.1 SSOT 落点：`.agents/skills/` 为唯一源（已锁定）
**决策**：把 `.agents/skills/` 设为唯一 skill 源，删除 `.claude/skills/`。**不新建** `.tad/skill-library/`。

**理由**：
1. **零内容风险**：两树当前逐字节相同（§2）。
2. **零迁移成本**：`.agents/skills` 已是 tracked（555 files）；不需要移动/重命名任何文件。
3. **`.tad/skill-library/` 不可行（除非改 deny-list）**：该路径在 `tad.sh:562` 的 `TAD_ZERO_TOUCH` 拒绝名单里（**永不同步到下游**）；把它当源会导致下游拿不到 skill。改 deny-list 又是 release-sync SAFETY 面。
4. **中立性足够**：`.agents/` 不是厂商目录（不是 `.claude/`/`.codex/`/`.cursor/`），语义为「agents」，与 harness 无关。
5. **可扩展**：未来把 OpenCode 升为一等时，仍从 `.agents/skills` 派生 target，无需再动 SSOT。

> **备选（不推荐，留作将来 rename）**：若人坚持字面无厂商联想的路径，可做一次纯 rename（`.agents/skills` → `skills/` 或 `.tad/agents-skills/`），但那是**独立 rename 单**，blast radius 更大（package.json files / .gitignore / deny-list / 所有消费者），不应与本移除批次耦合。

**安装器方向（实现）**：
- `$src/.agents/skills/*/` → `$TARGET/.agents/skills/`（`codex` 唯一 target）。
- 删除「primary `.claude/skills` + secondary `.agents/skills`」双写心智模型（§3.B.1/B.3）。
- `release-verify.sh structural` 同方向：`diff -rq "$SRC/.agents/skills" "$TGT/.agents/skills"`。

### 4.2 `.tad/hooks/lib/release-verify.sh` 修改（步骤 S3）

| # | 位置 | 改动 |
|---|------|------|
| V1 | `:15, :102-117`（头注释）| 「Claude↔Codex parity, direction FIXED Claude→Codex」→ 删除 parity 段（§4.3） |
| V2 | `:208-233`（structural）| `.claude/skills` diff → **`.agents/skills`**；`local/` INFO 例外保留 |
| V3 | `:234-243`（structural workflows）| `.claude/workflows` diff 块 → **删除** |
| V4 | `:293`（ephemeral trees 排除）| 保留 `.claude/worktrees/` 排除（无害）或改 `.agents/worktrees/` |
| V5 | `:454`（migration scope）| `-- .tad/ .claude/ .codex/ .agents/ CLAUDE.md AGENTS.md tad.sh` → **去 `.claude/`、去 `CLAUDE.md`**；保留 `.agents/` |
| V6 | `:558-748`（`parity` 子命令）| **整段删除**（§4.3） |
| V7 | `:555-556, :149`（usage）| 删除 `parity` usage 行 |
| V8 | `:790-792`（must-version registry）| `.claude/skills/tad-help/SKILL.md`、`alex`、`blake` → **`.agents/skills/...`** |
| V9 | `:905-1021`（`platform-skills` 子命令）| **整段删除**（§4.3） |
| V10 | `:579`（`check_platform_coupled_references`）| 若保留为「防止 Claude 耦合回归」的守卫：目标仍匹配 `reference:.*\.claude/`（禁止），扫描目录改 `.agents/skills`；若不想留，随 parity 删除 |
| V11 | 头注释 `:77`（"scoped to `.tad/`, `.claude/`, …"）| 去 `.claude/` |

### 4.3 `parity` / `platform-skills` 处置：**删除**（不是「改方向」）
**理由**：parity 的存在前提是**两棵 skill 树**（源 + 镜像）。SSOT 反转 + 删除 `.claude/skills` 后只剩一棵树 → parity 在结构上**无事可做**（比的是同一棵树）。把它「改方向」会得到一个永远 PASS 的空门（vacuous gate），正是 project-knowledge 反对的「验证剧场」。

- 删除 `parity [--fix]`（`release-verify.sh:558-748`）。
- 删除 `platform-skills`（`:905-1021`）。
- **调用方同步**（否则 release 流程 exit 2）：
  - `.agents/skills/release-runbook/references/publish-ops.md:36`（`parity`）
  - `.agents/skills/alex/references/publish-protocol.md:89,97`（`parity` / `parity --fix`）
  - `.agents/skills/capability-builder/SKILL.md:13`（「`release-verify.sh parity --fix` is Claude→Codex only」整句删除/改写）
  - `.agents/skills/blake/SKILL.md`、`alex/SKILL.md` 若在 step3b 引用 parity → 用 `structural` 替代（Blake 需 grep `step3b` + `parity`）
- **替代门**：`structural`（源↔目标 `.agents/skills` 字节一致）继续承担「copy 是否完整」的职责；`.tad/` dirs 的 `diff -rq` 不变。对称性「两边都有」不再需要。
- `.tad/project-knowledge/patterns/release-sync.md` 内 parity 相关条目：**加 AMENDED 注**（说明 2.x parity 工具已随 Claude 路径移除），不改历史 Discovery 文本。

> ⚠️ **SAFETY（release-sync）**：改 `release-verify.sh` 源方向/删除子命令属于 release-sync 承重面。Blake 落地时必须：(a) 同步改所有调用方，否则 `exit 2` 会变成「隐形 wiring 门」；(b) 用一个真实 `*publish` dry-run 验证 `structural` 仍能抓到 omission（可临时删目标一个文件测 fail）；(c) `TAD_RELEASE_GATE=warn` 只降级 drift，不得降级 wiring。

### 4.4 SSOT 消费者全清单（Codex 约束 3）

> SSOT 反转**不只** installer + parity。下面是把 `.claude/skills` 当源/锚点/权威路径的**全部活消费者**；每条必须在 S1/S3/S6 同批 repoint，否则会出现「绿门 + 坏数据」（门比对的是同一棵坏树）或指向已删路径的静默失效。

| 消费者类 | 文件 | 步骤 | 现状 → 目标 |
|----------|------|------|-------------|
| installer 主链 | `tad.sh`（B1/B4/B5/B7/B11/B12） | S1 | 源 `.claude/skills` → `.agents/skills`；target 恒 `.agents/skills` |
| release-verify | `.tad/hooks/lib/release-verify.sh`（V2/V8/V10） | S3 | `structural` diff 方向 → `.agents/skills`；must-version registry |
| npm 安装器 | `bin/tad-install.mjs`（C3） | S2 | platform 列表动态读；默认 `codex` |
| updater | `.tad/scripts/tad-update.sh`（C5/C7） | S2 | `detect_platform` 只认 `.agents/skills/alex` |
| platform 探测 | `.tad/hooks/lib/detect-platform.sh`（C4） | S2 | 删 `workflow` 信号分支 |
| **capability-pack installers** | `.tad/capability-packs/*/install.sh`（26 个）+ `.tad/templates/capability-pack-template/install.sh`（I12/I13）| S6 | 安装目标 → `.agents/skills` |
| **capability-skill.sh** | `.tad/scripts/capability-skill.sh`（I9）| S6 | 删 `.claude/skills` projection |
| **pack 验证器** | `pack-eval-runner.sh`（I10）、`pack-registry-driftcheck.sh`（I3）、`scan-collisions.sh`（I11）、`pack-collisions.yaml`/`collision-signatures.txt`/`behavioral-eval-status.yaml`（I19）| S6 | `SKILLS_DIR` + `ref:` 锚点 → `.agents/skills` |
| **brain index** | `.tad/hooks/lib/brain-index-gen.sh`（I2；产物 `.tad/brain-index.md` 当前 0 处 `.claude`）| S6 | `SKILLS_DIR` → `.agents/skills` |
| **runtime freshness** | `.tad/hooks/lib/runtime-freshness-verify.sh`（I18）+ `.tad/runtime-compat/{codex,claude-code}.md` | S6 | claude ledger 消费点改为可选/`RETIRED` 跳过 |
| **pair driver** | `.tad/scripts/phase2-pair-driver.mjs`（G3/G6）| S5 | 删 `claude -p` spawn；`JUDGE_MODEL_FAMILY` 去 `'claude'` 默认 |
| hooks libs | `skill-body-verify.sh`（I1）、`memory-redirect.sh`（I4）、`drift-check.sh`（I5）、`knowledge-blame.sh`（I6）、`migration-engine/draft.sh`（I7）、`verify-ac-commands.sh`/`friction-status-check.sh`（I8）| S6 | 路径 → `.agents/skills`；删 Claude-only memory redirect |
| 模板 | `.tad/templates/*.md`（I14）| S6 | `.claude/skills/...` → `.agents/skills/...`；workflow 引用改注 |
| tests/fixtures | `detect-state-fixture.sh`（I15）、`tad-update-fixture.sh`/`gate-exercise.sh`/`migration-fixtures`（I16）| S6 | fixture 路径 → `.agents/skills`（历史迁移 fixture 保留语义）|
| 根 CLI | `tad:85-86`（I17）| S6 | 计数目标 → `.agents/skills` |
| legacy live 元数据 | `.tad/skills-config.yaml`、`manifest.yaml`、`discipline-floor*.md`、`.tad/agents/*`、`.tad/skills/*/SKILL.md`、`portable-rules.md`（§3.K）| S6/S8 尾 | repoint 或标 `ARCHIVED` |

> **验证消费者完整性**：`grep -rn '\.claude/skills' <活目录>` 的结果集合必须与 §3.I + §4.4 的清单**逐条对上**（V-P1 的负向 grep 是最终判据）。

> **CoALA/AC 提醒**（ac-verification）：`brain-index.md` 是**生成产物**——只改生成器（I2）并在 S6 重生成；直接手改产物会在下次生成时回退。

---

## 5. 外部用户影响 & Release Notes 文案

### 5.1 影响面
- TAD 是公开仓库 + npm 包；`--platform both` 目前是 README 推荐默认（README 安装段）。
- **现有用户（含仍装 Claude Code 者）**：
  - 升级**不会删除**其 `.claude/`（`deprecation.yaml` 不列 `.claude/skills`/`.claude/settings.json`（历史 TAD 自有 `.claude/commands/tad-*.md` 除外）；`tad.sh:1154-1157` 平台切换显式保留旧树；rollback 只在目录安装前不存在时才删；v3 不生成删除 manifest）。→ **用户数据零损失**，用户 hooks / MCP / 权限配置一并保留（Codex 约束 5）。
  - 升级后会**新装/更新** `.agents/skills/`（新默认），`.claude/skills/` 保持旧版不变 → Release Notes 说明「旧 Claude 树不再更新；TAD 不代删，可自行清理」。
- `--platform claude-code` / `--platform both` 在 v3 **fail-before-mutation 报错**（tombstone + 恢复命令，§3.M）。
- capability pack 独立 `install.sh` 的目标从 `.claude/skills` 改为 `.agents/skills`。
- **能力回退（必须写清）**：`.claude/workflows/*.workflow.js` 的动态 workflow 运行时随移除消失；依赖 `TAD_PLATFORM=workflow` 的路由回落到 `codex`。这是 accepted limitation（Codex 无 workflow 等价物）。

### 5.2 外部用户升级兼容说明（发布时随 Release Notes，定稿）
1. **只用 Codex 的用户**：无需操作。`npx tad-framework` / `curl | bash` 现在默认装 `.agents/skills`；`--platform codex` 为默认。
2. **仍装 Claude Code 的用户**：Claude 路径自 v3.0.0 起**不再更新**。升级**不会删除、不会改写**你现有的 `.claude/`（含 skills、settings.json、hooks、MCP、权限配置）。如需清理请手动操作：`rm -rf .claude/skills .claude/workflows .claude/settings.json`（**TAD 不会代删**）。
3. **脚本里传 `--platform claude-code` 或 `--platform both` 的用户**：v3 会**在改动任何文件前**报错，并打印恢复命令。请改传 `--platform codex`，或直接重跑：
   - 本地 updater：`bash .tad/scripts/tad-update.sh --platform codex --yes`
   - npm：`npx tad-framework@latest --platform codex`
   - curl：`curl -fsSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform codex --yes`
   > 若你用**旧版（≤2.44.6）自带 updater**：它会自动探测出 `both` 并原样透传 → v3 会 fail-before-mutation 停下。用上面任一条恢复命令即可，**不会丢文件**（§3.M）。
4. **直接调用某个 capability pack 的 `install.sh`**：目标现在是 `.agents/skills/`；旧的 `~/.claude/skills/` 安装不会自动迁移或删除。
5. **迁移安全保证**：v3.0.0 **不生成**删除用户 `.claude/**` 的 migration manifest；历史 manifest 只读保留。

### 5.3 CHANGELOG 文案（v3.0.0 定稿；Blake 落地时粘贴）
> 人已拍板**一步到 v3.0.0**，因此只有 `### Removed` 块——**没有 2.45.0 `### Deprecated` 过渡块**（理由见 §6.1）。

```markdown
### Removed
- **Claude Code runtime path removed (breaking).**
  - Deleted `.claude/` (skills source, `settings.json` hooks, `workflows/`, `agents/`, `rules/`, `commands/`) and root `CLAUDE.md`.
  - `.agents/skills/` is now the **sole** skill source; the installer reads and writes it directly (no mirror).
  - `--platform claude-code` and `--platform both` are **rejected before any mutation**, with a printed recovery command; `--platform codex` is the only target and the default.
  - Removed Claude model bindings: `.claude/agents/*` opus/sonnet pins, the `claude-haiku` PreToolUse prompt hook, `.claude/workflows/*` model pins, `.tad/config-agents.yaml teammate_model: sonnet`, and the YOLO/pair-driver `claude` CLI spawn (`claude -p --model sonnet`).
  - Renamed `claude_websearch` → `websearch`, `claude_code_reviewer` → `code_reviewer`.
  - `release-verify.sh parity` / `platform-skills` removed (single skill tree; nothing to mirror).
  - **No user data is deleted**: pre-existing `.claude/` trees downstream (including user hooks, MCP, and permission config) are left byte-for-byte intact and are never recursively removed. No new migration manifest deletes `.claude/**`.
  - OpenCode remains updater-only in this release; first-class OpenCode support is a separate follow-up.
```

---

## 6. 分期、版本、步骤顺序、验证点、回滚

### 6.1 版本（已锁定）
> **v3.0.0 (major)，一步落地。**「彻底移除」= 移除一个已文档化的 install target + 删除其全部资产 = breaking API change，语义上不能是 minor。
>
> **为何不采用「分两版」（2.45.0 deprecate → 3.0.0 remove）**：人已拍板直接删除；过渡版会额外维护一个「标 DEPRECATED 但仍安装 `.claude/`」的双轨状态（新增 parity/installer 分支），与本批要退休的机制直接冲突、且延长下游的不确定窗口——故一次断言删除（CHANGELOG 只出 `### Removed`，见 §5.3）。

### 6.2 Blake 落地步骤顺序（单序列）

> 原则：**SSOT 反转（S1–S3）必须先于 `.claude/` 删除（S7）**；S4/S5/S6 可与 S1–S3 并行，但**不得**在 S7 后才改安装器读取路径。**Codex 5 约束的落点**以 `⟦C1..C5⟧` 标出。

| 步骤 | 内容 | 关联清单 |
|------|------|---------|
| **S0** 基线 | `git status` 干净；记 grep 基线计数（§8 命令，存 `/tmp/opencode/`）；打 checkpoint tag/commit。**升级安全 fixtures 基线 ⟦C5⟧**：记录一份预置 `.claude/`（含用户 hooks/MCP/权限配置）的 byte baseline，供 S7 断言不变 | §3.L |
| **S1** SSOT 反转 | 安装器读/写 `.agents/skills`（B1/B4/B5/B7）；`resolve_pack_dir`/pack list（B11/B12）。**此步后 `.claude/skills` 仍在，但已非源** | §4.1 |
| **S2** 平台矩阵收敛 + updater 兼容 ⟦C2⟧ | B13、C1–C7；tombstone `claude-code` **与 `both`**（fail-before-mutation + 恢复命令）；旧 updater 透传 `both` 的兜底（§3.M）；负控 fixture 断言零 mutation | §3.C/§3.M |
| **S3** release-verify | V1–V11；删除 parity/platform-skills；改调用方（publish-ops / publish-protocol / capability-builder）；`parity-criterion.md` 归档/删除（I20）；`--verify-denylist` 仍绿 | §4.2/§4.3 |
| **S4** 标签 + 去 pin | E1–E4、F5–F6 | §3.E/§3.F |
| **S5** YOLO harness + pair driver ⟦C4⟧ | G1–G7（含测试与 `.bak`）；pair-driver `claude -p --model sonnet` 与 `JUDGE_MODEL_FAMILY='claude'` 清除；**纳入硬零残留 AC** | §3.G |
| **S6** 路径改写消费者 ⟦C3⟧ | I1–I19 全清单（hooks lib / scripts / **capability-pack installers** / **capability-skill.sh** / **pack 验证器 + 碰撞锚点** / **brain index** / **runtime freshness** / templates / tests）；`tad` 根 CLI；**消费者完整性核对 §4.4** | §3.I/§4.4 |
| **S7** 删除 `.claude/` + 迁移安全 + 门面 ⟦C1,C5⟧ | A1–A7、A9；B8–B10（rollback 清理）；**L1–L7**：`migration-draft` scope 去 `.claude/`、不生成 3.0.0 删除 manifest、引擎 allow-list 保留、deprecation 不加条目、升级安全 fixture 断言用户 `.claude/` 不变；`.gitignore` 去 `.claude/*`（`:7,10,13,19,20`）与 parity 注释（`:14-16`），保留 `.agents/skills/local/`；**`:78`（`.claude/settings.local.json.bak-*`）例外——按 R1 返工恢复，不删**（Gate 4 裁决 `.tad/evidence/reviews/2026-09-15-gate4-acceptance-claude-removal.md` §7.1；以 R1 为准，覆盖本行原枚举）；`package.json` files 去 `.claude/`、keywords 去 `claude`/`claude-code` | §3.A/§3.B/§3.L |
| **S8** 文档中性化 | H1–H10、J1–J11、A10（`research/CLAUDE.md`→`research/AGENTS.md`） | §3.H/§3.J |
| **S9** 版本 + 发布物料 | bump **3.0.0**、CHANGELOG（§5.3 `### Removed` 定稿文案）、release notes/迁移说明（§5.2 含旧 updater 恢复命令）；`.tad/version.txt` / `TAD-VERSION` / `tad.sh` TARGET_VERSION / `package.json` / must-version registry 同步 | §5 |

### 6.3 每步验证点（grep 零残留清单）

> **范围纪律**：`grep` 只作用于**活代码/配置/公共文档**；历史面（§3.K 明确不动）**不在**零残留范围，否则会产生 1,215 行的假阳性噪声（design §2.D）。下列命令在 repo 根执行。

**V-P0 结构完整性（S1–S3 后）**
```bash
# SSOT：安装器只从 .agents/skills 读源
! grep -n 'src/\.claude/skills' tad.sh
grep -n 'src/\.agents/skills' tad.sh            # 期望：出现
# parity/platform-skills 已退休
! grep -n 'parity\|platform-skills' .tad/hooks/lib/release-verify.sh | grep -v '^#'
# tombstone：both 与 claude-code 都拒绝（fail-before-mutation）
! bash tad.sh --platform both --yes        && echo FAIL || echo "OK: both rejected"
! bash tad.sh --platform claude-code --yes && echo FAIL || echo "OK: claude-code rejected"
# 安装器自检可跑（sandbox）：fresh 安装 exit 0
bash tad.sh --source . --platform codex --yes --force   # 或测试 fixture；期望 exit 0
```

**V-P1 活运行时零残留（S2–S6 后）**
```bash
# 硬零（排除领域知识 pack + 保留清单 R2-1–R2-4；裁决 §5 字面形态）
git ls-files -z -- tad.sh bin .tad/platform-codes.yaml .tad/config-workflow.yaml \
  .tad/config-agents.yaml .tad/cross-model/capabilities.yaml .tad/hooks .tad/scripts \
  .tad/capability-packs .tad/templates .agents/skills .codex package.json .gitignore \
  | grep -zv 'ai-prompt-engineering\|ai-evaluation\|agent-computer-interface' \
  | grep -zv 'deps-protocol\.md\|dependency-ops/SKILL\.md' \
  | grep -zv 'CHANGELOG\.md' \
  | xargs -0 grep -n 'claude-code\|claude_websearch\|claude_code_reviewer' | grep -v 'claude-code\.md' ; echo "exit=$?"
# 期望：无输出
```
```bash
# 模型 pin 零残留（活文件）
! grep -rn 'model: *\(opus\|sonnet\|haiku\)\|claude-sonnet\|claude-haiku\|claude-opus' \
    .tad/config-agents.yaml .tad/scripts/yolo-harness-profiles.json .tad/eval/judge/README.md
# ⟦C4⟧ pair-driver 与 YOLO harness：无 claude spawn / 无 sonnet 默认 / 无 claude family
! grep -n 'claude' .tad/scripts/yolo-harness-profiles.json
! grep -n 'claude\|sonnet' .tad/scripts/phase2-pair-driver.mjs
! test -e .tad/scripts/phase2-pair-driver.mjs.bak
# 期望：全部无输出（测试 fixture 里的 .claude/ 作用域见 G5）
```
```bash
# ⟦C3⟧ 消费者完整性：活目录残留 .claude/skills 必须为空（逐目录复核 §4.4）
# carve-out（判据侧；被保留物本身不动，不得编辑 fixture/归档消命中 — 裁决 C-3 + Gate 4 §7.3）：
#   parity-criterion.md（ARCHIVED per §3.I20）、skills-config.yaml（ARCHIVED per §3.K，stale by design），
#   4 个历史/安全 fixture：run-fixtures.sh、test-15-dual-caller-integration.sh、tad-update-fixture.sh（I16 保留语义）、
#   installer-data-safety-fixture.sh（预置用户 .claude/ 树以断言 AC12/AC17 字节不变，§3.K 保留清单）
# config-workflow.yaml 不排除：:279 悬空 playground command 行按 §7.3 改写移除（非 carve-out）。
! grep -rn --exclude=parity-criterion.md --exclude=skills-config.yaml \
    --exclude=run-fixtures.sh --exclude=test-15-dual-caller-integration.sh \
    --exclude=tad-update-fixture.sh --exclude=installer-data-safety-fixture.sh \
    '\.claude/skills' .tad/hooks/lib .tad/scripts .tad/capability-packs \
    .tad/templates .tad/tests .tad/config-workflow.yaml .tad/skills-config.yaml
# runtime freshness 门仍绿（claude ledger 已 RETIRED/可选）
bash .tad/hooks/lib/runtime-freshness-verify.sh . "$(date +%Y-%m-%d)" ; echo "exit=$?"
```

**V-P2 `.claude/` 删除完整（S7 后）**
```bash
test ! -e .claude && test ! -e CLAUDE.md && echo "OK: .claude/ + CLAUDE.md removed"
git ls-files '.claude/**' 'CLAUDE.md' ; echo "exit=$?"        # 期望空
git status --porcelain | grep -c '^ D \.claude/'              # 期望 555 + 其余
! grep -n '\.claude/' package.json .gitignore                  # 期望空
```

**V-P3 公共文档零「一等平台」断言（S8 后）**
```bash
! grep -rn 'first-class runtimes.*Claude Code\|Claude Code and Codex\|two first-class' \
    README.md INSTALLATION_GUIDE.md docs/MULTI-PLATFORM.md docs/CODEX-USER-GUIDE.md AGENTS.md
# 12 双写标签零残留
! grep -rn '<!-- Claude Code:' .agents/skills
# 期望：无输出
```

**V-P4 发布门（S9 后）**
```bash
bash .tad/hooks/lib/release-verify.sh version-sweep . "$NEW"
bash .tad/hooks/lib/release-verify.sh structural . .    # 结构自比对（sandbox 用）
bash tad.sh --verify-denylist
```

**V-P5 负控（验证器自身有效）**
```bash
# 在 sandbox 目标里删一个 .agents/skills/<pack>/SKILL.md → structural 必须 FAIL
# 在 tad.sh 里临时把 .agents/skills 写回 .claude/skills → V-P0 必须 FAIL
# 在 tad.sh 里把 both 的 tombstone 改回静默接受 → V-P0 的 both 负控必须 FAIL
```
> 只跑正测 = 验证剧场；每类门必须配一个负控（project-knowledge: gate-design）。

**V-P6 迁移 / 用户数据安全（S7 后；⟦C1,C5⟧）**
```bash
# v3 不生成删除用户 .claude/** 的 manifest
! test -f .tad/migrations/2.44.6-to-3.0.0.yaml
! grep -rn 'path: *"\.claude/' .tad/migrations/*3.0.0*.yaml 2>/dev/null
# draft scope 不含 .claude/、CLAUDE.md
! grep -n '\.claude/\|CLAUDE.md' .tad/hooks/lib/migration-draft.sh
# deprecation.yaml 未登记下游 .claude
! grep -n '\.claude/skills\|\.claude/settings\.json' .tad/deprecation.yaml
# 升级安全：预置含用户 hooks/MCP/权限的 .claude/ → 升级后字节不变
diff -rq "$SANDBOX/target/.claude" "$SANDBOX/preexisting-claude" && echo "OK: user .claude untouched"
```
> 负控：临时把 `.claude/` 加回 `migration-draft.sh` scope，或给 `deprecation.yaml` 加一条 `.claude/skills` → V-P6 必须 FAIL。

**V-P7 旧 updater `both` 兼容（S2 后；⟦C2⟧）**
```bash
# 模拟旧 2.44.6 updater：预置 both 树，透传 --platform both → 必须失败且零 mutation
cp -a "$SANDBOX/target" "$SANDBOX/target.pre"
( cd "$SANDBOX/target" && bash "$TMP_INSTALLER" --platform both --yes ) ; echo "exit=$? (期望≠0)"
diff -rq "$SANDBOX/target" "$SANDBOX/target.pre" && echo "OK: zero mutation on fail"
# tombstone 文案含恢复命令
bash "$TMP_INSTALLER" --platform both --yes 2>&1 | grep -F -- '--platform codex'
```
> 负控：把 `resolve_platform` 的 tombstone 移到 `take_rollback_snapshot` 之后 → V-P7 的 zero-mutation 断言必须 FAIL（暴露顺序回归）。

### 6.4 回滚点

| 回滚点 | 触发 | 动作 |
|--------|------|------|
| R0（S0 checkpoint） | 任意步骤发现设计缺陷 | `git reset --hard <S0>`（未发布，无损） |
| R1（S1–S3 后） | 安装器/self-check 红 | `git revert` S1–S3 三个 commit（安装器与 release-verify 必须整组 revert，不能只回一半） |
| R2（S7 后） | `.claude/` 删除后发现必须保留某资产 | `git revert` S7（文件从 git 恢复）；**用户侧**：升级不会删用户树，无需回滚用户数据 |
| R3（S9 后、发布前） | 外部用户影响评估不通过 | 不 publish；`git revert` 到 S0 |
| R4（已发布后） | 需要撤回版本 | npm deprecate + 补丁版恢复兼容（不在本 handoff；另立 release 单） |

**SAFETY 约束（不可作为「顺手清理」）**：
- 不改 `deprecation.yaml` 去登记删除下游 `.claude/skills` / `.claude/**`（installer-data-safety：默认不删用户树）⟦C5⟧。
- **绝不新增对用户 `.claude/` 的递归删除站点**（用户可能叠加 hooks/MCP/权限配置）⟦C5⟧；`tad.sh` 任何新增 `rm -rf` 站点必须带同行 `# RM-OK:<id>`（否则 `installer-destructive-guard` FAIL）。本批是**删站点**，安全。
- **不生成删除用户 `.claude/**` 的新 migration manifest**；`migration-engine.sh:72` 的 `.claude/*` allow-list **保留**（历史 manifest 只读回放）⟦C1⟧。
- `release-verify.sh` 源方向/子命令改动必须过 release-sync SAFETY 评审（§4.3）；`runtime-freshness-verify.sh` 的 ledger 处理改动同属该面（I18）。
- `tad.sh` 平台 tombstone 必须保持**先于** `take_rollback_snapshot`（否则破坏 fail-before-mutation）⟦C2⟧。
- `TAD_DENY_LIST`（`tad.sh:553-573`）与 `derive-sync-set.sh` 的 drift 不变（`.agents` 不在 `.tad` 下，不进 deny 集合）。

---

## 7. OpenCode 一等 target 在本方案中的位置

**结论（明确标注为后续独立项，不在本批）：与本次移除完全解耦，不放进本批；作为**独立后续单**排在 v3.0.0 之后。本批对 OpenCode 唯一动作是「保持 updater-only 现状不变」。**

理由：
1. 用户方向是「只保留以 Codex 为主的**中立**机制」——移除本身不要求新增 target。移除后的矩阵是 `codex`（+ `none`）。
2. OpenCode 目前**没有 skill 加载契约**（`.opencode/` 仅 `commands/tad-update.md`，自述 "does not provide Alex/Blake/Gate roles, hooks, or gate parity"）。把它升为一等，需要先回答「OpenCode 如何发现并加载 `alex`/`blake` SKILL」——这是**独立设计单**，不是改字符串。
3. 本移除的正确姿势是**让矩阵可扩展**，而不是先加 OpenCode：
   - `KNOWN_PLATFORMS` 与 `.tad/platform-codes.yaml` 保持「单一 SSOT + 可增 key」结构（S2 已保留 `parse_platform_*` 的通用 delta 机制）。
   - SSOT 落在 `.agents/skills`（中立），未来 OpenCode target 从同一源派生 → **无需再次 SSOT 反转**。
4. 顺序建议：`TASK-…-claude-removal`（本单）→ `TASK-…-opencode-skill-contract`（前置设计）→ `TASK-…-opencode-target`（加矩阵项）。若人坚持把 OpenCode 目标写进新矩阵的 label，也只是改 `platform-codes.yaml` 一行，不阻塞本单。

> 因此 §8 的 AC **不含**任何 OpenCode 一等断言；只断言「矩阵只剩 codex 且结构可扩展」。

---

## 8. Acceptance Criteria

| # | AC | 验证 | 期望 |
|---|----|------|------|
| AC1 | SSOT 反转为 `.agents/skills`（安装器唯一源） | `! grep -n 'src/\.claude/skills' tad.sh` | exit 0（无匹配） |
| AC2 | `.claude/` 整套 + `CLAUDE.md` 已从 repo 删除 | `test ! -e .claude && test ! -e CLAUDE.md && git ls-files '.claude/**' CLAUDE.md \| wc -l` | 目录不存在；0 tracked |
| AC3 | `--platform` 矩阵只剩 `codex`，默认 codex，`claude-code` **与 `both`** tombstone | `grep KNOWN_PLATFORMS tad.sh`；`bash bin/tad-install.mjs --help`；`tad.sh --platform claude-code --yes`；`tad.sh --platform both --yes` | 只 `codex`；默认 codex；两者均明确报错 exit≠0 且零 mutation |
| AC4 | release-verify parity/platform-skills 已退休、调用方同步 | `! grep -n 'parity\|platform-skills' .tad/hooks/lib/release-verify.sh \| grep -v '^#'`；`! grep -rn 'release-verify.sh parity' .agents/skills` | exit 0 |
| AC5 | 标签改名 + 目录项 | `! grep -rn 'claude_websearch\|claude_code_reviewer' .tad/config-workflow.yaml .agents/skills .tad/guides README.md` | exit 0 |
| AC6 | 活文件无 Claude 模型 pin / `claude` spawn | §6.3 V-P1 命令（**R2-1–R2-4 保留清单除外，裁决 §5 字面形态**） | 无输出（保留项见 §3.H/§3.K 注） |
| AC7 | YOLO harness 无 claude profile，测试自洽 | `! grep -n 'claude' .tad/scripts/yolo-harness-profiles.json`；`node .tad/scripts/yolo-harness-runner.test.mjs` | profile 无；测试 exit 0 |
| AC8 | 12→6 双写中性化 | `! grep -rn '<!-- Claude Code:' .agents/skills` | exit 0 |
| AC9 | 公共文档不再宣称 Claude Code 一等 | §6.3 V-P3 | exit 0 |
| AC10 | `docs/pm/` 未动 | `git status --porcelain docs/pm` | 与本任务改动无关（保持任务前状态） |
| AC11 | 历史面未被改写 | `git diff --stat -- CHANGELOG.md .tad/evidence .tad/archive docs/archive .tad/memory .tad/migrations` | 无新增改动（CHANGELOG 只允许 S9 追加新版本块） |
| AC12 | 下游升级不删用户 `.claude/`（含 hooks/MCP/权限）⟦C5⟧ | `deprecation.yaml` 无 `.claude/skills`/`.claude/settings.json`/`.claude/**` 目录条目（历史 `.claude/commands/*.md` 单文件条目除外）；sandbox 预置 `.claude/{skills,settings.json,settings.local.json,.mcp.json}` → 安装后 `diff -rq` 空 | 字节不变 |
| AC13 | 发布门绿 | S9 后 `version-sweep` + `--verify-denylist` + `structural`(sandbox) | 全 exit 0 |
| AC14 | 每类门配负控 | §6.3 V-P5/V-P6/V-P7 | 每个负控按预期 FAIL |
| AC15 | CHANGELOG 文案符合 §5.3（**仅 `### Removed`**） | 读 CHANGELOG v3.0.0 块 | 含 "Removed"、`--platform both` 拒绝、`not auto-migrated`、无 2.45.0 `### Deprecated` 块 |
| AC16 | **pair-driver 零 Claude 残留** ⟦C4⟧ | `! grep -n 'claude\|sonnet' .tad/scripts/phase2-pair-driver.mjs`；`! test -e .tad/scripts/phase2-pair-driver.mjs.bak` | exit 0 |
| AC17 | **升级安全 fixture：用户 `.claude/` 字节不变** ⟦C5⟧ | §6.3 V-P6 的 `diff -rq` | exit 0 |
| AC18 | **v3 不生成删除用户 `.claude/**` 的 manifest；历史 manifest 仍可解析** ⟦C1⟧ | `! test -f .tad/migrations/2.44.6-to-3.0.0.yaml`；`! grep 'path: "\.claude/' .tad/migrations/*3.0.0*.yaml`；`migration-engine.sh --from 2.26.0 --to 2.27.0 --dry-run` 可解析 | 不存在/无匹配；历史回放不 REJECT |
| AC19 | **旧 updater `both` fail-before-mutation + 恢复命令** ⟦C2⟧ | §6.3 V-P7（zero-mutation diff + 文案含 `--platform codex`） | 无 mutation；文案含恢复命令 |
| AC20 | **SSOT 消费者完整性** ⟦C3⟧ | §6.3 V-P1 第二条命令（含 carve-out 清单）+ §4.4 清单逐条对上 | 无输出（carve-out：`parity-criterion.md` ARCHIVED per §3.I20、`skills-config.yaml` ARCHIVED per §3.K、4 个历史/安全 fixture per I16/§3.K；`config-workflow.yaml:279` 悬空 playground command 行已改写移除，非 carve-out。被保留物本身不动） |
| AC21 | **runtime freshness 门；OpenCode 不动** | `bash .tad/hooks/lib/runtime-freshness-verify.sh . <date>`（**达成路径 = Gate 4 书面 waiver + 另单真实重验，禁止写 PASS**；waiver 见 `.tad/evidence/reviews/2026-09-16-gate3-rework-r3-waiver.md`，另单 `TASK-20260916-CODEX-LEDGER-REVERIFY` 见 `.tad/active/TICKET-20260916-codex-ledger-reverification.md` + `NEXT.md` 优先队列）；`git diff --stat -- .opencode` | **WAIVED（仅"codex ledger 日期陈旧"子句，pre-existing/HEAD复现/与移除无关）+ 接线 PASS（claude retire-skip/无wiring-BLOCK）**；`.opencode/` 无改动 |

---

## 9. Risks

| 类别 | blast radius | 风险 | 缓解 / 回滚 |
|------|-------------|------|-------------|
| SSOT 反转 + 安装器 | 所有下游安装 | **高**：源方向改错 → 空装/漏装 | S1 后 sandbox fresh + upgrade 双向安装；`verify_install_complete` diff -rq；R1 |
| release-verify 门改向 | 发布流程 | **高**：删除 parity 后 publish 调用方 exit 2 | S3 同批改调用方；负控 V-P5；R1 |
| 默认平台变更 | 下游用户下次升级 | 中：少装 Claude（不删），多装 codex | legacy `.claude/` 保留；release notes §5.2；R0 |
| `.claude/workflows` 删除 | workflow 编排能力 | 中：`TAD_PLATFORM=workflow` 路由消失 | 明示 accepted limitation；后续可另立 port 单 |
| 模型 pin 去除 | Gate 3 审查模型选择 | 低：无运行时读者；审查走 harness 原生 | F5 只改 config；R1 |
| `claude` spawn 去除 ⟦C4⟧ | YOLO/判定路径（pair-driver + profile） | 中：真 `claude -p` 调用 + `JUDGE_MODEL_FAMILY='claude'` 默认 | G1–G7 同步测试；硬零残留 AC16；R1 |
| 标签改名 | config 一致性 | **极低**：无消费者 | E1–E4；R1 |
| 文档门面 | 公开印象 | 低 | S8；R0 |
| **下游数据丢失** | 用户 `.claude/`（hooks/MCP/权限）⟦C5⟧ | **SAFETY**：不得代删/改写 | AC12/AC17 + §6.4；不写 deprecation 条目；升级 fixture `diff -rq` |
| **v3 误生成 `.claude/**` 删除 manifest** ⟦C1⟧ | 所有老版本升级用户 | **SAFETY 高**：migration engine 会删用户 `.claude/skills` | migration-draft scope 去 `.claude/`；不提交 3.0.0 删除 manifest；引擎 allow-list 保留；AC18；负控 V-P6 |
| **旧 updater 透传 `both`** ⟦C2⟧ | 所有 both 默认安装用户首次升级 | **中-高**：升级中途 mutation 或硬失败 | tombstone 早于 snapshot（fail-before-mutation）+ 恢复命令；AC19；负控 V-P7 |
| **runtime freshness wiring** ⟦C3⟧ | 发布门 | 中：claude ledger 缺失/失修 → exit 2 永久 BLOCK | I18 使 ledger 可选/RETIRED；AC21 |
| SSOT 消费者遗漏 ⟦C3⟧ | pack 安装/验证/索引 | 中：门绿但数据指向已删路径 | §4.4 全清单 + V-P1 活目录 grep；AC20 |

---

## 10. Gate 2 / Next Steps

**建议专家（dual Gate 2）**：release/sync、installer data-safety、migration、shell-portability、架构。**审查重点**：§3.L（迁移/用户数据）、§3.M（旧 updater 兼容）、§4.4（消费者完整性）、6.4 SAFETY。

1. Alex 完成本 handoff（READY_FOR_GATE2）——两版方案已合并，5 条 Codex 约束已落点。
2. dual Gate 2（磁盘审查，Codex 走显式 subagent）→ 记于 `.tad/evidence/reviews/`；按 `gate-design` 每类门配负控（V-P5/V-P6/V-P7）。
3. **已锁定，无需再审**：版本 = **v3.0.0 一步落地**（§6.1）；SSOT = **`.agents/skills`**（§4.1）；OpenCode = 后续独立项（§7）。仅剩的人决策点 = **是否授权 Blake 开始执行 S0**（以及发布时的 publish 授权）。
4. Blake 按 §6.2 S0–S9 落地 → Gate 3 → Alex Gate 4 →（若人决定）发布。

---

## 11. Grounding / Verification

- **HEAD**：`c32bde27` (`release: v2.44.6`)，`.tad/version.txt` = `2.44.6`。
- **SSOT 等价实测**：`diff -rq -x local .claude/skills .agents/skills` → 空（exit 0）；`.claude/skills` 65 entries，`.agents/skills` 64（差 `local/`，gitignored）。
- **`.claude/` tracked 非 skill 文件（16）**：`.claude/agents/{security-auditor,spec-compliance-reviewer}.md`、`.claude/commands/README.md`、`.claude/rules/shell-portability.md`、`.claude/settings.json`、`.claude/settings.json.v2-backup`、`.claude/workflows/*.workflow.js`（10）。
- **关键 file:line**：`tad.sh:514/519-536/533/1162/1279/2485/2488/2698/2702/1868/2064`；`release-verify.sh:102-104/564/790-792/905-1021`；`.tad/platform-codes.yaml:6-18`；`bin/tad-install.mjs:128/153`；`.tad/config-workflow.yaml:791/796`；`.tad/config-agents.yaml:326`；`.tad/scripts/yolo-harness-profiles.json:18-35`；`.tad/scripts/phase2-pair-driver.mjs:39-40/773-778/797`；`detect-platform.sh:22-38`；`memory-redirect.sh:11/15`。
- **5 条 Codex 约束的落点证据（本轮复核）**：
  1. `.tad/hooks/lib/migration-draft.sh:94`（scope 含 `.claude/`/`CLAUDE.md`）；`.tad/hooks/lib/migration-engine.sh:72`（allow-list 含 `.claude/*`）；`.tad/migrations/2.26.0-to-2.27.0.yaml:6-25` + `2.42.0-to-2.43.0.yaml:21-33`（历史删具体 `.claude/skills/**` 文件）；`tad.sh:1565-1577`（chain gap = WARN，非致命）。
  2. `.tad/scripts/tad-update.sh:119-132`（detect `both`）、`:280`（透传 `--platform "$platform"`）；`tad.sh:528-536`（校验）、`main():2485` vs `take_rollback_snapshot:2702`（顺序）。
  3. `.tad/scripts/capability-skill.sh`、`.tad/capability-packs/*/install.sh`（26）、`.tad/scripts/pack-eval-runner.sh`、`.tad/hooks/lib/{pack-registry-driftcheck,brain-index-gen,runtime-freshness-verify}.sh`、`.tad/capability-packs/pack-collisions.yaml:33-83`、`.tad/scripts/phase2-pair-driver.mjs`。
  4. `.tad/scripts/phase2-pair-driver.mjs:775`（`-p … --model … 'sonnet'`）、`:39-40`（family 默认 `'claude'`）；`.tad/scripts/yolo-harness-profiles.json:18-35`。
  5. `.tad/deprecation.yaml:20-39`（`.codex/` 混合归属裁定先例）、`:44-86`（历史只删 TAD 自有 `.claude/commands/*.md`）；`tad.sh:1867-1878`（`snap_one`/`ROLLBACK_PRE_TOP`）、`:2047-2060`（预存在目录豁免整树删）。
- **模式参照**：`HANDOFF-2026-09-15-notebooklm-deprecation`（retire-not-delete）；本单是**移除**，故用 `### Removed` 而非只 `### Deprecated`。
- **来源文件**：`HANDOFF-2026-09-15-claude-decouple-design.md`（已 SUPERSEDED）；`HANDOFF-2026-09-15-claude-removal-plan-codex.md`（Codex 摘要，5 约束已并入本文件）。

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-09-15
**Merged**: DeepSeek/Alex S0→S9 skeleton + Codex 5 constraints（见页首「合并来源」）
**Status**: READY_FOR_GATE2
