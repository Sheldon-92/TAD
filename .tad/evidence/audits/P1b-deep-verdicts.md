# P1b-2 判定结果：7 条 DEEP 约束的载体核验

**日期**: 2026-08-05
**执行者**: Alex（设计侧搜读）+ 人（逐条拍板）
**Epic**: `EPIC-20260804-lite-as-tad-body` Phase 1b-2
**为什么不由 Blake 做**: 见 §4「拆单理由」

---

## 1. 判定（人已拍板）

| # | 键 | 判定 | 载体 | 归谁砍 |
|---|---|---|---|---|
| D1 | `alex-lite\|Route Contract（Lite / Standard / Full 三层路由）` | **NO-CARRIER** | — | P2 |
| D2 | `blake-lite\|Route Contract（Lite / Standard / Full 三层路由）` | **NO-CARRIER** | — | P2 |
| D3 | `alex-lite\|执行脊柱内「escalated_review 授权规则 + 额度出口」` | **NO-CARRIER** | — | P2 |
| D4 | `blake-lite\|L0 内「升级清单 1-3 类转 full 分支」` | **NO-CARRIER** | — | P2 |
| D5 | `alex-lite\|### Reviewer 档位规则` | **SUPERSEDED** | `.tad/evidence/research/2026-08-02-model-diversity-audit-results.md` | P3 |
| D6 | `blake-lite\|### Reviewer 档位规则` | **SUPERSEDED** | 同上 | P3 |
| D7 | `blake-lite\|L4 内「Model 行捕获纪律」` | **NO-CARRIER** | — | P3（降级为一行） |

**附带判定**（D7 拆分的另一半，落在 LIGHT 行上）：

| 键 | 判定 | 载体 |
|---|---|---|
| `blake-lite\|L4 Completion（append 到 LITE handoff 文件末尾）` | **HAS-CARRIER** | `.tad/evidence/research/2026-08-02-multi-model-portability-verification.md`（第 4 条「证据链缺口」） |

砍除名单 = **5 条 NO-CARRIER**（D1–D4、D7）+ **2 条 SUPERSEDED**（D5/D6，知情退场）。

---

## 2. 逐条证据

### D1 / D2 — Route Contract R0–R3 → NO-CARRIER

- 事故区（`journal/` `logs/` `reviews/` `project-knowledge/` `research/`）**零命中**，关键词
  `blocked_missing_contract` / `blocked_stale_revision` / `RouteDecision`
- 条文**自身不声称任何事故依据**（两 skill 全文 `依据|教训|实测|违规|盲区|事故` 共 6 处，无一属于本节）
- 起源单 `HANDOFF-20260801-lite-standard-routing-full.md` 给的是**设计理由**：
  > 真正要解决的问题：不是再造 Alex-Medium/Blake-Medium，而是把"治理风险"和"工作深度"
  > 拆成两个可路由维度
- 同期 journal `lite-standard-routing-2026-08-01.md` 5 条全是**实现摩擦**
  （sentinel 时序、`git ls-files | grep -q` 的 SIGPIPE 竞态、字面锚语言漂移），**无一条路由失败**

**最强反方**：起源单 §128–137 列了 4 个"问题"，可能被读成事故。逐条查证后否定——
那 4 条是**其它约束**的依据（slimming 移除 MUST 导致质量链失效 = 已在 principles.md 有条目；
grep 只证结构不证行为 = 行为验证的依据），**不是路由机器的**。

### D3 — escalated_review + 额度出口 → NO-CARRIER

- 条文无自称依据；事故区零命中
- COMPLETION 命中 2 处（`COMPLETION-20260730-tad-lite-channel.md` / `-lite-v11-quality-amendments.md`）
  经查为 **AC 计数记录**（`AC5 ✅ escalated_review: 6,6`、`AC9 ✅ NOT_via_suggestion FOUND`），
  即"这条约束被实现了"，不是"缺了它出过事"

**最强反方**：`NOT_via_suggestion` 与「跨角色请求消歧」共享反合理化机制，而后者**确有载体**
（2026-08-02 违规，`.tad/logs/violations.log` 第 2 条）。但该违规是 **Alex 越界写代码**，
与 escalated_review（用户坚持用 lite 处理高风险改动）是不同failure mode。载体不可转移。

### D4 — 升级清单 1–3 类转 full 分支 → NO-CARRIER

- 条文无自称依据；`ESCALATION-LIST-BEGIN` / `升级清单` 事故区零命中
- **存在反向证据**：本 Epic 的 Trigger 即用户 2026-08-04 原话「我经常会被拦着，非要我走 full」
  —— 这条约束造成的成本有记录，它挡住的失败没有

### D5 / D6 — Reviewer 档位规则 → SUPERSEDED（**不是 NO-CARRIER**）

**载体真实存在**：`.tad/evidence/research/2026-08-02-model-diversity-audit-results.md`
> 标题：flash 审 flash 的盲区实测
> 结果：只读审查 GATE PASS vs 执行探针盲审 **FAIL P0×1 + P1×6**
> 结论：flash 审 flash 有真实且系统性的盲区——抓得住记账/表层缺陷，
> 抓不住需要对抗性压力推演的系统性缺陷。最刺眼的是：诚实契约主题的单，
> 漏掉了 announce=ok 的诚实性缺陷。

