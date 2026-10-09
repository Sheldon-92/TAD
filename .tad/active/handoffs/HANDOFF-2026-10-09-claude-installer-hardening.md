---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/templates/claude", ".tad/tests", ".tad/provenance"]
handoff_revision: 3
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.2 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-09
**Project:** TAD Framework
**Task ID:** TASK-20261009-CLAUDE-INSTALLER-HARDENING
**Handoff Version:** 3.2.0
**Epic:** EPIC-20261008-multi-harness-restore-and-cleanup.md (Phase 4a-2/6)
**Depends on:** TASK-20261009-CLAUDE-LEGACY-ADOPTION 已提交（本单在它之上改 `tad.sh`；台账与 `claude_adopt_*` 函数须已存在）
**Grounding:** `phase4-grounding.md`、`phase4-hook-cwd-probe.md`、`workflow-runs/handoff-review.result.txt`（均在 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/`）
**Risk card:** `.tad/evidence/risk-cards/risk-TASK-20261009-CLAUDE-INSTALLER-HARDENING.md`

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|---|---|---|
| Architecture Complete | ✅ | 第 3 版：第 1 轮（2 P0／3 P0）后缩小范围并重写；第 2 轮两位审查均 0 P0，其 11 条 P1 已按报告给出的替换文本改入 |
| Components Specified | ✅ | §4 |
| Functions Verified | ✅ | §5 MQ2（对照 Phase 4a 落地后的 `tad.sh` 复核） |
| Data Flow Mapped | ✅ | §5 MQ3 |

---

## 1. Task Overview

### 1.1 What We're Building
3.3.0 首发前，Claude Code 安装路径必须补上的五处：
1. hook 命令锚定到项目根（变量为空时不执行任何脚本）。
2. `spec-compliance-reviewer` 投影成 Claude Code 的已注册子代理（只新建，不覆盖）。
3. 平台粘性（**只做链接维护**）：已有 TAD Claude 投影的项目，用别的平台参数升级时，新 skill 照样得到入口、失效入口照样清理。
4. `CLAUDE-HINT` 条件收窄；skill 名允许清单。
5. 安装摘要点名 hook 写入会话数据的三处路径。

### 1.2 Why
- 第 1 项已实测：会话里 `cd` 之后，相对路径的 hook 在子目录执行，2/2 次跑到了子目录里的另一份脚本（`phase4-hook-cwd-probe.md`）。
- 第 3 项：`tad-update.sh` 永远以 `--platform codex` 调用安装器。不做粘性，装了 Claude 投影的项目每次经更新入口升级，新 skill 就没有入口。

### 1.3 Intent Statement
- 真正要解决：3.3.0 首发的 Claude Code 安装不带已知缺陷；经更新入口升级后 skill 入口不退化。
- 不是要做：
  - 粘性下的任何「新建或替换」：不建、不改 `.claude/settings.json`，不写 `CLAUDE.md`，不投影子代理，不接管旧安装。这些只在显式 `--platform claude-code` 时发生。
  - 子代理定义的覆盖更新（目标已有不同内容的同名文件一律保留）。
  - 同版本闸的放行；hook 级合并；阻断型 hook 的恢复；迁移清单（Phase 6）。
  - `startup-health.sh` 的 `CLAUDE.md` 遮蔽告警、基线 5 项 fixture 失败的调查（第 1 版的 FR7、FR8）：挪到 Phase 5。

### 1.4 卸载记录
| 卸给 | 内容 |
|---|---|
| Phase 5 | 原 FR7（会话启动告警）、原 FR8（基线 fixture 失败调查）、`tad-update.sh:120-122` 的过时注释、`bin/tad-install.mjs` 的参数透传用例 |
| Phase 6 | 迁移清单；CHANGELOG 写明粘性是对「非 claude-code 平台不碰 `.claude/`」的有条件放宽；合并方式不得 squash（见 §4.1） |
| Phase 4b | 四家真机回归；`CLAUDE_PROJECT_DIR` 在各 hook 事件里的真机复核 |
| 人 | TAD 仓自身 `.claude/` 的自举 |

---

## 📚 Project Knowledge（Blake 必读）
同 Phase 4a handoff 所列四项；另加 `.tad/archive/handoffs/HANDOFF-2026-10-08-claude-code-installer-projection.md` §4.4（hook 投影状态表）与 §4.7（陈旧清理）；以及两份第 1 轮设计审查 `phase4a2-design-review-{cr,sec}.md`（`.tad/evidence/yolo/multi-harness-restore-and-cleanup/`）——本版每条规定的理由都在里面。

---

## 2. Background Context
- hook 模板现有四条命令，形如 `bash .tad/hooks/<x>.sh`，脚本依次是 `startup-health.sh`、`post-write-sync.sh`、`lib/askuser-capture.sh`、`precompact-session-snapshot.sh`。hook 脚本内部也用相对路径读写 `.tad/`，所以锚定必须是「先切到项目根再执行」。
- 实测：`CLAUDE_PROJECT_DIR` 在每条 hook 里都已设置且等于项目根。安全审查实测：变量为空时 `cd ""` 在 zsh、sh、dash 里成功且不移动，随后的相对路径脚本仍在当前目录执行（bash 里失败）；`${VAR:?}` 在 dash 里退出码为 2，而 2 是 Claude Code 的阻断码，不能用。
- 台账生成器只读 git 历史（`rev-list HEAD` 加全部 tag），不读工作区。未提交的模板 blob 不会进台账。
- Phase 4a 之后，`settings.json` 的替换只发生在 `claude_adopt_apply`（显式 `--platform claude-code`，接管模式不为 off）。所以「旧模板换成新模板」的通道只在显式 claude-code 运行时生效；经更新入口（粘性）的项目只会得到一行提示。
- Phase 2 版模板（相对路径，blob `2cdede5eed8686345e3beee792da9c230daa2eb3`，提交 `af97b99a`）从未进入任何 tag，没有真实下游持有它；它只用来证明升级通道是通的。
- `.tad/agents/claude/spec-compliance-reviewer.md` 是定义正本；Claude Code 只从 `.claude/agents/` 注册项目级子代理。`.tad/agents/claude-local/` 不投影。

---

## 3. Requirements

### 3.1 Functional
- **FR1** hook 模板四条命令改为 §4.1 的锚定形式；按 §4.1 的固定顺序提交模板并重新生成台账。
- **FR2** 子代理定义投影 `project_claude_agents`（§4.2）。
- **FR3** 平台粘性（§4.3）：只维护 skill 链接与陈旧清理。
- **FR4** `CLAUDE-HINT` 只在已装版本与源版本相等时打印。
- **FR5** skill 名允许清单（§4.4）。
- **FR6** 安装摘要在 hook 处于已注册状态时点名三处会写入会话数据的路径（§4.5）。安装器不改目标的 `.gitignore`。

### 3.2 Non-Functional
- NFR1 全新安装与 Phase 4a 的全部验收用例保持通过。
- NFR2 每条新增的 `rm`、`rmdir`、`mv`（含 `mv -f`）都带唯一 `RM-OK:<id>` 标记，之前有路径守卫；Blake 在 completion 里列出每一条的行号、标记、守卫。发版门的 destructive-guard 不检查 `mv`，脚本 B10 另有一条计数检查。注意：该守卫按字面匹配，`tad.sh` 新增的注释里不要出现 `rmdir`、`rm -f` 这类词。
- NFR3 非 claude-code 平台且粘性不成立时，对 `.claude/`、`CLAUDE.md` 的行为与本单之前相同。
- NFR4 安装器须在 `/bin/bash` 3.2 下通过全部验收（脚本默认就用它跑安装器）。

---

## 4. Technical Design

### 4.1 hook 模板锚定（FR1）
模板里每条 `command` 的值（JSON 字符串内，引号转义为 `\"`）改成：
```
test -n "$CLAUDE_PROJECT_DIR" && { cd -- "$CLAUDE_PROJECT_DIR" || exit 1; } && bash .tad/hooks/startup-health.sh
```
其余三条同形，脚本名不变。事件、matcher、timeout 不变。变量为空、未设置或指向不存在的目录时，命令以 1 退出、不执行任何脚本（非阻断；`|| exit 1` 是因为 dash 里 `cd` 失败的退出码是 2，而 2 是阻断码）。

**顺序固定**（生成器只读 git 历史）：
1. 改模板。
2. 提交模板，且**每次提交都只含这一个文件**。多个代理共用这个工作区和暂存区，所以不用 `git add`，用带路径的 `--only` 形式：
   ```
   git diff --cached --name-only > <私有临时文件 A>
   git commit --only -m "feat(installer): anchor Claude Code hook commands to the project root" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -- .tad/templates/claude/settings.json
   git show --stat --format='%h %s' HEAD        # 必须只列出这一个路径
   git diff --cached --name-only > <私有临时文件 B>   # A 与 B 必须相同
   ```
   这是本单授权 Blake 做的唯一一类提交：本地提交，不推送。
3. 在生成器里、`LC_ALL=C sort -u "$TMP/rows" > "$TMP/data"` 之前，加两条**字面量固定行**并加注释说明来历：
   ```
   # Pinned rows: the Phase 2 hook template (commit af97b99a, never in a tag). Literal ids, so a squash merge
   # or a clone without that commit cannot drop them. settings-ws = sha1 of the blob with ' ' TAB CR LF removed.
   printf 'settings\t2cdede5eed8686345e3beee792da9c230daa2eb3\t-\nsettings-ws\td94c5a368ddbb1cd0cff1d10142eaa75e695c59e\t-\n' >> "$TMP/rows"
   ```
   不要把固定 blob 写进 `$TMP/raw`（`settings-ws` 的派生需要对象库里有该 blob，缺失时会静默丢行）。变量名与列格式以生成器现有代码为准；去重排序沿用现有的 `sort -u`。
4. 运行 `.tad/scripts/gen-claude-provenance.sh`；`release-verify.sh provenance .` 必须通过。
5. 模板之后再有任何改动，从第 2 步重来。

不得手改台账；不得让生成器读工作区。`.tad/provenance/` 与生成器的改动留在工作区，由 Conductor 统一提交。

`project_claude_hooks` 在显式 claude-code 下的逻辑不改。

