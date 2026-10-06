# Gate 2 评审（tech 路）— TASK-20261006-SELF-REVIEW-R2

**评审者**：独立 Alex 评审会话（未参与本链设计）；与 fit 路互不可见。
**日期**：2026-10-06
**判据**：`.tad/gates/gate-canonical-checklist.md` Gate 2 节＋`.tad/tasks/gate-execution.md`；patterns 命中 `ac-verification`、`shell-portability`、`memory-and-learning`（索引选读）。

## 激活自报

按薄壳 `~/workspace/skills/tad-alex/SKILL.md` 激活协议入仓：已读仓根 `AGENTS.md`、`principles.md`、`patterns/_index.md`（全文）、`gate-canonical-checklist.md` Gate 2 节、`gate-execution.md`。评审对象身份复算全等：HANDOFF 54,687 B／sha256 `e50be44b…`（任务书锚一致）；风险卡、票、PM 判断正本均在盘。

## 总判：CONDITIONAL

设计本体成立（组 3 探针语义区分经代码实证、组 2 防刷日期结构成立、组 5 诚实标注到位）；但 §9.1 有一行 AC 在其验证时点不可复算（F-1，P1），另有三处判据精度问题（F-2/F-3/F-4，P2）须以文本修订关闭。全部条件均为 HANDOFF 文本修订级，不要求重设计；修订后本路转 PASS，无须重审全件（PM 对修订行复核即可）。

## 逐项结论

### 重点① 组 3 新探针设计——成立

- 语义区分属实且承重：现行 L1744 为单向校验（`diff -rq … | grep -q "^Only in $src"`，L1746–47 注释明载 target-only 为升级预期）；`_tad_tree_equal`（L2213）实证为条目集全等＋字节比对（L2220–2223 集相等先行），直接套用必把 target-only 误报 PARTIAL——设计「不许直接套」的禁令与新写单向探针的裁断正确。
- 存在判据 `[ -e ] || [ -L ]` 对悬空链接两侧均正确（dst 悬空链接：-e 假、-L 真 → 判存在，不重演备份刀 exit 2 病理）。
- 五景逐景可复跑且判据可判定：①src 悬空 dst 缺 → 枚举命中、dst 无 -e/-L → 检出；②dst 悬空、src 文件在 → -L 真 → 不误报；③双悬空同名 → 不报；④全等 → 不报；⑤src 真文件 dst 缺 → 检出。五景与探针语义逐一对得上。
- 锚复算：tad.sh sha `1490a6ab…`／3,523 行 ✓；`diff -rq` 活点恰 L1744＋注释 L1699 ✓；pre-top 生成 L739–743／消费 L2388–2410 ✓（L2410 WARN 原文与设计引文逐字同）；migrate-backup 跳过点 L710/L733、枚举 L2520、生成 L3357 ✓。
- 小注记见 F-5（枚举须含目录条目、探针落点未钉）。

### 重点② 组 5 规格可执行性——主体成立，两处操作化缺口（F-4）

- 题量与分母自洽：8＋24＋8＋5＝45；Recall@3 分母 40（无答案题不入）与 §4.5、FR5、AC21 四处同值。
- 期望集冻结成立：双文件分离、期望集 sha 先于跑题记入记录、跑题者只见题面、判分机械比对不经跑题者之手——防自判结构完整。AC20 冻结序＋抽题核原词，成立。
- 压缩比两组定义明确（patterns 索引÷本体、principles 表段÷本体），命令与中间值须入结果件，可审计。
- 「只量不改」的机械判据在 §4.5 与风险卡 ASM-5 中口径正确（跑题前后对照），但落到 §9.1 AC22 时丢了时点范围——见 F-1。
- 诚实标注到位：结果件须明写「路由面近似非真实会话召回」，§9 亦有同向警告。此为本组最易翻车处，设计已先行封口。

### 重点③ 组 2 三类复核证据形态——足以防刷日期，唯 AC9 命令精度不足（F-2）

