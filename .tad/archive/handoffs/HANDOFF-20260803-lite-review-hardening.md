---
task_type: protocol-docs
e2e_required: yes
research_required: no
git_tracked_dirs: [".claude/skills", ".agents/skills", ".tad/evidence/acceptance-tests"]
skip_knowledge_assessment: no
express: true
gate4_delta: []
---

# Express Handoff: Lite Review Hardening（执行探针 + reviewer 档位 + 跨角色消歧 + verifier 补field）

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-08-03 | **Version:** v2（R1 双专家 11 findings 整合后）
**Priority:** P1
**Evidence basis:**
- `.tad/evidence/research/2026-08-02-model-diversity-audit-results.md`（flash 审 flash 盲区实测：只读审查 GATE PASS vs 执行探针盲审 FAIL P0×1+P1×6）
- `HANDOFF-20260802-model-provenance-field.md` Completion（impl reviewer 突变探针抓注释盲化——执行验证价值第二次实证）
- `.tad/memory/feedback_alex-no-code-violation.md` 第三次事件 + 用户裁定"下不为例"

## 1. Intent

### What（4 项修订，一个波次）

1. **执行探针强制条款**：blake-lite L3 reviewer prompt 增加"以执行验证、不得以读代验"义务 + finding 分"执行实证/阅读推断"两类标注
2. **Reviewer 模型档位规则**：生产关键单审查须强模型档；reviewer 自身 model 身份写入 Contract Review / Completion（依托 2026-08-02 Model 字段）
3. **跨角色请求消歧协议**：用户在摩擦点说"你直接干"→ agent 必须消歧 + 逐字记录 + **仍然拒绝跨角色执行**（⚠️ v2 定性变更：R1 审查确认三个"先例"中仅 2026-08-02 一次是真跨角色且被用户裁定"下不为例"——本协议是消歧与记录机制，**不是**执行许可；不修改任何角色分离禁令）
4. **verify-state-flow.sh `required_fields` 补 `model`**：给昨日新增必填字段配常驻守卫

### Why now
2026-08-02 两次独立实证：只读审查系统性漏掉需压力推演的缺陷；执行探针两次都抓到。同日违规事件暴露"摩擦点模糊授权"缺消歧协议。混编舰队（执行 DeepSeek / 审查强档）已是既成事实但档位无定义。

### Non-goals
- 不改升级清单哨兵块（ESCALATION-LIST 区间零字节）
- 不改 CLAUDE.md、full Alex/Blake SKILL、routing-contract.yaml
- **不为跨角色执行创建任何许可路径**——alex-lite 精髓 #1"永不写实现代码"、Forbidden 清单、CLAUDE.md §4 全部原样保留（R1 CR-P0-2 方案 b）
- 不引入 hook/机械强制（2026-04-15 原则）
- 版本 bump/CHANGELOG/publish 推迟到发布周期

## 2. Scope（5 产品文件 + evidence artifacts）

1. `.claude/skills/blake-lite/SKILL.md`
2. `.agents/skills/blake-lite/SKILL.md`（与 1 逐字节相同）
3. `.claude/skills/alex-lite/SKILL.md`
4. `.agents/skills/alex-lite/SKILL.md`（与 3 逐字节相同）
5. `.tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh`（仅 required_fields 一处）

## 3. 设计契约

### 3.1 执行探针强制条款（blake-lite L3）

L3 reviewer prompt 模板内（"对照 handoff 检查：(1) spec 符合性 (2) 代码质量（bug/边界/安全）。"之后、"输出 P0…"之前，插入点已验证于 blake-lite L216）追加：

```
(3) 执行验证义务：凡可运行处必须以执行验证，不得以读代验——
    逐条重跑 AC 命令；对每个拟报 P0/P1 缺陷，在 scratch 副本上构造
    最小探针（突变/压力/边界输入）复现或证伪后再定级。
    仓库只读；探针写操作仅限 scratch/临时目录。
    客观无法执行处（无运行环境/需真机）→ 该 finding 标
    UNVERIFIED-BY-EXECUTION: {原因}，不得静默降为已验。
    报告首行自报你的 model 身份（harness/model/route，机械捕获同 Model 行纪律）。
    每条 finding 标注"执行实证"或"阅读推断"。
```