文档：`.tad/runtime-compat/claude-code.md` 的 hooks 行与 `runtime-adapter-instance-claude-code.md` 相应更新：锚定形式、实测依据、变量为空或目录不存在时四条 hook 静默不执行、R-CC-6 仍在、「脚本不存在时 hook 的表现未测」。

### 4.2 子代理定义投影（FR2）
新函数 `project_claude_agents <src>`，门控 `CLAUDE_PROJECTION=1` **且 `CLAUDE_STICKY` 不为 1**，紧挨在 `project_claude_hooks` 之后调用。

路径守卫用 4a 的 `claude_adopt_path_ok <相对路径> <d|f|p>`：逐级要求父目录是真实目录、拒绝符号链接；`d`／`f` 还要求末级存在且是该类型；`p` 只检查父链、不检查末级。

进入函数后按此顺序：
1. 源侧：`$src/.tad/agents`、`$src/.tad/agents/claude` 须是真实目录（`! -L` 且 `-d`）；不满足或其下没有普通 `.md` 文件 → 返回 0，不输出。
2. `.claude` 是符号链接、不存在、或存在但非目录 → 整体跳过，`CLAUDE-AGENTS-SKIPPED <原因>`，返回 0（`.claude` 由 `project_claude_skills` 先建，不在这里建）。
3. `.claude/agents` 是符号链接或存在但非目录 → 整体跳过，同上。
4. `claude_adopt_path_ok '.claude/agents' p` 不通过 → 整体跳过，同上。（此处不得用 `d`：尚不存在的 `.claude/agents` 会让全新安装被整体跳过。）
5. `.claude/agents` 不存在时：先设 `CLAUDE_AGENTS_DIR_CREATED=1` 再 `mkdir`；随后 `claude_adopt_path_ok '.claude/agents' d` 必须通过，否则按失败处理。

然后对源目录下每个 `<f>.md`（须 `! -L` 且 `-f`；符号链接的源定义跳过不输出；文件名去掉 `.md` 后须过 §4.4 的名字判定，否则记 `CLAUDE-AGENT-KEPT <清洗名> (name not allowed)`）：

| 目标 `.claude/agents/<f>.md`（先 `-L`） | 动作 | 记录 |
|---|---|---|
| 符号链接，或存在但非普通文件（含目录） | 不动 | `CLAUDE-AGENT-KEPT <f> (not a regular file)` |
| 不存在（`! -L` 且 `! -e`） | 写入前再调一次 `claude_adopt_path_ok ".claude/agents/<f>.md" p`；把源文件 `cp` 到同目录临时文件，`cmp -s` 源与临时文件，再 `mv -f --` 到目标，权限 644（有意固定，不随 umask）；记入 `CLAUDE_CREATED_AGENTS` | `CLAUDE-AGENT-NEW <f>` |
| 普通文件，`cmp -s` 与源相同 | 不动 | 计入 current |
| 普通文件，与源不同 | 不动 | `CLAUDE-AGENT-KEPT <f> (differs from the TAD definition; delete it and re-run to take the TAD version)` |

- 建目录、写临时文件、比较或 `mv` 失败：打印 `CLAUDE-AGENTS-FAILED <原因>`，返回 1，整次安装失败并回滚（同 `CLAUDE-HOOKS-FAILED`）。
- 临时文件名用固定前缀 `.tad-agent.XXXXXX`（不以 `.md` 结尾）。除登记全局变量供 EXIT 清理外，还须把该前缀加进 `cleanup_installer_temp` 里按文件名放行的 `case`（现在只放行 `.tad-claude-md.*|.tad-pointer.*`）。清理用的删除语句带唯一 `RM-OK` 标记并先判 `! -L`。
- 新增顶层变量（脚本在 `set -u` 下运行，须在顶层初始化）：`CLAUDE_AGENTS_DIR_CREATED=0`、`CLAUDE_CREATED_AGENTS=""`、`CLAUDE_AGENT_KEPT_NAMES=""`。
- 回滚（`rollback_claude_projection`）：对 `CLAUDE_CREATED_AGENTS` 里每个文件，`assert_under_root` 通过、不是符号链接且是普通文件即删除（与 `CLAUDE_SETTINGS_CREATED` 同一做法）。**不与源文件比较**：EXIT trap 的顺序是 `cleanup_installer_temp; cleanup_source_tree; rollback_on_failure`，下载来的源树此时已被删。然后本次新建的 `.claude/agents` 为空才 `rmdir`；这两步在既有的 `.claude` `rmdir` 之前。
- 自检：每个源定义在目标里要么与源相同，要么本次记为 KEPT，要么整体 SKIPPED。
- 汇总加一行（两格缩进，与其他行同式）：`agents: <n> new, <c> current, <k> kept`；整体跳过时为 `agents: skipped`。粘性下不打印这一行。
- 没有 `UPDATED` 分支，没有台账 kind `agent`，不做存档。
- 「判断不存在」与 `mv -f` 之间的窗口是单用户本机竞态；`mv` 是改名语义，不会跟随中途出现的符号链接写到项目外。

把 `.tad/agents/claude/spec-compliance-reviewer.md` 头部第二条注释改成：自 3.3.0 起由 `--platform claude-code` 投影到 `.claude/agents/`；类型未注册时的替代做法不变。

### 4.3 平台粘性（FR3）

**判据** `claude_projection_present`（只读，只看目标项目，不依赖源码与台账）成立当且仅当全部为真。判据里的每个路径都用 `claude_adopt_path_ok <相对路径> d|f` 测试（逐级拒绝符号链接与非目录），不得只测末级：
1. `.tad/version.txt` 是普通文件（项目装过 TAD）。
2. `.agents/skills/alex/SKILL.md` 是普通文件。
3. `.claude/skills` 是真实目录。
4. `.claude/skills/alex` 满足其一：是符号链接且 `readlink` 恰为 `../../.agents/skills/alex`；或通过 `claude_is_tad_pointer`。
5. 以下至少一项：(a) `CLAUDE.md` 是普通文件且不是符号链接，且含整行（`grep -Fx`）`<!-- TAD:AGENTS-REF:BEGIN (managed by tad.sh) -->`；(c) `.claude/skills` 下除 `alex` 外另有至少 3 个条目 `<n>` 满足第 4 条的同名形式（链接目标恰为 `../../.agents/skills/<n>`，或是 TAD 指路目录）。

（第 2 版里的 5(b)「`settings.json` 命中模板或台账」已删：它是唯一需要源码与台账的一条，而任何真实的 claude-code 安装都满足 (c)。）

不得用「存在任意一个指向 `.agents/skills` 的链接」。

**求值位置**：不在 `resolve_platform` 里求值，也不在那里为粘性设 `CLAUDE_PROJECTION`。在 `main()` 里、`claude_adopt_preflight "$TAD_SRC"` 的**紧前一行**求值：此处三处「Nothing to do」闸、确认提示和源码下载都已过去。平台不是 claude-code、`TAD_CLAUDE_STICKY` 不等于 `off`、且判据成立时，在同处设 `CLAUDE_PROJECTION=1`、`CLAUDE_STICKY=1`、`CLAUDE_ADOPT_MODE=off`、`CLAUDE_MD_STATE=skipped`、`CLAUDE_HOOKS_STATE=skipped`，并打印提示行：

`CLAUDE-STICKY: this project has a TAD Claude Code projection; keeping its skill links up to date (platform for this run: <p>). Legacy entries are not adopted in this run. Set TAD_CLAUDE_STICKY=off to skip.`

因此「Nothing to do」的运行里既不出现 `CLAUDE-STICKY` 也不出现 `CLAUDE-HINT`。`CLAUDE_STICKY` 在顶层初始化为 0。`TAD_CLAUDE_STICKY=off` 时什么都不设，行为与本单之前的非 claude-code 平台相同。

**粘性下做什么**（穷举；表外的 Claude 面一律不写）：

| 面 | 粘性下的行为 |
|---|---|
| `project_claude_skills` | 照常：新 skill 建链接，已有的不动，实体目录记保留；链接建不成时的指路目录回退与 `TAD_CLAUDE_SKILL_MODE=pointer` 也照常，只写 `.claude/skills/<n>/` 之内 |
| `claude_prune_stale` | 照常；不新增汇总行。其日志行里的名字改用 `claude_adopt_clean` 清洗后再打印（克隆来的仓库里链接名可能带终端控制序列） |
| `project_claude_md_ref` | **不执行**（函数开头遇 `CLAUDE_STICKY=1` 即返回），不读不写 `CLAUDE.md` |
| `backup_existing`／`take_rollback_snapshot` 里对 `CLAUDE.md` 的快照 | 粘性下不做；失败回滚不碰 `CLAUDE.md` |
| `project_claude_hooks` | **不写任何文件**。函数开头的粘性分支只读判断：先重复该函数既有的三条符号链接／非普通文件守卫；`.claude/settings.json` 是普通文件、与源模板 `cmp` 不同时，自行调用 `claude_provenance_ready "$1"`（接管模式为 off 时台账不会被别处加载），再用 `claude_blob_id` 与台账 `settings` 行比对；命中则打印 `CLAUDE-HOOKS-STALE .claude/settings.json holds an older TAD hook template; re-run with --platform claude-code --force to move to the current one`。台账不可用或其余情况不输出 |
| `project_claude_agents` | **不执行** |
| `claude_adopt_*`、`claude_adopt_notice` | 全部在首行返回（接管模式 off） |
| `claude_legacy_detected_note` | 粘性下不打印（提示行里已有一句） |
| 弃用清理的 `.claude/*` 跳过分支 | 与显式 claude-code 相同（跳过，打印 `CLAUDE-DEPRECATION-SKIPPED`）。后果：粘性运行不再删除原样的旧版 `.claude/commands/*`。`.codex/hooks.json` 的弃用条目被跳过在 codex 平台无害（该平台随后无条件重写此文件）；在 cursor／opencode 的粘性运行里，结果只是不再清掉一份旧的 `.codex/hooks.json` |
| 自检 `verify_install_complete` | 只要求：源里每个合格 skill 在 `.claude/skills/` 下有入口或被记为保留。`CLAUDE_MD_STATE`、`CLAUDE_HOOKS_STATE` 已设为 skipped，所以 `CLAUDE.md` 引用块与 hooks 两项检查不触发；子代理检查在粘性下不做 |
| 汇总 `claude_print_summary` | 首行恰为 `CLAUDE-SUMMARY (Claude Code projection) (sticky: links only)`（在现有首行文字后加括号段，以现有首行为准）；只打印 skills 行；不打印 hooks、agents、数据落点 |
| 回滚 | 照常：本次新建的链接与指路目录撤销 |

