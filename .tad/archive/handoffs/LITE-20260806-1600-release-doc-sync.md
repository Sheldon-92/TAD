# LITE Handoff: v2.40.0 发布准备（release 单 A）

**Date**: 2026-08-06
**Revision**: **v3**（v1 FAIL → v2 FAIL → v3 CONDITIONAL→PASS。三轮 L2.5，累计修
**7 P0 + 8 P1 + 9 P2**。v2 重新定义了判据设计，v3 补齐形状约束，见 Contract Review）
**Series**: release-2.40.0 step 1/2（单 B = `git tag` + `push`，**命中安全停清单第 1 条，需人授权**）

## 目标（2-3 句，含"为什么"）

Epic `lite-as-tad-body` 已完成，`CLAUDE.md` 写着「默认通道 = lite」，但发布物仍指 full 为主路径
——**该不一致由 P6 造成**，其 follow-up 指定归属为「下次 publish 一并同步」。**本单就是那个下次。**

本单交付一个**通过本项目自身发布闸**的工作区：路由描述一致 + 版本 bump 到 2.40.0 + CHANGELOG。
**不执行 tag / push**（单 B）。

## v1 为何 FAIL —— 两个 P0 改变了本单的设计

- **P0-1｜v1 的 AC2 用 `tad.sh` 全文 md5 焊死了一个会让 14 个下游静默冻结的 bug。**
  `tad.sh:22 TARGET_VERSION="2.39.0"` 未 bump，而 `derive_target_version()` 的**唯一调用点在
  L1550（下载之后）**；`detect_state()` L1352 用的是**尚未被覆盖的字面量** →
  `ACTION="none"` → L1484 打印「✅ Nothing to do. TAD v2.39.0 is already installed.」→ `exit 0`。
  **v2.40.0 发布后，停在 2.39.0 的下游跑安装命令会成功退出且什么都不做。**
  Alex 已走通完整调用链实证。L18 的注释「so TARGET_VERSION can never go stale」**只对下载后的
  路径成立**，对下载前的状态闸不成立——注释本身在误导。
  ⚠️ 这正是 `principles.md` §`Deny-List Beats Allow-List for Sync Sets` 逐字记录的
  「**tad.sh 卡在 2.19.1（不在 18 项 version-string 清单里）**」同类事故。**v1 漏引了这条**。

- **P0-2｜v1 只 bump 了 12 分之 1，且其 AC 黑名单在结构上禁止补全。**
  实跑 `release-verify.sh` 后确认真实规模：`version` 模式报 **29 处 STALE**、
  `version-sweep` Layer 1 报 **12 条 BLOCKING**，且 `parity` 要求
  `.claude/skills` 与 `.agents/skills` **byte-identical**。v1 的黑名单把其中 5 处列为「出现即 FAIL」。

## 判据设计的转变（v1 → v2）

v1 用「Alex 手工构造 md5 + 逐处 grep 锚」。**v2 改为让发布闸自己当判据。**

理由：本单的正确性定义就是「能通过 `release-verify`」，而该工具是既有的、已验证的、
且 runbook 明文列为发布门（step3b parity / step3c version）。用它当 AC，
既避开了 Alex 反复数不准的老毛病（本单起草过程中「12 处」→「22 处」→「24 处」→
L2.5 实跑 **29 处**，**四次估计四次错**），也让判据与真实门槛完全对齐。
⚠️ 第四次错发生在 v2 已经宣布「不再手工枚举」之后——**这本身就是该转向最强的论据**。
逐处 md5 仍保留在**唯一危险文件** `tad.sh` 上（见 AC2）。

## 不做什么

- ❌ **不执行 `git tag` / `git push` / 任何 release 动作**（安全停清单第 1 条 → 单 B，需人授权）。
- ❌ **不碰 `tad.sh` 的平台检测逻辑**（L792/794 的 `[ -d ".claude/skills/alex" ]` /
  `[ -d ".agents/skills/alex" ]`）——那是安装分支判断，改了会破坏 14 个下游的安装。
- ❌ **不改 `ROADMAP.md`**——其 2 处 `/gate` `/blake` 是指向 skill 文件的 markdown 链接，不是路由推荐（已核实）。
- ❌ **不改 `INSTALLATION_GUIDE.md` 故障排查段（L132-133）**、**不改 `README.md` 版本历史表**
  （L352/361/363）、**不改 README L114-117 的 v2.35.0 历史发布说明**——历史记录不作追溯性修改。
- ❌ 不改 `CLAUDE.md`、`.tad/hooks/`、`settings*.json`、两个 lite skill。
- ❌ **不改任何已生成的 `.tad/capability-packs/*/meta.yaml`**（25 个已装 pack）——
  本单只改 `pack-meta-template.yaml`（模板，影响未来生成物）与 `pack-registry.yaml` 的
  `synced_from_version`（无现役消费方，见「风险与注意」）。
- ❌ **不改 `README.md:88` 的 `### v2.39.0 — …` 历史发布标题**（`version` 模式已豁免）。
- ❌ **不为消除 `version-sweep` Layer 2 噪音而改动无关文件**（Layer 2 是 advisory，
  已知含假阳性：`ai-podcast-production/SKILL.md:109` 的 `VoxCPM2 v2.0.3` 是别的软件的版本号）。
- ❌ 不新增任何 MUST / 禁止条目 → 不触发约束准入闸。

## 文件清单

**版本 bump（由 `release-verify` 定义，共 29 处 STALE / 12 条 BLOCKING 注册表）**——
Blake 按工具输出逐处改，不必依赖本契约枚举（v1 三次枚举三次错，故不再枚举）：
```bash
bash .tad/hooks/lib/release-verify.sh version "$PWD" 2.40.0 2.39.0   # 列出全部 STALE
bash .tad/hooks/lib/release-verify.sh version-sweep "$PWD" 2.40.0    # 列出 Layer 1 BLOCKING
```
⚠️ **两处需要判断，不是机械替换**：
1. `tad.sh:22` —— 见 AC2，md5 已钉死。
2. `{.claude,.agents}/skills/tad-help/SKILL.md` 的 `## TAD v2.39.0 Highlights` 段——
   **标题改版本号的同时必须重写内容**（现列的是 v2.39.0 的 5 条特性；
   若只改标题就是把 v2.39.0 的特性说成 v2.40.0 的）。新内容见 §Highlights 新文本。

