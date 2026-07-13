---
task_type: mixed      # config (settings/jq) + bash script + protocol text + docs
e2e_required: no
research_required: no  # research already done: DR-20260712 + overlap matrix
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta:
  - field: "AC6"
    alex_said: "release-verify.sh parity --fix then parity PASS as a routine post-impl step"
    actual: "global parity structurally cannot PASS under concurrent-terminal mutation; scope-level cmp byte-identity accepted as EQUIVALENT_SUBSTITUTE; --fix also leaked gitignored local/ into tracked .agents (new tool defect)"
    caught_by: "Blake friction protocol + spec-compliance reviewer; distilled as patterns/release-sync.md E6 + handoff-design.md E5"
  - field: "AC8"
    alex_said: "AC8 human verify at Gate 4 before archive"
    actual: "user chose conditional accept — AC8 deferred to next natural new session (T8 revert tested as safety net)"
    caught_by: "human decision at Gate 4"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-12
**Project:** TAD Framework
**Task ID:** TASK-20260712-001
**Handoff Version:** 3.1.1(专家审查后修订:3 P0 + 6 P1 全部整合)
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-07-12(专家审查整合后)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Capture/Distill 分层 + 下游 opt-in + sync 三粒度保护 |
| Components Specified | ✅ | T1-T8 每个 Micro-Task 有目标文件/伪代码/验证 |
| Functions Verified | ✅ | derive-sync-set.sh --zero-touch 实跑;tad.sh 重复 deny-list(L207-216)由 code-reviewer 实地验证;.agents 镜像存在已确认 |
| Data Flow Mapped | ✅ | §2-4 数据流图(capture→distill→maintain 全链) |

**Gate 2 结果**: ✅ PASS
**专家审查**: code-reviewer(1 P0/4 P1/5 P2, CONDITIONAL PASS)+ security-auditor(2 P0/4 P1/4 P2, CONDITIONAL PASS)→ 全部 P0 与关键 P1 已整合(见 §9.2 audit trail)→ PASS

**Alex确认**: 我已验证所有设计要素,Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图(不只是字面需求)
- [ ] 每个 Micro-Task 的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
把 Claude Code 原生 auto-memory 的写入位置重定向到 `.tad/memory/`(repo 内),迁移 36 条存量记忆(**带敏感度分级,user 型与敏感文件不进 git**),并把 `.tad/memory/` 接入 Alex 蒸馏循环作为第二原料源。原生 memory 从"与 TAD knowledge 抢跑的对手"变成 TAD 知识流水线的 **Capture 层**。

### 1.2 Why We're Building It
**业务价值**:消除 system-prompt 层(auto-memory)与 skill 层(TAD knowledge)的指令抢跑——"模型倾向写 memory 而不写 knowledge"的双腿打架问题。
**决策来源**:DR-20260712-native-capability-overlap-verdicts.md 裁决 1(基于 23 源研究 + 重叠矩阵)。
**成功的样子**:新会话里模型自发写的 memory 落进 `.tad/memory/`;*accept 蒸馏循环把新增 memory 与 Blake journal 一起锻造进 project-knowledge;下游 TAD 项目一条命令 opt-in;*sync/install 在任何粒度都不会搬运任何项目的 memory 数据;**public repo 不泄露个人信息**。

### 1.3 Intent Statement(意图声明)

**真正要解决的问题**:两套记忆指令并存导致的行为分裂。解法不是消灭一套,而是分层:native 管即时捕获,TAD 管蒸馏与长期知识。

**不是要做的(避免误解)**:
- ❌ 不是关闭或削弱 auto-memory——它继续自由写,只是换了家
- ❌ 不是把 memory 文件改造成 project-knowledge 格式——memory 目录归 native 管,TAD 只读不改写
- ❌ 不是替换 Blake journal——journal 仍是第一原料源
- ❌ 不是给所有下游项目自动开启——下游 opt-in
- ❌ 不是把 36 条存量无差别 commit——**public repo,敏感文件必须隔离**(SEC P0-1)

