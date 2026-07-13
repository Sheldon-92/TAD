---
task_type: code
epic: EPIC-20260712-native-capability-adoption.md
phase: 1
skip_knowledge_assessment: no
production_dirs:
  - .tad/hooks
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 — HANDOFF-20260712-precompact-session-state-hook (v2 — 专家审查后)

## 🔴 Gate 2: Design Completeness (Alex 必填)

### Gate 2 检查结果
- [x] Expert review (min 2): code-reviewer + backend-architect,6 P0 全部整合(§9.2)
- [x] Architecture / Components / Functions / DataFlow: §4
- [x] Socratic 前置: 2026-07-12 Epic 三问(行为级验收 / P3 降级 / P1 优先)
- [x] Friction Preflight: §8.4

---

## 1. Task Overview

### 1.1 What We're Building
一个 **PreCompact hook**:在每次上下文压缩(手动 /compact 和自动压缩)之前,把机械可得的
会话状态写成**独立快照文件** `.tad/active/precompact/snapshot-{ts}-{sid8}.md`(每会话每次
压缩一个文件,newest-wins,保留最近 5 个);外加 **post-compact 提醒**:SessionStart
(source==compact) 时 additionalContext 注入一行,提示 agent 读 session-state.md + 最新快照。
两件合起来把 CLAUDE.md §4.5 的"agent 自觉自检"从唯一防线降为第二防线。

⚠️ **v2 关键设计变更(专家 P0 驱动)**:hook **完全不写 session-state.md**。该文件保持
100% agent 手写。机械/对话边界从"同文件内区块约定"升级为"物理分文件"。

### 1.2 Why We're Building It
压缩失忆是用户反复遭遇的真实痛点。现有恢复机制(§4.5)完全依赖 agent 压缩后的自觉。
原生 PreCompact hook 事件允许压缩前机械落盘,不靠自觉。DR-20260712 A1 裁决:先跑
PreCompact hook 试点,稳定后再议 §4.5 瘦身——本 handoff 即该试点。

### 1.3 Intent Statement
压缩前状态必有快照,压缩后恢复必有提示;hook 只写自己的快照文件,绝不触碰 agent 维护的
任何文件;任何 hook 故障都不得阻碍压缩本身(fail-open,烟雾报警器不是灭火系统)。

---

## 📚 Project Knowledge(Blake 必读)

相关类别:**Hook Contracts** + **Shell Portability**。摘录:
- Hook event keys **PascalCase**(`PreCompact`);`type: command` 支持 additionalContext 注入。
- **先 spike 验证机制再定架构**——T1 即该 spike,且其结果 gate 后续任务(见 T1)。
- 快照文件的字段格式会被 §4.5 恢复流程消费——**文件格式即契约**,字段名不可随意改。
- macOS bash 3.2 / BSD 兼容;**禁用 `set -e`**(或每个 `$()` 挂 `|| fallback`)——本仓已有
  两起 `$()` 非零 + set -e 触发 ERR trap 的事故记录(shell-portability.md)。
- 2026-04-15 principles.md SAFETY:本 hook 是写快照不是拦截,fail-open;实现严禁演变出
  任何 deny/block 行为。

### Blake 确认
- [ ] 已读上述摘录 + patterns/hook-contracts.md + patterns/shell-portability.md 全文

---

## 2. Background Context

### 2.1 Previous Work
- session-state.md 由 Alex/Blake 手写维护(本设计不改它,只在 §4.5 文档层联动)。
- SessionStart hooks 已注册(startup-health.sh + notebook-dormant-sync.sh),实测 compact 后
  也触发("SessionStart:compact hook success" 本会话可见)。
- 研究底座:.tad/evidence/research/claude-native-capabilities/(notebook b07a6598 可追问)。

### 2.2 Current State
`.claude/settings.json` 无 PreCompact 配置;`.tad/active/precompact/` 不存在(T2 创建)。
**⚠️ Blake 必读 grounding(实际代码状态 + Layer 1 替代检查 + T1 honest-partial 指引)**:
`.tad/evidence/yolo/native-capability-adoption/phase1-grounding.md`

### 2.3 Dependencies
- 本机 Claude Code 支持 PreCompact 事件(§8.4)。
- python3/jq(现有 hooks 已用)。

---

## 3. Requirements

### 3.1 Functional Requirements