**路由描述同步（4 个文件）**：`tad.sh`（2 处提示）、`README.md`（2 处表）、
`INSTALLATION_GUIDE.md`（1 处 + L51 注释）、`AGENTS.md`（1 处）。逐字文本见 §路由改动。

**CHANGELOG.md**：新增 `## [2.40.0] - 2026-08-06` 段，文本见 §CHANGELOG 新增段。

---

## 路由改动（逐字 old → new）

### tad.sh — 2-a（约 L1487-1489）
old：
```
            echo "  /alex  - Start Agent A (Solution Lead)"
            echo "  /blake - Start Agent B (Execution Master)"
            echo "  /gate  - Run quality gate"
```
new：
```
            echo "  /alex-lite, /blake-lite  - Default channel (lightweight, full capability)"
            echo "  /alex, /blake, /gate     - Reserved channel"
```

### tad.sh — 2-b（约 L1848）
⚠️ **分隔符是 U+00B7 MIDDLE DOT `·`**，不是 bullet `•`、不是句点。md5 对此敏感（L2.5 实测：
用 `•` 得 `8400a968…`、用 `.` 得 `a4f83dd1…`，只有 U+00B7 命中）。
old：
```
    echo -e "  2. ${CYAN}/alex${NC}, ${CYAN}/blake${NC}, ${CYAN}/gate${NC}"
```
new：
```
    echo -e "  2. ${CYAN}/alex-lite${NC}, ${CYAN}/blake-lite${NC} (default) · ${CYAN}/alex${NC}, ${CYAN}/blake${NC}, ${CYAN}/gate${NC} (reserved)"
```

### README.md — 替换整个「Open Two Terminals」区块（L182-187）
⚠️ v1 只替 L185，会把 lite 塞进标题为「Open Two Terminals」的表——**与 `CLAUDE.md` §2.5
「lite 可同 terminal」正面矛盾**（L2.5 P1-1）。故整块替换。
old（6 行）：
```
### 2. Open Two Terminals

| Terminal 1 | Terminal 2 |
|------------|------------|
| `/alex` | `/blake` |
| Design & Planning | Implementation |
```
new（14 行）：
```
### 2. Pick a Channel

**Default — TAD Lite** (one terminal; the human types the command to switch roles)

| Command | Role |
|---------|------|
| `/alex-lite` | Design & Planning |
| `/blake-lite` | Implementation |

**Reserved — full TAD** (two terminals, human is the only bridge)

| Terminal 1 | Terminal 2 |
|------------|------------|
| `/alex` | `/blake` |
| Design & Planning | Implementation |
```

### README.md — 命令表（L289-291）
old（3 行）：
```
| `/alex` | - | Activate Alex (Solution Lead) |
| `/blake` | - | Activate Blake (Execution Master) |
| `/gate N` | Both | Execute quality gate N |
```
new（5 行）：
```
| `/alex-lite` | - | **Default channel** — Alex Lite (design) |
| `/blake-lite` | - | **Default channel** — Blake Lite (implementation) |
| `/alex` | - | Reserved channel — Alex (Solution Lead) |
| `/blake` | - | Reserved channel — Blake (Execution Master) |
| `/gate N` | Both | Reserved channel — Execute quality gate N |
```

### INSTALLATION_GUIDE.md — 快速开始（L56-61）
old（5 行）：
```
# Terminal 1: 设计与规划
/alex

# Terminal 2: 实现与执行
/blake
```
new（7 行）：
```
# 默认通道（lite —— 可同一 terminal，由人输入命令切换角色）
/alex-lite      # 设计与规划
/blake-lite     # 实现与执行

# 保留通道（full —— 需双 terminal）
/alex           # Terminal 1: 设计与规划
/blake          # Terminal 2: 实现与执行
```
⚠️ 同一 fence 内 L51 的 `cat .tad/version.txt          # 应显示 2.39.0` 也要改成 `2.40.0`
（L2.5 P1-2：本单把 version.txt 改了，紧邻 5 行的验证注释若不同步，用户会以为装错了）。

### AGENTS.md — 角色切换说明（L18）
old：
```
Use `$alex` / `$blake` (full TAD) or `$alex-lite` / `$blake-lite` (Lite, the default channel) to activate a role. Alternatively, say any trigger phrase:
```
new：
```
Use `$alex-lite` / `$blake-lite` (Lite — **the default channel**) or `$alex` / `$blake` (full TAD — **reserved channel** since 2026-08-06) to activate a role. Alternatively, say any trigger phrase:
```

---

## 发布横幅新文案（5 处 + codex README，L2.5 P1-5）

⚠️ **实测 `version` 模式报 29 处 STALE，不是 24**（本单第四次范围估错：12→22→24→**29**）。
多出的 3 处里，`README.md:462` 等 **5 处携带 v2.39.0 的发布副标题
`Lite / Standard / Full Routing Profiles`——那正是本次 Breaking Changes 宣布废除的三层路由**。
机械替换版本号会产出「版本是新的、副标题在宣传刚删掉的东西」。

**新副标题（Alex 裁定）**：`Lite is the Default Channel` —— 非任意选择，是本次发布的实际内容。

| 位置 | 新文本 |
|---|---|
| `README.md:3` | `**Version 2.40.0 - Lite is the Default Channel**` |
| `README.md:462` | `**Welcome to TAD v2.40.0 - Lite is the Default Channel**` |
| `INSTALLATION_GUIDE.md:3` | `**Version 2.40.0 — Lite is the Default Channel**`（注意是全角破折号 `—`） |
| `docs/MULTI-PLATFORM.md:3` | `**Version**: 2.40.0 (Dual-Platform Architecture — Lite is the Default Channel)` |
| `.tad/config.yaml:1` | `# TAD Configuration v2.40.0 - Lite is the Default Channel` |
| `.tad/codex/README.md:3` | `…(since v2.25.0, current v2.40.0).` —— 仅改版本号 |
| `PROJECT_CONTEXT.md:4` | `- **Version**: 2.40.0 (Lite is the default channel + Lite core closure + 25 capability packs + brain-native knowledge search + Claude Science skill architecture)` |

