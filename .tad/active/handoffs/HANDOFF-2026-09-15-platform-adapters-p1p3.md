---
task_id: TASK-20260915-OPENCODE-CURSOR-P1P3
task_type: mixed            # shell installer + YAML config + live docs
express: false
skip_knowledge_assessment: no
e2e_required: no
research_required: no
status: READY_FOR_GATE2
feedback_required: false
git_tracked_dirs: []
gate4_delta: []
---

# HANDOFF-2026-09-15-platform-adapters-p1p3

**Task ID**: `TASK-20260915-OPENCODE-CURSOR-P1P3`
**From:** Alex (Solution Lead) **To:** Blake (Execution Master)
**Created**: 2026-09-15
**Status**: READY_FOR_GATE2 (design only — Blake lands files; **no commit by Alex**)
**Epic:** N/A — bounded S-sized mini-fix under the OpenCode/Cursor research verdict
**Mode**: installer gate + config + live-doc honesty + one hygiene move. **No push / tag / bump / release / delete.**
**Supersedes verdict**: `.tad/evidence/research/2026-09-15-opencode-cursor-firstclass/findings.md` — adopts its recommendation "defer P2/P4; only do the S-sized honesty/install fixes (P1+P3)".
**Channel**: Alex ≠ Blake. Dual Gate 2 on disk. Draft reviewers run via explicit subagent prompting (Codex TAD custom agents not yet active).

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-09-15 (Alex design; dual disk reviews recorded §9.2)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | P1 relaxes the `validate_platform` fail-before-mutation gate + adds 2 `platform-codes.yaml` deltas; P3 rewrites the live docs that claim exclusivity. No new pipeline, no hook work. |
| Components Specified | ✅ | §6.2 exact shell edits (with line anchors); §6.3 exact doc edits + canonical tokens. |
| Functions Verified | ✅ | `validate_platform` `tad.sh:519`, `KNOWN_PLATFORMS` `:514`, `resolve_platform` `:539`, `parse_platform_root_files` `:658`, hooks guard `:1298`, `project_opencode_command` `:2319` — all exist at HEAD (verified by extraction/Read). |
| Data Flow Mapped | ✅ | `--platform` → `validate_platform` → `PLATFORM` → `parse_platform_extra_deny/_root_files` → skill copy + root-file copy; hook generation remains codex-gated. §4.1. |

**Process Gate 2 = dual reviews on disk.** Do **not** wait for a human to type `/gate 2`. Human still says `当 Blake` for role switch.

**Alex确认**: 本 handoff 是设计权威。Blake 只改文件、不重设计、不新增 hook 适配、不删除文件、不发布。P2/P4 明确列为 Known Gaps（§10）。

---

## MQ (human lock)

1. **User**: TAD 框架维护者（grokbox 侧），不是终端产品用户。
2. **Problem**: 研究结论 `findings.md` 判定 OpenCode/Cursor 现状是"open-box usable, not first-class"：技能树天然可用，但 (a) 安装器 `validate_platform` **硬拒**非 codex 目标（`findings.md` C-1），(b) `AGENTS.md` / `README.md` / `INSTALLATION_GUIDE.md` 仍宣称 Codex 是**唯一目标 / sole runtime**、`$alex` 是通用激活语法（C-6/C-7）——**文档在说谎**。
3. **Scope**: **只做 P1 + P3**。P1 = 允许 `opencode` / `cursor` 安装目标（installer 实质与平台无关）；P3 = 修正 Codex 专属文档/触发语法 + 一处卫生（OpenCode 会误注册的裸 `.md` 伪技能）。P2（hooks 适配）与 P4（真机回归）**不做，记为 Known Gaps**。
4. **Out**: 不写 OpenCode plugin / Cursor hooks（P2）；不跑真机 OpenCode/Cursor 回归（P4）；不做 `/alex`/`/blake` slash 命令投影（C-5）；不改 `tad-update.sh` 的 `--platform` 门（C-11，functionally works）；不动 `CHANGELOG.md` / `PROJECT_CONTEXT.md` / `NEXT.md` / `.tad/active/handoffs/*`（records）；**`docs/pm/**` 只读不写**；不 bump 版本；不发布。
5. **Success**: `bash tad.sh --source <repo> --platform opencode|cursor --yes` 在空目录成功，产出 `.agents/skills/alex/SKILL.md` + `AGENTS.md` 且**不生成** `.codex/hooks.json`；所有 live 平台声明不再写"唯一目标"，激活语法区分 harness；`--platform codex` 行为零回归。
6. **Teeth**: dual Gate 2；Alex ≠ Blake；codex 回归 AC；commit scope set-equality；SAFETY/records 守卫。

**Gate 1**: problem / ICP / scope / verifiable ACs — PASS (§9.1 + this lock)。

### MQ evidence

| MQ | Triggered? | Evidence |
|----|------------|----------|
| MQ1 historical | yes | §2.1 survey + research `findings.md` C-1/C-6/C-7/C-8/C-13；`tad.sh:4` 自身头注释已是 "Codex-first, multi-harness neutral"；安装器 quick-start（`tad.sh:2891`）已打印 `/alex, /blake, /gate`，与 `AGENTS.md`/`README.md` 的 `$alex` 说法冲突。 |
| MQ2 functions | yes | §6.2 declares every referenced function; extraction dry-runs in §9.1 Dry-Run Log. |
| MQ3 data flow | no | No backend/frontend fields. |
| MQ4 visual | no | No UI states. |
| MQ5 state sync | no | Single source: `tad.sh` + `.tad/platform-codes.yaml`; no duplicated platform list beyond the documented `KNOWN_PLATFORMS` drift comment (updated in §6.2). |
| MQ6 research | yes | `.tad/evidence/research/2026-09-15-opencode-cursor-firstclass/findings.md`（vendor docs retrieved 2026-09-16）＋ live repo extraction probes. |

