---
task_id: TASK-20260805-P1a-fix
handoff: .tad/active/handoffs/HANDOFF-20260805-pricing-gate-scan-fix.md
base_commit: 4b29dc263a5368c0b598fc1030f465fc7ebdbc10
gate3_verdict:
---

# Completion — pricing-gate-scan-fix (2026-08-05)

**Epic**: EPIC-20260804-lite-as-tad-body — Phase 1a-fix（P1b 前置阻塞单）
**实现前判别力自检**（§5 要求，结果记入本报告）：
- AC1 实现前 **20 条 FAIL**（每文件 10 × 2）→ 判别力成立
- AC4a 旧命令对照留证：BASE 版旧命令命中集 {A1,A2,**A5**,A6,B1,B2,B3,A7}（含摘要假阳性 A5、多列误判 A6、非补零静默漏 A8）vs 新命令 {A1,A2,A6,A8,B1,B2,B3,A7}（A5 静默、A8/B1/B2/B3 显式 MALFORMED）——**命中集语义显著不同，判别力成立**
- AC6 实现前 2 FAIL（前言未同步 + 旧前言残留）；AC9 实现前 2 FAIL（AGENTS-MISSING ×2）
- AC2/AC3/AC4a/b/AC5/AC7/AC8 实现前 PASS 属设计（§5 注释：AC2 为否定断言无判别力；AC4/AC5 内联规格命令，判别力由 AC1 钉死落地文本 + 旧命令对照提供）

**改动文件**（改动 1-6 两 skill 逐字节相同 + 台账前言）：
- `.claude/skills/alex-lite/SKILL.md`（约束准入节内 5 处：RETIRED 文案 / 扫描命令块整块替换 / 备注列措辞+列序不变量 / append-only 条款 / 静默续期禁令）
- `.claude/skills/blake-lite/SKILL.md`（同 5 处，逐字节相同）
- `.tad/evidence/audits/lite-constraint-ledger.md`（前言 1 行：append-only 新约定）
- `.agents/skills/{alex,blake}-lite/SKILL.md`（parity --fix 镜像，FIX-PASS → parity PASS，未手改）
- AC 产物：`.tad/evidence/acceptance-tests/pricing-gate-scan-fix/`（快照/脚本/探针/留证）
- KA journal：`.tad/evidence/journal/pricing-gate-scan-fix-2026-08-05.md`

**AC 结果**（post-impl-check.sh 实跑，原始输出见 post-impl-output.txt）：
- AC1 ✅ 落地命令整行逐字（5 条 grep -Fxq + 4 短语 + 旧残留 2 项全清）
- AC2 ✅ 节外内容与 BASE strip 后 cmp 逐字节相同（ok=2 自证）
- AC3 ✅ 两节逐字节相同（5085 字节）且均在 ## Forbidden 前
- AC4a ✅ 八场景输出与期望逐字节一致（OVERDUE=A1/A2/A7 + MALFORMED=A6/A8/B1/B2/B3）
- AC4b ✅ 僵旗消除（n=0；处置行保留"原 review-by"字样不重命中）
- AC5 ✅ 正向对照（base=0 → 追加真超期 n=1）
- AC6 ✅ 表格 0 数据行 + 新前言在位 + 旧前言清除
- AC7 ✅（1 条命中已归因，见下）tracked 围栏：`.tad/research-notebooks/REGISTRY.yaml`
- AC8 ✅ untracked 围栏 0 命中
- AC9 ✅ .agents/ 镜像含新命令 + cmp 一致 + parity PASS (exit 0)
- 围栏双向自测 ✅（fence-output.txt）：负向探针被 AC8 抓获 / 正向 git add 授权集后静默 / unstage 回滚

**AC7 命中归因（P1-1 处置）**：`.tad/research-notebooks/REGISTRY.yaml`（tracked，BASE 中存在）在 §5.0 快照后 ~40 分钟被**外部修改**（1 行：`status: active → dormant`，mtime 12:19；git log 末次提交 30db1bf 2026-08-02 早于本单；内容为研究笔记本休眠化，与本单文件域无关）。判定：**非本单实现引入**（apply-changes.py 目标硬编码 3 文件、无触碰能力），围栏 fail-loud 按设计工作。**未** git checkout 还原（§6.6：与本单无关的仓库既有未提交项不得代为清理——该修改可能是用户侧 *research-notebook 有意操作，留 Gate 4 由用户确认）。

**⚠️ §2.2 显式承认（DoD 强制）**：本单的「状态列就地转移（仅限终态）」修好了僵旗，但**清除了一项旧副作用**：旧 bug 让已处置的行持续被报 OVERDUE——噪音，但也是"这行还没交代清楚"的持续可见信号。修复后该信号消失：任何一次就地转移都会让该行永久静默退出扫描视野，**扫描侧无法区分"诚实处置"与"图省事转个状态"**。真正拦这个的只有纯文本的「反合理化（复查侧）」，其强度新旧约定完全一样（都零机械校验）——本单未新增洗白漏洞，但**第一次让"跳过配套处置行"零残留信号**。无 AC 校验"转移必须配套追加行"（§7 DoD 承认）。此为有意取舍：机械校验处置配套需要状态机，超出本单"不新增约束"边界。

