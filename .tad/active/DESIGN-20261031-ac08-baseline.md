# DESIGN-20261031 — AC-08 基线边界分类与全量 diff 报告设计

- **性质**：设计票（design ticket）。只出设计，不改 AC-08 实现。后续实现另立 HANDOFF，按 §7 验收标准判。
- **作者**：Alex（Solution Lead），2026-10-31。Surplus Phase 2 自跑第 11 件（EV 1.80）。
- **来源**：NEXT.md BACKLOG「AC-08 baseline design knife — GM named, ticket not opened」（原文三行见 §1.1）；GM 14:06 E1 已知偏差并入本票。
- **现行实现（本设计改造对象）**：`.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/AC-08.py`（下称「AC-08 检查」），及其基线件 `baseline.json`、`repair-entry-scope-baseline.json`、Gate 4 实跑记录 `gate4-ac08-output.txt` 与 `gate4-acceptance-report.md`。

---

## 1. 问题（实测，非推测）

### 1.1 BACKLOG 原文

> - Ordinary PM, wrapper, and trace writes break an ignored-byte baseline, and AC-08 stops at the first mismatch so the first FAIL path is not the full set.
> - Next ticket designs the boundary among stable sources, task artifacts, external-owner state, and runtime output, and reports the complete diff. Do not widen this task's allowlist. GM 14:06 E1 known deviation belongs here.

### 1.2 缺陷一：首错退出（fail-fast），报告永远不完整

AC-08 检查的 `check()` 在首个 FAIL 处 `sys.exit(1)`（脚本内约 30 个检查点共用此出口）。Gate 4 实跑记录为证：输出 113 行 PASS（`gate4-ac08-output.txt` 全文件共 126 行）后在 `.tad/evidence/traces/2026-10-18.jsonl` 处 FAIL 退出（`gate4-ac08-output.txt` 末行 `EXIT:1`），其后整段检查（compatibility 映射、source-excerpts 逐字复核）在该轮**根本没有执行**。Gate 4 报告被迫在工具外人工裁定完整性（`gate4-acceptance-report.md:123`：「AC-08 stops at the first ignored-byte mismatch, so the first FAIL path is not the full set. This run's first FAIL was the trace file; the full set is still the two E1 paths.」）——即「完整 FAIL 集恰为两条 E1 路径」这一结论是 GM/Gate 4 在检查器之外担保的，检查器自己给不出。

### 1.3 缺陷二：基线无边界分类，非任务方的正常写入直接击穿

基线的隐含假设是「非 target 的每一字节都归任务方负责」。但仓内有三类**与任务无关的合法写入者**在任务窗口内持续写盘：

| 写入者 | 实例 | 现行处置 |
|---|---|---|
| PM（外部所有者） | `docs/pm/now.md` | 脚本内硬编码单路径豁免 `approved_scope_exemption()`，靠「仍被 git tracked」守卫 |
| wrapper（外部所有者） | `.tad/evidence/pm/last-codex.POINTER.md` | 同上硬编码，靠「仍被 git ignored」守卫 |
| 框架运行时（无单一所有者） | `.tad/evidence/traces/YYYY-MM-DD.jsonl`（trace-writer 在任何会话中持续 append；`.tad/evidence/` 整体被 .gitignore:122 忽略） | **无处置**——即 Gate 4 轮的首个 FAIL 本体 |

两条硬编码豁免是 GM 2026-10-18 12:54 的裁定（脚本注释在册），但它们以字面路径形态冻在检查器代码里：每多一个合法写入者就要改一次检查器代码并重过评审；运行时输出这类**按类合法**的写入则根本进不了「单路径豁免」的形态。SEC-R1-02 的旧账同源：ignored 路径最初不被枚举，靠后期堆叠（repair-entry 捕获、ignored 全集枚举、`external_delta_from_task_start` 显式登记）才补上——补丁都对，但分类缺位使每补一类都要动代码。

### 1.4 本设计要解的正是这两点

分类（§3）解缺陷二：每一路径在比对前先定类，类决定比对规则；报告（§4）解缺陷一：全部检查跑完、全部不符一次报全，工具自己给出完整 diff 集与「是否落在已知偏差内」的机械裁定。

---

## 2. 设计约束（不可越）

