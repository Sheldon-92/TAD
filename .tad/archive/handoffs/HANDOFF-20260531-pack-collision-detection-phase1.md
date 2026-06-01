---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: code       # code | yaml | research | e2e | mixed
e2e_required: no      # yes | no - yes 时 Blake 必须产出 E2E evidence
research_required: no # yes | no - yes 时 Blake 必须产出研究文件

# Production directories that must have ≥1 git-tracked file at Gate 3
git_tracked_dirs: [".tad/scripts", ".tad/capability-packs", ".tad/guides", ".tad/evidence/fixtures"]

skip_knowledge_assessment: no  # yes | no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-31
**Project:** TAD Framework — Pack Collision Detection
**Task ID:** TASK-20260531-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260531-pack-collision-detection.md (Phase 1/2)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-31 14:00

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 混合检测 (grep-seed + LLM-confirm)、precedence 引擎、pack-collisions.yaml schema、3 fixtures、reference doc 全部在 grounding 文件中有 file:line 验证 |
| Components Specified | ✅ | scan-collisions.sh 镜像 scan-packs.sh；签名清单；YAML schema；fixtures；guide 均明确指定路径与内容 |
| Functions Verified | ✅ | 镜像 scan-packs.sh 既有函数 (extract_frontmatter_field/extract_keywords)；无对不存在函数的调用 |
| Data Flow Mapped | ✅ | pack files → grep-seed → candidates.yaml → LLM-confirm → pack-collisions.yaml → (P2) consumers surface one-liner |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。本 Phase 仅创建新文件，零 SKILL 编辑。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（检测两个共载 pack 的矛盾指令，不是评估单 pack 质量）
- [ ] 每个交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
P1 of the Pack Collision Detection Epic: the **collision-detection engine + its data + fixtures**, using ONLY new files. We build:
1. `scan-collisions.sh` — the GREP-SEED half of a hybrid detector. For each pack pair sharing ≥1 keyword, it greps curated opposing-directive signatures and emits CANDIDATE collisions.
2. A documented **LLM-CONFIRM contract** — a procedure an agent follows to confirm each candidate is a true opposing directive, assign a category per side, and compute resolution → final `pack-collisions.yaml`.
3. The **precedence resolution engine semantics** (documented in the guide).
4. **3 acceptance fixtures** from the verified real contradictions (Inter / contrast / pyramid).
5. A **reference doc** (`.tad/guides/pack-collision-detection.md`).

### 1.2 Why We're Building It
**业务价值**：Closes the cross-model-audit gap "zero collision detection" (architecture.md "YOLO Audit Findings 2026-05-15"). Two co-loaded packs can issue contradicting directives (one bans `Inter`, another endorses it) with no mechanism to detect or resolve.
**用户受益**：When ≥2 packs load, the system can auto-resolve cross-category contradictions by precedence (with a VISIBLE log) and escalate same-category ties to the human, instead of silently following one rule and violating the other.
**成功的样子**：当 `scan-collisions.sh` 跑过真实 packs，输出覆盖 3 个已知矛盾对的 candidate；LLM-confirm 产出的 `pack-collisions.yaml` 对 3 个矛盾各有正确 category + resolution；每个 collision 的 file:line 可被 acceptance 手工复核 (count≠signal)。

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：检测两个**共同加载**的 capability pack 是否发出**互相矛盾**的指令，并按 precedence 自动解决跨类别冲突、升级同类别冲突给人类。

**不是要做的（避免误解）**：
- ❌ 不是评估单个 pack 自身质量（那是 lean-trustworthy 的 P5 behavioral eval — 正交）。
- ❌ 不是运行时 / 每会话检测 — 这是 build-time 工具。
- ❌ 不是自动修改 / 修复 pack 内容。
- ❌ 不是编辑 `alex/SKILL.md` step4_5 或 `blake/SKILL.md` 1_5a — 那是 **P2**，本 Phase 零 SKILL 编辑。
- ❌ 不是写入 `pack-registry.yaml` — 它是 READ-ONLY 输入（P5 的另一个 Alex 写 `behaviorally_verified` 进去；我们写独立的 `pack-collisions.yaml`）。

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. grep-seed 和 LLM-confirm 各自的职责边界是什么？
3. 成功的标准是什么（特别是为什么 "N collisions found" 不是验收）？
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed in 步骤 2 below
2. Read this handoff's "⚠️ Blake 必须注意的历史教训" entries carefully
3. This is NOT optional — project knowledge prevents repeated mistakes

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] code-quality - bash 脚本模式 / grep 计数陷阱
- [x] architecture - 验证剧场反模式、parser 自触发、混合检测
- [x] security - heredoc 注入边界（文件写 vs 解释器执行）
- [ ] ux / performance / api-integration / mobile-platform

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 4+ | (1) "Ad-hoc Dead Code Audit Tools Are Themselves Validation Theater" (2026-05-30) — grep 扫描器自身就是验证剧场，每个 flagged item 必须 spot-verify；(2) "Parser Self-Trigger" (2026-05-30) — 描述某 parser 模式的散文会自触发该 parser；(3) "A Parser Feeding a Human-Review Queue Must Propagate VALUE Fields" (2026-05-31) — 抽 key 必须连带抽 value；(4) "YOLO Audit Findings 2026-05-15" — 这就是本 Epic 要堵的 "zero collision detection" 缺口 |
| code-quality.md | 2 | (1) "AC Verification Command Bug: grep -ocE \| sort -u \| wc -l" (2026-05-27) — `grep -c` + `sort -u \| wc -l` 永远返回 1；唯一匹配计数用 `grep -oE \| sort -u \| wc -l`；(2) "Heredoc injection depends on the SINK" (2026-05-31) — 文件写 heredoc (`cat > f`) ≠ 解释器执行 heredoc (`python3 -c`)；前者只需换行展平 |
| security.md | 0 | ✅ 已检查，无直接相关（pack scope 边界知识，非本任务） |

**⚠️ Blake 必须注意的历史教训**：

1. **Ad-hoc 审计工具本身就是验证剧场** (architecture.md, 2026-05-30)
   - 问题：grep/regex dead-code 扫描器自信地输出 binary verdict，大多是 false positive。一个 collision 扫描器有同样风险。
   - 解决方案：每个 flagged collision 必须 hand-re-derive 其 file:line（见 AC2/AC3/AC6）。reference doc 必须明文写 "N collisions found 不是验收"。

