# Gate 2 技术评审（tech 路）— Epic Phase 3「运行时适配补全」设计

- 对象：HANDOFF-2026-10-06-epic-p3-runtime（86,126 B／sha256 `2c77e39f42b65bd85887b66bb41b56c5172f2aacdf446a5ce046921e77035b64`，开审复算与送审锚逐字全等）
- 裁断前提：PM 裁断件 `2026-10-06-epic-p3-design-rulings.md` 的 D-1–D-5 已落定，本审不重议；§9.2 提请的四处设计内决断在本审 §6 逐项表态。
- 审法：§2 基线锚逐项盘上复算；能力断言逐条对一手文档原文（本审当日抓取三页）；OC-1–OC-7 规程照行性与分支完整性；捕获隔离性与 step3f 原文对位；承接 B 计量面照行性。

## 结论：PASS（P0＝0／P1＝0／P2＝5）

设计的技术地基经本审独立复算成立：仓内锚逐项对得上、一手文档断言逐条有原文支撑、未确证项全部诚实降为 Phase 0 探针并预写分支。无开工前必改项；五条 P2 为精度注记，供 Gate 3 判读与首个增补机会处理。

## §2 基线锚复算（本审亲测）

- 行数锚全等：startup-health.sh 62 行、post-write-sync.sh 365 行、hook-envelope.sh 80 行、trace-step.sh 119 行；`.codex/hooks.json` 与 `.tad/codex/README.md` 在盘；tad.sh 生成门（PLATFORM=codex 才生成）在 L1350 邻域属实。
- envelope 契约亲读对位：事件名四级兜底、tool 三级、session_id 三级含 `conversation_id`（L76）、HOOK_SOURCE「Never synthesize」原注（L53）——§2.2 的「输入合成＋输出转码」收敛判读成立，共享脚本零改的写集纪律有据。
- tad.sh 锚全等：KNOWN_PLATFORMS L514；L519 邻域 known-gap 注记原文在盘；opencode_preflight L2371、project_opencode_command L2385、rollback_opencode_projection L2407 逐行命中——§3 原则 3 的「照既有模式扩」有真实同构对象。
- 目录锚：`.opencode/` 无 `plugins/`（见 P2-5）；`.cursor/` 不存在；`.tad/evidence/live-regression/` 不存在（3.3 首建属实）；regression-runs 仅 `20261006-first-run` 一轮。
- step3f/step4 原文对位：step3f 在 publish-protocol L237 起，冻结三家集、6 字段（L281–289，本审逐字读过）、「Phase 3 closeout 三份齐」句在盘；step4「Push only → git push (no tag)」在 L292（承接 D 成因锚属实）。
- publish-ops 落点实存：§3.1「Historical version references — minor/major triage」（L124）与 §6「Post-publish verification and report」（L185）均在盘，承接 C 锚 2 与承接 D 镜像落点非虚指。
- check4 现状：state-surface-check.sh L123 OLD_PAT ＝ `3\.1([^0-9.]|$)`，与 §2.6 所述 P2 裁定后形态逐字一致。
- infra 清单陈旧点坐实：environments.md L23 记 Cursor Agent **2026.09.28-64d2043**（2026-10-01 实测），与 §2.5「二进制已自更新」方向一致（本审未能亲测新值，见 P2-4）。
- 判分锚：regression-replay.sh 内 min_discriminative=3、control_max_hits=1、must_not 非空断言齐备，与 §2.6 引值一致；承接 A「判分锚零改」有可对之锚。
- minor 基线：本审原样复跑 detect-only（3.2.0←3.1.0）得 **56 stale hits／exit 1**，与 §2.6/§10 的设计亲测值逐值相同。

## 能力断言抽核（一手文档逐条对原文）

