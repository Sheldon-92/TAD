# HANDOFF: Codex 接线止血（hooks schema + 镜像 reference 路径 + 台账重验）(v2)

**Date**: 2026-08-03 | **From**: Alex | **To**: Blake（full 通道）
**Type**: express（≤1 天，但含协议契约面 → 专家审查见文末 Audit Trail：R1 双专家 FAIL+CONDITIONAL，5 P0 + 11 P1/P2 已处置）
**Series**: codex-universalization step 1/3（step 2 = 知识入口单；step 3 = 词汇通用化单）

## 1. 目标（为什么现在做）

2026-08-03 全库耦合扫描确认三处**现在就坏着**的 Codex 侧失效，且随 `tad.sh` 向下游扩散：
1. `.codex/hooks.json` 使用 0.137 时代 schema，被 codex ≥0.145 拒绝解析（用户 2026-07-30 冒烟
   transcript 报错原文：`unknown field 'SessionStart', expected 'description' or 'hooks'`），
   而 `tad.sh` heredoc（实测 L920-946，与现 `.codex/hooks.json` 逐字节一致）每次
   codex/both 安装都重新生成这份坏文件；
2. `.agents/skills/{alex,blake}/SKILL.md` 镜像内各 36 处（alex 34 + blake 2；双树合计 72 行）
   `reference: ".claude/skills/…"` 指向 codex-only 安装不存在的目录 → 36 个
   progressive-disclosure 协议静默加载失败（= 知识库 "Codex dogfood: Blake skipped
   Layer 2/Gate 3" 事故根因）；
3. `.tad/runtime-compat/codex.md` 钉在 0.137.0、`next_review: 2026-07-09` 已过期、
   `hooks` 行现为事实错误；`runtime-freshness-verify.sh` 当前对 high-volatility 行已处
   BLOCK 状态。docs 仍宣传 "0.137+ 可用"。

本单目标：Codex 侧从"接线全死"恢复为"接线活着且台账真实"。用户已确认主力向
Codex/DeepSeek 迁移，通用性为一等目标。

## 2. 不做什么（后续单负责）

- 知识入口（AGENTS.md 知识加载节、brain-index、CRITICAL 规则镜像）→ step 2
- hook 脚本 stdin 信封归一化（`.tool_input.*` 解析）→ step 2
- PreCompact 的 Codex 接线 → step 2
- **detect-platform.sh 误判修复 → 递延 step 2**（R1 审查裁定：属脚本内部逻辑且会静默改变
  Claude 会话编排默认值——`workflow`→`codex` 对 design-protocol.md:140 tournament 路由是
  质量回退；需先设计信号表：Claude 特征如 `CLAUDECODE=1`、codex 特征如 `CODEX_SANDBOX*`
  由 spike 取证 + 双信号并存期望值 + 消费者清单。本单不动该文件）
- 镜像内**非** `reference:` 行的 `.claude/` 可执行路径悬空 → step 2 工单，已知清单（本单
  声明为 known-broken，非"全部合法"）：alex SKILL L1852（AR registry awk 自提取）、
  blake L2090（honest_partial awk 自提取）、blake L559/L563（skill 可用性扫描）、
  `.agents/skills/blake/references/*.md` 的 `# Source:` 头。实测基线：非 reference 行
  `.claude/` 提及全镜像 173 处、alex+blake SKILL 内 23 处，绝大多数为治理对象名称（合法），
  以上枚举为已知例外
- Reviewer 档位/Model 捕获词汇通用化 → step 3
- Workflow 编排移植、Route Contract 减重 → 独立议题
- 不改任何 hook 脚本的内部逻辑（本单只修接线与声明层；release-verify.sh 是发布验证器
  非 hook，属本单范围）

## 3. 设计

### 3.1 hooks schema 修复（spike-first，spike 是 ground truth）

