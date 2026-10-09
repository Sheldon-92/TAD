---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/provenance", ".tad/tests", ".tad/scripts"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.2 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-09（第 2 版：Gate 2 第 1 轮后修订，见 §9.2）
**Project:** TAD Framework
**Task ID:** TASK-20261009-CLAUDE-LEGACY-ADOPTION
**Handoff Version:** 3.2.0
**Epic:** EPIC-20261008-multi-harness-restore-and-cleanup.md (Phase 4a/6)
**Supersedes:** N/A
**Grounding:** `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4-grounding.md`（585 行；本单凡引 `tad.sh:N` 均出自该文件，动手前以现文件复核行号）
**Design input (not binding):** `.tad/evidence/yolo/multi-harness-restore-and-cleanup/workflow-runs/tournament-phase4-legacy-adoption-design.md`。本单是它的**收窄版**，凡与本单冲突处以本单为准。
**Risk card:** `.tad/evidence/risk-cards/risk-TASK-20261009-CLAUDE-LEGACY-ADOPTION.md`

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|---|---|---|
| Architecture Complete | ✅ | 「凭证明腾位，由未改动的 Phase 2 投影填位」；四个面各有判定表（§4.3–§4.6） |
| Components Specified | ✅ | 台账、生成器、`claude_adopt_{notice,preflight,apply,commit}`、路径守卫、回滚、报告、弃用清理收紧（§4） |
| Functions Verified | ✅ | §5 MQ2 |
| Data Flow Mapped | ✅ | §5 MQ3 |

---

## 1. Task Overview

### 1.1 What We're Building
让 `tad.sh --platform claude-code` 在**旧版 Claude Code 安装**上不再造出混合状态。旧安装的 `.claude/skills/<name>` 是实体目录副本，`.claude/settings.json` 是旧版整文件，`CLAUDE.md` 顶部是旧版 TAD 正文，`.claude/workflows/` 是旧版 workflow 副本。现在的安装器把这些一律当成「用户所有」保留，结果是 53 个新链接加 10 个过期目录、hook 不注册、摘要不提这是旧版残留（grounding §16）。

本单新增「接管」：对能**逐字节证明**是 TAD 历史上发出去的条目，先在项目外存档并校验，再腾位，交给现有投影补位；证明不了的原样不动并写进报告。

### 1.2 Why
同步盘下 51 个已装项目里有 39 个带旧式实体目录（grounding §6）。不做接管，这 39 个项目升级到 3.3.0 后 Claude Code 读到的仍是过期 skill，等于没恢复。

### 1.3 Intent Statement
- 真正要解决：旧安装升级后，Claude Code 读到的是当前 skill，且用户没有丢任何东西。
- 不是要做：通用的 `.claude/settings.json` 合并器；阻断型 hook 的恢复；`--force` 式的强制接管；从存档一键还原的命令。
- 判断标准：对任何一个字节，要么能指出它在台账里的哪一行，要么它在升级后仍在原处、内容不变。

### 1.4 卸载记录（Offload Log）
| 卸给 | 内容 | 状态 |
|---|---|---|
| Phase 4a-2（另单） | hook 命令锚定项目根、子代理定义投影、平台粘性、`CLAUDE-HINT` 版本条件、skill 名允许清单、`3.2.0-to-3.3.0` 迁移清单、基线 5 项 fixture 失败 | 未开单 |
| Phase 4b | 四家真机回归 | 未开单 |
| 人 | TAD 仓自身的 `.claude/` 自举 | 留给人执行 |

---

## 📚 Project Knowledge（Blake 必读）

- `.tad/project-knowledge/patterns/shell-portability.md`：悬空符号链接条目（先 `-L` 再 `-d/-f/-e`）；BSD 与 GNU 差异。
- `.tad/project-knowledge/patterns/ac-verification.md`：2026-10-08 两条（探针要有阳性对照；幂等性检查不能落在空操作闸后面）。
- `.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md`：Claude Code 实例声明与残项。
- `.tad/archive/handoffs/HANDOFF-2026-10-08-claude-code-installer-projection.md` §4.0 通则：本单全部沿用，不重抄。

---

## 2. Background Context

- 旧安装器对 skill 是整目录 `cp -r`，对 `settings.json` 是无条件整文件覆盖，对 workflow 是覆盖式复制，都没有任何标记（grounding §2）。所以「是不是 TAD 发的」只能靠内容判断。
- 实测可识别率：skill 目录逐文件比对全部提交历史为 97.1%；`settings.json` 39/40；workflow 文件 97.1%；`CLAUDE.md` 带标记线的 31 份里 27 份标记线以上部分与某个已发版本一致（grounding 末表）。
- 51 个项目的 `settings.json` 里**没有任何用户自加的 hook 或键**（grounding §9）。因此本单不做 hook 级合并。
- 旧 `settings.json` 的 `permissions.deny` 是空数组；`PreToolUse(Write|Edit)` 是一条规则全为放行的提示型 hook；`PreToolUse(Skill)` 两条是阻断型脚本。Epic 既定口径是「默认不恢复阻断型 hook」。接管后与全新安装一致，旧文件在存档里。
- 8 个项目有 `<name>/<name>/` 自嵌套副本，共 1,909 个文件，全部与已发文件逐字节相同（grounding §7）。
- 现有备份机制 `backup_existing` 只覆盖 `.tad/`，在项目外；项目内的 `.tad-backup/` 没有忽略规则且在同步盘里（grounding §15）。

---

## 3. Requirements

### 3.1 Functional
- **FR1 台账**：`.tad/provenance/claude-legacy.tsv` 由生成器从 git 历史产出，记录 TAD 发过的每个相关文件的内容标识与相对路径。只从 `$TAD_SRC` 读，不分发到目标项目。
- **FR2 skill 目录接管**：目录内每个文件都可证明时，存档、校验、把原目录改名到墓碑位置，随后由 `project_claude_skills` 建链接；安装自检通过后才删除墓碑。
- **FR3 `settings.json` 接管**：整文件可证明时，存档后腾位，随后由 `project_claude_hooks` 落模板。
- **FR4 `CLAUDE.md` 接管**：旧版 TAD 正文可证明时去掉它，保留标记线以下的全部字节，随后由 `project_claude_md_ref` 追加引用块。
- **FR5 workflow 副本接管**：`.claude/workflows/<f>` 可证明时存档后腾位。
- **FR6 报告**：每个被接管和被留下的条目各一行，留下的写明原因；存一份到存档目录。
- **FR7 模式**：`--claude-adopt=apply|plan|off`，默认 `apply`。
- **FR8 回滚**：安装失败时，本次接管过的条目全部从墓碑移回原位。
- **FR9 其余平台**：非 claude-code 平台对旧 `.claude/` 与 `CLAUDE.md` 逐字节不动，只多打印一行 `CLAUDE-LEGACY-DETECTED`。
- **FR10 弃用清理收紧**：非 claude-code 平台按名删除 `.claude/commands/<name>` 前，先要求该文件内容在台账里；不在则保留并打印 `CLAUDE-CMD-KEPT`。

### 3.2 Non-Functional
- NFR1 不新增硬依赖。没有可用的 SHA-1 工具、台账缺失或损坏、备份根无法解析、存在遗留墓碑时，接管降级为只报告，安装照常成功。
- NFR2 幂等：接管成功后再跑一次，不产生新存档，`.claude/` 与 `CLAUDE.md` 不变。
- NFR3 所有删除语句带唯一 `RM-OK:<id>` 标记，`installer-destructive-guard` 通过。
- NFR4 不读、不写 `.claude/settings.local.json`。

---

## 4. Technical Design

### 4.0 通则
沿用 Phase 2 handoff §4.0 全部条目。补充：
1. 每个 `claude_adopt_*` 函数以 `[ "$CLAUDE_PROJECTION" = "1" ] || return 0` 开头；`CLAUDE_ADOPT_MODE=off` 时同样直接返回。
2. 任何「腾位」动作前必须在同一函数内**重新证明**一次。预检的结论只用于生成计划和提示，不作为腾位依据。
3. 证明只有「是」与「不是」两种结果。任何读取失败、工具缺失、意外文件类型都算「不是」。
4. **路径守卫** `claude_adopt_path_ok <相对路径>`：从项目根起逐级检查该路径的每一个父级分量，任何一级是符号链接或不是目录即返回非 0；最后一级按调用方声明的类型（目录或普通文件）用先 `-L` 的方式检查。它在预检时调用一次，并在每个 `mv` 之前**紧挨着**再调用一次。`assert_under_root` 只比较路径字符串（`tad.sh:322-328`），不能替代它。
5. **文件名**：含控制字符（`LC_ALL=C` 下的 `[[:cntrl:]]`，包括换行）的条目名或其内部任一路径一律判「不是」，且不逐字打印（打印时把控制字符替换为 `?`）。枚举目录内容用 `find … -print0` 配 `read -r -d ''`。台账查询用整行精确匹配（`grep -F -x` 或 `awk` 等值比较），不用正则。
6. 循环里要修改的计数与清单不得放在管道右侧的子 shell 里；已腾位清单以**文件**为准（§4.7 `done.tsv`），不依赖内存变量。

### 4.1 台账与生成器

**内容标识用 git blob id**（40 位十六进制 SHA-1）。安装时这样算，不需要 git：
```
{ printf 'blob %s\0' "$(LC_ALL=C wc -c < "$f" | tr -d ' ')"; cat -- "$f"; } | <sha1 工具> | cut -d' ' -f1
```
SHA-1 工具按序探测 `shasum -a 1`、`sha1sum`、`openssl sha1`（后者输出取最后一个字段）；都没有则降级（§4.2）。新增函数 `claude_blob_id <file>` 封装它。Blake 必须用 `git hash-object` 对 3 个以上文件（含一个 0 字节文件）做对照，把对照输出贴进 completion。

**文件** `.tad/provenance/`：
```
claude-legacy.tsv     台账
MANIFEST.sha1         一行：台账文件的 blob id
README.md             格式说明，≤30 行
```
`MANIFEST.sha1` 只防意外损坏（截断、同步冲突、手改），不防有意篡改；能改源的人本来就能改安装器。README 里照此写明。

**台账格式**：首行 `# schema=1 rows=<n>`（不含提交哈希，否则提交后无法复现），其后每行 `kind<TAB>id<TAB>key`，`LC_ALL=C sort -u`。

