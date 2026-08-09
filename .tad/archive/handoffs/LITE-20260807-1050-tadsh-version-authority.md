# LITE Handoff: tad.sh 版本权威提前 —— 让「已是最新」的判定结构上不会陈旧

**Date**: 2026-08-07

## 目标（含"为什么"）

`tad.sh` 的状态闸（`STATE=$(detect_state)`, L1420）用硬编码字面量 `TARGET_VERSION`（L22）判定
下游是否已是最新；而权威版本要到 L1549 `derive_target_version` 才从下载的源树取得——**判定发生在
真值可得之前 123 行**。字面量落后一个版本时，下游收到「✅ Nothing to do」并 `exit 0`，**静默不升级，
退出码 0**。

v2.40.0 只把字面量从 `2.39.0` 改成了 `2.40.0`——**补丁，不是修复**。`principles.md`
§`Deny-List Beats Allow-List for Sync Sets` 里记着「tad.sh 卡在 2.19.1」，**这已是第二次打同一个补丁**。

本单把「已是最新」的判定移到权威版本已知之后，使这一类缺陷**结构上不再可能发生**，而不是每次
发布靠记得改一行、靠发布闸兜底。

## 不做什么

- **不改 `.tad/hooks/` 下任何文件**——包括 `detect-state-test.sh` 与 `release-verify.sh`。
  命中安全停清单第 3 条（全局注册面）。`release-verify.sh` 的 `version-sweep` 对
  `tad.sh|TARGET_VERSION="x.y.z"` 的 BLOCKING 断言**保持不变、继续作为纵深防御**——本单不是要
  拆掉那道门，是要让门后面不再有雷。
- **不改 `detect_state()` 的签名与函数形状**。`detect-state-test.sh` 用 `sed` 从 `tad.sh`
  抽取 `/^detect_state() {/,/^}/` 和 `/^    case \$STATE in/,/^    esac/`，并以**变量**形式钉住
  `TARGET_VERSION` 后**无参调用**。改签名 = 必须改测试 = 命中安全停第 3 条。
- **不删除 L22 的字面量**。它仍是横幅（L1384）与探测失败时的兜底，且是 `version-sweep` 的锚点。
- 不改 `_tad_ver_cmp`、不改任何 `ACTION` 执行分支、不动 migration engine。
- 不发布、不 commit、不 push（安全停第 1 条，另行授权）。

## 文件清单

**修改（唯一一个文件）**：`tad.sh`

逐处：

| # | 位置 | 改动 |
|---|---|---|
| M1 | L17-21 注释 | 改写：现有 "so this literal can never go stale" **对状态闸不成立**，正是它误导了两次修复 |
| M2 | L24 附近 | 新增常量 `VERSION_URL="https://raw.githubusercontent.com/Sheldon-92/TAD/main/.tad/version.txt"` |
| M3 | L37 之后（`derive_target_version` 尾） | 新增 `PROBE_OK=0` 与函数 `probe_remote_version()` |
| M4 | L1418-1420 之间 | 在 `STATE=$(detect_state)` **之前**调用 `probe_remote_version` |
| M5 | L1422-1424 | `CURRENT_VERSION` 赋值处补 CRLF/空白裁剪（与 `detect_state` L1349 对齐） |
| M6 | L1472 的 `ACTION == "none"` 分支 | 加 `PROBE_OK != 1` 前置分支：**探测失败时不得宣称已是最新** |
| M7 | L1549-1550 之后 | **根因修复**：post-derive 权威复判块 |
| M8 | L1547-1548 注释 | 同 M1，去掉 "can never go stale" 措辞并写明它只对下载后路径成立 |

### 实现规格（逐条，不留发挥空间）

**M2 + M3**（放在 `derive_target_version()` 定义之后）：

```bash
PROBE_OK=0
# probe_remote_version — 在状态闸之前取得权威版本。成功 → 覆盖 TARGET_VERSION 并置
# PROBE_OK=1；任何失败（网络/超时/非法载荷）→ 两者均不动，PROBE_OK 保持 0。
# 这是 OPTIMIZATION 而非正确性来源：它只为保住「已是最新」的快速退出。正确性由
# main() 里 derive_target_version 之后的权威复判保证（见 M7）。
probe_remote_version() {
    local v
    v=$(curl -sSL --max-time 10 "$VERSION_URL" 2>/dev/null | head -1 | tr -d '[:space:]') || true
    # 载荷必须先验证再采信：404 会返回一整页 HTML，不加这道正则就会把 HTML 当版本号。
    if [[ "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TARGET_VERSION="$v"
        PROBE_OK=1
    fi
}
```

`|| true` 是必需的：`set -e` + 已武装的 `ERR` trap 下，管道非零退出会触发
`rollback_on_failure`（见 `shell-portability.md` §`grep No-Match in Command Substitution Under set -e`）。

**M4**：在 `main()` 的 `STATE=$(detect_state)` 之前一行调用 `probe_remote_version`。

**M6**：现有 `if [ "$ACTION" == "none" ]` 块改为三分支。**`--force` 分支必须排在最前**：

```bash
    if [ "$ACTION" == "none" ]; then
        if [ "$FORCE" = "1" ]; then
            <原有 --force 逻辑，原样保留（含 L1480 的「does not downgrade」保护与 exit 0）>
        elif [ "$PROBE_OK" != "1" ]; then
            # 目标版本未经证实（探测失败）——绝不基于猜测宣称已是最新。
            # 继续走下去，由 M7 的权威复判定夺；最坏结果是一次多余的重装，
            # 而不是一次静默的不升级。
            ACTION="upgrade"
        else
            <原有「Nothing to do」+ exit 0，原样保留>
        fi
    fi
```

⚠️ **分支顺序是承重的，不是风格问题**（契约 v1 在此处有 P0，Contract Review 2026-08-07 抓出）：
全文件唯一一处「`--force` 不降级」保护在 L1480，且**只在 `ACTION=="none"` 且 `FORCE=="1"` 时可达**。
若把 `PROBE_OK != "1"` 排在前面，则探测一失败就无条件命中该分支 → `--force` 分支连同那道保护整个
被跳过 → `ACTION="upgrade"`；而 M7 又以 `[ "$FORCE" != "1" ]` 开头同样跳过；`case $ACTION` 的
upgrade 分支**没有第二道版本比较**，会无条件覆盖安装并改写 `.tad/version.txt`。
净效果：**`--force` + 探测失败 + 本机版本确实更新 → 静默降级**。
把 `--force` 排在最前后，该分支的行为与改前逐字相同（它本来就不依赖探测机制），AC10a 钉住这一点。

**M7**（根因）：紧接 `log_info "  → Source version: v${TARGET_VERSION}"` 之后：

```bash
    # ROOT FIX：「已是最新」的判定，要么在状态闸用探测到的实时版本完成（探测成功，
    # 多数情况），要么推迟到这里用已下载源树的版本确认（探测失败）。两条路径都不再
    # 依赖 L22 的字面量，因此字面量陈旧不可能再产生静默 no-op。本块是后一条路径。
    if [ "$FORCE" != "1" ] && [ "$CURRENT_VERSION" != "none" ] \
       && [ "$(_tad_ver_cmp "$CURRENT_VERSION" "$TARGET_VERSION")" != "-1" ]; then
        rm -rf "$TAD_SRC"
        echo ""
        echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
        exit 0
    fi
```