**Blake请确认理解**:实现前用自己的话回答两个问题:(1) 为什么 memory 目录里的文件我们只读不写?(2) 为什么 zero-touch 必须同时改 lib 和 tad.sh 两处?

---

## 📚 Project Knowledge(⚠️ Blake 必须注意的历史教训)

1. **Mechanical Enforcement Rejected on Single-User CLI**(principles.md 2026-04-15)——全部机制走脚本+协议文本,**禁止注册任何新 hook、禁止修改 settings.json 的 hooks 段**。
2. **Deny-List SAFETY 两条**(principles.md 2026-06-01)——(a) exclusion 断言是 load-bearing AC;(b) **deny-list 必须应用于每个复制粒度,且 tad.sh 内有与 lib 重复的硬编码 TAD_ZERO_TOUCH 列表(L207-216 附近),头部注释明言"edit BOTH or the drift-check FAILS the release"**。本任务 AC3 端到端覆盖(lib + tad.sh + --verify-denylist + dirs 排除)。[CR P0-1 / SEC P0-2]
3. **Circular Trigger Test**(principles.md 2026-06-09)——只改 references/ 细节文件,不动 alex/SKILL.md body 的触发文本。
4. **Knowledge Is Forged at Distill, Not Captured**(principles.md 2026-06-22)——memory 是 Capture 层原料,一样要过 variabilize test;禁止"看起来像知识直接搬"。
5. **Drift-Check allowlist**(patterns/memory-and-learning.md)——`.tad/memory/` 是跨 handoff 共享路径,drift 检测报它属 allowlist 情形。
6. **Observational > Imperative**(patterns/memory-and-learning.md)——蒸馏扫描用 mtime > cursor 观察式增量。
7. **A Coverage Gate's Global-Count Floor Cannot Detect…**(principles.md 2026-06-01)——AC2 迁移完整性用 `diff -rq` 内容级对比,不用文件数下限(count floor 抓不到部分拷贝)。[SEC P1-1]

### Research Notebook Findings
Notebook: 'claude-native-capabilities'(b07a6598,23 sources)
- autoMemoryDirectory 必须是**绝对路径或 ~/ 开头**;配置在 project 级 settings(含 settings.local.json)时受 **workspace trust dialog** 约束。[S1b 链]
- MEMORY.md 启动只加载前 200 行 / 25KB。[S1 链]
- ⚠️ 文档级证据,未经对抗审查——**实测为准**(AC8);矛盾时按 friction protocol 停下上报,并回写 DR-20260712。

---

## 2-4. Requirements & Design

### 数据流(改造后)

```
模型自发写 memory ──native 机制──▶ .tad/memory/{fact}.md + MEMORY.md 索引   [Capture]
                                        │ (选择性进 git:user_*/敏感文件 gitignore)
Blake 写 journal ──Gate 3 KA──▶ .tad/evidence/journal/{slug}.md            [Capture]
                                        │
Alex *accept 蒸馏循环 ──读两个源(增量)──▶ variabilize test → 陌生人锻造      [Distill]
                                        │
                              .tad/project-knowledge/{category}.md          [长期知识]
                                        │
knowledge-maintain ──去重/reconcile/retire──▶                               [Maintain]
```

### 关键设计决策

| # | 决策 | 选择 | 来源 |
|---|------|------|------|
| D1 | git 策略 | 默认进 git,**但 user 型 + 敏感度扫描命中的文件 gitignore 隔离**(repo 是 PUBLIC 的:github.com/Sheldon-92/TAD) | 用户 2026-07-12 + SEC P0-1 修订(待用户在 Gate 4 确认修订) |
| D2 | 存量 36 条 | 迁移 + 敏感度分级 + 首次蒸馏扫全量 | 用户 2026-07-12 |
| D3 | 蒸馏时机 | *accept 顺带扫增量(mtime > cursor,首跑全量) | 用户 2026-07-12 |
| D4 | 下游项目 | opt-in 脚本;sync 三粒度 zero-touch 保护 | 用户 2026-07-12 |
| D5 | 配置位置 | settings.local.json(绝对路径机器特定) | Alex 设计 |
| D6 | cursor 位置 | `.tad/evidence/memory-distill-cursor` | Alex 设计 |

