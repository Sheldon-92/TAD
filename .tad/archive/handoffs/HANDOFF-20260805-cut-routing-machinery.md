# HANDOFF: 砍路由机器（Epic P2 + P3 合并）

**Date**: 2026-08-05 | **Version**: v2（v1 被 Gate 2 判 FAIL，见 §8）
**From**: Alex (Terminal 1) | **To**: Blake (Terminal 2)
**Epic**: `.tad/active/epics/EPIC-20260804-lite-as-tad-body.md` Phase 2 + 3（2026-08-05 人裁定合并）
**Channel**: full（F1_GOVERNANCE_CRITICAL：`routing_contract` + `protocol_state`，`override_allowed: false`）
**HEAD 锚**: `6a7cef0b22fddcd050af53949fd43e3c8ca0a36a`

---

## 1. 目标

删掉 2026-08-01 引入的三层路由装置**及其全部触手**。这是本 Epic 最大的一刀，也是刻意的最后一次 full 使用。

砍除依据 `.tad/evidence/audits/P1b-deep-verdicts.md`（Alex 搜读 + 人拍板）——逐条核验过载体：

| 砍除项 | 判定 |
|---|---|
| Route Contract R0–R3（两 skill） | **NO-CARRIER**（事故区零命中；起源单只给设计理由；同期 journal 5 条全是实现摩擦） |
| escalated_review 全套 | **NO-CARRIER** |
| 升级清单「转 full」分支 | **NO-CARRIER**，且有反向证据：本 Epic Trigger 即用户原话「我经常会被拦着」 |
| Reviewer 档位规则 ×2 | **SUPERSEDED**（⚠️ 有真载体，见 §6.2） |
| Model 行捕获纪律 8 条命令 | **NO-CARRIER**（载体明写「成本一行」） |

**v2 范围扩大到 8 个文件**（v1 只有 4 个 skill，Gate 2 抓出 4 处遗漏）：
删掉 skill 里的机制却留着**四份还在承诺它的文档**，等于制造「文档说有、系统没有」的新缺陷。
其中 **`CLAUDE.md §2.5` 是本单成败所系**——它是 `@import` 自动加载、优先级高于 skill 的路由层，
现在写着「lite = ≤5 文件、**非协议契约**的小任务」。不改它，skill 改完也白改：
两条活规则打架，赢的是先加载的 CLAUDE.md，**用户下次想走 lite 照样被拦**。

---

## 2. 不做什么

- **不删 `.tad/routing-contract.yaml` 文件本身**（人裁定）。两 skill 不再读它，文件留着可回滚。
  ⚠️ 它仍被 `verify-route-schema.sh` / `verify-state-flow.sh` 消费——**本单不碰那些验证器**。
- 不动 `.tad/config*.yaml`、`.tad/hooks/`、full 通道的 `alex`/`blake`/`gate` skill。
- **CLAUDE.md 只改 §2.5 的标题 + 首行**，其余（含 §2 路由表、§4 Terminal 隔离）不动——full 退场是 P6。
- **版本横幅与发布史显式豁免**（Gate 2 建议：显式豁免优于沉默，否则下个 reviewer 还要重扫）：
  `README.md` 的 `## What's New in vX` 块、`CHANGELOG.md`、`PROJECT_CONTEXT.md` 版本串、
  `docs/MULTI-PLATFORM.md`、`INSTALLATION_GUIDE.md:3` 与 `.tad/config.yaml:1` 的版本横幅
  ——它们是**发布史记录**不是行为承诺，且 `release-verify.sh` 的版本断言依赖其中数处。
  随 P6 版本号统一处理。
- 不 commit、不 push。

### ⚠️ 2.1 明确不修（碰了会 FAIL AC1，别好心）

Gate 2 发现这两处确有瑕疵，但它们落在 **AC1 冻结的 untouched 节**里，本单内改动即 FAIL：

1. **`R6` 悬空**：两 skill 的 `## 跨角色请求消歧` 写着「载体（R6）」，而文件只定义过 R0–R3。
   **前置缺陷，非本单引入。** 留给 P6。
2. **`## Lite-First 政策` 仍写「full TAD 是例外而非常态」「切换通道到 full（例外）」**。
   full 通道并未消失（人仍可自行输入 `/alex`），故前半句仍为真；后半句描述了一个 lite
   已不再具备的动作，措辞别扭但不致错。留给 P6 的 full 退场单。

---

## 3. 规格（8 个文件）

### 3.1 整节删除（2 处）

删掉整个 `## Route Contract（Lite / Standard / Full 三层路由）` 节，从该行到**下一个 `## ` 之前**
（alex-lite 66 行、blake-lite 54 行；边界已实测）。删后 alex-lite 的 `## L0-pre 命名消歧` 直接接
`## 执行脊柱`；blake-lite 的 `## 共享记忆契约` 直接接 `## L0 读契约 + 准入`。

### 3.2 整个子节删除（3 处）

| 文件 | 子节 | 边界（实测行数） |
|---|---|---|
| alex-lite | `### Reviewer 档位规则` | 到 `人工拍板后变更回流：` 之前（28 行） |
| blake-lite | `### Reviewer 档位规则` | 到 `## L3.5` 之前（28 行） |
| blake-lite | `Model 行捕获纪律（writer=…` 整块 | 到 `学习捕获纪律：` 之前（26 行） |

**Model 行捕获纪律替换为一行**（后面**保留一个空行**再接 `学习捕获纪律：`，否则 markdown 会并段）：

```
Model 行按运行时自报填写，一行即可；无法判定的字段填 unknown，不得伪造。
```

