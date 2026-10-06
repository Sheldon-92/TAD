# Gate 3 SAFETY 路独立评审 — Epic Phase 3「运行时适配补全」（TASK-20261006-EPIC-P3-RUNTIME）

- **评审身份**：Blake 评审（独立会话，未参与本链设计与实施；与 CODE 路互不可见、未沟通）
- **判据原件**：`.tad/gates/gate-canonical-checklist.md` Gate 3 节；HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p3-runtime.md`（sha256 `2c77e39f…35b64`，复算与裁断引用全等）
- **被审件**：COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-epic-p3-runtime.md`（18,128 B／sha256 `7df2cc45…f15`，开审复算与任务书全等，含承接 A 续办追记）；PM 裁断两份（design-rulings D-1–D-5、three-escalations-ruling 三节）
- **评审方式**：纯只读（git 只读、盘面复算、grokbox 只读 ls）；未改任何被审文件

## 总判：**PASS**（P0＝0、P1＝0；P2 观察 4 条，不构成过门条件，交 PM 收口注记）

---

## 逐项结论（SAFETY 六面）

### ① 越界与纪律 — 成立

- **git 零写**：`git log` 尖仍为 Phase 2 链务提交 `7e407b7c`，本链零提交、零 tag、零 push 痕；`.tad/version.txt` sha256 `b2f44d3b…` 与 Phase 0 基线锚逐字全等（AC33），零升版动作与发版冻结口径一致。
- **变更集封口**：当前 `git status --porcelain` 共 81 行（M 15／D 12／?? 54）。M 15 逐项对位：基线既存 6（EPIC 件＋docs/pm 五件，Phase 0 记录归因 PM 链务）＋本链 9（§7 MODIFY 六件 tad.sh／AGENTS.md／patterns/_index.md／state-surface-check.sh／publish-protocol.md／publish-ops.md ＋裁断授权的三件 control.md）。D 12 全为 `.tad/active/handoffs/` 下已收口旧链件的删除（基线时点已在册、归因 PM 链务），无本链删除。?? 54 为 §7 CREATE 件与链务自产件（插件、hooks.json、两垫片、三 transcript、运行目录、试点/F1/清单/实例/样例、风险卡、COMPLETION、Gate 评审件等）。
- **§7 FORBIDDEN 零触碰**：共享脚本逻辑面零改——`startup-health.sh`／`post-write-sync.sh`／`hook-envelope.sh`／`common.sh`／`askuser-capture.sh`／`precompact-session-snapshot.sh` 均不在变更集；`state-surface-check.sh` 的 git diff 仅新增 5 行注释（OLD_PAT 上方维护注记，逻辑行零改）✔ 锚 1 形态断言成立。runner `.tad/scripts/regression-replay.sh` 与样本集判分锚不在变更集（control.md 三件属裁断授权的例外，见 ③）。`.gitignore`、SC3 面、下游真实仓均无写痕。
- **仓外写入面**：COMPLETION §6 ASM-3 列明的 grokbox 七个 p3 前缀目录经只读 `ls` 实存核对全在（`p3-skeleton-tad`、`p3-skeleton-pilot{,-before}`、`p3-src-tad`、`p3-src-final`、`p3-struct-target`、`p3-probe-logs`），全部位于 `/home/box/` 下、在同步根 `/home/box/云同步/`（下游真实仓所在）之外；探针日志面含负控/漂移/试点原始日志逐件在盘。仓外零生产写入成立（范围差细节见 P2-1）。

### ② 风险卡 ASM-1/2/3 自监复核 — 成立

- 风险卡在盘（`.tad/evidence/risk-cards/risk-TASK-20261006-EPIC-P3-RUNTIME.md`），三条 ASM 与 HANDOFF §11 草案逐字对位（假设句＋证伪信号＋动作三列齐）；其「设计步漏落、Blake 开工核对发现、PM 按草案补落」的来历在卡头与 COMPLETION §0 双向留痕，无事后粉饰。
- **ASM-1（fail-open）负控证据成立**：Phase 1 验证件 §6——骨架内令 `startup-health.sh` 与 `post-write-sync.sh` 同时不可执行后，OpenCode 与 Cursor 会话均 exit 0 完成且写文件成功，原始日志 `p1-negctl-{opencode,cursor}.log` 在 grokbox 探针面实存；垫片侧故障三态（垃圾/空/exit 1）恒 `{}`＋exit 0（验证件 §2）。证伪信号未出现，自监结论与证据对位。
- **ASM-2（投影非破坏）**：投影 fixture 12/12 含分歧负控（preflight 非零退出且本地件逐字未动）与漂移红控（exit 1＋FATAL＋漂移文件未动，验证件 §1/§7）；试点 rollback 后 16 路径比对面与 before 清单逐行全等（试点 before/applied/after 三份清单在探针面实存）。证伪信号未出现。
- **ASM-3**：见 ① 与 P2-1——实质边界（隔离副本面、零下游/生产写）守住。