2. **Parser Self-Trigger** (architecture.md, 2026-05-30)
   - 问题：任何**散文里引用 parser 字面匹配模式**的工件会自触发该 parser。本任务的 `collision-signatures` 文件就是一组会被 grep 的字面模式 — 在 guide / fixtures 里描述它们时不要把签名字面量裸放在会被 scan 的 pack 文件路径下。
   - 解决方案：签名清单只放在 `.tad/scripts/`（NOT 在被扫描的 pack 目录），fixtures 放在 `.tad/evidence/fixtures/` 而非 capability-packs/ 下。

3. **grep -c 计数陷阱** (code-quality.md, 2026-05-27)
   - 问题：`grep -c PATTERN file | sort -u | wc -l` 永远返回 1。
   - 解决方案：要唯一匹配数用 `grep -oE 'a|b|c' file | sort -u | wc -l`（去掉 `-c`）。脚本里任何 "去重计数" 都遵此。

4. **Heredoc 注入取决于 SINK** (code-quality.md, 2026-05-31)
   - 问题：reviewer 易把 `cat > f <<EOF ... ${VAR} ... EOF` 误判为命令注入 P0。
   - 解决方案：文件写 heredoc 只把值当数据流插入、不再 re-scan；真正残留风险是换行 → 用 `gsub("\n";" ")` / sed 展平。只有 `python3 -c <<EOF`/`eval`/`source` 才是注入。本脚本不得用解释器 heredoc 注入用户/文件内容。

### Blake 确认
- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
- `.tad/scripts/scan-packs.sh` (184 lines) — the SIBLING to mirror. It auto-generates `pack-registry.yaml`. Conventions to copy verbatim: `set -euo pipefail`; `SCRIPT_DIR`/`TAD_DIR` derivation; arg-parse-BEFORE-deriving-OUTPUT; anchored awk frontmatter extraction (`awk '/^---$/{if(++n==2) exit} n==1 && /^field: /'`); single-line flow-form keywords. ⚠️ **Mirror the CONVENTIONS, NOT the directory**: scan-packs.sh uses `PACKS_DIR="$TAD_DIR/capability-packs"`, but scan-collisions.sh scans `SKILLS_DIR=.claude/skills` instead (the runtime-loaded tree — see FR1/§4.2A/P0-2).
- `.tad/capability-packs/pack-registry.yaml` — auto-generated; has `packs:` list each with name/description/path/consumes/produces/keywords/type. **READ-ONLY** for us.

### 2.2 Current State vs Target
- Current: no mechanism to detect cross-pack contradictions. 3 real contradictions exist live (Inter / APCA-vs-WCAG / testing-pyramid) — verified file:line in the grounding file.
- Target: a grep-seed detector + documented LLM-confirm contract that produces `pack-collisions.yaml`; precedence engine semantics documented; 3 fixtures; reference doc. NO SKILL edits, NO registry writes.

### 2.3 Dependencies
None for execution — reads `pack-registry.yaml` + pack files only. **Concurrency**: the other Alex runs lean-trustworthy P4/P5 in this repo (P4 = `verify-ac-commands.sh` new file at alex step1d; P5 writes `behaviorally_verified` into `pack-registry.yaml`). P1 creates ONLY new files → safe to build concurrently. Blake sub-agent uses worktree isolation.

---

## 3. Requirements

### 3.1 Functional Requirements
- **FR1**: Create `.tad/scripts/scan-collisions.sh` — the GREP-SEED detector. It enumerates packs from `.claude/skills/*/SKILL.md` and scans **that tree** (`.claude/skills/{pack}/`) — the runtime-loaded tree where the contradictions + P2 consumers live. Mirrors `scan-packs.sh` CONVENTIONS exactly (`set -euo pipefail`; SCRIPT_DIR/TAD_DIR derivation; arg-parse-before-OUTPUT-derive; anchored awk frontmatter; BSD-safe) — but the scan dir is `.claude/skills/`, NOT `.tad/capability-packs/`. The mirror is about conventions, not the literal PACKS_DIR. `--help` exits 0 clean.
- **FR2**: For each pack PAIR that shares ≥1 keyword, scan curated **opposing-directive signatures** and emit CANDIDATE collisions (to a staging file at `.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml`). The seed signature set MUST cover the 3 known pairs: web-ui-design×web-frontend (Inter), web-ui-design×web-frontend/web-testing (contrast), web-frontend×web-testing (pyramid). Each candidate records both sides' file:line. **Pack file set (explicit)**: for each pack the scan set = `find "$skill_dir" -name '*.md'` excluding `CHANGELOG.md`, `LICENSE*`, `README.md`. Signatures grep this set with `grep -nE`.
- **FR3**: Create `.tad/scripts/collision-signatures.txt` (or inline list in the script) — curated opposing-directive grep signatures; the seed set covers the 3 fixtures.
- **FR4**: Create `.tad/capability-packs/pack-collisions.yaml` — the CONFIRMED-collision registry (final, post-LLM-confirm). Separate file from `pack-registry.yaml`. Populated for the 3 confirmed collisions with the full schema (see §4.3).
- **FR5**: Document the **LLM-CONFIRM contract** in the guide — a procedure an agent follows to (a) confirm each candidate is a TRUE opposing directive (not a co-mention), (b) assign a category per side, (c) compute resolution, (d) write `pack-collisions.yaml`, dropping false positives.
- **FR6**: Document the **precedence engine semantics** in the guide: ordered categories `security/safety/compliance/data-integrity(1) > correctness(2) > a11y(3) > performance(4) > style(5)`; CROSS-category → auto-resolve (lower-number wins) + visible log; SAME-category → escalate. ALL resolutions (auto + escalated) logged (no-silent-caps).
- **FR7**: Document the **surfacing one-liner formats** (for P2 consumers): cross-cat → `⚙️ resolved: {winner} over {loser} ({rule})`; same-cat → `⚠️ unresolved: {a} vs {b} — human decides ({topic})`.
- **FR8**: Create the **3 fixtures** under `.tad/evidence/fixtures/pack-collisions/` — each with the contradiction + expected classification (cross-cat-resolve / same-cat-escalate).
- **FR9**: Document the **anti-validation-theater acceptance rule** in the guide: acceptance hand-re-derives every flagged collision's file:line; "N collisions found" is NOT acceptance.