---

## 1. Task Overview

### 1.1 What We're Building

两件小事：
1. **P1（installer target）**：把 `tad.sh` 的 `validate_platform` 从"只认 `codex`"放宽为认 `codex | opencode | cursor`，并给 `.tad/platform-codes.yaml` 补 `opencode` / `cursor` 两个平台块（`extra_root_files: [AGENTS.md]`，`extra_deny: []`）。
2. **P3（routing & hygiene）**：修正所有 **live** 文档里"Codex 是唯一目标 / sole runtime"与"`$alex` 是通用激活语法"的不实声明，并把 `AGENTS.md` 的 "Codex-Specific Notes" 明确限定为 Codex-only；顺带把 `.agents/skills/doc-organization.md` 从 skills 根移入 `_archived/`（OpenCode 会把根级裸 `.md` 当伪技能注册）。

### 1.2 Why

- `findings.md` 证明 K（技能树 + `AGENTS.md` 路由）在 OpenCode/Cursor 上**零改动可用**；唯一挡路的是安装器那道**硬拒**。这是最低风险的 S 改动，且对现有 Codex 用户零行为变化。
- 文档继续写"唯一目标"会让非 Codex 用户以为不支持、或让 agent 读到错误路由指令——**在用户不阅读时，真正生效的是执行体**（安装脚本/首屏输出），所以 P3 必须覆盖 live docs 而非只改一处。

### 1.3 Intent Statement

**真正要解决的问题**：让"安装器 + live 文档"与"OpenCode/Cursor 已可 open-box 使用"这一事实**一致**；不假装实现了 hooks（P2）或真机验证（P4）。

**不是要做的（避免误解）**：
- ❌ 不是实现 OpenCode plugin 或 Cursor hooks（P2 — Known Gap）。
- ❌ 不是在真实 OpenCode/Cursor 上跑回归（P4 — Known Gap）。
- ❌ 不是新增 `/alex` `/blake` slash 命令投影（C-5）。
- ❌ 不是改 `tad-update.sh` 的 `--platform` 门（C-11；`detect_platform` 已返回 codex，`$tad-update` 可用）。
- ❌ 不是删除任何历史记录 / CHANGELOG / PROJECT_CONTEXT。
- ❌ 不是发布或 bump 版本。

**Blake请确认理解**：这是"放宽一道 case 分支 + 加两块 YAML + 改几处 live 文档声明 + 移一个孤儿 .md"；不写 hook、不跑真机、不发布。

---

## 📚 Project Knowledge

**Loaded this knife:** `principles.md`；`patterns/_index.md` → `handoff-design.md`, `ac-verification.md`。

### Research Findings (Local Wiki)

Topic: OpenCode/Cursor first-class support | Canon: `research/canon/_index.md`（无本主题条目）
| Verdict: `.tad/evidence/research/2026-09-15-opencode-cursor-firstclass/findings.md`
（结论：不做大 Epic；若 Codex 仍是 house runtime，只做 **P1+P3 (S)**，P2/P4 记为 known gap）。

### ⚠️ Blake 必须注意的历史教训

1. **同病治一半 / 立项理由指向文档时，先找真正在跑的那段代码**（`principles.md` 2026-08-14）— 平台声明散落在 `tad.sh` usage/help/banner、`AGENTS.md`、`README.md`、`INSTALLATION_GUIDE.md`、`.tad/codex/README.md`、`docs/MULTI-PLATFORM.md`。§6.3 是**全量 live 载体清单**，不是示例；AC8/AC9 专门防守漏改。不要只改用户点名的 README。
2. **Deny-List / diff-r 是通用遗漏捕手**（`principles.md`）— commit 后必须证明 pathspec **双向集合相等**（AC12），MISSING 与 EXTRA 都算 FAIL。
3. **Verification Commands That Read the Git Index Are Vacuous Before Staging**（`ac-verification.md`）— AC12 依赖 `git diff-tree HEAD`，必须在 `git add` + commit 之后运行。
4. **Design-Agent AC Commands Systematically Assume a Machine That Isn't This One**（`ac-verification.md`）— 本仓库 `python3` **无 `yaml` 模块**（ban `import yaml`）；所有 AC 只用 stdlib/grep/awk/bash。禁止无保护 `$(grep -l ...)`（空集会 hang）。
5. **Rewiring a Gate's Prose Can Trip a `grep -c` SAFETY Count**（`principles.md`）— 不要碰 `.agents/skills/alex/SKILL.md` 的 `NOT_via_alex_auto: true` / `forbidden_implementations` / `anti_rationalization_registry`；本次**不编辑 skill 正文**（C-13 已延后）。
6. **Never Hand-Write What an Existing Tool Already Does**（`principles.md`）— 放宽平台走 `validate_platform` 的 case 分支，不要新增"再判断一次"的脚本；YAML 解析用安装器**已有**的 `parse_platform_*` 函数验证。

Pack pointers (not loaded): `web-deployment`（active，与 installer 相关但不 load）。Do not escalate.

---

## 2. Background

### 2.1 Survey — platform-exclusive claims + installer gate at HEAD

