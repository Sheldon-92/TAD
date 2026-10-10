# HANDOFF: 发版前的证据落账与发版门加固（Epic Phase 6a）

- Epic：`.tad/active/epics/EPIC-20261008-multi-harness-restore-and-cleanup.md`，Phase 6 第一部分（同时关闭 Phase 4b 的文档步骤）
- 日期：2026-10-09。作者：Alex（Conductor）。修订：2（按设计审查 `phase6a-design-review.md` 的 1 个 P0、9 个 P1 修订）
- 事实依据（都在 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/`）：`phase6-grounding.md`（下称「调研」）、`phase4b-gate-report.md`、`phase4b/results.md`、`phase4b/codex-d-retest.md`、`phase4b-evidence-audit.md`、`.tad/evidence/live-regression/*-20261009.md`（step3f 固定任务回归）
- 基线提交：派发时的 HEAD（由 Conductor 在派发消息里给出，下称 `<BASE>`）
- **本 handoff 不提升版本号。** 版本提升、迁移清单、CHANGELOG 在下一张 handoff（6b）。

## 1. 目的

两件事，文件集不相交，可由两个实现者并行：

- **工作包 D**：把 2026-10-09 在本机测到的事实写进四份 runtime 台账和三份对外文档，让每一句支持声明都能对上一条证据；没测到的照实写没测到。
- **工作包 E**：发版门现在有三处是空的或坏的（台账检查只抽查 2 个文件；`provenance`、`installer-destructive-guard`、`freshness` 不在发版规程里；`release-gates` 夹具调用一个已删除的模式）。修好它们，使下一步的发版提交能被真实地检查。

### 1.1 已裁定、不要重新讨论的事

| 事项 | 裁定 |
|---|---|
| 「一等」「一流」「first-class」「first class」「hook-enabled」「四家均已验证」「verified on all four」「fully supported」 | 禁用 |
| 证据的归属 | 2026-10-09 的结果只代表本机这几个 CLI 版本（claude 2.1.295、codex-cli 0.159.3、cursor-agent 2026.09.26、opencode 1.18.32）。2026-10-06 的结果来自另一台机器和别的版本。两者分开写，不合并成一句 |
| Codex `context_compaction` 台账行 | 改为 `accepted_limitation`：TAD 没有给 Codex 接 PreCompact；CLI 的帮助和 feature 列表只显示压缩相关的功能开关，没有 hook 事件清单；平台是否投递该事件未测。这是 2026-10-09 在 0.159.3 上实际复核的结论，可以更新 `last_verified`。**不得写成 verified** |
| 交互式 Claude Code 会话 | 未测，须人确认。所有文档保持「仅非交互运行」的限定 |
| Codex hook 的证据强度 | 写后留痕和会话启动摘要都只在**绕过 hook 信任审查**（`--dangerously-bypass-hook-trust`）的一次性沙箱里观察到；用户真正走完 Codex 的信任审查这条路径**没有测过**。不带信任时的数据点只有一次运行（会话启动摘要没有到达模型）。文档和台账只能这样写，不得写成「完成信任审查后即可工作」 |
| Claude Code「已有 `settings.json` 时不注册 hook」 | 只测了已有文件与模板**不同**的情况；与模板完全相同的情况未测。照此写 |
| step3f 固定任务回归（2026-10-09，本机） | 四家任务链均完成：Claude Code 2.1.295 PASS；Cursor 2026.09.26 PASS；OpenCode 1.18.32 PASS；Codex 0.159.3 任务链 PASS，但默认信任下写后留痕没有出现，绕过信任的第二次运行里出现。「链」是单个代理执行固定任务并自审，不含 Alex→Blake 派发，与 2026-10-06 的形态相同 |
| step3f 中 claude-code 的等级 | 首个基线为 2026-10-09，自本次发版起与另外三家同为 HARD |
| 版本号 | TAD 版本仍为 3.2.0；不新增带 TAD 版本号的句子。CLI 版本必须写，但写法有约束，见 D4 |
| `tad.sh` | 本 handoff 不改 |
| 推送、打标签 | 不做。仓库的发版规程要求人确认 |

### 1.2 不可触碰

`tad.sh`、`.tad/provenance/**`（E 不重新生成台账）、`.tad/templates/**`、`bin/**`、`.tad/tests/installer-data-safety-fixture.sh`、人的三个未提交文件（两份 `secret-detection-rules.md`、`docs/pm/status.md`：不打开、不暂存、不还原）、仓库自己的 `.claude/` 目录。不 `git add`、不提交、不推送、不切分支。

## 2. 工作包 D：证据落账

文件：`.tad/runtime-compat/codex.md`、`claude-code.md`、`cursor.md`、`opencode.md`；`docs/MULTI-PLATFORM.md`；`AGENTS.md`（只改 Known Gaps 的 P2、P4 两条和与之直接矛盾的句子）；`README.md`（只改 D7 点名的两处）；`.tad/codex/README.md`；`docs/CODEX-USER-GUIDE.md`（只加一句）；`.agents/skills/alex/references/publish-protocol.md`（只改 step3f 一段）。

`publish-protocol.md` 同时被工作包 E 在另一处（step3d 之后）编辑：两边都只做就地替换，不重写、不重排整个文件。

动手前读完 `phase4b-gate-report.md` 第一至第五节：那里是 Conductor 裁定后的口径，下面各条以它为准。每份台账先读它的表头和列定义，按现有列格式写，不发明新列。`release-verify.sh freshness .` 的解析器按 `|` 切分单元格：单元格里不得出现 `|`、`||`、`\|`；因此不要引用会话启动摘要的原文（它含 `|`），改述即可。列序：第 6 列 runtime_version、第 7 列 last_verified、第 8 列 volatility、第 9 列 next_review、第 12 列 status。`next_review` 的周期：high +30 天、medium +60 天、low +180 天。

**D1. Codex 台账（`.tad/runtime-compat/codex.md`）**
- 表头：`Last Updated` 2026-10-09；`Source` 补入 codex-cli 0.159.3 与证据目录 `phase4b/`，保留对 2026-10-06 复核的说明，删掉「context_compaction 与 trace_evidence_capture 卡在供应商额度、Oct 10 重试」那句（这两行今天已复核）。
- `context_compaction`：status `accepted_limitation`；runtime_version `codex-cli 0.159.3`；last_verified 2026-10-09；next_review 2026-11-08；source 含 `phase4b/codex-h.md`；current_behavior 写明「帮助和 feature 列表只显示压缩相关的功能开关，没有 hook 事件清单；TAD 没有给 Codex 接 PreCompact；平台是否投递该事件未测」；`fallback_behavior` 与 `regression_required: yes` 保持不动。
- `trace_evidence_capture`：status `verified_partial`；last_verified 2026-10-09；runtime_version `codex-cli 0.159.3`；next_review 2026-12-08。内容：2026-10-09 `codex exec --json` 六次会话的输出均可解析（`phase4b/codex-g.md`）；`apply_patch` 修复后的 hook 留痕在两次运行里观察到（单文件补丁一行、双文件补丁两行、非 TAD 路径无行；`phase4b/codex-d-retest.md`），条件是一次性沙箱、绕过 hook 信任审查、提交前的工作区版本。必须写明：旁路开关不等于交互式信任审查；走完真实信任审查的路径没有测；默认信任下 PostToolUse 的行为未测。
- `hooks`：保留现有 2026-10-06／0.149.0 的文字，追加实测，每句自带日期和版本：不带信任时会话启动摘要没有到达模型（一次运行，`phase4b/codex-c-default.md`）；绕过信任审查后到达（一次运行，`phase4b/codex-c-trusted.md`）；写后 hook 在修复前不留痕，原因是 `apply_patch` 信封没有路径字段（`phase4b-codex-postwrite-diagnosis.md`），修复后在绕过信任的沙箱里留痕。status 改为 `verified_partial`；last_verified 2026-10-09；runtime_version 写 `codex-cli 0.149.0; 0.159.3 (2026-10-09 live)`；next_review 2026-11-08。
- `skill_loading`、`agents_guidance_AGENTS_md`：同样保留原文并追加一句实测（`phase4b/codex-b.md`、`codex-a.md`）；last_verified 2026-10-09；runtime_version 同上写法；next_review 分别按该行的波动等级计算。`skill_loading` 写清证据强度：回答含只存在于 skill 文件的原文且事件流里没有任何命令执行；空目录对照里模型要靠可见的命令去别处找；只有一次运行。
- 其余行不动。

**D2. Claude Code 台账**
- 补入 2026-10-09 的实测：`AGENTS.md` 自动加载（禁用工具下返回口令）、会话启动 hook（事件流有 hook 响应）、写后留痕（有对照）、子代理定义可见、已有且与模板不同的 `settings.json` 时不注册 hook（与模板相同的情况未测）。
- `context_compaction` 一行：2026-10-09 手动 `/compact` 触发了 PreCompact 并写出快照（快照里 `Trigger: manual`）；CLI 当时回复「Not enough messages to compact」，没有内容被压缩；事件流里没有该 hook 的响应；「运行前快照目录不存在」是执行者的陈述；自然压缩未测。
- 行内不得出现 `RETIRED`、`DEPRECATED` 这两个词（`runtime-freshness-verify.sh` 见到其中任何一个就整份跳过该台账）。改完后跑 `release-verify.sh freshness .`，确认输出的条目总数没有减少。
- 交互面、子目录启动会话：保持未测／平台限制的现有写法。

**D3. Cursor、OpenCode 台账**
- 各补一句：2026-10-09 在本机旧一些的版本上复现了哪些（Cursor：`AGENTS.md`、会话启动、写后留痕、skill 调用一次；OpenCode：`AGENTS.md`、写后留痕）。不改各行原有的 2026-10-06 `last_verified`，除非该行的结论本身今天被实测覆盖且你把版本和日期一起如实更新。
- OpenCode 的 skill 一行：2026-10-09 观察到的是模型自己读了 `AGENTS.md` 指给它的 `SKILL.md`，不是 harness 的 skill 加载。如实写。该行现有的「first-class discovery path」改为「native discovery path」（禁用词）。
- Cursor 的 skill 一行：一次运行；空目录对照里模型要靠可见的搜索和读取去别处找。

**D4. `docs/MULTI-PLATFORM.md`**
- 状态表「Verification status」一列按上面的事实重写四行，各组证据分开写并带 CLI 版本：
  - Claude Code：2026-10-08 的台账探测（claude 2.1.295；机器未记录，不要称其为远程或本机）与 2026-10-09 本机；没有 2026-10-06 这一组。
  - Codex：2026-10-06 基于文档和帮助输出的复核（codex-cli 0.149.0）与当天的真机运行失败（供应商额度），两件事分开写；2026-10-09 本机（0.159.3）。
  - Cursor：2026-10-06 远程（2026.10.01-e373342）；2026-10-09 本机（2026.09.26，版本更旧）。
  - OpenCode：2026-10-06 远程（1.18.33）；2026-10-09 本机（1.18.32，版本更旧）。
- Codex 一行必须含：hook 配置在完成 Codex 的 hook 信任审查之前不生效（依据：一次默认信任运行对比一次绕过信任运行）；写后留痕在修复后于绕过信任审查的沙箱里观察到（两次运行），真实信任审查流程未测；`PreCompact not wired` 这个短语保留。
- 「Lifecycle hooks (shipped)」一列 Codex 行补「需完成 hook 信任审查后生效」。
- 写 step3f 的结果时按 §1.1 的口径。
- 第 124 行附近「Codex 平台提供 10 个事件…」是 2026-10-06 取自供应商文档的说法，补一句：0.159.3 的 CLI 探测未能确认事件清单。
- 文中其他与这些事实矛盾的句子一并改正（先 grep `quota`、`not yet run`、`FAIL`、`2026-10-10`）。
- **写法约束（否则 `state-surface` 变红）**：在 `AGENTS.md`、`README.md`、`docs/MULTI-PLATFORM.md` 里，CLI 版本不要紧跟在 `Version` 一词之后，也不要在文件前 15 行或含 `Runtime status` 的行里写成裸的 `(x.y.z)`；写成 `claude 2.1.295`、`codex-cli 0.159.3` 这样的行文或表格内容。不要删除 MULTI-PLATFORM 里现有的 `Version...: 3.2.0` 那一行。

**D5. `AGENTS.md` Known Gaps**
- P4 一条：按 §1.1 的 step3f 结果和 4b 结果改写，四家都列出；仍然分开列出没测的面（交互式 Claude Code、各家自然压缩、OpenCode 会话启动注入、Codex 真实信任审查流程）。「step3f grading is HARD for all three from v3.2.0」是关于 3.2.0 那次发版的历史事实，保留，再补 claude-code 自首个基线（2026-10-09）起为 HARD。
- P2 一条：补 Codex 的 hook 信任前提和 Claude Code「已有且不同的 `settings.json` 时不注册」。该行必须仍以 `- **P2 ` 开头并含 `Hook adapters` 与 `(implemented`（check8 靠这三处定位，丢了会静默跳过）。
- `Runtime status` 引用块（第 9 行起）：版本号不动；其中「每家都投影 hook 配置」之类的句子补上 Codex 需完成信任审查的限定。块内不得出现 `no lifecycle hooks`、`hook-enabled`、`currently get skills + routing + packs`。
- 改完跑 `release-verify.sh state-surface .`。

**D6. `publish-protocol.md` step3f**
- runtime 集合 `{codex, opencode, cursor}` 改为 `{claude-code, codex, opencode, cursor}`，可在步骤文字里加一个括注 `(claude-code added 2026-10-09: restored as an install target)`。变更说明按该步骤的规定写进发版记录，那是下一张 handoff 的事，不在这里写。
- 同一步骤里「all three runtimes」之类的措辞相应改为四家，并写明 claude-code 首个基线为 2026-10-09、自本次发版起为 HARD。
- 只动 step3f 这一段。

**D7. 另外三处用户会读到的旧说法**
- `.tad/codex/README.md`：第 3 行和第 12 行附近写着 Codex 是「hook-enabled…first-class」运行时、「Hooks | Active」，并说其他平台的 hook「not yet」。改为事实：四家都投影 hook 配置；Codex 的在完成 hook 信任审查后生效；去掉禁用词。`AGENTS.md` 把用户指到这个文件。
- `docs/CODEX-USER-GUIDE.md`：在讲 hook 的地方加一句信任审查的前提。只加一句。
- `README.md`：第 5 行附近列出 Codex hook 的句子补信任审查的限定；第 141 行附近「every context compaction auto-writes a mechanical snapshot…live-fire verified on a real /compact」改为如实：Codex 未接线；Claude Code 上验证的是手动 `/compact`（当时无内容可压缩），自然压缩未测；Cursor、OpenCode 只有处理函数级别的证据。

## 3. 工作包 E：发版门加固

文件：`.tad/hooks/lib/release-verify.sh`、`.tad/tests/tad-update-fixture.sh`（只改 `release-gates` 用例）、`.agents/skills/release-runbook/references/publish-ops.md`、`.agents/skills/alex/references/publish-protocol.md`（只加 E3 的步骤；与 D6 改的不是同一处，两位实现者各改各的段落，不要重排文件）、新文件 `.tad/tests/release-gates-fixture.sh`（可选，见 E4）。

**E1. `provenance` 模式增加整树成员检查**（调研 §5.5 方案 1；设计审查 E1 一节）
现状：只核对 hook 模板和 `alex/SKILL.md` 两个文件是否在台账里。别的 skill 文件变了、台账没重新生成，门照样通过。
要求：保留现有四项检查，新增第五项，判定条件与生成器（`gen-claude-provenance.sh`）的取舍逐条一致：
- 取 `git -C <repo> ls-files -s -- .agents/skills .tad/templates/claude/settings.json`。只看模式为 `100644` 或 `100755`、路径未被 git 加引号、且位于 `.agents/skills/<name>/...`（至少在 skills 根目录下一层目录里）的条目；其他模式、带引号的路径、直接放在 skills 根目录下的文件一律忽略，与生成器相同。
- 对每个这样的条目，`(blob, 相对 .agents/skills/ 的路径)` 必须是台账里的一条 `skill` 行（键匹配，不是只比 blob）。hook 模板的 blob 必须是一条 `settings` 行。
- 缺失时逐条打印 `not in ledger: <path> (<blob>)`，最多 20 条，其余给计数；退出 1；保留「regenerate the ledger」的指引。
- 读的是索引（已暂存或已提交的内容），不读工作区文件。因此人未提交的两份文件不影响结果，这是有意的，在注释里写明；同时写明：已暂存但未提交的 skill 改动会让本项变红，直到提交并重新生成台账。
- git 探测放在「台账文件是否存在」的检查之前：不在 git 仓库里或 `git ls-files` 失败时退出 2。
- 用 `awk` 或排序后 `comm`，不逐文件起进程；耗时 1 秒量级；兼容 `/bin/bash` 3.2。
- 这处改动超过 20 行，完成报告里按 AR-002 列出契约变更（新增检查项、无 git 时由可运行变为退出 2）。

**E2. `version-sweep` 的强制清单补六条**（调研 §2.3 第 1 条；模式已由设计审查核对）
按既有条目的格式加入：
- `.tad/TAD-VERSION`：整行等于版本号；
- `.tad/capability-packs/pack-registry.yaml`：`synced_from_version: "<版本>"`；
- `.tad/templates/handoff-a-to-b.md`：`**Handoff Version:** <版本>` 和 `**Version**: <版本>` 两条；
- `.tad/templates/deliverable-handoff.md`：同样两条。
加完后 `release-verify.sh version-sweep . 3.2.0` 必须仍然通过。不改 Layer 2。

**E3. 把三个门写进发版规程**
`provenance`、`installer-destructive-guard`、`freshness` 目前不在 `publish-ops.md`、`publish-protocol.md` 里。两份文件的结构：`publish-ops.md` 第 2 节是版本提升**之前**的只读预检，第 30–31 行有一句规定顺序的话；第 3 节是版本提升；第 4 节是发布。
- `publish-ops.md`：
  - 第 2 节加入 `installer-destructive-guard` 与 `freshness`（放在 migration 之后、supporting checks 之前），并同步改第 30–31 行那句顺序。每个门一行命令，沿用文件里现有的命令写法。
  - 在第 3 节之后（或其末尾）加一小节「提升之后」：版本提升提交存在之后，运行 `.tad/scripts/gen-claude-provenance.sh` 并提交其输出，然后重跑 `version-sweep` 和 `provenance`。
  - 写入这句原文（验收脚本按字面检查）：`All gates must complete before the tag; a commit made after the tag makes the migration gate look for an X-to-X hop.`
  - `freshness` 退出 1 时怎么办：如实重新核对该行（不得只改日期），或在发版记录里写明人的豁免。补一句提醒：高波动行在 `last_verified` 之后第 31 天变为 BLOCK，与是否改过文件无关。
  - 退出码含义：1 = 阻断，2 = 硬阻断。
- `publish-protocol.md`：在 `step3d` 之后加 `step3d2`，沿用该文件的步骤格式（`blocking: true`、`detect_only: true`），内容同上（命令逐条、两条顺序约束、freshness 的处理），同样含上面那句原文和 `.tad/scripts/gen-claude-provenance.sh` 这个路径。不改 `step3d` 现有文字的含义；该文件里 3c、3d 写「proceed to step4」而 3e、3f、3g 顺序跟随，新步骤按后一种方式接入，并在 `step3d2` 里注明它在 `step3d` 之后、`step3e` 之前。
- 两处新增文本各不超过约 30 行，只做就地插入。

**E4. `release-gates` 用例**
这个用例在 5b 工作包 B 里已经被改过一轮：现在的版本里 `parity` 是一个 SKIP 分支，日志行带 `PASS|FAIL|SKIP`，最新标签等于当前版本时 migration 是 SKIP。Conductor 会在 B 提交之后才派发本工作包；动手前用 `git status --short -- .tad/tests/tad-update-fixture.sh` 确认该文件没有未提交改动，有的话停下来问。
- 把第 1 个门整块（含对 `release-verify.sh parity` 的探测和它的 SKIP 输出）换成真正的 `structural "$REPO_ROOT" "$REPO_ROOT"` 调用。
- 在 migration 之后加入 `installer-destructive-guard`、`provenance`、`freshness` 三项；三项依次编号 5、6、7，原来的 5（pack-registry driftcheck）、6（`--verify-denylist`）顺延为 8、9；顺序断言相应改为九个门（序列 `123456789`）。`freshness` 的结果随日期变化：只断言它被调用且退出码是 0 或 1，不是 2。
- 实跑一遍，在完成报告里列出每个门的实际结果。发版前的预期（设计审查实测）：门 1 `structural` 通过；门 2 `version . 3.2.0 3.1.0` 失败（50 处历史上的 3.1.0 字样，与是否提升版本无关）；门 4 `migration` 是 SKIP。**不要为了让用例变绿去改门或放宽断言**；用例今天是红的就照实报告。

## 4. 验收标准

| # | 标准 | 验证 |
|---|---|---|
| AC1 | `release-verify.sh freshness .` 退出 0，条目总数不少于 42；Codex `context_compaction` 第 12 列为 `accepted_limitation`、第 7 列为 2026-10-09、引用 `codex-h`；`trace_evidence_capture` 为 `verified_partial` 并点名信任旁路 | 脚本 `D` |
| AC2 | 四份台账和三份文档里没有禁用词；没有把未测的东西写成已验证；2026-10-06 与 2026-10-09 的证据分开表述 | 脚本 `D` + 实现审查 |
| AC3 | `state-surface`、`version-sweep . 3.2.0`、`skill-body-verify` 仍通过 | 脚本 `GUARD` |
| AC4 | `provenance` 在当前树上通过；在一个临时克隆里改一个非 alex 的 skill 文件并提交后退出 1 并点名该文件；重新生成台账后恢复通过 | 脚本 `E` |
| AC5 | `version-sweep` 对四处新增位置生效：临时克隆里把其中一处改成别的版本后退出 1 | 脚本 `E` |
| AC6 | 两份规程文本都列出三个门及两条顺序约束 | 脚本 `E` |
| AC7 | `release-gates` 用例不再调用 `parity`，并包含三个新增的门 | 脚本 `E` |
| AC8 | 不可触碰的文件未变；只有范围内的文件有改动；没有任何暂存；版本仍为 3.2.0 | 脚本 `GUARD` |
| AC9 | 提交并重新生成台账之后，全部门为绿（`freshness` 含在内），HEAD 上每个 skill blob 都在台账里 | 脚本 `FINAL`（Conductor 在提交后运行） |

## 5. 验收脚本

Conductor 编写并运行。用法：`P6_BASE=<BASE> /bin/bash <脚本> D|E|GUARD|ALL`，在仓库根目录运行；`FINAL` 由 Conductor 在提交并重新生成台账之后运行。提交顺序（Conductor 执行）：先在未提交的工作区上跑 D、E、GUARD → 按明确路径提交 D 与 E → 运行生成器并提交台账 → 跑 FINAL。认为某条检查写错了，告诉 Conductor 是哪一行、为什么，不要绕过。

### §9.1-RAW

```bash
#!/bin/bash
# Phase 6a acceptance. Run from the repo root: P6_BASE=<commit> /bin/bash <this> D|E|GUARD|ALL|FINAL
set -u
REPO="$(pwd)"
BASE="${P6_BASE:?set P6_BASE}"
WORK="$(mktemp -d)" || exit 2
trap 'rm -rf "$WORK"' EXIT
FAILS=0
ok()  { printf '  ok   %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; FAILS=$((FAILS + 1)); }
has() { grep -qF -- "$2" "$1" 2>/dev/null; }
hasE() { grep -qE -- "$2" "$1" 2>/dev/null; }
yes_() { if "$@"; then ok "$DESC"; else bad "$DESC"; fi; }
no_()  { if "$@"; then bad "$DESC"; else ok "$DESC"; fi; }
RV=.tad/hooks/lib/release-verify.sh
BANNED='一等|一流|first-class|first class|hook-enabled|四家均已验证|verified on all four|fully supported'
EV=.tad/evidence/yolo/multi-harness-restore-and-cleanup
row() { grep -E "^\| *$2 *\|" "$1" | head -1; }
# ledger columns: 6 runtime_version 7 last_verified 9 next_review 12 status
col() { printf '%s' "$1" | awk -F'|' -v n="$2" '{gsub(/^[ \t]+|[ \t]+$/,"",$n); print $n}'; }

case_D() {
  echo "== D ledgers and docs"
  /bin/bash $RV freshness . > "$WORK/fr.log" 2>&1; rc=$?
  [ "$rc" = 0 ] && ok "freshness exit 0" || { bad "freshness exit $rc"; grep -E 'BLOCK|WARN' "$WORK/fr.log" | head -6; }
  n=$(sed -n 's/^Total: \([0-9][0-9]*\) entries.*/\1/p' "$WORK/fr.log")
  [ "${n:-0}" -ge 42 ] && ok "freshness still gates $n entries (>= 42)" || bad "freshness entries: ${n:-none} (< 42: a ledger was dropped or rows no longer parse)"
  DESC="freshness reports no BLOCK"; no_ grep -q '^BLOCK' "$WORK/fr.log"
  C=.tad/runtime-compat/codex.md
  r=$(row $C context_compaction)
  [ "$(col "$r" 12)" = accepted_limitation ] && ok "codex context_compaction status" || bad "codex context_compaction status: $(col "$r" 12)"
  [ "$(col "$r" 7)" = 2026-10-09 ] && ok "codex context_compaction last_verified" || bad "codex context_compaction last_verified: $(col "$r" 7)"
  [ "$(col "$r" 9)" = 2026-11-08 ] && ok "codex context_compaction next_review" || bad "codex context_compaction next_review: $(col "$r" 9)"
  case "$(col "$r" 6)" in *0.159.3*) ok "codex context_compaction version";; *) bad "codex context_compaction runtime_version: $(col "$r" 6)";; esac
  case "$r" in *codex-h*) ok "codex context_compaction cites codex-h";; *) bad "codex context_compaction does not cite codex-h";; esac
  r=$(row $C trace_evidence_capture)
  [ "$(col "$r" 7)" = 2026-10-09 ] && ok "codex trace row last_verified" || bad "codex trace row last_verified: $(col "$r" 7)"
  [ "$(col "$r" 12)" = verified_partial ] && ok "codex trace status verified_partial" || bad "codex trace status: $(col "$r" 12) (want verified_partial)"
  case "$r" in *[Bb]ypass*) ok "codex trace row names the trust bypass";; *) bad "codex trace row does not name the trust bypass";; esac
  case "$r" in *codex-d-retest*) ok "codex trace row cites the retest";; *) bad "codex trace row does not cite codex-d-retest";; esac
  r=$(row $C hooks)
  case "$r" in *codex-c-default*) ok "codex hooks row cites the default-trust run";; *) bad "codex hooks row does not cite codex-c-default";; esac
  case "$r" in *apply_patch*) ok "codex hooks row names the apply_patch cause";; *) bad "codex hooks row lacks the apply_patch cause";; esac
  [ "$(col "$r" 12)" = verified_partial ] && ok "codex hooks status verified_partial" || bad "codex hooks status: $(col "$r" 12) (want verified_partial)"
  DESC="codex ledger header no longer says the two rows hung on quota"; no_ hasE $C 'hung on vendor usage limit'
  r=$(row .tad/runtime-compat/claude-code.md context_compaction)
  case "$r" in *2026-10-09*) ok "claude context_compaction records 2026-10-09";; *) bad "claude context_compaction lacks 2026-10-09";; esac
  case "$r" in *[Mm]anual*) ok "claude context_compaction says manual trigger";; *) bad "claude context_compaction does not say manual";; esac
  for f in cursor opencode; do DESC="$f ledger records 2026-10-09"; yes_ has .tad/runtime-compat/$f.md '2026-10-09'; done
  DESC="claude-code ledger has no RETIRED/DEPRECATED word"; no_ hasE .tad/runtime-compat/claude-code.md 'RETIRED|DEPRECATED'
  for f in .tad/runtime-compat/codex.md .tad/runtime-compat/claude-code.md .tad/runtime-compat/cursor.md .tad/runtime-compat/opencode.md docs/MULTI-PLATFORM.md AGENTS.md README.md .tad/codex/README.md; do
    DESC="no banned support claim in $f"; no_ hasE "$f" "$BANNED"
  done
  M=docs/MULTI-PLATFORM.md
  cr=$(grep -E '^\| \*\*Codex\*\*' $M | head -1)
  case "$cr" in *[Tt]rust*) ok "MULTI-PLATFORM Codex row states trust review";; *) bad "MULTI-PLATFORM Codex row has no trust review";; esac
  case "$cr" in *0.159.3*) ok "MULTI-PLATFORM Codex row names 0.159.3";; *) bad "MULTI-PLATFORM Codex row lacks 0.159.3";; esac
  case "$cr" in *"PreCompact not wired"*) ok "MULTI-PLATFORM Codex row: PreCompact not wired";; *) bad "MULTI-PLATFORM Codex row lost 'PreCompact not wired'";; esac
  case "$cr" in *[Bb]ypass*) ok "MULTI-PLATFORM Codex row names the trust bypass";; *) bad "MULTI-PLATFORM Codex row does not say the evidence used the trust bypass";; esac
  for h in 'Claude Code' 'Cursor' 'OpenCode'; do
    hr=$(grep -E "^\| \*\*$h\*\*" $M | head -1)
    case "$hr" in *2026-10-09*) ok "MULTI-PLATFORM $h row has 2026-10-09 evidence";; *) bad "MULTI-PLATFORM $h row lacks 2026-10-09";; esac
  done
  hr=$(grep -E '^\| \*\*Claude Code\*\*' $M | head -1)
  case "$hr" in *2026-10-06*) bad "MULTI-PLATFORM Claude Code row cites 2026-10-06 (no such run)";; *) ok "MULTI-PLATFORM Claude Code row does not invent a 2026-10-06 run";; esac
  DESC="MULTI-PLATFORM: 2026-10-06 evidence kept"; yes_ has $M '2026-10-06'
  DESC="MULTI-PLATFORM: no stale 'not yet run'"; no_ hasE $M 'regression not yet run'
  DESC="MULTI-PLATFORM: interactive surface still marked unmeasured"; yes_ hasE $M '[Ii]nteractive'
  DESC="MULTI-PLATFORM: version line kept"; yes_ hasE $M 'Version.*: 3\.2\.0'
  DESC="AGENTS.md: no stale Codex quota retry line"; no_ has AGENTS.md 'retry on/after 2026-10-10'
  DESC="AGENTS.md: no stale 'Claude Code: not yet run'"; no_ has AGENTS.md 'Claude Code: not yet run'
  DESC="AGENTS.md: runtime status line still v3.2.0"; yes_ has AGENTS.md 'Runtime status (v3.2.0)'
  p2=$(grep -E '^- \*\*P2 ' AGENTS.md | head -1); p4=$(grep -E '^- \*\*P4 ' AGENTS.md | head -1)
  case "$p2" in *"Hook adapters"*"(implemented"*|*"(implemented"*"Hook adapters"*) ok "AGENTS.md P2 keeps the check8 anchor";; *) bad "AGENTS.md P2 lost 'Hook adapters' or '(implemented'";; esac
  case "$p2" in *[Tt]rust*) ok "AGENTS.md P2 states the Codex trust premise";; *) bad "AGENTS.md P2 lacks the Codex trust premise";; esac
  case "$p2" in *settings.json*) ok "AGENTS.md P2 states the Claude settings.json condition";; *) bad "AGENTS.md P2 lacks the settings.json condition";; esac
  case "$p4" in *[Ii]nteractive*) ok "AGENTS.md P4 lists the unmeasured interactive surface";; *) bad "AGENTS.md P4 dropped the interactive surface";; esac
  case "$p4" in *"Claude Code"*) ok "AGENTS.md P4 mentions Claude Code";; *) bad "AGENTS.md P4 lost Claude Code";; esac
  case "$p4" in *2026-10-09*) ok "AGENTS.md P4 records the 2026-10-09 runs";; *) bad "AGENTS.md P4 lacks 2026-10-09";; esac
  P=.agents/skills/alex/references/publish-protocol.md
  DESC="step3f set has all four runtimes"; yes_ hasE $P '\{claude-code, codex, opencode, cursor\}|\{claude-code, codex, cursor, opencode\}'
  DESC="step3f no longer freezes the three-runtime set"; no_ has $P '{codex, opencode, cursor}'
  DESC=".tad/codex/README.md states the trust review"; yes_ hasE .tad/codex/README.md '[Tt]rust'
  DESC="CODEX-USER-GUIDE states the trust review"; yes_ hasE docs/CODEX-USER-GUIDE.md '信任|[Tt]rust review'
  DESC="README no longer claims live-fire compaction for every runtime"; no_ has README.md 'live-fire verified on a real /compact'
  /bin/bash $RV state-surface . > "$WORK/ss.log" 2>&1 && ok "state-surface PASS" || { bad "state-surface: $(tail -1 "$WORK/ss.log")"; grep -E '^FAIL' "$WORK/ss.log" | head -4; }
  DESC="state-surface check8 actually ran (no silent skip)"; no_ grep -qiE 'check8.*(skip|INFO)' "$WORK/ss.log"
  DESC="completion report D exists"; yes_ test -f $EV/phase6a-completion-D.md
}