### 3.2 Non-Functional Requirements
- **NFR1**: BSD-safe only (macOS): NO `grep -P`, NO `\d`, NO `.*?`, NO `readlink -f`. Use `grep -E` / `-o` + `sed`.
- **NFR2**: `scan-collisions.sh` is a CLI tool (fail-fast `set -euo pipefail` OK) — **NOT a registered hook**. MUST NOT be added to `.claude/settings.json`.
- **NFR3**: Determinism in grep-seed (no LLM), false-positive defense in LLM-confirm. Per 2026-05-30, a pure-grep collision-scanner is itself validation-theater-prone — the split is mandatory.
- **NFR4**: ZERO edits to `alex/SKILL.md` / `blake/SKILL.md`; `pack-registry.yaml` unmodified.

---

## 4. Technical Design

### 4.1 Architecture Overview — Hybrid Two-Stage Detection

```
pack files + pack-registry.yaml
        │
        ▼  (STAGE 1 — deterministic, scan-collisions.sh)
  GREP-SEED: for each pack-pair sharing ≥1 keyword,
             grep curated opposing-directive signatures
        │
        ▼
  pack-collisions.candidates.yaml   (staging — candidate collisions, both-side file:line)
        │
        ▼  (STAGE 2 — agent procedure, LLM-CONFIRM contract in guide)
  CONFIRM each candidate is a TRUE opposing directive (not a co-mention),
  assign category per side, compute resolution, drop false positives
        │
        ▼
  pack-collisions.yaml   (final confirmed registry)
        │
        ▼  (P2 — NOT this phase) consumers read + surface one-liner
```

The split keeps **determinism** (grep) AND **false-positive defense** (LLM-confirm). A pure-grep scanner that auto-emits the final registry would be validation theater.

### 4.2 Component Specifications

**(A) `scan-collisions.sh` — the grep-seed half**
- Header conventions copied from `scan-packs.sh`: `set -euo pipefail`; `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`; `TAD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"`. **Scan target is the runtime-loaded tree, NOT `$TAD_DIR/capability-packs`**: `SKILLS_DIR="..."` resolved from the repo root, default `.claude/skills` (e.g. `REPO_ROOT="$(cd "$TAD_DIR/.." && pwd)"; SKILLS_DIR="$REPO_ROOT/.claude/skills"`). The mirror is about conventions (set -e, arg-parse-before-OUTPUT, anchored awk, BSD-safe), NOT the literal directory.
- Arg-parse loop BEFORE deriving OUTPUT. OUTPUT (staging) = `.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml` (evidence dir, NOT inside `.tad/capability-packs/`). Support `--help|-h` (echo usage, exit 0) and `--skills-dir=*`.
- Enumerate packs as `.claude/skills/*/SKILL.md`. Reuse anchored awk frontmatter extraction for `keywords:` (single-line flow form) from each `SKILL.md` to compute the keyword set per pack and find pairs sharing ≥1 keyword.
- For each qualifying pair, run each curated signature pair (a BAN-side regex against pack_a's file set + an ENDORSE-side regex against pack_b's file set — per-pack file set = `find "$skill_dir" -name '*.md'` minus CHANGELOG.md/LICENSE*/README.md, see P1-1). When BOTH sides match, emit a candidate with: pack_a, pack_b, topic, a_match (file:line + matched text), b_match (file:line + matched text).
- For locating file:line of a match: use `grep -nE 'pattern' file` (gives `line:text`), BSD-safe. For any **unique-match count**, use `grep -oE 'pat' file | sort -u | wc -l` — **NEVER** `grep -c | sort -u | wc -l` (always returns 1).
- Output is data written via `printf`/`cat > "$OUTPUT" <<EOF` file-write heredoc — flatten any embedded newlines from matched text with sed/`tr` before insertion. (File-write heredoc is NOT injection; do NOT use an interpreter heredoc on file content.)

**(B) `collision-signatures.txt` (or inline) — curated opposing-directive signatures**
- A small curated seed set covering the 3 fixtures. Each entry pairs a topic with two opposing BSD-safe `-E` regex signatures (side A vs side B). Example shape (illustrative — Blake curates exact regex against live files):
  - topic=`inter-font`: A=`NEVER use Inter` (style ban) vs B=`Inter.*next/font|family=Inter` (perf endorse)
  - topic=`contrast-standard`: A=`APCA` vs B=`4\.5:1`
  - topic=`testing-pyramid`: A=`Unit ~?60%|E2E .*cut` vs B=`Unit.*70%|More E2E`
- Document keyword overlap is the PRE-FILTER (only scan pairs sharing ≥1 keyword) so the seed set stays small and false positives low.
- ✅ **VERIFIED (architect, against live registry)**: the 3 target pairs DO each share ≥1 keyword — ui-design×frontend share `frontend,accessibility`; frontend×testing share `performance,accessibility`; ui-design×testing share `accessibility`. The pre-filter therefore passes for all 3 pairs. Blake MUST still run the dry-run confirm step (§6 step 2) against the live `.claude/skills/*/SKILL.md` keywords before writing signatures, but no fallback design is needed for the 3 known pairs.

**(C) LLM-CONFIRM contract (documented procedure — guide §)**
- A numbered procedure an agent follows when (re)generating `pack-collisions.yaml`:
  1. Read `pack-collisions.candidates.yaml`.
  2. For each candidate, open both file:line refs and confirm it is a **true opposing directive** (an actual contradiction in intent), NOT a co-mention (e.g. both files merely naming "Inter" without conflicting prescription).
  3. Assign a `category` per side from the category list (§4.4).
  4. Compute `resolution` via the precedence engine (§4.4).
  5. Write the confirmed row into `pack-collisions.yaml`; DROP candidates judged false positive (record drop rationale in the candidate's comment or the guide's worked example).
- **REQUIRED fields per candidate (converts the doc-only defense into a fillable contract — P1-2)**: every confirmed AND every dropped candidate MUST carry two fields:
  - `confirmed_by`: which refs the agent actually opened to confirm (e.g. `opened web-ui-design/SKILL.md:93 + web-frontend/references/performance.md:215`).
  - `drop_rationale`: for false positives, why it was dropped (e.g. `co-mention: both name Inter, no conflicting prescription`).
- The **co-mention drop worked-example is MANDATORY content of the guide** (NOT an optional §8.3 edge case) — the guide must show one concrete false-positive candidate and its `drop_rationale`, demonstrating the confirming agent opened both refs.
- This is a documented procedure, not code — there is NO LLM call inside `scan-collisions.sh`.

**(D) Precedence engine — see §4.4.**

**(E) Surfacing one-liner formats (for P2) — see §4.5.**

### 4.3 Data Models