L3 段落末尾加评级纪律一句：Completion 摘录 reviewer 结论时保留"执行实证/阅读推断"标注。

### 3.2 Reviewer 模型档位规则（自带标题小节 `### Reviewer 档位规则`；blake-lite 置于 `## L3 独立审查` section 内部末尾、`## L3.5` 之前；alex-lite 置于 `### **L2.5` section 内部末尾、`### **L3 —` 之前；措辞两侧一致——R2：位置钉死，不留 operator 选择区间）

```
Reviewer 档位规则（依据 2026-08-02 flash-审-flash 盲区实测）：
- 判定"生产关键"：执行 scope 触及生产服务/物理动作/外部副作用，或
  RouteDecision route_level ∈ {standard, full}
  （route_level 由 SSOT 单调推导，设计期与执行期均可读；
   不用 execution_depth——alex-lite 侧该字段尚未产生）
- 强档定义：opus / fable 级（经 Agent tool model 参数显式指定）；
  haiku / 小型 flash 类不构成强档
- 生产关键单的 reviewer 须强档。route=native → spawn 时显式指定强档 model；
  route 为 alias-mapped（如 DeepSeek 中转，会话内 spawn 无法产生异模型 reviewer）
  → 三选一并记录：
  (a) 人切换到 native 强档会话跑审查（人桥，推荐）
  (b) 用户逐字授权同模型审查 → 按 §3.3 逐字记录格式标
      REVIEWER-TIER-DEGRADED (用户原话: "...")
  (c) 停，报告人
- Reviewer 行必须记录 reviewer 自报的 model 身份，使档位可事后审计
- 非生产关键单：档位不限（执行探针义务仍适用）
```

配套（R1 CR-P1-6，reviewer model 身份的载体）：
- alex-lite L2 内嵌模板 Contract Review 段 `Reviewer: {待填}` → `Reviewer: {待填} | model={reviewer 自报，格式同 Model 行}`
- blake-lite L4 Completion 模板 Reviewer 行 → `- Reviewer: {verdict} | model={reviewer 自报} , P0={n}(fixed), P1={n}, 摘录关键发现原文（保留"执行实证/阅读推断"标注）`
- L2.5 与 L3 的 reviewer prompt 均含"报告首行自报 model 身份"指令（L3 已在 §3.1；L2.5 加同句）

不对称说明（R1 CFG-P2a）：执行探针强制条款只加 blake-lite L3；alex-lite L2.5 维持既有"至少 1 条实地只读核验"——设计期无实现产物可突变，此不对称是设计决定。

设计期信息上限说明（R2-R5）：设计期 route_level 仅由 design_depth 推导（execution_depth 尚未产生）。Alex 判 lite 而 Blake 后升 standard/full 的单，契约 reviewer 不会触发档位规则、实现 reviewer 会——这是设计期信息的固有上限，非缺陷，future reviewer 勿重开。

### 3.3 跨角色请求消歧协议（两 skill 各加一节，标题行 `## 跨角色请求消歧`，置于 Forbidden 节之前）

⚠️ 本协议是**消歧与记录机制，不是执行许可**。角色分离禁令（精髓 #1、Forbidden、CLAUDE.md §4）完全不变、优先于本节。

```
## 跨角色请求消歧

用户在摩擦点说"你直接做/你自己干"类话语时：
1. 触发消歧（仅此时，NOT_via_suggestion：禁止主动提供、建议或默认"打破角色"选项）：
   必须先问一次："是让我把这单备好、你输一条命令切角色继续（保持角色分离），
   还是要求我打破角色分离直接实现？"
2. 前者 → 正常流转（handoff 备好 + 告知切换命令），到此为止。
3. 后者 → 逐字记录 + 拒绝执行：
   cross_role_request: recorded (用户原话: "{逐字}")
   载体（R6）：写入当前 handoff；摩擦时刻早于契约创建 → 落入随后创建的
   LITE 契约 header；无契约产生 → lite-discoveries journal 追加一行。
   不得只留在对话里。并回复：角色分离是不可妥协条款
   （2026-08-02 违规已记 violations.log，用户裁定下不为例）；
   如要更改此规则本身，走 full 通道修订 CLAUDE.md §4 与本 skill。
4. 模糊、情绪化表述永不构成授权；未经消歧问句不得推断意图（2026-08-02 教训）。
```