`rm -rf "$TAD_SRC"` 与既有 L1825 的收尾清理**同一语句、同一对象**——引擎自建的临时解包目录，
非用户内容（`shell-portability.md` §`rm Chokepoint Constraint vs Temp File Cleanup`：
用命名清晰的同类清理，不是新增删除面）。

`!= "-1"` 即「已装 ≥ 目标」：等于 → 无事可做；大于 → 绝不降级（沿用 L1357/L1480 的既定方向）。

## AC

> 运行 shell 是 **zsh 5.9**（`echo $0` → `/bin/zsh`），`grep` 是 **ugrep 7.5.0**。
> 全部 AC 用字面词表、不用 `for x in $VAR`、不用 `\<`、不用数组。
> `grep -c` 命中 0 时退出码为 1 —— 一律 `$(... || true)` 取数后**数值比较**，不靠退出码。
> 基线值均为 2026-08-07 本机实跑所得（`tad.sh` md5 `4c26e5ba08b7e8e9430aef0b015ad993`，1855 行）。

- AC1: **顺序（根因本身）**——探测调用必须早于状态闸。
  ```bash
  MN=$(grep -n '^main() {' tad.sh | head -1 | cut -d: -f1)
  P=$(grep -n '^    probe_remote_version$' tad.sh | head -1 | cut -d: -f1)
  S=$(grep -n 'STATE=\$(detect_state)' tad.sh | head -1 | cut -d: -f1)
  [ -n "$P" ] && [ "$MN" -lt "$P" ] && [ "$P" -lt "$S" ] && echo AC1-PASS || echo AC1-FAIL
  ```
  改前基线：`P` 为空 → FAIL（实测 `grep -c '^    probe_remote_version'` = 0）。
  ⚠️ **`MN < P` 不是装饰**（增量复核 3 的 P1）：只比 `P < S` 的话，把探测调用误放进一个**更早定义
  的另一个函数体内**（例如落进 `derive_target_version()`）也满足 `P < S` → **假 PASS**，
  而真实运行时探测根本不在状态闸前触发。加上 `MN < P` 即要求调用落在 `main()` 之后。
  锚点稳定性已实测：`main() {` 在 L1381，且是**全文件最后一个**顶层函数定义
  （`grep -n '^[a-zA-Z_][a-zA-Z0-9_]*() {' tad.sh | tail` 确认，其后仅 `_tad_ver_cmp`/`detect_state`/`main`）。
  ⚠️ 严重度诚实标注：这个假 PASS **不会**造成静默降级或静默不升级——探测没跑 → `PROBE_OK` 停在 0
  → M6 的 `elif` 分支兜底成 `ACTION="upgrade"` → M7 仍是最终正确性保证。代价是每次多做一次无谓重装。
  所以它是 **P1 不是 P0**，但修法便宜且无新脆弱点。

- AC2: **根因修复块位置**——权威复判必须在 `derive_target_version` 调用之后、且在
  **执行分派**之前。
  ⚠️ `^    case \$ACTION in$` 在 `tad.sh` 里有**两处**：L1498 是「Show what will happen」
  的展示块，L1553 才是执行分派。`head -1` 会取到展示块，使断言恒 FAIL（本 AC 空跑时实际踩到）。
  改用唯一的 `# Execute based on action`（L1552）作锚，并顺带钉住「仍是两处」这个不变量。
  ```bash
  D=$(grep -n '^    derive_target_version "\$TAD_SRC"$' tad.sh | head -1 | cut -d: -f1)
  R=$(grep -n '# ROOT FIX' tad.sh | head -1 | cut -d: -f1)
  X=$(grep -n '# Execute based on action' tad.sh | head -1 | cut -d: -f1)
  N=$(grep -c '^    case \$ACTION in$' tad.sh || true)
  [ -n "$R" ] && [ "$D" -lt "$R" ] && [ "$R" -lt "$X" ] && [ "$N" -eq 2 ] \
    && echo AC2-PASS || echo AC2-FAIL
  ```
  改前基线：`D=1549` `X=1552` `N=2` `R` 为空 → FAIL（实测）。

- AC3: **探测函数行为**——抽取函数进临时 shim，用桩 `curl` 跑三种载荷。
  ```bash
  SHIM=$(mktemp)
  sed -n '/^probe_remote_version() {/,/^}/p' tad.sh > "$SHIM"
  grep -q 'PROBE_OK=1' "$SHIM" || { echo "AC3-HARNESS-FAIL: 抽取为空"; rm -f "$SHIM"; exit 1; }
  # 3a 正常载荷 → 覆盖
  ( source "$SHIM"; curl() { echo "2.99.0"; }; PROBE_OK=0; TARGET_VERSION="2.40.0"
    probe_remote_version; [ "$TARGET_VERSION" = "2.99.0" ] && [ "$PROBE_OK" = "1" ] \
    && echo AC3a-PASS || echo AC3a-FAIL )
  # 3b 网络失败 → 不动、不采信
  ( source "$SHIM"; curl() { return 7; }; PROBE_OK=0; TARGET_VERSION="2.40.0"
    probe_remote_version; [ "$TARGET_VERSION" = "2.40.0" ] && [ "$PROBE_OK" = "0" ] \
    && echo AC3b-PASS || echo AC3b-FAIL )
  # 3c 404 HTML 载荷 → 必须被正则挡下（这是最容易漏的一条）
  ( source "$SHIM"; curl() { echo "<!DOCTYPE html><html>404</html>"; }; PROBE_OK=0
    TARGET_VERSION="2.40.0"; probe_remote_version
    [ "$TARGET_VERSION" = "2.40.0" ] && [ "$PROBE_OK" = "0" ] && echo AC3c-PASS || echo AC3c-FAIL )
  rm -f "$SHIM"
  ```
  三条必须全 PASS。桩函数覆盖真 `curl`，**不发任何网络请求**。

- ~~AC4~~: **已退役（v3）——不要执行，不计入 AC 总数。**
  原文断言「`PROBE_OK` 分支存在且位于 `--force` 分支**之前**」，编码的是 v1 那个**错误**顺序。
  P0-2 把顺序对调后，这条 AC 在**正确实现上 100% FAIL**（Contract Review 增量复核 P0-3，
  Alex 已独立实证）：
  - `K` 的 pattern `if \[ "\$PROBE_OK"…` 无 `^` 锚点，而 `elif [` 里含子串 `if [` → **误命中 elif 行**；
  - `F` 的 pattern `elif \[ "\$FORCE"…` 在修订后不存在（`FORCE` 现在是裸 `if`）→ 空 →
    `[ "$K" -lt "$F" ]` 报 `integer expression expected` → 整条 FAIL。

  ⚠️ **退役而非改写的理由**：AC4 没有独立的失败模式。它想守的两件事已被更强的**行为性**断言覆盖——
  顺序被改回错误版 → **AC10a FAIL**（已双向反证：错误版 A 行输出 `ACTION=upgrade`、不含
  `does not downgrade`）；分支存在性 → **AC10b**。再留一条文本锚只是重复覆盖，且脆（钉死缩进）、
  又能误导。**这里的危险不是它会 FAIL，是实现者可能"照 AC 改代码"把顺序改回去，重新引入 P0-2 的静默降级。**
  按约束准入的默认动作（无独立载体即删除）退役。

