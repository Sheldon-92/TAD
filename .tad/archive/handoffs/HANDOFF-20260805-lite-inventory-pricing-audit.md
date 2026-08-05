# HANDOFF: 修复台账扫描的日期范围静默漏（Epic P1b-1）

**Date**: 2026-08-05 | **Version**: v4（v1/v2/v3 均被 Gate 2 判 FAIL 并作废，见 §6）
**From**: Alex (Terminal 1) | **To**: Blake (Terminal 2)
**Epic**: `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` Phase 1b-1
**Channel**: full（命中升级清单第 2 类：改 `.claude/skills/*/SKILL.md`）
**规模**: 4 个文件各改 1 行。**这是本单的全部。**

---

## 1. 目标

台账超期扫描的主正则 `[0-9]{2}` 只校验位数不校验取值，导致：

```
PROVISIONAL: review-by 2027-13-99   →  既不 OVERDUE 也不 MALFORMED，完全静默
```

根因两条叠加：正则接受 13 月 / 99 日；字典序下 `2027-13-99` > 今天，判为未超期。
**Gate 4 已独立复现**（2026-08-05，非单方报告）。

**触发面**：当前台账 0 数据行，不可触发；**写入第一批 PROVISIONAL 行后即可触发**。

---

## 2. 不做什么

- **不回填台账**。原计划的「39 行存量审计」已取消（用户 2026-08-05 裁定）——
  台账随 P2/P3/P5 自然生长：P2 砍 4 条时写那 4 行，P3 写 3 行，闸本来就强制新增约束写一行。
- **不改除 §3.0 与 §3.1 那两处以外的任何文本。** AC1 的 md5 会逐字节抓住。
- **台账仍保持 0 数据行**——§3.0 改的是前言散文，不是数据行。
- 不 commit、不 push。

---

## 3. 规格：两处改动（4 个 skill 各 1 行 + 台账前言 1 行）

### 3.0 台账前言的过时陈述（reviewer P2-4，必须一并修）

`.tad/evidence/audits/lite-constraint-ledger.md` 第 6 行现在写着：

```
> 存量 34 节的回填审计由 P1b 完成。
```

**这句已经是假的**——整批回填已于 2026-08-05 取消（§2）。留着会让六个月后的人以为
台账"本该有 39 行、只是没人做"，而实际是**刻意改成随 Epic 自然生长**。
这正是本 Epic 反复在防的那类误读。

**替换为**（两行）：

```
> P1b-2 已完成 7 条 DEEP 约束的载体判定（见 P1b-deep-verdicts.md）；整批回填已取消，
> 台账随 P2/P3/P5 自然生长——砍除时写该行，新增约束时由闸强制写一行。
```

⚠️ 这是**前言散文，不是数据行**——不触发「追加台账行前先扫」的前置义务（台账仍 0 数据行）。

### 3.1 skill 的正则改动

两个 skill 及其 `.agents/` 镜像，共 4 个文件，「约束准入」节内**各替换一行**。

**被替换的行**（当前每份文件中恰好出现 1 次，已实测）：

```
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
```

**替换为**：

```
    if (match($0, /PROVISIONAL: review-by [0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]*\|?[[:space:]]*$/)) {
```

**四个文件**：

```
.claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
```

`.agents/` 两份可直接改，也可改完 `.claude/` 后跑
`bash .tad/hooks/lib/release-verify.sh parity --fix`（爆炸半径已验：仅这 2 个文件）。

**parity 是白拿的**（reviewer 实证 + Alex 复核）：`.claude` 与 `.agents` 两对文件在 HEAD
**逐字节相同**（alex-lite `13c1102e…` / blake-lite `d9e4604b…`）。故 AC1（四份节相同）
+ AC2（各仅 1 增 1 删）**连带保证**改后 parity —— `parity --fix` 可省，跑了也无害。

**范围完整性**（reviewer 实证 + Alex 复核）：全仓 grep 旧正则共 9 处命中，
除这 4 个文件外全在 `.tad/evidence/acceptance-tests/pricing-gate-scan-fix/` 下
（上一单冻结的证据产物，非活的扫描器）。**没有第 5 处活副本，4 文件范围正确。**