---

## 5. Scope

**IN**: 重定向脚本、主仓启用+迁移+敏感度分级、zero-touch 三粒度保护(lib + tad.sh 双列表)、蒸馏协议扩展(additive)、.gitignore 敏感隔离、CLAUDE.md + runbook 文档、.agents parity。
**OUT**: 下游项目实际启用、auto-memory 行为修改、MEMORY.md 索引逻辑、任何 hook 注册、git push(commit 不 push,发布走 *publish 流程且 pre-publish 需复扫)。

---

## 6. Implementation Steps(Micro-Tasks — **按序执行,T2 必须在 T3 之前**)

### T2: zero-touch 三粒度保护(SAFETY — 先于迁移,防止任何窗口期数据外流)[CR P0-1 / SEC P0-2]

a. `.tad/hooks/lib/derive-sync-set.sh`:ZERO_TOUCH 列表加 `memory`(只加一词)。
b. `tad.sh`:**同步修改重复的硬编码 `TAD_ZERO_TOUCH` 列表**(L207-216 附近)加 `memory`,并按 L200-204 头部注释要求更新配套 count 注释(如有)。
c. 验证 drift gate:`bash tad.sh --verify-denylist` → exit 0(set-equality lib==tad.sh)。
d. 其余 4 个 flag 消费者(release-verify.sh / migration-engine.sh / migration-draft.sh 等)读 `--zero-touch` flag 单一事实源,自动继承——**不要**去改它们(code-reviewer 已验证)。

### T1: 创建 `.tad/hooks/lib/memory-redirect.sh`(新文件)

```bash
#!/usr/bin/env bash
# memory-redirect.sh — point Claude Code auto-memory at .tad/memory/ (TAD Capture layer)
# Usage: --enable | --status | --revert    (run from project root)
# DR-20260712 verdict 1. NO hooks registered — plain CLI tool (principles.md 2026-04-15).
set -euo pipefail

MODE="${1:---status}"
# Guard: must run from a TAD project root [SEC P2 run-from-root]
[ -f .tad/config.yaml ] || { echo "ERROR: run from TAD project root (.tad/config.yaml not found)"; exit 1; }
ROOT="$(pwd)"
LOCAL_SETTINGS=".claude/settings.local.json"
TARGET_DIR="$ROOT/.tad/memory"
# Claude Code derives the per-project dir by replacing '/' and ' ' with '-'
SLUG="$(printf '%s' "$ROOT" | sed 's![/ ]!-!g')"
OLD_DIR="$HOME/.claude/projects/$SLUG/memory"

status() {
  echo "project: $ROOT"
  echo "old native dir: $OLD_DIR ($(ls "$OLD_DIR" 2>/dev/null | wc -l | tr -d ' ') files)"
  echo "target dir:     $TARGET_DIR ($(ls "$TARGET_DIR" 2>/dev/null | wc -l | tr -d ' ') files)"
  echo "autoMemoryDirectory: $(jq -r '.autoMemoryDirectory // "ABSENT"' "$LOCAL_SETTINGS" 2>/dev/null || echo "no settings.local.json")"
}

enable() {
  command -v jq >/dev/null || { echo "ERROR: jq required"; exit 1; }
  # SLUG preflight: hard-verify derivation against reality [SEC P1-3]
  if [ ! -d "$OLD_DIR" ]; then
    echo "WARN: derived old dir not found: $OLD_DIR"
    echo "      (no prior memories, or slug rule mismatch — check ~/.claude/projects/ manually)"
    echo "      Proceeding with redirect only (no migration)."
  fi
  mkdir -p "$TARGET_DIR" .claude
  if [ -f "$LOCAL_SETTINGS" ]; then
    tmp="$(mktemp)"
    jq --arg d "$TARGET_DIR" '. + {autoMemoryDirectory: $d}' "$LOCAL_SETTINGS" > "$tmp" && mv "$tmp" "$LOCAL_SETTINGS"
  else
    printf '{\n  "autoMemoryDirectory": "%s"\n}\n' "$TARGET_DIR" > "$LOCAL_SETTINGS"
  fi
  if [ -d "$OLD_DIR" ]; then
    cp -n "$OLD_DIR"/*.md "$TARGET_DIR"/ 2>/dev/null || true
    # content-complete verification is AC2 (diff -rq), not here — script stays simple
  fi
  status
  echo "DONE. Verify in a NEW session (workspace trust dialog may appear once)."
}

revert() {  # [CR P1-2: falsification/rollback path]
  [ -f "$LOCAL_SETTINGS" ] || { echo "nothing to revert"; exit 0; }
  tmp="$(mktemp)"
  jq 'del(.autoMemoryDirectory)' "$LOCAL_SETTINGS" > "$tmp" && mv "$tmp" "$LOCAL_SETTINGS"
  echo "autoMemoryDirectory removed. .tad/memory/ left in place (data untouched)."
}

case "$MODE" in
  --enable) enable ;;
  --status) status ;;
  --revert) revert ;;
  *) echo "usage: memory-redirect.sh --enable|--status|--revert"; exit 1 ;;
esac
```