- AC5: **既有路由测试不回归**——证明 `detect_state` 形状与两处 `sed` 抽取锚点均未破坏。
  ```bash
  bash .tad/hooks/lib/detect-state-test.sh | tail -2
  ```
  必须输出 `TALLY: PASS=12 FAIL=0` 且退出码 0。改前基线：12/0（实测）。

- AC6: **误导性注释清零 + 正向锚点**。
  ```bash
  N=$(grep -c 'can never go stale' tad.sh || true)
  [ "$N" -eq 0 ] && echo AC6a-PASS || echo "AC6a-FAIL ($N)"
  M=$(grep -c 'state gate' tad.sh || true)
  [ "$M" -ge 1 ] && echo AC6b-PASS || echo AC6b-FAIL
  ```
  改前基线：`N=2`（L19、L1548），`M=0` —— 两个方向都有区分度。
  AC6b 的正向锚点确保注释是**被改写**而不是**被删掉**。

- AC7: **字面量与发布闸锚点存活**——L22 的 `TARGET_VERSION="2.40.0"` 必须仍在，且**版本号不变**
  （本单不发版）。
  ```bash
  L=$(grep -c '^TARGET_VERSION="2\.40\.0"$' tad.sh || true)
  [ "$L" -eq 1 ] && echo AC7-PASS || echo "AC7-FAIL ($L)"
  ```
  改前基线：1。

- AC8: **语法与改动形状**。
  ```bash
  bash -n tad.sh && echo AC8a-PASS
  git diff --numstat -- tad.sh
  ```
  `bash -n` 退出 0；`numstat` 只有 `tad.sh` 一行，且**按结果文件计**（部分替换时新旧有公共行，
  diff 会匹配成 context —— 不得按「替换了几行」估算）。实际值由实现者实跑填入完成报告，
  Alex 复核时以**再跑一次同一命令**为准，不与预估比对。

- AC9: **工作区未越界**——本单只应改 `tad.sh` 一个文件。**用当场快照做集合差，不钉绝对数**。
  ```bash
  # ① 动 tad.sh 之前，当场跑（不要用契约里写死的数字）：
  git status --short | LC_ALL=C sort > /tmp/ac9-before.txt
  LC_ALL=C sort -c /tmp/ac9-before.txt && echo "before-sorted-OK"
  # ② 实现完成后：
  git status --short | LC_ALL=C sort > /tmp/ac9-after.txt
  LC_ALL=C sort -c /tmp/ac9-after.txt && echo "after-sorted-OK"
  # ③ 断言：新增的有且只有 tad.sh，且没有条目消失
  LC_ALL=C comm -13 /tmp/ac9-before.txt /tmp/ac9-after.txt   # 期望：只有一行，且是 tad.sh
  LC_ALL=C comm -23 /tmp/ac9-before.txt /tmp/ac9-after.txt   # 期望：空
  ```
  ⚠️ 判据是「**只有一行，且该行指向 tad.sh**」——**不要拿 ` M tad.sh` 做字面量比对**：未暂存是
  `" M tad.sh"`（M 在第 2 列），一旦被 `git add` 就变成 `"M  tad.sh"`（M 在第 1 列），两者字节不同
  （增量复核 P2-5 实测）。行数与目标文件才是判据，前缀标记不是。
  ⚠️ AC9 与 AC8 一样是**打印 + 人工读结果**，不是自动 PASS/FAIL 断言。沿用既有风格，但复核时
  必须真的看输出，不能因为命令跑完退出 0 就记 PASS。
  机械抓手（可选，省心用）：
  ```bash
  ADD=$(LC_ALL=C comm -13 /tmp/ac9-before.txt /tmp/ac9-after.txt)
  DEL=$(LC_ALL=C comm -23 /tmp/ac9-before.txt /tmp/ac9-after.txt)
  [ "$(printf '%s\n' "$ADD" | grep -c 'tad\.sh$' || true)" -eq 1 ] \
    && [ "$(printf '%s' "$ADD" | wc -l)" -le 1 ] && [ -z "$DEL" ] \
    && echo AC9-PASS || echo AC9-FAIL
  ```
  ⚠️ **不得使用任何硬编码计数**（契约 v1 写死「改前 21 / 改后 22」，Contract Review 复验时实测已是
  22——起草到实现之间仓库仍在变动，绝对数当场就失真了）。这正是 `principles.md`
  §`Deny-List Beats Allow-List for Sync Sets` 里那句 "Never pin an absolute count — assert
  set-equality live" 要防的错，v1 引用了该条却没用在自己身上。
  ⚠️ 基线里那些历史脏项（evidence/ 遗留、`.claude/settings.local.json.bak-*`、`.tad/memory/` 等）
  **不是本单造成的**——集合差手法会自动扣除它们，这正是改用它的理由。
  ⚠️ `comm` 要求输入**全局有序**且 `LC_ALL=C`（见 `shell-portability.md`
  §`comm Silently Lies on Non-Globally-Sorted Input`）——上面的 `sort -c` 是必跑的前置断言，不是装饰。

- AC10: **`--force` 不降级保护存活 + 探测失败分支生效**（针对 v1 的 P0-2 新增）。
  ⚠️ 本 AC 的 harness **必须用 `bash` 跑**：被测代码块含 `[ "$x" == "y" ]`，而本机 Bash 工具
  运行的是 **zsh**，zsh 的 `[` 不认 `==`（实测报 `= not found`，第 4 行即炸）。`tad.sh` 自身是
  bash shebang，用 bash 跑才**匹配生产解释器**——与既有 `bash .tad/hooks/lib/detect-state-test.sh`
  的调用方式一致。其余 AC 是纯文本检查，照常在环境的 zsh 下跑。

⚠️ **不要用 heredoc 构造 harness**：本 AC 嵌在列表项里，`EOS` 终止符不在行首，heredoc 不会结束
  （契约 v2 起草时实际写错过一次）。用下面这个**已实跑验证**的 echo 构造式，逐字照抄：

