# Next Steps

> **本文件只放"还没做的"。** 已完成条目一律迁进
> `.tad/archive/next/NEXT-completed-through-YYYYMMDD.md`（逐字保留，可回查）。
> 规矩：**动手前先验一遍条目是否还成立**——2026-08-14 清账时发现
> ②a/②d/②e 三条标着「最高优先级」的待办**早已修复**，清单挂了两周没人划掉，
> 照它找活等于被误导。**清单不准 = 清单有害。**

**当前版本**：2.42.0 ｜ **默认通道**：full（`/alex` `/blake` `/gate`）｜ lite 🧊 冻结于 2026-08-13

---

## 🔴 优先队列（一个一个做，不并行）

### 1. 纪律可达性修复单（**有真实风险，排第一**）

TAD 自己的四笔账，源自 `EPIC-20260813-alex-blake-lightening` 收口。前两条是同一个病：**约束够不着 agent**。

- [x] **✅ 2026-08-15 ACCEPTED + ARCHIVED — 致命操作识别表已搬到够得着的地方**
      commit `2c220f5`（未 push）。`fatal_operations`（97 行/3,439 B）从 `config-cognitive.yaml`
      整块移到 `config-quality.yaml`（alex/blake 正文实读 + Gate 显式指针可达），11 处指针同步。
      Gate 4：10/10 AC **Alex 独立复算**；AC7 用 **Alex 自派**的零上下文 agent 复验 **6/6**
      （12 次 Read、每文件一次、无 offset、无 Bash/Grep）。**结构保证**：目标文件 875 行 ≈10.8K tokens，
      离 Read 上限 25K 有一倍余量——不重演 P7「在场但不可达」。
      ⚠️ 契约出了 7 个 rev，**没有一个是因为要做的事有问题**——全是验收层：落点判据错、
      字节漏算、键三次选错、行内替换按 1 行计、指针 #9 无 AC 覆盖。
      ⚠️ 过程如实记录不追认：Blake 一次越权改契约（内容对、过程错）＋ 一次误报指针已改。
      归档：`.tad/archive/handoffs/{HANDOFF,COMPLETION}-20260814-discipline-reachability.md`；
      Gate 4 报告 `.tad/evidence/acceptance-tests/reachability/gate4-alex-recompute.md`。
      **剩下三条（`研究先行`/`技术决策透明` 的载体仍在不加载的 `config-cognitive`）见下条。**

- [ ] **`config-cognitive.yaml` 仍不被 Alex 加载 → 另两条纪律仍是暗的**
      `研究先行` / `技术决策透明` 的载体还在 `config-cognitive.yaml`，而 `STEP 3` 正文不读它。
      ⚠️ 这两条**有常驻祈使句兜底**（P7 放的），缺的是本体；不像致命操作那样本体即识别能力，
      优先级低于原来的判断。**动手前先量：它们的本体到底承载什么，值不值 +N 字节。**

- [ ] **`gen-floor.py` 两处朽坏（Alex 留下的，同一脚本第二次）**
      (a) `:27` 的 `启动扫描` 锚点仍是 P3 前的旧串，实测在 T0 的 `SKILL.md` 已命中 0
      → 生成器现在跑必报 `anchor not in carrier`；
      (b) 它读的 `keys30` 路径已随单归档（与 `measure.sh` 硬编码归档路径同病）。
      ⚠️ **形状**：改了产物没改生成器。P7 时改地板表锚点漏了它，本单改载体又漏了它。
- [ ] **`alex/references/**` 83 条强制行中 82 条在常驻层无重复副本**
      → **今天守住纪律的是"重复"，不是加载机制。** 9 条 `forbidden` 里 8 条靠 `CLAUDE.md` 重复侥幸安全。
- [ ] **净省要打 25% 的折**：`knowledge-bootstrap` 的 `load_when` 是"每次激活时"，
      它每次都被读，只是搬出了测量分母。1,342 B / 净省 5,389 B 是假的。同类外置都要按这条复查。
- [ ] **express 审查下限两个口径**（**需人裁定**）：五处说 min 2（含 `CLAUDE.md:63`、
      `alex/SKILL.md:1551/1236/1585`、`config-quality.yaml:74`）；
      `principles.md` 的 SAFETY 条目与 AR-001（`alex/SKILL.md:1710`）说 express 可降到 **min 1**。
      P7 把 min 2 一侧写成了常驻祈使句（更严，方向安全），矛盾因此更显眼。