**实现提示**:
- SLUG 规则先实证:`ls -d ~/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD` 存在 ⇒ 成立;有出入则修正并记入 COMPLETION。
- 路径含空格("01-on progress programs")——所有变量展开必须加引号(伪代码已做,实现时保持)。
- jq merge 前后 `permissions` 必须**深度相等**(AC1 用 `jq -S .permissions` 前后对比,不只 keys)。[SEC P1-4]

### T3: 主仓执行启用 + 迁移 + **敏感度分级**(SEC P0-1)

```bash
bash .tad/hooks/lib/memory-redirect.sh --enable
```

然后敏感度分级(**在任何 git add 之前**):
a. 生成 `.tad/evidence/memory-migration-sensitivity-report.md`:36 个文件逐个一行:文件名 | frontmatter type | 分级(SAFE / SENSITIVE)| 理由。
   分级规则(保守,宁多勿漏):
   - `metadata.type: user` → SENSITIVE(个人画像)
   - 内容含 email / API key / token / 绝对家目录路径以外的隐私 → SENSITIVE(机械扫描:`grep -lEi '@[a-z0-9.-]+\.(edu|com|org)|api[_-]?key|token|password'` + LLM 逐文件判断)
   - 涉及未公开产品策略、第三方泄露材料分析(已知候选:`reference_claude-code-source.md`)→ SENSITIVE
   - 其余 → SAFE
b. `.gitignore` 追加(additive 段):
   ```
   # TAD memory capture layer — sensitive memories never committed (public repo; SEC P0-1)
   .tad/memory/user_*
   ```
   加上分级报告中每个非 user_ 前缀的 SENSITIVE 文件的**逐文件条目**。
c. 验证:`git check-ignore` 对每个 SENSITIVE 文件返回 0;`git status` 下 `.tad/memory/` 只出现 SAFE 文件。
d. ⚠️ 分级报告是 Gate 4 人类审查项——**commit 允许,push 禁止**(本 handoff OUT of scope;*publish 前 runbook 要求复扫)。

预期:`.tad/memory/` ≥36 个 .md;旧目录保持 36 个不动(备份);SENSITIVE 文件全部被 ignore。