| kind | id | key | 来源 |
|---|---|---|---|
| `skill` | blob id | `<skill 名>/<skill 内相对路径>` | 输入范围内 `.claude/skills/<n>/**` 与 `.agents/skills/<n>/**` 下出现过的每个 blob |
| `flat` | blob id | `<文件名>` | `.claude/skills/<f>`（直接位于 skills 目录下的普通文件） |
| `settings` | blob id | `-` | `.claude/settings.json` 与 `.tad/templates/claude/settings.json` 的每个历史 blob |
| `settings-ws` | 见下 | `-` | 对上面每个**非空** blob：`LC_ALL=C tr -d ' \t\r\n' \| <sha1 工具>` 的结果（普通 SHA-1）。去空白后长度为 0 的不入账 |
| `md-whole` | blob id | `-` | 根 `CLAUDE.md` 的每个**不含标记线**的历史 blob |
| `md-head` | 见下 | `-` | 根 `CLAUDE.md` 的每个**含标记线**的历史 blob 的头部字节流的普通 SHA-1 |
| `workflow` | blob id | `<文件名>` | `.claude/workflows/<f>` 的每个历史 blob |
| `cmd` | blob id | `<文件名>` | `.claude/commands/<f>` 的每个历史 blob |

**头部字节流的唯一定义**（生成器与安装器必须用同一组命令，逐字照抄）：
```
n=$(LC_ALL=C grep -n -x -F -e '<!-- TAD:PROJECT-CONTENT-BELOW -->' -- "$f" | head -1 | cut -d: -f1)
[ -n "$n" ] && head -n "$n" -- "$f" | <sha1 工具>
```
`grep -x` 要求整行相等，所以行尾带回车的文件没有标记线，按「不是」处理。

**输入范围**：`git rev-list HEAD $(git tag -l 'v*')` 可达的全部提交。结果只在上述路径有新 blob 时才变化，所以台账提交之后重新生成仍逐字节相同；一旦模板或 skill 有新版本而没重新生成，发版门就会失败，这正是要的。

**生成器** `.tad/scripts/gen-claude-provenance.sh`：只在 TAD 仓里运行，需要 git；写 `claude-legacy.tsv` 与 `MANIFEST.sha1`；重复运行输出逐字节相同；tag 数少于 78 时拒绝运行。

**不分发到目标项目**：把 `provenance` 加进 `tad.sh` 的 `TAD_TRANSIENT` 与 `.tad/hooks/lib/derive-sync-set.sh` 的对应清单，两处同改；`bash tad.sh --verify-denylist` 必须通过。
**但要随安装包分发**：`package.json` 的 `files` 白名单加一行 `".tad/provenance/"`，否则经 npx 安装时台账不在源里，接管永远降级。

**发版门** `release-verify.sh provenance <repo>`：(1) `MANIFEST.sha1` 与台账一致；(2) 首行 `rows=` 与实际数据行数一致；(3) 当前 `.tad/templates/claude/settings.json` 的 blob id 在台账的 `settings` 行里；(4) 当前 `.agents/skills/alex/SKILL.md` 的 blob id 在 `skill` 行里（抽样证明台账跟上了 HEAD）。第 (3) 条就是 hook 模板的升级通道。

### 4.2 入口、模式与调用位置

- 新参数 `--claude-adopt=apply|plan|off`，环境变量 `TAD_CLAUDE_ADOPT` 等价，命令行优先。非法值在参数校验阶段报错退出，不改任何文件。`bin/tad-install.mjs` 与 `tad-update.sh` 本单不改，经它们安装时用环境变量；写进 `INSTALLATION_GUIDE.md`。
- 没传 `--platform claude-code` 时该参数被接受但不起作用。
- 调用顺序（新增标 NEW）：
```
交互确认提示之前：claude_adopt_notice            NEW 只读，不需要源
各平台 preflight
claude_adopt_preflight "$TAD_SRC"                NEW 只读；plan 模式在此打印计划后 exit 0
backup_existing
NEED_ROLLBACK=1 ; take_rollback_snapshot
  copy_framework_files
    …
    claude_adopt_apply "$src"                    NEW 紧挨在 project_claude_skills 之前
    project_claude_skills ; project_claude_md_ref ; project_claude_hooks
    verify_install_complete
claude_prune_stale
discard_rollback_snap ; NEED_ROLLBACK=0          （现有）
claude_adopt_commit                              NEW 仅成功路径，且必须在 NEED_ROLLBACK=0 之后；清掉墓碑
claude_print_summary                             加接管行
```
- `claude_adopt_notice`：平台为 claude-code、模式为 `apply`、且 `.claude/skills` 下存在至少一个含普通文件 `SKILL.md` 的实体目录时，在「Continue?」提示（`tad.sh:3898` 附近）之前打印固定两行。此时源还没下载（下载在 `tad.sh:3915` 之后），所以这里不比对框架 skill 名，也不哈希：
  `Legacy Claude Code install detected. Entries under .claude/ and the TAD part of CLAUDE.md that are byte-identical to files TAD shipped will be archived outside the project and replaced by the current version; entries that differ are left as they are.`
  `Preview without changing anything: add --claude-adopt=plan`
- **降级**：以下任一成立即设 `CLAUDE_ADOPT_MODE=report`，打印一行 `CLAUDE-ADOPT-DEGRADED <原因>`，只分类和报告，不腾位，安装照常成功：没有 SHA-1 工具；台账不存在；`MANIFEST.sha1` 不符；`rows=` 不符；存在上次运行留下的墓碑目录（§4.8）；备份根无法解析（下一条）。
- **备份根**：`backup_existing` 在目标没有 `.tad/` 时直接返回（`tad.sh:700-702`），此时 `TAD_BACKUP_ROOT_ABS` 与 `BACKUP_GROUP` 为空。`claude_adopt_apply` 需要存档时若二者任一为空，必须自己调用 `resolve_backup_root` 与 `repo_group_key`（`tad.sh:538`、`:597` 附近）；调用后仍有一个为空、或存档目录建不出来，则降级，不腾位。`plan` 模式永不解析、永不创建备份根。
- `.claude` 是符号链接或不是目录时，**四个面全部跳过**（含 `CLAUDE.md`），打印 `CLAUDE-ADOPT-DEGRADED .claude is not a plain directory`。`.claude/skills` 或 `.claude/workflows` 是符号链接或不是目录时，只跳过那一个面。
- `plan` 模式：分类，打印 `CLAUDE-ADOPT-PLAN adopt=<a> retire=<r> left=<l> user=<u>` 与逐条目行，然后 `exit 0`。此时项目与备份根都必须零改动。

### 4.3 skill 面

对 `.claude/skills/` 下每个条目 `e`（名字 `n`；名字以 `.` 开头的跳过）：

| 情形 | 判定 | 动作 |
|---|---|---|
| `e` 是符号链接，或已是 TAD 指路目录 | 现有 Phase 2 规则 | 不变 |
| `e` 是普通文件，`claude_blob_id` 命中 `flat<TAB><id><TAB>n` | `RETIRED` | 腾位 |
| `e` 是普通文件，未命中 | `LEFT (unrecognised file)` | 不动 |
| `e` 是目录，`n` 不在台账任何 `skill` 行的 skill 名里，也不在源的 `.agents/skills/` 目录名里 | `USER` | 不动、不哈希，只计数 |
| `e` 是目录，逐文件证明全部通过，`n` 在本次将投影的 skill 集合里 | `ADOPT` | 腾位 |
| `e` 是目录，逐文件证明全部通过，`n` **不是**源 `.agents/skills/` 下的目录名 | `RETIRED` | 腾位（不建链接） |
| `e` 是目录，逐文件证明全部通过，`n` 在源里但不在将投影的集合里（例如 `--packs` 只选了一部分） | `LEFT (not selected for this install)` | 不动 |
| `e` 是目录，至少一个条目证明不了 | `LEFT (modified)` | 不动；报告前 5 个未通过的相对路径 |

**逐文件证明**：枚举 `e` 下全部条目（§4.0 第 5 条）：
- 符号链接或其他特殊类型：不通过。
- 目录：通过；但名为 `local` 且直接位于 `e` 下时不通过（项目自有内容）。
- 普通文件，相对路径 `r`：
  1. **自嵌套归一**：`r` 若以 `n/` 开头，反复去掉这个前缀，得到 `r'`。
  2. `skill<TAB><id><TAB>n/r'` 在台账里（id、路径两者同时相等）：通过。
  3. 与 `$TAD_SRC/.agents/skills/n/r'` 都是普通文件且 `cmp -s` 相同：通过。
  4. `r'` 等于 `.tad-pack-meta.yaml` 且满足：首行以 `# Auto-generated by tad.sh` 开头，含一行 `sync_policy: upstream`，不含 `sync_policy: forked`：通过。Blake 须以 `git show v2.44.6:tad.sh` 里 `generate_pack_meta` 的实际输出核对首行文字，不符则以实际为准并在 completion 里说明。
  5. 文件名是 `.DS_Store`：通过（随目录一起存档）。
  6. 其余：不通过。
- 目录里没有任何经第 2 或第 3 条通过的普通文件时不通过。

「本次将投影的 skill 集合」在预检阶段从 `$TAD_SRC/.agents/skills/*/SKILL.md` 结合 `--packs` 选择预测，在 `claude_adopt_apply` 里用目标内已装好的 `.agents/skills` 重算（即 `claude_skill_set`）。

### 4.4 `settings.json` 面（仅普通文件）

按序取第一个成立的：
1. 与模板 `cmp -s` 相同：`CURRENT`，不动。
2. 文件为 0 字节，或去空白后为 0 字节：`LEFT`。
3. `claude_blob_id` 命中 `settings` 行：`ADOPT`。
4. `LC_ALL=C tr -d ' \t\r\n' < 文件 | <sha1 工具>` 命中 `settings-ws` 行：`ADOPT`。已知并接受：字符串值内部的空白差异会被忽略；这不影响所有权判断，因为任何新增的键或 hook 都会改变结果。
5. 其余（含不可读）：`LEFT`，现有 `CLAUDE-HOOKS-KEPT` 行为不变。

`ADOPT` 的动作是存档后腾位；`project_claude_hooks` 随后走它已有的「不存在则落模板」分支。汇总里加两行，原文固定为：
```
hooks: legacy TAD settings.json replaced by the current template (previous file archived).
       Hooks that only the old file registered are no longer active; where present, that includes the PreToolUse checks pre-accept-check.sh and pre-gate-check.sh. The scripts stay in .tad/hooks/.
```

### 4.5 `CLAUDE.md` 面（仅普通、可写文件；且目标内 `AGENTS.md` 是普通文件）