| # | Surface | Where (HEAD) | Current claim / behavior | Fate |
|---|---------|--------------|--------------------------|------|
| 1 | Platform gate | `tad.sh:514,519-537` | `KNOWN_PLATFORMS="codex"`; `validate_platform` accepts only `codex`, rejects `both\|*claude*`, unknown → exit 1 | **RELAX** |
| 2 | Platform deltas | `.tad/platform-codes.yaml` | only `codex:` block | **ADD** `opencode:` `cursor:` |
| 3 | Usage/help | `tad.sh:366` | `target platform (codex). Default: codex` | **EDIT** |
| 4 | Hooks generator | `tad.sh:1298` | `if [ "$PLATFORM" = "codex" ]` → writes `.codex/hooks.json` | **UNCHANGED** (P2 gap; guards AC4/AC11) |
| 5 | OpenCode updater projection | `tad.sh:2319` | projects `.opencode/commands/tad-update.md` on **every** install (not platform-gated) | **UNCHANGED** (positive: opencode target gets `/tad-update`) |
| 6 | AGENTS.md header | `AGENTS.md:9-12` | "Codex is a first-class platform"; **stale** "Both platforms receive the same SKILL.md files" | **REWRITE** |
| 7 | AGENTS.md activation | `AGENTS.md:16-23` | `Use `$alex` / `$blake` …` as the universal route | **REWRITE** (harness-scoped) |
| 8 | AGENTS.md Codex notes | `AGENTS.md:140` | `## Codex-Specific Notes` read as universal | **SCOPE** heading |
| 9 | AGENTS.md gaps | (absent) | no OpenCode/Cursor known-gap record | **ADD** Known Gaps |
| 10 | README header/install | `README.md:5,74-83,169-184` | "`--platform codex` is the only target"; "sole runtime since v3.0.0" | **REWRITE** |
| 11 | INSTALLATION_GUIDE | `INSTALLATION_GUIDE.md:3,18,38,110-112,131-152` | "唯一目标"; `$alex`; Codex-only hook notes un-scoped | **REWRITE** |
| 12 | codex adapter README | `.tad/codex/README.md:3` | "sole runtime since v3.0.0" | **REWRITE** |
| 13 | Multi-platform guide | `docs/MULTI-PLATFORM.md:3-7,19` | "single install target (`codex`)"; Codex "sole runtime" | **REWRITE** |
| 14 | Skills root stray | `.agents/skills/doc-organization.md` | bare root-level `.md`, no `name`/`description` frontmatter → OpenCode surfaces pseudo-skill | **MOVE** → `_archived/` |

### 2.2 Current State vs Target

- **Have**: installer hard-rejects `opencode`/`cursor` before any mutation; six live docs assert Codex-exclusive runtime/target; stray `.md` at skills root.
- **Target**: `opencode`/`cursor` install cleanly (skills + `AGENTS.md`; no hooks); live docs describe three supported harnesses with harness-scoped activation; no stray skill-root `.md`.

### 2.3 Dependencies

None at runtime. Files: `tad.sh`, `.tad/platform-codes.yaml`, live docs. Probe uses `bash` + `git` + `mktemp` only. No network, no `node`, no `yaml` module.

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1** — `tad.sh` accepts `opencode` and `cursor` as `--platform` values: `KNOWN_PLATFORMS="codex opencode cursor"`; `validate_platform` gains `codex|opencode|cursor) return 0 ;;`. `resolve_platform` default **stays `codex`**. `both` / `*claude*` stay rejected before mutation.
- **FR2** — `.tad/platform-codes.yaml` gains `opencode:` and `cursor:` blocks, each with `extra_deny: []` and `extra_root_files: ["AGENTS.md"]`. No other key added (hooks projection is P2).
- **FR3** — Hook generation stays codex-gated: `opencode`/`cursor` installs must produce **no** `.codex/hooks.json`; `codex` installs unchanged.
- **FR4** — `tad.sh` usage/help text lists `codex|opencode|cursor` as valid targets (default `codex`).
- **FR5** — **Activation syntax honesty**: `AGENTS.md`, `README.md`, `INSTALLATION_GUIDE.md` state that `$alex`/`$blake` is the **Codex** invocation and `/alex`/`/blake` is the **OpenCode/Cursor** invocation (skills also model-selectable).
- **FR6** — **Platform-claim honesty** in live docs: remove every "only target"/"sole runtime"/"唯一目标" exclusivity claim from `AGENTS.md`, `README.md`, `INSTALLATION_GUIDE.md`, `.tad/codex/README.md`, `docs/MULTI-PLATFORM.md`; replace with "Codex / OpenCode / Cursor supported; Codex is the hook-enabled runtime".
- **FR7** — `AGENTS.md` "Codex-Specific Notes" is explicitly scoped to the Codex harness; `AGENTS.md` gains a **Known Gaps** subsection recording **P2 (hooks adapters)** and **P4 (live regression)** as not implemented; `INSTALLATION_GUIDE.md` carries one matching Known-Gaps line.
- **FR8** — Hygiene: `.agents/skills/doc-organization.md` no longer sits at the skills root; `git mv` into `.agents/skills/_archived/` (no content change, no delete). No `*.md` may remain directly under `.agents/skills/`.
- **FR9** — Records are **not** touched: `CHANGELOG.md`, `PROJECT_CONTEXT.md`, `NEXT.md`, `docs/pm/**`, `.tad/active/handoffs/*` (other contracts), `.tad/archive/**`, `.tad/evidence/**`, `docs/codex-guide.html`, `docs/CODEX-USER-GUIDE.md` (their statements remain true or are historical).

### 3.2 Non-Functional Requirements

- **NFR1** — Installer behavior for `--platform codex` is byte-for-byte unchanged (AC11 regression probe).
- **NFR2** — All changes are additive or doc-edits; **zero deletions, zero renames except the FR8 `git mv`**; no state migration.
- **NFR3** — No new runtime dependency; no network in ACs.
- **NFR4** — `docs/pm/**` read-only; no version-file bump.
- **NFR5** — Live-doc claims become consistent with the installer's own neutral phrasing (`tad.sh:4` "Codex-first, multi-harness neutral"; quick-start prints `/alex`).

---

## 4. Technical Design

### 4.1 Architecture Overview