### T4: 蒸馏协议扩展(ADDITIVE ONLY)

`.claude/skills/alex/references/distillation-loop-protocol.md`:在 `## Anti-Theater` 之前**新增**一节(现有行一行不动——AC4 line-set diff 验证):

```markdown
## Second Capture Source: .tad/memory/ (DR-20260712)

At the same *accept trigger, ALSO scan the native auto-memory capture layer:

1. Cursor: .tad/evidence/memory-distill-cursor stores the last-distill timestamp.
2. Scan (cursor-aware — first run has no cursor):
   if [ -f .tad/evidence/memory-distill-cursor ]; then
     find .tad/memory -name '*.md' ! -name 'MEMORY.md' -newer .tad/evidence/memory-distill-cursor
   else
     find .tad/memory -name '*.md' ! -name 'MEMORY.md'   # first run: full sweep (migrated backlog)
   fi
3. Each new/changed memory file = raw capture material. Same pipeline as journal:
   variabilize test (Step 2) → typed entry draft (Step 3) → gap detection (Step 4).
   Gap questions route to the USER (memory author is the model — no Blake round-trip).
4. READ-ONLY contract: never edit/delete files in .tad/memory/ — the native runtime owns
   that directory and its MEMORY.md ledger. Graduated entries live in project-knowledge;
   the memory original stays (user prunes via /memory if desired).
5. After the scan (regardless of graduation count): touch .tad/evidence/memory-distill-cursor
6. No memory dir / empty scan → skip silently (Codex-edition projects have no auto-memory).
```

[CR P1-1 已修:cursor 分支显式化,首跑不再对不存在的 cursor 跑 -newer]

**Guardrails**:现有 Step 1-7、Anti-Theater、blocking 语义一字不动;不修改 alex/SKILL.md body。

### T5: 文档(2 处,均 additive)

a. `CLAUDE.md` §7 之后新增:
```markdown
## 7.5 Memory Capture Layer
原生 auto-memory 已重定向至 `.tad/memory/`(via settings.local.json,DR-20260712)。
memory = Capture 层(native 自由写);*accept 蒸馏循环将其与 Blake journal 一起锻造进 project-knowledge。
`.tad/memory/` 归 native 管辖:TAD 侧只读。user 型/敏感 memory 已 gitignore(public repo)。
下游项目 opt-in:`bash .tad/hooks/lib/memory-redirect.sh --enable`。
```
b. `.claude/skills/release-runbook/SKILL.md` gotchas 加一行:"memory 在 zero-touch deny-list(lib + tad.sh 双列表,2026-07-12 起);*publish 前对 `git status` 中新增的 .tad/memory/ 文件复扫敏感度;下游项目升级后需手动 `memory-redirect.sh --enable`(opt-in)"。

### T6: .agents parity

T4 完成后:`bash .tad/hooks/lib/release-verify.sh parity --fix`(镜像 `.agents/skills/alex/references/distillation-loop-protocol.md` 已确认存在;若 runbook 也有镜像一并同步)。

### T7: 验证与提交

跑全部 §9.1 AC → `git add` 仅 SAFE 范围 → commit(**不 push**)。

### T8: 失败回退路径(AC8 falsification 时执行)[CR P1-2]

若 AC8 实测发现 autoMemoryDirectory 不生效/行为与文档不符:
1. `bash .tad/hooks/lib/memory-redirect.sh --revert`(删键,数据不动)
2. 按 friction protocol 标 BLOCKED,COMPLETION 记录实测行为
3. 矛盾事实回写 DR-20260712(Alex 在 Gate 4 处理)