- **FR1 快照文件**:PreCompact 触发 → 写 `.tad/active/precompact/snapshot-{YYYYMMDD-HHMMSS}-{sid8}.md`:
  ```
  # PreCompact Snapshot (mechanical — auto-written, do not edit)
  - When: {ISO8601 local}
  - Trigger: {manual|auto}
  - Session: {session_id 前 8 位}(诊断用;跨压缩边界不可作匹配键,读者按 newest-wins)
  - Git HEAD: {short-sha} {subject 首 60 字符}
  - Git: {branch} | ahead {A} / behind {B} origin | {N} modified, {M} untracked
  - Active handoffs ({count}): {文件名空格连接,单行,tr '\n' ' '}
  - Active epics ({count}): {同上}
  ```
  多行命令输出一律压成单行(计数 + 空格连接),禁止原样嵌入。
- **FR2 物理边界**:hook 唯一的写目标是自己的快照文件 + 目录内修剪。对 session-state.md
  及任何 agent 维护文件零写入(AC2 用全文件 diff 验证)。
- **FR3 fail-open + 可鉴别故障信号**:任何内部错误 → exit 0,不阻碍压缩。但故障不得与成功
  不可区分:内部出错时仍尽力写快照文件,派生失败的字段填 `(unavailable: {reason})`;若连
  文件都写不出,追加一行到 `.tad/active/precompact/.hook-debug.log`(`{ts} snapshot-skipped: {reason}`)。
  timeout ≤ 10s。
- **FR4 post-compact 提醒**:**必须以 startup-health.sh 内新增 compact 分支实现**(不新增
  hook 注册,消除多脚本交互面)。在现有 `source != startup → output_empty` 早退守卫**之前**
  插入:`source == compact → output_response 一行提醒; exit 0`。提醒文本:
  `Post-compact: read .tad/active/session-state.md + newest .tad/active/precompact/snapshot-*.md before continuing.`
  `source == startup` 路径输出必须 byte-identical(AC7)。
- **FR5 注册**:settings.json 增加 PreCompact 项(matcher 覆盖 manual+auto)。Blake 负责
  (Alex constraints deny settings 修改)。
- **FR6 修剪**:写入成功后,目录内 snapshot-*.md 按名字序(时间戳前缀即时序)只保留最新 5 个,
  多余删除;删除失败不影响 exit 0。
- **FR7 写入纪律**:真实文件只经最终一次 `mv` 落位——所有派生与拼装先在变量/temp 完成,
  中途死亡不得留下半截文件。禁用 `set -e`;每个 `$()` 挂 `|| echo "(unavailable)"` 类兜底。
- **FR8 gitignore**:`.tad/active/precompact/` 整目录加入 .gitignore(瞬态会话产物,不进
  public repo;内容虽低敏,但属噪音)。

### 3.2 Non-Functional Requirements
- macOS bash 3.2 兼容;无新依赖;脚本落 `.tad/hooks/precompact-session-snapshot.sh`。
- CLAUDE.md §4.5 增补三层模型(hook 快照=Layer 0 机械,自检=Layer 1,手动=Layer 2)。
  **允许对现有行做有界注解式修改**(为现有两层补 Layer 标号),但必须:修改前列出逐行
  变更清单(AR-002),line-set diff 的 delta 与清单严格相等(AC8)。语义只增不改。

---

## 4. Technical Design

### 4.1 Architecture Overview
```
[/compact 或 auto-compact]
      │ PreCompact (stdin JSON — 字段以 T1 实测为准)
      ▼
precompact-session-snapshot.sh
      │ 派生(全 read-only, 每个 $() 有兜底)→ 拼装到 temp → mv 落位 → 修剪保留 5
      │ exit 0 always
      ▼
[compaction proceeds]
      │ SessionStart (source==compact)
      ▼
startup-health.sh compact 分支 ──► additionalContext 提醒行
      ▼
agent 读 session-state.md(对话状态)+ newest snapshot(机械状态)
```
双终端语义:每次压缩产生独立文件,无共享写入者,无并发问题;读者规则 = newest-wins,
Session 字段仅诊断(session_id 跨压缩边界的稳定性由 T1 实测,设计不依赖它)。

