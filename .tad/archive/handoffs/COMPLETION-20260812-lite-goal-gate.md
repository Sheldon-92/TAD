# Completion: Epic Objective 闸（Phase 2）

- **Handoff**: `.tad/active/handoffs/HANDOFF-20260812-lite-goal-gate.md`（rev2）
- **Epic**: `EPIC-20260812-discipline-weight-separation.md`（Phase 2 / 6）
- **Gate 3**: PASS（V0–V10 全绿；六份 fixture 双向判别成立）
- **Git Commit**: uncommitted（本单无 commit 授权；§3.2 只允许只读 git 子命令）
- **流程深度**: Standard TAD

## 1. 交付物清单

| 文件 | 说明 |
|---|---|
| `.claude/skills/alex-lite/SKILL.md` | 纯增行：插入「Epic Objective 闸」节 + Forbidden 节 `.tad/active/epics/` 处追加 §4.2 一行 |
| `.claude/skills/blake-lite/SKILL.md` | 纯增行：L0.5 追加 Epic 载体检查 + §4.4 代码块 |
| `.agents/skills/alex-lite/SKILL.md` | 镜像（cp，parity 逐字相同） |
| `.agents/skills/blake-lite/SKILL.md` | 镜像（cp，parity 逐字相同） |
| `.tad/evidence/acceptance-tests/lite-goal-gate/` | fence-baseline/now.txt、status-pre/post.txt、fixtures/（6 份）、epic-20260809-t0.txt |

## 2. AC 结果

| AC | 验证 | 结果 |
|---|---|---|
| AC1 六份 fixture 双向判别 | good-mid/good-last exit 0；bad-no-null(null=0)/bad-two-null(null=2)/bad-letter-oob(inset=0)/bad-no-quote(quote=0) exit 1 | PASS |
| AC2 alex-lite L17-19 锚点逐字未变 | V3 grep -Fxq | PASS |
| AC3 五条选项规则 + 不覆盖声明在文 | V2 check_new（6 串，T=0 计数=0） | PASS |
| AC4 blake-lite L0.5 新检查在文 | V2 check_new（2 串，T=0 计数=0） | PASS |
| AC5 parity | V1 cmp -s ×2 | PASS |
| AC6 ESCALATION 闭集未改 | V4（基线区间 ≥3 行 + 逐字相同） | PASS |
| AC7 full 未被碰 | V6 diff --name-only = 0 | PASS |
| AC8 围栏（增量式） | V5 comm -13 行数=0 | PASS |
| AC9b 零删除 | V7 deleted=0 且 added>0 | PASS |
| AC10 契约未改（T0= 行除外） | V8 diff | PASS |
| AC14 subagent 未写文件 | V9 cmp status-pre == status-post | PASS |
| AC15 回放已标注非因果 | V10 grep | PASS |

## 3. Step 0 基线门

- T0 = `51ceeda`（Alex 建立并回填，V0 rev-parse 验证通过）
- fence-baseline.txt 冻结：当前 `{git diff --name-only $T0} ∪ {ls-files --others}` 并集，共 **944 行**（含 §0.1 声明的预存状态：`.claude/settings.local.json.bak-20260806-082549`、dependency-ops txn-lock、932 个 codex spike 中间产物、以及本单 fence 文件本身）
- 收工时 fence-now.txt 相对 fence-baseline 的新增（comm -13），减去 ALLOW（4 SKILL + lite-goal-gate/ + COMPLETION + lite-discoveries）与 HOOK（traces/decisions）后为空。

## 4. Step 2 六份 fixture 双向验证

| fixture | exit | 报错 |
|---|---|---|
| good-mid | 0 | — |
| good-last | 0 | — |
| bad-no-null | 1 | `null=0` ✓ |
| bad-two-null | 1 | `null=2` ✓ |
| bad-letter-oob | 1 | `inset=0` ✓ |
| bad-no-quote | 1 | `quote=0` ✓ |

§4.4 命令逐字复制（从代码块复制，未改；`bash -n` 语法验证通过）。2 good → exit 0，4 bad → exit 1 且各自在正确字段上失败。

## 5. Step 3 回放（⚠️ 单次采样，不构成因果证据）

- 输入：改过的「Epic Objective 闸」全文 + 已存在 Epic 摘要（Objective=「让 lite 替换 full」）+ 用户原话（逐字取自 `EPIC-20260809-full-capability-extraction-retirement.md` L593-594）。
- 四层隔离：prompt 首行逐字（待评估样本声明）、禁写工具声明、定界符包裹、spawn 前后 status 快照 diff=0（AC14）。
- **结果：subagent 判断「不触发」**。理由：已存在 Epic「让 lite 替换 full」，其 Objective 与用户原话指向一致，状态"进行中接近完成"，用户的话被读成"对现有 Epic 的继续推进/探索"，不满足「创建新 Epic」或「实质改变 Objective」任一触发条件。
- 选项数：0；`[无工作项]`：无（未触发）。

> ⚠️ **本回放是单次采样，不构成因果证据**（§6.2 / AC15）。且结果本身印证 §9 第 3 条已知缺口：闸挂在「创建/实质改变 Epic 时」，而事故发生在「Epic 已写完 Objective 之后、用户中途纠正」——这种中途纠正不在本闸的触发面内。因果效力未证，记入 §7。

## 6. Friction Status

| 项 | 状态 |
|---|---|
| T=0 锚 | READY（Alex 建立 51ceeda，回填契约） |
| 4 个 SKILL 写权限 | READY（§3.2 allow-list 内） |
| fixture 命令可执行性 | READY（§4.4 命令逐字，bash -n 通过） |
| 回放 subagent | READY（fresh general subagent，禁 fork，未写文件） |

无 BLOCKED 行。

## 7. §9 已知取舍与未证事项（逐条如实记录）

1. **因果效力未证**：§6.2 只跑一次、不作 AC 通过条件。本单买的是「载体存在且机械可查」，没买「行为确实改变」。
2. 选项公正性无机械载体：闸强制 disclosure 的格式，管不了 disclosure 的公正性（"我想做的 + 两个稻草人"格式合规）。唯一防线是 L2.5 独立契约审查的人工判断。
3. 闸只在 Epic 层触发：不经 Epic 的一次性推进、以及执行中途冒出的目标漂移，本闸不覆盖。**本单回放（§5）实测印证了这条**。
4. 新增 2 处 BLOCKING 未走「约束准入」台账：台账归 Alex-Lite 管辖，full 通道 Blake 不代写。已知缺口，交后续 lite 单补。
5. Q4 防锚定步骤未完成。

## 8. Knowledge Assessment

- Q1 发现：有——回放结果（闸在"上下文动量"下仍被读成"继续推进"，印证 §9 第 3 条缺口）值得记入 journal。
- Q2 可复用模式：否（单次实现，无新工作模式）。
- Q3 workflow 模式：否。

## 9. Reflexion History

无 reflexion（Layer 1 一次通过，未触发修复循环）。
