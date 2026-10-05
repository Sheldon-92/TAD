# 设计增量 — state-surface-check 括号版位形态覆盖（Gate 3 条件 C1）

- 任务：TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT（第一批实施 · Gate 3 返工设计步）
- 作者：Alex（Solution Lead）｜日期：2026-10-04
- 性质：微增量设计。只关闭 Gate 3 条件 C1，只扩模式家族，不松任何既有判据，不设计 C1 以外的问题。
- 依据（仓内原件与在盘证据）：
  - CODE 评审件 `.tad/evidence/reviews/2026-10-04-gate3-code-review-state-surface-closeout.md` §6/§8 条件 C1
  - Gate 3 合并裁定 `.tad/evidence/reviews/2026-10-04-gate3-merge-verdict-state-surface-closeout.md` 返工路径
  - 设计原件 `.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md` §2.2 机制 1/2
  - 被改对象 `.tad/hooks/lib/state-surface-check.sh`（176 行现行版）、`.tad/tests/state-surface-fixture/`
- 本件与设计原件的关系：本件**修订**设计 §2.2 机制 2 第 3 项的模式家族句与 Fixture 段负控句，
  以本件为准；设计原件本文不改（落地件只追加指针追记，见 §6 清单第 7 项）。

---

## 0. 根因与实测基线（dry-run 先行，非心算）

根因（CODE 评审 §6 已实证，本席复核成立）：check3 的 `DECL_PAT` 须以字面 `Version` 起头，
check4 只特判字面值 `3.1`——故任何**非 3.1 的错误版本号**只要写成括号形态 `(vX.Y)`，
两查皆盲。A9 的原始缺陷 `Runtime status (v3.1)` 正是此形态；现行真树靠 check4 的 3.1
特判守住，日后头部漂移成 `(v3.2)` 式新值即全绿放行。

本席 2026-10-04 在真树 + 合成样本上实跑候选模式，基线如下（Blake 实施后应复现同值）：

| # | 实测 | 结果 |
|---|---|---|
| B1 | 无锚括号 token 扫描 `\(v?[0-9]+\.[0-9]+(\.[0-9]+)?\)` 于身份面五文件 | 恰 2 命中：`AGENTS.md:9` `(v3.0.0)`（身份行）；`README.md:284` `## 🚦 4-Gate Quality System (v2.0)`（正文标题里的历史特性版本，**非现行版本声明**） |
| B2 | 同扫描于 NEXT.md / ROADMAP.md | 0 命中（两文件本不在 check3 扫描面，此为鲁棒性旁证） |
| B3 | check4 家族 `OLD_PAT` 对合成样本 | `(v3.1)`→命中、`(Version 3.1)`→命中、`**Runtime status (v3.1)**`→命中、`(v3.10)`→正确不命中（尾部守卫）、`(v9.9)`→不命中（非其职责） |
| B4 | P1 候选模式（§1）于真树五文件 | 0 命中 |
| B5 | P2 候选模式 + 锚定（§2）于真树五文件 | 恰 1 命中：`AGENTS.md:9` `(v3.0.0)`，值 == SSOT |
| B6 | P2 候选模式 + 锚定于 fixture AGENTS.md（未改动现状） | 恰 1 命中：第 3 行 `(v9.9)` |

由 B3 得**范围收窄结论**：check4 对 3.1 的括号形态本已覆盖，C1 是纯 check3 家族缺口；
本增量**不动 check4、不动 OLD_PAT、不动 AC6 命令**（§5）。

---

## 1. 模式家族扩展（check3 内新增括号分支，不新增查号）

### 1.1 衔接方式

- 括号分支**并入 check3**，与既有 DECL 分支共用文件清单 `DECL_FILES`、共用 `c3_bad`
  计数与同一条 PASS 行。查号总数保持 5——AC7「check1–check5 全 PASS」口径、
  release-verify 转调语义、publish-protocol step3e 文本均零扰动（§5）。
- 脚本仍 detect-only、bash + grep + sed、无 `grep -P`（shell-portability 纪律不变）。

### 1.2 新模式（正则原文，ERE，与现行脚本同风格）