1. **Spike A（schema）**：scratch git 仓放最小 `.codex/hooks.json` 候选（按 0.146 期望的
   `{description, hooks}` 顶层结构起草），本机 codex-cli 0.146.0 实测解析。
   **Spike 协议（R1 审查回填）**：
   - 已实测排除的廉价路径：`codex doctor`/`codex doctor --all`/`codex debug prompt-input`
     均不报 hooks 解析错误，`codex hooks` 子命令不存在 → 必须真实 session 启动观察 stderr；
   - **trust 隔离**：0.146 hook trust 是持久化授权；全新 scratch 仓未受信时 hooks 可能根本
     不被加载 → parse 警告不出现（AC1 假 FAIL 风险）。Spike 须用 scratch `CODEX_HOME`
     （保护真实 `~/.codex` 的 trust/state sqlite），显式建立项目/hook trust；
     "警告仅在受信上下文出现"若被证实，作为合法 spike 发现记录进 spike 报告；
   - 不使用 `--dangerously-bypass-hook-trust` 作为常规路径；如 spike 需要它对照，单独记录。
2. 用实测 schema 重写 `.codex/hooks.json`（该文件 git-tracked，直接改仓内文件），语义等价
   迁移现有 4 条接线（SessionStart×2、PostToolUse apply_patch、PostToolUse
   ask_user_question）。0.146 若不支持某事件/matcher → **honest 映射**：该条不接，在
   `.tad/guides/hooks-platform-mapping.md` 记录"0.146 不支持，原因/替代"，禁止硬造。
3. `tad.sh` heredoc（L920-946）同步替换为与修复后文件逐字节一致的内容；生成逻辑本身
   不重构（Never Hand-Write 原则）。

### 3.2 镜像 reference 路径平台中立化（spike-first，R1 审查升级）

**先决 Spike B（reference 解析）**：两位 Gate 2 专家对解析行为结论相反
（R1-A：Read 按仓库根/CWD 解析，相对形式两平台皆断；R1-B：capability packs 已在双平台
生产使用 skill-基目录相对形式如 `.claude/skills/web-backend/SKILL.md:39-43`
`references/api-design.md`，且实测 codex 载入 skill 附带 SKILL.md file locator）。
**以 spike 裁决，不以任一 review 结论为准**：scratch skill（或直接用现有 capability pack）
含相对 `reference:`，在 Claude Code 与 codex 0.146 各激活一次，观察 agent 能否实际读到
目标文件。**观察纪律（R2 回填，防 validation theater）**：spike 报告必须记录 agent 实际
使用的读取路径/工具序列——直接 Read 相对拼接路径成功才算 PASS；agent 靠 Glob/搜索兜底
命中目标算 FAIL-with-note（说明解析本身不成立）。Spike 结果二选一：

- **spike PASS（基目录解析成立）→ 方案 α（默认）**：
  1. `.claude/skills/alex/SKILL.md`（34 处）与 `.claude/skills/blake/SKILL.md`（2 处）中
     `reference: ".claude/skills/<skill>/references/<file>.md"` →
     `reference: "references/<file>.md"`；
  2. **维护者注记行**（R2 修订：定位与逐字内容钉死）：在每文件**第一个** `reference:` 行
     的紧邻上一行插入以下逐字内容（`#` 注释行，防止被误读为 YAML 键；性质 =
     maintainer 文档，非运行时指令；alex 的 reference 分散在 L673→L1678 约 6 簇，
     此行不承担 runtime belt——运行时解析可靠性由 Spike B 结论承担）：
     `# reference 相对路径以本 skill 基目录解析（两平台激活均提供该目录）——维护者注记，勿改回 .claude/skills 绝对形式`
     此行是 AC5 line-set diff 中唯一允许的非 reference 新增行（每文件恰 1 行，逐字如上）；
- **spike FAIL → 停，报告人**：带着 spike 证据与备选方案（镜像时路径改写=破坏字节 parity
  契约需 sanctioned-transform、`{SKILL_DIR}` token + 展开说明、references 迁入 `.tad/`
  共享树）回 Alex 重新设计——不得由 Blake 现场发明机制。

