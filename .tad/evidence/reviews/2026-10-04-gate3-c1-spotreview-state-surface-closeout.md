# Gate 3 定点复核 — 条件 C1 返工（TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT）

- 复核人：Blake（Execution Master），Gate 3 独立定点复核会话（未参与本链设计与实施）
- 日期：2026-10-04
- 被审对象：返工提交 `6d65bd3ef9b41ab8ae4ec9fc8d90ca4b52734809`（父 `165b2a39`，未 push，ahead 5）
- 依据：增量设计 `.tad/evidence/designs/2026-10-04-state-surface-check-pattern-delta.md`（下称「增量」）；Gate 3 合并裁定 `.tad/evidence/reviews/2026-10-04-gate3-merge-verdict-state-surface-closeout.md`；原 CODE 评审件 `.tad/evidence/reviews/2026-10-04-gate3-code-review-state-surface-closeout.md` §6/§8
- 方法：全部结论由本席在盘上亲跑命令得出，不采信实施回执。被审文件零改动。

## 1. 实现对增量（脚本 diff ↔ 增量 §1/§6）

证据：`git show 6d65bd3e -- .tad/hooks/lib/state-surface-check.sh`（脚本 diff 恰 2 个 hunk：头部注释 + 常量/P1/P2 追加；其余各查与 exit 语义无 hunk 触及）。

- 常量四行与增量 §1.2 **逐字一致**：`PAREN_VER_PAT='\(Version:? ?v?[0-9]+\.[0-9]+(\.[0-9]+)?\)'`、`PAREN_TOKEN_PAT='\(v?[0-9]+\.[0-9]+(\.[0-9]+)?\)'`、`PAREN_KEYWORD='Runtime status'`、`PAREN_HEAD_LINES=15`，置于 `OLD_PAT` 之后（§6.1a ✓）。
- `DECL_PAT` / `OLD_PAT` 在 diff 中为未改上下文行，**逐字未动**（§6.1d ✓）。
- P1 遍（§1.3）：对 `DECL_FILES` 每文件 `grep -oE "$PAREN_VER_PAT"` 全文件提取，逐 token 以 `grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1` 取值、经 `norm()` 与 SSOT 比较；FAIL 文案 `parenthesized version declaration '<token>' != version.txt <SSOT>`，token 逐字入文案（§1.4 ✓）。
- P2 遍（§1.3/§2）：`grep -nE "$PAREN_TOKEN_PAT"` 逐行取行号与行文；锚定为单标志 `anchored`（行号 ≤15 置 1，行文含 `Runtime status` 置 1），双锚同中只处理一次 → **同行不因双锚双报** ✓；锚外行直接跳过；逐 token 提取比较，FAIL 文案同 P1。
- P1/P2 与 DECL 分支共用 `c3_bad` 与同一条 check3 PASS 行，查号总数保持 5（§1.1 ✓）。
- 头部注释第 3 项已改述为双家族表述并注明 `(design delta 2026-10-04, Gate 3 C1)`（§6.1c ✓）。
- detect-only 保持：新增代码只有 grep 提取与比较，无任何写文件操作；未引入 `grep -P`（shell-portability 纪律 ✓）。

## 2. 探针全套亲跑（增量 §4，自仓根执行）

| 探针 | 期望 | 本席实跑 | 判定 |
|---|---|---|---|
| Probe-0 真树 | exit 0，check1–5 全 PASS | exit=0，五 PASS 行齐全，`state-surface: PASS` | ✅ |
| Probe-1 fixture | exit 1；四归因齐备；check2/4/5 PASS | exit=1；归因循环对 `(v9.9)` / `Version**: 9.9` / `(Version 9.7)` / `(v8.8)` 四 token **零 MISSING**；check2/4/5 PASS；两正控（README `(v3.0.0)`、PROJECT_CONTEXT `**Version**: 3.0.0`）无 FAIL 行 | ✅ |
| Probe-2 仅修粗体行 | 仍 exit 1 且 FAIL check3 含 `(v9.9)` 计数 ≥1 | exit=1，计数 = **1** | ✅（C1 核心判据；原 CODE 评审 §6 正是在此探针上实证 vacuous，现已反转） |
| Probe-3 四植入全修 | check3 PASS，唯一 FAIL 为 check1 | check3 PASS 行出现；唯一 FAIL = check1；exit=1 | ✅ |
| Probe-4 续修 NEXT | exit 0 | exit=0，全 PASS | ✅ |

附带复现增量基线 B1：真树无锚括号 token 恰 2 命中（`AGENTS.md:9` `(v3.0.0)` 身份行；`README.md:284` `(v2.0)` 历史标题）——后者在 Probe-0 中未被报（三锚皆不中），锚定按设计工作。
附带核验：`bash .tad/hooks/lib/release-verify.sh state-surface` exit=0（增量 §5「转调不受影响」属实）。

## 3. 改动面核查

证据：`git show --name-only 6d65bd3e`、`git log -- <path>`、`git status --porcelain`。