⚠️ **两处必须保留，不得清零**（L2.5 P0-7 / P1-8）：
- **`README.md:88`** 的 `### v2.39.0 — Lite / Standard / Full Routing Profiles` —— 历史发布标题
  （`version` 模式的标题豁免已正确放行它）。
- **`PROJECT_CONTEXT.md:21`** 的 `- **Lite / Standard / Full Routing Profiles** (2026-08-02) — Gate 4 PASS…`
  —— 历史成就记录（**大写** R/P，与 L4 的小写变体不同，`-F` 锚不会误伤，但手动清理时易顺手删掉）。

补锚（⚠️ **README 是 `== 1` 不是 `== 0`** —— v3 初版写 `== 0` 与上面「L88 必须保留」自相矛盾，
按那样执行会抹掉历史标题，与 v2 的 P0-3 同一病灶）：
```bash
grep -Fc  'Lite / Standard / Full Routing Profiles' README.md                  # == 1（仅剩 L88）
grep -Fxc '### v2.39.0 — Lite / Standard / Full Routing Profiles' README.md    # == 1（正向锁它存活）
grep -Fc  'Lite / Standard / Full Routing Profiles' INSTALLATION_GUIDE.md      # == 0
grep -Fc  'Lite / Standard / Full Routing Profiles' docs/MULTI-PLATFORM.md     # == 0
grep -Fc  'Lite / Standard / Full Routing Profiles' .tad/config.yaml           # == 0
grep -Fc  'Lite / Standard / Full routing profiles' PROJECT_CONTEXT.md         # == 0（小写变体，L4）
grep -Fc  'Lite / Standard / Full Routing Profiles' PROJECT_CONTEXT.md         # == 1（大写，L21 历史）
```

## Highlights 新文本（tad-help，两侧各一份，须 byte-identical）

将 `## TAD v2.39.0 Highlights`（L221）及其下**全部 7 条** `- **…**: …`（L222-228）替换为下列
**5 条**（两侧段结构实测：9 行 / 7 bullets / 两侧 md5 前缀 `6ca7fbf2795228db`，byte-identical）。

⚠️ **v2 写「全部 5 条」是错的，实为 7 条**（L2.5 P0-5）。照 v2 执行会留下 2 条孤儿挂在
`## TAD v2.40.0 Highlights` 之下——**正是本契约自己定义的那个错误**。两条孤儿的处置（Alex 裁定）：
- 旧第 6 条 `Cost: ~35K tokens/cycle (v1.0 measured 23K)` → **删除**。该数字正是本次废除 SC2 的
  理由（基线 65% 为估算、被测对象是 823 字节玩具单），留着等于继续传播已知不可信的数；
  新第 5 条的 `62,220 chars` 取代它。
- 旧第 7 条 `Lite channel basics (safety stop / lifecycle)` → **并入新第 2 条**。
  该内容本次不但未废除，反而是 lite 唯一的停止机制。

新文本：
```
## TAD v2.40.0 Highlights
- **Lite is the default channel; full is reserved**: new work defaults to `/alex-lite` → `/blake-lite`. The three full skills are unchanged and fully usable — only the recommendation moved.
- **Escalation list replaced by a 3-item safety-stop list**: file count, protocol density and "touches a protocol contract" no longer force an upgrade — only irreversible operations, SAFETY surfaces and global registration surfaces stop for a human. 296 lines of three-tier routing machinery removed. Lifecycle stays location-based (`active/` → `archive/`).
- **Constraint pricing gate**: every new MUST/BLOCKING clause must first be priced in `.tad/evidence/audits/lite-constraint-ledger.md` — per-ticket cost, the failure mode it blocks (with a verbatim grep anchor), and a real incident carrier. Default action on review is deletion.
- **Lite gained five capabilities**: read tool-orchestration docs (≤2 files, must name paths), spawn subagents for non-implementation work, write `session-state.md`, and commit/push after explicit human authorization.
- **Measured, not assumed**: fixed read load per lite session is 62,220 chars (protocol layer 16,964 + knowledge layer 45,256); the full channel measures ≈221,281 — 3.56×.
```

---

## CHANGELOG 新增段

在 `## [Unreleased]` 之下插入（`## [Unreleased]` 保留在最上方）：
```
## [2.40.0] - 2026-08-06

### Breaking Changes

- **Lite is now the default channel; full is a reserved channel.** `CLAUDE.md` routing layer
  rewritten: new work defaults to `/alex-lite` → `/blake-lite`. The three full skills
  (`/alex`, `/blake`, `/gate`) are **unchanged and fully usable** — only the recommendation
  changed. Rollback for the routing layer is `git checkout CLAUDE.md`.
- **Lite escalation list replaced by a 3-item safety-stop list.** File count, protocol density
  and "touches a protocol contract" no longer force an upgrade to full. Only irreversible
  operations / SAFETY surfaces / global registration surfaces stop for human decision.
  Removed 296 lines of three-tier routing machinery.
- **Lite agents gained five capabilities**: read tool-orchestration docs (`.tad/guides/`,
  `release-runbook`, registries, ≤2 files, must name paths), spawn subagents for non-implementation
  work, write `session-state.md`, and commit/push after explicit human authorization.
  ⚠️ These are soft constraints, not mechanical gates — see `principles.md`
  §`Mechanical Enforcement Rejected on Single-User CLI` for the deployment-model rationale.

### New Features

- **Constraint pricing gate** (`.tad/evidence/audits/lite-constraint-ledger.md`): every new
  MUST/BLOCKING clause must first be priced — per-ticket cost, the failure mode it blocks
  (with a verbatim grep anchor), and a real incident carrier. Default action on review is deletion.
- **Alex-Lite write permissions**: ledger, `.tad/project-knowledge/`, `.tad/active/epics/`,
  `session-state.md` — fixing a long-standing self-contradiction where the protocol required
  writes that `Forbidden` prohibited.
- `.agents/` Codex mirror brought to parity with `.claude/` for both lite skills.

### Fixed

- **`tad.sh` upgrade freeze**: `TARGET_VERSION` was compared against the installed version
  *before* `derive_target_version()` runs, so a stale literal made the installer report
  "already installed" and exit 0 without upgrading. Same failure class as the v2.19.1 incident
  recorded in `principles.md`.
- Ledger overdue-scan silently missed malformed dates (regex now validates month/day ranges).
- `alex-lite` `Forbidden` contradicted its own 约束准入 and Knowledge Closeout sections.

### Measured

- Fixed read load per lite session: **62,220 chars** (protocol layer 16,964 + knowledge layer 45,256).
  Full channel measures **≈221,281 chars** — 3.56×.
- Two lite skills grew by only 22 lines net across the whole Epic (296 lines of routing machinery
  removed), i.e. the migration did not reproduce the bloat it set out to remove.

### Notes

- Epic `lite-as-tad-body`: 10 phases delivered, 3 voided, 2 moved out. SC2 (end-to-end token
  ceiling) was **retired as a broken criterion** — it conflated channel overhead with verification
  cost, two quantities that should move in opposite directions.
```