```bash
# P1 — self-anchored parenthesized declaration: "(Version 9.9)" / "(Version: v9.9)"
PAREN_VER_PAT='\(Version:? ?v?[0-9]+\.[0-9]+(\.[0-9]+)?\)'

# P2 — bare parenthesized token: "(v9.9)" / "(9.9)" (line-qualified, see §2)
PAREN_TOKEN_PAT='\(v?[0-9]+\.[0-9]+(\.[0-9]+)?\)'
PAREN_KEYWORD='Runtime status'
PAREN_HEAD_LINES=15
```

既有两常数**逐字不动**：

```bash
DECL_PAT='Version\*{0,2}:?\*{0,2} ?v?[0-9]+\.[0-9]+(\.[0-9]+)?'
OLD_PAT='(Version|v)\*{0,2}:?\*{0,2} ?3\.1([^0-9]|$)'
```

### 1.3 语义（绑定性，实现形状可等价）

对 `DECL_FILES` 每个文件，在既有 DECL 提取循环之外追加两遍：

- **P1 遍**：`grep -oE "$PAREN_VER_PAT"` 全文件提取每个匹配 token，逐个按 §1.4
  取值与 SSOT 比较，不等即 `fail check3`。
- **P2 遍**：`grep -nE "$PAREN_TOKEN_PAT"` 逐行取行号与行文；仅当该行满足 §2 锚定
  （行号 ≤ `PAREN_HEAD_LINES`，或行文含 `Runtime status`）时，对该行
  `grep -oE "$PAREN_TOKEN_PAT"` 提取每个 token，逐个比较，不等即 `fail check3`。
  同一 token 在同一行只报一次（头部锚与关键词锚同中不双报）。
- P1 与 P2 按构造不交叠：P1 token 以 `(Version` 起头，P2 token 要求 `(` 后紧跟
  `v?` + 数字，二者在同一位置不可能同中。

### 1.4 取值与 FAIL 文案

- 取值：token 内恰含一个数字串（`Version`/`v` 前缀无数字），故
  `grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1` 即为其版本值，再走既有 `norm()`
  与 SSOT 比较——与 DECL 分支同一比较纪律。
- FAIL 文案（两分支同式，**token 必须逐字出现在 FAIL 行内**——§4 探针以 `grep -F`
  按 token 归因，文案不含 token 即探针失效）：

```
FAIL check3: <file>: parenthesized version declaration '<token>' != version.txt <SSOT>
```

---

## 2. 身份行语境锚定（只打身份行，不误伤沿革）

### 2.1 锚定规则（P2 三选一，P1 自锚）

| 锚 | 规则 | 依据 |
|---|---|---|
| A1 自锚 | `(Version …)` 形态：括号内自带 `Version` 字样，声明语义无歧义，全文件适用 | B4 真树 0 命中 |
| A2 头部锚 | 裸 token 所在行行号 ≤ 15 | 身份行实存位置（五文件身份行均在头部）；与 check1 既有 `head -n 15` 先例同界，非新发明 |
| A3 关键词锚 | 裸 token 所在行含 `Runtime status` | A9 缺陷与现行头部的框架惯用语；使身份行日后移出头部仍被守住 |

新身份惯用语出现时走设计修订增锚，不许实施者临时放宽——锚集小而有据是本设计
的取舍（宁可漏掉无锚的偏僻写法，不可让正文沿革引用误红；漏掉的形态仍受
机制 1 的人工面与 PM 自查覆盖）。

### 2.2 逐个反例验证（真树实跑预测，Blake 实施后须复现）