### 4.2 Component Specifications(micro-tasks)
- **T1 spike(先行,gate 后续所有任务)**:一次性测试注册探针 hook,把 PreCompact stdin
  原样落 `.tad/evidence/hooks/precompact-snapshot/probe-stdin.json`。必须记录四个答案:
  (i) stdin 字段名(session_id/trigger/cwd/transcript_path 实际拼写);
  (ii) session_id 是否跨压缩边界保持(compact 前后各取一次对比);
  (iii) PreCompact 是否在 **auto**-compact 也触发——无法按需触发 auto 时,记录为
  untestable-on-demand + matcher 仍覆盖两者 + completion report 注明残余未知;
  (iv) SessionStart 的 source 值集合(startup/compact/resume?)及 compact 可鉴别性。
  与设计不符 → 以实测为准修正 FR1/FR4,completion report 记 deviation。
- **T2 主脚本**(FR1/FR2/FR3/FR6/FR7):新建目录 + 快照写入 + 修剪。
- **T3 注册**(FR5)+ **FR8 gitignore**。
- **T4 提醒**(FR4):startup-health.sh compact 分支。
- **T5 行为级验证**:真实 /compact ≥2 次 + 故障注入 1 次;evidence 落
  `.tad/evidence/hooks/precompact-snapshot/`。
- **T6 文档**:CLAUDE.md §4.5 三层模型(含逐行变更清单)+ session-state 模板尾注
  (指向 precompact/ 快照的存在)。

### 4.3 Data Models
快照文件 = 消费契约:字段名(When/Trigger/Session/Git HEAD/Git/Active handoffs/Active epics)
被 §4.5 恢复流程与 FR4 提醒引用,改字段属 breaking change,需同步改 §4.5 文本。

### 4.4/4.5 API / UI
N/A。

---

## 5. 强制问题回答(Evidence Required)

### MQ1 历史代码搜索
`grep -rn "PreCompact" .claude/settings.json .tad/hooks/` → 0 hits(全新事件,无冲突)。
`grep -rn "precompact" .tad/` → 仅 idea/DR/Epic 文档引用,无实现。

### MQ2 函数存在性验证
startup-health.sh 存在、已注册,含 `output_response`/`output_empty` 单次调用契约(T4 保持)。

### MQ3 数据流完整性
PreCompact stdin(T1 实测)→ 只读派生 → temp → mv → 独立快照文件 → §4.5/提醒行 → agent 读。
无网络。写入面 = precompact/ 目录一处。

### MQ4 视觉层级
N/A。

---

## 8.4 Friction Preflight
| 前提 | 状态 | 缺失时 |
|------|------|--------|
| 本机 Claude Code 支持 PreCompact 事件 | 待 T1 验证 | 不支持 → **BLOCKED**,报告版本号,不得静默降级 |
| auto-compact 可按需触发 | 未知 | 不可 → T1(iii) 记 untestable-on-demand,非 BLOCKED |
| python3/jq | READY | — |
| settings.json 写权限(Blake) | READY | — |

## 8.5 Feedback Collector
feedback_required: false。

---

## 9. Acceptance Criteria(行为级)

- **AC1**:脚本存在、可执行、`bash -n` 通过、settings.json 注册 PreCompact(manual+auto matcher)。
- **AC2(核心行为级)**:压缩前 `cp .tad/active/session-state.md /tmp/pre-$$`;真实 /compact →
  (a) precompact/ 出现新快照文件,When/Trigger/Git HEAD 字段与当时事实一致;
  (b) `diff /tmp/pre-$$ .tad/active/session-state.md` 为空(hook 零触碰,全文件 diff,无需剥离)。
- **AC3(fail-open 可鉴别)**:注入故障(如把脚本内 git 调用临时改为不存在命令)→ 压缩正常
  完成、hook exit 0、快照文件含 `(unavailable: ...)` 字段或 .hook-debug.log 出现 skipped 行。
  恢复后再跑一次全字段正常。两次运行 evidence 均落盘。
- **AC4(修剪)**:连续触发 7 次(可直接命令行喂 stdin 跑脚本 7 次)→ 目录内 snapshot-*.md
  恰好 5 个,且为最新 5 个(名字序验证)。
- **AC5(torn-write 抗性)**:同一 stdin 并发 20 个后台进程跑脚本 + `wait` → 每个产出文件
  要么不存在要么完整(逐文件断言字段行数 == 模板行数);无半截文件。
  (注:本 AC 只证 torn-write 抗性;last-writer 语义不适用——每进程独立文件名。)