---

## AC（每条以 `- AC{n}:` 开头）

- AC1（**发布闸三门全过 —— 本单最强判据**）：以下三条**退出码均为 0**：
  ```bash
  bash .tad/hooks/lib/release-verify.sh version "$PWD" 2.40.0 2.39.0   # 零 STALE 残留
  bash .tad/hooks/lib/release-verify.sh version-sweep "$PWD" 2.40.0    # Layer 1 全 PASS
  bash .tad/hooks/lib/release-verify.sh parity "$PWD"                  # .claude ≡ .agents
  ```
  改前实测（L2.25 空跑）：第 1 条 **29 处 STALE**、第 2 条 **Layer 1 FAIL(12 stale)**、
  第 3 条 **PASS（byte-identical）**。
  ⚠️ **parity 改前已 PASS**，所以第 3 条的判别力是「**不许打破**」而非「修复」——
  `tad-help` / `alex` / `blake` 三个 SKILL.md 的版本串在 `.claude` 与 `.agents` 两侧
  **必须同步改**，只改一侧会把现有的 PASS 打成 FAIL。
  ⚠️ 这三条是 `release-runbook` step3b/step3c 明列的发布门。**它们 PASS 才叫"可发布"**，
  任何手工枚举都只是它们的近似。
  ⚠️ Layer 2 是 advisory（脚本自述 `Exit 0 = Layer 1 all PASS regardless of Layer 2 hits`），
  且已知含假阳性（`ai-podcast-production/SKILL.md:109` 的 `VoxCPM2 v2.0.3` 是**别的软件**的版本号）。
  **不得为消除 Layer 2 噪音而改动无关文件。**

- AC2（**`tad.sh` 成品 md5 —— 唯一危险文件**）：`md5 -q tad.sh` ==
  **`4c26e5ba08b7e8e9430aef0b015ad993`**，`wc -l < tad.sh` == **1855**。
  （改前 `2cab1d1926d79e736510fa69df8c3da6` / 1856。含 L22 的 `TARGET_VERSION="2.40.0"`
  与两处路由提示；Alex 已在内存中精确重放算得，并在同一字节序列上跑通 `bash -n`。）

- AC3（**`tad.sh` 未被改坏 —— md5 证「一致」，本条证「能跑」且「没碰逻辑」**）：
  ```bash
  bash -n tad.sh                                        # 退出码 0
  grep -Fxc 'TARGET_VERSION="2.40.0"' tad.sh            # == 1（P0-1 的修复）
  grep -Fc '[ -d ".claude/skills/alex" ]' tad.sh        # == 1（平台检测存活）
  grep -Fc '[ -d ".agents/skills/alex" ]' tad.sh        # == 1（同上）
  git diff HEAD --numstat -- tad.sh                     # 逐字 == "4	5	tad.sh"
  ```

- AC4（路由新串各 `grep -Fxc` == 1）：
  ```bash
  grep -Fxc '### 2. Pick a Channel' README.md
  grep -Fxc '| `/alex-lite` | Design & Planning |' README.md
  grep -Fxc '| `/alex-lite` | - | **Default channel** — Alex Lite (design) |' README.md
  grep -Fxc '| `/gate N` | Both | Reserved channel — Execute quality gate N |' README.md
  grep -Fxc '/alex-lite      # 设计与规划' INSTALLATION_GUIDE.md
  grep -Fc  'Use `$alex-lite` / `$blake-lite` (Lite — **the default channel**)' AGENTS.md
  ```

- AC5（路由旧串消失，`grep -Fxc` == 0）：
  ```bash
  grep -Fxc '### 2. Open Two Terminals' README.md
  grep -Fxc '| `/alex` | - | Activate Alex (Solution Lead) |' README.md
  grep -Fxc '| `/blake` | - | Activate Blake (Execution Master) |' README.md
  grep -Fxc '| `/gate N` | Both | Execute quality gate N |' README.md
  grep -Fxc '/alex' INSTALLATION_GUIDE.md
  ```
  ⚠️ **必须 `-x`**：`/alex` 是 `/alex-lite` 的前缀，`-F` 子串匹配下改后仍命中。
  ⚠️ v1 漏守了 `/blake` 与 `/gate N` 两行（L2.5 P1-3），Blake 可追加新表却保留旧行而全绿。改前各为 1。

  ⚠️ **`| \`/alex\` | \`/blake\` |` 这一行不在上表**——v2 曾要求它 == 0，但 §路由改动 的
  「Pick a Channel」新块**保留了它**（在 Reserved — full TAD 表内，内容上正确），
  两者直接矛盾、按契约执行必然 FAIL（L2.5 P0-3）。改为**正向锁它的位置**：
  ```bash
  grep -Fxc '| `/alex` | `/blake` |' README.md                                             # == 1
  grep -Fxc '**Reserved — full TAD** (two terminals, human is the only bridge)' README.md  # == 1
  ```
  旧标题 `### 2. Open Two Terminals` == 0 已足以证明区块被替换，无需再靠该行的消失。