#### 3.1.1 不得改动的三处不变量

1. **`substr($0, RSTART+23, 10)` 的 +23 偏移**——前缀 `PROVISIONAL: review-by ` 长度未变。
2. **前置过滤行**（大小写不敏感 + 全/半角冒号）。
3. **`else` MALFORMED 分支**——非法日期现在应落进这里，这正是修复目的。

三条都由 AC1 的整节 md5 保证（改任何一处 md5 即变）。

### 3.2 目标正则的语义已由 Alex 实测（10 个用例，2026-08-05）

| 输入 | 结果 | 说明 |
|---|---|---|
| `2027-13-99` `2027-13-01` | MALFORMED | 月非法 |
| `2027-01-99` `2027-01-39` `2027-01-32` `2027-01-00` | MALFORMED | 日非法（含 reviewer 指出的 32–39 与 00 区间） |
| `2027-00-15` | MALFORMED | 月 00 |
| `2024-01-01` | OVERDUE | 合法且已过期——**正向控制，防「全判 MALFORMED」的过度收紧** |
| `2027-12-31` | 静默 | 合法未过期——**兼验 +23 偏移未被破坏** |
| `2027-02-29` `2027-02-31` | 静默 | ⚠️ 见下方已知边界 |

⚠️ **已知边界（措辞按 reviewer 实证更正）**：本正则**不校验月日组合**——
**2 月 29–31 日、以及 4/6/9/11 月的 31 日，全部放行。** 不只是闰年问题。

这是刻意接受的残余：完整校验需在 awk 里写月份表 + 闰年判断，成本远超它挡住的失败
（把 review-by 写成 2 月 30 日）。**不要在实现时"顺手补上"** —— 理由见 §3.3。

### 3.3 裁定：本单是「修复」不是「新增约束」（Alex 2026-08-05）

对抗 reviewer 提了一个本单必须回答的问题：把 `13 月 / 99 日` 从**静默放行**改成
**MALFORMED（须人工处置）**，这**扩大了一个 BLOCKING 的触发面**——原来能过的台账行现在会被拦。
那它算不算「新增约束」？若算，按「约束准入」节自己的规矩就得先在台账写一行；
而 §2 又说本单不回填台账。**闸和 AC 会正面打架。**

**裁定：不算新增约束，不占台账行。**

**判据**（写下来，下次才有得 grep）：
> **未扩大约束的「意图」范围，只修复「实现」与「意图」的偏离 → 属修复，不占台账行。
> 扩大意图范围 → 属新增，须过闸。**

本单适用：「约束准入」节的意图始终是「PROVISIONAL 行必须带一个合法的到期日，
非法格式须人工处置」——`2027-13-99` 本就该被拦，只是实现漏了。意图未变。

反例（同一把尺）：给它补闰年 / 月日组合校验，**属于扩大意图范围**
（从「格式合法」扩到「日期真实存在」）→ **须过闸**，故 §3.2 明令不许顺手补。

---

## 4. Acceptance Criteria（3 条，Alex 已在零改动仓库实跑）

### AC1 — 四份文件的「约束准入」节逐字节等于目标

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
sect() { awk '/^## 约束准入/{f=1} f&&/^## Forbidden/{exit} f{print}' "$1"; }
ac1=0
# ⚠️ 字面量词表，不得改成 for f in $VAR —— 本机是 zsh，未加引号展开不分词（见 §5）
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  h=$(sect "$f" | md5); n=$(sect "$f" | wc -l | tr -d ' ')
  if [ "$h" = "47fd564853125c418195b5713c57b1e6" ] && [ "$n" -eq 70 ]; then
    echo "OK   $f  ($n 行, md5 一致)"
  else
    echo "AC1 FAIL $f  行数=$n(期望70) md5=$h"
    echo "         期望 md5=47fd564853125c418195b5713c57b1e6"
    ac1=1
  fi
done

