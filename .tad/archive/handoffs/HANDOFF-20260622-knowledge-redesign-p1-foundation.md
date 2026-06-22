---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/templates", ".tad/project-knowledge"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Knowledge Recording Redesign — P1 Foundation (schema + writing rules + L1 principle)

**From:** Alex (Terminal 1) · **To:** Blake (Terminal 2) · **Date:** 2026-06-22
**Epic:** EPIC-20260622-knowledge-recording-redesign.md (Phase 1/4)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三份文档 + 一条 L1 原则,内容规格在 §6 逐字给出 |
| Components Specified | ✅ | schema 6 字段、writing-rules 5 规则、变量化前后样例、template、L1 原则文本全部明确 |
| Functions Verified | ✅ | 纯文档,无函数调用。目标文件 principles.md 已确认存在(14 条,会话内已读) |
| Data Flow Mapped | ✅ | 无数据流(文档产物) |

**Gate 2 结果**: ✅ PASS(专家审查后回填 §9.2)

---

## 1. Task Overview

### 1.1 What We're Building
建立"知识记录重设计" Epic 的**契约地基**:一套 typed playbook-entry schema、一份写法规则、一个变量化前后样例、一个填空模板,以及在 `principles.md` 加 **1 条 L1 原则**。后续 P2(回环)/P3(维护)/P4(迁移)全部消费这层契约。

### 1.2 Why We're Building It
**问题**:当前 TAD 知识是"干活者在任务结尾写成品"——知识诅咒下必然写成日记(对作者显然的全省略),离开 session 没人看得懂(voice-studio 实例 + 14 下游项目实证)。
**成功的样子**:有了 schema 的 `failure_mode` 必填字段 + 变量化测试,一条知识能不能复用变成**机械可判**,而不是靠作者自觉。

### 1.3 Intent Statement
**真正要解决的问题**:让"什么算可复用知识""一条知识该写成什么形状"从判断题变成有明确规格的填空题。
**不是要做的**:
- ❌ 不是改任何 Gate KA 执行逻辑(那是 P2)
- ❌ 不是建维护/lint(P3)
- ❌ 不是迁移已有知识(P4)——本 phase 只立契约,不改任何执行行为

---

## 📚 Project Knowledge（Blake 必读）

涉及类别:architecture(知识系统设计)、本仓 methodology。

**⚠️ Blake 必须注意的历史教训**:

1. **Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical**(principles.md L1)
   - 提醒:本 phase 要写"非 SAFETY 条目不堆 MUST、解释为什么"的规则——但**绝不能**把这条理解为"可以削弱 SAFETY 约束"。SAFETY 条目的 MUST/MANDATORY 是 load-bearing,写法规则里要**显式排除 SAFETY 条目**,只对普通条目适用"解释 over MUST"。
2. **A `grep -c` SAFETY Count can be tripped by prose rewording**(principles.md L1, 2026-05-31)
   - 提醒:本 phase 给 principles.md **加** 1 条(不删不改现有),所以 SAFETY count 只增不减。AC 用 line-set 验证新增,不要误伤现有 14 条。
3. **Execution Discipline Content Must Stay in SKILL Body — Circular Trigger**(principles.md L1, 2026-06-09)
   - 提醒:本 phase 只产出 templates/ 下的参考文档 + 1 条原则,不涉及 SKILL body/reference 切分。但 P2 会涉及——本 phase 的 schema 文档要为 P2 留好"哪些必须进 body"的注记。

研究依据:`.tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md`(Mem0/Letta/AWM/Anthropic Skills 源码级研究)。

**Blake 确认**:- [ ] 已读上述 + 研究 findings 文件。

---

## 3. Requirements

### 3.1 Functional Requirements
- **FR1**: 创建 `.tad/templates/playbook-entry-schema.md` — 定义 typed entry 的 6 个字段。
- **FR2**: 创建 `.tad/templates/knowledge-writing-rules.md` — 写法规则 + 变量化前后样例。
- **FR3**: 创建 `.tad/templates/playbook-entry-template.md` — 填空模板。
- **FR4**: 在 `.tad/project-knowledge/principles.md` 追加 1 条 L1 原则。

### 3.2 Non-Functional Requirements
- **NFR1**: 不修改任何 SKILL/gate 执行逻辑(`git diff` 只动 templates/ + principles.md)。
- **NFR2**: principles.md 现有 14 条**逐字保留**,只追加;追加后 ≤15 条(命中上限,见 §10 风险)。

---

## 6. Implementation Steps

