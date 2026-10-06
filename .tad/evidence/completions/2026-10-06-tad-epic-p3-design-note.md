# 设计完工说明 — Epic Phase 3「运行时适配补全」设计步（Alex）

**激活自报**：本席以 Alex（Solution Lead）身份执行本步。已加载薄壳 skill `~/workspace/skills/tad-alex/SKILL.md` 并按其激活协议进仓：$REPO＝`/home/hatch/workspace/yun-sync/TAD`。进仓后按序亲读原件——仓根 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md` 及命中条 `hook-contracts.md` 全文、规程 `.tad/tasks/handoff-creation.md`、判据 `.tad/gates/gate-canonical-checklist.md`；锚点原件——Epic Phase 3 节、票 `.tad/active/TICKET-20261006-epic-p3-runtime.md`、Phase 2 HANDOFF（体例正本）、首跑裁断、check4 裁定、step3f 首秀登记、件 2.6 评估、C5/F1 判断正本；源码与协议原件——`.codex/hooks.json`、`.tad/hooks/` 共享层（hook-envelope/common/startup-health/post-write-sync/askuser-capture/precompact）、tad.sh 投影族与行锚、publish-protocol step3f/step4/step5、publish-ops 章节面、state-surface-check.sh L123。一手外部文档（2026-10-06 抓取）：OpenCode 插件文档（opencode.ai/docs/plugins）、Cursor hooks 文档与 CLI 配置文档（cursor.com/docs/agent/hooks、/docs/cli/reference/configuration）。真机实测：ssh grokbox 三家版本（OpenCode 1.18.33／Cursor Agent 2026.10.01-e373342／Codex 0.159.3）；只读亲跑 minor detect-only（56 hits／31 文件）。纪律执行：仓外零写、git 只读、同名文件全绝对路径、能力断言全带出处或降为核查点。本步只做设计：未派 Gate 2、未实施。

---

## 交付件

**HANDOFF**：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md`
- 字节数：**86,126 B**；sha256：`2c77e39f42b65bd85887b66bb41b56c5172f2aacdf446a5ce046921e77035b64`（2026-10-06 落盘后复算）。
- 章节清单：Quality Chain Metadata／Gate 2（设计完整性自检＋高风险触发逐项核对＋装载点位表）／Handoff Checklist／§1 Task Overview／§2 基线锚（2.1 Codex 参照实现、2.2 共享 envelope 契约、2.3 OpenCode 能力面、2.4 Cursor 能力面、2.5 安装器与真机版本锚、2.6 承接件现状锚）／§3 总体设计（四原则＋点位映射总表）／§4 逐件设计（4.0 共用基座、4.1 件 3.1、4.2 件 3.2、4.3 件 3.3、4.4 承接 A、4.5 承接 B、4.6 件 3.4、4.7 件 3.5、4.8 承接 C、4.9 承接 D）／§5 设计决断与强制问题回应（Q1–Q7）／§6 Implementation Steps（Phase 0–4）／§7 写集总表（MODIFY 7／CREATE 17＋条件件 3／FORBIDDEN 点名）／§8 Testing／§9 AC 总述／§9.1 Spec Compliance Checklist（AC1–AC33，逐行验证方法＋证据指针）／§9.2 Expert Review Status／§10 Minor 升版收口预检（v3.2.0）／§11 Important Notes（CF-1–CF-7、待 PM 裁断 D-1–D-5、设计假设 HA-1–HA-3、红线复述）／§12 Sub-Agent 使用记录。

本说明：`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/completions/2026-10-06-tad-epic-p3-design-note.md`（本件）。

---

## 9 件设计结论摘要