- 提交恰 **6 文件**：check 脚本、fixture 四件（FIXTURE.md / INSTALLATION_GUIDE.md / README.md / docs/MULTI-PLATFORM.md）、HANDOFF，与派发口径一致。
- fixture 三处植入与增量 §3.2 **逐字一致**（MULTI-PLATFORM:3 `(Version 9.7)`、INSTALLATION_GUIDE:3 `(v8.8)`、README:3 正控 `(v3.0.0)`）；FIXTURE.md 已按 §3.3 改述为逐植入清单（分支 + 期望 + 两正控），运行说明保留。
- **fixture AGENTS.md 未改**：不在本提交文件集内；其最后触碰提交为 `165b2a39`（实施步），本提交零触及（§6 第 6 项 ✓——`(v9.9)` 靠脚本分支落地自动转真负控，Probe-2 已证）。
- 设计原件指针行已按 §6 第 7 项**逐字落盘**：`.tad/evidence/designs/2026-10-04-tad-state-surface-closeout-design.md:100`，位于机制 2 段末、紧接 `**机制 3` 标题（:102）之前（机械比对 `ptr in orig == True`；该文件未入 git，查盘为准）。
- 工作树对本提交 6 文件干净（porcelain 空）；提交未 push（`origin/main...HEAD` = 0/5）。

## 4. 回填保真（HANDOFF §9.1）

证据：本席以脚本对 `6d65bd3e^` 与 `6d65bd3e` 两版 HANDOFF 的 §9.1 全 14 行逐格机械比对，并与 §2 亲跑输出对照。

- 判据/类型/方法格：**14 行全部与父版逐字一致**，无一格被动。
- Expected 格：仅第 8 行（AC8）变更，且新文本与增量 §5 替换文本**逐字节相等**（机械比对 `== True`）——即 PM 已路由的扩充文本，无第二处 Expected 变更。
- 实跑格：本提交填入第 3–14 行（第 1–2 行在父版已填）。说明在案：§9.1 全量回填自实施步起即在工作树待落，本提交一并带入；其中 C1 相关为 AC7/AC8 两行。AC7 实跑格述「exit 0，check1–check5 全 PASS」与本席 Probe-0 一致；AC8 实跑格述「exit 1、四归因齐备、Probe-2 计数 = 1、Probe-3 唯一 FAIL 为 check1、Probe-4 exit 0」与本席 §2 亲跑逐项一致。
- HANDOFF 中 §9.1 表外全部行与父版一致（机械比对 `== True`）。
- 方法注记（防误读）：首轮逐格比对曾对第 11 行报伪阳性——其实跑格内含字面 `|`（`grep -c '^|'`）致朴素切分错位；改以实跑格起始标记切分后，第 11 行判据+方法+Expected 前缀 406 字符与父版逐字一致，确认仅实跑格被填。

## 5. 报明裁定：`(Version 9.7)` 双报一行

现象（本席 Probe-1 账目）：FAIL 行共 6 = check1 ×1 + check3 ×5。check3 五行为四植入的归因行之外，多一行 `docs/MULTI-PLATFORM.md: version declaration 'Version 9.7'`——DECL 分支以子串 `Version 9.7` 命中 `(Version 9.7)` 植入，与 P1 分支对同一植入各报一行。

**裁定：可接受的真阳性双报，不须返工消除。** 理由：

1. **非误报**：该行指向的文件确实含一个错误版本声明，值 9.7 ≠ SSOT 3.0.0，文件名与值均属实。两正控在 Probe-1 中保持静默，真树 Probe-0 exit 0——没有任何正确内容被报。
2. **消除它须违反已批增量**：双报源自既有 `DECL_PAT` 的子串匹配，而增量 §1.2/§6.1d 明定 `DECL_PAT` 逐字不动；为去重而改 DECL 语义属增量外扩围，且会动 Gate 2 已批的模式家族基线。
3. **§3.3 归因集合不受影响**：四植入归因 token 在 Probe-1 归因循环中全齐（零 MISSING）；§3.3 的「check3 ×4 归因」按归因计，本席账目为 5 行 / 4 归因，归因集与设计恰合。FIXTURE.md 改述文本按植入与分支立条，未承诺 FAIL 行数恰为 4。
4. **不构成持续假红**：Probe-3 实证——植入修为 `(Version 3.0.0)` 后该行与 P1 行同时消失、check3 全 PASS。双报只附着于真错误值，随错而生、随修而灭。

## 6. C1 关闭裁定与总判定

合并裁定为 C1 设定的关闭路径（Alex 增量 → Blake 返工 → PM 探针 → 新 CODE 复核）已走完本席一环：增量落地与设计逐字相符，五探针亲跑全达期望，改动面恰为派发口径，回填保真，唯一报明裁定为可接受真阳性。

- **条件 C1：关闭（CLOSED）**。原 CODE 评审 §8 的限定表述（「仅覆盖 Version 声明形态 + 3.1 字面值」）自此解除——check3 现覆盖 DECL 形态 + 括号形态（P1 自锚 / P2 行锚），真树正控与 fixture 负控双向实证在盘。
- **本定点复核总判定：PASS**。可进 Gate 4。

证据指针汇总：提交 `6d65bd3e`（`git show` 全 diff）；脚本 `.tad/hooks/lib/state-surface-check.sh`（7,916 B，HEAD 版）；探针命令与期望见增量 §4，实跑输出见本件 §2；设计指针行在设计原件 :100；§9.1 逐格比对方法见本件 §4。

纪律确认：本席未改任何被审文件，未代填 COMPLETION 的 `gate3_verdict`，未 push。本件为本会话唯一写入。