**Grounded Against**(Alex step1c 实际 Read 过的源文件):
- .claude/settings.json(全文)— hooks 段不动
- .claude/settings.local.json(head 20)— permissions.allow 长列表,merge 须保留
- .gitignore(全文)— 现无 .tad/memory 规则;T3b 增段
- .claude/skills/alex/references/distillation-loop-protocol.md(全文,7 个 `## Step` 锚点)
- .tad/hooks/lib/derive-sync-set.sh(--zero-touch 实跑:10 项,无 memory)
- tad.sh L200-216(经 code-reviewer 实地验证:重复 TAD_ZERO_TOUCH + "edit BOTH" 注释 + --verify-denylist set-equality,当前 15 项 PASS)
- ~/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD/memory/(36 文件含 MEMORY.md;security-auditor 已逐文件枚举并确认含 user 画像 + 敏感引用)
- git remote(security-auditor 验证:public github.com/Sheldon-92/TAD.git)
- .tad/hooks/lib/memory-redirect.sh(new)/ .tad/memory/(new)

**AC Dry-Run Log**(Alex step1d dry-runs at 2026-07-12):
- AC1 基线:settings.local.json keys = {permissions};autoMemoryDirectory ABSENT ✅
- AC2 基线:旧目录 36 文件,MEMORY.md present ✅
- AC3 基线:lib --zero-touch grep -cx memory = 0;tad.sh --verify-denylist 当前 exit 0(15==15)✅
- AC4 基线:`grep -c '^## Step'` = 7 ✅
- AC5-AC10:post-impl;命令经语法校验 ✅

---

## 7. Files to Modify / Create

| File | Action | Micro-Task |
|------|--------|-----------|
| .tad/hooks/lib/derive-sync-set.sh | MODIFY(ZERO_TOUCH +1 词) | T2a |
| tad.sh | MODIFY(重复 TAD_ZERO_TOUCH +1 词 + count 注释) | T2b |
| .tad/hooks/lib/memory-redirect.sh | CREATE | T1 |
| .claude/settings.local.json | MODIFY(仅 +1 键,经脚本) | T3 |
| .tad/memory/(36+ 文件) | CREATE(迁移产物,选择性 track) | T3 |
| .gitignore | MODIFY(additive 敏感隔离段) | T3b |
| .tad/evidence/memory-migration-sensitivity-report.md | CREATE | T3a |
| .claude/skills/alex/references/distillation-loop-protocol.md | MODIFY(additive 新节) | T4 |
| CLAUDE.md | MODIFY(additive §7.5) | T5a |
| .claude/skills/release-runbook/SKILL.md | MODIFY(gotcha +1 行) | T5b |
| .agents/skills/alex/references/distillation-loop-protocol.md | SYNC(parity) | T6 |

## 8.4 Friction Preflight

| Prerequisite | Status | Fix path |
|---|---|---|
| jq 可用 | READY(已验证) | — |
| 旧 memory 目录存在(36 files) | READY(已验证) | — |
| workspace trust dialog | ⚠️ 一次性人工确认(AC8 验证会话) | 人类接受;若拒绝→重定向静默不生效→AC8 的负向检测就是为此 |
| tad.sh --verify-denylist 可跑 | READY(当前 15==15 PASS) | — |
| release-verify.sh parity 可跑 | READY | — |