⚠️ **L4 Completion 模板里的 `**Model**: harness=… | model=… | route=…` 那一行保留**——
它有载体（`2026-08-02-multi-model-portability-verification.md` 第 4 条，明写「成本一行」）。
删的是 8 条 env/jq/config.toml 捕获命令，不是字段本身。

### 3.3 升级清单 → 安全停清单（两 skill，逐字节相同）

哨兵块整体替换为（**md5 `166464e66b98c701a2b892d6e773256f`，7 行含两个 marker**）：

```
<!-- ESCALATION-LIST-BEGIN -->
安全停清单（命中任一 → 停下来问人；不再有"转 full"分支）：
1. 不可逆操作：支付/认证/批量数据删除/生产部署配置/依赖升级(lockfile、版本 pin)/release·publish·sync/破坏性 VCS(force-push、删分支、改历史)
2. SAFETY 面：.tad/project-knowledge/principles.md、patterns/ 中标 SAFETY 的条目、patterns/_index.md、本清单自身
3. 全局注册面：.tad/hooks/、.claude/settings*.json —— 注册后全 session 生效且无回滚验证
兜底：无法确信影响面 → 停，请人裁定。
```

**消失的是「协议契约面」与「耦合面」**——lite 从此可直接改 `SKILL.md` / `CLAUDE.md` /
`config*.yaml` / `epics/`。这是核心意图。第 2 条的「本清单自身」是刻意加的：不加则删清单本身不触发停。

⚠️ 该块第 2 行含字面串 `转 full`，**这是有意保留的**（说明"不再有转 full 分支"）。
AC2 的对应锚点已改为 `转 full TAD`，不会误伤——v1 用 `转 full` 导致 AC2×AC3 互斥、忠实实现必 FAIL。

### 3.4 alex-lite 其余改动

**(a) frontmatter 删第 6 行**：`  仅升级清单命中或用户明确要求时转 full TAD（/alex）。`

**(b) L0 节替换为**：

```
### **L0 — Applicability and current-state check（适用性与现状检查）**

- Input: 用户需求 + `.tad/active/handoffs/` 现状。
- Action: 对照下方安全停清单判断；定位相关当前 handoff/状态；
  不因篇幅、上下文引用数或"想要更多细节"而升级。
- Output: 判定（继续 lite / 安全停）。
- Stop: 命中安全停清单任一项 → **停下来问人**，说明命中了哪一条、建议怎么做；
  得到人的明确指示后再继续。未命中 → 直接进 L1。
```

**(c) 哨兵块之后两整块删除**（`escalated_review 授权规则：` 起，到 `### **L1 — Goal anchor` 之前，
实测 8 行含空行）。

**(d) 逐条改动（⚠️ 分「整行替换」与「子串替换」两类，别混）**：

| # | 类型 | 原文（逐字节已核） | 改为 |
|---|---|---|---|
| d1 | 整行替换 | `  **Date**: {date} \| **escalated_review**: no \| yes (用户原话: "...")` | `  **Date**: {date}` |
| d2 | 整行删除 | `  - escalated 单追加：升级清单命中项是否被 AC 覆盖` | （删） |
| d3 | **子串替换** | `命中升级清单` | `命中安全停清单` |
| d4 | 整行替换 | `- fatal 操作仍按升级清单第 4 类处理；普通局部修改继续留在 Lite。` | `- 不可逆操作按安全停清单第 1 条处理（停下来问人）；普通局部修改继续留在 Lite。` |
| d5 | **子串替换** | `，格式同 Model 行}` | `}` |
| d6 | **子串替换** | `，机械捕获同 Model 行纪律` | （删该子串） |

⚠️ **d3 必须是子串替换**：整行是
`  或 P0 修复扩大范围/命中升级清单 → 停，报告人；不得把 FAIL 契约交给 blake-lite。`
——v1 把前半截当"整行原文"，字面执行会**静默删掉 `不得把 FAIL 契约交给 blake-lite。`**
这条真约束，而五条 AC 全绿（Gate 2 实证）。d5/d6 同理，是行中片段。

**(e) Series 锚点整段替换为**：

```
Series 锚点：多步任务默认用 Series 行做轻量锚点（LITE 文件 header 追加，blake-lite 不消费）。确需正式 Epic → 可直接写 .tad/active/epics/（不再受清单限制）。
```

**(f) Forbidden 删 3 行**（`主动建议或默认 escalated_review /`、
`在无用户明示坚持时设置 escalated_review: yes /`、以`把额度出口句用于推荐/暗示 escalated`开头的那行）。

### 3.5 blake-lite 其余改动

**(a) L0 step2 末条与 step3 替换为**：

```
   - 无 LITE 文件 → 停："请先用 /alex-lite 生成计划"（口头需求不是契约）
3. 适用性复查（清单 = 下方哨兵块，与 alex-lite 逐字节相同）：
   - 命中安全停清单任一项 → **停下来问人**，说明命中了哪一条；得到明确指示后再继续
   - 未命中 → 进 L0.5
```

**(b) L0.5 删 2 行**（`escalated 单追加：核对…` 与紧随的 `（escalated 的 2-reviewer 结构…` ）。
⚠️ **删后不得留连续双空行**。

**(c) 逐条改动**：

| # | 类型 | 原文 | 改为 |
|---|---|---|---|
| e1 | 整行替换 | `- fatal 操作仍按升级清单第 4 类处理；普通局部修改继续留在 Lite。` | `- 不可逆操作按安全停清单第 1 条处理（停下来问人）；普通局部修改继续留在 Lite。` |
| e2 | 整行替换 | `  命中升级清单却不按 L0 step3 三分支处理 /` | `  命中安全停清单却不停下来问人 /` |
| e3 | **子串替换** | ` escalated_review: yes 却未核对用户原话 /` （**单个**前导空格） | （删该子串，同行其余保留） |
| e4 | **子串替换** | `，机械捕获同 Model 行纪律` | （删该子串） |

