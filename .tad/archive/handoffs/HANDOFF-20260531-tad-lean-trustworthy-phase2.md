---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: code       # code | yaml | research | e2e | mixed
e2e_required: no      # yes | no - yes 时 Blake 必须产出 E2E evidence
research_required: no # yes | no - yes 时 Blake 必须产出研究文件

git_tracked_dirs: []

skip_knowledge_assessment: no  # yes | no

gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-05-31
**Project:** TAD Framework
**Task ID:** TASK-20260531-002
**Handoff Version:** 3.1.0 (revision v2 — applies code-reviewer + backend-architect P0/P1 fixes)
**Epic:** EPIC-20260531-tad-lean-trustworthy.md (Phase 2/5)
**Supersedes:** v1 (this file, in place) — see §11 + review files under `.tad/evidence/yolo/tad-lean-trustworthy/`

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-05-31

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 4-step fix design fully specified in §6; grounded in phase2-grounding.md (authoritative over Epic's imprecise framing). |
| Components Specified | ✅ | ai-voice source dir (CAPABILITY.md + install.sh + references/ via cp -r), Step 1b consumes/produces preservation, scan-packs re-run, drift-check set logic (A/B/C, type-probe Set B), runbook wiring all specified. |
| Functions Verified | ✅ | scan-packs.sh `extract_consumes/produces/keywords` read firsthand; registry shape + entry format verified; ai-voice SKILL frontmatter verified verbatim. |
| Data Flow Mapped | ✅ | CAPABILITY.md → scan-packs → registry → drift-check set comparison → exit code. Mapped in §4.1. |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
Make the `ai-voice-production` capability pack discoverable to Alex/Blake auto-detection (it is the lone pack of 16 missing a source dir, so `scan-packs.sh` structurally cannot index it → invisible in the registry-keyword matching of Alex step4_5 / step1_5b / Blake 1_5a). Bring it fully into the source-dir convention (CAPABILITY.md + install.sh + copied references/, mirroring `video-creation/`) so it is indexable AND downstream-portable via `*sync`. Regenerate the registry (14→16, also picking up the source-only `ml-training` pack built after the last 2026-05-15 scan), and add a bidirectional, **advisory** drift-check (Set B = positive `type:`-frontmatter probe, no hardcoded allowlist) that catches this whole class of desync in the future, wired into the release pre-flight.

### 1.2 Why We're Building It
**业务价值**：A capability pack that is built and installed but invisible to detection is silently dead — the user paid build cost for zero behavioral benefit. The registry is stale (2026-05-15) and out of sync with reality.
**用户受益**：Voice/TTS tasks will now surface the ai-voice-production pack; future pack/registry desyncs are caught by a smoke alarm instead of going unnoticed.
**成功的样子**：Registry lists 16 packs incl. ai-voice-production with non-empty keywords; drift-check exits 0 on the clean state and 1 (advisory only) on an injected mismatch; release pre-flight runs the drift-check.

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：Two distinct root causes (NOT "phantom + invisible" as the Epic guessed — phase2-grounding.md corrects this):
1. **Registry is STALE.** ml-training (2026-05-29) + ai-voice-production (2026-05-28) postdate the 2026-05-15 scan.
2. **ai-voice-production breaks the source-dir convention** — it has `.claude/skills/ai-voice-production/SKILL.md` but NO `.tad/capability-packs/ai-voice-production/` source dir, so scan-packs cannot index it AND `*sync` cannot install it downstream. We make it conform by FULL source-dir-ification: `CAPABILITY.md` + `install.sh` + a copied `references/` dir (closes the dangling-pointer + downstream-404 class per backend P1-2).

**不是要做的（避免误解）**：
- ❌ 不是 authoring ml-training's SKILL.md content (it stays source-only — Tier 1 loadable; just gets an advisory flag).
- ❌ 不是 behavioral verification of any pack (that is Phase 5).
- ❌ 不是 collision detection across packs.
- ❌ 不是 making drift-check a blocking/fail-closed hook or a settings.json deny (forbidden — single-user CLI lesson).
- ❌ 不是 authoring NEW ai-voice-production reference content — the references already exist under `.claude/skills/ai-voice-production/references/`; we COPY them into the source dir, not rewrite them.

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. 用户会如何使用？
3. 成功的标准是什么？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed in 步骤 2 below
2. Read the handoff's "⚠️ Blake 必须注意的历史教训" entries carefully
3. This is NOT optional — project knowledge prevents repeated mistakes

### 步骤 1：识别相关类别

本次任务涉及的领域（勾选所有适用项）：
- [x] code-quality - 代码模式/反模式（AC grep-count、BSD-safe shell）
- [ ] security
- [ ] ux
- [x] architecture - 架构决策（drift-detector allowlist、advisory not blocking、smoke alarm doctrine）
- [ ] performance
- [ ] testing
- [ ] api-integration
- [ ] mobile-platform

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 4 条 | drift-check no-rot discriminator (type-probe, not allowlist) + quieting; advisory/smoke-alarm not fail-closed (single-user CLI); shell portability (BSD grep/awk, bracket-class slug matching); scan-packs OVERWRITES → verify determinism + committed→post-scan delta |
| code-quality.md | 2 条 | AC grep-count for reference-based packs (filename appears 2×); reference filename naturally appears in 2 SKILL.md locations |
| security.md | 0 条 | 无相关历史记录 |

**⚠️ Blake 必须注意的历史教训**：

1. **Mechanical Enforcement Rejected on Single-User CLI** (architecture.md, 2026-04-15)
   - 问题：Fail-closed PreToolUse hooks deny all tool calls with no self-recovery; "日常恢复成本 > 防偶尔跳步骤收益".
   - 解决方案：drift-check is a SMOKE ALARM, NEVER a fire suppressor. It REPORTS and exits 1 on real mismatch, but is NOT registered as a blocking hook / settings.json deny / SessionStart fail-closed gate. Include a clearly-delimited SAFETY/forbidden header comment block — mirror the `post-write-sync.sh:6-11` SAFETY-comment STYLE (those lines are a SAFETY *comment*, not a code `forbidden_implementations` block; there is no such block in any `.tad/hooks/*.sh`).

2. **Drift-Check and Staleness Detection / no-rot discriminator** (architecture.md, 2026-04-24)
   - 问题：Shared/project-level files false-flag in drift detectors; a hardcoded framework-skill allowlist ROTS (every new framework skill = spurious (b)-flag → false exit 1); BSD-incompatible regex.
   - 解决方案：Set B uses a POSITIVE `type:`-frontmatter probe, NOT a hardcoded allowlist. A skill counts as a capability-pack skill ONLY if its `SKILL.md` frontmatter declares `type: reference-based|deep-skill|orchestration-router` (`grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)' .claude/skills/*/SKILL.md` → basename). Framework skills declare no pack type → never false-flag → rot-free. BSD grep/awk only, no `grep -P`; `comm` over `LC_ALL=C sort`-ed lists; `shopt -s nullglob` for empty-glob safety.

3. **scan-packs OVERWRITES the registry — committed→fresh is NOT byte-stable** (architecture.md idempotency lesson; scan-packs.sh header; cr P0-1)
   - 问题：A fresh scan REORDERS entries (committed-last academic-research → alpha-first), changes `synced_from_version` (2.15.1→2.19.1), and would DROP `consumes/produces` for any pack whose CAPABILITY.md lacks `**CONSUMES**:`/`**PRODUCES**:` lines. So "14 entries byte-stable, only date changes" is FALSE for the committed→post-scan transition.
   - 解决方案：Two separate checks. (1) DETERMINISM (AC2.5a): run scan-packs TWICE *after* the 16-pack state exists and `diff` those two runs → empty or date-only. (2) committed→post-scan is an ENUMERATED line-SET diff (AC2.5b, `comm` over `LC_ALL=C sort`): expected delta = entry reorder + `synced_from_version` bump + 2 new packs + date — AND assert no existing pack degraded to "Not specified". Before re-scan, restore `**CONSUMES**:`/`**PRODUCES**:` to any CAPABILITY.md that would otherwise degrade (§6 Step 1b / AC2.6).

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解需要避免的问题
- [ ] 如遇到类似情况，我会参考上述解决方案

---

## 2. Background Context

### 2.1 Previous Work
- `scan-packs.sh` (`.tad/scripts/scan-packs.sh`) scans `"$PACKS_DIR"/*/CAPABILITY.md` and OVERWRITES `pack-registry.yaml` idempotently. It indexes ONLY packs that have a `.tad/capability-packs/{name}/CAPABILITY.md`. `extract_consumes/extract_produces` emit `"Not specified"` when the `**CONSUMES**:`/`**PRODUCES**:` body lines are absent.
- An existing reference-based pack `CAPABILITY.md` shape: `.tad/capability-packs/video-creation/CAPABILITY.md` (frontmatter `name/description/version/type/keywords` + a body blockquote with `**CONSUMES**:`/`**PRODUCES**:`).
- Phase 1 of this Epic shipped a header-aware trace decision parser (85fe0a9) — independent of this phase.

### 2.2 Current State (verified firsthand by Alex)
- `grep -c '^  - name:' .tad/capability-packs/pack-registry.yaml` = **14**; `last_scanned: "2026-05-15"`.
- 15 source packs under `.tad/capability-packs/*/` (incl. `ml-training/`), all with `CAPABILITY.md`. **ai-voice-production has NO source dir.**
- Installed skills under `.claude/skills/*/SKILL.md` include `ai-voice-production` (capability) plus all framework skills.
- ml-training: source `CAPABILITY.md` present, NO `.claude/skills/ml-training/SKILL.md` → source-only (Tier 1 loadable, not a phantom).
- ai-voice-production SKILL frontmatter keywords are a **single-line flow form** (required by scan-packs constraint).

### 2.3 Dependencies
None for execution (Epic: P1, P2 independent). Phase 5 later writes `behaviorally_verified` into the registry this phase regenerates.

---

## 3. Requirements

### 3.1 Functional Requirements
- **FR1**: Full source-dir-ify `ai-voice-production` (mirror `video-creation/`): (a) `.tad/capability-packs/ai-voice-production/CAPABILITY.md` — frontmatter `name`/`description`/`keywords` COPIED VERBATIM from `.claude/skills/ai-voice-production/SKILL.md`, `type: reference-based`, keywords single-line flow form `keywords: [...]`; body MUST contain a `**CONSUMES**:` and a `**PRODUCES**:` line (else "Not specified"); body reference pointers MUST resolve under the copied `references/` (no dangling pointers). (b) `install.sh` mirroring `video-creation/install.sh`. (c) `cp -r` the references from `.claude/skills/ai-voice-production/references/` into `.tad/capability-packs/ai-voice-production/references/`.
- **FR2**: Re-run `bash .tad/scripts/scan-packs.sh` → registry 14→16 (adds ai-voice-production + ml-training); `last_scanned` auto-bumps to today. No existing pack may degrade to `consumes/produces: "Not specified"` (see §6 Step 1b + AC2.6).
- **FR3**: Create `.tad/hooks/lib/pack-registry-driftcheck.sh` — advisory bidirectional drift-check (set logic per §4.1; Set B = positive `type:`-frontmatter probe, NO hardcoded allowlist); exit 1 on real mismatch, exit 0 clean (incl. empty `.claude/skills` fresh-clone), NEVER blocks a session; BSD-safe; with a clearly-delimited SAFETY/forbidden header block.
- **FR4**: Wire the drift-check into the release-runbook Phase 1 pre-flight checklist as an advisory check.

### 3.2 Non-Functional Requirements
- **NFR1**: drift-check MUST NEVER fail-closed. No `set -e` that would abort a SessionStart; advisory exit code only; not registered as a blocking hook or settings.json deny.
- **NFR2**: BSD-safe shell only (no `grep -P`, no `.*?`, no `\d`). Use `grep -l '^type: \(...\)'` for the type-probe and `comm` over `LC_ALL=C sort`-ed lists for set differences. Use `shopt -s nullglob` for empty-glob safety.
- **NFR3**: scan-packs idempotency preserved — only the date line may change on a second run.

### 3.3 Optimization Target
N/A — no numeric optimization goal.

---

## 4. Technical Design

### 4.1 Architecture Overview

Data flow:
```
ai-voice-production/CAPABILITY.md  ──┐
ml-training/CAPABILITY.md          ──┼─► scan-packs.sh (OVERWRITE) ─► pack-registry.yaml (16 packs)
(13 other source CAPABILITY.md)    ──┘                                        │
                                                                              ▼
pack-registry-driftcheck.sh:  Set A = registry names (grep '^  - name:')
                              Set B = installed CAPABILITY-PACK skills (positive type-frontmatter probe — NO allowlist)
                                      = for each .claude/skills/*/SKILL.md WHERE [ -f "$d/SKILL.md" ]:
                                          grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)'
                                          → basename(dir)   (framework skills declare no pack type → excluded, rot-free)
                              Set C = source packs = for each .tad/capability-packs/*/ WHERE [ -f "$d/CAPABILITY.md" ]: basename(dir)
                              (shopt -s nullglob so empty .claude/skills or empty capability-packs → empty set, NOT a literal-glob name;
                               all comm/sort inputs use LC_ALL=C sort)
  Report:
    (a) C \ registry          → source pack not indexed        (should be EMPTY post-scan)  → exit-affecting
    (b) B \ registry          → installed skill not indexed    (the ai-voice-production class) → exit-affecting
    (c) registry \ (B ∪ C)    → registry entry w/ neither src nor skill (true phantom)        → exit-affecting
    (d) advisory WARN:  C-without-skill (ml-training)  +  skill-without-C   → never changes exit
  exit 1 if any of (a)(b)(c) non-empty; else exit 0.   (d) is WARN-only.
```

### 4.2 Component Specifications

**ai-voice-production source dir (FR1) — FULL source-dir-ification** (mirror `video-creation/`):
- `CAPABILITY.md` — Frontmatter: `name: ai-voice-production`, `description: "..."` (verbatim from SKILL.md), `version: 0.1.0`, `type: reference-based`, `keywords: [...]` (verbatim, single line). Body: a `# AI Voice Production Capability Pack` heading + a blockquote with `**CONSUMES**:` and `**PRODUCES**:` lines (so `extract_consumes/produces` find them). Reference pointers in the body MUST resolve under the copied source `references/` (no dangling bare `references/` pointers — either point at the copied references/ or omit a reference table).
- `install.sh` — mirror `video-creation/install.sh` (claude-code installer + codex/cursor/gemini Phase-2 stubs; `PACK_NAME="ai-voice-production"`). Closes the `*sync` b2 / Tier3 `gh api .../install.sh` 404 class.
- `references/` — `cp -r .claude/skills/ai-voice-production/references/ .tad/capability-packs/ai-voice-production/references/` (7 files: apple-silicon, audiobook-pipeline, chattts-workflow, licensing-safety, narration-dubbing, tool-landscape, voice-cloning). Source dir becomes the canonical copy that install.sh fans out.

**pack-registry-driftcheck.sh (FR3)**:
- Set A from registry: `grep '^  - name:' "$REGISTRY" | sed 's/.*name: *"//; s/".*//'`.
- Set B (positive type-probe, NO allowlist): for each `.claude/skills/*/SKILL.md` where `[ -f "$d/SKILL.md" ]`, `grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)'` → basename(dir). Framework skills declare no pack `type:` → naturally excluded; this is rot-free (a new framework skill never false-flags).
- Set C: for each `.tad/capability-packs/*/` where `[ -f "$d/CAPABILITY.md" ]` → basename(dir). (Mirrors scan-packs' own gate exactly.)
- `shopt -s nullglob` so an unpopulated `.claude/skills` (fresh clone) or `.tad/capability-packs` yields an empty set instead of a literal `*` name → (b)/(a) empty → exit 0, no crash.
- Compute (a)(b)(c)(d) via `comm` on `LC_ALL=C sort`-ed name lists.
- Print human-readable report to stdout (pack names only — fine, not a parser-scanned artifact).
- exit 1 if any of (a)(b)(c) non-empty, else 0. (d) prints WARN lines, never alters exit.
- Header comment + clearly-delimited SAFETY/forbidden block (see §6 Step 3).

**release-runbook wiring (FR4)**: add one advisory checklist item to Phase 1 Pre-flight "Checklist (all must pass before continuing)" referencing `bash .tad/hooks/lib/pack-registry-driftcheck.sh` as advisory (drift is informational, NOT a release blocker).

### 4.3 Data Models
N/A (YAML registry already defined by scan-packs).

### 4.4 API Specifications
N/A.

### 4.5 User Interface Requirements
N/A.

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索

**问题**：用户是否提到"之前的"、"原来的"、"我们的方案"？

**回答**：
- [x] 是 → grounding references the existing scan-packs + an existing reference-based pack to mirror.

#### 搜索证据
```bash
# Verified the existing reference-based pack shape to mirror
cat .tad/capability-packs/video-creation/CAPABILITY.md   # frontmatter + CONSUMES/PRODUCES body
# Verified scan-packs indexing + extract_consumes/produces fallback
sed -n '69,85p;140,182p' .tad/scripts/scan-packs.sh
# Verified ai-voice SKILL frontmatter (verbatim source for CAPABILITY.md)
sed -n '1,7p' .claude/skills/ai-voice-production/SKILL.md
```

#### 决策说明
- **找到了什么**：video-creation/CAPABILITY.md is the canonical reference-based shape; ai-voice SKILL frontmatter has the verbatim name/description/keywords.
- **位置**：`.tad/capability-packs/video-creation/CAPABILITY.md`, `.claude/skills/ai-voice-production/SKILL.md:1-7`, `.tad/scripts/scan-packs.sh:69-85,140-182`.
- **决定**：✅ 复用 — mirror video-creation/CAPABILITY.md shape, copy ai-voice frontmatter verbatim. Reuse scan-packs (no script change needed — it indexes any source CAPABILITY.md).
- **原因**：The desync is a missing source CAPABILITY.md, not a scan-packs bug.

**Human验证点**：能看到搜索确实执行了吗？决策理由合理吗？

---

### MQ2: 函数存在性验证

**问题**：设计中调用了哪些函数？它们都存在吗？

#### 函数清单

| 函数名 | 文件位置 | 行号 | 代码片段 | 验证 |
|--------|---------|------|---------|------|
| extract_consumes | .tad/scripts/scan-packs.sh | 69-75 | `grep -m1 '^\*\*CONSUMES\*\*:' "$1" ... echo "${result:-Not specified}"` | ✅ |
| extract_produces | .tad/scripts/scan-packs.sh | 79-85 | `grep -m1 '^\*\*PRODUCES\*\*:' "$1" ...` | ✅ |
| extract_keywords | .tad/scripts/scan-packs.sh | 59-64 | `awk '/^---$/{...} n==1 && /^keywords: /'` (single-line flow form) | ✅ |
| extract_frontmatter_field | .tad/scripts/scan-packs.sh | 47-54 | `awk '/^---$/{...} n==1 && /^'"$field"': /'` | ✅ |

**Human验证点**：每个函数都有"✅存在"和具体位置吗？

---

### MQ3: 数据流完整性

**问题**：后端计算/返回了哪些字段？前端都显示了吗？

#### 数据流对照表

| 来源字段 | 用途说明 | 消费者 | 是否流通 | 不流通原因 |
|---------|---------|---------|---------|-----------|
| CAPABILITY.md `keywords` | LLM-semantic match in Alex step4_5 | pack-registry.yaml `keywords` | ✅ | — |
| CAPABILITY.md `**CONSUMES**:` | registry `consumes` field | extract_consumes | ✅ | (else "Not specified") |
| CAPABILITY.md `**PRODUCES**:` | registry `produces` field | extract_produces | ✅ | (else "Not specified") |
| registry names (Set A) | drift comparison | drift-check (a)(b)(c) | ✅ | — |
| installed skills (Set B) | drift comparison | drift-check (b) | ✅ | framework skills excluded by positive `type:`-frontmatter probe (no allowlist) |

**Human验证点**：每个字段都有对应消费者吗？

---

### MQ4: 视觉层级
- [ ] 有不同状态
- [x] 无不同状态 → 跳过 (CLI/file task, no UI states).

---

### MQ5: 状态同步

**问题**：数据存在几个地方？什么时候同步？

#### 状态存储位置

| 数据 | 存储位置1 | 存储位置2 | 同步时机 | 同步方向 |
|------|----------|----------|---------|---------|
| pack metadata | `.tad/capability-packs/{name}/CAPABILITY.md` (source of truth) | `pack-registry.yaml` (derived index) | on `scan-packs.sh` run | source → derived (one-way, OVERWRITE) |

#### 状态流图
```
CAPABILITY.md (Source of Truth) ──scan-packs.sh (OVERWRITE)──► pack-registry.yaml (derived)
                                                                 ▲
                                          drift-check reads both ┘ (compares, never mutates)
```

**Human验证点**：CAPABILITY.md is the single source of truth; registry is derived. drift-check only READS — it never mutates either side. ✅

---

## 6. Implementation Steps（分Phase）

Single phase (4 steps, ~1-2h). No micro-task split needed beyond the 4 steps.

### Phase 1: Registry conformance + drift-check（预计 1.5 小时）

#### 交付物
- [ ] `.tad/capability-packs/ai-voice-production/CAPABILITY.md` (CREATE)
- [ ] `.tad/capability-packs/ai-voice-production/install.sh` (CREATE — mirror video-creation/install.sh)
- [ ] `.tad/capability-packs/ai-voice-production/references/*.md` (CREATE via `cp -r` from `.claude/skills/ai-voice-production/references/`)
- [ ] consumes/produces restore for any degrading CAPABILITY.md (MODIFY — see Step 1b)
- [ ] `pack-registry.yaml` regenerated to 16 packs (MODIFY via scan-packs)
- [ ] `.tad/hooks/lib/pack-registry-driftcheck.sh` (CREATE)
- [ ] `.claude/skills/release-runbook/SKILL.md` Phase 1 pre-flight advisory item (MODIFY)

#### 实施步骤

**Step 1 — Full source-dir-ify ai-voice-production** (mirror `video-creation/`; closes backend P1-2 dangling-pointer + downstream-404).
Mkdir `.tad/capability-packs/ai-voice-production/`. Produce THREE artifacts:
- (a) **CAPABILITY.md** mirroring `video-creation/CAPABILITY.md`'s shape. Frontmatter: `name: ai-voice-production`, `description:` and `keywords:` COPIED VERBATIM from `.claude/skills/ai-voice-production/SKILL.md` frontmatter (description string + the 21-keyword array), `version: 0.1.0`, `type: reference-based`. Keywords MUST be a single-line flow form `keywords: [...]` (scan-packs `extract_keywords` only reads single-line flow form). Body: a `# AI Voice Production Capability Pack` heading, then a blockquote containing a `**CONSUMES**:` line and a `**PRODUCES**:` line (reuse the CONSUMES/PRODUCES wording already in the ai-voice SKILL.md blockquote). These two lines MUST start at column 0 (scan-packs greps `'^\*\*CONSUMES\*\*:'`). **Reference pointers in the body MUST resolve under the copied source `references/`** — either reproduce the SKILL.md's reference table (now pointing at the copied `references/*.md`) OR omit a reference table entirely. Do NOT leave a bare `references/` pointer that resolves to a non-existent path.
- (b) **install.sh** mirroring `video-creation/install.sh`: `PACK_NAME="ai-voice-production"`, `PACK_VERSION="0.1.0"`, the same `install_claude_code` (copy CAPABILITY.md → SKILL.md, fan out `references/*.md`) + codex/cursor/gemini Phase-2 stubs. Adjust the `check_prerequisites` tool list to ai-voice's tools (Python/venv + TTS tooling) or keep a minimal prereq stub — the install mechanics (copy CAPABILITY.md + references) are the load-bearing part. The pack MUST be installable + `*sync`-portable + `gh api .../install.sh`-resolvable.
- (c) **references/** — `cp -r .claude/skills/ai-voice-production/references/ .tad/capability-packs/ai-voice-production/references/` (7 files). The source dir is now the canonical copy; install.sh fans these out downstream.

**Step 1b — Pre-scan consumes/produces preservation (cr P0-1).**
BEFORE re-running scan-packs, fix any pack whose source `CAPABILITY.md` LACKS a **col-0** `**CONSUMES**:`/`**PRODUCES**:` line (scan-packs only matches the col-0 anchor `^\*\*CONSUMES\*\*:`). ⚠️ Ground truth: academic-research, ml-training, video-creation carry these markers in BLOCKQUOTE form (`> **CONSUMES**:`) which the col-0 grep MISSES → they would index as "Not specified". The fix is to CONVERT blockquote→col-0 (drop the leading `> `), NOT to add duplicate lines. Verify by grep:
```bash
# Find any committed pack whose CAPABILITY.md lacks the body markers (candidate to restore):
for d in .tad/capability-packs/*/; do
  [ -f "$d/CAPABILITY.md" ] || continue
  grep -q '^\*\*CONSUMES\*\*:' "$d/CAPABILITY.md" || echo "MISSING CONSUMES marker: $d"
done
```
⚠️ CORRECTION (Y4 re-review, ground-truth verified): academic-research, ml-training, video-creation all use BLOCKQUOTE `> **CONSUMES**:` form → the loop above WILL flag all three. academic-research HAS a real committed value (`Research question + optional domain constraints...`) → re-scan REGRESSES it. **Fix mechanism (convert, don't add)**:
```bash
for d in academic-research ml-training video-creation; do
  sed -i '' -e 's/^> \*\*CONSUMES\*\*:/**CONSUMES**:/' -e 's/^> \*\*PRODUCES\*\*:/**PRODUCES**:/' \
    ".tad/capability-packs/$d/CAPABILITY.md"
done
```
Then re-run the loop → zero "MISSING CONSUMES marker". This is AC2.6 (no consumes/produces regression vs committed).

**Step 2 — Re-run scan-packs.**
`bash .tad/scripts/scan-packs.sh`. Expect stdout `scan-packs.sh: scanned 16 packs`. Registry `grep -c '^  - name:'` → 16 (adds ai-voice-production + ml-training); `last_scanned` auto-bumps to today (script uses `date -u +%Y-%m-%d`). Confirm the ai-voice-production entry has non-empty keywords and non-"Not specified" consumes/produces, AND that no previously-real consumes/produces degraded (AC2.6).

**Step 3 — Create pack-registry-driftcheck.sh.**
Create `.tad/hooks/lib/pack-registry-driftcheck.sh` per §4.1/§4.2:
- Top-of-file: a clearly-delimited SAFETY/forbidden header COMMENT block, mirroring the `post-write-sync.sh:6-11` SAFETY-comment STYLE (those lines are a SAFETY *comment*; there is NO code `forbidden_implementations` block in any `.tad/hooks/*.sh`). The block MUST state: MUST NOT register as a blocking hook; MUST NOT be added to settings.json `permissions.deny`; MUST NOT fail-closed / abort a session; advisory exit code only. (AC2.4 greps for a marker in this block — a deliberate presence check.)
- `shopt -s nullglob` near the top so empty globs (fresh clone, unpopulated `.claude/skills`) yield empty sets, not literal `*` names.
- Set A (registry names via `grep '^  - name:' | sed`).
- Set B (positive type-probe, NO allowlist): for each `.claude/skills/*/SKILL.md` gated on `[ -f "$d/SKILL.md" ]`, collect basenames of dirs whose SKILL.md frontmatter matches `grep -l '^type: \(reference-based\|deep-skill\|orchestration-router\)'`. Framework skills (alex/blake/gate/…) declare no pack `type:` → excluded; no hardcoded list → rot-free.
- Set C: for each `.tad/capability-packs/*/` gated on `[ -f "$d/CAPABILITY.md" ]` → basenames (mirrors scan-packs' own gate).
- Report (a) C\registry, (b) B\registry, (c) registry\(B∪C); print offending names. (d) advisory WARN: C-without-skill (ml-training) + skill-without-C — WARN only.
- exit 1 if any of (a)(b)(c) non-empty; else exit 0. (d) never changes exit.
- BSD-safe: `comm` over `LC_ALL=C sort`-ed name lists for set differences. No `set -e` that would abort on a non-match; no `grep -P`.

**Step 4 — Wire into release-runbook pre-flight.**
In `.claude/skills/release-runbook/SKILL.md` Phase 1 "Checklist (all must pass before continuing)" (around line 49-56), add ONE advisory item, e.g.:
`- [ ] Pack registry drift-check run (advisory): `bash .tad/hooks/lib/pack-registry-driftcheck.sh` — exit 1 = registry/pack desync to review, NOT a release blocker.`
SessionStart wiring is OPTIONAL — note as a follow-up, do NOT add a fail-closed SessionStart gate.

#### 验证方法
Run all §9.1 AC commands. See AC2.1–AC2.6 (AC2.5 is split into AC2.5a determinism + AC2.5b committed→post-scan delta).

#### 🆕 Phase 1 完成证据（Blake必须提供）
- [ ] `ls .tad/capability-packs/ai-voice-production/` showing CAPABILITY.md + install.sh + references/ (7 files); `bash install.sh --check` (or `--help`) runs clean
- [ ] scan-packs stdout (`scanned 16 packs`) + `grep -A6 'name: "ai-voice-production"'` registry excerpt
- [ ] AC2.6: no existing pack degraded to `consumes/produces: "Not specified"` (committed vs post-scan grep)
- [ ] drift-check clean run (exit 0) + injected-mismatch run (exit 1 + offending name) + sed-revert proof (NOT git checkout)
- [ ] AC2.5a determinism diff (two POST-16-state scans → empty/date-only) + AC2.5b committed→post-scan line-SET diff with enumerated delta
- [ ] grep of the SAFETY/forbidden marker in the new script (AC2.4)

**Human决策**：✅ 继续 / ⚠️ 调整

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/capability-packs/ai-voice-production/CAPABILITY.md       # frontmatter (verbatim from SKILL.md) + CONSUMES/PRODUCES body + resolving reference pointers
.tad/capability-packs/ai-voice-production/install.sh          # mirror video-creation/install.sh — *sync-portable + gh-api-resolvable (closes downstream-404)
.tad/capability-packs/ai-voice-production/references/*.md     # cp -r from .claude/skills/ai-voice-production/references/ (7 files) — canonical copy install.sh fans out
.tad/hooks/lib/pack-registry-driftcheck.sh                    # advisory bidirectional drift-check; SAFETY/forbidden header comment; type-probe Set B; exit 1 on mismatch, never blocks
```

### 7.2 Files to Modify
```
.tad/capability-packs/pack-registry.yaml          # MODIFY via scan-packs re-run (14→16, last_scanned→today)
.claude/skills/release-runbook/SKILL.md           # MODIFY: add 1 advisory drift-check item to Phase 1 pre-flight checklist
(any degrading CAPABILITY.md)                      # MODIFY (Step 1b / AC2.6): restore **CONSUMES**:/**PRODUCES**: if a real registry consumes/produces would otherwise drop to "Not specified"
```

### 7.3 Grounded Against (Alex step1c — actually Read by Alex / grounding)

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- `.tad/scripts/scan-packs.sh` (full read, 2026-05-31 — indexing logic, extract_consumes/produces/keywords, single-line keyword constraint)
- `.tad/capability-packs/video-creation/CAPABILITY.md` (full read, 2026-05-31 — reference-based CAPABILITY.md shape + CONSUMES/PRODUCES body)
- `.tad/capability-packs/video-creation/install.sh` (full read, 2026-05-31 — install.sh shape to mirror for ai-voice-production)
- `.claude/skills/ai-voice-production/SKILL.md` head (read, 2026-05-31 — verbatim name/description/keywords source)
- `.claude/skills/ai-voice-production/references/` (listed, 2026-05-31 — 7 ref files to `cp -r` into the source dir)
- `.tad/capability-packs/pack-registry.yaml` head + count + entry shape (read, 2026-05-31 — current 14-pack baseline, entry format)
- `.claude/skills/release-runbook/SKILL.md` Phase 1 pre-flight (read, 2026-05-31 — wiring point lines 49-56)
- `.tad/evidence/yolo/tad-lean-trustworthy/phase2-grounding.md` (authoritative grounding, read 2026-05-31)
- `.tad/capability-packs/ai-voice-production/CAPABILITY.md` — (new — will be created)
- `.tad/capability-packs/ai-voice-production/install.sh` — (new — will be created)
- `.tad/capability-packs/ai-voice-production/references/*.md` — (new — `cp -r` from skills)
- `.tad/hooks/lib/pack-registry-driftcheck.sh` — (new — will be created)

---

## 8. Testing Requirements

### 8.1 Unit Tests
N/A (shell scripts — verified via AC commands).

### 8.2 Integration Tests
- scan-packs → registry: ai-voice-production indexed with keywords (AC2.1).
- drift-check clean-state vs injected-mismatch behavior (AC2.3).

### 8.3 Edge Cases
- Injected fake registry name (append `- name: "zzz-fake-pack"`) → drift-check (c) registry\(B∪C) non-empty → exit 1 + prints the fake name; targeted `sed` removal restores exit 0 (NOT `git checkout` — that would revert the 16-pack registry, destroying FR2).
- ml-training (source-only) → must NOT cause exit 1 (it IS in registry post-scan; only the (d) advisory WARN fires).
- ai-voice-production (skill-without-source pre-fix) → after Step 1+2 it has BOTH a CAPABILITY.md and a skill → no (b) flag.
- **Empty `.claude/skills` (fresh clone)** → Set B empty (via `shopt -s nullglob`) → (b) empty → exit 0, NO crash, no literal `*` name.
- **`.claude/skills/_archived/` (no SKILL.md)** → gated out by `[ -f "$d/SKILL.md" ]` AND has no `type:` frontmatter → MUST NOT be flagged in Set B / (b).

### 8.4 🆕 Test Evidence Required
- [ ] raw scan-packs stdout + registry excerpt
- [ ] drift-check exit-code demo (clean=0, injected=1, reverted=0)
- [ ] idempotency diff

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] 所有FR (FR1-FR4) 实现并验证
- [ ] 所有 §9.1 AC (AC2.1-AC2.6) PASS（有 raw output 证明）
- [ ] drift-check 是 advisory（never blocks）— SAFETY/forbidden header comment present (AC2.4)
- [ ] scan-packs determinism 验证通过（AC2.5a: two post-16 scans diff = empty/date-only）+ committed→post-scan enumerated delta（AC2.5b）
- [ ] no existing pack degraded to consumes/produces "Not specified"（AC2.6）
- [ ] Human 验证"这是我期望的"

---

## 9.1 Spec Compliance Checklist (for automated verification)

> **Pipe-escape note**: any `|` inside a `grep -E` here is shown un-escaped (run form). No `\|`-rendered cells below.
>
> **AC dry-run note (Alex step1d)**: Pre-impl baseline measured firsthand 2026-05-31 — registry currently lists **14** packs (`grep -c '^  - name:'` = 14), `last_scanned: "2026-05-15"`, ai-voice-production absent, ml-training absent. ⚠️ CORRECTION (Y4 re-review): academic-research / ml-training / video-creation use BLOCKQUOTE `> **CONSUMES**:` form which scan-packs' col-0 grep MISSES → would index "Not specified". academic-research has a real committed value → re-scan REGRESSES it unless Step 1b converts blockquote→col-0 FIRST. AC2.1/AC2.2/AC2.5/AC2.6 are **post-impl** — they require the Step-1 source dir + Step-1b restore + the Step-2 scan run before they can pass; their Verified Output is "(post-impl)". AC2.3/AC2.4 are post-impl (need the new script).

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC2.1 | ai-voice-production indexed with non-empty keywords | post-impl-verifiable | `grep -A6 'name: "ai-voice-production"' .tad/capability-packs/pack-registry.yaml` | Entry block present; `keywords:` line non-empty (the 21-item array); `type: "reference-based"` | (post-impl) — pre-fix returns nothing (pack absent from 14-entry registry) |
| AC2.2 | ml-training present in registry; no registry entry advertises a pack lacking BOTH source CAPABILITY.md AND installed SKILL.md (true-phantom check) | post-impl-verifiable | `grep -q 'name: "ml-training"' .tad/capability-packs/pack-registry.yaml && echo PRESENT` ; then run `bash .tad/hooks/lib/pack-registry-driftcheck.sh` and confirm report section (c) registry\(B∪C) is EMPTY | `PRESENT`; drift-check (c) prints no names | (post-impl) — registry=14 pre-scan, ml-training absent |
| AC2.3 | drift-check exit 0 clean; inject a temp fake registry name → exit 1 + prints the name → targeted-sed removal restores exit 0 (16-pack registry intact, FR2 preserved) | post-impl-verifiable | `bash .tad/hooks/lib/pack-registry-driftcheck.sh; echo "exit=$?"` (expect 0) → `printf '  - name: "zzz-fake-pack"\n' >> .tad/capability-packs/pack-registry.yaml` → re-run (expect exit=1 AND `zzz-fake-pack` in output) → `sed -i '' '/name: "zzz-fake-pack"/d' .tad/capability-packs/pack-registry.yaml` (BSD sed) → re-run (expect 0). NOTE: do NOT `git checkout pack-registry.yaml` — it would revert to the committed 14-pack registry and destroy FR2. | exit=0 / exit=1+name / exit=0; registry still 16 packs after | (post-impl) — script not yet created |
| AC2.4 | `last_scanned` == today; drift-check is advisory (SAFETY/forbidden header comment present; no exit path blocks a session — only reports) | post-impl-verifiable | `grep last_scanned .tad/capability-packs/pack-registry.yaml` (expect `2026-05-31`) ; `grep -n 'forbidden\|MUST NOT' .tad/hooks/lib/pack-registry-driftcheck.sh` (expect ≥1 — the deliberate SAFETY-comment marker) ; confirm NO `set -e` abort and the script only `echo`s + `exit 0/1` | `2026-05-31`; SAFETY-comment marker line(s); no blocking path | (post-impl) — last_scanned currently `2026-05-15`; script not yet created |
| AC2.5a | scan-packs DETERMINISM — run twice AFTER the 16-pack state exists, diff of the two registries shows nothing OR only the date line | post-impl-verifiable | (after Step 2 produced the 16-pack registry) `bash .tad/scripts/scan-packs.sh; cp .tad/capability-packs/pack-registry.yaml /tmp/r1.yaml; bash .tad/scripts/scan-packs.sh; diff /tmp/r1.yaml .tad/capability-packs/pack-registry.yaml` | diff empty OR only the `last_scanned:` line differs (same UTC day → likely empty) | (post-impl) — requires the 16-pack state first |
| AC2.5b | committed→post-scan line-SET diff has ONLY the enumerated expected delta | post-impl-verifiable | `git show HEAD:.tad/capability-packs/pack-registry.yaml | LC_ALL=C sort > /tmp/committed.sorted; LC_ALL=C sort .tad/capability-packs/pack-registry.yaml > /tmp/post.sorted; comm -3 /tmp/committed.sorted /tmp/post.sorted` | Delta is EXACTLY: entry reorder (academic-research moves), `synced_from_version` 2.15.1→2.19.1, +2 new packs (ai-voice-production, ml-training), `last_scanned` date — and NO line changing an existing pack's `consumes:`/`produces:` to `"Not specified"` | (post-impl) — requires the scan run |
| AC2.6 | no consumes/produces regression — every pack that had a real (non-"Not specified") consumes/produces in the committed registry still has one post-scan | post-impl-verifiable | `git show HEAD:.tad/capability-packs/pack-registry.yaml | grep -E 'consumes:|produces:' | grep -c 'Not specified'` (baseline count) vs same grep on the post-scan registry — the post-scan "Not specified" count for the 14 pre-existing packs MUST NOT increase | post-scan "Not specified" count ≤ committed count (no degradation) | (post-impl) — requires Step-1b restore + scan run |

---

## 9.2 Expert Review Status (Alex 必填)

> Conductor runs expert review (Y4/Y6) — table populated there. Alex does NOT pre-run review for this handoff.

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| _(Conductor Y4/Y6 to populate)_ | — | — | — |

### Experts Selected
1. **code-reviewer** — shell correctness, BSD portability, idempotency, set-logic bugs.
2. **backend-architect** (or equivalent) — advisory-not-blocking contract, type-probe rot-freeness + empty-glob safety, source-dir-ification downstream-portability, drift-check API surface.

### Overall Assessment (post-integration)
- _(Conductor to fill)_

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **drift-check NEVER fail-closed.** No `set -e` abort; advisory exit code only; MUST NOT be registered as a blocking hook or settings.json `permissions.deny` (single-user CLI lesson, architecture.md 2026-04-15). Include a clearly-delimited SAFETY/forbidden header COMMENT block mirroring the `post-write-sync.sh:6-11` SAFETY-comment STYLE (there is NO code `forbidden_implementations` block in any `.tad/hooks/*.sh` — it is a comment, not a code construct).
- ⚠️ **scan-packs OVERWRITES pack-registry.yaml — committed→fresh is NOT byte-stable.** A fresh scan reorders entries + bumps `synced_from_version` (2.15.1→2.19.1). Verify TWO things: AC2.5a determinism (two post-16 scans → empty/date-only) AND AC2.5b committed→post-scan enumerated line-SET delta (reorder + version bump + 2 adds + date, no "Not specified" degradation).
- ⚠️ **Set B uses a POSITIVE `type:`-frontmatter probe — NO hardcoded allowlist.** A skill is a capability-pack skill ONLY if its SKILL.md frontmatter declares `type: reference-based|deep-skill|orchestration-router`. This is rot-free: framework skills declare no pack type, so a NEW framework skill never false-flags (a hardcoded allowlist would rot — backend P1-3). Gate Set B on `[ -f "$d/SKILL.md" ]`, Set C on `[ -f "$d/CAPABILITY.md" ]`.
- ⚠️ **Empty-glob / fresh-clone safety.** Use `shopt -s nullglob` so an unpopulated `.claude/skills` yields an empty Set B → (b) empty → exit 0 (NOT a crash, NOT a literal `*` name). `.claude/skills/_archived/` (no SKILL.md, no `type:`) MUST NOT be flagged.
- ⚠️ **BSD-safe shell only** — no `grep -P`, no `.*?`, no `\d`. Use `grep -l '^type: \(...\)'` for the probe and `comm` over `LC_ALL=C sort`-ed lists for set differences.

### 10.2 Known Constraints
- Keywords MUST be single-line flow form `keywords: [...]` in CAPABILITY.md (scan-packs `extract_keywords` ignores block-list form).
- `**CONSUMES**:`/`**PRODUCES**:` lines MUST start at column 0 (scan-packs greps `'^\*\*CONSUMES\*\*:'`), else "Not specified" leaks.
- ml-training stays source-only (no SKILL.md) this phase — it is loadable as Tier 1; only the (d) advisory WARN fires. **ml-training source-only is downstream-safe BECAUSE it already has an `install.sh`** (so `*sync` b2 can install it + `gh api .../install.sh` resolves) — this is exactly the property ai-voice was missing, which is why ai-voice now gets its own `install.sh` in FR1 (backend P2-3).

### 10.3 🆕 Sub-Agent使用建议
- [ ] **test-runner** - after the 4 steps, to run all AC commands and capture raw output.
- [ ] **bug-hunter** - only if drift-check set logic misbehaves.

---

## 11. 🆕 Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | ai-voice-production: minimal CAPABILITY.md vs full source-dir-ification (+install.sh + references copy) | **Full source-dir-ification (NOT minimal)** | Minimal CAPABILITY.md alone leaves a downstream landmine (backend P1-2): a video-creation-mirrored body's bare `references/` pointers DANGLE on Tier-1 load (resolve to a non-existent source `references/`), AND with no `install.sh` the synced registry advertises a pack that `*sync` b2 never installs + `gh api .../install.sh` 404s. Full source-dir-ification (CAPABILITY.md with resolving pointers + install.sh mirroring video-creation + `cp -r` references) closes dangling-pointer + downstream-404 at once (~10 min boilerplate). |
| 2 | drift-check: advisory (smoke alarm) vs blocking (fail-closed hook) | **Advisory** (exit code only, never blocks; SAFETY/forbidden header comment) | Single-user CLI lesson (architecture.md 2026-04-15): fail-closed hooks deny tool calls with no self-recovery; "日常恢复成本 > 防偶尔跳步骤收益". Drift is informational — surfaces desync, does not stop work. Wired into release pre-flight as advisory, NOT a release blocker. The forbidden marker is a SAFETY *comment* (post-write-sync.sh:6-11 style), not a code block (cr P1-1). SessionStart wiring deferred (optional, must not be fail-closed). |
| 3 | drift-check Set B: hardcoded framework-skill allowlist vs positive `type:`-frontmatter probe | **Positive `type:` probe (NO allowlist)** | A hardcoded 19-name allowlist ROTS — every new framework skill = spurious (b)-flag → false exit 1 (the "shared-files false-flag" trap, architecture.md 2026-04-24; backend P1-3). Capability packs declare `type: reference-based|deep-skill|orchestration-router` in SKILL.md frontmatter; framework skills don't. Probing for that type is rot-free: a new framework skill never false-flags because it never declares a pack type. |
| 4 | ml-training: remove from registry vs index as source-only | **Index it** (source-only, advisory-flagged) | It HAS a CAPABILITY.md → scan-packs indexes it (14→16); step1_5b Tier 1 can load it. NOT a phantom. It is downstream-safe because it already has `install.sh` (backend P2-3). The source/skill asymmetry surfaces only as the (d) advisory WARN. |

**💡 Human学习点**: A derived index (registry) silently rots when a producer (a new pack) skips the convention the indexer keys on. The fix is two-pronged: (1) make the outlier conform to the convention, (2) add a smoke-alarm that compares the index against ground truth bidirectionally — but keep the alarm advisory, never a fire suppressor.

---

## Required Evidence Manifest

Blake MUST produce ALL of the following at Gate 3 (paths under `.tad/evidence/` or pasted raw into the completion report):
1. **Completion report** — `.tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase2.md`.
2. **gate3_verdict marker** — frontmatter `gate3_verdict: pass|fail|partial` written as a Gate 3 post-step Edit (allowlisted value; post-write-sync hook consumes it).
3. **ai-voice-production source dir** — `ls .tad/capability-packs/ai-voice-production/` showing CAPABILITY.md + install.sh + references/ (7 files); `bash .tad/capability-packs/ai-voice-production/install.sh --check` (or `--help`) clean run.
4. **scan-packs output** — raw stdout (`scanned 16 packs`) + `grep -A6 'name: "ai-voice-production"'` registry excerpt + `grep -c '^  - name:'` = 16.
5. **No consumes/produces regression (AC2.6)** — committed vs post-scan "Not specified" count for the 14 pre-existing packs (must not increase).
6. **drift-check exit-code demo** — clean run `exit=0`; injected-mismatch run `exit=1` + the offending name printed; sed-reverted run `exit=0` (NOT git checkout); registry still 16 packs after.
7. **Determinism + line-SET diff** — AC2.5a: `diff` of two consecutive POST-16-state scans (only date line, or empty). AC2.5b: committed→post-scan `comm` line-SET diff matching the enumerated expected delta.

---

## 12. 🆕 Sub-Agent使用记录

Blake完成后填写：

| Sub-Agent | 是否调用 | 调用时机 | 输出摘要 | 证据链接 |
|-----------|---------|---------|---------|---------|
| test-runner | ✅/❌ | [...] | [...] | [...] |
| bug-hunter | ✅/❌ | [...] | [...] | [...] |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-05-31
**Version**: 3.1.0 (revision v2 — P0/P1 fixes applied: full source-dir-ification, type-probe Set B, empty-glob safety, file-existence gates, AC2.5a/b+AC2.6 rewrite, sed-revert AC2.3, SAFETY-comment precedent, ml-training install.sh note)