- AC6（CHANGELOG 有内容，不只是骨架）：
  ```bash
  grep -Fxc '## [2.40.0] - 2026-08-06' CHANGELOG.md            # == 1
  grep -Fxc '## [Unreleased]' CHANGELOG.md                     # == 1（保留在最上方）
  grep -Fc  '62,220 chars' CHANGELOG.md                        # == 1（钉死的测量真值）
  grep -Fc  'retired as a broken criterion' CHANGELOG.md       # == 1
  grep -Fc  'tad.sh` upgrade freeze' CHANGELOG.md              # == 1（P0-1 必须记进变更说明）
  awk '/^## \[2.40.0\] - 2026-08-06$/{f=1;next} /^## \[/{f=0} f' CHANGELOG.md | wc -l   # >= 45
  ```
  ⚠️ 前两条必须 `-Fx`：L1185 有历史遗留的 `## [Unreleased] - 2026-02-01`，`-F` 会命中其前缀
  （改前 `-F` 得 2 / `-Fx` 得 1）。📌 那行历史错误**本单不修**，记入 follow-up。
  ⚠️ 末条行数下限是抗骨架断言（L2.5 P1-4：v1 只锁 4 个串，写个标题就能全绿）。

- AC8（**逐文件改动形状 —— 补三门对内容零约束之不足**）：
  ```bash
  git diff HEAD --numstat -- .tad/version.txt                          # "1	1"
  git diff HEAD --numstat -- .tad/config.yaml                          # "2	2"
  git diff HEAD --numstat -- package.json                              # "1	1"
  git diff HEAD --numstat -- PROJECT_CONTEXT.md                        # "1	1"
  git diff HEAD --numstat -- docs/MULTI-PLATFORM.md                    # "1	1"
  git diff HEAD --numstat -- .tad/codex/README.md                      # "1	1"
  git diff HEAD --numstat -- .tad/capability-packs/pack-registry.yaml  # "1	1"
  git diff HEAD --numstat -- .tad/templates/pack-meta-template.yaml    # "1	1"
  git diff HEAD --numstat -- .claude/skills/alex/SKILL.md              # "2	2"
  git diff HEAD --numstat -- .agents/skills/alex/SKILL.md              # "2	2"
  git diff HEAD --numstat -- .claude/skills/blake/SKILL.md             # "3	3"
  git diff HEAD --numstat -- .agents/skills/blake/SKILL.md             # "3	3"
  git diff HEAD --numstat -- .claude/skills/tad-help/SKILL.md          # "7	9"
  git diff HEAD --numstat -- .agents/skills/tad-help/SKILL.md          # "7	9"
  git diff HEAD --numstat -- README.md                                 # "18	7"
  git diff HEAD --numstat -- INSTALLATION_GUIDE.md                     # "8	6"
  git diff HEAD --numstat -- AGENTS.md                                 # "1	1"
  # 算法无关的交叉校验（numstat 依赖差分实现，wc -l 不依赖）：
  wc -l < README.md                                                    # == 475（改前 464，净 +11）
  wc -l < INSTALLATION_GUIDE.md                                        # == 141（改前 139，净 +2）
  # 集合闭合：改动文件恰好 19 个（AC8 的 17 + tad.sh + CHANGELOG.md）
  git diff HEAD --name-only | LC_ALL=C sort
  ```
  ⚠️ **判据优先级**：`wc -l` 是**主判据**（算法无关）；numstat 差 ±1–2 行而 `wc -l` 正确时，
  按差分实现差异处理、判 PASS，不要为凑数往文件里塞行
  （`ac-verification.md` §`A Positive Existence Anchor…` 记录过「掏空后补 180 行注释凑进区间」的攻击——
  **一个算错的钉死值会主动招来伪造**）。
  ⚠️ **`18	7` / `8	6` 是 L2.5 实算，v3 初版写的 `23	12` / `9	7` 是错的**：那按「整块删除+整块新增」算，
  但**新块特意保留了旧块的公共行**——README 新块末 4 行（`| Terminal 1 | Terminal 2 |` 等）与旧块逐字相同
  （**那正是 P0-3 修复的直接后果**），IG 新旧块共享中间空行。差分会把它们匹配成 context。
  ⚠️ **集合闭合**：`git diff HEAD --name-only` 相对**执行前基线**（Blake 动手前实跑记录，勿照抄）
  的新增部分必须**恰好是这 19 个路径**，多一个即 FAIL。这堵住「改了清单外文件」——
  AC8 是逐文件断言，对未列入者零约束；`parity` 是对称式，两侧同样改坏也 PASS。
  加三条**肯定锚**，守住 `version` 模式「删掉即通过」的三行协议正文：
  ```bash
  grep -Fxc '## 🔄 Ralph Loop (TAD v2.40.0)' .claude/skills/blake/SKILL.md          # == 1
  grep -Fc 'GLOBAL SKILL EXCLUSION (TAD v2.40.0' .claude/skills/alex/SKILL.md       # == 1
  grep -Fc 'GLOBAL SKILL EXCLUSION (TAD v2.40.0)' .claude/skills/blake/SKILL.md     # == 1
  ```
  加四条 **Highlights 锚**（本单唯一的内容工作，v2 完全无锚 —— L2.5 P0-5）：
  ```bash
  H=.claude/skills/tad-help/SKILL.md
  grep -Fxc '## TAD v2.40.0 Highlights' "$H"                                        # == 1
  grep -Fxc '## TAD v2.39.0 Highlights' "$H"                                        # == 0
  awk '/^## TAD v2\.40\.0 Highlights$/{f=1;next} /^## /{f=0} f' "$H" | grep -c '^- \*\*'  # == 5（防孤儿）
  grep -Fc '~35K tokens/cycle' "$H"                                                 # == 0（旧成本数字必须消失）
  ```
  ⚠️ **为什么必须有 AC8**：AC1 三门的谓词类型合起来**对正文内容零约束**——
  `version` 是**否定式**（`2.39.0` 消失即可，**删掉整节也满足**）、`version-sweep` L1 只覆盖
  12 条且 `.agents/` 一条没有、`parity` 是**对称式**（两侧同样改坏 → PASS）。
  L2.5 实证的伪造路径：把 `blake/SKILL.md` 的整个 Ralph Loop 小节连标题删除、`.agents/` 同样删
  → **三门全绿**，而 v2 的 7 条 AC 无一约束这 6 个 SKILL.md 的正文。
  同源知识：`principles.md` §`A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover
  SAFETY Loss When Legit Stripping Also Lowers the Count`（同一次改动既合法移除计数、
  又可能非法移除内容，门按构造分不出两者）。

