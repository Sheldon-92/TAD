# COMPLETION-2026-09-15-platform-adapters-p1p3

**Task ID**: `TASK-20260915-OPENCODE-CURSOR-P1P3`
**From:** Blake (Execution Master)
**Date**: 2026-09-16
**Commit**: `2fb80bf5` — `feat(installer+docs): OpenCode/Cursor P1P3 support [TASK-20260915-OPENCODE-CURSOR-P1P3]`
**Pushed**: NO — 本地 commit，ahead origin/main 1，未 push；无 tag；无版本 bump。（2026-10-04 订正，TASK-20261004：上一句已过期——commit `2fb80bf5` 现已在 origin/main，本地与远端 0/0；原文保留，本注为订正，不静默改写。）

---

## 1. 改了什么（9 文件，与 handoff §6.1 闭集一致）

| Path | 变更 |
|------|------|
| `tad.sh` | P1：`KNOWN_PLATFORMS="codex opencode cursor"`；`validate_platform` 首 arm → `codex\|opencode\|cursor) return 0`；usage 文本列出三目标（默认仍 `codex`）。hooks guard / `resolve_platform` / `project_opencode_command` 未动 |
| `.tad/platform-codes.yaml` | P1：追加 `opencode:` / `cursor:` 块（各 `extra_deny: []` + `extra_root_files: ["AGENTS.md"]`） |
| `AGENTS.md` | P3：`Harness activation` 句（`$alex`=Codex，`/alex`=OpenCode/Cursor）+ v3.1 runtime 状态块 + Codex-Specific Notes 限域 + Known Gaps（P2/P4） |
| `README.md` | P3：去"only target / sole runtime"，三 harness 声明 + harness-scoped 激活语法 |
| `INSTALLATION_GUIDE.md` | P3：去"唯一目标"，opencode/cursor 合法目标行 + Codex 限域 hooks + Known-Gaps 行 |
| `.tad/codex/README.md` | P3：Codex = hook-enabled runtime；OpenCode/Cursor supported（hooks 经 P2，未实现） |
| `docs/MULTI-PLATFORM.md` | P3：三 harness + 去 single-target 表述 |
| `.agents/skills/_archived/doc-organization.md` | FR8 hygiene：`git mv`（内容 0 改动，`R100`） |
| `.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md` | 设计权威本体随 commit 入库 |

**Staging 偏差记录**：指令原 pathspec 含新旧双路径（`.../doc-organization.md` + `.../_archived/doc-organization.md`），
但 rename 的 source 侧已 staged（worktree/index 均无旧名），`git add` 报 `pathspec ... did not match any files` 且原子失败、索引未污染。
改用其余 9 路径执行（rename 由新路径侧承载），闭集意图不变。禁止的 `git add -A/.` 未使用；
`NEXT.md`、`docs/pm/intent.md`、`docs/pm/now.md` 的 worktree 脏状态原样保留、未入 commit；stash（`pre-rebase-v2443-1788905904`）绝未动。

## 2. AC 结果

- **AC12（commit 范围 set-equality）**：字面命令（无 `-M` 的 plumbing `diff-tree`）把 `R100` 拆成 `A`+`D`，
  报 `EXTRA=['.agents/skills/doc-organization.md'] / DELETED=[D 行]` —— 纯属 rename 检测缺失（本机 `diff.renames` 未设置），非内容问题。
  加 `-M`（恢复 handoff §5.7 预设的 `FR8 is an R, allowed` 语义）后：**`MISSING=[] EXTRA=[] DELETED=[]` → PASS**。
- AC1–AC11：本 turn 未重跑 /tmp probe 全量回放（实现内容即上一 turn 已落盘改动，本 turn 只做 stage+commit+AC12）；
  完整 Gate 3 Layer-1 回放（含 probe transcript）归属 manifest 的 `gate3-evidence-platform-p1p3.md`，本 turn 未写该文件。

## 3. Gate 结论

- **Gate 3**：部分 — 范围完整性（AC12）PASS；AC1–AC11 probe 回放证据待 `gate3-evidence-platform-p1p3.md` 补齐后 close。
- **Gate 4**：**CONDITIONAL PASS**（PM 决定：commit 到本地，不 push；无发版指令，v3.0.1 以后再议）。
- **未 push 确认**：`git log origin/main..HEAD` 仅 `2fb80bf5`；`git status -sb` = `main...origin/main [ahead 1]`；无 tag 操作。

## 4. Gate 2 waiver（证据缺失说明）

Manifest 声明的 Gate 2 双审文件（`.tad/evidence/reviews/2026-09-15-gate2-review-platform-p1p3-{spec,scope}.md`）**不在盘**。
Waiver 理由：S 号小修（放宽一道 case 分支 + 两块 YAML + live 文档诚实化 + 一次 `git mv`），
设计即 handoff 本体（Alex 直写，§6.2/§6.3 精确到行号与字面 token，
§9.1 Dry-Run Log 已在基线实测验证 AC 手段非空），Gate 2 以 handoff 评审代替，不补文件。
P2/P4 仍为 Known Gaps（见 `AGENTS.md`），不在本刀范围。

## 5. 只读边界

`docs/pm/**` 只读不写（脏文件未碰）；`CHANGELOG.md` / `PROJECT_CONTEXT.md` / `NEXT.md` / 版本文件未动；
无 push / tag / bump / release / delete。