```
--platform <name>
   │
   ├─ validate_platform()            [tad.sh:519]   ← P1 FR1 relaxes
   │     codex | opencode | cursor → return 0
   │     both | *claude*           → reject before mutation (unchanged)
   │     *                         → reject (unchanged)
   │
   ├─ PLATFORM = codex (default) / opencode / cursor
   │
   ├─ parse_platform_extra_deny(yaml, PLATFORM)   [tad.sh:631]
   ├─ parse_platform_root_files(yaml, PLATFORM)   [tad.sh:658] ← P1 FR2 feeds AGENTS.md
   │        → copies root files (AGENTS.md) for the chosen platform
   ├─ copy skills → .agents/skills/<name>          (platform-agnostic)
   ├─ project_opencode_command()  [tad.sh:2319]    → .opencode/commands/tad-update.md
   └─ if PLATFORM = codex: generate .codex/hooks.json   [tad.sh:1298]  ← UNCHANGED (P2)
```

**Why the "capability-pack installer" needs no change of its own.** `--packs` selection (`is_pack_skill` `tad.sh:701`, `is_selected_pack` `:1038`, copy loops `:1178`/`:1437`) contains **no `PLATFORM` reference**. The hard reject that blocks pack installs for OpenCode/Cursor is the **global `validate_platform` gate**, which runs at `main` before any mutation (`tad.sh:2363`). Fixing `validate_platform` (FR1) is therefore what unblocks capability packs on `opencode`/`cursor` — the pack path itself is already platform-agnostic (`findings.md` C-8).

### 4.2 Component Specifications

**`validate_platform` (P1 core).** Add `opencode`/`cursor` to the accept arm only:

```sh
validate_platform() {
    local p="$1"
    case "$p" in
        codex|opencode|cursor) return 0 ;;
        both|*claude*)
            ... unchanged rejection ...
        *)
            log_error "Unknown platform: '$p'. Valid platforms: $KNOWN_PLATFORMS"
            exit 1
            ;;
    esac
}
```

The `*)` message auto-reflects `KNOWN_PLATFORMS`, so no second literal to maintain.

**`platform-codes.yaml`.** Deny-delta model is preserved: shared core unchanged, two small per-platform deltas appended. `parse_platform_*` reset on `^  [a-z]` and only read `extra_deny:` / `extra_root_files:`, so `label:` is inert.

**Doc policy (P3).** Class boundary per `findings.md` + repo pattern:

| Class | Decision |
|-------|----------|
| Live routing / platform claim (agent or user reads it and acts) | **EDIT** (§6.3) |
| Dated historical record (CHANGELOG, PROJECT_CONTEXT, NEXT, other handoffs, archive, evidence) | **LEAVE** |
| Statements that are already true (`claude-code`/`both` still rejected) | **LEAVE** |
| Skill body prose (C-13 stale Claude refs) | **LEAVE** (deferred; §10) |

### 4.3 Decision summary

| Decision | Choice |
|----------|--------|
| P1 mechanism | Relax `validate_platform` case arm + `KNOWN_PLATFORMS`; add 2 YAML blocks |
| Default platform | Unchanged: `codex` |
| Hook generation | Unchanged: codex-gated (P2 gap) |
| Rejected values | Unchanged: `both` / `*claude*` (fail-before-mutation) |
| P3 coverage | All live platform/activation claims (§6.3), justified by "同病治一半" principle |
| Hygiene | `git mv` stray skill-root `.md` → `_archived/` (no delete) |
| P2 / P4 | **Not done** → Known Gaps in `AGENTS.md` + `INSTALLATION_GUIDE.md` |
| Version | No bump |

---

## 5. Blake 实施步骤

1. `git status` vs §6.1. Do **not** `git add -A`. `docs/pm/intent.md` + `docs/pm/now.md` may be pre-existing dirty — **leave them**.
2. Land P1: `tad.sh` (FR1/FR4) then `.tad/platform-codes.yaml` (FR2).
3. Verify P1 locally with the **/tmp probe** before docs: opencode + cursor installs succeed, no `.codex/hooks.json`; codex install unchanged (AC4/AC11).
4. Land P3: `AGENTS.md` → `README.md` → `INSTALLATION_GUIDE.md` → `.tad/codex/README.md` → `docs/MULTI-PLATFORM.md` (FR5–FR7).
5. Land FR8 hygiene: `git mv .agents/skills/doc-organization.md .agents/skills/_archived/doc-organization.md`.
6. `git add --` **only** the §6.1 tracked paths + this handoff. Commit subject must contain `TASK-20260915-OPENCODE-CURSOR-P1P3`.
7. Prove `git diff-tree --no-commit-id --name-status -r HEAD` has **zero `D`** (FR8 is an `R`, allowed) and the path set-equals §6.1 (AC12).
8. Completion report. **No push / tag / bump / release.**

---

## 6. File Structure

### 6.1 Modify — commit set

| Path | FR |
|------|----|
| `tad.sh` | FR1, FR4 |
| `.tad/platform-codes.yaml` | FR2 |
| `AGENTS.md` | FR5, FR6, FR7 |
| `README.md` | FR5, FR6 |
| `INSTALLATION_GUIDE.md` | FR5, FR6, FR7 |
| `.tad/codex/README.md` | FR6 |
| `docs/MULTI-PLATFORM.md` | FR6 |
| `.agents/skills/_archived/doc-organization.md` | FR8 (`git mv` from `.agents/skills/doc-organization.md`) |
| `.tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md` | this handoff |

### 6.2 Exact P1 edits

**`tad.sh`**

- L514: `KNOWN_PLATFORMS="codex"` → `KNOWN_PLATFORMS="codex opencode cursor"`
- L516-518 comment: replace the "the old dual-tree mode and any platform value naming that path are rejected" wording with (keep the drift note at L511-513 intact):
  ```
  # v3.1: `opencode` / `cursor` are accepted targets — the installer body is
  # platform-agnostic (same .agents/skills tree, same packs, same .tad/ core),
  # so these values only relax the fail-before-mutation gate. They do NOT add
  # lifecycle hooks or slash commands (Platform Adapters P2 — known gap).
  # `both` / `*claude*` stay rejected before any mutation.
  ```
