# Phase 3 Completion Report — Cloud-Scheduled Weekly GitHub Registry Scan

**Handoff**: `.tad/active/handoffs/HANDOFF-20260713-native-capability-adoption-phase3.md`
**Epic**: EPIC-20260712-native-capability-adoption.md (Phase 3/4)
**Executed by**: Blake (YOLO Epic sub-agent), 2026-07-13
**Worktree**: `/Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_a4ff2d3f-9c0-3` (isolated; all paths below relative to this root)

---

## Intent Confirmation (三问, per §1.3 YOLO mode — Conductor 代行确认)

1. **这个功能解决什么问题？** scan-log.yaml 的 `last_scan` 一直是 null——周扫描 routine 从未真正跑过，Alex STEP 3.9 周报机制从未产出。本 phase 验证"scheduled headless session 能否跑通 LLM-driven SKILL 协议（含 gh keychain auth）"这一未知，并把 scan 协议改造成 headless-safe，使 CronCreate 周任务可以接管。
2. **用户会如何使用？** 用户什么都不用做：Conductor 注册 weekly cron 后，每周日 23:00 headless session 委托 SKILL scan 协议刷新 scan-log.yaml；用户下次 session start 时 STEP 3.9 直接报告更新和新候选。手动 `*research-github scan` 路径原样保留。
3. **成功的标准是什么？** 行为证据：一次真实 headless 运行把 `last_scan: null` 翻成日期、merge-write 保留用户 reject 决策（fixture 判别）、同日重跑 log-and-exit 不 prompt。全部已实证（见 spike-evidence.md）。

---

## Branch Declaration

**Spike Verdict: PASS** — PASS 分支交付。FR4 degraded path（STEP 3.9 nudge + 手动 cadence）未触发，
alex/SKILL.md 零改动（AC11 = NOT_APPLICABLE_WITH_REASON: verdict=PASS）。

---

## Files Changed

| File | Change |
|------|--------|
| `.claude/skills/research-github/SKILL.md` | FR1: Step 1b today-guard 新增 non-interactive 分支（same-day → log-and-exit，绝不 AskUserQuestion；交互路径原样保留）。FR2: "Setup: Scheduled Routine" 章节重写为委托式 routine prompt（删除内联复刻的 gh api/gh search 逻辑与 full-overwrite 写法），注明 CronCreate/Conductor 注册方式 + one-shot 验真建议 |
| `.agents/skills/research-github/SKILL.md` | 双平台镜像（cmp byte-identical, AC10） |
| `.tad/github-registry/scan-log.yaml` | 探针真实写入（行为证据，非代码改动）：last_scan null→2026-07-13, 4 updates + 4 pending candidates（ai-agents 域）。fixture 已按 Micro-task 7 清理 |
| `.tad/evidence/spikes/cron-github-scan-2026-07/cron-prompt.md` | 新建：Conductor CronCreate 直接取用的独立 prompt 文本（BEGIN/END 标记 + 用法注释, weekly Sunday 23:00） |
| `.tad/evidence/spikes/cron-github-scan-2026-07/spike-evidence.md` | 新建：四问 (i)-(iv) 原始输出 + fixture before/after + same-day re-run 判别 + `Verdict: PASS` |
| `.tad/evidence/yolo/native-capability-adoption/phase3-completion.md` | 本报告 |
| `.tad/evidence/traces/2026-07-13.jsonl` | TAD hook 自动 trace 排放（evidence_created 事件；仓库惯例是提交 trace 文件） |

**Not changed (by design)**: `.tad/github-registry/REGISTRY.yaml`（AC8 = 0 diff）、`.claude/skills/alex/SKILL.md`（PASS 分支）、Step 4 merge-write 协议本体（handoff §10.1 明令不动）。

---

## Layer 1 Results

| Check | Result | Detail |
|-------|--------|--------|
| `npx tsc --noEmit` | PASS (exit 0) | 仓库无 tsconfig.json / TS 源（纯 bash/markdown/mjs 框架仓库）；tsc 无输入即退出 0。实质等价 NOT_APPLICABLE_WITH_REASON |
| `npm test` | PASS (exit 0) | script = `echo "No tests yet"`（仓库现状）。协议级等价物 = §6.1 micro-task grep/cmp 验证，全绿（见 AC 表） |
| `npm run lint` | N/A | 无 lint script（"if available" 条件不满足） |
| YAML 有效性 | PASS | `yq` 解析 scan-log.yaml（last_scan=2026-07-13, 4+4 条目）与 SKILL frontmatter（name: research-github）均成功 |