1. **不许扩本任务的 allowlist**（BACKLOG 明文）。本设计不给 TASK-20261017 增任何新豁免路径；§3 的分类是给后续所有 AC-08 实例的机制，分类登记册的每一项仍须有裁定来源（§3.4），检查器永不自授豁免。
2. **判据按类作用域化**（principles 2026-06-01：全局计数下限对 must-cover 集合失明）。禁止用「不符总数 ≤ N」这类全局口径放行；放行与否逐路径、逐类判。
3. **集合有界才可用否定表**（principles 2026-06-01 AMENDED 判据）。分类的全体 = 任务清单 ∪ 登记册 ∪ 基线捕获，是有界可枚举集；集外一律 fail-closed（§3.3 决策程序第 5 步），不设「未列出即允许」。
4. **既有行格式与退出码兼容**（§5）。Gate 4 与 PM 已有按现行文本行消费的习惯，改造只许在末尾附加汇总段，不许改既有行文法。
5. **检查器不执行被检文档的命令、不写被检树**（gate-design 既有原则）。分类与报告全是只读比对＋向证据面写自己的报告件。

---

## 3. 边界分类：四类、判定规则、实例

每一路径在字节比对前先过一遍分类，报告里每一 diff 条目都带类名（下游消费者不许再自行推导分类——principles/patterns 的「排除项须在每个继承它的度量定义处重述」同理：分类随条目走）。

### 3.1 类 S — stable-source（稳定源）

- **定义**：基线捕获时已存在、非任务 target、且在任务窗口内没有任何在册写入者的文件。
- **判定规则**：出现在 `baseline.json` 的 `hashes`／`non_target_hashes`／`ignored_hashes` 捕获集内，且不命中 T／X／R 任一登记。
- **比对规则**：与捕获字节逐字相等。任何 delta（改／删／增）＝**FAIL**，归因「未登记的变更」——不自动区分是任务越界还是外部未登记写入，两者都要升级给人裁，检查器不代为开脱。
- **实例**：Gate 4 轮基线里的约 30 个预存 dirty tracked 文件的捕获字节、index tree、HEAD（后两者为 S 的退化形态：值即基线本身）。

### 3.2 类 T — task-artifact（任务产物）

- **定义**：任务合同自己枚举的路径：声明的 MODIFY targets、任务证据目录、任务名下的 ralph-loop／review／COMPLETION 出口。
- **判定规则**：路径 ∈ 任务清单（handoff §7 范围与 AC-08 的 `targets`＋`allowed()` 的任务自有前缀集）。成员资格只来自枚举，不来自「看起来像任务文件」。
- **比对规则**：变化是预期的，按 target 逐件报 before/after sha256 构成任务 delta 本体；清单内路径无变化反而要报（对应现行 `changed==targets` 的「每个声明 target 都必须真改」检查）。T 类内部再混入未枚举路径 → 该路径按未分类走 §3.3 第 5 步（FAIL），不因身处 T 目录而免检（现行对 E 目录的 `allowed()` 前缀放行须收紧为：E 内仍逐件对清单，未枚举的新文件报为 T-未枚举，计入 diff 集但不定 FAIL——它属于任务证据面，定性由 Gate 裁；此为与现行行为的**有意差异**，迁移时须在 §5 对照表显名）。
- **实例**：10 个 MODIFY targets；`.tad/evidence/acceptance-tests/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES/` 证据面；`.tad/evidence/ralph-loops/TASK-20261017-FULL-LAYER2-REVIEW-BRAKES_*`；COMPLETION-20261017 文件。

### 3.3 类 X — external-owner（外部所有者状态）

- **定义**：所有者是具名非任务方（PM、wrapper、其他席位／进程），且其写入是该所有者的常态职责。
- **判定规则**：路径命中**豁免登记册**（§3.4）中一条 X 登记：精确路径或窄模式＋具名所有者＋守卫条件。守卫是该登记的承重部分（承 principles 2026-06-01「safety rests entirely on the EXCLUSION path」之意：豁免的合法性全在守卫上）。
- **比对规则**：delta **报告不判 FAIL**，以所有者归因行入 diff 集（如 `X pm docs/pm/now.md modified (guard: tracked ✓)`）；守卫一旦不成立（豁免路径不再被 ignore／不再被 tracked、所有者不符）→ **FAIL**，且该条同时失去 X 资格、按 S 规则复判。
- **实例**：`docs/pm/now.md`（owner=PM，guard=tracked）；`.tad/evidence/pm/last-codex.POINTER.md`（owner=wrapper，guard=git-ignored）。现行 `external_delta_from_task_start` 机制并入本类：窗口开始前已存在的外部 delta 在基线捕获时即登记为 X-既存，报告单列，不再用一条 INFO 行带过。

