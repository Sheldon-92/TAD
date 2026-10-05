# Gate 3 独立 CODE 评审 — Platform Adapters P1+P3

- **Handoff**: `.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md` (AC1–AC12)
- **评审身份**: Blake (Execution Master), Gate 3 独立评审 — 只评审不写实现代码
- **日期**: 2026-09-16
- **工作区基线**: `main @ 20223774` (release v3.0.0), 改动未 commit（`git diff HEAD` 生效中；`git diff --cached` 仅含 FR8 rename）
- **约束遵守**: docs/pm 只读未写；无 commit；未改实现代码

## 1. 范围核对（handoff §6.1 vs 工作区）

§6.1 期望集合（9 路径，含 handoff 本体）:

```
tad.sh, .tad/platform-codes.yaml, AGENTS.md, README.md,
INSTALLATION_GUIDE.md, .tad/codex/README.md, docs/MULTI-PLATFORM.md,
.agents/skills/_archived/doc-organization.md (R from .agents/skills/doc-organization.md),
.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md
```

工作区 `git diff HEAD --name-status` 实际（10 行 tracked + 6 untracked）：

- ✅ 8 处 P1+P3 改动全部在 §6.1 内，逐项与 §6.2/§6.3 对齐（细节见 §2–§4）
- ✅ 零 `D` 删除；FR8 为 `R100` rename 且 `diff` 证实 byte-identical（见 §4）
- ✅ 记录守卫干净：`CHANGELOG.md / PROJECT_CONTEXT.md / OBJECTIVES.md / ROADMAP.md / HISTORY.md / docs/CODEX-USER-GUIDE.md / docs/codex-guide.html / .tad/brain-index.md / .tad/templates/ / package.json / .tad/version.txt / .tad/scripts/tad-update.sh / bin/ / .tad/archive/ / .tad/evidence/` 全无 diff（§6.4 遵守）
- ✅ skill 正文未碰：`.agents/skills/alex/SKILL.md` 无 diff，`NOT_via_alex_auto` count=2 存活
- ⚠️ **EXTRA（§6.1 之外，commit 时必须排除）**：
  1. `NEXT.md` (M, +7) — Codex ledger 重验 ticket 条目，与本刀无关；§6.4 明确列为 out-of-commit，且 §5.1 的 pre-existing-dirty 豁免只覆盖 `docs/pm/*`、**不覆盖 NEXT.md**
  2. `docs/pm/intent.md` (M)、`docs/pm/now.md` (M) — 内容为 model-routing/version 外宣更新，与本刀无关；§5.1 已预告其可能 pre-existing dirty 并要求 leave them / 不进 commit
  3. Untracked（他线工作）：`.tad/active/TICKET-20260916-codex-ledger-reverification.md` + 4 个他刀 handoff（`COMPLETION-20260915-notebooklm-deprecation.md`、`HANDOFF-2026-09-15-claude-decouple-design.md`、`HANDOFF-2026-09-15-claude-removal-plan-codex.md`、`HANDOFF-2026-09-15-claude-removal-plan.md`）— 不得 `git add -A` 带入
- Handoff 本体目前 untracked（`??`）— §5.6 要求 `git add --` 仅 §6.1 路径 + 本 handoff，符合预期（待 Blake commit 步骤执行）

**结论**: P1+P3 八处改动无超范围写入；工作区另有 3 tracked EXTRA + 6 untracked 他线文件，属隔离义务而非本刀缺陷。

## 2. `validate_platform` 放宽回归检查

`git diff HEAD -- tad.sh` 确认仅 4 处语义变更，余下全部 untouched：

| 检查点 | 结果 |
|---|---|
| `KNOWN_PLATFORMS="codex opencode cursor"` (L514) | ✅ 与 §6.2 一致 |
| accept arm `codex\|opencode\|cursor) return 0` | ✅ 仅此一行逻辑变更 |
| L511-518 注释块改写（含 P2 known-gap 声明，保留 drift note） | ✅ 与 §6.2 字面一致 |
| L366 usage `target platform (codex\|opencode\|cursor)` | ✅ 与 §6.2 一致 |
| tombstone 臂 `both\|*claude*`（恢复命令 + `exit 1`） | ✅ 逐行 untouched，fail-before-mutation 保留 |
| `*)` 未知平台臂（含 `$KNOWN_PLATFORMS` 插值报错） | ✅ untouched，错误信息自动带新三值 |
| `resolve_platform` 默认 `codex` | ✅ 全函数 untouched（现场 `awk` 抽取验证） |
| hooks 生成守卫 `if [ "$PLATFORM" = "codex" ]` (L1300) | ✅ 代码 untouched；opencode/cursor 不生成 hooks（AC4 实测证实） |
| codex version detection `if [ "$PLATFORM" = "codex" ]` (L2372) | ✅ untouched |
| `project_opencode_command` (L2321) | ✅ 函数/diff 均未动（仅 L1348 既有调用） |