---

## AC Verification Table (§9.1)

> 所有命令在 worktree 根目录运行（等价于 handoff 的项目根，per worktree grounding）。

| # | AC | Verification Method (as run) | Expected | Actual | Status |
|---|----|------------------------------|----------|--------|--------|
| AC1 | Baseline: last_scan null | `grep -c 'last_scan: null' .tad/github-registry/scan-log.yaml` | 1 | `1` (pre-impl, 2026-07-13) | PASS (baseline) |
| AC2 | Baseline: 交互 guard 在, headless 分支不在 | `grep -n 'Already scanned today' …; grep -c 'non-interactive\|headless' …` | L343 命中; 0 | `343:` 命中; `0` (pre-impl) | PASS (baseline) |
| AC3 | Baseline: spike 目录不存在 | `test -d … && echo EXISTS \|\| echo ABSENT` | ABSENT | `ABSENT` (pre-impl) | PASS (baseline) |
| AC4 | FR1 non-interactive 分支 + 交互路径保留 | `grep -c 'non-interactive' SKILL.md; grep -c 'Already scanned today' SKILL.md` | ≥2; ≥1 | `5`; `2` | PASS |
| AC5 | FR2 Setup 章节无内联 scan 逻辑 | `sed -n '/## Setup: Scheduled Routine/,$p' SKILL.md \| grep -c 'gh search repos'` | 0 | `0` | PASS |
| AC6 | cron-prompt.md 独立交付含 merge/单写者指令 | `test -f cron-prompt.md && grep -ci 'merge' cron-prompt.md` | 存在; ≥1 | 存在; `2` | PASS |
| AC7 | Verdict 显式 + fixture 清理 | `grep -cE '^Verdict: (PASS\|FAIL)' spike-evidence.md; grep -c 'fake-rejected-fixture' scan-log.yaml` | 1; 0 | `1`; `0` | PASS |
| AC8 | REGISTRY.yaml 零改动 | `git diff --name-only -- .tad/github-registry/REGISTRY.yaml \| wc -l` | 0 | `0` | PASS |
| AC9 | last_scan 真实翻转 (PASS 分支) | `grep -c 'last_scan: null' scan-log.yaml` | 0 | `0`（现值 `last_scan: 2026-07-13`） | PASS |
| AC10 | 双平台镜像 byte-identical | `cmp .claude/skills/research-github/SKILL.md .agents/skills/research-github/SKILL.md && echo IDENTICAL` | IDENTICAL | `IDENTICAL` | PASS |
| AC11 | FR4 STEP 3.9 nudge（仅 FAIL 分支） | — | — | — | NOT_APPLICABLE_WITH_REASON: spike verdict = PASS（FAIL 分支未走到；alex/SKILL.md 未改动） |
| AC12 | Blake 零 CronCreate; Escalations 记录 | `grep -c 'Conductor action' phase3-completion.md` | ≥1 | ≥1（见 §Escalations；本 session 零 CronCreate/CronDelete 调用） | PASS |
| AC13 | Change scope 限于 §7 清单 | `git status --porcelain -- .claude/skills .agents/skills .tad/github-registry .tad/evidence/spikes/cron-github-scan-2026-07 \| grep -v -e 'research-github' -e 'alex' -e 'scan-log' -e 'cron-github-scan' \| wc -l` | 0 | `0` | PASS |

### Edge-case 判别测试 (§8.3, FR1 判别)

- **Same-day headless re-run**: 第二次探针输出恰好一行 `Already scanned today (2026-07-13) — non-interactive mode, exiting without changes.`；scan-log.yaml md5 前后一致（`135367a7…`），未重扫、未 prompt。PASS。
- **fixture 判别**: fixture（status: rejected, first_seen: 2026-07-13, previous last_scan null → GC 必须保留）在探针后原样存活，新候选 merge 在其旁。无 full-overwrite 泄漏。PASS。
- **gh rate-limit**: 未触发（单域 6 calls）。NOT_APPLICABLE_WITH_REASON: 预算内。

---

## Spike Summary (Phase B)

四问全部 SATISFIED → **Verdict: PASS**（原始证据见 `.tad/evidence/spikes/cron-github-scan-2026-07/spike-evidence.md`）：