### Phase 1 唯一 Phase（预计 2-3 小时）

#### 交付物
- [ ] `.tad/templates/playbook-entry-schema.md`
- [ ] `.tad/templates/knowledge-writing-rules.md`(含变量化前后样例)
- [ ] `.tad/templates/playbook-entry-template.md`
- [ ] `principles.md` 追加 1 条 L1 原则

#### 6.1 `playbook-entry-schema.md` 的内容规格（6 字段,逐字定义语义）

文档必须定义以下 6 个字段,每个含语义 + 是否必填 + 一句理由(grounding: SkillOps `s=(P,O,A,V,F)` + Letta block + Anthropic selector)。**字段定义 MUST 用 markdown 表格(列:字段 | 必填 | 语义 | 理由),以便 §9.1 AC 机械核对**:

| 字段 | 必填 | 语义 | 理由 |
|------|------|------|------|
| `label` | 是 | 稳定身份(kebab-case slug),= 文件名/锚点 | Letta block label / Anthropic name |
| `selector` | 是 | "何时用"的触发描述,枚举触发词+近义+一个 catch-all,**外加一个 near-miss 排除(何时**不**触发,挡住共享关键词但实际不该触发的近邻)**;所有 when-to-use 都在这,不在正文 | Anthropic description-as-selector;"pushy"防 under-trigger,near-miss 防 over-trigger(两个方向都 load-bearing,研究 §2/§4) |
| `value` | 是 | 有界正文,自包含(无代词),保留具体值不泛化。**"有界"必须机械化:条目声明一个明确的字符预算(沿用 Letta `limit` 思路),让作者感到"压缩压力";具体数值可在本 doc 设定或显式注明留到后续 phase** | Letta bounded value(`limit` + live `chars_current/chars_limit`,有界=一个能看见的数,不是形容词);Mem0 self-contained |
| `failure_mode` | **是(REQUIRED)** | 这条纠正的那个**错误默认**:"naive 默认会怎么做/为什么错" | SkillOps `F`;**这是逼出 delta 的强制函数——填不出=没建模读者起点=条目不合格** |
| `validator` | 是 | 怎么验证"照这条做对了":可执行检查(客观)或人工判断(主观) | SkillOps `V`;Anthropic"客观产物上断言,主观靠人判断" |
| `read_only` | 否(默认 false) | SAFETY/load-bearing 条目标 true,自动维护禁止触碰 | Letta read_only;对应本仓 ⚠️ SAFETY 标记 |

文档结尾必须有为 P2 铺路的注记,两点:
1. "`selector` 和 `failure_mode` 必须随条目正文一起出现(非 circular-trigger),不可外移到 reference"——引用 principles.md circular-trigger 原则。
2. **P2 的"提炼者(distiller)"完整定义(本 phase 先记下,P2 消费)**:是一个**有自己 prompt 的独立 pass**,在任务**之后**跑,**从一个 high-water mark 重读整个未处理窗口**,被告知"**要挑剔——不是每个观察都值得记,但要高召回**"(研究 §1/§5,Letta sleeptime)。不要把"distiller"简化成只是"一个陌生人"。

#### 6.2 `knowledge-writing-rules.md` 的内容规格（5 规则 + 样例）

必须包含以下 5 条规则,**MUST 用顶层 `N.` 有序列表(便于 §9.1 AC 计数)**,每条祈使句 + 一句为什么(grounding: AWM + Letta + Anthropic):

1. **变量化测试(记什么)**:把条目里所有项目专属值替换成 `{命名槽}`——若一个连贯可复用的骨架还在 → 是 playbook 条目;若整个化成槽 → 是 log(别记);若什么都抽不出 → 一次性修复(别记)。(AWM)
   **配套两个 guard(变量化测试的 validator):(a) 只从 Gate-passed/accepted 的工作里采(success-only);(b) leak 检测——若成品里还带着源案例的字面值,说明抽象失败,拒收。**(AWM 的 `filter_workflows` leak-detector + success-only filter,研究 §1)
2. **保留不变量字面(对称规则)**:跨实例不变的值(按钮名、固定标签)保持字面,**不**变量化。过度抽象和抽象不足一样错。(AWM `Seattle→{origin-city}` 但 `One Way` 保持)
3. **不写相对时间**:不写"今天/最近/上次",写绝对日期——知识永久留存。(Letta sleeptime 逐字规则)
4. **非 SAFETY 条目解释为什么,不堆 MUST**:看到自己写全大写 ALWAYS/NEVER = 黄灯,重述成讲清推理让模型泛化。**⚠️ 例外:SAFETY/read_only 条目的 MUST/MANDATORY 是 load-bearing,保留不动。**(Anthropic skill-creator;本仓 Judgment-Only L1)
5. **祈使句 + 自包含**:用"做 X/别做 Y";无代词,保留具体名词/日期。(Anthropic imperative;Mem0 self-contained)