**为何仍退场**：用户 2026-08-04 裁定「因为我们要兼容各种模型和 harness 工具，
不用非要调用强档」。这是**知情取舍**，不是"当初就没道理"。

**用户 2026-08-05 复核确认状态为 SUPERSEDED**，理由：台账须让六个月后的人区分
「有事故依据但被裁定退场」与「从来没有依据」。

⚠️ **Alex 2026-08-04 初判把这条写成 P3 砍除对象且未标载体——判错。**
P3 照砍，但台账必须记 SUPERSEDED 且填载体路径。

### D7 — Model 行捕获纪律 → NO-CARRIER（但载体支撑它的**降级版**）

载体 `2026-08-02-multi-model-portability-verification.md` 第 4 条：
> **证据链缺口**：智能家居部分单实际由 DeepSeek 执行（用户口述），但
> handoff/Completion/RouteDecision 均未记录执行模型身份 → 无法回溯做模型×质量归因。
> **建议：Completion 与 RouteDecision 增加 `Model:` 字段**（harness + model + 路由方式），
> **成本一行**，是 harness×模型实测矩阵的数据基础。

**关键区分**：载体明写「成本一行」，支撑的是 **`Model:` 字段本身**（记在 L4 Completion 行，
判 HAS-CARRIER）。现行的 **25 行纪律 + 8 条 shell 命令**是后来长出来的，**无载体**。
P3 计划的「降级为一行自报」与载体方向一致——载体站在降级这边。

**反向证据（2026-08-05 当日新增）**：Gate 2 的一名 reviewer 为遵守 Model 行纪律
去 `env` 中 grep `ANTHROPIC/OPENAI/CLAUDE_CODE` 变量，触发凭据外泄告警
（脱敏逻辑只过滤变量名含字面 `KEY` 的项，真实 key 值不被遮蔽）。
原始纪律只 grep `ANTHROPIC_(BASE_URL|MODEL|SMALL_FAST_MODEL)` 是安全的，
但 agent 照其精神放宽范围即越界。**这条纪律本身诱导了一次安全事件。**

---

## 3. 方法记录（本节比结论更重要）

**关键词 grep 全军覆没，追自称出处一击命中。**

第一轮用 7 组关键词搜 5 个事故区目录 → **7 条全部零命中**。若就此结案，D5/D6 会被误判为
NO-CARRIER。原因：那份 flash 盲区研究文件**通篇没有出现「强档」二字**——它描述实验，不用约束的术语。

**这正是 R2 两名 reviewer 演示过的窄关键词失效，Alex 自己走了进去。**

救回的方法：`grep -nE '依据|教训|实测|违规|盲区|事故|20[0-9]{2}-[0-9]{2}-[0-9]{2}'` 扫两个 skill 全文，
命中仅 6 处，逐一追溯。**有载体的约束会在自己条文里写出依据；没载体的不写。**

→ **可复用规律**：审计"这条规则当初为什么加"时，先读规则**自己声称的出处**，
再用关键词补搜。反过来（先关键词后出处）会在术语不匹配时漏掉真载体，
而术语不匹配恰恰是常态——事故记录用事故的语言写，约束用约束的语言写。

---

## 4. 拆单理由（P1b 为何不整单交 Blake）

原 P1b 契约两轮 Gate 2 均 FAIL（v1 十一类 P0 / v2 四 P0 + 八 P1），
两名对抗 reviewer **各自构造出完整全绿伪造交付**，且 v2 的伪造成本比 v1 更低（30 分钟 → 15 分钟）。

三个根因：

1. **委托代理**：Blake 既是被审者，又掌握全部验证机制（他 spawn reviewer、写 prompt、
   决定留不留痕）。任何他能控制的验证都能被他绕过。
2. **规模不可行**：按契约要求逐个打开非自引用命中文件 = **74 个文件、965,811 字节、约 24 万 token**，
   单 session 装不下。诚实的 Blake 也做不完。
3. **判断不可 grep**：与 P1a 已记录的教训同源——"把判断塞进 grep，会持续长新洞，补一个长一个"。

处置：判断层移出 Blake，由 Alex 搜读 + 人拍板（本文件）；机械层留给 Blake（P1b-1）。

---

## 5. 溢出发现（不属于 P1b，已记入 Epic Known Issues）

`2026-08-02-multi-model-portability-verification.md`：

> **reviewer spawn 是 DeepSeek 的已证失效点**：TAD lite 的唯一/双防线依赖执行模型主动 spawn
> 独立 reviewer（L2.5/L3）。DeepSeek 有"planner 从不调 subagent"的公开实测先例。
> 弱模型跑 Blake 时，"禁止自审替代"的 prompt 级禁令可能**静默失效**。

同文件坐实：**2026-08-02 一张 LITE 单 401 轮，100% 跑在 deepseek-v4-flash 上。**

**为什么这条要紧**：2026-08-05 两名 Gate 2 reviewer 各自独立得出同一结论——
lite 的唯一真防线是独立 reviewer。若该防线在用户主力模型上会静默失效，
则 lite 的质量基础不是"仪式轻但防线在"，而是"防线可能从未起过作用"。

**用户 2026-08-05 裁定**：记进 Epic Known Issues，**P4 端到端实测时顺带验证**
（查 Completion 里 reviewer 行是否真有独立产出），不打断当前节奏。