1. (i) headless `claude -p` 内 `gh auth status` 读到 keyring 凭据（Sheldon-92, Logged in）。
2. (ii) SKILL 协议被 Read 并逐步执行（输出为协议 Step 5 规定格式，引用 Step 2/3/4 编号），全程零交互 prompt；same-day guard 的 non-interactive 分支按 FR1 精确执行。
3. (iii) merge-write 语义真实：rejected fixture 保留、原 first_seen 不变。
4. (iv) `last_scan` null → 2026-07-13 真实翻转（STEP 3.9 首次获得可观测输入）。

**Probe 环境备注**：首次探针尝试（broad `--allowedTools "Bash,Read,Write,Edit,Glob,Grep"`）被外层 auto-mode permission classifier 拒绝（嵌套自主 agent + 无限制 shell/write）。改用最小权限集重试成功：只读 gh 命令 + 仅 scan-log.yaml 单文件写权限。该拒绝是 Blake sub-agent 沙箱环境属性，不适用于 Conductor main session / 真实 cron routine；同时它给出了 cron routine 权限配置的最小集参考（记入 spike-evidence.md）。

---

## Escalations

1. **CronCreate registration = Conductor action, post-gate**（PASS 分支）：Blake 依 FR5/grounding 边界未调用 CronCreate/CronDelete。Conductor 在 gate PASS 后用 `.tad/evidence/spikes/cron-github-scan-2026-07/cron-prompt.md` 的 BEGIN/END 标记正文注册 weekly cron（Sunday 23:00）。建议 cron 权限配置至少包含 spike 使用的最小集（见 spike-evidence.md 环境备注）。
2. **+5min one-shot cron 验真 cron-fires-at-all = Conductor action**：`claude -p` 只是 gh-auth/skill-resolution/端到端问题的 EQUIVALENT_SUBSTITUTE（grounding 明示）；cron 是否真的按时触发需 Conductor 注册一个 +5 分钟 one-shot 验证。
3. **Handoff 文件不在 worktree 内**：handoff 与 Epic 文件是 main working dir 的 untracked 文件，未进入 worktree（从 main-dir 只读读取，无影响；记录备查）。
4. **Out-of-scope hook 漂移已回滚**：嵌套 headless session 的 SessionStart hook 把 `.tad/research-notebooks/REGISTRY.yaml` 3 个 notebook 标为 dormant（staleness 自动标记，非 scan 协议写入——探针写权限仅限 scan-log.yaml）。为守 NFR1/AC13 change-scope，已 `git checkout` 还原；该 staleness 标记会在 main repo 正常 session 中自然重现，无信息丢失。
5. **主仓库同名数据文件分叉提醒**：本 phase 在隔离 worktree 中真实写了 scan-log.yaml。merge 回 main 时若 main 侧 scan-log.yaml 也被改动（当前 main 为 null 基线，低风险），需以 worktree 版本为准。

---

## Sub-Agent 使用记录 (§12)

| Sub-Agent | 是否调用 | 说明 |
|-----------|---------|------|
| parallel-coordinator | ❌ | 任务线性（handoff §10.3 建议一致） |
| bug-hunter | ❌ | 探针无不可解释失败 |
| test-runner | ❌ | 无测试套件；AC 命令直接跑 |

（注：`claude -p` 探针进程是 spike 的被测载体，不是 review/实现 sub-agent。本 session 未 spawn 任何 reviewer。）

## Knowledge Assessment 候选（供 Gate 3 KA，skip_knowledge_assessment: no）

- **发现**: `claude -p` headless 模式在 macOS 上可见 keyring gh auth、可解析并遵循 project SKILL 协议、可被限定到单文件写权限——"LLM-driven SKILL 协议可以被 cron headless 委托执行"首次实证（对照 Phase 2 的 frontmatter INERT 负结果：文档说有 ≠ 真的有，这次是真的有）。
- **发现**: Blake sub-agent 环境下 spawn 嵌套 `claude -p` 需要最小权限集（tool-scoped allowedTools），broad 授权会被 auto-mode classifier 拒绝——该最小集恰好是 cron routine 权限配置的现成答案（约束变资产）。
- **发现**: 委托式 cron prompt（薄入口 + 厚协议）在真实 headless 运行中一次通过，包括 merge-write 与 same-day guard 两个最易漂移的语义——支持 handoff §11 的"入口薄、协议厚"决策。