按序取第一个成立的：
1. 文件里已有整行 `@AGENTS.md`：不动（Phase 2 行为）。
2. `claude_blob_id` 命中 `md-whole`：`ADOPT-WHOLE`。新内容为 0 字节。
3. 按 §4.1 的唯一定义取到头部且其 SHA-1 命中 `md-head`：`ADOPT-HEAD`。新内容是 `tail -n +$((n+1))` 的输出，即标记线之后的全部字节，一个字节不改。
4. 其余：`LEFT`，Phase 2 行为不变（末尾追加引用块）。

改写方式与 Phase 2 §4.3 相同：同目录临时文件、保留权限位、`mv`。`CLAUDE.md` 已在回滚快照里（`tad.sh:2277-2317`），回滚由快照负责；存档里另存一份原文件。

随后 `project_claude_md_ref` 追加引用块。它对**非空**文件的行为（必要时补行尾换行，再写一个空行和三行引用块，`tad.sh:3500-3512`）是 Phase 2 的契约，**不得改动**。它对 **0 字节**文件现在会先写一个空行：本单授权只为这一种输入加一个分支，使结果恰好是三行引用块，没有前导空行。

### 4.6 workflow 面

`.claude/workflows/` 下每个普通文件 `f`：`claude_blob_id` 命中 `workflow<TAB><id><TAB>f` 则 `ADOPT`（存档后腾位），否则 `LEFT`，并在报告里附固定提示：
`calling this workflow by its saved name may load this copy instead of .tad/workflows/claude/<f>`
`.claude/workflows` 的 `rmdir` 放在 `claude_adopt_commit` 里、墓碑删掉之后：目录此时为空才删，带自己的 `RM-OK` 标记；失败只记一行提示。子目录与符号链接不碰。

`.claude/commands`、`.claude/agents`、`.claude/rules`：claude-code 平台下只在报告里给出文件数，不动。

### 4.7 存档

位置：`"$TAD_BACKUP_ROOT_ABS/$BACKUP_GROUP/claude-adopt/<YYYYMMDD_HHMMSS>[.n]/"`。目录名 `claude-adopt` 不匹配 `prune_backups` 的时间戳正则（`tad.sh:636-695`），所以不会被保留策略清掉；Blake 须读代码确认并写一条 fixture。时间戳目录用**不带 `-p` 的 `mkdir`** 创建，已存在就换下一个 `.n`，这样两个同时运行的安装器不会共用一个存档。权限 700。

```
tree/<相对路径>    每个将被腾位条目的 cp -R -p 副本（CLAUDE.md 也存一份）
plan.tsv           面、相对路径、判定、证明方式
done.tsv           腾位日志：每个条目在 mv 之前追加一行「相对路径<TAB>墓碑相对路径」
report.md          §4.9 的报告
origin.txt         目标根的物理路径
manifest.txt       在全部副本校验通过之后、第一个 mv 之前写；它存在才表示存档完整
```

**只存档将被腾位的条目。** 判为 `LEFT`、`USER` 的条目不复制到存档（它们可能含用户的凭据或私有内容）。报告与日志只写路径和判定，不写文件内容。

每个副本做 `diff -r`（目录）或 `cmp -s`（文件）校验。任何一步失败：打印 `CLAUDE-ADOPT-FAILED archive`，函数返回非 0，此时项目内尚无改动。计划里没有任何腾位条目时不建存档目录。

### 4.8 `claude_adopt_apply`、提交、回滚与自检

顺序固定：skill 面 → workflow 面 → `CLAUDE.md` → `settings.json`。

**腾位用改名，不直接删除。** 墓碑位置与原条目在同一目录、同一文件系统。墓碑目录用不带 `-p` 的 `mkdir` 创建，已存在即视为遗留墓碑并降级；`mv` 之前确认墓碑内的目标名不存在：
- skill 条目：`.claude/skills/.tad-adopt-tomb.<pid>/<n>`
- workflow 文件：`.claude/workflows/.tad-adopt-tomb.<pid>/<f>`
- `settings.json`：`.claude/.tad-adopt-tomb.<pid>.settings.json`

每个腾位条目依次：
1. `claude_adopt_path_ok`；重新证明（§4.0 第 2 条）。结论变了就降为 `LEFT`，打印 `CLAUDE-ADOPT-LEFT <路径> (changed since preflight)`。
2. 往 `done.tsv` 追加一行。
3. `mv --` 到墓碑。
4. 对墓碑与存档副本再做一次 `diff -r` 或 `cmp -s`。不同（说明校验之后、改名之前有东西变了）：按下面的「移回规则」把墓碑移回原位，在 `done.tsv` 追加一行 `REVERTED<TAB><相对路径>`，降为 `LEFT`，打印 `CLAUDE-ADOPT-LEFT <路径> (changed during adoption)`。自检与回滚读 `done.tsv` 时跳过已 `REVERTED` 的条目。
5. 打印 `CLAUDE-ADOPTED <路径> (<ledger|equal|mixed>)`。

第 2 步失败：打印 `CLAUDE-ADOPT-FAILED <路径>`，返回非 0，交给现有失败路径触发回滚。第 3 步 `mv` 失败时：若是 skill 条目或 workflow 文件（例如条目自身不可写），从 `done.tsv` 的角度记 `REVERTED`，降为 `LEFT (cannot be moved)`，继续；若是 `settings.json`，打印 `CLAUDE-ADOPT-FAILED .claude/settings.json` 并返回非 0。

**移回规则**（第 4 步与回滚共用，写成一个函数）：仅当原位置 `[ ! -e ] && [ ! -L ]` 且 `claude_adopt_path_ok` 通过时才 `mv`；移回后确认原位置是与墓碑同类型的条目且墓碑里已无此项。原位置被占用时**绝不** `mv`（`mv 目录 已存在目录` 会嵌套进去，`mv 目录 指向目录的链接` 会穿过链接），把两处路径写进小结，条目留在墓碑里。

**提交** `claude_adopt_commit`（仅成功路径，在 `verify_install_complete` 通过且 `NEED_ROLLBACK=0` 之后；函数内任何命令失败都不得让安装器退出，全部以 `|| …` 接住）：对 `done.tsv` 里每个未 `REVERTED` 的条目：先把墓碑与存档副本再比对一次（`diff -r` 或 `cmp -s`），**不同则保留墓碑**并在小结里写明路径；相同才删除（目录先 `chmod -R u+w`）。每个删除点先 `claude_adopt_path_ok`、再 `assert_under_root`，各带一条唯一的 `# RM-OK:claude-adopt-<面>` 标记。墓碑目录空了才 `rmdir`。这里任何失败只打印提示（墓碑留在原处，路径写进小结），不让安装失败。这是全流程唯一不可逆的一步。

**回滚** `rollback_claude_adoption`：在 `rollback_claude_projection`（`tad.sh:3689`）**之后**调用。按 `done.tsv` 倒序、跳过 `REVERTED`，对每个条目执行上面的「移回规则」。`CLAUDE.md` 由快照还原。空的墓碑目录 `rmdir` 掉。存档目录保留。回滚不从存档复制：墓碑就是原件，权限与时间戳不变。

**上次运行留下的墓碑**（进程被杀）：预检在 `.claude/`、`.claude/skills/`、`.claude/workflows/` 三处查找，发现任何 `.tad-adopt-tomb.*` 即降级（§4.2），打印 `CLAUDE-ADOPT-DEGRADED leftover <路径>`，并在报告里给出固定的手工处理说明（把墓碑里的条目移回原位或删除墓碑，然后重跑）。安装器不自动处理它。

**自检**（并入 `verify_install_complete`）：`done.tsv` 里每个 `ADOPT` 的 skill 现在必须是目标文字为 `../../.agents/skills/<n>` 的符号链接，或 TAD 指路目录；`settings.json` 若被接管则必须与模板相同；`CLAUDE.md` 若被接管则必须含整行 `@AGENTS.md`。任一不满足即失败并回滚。

### 4.9 报告与汇总

- 逐条目行：`CLAUDE-ADOPTED …`、`CLAUDE-ADOPT-LEFT <路径> (<原因>)`。
- 小结行：`CLAUDE-ADOPT-DONE adopted=<a> retired=<r> left=<l> user=<u>`；有存档时再一行 `CLAUDE-ADOPT-ARCHIVE <绝对路径>`。
- `report.md`：三节「Adopted」「Left for you」「Yours」。「Left for you」每条给出相对路径、原因、未通过的前 5 个文件，以及一条可照抄的比较命令 `diff -r .claude/skills/<n> .agents/skills/<n>`。「Yours」只给数量，不列名字。末尾固定文字五段：如何从存档手工还原一个条目（并提醒：原位置若已是链接，先删链接再移回，不要直接 `mv` 覆盖）；项目若把 `.claude/` 纳入了 git，接管会显示为删除加新增链接，需要自行提交；存档不会被自动清理，里面有接管前完整的 `CLAUDE.md`，确认无误后可自行删除；判断只看字节——若你有意停留在某个旧版 skill，它与已发版本一致就会被当前版本取代；旧 `CLAUDE.md` 头部里的 `@.tad/project-knowledge/...` 引入行随头部一起去掉，由 `AGENTS.md` 接替。
- `claude_note_kept` 对实体目录的措辞从 `(user-owned)` 改为按判定输出 `(legacy copy, modified)`、`(not selected)` 或 `(user-owned)`，汇总行相应拆开。
- 非 claude-code 平台：目标存在 `.claude/skills` 实体目录且其中至少一个目录名在源 `.agents/skills/` 里时，在安装小结里打印一行
  `CLAUDE-LEGACY-DETECTED: this project has a legacy Claude Code install; run with --platform claude-code to adopt it (dry run: add --claude-adopt=plan).`
  只读判断，不哈希。

### 4.10 弃用清理收紧（FR10）

位置 `apply_deprecations`（`tad.sh:2006-2197`）。在非 claude-code 平台、目标路径形如 `.claude/commands/<f>` 且是普通文件时：
- 台账可用且 `cmd<TAB><id><TAB>f` 命中：照旧（备份后删除）。
- 否则：跳过该条，打印 `CLAUDE-CMD-KEPT .claude/commands/<f> (not a file TAD shipped)`。
- 台账不可用或没有 SHA-1 工具：一律跳过并打印同一行，原因写 `(provenance unavailable)`。

claude-code 平台下 Phase 2 的整体跳过不变。

### 4.11 Fixture 与文档

- `.tad/tests/installer-data-safety-fixture.sh` 新增用例，至少覆盖 §9 的每条 AC；fixture 用 `git archive <tag>` 取历史内容搭建，不复制任何真实项目。
- `INSTALLATION_GUIDE.md`：新增一节「从旧版 Claude Code 安装升级」，写明：先 `--claude-adopt=plan` 看计划；存档位置；哪些会被替换；阻断型 hook 不再注册；如何手工还原；Syncthing 等同步工具对符号链接的处理未测。
- `.tad/runtime-compat/claude-code.md` 加一行 `legacy adoption`；`runtime-adapter-instance-claude-code.md` 加残项 R-CC-8：「迁移引擎拒绝路径中含符号链接的清单条目，所以今后的迁移清单不得再列 `.claude/skills/**` 路径」（grounding §17）。