# §3.0 台账前言：整文件 md5（台账只有 10 行，直接钉全文）
L=.tad/evidence/audits/lite-constraint-ledger.md
lh=$(md5 -q "$L"); ln=$(wc -l < "$L" | tr -d ' ')
lrows=$(awk -F'|' '$2 ~ /^ *[0-9]{4}-[0-9]{2}-[0-9]{2} *$/' "$L" | wc -l | tr -d ' ')
if [ "$lh" = "a81fde7d53829dc1b91b987fd4a6add9" ] && [ "$ln" -eq 10 ] && [ "$lrows" -eq 0 ]; then
  echo "OK   $L  ($ln 行, 0 数据行, md5 一致)"
else
  echo "AC1 FAIL $L  行数=$ln(期望10) 数据行=$lrows(期望0) md5=$lh"
  echo "         期望 md5=a81fde7d53829dc1b91b987fd4a6add9"
  ac1=1
fi

[ $ac1 -eq 0 ] && echo "AC1 PASS" || echo "AC1 FAIL"
```

**台账那条同时钉了「0 数据行」**：§2 要求台账保持空表，md5 已隐含此约束，
但显式断言让 FAIL 信息能直接指出是哪种偏离。
基线：修改前台账 9 行、md5 `a592d8d4508a1d9f47b7bd947fe9526a` → **AC1 在零改动仓库必 FAIL**。

**为什么用整节 md5 而不是 grep 行 / 抽取执行**：

- v3 的 AC1 把 skill 里的 awk 块**抽取出来 eval**。对抗 reviewer 实证：抽取器的终止行是
  **先打印再退出**，而那一行正好是 shell 命令的结尾（awk 的文件参数）——在哨兵后追加
  `; printf 'MALFORMED...'` 即可注入 payload，**节内限定与计数断言两道防线都只守入口，攻击搬到了出口**。
  正则一个字未改而 AC 全绿。**让被验证物执行任意代码，本身就是错的验证方式。**
- v3 的 5 个探针也被打靶：加一个 `&& $0 !~ /-13-|-99 /` 子句即可全过。**探针是枚举，枚举可被反制。**
- 整节 md5 没有入口/出口之分，没有可枚举的靶。**规格是一段确定文本，验证就该是逐字节比对。**
  （P1a Gate 3 的 spec-compliance reviewer 当时即指出：规格块 byte diff 是 AC 判别力的上限。）

**基线事实**（Alex 2026-08-05 实测）：改动前四份文件该节均为 70 行、md5 `9e787d0fc263d5cbe9cde3ebc384b6a7`；
被替换行在每份中恰好出现 1 次；目标行出现 0 次。

---

### AC2 — 改动形状：4 个文件，各恰好 1 增 1 删

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
N=$(mktemp)
git diff --numstat HEAD -- .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
    .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md > "$N"
cat "$N"
ac2=0
[ "$(wc -l < "$N" | tr -d ' ')" -eq 4 ] || { echo "AC2 FAIL skill 改动文件数 != 4"; ac2=1; }
[ "$(awk '$1==1 && $2==1' "$N" | wc -l | tr -d ' ')" -eq 4 ] \
  || { echo "AC2 FAIL 存在非「1 增 1 删」的 skill 改动"; ac2=1; }
# 台账：删 1 行、加 2 行
LS=$(git diff --numstat HEAD -- .tad/evidence/audits/lite-constraint-ledger.md)
echo "$LS"
[ "$(printf '%s' "$LS" | awk '$1==2 && $2==1' | wc -l | tr -d ' ')" -eq 1 ] \
  || { echo "AC2 FAIL 台账改动不是「2 增 1 删」"; ac2=1; }
[ $ac2 -eq 0 ] && echo "AC2 PASS" || echo "AC2 FAIL"
```

AC1 保证节内容与台账全文正确；AC2 保证**节外**一个字没动
（节外任何改动都会让 numstat 超出 1/1）。两条合起来 = 这 5 个文件整体逐字节受控。