- L519-537 `validate_platform`: first case arm `codex) return 0 ;;` → `codex|opencode|cursor) return 0 ;;`. **No other line changes** (rejection arms + `*)` untouched).
- L366: `echo "  --platform <name>  target platform (codex). Default: codex"` → `echo "  --platform <name>  target platform (codex|opencode|cursor). Default: codex"`
- **Do NOT touch**: L1298 hooks guard, L2370 codex version detection, L2319 `project_opencode_command`, `resolve_platform` L539-547 (default stays `codex`).

**`.tad/platform-codes.yaml`** — append (2-space indent, matching `codex:` block):

```yaml
  opencode:
    label: "OpenCode"
    extra_deny: []
    extra_root_files:
      - "AGENTS.md"
  cursor:
    label: "Cursor"
    extra_deny: []
    extra_root_files:
      - "AGENTS.md"
```

### 6.3 Exact P3 edits (canonical tokens — AC6/AC7 key on these)

Mandated literal anchors:
- `AGENTS.md` must contain `Harness activation` and both `OpenCode` and `Cursor`; must NOT contain `Both platforms receive`; heading must read `## Codex-Specific Notes (Codex harness only — not applicable to OpenCode/Cursor)`; must contain a `Known Gaps` section naming `P2` and `P4`.

**`AGENTS.md`**

- L9-12 block → replace with:
  ```
  > **Runtime status (v3.1)**: TAD supports **Codex**, **OpenCode**, and **Cursor**.
  > `.agents/skills/` is a first-party discovery path on all three and `AGENTS.md`
  > is read natively by all three, so roles, gates, and capability packs load
  > open-box. Codex is the **hook-enabled** runtime (SessionStart / PostToolUse);
  > OpenCode and Cursor currently get skills + routing + packs but **no lifecycle
  > hooks** (Platform Adapters P2 — see Known Gaps).
  > See `.tad/codex/README.md` for adapter details and activation status.
  ```
- L18 → `Harness activation:` sentence: `$alex`/`$blake` = Codex; `/alex`/`/blake` = OpenCode/Cursor; skills also model-selectable. Keep the existing trigger-phrase table (it already lists `$alex` and `/alex` rows).
- L140 heading → `## Codex-Specific Notes (Codex harness only — not applicable to OpenCode/Cursor)`.
- Add a `## Known Gaps (OpenCode / Cursor)` section recording **P2** (hook adapters: `.opencode/plugins/tad.ts`, `.cursor/hooks.json`) and **P4** (live behavioral regression not run), plus C-5/C-11/C-12 by reference. Place before `## Frozen Channel:` (L148).

**`README.md`**

- L5 → drop `--platform codex is the only target`; state targets `codex|opencode|cursor` (default `codex`).
- L74 heading → `## 🔄 Supported Harnesses (Codex · OpenCode · Cursor)`; L76-83 body → all three discover `.agents/skills/` + `AGENTS.md`; `$alex`(Codex) / `/alex`(OpenCode, Cursor); hooks only Codex (P2 gap); install `bash tad.sh --platform codex|opencode|cursor --yes`.
- L169 → `默认安装（codex 目标）…`; L171 → `--platform codex|opencode|cursor` 均可（默认 codex）; keep the true `claude-code`/`both` rejection sentence.
- L178-184 (`$tad-update` / `/tad-update`) → OpenCode/Cursor also receive roles via `.agents/skills/`; the `/tad-update` projection is **in addition**; no lifecycle hooks (P2).

**`INSTALLATION_GUIDE.md`**

- L3 `**Version 3.0.0 — Alex / Blake is the Default, Codex is the Runtime**` → `… Codex / OpenCode / Cursor are supported runtimes`.
- L18 comment `# Codex（默认，也是唯一目标）` → `# codex（默认；或 opencode / cursor）`.
- L22-23 keep the true rejection note; add one line: `opencode` / `cursor` 现为合法目标。
- L38 `（安装目标恒为 Codex）` → `（安装目标：codex / opencode / cursor）`.
- L110-112 table → add OpenCode / Cursor rows (skills + AGENTS.md, no hooks).
- L131-152 `## Codex CLI` → add harness note (`$alex` vs `/alex`); scope L147-152 hook bullets to Codex; add Known-Gaps line naming P2/P4.

**`.tad/codex/README.md`**

- L3 → `Codex is the **hook-enabled TAD runtime** (first-class since v2.25.0). OpenCode and Cursor are also supported (skills + AGENTS.md + packs; lifecycle hooks via Platform Adapters P2 — not yet).`

**`docs/MULTI-PLATFORM.md`**

- L3 version line → v3.1 wording; L5-7 → three supported harnesses, remove "single install target (`codex`)"; L19 table → Codex `/`.codex/hooks.json` only`, add OpenCode + Cursor rows (`— (OpenCode: `.opencode/commands/tad-update.md` updater-only; hooks P2)`).

### 6.4 Out of commit (explicitly NOT touched)

`docs/pm/**` (read-only), `CHANGELOG.md`, `PROJECT_CONTEXT.md`, `NEXT.md`, `OBJECTIVES.md`, `ROADMAP.md`, `HISTORY.md`,
`docs/CODEX-USER-GUIDE.md`, `docs/codex-guide.html` (statements there remain true/historical),
`.tad/active/handoffs/*` (other contracts), `.tad/archive/**`, `.tad/evidence/**`, `.tad/brain-index.md`,
`.agents/skills/**` (except the FR8 `git mv`), `.tad/templates/**`, `package.json`, `.tad/version.txt`,
`.tad/scripts/tad-update.sh` (C-11 deferred), `bin/**` (npx installer untouched).

### 6.5 Grounded Against (Alex step1c 2026-09-15)