逐字记录格式统一注（R1 CFG-P2b）：以 escalated_review 既有格式为准——字段型用
`{字段}: {值} (用户原话: "{逐字}")`（escalated_review、cross_role_request）；
标记型用 `{标记} (用户原话: "{逐字}")`（REVIEWER-TIER-DEGRADED）。
共同不变量是**逐字引用括注**，不另造第三种变体。

### 3.4 verify-state-flow.sh

`required_fields=` 行追加 `model`（内容锚定不锚定行号）。前置已满足：decision_record.required 已含 model（2026-08-02）、DR_BLOCK 已剥注释、注释块在 awk 范围外——双专家均已独立执行验证此改动 PASS/突变 FAIL。

## 4. AC（全部管道形式，zsh 兼容；`grep -c` 计 0 时 exit 1，脚本勿依赖 set -e；R1 CR-P0-3：全部 section-scoped，防"文本落错位置全绿"——审查者已实证 v1 的全文件 grep 可被追加在 Forbidden 尾部的一行文本全数骗过）

前置：`mkdir -p .tad/evidence/acceptance-tests/lite-review-hardening/`；改前 4 skill 哨兵 baseline 与各 AC baseline 实测值存该目录（`B=.claude/skills/blake-lite/SKILL.md; A=.claude/skills/alex-lite/SKILL.md`）。

- AC1 探针条款在 reviewer prompt 内（baseline 0）：
  `awk '/^## L3 独立审查/,/^## L3\.5/' $B | awk '/spawn 1 个 code-reviewer/,/verdict PASS\/CONDITIONAL\/FAIL"/' | grep -c '执行验证义务'` ≥ 1；同管道 `grep -c 'UNVERIFIED-BY-EXECUTION'` ≥ 1；同管道 `grep -cE '执行实证|阅读推断'` ≥ 1
- AC2 档位规则（自带标题小节，位置钉死——R2，消除 operator 选区间）：
  `grep -c '^### Reviewer 档位规则' $B` == 1 且 `$A` == 1；
  位置断言 blake：标题行号严格介于 `grep -n '^## L3 独立审查'` 与 `grep -n '^## L3\.5'` 之间；
  位置断言 alex：严格介于 `grep -n '^### \*\*L2\.5'` 与 `grep -n '^### \*\*L3 —'` 之间；
  内容三项（blake 区间 `awk '/^### Reviewer 档位规则/,/^## /'` ；alex 区间 `awk '/^### Reviewer 档位规则/,/^### \*\*L3 —/'`）：`grep -c 'route_level'` ≥ 1、`grep -c 'execution_depth'` == 0（P0-1 回归防护）、`grep -c 'REVIEWER-TIER-DEGRADED'` ≥ 1——两侧各跑
- AC3 消歧协议落位 + 位置 + 逐条款 presence（R1：禁用 grep -cE 多词计数——grep -c 计行不计次，配对措辞两词一行会假 FAIL 正确实现）：
  `grep -c '^## 跨角色请求消歧' $A` == 1 且 $B 同；
  位置断言：`[ "$(grep -n '^## 跨角色请求消歧' $A | cut -d: -f1)" -lt "$(grep -n '^## Forbidden' $A | cut -d: -f1)" ]` 两侧均真；
  per-term presence（无输出 = PASS，两侧各跑）：
  ```bash
  for t in 触发消歧 逐字记录 拒绝执行 NOT_via_suggestion cross_role_request; do
    n=$(awk '/^## 跨角色请求消歧/,/^## Forbidden/' $A | grep -c "$t")
    [ "$n" -ge 1 ] || echo "AC3 MISSING: $t"
  done
  ```
  角色分离禁令零变更（R4：本机 grep 为 ugrep，`-` 开头 pattern 必须用 `-e`，否则 exit 2 会被误读）：改前改后各跑，四条锚均须 exit 0——
  `grep -Fxq -e '- 写实现代码 / 自行调用 blake-lite 或用 Agent tool 实现任务 /' $A`；
  精髓 #1 行（$A）、blake Forbidden 首条（$B）、alex L231 Stop 行同式 `grep -Fxq -e`；
  且 `git diff` 中不得出现这四行的 hunk
