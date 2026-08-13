# Completion: 摸清需求 —— 不管哪个模式都要做（Phase 2b）

- **Handoff**: `.tad/active/handoffs/HANDOFF-20260812-requirement-first.md`（rev3）
- **Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 2b / 6）
- **Gate 3**: PASS（V1–V13 全绿；AC5 deleted=5，AC13 冻结补集通过）
- **Git Commit**: uncommitted（本单无 commit 授权；§5.1 只允许只读 git 子命令）
- **流程深度**: Standard TAD

## 1. 交付物清单

| 文件 | 说明 |
|---|---|
| `CLAUDE.md` | R1：L49 路由行替换（OLDC_LINE → NEWC_LINE，`通道由人裁定`） |
| `.claude/skills/alex-lite/SKILL.md` | R2（OLDS→NEWS1+NEWS2）+ L1a 目标题节（GOALQ-L1A 哨兵包裹） |
| `.claude/skills/blake-lite/SKILL.md` | R3（OLDS→NEWS1+NEWS2）+ L0.5 目标题检查（GOALQ-CHECK 哨兵包裹，含代码块） |
| `.agents/skills/alex-lite/SKILL.md` | 镜像（cp，parity 逐字相同） |
| `.agents/skills/blake-lite/SKILL.md` | 镜像（cp，parity 逐字相同） |
| `.tad/evidence/acceptance-tests/requirement-first/` | fence-baseline/now.txt、contract.sha256、goal-check.sh、fixtures/（6 份）、verify.sh |

## 2. AC 结果

| AC | 验证 | 结果 |
|---|---|---|
| AC1 五处逐行替换 | V1（OLDC_LINE/OLDS=0；通道由人裁定 5 文件各=1；NEWS1 整行=1） | PASS |
| AC2 协议密度=0、文件数≥1 | V2 | PASS |
| AC13 冻结补集（含纯增行） | V13（CLAUDE.md 补集 + 4 SKILL 哨兵块外补集） | PASS |
| AC3 目标题检查判别力 | V3（2 good exit0；4 bad exit1 且点名 null=0/null=2/inset=0/wrong=1；blake-lite 承重要素≥1） | PASS |
| AC4 L1a 六条条款 | V4（L1a 节切片 + T=0 侧 0 行防永真） | PASS |
| AC5 删除预算 | V5 deleted=5（钉死表旧文行数） | PASS |
| AC6 parity | V6 cmp ×2 | PASS |
| AC7 ESCALATION 闭集未改 | V7 | PASS |
| AC8 L17-19 锚未变 | V8 grep -Fxq | PASS |
| AC9 上一单 Epic 闸未改 | V9 | PASS |
| AC10 full 未碰 | V10 | PASS |
| AC11 围栏（增量式 + 基线无高权限脏路径） | V11 + Step 0 V11b | PASS |
| AC12 契约 sha256 未变 | V12（Step 0 冻结） | PASS |

## 3. Step 0 基线

- T0 = `d225585`（rev-parse 验证通过）
- contract.sha256 = `b7eb0afe…e94bc64`（Step 0 冻结，AC12 复验一致）
- fence-baseline.txt = **839 行**；**高权限脏路径断言通过**（基线无 CLAUDE.md/.claude/(agents|workflows)/settings/.tad/(project-knowledge|hooks|logs)/full skills 等）
- goal-check.sh：§6.3 代码块逐字落盘 + 首行 `f="$1"`（bash -n 通过；blake-lite SKILL 内代码块同样 bash -n 通过）
- 6 份 fixture：good-mid/good-last/bad-no-null/bad-two-null/bad-letter-oob/bad-chose-null

## 4. 关键实现说明

- **路由规则 5 处**：`通道由人裁定` 在 5 个文件各恰好 1 次（CLAUDE.md 与 4 个 lite SKILL），措辞统一（Gate 2 P0-2 修复）。
- **`修改框架自身` 范围**：含 CLAUDE.md、`.claude/` 与 `.agents/` 下 skills/agents、hooks、settings、`.tad/project-knowledge/`、`.gitignore`、`AGENTS.md`、`tad.sh`，非穷举按命中处理（Gate 2 P1-2 修复）。
- **L1a 目标题**：加在 alex-lite L1 之后、L1.5 之前，GOALQ-L1A 哨兵包裹；含 `## 目标题` 段格式 + `通道:` 载体行说明；末尾声明「与真人决策点只有三类的关系：第一类组成部分，不构成第四类」（Gate 2 P1-3，不动 L17-19 一个字）。
- **blake-lite L0.5 目标题检查**：GOALQ-CHECK 哨兵包裹（含代码块），机械验证 `## 目标题` 段（opts≥2/null=1/pick=1/chan=1/inset=1/wrong=0），选中「不是这个意思」→ wrong=1 FAIL。
- **实现中修复一处结构问题**：初版把 blake-lite 目标题检查代码块放在 GOALQ-CHECK 哨兵块外，V13（冻结补集只豁免哨兵块内）FAIL；已将代码块移入哨兵块内，V13 通过。alex-lite L1a 块后的多余空行也已消除（V13 补集要求行级逐字相等）。

## 5. Friction Status

| 项 | 状态 |
|---|---|
| T0 锚 | READY（d225585） |
| 5 文件写权限 | READY（§5.1 allow-list 内） |
| goal-check.sh 可执行性 | READY（§6.3 逐字，bash -n 通过） |
| 高权限基线断言 | READY（Step 0 通过） |

无 BLOCKED 行。

## 6. §9 已知取舍

1. 每单一问可能退化（闭眼选 A）——减缓：明确单只列 2 选项；长期是否退化本单无法证明。
2. 选项公正性无机械载体（"我想做的 + 稻草人"格式合规）——唯一防线是独立契约审查。
3. 因果效力未证——本单不做行为回放实验（≈16 次 agent 调用与 credit 约束冲突），明写没买。
4. 新增 BLOCKING 未走「约束准入」台账——台账归 alex-lite 管辖，连同上一单欠的 2 处，交后续 lite 单一并补。

## 7. Knowledge Assessment

- Q1 发现：有——本单实现中暴露「哨兵块豁免边界」的教训（冻结补集只豁免哨兵块内行，代码块须入哨兵块）值得记入 journal。
- Q2 可复用模式：否。
- Q3 workflow 模式：否。

## 8. Reflexion History

无 reflexion（Layer 1 一次通过，未触发修复循环）。