### 3.6 AGENTS.md（Codex 侧平台路由入口）

**删掉整节 `## Lite / Standard / Full Routing（用户可读说明）`，即 L89–L109 共 21 行**
（含节末空行），删后 L88 直接接 `## Default Behavior (no role specified)`。

理由：该节向 Codex 用户承诺三层路由、`当前建议: Lite|Standard|Full` 提示、
以及「**Full 是治理边界，涉及协议/路由契约必须走 Full**」——删完后无任何角色会产生这些行为，
且最后一句与本单核心意图正面冲突。

### 3.7 CLAUDE.md §2.5（**本单成败所系**）

**两行整行替换**（L33 标题 + L34 正文，各全文件唯一，逐字节已核）：

| 原文 | 改为 |
|---|---|
| `### 2.5 Lite 通道（用户显式选择，Alex 不自动推荐）` | `### 2.5 Lite 通道（默认通道）` |
| `` `/alex-lite` → `/blake-lite`：≤5 文件、非协议契约的小任务，或额度紧张时。契约文件 `LITE-*.md`。 `` | `` `/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；仅命中 lite skill 内的「安全停清单」时停下来问人。契约文件 `LITE-*.md`。 `` |

⚠️ **标题必须一起改**（v3 新增）：只改正文会让同一节自相矛盾——标题说「用户显式选择，
Alex 不自动推荐」，正文说「默认通道」。而**一个 agent 读 CLAUDE.md 时先读到标题**，
这恰好落在 §1 称为「本单成败所系」的那一节里。v2 漏了标题，且 AC1b 的排除集只含正文，
**机械上禁止修**（Gate 2 实证：改标题 → AC1b FAIL）。

**CLAUDE.md 其余一个字不动**（§2 路由表、§4 Terminal 隔离等留给 P6）。

### 3.8 tad-help ×2（用户直接调用的帮助文档，两树逐字节相同）

`.claude/skills/tad-help/SKILL.md` 与 `.agents/skills/tad-help/SKILL.md` 同样改
（`## TAD v2.39.0 Highlights` 列表里共 **5 条**要动，**v2 只清了 2 条**——Gate 2 抓出剩下 3 条仍在承诺被删机制）：

| 行 | 动作 |
|---|---|
| `- **Lite / Standard / Full routing profiles**: …` | **整行删** |
| `- **Shared route contract**: …routing-contract.yaml…` | **整行删** |
| `- **Independent depth selection**: design and execution can use different profiles while …` | **整行删**（v3 补：删完就没有 profile 了） |
| `- **No automatic ceremony escalation**: …; risk and explicit routing rules do.` | **子串替换** `risk and explicit routing rules do` → `risk does`（v3 补：指向已删的路由规则） |
| `- **Lite channel basics (since v2.35)**: …` | **子串替换** `escalation valve (SAFETY/protocol/fatal → full TAD, fail-closed)` → `safety stop (irreversible ops / SAFETY surface / global registration → stop and ask)` |

### 3.9 INSTALLATION_GUIDE.md（Gate 2 抓出的第 5 处遗漏）

**删掉整节 `## Lite / Standard / Full 路由`，即 L74–L77 共 4 行**，删后 L73 直接接 `## 平台说明`。

该节与 §3.6 已纳入的 AGENTS.md 节**同构**：同样承诺「涉及…协议契约…时进入 Full」
（§3.6 已判定这句与本单核心意图正面冲突），同样声称「路由由 `.tad/routing-contract.yaml` 决定」
——删完后两 skill 都不再读它，纯假话。它是活文档：`README.md:82` 直接链向它，
`release-verify.sh:750` 对它有版本断言。

⚠️ **L3 的版本横幅 `**Version 2.39.0 — Lite / Standard / Full Routing Profiles**` 不动**——
它是发布史记录，且 `release-verify.sh` 的版本断言依赖它。同类豁免见 §2。

---

## 4. Acceptance Criteria（6 条，Alex 已在零改动仓库实跑）

### 4.0 ⚠️ 本机 shell 是 zsh 5.9，不是 bash

`echo $0` → `/bin/zsh`，`BASH_VERSION` 空。不得 `for f in $VAR`（不分词）、`[ "$a" \< "$b" ]`、
`rm -f dir/glob*`、数组。BSD sed 的 `t` 不接受行内分隔符；`uniq` 折叠中文 → `sort/uniq/comm` 一律
`LC_ALL=C`。**每条 AC 自带 `cd` 与全部定义**（变量和函数都不跨调用存活）。
`bash --version` 是「装着的 bash」不是「正在跑的 shell」——**直接用 Bash tool 跑，不要 `bash -c`**。

---

