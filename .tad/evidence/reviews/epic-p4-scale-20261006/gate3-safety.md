# Gate 3 SAFETY 路独立评审 — Epic Phase 4「体量与知识复产」（TASK-20261006-EPIC-P4-SCALE）

- 评审者：Blake 评审身份（独立会话，未参与本链设计与实施；与 CODE 路互不可见）
- 对象：HANDOFF-2026-10-06-epic-p4-scale（49,664 B）＋SUPPLEMENT-1（7,883 B）× COMPLETION-2026-10-06-epic-p4-scale.md（31,324 B／sha256 `69d41183…`，评审开工复算全等）＋PM 裁断（设计五项、Gate 2 合并裁定、D-P0-1）＋风险卡 risk-TASK-20261006-EPIC-P4-SCALE（ASM-1/2/3）
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 3 节＋`.tad/tasks/evidence-collection.md` 负证据纪律
- 纪律：全程只读（git 只读命令、盘面复算、隔离面 /tmp 重演算后已清除）

## 总判：PASS

无 P0/P1。删除安全性有独立重演算背书；ASM-1/2/3 三条证伪信号均未触发；纪律面（版本冻结、git 写归属、append-only）逐项实测成立。下列 P2×2、P3×1 为记录与归口事项，不构成过门条件，但请 Gate 4/PM 在收口时显式认领 P2-1。

## 逐项结论（SAFETY 五重点）

### ① 删除安全性终审（(a′) 三目录）——成立

- **证据链完整**：Phase 0 基线清单 `worktree-baseline-manifest.txt` 在盘，评审复算 **20,480 行／sha256 `83491423…`**，与 COMPLETION、比对件、盘点件四处引值全等。四目录在盘计数（2,367／2,387／2,233／13,493）求和恰 20,480，清单覆盖无缺口。
- **比对方法对「在盘唯一字节」的覆盖充分**：方法＝在盘全量清单 vs `git archive` 尖端物化清单三向比对（extra／missing／sha_diff）。删除可销毁的只有在盘字节；在盘字节的唯一性恰由 extra＝0 ∧ sha_diff＝0 完全刻画（每个在盘文件都有一份逐字节相同的副本活在分支尖树内）。missing 向是副本不完整、不是删除损失，与安全性无关。**删除安全只依赖实测面，不依赖「同步过滤」解释**——该解释在比对件 §C 标注为 probed（正控齐备：同名文件在主树与分支树 `cat-file -e` 命中、四副本内 find 0 命中），其真伪不影响删除结论，仅影响 (a) 级字面形态，处置路径（停步→PM 立 (a′)）正确。
- **独立重演算**：评审自取最小目录 `tad-yolo2-scope-proof` 重演 AC4——以现行分支尖 `69194cd1` 重新物化、与基线清单对应段逐行比对：baseline-only＝1（`.git` 指针文件）、tip-only＝27、**sha-diff＝0**，与盘点件 §C 回退验证表逐值全等。三分支尖评审时点复核未移（`f7e99dc0`／`f235e377`／`69194cd1`，与 AC4 记录一致）→ AC4 的「删除前复行」结论可重放、非一次性自报。
- **时序**：§C 回退验证节记于删除前、删除窗口 2026-10-06T13:54:01Z–13:54:19Z 与静默点声明在盘；删除集恰为裁定三行，(b) 级 candidate 删除后仍在盘（评审实测 `.worktrees/` 仅余 candidate），AC3 删除负控成立。
- **诚信信号（正向）**：AC4 首轮脚本因清单分隔形态（哈希后 3 空格）解析落空得「空集假 PASS」，执行方当场作废重跑并在两处留痕——假 PASS 未被用作依据。此为本链证据可信度的加分项。
- 残余风险（已批准、非缺陷）：HANDOFF §9.2(a) 自述的「对端未达新写入」残窗，经静默点＋PM 确认＋基线清单三闸缓解，Gate 2 与 D-P0-1 两级明知接受。删除对象为 Mac 侧 worktree 的同步副本、内容全量在 ref，定性成立。

### ② ASM-2 证据面零触碰——成立（附 P2-1）

- 删除集（三 worktree 目录）与写集（评审实测 `git status --porcelain`：§7 七件 MODIFY/REGENERATE＋计数脚本 CREATE＋tad.sh 接线＋链务件）与 `.tad/evidence/**`、`.tad/archive/**` 既存件交集为空；证据面内仅本链 CREATE 件组与 log 一行 append。
- maintainer-evidence 尖评审实测仍为 `ea54399f`（全值 `ea54399fc40680ee13ccabff5fd441fc9d48c9bc`），ASM-2 祖先断言以「尖本身未动」强形态成立；main 谱系含 `68593e82`（`merge-base --is-ancestor` exit 0），零 ref 重写。
- **gc 连带移除 3 件 `.git/refs/` 内冲突副本的定性**：记录如实——COMPLETION 追记 AC9 后记与盘点件 §C 后记两处均明记「删除判据时点 8→8、其后 gc pack-refs 连带后末复验 5、工作树面全程 0」，归因（gc 标准 ref 打包）与时序不混入删除账。评审盘面复核：现存 5 件全在 `.git/logs/refs/remotes/origin/`（含既存冻结类），与记录逐件相符。定性判读见 P2-1。

### ③ ASM-3 接线回归面——成立