case_E() {
  echo "== E release gates"
  DESC="release-verify passes bash 3.2 syntax check"; yes_ /bin/bash -n $RV
  /bin/bash $RV provenance . > "$WORK/pv.log" 2>&1; rc=$?
  [ "$rc" = 0 ] && ok "provenance PASS on the repo (index-based: says nothing about after-commit)" || { bad "provenance exit $rc on the repo"; tail -6 "$WORK/pv.log"; }
  CL="$WORK/clone"; git clone -q --local "$REPO" "$CL" 2>/dev/null
  if [ -d "$CL/.git" ]; then
    cp "$REPO/$RV" "$CL/$RV"
    ( cd "$CL" && git config user.email t@example.invalid && git config user.name t && git commit -q -am "carry gate script" ) >/dev/null 2>&1
    regen() { ( cd "$CL" && /bin/bash .tad/scripts/gen-claude-provenance.sh > "$WORK/gen.log" 2>&1 && git add .tad/provenance && git commit -q -m regen ) >/dev/null 2>&1; }
    pv() { ( cd "$CL" && /bin/bash $RV provenance . > "$WORK/$1" 2>&1 ); echo $?; }
    regen; rc=$(pv pv0.log)
    [ "$rc" = 0 ] && ok "clone baseline: provenance PASS" || { bad "clone baseline provenance exit $rc"; tail -4 "$WORK/pv0.log"; }
    ( cd "$CL" && printf '\nprobe line\n' >> .agents/skills/blake/SKILL.md && git commit -q -am probe ) >/dev/null 2>&1
    rc=$(pv pv2.log)
    [ "$rc" = 1 ] && ok "provenance exit 1 after a committed change to blake/SKILL.md" || bad "provenance exit $rc after a committed skill change (want 1)"
    grep -qE 'not in ledger: \.agents/skills/blake/SKILL\.md \([0-9a-f]{40}\)' "$WORK/pv2.log" && ok "message format: not in ledger: <path> (<blob>)" || bad "message lacks 'not in ledger: .agents/skills/blake/SKILL.md (<blob>)'"
    regen; rc=$(pv pv3.log)
    [ "$rc" = 0 ] && ok "provenance PASS again after regenerating the ledger" || { bad "provenance exit $rc after regeneration"; tail -4 "$WORK/gen.log"; tail -4 "$WORK/pv3.log"; }
    ( cd "$CL" && printf '\nunstaged probe\n' >> .agents/skills/blake/SKILL.md ); rc=$(pv pv5.log)
    [ "$rc" = 0 ] && ok "provenance ignores an unstaged working-tree edit" || bad "provenance exit $rc with only a working-tree edit (want 0)"
    ( cd "$CL" && git add .agents/skills/blake/SKILL.md ); rc=$(pv pv5b.log)
    [ "$rc" = 1 ] && ok "provenance is red for a staged, uncommitted skill change" || bad "provenance exit $rc with a staged skill change (want 1)"
    ( cd "$CL" && git reset -q --hard )
    rf=$( cd "$CL" && git ls-files '.agents/skills/blake/references/*' | head -1 )
    if [ -n "$rf" ]; then
      ( cd "$CL" && printf '\nref probe\n' >> "$rf" && git commit -q -am ref-probe ) >/dev/null 2>&1; rc=$(pv pv6.log)
      [ "$rc" = 1 ] && ok "provenance catches a changed reference file" || bad "provenance exit $rc after a reference-file change (want 1)"
      regen
    else bad "no blake reference file found for the reference probe"; fi
    ( cd "$CL" && ln -s SKILL.md .agents/skills/blake/probe-link && git add .agents/skills/blake/probe-link && printf 'x\n' > .agents/skills/rootfile-probe.txt && git add .agents/skills/rootfile-probe.txt && git commit -q -m odd ) >/dev/null 2>&1; rc=$(pv pv7.log)
    [ "$rc" = 0 ] && ok "symlink and skills-root file are ignored, as the generator ignores them" || { bad "provenance exit $rc with a symlink and a skills-root file (want 0)"; grep 'not in ledger' "$WORK/pv7.log" | head -3; }
    mkdir -p "$WORK/nogit/.tad/provenance" && cp "$REPO/.tad/provenance/"* "$WORK/nogit/.tad/provenance/" 2>/dev/null
    ( cd "$WORK" && /bin/bash "$REPO/$RV" provenance "$WORK/nogit" >/dev/null 2>&1 ); rc=$?
    [ "$rc" = 2 ] && ok "provenance exit 2 outside a git repo" || bad "provenance exit $rc outside a git repo (want 2)"
    ( cd "$CL" && /bin/bash $RV version-sweep . 3.2.0 > "$WORK/vs0.log" 2>&1 ); rc=$?
    [ "$rc" = 0 ] && ok "version-sweep . 3.2.0 PASS in the clone" || { bad "version-sweep exit $rc in the clone"; grep '❌' "$WORK/vs0.log" | head -5; }
    for f in .tad/TAD-VERSION .tad/capability-packs/pack-registry.yaml .tad/templates/handoff-a-to-b.md .tad/templates/deliverable-handoff.md; do
      ( cd "$CL" && cp "$f" "$WORK/keep" && sed 's/3\.2\.0/9.9.9/g' "$WORK/keep" > "$f" && /bin/bash $RV version-sweep . 3.2.0 > "$WORK/vs.log" 2>&1; echo $? > "$WORK/vs.rc"; cp "$WORK/keep" "$f" )
      [ "$(cat "$WORK/vs.rc")" = 1 ] && ok "version-sweep catches a stale $f" || bad "version-sweep exit $(cat "$WORK/vs.rc") with a stale $f (want 1)"
    done
    for f in .tad/templates/handoff-a-to-b.md .tad/templates/deliverable-handoff.md; do
      ( cd "$CL" && cp "$f" "$WORK/keep" && sed 's/^\(\*\*Version\*\*: \)3\.2\.0/\19.9.9/' "$WORK/keep" > "$f" && /bin/bash $RV version-sweep . 3.2.0 > "$WORK/vs.log" 2>&1; echo $? > "$WORK/vs.rc"; cp "$WORK/keep" "$f" )
      [ "$(cat "$WORK/vs.rc")" = 1 ] && ok "version-sweep catches a stale footer line alone in $f" || bad "version-sweep misses a stale footer line in $f"
    done
  else bad "could not make a local clone for the negative controls"; fi
  /bin/bash $RV version-sweep . 3.2.0 > "$WORK/vsr.log" 2>&1 && ok "version-sweep . 3.2.0 PASS on the repo" || bad "version-sweep . 3.2.0 fails on the repo"
  O=.agents/skills/release-runbook/references/publish-ops.md
  P=.agents/skills/alex/references/publish-protocol.md
  for f in $O $P; do
    b=$(basename $f)
    for g in 'provenance' 'installer-destructive-guard' 'freshness'; do DESC="$b lists the $g gate command on one line"; yes_ hasE "$f" "release-verify\.sh[^\`]* $g"; done
    DESC="$b contains the literal ordering sentence"; yes_ has "$f" 'All gates must complete before the tag'
    DESC="$b names the generator script"; yes_ has "$f" '.tad/scripts/gen-claude-provenance.sh'
    DESC="$b says what to do on a freshness block"; yes_ hasE "$f" '[Ww]aiver|豁免'
  done
  DESC="publish-protocol has step3d2"; yes_ hasE $P '^[[:space:]]*step3d2:'
  DESC="publish-ops order sentence includes the new gates"; yes_ hasE $O 'migration.*(installer-destructive-guard|freshness).*supporting'
  T=.tad/tests/tad-update-fixture.sh
  DESC="tad-update-fixture passes bash 3.2 syntax check"; yes_ /bin/bash -n $T
  blk=$(awk '/^case_release_gates\(\)/,/^}/' $T | grep -vE '^[[:space:]]*#')
  [ -n "$blk" ] && ok "release-gates case found" || bad "release-gates case not found by name (case_release_gates)"
  printf '%s\n' "$blk" | grep -q 'parity' && bad "release-gates still mentions parity outside comments" || ok "release-gates no longer mentions parity"
  for g in structural installer-destructive-guard provenance freshness; do
    printf '%s\n' "$blk" | grep -qE "release-verify\.sh\"? +$g|RELEASE_VERIFY\"? +$g|RV\"? +$g" && ok "release-gates runs $g" || bad "release-gates does not run $g"
  done
  printf '%s\n' "$blk" | grep -q '123456789' && ok "release-gates order assertion covers nine gates" || bad "release-gates order assertion does not cover nine gates (expected the sequence 123456789)"
  DESC="completion report E exists"; yes_ test -f $EV/phase6a-completion-E.md
}