### AC1 — 不动内容逐字节未变（**围栏，覆盖 4 个文件的 27 个 untouched 节**）

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
python3 - <<'PY'
import hashlib, sys
A="Route Contract（Lite / Standard / Full 三层路由）"
CASES=[
 (".claude/skills/alex-lite/SKILL.md", True,
  {A,"执行脊柱","Scope / Risk Router（影响范围与风险）","Forbidden"},
  178, "13b0b87bb2412d81244979c47dc202a1"),
 (".claude/skills/blake-lite/SKILL.md", False,
  {A,"L0 读契约 + 准入（⚠️ BLOCKING）",
   "L0.5 契约审查复查（所有 LITE 单 ⚠️ BLOCKING）",
   "L3 独立审查（⚠️ MANDATORY——express 教训：小改不等于免审，2026-04-14 一次 15 分钟小改被审出 4 个 P0。此步不可以任何理由跳过）",
   "Scope / Risk Router（影响范围与风险）",
   "L4 Completion（append 到 LITE handoff 文件末尾）","Forbidden"},
  251, "0afa760c84d60bbbf5b018efd749cd5b"),
]
fail=0
for f, sf, touched, en, eh in CASES:
    out=[];cur=None;front=True
    for l in open(f).read().split("\n"):
        if l.startswith("## "): cur=l[3:].strip(); front=False
        if front and sf: continue
        if cur is None or cur not in touched: out.append(l)
    h=hashlib.md5("\n".join(out).encode()).hexdigest(); ok=(len(out)==en and h==eh)
    print(f"  {'OK  ' if ok else 'FAIL'} {f}  {len(out)}行(期望{en}) {h}")
    if not ok: print(f"       期望 {eh}"); fail=1
sys.exit(fail)
PY
[ $? -eq 0 ] && echo "AC1 PASS" || echo "AC1 FAIL"
```

**AC1b — 另 3 个文件的不动内容**（按内容排除，不依赖行号）：

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
python3 - <<'PY'
import hashlib,sys
fail=0
# AGENTS.md：排除「## Lite / Standard / Full Routing」整节
L=open("AGENTS.md").read().split("\n"); out=[];skip=False
for l in L:
    if l.startswith("## Lite / Standard / Full Routing"): skip=True; continue
    if skip and l.startswith("## "): skip=False
    if not skip: out.append(l)
h=hashlib.md5("\n".join(out).encode()).hexdigest()
ok=(len(out)==135 and h=="9862c78301ed4e7d170f036a259e1462")
print(f"  {'OK  ' if ok else 'FAIL'} AGENTS.md 非路由节 {len(out)}行(期望135) {h}")
if not ok: fail=1
# INSTALLATION_GUIDE.md：排除「## Lite / Standard / Full 路由」整节（v3 补）
L=open("INSTALLATION_GUIDE.md").read().split("\n"); out=[];skip=False
for l in L:
    if l.startswith("## Lite / Standard / Full 路由"): skip=True; continue
    if skip and l.startswith("## "): skip=False
    if not skip: out.append(l)
h=hashlib.md5("\n".join(out).encode()).hexdigest()
ok=(len(out)==140 and h=="f9b8bd543cee31341bc041cd524159b1")
print(f"  {'OK  ' if ok else 'FAIL'} INSTALLATION_GUIDE.md 非路由节 {len(out)}行(期望140) {h}")
if not ok: fail=1
# CLAUDE.md：排除 §2.5 的标题行与首行（新旧四态都排除）
EXC={
 "### 2.5 Lite 通道（用户显式选择，Alex 不自动推荐）",
 "### 2.5 Lite 通道（默认通道）",
 "`/alex-lite` → `/blake-lite`：≤5 文件、非协议契约的小任务，或额度紧张时。契约文件 `LITE-*.md`。",
 "`/alex-lite` → `/blake-lite`：**默认通道**。文件数、协议密度、是否触及协议契约均不构成升级理由；仅命中 lite skill 内的「安全停清单」时停下来问人。契约文件 `LITE-*.md`。",
}
out=[l for l in open("CLAUDE.md").read().split("\n") if l not in EXC]
h=hashlib.md5("\n".join(out).encode()).hexdigest()
ok=(len(out)==109 and h=="c358c0c0c0bcd49602b43509c77f91c6")
print(f"  {'OK  ' if ok else 'FAIL'} CLAUDE.md 除 §2.5 标题+首行 {len(out)}行(期望109) {h}")
if not ok: fail=1
# tad-help ×2：排除 3 整行删除 + 2 行子串替换（新旧两态）—— v3 补，v2 算了值却没接进 AC
TH_DROP_MARK=("- **Lite / Standard / Full routing profiles**",
              "- **Shared route contract**",
              "- **Independent depth selection**")
TH_SUB_MARK=("- **No automatic ceremony escalation**", "- **Lite channel basics (since v2.35)**")
for f in (".claude/skills/tad-help/SKILL.md",".agents/skills/tad-help/SKILL.md"):
    out=[l for l in open(f).read().split("\n")
         if not l.startswith(TH_DROP_MARK) and not l.startswith(TH_SUB_MARK)]
    h=hashlib.md5("\n".join(out).encode()).hexdigest()
    ok=(len(out)==231 and h=="dfd2ba7abd2c8a002132da9dc28218f1")
    print(f"  {'OK  ' if ok else 'FAIL'} {f} 除 5 行 {len(out)}行(期望231) {h}")
    if not ok: fail=1
sys.exit(fail)
PY
[ $? -eq 0 ] && echo "AC1b PASS" || echo "AC1b FAIL"
```

⚠️ **AC1/AC1b 在零改动仓库会 PASS**（不动内容本来就没动）。它们是**围栏不是交付判据**——
判别力由 AC2/AC3 提供。这是诚实记录。
⚠️ **AC1 只冻结 untouched 节。touched 节内的破坏它看不见**——那由 AC2 的正向锚兜（见下）。

---