- **OpenCode plugins 页**：插件目录（项目 `.opencode/plugins/` 与全局目录自动加载）、npm 走 config `plugin` 数组、插件函数入参 `{project, client, $, directory, worktree}` 与 `$` 为 Bun shell、事件总线（session.created/compacted、file.edited、permission.asked/replied、message.*、todo.updated 等）、`tool.execute.before/after` 与 `shell.env` 钩子、`experimental.session.compacting` 以 `output.context.push` 注入——§2.3 的承重断言逐项有原文。设计对「output 改写是否达模型」不下断言、降为 OC-4 实测，处置正确。
- **Cursor hooks 页**：hooks.json 项目/用户两级、stdio JSON 双向、事件全集（含 sessionStart/sessionEnd、pre/postToolUse、preCompact、afterFileEdit）、项目 hooks 自项目根运行且路径形如 `.cursor/hooks/script.sh`、trusted workspace 自动加载、cloud agents 加载项目 hooks、failClosed 默认 false、退出码 0/2/其他三态——§2.4 逐项有原文。关键 I/O 逐字对上：sessionStart 输入仅 session_id/is_background_agent/composer_mode（另加通用字段）、**无 source 字段**；其输出含 `env` 与 `additional_context`（原文释义即「加入会话初始系统上下文」）；postToolUse 与 postToolUseFailure 输出均含 `additional_context`；通用输入含 conversation_id/generation_id/hook_event_name/workspace_roots，与 envelope 兜底链对位成立。
- **Cursor CLI 配置页**：项目级 `<project>/.cursor/cli.json`、`permissions.allow`/`deny`（条目为精确字符串）、`approvalMode`（allowlist/auto-review/unrestricted）、`sandbox.mode`/`sandbox.networkAccess`——§2.4 与 §4.7 第 4 行的「真可声明面」断言逐项有原文，F1 落样例的字段集可照此封口（AC27）。

## OC-1–OC-7 探活规程照行性

七项逐项有方法、原始输出落点、结论形态与对设计的分支影响，Phase 0 出口判据写死（七项全有结论、空缺不可；分支影响逐项写明）。骨架路径断言与 Phase 0 基线锚（git 状态＋§7 写集 sha256 清单）同在 Phase 0 落定，承接 B 的「变更前」面有真实来源。分支完整性：OC-2 的 A/B 判据有日志实证门（无日志不许判 B）；OC-5 双路（文档＋实测）定案；OC-7 定直调/转接二支且转接件已列条件写集。无悬空项（一处命名层小缺口见 P2-3）。

## 件 3.3／承接 A 隔离性与字段对位

- step3f 6 字段与 §4.3 成文步骤逐项同构（runtime／harness 名与版本／执行日期／链路类型／结果＋定性／原始输出指针），版本取 OC-6 复测值、本周期口径（执行日期 ≥ 上一版发布日）均与协议原文对位。
- 隔离性成立：捕获宿主为 grokbox 上骨架仓内的三家无头新进程（codex exec／opencode run／agent -p），进程级洁净、无 PM 会话上下文可继承，与首跑 INVALID 的 fork 污染根因结构性绝缘；§4.4 另以明文禁 fork/续接、对照只给 input.md，并把捕获纪律列为 AC17 的先行判据（在场 fork 记录即 FAIL）——根因对治到位。两件共用骨架面、证据与判读严格分开且明文互不充数，判读面干净。

## 承接 B 四维判据照行性

计量面可照行：试点墙钟以起止时间戳落记录；Gate 3 工时以派发记录/评审件时间戳为源（§4.5 明示来源），(ii) 维允许「待 Gate 3 后回填」中间态、AC21 以「Gate 4 前终值在盘」封口——分母后发生的时序问题有两段判读承接，不悬空。比对面构造明确：路径＋sha256 清单、排除面逐项列明且与 migration-engine 守卫同源、「不许以排除吞差异」写死。翻负判据逐维可判：(i) 不可执行/比对面不可构造、(ii) 比值 >20%、(iv) 不可分诊差异 ≥1 为自动翻负，(iii) 须 PM 点名——与 §2.6 引的 2.6 评估原口径对位。本审曾考虑 §9.2(c) 提的改锚备选（以实施总工时为分母）：改锚会与评估原框架断裂、且试点成本的对照对象本就是它要增援的 Gate 3 工时，现锚成立，不建议改。