- AC4 镜像：两对 `cmp` exit 0
- AC5 哨兵零变更：4 文件 sentinel md5 == `4c55bcb6563f24dc78449fb19ff76067`；每文件 BEGIN 计数 == 1
- AC6 verifier 补 field（内容锚定，R1 CR-P2-9）：`grep -A3 'required_fields=' .tad/evidence/acceptance-tests/lite-standard-routing/verify-state-flow.sh | grep -c '\bmodel\b'` ≥ 1（baseline 0）
- AC7 verifier 行为：shim（`bash -c 'rg(){ grep -E "$@"; }; export -f rg; bash …verify-state-flow.sh'`）exit 0 全 PASS 且出现 `OK: decision_record field 'model' required`；突变探针（scratch 完整树移除 contract required 中的 model）→ FAIL "missing required field 'model'" exit 1；restore 与 post byte-identical。证据入 evidence 目录（复用 2026-08-02 完整树方法）
- AC8 行为验收（R1 CR-P1-5 修订，PASS 判据二值化）：
  1. scratch 建玩具树：`git init` + 一个 initial commit（L3 prompt 含 git 命令，非 git 树必炸）+ 玩具契约 + 一个"注释假满足 grep 检查"类微型缺陷文件（有 2026-08-02 两个真实样本可仿）
  2. 按修订后的 L3 prompt **逐字** spawn 一次 reviewer；prompt 已含"报告末尾附 '## 执行证据' 段，逐条列实际运行的命令与其原始输出（前 10 行）"
  3. 报告存 `.tad/evidence/acceptance-tests/lite-review-hardening/ac8-probe-report.md`
  4. PASS 当且仅当：(a) '## 执行证据' 段含 ≥1 条对玩具缺陷文件实际运行的命令及原始输出；(b) 报告抓到该玩具缺陷；(c) 每条 finding 带"执行实证/阅读推断"标注；(d) 报告首行含 reviewer 自报 model 身份。任一不满足 = FAIL
- AC9 reviewer model 载体落位（R1 CR-P1-6 + R3，baseline 均 0）：alex-lite 模板行 `grep -c 'Reviewer: {待填} | model='` ≥ 1；blake-lite Completion 模板 Reviewer 行 `grep -c 'model={reviewer 自报'` ≥ 1；**L2.5 prompt 自报指令**：`awk '/^### \*\*L2\.5/,/^### \*\*L3 —/' $A | grep -c '自报'` ≥ 1（R3——缺这句则 alex 侧 model= 字段永远填不出而 AC 全绿）。均镜像同验 via AC4

## 5. 风险与注意

- 本单改 lite 协议契约面 → full 通道 express 载体；≥2 专家已审（见 §6）
- **AC2 的 awk 锚点依落位而定**——§3.2 说"L3 段之后"即新小节，Blake 落位后必须用实际相邻标题定区间并在 Completion 记录实测命令；禁止退回全文件 grep（那正是 CR-P0-3 实证骗过的形态）
- AC8 是唯一行为验收，玩具缺陷必须是"执行探针可抓、纯阅读易漏"类
- 4 镜像成对逐字节；哨兵零字节；角色分离禁令零变更是本单红线（v2 的定性就是"不动禁令"）
- verify-state-flow.sh 若行号漂移，一切锚定按内容

## 6. Expert Review — Audit Trail（2026-08-03，2 reviewers，R1）