- 分类与台账实盘逐条对得上（本席复算 codex.md 12 行）：A 类 7（skill_loading／agents_guidance／hooks／mcp／config_toml／sandbox_approval_permissions／release_sync_install）、B 类 3（subagents_custom_agents／codex_cloud／ask_user_question_hook）、C 类 2（context_compaction／trace_evidence_capture，verified_partial）✓；high 6 条与 freshness BLOCK 6 同集（AC3 本席复跑：BLOCK 6／WARN 6／exit 1 ✓）。
- 防刷结构成立：A 类三件套（本地探针原始输出＋文档当次复查＋版本回填）以探针输出为承重件；B 类负向证据须当次、不许只引旧 spike；C 类明文禁止文档核对替代；§10 停步点 3 的「A 类受配额阻断按 C 类挂起、不许降格充数」堵住了最可能的降格路径。
- C 类挂起口径干净：日期不动、COMPLETION 明记、freshness 只记「分段终值：BLOCK 剩 C 类 2 条」、明文不许宣称 exit 0；AC10 双分支与此同构。ASM-3 证伪信号与之对齐。
- 承接关系写明且不越权：票不预关、关否归 PM Gate 4 后裁定、AC21 回归不在 Blake 写集——与票面红线同向。

### 重点④ 28 行 AC 文法与可复跑性——pre-impl 四行本席全复跑通过；post-impl 行一处 P1、三处精度问题

- 文法：28 行 Verification Method 均为 command／path-check／fixture 三类合法形态（无纯散文行），pre-impl 行 Verified Output 已填实测。
- 本席 live 复跑：AC1（sha/行数 ✓）、AC2（driftcheck 现跑 (b) 恰 §4.1 名录 11 件、(a)/(c) 空 ✓）、AC3（见上 ✓）、AC4（patterns `grep -c '^### '` 合计 232 ✓／incidents find 25 ✓）——四行与自报逐值全等，证据否决面无触发。
- AC18/AC19 关键串本席验过：§4.4 原文中 `git/refs loose`、`find .git/refs -type f`、`loose` 均在位可 grep。
- 问题行：AC22（F-1，P1）、AC9（F-2，P2）、AC27/AC12（F-3，P2）。

### 重点⑤ 组 6 落点与 knowledge-writing-rules 冲突面——无冲突

- 现行 `knowledge-writing-rules.md` 为 5 条散文规则，无「条目首行格式」类强制条款；Rule 6 追加为第六条不与 Rule 1–5 任一条相抵（置信维是元数据层，Rule 4/5 管正文文体，辖面不交叠）。文件头「5 rules」计数行设计未提同步——见 F-6。
- 形态锚真实：patterns 条目首行现为 `- **Discovery**:` 等同形 bullet，`- **Source confidence**:` 首行可插入；incidents 25 件本席全量 grep 均有 `**Linked to:**` 行，设计规定的加行锚 25/25 存在。
- 增量＋未定级视同推断的迁移裁断有仓内实证支撑（批量迁移约 30% 需 doer 上下文），且设计明写 Gate 2 可否决并附条件（否决须给判读证据来源方案）——程序上正当，本路不否决。
- handoff 模板 §1 现为 1.1/1.2/1.3，无既存 1.4，新增节不撞号；session-state-template.md 在盘、尾部加节可行。brain-index 的 Keywords 列实存（组 5 路由面属实）。

## Findings