后续步骤（方案 α 下）：
  3. `reference: ".tad/…"` 形式不动（`.tad/` 两平台共享，天然中立）；
  4. rsync 镜像（release-verify.sh `parity --fix` 方向 Claude→agents）；
  5. `release-verify.sh` parity 新增 fail-closed 检查，**插入点与顺序为 SAFETY 规格**：
     - 检查必须在双树字节一致 early-exit（现 L543-549 `exit 0`）**之前**无条件执行——
       否则"双树一致且都含坏行"的常态（过去一个月 36 行存活的状态）下检查永不运行；
     - `--fix` 模式下检查运行于 rsync **之后**的终态（避免对 still-stale `.agents` 树
       误 FAIL 而拒绝执行修复它的 rsync——死锁）；verify 模式下运行于 diff 之前；
     - 检查范围 `.agents/skills/**/*.md`（全部 md，含 references/ 嵌套——当前嵌套层无
       绝对形式引用，此为防未来回归；release-sync.md "verifier 粒度必须匹配复制粒度"）；
     - 只针对 `reference:` 声明行含 `.claude/` 的情形 FAIL，输出**专属可断言消息**
       （如 `parity FAIL: platform-coupled reference path in <file>:<line>`）；
       非 reference 行的 `.claude/` 内容性提及不触发（见 §2 known-broken 清单）。

### 3.3 台账与文档重验

1. `.tad/runtime-compat/codex.md`：12 行 surface 逐行用本机 0.146.0 重验。
   - 每行证据 = 预授权类别之一：本机 CLI 探测 / `--help` 表面 / 官方 changelog 或 manual
     （带 URL + 检索日期，YOLO audit auditability 原则）——**doc-source 属合法重验**，
     完成即可合法刷新 `last_verified`；
   - **Reconciliation 规则（R2 回填——防 AC7 死结）**：SAFETY_SURFACES 行（以
     runtime-freshness-verify.sh L14 名单为准，含 hooks、ask_user_question_hook、
     subagents_custom_agents、`context_compaction` 等）与 volatility=high 行**不得**以
     unknown/旧日期终态收尾——必须经预授权证据类别完成重验（doc-source 可接受）；
     穷尽 doc 渠道仍无法重验 → **honest_partial 上报人裁决**（人可选择降 volatility 或
     豁免该行），不得自行改日期/status/验证器凑 exit 0。`context_compaction` 由 v2 的
     "预期 unknown"改列为"必须 doc-verify 或上报"；
   - 仅**非 safety 且非 high** 的行允许以 `unknown_current_behavior` 收尾（台账既有
     fail-closed 契约），原因写入 current_behavior 列，`last_verified` 保留真实旧日期，
     禁止盖 2026-08-03 伪造 provenance；
   - 已验证行：`last_verified: 2026-08-03`、`next_review` = +30 天。
2. `.tad/guides/hooks-platform-mapping.md`：更新到 0.146 实测 schema 与事件映射。
3. 文档宣称修正（清单以实测为准，R1 修正）：`docs/CODEX-USER-GUIDE.md:3`（唯一 "0.137+"
   宣称处）+ `docs/INSTALLATION_GUIDE.md` L123/L127（hooks.json 生成描述）与 L82-83
   （"Codex 瘦版不含 alex/blake SKILL + hooks"与 tad.sh 现行为矛盾）。README.md 无 0.137
   宣称（grep 0 命中），移出清单。历史提及保留但须明确标注为历史。

## 4. 文件清单

修改：`.codex/hooks.json`（git-tracked）、`tad.sh`、`.claude/skills/alex/SKILL.md`、
`.claude/skills/blake/SKILL.md`、`.agents/skills/alex/SKILL.md`、
`.agents/skills/blake/SKILL.md`（镜像 rsync 产物）、
`.tad/hooks/lib/release-verify.sh`、`.tad/runtime-compat/codex.md`、
`.tad/guides/hooks-platform-mapping.md`、`docs/CODEX-USER-GUIDE.md`、
`docs/INSTALLATION_GUIDE.md`
新增：`.tad/evidence/acceptance-tests/codex-wiring-stopbleed/`（AC 脚本 + Spike A/B 报告）
（v1 曾列 detect-platform.sh、AGENTS.md、README.md——已按审查移出）

## 5. AC（全部可运行；证据落 `.tad/evidence/acceptance-tests/codex-wiring-stopbleed/`）