⚠️ **`mktemp` 而非固定 `/tmp` 路径**：2026-08-05 实测，固定路径会被同 session 的其它 agent
覆盖——Alex 拍的 1740 行基线在两次调用之间被覆盖成 2 行，围栏随即报出几百个假越权。

⚠️ **AC1 的 `/^## Forbidden/` 是无尾锚前缀匹配**（reviewer 实证：把终止行改成
`## Forbidden-RENAMED`，节内容不变 → AC1 仍 PASS）。**终止行的唯一性由 AC2 提供，不是 AC1**——
边界移位需要节外改动，而 AC2 限死净变化。两条必须同时在，不得只留一条。

**HEAD 锚**：本 AC 与 AC3 都以 `HEAD` 为基准。起草时 HEAD = `910ab6cd4ea1765cbd4f64b69f4e015a5eac3dbc`。
AC3 会断言它没被移动过（`git reset` 配合晚拍基线是 reviewer 指出的攻击面）。

---

### AC3 — 改动围栏（**HEAD 锚，无快照**）

⚠️ **v4 初稿用「实现前拍基线 / 实现后拍快照 / 差分」，被对抗 reviewer 100% 攻破**：
契约里**没有任何东西把基线钉在实现之前**——基线由被验证方自己写在自己的 `/tmp`，
无时间戳、无 HEAD sha、无第三方见证。攻法不是攻正则（攻不动），是**攻基线时机**：

```
1. 真做那 4 行改动     ← AC1/AC2 逼的，省不掉
2. 任意附带破坏        ← 此时还没有基线
3. 现在才拍"基线"
4. 拍收尾快照 → 三条全绿
```

他在沙箱里删掉 tracked 的 `release-verify.sh`、写坏 session-state、改了 `.git/hooks/pre-commit`，
**AC3 照样 PASS**。指纹自校验挡的是"基线被别人覆盖"，挡不住"基线拍晚了"。

**修法：不要快照。以 HEAD 为锚重算——没有可篡改的基线，就没有时机攻击。**

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
ac3=0

# (a) HEAD 未被移动（防 git reset 换锚后再晚拍基线）
[ "$(git rev-parse HEAD)" = "910ab6cd4ea1765cbd4f64b69f4e015a5eac3dbc" ] \
  || { echo "AC3 FAIL HEAD 已移动，锚失效: $(git rev-parse HEAD)"; ac3=1; }

# (b) index 上无 assume-unchanged / skip-worktree
#     （否则 tracked 文件可被静默破坏：它同时从 git status 和 git ls-files -m 消失）
[ "$(git ls-files -v | grep -vc '^H ')" -eq 0 ] \
  || { echo "AC3 FAIL index 上有 assume-unchanged/skip-worktree 标记:"; git ls-files -v | grep -v '^H '; ac3=1; }

# (c) 相对 HEAD 变动的 tracked 文件，必须落在「起草时已 dirty 的 12 个」+「本单授权的 5 个」之内
#     ⚠️ 这 12 个由 Alex 于 2026-08-05 起草时实测钉死，不是 Blake 生成的 —— 这是本 AC 的锚
A=$(mktemp)
cat > "$A" <<'EOF'
.claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.tad/evidence/audits/lite-constraint-ledger.md
NEXT.md
.tad/active/handoffs/COMPLETION-20260805-pricing-gate-scan-fix.md
.tad/active/handoffs/HANDOFF-20260805-pricing-gate-scan-fix.md
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
.tad/evidence/decisions/2026-08-05.jsonl
.tad/evidence/journal/lite-pricing-gate-protocol-2026-08-05.md
.tad/project-knowledge/patterns/ac-verification.md
.tad/project-knowledge/patterns/gate-design.md
.tad/project-knowledge/patterns/shell-portability.md
.tad/research-notebooks/REGISTRY.yaml
EOF
V=$(mktemp)
git diff --name-only HEAD | LC_ALL=C sort -u \
  | grep -vxF -f "$A" \
  | grep -vE '^\.tad/evidence/(journal|traces)/|^\.tad/memory/' \
  > "$V"
[ -s "$V" ] && { echo "AC3 FAIL tracked 文件被越权改动或删除:"; cat "$V"; ac3=1; }