- `tad.sh` — `:514` `KNOWN_PLATFORMS`, `:519-537` `validate_platform`, `:539-547` `resolve_platform`, `:631`/`:658` `parse_platform_*`, `:701` `is_pack_skill`, `:1038` `is_selected_pack`, `:1178`/`:1437` copy loops, `:1298` hooks guard, `:2319` `project_opencode_command`, `:2363` `resolve_platform` call, `:2891` quick-start.
- `.tad/platform-codes.yaml` (whole file, 11 lines).
- `AGENTS.md` (`:9-12`, `:16-23`, `:140`, `:148`); `README.md` (`:5`, `:74-83`, `:169-184`); `INSTALLATION_GUIDE.md` (`:3`, `:18-23`, `:38`, `:110-112`, `:131-152`).
- `.tad/codex/README.md:3`; `docs/MULTI-PLATFORM.md:3-7,19`.
- `.agents/skills/doc-organization.md` (stray; no `name`/`description` frontmatter).
- `.tad/evidence/research/2026-09-15-opencode-cursor-firstclass/findings.md`.

LSP/graph: skipped (`task_type: mixed`, shell + docs).

---

## 7. Required Evidence Manifest

```yaml
required_evidence_manifest:
  handoff_id: "HANDOFF-2026-09-15-platform-adapters-p1p3"
  evidence_files:
    - path: ".tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md"
      description: "this handoff (design authority)"
    - path: ".tad/evidence/reviews/2026-09-15-gate2-review-platform-p1p3-spec.md"
      description: "Gate 2 Reviewer A — installer semantics + AC realism (human-triggered)"
    - path: ".tad/evidence/reviews/2026-09-15-gate2-review-platform-p1p3-scope.md"
      description: "Gate 2 Reviewer B — live-doc completeness / records boundary (human-triggered)"
    - path: ".tad/active/handoffs/COMPLETION-2026-09-15-platform-adapters-p1p3.md"
      description: "Blake completion after pathspec commit"
    - path: ".tad/evidence/reviews/gate3-evidence-platform-p1p3.md"
      description: "Blake Gate 3 Layer 1 replay of §9.1 + /tmp probe transcripts"
```

---

## 8. Friction / Notes

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| None | — | — | — | — |

Shell/YAML/docs only; `bash`/`grep`/`awk`/`git`/`mktemp` present. No new deps, no auth, no network (probe uses `--source` offline mode). No reviewer blockage expected.

### 8.5 feedback_required: false

---

## 9. Acceptance Criteria

### AC realism (copy)

