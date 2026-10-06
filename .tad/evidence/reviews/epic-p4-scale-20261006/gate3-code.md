# Gate 3 CODE 路独立评审 — Epic Phase 4「体量与知识复产」（TASK-20261006-EPIC-P4-SCALE）

- 评审者：Blake 评审身份（独立会话，未参与本链设计与实施；与 SAFETY 路互不可见）。
- 对象：HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-epic-p4-scale.md`＋增补 SUPPLEMENT-1（B1–B5）× COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-epic-p4-scale.md`（落盘复算 31,324 B／sha256 `69d41183…`，与派发锚全等）＋ PM 裁断三份（design-rulings／gate2-merged-ruling／dp01-ruling）＋风险卡。
- 方法：§9.1 逐行**自跑复现**（不采信自报）：真仓只读命令、隔离骨架 fixture（生成器 LC_ALL=C 干跑、check7 置旧向、tad.sh 刷新正控＋缺生成器负控两跑全程实跑）、计数脚本双向判读、集合 comm 比对、git 谱系断言。隔离面跑后已清除，评审零仓写（本件除外）。

## 总判：**CONDITIONAL**

承重面（删除封口、回退验证、谱系、证据零触、生成器修复、接线、计数双向）全部独立复现成立。条件仅两项，均为判读/更正级、非实施返工：
- **C-1（AC27 字面项）**：`release-verify` 三 mode 非 0 经本席逐项复跑确认与被审方归因逐字同因（见 AC27 行），且均非本链引入。请 PM 以裁定明示「按归因判读成立」或将三项作为具名残留带入 Epic 总收口，不许静默当全绿。
- **C-2（AC28 自报数值更正）**：COMPLETION 两处记 `origin/main 仍 526f1df3` 与盘面不符（实测远端尖 `7e407b7c`，且设计锚 §2.6 亦记此值）。AC28 判据实质（版本冻结、无 tag、本链提交未 push）独立复核成立，但错误数值须以可见追记更正（沿本链追记惯例），不得留错值入档。

## AC 逐条结论（AC1–AC28＋AC12B）

