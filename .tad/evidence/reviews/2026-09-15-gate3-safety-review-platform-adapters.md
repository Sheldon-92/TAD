# Gate 3 SAFETY Review — Platform Adapters P1+P3 (installer 放宽 + 文档修正)

- **Reviewer**: Blake (Execution Master), Gate 3 独立 SAFETY 评审 — 只评审，不写代码
- **Date**: 2026-09-16
- **Handoff**: `.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md` (TASK-20260915-OPENCODE-CURSOR-P1P3)
- **Scope**: 工作区改动 vs handoff §6.1 commit set；docs/pm 只读；不 commit
- **Knowledge**: `principles.md` + `patterns/_index.md` 已读（Blake 激活 ingress）

## 1. 用户数据删除/修改核查 — PASS

| 检查 | 命令 | 结果 |
|------|------|------|
| 删除项 | `git diff HEAD --diff-filter=D --name-status` | 空 — **zero `D`** |
| 改动集 | `git diff HEAD --name-status` | 1×R100 (`doc-organization.md` → `_archived/`, similarity 100%, 内容零改动，handoff FR8 允许的唯一 rename）+ 10×M，无新增 untracked 归属本刀 |
| `.claude/` 本机数据 | `git ls-files .claude` → 空（未跟踪）；`git status --ignored .claude/` → `!! .claude/`（被忽略）；磁盘 `settings.local.json` (16KB) 未动 | 仍被忽略、无新增删除 |
| skill 正文 / hooks | `git diff HEAD -- .agents/skills/alex/ .agents/skills/blake/ .tad/hooks/` → 空 | 未碰（符合"不重设计 skill 正文"约束） |

## 2. Installer 放宽执行面核查 — PASS

- `git diff HEAD -- tad.sh` 仅 4 处，与 handoff §6.2 逐行一致：usage L366、注释重写、`KNOWN_PLATFORMS="codex opencode cursor"`、`codex|opencode|cursor) return 0`。**未动**：hooks guard (`tad.sh:1300` `if [ "$PLATFORM" = "codex" ]`，内为 `.codex/hooks.json` 生成）、`resolve_platform` (默认仍 `codex`)、codex version detection (`:2372`)、`project_opencode_command` (`:2321`, 全平台预先存在行为，非新增面）。
- `.tad/platform-codes.yaml` diff = 追加 `opencode:`/`cursor:` 两块（`extra_deny: []` + `extra_root_files: [AGENTS.md]`），codex 块未动。deny 为空 → 无排除语义变化，无新执行面。
- `/tmp` 活探针（仓库树只读，安装目标均为 `mktemp -d` + `rm -rf`）：
  - `opencode`: rc=0, skills=yes, AGENTS.md=yes, hooks=no
  - `cursor`: rc=0, skills=yes, AGENTS.md=yes, hooks=no
  - `codex`: rc=0, hooks=yes（零回归）
  - 拒绝臂保持：`claude-code=REJECT / both=REJECT / bogus=REJECT`（fail-before-mutation 成立；注：单 shell 循环会被 `exit 1` 中断，验证时已按 handoff AC2 方式每平台隔离 `bash -c`）。
- 结论：放宽 = 仅 gate 分支 + YAML 数据；**hooks 仍 codex-gated 成立**；opencode 目标附带的 `/tad-update` 投影是全平台预先存在行为（handoff §2.1 #5 UNCHANGED），非未预期副作用。

## 3. Known Gaps (P2/P4) 声明诚实性 — PASS

- `AGENTS.md` 新增 `## Known Gaps (OpenCode / Cursor)`：P2 点名 `.opencode/plugins/tad.ts` + `.cursor/hooks.json` 未发货及后果（无 trace/ask-user 捕获）；P4 明示 "open-box usable rests on vendor docs + installer probe; no live harness transcript"；C-5/C-11/C-12 仅 by-reference deferred — 与 handoff §10 逐项对应，**无夸大、无把 gap 说成已实现**。
- `INSTALLATION_GUIDE.md` 一行 Known-Gaps (P2/P4) 与 AGENTS 一致。`.tad/codex/README.md`、`docs/MULTI-PLATFORM.md` 均保留 "hooks P2 — not yet" 限定。
- 观察（非安全项）：README/INSTALLATION_GUIDE/MULTI-PLATFORM 头部已写 "3.1"，而 `version.txt` 按 NFR4 不 bump — 系 handoff §6.3 授权措辞，不构成安全问题。

## 4. 结论：CONDITIONAL PASS（条件项，非红线）

**无安全红线问题。**

条件项（commit hygiene，Blake 落盘时执行）：
- **C1**: 工作区有三处非本刀 dirty，必须排除在本刀 commit 外，否则 AC12 set-equality FAIL：`NEXT.md`（codex-ledger 2026-09-16 另一刀内容）、`docs/pm/intent.md`、`docs/pm/now.md`（handoff §5.1 已预告 pre-existing dirty，leave them）。另有其他刀的 untracked handoffs/TICKET（`HANDOFF-2026-09-15-claude-*`、`COMPLETION-2026-09-15-notebooklm-*`、`TICKET-20260916-*`）不得 sweep。Commit 必须 pathspec 限定 §6.1 九路径 + 本 handoff（含 untracked 的 `HANDOFF-2026-09-15-platform-adapters-p1p3.md` 需 `git add --` 显式纳入）。
- **C2** (观察): "3.1" 文档头 vs version 未 bump — handoff 授权，无需动作。

满足 C1 即视为 PASS；回滚保证成立（纯加法 + 文档 + 一次 git mv，无状态/迁移/网络）。