```bash
cd "<repo-root>"; SH=/tmp/ac10-harness.sh; rm -f "$SH"
{
  echo '#!/usr/bin/env bash'
  echo 'set -u'
  echo 'TAD_SH="$1"'
  echo 'log_warn() { echo "WARN:$*"; }'
  echo 'log_info() { :; }'
  echo 'GREEN=""; YELLOW=""; NC=""'
  echo 'eval "$(sed -n '"'"'/^_tad_ver_cmp() {/,/^}/p'"'"' "$TAD_SH")"'
  echo 'force_gate() {'
  echo '  local ACTION="$1" FORCE="$2" PROBE_OK="$3" CURRENT_VERSION="$4" TARGET_VERSION="$5"'
  sed -n '/^    if \[ "\$ACTION" == "none" \]; then/,/^    fi$/p' tad.sh
  echo '  echo "ACTION=$ACTION"'
  echo '}'
  echo 'echo "A: $(force_gate none 1 0 2.41.0 2.40.0 2>&1)"'
  echo 'echo "B: $(force_gate none 0 0 2.40.0 2.40.0 2>&1)"'
  echo 'echo "C: $(force_gate none 0 1 2.40.0 2.40.0 2>&1)"'
  echo 'echo "D: $(force_gate none 1 1 2.42.0 2.41.0 2>&1)"'
} > "$SH"
# 抽取自检：用块内**稳定存在**的字符串（改前改后都在），不要用会随改动变化的锚
grep -q 'Nothing to do' "$SH" || { echo "AC10-HARNESS-FAIL: 抽取为空"; rm -f "$SH"; exit 1; }
bash "$SH" tad.sh
rm -f "$SH"
```

  ⚠️ 自检锚**不要**写成 `grep -q 'ACTION == "none"'` —— 真实文本是 `"$ACTION" == "none"`，
  中间有引号，该 pattern 恒不匹配；`grep` 退出 1 会让整条 `&&` 链**静默中止、零输出**，
  看上去像「什么都没发生」而不是 FAIL（契约 v2 起草时实际踩到）。
  判据（**看输出文本，不看退出码**——块内含 `exit 0`，在 `$( )` 里只退子 shell，`$?` 不区分）：
  - **AC10a（P0-2 守卫，回归性）**：A 行含 `does not downgrade`，且**不含** `ACTION=upgrade`。
    改前实测已 PASS —— 它的作用是钉住「这次改动没把它弄坏」，不是发现新问题。
  - **AC10b（区分性）**：B 行含 `ACTION=upgrade`。改前实测为「Nothing to do」→ **FAIL**，改后 PASS。
  - **AC10c（快速退出存活，回归性）**：C 行含 `Nothing to do`。改前实测已 PASS。
  - **AC10d（`PROBE_OK=1` 场景下的第二组回归数据）**：`FORCE=1 && PROBE_OK=1 && 本机(2.42.0) >
    目标(2.41.0)` → D 行含 `does not downgrade`。
    ⚠️ **不要声称它验证了「比较用的是探测值而非 L22 字面量」**——增量复核指出这个说法名不副实，
    已改写：harness 把 `TARGET_VERSION` 作为**位置参数**喂进抽取块，全局只有**一个**变量，
    分支代码从内部**观察不到这个值的来历**，所以 D 与 A 走的是完全相同的代码路径、只是换了组数值。
    「比较用的是 probe 覆盖后的值」是 **M3+M4 的结构事实**（单一全局变量 + probe 在状态闸之前原地覆盖），
    不是这个 harness 能独立观察的运行时事实。保留 D 只因它是无害的额外回归数据点。

  ⚠️ 诚实标注：AC10 四条里**只有 AC10b 有区分度**（改前 FAIL / 改后 PASS），a/c/d 是回归守卫。
  不要把四条都算成「验证了修复」。
  ⚠️ AC10a 的拦截力已**双向反证**（增量复核实跑）：把 M6 分支顺序倒回错误版 → A 行变成
  `ACTION=upgrade`、不含 `does not downgrade` → **确凿 FAIL**；换回正确顺序 → 恢复 PASS。
  这条 AC 拦得住它要防的缺陷，不是装饰。

- AC11: **`PROBE_OK` 读取位置不变量**（针对增量复核 P0-4 新增）——`PROBE_OK` 的每一处**读取**
  都必须落在 `ACTION == "none"` 块**内部**。
  ```bash
  TOTAL=$(grep -c '\[ *"\$PROBE_OK"' tad.sh || true)
  INSIDE=$(sed -n '/^    if \[ "\$ACTION" == "none" \]; then/,/^    fi$/p' tad.sh \
           | grep -c '\[ *"\$PROBE_OK"' || true)
  [ "$TOTAL" -ge 1 ] && [ "$TOTAL" -eq "$INSIDE" ] && echo AC11-PASS || echo AC11-FAIL
  ```
  ⚠️ **为什么必须有这条**：AC10 的 harness 用 `sed` 抽取 `ACTION == "none"` 块，
  这隐含假设「修复的全部逻辑都活在被抽取的那一个块里」。该假设对 M6 的逐字规格成立，
  对**结构不同的实现**不成立。增量复核实跑了一个变体——把 `PROBE_OK` 判断挪到块**外面**
  做独立前置块（`if [ "$PROBE_OK" != "1" ] && [ "$ACTION" == "none" ]; then ACTION="upgrade"; fi`）
  ——`sed` 完全看不见它，**AC10a/b/c/d 连同 AC1/2/3/5/6/7/8/9 全部假 PASS**，
  而真实脚本在 `FORCE=1 + 探测失败 + 本机更新` 下**照样静默降级**。
  这是 P0-2 换了个位置藏起来，不是新缺陷。

  双向验证（Alex 独立实跑，2026-08-07）：
  | fixture | TOTAL / INSIDE | 判定 |
  |---|---|---|
  | 符合 M6 规格的正确实现 | 1 / 1 | **PASS** ✅ |
  | 变体 B（判断挪到块外） | 1 / 0 | **FAIL** ✅ 抓到 |
  | 改前 tad.sh（无 `PROBE_OK`） | 0 / 0 | FAIL（不满足 `-ge 1`）—— 符合预期，
    「修复是否存在」是 AC1/AC10b 的职责，不是这条的 |

  ⚠️ 这是**结构不变量**（读取位置必须在指定块内），不是钉死某一行的文本锚；
  复用的是 AC10 已在用的同一个 `sed` 锚点，未引入新脆弱点，也不会在按规格逐字实现的正确版上误 FAIL。
  纯文本检查，在环境的 zsh 下跑即可，不需要 `bash`。