### 2. Phase 3c —— **BLOCKED，通道被关**（需人裁定）

- [ ] **Phase 3c Release live dogfood** — 原文：「**Lite-only** 真实 publish+sync，
      这是整个 Epic 第一个真正对外写的阶段」。**但 lite 已于 2026-08-13 冻结**
      （`CLAUDE.md` §2.5：不接新工作）。**一个 READY 状态的阶段，它的通道已被另一条线关掉。**
      三选一：改走 full ｜ 作废 ｜ 作为"在飞单"例外放行。开工前另需处理
      AC8 只剩 **2 字节**余量（Lite core 52,198 / 上限 52,200）。

### 3. 剩余机制缺口

- [ ] **③ 移植 lite 的无条件轮次上限到 full**
      lite 有 `repair_round 3/3`（不看错是否相同）+ 跨压缩持久化；full 只有 error-shaped 的
      `consecutive_same_error>=3`，**错不重样就永远归零**。
      ⚠️ **重做前必须先读** `.tad/archive/handoffs/blocked/HANDOFF-20260804-gate-loop-circuit-breaker.md`：
      2026-08-04 按三 FR 大单设计过，**4 轮 Gate 2 / 8 名专家 / 26 个 P0 / 零交付**，四版栽在同一处。
      关键洞察：lite 的免疫来自 **boundary-append**（阶段边界枚举、与成败无关），不是「3 轮」这个数字。
- [ ] **④ handoff 体量闸** — 生成时超 80KB / 20 AC → 提示拆分或降级（提示不硬拒）。
      落点必须在**任何 reviewer 被 spawn 之前**（step1b/step1c 之间），否则"坚持原样"是唯一理性选项。
      实测分布：出事那张 107KB/27AC；64/62/52KB 三张都跑完了；其余 <40KB。

### 4. 杂活（不走 phase 那套机器）

- [ ] **brain-index 生成器 `set -e` 缺陷** — 撞到缺 `task_type:` 的旧归档即退出 →
      「recent 50」段只出 11 条（缺 39）。**预存缺陷**。
- [ ] **`STEP 3.5b` 的 CVE 正则抓不到 GHSA** — Path 2 是 `/CVE-\d{4}-\d+/`，
      而触发这条纪律的那次真实事故（停跑 28 天、漏 4 个漏洞、含明文 token 打印）
      里的编号全是 **GHSA-**。**原正则本来就不可能命中。**

---

## 📌 判断依据（不是待办，是下次动手前要想起来的）

- **改一个机制时去找它的兄弟位置。** 同病治一半是本仓库的高频形状：
  Gate 3 改了 AC 驱动、Layer 1 被落下；reviewer 读取有界了、Blake 自己无界；
  lite 有护栏、full 没有。**修复没横向扫干净 = 病灶原地转移。**
- **遇到 full 侧的纪律问题，先去 lite 找有没有现成答案**，别从头设计。
  lite 是踩完坑之后建的，full 是更早的设计。
- **`grep` 证明"在文件里"，不证明"agent 读得到"。** 文件超过 Read 单次上限
  （本机实测 25,000 tokens）后，尾部是"在场但不可达"的内容，而所有基于 grep 的检查对它全盲。
  详见 `patterns/gate-design.md` 同名 SAFETY 条目。

---

## 💡 Ideas（未裁定，按需捞取）

完整清单见 `.tad/ideas/`。此处只留最近三批的入口：

- **2026-07-03（AI Tinkerers #33）**：single-loop agent 无框架 · trace hour 周会 ·
  rubber stamp effect（人验证 AI 判断会盲目同意，已进 `principles.md`）· JAX 极致并行
- **2026-06-16（SkillOpt 深研）**：见 `.tad/ideas/`
- **长期停放**：TAD opt-in 模式（担心放松默认）· Domain Pack YAML 退役 ·
  跨项目 skill 提升 · declarative agent constraints · agent adapter pattern

## 🧊 长期停放的 Epic（非阻塞）

- Agent Capability Packs 6/9 · Goal-Driven Research Director 3/4 · Security Domain Pack Chain 2/5（暂停）