**变量化前后样例(必含,AWM 式一个 worked example)**:取一个真实音频教训("BGM 直接 loop 有接缝")展示 before(原始 journal 散文)→ after(typed entry,值变量化、failure_mode 填出"naive 默认=直接 loop"、保留不变量)。样例必须让读者从 before/after 对比里看出"抽什么、留什么"。

#### 6.3 `playbook-entry-template.md` 的内容规格

6 字段的填空骨架 + 每字段一行占位提示。`failure_mode` 占位写明"必填——写出 naive 默认会怎么错"。

#### 6.4 principles.md 追加的 L1 原则（逐字给出,Blake 按此写入,可微调措辞但不改语义）

追加到 principles.md 的 `## Principles` 列表末尾(在现有最后一条之后):

```
### Knowledge Is Forged at Distill, Not Captured - 2026-06-22
- **Discovery**: The doer who just did the work cannot write reusable knowledge — the curse of
  knowledge makes them omit everything that is obvious to them in the moment, producing a session
  diary no zero-context reader can use (voice-studio 12-iteration audio knowledge + 14 downstream
  projects, all empirically). Every SOTA agent-memory system (Mem0, Letta, AWM, Anthropic Skills)
  separates CAPTURE (doer writes raw journal) from DISTILL (a structural stranger forges the entry)
  from MAINTAIN (cheap rule-driven). TAD's terminal isolation is an ASSET here: Alex lacks Blake's
  execution context by construction, which makes Alex a genuine stranger — the distiller who can see
  the gaps the doer cannot. The typed entry's required `failure_mode` field is the gap detector: any
  field the stranger cannot fill from the journal becomes a specific question routed back to the doer.
- **Action**: Do NOT let the doer write finished knowledge at task end. Blake writes a raw journal
  (what happened). A structural stranger (Alex by default; Codex for high-stakes) distills it into a
  typed entry; unfillable fields become questions handed back across the human bridge. Knowledge that
  passes the variabilize test enters the playbook; one-off material stays journal. Reusability is a
  mechanical test (can you variabilize the episode-specific values?), not the author's judgment.
- ⚠️ SAFETY ENTRY — requires human review for any modification
- **Grounded in**: .tad/evidence/research/agent-knowledge-systems/2026-06-22-findings.md, EPIC-20260622-knowledge-recording-redesign.md
```

#### 验证方法
- `ls .tad/templates/playbook-entry-{schema,writing-rules,template}.md` → 3 文件存在
- schema 含 6 字段名 + `failure_mode` 标 REQUIRED
- writing-rules 含 5 规则 + before/after 样例 + SAFETY 例外
- principles.md 从 14 → 15 条,新增条目含 SAFETY 标记,旧 14 条逐字不变