| Reviewer | Issue | Resolution | Status |
|---|---|---|---|
| config-manager | P0 §3.3 与 alex-lite Forbidden spawn 限制冲突 | **被 CR-P0-2 方案 b 上位解决**：§3.3 降级为消歧协议、不再要求执行后 spawn → Forbidden 无需修订，v1 的"配套修订+AC3b"撤销 | ✅ Superseded |
| config-manager | P1 AC3 基数错误（alex-lite baseline 实测 2 非 1） | AC 前置改为实测记录制 | ✅ Fixed |
| config-manager | P1 AC2 漏验 alex-lite 侧 REVIEWER-TIER-DEGRADED | AC2 双侧 + section-scoped | ✅ Fixed |
| config-manager | P2 探针条款不对称未说明 | §3.2 末尾设计说明 | ✅ Fixed |
| config-manager | P2 三处逐字记录格式漂移风险 | §3.3 格式统一注（以 escalated_review 为准） | ✅ Fixed |
| code-reviewer | P0-1 §3.2 判据用 execution_depth 在 alex 侧不可判定 | 改 route_level（SSOT 单调推导双侧可读）+ AC2 回归防护 | ✅ Fixed |
| code-reviewer | P0-2 §3.3 与三处未修订绝对禁令矛盾（精髓#1/L231/CLAUDE.md §4） | **采方案 b**：§3.3 重写为消歧与记录协议，不造许可路径；Non-goals 明记；AC3 增加"禁令零变更"断言。同时修正 v1 的错误前提（三先例中仅一次真跨角色且已被裁定下不为例） | ✅ Fixed |
| code-reviewer | P0-3 AC1-3 placement-blind（实证：一行文本追加骗过全部） | AC1/2/3 全部 section-scoped（采纳其预验证命令）+ §5 红线 | ✅ Fixed |
| code-reviewer | P1-4 AC3 基数（同 CFG P1-1） | 同上 | ✅ Fixed |
| code-reviewer | P1-5 AC8 不可执行（git 树/transcript 不可得/PASS 未定义） | git init + '## 执行证据' 段自报制 + 二值 PASS 判据 + 具名证据路径 | ✅ Fixed |
| code-reviewer | P1-6 reviewer model 身份无载体无 AC | §3.2 配套模板修订 + prompt 自报指令 + AC9 | ✅ Fixed |
| code-reviewer | P1-7 强档未定义 | §3.2 强档 = opus/fable 级，haiku/小型 flash 不构成 | ✅ Fixed |
| code-reviewer | P2-8 评级纪律无 AC | AC1 增加 执行实证/阅读推断 锚点 | ✅ Fixed |
| code-reviewer | P2-9 AC6 行号锚定与 §5 矛盾 | 改内容锚定 grep -A3 | ✅ Fixed |
| code-reviewer | P2-10 frontmatter e2e/git_tracked_dirs 失实 | e2e_required: yes + git_tracked_dirs 填实 | ✅ Fixed |
| code-reviewer | P2-11 记录格式写两处会漂移 | §3.3 统一注 + §3.2b 引用制 | ✅ Fixed |

双方对 §3.4（verifier 补 field）独立执行验证均 PASS+突变 FAIL——本项零 finding。

### 增量轮（R2，2026-08-03）

| Reviewer | Verdict | Findings | Resolution |
|---|---|---|---|
| config-manager | 确认 P0 supersession 正确（"resolved, not relabeled"），对 v2 无新阻塞项；1 个格式脚注 nit | nit | ✅ 统一注改为字段型/标记型双形态 |
| code-reviewer | 原 3 P0 确认关闭；**新 R1 [P0]**：AC3 的 grep -cE 多词计数按行计——正确实现只得 2/4，会假 FAIL（实证）；R2 [P1] AC2 awk 区间仍留 operator 选择；R3 [P1] L2.5 自报指令无 AC；R4-R6 [P2] ugrep `-e` 陷阱 / 设计期 route_level 上限说明 / clause 3 载体 | R1-R6 | ✅ 全部采纳其预执行命令：AC3 per-term 循环、AC2 自带标题+位置断言、AC9 补 L2.5 自报、零变更断言 `grep -Fxq -e` 命令化、§3.2 上限说明、§3.3 载体 fallback |

code-reviewer 增量结论（原文）："Fix R1, R2, R3 … and my incremental verdict flips to **PASS** without needing another round"——三项修复均逐字采纳其预执行验证过的命令，据此记 R2 verdict = PASS（pre-committed）。