## 8.5 Feedback Collector
feedback_required: false

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence | Verified Output |
|-----|-------------|--------------------|-------------------|-----------------|
| AC1 | settings.local.json 仅多 autoMemoryDirectory 键;permissions **深度相等** | 前后各存 `jq -S .permissions` 快照并 diff;`jq -r '.autoMemoryDirectory'` | diff 空;值为绝对路径以 .tad/memory 结尾 | (post-impl) |
| AC2 | 迁移**内容级**完整且旧目录未动 | `diff -rq ~/.claude/projects/-Users-sheldonzhao-01-on-progress-programs-TAD/memory .tad/memory` 只允许 "Only in .tad/memory" 方向差异(如后续新写入);旧目录 `ls | wc -l` = 36 | diff 无 "Only in ~/.claude..." 行(36 条全到齐,内容一致);旧目录不变 | (post-impl) |
| AC3 | **SAFETY 端到端**:memory 在两处 deny-list + drift gate + sync 集排除 | ① `derive-sync-set.sh --zero-touch | grep -cx memory` ② `grep -c '"memory"\|memory' tad.sh 的 TAD_ZERO_TOUCH 块`(实现时按实际格式写精确 grep)③ `bash tad.sh --verify-denylist; echo $?` ④ `derive-sync-set.sh --dirs | grep -cx memory` | ① 1 ② ≥1 ③ 0 ④ 0 | (post-impl;基线 0/0/0(15==15)/—) |
| AC4 | 蒸馏协议纯 additive | `comm -23 <(git show HEAD:.claude/skills/alex/references/distillation-loop-protocol.md | sort -u) <(sort -u 同文件) | wc -l`;`grep -c '^## Step'`;`grep -c '^## Second Capture Source'` | 0(无删除行);7;1 | (post-impl) |
| AC5 | CLAUDE.md §7.5 + runbook gotcha 均 additive | `grep -c 'Memory Capture Layer' CLAUDE.md`;`grep -c 'memory-redirect' .claude/skills/release-runbook/SKILL.md`;两文件同法 comm 删除侧 = 0 | ≥1;≥1;0/0 | (post-impl) |
| AC6 | .agents parity PASS | `bash .tad/hooks/lib/release-verify.sh parity` | PASS/0 drift | (post-impl) |
| AC7 | 脚本健壮 + 幂等 | `bash -n`;`--status` exit 0;二次 `--enable` 后 AC1/AC2 复跑仍 PASS;`--revert` 后 `jq -r '.autoMemoryDirectory'` = ABSENT 且 permissions 不变(测完重新 --enable) | 全部如述 | (post-impl) |
| AC8 | **实测重定向生效 + 负向检测** | Gate 4 人工:新会话(接受 trust dialog)存一条测试 memory → `ls -t .tad/memory | head -3` 出现新文件;**且旧目录文件数仍 36(负向:确认没有静默写回老家)** | 新文件在 .tad/memory/;旧目录 36 不变 | (Gate 4 human-verified) |
| AC9 | 变更范围如计划(判别性)| `git status --short` 逐行对照 §7 表:每个改动行必须能映射到 §7 的一行;§7 中 MODIFY 的 git-tracked 文件必须全部出现在 diff 中;出现表外文件 = FAIL | 一一映射,无表外条目 | (post-impl) |
| AC10 | **敏感隔离(SEC P0-1)** | 分级报告存在且 36 行全覆盖;对报告中每个 SENSITIVE 文件 `git check-ignore <file>; echo $?` = 0;对 tracked 的 memory 文件 `git ls-files .tad/memory | xargs grep -lEi '@[a-z0-9.-]+\.(edu|com|org)|api[_-]?key|password'` = 空 | 全部通过;user_* 无一 tracked | (post-impl) |

⚠️ AC8 falsification → 执行 T8 回退,不硬编 workaround。