**`pack-collisions.yaml` schema** (one row per confirmed collision):
```yaml
collisions:
  - pack_a: web-ui-design
    pack_b: web-frontend
    topic: inter-font
    a_says:
      ref: ".claude/skills/web-ui-design/SKILL.md:93"     # hand-re-derive at acceptance
      quote: "NEVER use Inter, Roboto, Arial, or system-ui as the primary typeface."
      category: style
    b_says:
      ref: ".claude/skills/web-frontend/references/performance.md:215"
      quote: "import { Inter } from 'next/font/google'  (✅ font-loading optimization)"
      category: performance
    resolution: auto
    winner: web-frontend       # performance(4) > style(5)
    loser: web-ui-design
    rule: "performance>style"
    logged: true
  - pack_a: web-ui-design
    pack_b: web-frontend       # also web-testing (a11y) — see notes
    topic: contrast-standard
    a_says: { ref: ".claude/skills/web-ui-design/SKILL.md:454", quote: "Validate contrast with APCA (LC ≥60 body, ≥45 large)", category: a11y }
    b_says: { ref: ".claude/skills/web-frontend/references/accessibility.md:45", quote: "Minimum 4.5:1 (normal), 3:1 (large) — WCAG 2.2 SC 1.4.3", category: a11y }
    resolution: escalate
    reason: same-category        # a11y vs a11y — precedence cannot break the tie
    logged: true
  - pack_a: web-frontend
    pack_b: web-testing
    topic: testing-pyramid
    a_says: { ref: ".claude/skills/web-frontend/references/testing.md:15", quote: "Unit ~60%; E2E ~10%; if E2E >20% — cut", category: testing }
    b_says: { ref: ".claude/skills/web-testing/references/test-strategy-rules.md:25", quote: "Unit 70%; E2E 10%; UI-heavy app: More E2E", category: testing }
    resolution: escalate
    reason: same-category        # testing vs testing (correctness band)
    logged: true
```
- Each row's `ref` (file:line) MUST be hand-re-derivable against the live pack files at acceptance.
- ✅ **Invariant (P0-2 — canonical tree)**: collision refs are recorded against `.claude/skills/` (the runtime-loaded tree that the P2 surfacing consumers actually load); `.tad/capability-packs/` is a source copy kept in sync by `*sync`. The scanner (§4.2A) reads `.claude/skills/` too, so scanner output, schema refs, and acceptance hand-re-derivation all anchor to the SAME physical files. This guide content requirement must be stated in `pack-collision-detection.md`.
- Note: contrast collision touches 3 packs (ui-design APCA vs frontend WCAG vs testing WCAG). Represent as the ui-design×frontend pair plus a comment noting web-testing/accessibility-testing-rules.md:12 also carries the WCAG side (same-category escalate either way).

### 4.4 Precedence Engine Semantics (documented in guide)

Ordered categories (highest precedence → lowest):
1. `security / safety / compliance / data-integrity` (non-overridable)
2. `correctness`
3. `accessibility (a11y)`
4. `performance`
5. `style / aesthetic`

- **CROSS-category collision** → auto-resolve: the **lower category NUMBER wins**. Record `winner`, `loser`, both `category`, the `rule` string that fired (e.g. `performance>style`), and a visible log line. The Inter case is the dangerous one — a legit `next/font` use must not be silently killed; the log lets a human verify Inter isn't the *primary* typeface.
- **SAME-category collision** → precedence tie → **ESCALATE** to human (no silent pick). Record `resolution: escalate`, `reason: same-category`.
- **No-silent-caps rule**: EVERY resolution (auto AND escalated) is logged visibly.
- **Category list completeness (P1-4)**: the list `security/safety/compliance/data-integrity(1) > correctness(2) > a11y(3) > performance(4) > style(5)` is **CLOSED for P1, EXTENSIBLE in P2**. Known-missing directive classes that already exist in the live pack set (NOT covered by the 5 categories): **licensing/legal** and **cost/economic** (present in `ai-voice-production` license + cost refs, `ml-training` cloud-GPU cost). **Fallback rule**: if EITHER side's directive cannot be cleanly categorized into the closed list → `resolution = ESCALATE` (never a silent auto-resolve). This fallback MUST be stated in the guide too — an out-of-list category in a "no silent pick" precedence engine must escalate, not guess.

### 4.5 Surfacing One-Liner Formats (for P2 consumers — specified now)

- Cross-cat (auto-resolved): `⚙️ resolved: {winner} over {loser} ({rule})`
  - e.g. `⚙️ resolved: web-frontend over web-ui-design (performance>style)`
- Same-cat (escalated): `⚠️ unresolved: {a} vs {b} — human decides ({topic})`
  - e.g. `⚠️ unresolved: web-ui-design vs web-frontend — human decides (contrast-standard)`

These are the contract P2 reads from `pack-collisions.yaml` and surfaces in Alex step4_5 / Blake 1_5a. P1 only SPECIFIES them.

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
**回答**: [x] 是 — 用户/grounding 提到要 MIRROR `scan-packs.sh`。
- **找到了什么**: `scan-packs.sh` 既有约定 + `extract_frontmatter_field`/`extract_keywords` 函数可复用模式。
- **位置**: `.tad/scripts/scan-packs.sh:14-64`。
- **决定**: ✅ 复用约定与抽取模式（新文件 scan-collisions.sh，不改 scan-packs.sh）。
- **原因**: grounding 明确要求镜像；保持工具家族一致。

### MQ2: 函数存在性验证
| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| extract_frontmatter_field (模式来源) | .tad/scripts/scan-packs.sh | 47-54 | `awk '/^---$/{if(++n==2) exit} n==1 && /^'"$field"': /'` | ✅ 存在（镜像，不调用） |
| extract_keywords (模式来源) | .tad/scripts/scan-packs.sh | 59-64 | `awk ... /^keywords: /` | ✅ 存在（镜像） |
- 本任务不调用既有函数，而是在新文件里复刻同款 BSD-safe 模式。无对不存在函数的调用。

### MQ3: 数据流完整性
| 后端字段 | 用途说明 | 下游消费 | 是否传递 | 备注 |
|---------|---------|---------|---------|------|
| candidate {pack_a,pack_b,topic,a_match,b_match} | grep-seed 输出 | LLM-confirm | ✅ | 含双侧 file:line |
| pack-collisions.yaml row (全 schema) | 确认后注册 | P2 consumers | ✅ | category+resolution 全填 |
- ⚠️ 重要（architecture.md 2026-05-31）：candidate→confirmed 时必须**连带传递 VALUE 字段**（quote、file:line），不能只抽 topic/key。