### 3.4 类 R — runtime-output（运行时输出）

- **定义**：框架自身机械在任何会话运行都会写的路径——没有单一的人类所有者，内容以 append 为主、高频变动。对这类文件钉字节哈希是范畴错误：哈希必然变，变不构成证据。
- **判定规则**：路径命中登记册中一条 R 登记：目录＋文件名模式＋写出机制名（如 trace-writer／trace-rotate）。
- **比对规则**：不比字节。报三件事：路径集（新增日期文件属预期）、每件字节数、与捕获时相比的增减方向。**增长／新增＝报告不判 FAIL；窗口内文件的消失或缩短＝FLAG**（单列一档，介于 PASS 与 FAIL：默认按 FAIL 计入退出码，除非登记册为该模式登记了轮转机制——`trace-rotate.sh` 即一例，轮转删除须由登记册显名才降为报告项）。FLAG 的退出码口径在实现票里二选一锁死，不许留运行时裁量。
- **实例**：`.tad/evidence/traces/2026-10-18.jsonl`——Gate 4 轮首个 FAIL 本体；按本设计它应是 R 类报告行而不是 FAIL，整轮结论随之从「exit 1＋人工担保完整集」变为「完整报告＋机械裁定 known-deviation」（见 §4.3 对 E1 的收编）。

### 3.5 分类决策程序（有序，先命中先定类）

对任一路径 p，依次判：

1. p ∈ 任务清单 targets → **T**
2. p 命中豁免登记册 X 条（且守卫成立）→ **X**（守卫不成立 → 失去豁免，转第 4 步按 S 判并另记守卫 FAIL）
3. p 命中登记册 R 模式 → **R**
4. p ∈ 基线捕获集 → **S**
5. 其余（未捕获、未登记的新路径）→ **未分类**：tracked／untracked 按现行清单规则判 FAIL-as-S；ignored 新路径同判 FAIL-as-S。fail-closed，不许落进任何放行类。

### 3.6 豁免登记册（exemption registry）——数据，不是代码

- **形态**：JSON 文件，随任务基线同置（AC-08 实例：任务证据目录内 `scope-registry.json`）；框架层不预置任何路径。
- **每条字段**：`path`（精确）或 `pattern`（窄 glob）、`class`（X 或 R）、`owner`（X 必填：pm／wrapper／具名进程；R 填写出机制名）、`guard`（X 必填，如 `git-ignored`／`tracked`；R 填轮转机制名或空）、`granted_by`（裁定出处，如「GM 2026-10-18 12:54 A'」）、`date`。
- **治理**：运行中不得增改（防被检方自授豁免）；增改只发生在两次运行之间、且必须有裁定记录。检查器启动时校验登记册 schema 与 `granted_by` 非空，缺一即 INDETERMINATE。
- **种子**：迁移时登记册只许由现行代码里的既成事实播种——两条硬编码豁免（带其原裁定出处）＋E1 的 traces 模式（出处 GM 14:06 G）。种子之外无任何条目（§2 约束 1）。

---

## 4. 全量 diff 报告：输出形态

### 4.1 执行模型：collect-and-continue

`check()` 改为记录式：每个检查点 append 一条结果记录 `{section, name, path, class, verdict, detail}`，永不中途退出。全部检查点跑完后统一结算退出码：

- exit 0：无 FAIL 且无未裁 FLAG；
- exit 1：≥1 FAIL，或有未裁 FLAG；
- exit 2：INDETERMINATE（基线／登记册等输入缺失或 schema 不合）。

INDETERMINATE 亦收集化：某输入缺失时，依赖它的检查点逐条标 `SKIPPED (missing input: <name>)`，其余检查照跑——报告永远完整呈现「跑了什么、跳了什么、为什么跳」，不许整段静默消失。

### 4.2 文本输出（人读，兼容现行）