---

## 5. 强制问题回答

### MQ1 历史代码搜索
旧安装器的复制行为见 grounding §2；`merge_claude_md` 与标记线见 §4。本仓现有代码里没有任何按内容识别旧文件的实现。

### MQ2 函数存在性（Alex 抽核，2026-10-09，`grep -n` 于 `tad.sh` 现文件）
`assert_under_root` 322；`resolve_backup_root` 538；`backup_existing` 699；`validate_platform` 842；`resolve_platform` 863；`copy_framework_files` 1481；`verify_install_complete` 1778；`apply_deprecations` 2006；`take_rollback_snapshot` 2277；`rollback_on_failure` 2466；`claude_skill_set` 3204；`claude_projection_incomplete` 3237；`claude_note_kept` 3266；`claude_is_tad_pointer` 3288；`project_claude_skills` 3340；`project_claude_md_ref` 3465；`project_claude_hooks` 3534；`claude_print_summary` 3589；`claude_prune_stale` 3634；`rollback_claude_projection` 3689；`main` 3733。全局 `TAD_BACKUP_ROOT_ABS` 82、`BACKUP_GROUP` 83；`TAD_TRANSIENT` 在 897 行附近。
未核实：`guarded_remove`、`do_backup` 不是顶层 `name()` 形式的定义（grep 未命中），grounding 引用它们在 `apply_deprecations` 内使用。Blake 动手前先定位，并在 completion 里写明实际定义位置。

### MQ3 数据流
`$TAD_SRC/.tad/provenance/claude-legacy.tsv` → `claude_adopt_preflight`（分类，写临时 `plan.tsv`）→ `claude_adopt_apply`（重证、存档到备份根、记 `done.tsv`、改名到墓碑）→ `project_claude_*`（补位）→ `verify_install_complete` → `claude_adopt_commit`（删墓碑）→ `claude_print_summary`。失败支路：`rollback_on_failure` → `rollback_claude_projection` → `rollback_claude_adoption`（按 `done.tsv` 把墓碑移回）。

### MQ4 不适用（无 UI）。
### MQ5 状态同步
台账与模板必须同步：由 §4.1 发版门第 (3) 条强制。`tad.sh` 与 `derive-sync-set.sh` 的排除清单同步：由 `--verify-denylist` 强制。

### MQ6 技术调研
不引入新工具。git blob id 的算法是 `sha1("blob " + 字节数 + "\0" + 内容)`。

---

## 6. Implementation Steps

0. 读 grounding 全文与本单；定位 MQ2 里未核实的两个函数；记录 `git status --porcelain -uall` 基线到 completion。
1. 写生成器，产出台账与 `MANIFEST.sha1`；用 `git hash-object` 对照 `claude_blob_id`；把两处排除清单同改并跑 `--verify-denylist`。
2. `release-verify.sh` 加 `provenance` 子命令。
3. `tad.sh`：参数与模式、`claude_blob_id`、台账查询函数、`claude_adopt_preflight`。此时 `plan` 模式可用，先用它在 fixture 上核对分类。
4. `claude_adopt_apply`、存档、`rollback_claude_adoption`、自检、汇总与报告。
5. `apply_deprecations` 收紧；`CLAUDE-LEGACY-DETECTED`。
6. Fixture；文档；台账因模板或历史变化需要时重新生成。
7. 跑 §9.1-RAW 脚本 `ALL`、三件既有 fixture、`installer-destructive-guard`、`skill-body-verify.sh`，把原始输出贴进 completion。

每一步之后都重跑上一步已通过的检查。

---

## 7. File Structure

### 7.1 Create
- `.tad/provenance/claude-legacy.tsv`、`.tad/provenance/MANIFEST.sha1`、`.tad/provenance/README.md`
- `.tad/scripts/gen-claude-provenance.sh`

### 7.2 Modify
- `tad.sh`
- `.tad/hooks/lib/derive-sync-set.sh`（仅排除清单一处）
- `.tad/hooks/lib/release-verify.sh`（仅新增 `provenance` 子命令）
- `package.json`（仅 `files` 白名单加一行 `".tad/provenance/"`）
- `.tad/tests/installer-data-safety-fixture.sh`
- `INSTALLATION_GUIDE.md`、`.tad/runtime-compat/claude-code.md`、`.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md`、`.tad/project-knowledge/patterns/runtime-adapter-checklist.md`（仅 R-CC-8）

除此之外的任何文件都不改。特别是：`.tad/templates/claude/settings.json`、`.claude/` 下任何东西、`bin/tad-install.mjs`、`.tad/scripts/tad-update.sh`、两份 `secret-detection-rules.md`、`docs/pm/status.md`、Epic 文件。

### 7.3 Grounded Against
`tad.sh` @ `5c3f0ab1`（Phase 3 未改它，内容同 `af97b99a`）；grounding 的行号取自 `af97b99a`。

---

## 8. Testing Requirements

### 8.3 Edge Cases（均已在 §4 定案）
自嵌套副本；`.DS_Store`；`local/`；`sync_policy: forked`；目录内符号链接；`.claude` 或 `.claude/workflows` 本身是符号链接；内容在台账里但路径不同；文件名含换行或控制字符；0 字节 `settings.json`；只差空白的 `settings.json`；无标记线的整文件旧 `CLAUDE.md`；标记线下有用户内容；标记线上被改过一行；行尾带回车的副本；`.claude` 只读导致中途失败；skill 目录里有只读子目录（提交阶段删不掉墓碑：只提示，不失败）；目标没有 `.tad/`；遗留墓碑；`--packs` 只选一部分；台账缺失或损坏；没有 SHA-1 工具（用 PATH 垫片模拟）。

§9.1-RAW 脚本没有覆盖的几项必须由 Blake 在 fixture 里各写一条用例，并在 completion 里列出用例名与结果：skill 目录内有只读子目录；skill 目录自身为 0555（改名失败应降为 `LEFT`）；无 SHA-1 工具；`sync_policy: forked`；移回时原位置已被占用（不得嵌套、不得穿过链接）；提交阶段墓碑内容与存档不同（墓碑应保留）。

## 8.4 Friction Preflight

| 摩擦点 | 涉及步骤 | 处理 | 允许的替代 | 对 Gate 的影响 |
|---|---|---|---|---|
| 沙箱里安装器需要 `TAD_BACKUP_ROOT` | 全部安装运行 | 每次运行都显式设置为沙箱内目录 | 无 | 未设置即运行视为违规，Gate 3 不过 |
| `spec-compliance-reviewer` 类型未注册 | Layer 2 Group 0 | 派通用子代理，任务文字用 `.tad/agents/claude/spec-compliance-reviewer.md` 正文 | `EQUIVALENT_SUBSTITUTE` | 缺这一步 Gate 3 不过 |
| 历史 tag 不全（浅克隆） | Step 1 | 先 `git tag -l 'v*' \| wc -l`，应为 78 | 无 | 少于 78 则停，报告 |

## 8.5 Feedback Collection
completion 里单列一节「本单哪条规定在实现时发现不成立或有歧义」。

---

## 9. Acceptance Criteria

- [ ] AC1 生成器重复运行输出逐字节相同；`release-verify.sh provenance .` 退出 0；目标项目里不存在 `.tad/provenance`。
- [ ] AC2 `claude_blob_id` 与 `git hash-object` 对 3 个以上文件（含一个 0 字节文件）一致。依据是 completion 里的对照输出；脚本用例 A3 间接覆盖（算错则全部判「不是」）。
- [ ] AC3 原样的 v2.44.6 旧安装：全部同名 skill 变为正确链接；`settings.json` 等于模板；`CLAUDE.md` 只含引用块；旧 workflow 副本清空；存档里的副本与升级前逐字节相同；不留墓碑。
- [ ] AC4 被改过的条目（skill 文件改一字节、目录多一个文件、`local/`、目录内符号链接、内容来自另一路径的已发文件、用户自建目录、带用户键的 `settings.json`、标记线上改过的 `CLAUDE.md`、改过的 workflow）升级后逐字节不变，各有一行 `CLAUDE-ADOPT-LEFT` 或既有的 `KEPT` 行，且不被复制进存档。
- [ ] AC5 标记线下的用户内容在升级后的 `CLAUDE.md` 里逐字节保留，位于引用块之前。
- [ ] AC6 再跑一次（带 `--force`）：不产生新存档；`.claude/` 与 `CLAUDE.md` 不变（脚本用例 A3 后半）。
- [ ] AC6b `.claude` 或 `.claude/workflows` 是符号链接时，链接指向的目录逐字节不变；目标没有 `.tad/` 时存档只出现在备份根之下或接管降级；存在遗留墓碑时接管降级（脚本用例 A6）。
- [ ] AC7 `--claude-adopt=plan`：退出 0，项目与备份根零改动。`--claude-adopt=off`：行为与 Phase 2 相同。
- [ ] AC8 中途失败：项目树回到安装前状态，不留墓碑。
- [ ] AC9 `--platform codex`：旧 `.claude/` 与 `CLAUDE.md` 逐字节不变；有 `CLAUDE-LEGACY-DETECTED`；台账里没有的 `.claude/commands/<弃用名>` 被保留并有 `CLAUDE-CMD-KEPT`；内容确为 TAD 所发的弃用文件照旧被清理（阳性对照）。
- [ ] AC10 台账损坏或缺失：安装成功，`CLAUDE-ADOPT-DEGRADED`，旧条目一个不动。
- [ ] AC11 `installer-destructive-guard` 退出 0；三件既有 fixture 的通过行不少于基线；`--verify-denylist` 通过。

## 9.1 Spec Compliance Checklist

验收依据是下面这段脚本，不是 Blake 自己的 fixture。在仓根运行 `bash <提取出的脚本> ALL`。提取命令：
```
awk '/^### §9.1-RAW/{f=1} f&&/^```bash$/{g=1;next} g&&/^```$/{exit} g' <本文件> > <你自己的私有临时路径>
```
不要写到共享的 `$TMPDIR/固定名`。脚本只在自己建的临时沙箱里安装，对仓库只读。末行 `== TOTAL FAILS: 0` 才算通过。脚本本身若有错，不要改实现去迁就它：把出错的检查原样报告给 Alex。

### §9.1-RAW — 可运行正本