- **AC6(提醒,机械验证)**:`echo '{"source":"compact",...}' | bash .tad/hooks/startup-health.sh`
  输出含提醒行(`grep -F`);`{"source":"startup",...}` 输出不含提醒行。字段名以 T1(iv) 实测为准。
- **AC7(不回归)**:`source==startup` 时 startup-health.sh 输出与改动前 byte-identical
  (改前捕获基线输出文件,改后 diff);notebook-dormant-sync.sh 不受影响(未改动 + 注册序不变)。
- **AC8(文档,有界变更)**:CLAUDE.md §4.5 变更 = 逐行变更清单(T6 先列),line-set diff 的
  FORWARD-missing/REVERSE-added 与清单严格相等;三层模型呈现完整。
- **AC9(T1 记录完整)**:probe-stdin.json + T1 四问答案文件存在于 evidence 目录。

Evidence 目录:`.tad/evidence/hooks/precompact-snapshot/`

---

## 9.2 Expert Review Audit Trail(v1 → v2)

| # | 专家 | 级别 | 发现 | v2 处置 |
|---|------|------|------|---------|
| 1 | arch F3 | P0 | 共享单区块双终端互相覆盖,读者误认他会话状态 | **根本重构**:改为每会话每次压缩独立快照文件,newest-wins;session-state.md 零写入 |
| 2 | cr#1 | P0 | 区块替换算法未指定(BSD sed 陷阱) | 随 F3 消解:无共享文件替换;FR7 规定 temp→mv 唯一落位纪律 |
| 3 | cr#4 | P0 | temp+mv 不能防 read-modify-write 竞态,FR6 过度声称 | 随 F3 消解:无共享写入者;AC5 重定义为 torn-write 抗性且明示边界 |
| 4 | cr#6 | P0 | set -e + $() 中途死亡可留半截文件 | FR7:禁 set -e / 每 $() 兜底 / 真实文件只经 mv 落位 |
| 5 | cr#8 | P0 | AC2 byte-identical 无可执行操作数 | AC2 重写:cp 基线 + 全文件 diff(hook 不碰该文件,diff 应为空) |
| 6 | cr#5 | P1↑ | grep -c BEGIN==1 幂等检查不充分 | 随 F3 消解;修剪语义改 AC4(7 次→恰 5 文件) |
| 7 | arch F4 | P1 | session_id 跨压缩边界不稳定,不可作读者匹配键 | FR1 标注 Session 仅诊断;读者规则 newest-wins;T1(ii) 实测 |
| 8 | arch F7 | P1 | T1 spike 太窄(auto 触发/source 值/id 稳定性未探) | T1 扩为四问,gate 后续任务;§8.4 增 auto 行 |
| 9 | arch F5 | P1 | AC8 仅新增行 vs 三层标号需注解现有行,自相矛盾 | NFR/AC8 放宽为有界清单式修改,line-set diff 与清单相等 |
| 10 | arch F1 | P1 | 缺最有恢复价值的机械事实:HEAD sha / ahead-behind | FR1 增 Git HEAD 行与 ahead/behind |
| 11 | cr#7 | P1 | fail-open 与成功不可鉴别,AC3 不可证 | FR3 增 (unavailable) 字段 + .hook-debug.log 面包屑 |
| 12 | cr#11/12 | P1/P2 | startup-health 扩展守卫顺序风险;双载体选择削弱 AC7 | FR4 强制单载体 + 指定分支插入位置;AC7 基线 diff |
| 13 | cr#13 / arch F2 | P2 | ls 多行输出嵌单行字段;handoff 列表低信噪 | FR1 计数+单行压缩规则 |
| 14 | arch F8 | P2 | FR6 并发机械属可删范围 | 已删;AC5 缩为 torn-write |

双专家 verdict(v1): NEEDS-FIXES(P0 ×6)→ v2 全部整合。

## 11. Decision Summary
| 决策 | 选择 | 依据 |
|------|------|------|
| 快照载体 | 独立文件/次,非共享区块 | arch F3(双终端覆盖);物理边界优于约定边界 |
| 读者匹配 | newest-wins by 文件名时序 | arch F4(session_id 跨边界不可靠) |
| 故障策略 | fail-open + 可鉴别面包屑 | 2026-04-15 SAFETY + cr#7 |
| 提醒载体 | startup-health.sh 单载体分支 | cr#11/12(缩小交互面) |
| 快照留存 | 最新 5 个,gitignore 整目录 | 瞬态产物;public repo 噪音控制 |
