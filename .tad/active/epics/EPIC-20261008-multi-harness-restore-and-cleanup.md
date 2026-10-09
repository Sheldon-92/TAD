# Epic: 多 Harness 恢复与残余清理（Multi-Harness Restore & Cleanup）

**Epic ID**: EPIC-20261008-multi-harness-restore-and-cleanup
**Created**: 2026-10-08
**Owner**: Alex
**Target version**: 3.3.0
**Decision Record**: `.tad/decisions/DR-20261008-claude-code-runtime-restore.md`

---

## Objective
把 v3.0.0 剔除 Claude Code 运行时造成的损伤修回来，使 TAD 在 Claude Code、Codex、Cursor、OpenCode 四个 harness 上都是一等公民（角色入口、生命周期 hook、编排能力、安装与升级路径齐备），同时保持 `.agents/skills/` 为唯一 skill 正本。恢复完成后清掉全仓残余（悬空引用、红门、口径漂移、过期状态面），以 v3.3.0 发版收口。

## Success Criteria
- [ ] SC1 全新项目用 `--platform claude-code|codex|cursor|opencode` 各装一次，全部 exit 0 且安装自检通过
- [ ] SC2 Claude Code 真机：`/alex` `/blake` `/gate` 能进角色；SessionStart / PreCompact / PostToolUse 三个 hook 实际触发，有会话记录为证
- [ ] SC3 skill 正文只有一份来源：有一条检查命令证明仓库与安装产物里没有重复的 skill 正文
- [ ] SC4 自带 `.claude/settings.json` 的现有项目升级后，用户自己的 hook 与权限配置逐字节保留，只多出 TAD 管辖块
- [ ] SC5 10 个 workflow 在 Claude Code 主会话下可经 `scriptPath` 调用；其中 8 个有真实运行记录（`yolo-epic` 仅 design 步），`pack-upgrade`、`surplus-execute` 有零代理装载与缺参校验记录并如实标为未真跑；`spec-compliance-reviewer` 在 Claude Code 目标项目中是已注册子代理（Phase 4）；其余 harness 上协议明确降级而非报错 —— *2026-10-09 修订，见 Notes*
- [ ] SC6 四个 harness 各有一份真机全链回归 transcript，结论 PASS（含承接项：Codex PASS 基线，原排 2026-10-10 补跑）
- [ ] SC7 全部发版检查 exit 0；历史归档面之外零悬空路径引用；NEXT.md ≤ 500 行；各文档版本与状态说法一致

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Claude Code 实例声明与探活 spike | ✅ Done | HANDOFF-2026-10-08-claude-code-instance-spike.md（已归档） | 四个未知项的真机实测结论＋`runtime-adapter-instance-claude-code.md` |
| 2 | 安装器与投影落地 | ✅ Done | HANDOFF-2026-10-08-claude-code-installer-projection.md（已归档） | `--platform claude-code` 可装：skill 投影、hook 注册、CLAUDE.md 引用块、平台探测 |
| 3 | 编排能力恢复 | ✅ Done | HANDOFF-2026-10-09-workflow-restore.md（已归档） | 10 workflow＋2 子代理恢复并翻新；8 个有真实运行记录，2 个仅装载校验 |
| 4 | 下游升级路径与四家真机回归 | 🔄 Active | 分 4a（存量接管与安装器数据安全）、4b（四家真机回归）两张 handoff | 3.2.0→3.3.0 迁移清单、存量 `.claude/` 合并安全、四家 transcript PASS |
| 5 | 残余清理 | ⬚ Planned | — | 悬空引用清零、红门转绿、口径一致、状态面瘦身 |
| 6 | v3.3.0 发版 | ⬚ Planned | — | 发版清单全绿、CHANGELOG、tag |

### Phase Dependencies
顺序执行。Phase 2 依赖 Phase 1 的实测结论（链接可用性决定走 A 还是 B 路径）；Phase 3 依赖 Phase 2（workflow/子代理的装载点由安装器投影）；Phase 4 依赖 Phase 2+3（回归对象齐备）；Phase 5 必须排在 1–4 之后（人裁定「先恢复再清理」，避免把恢复所需的引用当残余删掉）；Phase 6 依赖全部。

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## 已锁定的人裁定（2026-10-08）