1. **件 3.1（OpenCode hooks）**：薄垫片 TS 插件 `.opencode/plugins/tad-hooks.ts`——插件只做事件→envelope 合成→调既有 `.tad/hooks/*.sh`（行为单源；envelope 契约亲读确证本为多平台容忍设计）。session.created 走副作用对等（trace/session-state）；启动上下文注入 OpenCode 无对等面，登记残项 R-OC-1；compacting 面部分对等（注入 post-compact 提醒）；写后提醒经 tool.execute.after，注入支由 OC-4 实测定的启用/降级；提问捕获由 OC-1 工具名册实测定生死（残项 R-OC-2 备册）。分发照 tad.sh 既有单文件投影模式扩（preflight FATAL/project/cmp/rollback/自检），L519 known-gap 注记同批改写。
2. **件 3.2（Cursor hooks）**：官方 hooks 面确证丰富——sessionStart 可回 `additional_context`（与 Codex 对等）、postToolUse 同、preCompact 可直调既有快照脚本、failClosed 默认 false。落 `.cursor/hooks.json` 四条目＋两支转码垫片（`additionalContext`→`additional_context`），tad.sh 新增 Cursor 投影族。**唯一未决**：CLI 无头二进制是否触发项目 hooks 无文档明证——OC-2 探活定分支，分支 B（不触发）处置已预写：IDE/cloud 面照落＋CLI 边界记残项 R-CU-2，不判 3.2 失败（票面口径）。提问捕获无事件，残项 R-CU-1。
3. **件 3.3（真机基线）**：新建 `.tad/evidence/live-regression/`（现不存在，亲测）；三家同构捕获规程五步写成可照行（骨架仓经 tad.sh 实装→固定任务书全链会话→逐点位触发核验→6 字段成文→判读自洽），版本取 OC-6 复测值（infra 清单 Cursor 版本已陈旧，亲测发现）。与承接 A：共用骨架面与洁净捕获纪律，证据目录/判读正本/结论互不充数，已点名写死。
4. **承接 A（2.1 首个有效基线跑）**：针对首跑 INVALID 根因（fork 上下文污染）写死洁净新 spawn 捕获纪律（AC17 先于命中数判读）；冻结判分零改；整轮 PASS 才回填裁断销账行且 diff 仅限该行，非 PASS 不回填、报 PM。
5. **承接 B（2.6 试点）**：本链 Gate 3 前对自家变更集在骨架副本走 apply→rollback→哈希清单还原比对（排除面与 migration-engine 守卫同源）；四维回填落点与翻负判据逐维写死——(i) 回滚不可执行/比对面不可构造、(ii) 成本比 >20%、(iv) 不可分诊差异 ≥1 为自动翻负，(iii) 须 PM 点名；(ii) 分母（Gate 3 工时）以两段判读承接（待回填态→收口前终值）。
6. **件 3.4（C5 清单）**：六维声明清单正本落 patterns 面＋_index 登记（装载点位）；三家实例全回填（超 Epic「两平台」字面下限，已点名），空格零容忍、无面格带残项编号；首节写死「实例未立不许接线」义务。Known Gaps 逐项处置同批回写（关闭给指针、残项逐项点名、不许整节删）。
7. **件 3.5（F1 核查表）**：五通道逐行核——原生 spawn 无面（记边界）、Codex 固定沙箱口径（记指针）、OpenCode permission 面待 OC-5 实测、**Cursor CLI 项目 cli.json 的 permissions/approvalMode/sandbox 为一手文档确证的真可声明面**→落 inert 声明样例（templates 面、不随分发，启用权在各仓所有者/PM；直接生效属 D-4 裁断）。每行无证据指针即整件不判达成（不落空文的机器面）。
8. **承接 C（check4 审视）**：**结论：维持字面量＋换版注记维护，不改相对化。** 承重理由＝自指盲区（推导源与巡检真源同源，迁移窗口静默失效）＋失败方向不对称（字面量遗忘＝响亮假阳性、相对化出错＝静默假阴性；P2 相撞事件被收口当场抓出即实证）＋维护成本已被 minor 分诊机制吸收＋语义随版型判断非纯机械可推。落定三锚：脚本内注释（逻辑零改）、publish-ops §3.1 注记行、收口正负控 fixture 固化；字面量改值归 PM 收口 bump 步。
9. **承接 D（tag 步）**：成因已定位——step4「Push only」是合法选项即漏 tag 的结构面。改法两处：step4 对版本发版取消该旁路（余 Push + Tag／Abort＋来历注记）；step5 加 tag 在位断言（本地/远端/指向发版提交三要素，不成立即 RED），publish-ops §6 镜像一行。v3.2.0 收口为首跑（§10 点名）。

**minor 预检（§10）**：detect-only 基线 56 hits／31 文件，分类预估 L≈25／H·D≈28／F≈1–3，收口总量上限估 70；本版四处首次实地适用点已点名（step3f 三家 HARD、hop 随船＋在船断言、承接 D tag 断言首跑、check4 OLD_PAT 改值）。

## 待 PM 裁断项（HANDOFF §11，逐项附主案）

D-1 Epic 3.3「两平台」措辞与票/step3f 三家差（主案：按三家实施，PM 给 Epic 加注记；不阻塞 Gate 2，Gate 4 前须有口径在案）／D-2 R-OC-1 残项处置确认（主案：如实登记，不硬凑）／D-3 风险卡附卡与否（字面触发未命中，分发面属 PM 判断候选；主案：附卡，三条证伪式假设草案已备）／D-4 F1 样例生效形态（主案：inert 样例；备选：仅 TAD 仓自身启用一份 cli.json）／D-5 Phase 0 分支处置授权形态（主案：预写分支经 PM 过目无异议即执行；备选：负面分支逐项停步报裁）。

## Phase 0 核查点（HANDOFF §6，七项，未清账不进 Phase 1）

OC-1 OpenCode 工具名册实测（探针插件记录 tool 名集；定写类名册与 question 工具存否）／OC-2 Cursor CLI hooks 探活（定分支 A/B）／OC-3 Cursor sessionStart 注入达模型验证（canary 法，仅分支 A）／OC-4 OpenCode output 改写达模型验证（定写后注入支）／OC-5 OpenCode permission 面核实（文档＋骨架实测，定 F1 第 3 行）／OC-6 真机三家版本复测（transcript/实例版本源；infra 清单差异只记不改）／OC-7 preCompact envelope 兼容验（定直调/转接）。产出正本 `.tad/evidence/designs/2026-10-06-p3-phase0-probes.md`，七项逐项方法/原始输出指针/结论/分支影响。

## 本步边界

本步为设计步：已交付 HANDOFF 与本说明；未派 Gate 2、未做任何实施写、未动 git。下一程（HANDOFF §12）：PM 验盘 → Gate 2 双审 → 合并裁定（含 D-1–D-5）→（附卡时 Alex 先落风险卡）→ Blake 按 §6 实施。