### AC2 — 该删的全零 + **该留的必须还在**

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
ac2=0
# ── 负向：必须为 0 ──
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  for pat in '## Route Contract' 'R0 — Route preflight' 'RouteDecision' 'route_level' \
             'blocked_missing_contract' 'blocked_stale_revision' 'escalated_full' \
             'design_depth' 'execution_depth' 'F0_FATAL' 'F1_GOVERNANCE' \
             'Standard is a profile' 'routing-contract.yaml' \
             'escalated_review' 'escalated' '额度出口' '升级清单' '转 full TAD' \
             '### Reviewer 档位规则' '强档' 'REVIEWER-TIER-DEGRADED' \
             'Model 行捕获纪律' 'Model 行捕获紀律' 'Model 行纪律' '格式同 Model 行' \
             'default_subagent_model' 'CODEX_HOME' 'alias-mapped'; do
    n=$(grep -cF -- "$pat" "$f"); [ "$n" -eq 0 ] || { echo "  AC2 FAIL [$f] 残留 '$pat' ×$n"; ac2=1; }
  done; done
for f in AGENTS.md .claude/skills/tad-help/SKILL.md .agents/skills/tad-help/SKILL.md; do
  for pat in 'Lite / Standard / Full Routing' 'Standard 是深度配置' '当前建议' \
             'routing profiles' 'Shared route contract' 'escalation valve' \
             'Independent depth selection' 'different profiles' 'explicit routing rules'; do
    n=$(grep -cF -- "$pat" "$f"); [ "$n" -eq 0 ] || { echo "  AC2 FAIL [$f] 残留 '$pat' ×$n"; ac2=1; }
  done; done
# INSTALLATION_GUIDE.md（v3 补）：只查节内承诺，L3 版本横幅豁免（见 §3.9）
for pat in '## Lite / Standard / Full 路由' '涉及安全、协议契约或致命操作时进入 Full' 'routing-contract.yaml'; do
  n=$(grep -cF -- "$pat" INSTALLATION_GUIDE.md); [ "$n" -eq 0 ] || { echo "  AC2 FAIL [INSTALLATION_GUIDE.md] 残留 '$pat' ×$n"; ac2=1; }
done
n=$(grep -cF -- '非协议契约的小任务' CLAUDE.md); [ "$n" -eq 0 ] || { echo "  AC2 FAIL CLAUDE.md 旧 §2.5 残留"; ac2=1; }
# ── 正向：必须还在（挡 touched 节被整节掏空；Gate 2 实证 v1 放行过这种破坏）──
must() { n=$(grep -cF -- "$2" "$1"); [ "$n" -ge "$3" ] || { echo "  AC2 FAIL [$1] '$2' 只剩 $n（期望 ≥$3）"; ac2=1; }; }
for p in .claude .agents; do
  # blake-lite —— 锚必须落在【正文】里，标题存在性挡不住掏空
  must "$p/skills/blake-lite/SKILL.md" '跳过 L3 reviewer' 1                    # Forbidden 正文
  must "$p/skills/blake-lite/SKILL.md" '以自审、自我复核替代 subagent spawn' 1   # Forbidden 正文
  must "$p/skills/blake-lite/SKILL.md" '六条件自治修复' 1                       # L3 正文
  must "$p/skills/blake-lite/SKILL.md" 'UNVERIFIED-BY-EXECUTION' 1             # L3 正文（v3 补）
  must "$p/skills/blake-lite/SKILL.md" '最小探针' 1                            # L3 正文（v3 补）
  must "$p/skills/blake-lite/SKILL.md" '**Model**: harness=' 1                 # L4 模板（§3.2 明写保留，v3 补）
  must "$p/skills/blake-lite/SKILL.md" '## L3 独立审查' 1
  must "$p/skills/blake-lite/SKILL.md" '## Forbidden' 1
  # alex-lite —— v2 只给了 3 条且【无一在 Forbidden 正文内】，掏空 Forbidden 可全绿逃逸
  must "$p/skills/alex-lite/SKILL.md"  '以自审替代 reviewer spawn' 1            # Forbidden 正文（v3 补，堵 v2 逃逸）
  must "$p/skills/alex-lite/SKILL.md"  '不得把 FAIL 契约交给 blake-lite' 1      # L2.5 Stop
  must "$p/skills/alex-lite/SKILL.md"  '## Forbidden' 1
done
must CLAUDE.md '默认通道' 1
[ $ac2 -eq 0 ] && echo "AC2 PASS" || echo "AC2 FAIL"
```

⚠️ **正向锚是 v2 新增的**。Gate 2 实证：v1 只有负向锚时，**把 `## L3 独立审查（⚠️ MANDATORY）`
整节掏空 + 两份 Forbidden 掏空 + 路由机器搬进新文件，五条 AC 全绿**。
⚠️ 锚点用 `转 full TAD` 而非 `转 full`——后者与 §3.3 保留的清单文本互斥（v1 的阻塞缺陷）。
⚠️ `Model 行纪律` / `格式同 Model 行` 是 v2 补的：v1 只查 `Model 行捕获纪律`，
漏掉 3 处不带"捕获"二字的悬空引用。

---

### AC3 — 新安全停清单逐字节正确且 4 文件相同

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
ac3=0
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md \
         .agents/skills/alex-lite/SKILL.md .agents/skills/blake-lite/SKILL.md; do
  blk=$(awk '/ESCALATION-LIST-BEGIN/{f=1} f{print} /ESCALATION-LIST-END/{exit}' "$f")
  h=$(printf '%s\n' "$blk" | md5); n=$(printf '%s\n' "$blk" | wc -l | tr -d ' ')
  [ "$h" = "166464e66b98c701a2b892d6e773256f" ] && [ "$n" -eq 7 ] \
    && echo "  OK   $f" || { echo "  AC3 FAIL $f  $n 行(期望7) md5=$h"; ac3=1; }