| # | 决定 | 选择 |
|---|---|---|
| D1 | Claude Code 如何取得 skill | 安装时逐 skill 符号链接为主（A）；链接在同步盘/目标环境实测不可用时退到生成指路文件（B）。禁止恢复完整镜像 |
| D2 | workflow/子代理恢复方式 | 自 `20223774^` 历史恢复后逐个翻新，每个至少真跑一次 —— *执行注（2026-10-09，Conductor 在人授权范围内裁定）：10 个全部恢复并翻新；真跑 8 个，`pack-upgrade` 与 `surplus-execute` 不真跑（一跑即改正本 pack 或自动执行积压任务并派数十代理），改做零代理装载与缺参校验；`security-auditor` 定义恢复但不投影给目标项目* |
| D3 | AGENTS.md 兜底 | 安装器在**已存在**的 `CLAUDE.md` 内维护带标记的引用块；项目无 `CLAUDE.md` 时不创建 |
| D4 | 版本号 | 3.3.0 |
| 顺序 | 两条线先后 | 先恢复多 harness，再清残余 |
| 排除 | 不在本 Epic | 重写 OBJECTIVES/定新方向（仅修指向已退役物的条目）；协议瘦身；直接改下游仓；新能力包/Lite/Capability Builder/第五个 harness |

---

## Phase Details

### Phase 1: Claude Code 实例声明与探活 spike

**Status:** ✅ Done（2026-10-08；Gate 4 由人委托 Conductor 裁定——人原话「你自己决定，继续把 epic 跑完」）
**Execution:** YOLO（人裁定 2026-10-08：子代理任 Blake 与审查者，模型 Sonnet 5.5；Conductor 手动驱动——`yolo-epic` workflow 已随 v3.0.0 删除）

#### Scope
按 `runtime-adapter-checklist.md` 六维为 Claude Code 立实例声明，并用真机实测关闭四个未知项：(a) `AGENTS.md` 在无 `CLAUDE.md` 的项目里是否真被加载（2026-10-08 本仓会话中未见其进入上下文，原因未明）；(b) 逐 skill 符号链接在「云同步」目录下是否可被 Claude Code 发现并稳定存活；(c) `CLAUDE.md` 内引用块能否让 `AGENTS.md` 在已有 `CLAUDE.md` 的项目里加载；(d) `.claude/settings.json` 的 SessionStart/PreCompact/PostToolUse 对共享 `.tad/hooks/*.sh` 的触发与 stdin/输出契约。**不在范围**：改 `tad.sh`、改任何 skill 正文、恢复 workflow——本 Phase 只在隔离骨架仓里手置探针并出结论。

#### Input
- 官方文档核查结论（2026-10-08，见 DR）：skill 只认 `.claude/skills/`；逐 skill 链接有文档支持、目录级链接无文档；`AGENTS.md` 仅在工作目录及上级无 `CLAUDE.md` 时默认加载；hook 位置为 `.claude/settings.json` 或插件
- 既有三家实例：`.tad/project-knowledge/patterns/runtime-adapter-instance-{codex,cursor,opencode}.md`
- 剔除前的注册面：`git show 20223774^:.claude/settings.json`

#### Output
- `.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md`（六维声明＋残项编号 R-CC-n）
- spike 证据目录：四个未知项各一份原始日志与判读
- 对 D1 的定案句：走 A、走 B、或按环境二选一的判据

#### Acceptance Criteria
- [ ] `test -f .tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md` 且六维表行齐全：`grep -cE '^\| [①②③④⑤⑥] ' <file>` 输出 6（实例体例为六行表，非小节标题——2026-10-08 起草 handoff 时对 cursor 实例实跑订正）
- [ ] 未知项 (a)(b)(c)(d) 各有一份原始日志在 `.tad/evidence/spikes/2026-10-claude-code-instance/` 下，且实例文件对每项写出 成立/不成立/部分成立 三值之一，附日志路径
- [ ] `claude --version` 实测值记入实例声明①，且 ≥ 2.1.281
- [ ] (b) 的结论包含同步盘路径与非同步盘路径各一次实测；若任一失败，实例文件写明退到 B 的触发判据
- [ ] `patterns/_index.md` 新增该实例一行；`bash .tad/hooks/lib/release-verify.sh state-surface .` exit 0

#### Files Likely Affected
- `.tad/project-knowledge/patterns/runtime-adapter-instance-claude-code.md` (CREATE)
- `.tad/project-knowledge/patterns/_index.md` (MODIFY)
- `.tad/project-knowledge/patterns/runtime-adapter-checklist.md` (MODIFY — 实例名册与残项总册)
- `.tad/evidence/spikes/2026-10-claude-code-instance/*` (CREATE)

#### Dependencies
None