| 反例 | 位置/形态 | 预测 | 机制 |
|---|---|---|---|
| README 4-Gate 标题 `(v2.0)` | `README.md:284`，正文标题历史特性版本 | **不命中** | 行号 >15、无 `Runtime status`、非 `(Version …)`——三锚皆不中（B1/B5 已实证：有 token、无归因） |
| README 更新日志表行 | `README.md:386+`，`\| **v2.29.0** \| …` 表格行 | **不命中** | 无括号 token；DECL 分支须字面 `Version` 起头、OLD_PAT 须字面 `3.1`，均不中（与 AC6 现行 = 0 一致） |
| README 目录链接 | `README.md:7` `[Version History](#version-history)` | **不命中** | `(` 后为 `#`，token 模式要求 `v?` + 数字紧随 `(` |
| NEXT.md 历史行 | 如「✅ DONE 2026-09-11. Publish patch v2.44.5」 | **不命中** | NEXT 不在 check3 扫描面（check1 单独管其头部行）；且 B2 实证 NEXT 全文 0 括号 token |
| AGENTS.md 现行头部 | `AGENTS.md:9` `(v3.0.0)` | 命中 P2（A2+A3 双锚），值 == SSOT → **不报 FAIL** | B5 已实证——正控在真树 |
| `(v3.10)` 类近似值 | 合成样本 | check4 尾部守卫正确放行（3.10 ≠ 3.1）；check3 若其为身份行则按值比较 | B3 已实证 check4 侧 |

### 2.3 边界（明示不覆盖，防后人误读为全形态覆盖）

- 括号内版本后带后缀文本者（如 `(v3.0.0, 2026-09-16)`）不在覆盖内：token 模式
  要求版本后紧跟 `)`。现行五文件无此形态。
- 全角括号 `（vX.Y）` 不在覆盖内：五文件与 fixture 均无实例，且 CJK 括号在
  grep ERE 下的 locale 行为需另行验证——登记于 §7，不在本增量设计。

---

## 3. Fixture 真负控化

### 3.1 核心事实

fixture `AGENTS.md:3` 的 `(v9.9)` 植入**位置与形态本已合格**（头部第 3 行 +
`Runtime status` 关键词行，P2 双锚同中，B6 已实证）——它成为 vacuous 的唯一原因是
脚本无此分支。故 **fixture AGENTS.md 一字不改**，脚本落地之时该植入自动转真负控。
Blake 不许「顺手修正」该文件。

### 3.2 新增植入（每形态一条，值互异以便 FAIL 归因）

| 文件 | 改动 | 植入值 | 覆盖分支 |
|---|---|---|---|
| `docs/MULTI-PLATFORM.md` | 第 3 行替换为：`Minimal stand-in. Edition note (Version 9.7) — planted negative control.` | `(Version 9.7)` | P1 自锚 |
| `INSTALLATION_GUIDE.md` | 第 3 行替换为：`Minimal stand-in. Fixture build (v8.8) — planted negative control.` | `(v8.8)` | P2 头部锚（该行无 `Runtime status`、无 `Version` 字样，归因唯一） |
| `README.md` | 第 3 行替换为：`Minimal stand-in. **Runtime status (v3.0.0)** — positive control (correct value; must not be flagged).` | `(v3.0.0)` | P2 正控（值 == fixture SSOT，证分支比值而非禁形态） |

植入值 9.7 / 8.8 刻意避开 3.1：新植入不得触发 check4，保 check4 PASS 的归因纯度。

### 3.3 全负控/正控清单（fixture 终态期望，FIXTURE.md 须同步改述至与此表一致）

| 文件:行 | 植入 | 分支 | 期望 |
|---|---|---|---|
| NEXT.md:3 | 当前版本 2.44.5（既有） | check1 | FAIL check1 |
| AGENTS.md:3 | `(v9.9)`（既有，不改） | check3-P2 | FAIL check3，归因含 `(v9.9)` |
| AGENTS.md:4 | `**Version**: 9.9`（既有） | check3-DECL | FAIL check3，归因含 `Version**: 9.9` |
| docs/MULTI-PLATFORM.md:3 | `(Version 9.7)`（新增） | check3-P1 | FAIL check3，归因含 `(Version 9.7)` |
| INSTALLATION_GUIDE.md:3 | `(v8.8)`（新增） | check3-P2 | FAIL check3，归因含 `(v8.8)` |
| README.md:3 | `(v3.0.0)`（新增正控） | check3-P2 | 不报 |
| PROJECT_CONTEXT.md:3 | `**Version**: 3.0.0`（既有正控） | check3-DECL | 不报 |
| ROADMAP.md:3 | `for v3.0.0`（既有正控） | check2 | PASS |

终态总期望：exit 1；FAIL = check1 ×1 + check3 ×4 归因；check2 / check4 / check5 PASS。
FIXTURE.md 现述「check3: AGENTS.md carries `(v9.9)` and the bold-colon…」一句须改写
为与上表一致的清单（逐植入写明分支与期望），其余运行说明保留。