# (d) 关键 untracked 文件未被破坏（HEAD 锚看不见 untracked，单独钉 md5）
[ "$(md5 -q .tad/active/epics/EPIC-20260804-lite-as-tad-body.md)" = "1acdc51ec250237bd9e8c49c4be4604d" ] \
  || { echo "AC3 FAIL Epic 文件被改"; ac3=1; }
[ "$(md5 -q .tad/evidence/audits/P1b-deep-verdicts.md)" = "9da84175c709586056ac20da26aae79f" ] \
  || { echo "AC3 FAIL P1b-2 判定文件被改"; ac3=1; }

[ $ac3 -eq 0 ] && echo "AC3 PASS" || echo "AC3 FAIL"
```

**为什么这样就没有时机攻击**：(c) 比的是「当前工作区」对「一个不可移动的 commit」的差异，
**不依赖任何在实现期间生成的中间产物**。晚拍、早拍、不拍，结果一样。
(a) 堵死了"把 HEAD 挪走再算"这条路。

⚠️ **绝不拿仓库里的真实文件当探针。** 2026-08-05 Alex 为测围栏改了 tracked 的 `NEXT.md`
再 `git checkout --` 还原，**抹掉了用户 28 行未提交改动**（靠 reviewer 遗留在 `/tmp` 的
fixture 副本才逐字节找回，纯属侥幸）。要造探针就在 `/tmp` 建独立 git 仓。

**已知残余（不隐瞒，均经 reviewer 实证）**：

| 看不见的改动形态 | 处置 |
|---|---|
| 新增 untracked 文件 | 接受。风险是"多出东西"不是"破坏东西"；关键 untracked 文件已由 (d) 钉住 |
| gitignored 路径（`.claude/settings.local.json`、`*.log`、`skills/local/`） | 接受，本单改动面 5 文件 |
| `.git/` 内部（含 `.git/hooks/`） | 接受；无廉价机械修法，Gate 4 人工留意 |
| 空目录增删、非可执行权限位（`chmod 600`）、mtime | 接受，无害。`chmod +x` 看得见 |
| 白名单三目录 + `COMPLETION-*` 内任意内容 | 设计如此（流程产物通道），口径确实宽 |

⚠️ **结构性自指（reviewer P1-3，本单不修但须知）**：本 handoff 自身是 untracked，
且三条 AC 的定义（含全部钉死的 md5 常量）就住在它里面。
**理论上被验证方可以改写 AC 定义。** 本轮不构成实际风险——常量在 Alex 手里，
Gate 4 会独立重算；但结构上该由人持有独立副本执行 AC。记此备查。
## 5. ⚠️ 本机 shell 是 zsh 5.9，不是 bash

```
$ echo $0 → /bin/zsh   ZSH_VERSION=5.9   BASH_VERSION=none
$ T="a b c"; for x in $T; do ...   → 循环 1 次（bash 下 3 次）
```

- **不得** `for f in $VAR`（不分词）→ 写字面量词表
- **不得** `[ "$a" \< "$b" ]`（zsh 报 `condition expected: <`）
- **不得** `rm -f dir/glob*`（zsh 无匹配时报错）
- **不得**用数组 `arr=(...)` / `"${arr[@]}"`
- ⚠️ **BSD sed 的 `t` 不接受行内分隔符**：`s/x//; t; s/y//` 会把 `; s/y//` 当标签名 → 语法错
- ⚠️ **`uniq` 在 UTF-8 下把不同中文串判为相同**（`中文一/二/三` → `3 中文一`）→
  `sort`/`uniq`/`comm` 一律加 `LC_ALL=C`
- ⚠️ `bash --version` 报的是「装着的 bash」，不是「正在跑的 shell」。**在 Bash tool 里直接跑，
  不要 `bash -c` 包一层**——v1 的两名 reviewer 在错误语义下验完了全部 AC。