### MQ4: 视觉层级
[x] 有不同状态：cross-cat auto-resolve vs same-cat escalate。
| 状态 | 一行格式 | 标记 |
|------|---------|------|
| auto-resolved | `⚙️ resolved: {winner} over {loser} ({rule})` | ⚙️ |
| escalated | `⚠️ unresolved: {a} vs {b} — human decides ({topic})` | ⚠️ |

### MQ5: 状态同步
| 数据 | 存储位置1 | 存储位置2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| candidates | pack-collisions.candidates.yaml (staging) | pack-collisions.yaml (final) | LLM-confirm pass | candidates → final (单向) |
- 主状态 = `pack-collisions.yaml`（confirmed）。candidates 是中间产物。`pack-registry.yaml` 是只读输入，绝不写。

---

## 6. Implementation Steps

### 交付物
- [ ] `.tad/scripts/scan-collisions.sh` (CREATE)
- [ ] `.tad/scripts/collision-signatures.txt` (CREATE) — 或 inline 在脚本内的签名清单
- [ ] `.tad/capability-packs/pack-collisions.yaml` (CREATE)
- [ ] `.tad/guides/pack-collision-detection.md` (CREATE)
- [ ] `.tad/evidence/fixtures/pack-collisions/{inter,contrast,pyramid}.md` (CREATE) — 3 fixtures + expected classification

### 实施步骤

1. **scan-collisions.sh — 头部与约定（镜像 scan-packs.sh 约定，但扫描 `.claude/skills/`）**
   - 首行 `#!/usr/bin/env bash`，紧接 `set -euo pipefail`。
   - `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`；`TAD_DIR`；`REPO_ROOT="$(cd "$TAD_DIR/.." && pwd)"`；`SKILLS_DIR="$REPO_ROOT/.claude/skills"`（**运行时加载树，NOT `$TAD_DIR/capability-packs`** — 矛盾源与 P2 消费者都在这里）。
   - **Arg-parse 循环放在 OUTPUT 推导之前**：`--help|-h`（echo usage，exit 0）、`--skills-dir=*`。然后 OUTPUT（staging）= `.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml`（evidence 目录，NOT 在 `.tad/capability-packs/` 内）。
   - `if [ ! -d "$SKILLS_DIR" ]; then echo "ERROR..." >&2; exit 1; fi`。

2. **scan-collisions.sh — 关键词抽取与配对**
   - 枚举 packs：`.claude/skills/*/SKILL.md`。复刻 anchored awk frontmatter 抽取：`awk '/^---$/{if(++n==2) exit} n==1 && /^keywords: /'`（单行 flow form）从每个 pack 的 **SKILL.md** frontmatter 取 keywords（同款 anchored awk 模式在 SKILL.md frontmatter 上一样工作）。
   - 计算所有 pack 两两配对中**共享 ≥1 keyword** 的对（pre-filter）。BSD-safe：用 `grep -oE` + `sort -u` 求交集，**不用** `grep -c | sort -u | wc -l`。
   - ✅ **已验证（architect）**：3 个目标对各共享 ≥1 keyword（ui-design×frontend: `frontend,accessibility`；frontend×testing: `performance,accessibility`；ui-design×testing: `accessibility`）→ pre-filter 对 3 对全通过。Blake 仍须对 live `.claude/skills/*/SKILL.md` keywords 跑 dry-run 确认后再写签名。

3. **scan-collisions.sh — 签名扫描与 candidate 发射**
   - 读 `collision-signatures.txt`（topic + A 侧 `-E` regex + B 侧 `-E` regex）。
   - **Pack 文件集（明确定义 — P1-1）**：每个 pack 的扫描集 = `find "$skill_dir" -name '*.md'`，排除 `CHANGELOG.md`、`LICENSE*`、`README.md`。签名用 `grep -nE` 跑这个集合。
   - 对每个 qualifying pair × 每条签名：在 pack_a 文件集跑 A 侧 `grep -nE`，在 pack_b 文件集跑 B 侧 `grep -nE`；两侧都命中→发射 candidate。
   - **签名特异性（P1-3）**：每条种子签名必须 dry-run 验证它**只**命中目标矛盾行（把命中行记入 candidates evidence），用锚定签名（如 `NEVER use Inter` 而非裸 `Inter` — 后者会误命中 `INP (Interaction...)`）。
   - candidate 记录 `pack_a, pack_b, topic, a_ref(file:line), a_quote, b_ref(file:line), b_quote`。用 `grep -nE` 取 `line:text`，再 sed 提取行号与文本；插入前用 `tr -d '\r'` / sed 把 quote 展平为单行（file-write heredoc，非注入）。
   - 种子签名集必须使 scan 覆盖 3 个已知对：web-ui-design×web-frontend (Inter)、web-ui-design×web-frontend/web-testing (contrast)、web-frontend×web-testing (pyramid)。
   - 把所有 candidate 写入 `$OUTPUT`（`.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml`）。

4. **collision-signatures.txt**
   - 写 3 条种子签名（inter-font / contrast-standard / testing-pyramid），每条含 topic + 两侧 BSD-safe `-E` 正则。注释说明 keyword-overlap 是 pre-filter。⚠️ 此文件放 `.tad/scripts/`（NOT 被扫描的 pack 目录）以避免 parser self-trigger。

5. **pack-collisions.yaml**
   - 按 §4.3 schema 手工填 3 个 confirmed collisions（Inter→auto/performance>style，contrast→escalate/same-category-a11y，pyramid→escalate/same-category-testing）。每行 file:line 必须能对照 live pack 文件复核。

6. **.tad/guides/pack-collision-detection.md**
   - 写：混合检测流程（§4.1 图）、precedence 引擎语义（§4.4，含分类列表与 no-silent-caps）、category 列表、resolution 语义（cross→auto+log / same→escalate）、surfacing 一行格式（§4.5）、LLM-confirm 契约（§4.2C 编号步骤）、**anti-validation-theater 验收规则**（"N collisions found 不是验收；acceptance 手工复核每个 file:line"）。明文写：scan-collisions.sh 是 CLI 工具、非 hook、绝不进 settings.json。
   - 还必须写入这些不变量：(a) **canonical-tree 不变量（P0-2）**：collision refs 记录在 `.claude/skills/`（运行时加载树），`.tad/capability-packs/` 是 `*sync` 保持同步的源副本；(b) **uncategorizable→escalate 回退规则（P1-4）**：category 列表 P1 封闭、P2 可扩展，已知缺失类 licensing/legal、cost/economic；任一侧无法归类 → ESCALATE，绝不静默 auto-resolve；(c) **co-mention drop worked-example（P1-2）** 为 MANDATORY 内容（含 `confirmed_by` + `drop_rationale`），非 optional edge case。