- AC7（零越权 + **未执行 release 动作**）：
  ```bash
  git rev-parse --short HEAD              # 须仍为 21816d6
  git tag --sort=-v:refname | head -1     # 须仍为 v2.39.0（未打新 tag）
  git tag | wc -l                         # == 62（起草时实测，防非 semver 名的 tag 绕过上一条）
  ```
  `git status --short` 相对起草时基线（**23 行**，Blake 执行前先实跑记录）的新增部分，
  只允许落在：**发布闸三门要求改的文件**（由 AC1 的工具输出定义）、`CLAUDE.md` 除外、
  `.tad/active/handoffs/`、`.tad/archive/handoffs/`、
  `.tad/evidence/{reviews,journal,ralph-loops,acceptance-tests,traces,decisions}/`、
  `.tad/memory/`、`.tad/active/precompact/`。
  **黑名单（出现即 FAIL）**：`CLAUDE.md`、`.claude/skills/{alex-lite,blake-lite}/`、
  `.agents/skills/{alex-lite,blake-lite}/`、`.tad/hooks/`、`.claude/settings.json`、
  `.claude/agents/`、`.gitignore`、`.tad/sync-registry.yaml`、`.tad/logs/`、`ROADMAP.md`。
  ⚠️ `.claude/settings.local.json.bak-20260806-082549` 起草时已存在，不构成命中。
  **本单禁止** `git add` / `commit` / `push` / `tag` / `checkout --` / `stash`。

## 知识引用

- `principles.md` §`Deny-List Beats Allow-List for Sync Sets; Version Grep Must Scope to
  git-ls-files` — ⚠️ **v1 漏引了这条，而它逐字记着「tad.sh 卡在 2.19.1（不在 18 项
  version-string 清单里）」——正是 P0-1 的同类事故。** 该条的 Action「版本检查须 scope 到
  `git ls-files`、宁可假阳性不可假阴性」也正是 `release-verify version` 模式的设计依据，
  故 v2 把它提升为 AC1 的主判据而非手工枚举。
- `ac-verification.md` §`Verification Strength Is Bounded by the Deliverable's Determinacy`
  （含 2026-08-06 AMENDED）— `tad.sh` 是确定文本 → AC2 写死 md5（答案 cheap to recompute，
  符合 AMENDED 的公布边界）；但 md5 只证「一致」不证「能跑」，故 AC3 补 `bash -n`。
- `ac-verification.md` §`An Aggregate-Only Check Locks the Exit, Not the Entrance` —
  AC6 的行数下限即依此条（v1 只锁 4 个串，骨架可全绿）。
- `handoff-design.md` §`A Change That Makes a Dormant Defect Reachable Owns That Defect` —
  本单在偿还 P6 记下的账（P6 造成发布物与 `CLAUDE.md` 不一致，指定「下次 publish 同步」）。

## Contract Review (2026-08-06)

Reviewer: code-reviewer subagent (fresh context) | model=claude-opus-5[1m] | route=unknown
首轮 verdict: **FAIL**（v1：P0=2, P1=4, P2=5）
第二轮 verdict: **FAIL**（v2：P0=3, P1=2, P2=4）
第三轮 verdict: **CONDITIONAL**（v3：P0=2, P1=2, P2=4）→ reviewer 明示
「改完这 5 处即可执行，**不需要第四轮契约审查**——都是把已核实的实测值填进去，没有新设计」
最终 verdict: **PASS**（5 处全部填入并实测验证）
P0=7(fixed), P1=8(fixed), P2=9(8 adopted, 1 → follow-up); 已审 AC 条数: **8**

**三轮审查的关键发现（按严重度）**：

- **v1 P0-1｜AC 焊死了一个会让 14 个下游静默冻结的 bug**：`tad.sh:22` 的 `TARGET_VERSION`
  在 `derive_target_version()`（唯一调用点 L1550，**下载之后**）之前就被 `detect_state()` L1352 使用
  → `ACTION="none"` → L1484 `exit 0`。v2.40.0 发布后，停在 2.39.0 的下游跑安装命令会打印
  「✅ Nothing to do」并成功退出。而 v1 用 `tad.sh` **全文 md5** 当最强判据——Blake 修 L22 就会 FAIL。
  ⚠️ `principles.md` §`Deny-List Beats Allow-List for Sync Sets` 逐字记着同类事故
  「tad.sh 卡在 2.19.1」，**v1 引了三条知识唯独漏了它**。

- **v2 P0-4｜转向时拆了围栏没补新锁**：v2 把「手工枚举」换成「发布闸驱动」（方向正确），
  但为让版本串可改，把 AC 黑名单从 `.claude/skills/` 收窄到 `{alex-lite,blake-lite}`，
  **4 个 2000 行协议文件全部解锁**。而三门的谓词类型合起来对正文零约束：
  `version` 否定式（删整节也满足）、`version-sweep` 只覆盖 12 条且 `.agents/` 一条没有、
  `parity` 对称式（两侧同样改坏 → PASS）。reviewer 实证：删掉 blake 的整个 Ralph Loop 小节
  → 三门全绿。→ v3 新增 AC8（逐文件 numstat + 肯定锚 + 集合闭合）。

- **v3 P0-6/P0-7｜两个 P0 同一成因**：都是「**先写正确的新文本、再回头算判据**」时算错的，
  都错在**没考虑新旧文本的公共部分**——README 的 `23	12` 按整块替换算，
  而新块特意保留了旧块末 4 行（**那正是 P0-3 修复的直接后果**）；横幅锚的 `== 0` 按全文件清零算，
  而契约自己指定 L88 历史标题必须保留。**修复动作本身在文件里留下了旧内容，判据却按"全改"算。**