| # | 结论 | 本席复现值（证据指针） |
|---|---|---|
| AC1 | PASS | `size-inventory.md` 在盘、顶层逐项齐、grep「待定」0 行；锚值抽核全等（HEAD/pack 56.01→gc 后 56.02、worktree 141/30/30/26、log 6 行 4,530 B 在 Phase 0 时点口径成立） |
| AC2 | PASS | 差集件逐件复数：NC 三件各 1 行（植入点全命中、判 (b)）；三子集目录 only-tip 28/28/27、only-wt 0、sha-diff 0；candidate only-wt **11,275**、only-tip 27、sha-diff **9**——与比对表逐值全等 |
| AC3 | PASS | 删除集恰为 dp01 裁定 (a′) 三目录：`.worktrees/` 现仅余 `tad-yolo2-candidate`（141M，test -d 在盘）；三删目录均不存在。字面 (a) 级经 PM 裁定立 (a′)  supersede，链路在案 |
| AC4 | PASS | 基线清单留盘复算：**20,480 行／sha256 `83491423…`** 与自报全等；§C 回退验证表 tip 独有 28/28/27 与 AC2 差集件逐值互证；在盘缺于 tip 0、sha 不一致 0。首轮假 PASS 已由实施者当场作废并留痕，终值以重跑为准——处置合规 |
| AC5 | PASS | gc 后复测：in-pack **27,302**、size-pack **56.02 MiB**、garbage **0**（与 §C 全等）；loose 现 26 件/164 KiB 系 gc 后并行链两笔提交的新增对象，非 gc 未净；总量 `du -sh .`＝**440M** 与 §C 终值全等；归因算术闭合（530−86−7＋3浮动＝440；对 R1 基线 521M 净降 81M），无未归因差额 |
| AC6 | PASS | 删除集为 `.worktrees/` 三目录，与 `.tad/evidence/**`、`.tad/archive/**` 交集为空；maintainer-evidence 尖实测仍 `ea54399f`（`git rev-parse` 原值） |
| AC7 | PASS | `git status --porcelain` 全集无 supabase/、experiments/、.tad/spike-v3/、codex-tad-bundle/、tad-work/ 任一路径；五处仅盘点表有决议行与引用扫描结论 |
| AC8 | PASS | `git merge-base --is-ancestor 68593e82 main` exit 0；`ea54399f` 为 maintainer-evidence 尖本身（祖先断言 exit 0）；无 force 痕（谱系单向生长至 `5c13a9d9`） |
| AC9 | PASS（附注） | 删除窗口 8→8 的记录在盘点件 §C；链末复验总计数 **5**、工作树面（`.git` 外）**0**——与 §C 后记归因（gc pack-refs 移除 `.git/refs/` 内 3 件冻结副本）逐值吻合。判据时点（删除动作前后）相等成立，后续 gc 连带已如实补记，不构成矛盾 |
| AC10 | PASS | 本席隔离骨架以仓内生成器原件（sha `6fcea745…` 与验证件自报全等）`LC_ALL=C` 干跑：产物 UTF-8 严格解码 exit 0、NEL(U+0085)＝0；真仓产物同值（27,432 B、NEL 0） |
| AC11 | PASS（照 B2 修订口径） | 本席全量比对：principles 16 条标题与产物 §1 行集**去日期后缀后集合全等（16/16）**（真仓产物与本席骨架产物双验）；Deny-List 行验标题段、AI/Human 行验标题＋摘要段，两损段均净 |
| AC12 | PASS | 在盘索引 Generated＝2026-10-06（298 行）；本席实跑 state-surface：`INFO check7: brain-index generated 2026-10-06, age 0d`、无 WARN、全检 PASS exit 0 |
| AC12B | PASS | 本席隔离副本回填 Generated 2026-09-20 实跑：输出 `WARN check7: brain-index age 16d exceeds 14d (advisory; not counted as FAIL)`，与自报逐字一致；新鲜/置旧双向齐备 |
| AC13 | PASS | 真仓产物含 runtime-adapter-instance 三行＋EPIC-20261006 行（grep 实测）；§1 行数 16 ＝ principles.md `###` 计数 16（本席复算） |
| AC14 | PASS | 接线 diff 本席以 `f9f397bc` blob 为基线复算：基线 sha `459b9fc9…`、接线后 `0eaa2d18…` 与自报双全等；diff 恰 **+4 行一处**（注释 2＋调用 1＋空行 1，upgrade 分支 copy 之后）；调用点定义 L1409／初装 L3225／刷新 L3324 与自报逐行全等。**刷新正控本席全程实跑复现**：老装机骨架（3.0.2、无索引、哨兵件）刷新 exit 0，生成行在日志中位于框架同步＋自检之后、迁移引擎之前（新调用点实火），产物 120 行、Generated 当日、解码 OK、NEL 0，哨兵完好，自检行 `91 derived paths + 23 top-level files` 与自报逐字一致 |
| AC15 | PASS | 缺生成器负控本席实跑复现：exit 0、刷新完成至 3.1.0、WARN 原文与自报逐字一致（`brain-index generator not present in target tree … was not generated`）、索引未生成——fail-open 成立。初装回归依 §F 记录＋本席正控中自检/生成面同源判读，不重复全跑（见 findings F-3 注记） |
| AC16 | PASS | publish-protocol step3g 在盘：生成命令＋check7 回读（age 0d 无 WARN）＋触发集三项（发版收口／自查轮次／知识层变更链收口）＋责任面（当链 PM）齐备，`blocking: true` |
| AC17 | PASS | COMPLETION 边界节明示下游刷新执行与逐席验证归 GM；本链实际变更集（porcelain 全集）无任何下游仓路径 |
| AC18 | PASS | 本席以计数脚本对 log 前 6 行隔离复算：total 6／usage 5／chains 2／distinct **28**、NOT MET (6/50, 2/5)，与盘点件及设计锚 §2.3 逐值全等；四类计数（verdict 2／设计 3／COMPLETION 0／PM 裁定 3）与盘点件 §C 一致 |
| AC19 | PASS（双向自跑） | 现行 log（7 行，含 dogfood）输出 NOT MET 且与 COMPLETION 尾注复算值一致（total 7／usage 6／chains 3）；本席自造合成 fixture（50 行＋单件 PM 裁定类被 5 链引）输出 `TRIGGER: MET (lines 50/50, max cross-chain 5/5)`——双向判读均成立 |
| AC20 | PASS | `d35-usage-inventory.md` §E 直读重议清单＝空集，唯一依据为 §B–§D 计数，无印象列件 |
| AC21 | PASS | 模板 `.tad/templates/completion-report.md:215` 含 `## 📚 Knowledge Usage` 节（字段照 revival §4.5＋JSON 示例行＋空数组纪律）；`.tad/tasks/evidence-collection.md:289` 收口 append 动作行在盘（append-only 明示＋计数脚本指针） |
| AC22 | PASS | log 实测 **7 行全行 JSON 可解析**；末行 chain＝`TASK-20261006-EPIC-P4-SCALE`、step＝`Phase4-closeout`、ts＝`2026-10-06T13:46:41Z`，与 COMPLETION 尾注逐值全等 |
| AC23 | PASS（照 B4 订正口径） | patterns 集合：盘上文件 16 ＝ 索引行集 16（comm 双向差集为空；索引首行 Format 示例中的 `filename.md` 为格式说明、非条目，本席已剔除后比对）；3 新增行 hook 本席抽读三件原件标题＋首节六维声明表逐行对位——Codex（0.159.3／三点位／限额 exit 1）、Cursor（--trust／hooks.json 实测触发／R-CU-1）、OpenCode（1.18.33／tad-hooks.ts 四点位／R-OC-1、R-OC-2）均与各件声明内容相符 |
| AC24 | PASS | incidents 对账：在盘 25 件全在册（仅盘面 0）；仅索引 1 件 `2026-05/yq-normalizes-once-idempotent.md` 在索引内以删除线＋GRADUATED 注记留痕（本席原件抽读确认）；`_index.md` 末尾对账验证行含日期与双向差集计数，与对账表同值 |
| AC25 | PASS | `epic-closeout-checklist.md` 在盘：发版 9 步逐项含命令/判据/落点且与 HANDOFF §10 骨架一致（另含步 8 接线前置核对，属增益非偏离）；版本终值建议 v3.2.0＋理由、CF-7 与 driftcheck (b) 11 件去向建议各成段 |
| AC26 | PASS（附注） | 本席复跑正口径命令得 **65 hits／35 文件**；与清单件基线 59／34 的差额 **+6 hits／+1 文件恰为 `.tad/hooks/lib/tad-backup-test.sh`**——系并行 tadsh-backup-fix 链在本链测量后新建并提交（`f9f397bc`）的 tracked 文件，59＋6＝65、34＋1＝35 严格闭合。基线在测量时点成立、「可复跑」判据实质成立；注记供 PM 收口分诊时以 65／35 为新起点（清单件步 1 本就要求以基线为起点逐项处置） |
| AC27 | **CONDITIONAL**（见 C-1） | 写集封口成立：porcelain 变更集 ⊆ §7 写集 ∪ 链务自产件（M 8 件＝7 写集件＋tad.sh 接线；?? 为计数脚本、P4 票/HANDOFF、本门开跑卡）；全部新/改 `.sh` 本席 `bash -n` 复验通过（brain-index-gen.sh／knowledge-usage-count.sh／tad.sh）；tad.sh 自检段经本席两跑实装复现 exit 0。release-verify 逐 mode 本席复跑：version／version-sweep／state-surface exit 0；freshness exit 1（codex freshness 台账 stale 64 天、next_review 2026-09-02 过期——长存开放项、本链零触）、migration exit 1（`MISSING HOP 3.1.0-to-3.1.0.yaml`——发版时点构造性形态）、installer-destructive-guard exit 1（重复 id `rollback-opencode-rmdir-root`／`tad-backup-retention`——本席以 diff 证明 P4 对 tad.sh 仅 +4 行接线，两 id 不在接线 hunk 内、属既存且为并行链辖区）——三项与被审方归因逐项同因、均非本链引入。唯 AC 字面「release-verify exit 0」未达，须 PM 裁定判读（C-1） |
| AC28 | PASS（附 C-2 更正条件） | `.tad/version.txt`＝`3.1.0` 且 git diff 为空；无 v3.2.0 tag（`git tag -l 'v3.2*'` 空）；远端 main＝`7e407b7c`（P2 链务尖、本链谱系祖先），本链及并行链本地提交（`68593e82`…`5c13a9d9`）均未 push——冻结实质成立。唯 COMPLETION 自报的远端尖数值 `526f1df3` 错误（见 findings F-2），须追记更正 |