### ③ 承接 A 对照替换的程序正当性 — 成立

- **授权在先**：时序证据完整——首轮执行者在 scores.md 执行者附注中明记「样本集属写集外禁改面、本席无权径行替换」，按 §4.4 第 4 步不回填销账、呈报 PM；PM 裁断（three-escalations-ruling 第一节）其后授权替换并写死三项执行要求；续办追记在裁断后执行。无先行后奏、无临场自创分支（与 D-5 预授权边界一致：替换不在预写分支内，故走了停步→裁断→续办的正道）。
- **留痕三要素齐备**：三件新 `control.md` 文件头逐件在盘核对——本轮 run id `20261006-first-valid-baseline`、裁断路径、被替代件出处（首跑 fork 污染捕获＋存档路径）三要素齐；正文为洁净对照逐字移入。
- **被替代件存档未动**：`.tad/evidence/regression-runs/20261006-first-run/` 五件在盘（污染捕获件、scores、outputs 三件），目录与文件时间戳停在本日清晨的首跑时点，早于午间替换作业，未被续办触碰。
- **无凑 PASS 迹象**：复评用同一 runner（`regression-replay.sh score`，判分锚在机械值块中可见且未动：min 3／must_not 0／control max 1）；被测侧第一试「激活提示过弱」判别命中不足的事实连同其产物目录 `outputs-attempt1-framing-weak/` 一并留存未删，第二试改用完整激活形态后 5/7/6——试错过程全程可见，非选择性呈报。复评机械值（5/7/6、must_not 全 0、对照 0/1/0、整轮 PASS）与销账行（首跑裁断件尾部新增一行，含运行目录指针＋verdict＋命中数；该文件现 sha256 `0ca68988…` 与追记自报全等）逐值对位；替换前后 sha 对照（旧 `fb98173d/288213ca/29b21f08`→新 `ec5d4bdf/227e1182/f49c13c6`）与盘上新件复算全等（字节 2,304／1,448／1,896 亦合）。

### ④ Codex 基线 FAIL 归因 — 成立

- 一手原文在盘：`live-regression/raw/p2-codex-session.log` 逐字含厂商报文 “You’ve hit your usage limit … try again at Oct 10th, 2026 10:24 AM”，且日志形态自证失败点在首次模型调用（工具使用之前 exit），workdir 为骨架仓。transcript 第 5 字段的逐点位零触发核算是对此正向失败证据的负向对账（运行后查盘无 trace/无产物），非以日志空白充证据。
- 判读成立：失败归属厂商账号配额、非机制失败、非新残项，与 PM 裁断第二节一致；AC16「部分成立」如实记、未凑三家全 PASS。
- **挂账登记如实**：AGENTS.md Known Gaps P4 行已回写 Codex FAIL 与 2026-10-10 后补跑口径；COMPLETION §5-① 明列待补跑与回填义务；step3f 自 v3.2.0 起三家 HARD 的判读前提（Codex 基线欠账）在同一行内点名，未被 HARD 表述掩盖。

### ⑤ F1 样例 inert 性与 C5 Known Gaps 回写 — 成立

- 两样例实读：`cursor-cli.json`（approvalMode=allowlist；allow＝Read/Write 工作区面＋git 只读与 hooks 的 Shell 面；deny＝`rm -rf`、`git push`）与 `opencode-permission.json`（bash 默认 ask、只读命令 allow、rm deny、external_directory/webfetch ask）——均为策略形态示例值，无任何真实凭据、令牌或账户标识；字段集与 F1 核查表第 3/4 行的文档确证集对位，逐值理由在核查表行内。
- **inert 机器面**：`grep` 复算 tad.sh 及 `.tad/hooks/` 对 `runtime-permission-examples` 引用 **0 命中**；两件仅存 `.tad/templates/` 面，仓内无 `.cursor/cli.json` 启用件（D-4 主案未被实施步僭越）。
- 核查表五行逐行带证据指针（判断正本行号／官方 URL＋抓取日期／OC-5 实测指针）；两行「无面」定案依据为正向出处（判断正本结论＋固定口径拍板记录），非查无此面式的缺失推断。
- **AGENTS.md 回写 diff 仅两行**：git diff 复算——Known Gaps 节恰两行被替换（P2 行、P4 行），关闭项写落形态＋指针、残项 R-OC-1/R-OC-2/R-CU-1 逐项点名归属，无整段删除，版本标记行不在 diff 内。