| # | 级别 | 内容 | 关闭条件 |
|---|---|---|---|
| F-1 | **P1** | AC22 验证时点错位：该行是 §9.1 post-impl 行、由 Gate 3 在链末执行，但其判据「`git status --porcelain` 与 Step 0 基线对照、机制面零新增零修改」在链末必然被同链合法改动击穿——组 4 改 `.tad/tasks/handoff-creation.md`、组 6 改 `.tad/templates/*` 与 `.tad/active/session-state.md`、组 6 补标改 `.tad/project-knowledge/patterns/*.md`、组 1 或改 `.tad/hooks/lib/pack-registry-driftcheck.sh`，全在 AC22 的机制面路径集内。按字面执行＝正确实施被判 FAIL（patterns/ac-verification 明列此类 AC 危害大于无 AC）；§4.5 与风险卡 ASM-5 的原意是「跑题前后」步内对照，AC 行丢失了该范围。 | AC22 改为绑定 Step 1 步内证据：Blake 于跑题前后各存一份 porcelain 快照入跑题记录，AC22 改 path-check 两快照 diff 为空＋机制面路径过滤；或等价地把对照时点写死为 Step 1 出口并要求快照落盘。 |
| F-2 | P2 | AC9 防刷判据不精确：`grep '2026-08-03' codex.md` 不是列范围——台账头 L5/L6 与每行 source 列的 `(2026-08-03)`/`(retrieved 2026-08-03)` 都会命中，忠实刷新后残余命中数取决于 source 列是否改写（§4.2 未明写），「恰 2 条」无法从原始 grep 行数干净读出，本链最承重的防空 bump 行反而最含糊。 | 改列范围断言，如 `grep -c '\| 2026-08-03 \|'` 数 last_verified 列（本席验过行格式：该串只命中 last_verified 格），并明写 source 列随新证据更新的要求。 |
| F-3 | P2 | AC27 路径范围与组 1 合法写集相撞：`git status --porcelain -- .tad/hooks .agents/skills` 会把组 1 的 driftcheck 口径修订（`.tad/hooks/` 内）与投影注销/声明锚（`.agents/skills/` 内）一并显示为非空，与「组 7 零落地」的语义目标不可机械区分（与 F-1 同族、程度较轻，§10 语义兜底可判读但不应依赖兜底）。AC12 同族小例：改后 `grep -n 'diff -rq' tad.sh` 仍命中 L2206 既有注释（`_tad_tree_equal` 头注，非活代码、亦不指向新探针），该行不在组 3 两区写集内，AC12 的注释条款字面无法满足。 | AC27 改为与组 1 完成后的快照对照，或在期望证据中枚举组 1 允许的 hooks/skills 增量为白名单；AC12 加「L2206 既有头注除外」或把 grep 范围限于 verify_install_complete 函数体。 |
| F-4 | P2 | 组 5 Recall@3 两处操作化未定：(i) 关键词匹配命中多于 3 条时，top-3 的取舍/排序规则未定义（先命中序？命中词数序？），不同跑题者可给出不同 top-3，基线跨轮不可比；(ii) 「可用 grep」未枚举目标文件——对条目本体 grep 与对索引面 grep 量的是两种召回（全文检索 vs 索引路由），本实验自称量「现行路由」，本体 grep 会系统性抬高数值且与诚实标注口径相抵。 | §4.5 各补一句：grep 目标文件枚举（brain-index.md 与 patterns/incidents 两 _index.md，共三文件）；top-3 定序规则（如按面 (1)→(2) 顺序取先命中、面内按行序，去重后取前 3）。 |
| F-5 | P3 | 组 3 两处未钉：(i) R1 探针「递归枚举 src 条目」未明写含目录条目本身——若实施成 files-only 枚举，空目录缺失将漏检，而现行 diff 会报 `Only in src: <emptydir>`，属行为回退；应明写枚举等价 `find <src> -mindepth 1`（含目录与 symlink 本体、不跟随）。(ii) 新探针的定义落点未在 §4.3/§6 钉明（§6 以「R1 探针+调用点+注释（约 L1699/L1744 区）」含摄，建议明写定义置于 `_tad_tree_equal` 相邻处并计入 R1 区）。 | §4.3 各补一句即可。 |
| F-6 | P3 | 两处计数/口径小疵：(i) §2.2/§4.7 的 traces「88 个日文件」本席复算不符——日期命名 jsonl 85 件、全目录 jsonl 共 87 件；§4.7 已设「实施步实测回填确值」自纠，本条只记账不拦。(ii) knowledge-writing-rules.md 文件头「5 rules」计数行在新增 Rule 6 时未列入改动，落地时应同步为 6。另 §4.5 抽样「每 k 取 1」在 patterns 层 k≈9.67 非整数、出题单位（条目题 vs 文件）表述含混——因期望集冻结＋k 值记入题集件，复现性由冻结兜底，记注即可。 | 知悉件，实施/收口时顺手对齐。 |

## Gate 2 Canonical 对照（tech 面）

- Expert review complete（双审）：本路为其一，另一路在盘后合并判定。
- Architecture / Components / Data flow：七组处置法、落点行号锚、输入→动作→落盘逐组在文，本席抽验的锚（tad.sh 五处、codex.md 分类、模板三处、语料计数）全部复现。
- Functions verified：`_tad_tree_equal`、`pack-registry-driftcheck.sh`、`runtime-freshness-verify.sh`、`post-write-sync.sh`（`.tad/hooks/` 下）、两模板与 knowledge-writing-rules 均实存且形态与设计描述一致。
- Risk card：已落盘，ASM-1/2/3 与 HANDOFF 指定三条对齐，证伪信号＋动作三列齐。
- Load points declared：逐改动列明装载面与触发时点，组 6 Rule 6 的装载面（knowledge-writing-rules 本体）与其既有被读路径一致，成立。

**结论**：CONDITIONAL——F-1（P1）与 F-2/F-3/F-4（P2）四项文本修订为转 PASS 条件；F-5/F-6 为知悉注记。修订属 Alex 对 HANDOFF 的定点改字，不触动七组设计本体。

---

**自报（本节追加前正文）**：12,000 B／sha256 `80e72318255c6fe0e493f1fe485148148b91edfeac8631d8fabedcce91e2c863`。评审全程只读，本件为唯一写入。
