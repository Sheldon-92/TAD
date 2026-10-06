# 完工说明 — 本体收口批 HANDOFF · Gate 2 条件增补（Alex）

- 任务：按 PM 合并裁定（`.tad/evidence/pm/2026-10-05-closeout-batch-gate2-merged-ruling.md`）增补清单 A1–A4，对 HANDOFF 做定点修订。
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-05-tad-closeout-batch.md`
  - 修订前：62,785 B／sha256 `b0e5ba0a20271f331f6915b30e36ed7afa83a89021087bfdc95982ed49f96962`（开工复算与派发锚全等）
  - **修订后：66,327 B／sha256 `dabaf3298234e72855e03874090c18525cb8d0a2095216ba8744c20c40af242e`**（落盘后复算）
- 写集纪律：只改 HANDOFF 一件＋本说明一件；仓外零写；git 只读（status 核对）。

## 逐项改动定位（行号为修订后文件行号）

### A1（裁定 2）— §4.6 指针行第二列改前 70 字符硬截断

- **L311**：指针行第二列由原 96 字符串改为 registry description 前 70 字符硬截断。落盘后机器复核：从 HANDOFF 文件抽取该行第二列，实测长度 **70**，且与 registry description 前 70 字符逐字相等（`Unified research pipeline for AI agents — 5-phase (Plan→Source→Curate→`，截于词中，与邻行硬截断惯例一致；邻行实测：academic-research 70、agent-memory 69、rag-retrieval 70、synthetic-data 69）。
- **L313**：说明句订正——「邻行惯例 66–72」改实测口径（13 行 registry 派生行 69–70），「本行 71 字符」订正为 70，并留痕原稿 96 字符／自称 71 之误与裁定出处。
- **AC10（L661）未动**：判据带 60–75 与 startswith 校验原文复核无变化；70 ∈ [60,75]，fit C1 与 tech P1 同指一处合并销账。

### A2（裁定 4）— §4.2 丙层补点名＋预授权留痕句

- **L225**（丙层枚举行尾部追加）：补入 `ROADMAP.md`（注 §7.4 已列）；补入本链流程自产件五件点名——本 HANDOFF、设计完工说明、Gate 2 双路 verdict（fit／tech 两件分列）、PM 合并裁定件、本增补完工说明。
- **L226**（停步规则行追加例外句）：预授权实施者对本链后续流程自产件（实施完工说明、Gate 3/4 verdict、COMPLETION、完事卡等本链 task_id 路径模式内文件）于 Phase 0 就地分类归丙层并在 COMPLETION 留痕，不触发停步阀；路径模式外新路径仍须停步报 PM。

### A3（裁定 3，路线 A）— AC7 改结构判据组＋§4.5 同步

- **L658（§9.1 AC7 行整行替换）**：判据由「capability-skill.sh validate／verify 两命令 exit 0」改为七项结构判据组——① 目录与 SKILL.md 在册；② 文件集与 §4.5 清单 12 件集合相等；③ 禁入四件 0 命中；④ 符号链接 0；⑤ frontmatter `name:` ＝ `research-methodology`；⑥ 占位符（`{{`／`[TODO]`／`[TBD]`）0 命中；⑦ 除 SKILL.md 外 11 件与 pack 本体逐件 sha256 全等。Expected 改「七项全成立」；Verified Output 记修订判据已实跑证明（见下节）。
- **L303（§4.5 自检 bullet 替换）**：同步改为结构判据组自检，并明文「不以 validate／verify 退出码为判据」及漂移原因。
- **L545（§6 Phase 2 件 4 步骤）**：同步——物化后按 AC7 结构判据组当场自检，删原「跑 capability-skill.sh validate＋verify」。
- **附带同步一处（L176，FR4）**：FR4 原文尾句「capability-skill.sh validate/verify 双过」与修订后 AC7 直接冲突，属同一退出码要求的需求层表述；已最小化改写为「AC7 结构判据组全过（…不以 validate/verify 退出码为判据…见 §4.5）」。此为 A3 的连带一致性修订、非新增改动，请 PM 定点核时一并过目；§2.2 判据原件清单（L164）、§4.11 以外对 capability-skill.sh 的其余提及均为清单/出处性引用、无退出码要求，未动。

### A4（裁定 3、5）— 批外登记句＋版本标记口径句

- **L305（§4.5 末新增 bullet）**：批外登记句——校验器 frontmatter 契约与现行 26 件投影惯例漂移、且未被 tad.sh／publish-protocol／Canonical 任一规程引用；登记为批外独立事项，**记入本批完事卡遗留节**另行处置；本批不改校验器、不改 frontmatter 惯例（路线 B 不采）。
- **L390（§4.10 新增口径留痕 bullet）**：版本标记同步口径句——AGENTS.md 代际标记行随 `.tad/version.txt` 同步属版本口径归一（R1 机械核查面），不构成票面红线所禁的正文新增复述；新版号字面量出现面封顶两处（version.txt 首行＋AGENTS.md 标记行，派生行按 AC15 口径另计）。

未动声明：§9.2 Audit Trail 的双审回填未在本步处理（原文定位为双审落盘＋裁定后回填，本步按定点纪律未触碰，留 PM 收口或后续步回填）；HANDOFF 其余章节逐字未动。

## A3 实跑证据（/tmp 隔离根模拟物化，证明修订后 AC7 ∧ AC9 可同时满足）

- 脚本：`/tmp/closeout-batch-amend-a3-sim.sh`；隔离根：`SIM_ROOT=/tmp/closeout-batch-amend-sim-rYid4v`（fixture 留 /tmp，不入仓）。
- 物化法：严格按 §4.5——先断言 CAPABILITY.md `^status: ` 命中数，再复制 11 件＋派生 SKILL.md（删 status 行）、禁入四件不入。
- 关键输出（脚本退出码 0）：

```
ASSERT status-line-count=1 (expect 1)
MATERIALIZE_DONE files=12 (expect 12)
OLD-AC7 validate exit=2 (drift record only)
OLD-AC7 verify   exit=2 (drift record only)
PASS AC7-1 dir+SKILL.md (0)
PASS AC7-2 fileset==§4.5清单12件 (0)
PASS AC7-3 forbidden-count (0)
PASS AC7-4 symlink-count (0)
PASS AC7-5 frontmatter-name (research-methodology)
PASS AC7-6 placeholder-count (0)
PASS AC7-7 11件与本体字节全等 (0)
AC9 diff-exit=1 del-lines=1 add-lines=0 del-content: < status: frozen
PASS AC9 exactly-one-deletion(status) (0)
EXIST academic-research forbidden=0 symlink=0 name=academic-research placeholders=0
SIM_RESULT: revised-AC7-group ALL_PASS ; AC9 checked above
SCRIPT_EXIT=0
```

- 判读：同一模拟投影上，旧 AC7（validate／verify）退出 2（漂移实证——按 §4.5 规则忠实物化仍不过旧判据）；修订后 AC7 七项全 PASS，且 AC9（diff 恰删 `status: frozen` 一行、零新增）同时 PASS——**AC7（修订）∧ AC9 联立可满足**。既有投影 academic-research 以同一结构组核查（forbidden 0／symlink 0／name 相符／占位符 0）亦过，「与既有投影同法可验」成立；其 SKILL.md 与本体的正文差异为 §4.5 已注明的装后演化、非生成规则项，不影响本证明（证明对象为首次物化投影）。