### ⑥ 负证据纪律 — 成立

全链承重否定结论逐一核源，无以日志空白/零命中充能力证据者：
- R-OC-2（无头面无 question 工具）：探针事件名册＋模型被明确要求使用后自报 `NO_QUESTION_TOOL` 的正向实测，非日志缺失推断；
- 分支 A（CLI 触发 hooks）：日志型垫片实触发落盘＋canary 复述（OC-2/OC-3 正向证据）；
- `failClosed` 零命中、「Push only」零命中属 HANDOFF 预先定义的 **结构断言型** AC（command 法），核的是文件形态而非能力，口径合法；
- Codex 零触发的盘后核算是对已证失败的对账（见 ④），方向正确。

---

## Findings（分级）

**P0**：无。
**P1**：无。

**P2-1（ASM-3 字面口径与 Phase 0 闭口断言的范围差）**：Phase 0 记录 §0.1 断言「本链全部真机运行写面封闭于 `p3-skeleton-tad` 与 `p3-probe-logs/` 之内」，实际运行另用了试点与结构验证的同级隔离副本目录（`p3-skeleton-pilot{,-before}`、`p3-src-tad`、`p3-src-final`、`p3-struct-target`）。COMPLETION §6 已如实全列，七目录均在同步根之外、零下游/生产写入，ASM-3 的实质判据（写面封闭于隔离副本面）成立；但 §0.1 断言字面窄于 §4.0/§4.5 设计本有的骨架面范围，属断言措辞与执行面的对位瑕疵。建议 PM 收口时在链务记录注记一句即可，不返工。

**P2-2（基线状态快照只存执行者 /tmp，行级复核不可重演）**：Phase 0 的 `git status` 61 行快照存于执行者 /tmp 暂存（`/tmp/p3-blake-Dqnr3y/`），评审时已不存在（前任暂存丢失、本席重采的经过已在 Phase 0 记录 §0 如实留痕）；承重锚（HEAD＋8 件 sha256）已落盘面记录、可复算，故封口结论不受影响。但 Phase 0 散文计数「D 13」与当前盘面 12 件 D 无法逐行对账（12 件全属基线归因的 PM 链务删除类别，无一为本链文件）。建议后续链把 status 快照直接落证据记录件内文，勿只存 /tmp。

**P2-3（裁断件内的存档路径简写与盘面不一致）**：three-escalations-ruling 第一节将存档位置写作 `eval-runs/2026-10-06-first-run/`，盘面实址为 `.tad/evidence/regression-runs/20261006-first-run/`；执行方在 control.md 文件头与追记中均用了盘面真址，程序与留痕不受影响。仅裁断件字面待 PM 收口时顺手勘正，不阻门。

**P2-4（替换前机械 scores 原件被复评覆写）**：首轮机械判读（INVALID、对照 4/5/3）的 scores.md 原件在续办复评时被 runner 重写，其数值仅以散文形态保全于执行者附注（覆写与逐字回附的过程已在 scores.md 续办附注中明示），且与 COMPLETION §1/§3/§5 三处记载互洽。证据链完整但强度低一档；后续同型续办建议先把旧 scores 另存副本再复评。

## 自报数字复算（抽重 SAFETY 相关面）

COMPLETION §4 自报与本席复算逐值全等：tad.sh `947a8614…`、tad-hooks.ts `7c165c01…`、hooks.json `c76af436…`、两垫片 `dd7bd299…`／`77fb6186…`、两样例 `833f43eb…`／`de56c5cd…`、AGENTS.md `4264d739…`、三件 control.md（见 ③）、scores.md 4,449 B／`fef5487b…`、首跑裁断件 `0ca68988…`、HANDOFF/COMPLETION 本体锚（见头部）。无自报与盘上不符行，证据否决条款不触发。

## 结论

SAFETY 路 **PASS**。越界与纪律、ASM 自监、承接 A 程序正当性、Codex FAIL 归因与挂账、F1 inert 与 Known Gaps 定点回写、负证据纪律六面全部成立；四条 P2 均为记录形态的可改进项，交 PM 收口注记，不构成 Gate 3 过门条件。