实测（本机 live，非引用 handoff 旧值）：

- AC2 探针：`codex=ACCEPT / opencode=ACCEPT / cursor=ACCEPT / claude-code=REJECT / both=REJECT / bogus=REJECT` ✅
- AC4 探针：`opencode=OK / cursor=OK`（skills + AGENTS.md 存在、无 `.codex/hooks.json`）✅
- AC11 回归：`codex=OK`（`.codex/hooks.json` + skills 存在）✅

**结论**: 放宽无回归。codex 默认路径、tombstone 逻辑、hooks 门控行为全保留。

注（cosmetic，非缺陷）：L1298 注释 `# Codex hooks.json generation (v3.0.0: codex is the only target)` 与 L2367 注释 `# v3.0.0: codex is the only target; skills live in .agents/skills.` 仍写 "only target"，与新行为字面矛盾。但 §6.2 明令 **Do NOT touch L1298 guard**，且两处均为注释零语义影响；AC 亦无覆盖。故记为观察项，不列入条件。

## 3. `platform-codes.yaml` 格式与消费点一致性

- Diff：仅追加 10 行（`opencode:` / `cursor:` 两块），`codex:` 块零改动 ✅
- 格式：2 空格缩进、与 `codex:` 块逐键同构（`label / extra_deny: [] / extra_root_files: ["AGENTS.md"]`），`cat -A` 无 tab、无尾随空格 ✅
- DRIFT 契约（tad.sh L511-513 `must match platforms: keys`）：yaml keys `{codex, opencode, cursor}` == `KNOWN_PLATFORMS` 三值 ✅
- 消费点（安装器自有 parser，stdlib 实测）：
  - `parse_platform_root_files` → `codex:[AGENTS.md] / opencode:[AGENTS.md] / cursor:[AGENTS.md]` ✅（AC3）
  - `parse_platform_extra_deny` → 三平台均为 `[]`，`bogus` → `[]`（空安全，无误拒/误放）✅
  - `label:` 键按 handoff §4.1 为 inert，未被 parser 读取 ✅
- FR2 "No other key added" ✅（无 hooks 相关键，P2 保持 gap）

**结论**: 格式与消费点一致，无缺陷。

## 4. P3 文档 + FR8 卫生抽查

- AC1 `grep -cF 'KNOWN_PLATFORMS="codex opencode cursor"'` = 1 ✅
- AC5 `bash tad.sh --help | grep -cE 'opencode\|cursor'` = 1 ✅
- AC6 AGENTS.md tokens：`Harness activation`✅ `OpenCode`✅ `Cursor`✅ `Both platforms receive` 已除✅ `Codex-Specific Notes (Codex harness only`✅
- AC7 AGENTS.md `Known Gaps` 段含 `P2` + `P4`（C-5/C-11/C-12 by reference）✅；位置在 `Frozen Channel` 之前 ✅
- AC8 README：无 `only install target` / `sole runtime since v3.0.0`，含 `opencode` + `cursor` ✅
- AC9 兄弟文档：`.tad/codex/README.md` 无 `sole runtime since v3.0.0`✅；`docs/MULTI-PLATFORM.md` 无 `single install target`✅；`INSTALLATION_GUIDE.md` 无 `唯一目标`✅（且含 `opencode` ×5）；三者 `BAD=[]` ✅
- AC10：`.agents/skills/*.md` → `STRAYS=[]` ✅；FR8 rename `R100`、`similarity 100%`、`diff` byte-identical ✅
- AC12：**待 commit 后运行**（`git diff-tree HEAD` 需 commit freeze；当前 HEAD 仍为 v3.0.0 基线）。前置条件：commit pathspec 必须恰为 §6.1 九路径（排除 §1 所列 EXTRA + untracked），否则 MISSING/EXTRA 即 FAIL。

## 5. 结论

**CONDITIONAL**（功能零缺陷，放行条件仅为 commit 隔离）：

1. commit 仅含 §6.1 九路径（`git add --` 显式列出，禁用 `git add -A`）；`NEXT.md`、`docs/pm/intent.md`、`docs/pm/now.md` 不得带入；6 个 untracked 他线文件不得带入。
2. commit 后运行 AC12（handoff §9.1 原命令），要求 `MISSING=[] EXTRA=[] DELETED=[]`，`subject` 含 `TASK-20260915-OPENCODE-CURSOR-P1P3`。
3. 观察项（不阻塞）：tad.sh L1298/L2367 两处 "only target" 注释已过时；如需清理应另开卫生刀，不在本刀触碰 guard 行。

功能性缺陷：**无**（AC1–AC11 实测全 PASS；AC12 待 commit 后机械执行）。
