
# HANDOFF: knowledge-redesign-p1-foundation

---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/templates", ".tad/project-knowledge"]
skip_knowledge_assessment: no
gate4_delta: []
---

---

## §9.1 Spec Compliance Checklist (excerpt)
## 9.1 Spec Compliance Checklist ⚠️ Gate 3 逐行执行

---

## §6 Implementation Steps (head)
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


---

## §9.2 Expert Review Audit Trail
## 9.2 Expert Review Status
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

---


# TRACE EVENTS (slug=knowledge-redesign-p1-foundation, sorted by ts)

/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-06-22.jsonl:{"ts":"2026-06-22T14:32:22Z","type":"handoff_created","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260622-knowledge-redesign-p1-foundation.md","size_bytes":14946,"slug":"knowledge-redesign-p1-foundation"}

---

