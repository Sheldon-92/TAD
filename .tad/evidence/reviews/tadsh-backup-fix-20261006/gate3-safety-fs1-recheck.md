# Gate 3 SAFETY 路定点复核 — F-S1 关闭判定（TASK-20261006-TADSH-BACKUP-FIX）

**复核者**：Blake 评审身份，独立会话（未参与本链设计、实施与 F-S1 修复；与原 SAFETY 路、CODE 路互不可见）
**日期**：2026-10-06
**复核面**：只核一件——原 verdict `.tad/evidence/reviews/tadsh-backup-fix-20261006/gate3-safety.md` 的唯一条件 **F-S1**（`resolve_backup_root` 在符号链接别名落点路径上、物理拒绝之前已对目标内既存目录 `chmod 700`，与 NFR1／C1「变更前中止、零痕迹拒绝」合同不符）。关闭条件原文取 (a)：物理落点判定前置于任何 mkdir/chmod 效应；关闭后定点复核此函数即可、无需重审全链。本件不重审其余各面。

**对象锚（复核时实测）**：
- 修复后 `tad.sh`：157,388 B／sha256 `459b9fc9…`（全文 `459b9fc92311a837d482fddfd6311cc3d017a28ca5aa8493173753351de87f98`），与 COMPLETION 追记自报一致；`resolve_backup_root` 现 L488–553（注释头 L488–503＋函数体 L504–553）。
- `.tad/hooks/lib/tad-backup-test.sh`：34,018 B／sha256 `941d3609…`，与追记一致；新场景 `case_root_alias` 现 L629–663。
- COMPLETION 追记：`.tad/evidence/completions/COMPLETION-2026-10-06-tadsh-backup-fix.md` 28,748 B／sha256 `40ccabdc…`，与任务书锚一致；追记自述写集仅两件、`gate3_verdict` 仍留空待本复核裁定。

**方法**：规程原件按 tad-blake 激活壳进仓读（AGENTS.md／principles／Gate 3 判据面）；修复后函数逐行亲读；作者套件在隔离 fixture 面**本人全新复跑**（新场景单跑＋全套）；另以同法 sed 逐字抽取当前真函数直调，构造本人对抗探针 12 例（脚本暂存 /tmp，结论在下）；并自建负控变异体（把 mkdir+chmod 挪回物理判定之前）验证新场景的判别力。git 全程只读；未以 tad.sh 碰任何真实项目仓；真实 HOME 下 `.tad-backups` 仍不存在（冻结令互洽）。

---

## 结论：F-S1 **关闭（CLOSED）**

关闭条件 (a) 已按规格实现且经独立实测成立：物理落点判定（只读解析＋inside-target 拒绝）整体前置于 `mkdir -p`／`chmod 700` 两个效应点（现 L548–549，位于物理拒绝 L543–546 之后）；别名路径拒绝零痕迹（权限与内容均不变）；合法既存根的收紧行为保留且移至判定之后。修复未触函数外语义（见 ③）。原 verdict 的 CONDITIONAL 唯一条件即此条，本件只判 F-S1 本身，SAFETY 路整体结论的收口归 PM／Gate 流程据本件办理。

---

## ① 自跑新场景与全套 fixture — ✅ 别名拒绝零痕迹、合法收紧保留

- 本人复跑 `bash .tad/hooks/lib/tad-backup-test.sh --case root-alias` → `PASS root-alias`；全套复跑 → **TALLY: PASS=15 FAIL=0**（原 14＋新 1），与追记自报一致。其余 14 例全绿兼作行为平价证据（见 ③）。
- 作者场景 `case_root_alias` 本人亲读：别名指向目标内既存目录（755，含两级内容文件）→ 断言 rc≠0、拒绝有日志、该目录**权限保持 755、内容清单（tree_manifest）与条目集零变化**；第二段钉保留行为：目标外既存根（755）备份成功且被收紧为 700。断言面与 F-S1 的缺陷面（权限先行变更）正对。
- 本人独立探针复证（直调函数，不经 do_backup 封装）：B1 别名→目标内既存目录——rc≠0、`inner` 保持 755、`find` 条目集与调用前逐行相等；B9 别名链（link→link→inner）同判。B6 合法别名→目标外既存目录（755）——rc=0、真实目录被收紧为 700、`TAD_BACKUP_ROOT_ABS` 回报**物理路径**（下游 repo_group_key 的入参口径未变）。

## ② 函数重排的边界效应 — ✅ 无新副作用引入（12 例探针全过，1 项刻意只读判定）

修复后函数的判定顺序（亲读 L504–553）：字面快速拒绝（无副作用）→ 只读物理解析（既存目录 `cd && pwd -P`；存在但非目录直接报错；不存在则经最近既存祖先只读解析预计落点）→ 空／`/` 安全检查 → 物理 inside-target 拒绝 → 判定通过后才 `mkdir -p`＋`chmod 700`。逐边界实测：

