# 组 5 召回测量 · 期望集（跑题前冻结；跑题者禁见本文件）

- 冻结方式：本文件落盘后计算 sha256、记入跑题记录与结果件；跑题开始后本文件零改动。
- 判分要点每行一句；命中＝期望条目 ∈ 跑题 top-3（粒度注记见结果件方法注记：principles 为条目级、patterns 为文件级——两索引面 patterns 均只到文件粒度、incidents 为文件级）。

| 题 | 期望条目（文件＋条目题名） | 判分要点 |
|---|---|---|
| Q1 | principles.md · Four-Gate Quality System | 四门分工（需求/设计/实现/验收）与「测试只验正确性不验对齐」 |
| Q2 | principles.md · Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical | 约束规则（MUST/MANDATORY/VIOLATION）不可随瘦身删除 |
| Q3 | principles.md · Mechanical Enforcement Rejected on Single-User CLI | 单人 CLI 硬拦截 fail-closed 恢复成本大于收益；替代为软提醒 |
| Q4 | principles.md · YOLO Epic Execution: Cross-Model Audit Findings | Validation Theater／Rule Soup／零碰撞检测／研究证据不可审计 |
| Q5 | principles.md · Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count | 计数基线把承重条目与引用散文混算；改用行集 diff 并在改写时保留约束引用 |
| Q6 | principles.md · Deny-List Beats Allow-List for Sync Sets | 同步集用 deny-list；承重断言在排除侧（EXCLUSION） |
| Q7 | principles.md · Execution Discipline Content Must Stay in SKILL Body | 循环触发（circular trigger）：load_when 引用被抽走内容自身则触发永不发生 |
| Q8 | principles.md · AI/Human Judgment Domain Awareness | AI 域自判/互审、人域给人且须选择题（橡皮图章效应） |
| Q9 | patterns/ac-verification.md · Workflow `{name:}` Invocation Can Load a STALE Cached Copy — Use `scriptPath` | 按名调用可能命中缓存旧副本；测新版用 scriptPath 直引真实文件 |
| Q10 | patterns/ac-verification.md · Section-Scoped Checks Must Share the Governed Location's Exact Boundary Semantics | 章节边界表达式与受治位置须同语义；整文件 grep 位置失真、范围式抽取边界自吞 |
| Q11 | patterns/ac-verification.md · Verification Strength Is Bounded by the Deliverable's Determinacy | 可验证强度受交付物确定性上界约束；先缩范围再硬化检查 |
| Q12 | patterns/ac-verification.md · A New Guard's Criteria Must Be (1) Read Verbatim From the Implementation, (2) Dry-Run Against Every Shape, (3) Composed Only of Inputs the Executor Can Obtain Independently | 三件缺一，守卫本身成下轮缺陷 |
| Q13 | patterns/ac-verification.md · A Negative Control Keyed on a Marker the Design Itself Invented Is Trivially True | 负控判据须格式无关（语义指标＋盲判＋placebo），否则通过率≈1 与改动无关 |
| Q14 | patterns/ac-verification.md · 窄判据不只让检查失效，它会产出错误的统计 → 错误的待办 → 错误的优先级 | 窄 grep 口径产出错误统计（18/20），进而立项理由与待办全错位 |
| Q15 | patterns/ac-verification.md · Ignored-tree blindness in inventory claims | git status 对整树 ignore 目录结构性失明；盘点结论须显式枚举被忽略树 |
| Q16 | patterns/gate-design.md · YOLO Mode Strengths and Constraints | 研究须 Conductor 侧（工具状态性/串行不可下放）等模式固有约束 |
| Q17 | patterns/gate-design.md · Dual-Blind Disjoint-Row Spot-Check: Producer-Hired + Acceptor-Hired Panels | 实施方雇的核查员与实施方共享先验；须验收方另雇、行集不重叠的双盲抽查 |
| Q18 | patterns/gate-design.md · Every Irreversible Action Needs Its Own Immediately-Preceding Read-Only Gate | 每个不可逆动作须各自紧贴一个只读门，「发布前统一验」不够 |
| Q19 | patterns/handoff-design.md · Missing Interactive-Decision Hooks Are Evidence-Completeness Gaps | 决策捕获钩子不触发＝决策溯源从证据链消失，按证据完整性缺口对待 |
| Q20 | patterns/handoff-design.md · Registry and Protocol Field Design | 持久态与派生态须分开声明；协议字段须三声明（归属/语义/操作面） |
| Q21 | patterns/handoff-design.md · A Change That Makes a Dormant Defect Reachable Owns That Defect | 使休眠缺陷变得可达的改动拥有该缺陷，「没碰那行」不成立 |
| Q22 | patterns/hook-contracts.md · Claude Code Hook Contract Summary | 事件键 PascalCase；per-skill hooks 未实现、allowed-tools 不强制 |
| Q23 | patterns/memory-and-learning.md · Batch Migration failure_mode Inferability: ~70% Text-Inferable, ~30% Need Doer Context | 约 70% 可文本推断、约 30% 需 doer 上下文；禁止强行编造填充 |
| Q24 | patterns/pack-build-rules.md · YAML String-Form Annotation for Pack Schema Homogeneity | 单条改 dict 破坏 schema 同质性；用行尾字符串标注 `[applies_when: ...]` |
| Q25 | patterns/pack-build-rules.md · Content Production Quality Delta Pattern | 质量须定义为结构化 delta（分项加分），非主观品味 |
| Q26 | patterns/pack-evaluation.md · Capability Pack Quality Bar: Anti-Slop Metrics | 区分度在包特有数字/阈值/命名规则；通用领域内容前沿模型自带、不加分 |
| Q27 | patterns/process-tax-cut.md · Gate 2 disk-only | Gate 2 PASS ⇔ 盘上两份独立评审件在册（P0=0 或有 sanctioned 豁免行），不等人令 |
| Q28 | patterns/research-methodology.md · NotebookLM Research Methodology | 报告是第 3 步非终点；价值在 curate 后的多轮 Ask |
| Q29 | patterns/runtime-adapter-checklist.md · ① 入口（entry） | 声明二进制名/路径/版本/启动面与无头前置；合格＝--version 实测＋无头一轮 exit 0 |
| Q30 | patterns/shell-portability.md · mikefarah yq -i Normalizes Whole File on First Write | yq -i 首写整文件规范化；字节一致验收须以规范化后文件为基线、先触发规范化再验 |
| Q31 | patterns/shell-portability.md · Command Substitution Swallows Gate Markers | $() 里 exit 只终子壳且输出被捕获；标记在主脚本层打印、exit 在调用点 |
| Q32 | patterns/shell-portability.md · The Bash Tool Runs zsh, Not bash | 本机 Bash 工具实为 zsh；zsh 不做未引用展开分词，循环只跑一次 |
| Q33 | incidents/2026-05/academic-research-pack-pilot.md | 深度指标靠自报无机械强制；缺证据等级（Tier）标注规则 |
| Q34 | incidents/2026-05/claude-md-routing-label-conflicts.md | 注释复用路由关键词作前缀使 grep 计数 +1；注释须用不共享关键词的独立前缀 |
| Q35 | incidents/2026-05/gemini-cli-constraints.md | Gemini CLI；`-p` 标志（非 TTY 必需、该模式只读） |
| Q36 | incidents/2026-05/pack-collision-detection.md | 碰撞检测与单包 eval 正交；跨带按优先级裁、同带内必须升级人工 |
| Q37 | incidents/2026-05/scienceclaw-skill-decoupling.md | 先扫运行时依赖导入定范围；耦合在基础设施层（上下文引擎/路由/插件 SDK），技能本身零导入可直接搬 |
| Q38 | incidents/2026-06/alex-role-decay-direct-execution.md | 第一成因＝角色身份衰减（长题外 detour 积攒直执惯性、personas 规则被挤出有效上下文） |
| Q39 | incidents/2026-06/cross-agent-parity-check.md | 硬编码他版没有的标记必假 FAIL；每标记须 source-condition（源里有才查） |
| Q40 | incidents/2026-06/pack-value-cross-vendor.md | 价值跨厂商成立；最稳信号＝CONTROL 在所有模型上一致低（包特有标记无模型能自发产出） |
| Q41 | 无答案（语料外：飞书镜像项目专有流程） | 给出任一候选＝误报 |
| Q42 | 无答案（语料外：阿里国际站席位报价口径） | 给出任一候选＝误报 |
| Q43 | 无答案（语料外：Menu Tales 菜谱库口径） | 给出任一候选＝误报 |
| Q44 | 无答案（语料外：BrowserSkill/GM 基础设施） | 给出任一候选＝误报 |
| Q45 | 无答案（语料外：智能家居语音板项目） | 给出任一候选＝误报 |