done
[ $ac3 -eq 0 ] && echo "AC3 PASS" || echo "AC3 FAIL"
```

（`printf '%s\n' "$blk"` 的换行语义已由 Gate 2 实测确认无多/少：`$(...)` 剥尾换行、`printf` 补回一个。）

---

### AC4 — 减重落在实测带内 + parity

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
ac4=0; tot=0
for f in .claude/skills/alex-lite/SKILL.md .claude/skills/blake-lite/SKILL.md; do
  c=$(wc -c < "$f" | tr -d ' '); echo "  $f: $(wc -l < "$f" | tr -d ' ') 行 / $c 字符"; tot=$((tot + c))
done
echo "  两 skill 合计: $tot（改动前 64,050；Gate 2 沙箱忠实实现实测 45,234）"
[ "$tot" -le 47000 ] || { echo "  AC4 FAIL 合计 > 47,000（删得不够）"; ac4=1; }
[ "$tot" -ge 44000 ] || { echo "  AC4 FAIL 合计 < 44,000（删多了）"; ac4=1; }
for s in alex-lite blake-lite tad-help; do
  a=$(md5 -q ".claude/skills/$s/SKILL.md"); b=$(md5 -q ".agents/skills/$s/SKILL.md")
  [ "$a" = "$b" ] && echo "  OK   parity $s" || { echo "  AC4 FAIL parity $s"; ac4=1; }
done
[ $ac4 -eq 0 ] && echo "AC4 PASS" || echo "AC4 FAIL"
```

⚠️ **上下限都要**。v1 只有上限，Gate 2 实证：整节掏空后 40,788 字符照样 PASS。
带宽 44–47K 来自 Gate 2 沙箱**忠实实现实测 45,234**，不是估算。

---

### AC5 — 改动围栏（HEAD 锚 + 新增文件扫描）

```bash
cd "$(git rev-parse --show-toplevel)" || exit 1
ac5=0
[ "$(git rev-parse HEAD)" = "6a7cef0b22fddcd050af53949fd43e3c8ca0a36a" ] \
  || { echo "  AC5 FAIL HEAD 已移动: $(git rev-parse HEAD)"; ac5=1; }
[ "$(git ls-files -v | grep -vc '^H ')" -eq 0 ] \
  || { echo "  AC5 FAIL index 有 assume-unchanged/skip-worktree"; ac5=1; }
A=$(mktemp); cat > "$A" <<'EOF'
.claude/skills/alex-lite/SKILL.md
.claude/skills/blake-lite/SKILL.md
.agents/skills/alex-lite/SKILL.md
.agents/skills/blake-lite/SKILL.md
.claude/skills/tad-help/SKILL.md
.agents/skills/tad-help/SKILL.md
AGENTS.md
CLAUDE.md
INSTALLATION_GUIDE.md
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/tracked-after.txt
.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/untracked-after.txt
.tad/research-notebooks/REGISTRY.yaml
EOF
V=$(mktemp)
git diff --name-only HEAD | LC_ALL=C sort -u | grep -vxF -f "$A" \
  | grep -vE '^\.tad/evidence/(journal|traces|decisions|ralph-loops)/|^\.tad/memory/|^\.tad/active/handoffs/COMPLETION-' > "$V"
[ -s "$V" ] && { echo "  AC5 FAIL tracked 越权改动:"; cat "$V"; ac5=1; }
# v2 新增：交付目录内不得新增文件（v1 实证：路由机器可搬进新的未跟踪文件后全绿）
for d in .claude/skills/alex-lite .claude/skills/blake-lite .agents/skills/alex-lite .agents/skills/blake-lite; do
  n=$(find "$d" -type f | wc -l | tr -d ' ')
  [ "$n" -eq 1 ] || { echo "  AC5 FAIL $d 有 $n 个文件（期望 1）"; find "$d" -type f; ac5=1; }
done
[ $ac5 -eq 0 ] && echo "AC5 PASS" || echo "AC5 FAIL"
```

⚠️ **HEAD 锚，不用快照。** 快照基线由被验证方自己写在自己的 `/tmp`，无时间戳无见证——
**先破坏、后拍基线，围栏必绿**（2026-08-05 对抗 reviewer 沙箱实证）。
⚠️ **绝不拿仓库真实文件当探针**：2026-08-05 有人拿 tracked 的 `NEXT.md` 试围栏再 `git checkout --`
还原，抹掉用户 28 行未提交改动。要造探针就在 `/tmp` 建独立 git 仓。
⚠️ 允许清单里的 4 个非交付文件是起草时已 dirty 的，**改它们不会被抓** → Gate 4 由 Alex 逐个比对。

---

## 5. 陷阱表（**v2 已按 Gate 2 实证更正**）

| 陷阱 | 谁挡 | v1 的错误声称 |
|---|---|---|
| `route_level` 悬空 | 合并 P3 整节删 + AC2 | — |
| 「升级清单」散在 frontmatter / Scope Router | AC2 全文件查 | — |
| `Model 行纪律`（无"捕获"）悬空 ×3 | AC2 补锚 | v1 漏 |
| 改了**不动**节 | AC1/AC1b digest | ✓ |
| **掏空 touched 节内的真约束** | **AC2 正向锚 + AC4 下限** | ❌ v1 称「AC1 挡」——**假的**，AC1 按构造排除 touched 节 |
| 路由机器搬进新文件 | **AC5 find 计数** | ❌ v1 无覆盖 |
| 4 文件清单不一致 / 镜像漏同步 | AC3 + AC4 parity | ✓ |
| 繁体/同义改写规避 | AC2 繁体探针 + AC1 digest | ✓ |
| 围栏基线被后拍 | AC5 HEAD 锚 | ✓ |

---

## 6. 风险与注意