- **范围估计四次全错**：12 → 22 → 24 → 实跑 **29**。第四次错发生在 v2 已宣布「不再手工枚举」之后
  ——**这是该转向最强的论据**。

**v1 的两个 P0 见上方「v1 为何 FAIL」。四个 P1 处置**：
- P1-1 README 4-a 会把 lite 塞进「Open Two Terminals」表 → v2 整块替换为「Pick a Channel」。
- P1-2 IG L51 `# 应显示 2.39.0` 未同步 → v2 纳入。
- P1-3 AC5 漏守 `/blake` `/gate N` 旧行 → v2 补两条 `-Fxc == 0`。
- P1-4 AC6 可只写骨架 → v2 补测量真值锚 + 段长下限 ≥45 行。
**五个 P2 均已采纳**：U+00B7 已标注（AC2 上方）、tad.sh 引用实为 7 处（v2 不再枚举，
改由工具驱动）、README 故障排查段与 v2.35.0 历史段已列入「不做什么」、tag 计数已加。

## 风险与注意

- 🔴 **`tad.sh` 是 14 个下游的安装入口**。本单改 3 处（L22 版本 + 2 处提示），
  平台检测逻辑（L792/794）禁改且由 AC3 机械守护。**回滚 = `git checkout tad.sh`**。

- 🔴 **P0-1 的修复必须进 CHANGELOG**（AC6 已锁）——下游需要知道「为什么之前升级没反应」。

- **本单不发布**。tag / push 归单 B，命中安全停清单第 1 条。AC7 的 tag 断言是机械兜底。

- **`{.claude,.agents}/skills/tad-help/` 的 Highlights 段是本单唯一的内容工作**，
  其余均为机械替换。两侧须 byte-identical（`parity` 门会验）。

- **caller/consumer**：`tad.sh` 被 `npx github:Sheldon-92/TAD` 与 `curl | bash` 执行；
  `version.txt` / `config.yaml` 被 `release-verify` 与多个 hook 读取；
  三个 full SKILL.md 被 skill 加载器读取（**本单只改其版本注释行，不动协议内容**）。
  ✅ **已核实（v2 曾误标为「未验证」—— L2.5 P1-6 指出那是把已知问题降格成待查）**：
  `.tad/capability-packs/pack-registry.yaml:8` 的 `synced_from_version` **自带注释**
  `# reserved for cross-version compatibility checks (Phase 2 consumer TBD)` ——
  **即无现役消费方**；`pack-meta-template.yaml:4` 的 `installed_version` 是**模板占位符**，
  只影响未来生成的 pack meta。故 bump 二者**无行为影响**。
  Blake 仍跑一次 `bash .tad/hooks/lib/pack-registry-driftcheck.sh` 作为 advisory 存证写进 Completion。
  ⚠️ **不得追改已生成的 `.tad/capability-packs/*/meta.yaml`**（25 个已装 pack）——
  那才是真事故；已列入「不做什么」。

- **自指**：本单改 `AGENTS.md`（Codex 路由入口）与三个 full SKILL.md 的版本注释，
  均在**下一个 session** 才生效。执行期间若压缩，不得重跑 `/blake-lite` → 停下报人。

---

## Lite Progress

- Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/release-doc-sync/ac-results.md | Next Action=实现 19 文件改动
- L0 准入：LITE-*.md 白名单命中；L0.5 机械检查全过（最终 verdict PASS / P0=7(fixed) / 已审 AC 条数 8==机械计数 8）；**安全停清单裁定**：本单为 release 文档准备面（第 1 条 release·publish·sync 的字面相邻面）→ 人已明确指示（用户消息「Blake 要做的…不 tag、不 push」+ 契约 v3 三轮审查）+ 契约三重声明（§不做什么「不执行 git tag/push/任何 release 动作」+「本单不发布，tag/push 归单 B」+ AC7 tag 断言机械兜底）→ 逐字记录放行；全部改动 git-tracked 可回滚
- L0.75：基线预检全绿（HEAD=21816d6、status 23 行、tag v2.39.0/62、tad.sh md5 2cab1d19/1856、README 464、IG 139）；AC1 三门改前实测（29 STALE / 12 BLOCKING / parity PASS）——与契约记载完全一致
- Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/release-doc-sync/ac-results.md | Next Action=AC 自验
- 实现：25 处批量替换（python3 断言唯一）+ 8 处复杂块（tad.sh×2/README×2/IG/AGENTS/Highlights×2/CHANGELOG）；19 文件
- Phase=ac | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/release-doc-sync/ac-results.md | Next Action=L3 独立审查
- 结果：AC1 三门全过（repair round 1：补 tad-help L17 版本行后 version 0 STALE）；AC2 md5 4c26e5ba 精确命中；AC3 bash -n/锚/numstat 4→5 全过；AC4/AC5 全过；AC6 段长 50；AC8 主判据 wc -l 475/141 全对、numstat 15/17 命中 + tad-help 差 1 插（根因=L17 修复，按判据优先级判 PASS 如实记录）、集合闭合 19；AC7 HEAD/tag 未动/黑名单 0；横幅补锚 7 条全过；driftcheck advisory 存证（11 skill-only 既有状态）
- Phase=review | repair_round=1/3 | same_error_count=1/2 | verdict=RUNNING | Evidence=.tad/evidence/reviews/blake/release-doc-sync/code-reviewer.md | Next Action=L3.5 Technical Gate → L4 Completion
- L3 reviewer: PASS | model=deepseek-v4-flash | P0=0 P1=0 P2=3（三门独立重跑全绿；tad.sh 三处逐字核验含 U+00B7 字节实证；Highlights 两侧 byte-identical；CHANGELOG 剥离空行后 diff 空）；P2-2 采纳修复（双空行→单，AC6 复验 49 行），P2-1 保留（与契约逐字一致）、P2-3 记录

---

## Completion (2026-08-06)

**Commit**: uncommitted（本单零 git 写操作含零 tag；commit/tag 归单 B 与人）
**Model**: harness=claude-code | model=deepseek-v4-flash | route=api.deepseek.com (alias-mapped)