- AC12: **M7（根因修复本体）的行为性验证**（针对增量复核 3 的 P0-5 新增）。
  ⚠️ **为什么必须有这条**：AC2 断言的是 `# ROOT FIX` **这行注释**的位置，**从未读过注释下面的代码**。
  增量复核实跑证实：把 M7 的 if 块整段注释掉、只留一行裸注释 → **AC2 判 PASS**。
  M7 是本单标题里那个「根因修复」本身，在 AC12 之前它是**全单唯一一处完全没有行为性验证的核心逻辑**
  ——比 P0-4 覆盖的 M6 安全网路径更根本。

  ```bash
  cd "<repo-root>"; SH=/tmp/ac12-harness.sh; rm -f "$SH"
  {
    echo '#!/usr/bin/env bash'
    echo 'set -u'
    echo 'TAD_SH="$1"'
    echo 'log_info() { :; }'
    echo 'GREEN=""; NC=""'
    echo 'eval "$(sed -n '"'"'/^_tad_ver_cmp() {/,/^}/p'"'"' "$TAD_SH")"'
    echo 'root_fix_gate() {'
    echo '  local FORCE="$1" CURRENT_VERSION="$2" TARGET_VERSION="$3" TAD_SRC="/tmp/ac12-nonexist-$$" ACTION="upgrade"'
    sed -n '/^    # ROOT FIX/,/^    fi$/p' tad.sh
    echo '  echo "PROCEEDED"'
    echo '}'
    echo 'echo "eq_noforce   : $(root_fix_gate 0 2.40.0 2.40.0 2>&1)"'
    echo 'echo "newer_noforce: $(root_fix_gate 0 2.41.0 2.40.0 2>&1)"'
    echo 'echo "older_noforce: $(root_fix_gate 0 2.39.0 2.40.0 2>&1)"'
    echo 'echo "eq_force     : $(root_fix_gate 1 2.40.0 2.40.0 2>&1)"'
    echo 'echo "fresh_none   : $(root_fix_gate 0 none 2.40.0 2>&1)"'
  } > "$SH"
  grep -q '# ROOT FIX' "$SH" || { echo "AC12-HARNESS-FAIL: 抽取为空"; rm -f "$SH"; exit 1; }
  bash "$SH" tad.sh
  rm -f "$SH"
  ```
  判据：`eq_noforce` / `newer_noforce` 含 `Nothing to do`；
  `older_noforce` / `eq_force` / `fresh_none` 含 `PROCEEDED` 且**不含** `Nothing to do`。
  用 `bash` 跑（`_tad_ver_cmp` 用了 bash 数组，同 AC10 的既有理由）。
  `TAD_SRC` 指向不存在的临时路径，使 M7 里的 `rm -rf "$TAD_SRC"` 成为无害 no-op。

  三向验证（Alex 独立实跑，2026-08-07，三个 fixture 互相印证）：
  | fixture | eq_noforce | newer_noforce | older_noforce | 判定 |
  |---|---|---|---|---|
  | 按 M7 规格的正确实现 | Nothing to do | Nothing to do | PROCEEDED | **PASS** ✅ |
  | 条件反写（`!= "-1"` 手滑成 `== "-1"`） | PROCEEDED | **PROCEEDED**（该拒降级却放行） | **Nothing to do**（**原始 bug 原样复现**：该升级却谎称已最新） | **FAIL** ✅ 抓到 |
  | 逻辑被注掉、只留裸注释 | PROCEEDED | PROCEEDED | PROCEEDED | **FAIL** ✅ 抓到（而 AC2 对它是绿的） |

  改前基线：`tad.sh` 无 `# ROOT FIX` → harness 自检先 `AC12-HARNESS-FAIL` → 天然有区分度。

### AC 空跑记录（2026-08-07，本机实跑，非推演）

| 项 | 实测 | 含义 |
|---|---|---|
| `^    probe_remote_version$` | 0 | AC1 改前必 FAIL ✅ 有区分度 |
| `D=1549` / `X=1552` / `N=2` / `R`=空 | — | AC2 改前必 FAIL ✅（**已修正**：`case $ACTION in` 有两处，原写法恒 FAIL） |
| sed 抽函数→`source`→桩 `curl` 覆盖 | 通过（zsh 子 shell 内桩生效，返回 `2.99.0`） | AC3 手法可行 ✅ |
| 正则对 `2.99.0`/HTML/空串 | ACCEPT / REJECT / REJECT | AC3c 挡得住 ✅ |
| ~~`elif [ "$FORCE" = "1" ]` / `if [ "$PROBE_OK" != "1" ]` = 0 / 0~~ | **作废** | AC4 已于 v3 退役（见 P0-3），此行不再有效 |
| `detect-state-test.sh` | `TALLY: PASS=12 FAIL=0` | AC5 基线 ✅ |
| `can never go stale` / `state gate` | 2 / 0 | AC6 双向均有区分度 ✅ |
| `^TARGET_VERSION="2.40.0"$` | 1 | AC7 基线 ✅ |
| `bash -n tad.sh` | exit 0 | AC8 基线 ✅ |
| ~~`git status --short \| wc -l` = 21~~ | **作废** | AC9 v1 用绝对数；复审时实测已变为 22 → 改用 `comm` 集合差 |

### AC 空跑记录 · 第二轮（2026-08-07，v2 修订后，本机实跑）

| 项 | 实测 | 含义 |
|---|---|---|
| AC9 `comm -13` / `comm -23`（模拟只改 tad.sh） | ` M tad.sh` / 空 | 集合差正确隔离出唯一新增项，**不受 22 项历史脏项影响** ✅ |
| AC9 `LC_ALL=C sort -c` 前置断言 | 通过 | `comm` 输入全局有序已验证 ✅ |
| AC10 harness（echo 构造式 + bash 执行） | 构造 1366 字节、`bash` 退出 0 | 手法可行 ✅ |
| AC10a（A 行，改前） | `does not downgrade` **在** | 回归守卫，改前已 PASS |
| AC10b（B 行，改前） | `Nothing to do` | **改前 FAIL ✅ 唯一有区分度的一条** |
| AC10c（C 行，改前） | `Nothing to do` **在** | 回归守卫，改前已 PASS |
| zsh 下直接跑抽取块 | `force_gate:4: = not found` | 证实必须用 `bash`；zsh 的 `[` 不认 `==` ✅ |
| 自检锚 `grep -q 'ACTION == "none"'` | 命中 0 → `&&` 链静默中止、零输出 | 已改用 `Nothing to do` 作锚 ✅ |

### AC 空跑记录 · 第三轮（2026-08-07，v3 修订后，本机实跑）

| 项 | 实测 | 含义 |
|---|---|---|
| AC4 的 `K` pattern 对 `elif [ "$PROBE_OK"…` 行 | **命中**（子串 `if [` 在 `elif [` 内） | 无 `^` 锚点的误命中已实证 → AC4 退役依据 ✅ |
| AC4 的 `F` pattern `elif \[ "\$FORCE"…` | 0 | 修订后不存在 → AC4 恒 FAIL 已实证 ✅ |
| AC10d（D 行，改前） | `does not downgrade` **在** | 回归守卫，改前已 PASS ✅ |
| AC9 暂存态前缀差异 | `" M tad.sh"` vs `"M  tad.sh"` 字节不同 | 判据改为「只有一行且指向 tad.sh」✅ |

## 知识引用

- `.tad/project-knowledge/patterns/shell-portability.md` §`Prefix-Glob Version Routing Goes Stale; Verify What the ACTION Branches Actually DO` — 同一个 `detect_state`、同一类「陈旧判定」；其 (c) 条要求先读 ACTION 分支再声称价值 → 已照做：M7 落在 `case $ACTION` 之前，不改任何分支行为。
- `.tad/project-knowledge/patterns/shell-portability.md` §`grep No-Match in Command Substitution Under set -e Triggers ERR Trap` — 就发生在 `tad.sh` 自己身上 → M3 的 `|| true` 是必需项，不是保险。
- `.tad/project-knowledge/patterns/shell-portability.md` §`The Bash Tool Runs zsh, Not bash` — AC 全部按 zsh 语义写；reviewer 报 `bash --version` 一律视为**已安装**解释器而非**运行中**的。
- `.tad/project-knowledge/patterns/shell-portability.md` §`ugrep Host: Fixed-String Patterns Starting with '-' Require -e` — 本单所有 AC 模式均不以 `-` 开头，已逐条核对。
- `.tad/project-knowledge/patterns/ac-verification.md` §`A Guard Added to Repair a Guard Does Not Inherit the Original's Dry Run` — 本单是「修复的修复」，AC1/AC6 基线已在本机实跑（0 / 2），未继承任何旧结论。
- `.tad/project-knowledge/patterns/release-sync.md` §`Identity Early-Exits Blind Downstream Checks` — 同构：早退把下游检查变成死代码。本单的早退（L1484 exit 0）正是这一类；修法一致——把真正的判定放在早退**之前的真值可得点**。
- `.tad/project-knowledge/principles.md` §`Deny-List Beats Allow-List for Sync Sets` — 载体：其中记录的「tad.sh 卡在 2.19.1」即本缺陷第一次发生。