- **AC0（Spike B 裁决）**：spike 报告落盘，含两平台各一次相对 reference 解析实测记录
  （命令/操作 + 实际读取路径/工具序列 + 观察结果，按 §3.2 观察纪律）；结论为 PASS 才
  继续 AC4-AC5；FAIL 则 §3.2 路径改写停手报告人。**AC6 不受 AC0 门控**（R2 修订：
  fail-closed parity 检查在任何 spike 结局下都有价值，包括改走镜像改写方案时）。
- **AC1（Spike A 基线，两分支 pass 条件——R2 修订）**：scratch `CODEX_HOME` + 受信
  scratch 仓 + 旧 hooks.json → codex 最小 session。分支 (i)：stderr 匹配 transcript
  实测模式（锚定 `unknown field`/hooks-scoped 宽匹配，不猜 wrapper 短语），原文存证 →
  PASS；分支 (ii)：警告不出现且能以 trust 上下文差异解释（§3.1.1 已预判为合法发现）→
  记录解释与证据后同样 PASS，此时 **AC2 升格为 load-bearing**（新 schema 必须在受信
  上下文实测无警告）。两分支都不满足（无警告且无解释）→ FAIL，报告人。
- **AC2（schema 修复）**：同环境换新 hooks.json → 同一调用无解析警告；
  仓内 `.codex/hooks.json` 与 scratch 验证版 `cmp` 一致。
- **AC3（生成一致）**：`sed -n '<start>,<end>p' tad.sh` 提取修复后 heredoc 与
  `.codex/hooks.json` `cmp` 一致（行号以实现后实际为准，v1 实测 L921-945 与现文件一致）。