1. 主体与现行一致：各检查点按现行顺序逐行 `PASS/FAIL/INFO <name> <path>`，行文法不变（附加：diff 条目行尾带 `[class]` 标记，此为附加后缀，不改行首文法）。
2. 末尾新增 `== SUMMARY ==` 段：
   - 计数矩阵：verdict（PASS／FAIL／FLAG／SKIPPED）× 类（S／T／X／R／未分类）；
   - `DIFF SET` 全表：每一个不符路径一行，按 类→路径 排序（排序保证跨轮可做行集 diff，承 principles 2026-05-31 行集比对口径），列：路径、类、delta 种（modified／added／deleted）、before/after sha256 前 12 位（R 类为字节数与方向）；
   - `KNOWN-DEVIATION: yes|no` 行与未被已知偏差覆盖的 FAIL 余集（§4.3）。

### 4.3 已知偏差的机械裁定（收编 E1）

- 已知偏差集 = 登记册内标 `known_deviation` 的条目集（E1 迁移后 = 两条：POINTER（X）与 traces 当日文件（R））。
- 裁定式：`known_deviation ⟺ FAIL∪FLAG 路径集 ⊆ 已知偏差集`。成立则打印 `KNOWN-DEVIATION: yes (covered: <n>, set equals deviation registry)`；不成立则打印 `no` 并逐行列出余集。Gate 4 报告 §22 那种「complete list below is exactly the two E1 paths」的人工担保自此由工具自证。
- 注意口径变化：按本设计，E1 两路径在新分类下本就不产 FAIL（X 报告、R 报告），known-deviation 裁定主要服务于迁移期与未来新偏差（如守卫临时不成立的 X 条）。报告须同时打印两口径：分类后 FAIL 集、以及「若按旧口径（无分类）将 FAIL 的路径集」一行——使新旧轮次可对照，防分类把真问题洗掉（此行即 §5 迁移对照的运行时形态）。

### 4.4 机器可读侧车

同轮输出 `AC-08-report.json`（写证据面）：含全部结果记录、计数矩阵、diff 全集、known-deviation 裁定与余集。后续 Gate／PM 消费 JSON，不再刮文本（现行 `gate4-ac08-output.txt` 式全文保存继续保留为人读证据）。

---

## 5. 兼容与迁移注记

| 面 | 现行 | 本设计 | 兼容判 |
|---|---|---|---|
| 检查点行文法 | `PASS/FAIL/INFO name path` | 不变；diff 行尾加 `[class]` 后缀 | 兼容（行首文法与顺序不变） |
| 退出码 | 0/1/2（1=首个 FAIL 处） | 0/1/2（1=完整跑完后 ≥1 FAIL） | 语义增强：1 的含义从「首错」变「全集非空」，消费方（Gate 4 报告模板）须在实现票中同步一句注记 |
| `baseline.json`／`repair-entry-scope-baseline.json` | 既有格式 | 不动；`external_delta_from_task_start` 字段保留读入并转登记为 X-既存 | 兼容 |
| `approved_scope_exemption()` 硬编码 | 两条路径＋守卫在代码里 | 移入登记册数据，守卫语义逐字保留（ignored／tracked 校验不降格） | 行为等价，须由 AC2 对照证 |
| `allowed()` 的 E 目录前缀放行 | 前缀即放行 | 收紧为逐件对清单、未枚举报 T-未枚举（不定 FAIL） | **有意差异**，实现票须显名，Gate 2 重点审 |
| 其余 AC-01…AC-07 | — | 不受影响 | — |
| HANDOFF §9.1 中 AC8 行口径 | 「exit 0；初始字节/最终 delta/hunk 归因」 | 措辞更新属后续实现票，不在本设计内改 | — |
| 回滚 | — | 单脚本改造：旧脚本留 `AC-08.py.prev` 至后续实现票 Gate 4 通过 | — |

迁移验收的对照基线就是 Gate 4 轮的记录集：新检查器在该轮证据上重跑，分类后 FAIL 集应为空、旧口径 FAIL 集应恰为 E1 两路径、且 §1.2 中未被执行的后段检查（compatibility／excerpts）须在本轮完整出现。

---

## 6. 范围外（非目标）