### ⚠️ 6.1 本单砍掉最后一道通道护栏，而主力模型有已实测的审查盲区

砍掉「协议契约面」后，**lite 可直接改自己的 SKILL.md 且不会停**。剩余防线：约束准入闸 +
设计期 1 reviewer + 实现后 1 reviewer + 人两次拍板。

而 `2026-08-02-model-diversity-audit-results.md` 实测 **flash 审 flash 有系统性盲区**
（只读审查 GATE PASS vs 执行探针盲审 FAIL P0×1 + P1×6），`2026-08-02-multi-model-portability-verification.md`
坐实用户主力是 deepseek-v4-flash（一张 LITE 单 401 轮 100% flash）。

**两件事叠加是本次砍除的真实代价，明记不隐瞒。** 人 2026-08-05 知情裁定继续。
缓解：Epic P4 实测时验证「reviewer 是否真被 spawn」（已入 Epic Known Issues）。

### ⚠️ 6.1b touched 节内部由 Alex 在 Gate 4 读 diff 验，**不由 AC 验**（人 2026-08-05 裁定）

AC1/AC1b 只冻结 **untouched** 内容；touched 的 11 个节（含 alex-lite 整条执行脊柱、
blake-lite 的 L0/L0.5/L3/L4/Forbidden）**内部无逐字节保证**。AC2 的正负锚 + AC4 上下限
+ AC5 的 find 计数联合覆盖了 Gate 2 演示过的全部具体攻击，但**词表拦不住改写**——
对抗 reviewer 写出过一条零禁词的完整三层路由指令。

**根因**：规格规定了「删什么」，没规定「删完长什么样」。要机械验全就得把 11 个节的最终文本
全写进契约，那等于 Alex 把活干了、Blake 变打字员。人裁定：**接受这个口子，
由 Alex 在 Gate 4 逐行读 254 行删除的 diff**。这是诚实记录，不是遗漏。

### 6.2 Alex 在 Gate 4 必须补四件事（**不给 Blake，因为落在新清单第 2 条 SAFETY 面上或不在授权集内**）

1. **台账补一行**：`Reviewer 档位规则` 记 `SUPERSEDED`，载体路径填
   `.tad/evidence/research/2026-08-02-model-diversity-audit-results.md`。
   它**有真载体**，删是知情取舍——不补这行，六个月后看台账的人会读成相反结论。
2. **`.tad/project-knowledge/patterns/gate-design.md` 两处与新规则矛盾**（Gate 2 发现）：
   L113 的 Action 写着 route SAFETY work back to full via an **escalation valve**；
   L126–142 整条 L2 条目讲 `route_level: full` → 强档 → `REVIEWER-TIER-DEGRADED`。
   删完后这两条指向不存在的规则，须由 Alex 按知识蒸馏纪律修订（标注被本单取代，不静默删）。
3. **作废 `HANDOFF-20260804-full-reviewer-tier-rule.md`**（人 2026-08-05 裁定），
   归档到 `.tad/archive/handoffs/withdrawn/`。
   ⚠️ **Gate 2 发现它是一张活契约，不是待处置的僵尸**：其 **AC8(b) 钉死了哨兵块 md5
   `4c55bcb6563f24dc78449fb19ff76067`——正是四份 skill 的当前值，现在是绿的**；本单 §3.3
   改成 `166464e6…` 即让它变红。其 L112 更写着「lite 保留自己的档位强制，本单不动它」，
   被本单 §3.2 直接证伪。三重失效（用户 08-04 已裁定不要强档 / 本单删 lite 档位规则 /
   full 本身 P6 退场）→ 作废。
4. **更新 `NEXT.md`**（`②b 从 lite 移除档位强制` 等 3 条已由本单完成，仍是 `- [ ]`）。
   它 tracked 且 clean，**不在 AC5 授权集内 → Blake 改它会 FAIL**，故归 Alex。

**⚠️ 方法论教训（Gate 2 实证，值得记住）**：`git grep` **看不见 untracked 文件**。
`.tad/active/handoffs/` 下两张单全是 untracked，`git grep` 命中数 = 0——
上面第 3 条差点被漏掉。**消费方扫描必须同时跑 `git ls-files --others --exclude-standard`。**

### 6.3 其它

- 本单**不新增任何 MUST/BLOCKING**（安全停清单是既有约束的**收缩**），故不触发定价闸义务。
- 发现契约本身有错 → **停，报告人回 Alex 修订，不自行改规格**。
- Epic 执行约束 5：Completion 须记录本 phase 实际消耗。
- §2「F0 七类」的说法：`routing-contract.yaml` 实为 **6 个键**（`auth_payment` 一键覆盖支付+认证），
  新清单第 1 条散文列 7 项。数字差异已知，不影响交付。

---

## 7. Knowledge 引用

- `.tad/evidence/audits/P1b-deep-verdicts.md` — 7 条判定与方法（**先追条文自称出处，再关键词补搜**）
- `patterns/ac-verification.md` — 验证强度受限于交付物确定性；围栏需正负双向
- `patterns/gate-design.md` — 围栏基线由被验证方自持则可被时机攻击（⚠️ 另见 §6.2，本文件有两条待修订）
- `patterns/shell-portability.md` — zsh 非 bash；`comm` 未排序静默出错
- `principles.md` §`Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count` — 本单 AC2 正负双锚的直接依据

---

## 8. v1 作废记录 + Gate 2 检查表

**v1 被两名 reviewer 独立判 FAIL**（2026-08-05）。核心缺陷：