Blake 须 grep 全部以 `CLAUDE_PROJECTION` 为条件的代码点，在 completion 里列表说明每一处在粘性下的行为属于上表哪一行；表里没有的代码点先报告再动。

### 4.4 `CLAUDE-HINT` 条件（FR4）与 skill 名允许清单（FR5）
- FR4：不删除任何调用点。在 `claude_hint_if_incomplete` 函数体开头加：`[ "$(_tad_ver_cmp "${CURRENT_VERSION:-}" "${TARGET_VERSION:-}")" = "0" ] || return 0`（变量名以该函数调用点处实际可用的为准；`_tad_ver_cmp` 已存在）。
- FR5：`claude_skill_set` 里的判定顺序：先 `-L`、`-d`、`SKILL.md` 是普通文件，**最后**才看名字。只有「真实目录、有普通 `SKILL.md`」而名字不合清单的才跳过并打印。判定用 `case`，函数内 `local LC_ALL=C`：
  ```
  case "$_n" in ''|[!A-Za-z0-9]*|*[!A-Za-z0-9._-]*) <跳过> ;; esac
  ```
  另加长度上限 64 字符。不用 `grep`（按行匹配，含换行的名字能绕过），不用 bash 正则。
- 把名字判定做成一个小函数 `claude_skill_name_ok <name>`（上面的 `case` 加长度上限），供所有构造 Claude skill 名集合的地方共用（至少 `claude_skill_set`、`claude_adopt_pred_set`、`claude_adopt_src_names`；它们读的树不同，所以共用的是名字判定，不是集合函数），§4.2 的文件名判定也用它。Blake grep 后在 completion 里列出全部位置。
- 被跳过的名字各打印一行 `CLAUDE-SKILL-SKIPPED <claude_adopt_clean 清洗后的名字> (name not allowed)`，**只在 `claude_skill_set` 的 warn 模式下打印**（即 `project_claude_skills` 的那一次调用），其余调用方不重复打印。旧 token `CLAUDE-SKILL-NAME-SKIPPED`（两处）删除。
- 点开头的目录整体不在集合里，也不打印（无论有没有 `SKILL.md`）。
- `_archived` 没有 `SKILL.md`，不在集合里，也不得产生 SKIPPED 行。

### 4.5 安装摘要的数据落点说明（FR6）
`claude_print_summary` 在**非粘性**且本次运行结束时 hook 处于已注册状态（新落模板、接管替换、或与模板相同）时追加固定五行：
```
Registered hooks write session data inside this project:
  .tad/active/precompact/                                   (compaction snapshots)
  .tad/evidence/hooks/precompact-snapshot/last-stdin.json   (session id, transcript path, compact instructions)
  .tad/evidence/decisions/<date>.jsonl                      (questions asked and the options chosen)
If this project is a git repository, consider adding these three paths to .gitignore.
```
`settings.json` 被保留（用户改过）或被跳过时不打印这五行。路径已由审查对照 `precompact-session-snapshot.sh:21-26,43` 与 `askuser-capture.sh:163` 核实。

### 4.6 Fixture 与文档
- 不往既有 fixture 里加用例：§9.1-RAW 脚本已覆盖这些行为，而 `installer-data-safety-fixture.sh` 目前带 5 项基线失败（调查在 Phase 5），往里加用例没有可核对的验收标准。
- `INSTALLATION_GUIDE.md` 的 Claude Code 一节：锚定形式的 hook、子代理投影（只新建）、粘性行为（只维护链接；模板与 `CLAUDE.md` 要显式 `--platform claude-code --force`；`TAD_CLAUDE_STICKY=off`）、会话数据三处路径。
- `.tad/provenance/README.md`：固定行的说明。

---

## 5. 强制问题回答

### MQ1 历史代码搜索
Phase 2 的投影三件套与陈旧清理是直接先例；子代理投影照 `project_claude_hooks` 的状态表写；路径守卫复用 4a 的 `claude_adopt_path_ok`。

### MQ2 函数存在性（审查对照 Phase 4a 落地后的 `tad.sh` 复核，2026-10-09）
全部存在：`resolve_platform`、`claude_skill_set`、`claude_projection_incomplete`、`claude_hint_if_incomplete`、`claude_is_tad_pointer`、`project_claude_skills`、`project_claude_md_ref`、`project_claude_hooks`、`claude_print_summary`、`claude_prune_stale`、`rollback_claude_projection`、`claude_adopt_clean`、`claude_adopt_path_ok`、`claude_adopt_pred_set`、`_tad_ver_cmp`、`verify_install_complete`。`claude_projection_present`、`project_claude_agents` 是新增。行号会变，一律以函数名定位。

### MQ3 数据流
模板 →（提交）→ 生成器（历史行加固定行）→ 台账 `settings` 行 → `claude_adopt_*`（显式 claude-code 下旧模板可替换）／粘性下的 `CLAUDE-HOOKS-STALE` 判断。`.tad/agents/claude/*.md` → `project_claude_agents` → 目标 `.claude/agents/`。目标现状 → `claude_projection_present` → `CLAUDE_PROJECTION`、`CLAUDE_STICKY`。

### MQ4 不适用。 MQ5 状态同步：模板与台账由发版门强制同步。 MQ6 技术调研：`CLAUDE_PROJECT_DIR` 的可用性与空值行为均已实测。

---

## 6. Implementation Steps
0. 确认 Phase 4a 已提交；记下此时的 `git rev-parse HEAD` 作为 `P4_BASE`；记录 `git status --porcelain -uall` 基线；跑一遍 Phase 4a 的验收脚本确认起点全绿。对 `installer-data-safety-fixture.sh`、`tad-update-fixture.sh`、`detect-state-fixture.sh` 各跑一遍，把每件的失败用例名清单原样写进 completion 作基线。
1. §4.1 模板、提交、生成器固定行、台账。
2. §4.4（先做允许清单，§4.2 要用）。
3. §4.2 子代理投影。
4. §4.3 粘性。
5. §4.5、§4.6。
6. 跑本单 §9.1-RAW 脚本 `P4_BASE=<第 0 步的提交> bash <脚本> ALL`、Phase 4a 的验收脚本 `ALL`、三件既有 fixture（失败用例名清单须与第 0 步基线逐项相同，不新增失败；不得为让基线失败项通过而改安装器逻辑）、`installer-destructive-guard`、`--verify-denylist`、`skill-body-verify.sh`、`release-verify.sh provenance .`。**最后一次改动之后**必须有一次完整的 `ALL`；原始输出进 completion。

---

## 7. File Structure

### 7.1 Create
无新文件。

### 7.2 Modify
- `tad.sh`
- `.tad/templates/claude/settings.json`
- `.tad/provenance/claude-legacy.tsv`、`.tad/provenance/MANIFEST.sha1`、`.tad/provenance/README.md`、`.tad/scripts/gen-claude-provenance.sh`
- `.tad/agents/claude/spec-compliance-reviewer.md`（仅头部注释）
- `INSTALLATION_GUIDE.md`、`.tad/runtime-compat/claude-code.md`、`.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md`、`.tad/project-knowledge/patterns/runtime-adapter-checklist.md`

其余文件不改，特别是 `bin/tad-install.mjs`、`.tad/scripts/tad-update.sh`、`.tad/hooks/` 下任何脚本、`.claude/` 下任何东西、Epic 文件。

---

## 8. Testing Requirements

### 8.3 Edge Cases
`.claude` 或 `.claude/agents` 是符号链接；用户已有同名但内容不同的子代理定义；同名位置是符号链接；`.claude/agents` 不可写；粘性判据遇到：没装过 TAD 的项目、他人链接、只有两条手建标准链接的项目（都不应触发）；粘性项目里同时存在旧式实体目录（不接管）；粘性下 `CLAUDE.md` 没有引用块、`settings.json` 不存在（都不得被写）；粘性运行失败时回滚；skill 名含空格、换行、非 ASCII、以 `-` 开头、超过 64 字符；项目路径含空格；`CLAUDE_PROJECT_DIR` 未设置。

## 8.4 Friction Preflight
同 Phase 4a handoff §8.4 三行。

## 8.5 Feedback Collection
completion 里单列「本单哪条规定在实现时发现不成立或有歧义」。

---

## 9. Acceptance Criteria
- [ ] AC1 模板四条命令都是 §4.1 的锚定形式，JSON 可解析，模板已提交；台账含当前模板与 Phase 2 版模板的 blob；发版门通过。（B1）
- [ ] AC2 从子目录执行模板里的命令：变量指向项目根时跑的是项目根的脚本（路径含空格也成立）；变量未设置时在 sh、bash、zsh、dash 下都不执行任何脚本。（B1）
- [ ] AC3 目标里是 Phase 2 版模板的项目，用 `--platform claude-code --force` 重跑后 `settings.json` 等于新模板，存档里的旧文件等于 Phase 2 版模板；用户改过的 `settings.json` 保留。（B2）
- [ ] AC4 全新 claude-code 安装后子代理定义与源相同；用户已有的不同内容同名文件、同名符号链接都保留并有 `CLAUDE-AGENT-KEPT`；`.claude` 或 `.claude/agents` 是符号链接时不写穿；不可写时安装失败并回滚到安装前。（B3）
- [ ] AC5 已有 TAD Claude 投影的项目用 `--platform codex` 升级：有 `CLAUDE-STICKY`；新增 skill 有链接；旧式实体目录不被接管；`CLAUDE.md`、`.claude/settings.json`、`.claude/agents` 不被新建或改动；旧模板得到 `CLAUDE-HOOKS-STALE`；运行失败时 `.claude` 回到运行前；`TAD_CLAUDE_STICKY=off` 时 `.claude` 完全不动。（B4）
- [ ] AC6 判据不成立的项目用 `--platform codex`：没有 `CLAUDE-STICKY`，`.claude/` 不被创建或改动。（B5）
- [ ] AC7 名字不在允许清单里的 skill 不被投影并有 `CLAUDE-SKILL-SKIPPED`；旧 token 不再出现；`_archived` 不产生跳过行。（B7）
- [ ] AC8 安装摘要在 hook 已注册时含数据落点三处路径，`settings.json` 被保留时不含；`CLAUDE-HINT` 只在版本相等时出现。（B7）
- [ ] AC9 守卫：destructive-guard 通过；`RM-OK` 无重复；禁改文件相对 `P4_BASE` 无改动。（B10）
- [ ] AC10 Phase 4a 的验收脚本仍为 `== TOTAL FAILS: 0`。（Blake 与 Conductor 各跑一次）