| 探针 | 场景 | 结果 |
|---|---|---|
| B3 | 不存在根的预计落点在别名祖先之内（alias→目标内目录，其下新子路径） | rc≠0，目标内**未建任何条目**、祖先目录权限未动——预计落点解析在创建前完成判定 |
| B7 | 不存在根（目标外多级新路径） | rc=0，建成、叶目录 700、`TAD_BACKUP_ROOT_ABS`＝预计落点——正常创建路径保留 |
| B4 | 悬空链接作根（指向目标内不存在路径） | rc≠0（「exists but is not a directory」支），链接目标**未被创建**、链接本体仍悬空 |
| B5 | 根为既存普通文件（目标外） | rc≠0，文件内容与 644 权限逐字未动 |
| B12 | 符号链接指向既存文件作根 | rc≠0，目标文件权限未动（`-e`／`-L` 支在任何 chmod 前触发） |
| B2 | 别名指向**目标根自身** | rc≠0，目标根目录权限（755）未动——原缺陷面在「根即目标」形态下同样关闭 |
| B8 | 字面 `..` 穿越（目标外前缀＋`/../proj/inner`） | 物理解析后 rc≠0，inner 保持 755 |
| B10 | 字面目标内路径带尾斜杠、目录尚不存在 | 快速拒绝 rc≠0，未创建 |
| B11 | 路径中段组件是「指向普通文件的符号链接」 | rc≠0（mkdir 处 fail-closed），被指文件内容/权限未动——预计落点解析对该形态给出字符串落点、由 mkdir 的真实失败兜底，方向保守 |
| B1/B9/B6 | 见 ① | 全过 |

- **根＝`/` 刻意未做活体探针**：若该守卫回归，探针本身即会对 `/` 执行 chmod，探针即危害。改以代码判定：`/` 走既存目录支，`cd / && pwd -P` 得 `_abs="/"`，L539–541 的显式 `[ "$_abs" = "/" ]` 拒绝位于 mkdir/chmod（L548–549）之前，顺序确定性成立，判安全。此处理由记明备查。
- **一处行为差（记录，非阻塞）**：既存目录若当前不可进入（`cd` 失败，如他人所有的无执行权目录），新序在 chmod **之前**即以「cannot resolve backup root」rc=1 退出；旧序会先 chmod（所有者场合可能顺带修好权限）再解析。新行为 fail-closed、无副作用、报错点名，符合 NFR1 方向；单操作者 CLI 威胁模型下操作者自有目录恒可进入，不构成关闭障碍。
- 判定与效应之间的 TOCTOU 窗口（解析后、mkdir 前路径组件被替换）在旧实现中以更差形态存在（效应先行），威胁模型为单操作者 CLI（principles 既定前提），重排未使其恶化，不立项。

## ③ 修复未触函数外语义 — ✅ 写集限于该函数＋测试脚本（核法见注记）

- **tad.sh 对 git HEAD 的 hunk 清单**（`git diff -U0`）全部落在本链原声明行段内（全局 2 行／备份节／`_tad_tree_equal` 新增／两 restore helper 探针行／C5／C6 step-1），F-S1 修复位于备份节 hunk（新 L488 起）内的 `resolve_backup_root` 段；备份节之外无新 hunk 出现。
- 原 verdict 的承重不变量本人重验、全数保持：增补 S4 口径 `git diff -- tad.sh | grep -cE '^[+-]TAD_(ZERO_TOUCH|TRANSIENT|TOP_DENY)='` ＝ **0**；`derive_framework_dirs`／`derive_framework_top_files`／`verify_denylist_drift` 三函数与 HEAD **逐字节相同**（awk/sed 抽取 cmp 实测）；`verify_install_complete` 的 `diff -rq` 执行行仍在盘逐字未动（现 L1744）。
- **测试脚本增量结构**：`case_*` 函数恰 15 个＝原 14＋`case_root_alias`（L629，位于 root-guard 与 legacy 之间）；登记面恰两处（文件头场景清单 L17、`ALL_CASES` L697）；体量 32,069→34,018 B（+1,949 B）、692→728 行（+36 行），与「一个约 35 行场景＋两处登记行」的增量形态吻合，无其他场景增删。
- **行为平价**：全套 15 例中原 14 例在修复后代码上全部复跑绿（①），函数外行为无漂移的实测面成立。
- **负控（判别力，本人自建）**：在 /tmp 镜像树中把当前 tad.sh 的 `resolve_backup_root` 人为改回缺陷顺序（mkdir+chmod 挪至只读解析之前），跑作者 harness 的 root-alias → **FAIL，签名恰为 `aliased dir perms changed by refused call: 700 (F-S1)`**；同变异体跑 root-guard → PASS。即新场景钉住的正是 F-S1 的拒绝前副作用（而非拒绝缺席或功能缺席），且当前盘面函数的顺序是其通过的充要面。与追记自报的两项负控（旧函数体拼回 FAIL／git HEAD 版 FAIL）互相印证。
- 注记：修复前工作区从未提交 git，「修复增量」无 pre/post 直接 diff 可凭；本节结论由 hunk 清单＋不变量重验＋增量结构＋行为平价＋负控五路互证得出，与原 verdict ⑤ 的核法同口径。
- 附带核对：`.tad/version.txt` 仍 3.1.0（版本冻结守）；两文件 `bash -n` 均通过；COMPLETION 追记对本复核的预留（`gate3_verdict` 留空、关闭与否归 SAFETY 路定点复核）与 verdict 关闭条件原文一致，程序面无越位。

---

## 复核纪律自报

- 纯只读复核：代码与证据只读；执行仅限 mktemp 隔离 fixture（作者套件全套＋单跑、本人探针 12 例、/tmp 镜像树变异体负控，全部在 /tmp 沙箱内构造与销毁）；未以 tad.sh 碰任何真实项目仓；git 只读（status/diff/show）。
- 本人实测汇总：作者套件 15/15 PASS；本人探针 12/12 PASS；负控变异体 root-alias FAIL（预期签名）＋root-guard PASS。
- 本件落盘后以 `wc -c`／`sha256sum` 实测自报，随回执上报（自引用值不写进正文，循本仓惯例）。

**F-S1 判定**: 关闭（CLOSED）— 关闭条件 (a) 已实现并经独立实测
**Reviewer**: Blake（Gate 3 SAFETY 路定点复核，独立会话）
**Date**: 2026-10-06