| # | 缺陷 | v2 修法 |
|---|---|---|
| P0 | AC2 锚 `转 full` 与 AC3 钉死块内的 `转 full` **互斥** → 忠实实现必 FAIL，Blake 卡死 | 锚改 `转 full TAD`（两名 reviewer 各自验证判别力保留） |
| P0 | AC1/AC4/AC5 组合**挡不住 touched 节被整节掏空**——掏掉 `## L3 独立审查（MANDATORY）`+ 两份 Forbidden + 路由机器搬进新文件，五条全绿 | AC2 加 16 条正向存活锚 + AC4 加下限 + AC5 加 find 计数 |
| P0 | `AGENTS.md` 三层路由整节遗漏 | §3.6 |
| P0 | `CLAUDE.md §2.5` 被误归 P6——它是**本单成败所系** | §3.7 |
| P1 | §3.4(d) r3「原文」是行前缀，字面执行**静默删掉 `不得把 FAIL 契约交给 blake-lite。`** 且五条 AC 全绿 | 改为子串替换 d3 |
| P1 | `Model 行纪律` 3 处悬空，AC2 锚差"捕获"二字 | §3.4 d5/d6、§3.5 e4 + AC2 补锚 |
| P1 | `tad-help` ×2 帮助文档全假 | §3.8 |
| P1 | `gate-design.md` 两条知识与新规则矛盾 | §6.2（归 Alex） |
| P2 | AC4 预期带 47–50K 错（实测 45,234） | 改 44–47K |
| P2 | §3.5(c) r3 前导空格字节错 | e3 已修正为单空格 |
| P2 | 两处替换的空行未说明 | §3.2 / §3.5(b) 已补 |

**Gate 2 给 v2 的背书**（两名 reviewer 独立实证，v2 保留未动）：
4 个钉死值全部独立复现；`skip_front` 不对称正确且必要；5 个变异测试全部按声称挡住；
`$?` 穿透 heredoc / `grep -cF --` 逐字传递 / `printf '%s\n'` 换行语义 / `wc -c` 前导空格 /
`grep -vxF -f` 五个 shell 怀疑点在 zsh 5.9 下全部无误。

- [x] 台账超期扫描：0 数据行，无超期
- [x] AC 条数 ≤10：6 条
- [x] 消费方扫描（v1 做过 + v2 按 Gate 2 补全 4 个文件）
- [x] 全部钉死值实测（v2 新增 3 个：AGENTS.md `9862c783…` / CLAUDE.md `a8a6802a…` / tad-help `2b609c5c…`）
- [x] **v2 专家审查（2 名，均已回报）** → v3。核心结论与修法：

  | # | 级 | 发现 | v3 修法 |
  |---|---|---|---|
  | 1 | P0 | **`INSTALLATION_GUIDE.md` 第 5 处遗漏**——与 §3.6 已纳入的 AGENTS.md 节同构、同冲突 | §3.9 纳入（第 9 文件）+ AC1b 第 5 个 digest + AC2 锚 |
  | 2 | P0 | **`HANDOFF-20260804-full-reviewer-tier-rule.md` 是活契约**，AC8(b) 钉的哨兵 md5 现在是绿的，本单落地即红；L112 前提被证伪 | §6.2 第 3 条：人裁定作废，归档 withdrawn/ |
  | 3 | P1 | **alex-lite `## Forbidden` 整节掏空 → 6 条 AC 全绿**（v2 只把正向锚对称到 blake-lite） | AC2 补 `以自审替代 reviewer spawn`（落在 Forbidden 正文内）|
  | 4 | P1 | **CLAUDE.md §2.5 标题与新正文自相矛盾**，且 AC1b 机械上禁止修 | §3.7 扩为改标题+正文两行，AC1b 排除集扩为四态、digest 重算 `c358c0c0…` |
  | 5 | P1 | **tad-help 同一列表还剩 3 条悬空承诺**（v2 只清了 5 条中的 2 条）| §3.8 补删 `Independent depth selection` + 改 `explicit routing rules` 尾巴 + AC2 补 3 个负向锚 |
  | 6 | P2 | **tad-help digest 算了却没接进 AC1b** → 掏空 tad-help 全绿 | AC1b 补第 4/5 段 |
  | 7 | P2 | `**Model**: harness=` §3.2 明写保留却零 AC 覆盖；`不可跳过、不可自审替代` 锚落在 AC1 已冻结的 untouched 节里，判别力为 0 | 前者补正向锚，后者删除 |
  | 8 | P2 | AC4 下限余量仅 1,144 字节；单 token 锚挡不住"重写得更简洁" | 补 L3 正文双锚 `UNVERIFIED-BY-EXECUTION` + `最小探针` |
  | — | — | 版本横幅类未显式豁免 | §2 补显式豁免条款 |

  **v2 获得的背书**（两名 reviewer 独立实证，v3 保留未动）：`转 full TAD` 锚修复真有效
  （v1 锚会让忠实实现 FAIL，实测确认）；掏空/搬文件的 v1 原攻击被 AC2+AC4+AC5 **三重独立抓住**；
  d3 子串替换真的保住了 `不得把 FAIL 契约交给 blake-lite。`；`skip_front` 不对称正确且必要；
  AC1b 的空行处理与 §3.6 逐字节一致；`must()` 动态作用域、`$?` 穿透 heredoc、`printf '%s\n'`
  换行语义、`find` 计数在 zsh 5.9 下全部无误。

- [x] **v3 全部 AC 在零改动仓库由 Alex 实跑**：AC1/AC1b **PASS**（5 个 digest 全绿）、
      AC2 **FAIL**（负向锚全命中）且 **22/22 正向锚存在**（证明不会误伤忠实实现）、
      AC3/AC4 **FAIL**、AC5 **PASS**。
- [ ] **人工拍板**（L3）