- Every landing AC has exactly one legal Verification Method: command | path-check | fixture | rubric-spawn | light-tier N/A+reason.
- Dry-run on live baseline before Gate 2 lock. Post-impl rows must fail **for the right reason** on the unmodified tree.
- Known-GOOD must PASS; known-BAD must FAIL. Ban `import yaml`; no unguarded `$(grep -l ...)`.

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d 2026-09-15) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| 1 | `KNOWN_PLATFORMS` names all three targets | post-impl-verifiable | `grep -cF 'KNOWN_PLATFORMS="codex opencode cursor"' tad.sh` | 1 | `0` (baseline) |
| 2 | `validate_platform` accepts codex/opencode/cursor, rejects claude-code/both/bogus | post-impl-verifiable | ``bash -c 'for p in codex opencode cursor claude-code both bogus; do bash -c "eval \"\$(awk \"/^validate_platform\(\)/,/^}/\" tad.sh)\"; log_error(){ :; }; validate_platform $p" >/dev/null 2>&1 && echo "$p=ACCEPT" || echo "$p=REJECT"; done'`` | `codex/opencode/cursor=ACCEPT`; `claude-code/both/bogus=REJECT` | `codex=ACCEPT / opencode=REJECT / cursor=REJECT / claude-code=REJECT / both=REJECT / bogus=REJECT` (baseline) |
| 3 | `platform-codes.yaml` resolves `AGENTS.md` root for all three via the installer's own parser | post-impl-verifiable | ``bash -c 'eval "$(awk "/^parse_platform_root_files\(\)/,/^}/" tad.sh)"; for p in codex opencode cursor; do printf "%s:[%s]\n" "$p" "$(parse_platform_root_files .tad/platform-codes.yaml "$p")"; done'`` | `codex:[AGENTS.md]`, `opencode:[AGENTS.md]`, `cursor:[AGENTS.md]` | `codex:[AGENTS.md] / opencode:[] / cursor:[]` (baseline) |
| 4 | `opencode` + `cursor` installs succeed and generate **no** `.codex/hooks.json` | post-impl-verifiable | ``bash -c 'R="$PWD"; for p in opencode cursor; do T=$(mktemp -d); ( cd "$T" && bash "$R/tad.sh" --source "$R" --platform "$p" --yes >/dev/null 2>&1 ); rc=$?; test $rc -eq 0 && test -f "$T/.agents/skills/alex/SKILL.md" && test -f "$T/AGENTS.md" && test ! -e "$T/.codex/hooks.json" && echo "$p=OK" || echo "$p=FAIL(rc=$rc)"; rm -rf "$T"; done'`` | `opencode=OK` and `cursor=OK` | `opencode=FAIL(rc=1) / cursor=FAIL(rc=1)` (baseline: platform rejected before mutation) |
| 5 | Help text lists all three targets | post-impl-verifiable | ``bash tad.sh --help 2>&1 \| grep -cE 'opencode\|cursor'`` | ≥ 1 | `0` (baseline: `target platform (codex). Default: codex`) |
| 6 | `AGENTS.md` activation syntax + header honesty (canonical tokens) | post-impl-verifiable | ``python3 -c "import pathlib; t=pathlib.Path('AGENTS.md').read_text(); ok=('Harness activation' in t and 'OpenCode' in t and 'Cursor' in t and 'Both platforms receive' not in t and 'Codex-Specific Notes (Codex harness only' in t); print(ok); raise SystemExit(0 if ok else 1)"`` | `True`, exit 0 | `False` (baseline: `Harness activation` absent, `Both platforms receive` present) |
| 7 | `AGENTS.md` records P2/P4 as Known Gaps | post-impl-verifiable | ``python3 -c "import pathlib; t=pathlib.Path('AGENTS.md').read_text(); i=t.find('Known Gaps'); ok=(i!=-1 and 'P2' in t[i:] and 'P4' in t[i:]); print(ok); raise SystemExit(0 if ok else 1)"`` | `True`, exit 0 | `False` (baseline: no Known Gaps section) |
| 8 | `README.md` no exclusivity claim + names harnesses | post-impl-verifiable | ``python3 -c "import pathlib; t=pathlib.Path('README.md').read_text(); ok=('only install target' not in t and 'sole runtime since v3.0.0' not in t and 'opencode' in t and 'cursor' in t); print(ok); raise SystemExit(0 if ok else 1)"`` | `True`, exit 0 | `False` (baseline: `only install target` + `sole runtime since v3.0.0` present) |
| 9 | Sibling live docs lose exclusivity claim | post-impl-verifiable | ``python3 -c "import pathlib; checks={'.tad/codex/README.md':'sole runtime since v3.0.0','docs/MULTI-PLATFORM.md':'single install target','INSTALLATION_GUIDE.md':'唯一目标'}; bad=[(p,s) for p,s in checks.items() if s in pathlib.Path(p).read_text()]; print('BAD='+repr(bad)); raise SystemExit(0 if not bad else 1)"`` | exit 0; `BAD=[]`; `INSTALLATION_GUIDE.md` also contains `opencode` | `BAD=[('.tad/codex/README.md','sole runtime since v3.0.0'), ...]` (baseline: all 3 flagged) |
| 10 | No stray `*.md` at `.agents/skills` root | post-impl-verifiable | ``python3 -c "import pathlib; s=[f.name for f in pathlib.Path('.agents/skills').glob('*.md')]; print('STRAYS='+repr(s)); raise SystemExit(0 if not s else 1)"`` | exit 0; `STRAYS=[]` | `STRAYS=['doc-organization.md']` (baseline) |
| 11 | Codex install regression (hooks still generated) | post-impl-verifiable | ``bash -c 'R="$PWD"; T=$(mktemp -d); ( cd "$T" && bash "$R/tad.sh" --source "$R" --platform codex --yes >/dev/null 2>&1 ); rc=$?; test $rc -eq 0 && test -f "$T/.codex/hooks.json" && test -f "$T/.agents/skills/alex/SKILL.md" && echo codex=OK || echo "codex=FAIL(rc=$rc)"; rm -rf "$T"'`` | `codex=OK` | `codex=OK` (baseline: known-GOOD; this row is an edit-integrity guard) |
| 12 | Commit scope set-equality; `docs/pm/**` / version files untouched; zero `D` | post-impl-verifiable | ``python3 -c "import subprocess; exp=set('tad.sh .tad/platform-codes.yaml AGENTS.md README.md INSTALLATION_GUIDE.md .tad/codex/README.md docs/MULTI-PLATFORM.md .agents/skills/_archived/doc-organization.md .tad/active/handoffs/HANDOFF-2026-09-15-platform-adapters-p1p3.md'.split()); rows=subprocess.check_output(['git','diff-tree','--no-commit-id','--name-status','-r','HEAD'],text=True).splitlines(); got={l.split('\t')[-1] for l in rows}; dels=[l for l in rows if l[:1]=='D']; extra=sorted(got-exp); missing=sorted(exp-got); print('MISSING=',missing); print('EXTRA=',extra); print('DELETED=',dels); raise SystemExit(0 if (not missing and not extra and not dels) else 1)"`` | exit 0; `MISSING=[]`, `EXTRA=[]`, `DELETED=[]` | (post-impl — baseline HEAD is not this knife) |

### Verification Method grammar

LEGAL: command in backticks | path-check | fixture | rubric-spawn | light N/A. ILLEGAL: prose-only.

## AC Dry-Run Log (Alex step1d 2026-09-15)