- **每条 AC 自带 `cd` 与全部定义**——每次 Bash 调用是新进程，**变量和函数都不跨调用存活**。
  （实测：变量为空时 `awk ... "$L"` 会把空文件名当 stdin → **静默挂死**，不是报错；
  函数未定义时 `snap > f` 会先完成重定向再报 `command not found` → **留下一个空文件**，
  下游 `comm` 因此无输出 → 假 PASS。AC3 的两个块各自完整定义 `snap()` 就是为此。）
- ⚠️ **`comm` 对未排序输入语义未定义**——凡喂给 `comm` 的文件，生成时必须末尾单次
  `LC_ALL=C sort`，并用 `LC_ALL=C sort -c` 前置断言。分段排序后拼接**不算有序**。

---

## 6. v1/v2/v3 作废记录（不要往回走）

| 版本 | 范围 | Gate 2 | 被攻破的方式 |
|---|---|---|---|
| v1 | 9 AC，含 Blake 做载体判定 | **FAIL，11 类 P0** | 台账是 tracked 文件 → 锚自命中 → NO-CARRIER 恒 FAIL / HAS-CARRIER 恒 PASS。伪造 30 分钟 |
| v2 | 5 AC，判断交对抗复核 | **FAIL，4 P0 + 8 P1** | AC 的查询命令写在契约里 → 把输出管进答案即可。对抗复核 prompt 在 Blake 手里、留痕反被围栏判越权。伪造 15 分钟 |
| v3 | 5 AC，判定作为数据给入 | **FAIL，7 P0** | 抽取器出口注入；探针枚举被反制；载体只验存在不验是否那一个；**150 格散文零验证**。伪造 20 分钟 |

**三轮收敛到的结论**：AC 只能验机械层，且**只有当交付物本身是一段确定文本时**，
验证才可能是穷尽的（本单：整节 md5）。凡交付物含自由撰写内容，AC 必然留有伪造空间——
把判断塞进 grep 会持续长新洞，每轮的绕过更廉价。

**处置**：判断层已全部移出（7 条 DEEP 判定见 `.tad/evidence/audits/P1b-deep-verdicts.md`，
Alex 搜读 + 人拍板）；台账回填取消（随 P2/P3/P5 自然生长）；本单只剩一处正则。

---

## 7. 风险与注意

- 本单**没有判断层**——交付物是一段确定文本，AC1 的整节 md5 是穷尽验证。
  这次这句话成立（v3 说过同样的话但不成立，因为它留了 150 格散文给 Blake）。
- 发现契约本身有错 → **停，报告人回 Alex 修订，不自行改规格**。
- Epic 执行约束 5：Completion 须记录**本 phase 实际消耗**。
- 台账当前 0 数据行，本单不追加行，故**不触发「追加前先扫」的前置义务**。

---

## 8. Gate 2 检查表

- [x] **台账超期扫描（Epic 执行约束 0）**：2026-08-05 → 0 数据行，无超期，无 MALFORMED
- [x] **AC 条数 ≤10**：3 条
- [x] **v1/v2/v3 专家审查**：6 名 reviewer，三轮均 FAIL，结论已吸收（§6）
- [x] **目标正则语义 10 用例实测**（§3.2），含 reviewer 指出的 32–39 与 00 区间
- [x] **基线实测**：四份文件该节均 70 行、md5 `9e787d0f…`；旧行各 1 次、新行各 0 次
      → **AC1 在零改动仓库必 FAIL**（当前 md5 ≠ 目标 md5）