#### Notes
- 清单硬规：「实例未立不许接线」——Phase 2 不得早于本 Phase 的 Gate 4
- 探针须跑在隔离骨架仓，不得在本仓 `.claude/` 下注册 hook（本仓 `.claude/` 是未跟踪的本地目录，含用户权限配置）
- Claude Code 无头面（`claude -p`）的信任与权限参数属①入口维必填

### Phase 2: 安装器与投影落地

**Status:** ✅ Done（2026-10-09；Gate 2/3/4 PASS，见 phase2-gate-report.md）
**Execution:** YOLO（Conductor 手动派发）

#### Scope
让 `tad.sh --platform claude-code` 重新成为合法目标，并沿用既有「单文件投影」模式落四样东西：skill 入口投影（按 Phase 1 定案走链接或指路文件）、`.claude/settings.json` 的 TAD hook 块、已有 `CLAUDE.md` 内的引用块、平台探测对 claude-code 的识别。全新项目与空 `.claude/` 目录是本 Phase 的目标面。**不在范围**：存量 `.claude/settings.json` 的合并安全与迁移清单（Phase 4）；workflow/子代理（Phase 3）；文档口径改写（Phase 5）。

#### Input
Phase 1 实例声明与 D1 定案；`tad.sh` 现有 `project_cursor_hooks` / `project_opencode_hooks_plugin` 及其 preflight/rollback 三件套作模板；共享行为面 `.tad/hooks/*.sh`。

#### Output
- `tad.sh`：`validate_platform` 接受 `claude-code`；新增 claude 投影三件套（preflight/project/rollback）
- 投影正本文件（hook 注册模板、指路文件生成器）
- 安装自检覆盖 claude 投影粒度
- fixture：install / 分歧 FATAL / rollback 三路

#### Acceptance Criteria
- [ ] 隔离空目录内 `bash tad.sh --platform claude-code --yes` exit 0，且 `ls <target>/.claude/skills | wc -l` 等于 `ls .agents/skills | grep -v '^_' | wc -l`
- [ ] 单一来源证明：链接路径下 `find <target>/.claude/skills -maxdepth 1 -type l | wc -l` 等于 skill 数；指路路径下每个投影 `SKILL.md` ≤ 20 行。两路径下 `git ls-files .claude/skills | wc -l` 在本仓均为 0
- [ ] `<target>/.claude/settings.json` 中 TAD 注册的命令全部指向存在的脚本：逐条 `test -f` 通过
- [ ] 目标已有 `CLAUDE.md` 时，引用块以起止标记包裹且重复安装后块数恒为 1（幂等）；目标无 `CLAUDE.md` 时安装后仍无该文件
- [ ] `--platform both` 仍在任何写入前被拒绝；`--platform codex|cursor|opencode` 的既有 fixture 全部仍 PASS
- [ ] `bash .tad/hooks/lib/release-verify.sh installer-destructive-guard .` exit 0

#### Files Likely Affected
- `tad.sh` (MODIFY)
- `.tad/hooks/lib/detect-platform.sh` (MODIFY)
- `.tad/hooks/lib/claude-*.sh` (CREATE — 仅当 stdin/输出需转码垫片)
- `.tad/templates/claude-settings-hooks.json` 或等价正本 (CREATE)
- `.tad/tests/*claude*fixture*` (CREATE)
- `.tad/runtime-compat/claude-code.md` (CREATE — 新鲜度台账)
- `bin/tad-install.mjs`、`INSTALLATION_GUIDE.md` 的平台枚举 (MODIFY)

#### Dependencies
Phase 1

#### Notes
- SAFETY：`tad.sh` 属删除/覆盖高风险面；每个新增 `rm`/覆盖点须带 guard 标记，否则 destructive-guard 转红
- 「deny-list 须在每个拷贝粒度都落实、校验粒度须与拷贝粒度一一对应」（principles 2026-06-01）直接适用：新增 claude 投影粒度必须同时新增对应校验粒度
- 剔除前的 PreToolUse haiku prompt hook 与 `pre-accept-check`/`pre-gate-check` 是否恢复，按 principles「单用户 CLI 拒绝机械强制」条定：默认不恢复阻断型 hook，须人裁定后才可加入
- 本 Phase 附带修掉评估期发现的红门：`tad.sh` 2463–2472 行 4 处未标记删除点

### Phase 3: 编排能力恢复