## 9.1 Spec Compliance Checklist

验收依据是下面的脚本。提取方式与 Phase 4a 相同（私有临时路径）。在仓根运行 `P4_BASE=<Phase 4a 的提交> bash <脚本> ALL`，末行 `== TOTAL FAILS: 0` 才算通过。脚本默认用 `/bin/bash` 跑安装器（`P4_BASH` 可改）。脚本若有错，报告给 Alex，不要改实现迁就它。

基线（2026-10-09，Conductor 在 Phase 4a 提交 `89074250` 上用 `/bin/bash` 试跑第 3 版脚本）：70 项 FAIL、146 项 ok。失败项都是尚未实现的行为；已通过项是回归守卫与反向用例。B4(a)「pristine legacy command file left byte-identical under sticky」在基线上为 FAIL（非粘性的 codex 运行会删掉它），说明该行有判别力。

### §9.1-RAW — 可运行正本

```bash
# Phase 4a-2 acceptance script (handoff revision 3). Run from the repo root:
#   P4_BASE=<phase-4a commit> bash <this> ALL | <case...>
set -u
umask 022
REPO="$(pwd -P)"
[ -f "$REPO/tad.sh" ] && [ -d "$REPO/.tad" ] || { echo "run from repo root"; exit 2; }
for c in git rsync shasum tar awk python3 cmp diff; do command -v "$c" >/dev/null 2>&1 || { echo "missing tool: $c"; exit 2; }; done
[ "$(id -u)" != 0 ] || { echo "do not run as root"; exit 2; }
TPL_REL=".tad/templates/claude/settings.json"
P2_TPL_COMMIT=af97b99a                                   # Phase 2: the relative-path template
P2_TPL_BLOB=2cdede5eed8686345e3beee792da9c230daa2eb3
P2_TPL_WS=d94c5a368ddbb1cd0cff1d10142eaa75e695c59e          # the same template with blank, TAB, CR, LF removed
DEP_CMD_BLOB=017f0414f2a0166214b361616b119f9d1b24abaf       # a shipped .claude/commands/tad-blake.md (ledger row)
BUT="${P4_BASH:-/bin/bash}"                              # the bash that runs the installer under test
BASE="${P4_BASE:-HEAD}"
KEEP="${P4_KEEP:-0}"
ROOT="$(mktemp -d "${TMPDIR:-/tmp}/tad-p4bac.XXXXXX")"; ROOT="$(cd "$ROOT" && pwd -P)"
cleanup(){ [ "$KEEP" = 1 ] && { echo "(sandbox kept: $ROOT)"; return; }; case "$ROOT" in */tad-p4bac.*) chmod -R u+w "$ROOT" 2>/dev/null; rm -rf "$ROOT";; esac; }
trap cleanup EXIT
FAILS=0
ok(){ echo "  ok   $*"; }
bad(){ echo "  FAIL $*"; FAILS=$((FAILS+1)); }
chk(){ local l="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$l"; else bad "$l"; fi; }
eq(){ if [ "$2" = "$3" ]; then ok "$1 = $3"; else bad "$1: got '$2' want '$3'"; fi; }
cnt(){ grep -c -- "$1" "$2" 2>/dev/null | tr -d ' '; }
mode(){ stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1" 2>/dev/null; }
NEWSRC="$ROOT/newsrc"
mk_src(){ [ -d "$NEWSRC" ] && return 0; mkdir "$NEWSRC"
  ( cd "$REPO" && git ls-files -co --exclude-standard -z -- . ':!.claude' | rsync -a -0 --files-from=- . "$NEWSRC/" ) || { echo "cannot build NEWSRC"; exit 2; }; }
new_target(){ local sb="$ROOT/$1"; mkdir -p "$sb/t" "$sb/bk"; ( cd "$sb/t" && git init -q . ); echo "$sb"; }
# inst <sandbox> <src> <platform> [args...]   (env prefix via INST_ENV="K=V ...")
inst(){ local sb="$1" src="$2" plat="$3"; shift 3; local n; n=$(ls "$sb" | grep -c '^log\.')
  ( cd "$sb/t" && env TAD_BACKUP_ROOT="$sb/bk" ${INST_ENV:-} "$BUT" "$src/tad.sh" --source "$src" --platform "$plat" --yes "$@" >"$sb/log.$n" 2>&1 ); local rc=$?
  LASTLOG="$sb/log.$n"; return $rc; }
sig(){ ( cd "$1" 2>/dev/null || exit 0; find "${2:-.}" -name .git -prune -o -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r p; do
    if [ -L "$p" ]; then echo "L $p -> $(readlink "$p")"; elif [ -d "$p" ]; then echo "D $p $(mode "$p")"; else echo "F $p $(mode "$p") $(shasum -a 256 "$p" | cut -d' ' -f1)"; fi; done ); }
tplcmds(){ python3 - "$1" <<'PY'
import json,sys
d=json.load(open(sys.argv[1]))
for ev in d["hooks"].values():
    for g in ev:
        for h in g["hooks"]: print(h["command"])
PY
}

B1(){ echo "== B1 anchored hook template, its behaviour, and the ledger"; mk_src
  local T="$REPO/$TPL_REL" L="$REPO/.tad/provenance/claude-legacy.tsv" x
  chk "template is valid JSON" python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$T"
  tplcmds "$T" | LC_ALL=C sort > "$ROOT/b1.have"
  for x in startup-health.sh post-write-sync.sh lib/askuser-capture.sh precompact-session-snapshot.sh; do
    printf 'test -n "$CLAUDE_PROJECT_DIR" && { cd -- "$CLAUDE_PROJECT_DIR" || exit 1; } && bash .tad/hooks/%s\n' "$x"; done | LC_ALL=C sort > "$ROOT/b1.want"
  chk "the four hook commands are exactly the anchored forms" cmp -s "$ROOT/b1.have" "$ROOT/b1.want"
  chk "template file is committed (clean in git)" test -z "$(cd "$REPO" && git status --porcelain -- "$TPL_REL")"
  chk "the template really changed since Phase 2" test "$(git -C "$REPO" hash-object "$T")" != "$P2_TPL_BLOB"
  eq "current template blob is a settings row" "$(awk -F'\t' -v b="$(git -C "$REPO" hash-object "$T")" '$1=="settings"&&$2==b' "$L" | wc -l | tr -d ' ')" 1
  eq "Phase 2 template blob is a settings row" "$(awk -F'\t' -v b="$P2_TPL_BLOB" '$1=="settings"&&$2==b' "$L" | wc -l | tr -d ' ')" 1
  eq "Phase 2 settings-ws id is a settings-ws row" "$(awk -F'\t' -v b="$P2_TPL_WS" '$1=="settings-ws"&&$2==b' "$L" | wc -l | tr -d ' ')" 1
  chk "both Phase 2 ids are pinned as literals on a non-comment line of the generator" sh -c 'grep -v "^[[:space:]]*#" "$1" | grep -q "$2" && grep -v "^[[:space:]]*#" "$1" | grep -q "$3"' _ "$REPO/.tad/scripts/gen-claude-provenance.sh" "$P2_TPL_BLOB" "$P2_TPL_WS"
  eq "ledger rows of kind agent" "$(awk -F'\t' '$1=="agent"' "$L" | wc -l | tr -d ' ')" 0
  ( cd "$REPO" && bash .tad/hooks/lib/release-verify.sh provenance . >/dev/null 2>&1 ); eq "release-verify provenance rc" "$?" 0
  # behaviour: run the command string from a subdirectory that holds a decoy script
  local P="$ROOT/b1 with space/proj" M="$ROOT/b1.mark" cmd sh
  mkdir -p "$P/.tad/hooks" "$P/sub/.tad/hooks"
  echo 'echo real >> "$TAD_B1_MARK"' > "$P/.tad/hooks/startup-health.sh"
  echo 'echo decoy >> "$TAD_B1_MARK"' > "$P/sub/.tad/hooks/startup-health.sh"
  cmd="$(tplcmds "$T" | grep 'startup-health.sh$' | head -1)"
  [ -n "$cmd" ] && ok "startup-health command found in the template" || bad "startup-health command not found in the template"
  local nsh=0
  for sh in sh bash zsh dash; do command -v "$sh" >/dev/null 2>&1 || { echo "  (shell $sh not installed, skipped)"; continue; }
    nsh=$((nsh+1))
    : > "$M"; ( cd "$P/sub" && env TAD_B1_MARK="$M" CLAUDE_PROJECT_DIR="$P" "$sh" -c "$cmd" >/dev/null 2>&1 )
    eq "[$sh] variable set, run from a subdirectory: script that ran" "$(tr '\n' ' ' < "$M")" "real "
    : > "$M"; ( cd "$P/sub" && env -u CLAUDE_PROJECT_DIR TAD_B1_MARK="$M" "$sh" -c "$cmd" >/dev/null 2>&1 ); local rc=$?
    eq "[$sh] variable unset: scripts that ran" "$(wc -l < "$M" | tr -d ' ')" 0
    [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ] && ok "[$sh] variable unset: exit code is non-zero and not the blocking code 2 ($rc)" || bad "[$sh] variable unset: exit code $rc"
    : > "$M"; ( cd "$P/sub" && env TAD_B1_MARK="$M" CLAUDE_PROJECT_DIR= "$sh" -c "$cmd" >/dev/null 2>&1 )
    eq "[$sh] variable empty: scripts that ran" "$(wc -l < "$M" | tr -d ' ')" 0
    : > "$M"; ( cd "$P/sub" && env TAD_B1_MARK="$M" CLAUDE_PROJECT_DIR="$ROOT/b1-no-such-dir" "$sh" -c "$cmd" >/dev/null 2>&1 ); rc=$?
    eq "[$sh] variable names a missing directory: scripts that ran" "$(wc -l < "$M" | tr -d ' ')" 0
    [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ] && ok "[$sh] missing directory: exit code is non-zero and not 2 ($rc)" || bad "[$sh] missing directory: exit code $rc"
  done
  [ "$nsh" -ge 3 ] && ok "shells exercised: $nsh" || bad "only $nsh shells exercised (need sh, bash and at least one of zsh, dash)"; }

B2(){ echo "== B2 a project holding the Phase 2 template is moved to the new one (explicit claude-code only)"; mk_src
  local sb t; sb=$(new_target b2); t="$sb/t"
  inst "$sb" "$NEWSRC" claude-code; eq "first install rc" "$?" 0
  chk "fresh install has the current template" cmp -s "$t/.claude/settings.json" "$NEWSRC/$TPL_REL"
  ( cd "$REPO" && git show "$P2_TPL_COMMIT:$TPL_REL" ) > "$sb/p2.json"; cp "$sb/p2.json" "$t/.claude/settings.json"
  eq "fixture: Phase 2 template blob id" "$(git -C "$REPO" hash-object "$sb/p2.json")" "$P2_TPL_BLOB"
  inst "$sb" "$NEWSRC" claude-code --force; eq "re-run rc" "$?" 0
  chk "old TAD template replaced by the current template" cmp -s "$t/.claude/settings.json" "$NEWSRC/$TPL_REL"
  local arc; arc="$(find "$sb/bk" -path '*/claude-adopt/*/tree/.claude/settings.json' 2>/dev/null | head -1)"
  eq "archived copies of the old template" "$(find "$sb/bk" -path '*/claude-adopt/*/tree/.claude/settings.json' 2>/dev/null | wc -l | tr -d ' ')" 1
  chk "the archived copy is the Phase 2 template" cmp -s "${arc:-/nonexistent}" "$sb/p2.json"
  python3 - "$t/.claude/settings.json" <<'PY'
import json,sys
p=sys.argv[1]; d=json.load(open(p)); d["env"]={"MINE":"1"}; json.dump(d,open(p,"w"),indent=2)
PY
  cp "$t/.claude/settings.json" "$sb/mine.json"
  inst "$sb" "$NEWSRC" claude-code --force; eq "re-run with a user-edited settings rc" "$?" 0
  chk "negative control: a user-edited settings.json is kept" cmp -s "$t/.claude/settings.json" "$sb/mine.json"
  eq "data-path lines printed although settings.json was kept" "$(cnt 'Registered hooks write session data' "$LASTLOG")" 0; }

B3(){ echo "== B3 sub-agent definition projection"; mk_src
  local sb t f="spec-compliance-reviewer.md"; sb=$(new_target b3a); t="$sb/t"
  inst "$sb" "$NEWSRC" claude-code; eq "(a) rc" "$?" 0
  chk "(a) definition projected and identical to the source" cmp -s "$t/.claude/agents/$f" "$NEWSRC/.tad/agents/claude/$f"
  eq "(a) projected definition is a regular file, mode" "$( [ -L "$t/.claude/agents/$f" ] && echo link || mode "$t/.claude/agents/$f")" 644
  eq "(a) entries in .claude/agents" "$(ls -A "$t/.claude/agents" 2>/dev/null | wc -l | tr -d ' ')" "$(ls "$NEWSRC/.tad/agents/claude" | grep -c '\.md$' | tr -d ' ')"
  eq "(a) security-auditor (repo-local) projected" "$( [ -e "$t/.claude/agents/security-auditor.md" ] && echo yes || echo no)" no
  chk "(a) summary has an agents line" grep -Eq '^[[:space:]]*agents: [0-9]+ new' "$LASTLOG"
  sig "$t" .claude > "$sb/s1"; inst "$sb" "$NEWSRC" claude-code --force; eq "(a) forced re-run rc" "$?" 0; sig "$t" .claude > "$sb/s2"
  chk "(a) forced re-run leaves .claude identical" cmp -s "$sb/s1" "$sb/s2"
  chk "(a) data-path lines are printed again when the hooks are already current" grep -q 'Registered hooks write session data' "$LASTLOG"
  sb=$(new_target b3b); t="$sb/t"; mkdir -p "$t/.claude/agents"; echo 'my own reviewer' > "$t/.claude/agents/$f"
  inst "$sb" "$NEWSRC" claude-code; eq "(b) rc" "$?" 0
  eq "(b) user's same-named definition kept" "$(cat "$t/.claude/agents/$f")" 'my own reviewer'
  chk "(b) token CLAUDE-AGENT-KEPT" grep -q "CLAUDE-AGENT-KEPT $f" "$LASTLOG"
  eq "(b) CLAUDE-AGENT-UPDATED lines (no overwrite branch exists)" "$(cnt 'CLAUDE-AGENT-UPDATED' "$LASTLOG")" 0
  sb=$(new_target b3c); t="$sb/t"; mkdir -p "$t/.claude" "$sb/elsewhere"; ln -s "$sb/elsewhere" "$t/.claude/agents"
  inst "$sb" "$NEWSRC" claude-code; eq "(c) rc" "$?" 0
  eq "(c) entries written through a symlinked .claude/agents" "$(ls -A "$sb/elsewhere" | wc -l | tr -d ' ')" 0
  chk "(c) token CLAUDE-AGENTS-SKIPPED" grep -q 'CLAUDE-AGENTS-SKIPPED' "$LASTLOG"
  sb=$(new_target b3d); t="$sb/t"; mkdir -p "$t/.claude/agents"; echo 'target of my link' > "$sb/mine.md"; ln -s "$sb/mine.md" "$t/.claude/agents/$f"
  inst "$sb" "$NEWSRC" claude-code; eq "(d) rc" "$?" 0
  chk "(d) a symlink at the definition's name is still that symlink" test -L "$t/.claude/agents/$f"
  eq "(d) the link's target file" "$(cat "$sb/mine.md")" 'target of my link'
  chk "(d) token CLAUDE-AGENT-KEPT (not a regular file)" grep -q "CLAUDE-AGENT-KEPT $f (not a regular file" "$LASTLOG"
  sb=$(new_target b3e); t="$sb/t"; mkdir -p "$t/.claude/agents"; chmod 555 "$t/.claude/agents"; sig "$t" . > "$sb/s1"
  inst "$sb" "$NEWSRC" claude-code; [ "$?" -ne 0 ] && ok "(e) install fails when the definition cannot be written" || bad "(e) install reported success although .claude/agents is read-only"
  chk "(e) token CLAUDE-AGENTS-FAILED" grep -q 'CLAUDE-AGENTS-FAILED' "$LASTLOG"
  sig "$t" . > "$sb/s2"; chk "(e) target tree identical to the pre-install state after rollback" cmp -s "$sb/s1" "$sb/s2"
  eq "(e) temp files left in .claude/agents" "$(ls -A "$t/.claude/agents" | wc -l | tr -d ' ')" 0
  chmod 755 "$t/.claude/agents"
  sb=$(new_target b3f); t="$sb/t"; mkdir -p "$sb/outside"; ln -s "$sb/outside" "$t/.claude"
  inst "$sb" "$NEWSRC" claude-code; eq "(f) rc" "$?" 0
  eq "(f) entries written through a symlinked .claude" "$(ls -A "$sb/outside" | wc -l | tr -d ' ')" 0
  chk "(f) token CLAUDE-AGENTS-SKIPPED" grep -q 'CLAUDE-AGENTS-SKIPPED' "$LASTLOG"
  # (g) a failure AFTER the agents stage must take the definition away again
  sb=$(new_target b3g); t="$sb/t"; local src4="$ROOT/src-noskills"
  [ -d "$src4" ] || { rsync -a "$NEWSRC/" "$src4/"; rm -rf "$src4/.tad/skills"; }
  sig "$t" . > "$sb/s1"
  inst "$sb" "$src4" claude-code; [ "$?" -ne 0 ] && ok "(g) install fails after the projection stages" || bad "(g) install succeeded although .tad/skills is missing from the source"
  chk "(g) the failure is the late validation" grep -q 'Missing skills directory' "$LASTLOG"
  chk "(g) the agents stage had run before the failure" grep -q "CLAUDE-AGENT-NEW $f" "$LASTLOG"
  sig "$t" . > "$sb/s2"; chk "(g) target identical to the pre-install state (no leftover .claude/agents)" cmp -s "$sb/s1" "$sb/s2"
  # (h) odd shapes at the target and at the source
  sb=$(new_target b3h); t="$sb/t"; mkdir -p "$t/.claude/agents/$f"; echo keep > "$t/.claude/agents/$f/mine.txt"
  inst "$sb" "$NEWSRC" claude-code; eq "(h) rc with a directory at the definition's name" "$?" 0
  eq "(h) user's file inside that directory" "$(cat "$t/.claude/agents/$f/mine.txt" 2>/dev/null)" keep
  sb=$(new_target b3i); t="$sb/t"; mkdir -p "$t/.claude"; echo 'a file' > "$t/.claude/agents"
  inst "$sb" "$NEWSRC" claude-code; eq "(i) rc when .claude/agents is a regular file" "$?" 0
  eq "(i) that file" "$(cat "$t/.claude/agents" 2>/dev/null)" 'a file'
  chk "(i) token CLAUDE-AGENTS-SKIPPED" grep -q 'CLAUDE-AGENTS-SKIPPED' "$LASTLOG"
  sb=$(new_target b3j); t="$sb/t"; local src5="$ROOT/src-symagent"
  [ -d "$src5" ] || { rsync -a "$NEWSRC/" "$src5/"; echo 'SECRET' > "$ROOT/secret.txt"; ln -s "$ROOT/secret.txt" "$src5/.tad/agents/claude/zz-leak.md"; }
  inst "$sb" "$src5" claude-code; eq "(j) rc with a symlinked definition in the source" "$?" 0
  eq "(j) symlinked source definition projected" "$( { [ -e "$t/.claude/agents/zz-leak.md" ] || [ -L "$t/.claude/agents/zz-leak.md" ]; } && echo yes || echo no)" no; }

# sticky fixture: a claude-code install, then a source with one extra skill
mk_plus(){ SRC2="$ROOT/src-plus"; [ -d "$SRC2" ] && return 0; rsync -a "$NEWSRC/" "$SRC2/"; mkdir -p "$SRC2/.agents/skills/zz-new-skill"
  printf -- '---\nname: zz-new-skill\ndescription: test\n---\nbody\n' > "$SRC2/.agents/skills/zz-new-skill/SKILL.md"; }

B4(){ echo "== B4 sticky projection on another platform: links only"; mk_src; mk_plus
  local sb t f="spec-compliance-reviewer.md"
  # (a) full projection present; codex upgrade
  sb=$(new_target b4a); t="$sb/t"; printf '# my rules\n' > "$t/CLAUDE.md"     # the installer only maintains its block in an existing CLAUDE.md
  inst "$sb" "$NEWSRC" claude-code; eq "(a) claude-code install rc" "$?" 0
  chk "(a) fixture: CLAUDE.md holds the managed block" grep -q 'TAD:AGENTS-REF:BEGIN' "$t/CLAUDE.md"
  mkdir -p "$t/.claude/skills/legacy-like"; echo '# mine' > "$t/.claude/skills/legacy-like/SKILL.md"
  ( cd "$REPO" && git archive v2.44.6 .claude/skills/tad-help | tar -x -C "$sb" ) && rm -f "$t/.claude/skills/tad-help" && cp -R "$sb/.claude/skills/tad-help" "$t/.claude/skills/tad-help"
  chk "(a) fixture: a pristine legacy real directory sits inside the projected project" test -f "$t/.claude/skills/tad-help/SKILL.md"
  ( cd "$REPO" && git show "$P2_TPL_COMMIT:$TPL_REL" ) > "$t/.claude/settings.json"
  mkdir -p "$t/.claude/commands"; ( cd "$REPO" && git cat-file blob "$DEP_CMD_BLOB" ) > "$t/.claude/commands/tad-blake.md"; cp "$t/.claude/commands/tad-blake.md" "$sb/cmd1"
  chk "(a) fixture: the pristine command file is non-empty" test -s "$sb/cmd1"
  sig "$t/.claude" skills/tad-help > "$sb/h1"; cp "$t/CLAUDE.md" "$sb/md1"; cp "$t/.claude/settings.json" "$sb/set1"; sig "$t/.claude" agents > "$sb/ag1"
  inst "$sb" "$SRC2" codex --force; eq "(a) codex upgrade rc" "$?" 0
  eq "(a) CLAUDE-STICKY lines" "$(cnt '^.*CLAUDE-STICKY:' "$LASTLOG")" 1
  chk "(a) new skill got its link although the platform was codex" test -L "$t/.claude/skills/zz-new-skill"
  sig "$t/.claude" skills/tad-help > "$sb/h2"; chk "(a) legacy real directory is NOT adopted under sticky" cmp -s "$sb/h1" "$sb/h2"
  eq "(a) CLAUDE-ADOPTED lines under sticky" "$(cnt 'CLAUDE-ADOPTED' "$LASTLOG")" 0
  eq "(a) adoption archives created under sticky" "$(find "$sb/bk" -type d -name claude-adopt 2>/dev/null | wc -l | tr -d ' ')" 0
  chk "(a) user's own skill directory untouched" test -f "$t/.claude/skills/legacy-like/SKILL.md"
  chk "(a) CLAUDE.md byte-identical" cmp -s "$t/CLAUDE.md" "$sb/md1"
  chk "(a) older TAD hook template left byte-identical under sticky" cmp -s "$t/.claude/settings.json" "$sb/set1"
  chk "(a) token CLAUDE-HOOKS-STALE" grep -q 'CLAUDE-HOOKS-STALE' "$LASTLOG"
  sig "$t/.claude" agents > "$sb/ag2"; chk "(a) .claude/agents identical" cmp -s "$sb/ag1" "$sb/ag2"
  eq "(a) data-path lines under sticky" "$(cnt 'Registered hooks write session data' "$LASTLOG")" 0
  chk "(a) regression guard: .codex/hooks.json present after the codex run" test -f "$t/.codex/hooks.json"
  chk "(a) pristine legacy command file left byte-identical under sticky" cmp -s "$t/.claude/commands/tad-blake.md" "$sb/cmd1"
  chk "(a) token CLAUDE-DEPRECATION-SKIPPED for it" grep -q 'CLAUDE-DEPRECATION-SKIPPED .claude/commands/tad-blake.md' "$LASTLOG"
  eq "(a) agents summary lines under sticky" "$(grep -Ec '^[[:space:]]*agents: ' "$LASTLOG" | tr -d ' ')" 0
  chk "(a) summary is marked sticky" grep -q '(sticky: links only)' "$LASTLOG"
  inst "$sb" "$SRC2" claude-code --force; eq "(a) positive control: explicit claude-code run rc" "$?" 0
  chk "(a) positive control: the same legacy directory IS adopted by an explicit claude-code run" grep -q 'CLAUDE-ADOPTED' "$LASTLOG"
  # (b) projection with CLAUDE.md block, settings.json and agents removed: sticky via link count; nothing recreated
  sb=$(new_target b4b); t="$sb/t"
  inst "$sb" "$NEWSRC" claude-code; eq "(b) claude-code install rc" "$?" 0
  printf '# my rules\n' > "$t/CLAUDE.md"; rm -f "$t/.claude/settings.json"; rm -f "$t/.claude/agents/$f"; rmdir "$t/.claude/agents" 2>/dev/null
  inst "$sb" "$SRC2" codex --force; eq "(b) codex upgrade rc" "$?" 0
  eq "(b) CLAUDE-STICKY lines" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 1
  chk "(b) new skill got its link" test -L "$t/.claude/skills/zz-new-skill"
  eq "(b) CLAUDE.md after the sticky run" "$(cat "$t/CLAUDE.md")" '# my rules'
  eq "(b) .claude/settings.json created under sticky" "$( [ -e "$t/.claude/settings.json" ] && echo yes || echo no)" no
  eq "(b) .claude/agents created under sticky" "$( [ -e "$t/.claude/agents" ] && echo yes || echo no)" no
  eq "(b) CLAUDE-HOOKS-STALE lines when there is no settings.json" "$(cnt 'CLAUDE-HOOKS-STALE' "$LASTLOG")" 0
  # (c) a failing sticky run rolls .claude back
  sb=$(new_target b4c); t="$sb/t"
  inst "$sb" "$NEWSRC" claude-code; eq "(c) claude-code install rc" "$?" 0
  chmod 555 "$t/.claude/skills"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; [ "$?" -ne 0 ] && ok "(c) sticky run fails when the new link cannot be created" || bad "(c) sticky run reported success although .claude/skills is read-only"
  sig "$t" .claude > "$sb/s2"; chk "(c) .claude identical to the state before the failed run" cmp -s "$sb/s1" "$sb/s2"
  chmod 755 "$t/.claude/skills"
  # (d) opt-out
  sb=$(new_target b4d); t="$sb/t"; printf '# my rules\n' > "$t/CLAUDE.md"
  inst "$sb" "$NEWSRC" claude-code; eq "(d) claude-code install rc" "$?" 0
  sig "$t" .claude > "$sb/s1"; cp "$t/CLAUDE.md" "$sb/md1"
  INST_ENV="TAD_CLAUDE_STICKY=off" inst "$sb" "$SRC2" codex --force; eq "(d) codex upgrade with TAD_CLAUDE_STICKY=off rc" "$?" 0
  eq "(d) CLAUDE-STICKY lines" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(d) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  chk "(d) CLAUDE.md unchanged" cmp -s "$t/CLAUDE.md" "$sb/md1"
  # (e) no sticky line on a run that does nothing
  sb=$(new_target b4e); t="$sb/t"
  inst "$sb" "$NEWSRC" claude-code; eq "(e) claude-code install rc" "$?" 0
  inst "$sb" "$NEWSRC" codex; eq "(e) same-version codex run rc" "$?" 0
  chk "(e) the same-version gate was reached" grep -q 'Nothing to do' "$LASTLOG"
  eq "(e) CLAUDE-STICKY lines on a run that does nothing" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  rm -f "$t/.claude/settings.json"
  inst "$sb" "$NEWSRC" codex; eq "(e) same-version codex run without settings.json rc" "$?" 0
  eq "(e) CLAUDE-HINT lines on a codex run that does nothing" "$(cnt 'CLAUDE-HINT' "$LASTLOG")" 0
  # (f) prune under sticky removes only dangling standard-form links
  sb=$(new_target b4f); t="$sb/t"; printf '# my rules\n' > "$t/CLAUDE.md"
  inst "$sb" "$NEWSRC" claude-code; eq "(f) claude-code install rc" "$?" 0
  local k="$t/.claude/skills"
  ln -s ../../.agents/skills/zz-gone "$k/zz-gone"                       # dangling, standard form: stale
  ln -s ../elsewhere/zz-odd "$k/zz-odd"                                 # dangling, other form: not TAD's
  mkdir -p "$sb/live"; ln -s "$sb/live" "$k/zz-live"                    # live foreign link
  mkdir -p "$k/zz-mine"; echo '# mine' > "$k/zz-mine/SKILL.md"; echo x > "$k/zz-mine/notes.txt"   # user's directory
  inst "$sb" "$SRC2" codex --force; eq "(f) codex upgrade rc" "$?" 0
  eq "(f) CLAUDE-STICKY lines" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 1
  eq "(f) dangling standard-form link still there" "$( [ -L "$k/zz-gone" ] && echo yes || echo no)" no
  chk "(f) dangling link of another form kept" test -L "$k/zz-odd"
  chk "(f) live foreign link kept" test -L "$k/zz-live"
  chk "(f) user's directory kept with both files" test -f "$k/zz-mine/SKILL.md" -a -f "$k/zz-mine/notes.txt"
  chk "(f) a live TAD link (alex) kept" test -L "$k/alex"; }

B5(){ echo "== B5 no sticky without a TAD projection"; mk_src; mk_plus
  local sb t n
  sb=$(new_target b5a); t="$sb/t"
  inst "$sb" "$NEWSRC" codex; eq "(a) rc" "$?" 0
  eq "(a) CLAUDE-STICKY lines" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  eq "(a) .claude created by a codex install" "$( [ -e "$t/.claude" ] || [ -L "$t/.claude" ] && echo yes || echo no)" no
  eq "(a) CLAUDE.md created by a codex install" "$( [ -e "$t/CLAUDE.md" ] && echo yes || echo no)" no
  # (b) installed TAD project; a foreign link named alex
  sb=$(new_target b5b); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(b) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills" "$sb/mine"; ln -s "$sb/mine" "$t/.claude/skills/alex"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(b) rc" "$?" 0
  eq "(b) CLAUDE-STICKY lines for a foreign link" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(b) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  # (c) installed TAD project; two hand-made standard-form links, nothing else
  sb=$(new_target b5c); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(c) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills"; for n in alex blake; do ln -s "../../.agents/skills/$n" "$t/.claude/skills/$n"; done; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(c) rc" "$?" 0
  eq "(c) CLAUDE-STICKY lines for two hand-made links" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(c) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  eq "(c) CLAUDE.md created" "$( [ -e "$t/CLAUDE.md" ] && echo yes || echo no)" no
  # (d) positive control for (c): same project plus the managed CLAUDE.md marker
  printf '# mine\n\n<!-- TAD:AGENTS-REF:BEGIN (managed by tad.sh) -->\n@AGENTS.md\n<!-- TAD:AGENTS-REF:END -->\n' > "$t/CLAUDE.md"; cp "$t/CLAUDE.md" "$sb/md1"
  inst "$sb" "$SRC2" codex --force; eq "(d) rc" "$?" 0
  eq "(d) positive control: CLAUDE-STICKY lines once the marker is present" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 1
  chk "(d) new skill got its link" test -L "$t/.claude/skills/zz-new-skill"
  chk "(d) CLAUDE.md byte-identical" cmp -s "$t/CLAUDE.md" "$sb/md1"
  eq "(d) .claude/settings.json created under sticky" "$( [ -e "$t/.claude/settings.json" ] && echo yes || echo no)" no
  # (e) standard-form links in a directory where TAD was never installed and .agents is absent: a first codex install
  sb=$(new_target b5e); t="$sb/t"; mkdir -p "$t/.claude/skills"; for n in alex blake a b c; do ln -s "../../.agents/skills/$n" "$t/.claude/skills/$n"; done
  printf '<!-- TAD:AGENTS-REF:BEGIN (managed by tad.sh) -->\n@AGENTS.md\n<!-- TAD:AGENTS-REF:END -->\n' > "$t/CLAUDE.md"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$NEWSRC" codex; eq "(e) rc" "$?" 0
  eq "(e) CLAUDE-STICKY lines where TAD was never installed" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(e) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  # (f)-(k): every other condition holds, exactly one is violated; the marker CLAUDE.md is present unless stated
  local MARK='# mine\n\n<!-- TAD:AGENTS-REF:BEGIN (managed by tad.sh) -->\n@AGENTS.md\n<!-- TAD:AGENTS-REF:END -->\n'
  # (f) condition 1: no .tad/version.txt
  sb=$(new_target b5f); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(f) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills"; for n in alex blake; do ln -s "../../.agents/skills/$n" "$t/.claude/skills/$n"; done; printf "$MARK" > "$t/CLAUDE.md"
  rm -f "$t/.tad/version.txt"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force
  eq "(f) CLAUDE-STICKY lines without .tad/version.txt" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(f) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  # (g) condition 5(c) boundary: alex + 2 others, no marker -> no; alex + 3 others -> yes
  sb=$(new_target b5g); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(g) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills"; set -- $(ls "$t/.agents/skills" | grep -v '^alex$' | grep -E '^[A-Za-z0-9][A-Za-z0-9._-]*$' | head -3)
  ln -s ../../.agents/skills/alex "$t/.claude/skills/alex"; ln -s "../../.agents/skills/$1" "$t/.claude/skills/$1"; ln -s "../../.agents/skills/$2" "$t/.claude/skills/$2"
  sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(g) rc" "$?" 0
  eq "(g) CLAUDE-STICKY lines with alex + 2 standard links and no marker" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(g) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  ln -s "../../.agents/skills/$3" "$t/.claude/skills/$3"
  inst "$sb" "$SRC2" codex --force; eq "(g) rc with a third link" "$?" 0
  eq "(g) positive control: CLAUDE-STICKY lines with alex + 3 standard links" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 1
  # (h) condition 4: alex is a link, but not the standard one
  sb=$(new_target b5h); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(h) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills"; ln -s "$t/.agents/skills/alex" "$t/.claude/skills/alex"; printf "$MARK" > "$t/CLAUDE.md"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(h) rc" "$?" 0
  eq "(h) CLAUDE-STICKY lines when alex is an absolute link (marker present)" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(h) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  # (i) condition 3: .claude/skills is a symlink to a directory holding standard links
  sb=$(new_target b5i); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(i) codex install rc" "$?" 0
  mkdir -p "$t/.claude" "$t/.hold/x"; ln -s ../../.agents/skills/alex "$t/.hold/x/alex"; ln -s ../.hold/x "$t/.claude/skills"; printf "$MARK" > "$t/CLAUDE.md"
  sig "$t" .hold > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(i) rc" "$?" 0
  eq "(i) CLAUDE-STICKY lines when .claude/skills is a symlink" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .hold > "$sb/s2"; chk "(i) directory behind the symlink unchanged" cmp -s "$sb/s1" "$sb/s2"
  # (j) condition 5(a): CLAUDE.md is a symlink to a file holding the marker
  sb=$(new_target b5j); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(j) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills"; ln -s ../../.agents/skills/alex "$t/.claude/skills/alex"; printf "$MARK" > "$sb/real.md"; ln -s "$sb/real.md" "$t/CLAUDE.md"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(j) rc" "$?" 0
  eq "(j) CLAUDE-STICKY lines when CLAUDE.md is a symlink" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(j) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"
  # (k) condition 4: alex is a directory that only claims to be a TAD pointer
  sb=$(new_target b5k); t="$sb/t"; inst "$sb" "$NEWSRC" codex; eq "(k) codex install rc" "$?" 0
  mkdir -p "$t/.claude/skills/alex"; printf -- '---\nname: alex\ntad_pointer: true\n---\nnot the generated body\n' > "$t/.claude/skills/alex/SKILL.md"; printf "$MARK" > "$t/CLAUDE.md"; sig "$t" .claude > "$sb/s1"
  inst "$sb" "$SRC2" codex --force; eq "(k) rc" "$?" 0
  eq "(k) CLAUDE-STICKY lines for a look-alike pointer directory" "$(cnt 'CLAUDE-STICKY:' "$LASTLOG")" 0
  sig "$t" .claude > "$sb/s2"; chk "(k) .claude unchanged" cmp -s "$sb/s1" "$sb/s2"; }

B7(){ echo "== B7 skill name allow-list, hint condition, summary text"; mk_src
  local sb t src3="$ROOT/src-names" n long; rsync -a "$NEWSRC/" "$src3/"
  long="$(printf 'a%.0s' $(seq 1 65))"; NL="$(printf 'good\n-rf x')"; NL2="$(printf 'ok\nalso')"; local max="$(printf 'b%.0s' $(seq 1 64))" TABN="$(printf 'a\tb')"
  for n in "has space" "-dash" "ok.name_1" "$max" "$long" "$NL" "$NL2" "caf$(printf '\303\251')" "$TABN" ";x"; do mkdir -p "$src3/.agents/skills/$n"; printf -- '---\nname: x\ndescription: x\n---\n' > "$src3/.agents/skills/$n/SKILL.md"; done
  sb=$(new_target b7); t="$sb/t"
  INST_ENV="LC_ALL=en_US.UTF-8" inst "$sb" "$src3" claude-code; eq "rc (installer run in a UTF-8 locale)" "$?" 0
  chk "allowed name is projected" test -L "$t/.claude/skills/ok.name_1"
  chk "a 64-character name is projected" test -L "$t/.claude/skills/$max"
  for n in "has space" "-dash" "$long" "$NL" "$NL2" "caf$(printf '\303\251')" "$TABN" ";x"; do
    eq "disallowed name projected ($(printf '%s' "$n" | tr -c 'A-Za-z0-9._ -' '?' | cut -c1-20))" "$( { [ -e "$t/.claude/skills/$n" ] || [ -L "$t/.claude/skills/$n" ]; } && echo yes || echo no)" no; done
  eq "entries in .claude/skills whose name is outside the allow-list" "$(ls -A "$t/.claude/skills" | LC_ALL=C grep -cvE '^[A-Za-z0-9][A-Za-z0-9._-]*$' | tr -d ' ')" 0
  eq ".claude/skills entries that are not a whole directory name of the source" "$(ls -A "$t/.claude/skills" | while IFS= read -r e; do [ -d "$src3/.agents/skills/$e" ] || echo "$e"; done | wc -l | tr -d ' ')" 0
  eq "CLAUDE-SKILL-SKIPPED lines (one per disallowed name)" "$(cnt 'CLAUDE-SKILL-SKIPPED' "$LASTLOG")" 8
  eq "old token CLAUDE-SKILL-NAME-SKIPPED in the log" "$(cnt 'CLAUDE-SKILL-NAME-SKIPPED' "$LASTLOG")" 0
  eq "old token CLAUDE-SKILL-NAME-SKIPPED in tad.sh" "$(cnt 'CLAUDE-SKILL-NAME-SKIPPED' "$REPO/tad.sh")" 0
  eq "SKIPPED lines naming _archived" "$(grep 'CLAUDE-SKILL-SKIPPED' "$LASTLOG" | grep -c '_archived' | tr -d ' ')" 0
  chk "summary names the precompact snapshot directory" grep -q '\.tad/active/precompact' "$LASTLOG"
  chk "summary names the last-stdin path" grep -q '\.tad/evidence/hooks/precompact-snapshot/last-stdin.json' "$LASTLOG"
  chk "summary names the decisions path" grep -q '\.tad/evidence/decisions' "$LASTLOG"
  chk "summary suggests the ignore rule for these three paths" grep -q 'three paths to .gitignore' "$LASTLOG"
  local sb2 t2; sb2=$(new_target b7h); t2="$sb2/t"
  inst "$sb2" "$NEWSRC" codex; eq "(hint) codex install rc" "$?" 0
  echo 99.0.0 > "$t2/.tad/version.txt"
  inst "$sb2" "$NEWSRC" claude-code; eq "(hint) installed-newer run rc" "$?" 0
  chk "(hint) the version gate was reached" grep -q 'Nothing to do' "$LASTLOG"
  eq "(hint) CLAUDE-HINT lines when the installed version is newer" "$(cnt 'CLAUDE-HINT' "$LASTLOG")" 0
  cp "$NEWSRC/.tad/version.txt" "$t2/.tad/version.txt"
  inst "$sb2" "$NEWSRC" claude-code; chk "(hint) positive control: CLAUDE-HINT when versions are equal and the projection is missing" grep -q 'CLAUDE-HINT' "$LASTLOG"; }

B10(){ echo "== B10 guards"
  ( cd "$REPO" && bash .tad/hooks/lib/release-verify.sh installer-destructive-guard . >/dev/null 2>&1 ); eq "installer-destructive-guard rc" "$?" 0
  eq "duplicate RM-OK ids in tad.sh" "$(grep -o 'RM-OK:[A-Za-z0-9_-]*' "$REPO/tad.sh" | sort | uniq -d | wc -l | tr -d ' ')" 0
  chk "/bin/bash -n tad.sh" /bin/bash -n "$REPO/tad.sh"
  eq "forbidden files changed since $BASE (commits and working tree)" "$( { cd "$REPO" && git diff --name-only "$BASE" -- bin/tad-install.mjs .tad/scripts/tad-update.sh .tad/hooks; git status --porcelain -- bin/tad-install.mjs .tad/scripts/tad-update.sh .tad/hooks; } | wc -l | tr -d ' ')" 0
  [ -n "${P4_BASE:-}" ] && ok "P4_BASE is set ($BASE)" || bad "P4_BASE is not set: the two comparisons against the Phase 4a commit are not meaningful"
  local m0 m1; m0="$(cd "$REPO" && git show "$BASE:tad.sh" | grep -E '(^|[;&|[:space:]])mv[[:space:]]' | grep -vc 'RM-OK:' | tr -d ' ')"; m1="$(grep -E '(^|[;&|[:space:]])mv[[:space:]]' "$REPO/tad.sh" | grep -vc 'RM-OK:' | tr -d ' ')"
  [ "$m1" -le "$m0" ] && ok "lines with a mv command and no RM-OK marker did not increase ($m0 -> $m1)" || bad "new unmarked mv lines in tad.sh ($m0 -> $m1)"
  eq "files under .claude/ tracked by git" "$(cd "$REPO" && git ls-files .claude | wc -l | tr -d ' ')" 0; }

ALLCASES="B1 B2 B3 B4 B5 B7 B10"
[ $# -ge 1 ] || { echo "usage: $0 ALL | <case...>   cases: $ALLCASES"; exit 2; }
[ "$1" = ALL ] && set -- $ALLCASES
for c in "$@"; do case " $ALLCASES " in *" $c "*) "$c";; *) echo "unknown case $c"; exit 2;; esac; done
echo "== TOTAL FAILS: $FAILS"
[ "$FAILS" -eq 0 ]
```

