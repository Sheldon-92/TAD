# Amendment Record — pin 13 NEW (routing-decouple, rev2→rev3-in-effect)

**Date**: 2026-08-14 (TAD session, Blake execution)
**Authority**: 用户裁定（Q&A，用户明确选择「修订 pin 13 NEW 为 "Default"（推荐）」）
**Contract**: `.tad/active/handoffs/HANDOFF-20260814-routing-decouple.md`（rev2，契约文件本体未改）

## 矛盾

AC1 要求 pins.tsv 19 条逐字应用（NEW 恰好 1），AC6 要求模式集
（大小写不敏感，含 `default channel`）在 `git ls-files` 全集计数 0。
原 pin 13 NEW = `echo "  /alex, /blake, /gate     - Default channel"`
内含 "Default channel"，两个 AC 不可同时满足（实现已被 AC1 钉死，
非实现错误，Gate 2 三专家未捕获）。

## 修订

pin 13 NEW: `echo "  /alex, /blake, /gate     - Default channel"`
→ `echo "  /alex, /blake, /gate     - Default"`
（仅删除词 "channel"，保留 12 空格缩进与其余字节；tad.sh 帮助文本语义不变。
该行仍以 "Default" 对齐 pin 14 行的 `- Frozen experiment`。）

## 基线重冻结（修订的必然结果）

- `$EV/inputs.sha256`：重新哈希五个输入（pins.tsv 哈希随修订更新）
- `$EV/step0-baseline.sha256`：随 inputs.sha256 重冻结
- `$EV/fence-baseline.txt`：追加被修订的输入路径
  `.tad/active/handoffs/HANDOFF-20260814-routing-decouple.pins.tsv`
  （AC11 围栏的仅此一项例外；除此之外实现期间无任何围栏外改动）

## 验证影响

- AC1/AC6/AC9/AC11 均在修订后全绿（verify-run-2 记录：AC1-AC9 PASS，
  AC11 在本记录生效后 PASS）
- 其余 18 条 pin 与三个块文件零改动

## 补记 1 — AC3 读法（独立裁定外的解释性决定，2026-08-14）

契约 AC3 字面「整文件减去哨兵块区间 == T0 整文件减去旧块区间」对 alex-lite
**不可满足**：其 frontmatter description 行（含 AC6 禁词「默认通道」）由 pin 18/19
钉死必改（AC1），而该行不在块区间内 → 严格读法下 AC3 必红，与 AC1/AC6 矛盾
（与 pin 13 同类，Gate 2 三专家未捕获）。

采用的可满足机械读法：**T0 侧先施加 description pins（18/19）再减旧块区间**，
live 侧减 LITE-FROZEN 区间，两侧 sha256 相等 ⟺ 4 个 lite skill 的唯一增量 =
{钉死的 description 行 + 块}，协议体零漂移（判别力保留：任何其他行漂移仍红）。
依据：契约 §2「本单只改『我是默认通道』这类声明」——description 正是声明类改动，
且由 AC1 逐字钉死，数据源受 AC9 冻结保护。AC4 独立全文重建交叉验证该读法。

## 补记 2 — brain-index-gen.sh 预存缺陷（NEXT.md 已记载的 warty exit）

`brain-index-gen.sh`（`.tad/hooks/lib/`，§5 外不可改）在归档手稿循环遇
`HANDOFF-20260812-discipline-inventory-columns.md`（无 `task_type:` 字段，
HEAD 即如此）时 `set -euo pipefail` 杀脚本，exit 1。输出为部分文件：
章节结构完整，仅「Archived Handoffs (recent 50)」段截断约 2 行。
AC8（`默认走 lite`=0）实测达标；apply-changes.sh 因该缺陷红退（exit 1），
内容已正确落盘。修复属独立维护单（不在本契约 §5）。

## 补记 3 — Layer 2 审查 P1 处置（2026-08-14）

- **P1-3 权限损伤**：mktemp+mv 使 8 个文件 644→600、tad.sh 755→644。
  已修复：`chmod 644`（8 文件）+ `chmod 755 tad.sh`；apply 脚本已加
  `chmod --reference` 防止复发。
- **P1-1/P1-2/P1-4 apply 加固**：apply_block 增加 end 锚点断言（end_hit）、
  block C 断言被替换行含「**默认通道**」、mv 失败显式检查、block 文件不可读
  显式 exit 2（此前 end 锚点缺失会静默截断文件）。
- **AC10 收紧**：输出提及 lite → 机械红；提到 Alex 通道（/alex 或 当 Alex）
  且无 lite → 通过；其余由 Blake 裁定（§9.3）。
- **AC4 字节精确**：live 与 git show 两侧改 `newline=""` 逐字节读取（消除 CRLF
  归一化掩盖）。

## 补记 4 — 契约文案小误（非阻塞，Gate 2/3 记录）

契约 §3.1 称「第 13-15 条含 ${CYAN} ${NC}」——实测仅第 15 条含（tsv 全文
grep -c = 1）。执行路径全部按字面处理，不影响结果。