---

## 4. 探针判据（Blake 实施自验 + PM 验盘 + CODE 定点复核共用，自仓根目录执行）

```bash
# Probe-0 真树正控：exit 0，check1–check5 全 PASS
bash .tad/hooks/lib/state-surface-check.sh; echo "exit=$?"

# Probe-1 fixture 全负控：exit 1，四处 check3 归因齐备，check2/4/5 PASS
bash .tad/hooks/lib/state-surface-check.sh --repo .tad/tests/state-surface-fixture; echo "exit=$?"
out="$(bash .tad/hooks/lib/state-surface-check.sh --repo .tad/tests/state-surface-fixture 2>&1)"
for t in '(v9.9)' 'Version**: 9.9' '(Version 9.7)' '(v8.8)'; do
  printf '%s' "$out" | grep -qF "$t" || echo "MISSING attribution: $t"
done   # 期望：无 MISSING 输出

# Probe-2 C1 核心判据：副本仅修粗体冒号行 → 仍 exit 1，且 FAIL 含指向 (v9.9) 的 check3 行
rm -rf /tmp/ssfx-probe2 && cp -R .tad/tests/state-surface-fixture /tmp/ssfx-probe2
sed -i 's/\*\*Version\*\*: 9\.9/**Version**: 3.0.0/' /tmp/ssfx-probe2/AGENTS.md
bash .tad/hooks/lib/state-surface-check.sh --repo /tmp/ssfx-probe2; echo "exit=$?"
bash .tad/hooks/lib/state-surface-check.sh --repo /tmp/ssfx-probe2 2>&1 | grep 'FAIL check3' | grep -cF '(v9.9)'
# 期望：exit=1，计数 ≥1（macOS 上 sed -i 须作 sed -i ''）

# Probe-3 归因隔离：副本修全部四处错误植入 → check3 PASS，总 exit 1 且唯一 FAIL 为 check1
rm -rf /tmp/ssfx-probe3 && cp -R .tad/tests/state-surface-fixture /tmp/ssfx-probe3
sed -i 's/(v9\.9)/(v3.0.0)/; s/\*\*Version\*\*: 9\.9/**Version**: 3.0.0/' /tmp/ssfx-probe3/AGENTS.md
sed -i 's/(Version 9\.7)/(Version 3.0.0)/' /tmp/ssfx-probe3/docs/MULTI-PLATFORM.md
sed -i 's/(v8\.8)/(v3.0.0)/' /tmp/ssfx-probe3/INSTALLATION_GUIDE.md
bash .tad/hooks/lib/state-surface-check.sh --repo /tmp/ssfx-probe3; echo "exit=$?"
# 期望：check3 PASS 行出现；唯一 FAIL 为 check1（证作用域精确、正控不误报）

# Probe-4 全绿：续修 NEXT 头部 → exit 0（证 fixture 无 vacuous-red 残留）
sed -i 's/2\.44\.5/3.0.0/g' /tmp/ssfx-probe3/NEXT.md
bash .tad/hooks/lib/state-surface-check.sh --repo /tmp/ssfx-probe3; echo "exit=$?"
# 期望：exit=0
```

---

## 5. 影响面

| 对象 | 结论 | 理由 |
|---|---|---|
| `release-verify.sh state-surface` 转调臂 | **不受影响，不改** | 转调是整脚本 exec 转发，脚本内部增分支自动生效；AC13 的三 grep 与「转调与 AC7 同 exit 0」期望不变 |
| publish-protocol step3e | **不受影响，不改文本** | 其收口步跑的是同一脚本，发版面自动获得括号覆盖；断言步与文件集不变 |
| 设计 §2.2 原文 | 不改本文；Blake 追加一行指针追记（§6 第 7 项） | 落地件保 Gate 2 时点原貌，增量以本件为准 |
| HANDOFF AC6 | **口径不动** | 其命令模式即 OLD_PAT 家族，B3 实证已覆盖 `(v3.1)` 括号形态；AC6 管的是 3.1 字面清零，与 C1（任意错误值 × 括号形态）正交 |
| HANDOFF AC7 | **判据不动，须重跑回填** | 查数仍 5、exit 0 期望不变；Blake 实施后重跑并更新其实跑输出列（真树输出中 check3 PASS 行的覆盖面已扩，回填须反映增量后实跑） |
| HANDOFF AC8 | **口径要扩（只扩不松）** | 现 Expected Evidence 只要求粗体冒号行被命中；增量后须按下述替换文本执行。本步不动 HANDOFF 本体，替换文本在此成文、由 PM 路由落入 §9.1 AC8 行 |