## §9.2 四处决断 · tech 路表态

1. **§3 原则 3（新两家用投影、Codex 维持生成）：成立。** 新两家正本天然是仓内可直读文件，投影使正本与分发件逐字节同体、漂移可 cmp 断言，且与已亲验的 project_opencode_command 模式同构；为 TS 插件造 heredoc 生成面只增转义与对齐成本，无收益。
2. **§4.2 分支 B 处置（CLI 不触发时照落＋记边界、不判 3.2 失败）：成立。** IDE/cloud 是文档确证的真实装载面，落地收益真实；失败判据应是无实测而宣称落地，设计以探活原始日志为判 B 前提，防线在位。
3. **§4.7 F1 样例 inert 形态：与 PM 裁断 D-4 一致，本审无异议。** 字段集已经本审对一手文档逐项确证为真可声明面，「核面＋定形态」以样例存档满足，不落空文。
4. **§4.8 承接 C 维持字面量：成立（本审重点驳验后仍成立）。** 驳验点有二，均不撼动主案：其一，check3 已以 version.txt 为真源核声明全等，相对化似有兜底——但 check3 与相对化后的 check4 将同源于同一真源，真源本身写错或 bump 半途时两者同盲，字面量是唯一独立见证；其二，相对化实现成本不高——但失败方向不对称（字面量失效为响亮假阳性、相对化失效为静默假阴性）对烟雾报警是决定性选型原则，且 P2 相撞事件被收口当场抓出是「响亮」一侧的实证。三锚（脚本注释零逻辑改、publish-ops 注记、收口正负控）把维护成本钉在既有分诊轮内，结论可照行。

## P2 注记（非关闭条件）

- **P2-1**：§2.3 钩子清单含 `chat.message`、`chat.params`、`permission.ask`，三者未出现在所引 plugins 页的钩子/事件清单内（属 SDK 类型层钩子名）；本设计的承重钩子（event、tool.execute.after、experimental.session.compacting、shell.env）均已经本审在该页确证，此三名仅 Q3 以否定形态引用 chat.message，不影响任何落点。建议实例回填时注记其出处层级。
- **P2-2**：§2.4「cloud agents 亦加载项目 hooks」未带原文的一处限定：sessionStart 在 cloud agents 面被明确列为不支持（其余本链用到的 postToolUse/preCompact 在 cloud 面可跑）。§4.2 的 sessionStart 对等主张是 IDE 面口径、不受此限；建议 §4.6 Cursor 实例填 cloud 行时带明此限定，免后人误读。
- **P2-3**：§4.2 分支 A 判据写「日志在盘且 canary 被复述」，而 OC-3 预写了第三态「CLI 触发但注入未达模型」（按 R-CU-2 变体处置、记录件写死所走支）——处置不悬空，但 §4.2 的分支分类未点名此态。Gate 3 判读 AC10 时以 OC-3 文本为准；建议首个增补机会在 §4.2 补点名一句。
- **P2-4**：§2.5 的 grokbox 三家版本值本审未能独立复测——评审窗口内隧道两次 Broken pipe 不可达（环境面，非设计面）。设计已以 OC-6 强制复测且明文以复测值覆盖 §2.5，本审对此不设条件；Gate 3 复核 transcript 版本字段时以 OC-6 记录件为据。
- **P2-5**：§2.3 称发布源 `.opencode/`「只有 commands/」——实盘另有 package.json/package-lock.json/node_modules；承重主张「无 plugins/」本审已确证，表述精度供增补时顺手对齐。

- 自报：正文 10766 B／sha256 `f64854bb752fe87a938c6886b8396f48c7d4a530c931d6fe24d00d7b9fac157a`（本行不计入正文，落盘后以 head -c 10766 复算）