**Status:** ✅ Done（2026-10-09；Gate 报告 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-gate-report.md`）
**Execution:** YOLO（Conductor 手动派发）

#### Scope
自 `20223774^` 取回 10 个 `.claude/workflows/*.workflow.js` 与 2 个 `.claude/agents/*.md`，正本放在随框架同步的 `.tad/workflows/claude/` 与 `.tad/agents/claude*/`，**不由安装器投影**，以 `scriptPath` 调用（2026-10-09 修订，原文为「由安装器在 claude-code 目标上投影」；依据见下方 AC 修订注）；逐个翻新 9 月 16 日之后失效的引用（NotebookLM 退役、`claude_websearch`→`websearch` 改名、模型绑定、skill 路径）。在 Alex/Blake 协议中把这些 workflow 的调用点写成「Claude Code 有则用、其余 harness 明确降级到既有顺序路径」。**不在范围**：新增 workflow；把 workflow 移植到其他 harness 的原生编排面；YOLO2 默认开启。

#### Input
Phase 2 的投影机制；历史文件 `git ls-tree -r 20223774^ -- .claude/workflows .claude/agents`；现行协议中仍在引用这些 workflow 的位置。

#### Output
- 10 个 workflow＋2 个子代理的仓内正本（2026-10-09 修订：无投影；子代理定义投影到 `.claude/agents/` 移入 Phase 4）
- 8 个 workflow 各一份真实运行记录；`pack-upgrade`、`surplus-execute` 只有零代理装载与缺参校验记录（2026-10-09 修订，原文为「每个 workflow 一份」）
- 协议调用点的跨 harness 降级条文

#### Acceptance Criteria
*2026-10-09 修订（Conductor 在人授权范围内裁定；依据：Phase 3 摸底与五次零代理探针，见 `HANDOFF-2026-10-09-workflow-restore.md` §5、§11）。原 AC1「claude-code 目标安装后 `.claude/workflows/` 下 10 个文件」与原 AC3「每个 workflow 一份运行记录」被下列条目取代：workflow 不投影进 `.claude/workflows/`，改留在随框架同步的 `.tad/workflows/claude/` 并以 `scriptPath` 调用（实测可用，免改安装器，且避开「按名调用加载过期缓存」）。*
- [x] `.tad/workflows/claude/` 下恰 10 个 `*.workflow.js`，逐个通过包裹式语法检查；codex 与 claude-code 全新安装后目标项目里这 10 个文件与源逐字节相同（handoff §9.1 脚本 C1、C7）
- [x] 翻新后的 workflow 中已退役标识、旧树路径、固定模型绑定计数为 0；相对历史原件的改动量在封闭清单的上限内（脚本 C2、C3）
- [x] 真实运行记录落 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase3-gate-report.md`：8 个 workflow 各含 run id、agent 数与结果；`pack-upgrade`、`surplus-execute` 为零代理装载与缺参校验记录，并明示未真跑
- [x] 三处协议调用点以 `scriptPath` 调用并各带 `WORKFLOW-FALLBACK` 降级行；判据为「自己的工具列表里有无 Workflow 工具」；YOLO 的降级目标是随框架分发的文件（脚本 C5）
- [x] `bash .tad/hooks/lib/skill-body-verify.sh` RESULT 为 ALL CHECKS PASSED

#### Files Likely Affected
*2026-10-09 修订为实际改动面：*
- `.tad/workflows/claude/*.workflow.js`、`.tad/workflows/README-claude.md` (CREATE)
- `.tad/agents/claude/spec-compliance-reviewer.md`、`.tad/agents/claude-local/security-auditor.md` (CREATE)
- `tad.sh`：**未改**（原计划为投影两类新件，已取消）
- `.agents/skills/alex/references/` 下四个协议文件、`.agents/skills/surplus/SKILL.md`、`.agents/skills/blake/SKILL.md`（一处括注）(MODIFY)
- `.tad/config-agents.yaml`：**未改**（workflow 内固定模型绑定已删，改为继承会话模型）

#### Dependencies
Phase 2

#### Notes
- 已知坑（memory 2026-06）：named＋scriptPath 的 Workflow 调用不收 args，须硬编码或 Conductor 手动；子代理不能调 Workflow，live test-run 须由主会话跑。**2026-10-09 更正**：在 claude 2.1.295 上实测 `scriptPath` 与内联调用都能收到 `args` 对象，前半句已过时；「子代理不能调 Workflow」来自早先观察，Phase 3 未重测
- workflow 运行消耗大：运行记录可用最小输入，但不得以「文件存在」代「跑过」
- 改 SKILL 正文 >20 行须先列明改了哪条契约（AR-002）

### Phase 4: 下游升级路径与四家真机回归