## 9.2 Expert Review Status
### Audit Trail
| 轮次 | 审查 | 结论 | 处置 |
|---|---|---|---|
| 1 | code-reviewer | FAIL：2 P0、11 P1、8 P2（`phase4a2-design-review-cr.md`） | P0-1 → §4.1 固定顺序加生成器固定行；P0-2 → §4.3 新判据；P1-1 → §4.4；P1-2 → `CLAUDE-HOOKS-STALE`；P1-3、P1-11 → 原 FR7／FR8 挪 Phase 5；P1-4 → 删 UPDATED 与 `agent` 台账；P1-5 → §4.5 三处路径加反例；P1-6 → §4.4；P1-7 → §4.2；P1-8、P1-9 → B4 (a)–(e)；P1-10 → B10 用 `P4_BASE`、B7 断言退出码与版本闸；P2-2 → 默认 `/bin/bash`；P2-3 → B1 行为用例；P2-6 → 固定行 |
| 1 | security-auditor | CONDITIONAL PASS：3 P0、4 P1、6 P2（`phase4a2-design-review-sec.md`） | P0-1 → §4.3 判据第 1、2 条；P0-2 → 粘性收窄为只维护链接，加 `TAD_CLAUDE_STICKY=off`；P0-3 → §4.2 表第 1 行与 B3(f)；P1-1 → `case` 加 64 上限；P1-2 → `test -n` 形式与 B1 四种 shell；P1-3 → `CLAUDE-HOOKS-STALE`；P1-4 → 覆盖分支已删 |
| 2 | code-reviewer | CONDITIONAL PASS：0 P0、6 P1、17 P2（`phase4a2-design-review-r2-cr.md`） | P1-1 → §4.3 求值位置、删 5(b)；P1-2 → §4.1 两条字面量固定行；P1-3 → §4.2 回滚不比较源、B3(g)；P1-4 → B7 第二个换行名与子集检查；P1-5 → §4.2 守卫类型 `p`；P1-6 → §6 fixture 基线、删 §4.6 fixture 补用例。P2 已改入：1、2、3、4、5、6、7、8、10、11、13、15、16、17 |
| 2 | security-auditor | PASS WITH CONDITIONS：0 P0、5 P1、8 P2（`phase4a2-design-review-r2-sec.md`） | N-P1-1 → §4.3；N-P1-2 → §4.2 五步顺序；N-P1-3 → B5(f)–(k)、§10.2 重写；N-P1-4 → B4(f) 清理用例、B3(g)；N-P1-5 → `git commit --only`。P2 已改入：1（`|| exit 1`）、2、3、4（部分）、5、6、7、8 |