- **AC4（reference 清零 + 双树可解析）**：
  `grep -rn 'reference: "\.claude/skills' .claude/skills .agents/skills` → 0 行
  （基线 = 72，双树各 36）；脚本遍历两树全部 `reference:` 行（**含嵌套 references/*.md**），
  相对形式以该 SKILL 所在目录拼接、`.tad/` 形式以仓库根拼接，断言目标存在，两树 missing=0。
- **AC5（SKILL 修改约束，SAFETY）**：alex/blake 两份 SKILL.md line-set diff（`comm` 于
  修改前 baseline）：变化行 = 全部 `reference:` 行 + 每文件 ≤1 行预登记的解析规则说明行，
  无其它任何行变化；四哨兵按既有脚本
  `.tad/evidence/acceptance-tests/lite-review-hardening/AC-05-sentinel-preservation.sh`
  验证（awk ESCALATION-LIST 块提取 md5 = `4c55bcb6563f24dc78449fb19ff76067` ×4 +
  BEGIN/END 计数 ==1；**不是整文件 md5**——整文件实测为 `a55d3773…`/`dc7699fa…`，
  不得"顺手修正期望值"）。
- **AC6（parity fail-closed 突变探针，R1 重写）**：向 `.claude/skills/alex/SKILL.md` 与
  `.agents/skills/alex/SKILL.md` **两树同时**注入同一行 `reference: ".claude/skills/x.md"`
  （保持字节一致，`diff -rq` 干净）→ `release-verify.sh parity` 必须 FAIL 且输出
  §3.2.5 的专属消息（断言消息文本，证明 FAIL 来自新检查而非字节 diff）；还原 → PASS。
  另：单树注入 → 仍 FAIL（既有字节检查未回归）。
- **AC7（台账重验，delta 断言——R2 重写，禁 exit-0 硬指标）**：基线 =
  `runtime-freshness-verify.sh` BLOCK exit 1（5 行）。更新后按 §3.3.1 reconciliation
  规则断言：(a) 分支甲（全部 safety/high 行完成合法重验）→ 验证器 exit 0；
  (b) 分支乙（存在穷尽 doc 后仍无法重验的行）→ 验证器 BLOCK 集合 ⊆ Completion 中
  **预登记的上报清单**，且 **0 个 BLOCK 来自已标 verified 的行**，BLOCK 数 < 5 基线，
  非零退出在 Completion 显式记为 honest_partial 待人裁决——**禁止**以改验证器、改日期、
  改 status 的方式在两分支之外制造绿灯。另断言：`.tad/runtime-compat/codex.md` 含
  `codex-cli 0.146`；允许保留 unknown 的行（非 safety 非 high）`last_verified` 为
  真实旧日期（抽查）；`grep -n '0\.137' docs/CODEX-USER-GUIDE.md
  docs/INSTALLATION_GUIDE.md .tad/runtime-compat/codex.md` 每处残留带历史标注
  （逐处人读判定，清单存证）。
- **AC8（回归）**：`bash .tad/hooks/lib/skill-body-verify.sh` 通过（alex/blake 镜像
  byte-identity + load_when 非循环触发——§3.2 恰好触这些文件）；
  `bash -n` 全部改动 shell 文件通过。
- **AC9（下游安装模拟）**：scratch 目录模拟 codex-only 安装产物结构
  （`.agents/skills` 存在 + `.claude/skills` 不存在），AC4 解析脚本在该结构下 missing=0。

## 6. 风险与注意

- **0.146 hooks 能力可能与 0.137 差异大**：部分事件可能不存在。处理 = honest 映射
  （§3.1.2），映射降级逐条记录，不构成本单 FAIL。
- **Spike B 双专家实证冲突**是本单最大不确定点——已把裁决权交给 spike（AC0 先决）。
- **升级清单命中**：本单触 `tad.sh`、`.claude/skills/*/SKILL.md`、release-verify——full
  通道执行，Gate 3 照常。
- **`codex exec` 产生真实模型调用**：spike 用最小 prompt，次数个位数；scratch
  `CODEX_HOME` 防污染真实用户态。
- **发布语义（R1 回填）**：TAD 安装是 pull-from-main（`npx github:Sheldon-92/TAD`）→
  合入 main 即事实发布。本单为严格改善、单独发布安全；版本号/CHANGELOG 由人在 commit 时
  决定；须在 Completion 提示：曾用 `--platform both/codex` 安装的下游项目需重跑安装器
  才能替换坏 hooks.json。
- **AC5/AC6 是 SAFETY 约束**：line-set diff 是 ground truth；AC6 的双树注入形态是
  区分力的必要条件（单树注入被既有字节 diff 顺带 FAIL，证明不了新检查存在）。

## 7. 知识引用

- `patterns/release-sync.md` — parity/镜像危害、deny-list/verifier at every granularity →
  新 parity 检查含嵌套 md + 插入点前置于 early-exit
- `patterns/ac-verification.md` — 突变探针必须隔离被测检查（双树注入设计）、baseline
  line-set diff 验协议文件修改边界、自确认检查（checker 定义自己验证的规则）是 self-leak
- `principles.md` "Never Hand-Write What an Existing Tool Already Does" — 修 tad.sh
  heredoc 本体；AC7 复用 runtime-freshness-verify.sh 而非手搓 grep
- `principles.md` "Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count" — AC5 用
  line-set diff 而非计数
- `patterns/research-methodology.md` "doc-research is hypothesis, spike is ground truth" —
  Spike A/B 先决设计；两位专家结论冲突时由 spike 裁决
- `.tad/evidence/research/2026-08-02-multi-model-portability-verification.md` —
  Codex 0.146 能力地基（hooks stable、plugins、skills）

## 8. Audit Trail（Gate 2 专家审查）

**R1 双专家（独立上下文并行，2026-08-03）：**
- 专家 A（code-reviewer lens，自报 claude-opus-5[1m]/native）：verdict **FAIL**。
  P0×5：①§3.2 相对路径前提未验证（Read 按 CWD 解析论）→ 处置：升级为 Spike B 先决 + AC0，
  加解析规则双保险行；②AC6 单树注入无区分力 → 处置：双树注入 + 专属消息断言 + 单树回归项；
  ③新检查插入点未指定（early-exit 前 + --fix 顺序死锁）→ 处置：§3.2.5 SAFETY 规格化；
  ④`UNVERIFIED:` 令牌绕过台账 fail-closed 契约 + 伪造 last_verified → 处置：改用
  `unknown_current_behavior` + 保留真实日期；⑤§2 与 §3.3.4 矛盾 + detect-platform 默认值
  静默翻转 → 处置：整项递延 step 2（含信号表设计要求）。
  P1×6 全部采纳：AC8 同义反复（随⑤删除）、AC7 复用 runtime-freshness-verify.sh、AC5 引用
  既有哨兵脚本、检查范围扩至嵌套 md、"90+/全部合法"改为实测数 + known-broken 枚举、
  README 无 0.137 宣称移出清单。P2×8：采纳 P2-2（git-tracked 注明）、P2-6（skill-body-verify
  回归 AC）、P2-8（AC4 基线 72）；P2-1/3/4/5 为验证性 good、P2-7 并入 NEXT 已记。
- 专家 B（平台/发布工程 lens，自报 claude-fable-5）：verdict **CONDITIONAL**。
  P0×1 = 专家 A ②③同源（AC6 区分力 + 永不执行路径）→ 同处置。事实核验：36×2/heredoc
  唯一写入点/哨兵值 全部确认；**§3.2 相对路径设计判 PASS（capability packs 双平台生产先例 +
  codex file locator 实测）**——与专家 A ①冲突，处置 = Spike B 裁决而非采信任一方。
  P1×4 全部采纳：spike trust/CODEX_HOME 隔离协议、detect-platform 信号表要求（随递延带走）、
  "全部合法"声称过宽（同 A）、runtime-freshness-verify 绿灯 AC（同 A）。
  P2×5 采纳：AC1 锚定 transcript 实测模式、INSTALLATION_GUIDE 补入清单、发布语义段、
  ledger 证据类别预授权、哨兵提取方法自含。
- **v2 状态**：全部 P0 处置完毕；两专家冲突点（§3.2）以 Spike B 先决裁决，未采信任一方
  单方结论。

**R2 增量复核（同两位专家，2026-08-03）：**
- 专家 A：R1 五 P0 全部确认解决（并自行核实专家 B 的 capability-pack 反证为真，撤回对
  §3.2 设计的 FAIL，认可 spike 裁决框架优于自己原建议）。新发现 **P0-NEW：AC7 exit-0
  不可满足**（context_compaction 是 SAFETY surface → unknown 必 BLOCK；high-volatility
  行保留旧日期必 stale-BLOCK——逼 Blake 在伪造 provenance 与永久红灯间二选一）+
  P1-N1（"声明区起始处"不存在，注记行须钉在首个 reference 紧邻上一行 + 明确非 runtime
  belt）+ P1-N2（预登记行须逐字 + `#` 注释形态）+ P1-N3（AC1 需两分支 pass 条件）+
  P2（AC6 不应受 AC0 门控）。verdict CONDITIONAL，预承诺照修即 PASS。