#### Phase 1 完成证据（Blake 必须提供）
- [ ] 三个新文件的内容
- [ ] `git diff --stat`(只动 templates/ + principles.md)
- [ ] principles.md 新旧条目 line-set diff(证明只增不改)

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/templates/playbook-entry-schema.md      # 6-field typed entry contract
.tad/templates/knowledge-writing-rules.md    # 5 rules + variabilize before/after exemplar
.tad/templates/playbook-entry-template.md    # fill-in skeleton
```
### 7.2 Files to Modify
```
.tad/project-knowledge/principles.md         # append 1 L1 principle (14 → 15)
```
### 7.3 Grounded Against
- `.tad/project-knowledge/principles.md`(全文已在会话 context,2026-06-22 读;14 条 SAFETY-heavy,末条为 "Execution Discipline Content Must Stay in SKILL Body 2026-06-09")
- `.tad/templates/playbook-entry-schema.md`(new — will be created)
- `.tad/templates/knowledge-writing-rules.md`(new — will be created)
- `.tad/templates/playbook-entry-template.md`(new — will be created)

---

## 8. Testing Requirements

### 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| Expert review (Layer 2) | min 2 experts on this handoff | Alex invokes code-reviewer + 1 research-fidelity reviewer | Independent reviewer, equivalent scope (self-review NEVER equivalent) | Missing review blocks Gate 2 |

无依赖安装/auth/网络 friction(纯本地文档)。

### 8.5 Feedback Collection
N/A(无 non-code artifact;产物是 spec 文档,由 Gate 验证不由人审美)。

---

## 9. Acceptance Criteria
- [ ] FR1-FR4 全部实现
- [ ] NFR1: 无 SKILL/gate 逻辑改动
- [ ] NFR2: principles.md 现有 14 条逐字保留

## 9.1 Spec Compliance Checklist ⚠️ Gate 3 逐行执行

> ⚠️ 表内 `\|` 是 markdown 渲染转义;实跑时用裸 `|`(step1d Sub-rule 1)。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|---------------------|-------------------|-------------------------------|
| 1 | 三个模板文件存在 | post-impl | `ls .tad/templates/playbook-entry-schema.md .tad/templates/knowledge-writing-rules.md .tad/templates/playbook-entry-template.md 2>&1 \| grep -c playbook-entry` | 3 | (post-impl) |
| 2 | schema 定义全部 6 字段(格式无关,数 distinct token) | post-impl | `grep -oE '(label\|selector\|value\|failure_mode\|validator\|read_only)' .tad/templates/playbook-entry-schema.md \| sort -u \| wc -l` | 6 | (post-impl) |
| 3 | failure_mode 标 REQUIRED/必填(两词都出现即可,不要求同行) | post-impl | `f=.tad/templates/playbook-entry-schema.md; grep -q failure_mode "$f" && grep -qiE 'REQUIRED\|必填' "$f" && echo OK` | OK | (post-impl) |
| 4 | writing-rules 含 5 条规则(§6.2 已 pin 顶层 `N.` 有序列表) | post-impl | `grep -cE '^[0-9]+\. ' .tad/templates/knowledge-writing-rules.md` | >= 5 | (post-impl) |
| 5 | writing-rules 含变量化前后样例(before+after+至少一个 {slot}) | post-impl | `f=.tad/templates/knowledge-writing-rules.md; grep -qiE 'before\|原始\|之前' "$f" && grep -qiE 'after\|变量化\|之后' "$f" && grep -qE '\{[a-z-]+\}' "$f" && echo OK` | OK | (post-impl) |
| 6 | writing-rules 规则4 含 SAFETY **例外语义**(不只是出现 SAFETY 一词) | post-impl | `grep -iE '(SAFETY\|read_only).*(例外\|exception\|保留不动\|load-bearing\|不适用)' .tad/templates/knowledge-writing-rules.md \| wc -l` | >= 1 | (post-impl) + Layer2 reviewer 确认例外条款真实存在 |
| 7 | principles.md 增至 15 条 | post-impl | `grep -c '^### ' .tad/project-knowledge/principles.md` | 15 | pre-impl 实跑=14 ✅ |
| 8 | 新原则含 SAFETY 标记 | post-impl | `grep -A6 'Knowledge Is Forged at Distill' .tad/project-knowledge/principles.md \| grep -c 'SAFETY ENTRY'` | 1 | (post-impl) |
| 9 | **现有每一行逐字保留(line-set diff,非 grep -c)** | post-impl | `comm -23 <(git show HEAD:.tad/project-knowledge/principles.md \| sort) <(sort .tad/project-knowledge/principles.md) \| grep -c .` | 0(旧文件无任何一行缺失=纯追加) | (post-impl) |
| 10 | 改动只落在 4 个 sanctioned 路径(deny-list,非只查 skills/) | post-impl | `git diff --name-only \| grep -vE '^(\.tad/templates/playbook-entry-(schema\|writing-rules\|template)\.md\|\.tad/project-knowledge/principles\.md)$' \| grep -c .` | 0 | (post-impl) |

**AC Dry-Run Log**(Alex step1d, 2026-06-22):
- **AC7 pre-impl 实跑**:`grep -c '^### ' principles.md` = **14** ✅(实现后应为 15)。SAFETY ENTRY 当前 = 11(实现后应为 12)。
- **AC9 改用 `comm` line-set diff**(P0-1 修复):`^-[^-]` grep 对被删的 `- ` 开头行(每条 SAFETY bullet,53/90 行)是瞎的——这是 principles.md 2026-05-31 教训重犯。`comm -23 旧 新` 计"旧文件有但新文件没有的行",纯追加时应为 0,删/改任何旧行都会 >0。syntax 合法(进程替换 + sort)。
- **AC6 改验例外语义**(P0-2 修复):原 AC 只查 `SAFETY` 一词出现,证不了"例外条款"存在;现要求 SAFETY/read_only 与"例外/load-bearing/不适用"共现,并加 Layer2 reviewer 确认。
- **AC2/3/4/5 改格式无关**(P1-1 修复):token-count(`grep -oE|sort -u|wc`)+ 双 grep 守卫,不再绑死 Blake 的 markdown 渲染选择,避免正确文档 false-fail。§6.1/§6.2 已 pin 格式作双保险。
- **AC10 改 deny-list**(P1-2 修复):原只查 `skills/(alex|blake|gate)/`,改成"除 4 个 sanctioned 路径外任何文件被动 = fail",真正兜住 NFR1。
- 其余 post-impl(目标文件未创建),syntax-validated。

## 9.2 Expert Review Status

### Experts Selected
1. **code-reviewer** — §9.1 验证命令的可执行性 + 越界/SAFETY 保护(本 handoff 风险全在 AC 层)
2. **research-fidelity reviewer**(general-purpose) — schema/原则是否忠实研究、有无事实错或削弱 SAFETY

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: AC9 `grep -cE '^-[^-]'` 对被删的 `- ` bullet(每条 SAFETY,53/90 行)瞎,重犯 2026-05-31 教训 | §9.1 AC9 改 `comm` line-set diff;dry-run 阴性测试删 SAFETY 行返回 11(原返回 0) | Resolved |
| code-reviewer | P0-2: AC6 只查 "SAFETY" 一词出现,证不了例外条款存在(handoff 自己标的 P0) | §9.1 AC6 改验例外语义共现 + Layer2 reviewer 确认 | Resolved |
| code-reviewer | P1-1: AC2/3/4 绑死 markdown 格式,正确文档会 false-fail | §9.1 AC2/3/4/5 改格式无关(token-count + 双 grep);§6.1/§6.2 pin 格式双保险 | Resolved |
| code-reviewer | P1-2: AC10 只查 3 个 skills 目录,NFR1 "只动 templates/+principles" 未真兜住 | §9.1 AC10 改 deny-list(除 4 sanctioned 路径外任何文件被动=fail) | Resolved |
| code-reviewer | P1-3: 15-cap 下 AC7(==15)+AC9 须成对理解,单独 AC7 挡不住"偷 slot" | P0-1 修复后 AC9 line-set 兜住;dry-run log 已注明二者为 pair | Resolved |
| research-fidelity | P1-1: `value` 的"有界"退化成形容词,丢了 Letta 的 char-budget 机制 | §6.1 `value` 行补"机械化:声明明确字符预算,数值可留后续 phase" | Resolved |
| research-fidelity | P1-2: `selector` 缺 AWM/Anthropic 的 near-miss 排除(何时不触发) | §6.1 `selector` 行补 near-miss 排除 | Resolved |
| research-fidelity | P1-3: L1/distiller 定义被稀释(丢了 own-prompt+high-water-mark+be-selective) | §6.1 P2 注记补 distiller 完整定义,供 P2 继承 | Resolved |
| research-fidelity | P2-4: 变量化测试缺 leak-detector/success-only 这两个 foundation 层 guard | §6.2 规则1 补两个 guard 作为变量化测试的 validator | Resolved |

### Overall Assessment (post-integration)
- **code-reviewer**: CONDITIONAL PASS → 2 P0 + 3 P1 全 Resolved(P0 修复经 dry-run 判别性验证)
- **research-fidelity**: CONDITIONAL PASS → 0 P0,4 项 P1/P2 全 Resolved;明确确认 `failure_mode`→SkillOps `F`、`selector`→Anthropic、AWM 对称规则、SAFETY 例外均忠实无误

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **principles.md 命中 15 条上限**:加这条后正好 15(README 上限)。Blake **不要**为腾位置删任何现有条目;若 Alex/审查判断某现有条目其实是 L2,那是**单独**的决定,不在本 handoff 内。本 handoff 只追加。
- ⚠️ **SAFETY 不可削弱**:writing-rules 规则 4("解释 over MUST")**必须**显式写出"SAFETY/read_only 条目例外"。漏掉这句 = 给未来"削弱 SAFETY 约束"开口子 = P0。
- ⚠️ **本 phase 零执行行为变更**:不动任何 KA/Gate 逻辑。若 diff 触到 skills/ 执行文件 = 越界。

### 10.2 Known Constraints
- 这是契约层,后续 3 个 phase 的正确性都依赖这层措辞准确。schema 字段语义要精确,尤其 `failure_mode`(整个机制的强制函数)。

---

**Handoff Created By**: Alex · **Date**: 2026-06-22 · **Version**: 3.1.0