- 评审亲取 `git diff tad.sh`：**恰一处 hunk、+4 行**（注释 2 行＋`generate_target_brain_index` 调用＋空行），位于 upgrade 分支 `copy_framework_files` 之后、迁移引擎之前；初装分支与既有刷新语义零改动，未新增守卫代码（守卫在函数本体内）。与验证件 §F 记行（定义 L1409／初装 L3225／刷新 L3324、接线后 sha `0eaa2d18…`）逐项相符；评审复算 tad.sh sha 前缀 `0eaa2d18d6046cfd` 全等。
- 行为不变面有 fixture 三跑背书（刷新正控实火、初装不回归、缺生成器负控 fail-open 只 WARN），ASM-3 证伪信号（初装失败／自检非 0／diff 超一处）均未出现；自检三跑 exit 0 在盘。

### ④ 纪律面——成立

- **版本冻结**：`.tad/version.txt` 评审实测仍 `3.1.0` 且不在改动集；tag 面最新仍 v3.1.0（无 v3.2.0）；本链无 push 动作（链后两笔在盘提交 `f9f397bc`／`5c13a9d9` 经 log 归属为备份修复链与 PM 收口，非本链）。
- **git 写归属**：本链 git 写仅 `git gc` 一处（写集明示授权）；gc 后 count-objects 与 AC5 终值相符（in-pack 27,302／size-pack 56.02 MiB／garbage 0；评审时点 loose 26 件为其后两笔他链提交的新生对象，可归因、非本链动作）。
- **usage log append-only**：评审逐行解析 7 行全 JSON 合法；前 6 行 chain/ts 与设计锚 §2.3 逐值相符（未改写），新增第 7 行 chain＝TASK-20261006-EPIC-P4-SCALE、step＝Phase4-closeout、ts＝2026-10-06T13:46:41Z，与 COMPLETION 尾注互证。dogfood 一行合规（字段形态照新模板节）。
- **停步纪律**：Phase 2 未抢跑（等 D-P0-1）、步 4 未抢跑（等 B5 串行序满足且开工复算新锚 `459b9fc9…` 全等后才动），两处均有裁定/增补凭据，非自判放行。

### ⑤ 负证据纪律——成立

- 本链安全结论无一以「零命中/日志空白」为唯一依据：删除安全＝正向清单比对＋负控判别力自证（植入三差异逐件命中）＋评审重演算；零触碰＝porcelain 变更集与分支尖的正向读数；冲突计数＝同口径 find 前后实测。
- 唯一推断性结论「同步通道名称过滤」按纪律标注 probed 并附正控，未被用作删除依据（见 ①）——分工正确。
- 首轮后台 exec 产物丢失与一伪影读数（loose 4.23 MiB）均在盘点件 §A 与 Reflexion 中显式作废、以前台复算值替换，未让作废读数进入任何判据——负证据/坏证据处置合规。

## Findings

| 级别 | # | 内容 | 处置建议 |
|---|---|---|---|
| P2 | 1 | **gc 连带移除 `.git/refs/` 内 3 件 `.sync-conflict` 冻结副本**：系授权动作 `git gc` 的 pack-refs 标准行为连带、非删除/合并决定，且双处如实记录、归因明确；被移除者为远端跟踪 ref 的同步冲突副本（活内容可由远端 ref 再生）、F4 类冻结件（`.git/logs/` 面 5 件）评审实测仍全数在盘。但其形态上触及「冲突副本冻结待裁」的常设纪律面，链内记录属事后补记而非事前预见。 | 请 PM 在 Gate 4/收口时显式认领此连带为已接受（或裁定异议），并在后续含 gc 的链的设计中把「gc 将打包 .git/refs 内 loose 件」列入预检一行。不阻本门。 |
| P2 | 2 | **AC9 判读口径注记**：AC9 字面判据「删除执行前后计数相等」在删除时点成立（8→8），但链末总计数为 5——COMPLETION 与盘点件均已分时点如实记明，无矛盾读数风险；仅提示 Gate 4 复算时须按「删除时点 8→8、gc 后 5」两段读，勿以链末单值对 AC9 字面判 FAIL。 | Gate 4 按两段口径判读即可，无需返工。 |
| P3 | 1 | 计数口径小注：比对件 §B「在盘文件数」含 `.git` 指针件（四目录求和＝清单 20,480），盘点件 §C 回退验证表「基线段行数」不含指针（2,366／2,386／2,232）——两口径各自自洽、评审已对平，但两件未互注口径差，后续读者可能误读为 1 件出入。 | 收口时任选一处补一行口径注即可，不阻本门。 |

## Canonical Gate 3 对照（SAFETY 相关行）

- §9.1 Spec Compliance：SAFETY 辖区行 AC2–AC9 逐行有盘上证据指针且与评审复算相符；被审方自报与评审重算不符行＝**无**（基线清单 sha/行数、tad.sh sha、分支尖、log 行、count-objects 五组关键自报值经评审独立复算全等，证据否决条款未触发）。
- Evidence files exist：件组六件＋差集 13 件＋Ralph 记录在盘。
- Git commit done：本链按写死纪律实施不 commit（NONE 合规，归 PM 收口），非缺项。
- Knowledge Assessment：非空，两项新发现均 probed 级落盘，distill 归口标注明确。

**评审自报**：本件字节数与 sha256 以落盘复算为准（见回执）。