## Contract Review (2026-08-07)

Reviewer: code-reviewer (独立上下文 subagent) | model=claude-sonnet-5, harness=Claude Code Agent tool, route=subagent
首轮 verdict: **CONDITIONAL**
增量复核 (2026-08-07): **CONDITIONAL** —— P0-1/P0-2/P1-1/P1-2 修订全部核验通过（逐条实跑，
含 AC10a 的**双向反证**：错误版 M6 → A 行 FAIL；正确版 → PASS），但新发现 **P0-3**（见下）。
覆盖改动：M6 分支顺序对调 + AC10 新增 + AC9 改集合差 + M7/风险 #2 措辞 + P2×3。
增量复核 2 (2026-08-07): **CONDITIONAL** —— AC4 退役理由独立复算成立；AC9 措辞已足（rename /
mode change / 目录折叠 / merge conflict 四种形态逐一核过）；但**变体专项测试挖出 P0-4**（见下），
且指出 **AC10d 名不副实**（已改写措辞）。
增量复核 3 (2026-08-07): **CONDITIONAL** —— 按要求把「变体 B 透镜」逐条套过全部 11 条现行 AC，
一次性系统扫描而非逐个变体试探。结论：AC3/AC5/AC8/AC9/AC10(FORCE 镜像)/AC11 **实测无缺口**；
AC6/AC7 有理论缺口但需实现者违背白纸黑字规格才能触发 → 按既定红线**不加 AC**，标 P2；
真正需处理的两条：**P0-5（AC12）** 与 **P1（AC1 追加 `MN < P`）**，均已双向实跑验证。
最终 verdict: **CONDITIONAL（全部 P0 已修）+ 人工拍板放行**
人工拍板 (2026-08-07): 用户选择「直接实现」，**未跑第四次增量复核**。
偏离已在下方「放行判断」显式记录并向用户完整披露（含四轮命中率与协议要求），用户知情后仍选放行。
剩余风险移交 blake-lite 的实现后独立审查承担。
P0=5(fixed), P1=3(fixed), P2=10(9 fixed / 1 记入完成报告);
已审 AC 条数: 9 → 10 → 9（AC4 退役）→ 10（AC11）→ **11**（AC12）

关键发现:
- **P0-1 AC9 钉死绝对计数**：契约写「改前 21 / 改后 22」，reviewer 实测当场已是 22 —— 起草到实现
  之间仓库仍在变动，绝对数即刻失真，会在改动**完全正确**时假 FAIL，重演本单自己列出的
  「连续 3 单假 FAIL」历史。且这正是 `principles.md` §`Deny-List Beats Allow-List for Sync Sets`
  已沉淀的 "Never pin an absolute count — assert set-equality live"——**v1 引用了该条却没用在自己身上**。
  → 改为当场 BEFORE/AFTER 快照 + `LC_ALL=C comm` 集合差（已实跑验证）。
- **P0-2 M6 分支顺序静默打掉 `--force` 不降级保护**：全文件唯一一处降级保护在 L1480，仅在
  `ACTION=="none" && FORCE=="1"` 时可达。v1 把 `PROBE_OK != 1` 排在最前 → 探测一失败即无条件命中，
  `--force` 分支整个被跳过；M7 又以 `FORCE != 1` 开头同样跳过；upgrade 分支无第二道版本比较
  → **`--force` + 探测失败 + 本机更新 = 静默降级**。9 条 AC 无一能拦。reviewer 用逐字代码现场复现。
  → 分支顺序对调（`--force` 最前）+ 新增 AC10。
- P1-1 M7 注释的机制描述不准（探测成功时判定其实发生在 M7 之前）→ 已改写。
- P1-2 风险 #2「只在下载也会失败时才会失败」不成立：`raw.githubusercontent.com` 与
  `codeload.github.com` 是两个独立端点 → 探测失败分支**会真实发生**，这正是 P0-2 值得当 P0 的理由。
- 知识引用 7 条逐条开文核对，**全部真实存在且 implication 与原文一致**，无「只读标题」问题。

- **P0-3（增量复核发现）AC4 未随 M6 顺序对调一起改，在正确实现上 100% FAIL**：AC4 编码的是 v1 的
  错误顺序。`K` 的 pattern 无 `^` 锚点，`elif [` 含子串 `if [` → 误命中；`F` 的 `elif FORCE` 在
  修订后不存在 → 空 → `integer expression expected` → 整条 FAIL。
  **真正的危险不是它会 FAIL，是实现者可能"照 AC 改代码"把分支顺序改回去，重新引入 P0-2 的静默降级。**
  → **退役 AC4**（非改写）：它没有独立失败模式，顺序由 AC10a 行为性覆盖、存在性由 AC10b 覆盖，
  两者都比文本锚强且不受子串误判影响。按约束准入默认动作（无独立载体即删除）处理。
  ⚠️ 这是「修 M6 时没回头核对依赖 M6 内部结构的旧 AC」——与下方 Alex 自查的两条同属
  `ac-verification.md` §`A Guard Added to Repair a Guard Does Not Inherit the Original's Dry Run`，
  **本单一天内第三次踩同一条**。

- **P0-4（增量复核 2 发现）AC10 对「逻辑挪出被抽取块」的结构变体完全失明**：AC10 的 harness 用
  `sed` 抽取 `ACTION == "none"` 块，隐含假设「修复的全部逻辑都活在那一个块里」。reviewer 实跑了
  变体 B（把 `PROBE_OK` 判断挪到块外做独立前置块）：`sed` 看不见它 →
  **AC10a/b/c/d 连同其余全部 AC 一律假 PASS**，而端到端实跑证实真实脚本在
  `FORCE=1 + 探测失败 + 本机更新` 下**照样静默降级**——P0-2 换了个位置藏起来。
  → 新增 **AC11**（`PROBE_OK` 读取位置不变量），Alex 独立双向实跑验证：
  正确实现 `1/1` PASS、变体 B `1/0` FAIL。结构不变量而非文本锚，复用 AC10 已有的 sed 锚点。
  ⚠️ **这条的方法论意义大于本单**：一个基于「抽取某个块」的验证，其有效性上限是
  「被验证的逻辑确实在那个块里」——而这恰恰是它无法自证的前提。