- 专家 B：R1 全部 findings 确认处置到位；§3.2 spike 裁决框架 sanity-check 通过（放弃
  坚持自己的 PASS 结论）。**独立撞上同一 AC7 矛盾**（P1-NEW，给出处方另一半：
  safety/high 行须经预授权 doc 证据真实重验合法刷日期，穷尽后仍不可验 → honest_partial
  上报人裁决，context_compaction 改列必须 doc-verify 或上报）+ P2-NEW（Spike B 观察
  纪律：直接 Read 相对拼接路径成功才算 PASS，搜索兜底命中算 FAIL-with-note）。
  verdict CONDITIONAL，预承诺回填即转 PASS、无需再轮全量。
- **v3 处置（终版）**：AC7 重写为两分支 delta 断言（分支甲 exit 0 / 分支乙预登记上报
  清单 ⊆ 断言 + honest_partial，禁改验证器/日期/status 造绿）；§3.3.1 增 reconciliation
  规则（safety/high 行必须重验或上报，doc-source 合法刷日期；仅非 safety 非 high 允许
  unknown 终态）；注记行钉死逐字内容与位置（`#` 形态、首 reference 紧邻上一行、
  非 runtime belt）；AC1 两分支（复现 或 trust 差异解释 + AC2 升格 load-bearing）；
  AC6 脱离 AC0 门控；Spike B 观察纪律入 §3.2。两位专家的修复处方互补合并，
  均按其逐字规格实现——依其预承诺，Gate 2 记 **PASS（条件已兑现）**。