**Status:** 🔄 Active
**Execution:** YOLO（Conductor 手动派发）；拆为 4a、4b（2026-10-09，Conductor 裁定，依据 `phase4-grounding.md` 与 epic-audit 建议）

#### Scope
保证存量项目能升到 3.3.0：补 3.2.0→3.3.0 迁移清单；让安装器对已存在的 `.claude/settings.json` 做「只动 TAD 管辖块」的合并，用户自有 hook、权限、MCP 配置逐字节保留；`tad-update` 接受 claude-code 目标。随后四个 harness 各跑一次全链真机回归并落 transcript，其中包含承接项 Codex PASS 基线。**不在范围**：进入任何下游仓执行升级（各项目自行拉取）；修下游项目自身的问题。

#### Input
Phase 2/3 产物；既有 `installer-data-safety-fixture.sh`、`upgrade-acceptance.sh`、`.tad/evidence/live-regression/` 三家基线与 `20261006-field-checklist.md`。

#### Output
- `.tad/migrations/3.2.0-to-3.3.0.yaml`
- 存量 `.claude/` 合并的 fixture（含用户 hook、权限、MCP 三类样本）
- 四份 transcript：`.tad/evidence/live-regression/{claude-code,codex,cursor,opencode}-<date>.md`

#### Acceptance Criteria
- [ ] fixture：预置含用户 hook/permissions/mcp 的 `settings.json`，安装后以 `jq 'del(<TAD 管辖路径>)'` 比对前后，`cmp` 相同
- [ ] 同一目标连续安装两次，第二次 `git diff --stat`（目标仓内）为空（幂等）
- [ ] 中断回滚：投影中途注入失败后，`.claude/` 与 `CLAUDE.md` 回到安装前状态，`diff -rq` 备份与现场无差异
- [ ] `bash .tad/hooks/lib/release-verify.sh migration . 3.3.0` exit 0
- [ ] 四份 transcript 均在盘且判定行为 PASS；`bash .tad/hooks/lib/release-verify.sh freshness .` exit 0（含 Codex 台账 `context_compaction` 条真实重验）

#### Files Likely Affected
- `.tad/migrations/3.2.0-to-3.3.0.yaml` (CREATE)
- `tad.sh`、`.tad/scripts/tad-update.sh` (MODIFY)
- `.tad/tests/installer-data-safety-fixture.sh`、`.tad/tests/upgrade-acceptance.sh` (MODIFY)
- `.tad/runtime-compat/codex.md` (MODIFY — 重验刷新，禁止空 bump)
- `.tad/evidence/live-regression/*` (CREATE)

#### Dependencies
Phase 2, Phase 3