- 上下文刷新：已读契约全文（v3 三轮审查 + 8 条 AC + §路由改动/横幅/Highlights/CHANGELOG 逐字文本）、知识引用四条目（含 Deny-List Beats Allow-List 的 tad.sh 2.19.1 同类事故）；基线预检全绿（HEAD=21816d6、status 23 行、tag v2.39.0/62、tad.sh md5 2cab1d19/1856、README 464、IG 139）+ AC1 三门改前实测（29 STALE/12 BLOCKING/parity PASS）；关键约束：不 tag 不 push 不发布、tad.sh 平台检测禁改、历史记录不追溯、Highlights 两侧 byte-identical、禁 git 写操作；成功条件：AC1-AC8 全绿 + reviewer PASS + Technical Gate PASS
- 改动文件（19 个，集合闭合验证恰 19）：
  - tad.sh（L22 TARGET_VERSION + 2 处路由提示；md5 4c26e5ba…/1855 行）
  - .claude/.agents/skills/{alex,blake,tad-help}/SKILL.md ×6（版本注释串 + Highlights 重写）
  - .tad/{version.txt,config.yaml,codex/README.md,capability-packs/pack-registry.yaml,templates/pack-meta-template.yaml}
  - README.md、INSTALLATION_GUIDE.md、AGENTS.md、CHANGELOG.md、package.json、PROJECT_CONTEXT.md、docs/MULTI-PLATFORM.md
  - [清单外：白名单证据载体] ac-results.md、code-reviewer.md、本契约自身
- AC 结果：AC1-AC8 全部 ✅（repair round 1 后），原始输出 → .tad/evidence/acceptance-tests/release-doc-sync/ac-results.md（reviewer 独立重跑逐字一致）
  - AC1 ✅ 三门全过（version 0 STALE / sweep 12 verified / parity byte-identical）——最强判据
  - AC2 ✅ md5=4c26e5ba08b7e8e9430aef0b015ad993 / 1855 行 | AC3 ✅ bash -n 0 / 锚 1,1,1 / numstat 4→5
  - AC4 ✅ 新串 6/6 | AC5 ✅ 旧串 5/5=0 + 正向锁 2 | AC6 ✅ 5 锚 + 段长 50（P2-2 修复后 49）
  - AC8 ✅ wc -l 475/141 主判据 + numstat 15/17 + tad-help 差 1 插（根因 L17 修复，判据优先级处理）+ 集合闭合 19 + 肯定锚 3 + Highlights 锚 4
  - AC7 ✅ HEAD=21816d6 / tag v2.39.0 / 62 / 黑名单 0 / 零 git 写操作
  - 横幅补锚 7 条全过（L88/PC L21 历史存活）；driftcheck advisory 存证（11 skill-only 既有）
- Reviewer: PASS | model=deepseek-v4-flash, P0=0, P1=0, P2=3 | 摘录：三门独立重跑全绿（sweep 12/12 verified 0 warnings）；tad.sh 三处逐字核验（U+00B7 字节实证 \xc2\xb7=1、bullet=0，平台检测未触碰）；路由 4 文件逐字（含 Reserved 表 4 公共行=P0-3 修复预期后果）；Highlights 两侧段 md5 df382b3c 相同且与契约 byte-identical；CHANGELOG 剥离空行后 diff 空；repair_round 叙事一致（L17 遗漏→AC1 门抓出→归零，「发布闸当判据」正面实证）（执行实证）
- Technical Gate: **GATE PASS**
  1. AC/evidence：8 条 AC 全部有原始输出与证据路径（自验 + reviewer 双份）✅
  2. reviewer verdict：PASS，P0=0 P1=0 ✅
  3. friction：无 BLOCKED（release-verify 脚本、bash、grep 全可用）✅
  4. scope/risk：改动限于 19 个路径（集合闭合实证）；caller/consumer 已检查（tad.sh=14 下游安装入口，平台检测 AC3 机械守护；pack-registry/template 无现役消费方）✅
  5. Knowledge Assessment：journal captured → .tad/evidence/journal/lite-discoveries.md 追加 1 行 ✅
- Knowledge Assessment: journal captured（.tad/evidence/journal/lite-discoveries.md 2026-08-06 行：发布闸当判据 + 判据优先级容纳工具强制要求差异）
- 意外发现：repair round 1 本身即「发布闸当判据」设计的正面实证——L17 版本行（29 处 STALE 之一）被 AC1 version 门机械抓出，修复后归零；契约 numstat 期望值按未含 L17 计算，判据优先级规则容纳该差异
- follow-up：
  - ⏳ **单 B = `git tag` + `push`**（命中安全停清单第 1 条，需人授权）——本单不执行 | owner=人
  - CHANGELOG L1236 历史遗留 `## [Unreleased] - 2026-02-01`（-F 前缀命中源，-Fx 已避开）——历史错误本单不修 | owner=Alex-Lite
  - release-verify Layer 2 advisory 假阳性（`VoxCPM2 v2.0.3` 等）已知，未触发无关改动 | owner=Alex-Lite
  - P2-3：traces/2026-08-06.jsonl 为 hook 自动 trace 发射（允许路径），归档时证据时间戳口径 | owner=Blake-Lite
  - 本单 + 前几单工作区改动均未 commit（发布归人）
- 显式声明（AC7 结构性盲区）：本单**未触碰** `.claude/settings.local.json` 与 `.tad/logs/violations.log`；未执行任何 release 动作（无 tag/push/publish 命令）

## Reflexion

- 失败：tad-help L17 版本行漏改（29 处 STALE 批量脚本遗漏）/ 假设：批量脚本覆盖了全部 STALE 清单 / 动作：AC1 version 门抓出 2 处 STALE，python 修复两侧 / 结果：version 归零、三门全过——工具驱动判据在 repair 中起正向作用
- Phase=technical-gate | repair_round=1/3 | same_error_count=1/2 | verdict=GATE PASS | Evidence=.tad/evidence/acceptance-tests/release-doc-sync/ac-results.md + .tad/evidence/reviews/blake/release-doc-sync/code-reviewer.md | Next Action=人验收（L5）→ 归档
- Phase=human-gate | repair_round=1/3 | same_error_count=1/2 | verdict=GATE PASS | Evidence=同上 | Next Action=人验收 → 归档；单 B（tag+push）归人授权