```bash
# Phase 4a acceptance script. Run from the repo root: bash <this> ALL | <case...>
set -u
umask 022
REPO="$(pwd -P)"
[ -f "$REPO/tad.sh" ] && [ -d "$REPO/.tad" ] || { echo "run from repo root"; exit 2; }
for c in git rsync shasum tar awk python3 cmp diff; do command -v "$c" >/dev/null 2>&1 || { echo "missing tool: $c"; exit 2; }; done
[ "$(id -u)" != 0 ] || { echo "do not run as root"; exit 2; }
LEGACY_TAG=v2.44.6
TPL_REL=".tad/templates/claude/settings.json"
MARK='<!-- TAD:PROJECT-CONTENT-BELOW -->'
KEEP="${P4_KEEP:-0}"
ROOT="$(mktemp -d "${TMPDIR:-/tmp}/tad-p4ac.XXXXXX")"; ROOT="$(cd "$ROOT" && pwd -P)"
cleanup(){ [ "$KEEP" = 1 ] && { echo "(sandbox kept: $ROOT)"; return; }; case "$ROOT" in */tad-p4ac.*) chmod -R u+w "$ROOT" 2>/dev/null; rm -rf "$ROOT";; esac; }
trap cleanup EXIT
FAILS=0
ok(){ echo "  ok   $*"; }
bad(){ echo "  FAIL $*"; FAILS=$((FAILS+1)); }
chk(){ local l="$1"; shift; if "$@" >/dev/null 2>&1; then ok "$l"; else bad "$l"; fi; }
eq(){ if [ "$2" = "$3" ]; then ok "$1 = $3"; else bad "$1: got '$2' want '$3'"; fi; }
mode(){ stat -f '%Lp' "$1" 2>/dev/null || stat -c '%a' "$1" 2>/dev/null; }
BLOCK="$(printf '%s\n' '<!-- TAD:AGENTS-REF:BEGIN (managed by tad.sh) -->' '@AGENTS.md' '<!-- TAD:AGENTS-REF:END -->')"
NEWSRC="$ROOT/newsrc"
mk_src(){ [ -d "$NEWSRC" ] && return 0; mkdir "$NEWSRC"
  ( cd "$REPO" && git ls-files -co --exclude-standard -z -- . ':!.claude' | rsync -a -0 --files-from=- . "$NEWSRC/" ) || { echo "cannot build NEWSRC"; exit 2; }; }
# legacy <name>: a v2.44.6-style Claude install claiming version 3.1.0 (so the installer takes the plain upgrade path)
legacy(){ local sb="$ROOT/$1"; mkdir -p "$sb/t/.tad/active/handoffs" "$sb/bk"
  ( cd "$REPO" && git archive "$LEGACY_TAG" .claude/skills .claude/settings.json .claude/workflows CLAUDE.md | tar -x -C "$sb/t" ) || { echo "cannot build legacy fixture"; exit 2; }
  echo 3.1.0 > "$sb/t/.tad/version.txt"; ( cd "$sb/t" && git init -q . ); echo "$sb"; }
inst(){ local sb="$1" plat="$2"; shift 2; local n; n=$(ls "$sb" | grep -c '^log\.')
  ( cd "$sb/t" && TAD_BACKUP_ROOT="$sb/bk" bash "$NEWSRC/tad.sh" --source "$NEWSRC" --platform "$plat" --yes "$@" >"$sb/log.$n" 2>&1 ); local rc=$?
  LASTLOG="$sb/log.$n"; return $rc; }
sig(){ ( cd "$1" 2>/dev/null || exit 0; find "${2:-.}" -name .git -prune -o -print 2>/dev/null | LC_ALL=C sort | while IFS= read -r p; do
    if [ -L "$p" ]; then echo "L $p -> $(readlink "$p")"; elif [ -d "$p" ]; then echo "D $p $(mode "$p")"; else echo "F $p $(mode "$p") $(shasum -a 256 "$p" | cut -d' ' -f1)"; fi; done ); }
csig(){ ( sig "$1" .claude; [ -e "$1/CLAUDE.md" ] && sig "$1" CLAUDE.md ); }       # only the Claude surfaces
projected(){ ( cd "$1/.agents/skills" 2>/dev/null && for d in */; do d="${d%/}"; [ -f "$d/SKILL.md" ] && echo "$d"; done ); }
archives(){ find "$1/bk" -type d -path '*/claude-adopt/*' -mindepth 3 -maxdepth 3 2>/dev/null | wc -l | tr -d ' '; }
arch_tree(){ find "$1/bk" -type d -path '*/claude-adopt/*/tree' 2>/dev/null | head -1; }

A1(){ echo "== A1 ledger, generator, release gate"; mk_src
  local L="$REPO/.tad/provenance/claude-legacy.tsv"
  chk "ledger exists" test -f "$L"
  chk "manifest exists" test -f "$REPO/.tad/provenance/MANIFEST.sha1"
  eq "ledger header rows= equals data rows" "$(sed -n '1s/.*rows=\([0-9]*\).*/\1/p' "$L")" "$(grep -vc '^#' "$L" | tr -d ' ')"
  for k in skill flat settings settings-ws md-whole md-head workflow cmd; do
    [ "$(awk -F'\t' -v k="$k" '$1==k' "$L" | wc -l | tr -d ' ')" -ge 1 ] && ok "ledger has kind $k" || bad "ledger has no rows of kind $k"; done
  eq "current hook template blob is a settings row" "$(awk -F'\t' -v b="$(git hash-object "$REPO/$TPL_REL")" '$1=="settings"&&$2==b' "$L" | wc -l | tr -d ' ')" 1
  local b; b=$(git rev-parse "$LEGACY_TAG:.claude/skills/alex/SKILL.md")
  [ "$(awk -F'\t' -v b="$b" '$1=="skill"&&$2==b&&$3=="alex/SKILL.md"' "$L" | wc -l | tr -d ' ')" -ge 1 ] && ok "positive control: v2.44.6 alex/SKILL.md is a skill row" || bad "v2.44.6 alex/SKILL.md missing from ledger"
  eq "negative control: an unshipped blob id is absent" "$(grep -c "$(printf 'never shipped %s\n' "$ROOT" | git hash-object --stdin)" "$L" | tr -d ' ')" 0
  local g="$ROOT/gen"; mkdir "$g"
  ( cd "$REPO" && git ls-files -co --exclude-standard -z -- . ':!.claude' | rsync -a -0 --files-from=- . "$g/" && cp -R .git "$g/.git" ) >/dev/null 2>&1
  chk "copy for the generator run holds the generator and the ledger" test -f "$g/.tad/scripts/gen-claude-provenance.sh" -a -f "$g/.tad/provenance/claude-legacy.tsv"
  : > "$g/.tad/provenance/claude-legacy.tsv"                                         # the generator must rebuild it from history, not reuse it
  ( cd "$g" && bash .tad/scripts/gen-claude-provenance.sh >/dev/null 2>&1 ); chk "generator reproduces the ledger byte for byte from an emptied file" cmp -s "$g/.tad/provenance/claude-legacy.tsv" "$L"
  chk "generator reproduces MANIFEST.sha1" cmp -s "$g/.tad/provenance/MANIFEST.sha1" "$REPO/.tad/provenance/MANIFEST.sha1"
  eq "MANIFEST.sha1 is the blob id of the ledger" "$(tr -d ' \n' < "$REPO/.tad/provenance/MANIFEST.sha1")" "$(git hash-object "$L")"
  eq "ledger header carries a commit hash (would make it unreproducible)" "$(sed -n 1p "$L" | grep -c 'generated-from' | tr -d ' ')" 0
  ( cd "$REPO" && bash .tad/hooks/lib/release-verify.sh provenance . >"$ROOT/rv.log" 2>&1 ); eq "release-verify provenance rc" "$?" 0
  ( cd "$g" && bash .tad/hooks/lib/release-verify.sh provenance . >/dev/null 2>&1 ); eq "positive control: the release gate passes on the regenerated copy" "$?" 0
  printf 'x\n' >> "$g/.tad/provenance/claude-legacy.tsv"
  ( cd "$g" && bash .tad/hooks/lib/release-verify.sh provenance . >/dev/null 2>&1 ); [ "$?" -ne 0 ] && ok "release-verify provenance fails on a tampered ledger" || bad "tampered ledger passed the release gate"
  ( cd "$REPO" && bash tad.sh --verify-denylist >"$ROOT/dl.log" 2>&1 ); eq "--verify-denylist rc" "$?" 0
  chk "npm package whitelist ships the ledger" grep -q '"\.tad/provenance/"' "$REPO/package.json"; }

A3(){ echo "== A3 pristine legacy install is adopted"; mk_src
  local sb t n=0 links=0 real=0 s; sb=$(legacy a3); t="$sb/t"
  cp -R "$t/.claude" "$sb/before.claude"; cp "$t/CLAUDE.md" "$sb/before.CLAUDE.md"
  cp -R "$t/.claude/skills/gate" "$t/.claude/skills/gate/gate"                      # self-nested duplicate, as old cp -r made
  printf 'x' > "$t/.claude/skills/blake/.DS_Store"
  inst "$sb" claude-code; eq "installer rc" "$?" 0
  for s in $(projected "$t"); do n=$((n+1))
    if [ -L "$t/.claude/skills/$s" ] && [ "$(readlink "$t/.claude/skills/$s")" = "../../.agents/skills/$s" ]; then links=$((links+1)); elif [ -d "$t/.claude/skills/$s" ]; then real=$((real+1)); echo "    still a directory: $s"; fi; done
  [ "$n" -ge 60 ] && ok "projected skills: $n" || bad "too few projected skills: $n"
  eq "projected skills that are correct links" "$links" "$n"
  eq "legacy directories left among projected names" "$real" 0
  chk "settings.json equals the template" cmp -s "$t/.claude/settings.json" "$NEWSRC/$TPL_REL"
  eq "CLAUDE.md is exactly the managed block" "$(cat "$t/CLAUDE.md")" "$BLOCK"
  eq "legacy workflow copies left" "$(find "$t/.claude/workflows" -type f 2>/dev/null | wc -l | tr -d ' ')" 0
  eq "archives created" "$(archives "$sb")" 1
  local a; a=$(arch_tree "$sb")
  chk "archive is complete (manifest.txt)" test -f "$(dirname "$a")/manifest.txt"
  chk "archived alex equals the pre-run directory" diff -r "$a/.claude/skills/alex" "$sb/before.claude/skills/alex"
  chk "archived settings.json equals the pre-run file" cmp -s "$a/.claude/settings.json" "$sb/before.claude/settings.json"
  chk "archived CLAUDE.md equals the pre-run file" cmp -s "$a/CLAUDE.md" "$sb/before.CLAUDE.md"
  chk "archived gate keeps the nested duplicate" test -f "$a/.claude/skills/gate/gate/SKILL.md"
  chk "tokens CLAUDE-ADOPTED and CLAUDE-ADOPT-DONE" bash -c "grep -q '^CLAUDE-ADOPTED\|CLAUDE-ADOPTED ' '$LASTLOG' && grep -q 'CLAUDE-ADOPT-DONE' '$LASTLOG'"
  chk "summary states what replaced the old settings and which checks are no longer active" bash -c "grep -q 'previous file archived' '$LASTLOG' && grep -q 'pre-gate-check.sh' '$LASTLOG'"
  eq "tombstones left after a successful run" "$(find "$t/.claude" -name '.tad-adopt-tomb*' 2>/dev/null | wc -l | tr -d ' ')" 0
  chk "archive has the vacate journal done.tsv" test -s "$(dirname "$a")/done.tsv"
  eq ".tad/provenance shipped into the target" "$( [ -e "$t/.tad/provenance" ] && echo yes || echo no)" no
  csig "$t" > "$sb/s1"
  inst "$sb" claude-code --force; eq "second run rc" "$?" 0
  csig "$t" > "$sb/s2"
  chk "second run leaves .claude and CLAUDE.md identical" cmp -s "$sb/s1" "$sb/s2"
  eq "archives after the second run" "$(archives "$sb")" 1
  chk "second run really ran the projection (token CLAUDE-SKILLS-DONE)" grep -q 'CLAUDE-SKILLS-DONE' "$LASTLOG"; }

A4(){ echo "== A4 modified and user-owned entries are left byte-identical"; mk_src
  local sb t; sb=$(legacy a4); t="$sb/t"
  cp "$t/.claude/skills/alex/SKILL.md" "$t/.claude/skills/tad-status/SKILL.md"       # a shipped blob, but at another skill's path
  printf 'x' >> "$t/.claude/skills/alex/SKILL.md"                                   # one-byte edit
  echo mine > "$t/.claude/skills/blake/extra.txt"                                   # added file
  mkdir -p "$t/.claude/skills/my-own-skill" && echo '# mine' > "$t/.claude/skills/my-own-skill/SKILL.md"
  mkdir -p "$t/.claude/skills/gate/local" && echo keep > "$t/.claude/skills/gate/local/note.md"
  ln -s /etc/hosts "$t/.claude/skills/tad-init/link-inside"
  python3 - "$t/.claude/settings.json" <<'PY'
import json,sys
p=sys.argv[1]; d=json.load(open(p)); d["env"]={"MY":"1"}; json.dump(d,open(p,"w"),indent=2)
PY
  { sed '3s/$/ (edited)/' "$t/CLAUDE.md"; echo 'my own notes'; } > "$t/CLAUDE.md.new" && mv "$t/CLAUDE.md.new" "$t/CLAUDE.md"
  local wf; wf=$(ls "$t/.claude/workflows" | head -1); echo '// edited' >> "$t/.claude/workflows/$wf"
  for p in skills/alex skills/blake skills/my-own-skill skills/gate skills/tad-init skills/tad-status settings.json "workflows/$wf"; do sig "$t/.claude" "$p"; done > "$sb/s1"
  cp "$t/CLAUDE.md" "$sb/before.CLAUDE.md"
  inst "$sb" claude-code; eq "installer rc" "$?" 0
  for p in skills/alex skills/blake skills/my-own-skill skills/gate skills/tad-init skills/tad-status settings.json "workflows/$wf"; do sig "$t/.claude" "$p"; done > "$sb/s2"
  [ "$(wc -l < "$sb/s1" | tr -d ' ')" -ge 12 ] && ok "fixture listing is not empty" || bad "fixture listing is empty (case proves nothing)"
  chk "the eight modified or user-owned entries are byte-identical" cmp -s "$sb/s1" "$sb/s2"
  cmp -s "$sb/s1" "$sb/s2" || diff "$sb/s1" "$sb/s2" | head -8 | sed 's/^/    /'
  eq "CLAUDE.md with an edited head: original bytes kept as prefix" "$(head -c "$(wc -c < "$sb/before.CLAUDE.md" | tr -d ' ')" "$t/CLAUDE.md" | cmp -s - "$sb/before.CLAUDE.md" && echo yes || echo no)" yes
  chk "CLAUDE.md with an edited head still gets the managed block" grep -qx '@AGENTS.md' "$t/CLAUDE.md"
  for n in alex blake gate tad-init tad-status; do chk "CLAUDE-ADOPT-LEFT names skills/$n" grep -q "CLAUDE-ADOPT-LEFT .*skills/$n" "$LASTLOG"; done
  eq "my-own-skill is never named in an ADOPT line" "$(grep -c 'CLAUDE-ADOPT.*my-own-skill' "$LASTLOG" | tr -d ' ')" 0
  chk "settings with a user key kept (CLAUDE-HOOKS-KEPT)" grep -q 'CLAUDE-HOOKS-KEPT' "$LASTLOG"
  chk "positive control: an untouched skill in the same run was adopted" test -L "$t/.claude/skills/research-github"
  local a; a=$(arch_tree "$sb")
  chk "an archive exists for the entries that were adopted" test -d "$a/.claude/skills/research-github"
  eq "left entries copied into the archive tree" "$( { [ -e "$a/.claude/skills/alex" ] || [ -e "$a/.claude/skills/my-own-skill" ] || [ -e "$a/.claude/settings.json" ]; } && echo yes || echo no)" no; }

A5(){ echo "== A5 CLAUDE.md and settings variants"; mk_src
  local sb t; sb=$(legacy a5a); t="$sb/t"
  printf '\n## My project\nline A\nline B\n' >> "$t/CLAUDE.md"
  inst "$sb" claude-code; eq "(a) installer rc" "$?" 0
  eq "(a) user text below the marker is kept byte for byte, then one blank line and the block (Phase 2 append contract)" "$(cat "$t/CLAUDE.md")" "$(printf '\n## My project\nline A\nline B\n\n%s' "$BLOCK")"
  eq "(a) marker line left in CLAUDE.md" "$(grep -cF "$MARK" "$t/CLAUDE.md" | tr -d ' ')" 0
  sb=$(legacy a5b); t="$sb/t"
  ( cd "$REPO" && git show v2.30.0:CLAUDE.md ) > "$t/CLAUDE.md"                     # pre-marker whole-file version
  eq "(b) fixture really has no marker" "$(grep -cF "$MARK" "$t/CLAUDE.md" | tr -d ' ')" 0
  inst "$sb" claude-code; eq "(b) installer rc" "$?" 0
  eq "(b) pre-marker shipped CLAUDE.md becomes exactly the managed block" "$(cat "$t/CLAUDE.md")" "$BLOCK"
  sb=$(legacy a5c); t="$sb/t"
  python3 - "$t/.claude/settings.json" <<'PY'
import json,sys
p=sys.argv[1]; d=json.load(open(p)); open(p,"w").write(json.dumps(d,indent=4,ensure_ascii=False))
PY
  chk "(c) fixture settings differ in bytes from the shipped blob" bash -c "! cmp -s '$t/.claude/settings.json' <(cd '$REPO' && git show $LEGACY_TAG:.claude/settings.json)"
  inst "$sb" claude-code; eq "(c) installer rc" "$?" 0
  chk "(c) whitespace-only variant of shipped settings is replaced by the template" cmp -s "$t/.claude/settings.json" "$NEWSRC/$TPL_REL"
  sb=$(legacy a5d); t="$sb/t"; : > "$t/.claude/settings.json"
  inst "$sb" claude-code; eq "(d) installer rc" "$?" 0
  eq "(d) zero-byte settings.json left as is" "$(wc -c < "$t/.claude/settings.json" | tr -d ' ')" 0; }

A7(){ echo "== A7 plan and off modes"; mk_src
  local sb t; sb=$(legacy a7a); t="$sb/t"; sig "$t" . > "$sb/s1"
  inst "$sb" claude-code --claude-adopt=plan; eq "(plan) rc" "$?" 0
  sig "$t" . > "$sb/s2"; chk "(plan) project tree unchanged" cmp -s "$sb/s1" "$sb/s2"
  eq "(plan) entries under the backup root" "$(ls -A "$sb/bk" | wc -l | tr -d ' ')" 0
  chk "(plan) token CLAUDE-ADOPT-PLAN" grep -q 'CLAUDE-ADOPT-PLAN' "$LASTLOG"
  sb=$(legacy a7b); t="$sb/t"; csig "$t" > "$sb/s1"
  inst "$sb" claude-code --claude-adopt=off; eq "(off) rc" "$?" 0
  chk "(off) legacy alex is still a directory" test -d "$t/.claude/skills/alex" -a ! -L "$t/.claude/skills/alex"
  chk "(off) settings.json unchanged" cmp -s "$t/.claude/settings.json" <(cd "$REPO" && git show "$LEGACY_TAG:.claude/settings.json")
  eq "(off) archives" "$(archives "$sb")" 0
  sb=$(legacy a7c)
  inst "$sb" claude-code --claude-adopt=bogus; [ "$?" -ne 0 ] && ok "(bogus) invalid mode rejected" || bad "(bogus) invalid mode accepted"
  eq "(bogus) nothing installed" "$( [ -e "$sb/t/.agents" ] && echo yes || echo no)" no; }

A8(){ echo "== A8 failure after adoption rolls everything back"; mk_src
  local sb t rc; sb=$(legacy a8); t="$sb/t"
  chmod 555 "$t/.claude"                                                            # skills/ stays writable; settings.json cannot be removed
  sig "$t" . > "$sb/s1"
  inst "$sb" claude-code; rc=$?
  [ "$rc" -ne 0 ] && ok "installer failed as expected (rc=$rc)" || bad "installer succeeded although .claude is read-only"
  chk "skills had been adopted before the failure (token CLAUDE-ADOPTED)" grep -q 'CLAUDE-ADOPTED .*skills/' "$LASTLOG"
  chk "failure is reported (token CLAUDE-ADOPT-FAILED)" grep -q 'CLAUDE-ADOPT-FAILED' "$LASTLOG"
  sig "$t" . > "$sb/s2"
  chk "target tree identical to the pre-install state" cmp -s "$sb/s1" "$sb/s2"
  cmp -s "$sb/s1" "$sb/s2" || diff "$sb/s1" "$sb/s2" | head -8 | sed 's/^/    /'
  eq "tombstones left after rollback" "$(find "$t/.claude" -name '.tad-adopt-tomb*' 2>/dev/null | wc -l | tr -d ' ')" 0
  chmod 755 "$t/.claude"; }

A6(){ echo "== A6 symlinked surfaces, missing .tad, leftover tombstone"; mk_src
  local sb t; sb=$(legacy a6a); t="$sb/t"
  mv "$t/.claude" "$sb/outside" && ln -s ../outside "$t/.claude"
  sig "$sb/outside" . > "$sb/s1"
  inst "$sb" claude-code; eq "(a) .claude is a symlink: installer rc" "$?" 0
  sig "$sb/outside" . > "$sb/s2"; chk "(a) directory behind the symlinked .claude is byte-identical" cmp -s "$sb/s1" "$sb/s2"
  eq "(a) archives" "$(archives "$sb")" 0
  chk "(a) token CLAUDE-ADOPT-DEGRADED" grep -q 'CLAUDE-ADOPT-DEGRADED' "$LASTLOG"
  eq "(a) marker line still in CLAUDE.md (no surface is adopted behind a symlinked .claude)" "$(grep -cF "$MARK" "$t/CLAUDE.md" | tr -d ' ')" 1
  sb=$(legacy a6b); t="$sb/t"
  mv "$t/.claude/workflows" "$sb/shared-wf" && ln -s ../../shared-wf "$t/.claude/workflows"
  sig "$sb/shared-wf" . > "$sb/s1"
  inst "$sb" claude-code; eq "(b) .claude/workflows is a symlink: installer rc" "$?" 0
  sig "$sb/shared-wf" . > "$sb/s2"; chk "(b) directory behind the symlinked workflows is byte-identical" cmp -s "$sb/s1" "$sb/s2"
  chk "(b) positive control: skills in the same run were adopted" test -L "$t/.claude/skills/alex"
  sb=$(legacy a6c); t="$sb/t"; rm -rf "$t/.tad"
  inst "$sb" claude-code; eq "(c) no .tad directory: installer rc" "$?" 0
  if [ -L "$t/.claude/skills/alex" ]; then eq "(c) adopted, so exactly one archive under the backup root" "$(archives "$sb")" 1
  else chk "(c) not adopted, so the run says why (token CLAUDE-ADOPT-DEGRADED)" grep -q 'CLAUDE-ADOPT-DEGRADED' "$LASTLOG"; chk "(c) legacy alex untouched" test -d "$t/.claude/skills/alex"; fi
  eq "(c) log mentions an archive path outside the backup root" "$(grep 'CLAUDE-ADOPT-ARCHIVE' "$LASTLOG" | grep -vc "$sb/bk/" | tr -d ' ')" 0
  sb=$(legacy a6d); t="$sb/t"; mkdir -p "$t/.claude/skills/.tad-adopt-tomb.999/alex"; echo old > "$t/.claude/skills/.tad-adopt-tomb.999/alex/SKILL.md"
  csig "$t" > "$sb/s1"
  inst "$sb" claude-code; eq "(d) leftover tombstone: installer rc" "$?" 0
  chk "(d) token CLAUDE-ADOPT-DEGRADED" grep -q 'CLAUDE-ADOPT-DEGRADED' "$LASTLOG"
  chk "(d) legacy alex is still a directory" test -d "$t/.claude/skills/alex" -a ! -L "$t/.claude/skills/alex"
  chk "(d) the leftover tombstone is untouched" test -f "$t/.claude/skills/.tad-adopt-tomb.999/alex/SKILL.md"
  eq "(d) archives" "$(archives "$sb")" 0; }

A12(){ echo "== A12 odd file names and pack subsets are never adopted"; mk_src
  local sb t; sb=$(legacy a12a); t="$sb/t"
  printf 'x\n' > "$t/.claude/skills/tad-help/$(printf 'odd\nname.md')"                # a file name containing a newline
  [ "$(ls "$t/.claude/skills/tad-help" | wc -l | tr -d ' ')" -ge 3 ] && ok "(a) fixture has the odd file name" || bad "(a) could not create the odd file name"
  ( cd "$t/.claude/skills" && tar -cf - tad-help | shasum ) > "$sb/s1"            # tar, because the line-based sig helper cannot carry a newline in a name
  inst "$sb" claude-code; eq "(a) installer rc" "$?" 0
  ( cd "$t/.claude/skills" && tar -cf - tad-help | shasum ) > "$sb/s2"
  chk "(a) skill is still a real directory" test -d "$t/.claude/skills/tad-help" -a ! -L "$t/.claude/skills/tad-help"
  chk "(a) skill holding a control-character file name is byte-identical" cmp -s "$sb/s1" "$sb/s2"
  chk "(a) it is reported as left" grep -q 'CLAUDE-ADOPT-LEFT .*skills/tad-help' "$LASTLOG"
  eq "(a) log lines forged by the file name (a line that is exactly 'name.md')" "$(grep -cx 'name.md.*' "$LASTLOG" | tr -d ' ')" 0
  chk "(a) positive control: another skill in the same run was adopted" test -L "$t/.claude/skills/alex"
  sb=$(legacy a12b); t="$sb/t"
  sig "$t/.claude" skills/web-backend > "$sb/s1"
  inst "$sb" claude-code --packs agent-memory; eq "(b) installer rc with --packs agent-memory" "$?" 0
  if [ -e "$t/.agents/skills/web-backend/SKILL.md" ]; then ok "(b) SKIP-NOT-APPLICABLE: --packs did not leave web-backend out of the target, case cannot discriminate"
  else sig "$t/.claude" skills/web-backend > "$sb/s2"
    chk "(b) pristine copy of a pack the source still ships but this install did not select is byte-identical" cmp -s "$sb/s1" "$sb/s2"
    chk "(b) it is reported as left" grep -q 'CLAUDE-ADOPT-LEFT .*skills/web-backend' "$LASTLOG"; fi
  chk "(b) positive control: a selected or non-pack skill was adopted" test -L "$t/.claude/skills/alex"; }

A9(){ echo "== A9 other platforms leave the legacy install alone"; mk_src
  local sb t; sb=$(legacy a9); t="$sb/t"
  mkdir -p "$t/.claude/commands"
  local dep; dep=$(grep -oE '\.claude/commands/[A-Za-z0-9._-]+\.md' "$REPO/.tad/deprecation.yaml" | head -1)
  [ -n "$dep" ] && ok "deprecation list names a .claude/commands file: $dep" || bad "no .claude/commands entry found in deprecation.yaml (case cannot run)"
  echo 'my own command with this name' > "$t/$dep"
  csig "$t" > "$sb/s1"
  local dep2="" tg="" d g                                                            # a second deprecated name whose shipped content exists at some tag
  for d in $(grep -oE '\.claude/commands/[A-Za-z0-9._-]+\.md' "$REPO/.tad/deprecation.yaml" | sort -u); do [ "$d" = "$dep" ] && continue
    for g in $(cd "$REPO" && git tag -l 'v*'); do if ( cd "$REPO" && git cat-file -e "$g:$d" 2>/dev/null ); then dep2="$d"; tg="$g"; break 2; fi; done; done
  [ -n "$dep2" ] && ok "found shipped content for a deprecated command: $dep2 at $tg" || bad "no shipped deprecated command found (positive control cannot run)"
  [ -n "$dep2" ] && ( cd "$REPO" && git show "$tg:$dep2" ) > "$t/$dep2"
  inst "$sb" codex; eq "installer rc" "$?" 0
  [ -n "$dep2" ] && { [ ! -e "$t/$dep2" ] && ok "positive control: the shipped deprecated command file was still cleaned up" || bad "shipped deprecated command file was kept (the tightening went too far)"; }
  csig "$t" > "$sb/s2"
  chk ".claude and CLAUDE.md byte-identical after a codex upgrade (including the user's command file)" cmp -s "$sb/s1" "$sb/s2"
  cmp -s "$sb/s1" "$sb/s2" || diff "$sb/s1" "$sb/s2" | head -8 | sed 's/^/    /'
  chk "token CLAUDE-LEGACY-DETECTED" grep -q 'CLAUDE-LEGACY-DETECTED' "$LASTLOG"
  chk "token CLAUDE-CMD-KEPT for the user's file" grep -q "CLAUDE-CMD-KEPT $dep" "$LASTLOG"
  eq "archives" "$(archives "$sb")" 0
  eq "CLAUDE-ADOPTED lines on codex" "$(grep -c 'CLAUDE-ADOPTED' "$LASTLOG" | tr -d ' ')" 0; }

A10(){ echo "== A10 unusable ledger degrades to report-only"; mk_src
  local src2="$ROOT/src-noledger" sb t; rsync -a "$NEWSRC/" "$src2/"; rm -f "$src2/.tad/provenance/claude-legacy.tsv"
  sb=$(legacy a10a); t="$sb/t"; csig "$t" > "$sb/s1"
  ( cd "$t" && TAD_BACKUP_ROOT="$sb/bk" bash "$src2/tad.sh" --source "$src2" --platform claude-code --yes >"$sb/log.0" 2>&1 ); eq "(missing) rc" "$?" 0
  chk "(missing) token CLAUDE-ADOPT-DEGRADED" grep -q 'CLAUDE-ADOPT-DEGRADED' "$sb/log.0"
  csig "$t" > "$sb/s2x"; eq "(missing) legacy skill directories still real directories" "$(find "$t/.claude/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" "$(grep -c '^D \.claude/skills/[^/ ]* ' "$sb/s1" | tr -d ' ')"
  chk "(missing) legacy alex is still a directory" test -d "$t/.claude/skills/alex" -a ! -L "$t/.claude/skills/alex"
  chk "(missing) settings.json unchanged" cmp -s "$t/.claude/settings.json" <(cd "$REPO" && git show "$LEGACY_TAG:.claude/settings.json")
  local src3="$ROOT/src-badledger"; rsync -a "$NEWSRC/" "$src3/"; printf 'skill\tdeadbeef\tx/y\n' >> "$src3/.tad/provenance/claude-legacy.tsv"
  sb=$(legacy a10b); t="$sb/t"
  ( cd "$t" && TAD_BACKUP_ROOT="$sb/bk" bash "$src3/tad.sh" --source "$src3" --platform claude-code --yes >"$sb/log.0" 2>&1 ); eq "(tampered) rc" "$?" 0
  chk "(tampered) token CLAUDE-ADOPT-DEGRADED" grep -q 'CLAUDE-ADOPT-DEGRADED' "$sb/log.0"
  chk "(tampered) legacy alex is still a directory" test -d "$t/.claude/skills/alex" -a ! -L "$t/.claude/skills/alex"; }

A11(){ echo "== A11 guards and static checks"
  ( cd "$REPO" && bash .tad/hooks/lib/release-verify.sh installer-destructive-guard . >"$ROOT/dg.log" 2>&1 ); eq "installer-destructive-guard rc" "$?" 0
  [ "$(grep -c 'RM-OK:claude-adopt' "$REPO/tad.sh" | tr -d ' ')" -ge 3 ] && ok "adoption delete sites carry RM-OK:claude-adopt markers" || bad "fewer than 3 RM-OK:claude-adopt markers"
  eq "duplicate RM-OK ids in tad.sh" "$(grep -o 'RM-OK:[A-Za-z0-9_-]*' "$REPO/tad.sh" | sort | uniq -d | wc -l | tr -d ' ')" 0
  eq "settings.local.json mentioned in adoption code paths as a read or write target" "$(grep -n 'settings\.local\.json' "$REPO/tad.sh" | grep -vc '^[0-9]*:[[:space:]]*#' | tr -d ' ')" 0
  chk "bash -n tad.sh" bash -n "$REPO/tad.sh"
  chk "bash -n generator" bash -n "$REPO/.tad/scripts/gen-claude-provenance.sh"
  eq "hook template changed by this task" "$(cd "$REPO" && git diff --name-only 5c3f0ab1 -- "$TPL_REL" | wc -l | tr -d ' ')" 0
  eq "files under .claude/ tracked by git" "$(cd "$REPO" && git ls-files .claude | wc -l | tr -d ' ')" 0; }

ALLCASES="A1 A3 A4 A5 A6 A7 A8 A9 A10 A11 A12"
[ $# -ge 1 ] || { echo "usage: $0 ALL | <case...>   cases: $ALLCASES"; exit 2; }
[ "$1" = ALL ] && set -- $ALLCASES
for c in "$@"; do case " $ALLCASES " in *" $c "*) "$c";; *) echo "unknown case $c"; exit 2;; esac; done
echo "== TOTAL FAILS: $FAILS"
[ "$FAILS" -eq 0 ]
```