7. **fixtures（3 个）**
   - `.tad/evidence/fixtures/pack-collisions/inter.md`：Inter 矛盾 + expected `cross-cat-resolve (performance>style, winner=web-frontend)`。
   - `.../contrast.md`：APCA-vs-WCAG + expected `same-cat-escalate (a11y)`。
   - `.../pyramid.md`：testing-pyramid + expected `same-cat-escalate (testing)`。
   - 每个 fixture 含双侧 file:line 引用（acceptance 据此手工复核）。

8. **自检（提交前）**
   - `bash -n .tad/scripts/scan-collisions.sh` 通过；`bash .tad/scripts/scan-collisions.sh --help` exit 0。
   - `grep -c 'set -euo pipefail' .tad/scripts/scan-collisions.sh` == 1。
   - 脚本内无 `grep -P` / `\d` / `.*?` / `readlink -f`；无 `grep -c ... | sort -u | wc -l`。
   - `git diff --name-only` 只含新文件；`alex/SKILL.md`、`blake/SKILL.md`、`pack-registry.yaml` 不在其中。
   - `grep -c 'scan-collisions' .claude/settings.json` == 0。

### Grounded Against (Alex step1c — 实际 Read 过的源文件)

> 本 handoff 起草时 Alex 实际 Read / 验证过的源文件（2026-05-31）：

- `.tad/scripts/scan-packs.sh` (head 80 lines, read 2026-05-31) — 镜像约定来源（set -euo pipefail / SCRIPT_DIR / arg-parse-before-OUTPUT / anchored awk frontmatter / 单行 keywords）。
- `.tad/capability-packs/pack-registry.yaml` — READ-ONLY 输入（packs 列表 + keywords）。*(new code reads it; not modified)*
- `.claude/skills/web-ui-design/SKILL.md` (lines ~90-99 verified live 2026-05-31) — Inter 禁令 + APCA 矛盾源 (Fixture 1 & 2 A 侧)。
- `.claude/skills/web-frontend/references/performance.md` (lines ~205-216 verified live 2026-05-31) — Inter/next/font 背书 (Fixture 1 B 侧)；`references/accessibility.md:45` WCAG (Fixture 2 B 侧)；`references/testing.md:15` pyramid (Fixture 3 A 侧)。
- `.claude/skills/web-testing/references/test-strategy-rules.md:25` + `references/accessibility-testing-rules.md:12` — pyramid B 侧 + WCAG 第三方 (per grounding file:line)。
- `.tad/evidence/yolo/pack-collision-detection/phase1-grounding.md` — 矛盾 fixtures (file:line)、镜像约定、precedence 语义、混合检测契约的 source of truth。
- `.tad/active/epics/EPIC-20260531-pack-collision-detection.md` (Phase 1 Detail Block) — Scope/Input/Output/AC1-AC8/Files-Likely-Affected = the contract.
- `.tad/templates/handoff-a-to-b.md` — section numbering.