- [x] **AC2 零改动实测**：numstat 输出 0 行 ≠ 4 → **FAIL**
- [x] **AC3 双向性实测**：`comm -3` 能看见消失的行（`comm -13` 不能）
- [x] **AC3 修复轮**（2026-08-05，来源：v3 zsh reviewer 迟到报告 + Alex 现场实测）：
      | 缺陷 | 证据 | 修法 |
      |---|---|---|
      | `comm` 吃未全局排序输入 → 对诚实实现假阳性 | reviewer 真仓库实测 2 个无辜文件被报；Alex `sort -c` 第 875 行 disorder | 末尾单次全局 sort + `sort -c` 前置断言 |
      | `snap()` 不跨 Bash 调用存活 → 空快照 → **fail-open PASS** | reviewer 实测 `command not found` + 重定向先发生 | 收尾块重定义 + 非空断言 |
      | TAD 自己的 trace hook 写入被判越权 | `.tad/evidence/traces/` 未被 gitignore，快照中 4 行 | 排除正则补 `traces` |
      | `core.quotePath` 让中文/含空格路径丢哈希行 | 仓库有 12 中文名 + 6 含空格 tracked 文件（当前不 dirty，潜伏） | `git -c core.quotePath=false` |
      | 固定 `/tmp` 路径被同 session 其它 agent 覆盖 | **Alex 现场遭遇**：基线 1740 行被覆盖成 2 行，报出几百个假越权，三条断言无一拦住 | 路径按仓库根 md5 派生 + 基线指纹自校验 |
      修复后实测：零改动之间 AC3 正确 PASS；篡改 / 空 / 乱序三个负向控制全部触发。
- [x] **v4 专家审查（2 名，均已回报）**：
      - **对抗 reviewer**：`「伪造交付」造不出。「伪造围栏」100% 造得出。`
        AC1+AC2 锁死 4 文件、攻不动，正则必须真改对；但 AC3 的快照基线**可以后拍**——
        先破坏、后拍基线，三条全绿。沙箱实证：删 `release-verify.sh`、写坏 session-state、
        改 `.git/hooks/pre-commit`，AC3 照样 PASS。
      - **正确性 reviewer**：两个 md5 **独立重算一致**；§3.2 十例逐格属实，
        另做 **462 例穷举**（月 00–13 × 日 00–32）**0 mismatch**；
        AC1+AC2 三个变异体全被抓（含 v3 式绕过子句）；7 条 zsh 陷阱条条属实，另补 3 条。
- [x] **AC3 第二次重设计（本轮，采纳对抗 reviewer 的处方）**：**彻底不用快照，改 HEAD 锚。**
      | 缺陷 | 修法 |
      |---|---|
      | 基线由被验证方自持、可后拍 → 围栏 100% 可绕 | 以固定 commit `910ab6c` 为锚重算，**没有可篡改的中间产物** |
      | `git reset` 换锚 | (a) 断言 HEAD 未移动 |
      | `assume-unchanged`/`skip-worktree` 让 tracked 文件从两条腿一起消失 | (b) 断言 `git ls-files -v` 全 `H ` |
      | 框架自写路径被判越权 | 豁免补 `traces`、`.tad/memory/`（29 tracked 文件、未 gitignore）|
      | HEAD 锚看不见 untracked | (d) 单钉 Epic 与 P1b 判定文件的 md5 |
      | 固定 `/tmp` 路径并发覆盖 | 全改 `mktemp` |
- [x] **修订后三条 AC 在零改动仓库实跑**：AC1 **FAIL**（5 文件全为基线 md5）/
      AC2 **FAIL**（numstat 0 行）/ AC3 **PASS**（尚无破坏，应 PASS 即正确）
- [x] **Gate 2 关闭**（2026-08-05，人裁定：不再为 6 行改动加审查轮次）。
      AC3 的增量复核**主动取消**——理由：AC1+AC2 已被两名 reviewer 独立证为不可伪造，
      而 AC3 是**围栏**不是交付判据，其真实验收在 Gate 4（Alex 用同一 HEAD 锚独立重跑）。
      **已知残余（两条，Gate 4 必须亲验）**：
      1. AC3(c) 的允许清单含 12 个起草时已 dirty 的文件（含 `NEXT.md` 与三个
         `project-knowledge/patterns/*.md` = CLAUDE.md 第 1 类 SAFETY 面），
         **改动它们不会被 AC3 抓到** → Gate 4 由 Alex 逐个比对这 12 个。
      2. 被中断的增量复核留下一句未完成的判断：「**Confirmed bypass … `git status`
         与 `git diff` 结果不一致**」——无细节。**不视为已解决**，Gate 4 时 Alex
         同时用 `git status --short -uall` 与 `git diff --name-only HEAD` 两路交叉核对。