## 9.2 Expert Review Status

### Audit Trail

第 1 轮（2026-10-09）：code-reviewer CONDITIONAL PASS（4 P0／6 P1／9 P2），security-auditor CONDITIONAL PASS（2 P0／5 P1／11 P2）。报告 `phase4a-design-review-cr.md`、`phase4a-design-review-sec.md`。

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| cr P0-1 / sec P0-1 | 目标没有 `.tad/` 时备份根变量为空，存档路径落到文件系统根 | §4.2「备份根」；脚本 A6(c) | Resolved |
| cr P0-2 / sec P1-1 | 直接删除会留下删到一半的目录；校验与删除之间有空窗；并发共用存档；内存清单可能丢 | §4.7（`mkdir` 不带 `-p`、`done.tsv`）、§4.8（改名到墓碑、再比对、提交阶段才删）；决策 3 | Resolved |
| cr P0-3 / sec 附注 | 脚本期望引用块前没有空行，与 Phase 2 契约矛盾；0 字节文件需要特例 | §4.5 末段；脚本 A5(a) | Resolved |
| cr P0-4 | 台账头含提交哈希无法复现；A1 的副本不含未提交文件，篡改检查恒真 | §4.1 台账格式与输入范围；脚本 A1（清空后重建、阳性对照） | Resolved |
| sec P0-2 | `assert_under_root` 只比字符串；符号链接的 `.claude` 或 `.claude/workflows` 会被写穿 | §4.0 第 4 条路径守卫；脚本 A6(a)(b) | Resolved |
| cr P1-1 | `package.json` 白名单不含台账；包装入口传不了新参数 | §4.1、§4.2、§7.2 | Resolved（包装入口用环境变量，写进文档） |
| cr P1-2 | 存档 `cp -R` 不带 `-p` | §4.7 | Resolved |
| cr P1-3 | `rmdir` 失败与 workflows 目录还原未定 | §4.6、§4.8（回滚是移回墓碑，不重建目录） | Resolved |
| cr P1-4 | `md-head`、`settings-ws` 定义不够逐字节 | §4.1 给出唯一命令 | Resolved |
| cr P1-5 / sec Q7 | 脚本缺反例与阳性对照；AC2 无检查 | 脚本 A4（路径错配、空清单守卫）、A6、A9（阳性对照）；§8.3 列出须由 Blake 补的 5 条 fixture；AC2 改为以 completion 输出为据 | Resolved（5 条未进脚本，已明示） |
| cr P1-6 | 「旧首行不在」的自检会误回滚 | §4.8 自检改为查 `@AGENTS.md` 行 | Resolved |
| sec P1-2 | 默认 `apply`，但确认提示不提会腾位 | §4.2 `claude_adopt_notice` | Resolved |
| sec P1-3 | `RETIRED` 会删掉源里仍有但本次没选的 skill | §4.3 判定表；决策 8 | Resolved |
| sec P1-4 | 文件名逐行处理，可被换行或控制字符破坏 | §4.0 第 5、6 条 | Resolved |
| sec P1-5 | 固定汇总句对没有阻断 hook 的旧版不真实，也没说去掉了什么 | §4.4 固定两行 | Resolved |
| sec Q5 | 存档是否会带出用户凭据 | §4.7「只存档将被腾位的条目」；脚本 A4 末行；决策 9 | Resolved |
| P2 共 20 条 | 见两份报告 | 未逐条处理；实施审查时复核 | Deferred |