## Canonical Gate 3 七项

- 产出完整性 ✅：已实施范围（Phase 0/1/3＋Phase 2 续行＋步 4 续做）全落地，全部 AC 有终值；两处曾挂起项均经裁定/串行序正规续行，非遗漏。
- §9.1 逐行 ✅（AC27 字面项与 AC28 数值更正以条件 C-1/C-2 挂账）。
- 证据存在性 ✅：§7 证据件组 6 件＋差集件 13 件＋COMPLETION＋Ralph 记录全在盘。
- 证据可重放（advisory）✅：本席重放生成器干跑、check7 双向、计数双向、tad.sh 两跑、release-verify 六 mode，结果与在盘记录逐值一致（唯一变量为索引 Generated 时间戳，属预期）。
- Git commit：NONE（按链例归 PM 收口），COMPLETION 已记明 ✅。
- Knowledge Assessment ✅：非空，两项新发现（同步通道敏感名过滤／后台 exec 落盘不可靠）均有 probed 级证据指针；distill 归 Gate 4 的分工声明在盘。
- Provenance ✅：非空，逐件生成法在册。

## Findings（分级）

- **F-1（P1 → 条件 C-1）**：AC27 字面判据未达（release-verify 三 mode 非 0），归因全部成立且非本链引入。处置选项归 PM：裁定按归因判读成立，或将三项具名带入 Epic 总收口清单。不构成实施返工。
- **F-2（P2 → 条件 C-2）**：COMPLETION 自报数值错误——AC28 行与 Evidence Checklist 两处 `origin/main 仍 526f1df3`，实测远端尖为 `7e407b7c`（与本链设计锚 §2.6 自相矛盾）。判据实质不受影响（未 push 的对象是本链提交、复核成立），但按证据纪律须可见追记更正。
- **F-3（P3 注记）**：AC15 初装回归一跑本席未重复全跑（依 §F 在盘记录＋同一 tad.sh 的本席两跑实证旁证判读）；如 Gate 4 要求全项重放，可在骨架上补跑初装一跑，预计与 §F 记录一致。
- **F-4（P3 注记）**：AC26 基线已被并行链提交推进至 65 hits／35 文件（差额归因闭合）；PM 总收口分诊请以复跑值为起点，避免按 59 销账时多出 6 件无主。

## 风险卡 ASM 复核

- ASM-1：未被证伪——删除三目录经 Phase 0 比对＋删除前 AC4 复行双证在盘内容零唯一字节；字面分级与安全实质的冲突经停步点由 PM 立 (a′) 裁断，未径行升 (a)。
- ASM-2：未被证伪——AC6/AC8 本席复核成立，证据面零触、谱系完整。
- ASM-3：未被证伪——接线 diff 恰一处调用点＋4 行（本席以修复后 blob 为基线复算），初装/刷新/负控三跑行为与自报一致（本席复现两跑）。

**评审结论重申：CONDITIONAL（条件 C-1、C-2 均为 PM 判读/更正级；核销后本路可转 PASS，无实施返工项）。**

**自报**：正文（本行之前）13,681 B／sha256 `3fbcdfcbd74848343790edab09e662427c2d620308b0136d9eecd0718524a2c0`；全件字节数以落盘复算为准。