case_GUARD() {
  echo "== GUARD (run before the ledger is regenerated)"
  for p in tad.sh .tad/provenance .tad/templates bin .tad/tests/installer-data-safety-fixture.sh .tad/capability-packs; do
    ch=$( { git diff --name-only "$BASE" -- "$p"; git status --porcelain -- "$p" | cut -c4-; } | grep -v 'secret-detection-rules\.md$' | sort -u )
    if [ -z "$ch" ]; then ok "unchanged since base: $p"; else bad "changed since base: $p ($(echo "$ch" | head -3 | tr '\n' ' '))"; fi
  done
  allowed='^(\.tad/runtime-compat/(codex|claude-code|cursor|opencode)\.md|docs/MULTI-PLATFORM\.md|docs/CODEX-USER-GUIDE\.md|AGENTS\.md|README\.md|\.tad/codex/README\.md|\.agents/skills/alex/references/publish-protocol\.md|\.agents/skills/release-runbook/references/publish-ops\.md|\.tad/hooks/lib/release-verify\.sh|\.tad/tests/tad-update-fixture\.sh|\.tad/active/handoffs/HANDOFF-2026-10-09-release-evidence-and-gates\.md)$'
  extra=$( { git diff --name-only "$BASE"; git ls-files -o --exclude-standard; } | grep -vE "$allowed" | grep -v -e 'secret-detection-rules\.md$' -e '^docs/pm/status\.md$' -e '^\.claude/' | sort -u )
  [ -z "$extra" ] && ok "only in-scope files changed" || bad "out-of-scope changes: $(echo "$extra" | head -4 | tr '\n' ' ')"
  git diff --cached --quiet && ok "nothing staged" || bad "something is staged (handoff 1.2: no git add)"
  DESC="no file under .claude/ is tracked"; no_ test -n "$(git ls-files .claude | head -1)"
  DESC="version.txt still 3.2.0"; yes_ test "$(cat .tad/version.txt)" = "3.2.0"
  for m in "state-surface ." "installer-destructive-guard ." "version-sweep . 3.2.0"; do
    # shellcheck disable=SC2086
    /bin/bash $RV $m > "$WORK/g.log" 2>&1; rc=$?
    [ "$rc" = 0 ] && ok "release-verify $m" || bad "release-verify $m rc=$rc: $(tail -1 "$WORK/g.log")"
  done
  /bin/bash .tad/hooks/lib/skill-body-verify.sh > "$WORK/g.log" 2>&1 && ok "skill-body-verify" || bad "skill-body-verify: $(tail -1 "$WORK/g.log")"
  node .tad/scripts/check-path-refs.mjs > "$WORK/g.log" 2>&1 && ok "check-path-refs" || { bad "check-path-refs"; grep '^DANGLING' "$WORK/g.log" | head -5; }
}