第 2 轮（2026-10-09，末轮）：code-reviewer CONDITIONAL PASS（0 P0／4 P1／6 P2），security-auditor CONDITIONAL PASS（0 P0／2 P1／8 P2）。两位都写明没有阻塞实施的 P0。报告 `phase4a-design-review-r2-cr.md`、`phase4a-design-review-r2-sec.md`。

| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| cr N-P1-1 / sec P2-1 | 告知行在源下载之前打印，拿不到框架 skill 名；措辞过头 | §4.2 `claude_adopt_notice` | Resolved（已知残余：只有旧 settings 或旧 `CLAUDE.md`、没有 skill 目录的项目不会看到告知行） |
| cr N-P1-2 / sec P1-1 | 提交步骤相对 `NEED_ROLLBACK=0` 的位置未定；删墓碑前没有再比对 | §4.2 调用顺序、§4.8「提交」 | Resolved |
| cr N-P1-3 | workflows 的 `rmdir` 在墓碑还在时不可能成功 | §4.6 | Resolved |
| cr N-P1-4 | 符号链接的 `.claude` 下 `CLAUDE.md` 仍会被接管，A6(a) 会误判 | §4.2；脚本 A6(a) | Resolved |
| sec P1-2 | 移回用裸 `mv`，原位置被占时会嵌套或穿过链接 | §4.8「移回规则」 | Resolved |
| sec P2-2/3/4/5 | 0555 条目改名失败；墓碑创建方式；遗留墓碑查找范围；`done.tsv` 没有已撤回状态 | §4.8 | Resolved |
| sec P2-7 | 用户可见文字漏了几项后果 | §4.9 报告末尾五段 | Resolved |
| sec Q4 | 控制字符文件名、`--packs` 子集应进 Alex 的脚本 | 脚本 A12 | Resolved |
| 其余 P2 | 见两份报告 | 实施审查时复核 | Deferred |