- **P0-5（增量复核 3 发现，四轮里最根本的一条）AC2 是「注释位置检查」冒充「逻辑位置检查」**：
  AC2 只断言 `# ROOT FIX` **这行注释**的行号落在区间内，**从未读过注释下面的代码**。
  实跑证实：把 M7 的 if 块整段注释掉、只留裸注释 → **AC2 判 PASS**。
  而 M7 正是本单标题里那个「根因修复」本身——**全单最核心的一段逻辑，此前零行为性验证**。
  → 新增 **AC12**（M7 行为性 harness）。Alex 独立三向实跑：正确实现 PASS；
  条件反写（`!=` 手滑成 `==`）→ **原始 bug 原样复现**（`older_noforce` 输出「已是最新」）→ FAIL；
  逻辑被注掉 → 五项全放行 → FAIL。
  ⚠️ 与 P0-4 合起来构成本单最大的方法论收获：**「注释/标记在正确位置」≠「逻辑在正确位置」，
  「逻辑在被抽取的块里」也不是抽取式验证能自证的前提。**

### 放行判断（Alex，交人裁定）

**未跑第四次增量复核。** 理由与风险都摆在这里，由人决定：
- 支持放行：本轮是**系统性扫描**（11 条 AC 逐条过筛）而非逐个变体试探，reviewer 明确表示
  「这两条落地后这一类盲区已排查干净」；AC12 与 AC1 追加判据均为 reviewer 逐字给出，
  且 **Alex 已独立三向/双向实跑复验**（不是照抄未验）。
- 支持再审：**四轮四次都抓到了真缺陷**，其中三次是「验证本身失效」而非「代码写错」。
  按这个命中率，第五轮的期望收益并不低。协议也确实要求 P0 修完后回同 reviewer 增量复核——
  **本次跳过是协议偏离，在此显式记录，不作辩解。**
- 成本事实：四轮契约审查累计约 810k subagent token，而 `tad.sh` 至今**一字节未改**。

Alex 修订时自行发现的第 3 类缺陷（不在 reviewer 报告内）:
- AC10 v1 用 heredoc 构造 harness，`EOS` 终止符在列表缩进内不在行首 → heredoc 不终止。
- AC10 v1 自检锚 `grep -q 'ACTION == "none"'` 恒不匹配（真实文本含引号 `"$ACTION" == "none"`），
  `grep` 退出 1 使整条 `&&` 链**静默中止、零输出**——伪装成「什么都没发生」而非 FAIL。
- 两者均为「修复动作不继承被修复对象的空跑」的实例，已按 `ac-verification.md`
  §`A Guard Added to Repair a Guard Does Not Inherit the Original's Dry Run` 就地重跑修正。

## 风险与注意

1. **受众是 14 个下游项目**。`tad.sh` 是安装器；改错的代价是别人装不上或静默不升级。本单不触发
   发布——改动随下次 `*publish` 才生效，届时受安全停清单第 1 条约束（需人授权）。
2. **新增一次网络调用**，与「删机制优于加机制」相悖。诚实计价：失败方向是「多下一次」而非
   「静默不升级」，且 M7 在探测失败时提供真正的兜底。
   ⚠️ **不要说「它只在下载也会失败时才会失败」**——契约 v1 这么写过，Contract Review 指出不准确：
   探测走 `raw.githubusercontent.com`，下载走 `github.com/.../archive/`（实际经 `codeload.github.com`），
   是**两个独立的服务端点/CDN**，各有各的可用性与限流窗口，一个挂不蕴含另一个挂。所以探测失败分支
   **不是近乎不可达**，是**会真实发生**的——这也正是 P0-2（那条分支上的降级缺陷）值得当 P0 处理的原因。
   这条取舍在设计速写阶段已向人明示并获选定（方案 A vs B）。
3. **`raw.githubusercontent.com` 有 CDN 缓存**（通常数分钟）。刚发布后的极短窗口内探测可能仍返回
   旧版本 → 状态闸判为 current → 快速退出 → 下游延后几分钟才升级。**不会静默永久不升级**
   （下次运行即纠正），且比今天「忘改字面量就永久冻结」严格更好。不在本单处理。
4. **caller/consumer 检查（有界，已做）**：`TARGET_VERSION` 在 `tad.sh` 内共 26 处引用
   （实跑 `grep -n TARGET_VERSION`）。本单只改**赋值时机**，不改任何读取点语义；唯一新增读取者是
   M7。跨文件消费方只有一个：`.tad/hooks/lib/release-verify.sh` 的 `MUST_VERSION_PATTERNS`
   锚定 `tad.sh|TARGET_VERSION="x.y.z"` —— AC7 专门保住这个锚点。
   `.tad/hooks/lib/detect-state-test.sh` 通过 `sed` 抽取消费 `detect_state` 与 `case $STATE`
   两个块 —— AC5 专门保住。**两个消费方均已采样确认，无第三方。**
5. **本单不改 `release-verify.sh`**。那道 BLOCKING 门今天确实抓到了陈旧字面量，是有效的纵深防御，
   保留。目标是让它从「唯一防线」退居「第二道防线」。
6. 探测正则 `^[0-9]+\.[0-9]+\.[0-9]+$` 是**采信前的验证**，不是格式美化。缺了它，一个 404 HTML
   页面会成为 `TARGET_VERSION` 并被写进下游 `.tad/version.txt`。AC3c 专门打这一点。
7. **M5 顺带修了一个契约范围外的既有缺陷**：L1475 的 `--force` 比较此前一直用**未裁剪**的
   `CURRENT_VERSION`（`detect_state` L1349 裁了，这里没裁，两处对同一个值口径不一致）。M5 补齐后
   两处一致。这是有益副作用，但**必须在完成报告里显式记一笔**，否则日后会被当成意外改动。
8. **展示层短暂不一致（已知，不处理）**：L1443/1449/1454/1459 的「Show what will happen」预览用的是
   探测值；若探测命中 CDN 缓存旧值，预览显示的目标版本可能与最终实际安装的（M7 之后由
   `derive_target_version` 二次覆盖）不同。纯展示层，非正确性问题。完成报告提一句即可。

## Lite Progress

- Phase=admission | handoff=LITE-20260807-1050-tadsh-version-authority.md | 准入=L0.5 契约复查全过（11==11，CONDITIONAL 放行，P0=5(fixed)）；安全停清单=未命中（不改 hooks/SAFETY 面/全局注册面；不发布不 commit 不 push） | verdict=RUNNING | Next Action=L1 实现
- Phase=implement | 改动=tad.sh 8 处（M1 注释/M2 VERSION_URL/M3 PROBE_OK+probe/M4 调用/M5 CRLF 裁剪/M6 三分支/M8 注释/M7 ROOT FIX） | 最后一个 AC=— | Next Action=L2 AC 自验 | 错误类别=无 | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md
- Phase=ac | 结果：AC1-AC12 全 PASS（11 条执行，AC4 退役跳过；AC3 三载荷/AC5 12-0/AC10 a-d/AC12 五向 harness 全过） | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md | Next Action=L3 独立审查
- Phase=review | 结果：code-reviewer PASS（P0=0 P1=0 P2=3 记录类）；核心场景 S1 端到端实证（探测失败+字面量陈旧 → 真实升级）；AC10a 反向拦截力独立复现 | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md | Next Action=L3.5 Technical Gate
- Phase=technical-gate | 结果：GATE PASS（AC/evidence 全绿 / reviewer PASS / friction 无 BLOCKED / scope 仅 tad.sh + journal 豁免 / Knowledge Assessment=journal captured + candidate for distillation） | repair_round=0/3 | same_error_count=0/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md + .tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md | Next Action=人验收（L5）→ 归档；commit 归人决定