- 不改十个 target 的任务 delta 定义与归因规则。
- 不扩任何既有 allowlist；不给 TASK-20261017 新增豁免（E1 两路径是既成裁定的收编，非新增）。
- 不改 trace-writer、wrapper、PM 的任何写入行为——写入者照常写，检查器学会分类。
- 不新建仓级通用工具；改造限于 AC-08 检查这一族脚本与其基线／登记册数据。

---

## 7. 后续实现件验收标准（Gate 2 锁前须逐条在活基线上干跑，known-GOOD 必过、known-BAD 必挂）

| # | 标准 | 验证形态 |
|---|---|---|
| AC1 | **全集报告**：在含 ≥3 处不同检查段不符的 fixture（其中一处位于 ignored 段之后）上运行新检查，一轮内报出全部不符路径、exit 1；同 fixture 上旧检查恰报 1 处即退出（对照组） | fixture |
| AC2 | **E1 收编对照**：在 Gate 4 轮记录的证据集上重跑——分类后 FAIL 集为空；旧口径 FAIL 集恰为 {`.tad/evidence/pm/last-codex.POINTER.md`, `.tad/evidence/traces/2026-10-18.jsonl`}；`KNOWN-DEVIATION: yes`；从登记册删去任一条（fixture 副本）后翻为 `no` 且该路径出现在余集 | command（对记录集重跑）＋fixture（删登记） |
| AC3 | **四类行为**：单轮 fixture 内同时植入七个子断言——S 字节改→FAIL；T 内改→任务 delta 报告、无 FAIL；X 改且守卫完好→所有者归因报告、无 FAIL；X 守卫破坏（豁免路径不再 ignored／不再 tracked，二选一植入）→FAIL；R 增长→报告、无 FAIL；R 窗口内文件删除→FLAG 且计入退出码；未分类新 ignored 文件→FAIL。七条同轮全中 | fixture |
| AC4 | **无静默跳段**：干净重放（除任务自身 delta 外无植入）exit 0，且现行脚本的每一检查段（targets／non-target 保存／status 行／index·HEAD／untracked／ignored／证据成员／compat 映射／excerpt 逐字）都在报告中出现；另：fixture 移除 `baseline.json` → exit 2、可计算段仍全报、缺失输入被显名、依赖段标 SKIPPED | command＋fixture |
| AC5 | **豁免在数据不在代码**：登记册文件存在且含 owner／guard／granted_by／date 全字段；新脚本正文 grep 无两条种子路径的字面量（加载器除外）；登记册缺 `granted_by` 的条目使运行判 INDETERMINATE | path-check＋command |
| AC6 | **文本兼容**：新旧输出在 Gate 4 记录集上的检查点行做行集 diff——差异仅为附加的 `[class]` 后缀与末尾 SUMMARY 段，无既有行删除或改序；三类 fixture 退出码与现行一致（clean 0／fail 1／缺输入 2） | command |

## 8. 开放问题（留实现票 Gate 2 裁，不在本设计预答）

1. R 类 FLAG 的退出码口径：计入 exit 1（本设计倾向，防轮转误报可由登记册轮转条目逐模式豁免）vs 单列 exit 3。实现票须二选一锁死并写明消费方（Gate 4 模板）如何读。
2. `scope-registry.json` 的仓级默认面：本设计只定「随任务基线同置」。后续若多个任务共用同一批 X 所有者（如 PM/wrapper 是全仓常态），是否升格出仓级登记册＋任务级覆盖，两级合并语义待第二个 AC-08 实例出现后再定，本票不预建。

## Knowledge Usage

- principles：2026-05-31（行集 diff 而非计数——§4.2 排序与行集口径）、2026-06-01 及 AMENDED（全局下限失明→逐类判；有界集合才可用否定表→§2 约束 2/3、§3.5 第 5 步 fail-closed）、2026-06-01 Deny-List granularity（豁免的承重在守卫→§3.3）。
- patterns：ac-verification（AC 须干跑、known-BAD 必挂、非空集断言→§7 写法与对照组）、gate-design（检查器不执行被检命令→§2 约束 5）。
- 仓内事实：NEXT.md BACKLOG 原文、AC-08.py 现行源码、gate4-ac08-output.txt、gate4-acceptance-report.md（E1 定义与 §123/§131 定性）、.gitignore:122、trace-writer.sh 写出面。