### Experts Selected
code-reviewer（必选）、security-auditor（命中：对用户项目目录做删除与改写）。

---

## 10. Important Notes

### 10.1 Critical Warnings
- **绝不对本仓库或任何真实项目运行安装器。** 只在自己建的临时沙箱里跑，每次都设 `TAD_BACKUP_ROOT`。
- 不创建、不修改本仓 `.claude/` 下任何东西；不查看 `~/.claude/` 下任何文件；不打印 `CLAUDE*`、`ANTHROPIC*` 环境变量的值。
- 不在自己的临时目录之外做递归删除。
- 不提交。提交由 Conductor 做。
- 同步盘下其他项目一律不碰、不读。台账只从本仓 git 历史生成。

### 10.2 Known Constraints / 明确延后
- 不做 hook 级合并；带任何用户改动的 `settings.json` 整文件保留。
- 不做 `--force` 式强制接管，也不做还原命令与墓碑自动恢复；手工步骤写在报告里。
- 接管默认开启（`apply`），不因交互与否而变；提示之前有固定两行告知（§4.2）。
- 行尾带回车的副本按「不是」处理。
- 同版本闸不变：3.3.0 上想补做接管仍需 `--force`。

### 10.3 Sub-Agent 使用建议
实现本身一人顺序做。Layer 2 审查按 Blake 协议派出；`spec-compliance-reviewer` 未注册时按 §8.4 替代。

---

## 11. Decision Summary

| # | 决策 | 备选 | 选择 | 理由 |
|---|---|---|---|---|
| 1 | 所有权依据 | 按名字／按内容 | 按内容（git blob id＋路径） | 旧安装器没留标记，名字相同不等于内容没改 |
| 2 | `settings.json` | hook 级合并／整文件判定 | 整文件判定 | 51 个项目里 0 个有用户 hook；合并需要 JSON 引擎依赖 |
| 3 | 腾位方式 | 存档后直接删除／存档后改名到同目录墓碑、自检通过再删 | 改名到墓碑 | 第 1 轮两位审查者都指出直接删除会留下删到一半的目录，且校验与删除之间有空窗；改名是原子的，回滚是把原件移回 |
| 8 | `RETIRED` 的条件 | 不在投影集合／不在源里 | 不在源里 | `--packs` 只选一部分时，源里仍有的 skill 不该被当成已退役删掉 |
| 9 | 存档范围 | 全部旧条目／只存将被腾位的 | 只存将被腾位的 | 留下的条目可能含用户凭据，不该被复制到项目外 |
| 4 | 旧阻断型 hook | 保留／随模板去掉 | 去掉 | Epic 既定口径；旧 `permissions.deny` 为空，提示型 hook 规则全为放行 |
| 5 | 触发条件 | 任何平台自动／仅显式 claude-code | 仅显式 | 其余平台必须对 `.claude/` 零触碰 |
| 6 | 台账分发 | 随框架分发／只在源里 | 只在源里 | 目标项目用不到，约 110 KB |
| 7 | 已退役 skill 的可证明副本 | 留下／存档后删除 | 存档后删除 | 内容是 TAD 发的且已退役，留着会被 Claude Code 当成可用 skill |

## 12. Sub-Agent使用记录
（Blake 填写）

## Required Evidence Manifest
- `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4a-completion.md`：含 Step 0 基线、blob id 对照、§9.1-RAW 脚本 `ALL` 的完整原始输出、三件既有 fixture 的前后对比、`installer-destructive-guard` 输出、§8.5 反馈。