case_FINAL() {
  echo "== FINAL (after commit and ledger regeneration)"
  for m in "provenance ." "state-surface ." "installer-destructive-guard ." "freshness ." "version-sweep . 3.2.0"; do
    # shellcheck disable=SC2086
    /bin/bash $RV $m > "$WORK/f.log" 2>&1; rc=$?
    [ "$rc" = 0 ] && ok "release-verify $m" || bad "release-verify $m rc=$rc: $(tail -1 "$WORK/f.log")"
  done
  [ -z "$(git status --porcelain -- .agents/skills .tad/provenance | grep -v secret-detection-rules)" ] && ok "skills and provenance committed" || bad "uncommitted skill or provenance changes"
  git ls-tree -r HEAD -- .agents/skills | awk -F'\t' '{split($1,a," "); if (a[1]!="100644" && a[1]!="100755") next; p=$2; sub(/^\.agents\/skills\//,"",p); if (p !~ /\//) next; print "skill\t" a[3] "\t" p}' | LC_ALL=C sort -u > "$WORK/h.kv"
  awk -F'\t' '$1=="skill"' .tad/provenance/claude-legacy.tsv | LC_ALL=C sort -u > "$WORK/l.kv"
  miss=$(LC_ALL=C comm -23 "$WORK/h.kv" "$WORK/l.kv" | wc -l | tr -d ' ')
  [ "$miss" = 0 ] && ok "every skill blob at HEAD is a ledger row" || bad "$miss HEAD skill blobs are not in the ledger"
  /bin/bash .tad/hooks/lib/skill-body-verify.sh > "$WORK/f.log" 2>&1 && ok "skill-body-verify" || bad "skill-body-verify: $(tail -1 "$WORK/f.log")"
  node .tad/scripts/check-path-refs.mjs > "$WORK/f.log" 2>&1 && ok "check-path-refs" || { bad "check-path-refs"; grep '^DANGLING' "$WORK/f.log" | head -5; }
}