AC8 行 Expected Evidence **替换文本（逐字，PM 路由用）**：

> exit 1；FAIL 集 = check1（NEXT 2.44.5）+ check3 四处归因：AGENTS.md `(v9.9)`（P2 分支）、AGENTS.md `**Version**: 9.9` 粗体冒号行（DECL 分支）、docs/MULTI-PLATFORM.md `(Version 9.7)`（P1 分支）、INSTALLATION_GUIDE.md `(v8.8)`（P2 头部锚）；check2/4/5 PASS；且按增量设计 §4 Probe-2：fixture 副本仅修粗体冒号行后仍 exit 1 且输出含指向 `(v9.9)` 的 check3 FAIL 行（增量设计：`.tad/evidence/designs/2026-10-04-state-surface-check-pattern-delta.md`）

---

## 6. 给 Blake 的实施清单（改动面恰为以下 7 处，多一处即越界）

1. **`.tad/hooks/lib/state-surface-check.sh`**：
   a. 常数区新增 §1.2 四行（`PAREN_VER_PAT` / `PAREN_TOKEN_PAT` / `PAREN_KEYWORD` / `PAREN_HEAD_LINES`），置于 `OLD_PAT` 之后；
   b. check3 节内在 DECL 循环后追加 P1、P2 两遍（语义按 §1.3/§1.4，共用 `c3_bad` 与 PASS 行）；
   c. 头部注释第 3 项改述为双家族表述（DECL 形态 + 括号形态及锚定一句话），并注明增量出处 `design delta 2026-10-04 (Gate 3 C1)`；
   d. 其余各查、exit 语义、detect-only 性质逐字不动。
2. **fixture `docs/MULTI-PLATFORM.md`**：第 3 行按 §3.2 替换。
3. **fixture `INSTALLATION_GUIDE.md`**：第 3 行按 §3.2 替换。
4. **fixture `README.md`**：第 3 行按 §3.2 替换（正控行）。
5. **fixture `FIXTURE.md`**：check3 相关段改写为 §3.3 清单（逐植入：文件:行 / 形态 / 分支 / 期望），保留运行说明与真树 exit 0 句。
6. **fixture `AGENTS.md`**：**不改**（§3.1）。NEXT / ROADMAP / PROJECT_CONTEXT / `.tad/` 内两件亦不改。
7. **设计原件** `.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md`：在机制 2 段末（`**机制 3` 标题之前）追加一行指针追记，逐字如下：

   > **2026-10-04 Gate 3 条件 C1 增量追记**：机制 2 第 3 项模式家族已由增量设计 `.tad/evidence/designs/2026-10-04-state-surface-check-pattern-delta.md` 扩至括号版位形态（P1/P2 分支），以该件为准；本节原文保留作 Gate 2 时点记录。

**验收命令**（Blake 回执须含五探针全输出）：§4 Probe-0 ～ Probe-4 逐条实跑；
另附 `bash .tad/hooks/lib/release-verify.sh state-surface` exit 0（证转调未损）。
提交口径从 HANDOFF 既有纪律（本地 commit、不 push），由 PM 在返工派发书中确认。

---

## 7. 登记（只登记，不设计，不在本增量处置）

- AC6 命令的文件清单为 4 文件（不及 PROJECT_CONTEXT.md），脚本 check4 为 5 文件——
  第一批既有口径差，本增量不动，留 PM 收口时裁。
- 全角括号 `（vX.Y）` 形态未覆盖（§2.3），待真树出现首例再议。
- 合并裁定两条非阻塞观察（session-state 状态词、HANDOFF 模板 v3.1 boilerplate）
  与本增量无关，不在此设计。