**⚠️ P1-2 残差记录（用户 2026-08-05 裁定：条件放行进 Gate 3）**：code-reviewer 执行实证发现新 awk 命令对**补零但非法日期**（如 `2027-13-99` / `2026-00-15`）静默漏报——主正则 `[0-9]{4}-[0-9]{2}-[0-9]{2}` 只验形状不验月份/日范围：词法上"未来"的非法值（13 月/00 日）永不触发（静默漏，违反自称 fail-safe），词法上"过去"的非法值误报 OVERDUE。修法需改命令文本（月份 `(0[1-9]|1[0-2])`、日 `(0[1-9]|[12][0-9]|3[01])` 校验）——AC1 冻结命令 + §1.3 禁新增约束 → **转 P1b/后续修订单**。实现与规格逐字节一致（spec-compliance PASS 证实），Blake 无权改规格。触发面 = 未来有人写非法日期进状态列；当前台账 0 数据行不可触发。

**Layer 2**（layer2-audit DISTINCT_COUNT=2 达标，均为 alias-mapped 会话，未指定 model 覆盖——延续用户 2026-08-05 决定，档位以 reviewer 实际自报为准）：
- spec-compliance-reviewer：**PASS**（AC1-AC9 全过；§4 规格块 vs 落地节 byte-diff **零差异**（连尾部空行逐字节一致）；旧特征 6 项全清除；改动 5 旧块为新块前缀属设计使然已证）。Model 自报：claude-code/deepseek-v4-flash/l2g0-spec-compliance-reviewer
- code-reviewer：**CONDITIONAL**（0 P0 / 2 P1 / 3 P2，全部执行实证；16 条边界探针 + 跨年边界直测 + AC 判别力复核）。Model 自报：deepseek-v4-flash
- P2 三项（建议性，follow-up）：P2-1 前置过滤 token `[Pp]rovisional` 对摘要列英文词碰撞（噪音非静默，概率低，建议后续单锚定行尾）；P2-2 台账前言缺"禁止静默续期/不要重复 PROVISIONAL 字样"两条（处置者看台账拿不到反续期禁令——建议后续单补一句）；P2-3 AC4a 覆盖外残差建议注释显式枚举边界。

**Knowledge Assessment**: journal captured → `.tad/evidence/journal/pricing-gate-scan-fix-2026-08-05.md`（3 条：分类器窗口轮询模式 / tracked 围栏对快照后外部修改的敏感性 / 判别力"语义不同"形态）

**意外发现**: 无

**follow-up**（非阻塞）：
- P1-2（非法日期静默漏）→ 现象/证据：code-reviewer 探针 P8/P9（/tmp/probe-edge.md）| 为什么不阻塞：触发面=未来手滑写非法日期，当前台账 0 数据行；用户已裁定条件放行 | 建议 owner：P1b 修订单（改 §4 命令加月份/日校验）
- P2-1（前置过滤 token 碰撞）→ 现象/证据：探针 P14 | 噪音非静默，概率低 | 建议 owner：后续单
- P2-2（台账前言缺反续期禁令）→ 现象/证据：ledger L5 | 实操落地一半 | 建议 owner：后续单补一句
- P2-3（AC 注释边界枚举）→ 建议 owner：后续单

## ⚠️ Friction Status

| 摩擦点 | 状态 | 处置 / 证据 |
|---|---|---|
| 写操作分类器（deepseek-v4-flash）持续间歇不可用 ~1.5h | READY（未降级） | 窗口轮询（后台 sleep + 合并大 Edit）+ 只读验证穿插；全部必需步骤完成，无跳过、无降级、无自审替代。窗口开时每次 1 操作：alex-lite Write / ledger Edit / blake-lite Edit×2 / parity --fix / AC 全跑 / 围栏自测 / journal / reviewer spawn×2 均完成。期间无 BLOCKED 行 |
| 无其他摩擦 | READY | — |

## Model

- writer=blake | harness=claude-code | model=deepseek-v4-flash（运行时自报）| route=alias-mapped（DeepSeek 中转；本单未切模型）
- Layer 2 reviewer 自报模型见上（均 deepseek-v4-flash，档位以自报为准）

## 本 phase token

- Layer 2 subagent 实测：code-reviewer 89,999（subagent usage 字段）；spec-compliance reviewer 通知未附 usage（估算 ~80-90K）
- 主会话估算 ~120-150K（含分类器故障期间的等待/重试/验证往返，无法精确测量）