## Completion (2026-08-07)

**Commit**: uncommitted（零 git 写操作；commit 归人决定）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped)
- 上下文刷新：shell-portability.md（grep No-Match / rm Chokepoint / zsh-not-bash / comm / ugrep 段）、ac-verification.md §A Guard Added to Repair、release-sync.md §Identity Early-Exits、principles.md §Deny-List（上下文内）；tad.sh 目标区域 L17-37 / L1340-1360 / L1408-1500 / L1535-1560 / L1818-1832 | 关键约束：M6 `--force` 分支排最前（承重顺序）；M7 逐字；AC10/AC12 必须 bash 跑；AC9 当场快照不钉绝对数；零 git 写操作 | 成功条件：AC1-AC12 全绿 + reviewer PASS + 根因修复端到端实证
- 改动文件：tad.sh（唯一，8 处 M1-M8；AC9 集合差实证新增恰 1 项）[清单外：无]；证据产物 .tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md
- AC 结果：
  - AC1 ✅ MN=1401 < P=1440 < S=1441（探测调用在 main() 后、状态闸前）
  - AC2 ✅ D=1578 < R=1581 < X=1592、N=2（ROOT FIX 在 derive 后、分派前；case 仍两处）
  - AC3 ✅ 三载荷全过（2.99.0 覆盖 / curl 7 不动 / 404 HTML 被正则拦截）
  - AC5 ✅ TALLY: PASS=12 FAIL=0（detect_state 形状未破坏）
  - AC6 ✅ N=0（can never go stale 清零）、M=2（state gate 锚存活）
  - AC7 ✅ ^TARGET_VERSION="2.40.0"$ == 1（字面量与发布闸锚点存活）
  - AC8 ✅ bash -n exit 0；numstat 43/3（结果文件计，Alex 复核以再跑为准）
  - AC9 ✅ comm -13 仅 ` M tad.sh` 一行、comm -23 空（集合差，无硬编码计数）
  - AC10 ✅ A=does not downgrade 无 ACTION=upgrade / B=upgrade / C=Nothing to do / D=does not downgrade（bash harness）
  - AC11 ✅ TOTAL=1 INSIDE=1（PROBE_OK 读取位置不变量）
  - AC12 ✅ eq/newer→Nothing to do；older/eq_force/fresh→PROCEEDED（bash harness）
  - AC4 退役（v3），未执行
  - 全部原始输出：.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md
- Reviewer: PASS | model=deepseek-v4-flash（subagent 自报）| P0=0, P1=0, P2=3（记录类）
  摘录关键发现（执行实证）：「根因修复端到端生效（核心场景 S1）：集成模拟——探测失败 + 字面量 2.40.0 陈旧 + 本机 2.40.0 + 真实源树 2.41.0 → FINAL_ACTION=upgrade（改前此场景静默不升级）。**本单标题级目标实证达成。**」「AC10a 拦截力独立反证：构造 v1 错误分支顺序变体 → A 行 ACTION=upgrade、无 does not downgrade → 判据 FAIL」；「|| true 是功能性的：bash+set -euo pipefail 下无 || true 时 curl 失败 → 退出 7 → set -e 终止」；S2 不降级 / S3 继续安装均实证。
  P2×3（均执行实证/阅读推断标注在报告内）：多行 version.txt 裁剪为连接（既有行为，fail-safe，不改）/ 高段垃圾版本判已最新（既有行为，非回归）/ AC3 shim 无 pipefail 上下文（已由 reviewer 探针补验）。
- Technical Gate: GATE PASS（AC/evidence 全绿 + reviewer PASS 无 P0/P1 + friction 无 BLOCKED + scope 限于 tad.sh 且 caller/consumer 已检查——契约风险 #4：TARGET_VERSION 26 处引用、release-verify.sh 与 detect-state-test.sh 两消费方由 AC7/AC5 保住 + Knowledge Assessment 三态已标记）
- Knowledge Assessment: journal captured（.tad/evidence/journal/lite-discoveries.md 追加 1 行）+ candidate for distillation（「四轮契约审查 5 P0 全属验证本身失效 → 实现 0 repair 一次通过」是验证设计方法的极端案例）
- 意外发现：无（契约审查已穷尽）——顺带修复的契约范围外既有缺陷（风险 #7：--force 比较用未裁剪 CURRENT_VERSION）已在 ac-results.md 显式记录
- follow-up：
  - P2-1 多行 version.txt 裁剪连接（既有行为，fail-safe 方向）| owner=Alex-Lite
  - P2-2 `_tad_ver_cmp` 首段非数字 fail-safe 加固（可选，超本单范围）| owner=Alex-Lite
  - P2-3 AC3 shim 加 set -euo pipefail 上下文（验证强度建议）| owner=Alex-Lite
  - 风险 #8 展示层预览短暂不一致（已知，不处理，实现后依旧成立）| owner=Alex-Lite
  - 本单改动随下次 `*publish` 才生效（安全停清单第 1 条，需人授权）| owner=人
  - 未触碰 settings.local.json / violations.log / hooks（盲区显式声明）

## Reflexion

无修复（repair_round=0/3）。四轮契约审查抓出的 5 个 P0 全是「验证本身失效」而非实现缺陷——审查修的是验证设计，实现照逐字规格一次通过。验证：规格写到照抄粒度（含 `--force` 排最前这类承重顺序）+ 行为性 harness（AC10/AC12）比文本锚可靠，实现者没有发挥空间就不会写错。

## Human Acceptance (2026-08-09)

- Verdict: **ACCEPTED**
- Human decision: 用户选择「验收当前 `tad.sh` 技术成果并归档；完成知识闭环后设计 10 分收尾 handoff」。
- Phase=human-gate | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/tadsh-version-authority/ac-results.md + .tad/evidence/reviews/blake/tadsh-version-authority/code-reviewer.md | Next Action=Knowledge Closeout → archive

## Knowledge Closeout (2026-08-09)

- Variabilize: PASS——项目特定的 `tad.sh` 行号已参数化为「抽取边界 / 结构不变量 / 行为 fixture」。
- Provenance: PASS——Completion、AC 证据、独立 reviewer 报告与 raw journal 均有路径载体。
- Distilled: `.tad/project-knowledge/patterns/ac-verification.md` §`An Extracted Harness Cannot Prove Its Own Extraction Boundary`。
- Index updated: `.tad/project-knowledge/patterns/_index.md` AC Verification 摘要。
- SAFETY authorization: 用户于 2026-08-09 选择选项 1，明确授权更新上述知识条目与 SAFETY 索引。