- AC1, AC5, AC6–AC10: post-impl structural; baselines measured live → all fail for the **right** reason (0 / absent / present-wrong-token).
- AC2–AC4, AC11: extraction/probe run live on baseline:
  - AC2 baseline output recorded above (`codex=ACCEPT … bogus=REJECT`); the extraction technique was executed and validated.
  - AC3 baseline `codex:[AGENTS.md] / opencode:[] / cursor:[]` (installer's own `parse_platform_root_files`).
  - AC4 baseline: `--platform opencode` → `Unknown platform: 'opencode'. Valid platforms: codex` exit 1 (captured `/tmp/tad-p1-probe.log`).
  - AC11 baseline: `--platform codex` → exit 0, `.codex/hooks.json` present (captured `/tmp/tad-codex-probe.log`) → **known-GOOD PASS guard**.
- AC12: post-impl; run **after** commit (index/commit-freeze requirement, `ac-verification.md`).
- Method mix: `grep`/`bash`/`python3 stdlib`/`git` only — no network, no `yaml` module, no `node`.

---

## 9.2 Expert Review Status

> Dual files on disk = process Gate 2. Not a human `/gate 2` lock.
> **This design turn** (constraint: only this HANDOFF file may be written) ran an in-conversation self-consistency pass + live baseline dry-runs.
> The two on-disk review carriers are produced at the human-triggered Gate 2.

### Audit Trail

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| Alex (self-check) | The user-named "capability-pack installer hard-reject" is **not** in the `--packs` path (no `PLATFORM` ref there) — it is the global `validate_platform` gate | §4.1 "Why the capability-pack installer needs no change of its own"; FR1 targets `validate_platform` | Resolved |
| Alex (self-check) | Fixing only `README.md`/`AGENTS.md` (user-named) would leave the identical false claim in 3 more live docs | FR6 sibling sweep covers `INSTALLATION_GUIDE.md`, `.tad/codex/README.md`, `docs/MULTI-PLATFORM.md`; AC9 | Resolved |
| Alex (self-check) | `opencode`/`cursor` could accidentally receive `.codex/hooks.json` if `.codex/` were copied | Verified `.codex/` is not in `derive_framework_dirs` (only `.tad/*/`) and only generated under `PLATFORM=codex` → AC4 asserts absence | Resolved |
| Alex (self-check) | Records (CHANGELOG / PROJECT_CONTEXT / other handoffs) risk being swept by a careless "make docs honest" pass | §4.2 class table + FR9 + AC12 `docs/pm` guard; §6.4 explicit out-of-commit list | Resolved |
| Alex (self-check) | C-13 stale "Claude Code" refs are 53 live occurrences incl. legitimate cross-harness prose | Deferred to §10 with rationale; no skill body edited this knife | Deferred (documented) |

### Experts Selected (to run at human-triggered Gate 2)

1. **Reviewer A — Installer semantics & AC realism** — `validate_platform` relaxation is minimal/additive; codex regression; probe-based ACs are runnable and non-vacuous.
2. **Reviewer B — Live-doc completeness & records boundary** — every live exclusivity claim covered; records untouched; `$alex` harness-scoping accurate.

**Gate 2 结果**: ⚠️ PENDING on-disk dual reviews (human-triggered). In-conversation self-consistency PASS.

---

## 10. Known Gaps (explicitly NOT implemented — do not silently absorb)

| Gap | Research ref | Impact | Status |
|-----|--------------|--------|--------|
| **P2 — Hook adapters** (OpenCode `.opencode/plugins/tad.ts`; Cursor `.cursor/hooks.json`) | C-3/C-4 | Silent capability loss on OpenCode/Cursor: no framework health summary, no TAD trace emission (`session.diff`/journal), no ask-user capture, no post-compact recovery hint. | **Known gap** — recorded in `AGENTS.md` Known Gaps (FR7) |
| **P4 — Live behavioral regression** on real OpenCode/Cursor | §3 Phase 4 | The claim "open-box usable" rests on vendor docs + an installer probe; no live harness transcript. | **Known gap** — recorded (FR7) |
| **C-5 — `/alex`, `/blake` slash projection** | C-5 | Only `/tad-update` is projected (OpenCode); Cursor gets no command. Activation is via skill tool / model selection. | **Known gap** (deferred) |
| **C-11 — updater `--platform must be codex`** | C-11 | `detect_platform` returns `codex` on any v3 project, so `$tad-update` works; explicit `--platform opencode` to `tad-update.sh` is still rejected. Misnomer. | **Known gap** (deferred) |
| **C-12 — no runtime freshness ledger** for OpenCode/Cursor | C-12 | No freshness gate for those harnesses. | **Known gap** (deferred) |
| **C-13 — stale Claude-harness refs in skill bodies** | C-13 | 53 literal `Claude Code` occurrences across `.agents/skills/*/SKILL.md` (many are legitimate cross-harness prose). Too broad/noisy for an S knife; needs its own bounded enumeration. | **Known gap** (deferred) |

---

## 11. Rollback

All changes are additive (installer gate relaxation + YAML blocks) or documentation edits + one `git mv`. **No state, no migration, no db, no network.**

| Layer | Rollback action | Notes |
|-------|-----------------|-------|
| Whole knife | `git revert --no-edit <commit>` (or `git checkout <base> -- <§6.1 paths>`) | Clean revert; §6.1 is a closed file set (AC12). |
| P1 (`tad.sh`) | Restore `KNOWN_PLATFORMS="codex"`, remove `opencode\|cursor` from the accept arm, restore L366 usage | Because `validate_platform` rejects **before any mutation**, reverting re-establishes the old hard reject with **no leftover state**. Existing files in a project that was installed with `--platform opencode` remain on disk (they are ordinary `.agents/skills` + `AGENTS.md`); only re-running the installer with `--platform opencode` becomes impossible again. |
| P1 (`platform-codes.yaml`) | Remove the two appended blocks | Codex block untouched; no other platform depends on them. |
| P3 (docs) | `git checkout <base> -- AGENTS.md README.md INSTALLATION_GUIDE.md .tad/codex/README.md docs/MULTI-PLATFORM.md` | Doc-only. |
| Hygiene | `git mv .agents/skills/_archived/doc-organization.md .agents/skills/doc-organization.md` | Reversible; content byte-identical. |
| Probes | None | AC4/AC11 install into `mktemp -d` under `/tmp` and `rm -rf` it; the repo tree is never a target. No cleanup needed. |

**Guarantee**: rollback never touches `docs/pm/**`, `CHANGELOG.md`, `PROJECT_CONTEXT.md`, other handoffs, or any version file. No release rollback is required because **no version was bumped and nothing was pushed/tagged**.

---

## 12. Decision Summary

| Decision | Choice | Source |
|----------|--------|--------|
| Scope | P1 + P3 only (S); P2/P4 → Known Gaps | `findings.md` decision guidance |
| P1 mechanism | Relax `validate_platform` accept arm + `KNOWN_PLATFORMS`; 2 YAML blocks | §4.1/§6.2 |
| Default target | `codex` (unchanged) | §4.3 |
| Hook generation | Codex-gated (unchanged) | §4.3 |
| Doc coverage | All live platform/activation claims (5 files), not just README/AGENTS | "同病治一半" principle; FR6 |
| Records | Untouched | §4.2 class table; FR9 |
| Hygiene | `git mv` stray skill-root `.md` → `_archived/` (no delete) | FR8 |
| Version | No bump | NFR4 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-09-15
**Version**: 3.1