Gate 2 结论：两轮后 0 P0；第 2 轮的 P1 全部按审查给出的替换文本改入第 3 版，不再开第 3 轮（上限两轮）。

### Experts Selected
code-reviewer（必选）、security-auditor（命中：改 hook 注册内容、对用户项目目录写入）。

---

## 10. Important Notes

### 10.1 Critical Warnings
同 Phase 4a handoff §10.1 五条，逐条适用。另：
- 本单只授权一类提交：只含 `.tad/templates/claude/settings.json` 的本地提交（§4.1）。其余改动留在工作区。不推送。
- 粘性下任何对 `CLAUDE.md`、`.claude/settings.json`、`.claude/agents` 的写入都是缺陷。

### 10.2 Known Constraints / 明确延后
- 粘性是对 Phase 2「非 claude-code 平台不碰 `.claude/`」的**有条件放宽**。判据只检查目标目录的现状，而一个仓库可以整体提交这些现状（`.tad/version.txt`、`.agents/skills/alex/SKILL.md`、`.claude/skills/alex` 链接或伪造的指路目录、`CLAUDE.md` 里一行标记）。所以克隆来的任何仓库都可能让粘性成立。粘性成立时安装器只做两件事：在已是真实目录的 `.claude/skills` 下为 `.agents/skills` 里的合格名字建相对链接；删除悬空的标准形式链接与未被引用的 TAD 指路目录。不新建 `settings.json`、不写 `CLAUDE.md`、不建子代理、不接管。这与仓库作者本来就能提交 `.claude/skills/*` 的能力相比没有新增。已知并接受；`TAD_CLAUDE_STICKY=off` 可整体关闭；写进 `INSTALLATION_GUIDE.md`。
- 粘性运行不删除原样的旧版 `.claude/commands/*`（显式 claude-code 也不删）。
- 经更新入口升级的项目不会自动换到新 hook 模板，只会看到 `CLAUDE-HOOKS-STALE`。
- 子代理定义不会随升级自动更新。
- `CLAUDE_PROJECT_DIR` 若未设置，四条 hook 静默不执行（2.1.295 上实测每个事件都有值）。
- 会话从子目录启动时 hook 不触发（R-CC-6）不在本单范围。
- 同版本闸不变。
- 验收脚本只走 `--source` 模式；下载模式下的行为（尤其回滚时源树已删）靠设计规定与审查保证，Blake 在 completion 里注明。

