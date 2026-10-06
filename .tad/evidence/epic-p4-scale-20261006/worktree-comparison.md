# worktree 比对表 — Epic Phase 4 件 4.1 Phase 0（2026-10-06，Blake）

方法：逐目录以「在盘全量文件清单（路径＋sha256）」对「对应分支尖端树物化清单（`git archive <branch>` 至隔离面后同法清单）」三向比对——多余（only-wt）／缺失（only-tip）／同路径 sha 不同（sha-diff）。`.git` 指针文件不计入清单（四目录各 1 件，指向 `/Users/sheldonzhao/云同步/TAD/.git/worktrees/…`，其元数据不在本机）。全量基线清单：`worktree-baseline-manifest.txt`（20,480 行，sha256 `834914238b9eda9b96619e087bb8ab524972aa7f07ae29c8233e5c59046fd26c`，含 `.git` 指针文件 4 件）。

## A. 比对流程负控（AC2 判读，判别力自证）

自造目录＝`feat/local-wiki-phase3` 尖端物化副本＋三处植入差异（改 `CHANGELOG.md` 尾加一行／新增 `PLANTED-EXTRA.txt`／删 `NEXT.md`）。流程输出：extra=1、missing=1、sha_diff=1，定级 **(b)**，且三份差集文件逐件命中植入点（`worktree-diff-NC.only-wt.txt`／`.only-tip.txt`／`.sha-diff.txt`）。判别力成立后方用于真目录。

## B. 逐目录结果

| 目录 | 对应分支（尖） | 在盘文件数 | extra | missing | sha_diff | 定级 |
|---|---|---|---|---|---|---|
| `local-wiki-phase3` | `feat/local-wiki-phase3`（`f7e99dc0`，0 ahead） | 2,367 | 0 | 28 | 0 | **(b)**（字面）／子集等值候选 |
| `local-wiki-phase3-native` | `feat/local-wiki-phase3-native`（`f235e377`，0 ahead） | 2,387 | 0 | 28 | 0 | **(b)**（字面）／子集等值候选 |
| `tad-yolo2-scope-proof` | `tad/yolo2-scope-proof`（`69194cd1`，0 ahead） | 2,233 | 0 | 27 | 0 | **(b)**（字面）／子集等值候选 |
| `tad-yolo2-candidate` | `tad/yolo2-candidate`（`3ce202b4`，2 ahead） | 13,493 | **11,275** | 27 | **9** | **(b)**（实质） |

差集逐件文件：`worktree-diff-<dir>.only-wt.txt`／`.only-tip.txt`／`.sha-diff.txt`（同目录在盘）。

## C. 缺失集合分析——同步通道名称过滤（新发现，实测）

三目录的缺失集合几乎同一（27 件公共集；phase3／native 多 1 件 `termination-secret-isolation.json`，candidate 与 scope-proof 在盘有该件）。27 件公共集**全部**为文件名含 `token`／`secret` 字样或 `.env` 的文件：`design-tokens.*`（11 件）、`cost-token-economics.md`（×3 投影）、`secret-detection-rules.md`（×3）、`brand-tokens.md`（×3）、`starter-tokens.json`（×3）、`tokens-to-css.sh`（×3）、`.env.example`（1 件）。交叉验证：

- 同名文件在本仓主工作树与分支尖端树中均实存（`git cat-file -e` 命中、主工作树 ls 命中）；
- `find .worktrees -iname '*token*' -o -iname '*secret*' -o -name '.env*'` ＝ **0 命中**——四目录内此类文件全数缺席；
- 结论（证据强度：probed）：四份副本经同步/复制通道到达本机时，该通道对含敏感名称的文件做了系统性排除。副本因此是尖端树的**真子集**：在盘的每一个文件都与尖端逐件 sha 全等（sha_diff=0、extra=0），**唯一字节为零**——删除不销毁任何 ref 不可还原的内容，REQ-1 的安全实质成立；不成立的只是 §4.1 (a) 级「差集为空」的字面形态。故三目录的去向不在 Blake 判定内，入停步点 D-P0-1 由 PM 裁（见 `size-inventory.md` §D）。

## D. candidate (b) 级差集逐件要点（实质 (b)，任何口径下不删）

- **extra 11,275 件全部位于 `.tad/evidence/`**（该目录在盘合计 11,292 件／116M）：系该 worktree 在 Mac 侧运行期间积累的 gitignored 证据工作副本，**不在 `tad/yolo2-candidate` 分支 ref 内**，删除即销毁（其内容是否与主仓证据面／maintainer-evidence 载体全等未逐件验，超出本链比对范围，不许默认等同）。
- **sha_diff 9 件**（与尖端同路径内容不同，逐件见 `worktree-diff-tad-yolo2-candidate.sha-diff.txt`）：含 yolo2-phase2 评审件 4 件、scope-proof 机器件 5 件——属该候选分支工作期间的在研改动残留。
- missing 27 件同 §C 过滤集合。
- 定级：**(b)**。设计预判「大概率 (b)」经实测坐实且量级超预判（116M 非 ref 内容）。去向归 PM/属主裁断，本链零动作。

## E. 回退验证衔接（Phase 2 预告）

若 PM 就 D-P0-1 裁 (i)：Phase 2 删除前按承接 B 常设规程，对每个获确认目录以本表所用尖端物化清单与 `worktree-baseline-manifest.txt` 对应段做「物化集 ↔ 在盘集」逐行复核（在盘集 ⊆ 物化集且共有路径 sha 全等，即还原路径已证），记录入盘点件回退验证节后方执行删除。若裁 (ii)：四目录全数保留，Phase 2 仅 `git gc`。

（本件自报：字节/sha 以落盘复算为准；差集明细件与基线清单同目录在盘。）