case "${1:-ALL}" in
  D) case_D ;; E) case_E ;; GUARD) case_GUARD ;; FINAL) case_FINAL ;;
  ALL) case_D; case_E; case_GUARD ;;
  *) echo "usage: P6_BASE=<commit> $0 D|E|GUARD|ALL|FINAL" >&2; exit 2 ;;
esac
echo "== TOTAL FAILS: $FAILS"
[ "$FAILS" = 0 ]
```

## 6. 交付

- 完成报告：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase6a-completion-D.md`、`phase6a-completion-E.md`。
- D 的报告须含一张对照表：每一处改动的句子 → 它依据的证据文件。写不出依据的句子不要写进文档。
- E 的报告须含 `release-gates` 用例实跑时每个门的实际结果。
- 全部前台运行；卡住、矛盾、几分钟没有输出，就给 Conductor 发消息。

## 7. 风险

| 风险 | 缓解 |
|---|---|
| 把「观察到一次」写成「已验证」，或把本机结果与远程结果合并 | §1.1 裁定；D 的对照表；实现审查逐句核对 |
| 为了让 `freshness` 清零而空改日期 | Codex 压缩一行只允许 `accepted_limitation` 且必须写明未测；脚本检查状态 |
| 台账单元格里的 `|` 让解析错位 | 明确禁止；脚本检查条目总数不少于 42 |
| `provenance` 加严后在人的未提交文件上误报 | 用索引里的 blob，不读工作区 |
| 规程文本改动影响其他步骤 | 每处不超过约 25 行，只新增 |