### 9.2 Expert Review(Gate 2 audit trail)

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: tad.sh 重复硬编码 TAD_ZERO_TOUCH,只改 lib → release drift FAIL;AC3 原版测不出 | §6 T2b/T2c + AC3③(--verify-denylist 门) | Resolved |
| code-reviewer | P1-1: find -newer 在无 cursor 首跑硬报错 | §6 T4 第 2 点(显式 [ -f cursor ] 分支) | Resolved |
| code-reviewer | P1-2: AC8 证伪后留下半套配置无回退 | §6 T8 + 脚本 --revert + AC7 | Resolved |
| code-reviewer | P1-3: AC9 无判别力 | AC9 重写(逐行映射 §7 表) | Resolved |
| code-reviewer | P1-4: jq merge 仅比 keys 不够 | AC1 深度相等(jq -S .permissions diff) | Resolved |
| code-reviewer | P2×5(pipefail 注释/命名等) | 采纳进 T1 伪代码;其余 Blake 酌情 | Deferred(P2) |
| security-auditor | P0-1: public repo commit 36 条含个人画像/敏感引用 → 泄露;无内容扫描 AC | §6 T3a/T3b(分级+gitignore)+ AC10 + D1 修订(Gate 4 用户确认) | Resolved |
| security-auditor | P0-2: AC3 只测单一粒度,tad.sh 内联列表/drift gate/实际排除未验 | §6 T2(先于迁移执行)+ AC3 四断言端到端 | Resolved |
| security-auditor | P1-1: cp -n 部分拷贝,count-floor AC 抓不到 | AC2 改 diff -rq 内容级 | Resolved |
| security-auditor | P1-2: trust dialog 被拒 → 静默写回老家无检测 | AC8 增负向检测(旧目录计数不变) | Resolved |
| security-auditor | P1-3: SLUG sed 推导脆弱无预检 | T1 脚本 OLD_DIR 存在性 preflight + 实证提示 | Resolved |
| security-auditor | P1-4: permissions 深度相等 | AC1(同 CR P1-4) | Resolved |
| security-auditor | P2×4(pre-publish 复扫等) | T5b runbook gotcha 行涵盖复扫;其余 Deferred | Partially Resolved(P2) |

---

## 10. Important Notes

1. **禁止注册 hooks / 修改 settings.json**。settings 唯一触碰 = settings.local.json ±1 键,经脚本。
2. **memory 目录只读契约**:TAD 协议/脚本不写不删 `.tad/memory/`(cursor 在 evidence/)。唯一例外:T3 一次性迁移 cp。
3. **不放 README 进 .tad/memory/**(native 扫描该目录,减少干扰)。
4. **Codex edition**:无 auto-memory,目录自然为空,蒸馏扫描静默跳过。
5. **下游 rollout 是 opt-in**;下游同样受 T2 双列表保护(sync 更新 tad.sh + lib 后自动生效)。
6. **首次蒸馏全量 36 条较重**——预期一次性成本。
7. **commit 允许、push 禁止**;*publish 前按 runbook 复扫新增 memory 文件。
8. **D1 修订待确认**:原裁决"全部进 git"因 public-repo 事实修订为"选择性进 git"——Gate 4 时 Alex 需向用户明示此修订并取得确认(gate4_delta 记录)。

## 11. Decision Summary

| Decision | Choice | Why | Research source |
|----------|--------|-----|-----------------|
| 重定向 vs 关闭 vs 共存 | 重定向为 Capture 层 | 保留原生召回 + 消除抢跑 + 对齐 Capture/Distill | DR-20260712;matrix §0.1/§0.5 |
| 配置载体 | settings.local.json | 绝对路径机器特定 | S1b 链 |
| git 策略 | 选择性(SAFE track / SENSITIVE ignore) | repo 是 public;存量含个人画像 | SEC P0-1(实地验证) |
| zero-touch | lib + tad.sh 双列表 + drift gate | tad.sh 有重复硬编码列表 | CR P0-1(实地验证) |
| cursor 位置 | .tad/evidence/ | memory 目录纯 native 管辖 | §10.2 |

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/handoff-reviews/20260712-memory-redirect-code-reviewer.md
  - .tad/evidence/handoff-reviews/20260712-memory-redirect-security-auditor.md
gate_verdicts:
  - COMPLETION frontmatter gate3_verdict
completion:
  - .tad/active/handoffs/COMPLETION-20260712-memory-redirect-capture-layer.md
blake_reviews:
  - .tad/evidence/reviews/blake/memory-redirect-capture-layer/  # ≥2 distinct reviewers (mixed tier)
sensitivity_report:
  - .tad/evidence/memory-migration-sensitivity-report.md
knowledge_updates:
  - conditional: Gate 3 KA
```