> *(new — will be created)*: scan-collisions.sh, collision-signatures.txt, pack-collisions.yaml, pack-collision-detection.md, fixtures/*.

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/scripts/scan-collisions.sh                          # grep-seed candidate detector (NOT a hook)
.tad/scripts/collision-signatures.txt                    # curated opposing-directive signatures (3-fixture seed)
.tad/capability-packs/pack-collisions.yaml               # confirmed-collision registry (post-LLM-confirm)
.tad/guides/pack-collision-detection.md                  # reference doc (flow, precedence, contract, anti-theater rule)
.tad/evidence/fixtures/pack-collisions/inter.md          # Fixture 1 — cross-cat-resolve
.tad/evidence/fixtures/pack-collisions/contrast.md       # Fixture 2 — same-cat-escalate (a11y)
.tad/evidence/fixtures/pack-collisions/pyramid.md        # Fixture 3 — same-cat-escalate (testing)
```
(Staging file `.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml` is produced by running the script — written to the evidence dir, NOT inside `.tad/capability-packs/`, to avoid polluting the auto-generated registry space and to resolve the gitignore-vs-tracked tension.)

### 7.2 Files to Modify
```
(none — P1 is new-files-only. ZERO SKILL edits. pack-registry.yaml read-only.)
```

---

## 8. Testing Requirements

### 8.1 / 8.2 Functional Checks
- `bash -n scan-collisions.sh` parses clean; `--help` exits 0.
- Running over real packs emits candidates covering all 3 known pairs (verify by hand-re-deriving each candidate's two file:line — NOT a count).
- `pack-collisions.yaml` rows' file:line each resolve against live pack files.

### 8.3 Edge Cases
- A pack pair sharing a keyword but with NO opposing-signature match → emits NO candidate (no false positive).
- A matched quote containing a newline → flattened to single line in output (file-write heredoc safety).
- Co-mention (both name "Inter" with no conflicting prescription) → LLM-confirm DROPS it (documented in guide worked example).

### 8.4 Test Evidence Required
- [ ] `bash -n` + `--help` exit-0 output.
- [ ] candidates.yaml content + hand-re-derivation notes for the 3 pairs.
- [ ] `git diff --name-only` showing only new files.

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当 AC1-AC8（见 §9.1）全部 PASS，且每个 collision 的 file:line 经**手工复核**（count≠signal）。

## 9.1 Spec Compliance Checklist (for automated verification)

> 来自 Epic Phase 1 Detail Block AC1-AC8，逐条转录 + 验证命令。
> ⚠️ AC2/AC3/AC6：acceptance 必须 **HAND-RE-DERIVE** 每个 collision 的 file:line，**count 不是 signal**（2026-05-30 dead-code-scanner-is-theater 教训）。

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence |
|---|---------------------|-------------------|--------------------|--------------------|
| AC1 | `bash scan-collisions.sh --help` exit 0；脚本镜像 scan-packs.sh 约定 (set -euo pipefail, BSD-safe awk/grep, arg-parse-before-derive-OUTPUT, anchored frontmatter) | post-impl | `bash -n .tad/scripts/scan-collisions.sh` (exit 0) + `bash .tad/scripts/scan-collisions.sh --help; echo $?` (==0) + `grep -c 'set -euo pipefail' .tad/scripts/scan-collisions.sh` (==1) | bash -n 无错；--help exit 0；count==1 |
| AC2 | scan 真实 packs（`.claude/skills/` 运行时加载树），对全部 3 个已知对发射 CANDIDATE (web-ui-design×web-frontend Inter；ui-design×frontend/testing contrast；frontend×testing pyramid)；每条种子签名 dry-run 仅命中目标矛盾行（P1-3） | post-impl ⚠️hand-re-derive | 跑脚本 → 读 candidates.yaml → **逐个手工打开两侧 file:line** 对照 live `.claude/skills/` pack 文件（NOT 计数）；核对每条签名命中行记入 candidates evidence、无 extra 误命中 | 3 对各有 candidate；每侧 file:line 经人工复核命中真实矛盾文本；签名特异性记录在案 |
| AC3 | `pack-collisions.yaml` schema 文档化 + 填好 3 个 confirmed，各含 {pack_a,pack_b,topic,a_says(ref(file:line)+quote+category),b_says(ref(file:line)+quote+category),resolution}（category 嵌套在 a_says/b_says 内，per §4.3 nested form — NOT flat category_a/category_b）；refs 记录在 `.claude/skills/`（canonical tree, P0-2）；Inter→auto/winner=web-frontend(perf)/loser=ui-design(style)/rule="performance>style"；contrast→escalate/same-category(a11y)；pyramid→escalate/same-category(testing) | post-impl ⚠️hand-re-derive | 读 pack-collisions.yaml；**hand-re-derive** 每行 a_says/b_says 的 file:line 对照 live `.claude/skills/` 文件；核对 nested category + resolution/winner/rule 字段 | 3 行 schema 完整（nested category）；每个 ref 人工复核命中；resolution 值如规定 |
| AC4 | precedence 引擎语义在 reference doc 文档化：security/safety/compliance/data-integrity(1)>correctness(2)>a11y(3)>performance(4)>style(5)；CROSS→auto-resolve(lower wins)+visible log；SAME→escalate；所有 resolution 都 logged (no-silent-caps) | post-impl | `grep -c 'performance' .tad/guides/pack-collision-detection.md` (>0) + 人工核对分类顺序 + cross/same 规则 + no-silent-caps 句 | guide 含完整有序分类 + cross/same 规则 + "every resolution logged" |
| AC5 | surfacing 一行格式（for P2）：cross-cat → `⚙️ resolved: {winner} over {loser} ({rule})`；same-cat → `⚠️ unresolved: {a} vs {b} — human decides ({topic})` | post-impl | `grep -F '⚙️ resolved:' .tad/guides/pack-collision-detection.md` + `grep -F '⚠️ unresolved:' .tad/guides/pack-collision-detection.md` 各 ≥1 | 两种一行格式都在 guide 中明文给出 |
| AC6 | anti-validation-theater guard 文档化 + 应用：acceptance hand-re-derives 每个 flagged collision 的 file:line；reference doc 明文 "N collisions found 不是验收" | post-impl ⚠️hand-re-derive | `grep -niE 'not (acceptance|sufficient)|count.{0,4}signal|hand-re-derive' .tad/guides/pack-collision-detection.md` ≥1 + acceptance 实际对每个 collision hand-re-derive file:line | guide 含 anti-theater 句；acceptance 记录每个 collision 的人工复核 |
| AC7 | scan-collisions.sh **未** 注册进 `.claude/settings.json`；reference doc 声明其为 CLI 工具非 hook | post-impl | `grep -c 'scan-collisions' .claude/settings.json` (==0) + `grep -ni 'not a hook' .tad/guides/pack-collision-detection.md` (≥1) | settings 计数 0；guide 声明非 hook |
| AC8 | ZERO 编辑 alex/SKILL.md + blake/SKILL.md（git diff 只含新文件）；pack-registry.yaml 未改 | post-impl | `git diff --name-only` 不含 `alex/SKILL.md`/`blake/SKILL.md`/`pack-registry.yaml`；`git status --short .tad/capability-packs/pack-registry.yaml` 为空 | diff 仅新文件；registry 无改动 |

> Pre-impl note: AC1 的 `grep -c 'set -euo pipefail'` 与 `bash -n` 可在脚本写完即跑（Blake Gate 3 Layer 1）。AC2/AC3/AC6 是 post-impl 且 **acceptance 阶段必须 hand-re-derive**，不接受任何 "found N collisions" 作为通过。

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1 AC7 broken `\|` literal-pipe grep | §9.1 AC7 | ✅ Resolved (→ `grep -ni 'not a hook'`) |
| code-reviewer | P1-1 keyword pre-filter unverified for 3 pairs | §4.2(B), §6 step 2 | ✅ Resolved (architect-verified note) |
| code-reviewer | P2-1 AC3 flat vs nested category schema | §9.1 AC3, §4.3 | ✅ Resolved (AC3 → nested) |
| code-reviewer | P2-2 candidates staging-file lifecycle ambiguous | §4.2(A), §6, §7.1 | ✅ Resolved (→ evidence dir) |
| backend-architect | P0-1 canonical scan tree (`.tad/capability-packs` vs `.claude/skills`) | FR1, §4.2(A), §4.3, §6 1-3 | ✅ Resolved (canonical = `.claude/skills/`) |
| backend-architect | P1-1 pack file-set enumeration unspecified | FR2, §6 step 3 | ✅ Resolved (`find -name '*.md'` minus CHANGELOG/LICENSE/README) |
| backend-architect | P1-2 confirm-step has zero enforcement | §4.2(C) | ✅ Resolved (`confirmed_by`+`drop_rationale`, mandatory worked-example) |
| backend-architect | P1-3 bare-token signatures over-match | §6 step 3, AC2 | ✅ Resolved (signature-specificity dry-run clause) |
| backend-architect | P1-4 category list not exhaustive / uncategorizable undefined | §4.4 | ✅ Resolved (closed-for-P1 + uncategorizable→ESCALATE) |

### Experts Selected (recommended for Blake Gate 3 Layer 2)
1. **code-reviewer** — bash script (set -e propagation, BSD-safe regex, file-write heredoc, grep-count traps).
2. **(optional) backend-architect** — only if signature-matching logic grows beyond the seed set.

### Overall Assessment
- Pre-impl design review RAN (code-reviewer + backend-architect, blue-team). Both verdicts: CONDITIONAL PASS. All P0 (CR P0-1, architect P0-1) + all P1 resolved in this handoff (see Audit Trail + §Y4 Design-Review Resolutions). Reviews: `.tad/evidence/yolo/pack-collision-detection/phase1-design-review-{cr,architect}.md`.
- Blake Gate 3 Layer 2 still runs code-reviewer post-impl on the actual script.

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **Anti-validation-theater (LOAD-BEARING)**: "N collisions found" is NOT acceptance. AC2/AC3/AC6 acceptance MUST hand-re-derive every flagged collision's two file:line against live pack files. A grep collision-scanner is itself validation-theater-prone (architecture.md 2026-05-30).
- ⚠️ **Concurrency (HARD)**: the OTHER Alex concurrently owns `alex/SKILL.md` (lean-trustworthy P4/P5). P1 MUST touch **ZERO** shared SKILL files. `pack-registry.yaml` is **READ-ONLY** (P5 writes `behaviorally_verified` into it — do NOT write it). P1 = new files only → commits interleave safely. Blake sub-agent uses worktree isolation.
- ⚠️ **`scan-collisions.sh` MUST NOT go in `.claude/settings.json`** — it is a CLI tool, not a registered hook. The no-fail-closed-hook rule does not apply (fail-fast `set -euo pipefail` is correct), but registering it as a hook is forbidden.
- ⚠️ **grep-count trap**: any unique-match count uses `grep -oE | sort -u | wc -l`, NEVER `grep -c | sort -u | wc -l` (always returns 1) — code-quality.md 2026-05-27.
- ⚠️ **Parser self-trigger**: signature literals live in `.tad/scripts/` (not under scanned pack dirs); fixtures live under `.tad/evidence/fixtures/` — so describing signatures in docs doesn't self-trigger the scanner.

### 10.2 Known Constraints
- BSD-safe only: NO `grep -P`, `\d`, `.*?`, `readlink -f`.
- Keywords are single-line flow form only (matches scan-packs.sh constraint).
- No LLM call inside the script — LLM-confirm is a documented agent procedure.
- The file:line numbers in §4.3 are Alex's grounding estimates; Blake hand-re-derives exact lines against live files (the contradictions are confirmed live; exact line offsets may shift ±a few lines).

### 10.3 Sub-Agent 使用建议
- [ ] **code-reviewer** — after scan-collisions.sh is written (Gate 3 Layer 2).
- [ ] **test-runner** — n/a (no test suite; functional checks are bash -n + --help + hand-re-derivation).

---

## Required Evidence Manifest

```yaml
required_evidence:
  - path: .tad/scripts/scan-collisions.sh
    type: code
    proves: "FR1/FR2 grep-seed detector; AC1 (bash -n + --help exit 0 + set -euo pipefail==1)"
  - path: .tad/scripts/collision-signatures.txt
    type: code
    proves: "FR3 curated opposing-directive signatures covering 3 fixtures"
  - path: .tad/capability-packs/pack-collisions.yaml
    type: data
    proves: "FR4/AC3 confirmed-collision registry, full schema, 3 rows"
  - path: .tad/guides/pack-collision-detection.md
    type: doc
    proves: "FR5/FR6/FR7/FR9; AC4 (precedence), AC5 (one-liners), AC6 (anti-theater), AC7 (not-a-hook)"
  - path: .tad/evidence/fixtures/pack-collisions/inter.md
    type: fixture
    proves: "FR8; Fixture 1 cross-cat-resolve (performance>style)"
  - path: .tad/evidence/fixtures/pack-collisions/contrast.md
    type: fixture
    proves: "FR8; Fixture 2 same-cat-escalate (a11y)"
  - path: .tad/evidence/fixtures/pack-collisions/pyramid.md
    type: fixture
    proves: "FR8; Fixture 3 same-cat-escalate (testing)"
  - path: .tad/evidence/yolo/pack-collision-detection/phase1-acceptance.md
    type: acceptance
    proves: "AC2/AC3/AC6 hand-re-derivation log — each collision's two file:line verified against live packs (count≠signal); AC8 git diff --name-only output; AC7 settings.json grep==0"
```

---

## Y4 Design-Review Resolutions

Pre-impl blue-team design review ran (code-reviewer + backend-architect). Conductor-decided resolutions applied to this handoff:

- **CR P0-1** (AC7 broken grep): AC7 second grep `'cli tool\|not a hook\|非 ?hook'` (literal pipe under -E) → `grep -ni 'not a hook'` (no-alternation, table-safe). First grep unchanged.
- **Architect P0-1** (canonical scan tree): DECIDED `.claude/skills/` is the scan target (runtime-loaded tree where contradictions + P2 consumers live). FR1/§4.2A/§6 1-3 now use `SKILLS_DIR=.claude/skills` (NOT `$TAD_DIR/capability-packs`); scan-packs.sh mirror = CONVENTIONS only. §4.3 invariant added: refs recorded against `.claude/skills/`; `.tad/capability-packs/` is a `*sync`-maintained copy.
- **Architect P1-1 / CR P1-1** (file-set enumeration + pre-filter verified): pack file set = `find "$skill_dir" -name '*.md'` minus CHANGELOG.md/LICENSE*/README.md (FR2, §6 step 3). Architect-verified the 3 target pairs share ≥1 keyword (ui×frontend `frontend,accessibility`; frontend×testing `performance,accessibility`; ui×testing `accessibility`) — noted in §4.2B/§6 step 2; Blake's dry-run confirm retained.
- **Architect P1-2** (confirm-step enforcement): added required `confirmed_by` + `drop_rationale` fields per candidate; co-mention drop worked-example is now MANDATORY guide content (§4.2C, §6 step 6).
- **Architect P1-3** (signature specificity): added clause — each seed signature dry-run must match ONLY the intended contradiction line(s), record matched lines in candidates evidence, anchor signatures (`NEVER use Inter` not bare `Inter`) (§6 step 3, AC2).
- **Architect P1-4** (uncategorizable → escalate): category list CLOSED for P1 / EXTENSIBLE in P2; known-missing classes (licensing/legal, cost/economic); uncategorizable side → ESCALATE, never silent auto-resolve (§4.4, guide).
- **CR P2-1** (schema consistency): AC3 now references nested `category` under `a_says`/`b_says` (matches §4.3), not flat `category_a,category_b`.
- **CR P2-2** (staging-file location): candidates staging file → `.tad/evidence/yolo/pack-collision-detection/pack-collisions.candidates.yaml` (out of `.tad/capability-packs/`) (§4.2A, §6, §7.1).

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-31
**Version**: 3.1.0