### 10.3 Sub-Agent 使用建议
同 Phase 4a。

---

## 11. Decision Summary

| # | 决策 | 备选 | 选择 | 理由 |
|---|---|---|---|---|
| 1 | hook 锚定方式 | 脚本路径写绝对／`cd "$VAR" &&`／先判空再 `cd --` | 先判空再 `cd --` | `cd ""` 在三种 shell 里成功，等于没锚定；`${VAR:?}` 在 dash 里给出阻断码 |
| 2 | 新模板 blob 如何进台账 | 生成器读工作区／手改台账／先提交模板再生成 | 先提交再生成 | 保持生成器「同一历史得同一输出」 |
| 3 | 粘性的范围 | 与显式 claude-code 相同／只维护链接 | 只维护链接 | 平台参数不是 claude-code 的运行不应新建可执行的 hook 配置或改 `CLAUDE.md` |
| 4 | 粘性的判据 | 任一标准链接／装过 TAD 且 `alex` 是 TAD 入口且另有一项佐证 | 后者 | 标准链接可以是手建的，也可以随克隆的仓库带来 |
| 5 | 子代理定义的更新 | 台账命中则覆盖／不同即保留 | 不同即保留 | 覆盖需要完整的存档与回滚路径，收益很小 |
| 6 | 原 FR7、FR8 | 留在本单／挪走 | 挪到 Phase 5 | 一单做不完；二者与安装器无耦合 |

## 12. Sub-Agent使用记录
（Blake 填写）

## Required Evidence Manifest
- `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4a2-completion.md`：Step 0 基线与 `P4_BASE`；本单与 Phase 4a 两个验收脚本在**最后一次改动之后**的 `ALL` 完整原始输出；§4.3 的 `CLAUDE_PROJECTION` 代码点列表；§4.4 的名字集合位置列表；NFR2 的删除／移动语句列表；fixture 前后对比；其余命令输出；§8.5 反馈。