#### Notes
- 本 Epic 唯一可能造成用户数据丢失的面在这里：高风险派发，handoff 须附风险卡，关键假设写成可证伪句
- Codex 回归受账号限额约束（上次因限额 FAIL）；限额阻塞按 BLOCKED 上报，不得改判 PASS
- 吸收 NEXT 在册单 `TASK-20260916-CODEX-LEDGER-REVERIFY`
- 承接自 Phase 3 Gate 2（2026-10-09）：(9) **子代理定义投影——本 Phase 的件目**：把 `.tad/agents/claude/*.md`（目前只有 `spec-compliance-reviewer.md`）投影进 claude-code 目标的 `.claude/agents/`，沿用 hook 模板的「不存在才落、已存在且不同则保留并提示、符号链接不写穿、回滚只撤本次创建」体例，并纳入自检、汇总与 `CLAUDE-HINT` 判断；在此之前 Claude Code 上 Blake Layer 2 Group 0 以通用子代理＋该定义文件正文作等价替代；`.tad/agents/claude-local/security-auditor.md` 不投影给目标项目，仅用于本仓自举；(10) **本仓自举**：TAD 仓自身原是受版本管理的 Claude Code 项目，现在仓内进不了 `/alex`——用自己的安装器给自己装一遍并决定哪些入库；(11) 现有安装器 fixture 在基线上有 5 项失败（`ac2.6a`、`ac2.6b`、`ac2.8`×2、`r1`），待查是测试过期还是真缺陷
- 承接自 Phase 3 真跑（2026-10-09，`handoff-review` workflow 复审已归档的 Phase 2 handoff，结果见 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/workflow-runs/handoff-review.result.txt`；以下均为审查者依文档推断，未实测）：(12) **hook 命令是相对路径——发版前必须处理**（**2026-10-09 已实测，缺陷成立**：claude 2.1.295，10 个 headless 会话；Bash `cd` 会延续到后续工具调用，之后相对路径的 PostToolUse hook 在子目录执行，2/2 次跑到了子目录里的另一份脚本；`CLAUDE_PROJECT_DIR` 在每条 hook 里都已设置且等于项目根；`cd "$CLAUDE_PROJECT_DIR" && bash …` 形式 2/2 次在项目根执行。会话从子目录启动时两种形式都不触发 hook，同 R-CC-6。报告 `phase4-hook-cwd-probe.md`。模板改为锚定形式列入 4a-2）：`.tad/templates/claude/settings.json` 的四条命令形如 `bash .tad/hooks/<x>.sh`，Phase 1 只测了会话启动时的工作目录，没测会话中途 `cd` 之后 PostToolUse/PreCompact 的工作目录；若会漂移，可能执行子目录里另一份 `.tad/hooks/` 脚本或静默失败。因「与模板不同即视为用户所有」，首发模板事后无法自动纠正，所以须在 3.3.0 首发前实测并（如需）改成锚定 `$CLAUDE_PROJECT_DIR` 的形式；(13) **hook 模板没有升级通道**：模板一改，所有已装项目都落入「保留用户文件」分支，修复到不了存量安装，且会打印不实的「TAD hooks are NOT registered」——需历史模板哈希表或标记来识别 TAD 旧版；(14) 安装后新建的 `CLAUDE.md` 会压掉 `AGENTS.md` 且无提示，考虑在 `startup-health.sh` 加只读告警；(15) 已注册的 hook 会把会话数据（含带用户名的绝对路径、提问文本）写进目标项目的 `.tad/evidence/`，而安装器不管目标项目的 `.gitignore`——安装摘要须点名这两处路径并处理忽略规则；(16) `tad-install.mjs` 与 `tad-update.sh` 的平台参数只有静态检查，补行为用例；(17) `CLAUDE-HINT` 在已装版本比源新时也打印，其建议的 `--force` 在该分支无效，应限定版本相等才提示；(18) skill 名过滤改为允许清单 `[A-Za-z0-9][A-Za-z0-9._-]*`
- 承接自 Phase 2 Gate 2（2026-10-08，人裁定缩小范围）：(4) **自动加装**——给已装同版本 TAD 的项目加一个平台，目前要 `--force` 整套重装；应提供不重装框架、不跑弃用清理的独立投影路径（注意不得在目标版本比源新时降级）；(5) **多平台共存缺陷（既有）**：弃用清理里 2.3.0 时代的规则会在每次升级型运行删 `.codex/hooks.json`，而它只在 `PLATFORM=codex` 时重生成——Codex 项目上 `--force` 装 cursor/opencode 即丢 Codex hook 接线（Phase 2 只对 claude-code 平台做了跳过）；(6) **既有按名删除**：其余平台的弃用清理仍会按文件名删用户的 `.claude/commands/research.md` 等（Alex 基线实测），与安装指南「不动你的 `.claude/`」不符；(7) v2.x 遗留的 `.claude/skills/<名>` 镜像目录会被当作用户自有保留并挡住新入口，需识别规则；(8) 会话在项目子目录启动时项目 `.claude/settings.json` 不加载（R-CC-6）
- 承接自 Phase 2 设计（2026-10-08）：(1) 已存在且不同的 `.claude/settings.json` 在 Phase 2 是「保留＋提示」，本 Phase 做合并；(2) `tad-update.sh detect_platform` 只会返回 `codex|ambiguous`，装过 claude-code 的项目升级时会被当成 codex 转发、Claude 投影不被刷新——本 Phase 须解决「已装平台的识别与粘性刷新」（一个项目可同时用多家 harness）；(3) 现有 fixture 不设 `TAD_BACKUP_ROOT`，升级类用例会写 `$HOME/.tad-backups`

### Phase 5: 残余清理

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
恢复落定后清全仓残余，分四类：(1) 悬空与过期引用——活跃面中指向不存在路径的 `.claude/` 引用按「已恢复则改指正确位置、未恢复则删」处置，NotebookLM 已退役块、「20 Domain Packs」等陈述清除；(2) 口径漂移——README、ROADMAP、AGENTS.md、PROJECT_CONTEXT、INSTALLATION_GUIDE、`docs/pm/status.md` 对平台支持与版本的说法统一到四家一等；(3) 状态面——NEXT.md 归档已完成条目至 ≤500 行、session-state 过期正文迁走、已收口 ticket 归档、OBJECTIVES 中指向已退役物的 KR 订正；(4) 停摆的例行扫描——依赖扫描与 GitHub Registry 扫描恢复或明确退役。**不在范围**：删除或瘦身协议约束条文；重定 Objectives 方向；`.tad/archive`、`.tad/evidence`、`docs/archive`、CHANGELOG 等历史面的改写。

#### Input
Phase 1–4 全部产物；2026-10-08 评估清单（见 Notes）。

#### Output
干净的活跃面与一份逐项处置表（每条残余：位置、处置、依据）。

#### Acceptance Criteria
- [ ] 悬空引用清零：对活跃面（排除 `.tad/archive` `.tad/evidence` `docs/archive` `docs/legacy` `CHANGELOG.md` `.tad/spike-v3` `scripts/archive`）提取全部 `.claude/…` 与 `.tad/…` 路径引用，逐条 `test -e`，不存在数为 0（脚本与输出落处置表）
- [ ] `wc -l < NEXT.md` ≤ 500，且 `grep -c '^### ✅' NEXT.md` 为 0
- [ ] 口径一致：`grep -rnE 'no longer offered|was removed in TAD v3\.0\.0|Returns: "codex" \| "none"' README.md ROADMAP.md AGENTS.md INSTALLATION_GUIDE.md tad.sh .tad/hooks/lib/detect-platform.sh` 无命中；`docs/pm/status.md` 版本与 `.tad/version.txt` 一致
- [ ] README 中「14 registered downstream projects」一句或有在盘可核的来源指针，或改为不依赖已退役注册表的表述
- [ ] `.tad/dependencies/scan-results.yaml` 的 `last_scan` 距验收日 ≤ 7 天，且 gh 条目 `current_version` 与 `gh --version` 一致
- [ ] `bash .tad/hooks/lib/release-verify.sh state-surface .` exit 0；处置表在 `.tad/evidence/designs/` 下可 `test -f`

#### Files Likely Affected
- `README.md`、`ROADMAP.md`、`AGENTS.md`、`PROJECT_CONTEXT.md`、`INSTALLATION_GUIDE.md`、`OBJECTIVES.md`、`NEXT.md` (MODIFY)
- `docs/pm/status.md`、`docs/MULTI-PLATFORM.md` (MODIFY)
- `.agents/skills/**`（约 30 个含 `.claude/` 引用的文件）(MODIFY)
- `.tad/guides/tool-quick-reference-alex.md`、`.tad/config-workflow.yaml`（退役块）(MODIFY)
- `.tad/active/session-state.md`、`.tad/active/TICKET-20261006-*.md` (MODIFY/归档)
- `.tad/archive/next/NEXT-completed-through-20261008.md` (CREATE)

#### Dependencies
Phase 1–4

#### Notes
评估期在册问题清单（须在处置表中逐条销账）：
1. NEXT.md 582 行且留大量 ✅ DONE；「TAD Research 机制」条目路径指 active 而文件已在 archive
2. `docs/pm/status.md` 仍写 2.44.0
3. README「14 registered downstream projects」无活的来源（注册表 2026-08 退役）
4. ROADMAP 写 OpenCode/Cursor hooks 仍是已知缺口，与 AGENTS.md「已实现」矛盾
5. Alex 快速参考仍列「Domain Packs (20 packs)」与已退役 NotebookLM 命令
6. OBJECTIVES O3 的 KR 以 NotebookLM 笔记本为达成依据
7. 依赖扫描停于 2026-08-12；gh 2.97.0 未登记
8. GitHub Registry 扫描停于 2026-09-04，43 个 pending 候选
9. session-state 正文仍标 Alex/ACTIVE 指向已收口的 hillclimb 链
10. `.tad/active/TICKET-20261006-epic-p{2,3}-*.md` 引用已归档的 Epic 路径
11. 工作区 3 个未提交改动（两份 `secret-detection-rules.md`、`docs/pm/status.md`）来历待人确认后处置
12. `package.json` 的 `test` 脚本为 `echo "No tests yet"`，与实际存在的 fixture 套件不符
- 改 SKILL / config / hooks 超过 20 行须先列契约变化（AR-002）；SAFETY 条目不得顺手改写
- 删除前先核「哪份是最新」（memory：verify-before-delete）

### Phase 6: v3.3.0 发版

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
按 `publish-protocol` 走 3.3.0 发版：版本面一致、CHANGELOG 记「恢复 Claude Code 为一等运行时」并说明与 3.0.0 公告的关系、全部发版检查实跑、打 tag 并推送。**不在范围**：向下游仓推送（已无 sync，各项目自拉）；任何功能性改动。

#### Input
Phase 1–5 全部 Gate 4 PASS。

#### Output
`v3.3.0` tag 与发布说明。

#### Acceptance Criteria
- [ ] `cat .tad/version.txt` 为 `3.3.0`，`bash .tad/hooks/lib/release-verify.sh version . 3.3.0 3.2.0` exit 0
- [ ] `release-verify.sh` 的 `state-surface`、`freshness`、`migration . 3.3.0`、`installer-destructive-guard`、`version-sweep . 3.3.0` 五项全部 exit 0，原始输出落发版证据
- [ ] CHANGELOG 3.3.0 节包含四个平台名与升级指引；`git tag -l v3.3.0` 非空
- [ ] Epic SC1–SC7 逐条有证据指针

#### Files Likely Affected
- `.tad/version.txt`、`package.json`、`CHANGELOG.md`、`README.md`、`NEXT.md`、`ROADMAP.md`、`.tad/config.yaml` (MODIFY)

#### Dependencies
Phase 1–5

#### Notes
推送与打 tag 属对外不可逆动作，须人逐次确认。

---

## Context for Next Phase

### Completed Work Summary
- Phase 2（Gate 2/3/4 PASS，2026-10-09）：`tad.sh --platform claude-code` 可用——逐 skill 相对符号链接（指路文件退路）、已有 `CLAUDE.md` 追加 `@AGENTS.md` 受管块、无 `settings.json` 时落四条非阻断 hook；符号链接一律不写穿；失败完整回滚；其余三平台产物逐字节不变。同版本项目加装需 `--force`。判定见 phase2-gate-report.md
- Phase 1（Gate 2/3/4 PASS，2026-10-08）：16 探针 13 成立／1 部分／2 不成立／0 未测成；**D1 定案 A（逐 skill 符号链接）**；AGENTS.md 加载／压制／引用三条件实测成立；三个 hook 可直调共享脚本原件、无需垫片。判定与遗留见 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase1-gate-report.md`

### Decisions Made So Far
- D1–D4 与顺序、排除项见「已锁定的人裁定」；依据见 DR-20261008

### Known Issues / Carry-forward
- 承接自 EPIC-20261006（已归档）：Codex live-regression PASS 基线未取得（原因：账号限额），并入本 Epic Phase 4
- 2026-10-08 本仓 Claude Code 2.1.295 会话中未观察到 `AGENTS.md` 自动进入上下文，上级目录无阻断性 `CLAUDE.md`，原因未明——Phase 1 未知项 (a)

### Next Phase Scope
Phase 4a：存量 Claude Code 安装的接管（旧 skill 实体目录、旧 settings.json、旧 CLAUDE.md 头、旧 workflow 副本）与安装器数据安全，含 3.2.0→3.3.0 迁移清单；设计输入为 `phase4-grounding.md` 与 `workflow-runs/tournament-phase4-legacy-adoption-design.md`。Phase 4b：四家真机回归。Phase 1 遗留 C1（交互面 `AGENTS.md` 加载）仍未验证，须人在交互会话里查看。

---

## Notes
- 2026-10-09 Phase 3 设计偏离了立项时的两处文字（D2「各至少真跑一次」、Phase 3 原 AC1「装进 `.claude/workflows/`」）。Conductor 依人 2026-10-08/09 的全权授权裁定并在 D2 执行注、SC5、Phase 3 AC 三处就地修订，原文保留在 git 历史（提交 `5ac69cc7`）。理由与实测见 Phase 3 handoff §5、§11。人可随时推翻：要全部真跑，或要投影进 `.claude/workflows/`，告知即可。
- 2026-10-08（Phase 2 Gate 2 期间）人两次明示：「后面整个 Epic 的执行我全都授权你自己做决策，你自己把它跑完」「整个 epic 我都授权你」。此前同场已书面预授权：两轮设计审查后仍有遗留 P0 时，Conductor 可自行选「缩小范围」并记录。Conductor 据此就全 Epic 的执行自行决策，每次决策落盘（handoff §9.2/§11 或各 Phase gate-report）。
- 2026-10-08 人授权 Conductor 自行裁定各 Phase 验收并把 Epic 跑完。Conductor 自定边界：每 Phase 在分支 `epic/multi-harness-restore` 本地提交一次；**推送与打 tag 不在自裁范围，Phase 6 到该步停下等人确认**；工作区原有的 3 个非本链改动不提交。
- 2026-10-08 立项。人在 *analyze 中裁定 Full 流程、建 Epic、先归档自优化 Epic、先恢复后清理。
