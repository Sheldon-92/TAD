**PM 2026-09-10:** Human Gate2 确认通过 + 当 Blake。

---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta:
  - field: "Layer 2 disk path"
    alex_said: "Blake Layer 2 artifacts land under .tad/evidence/reviews/blake/<slug>/"
    actual: "layer2-audit.sh exit 1, directory missing; Gate 4 independent code+security reviews written instead; EQUIVALENT_SUBSTITUTE accepted"
    caught_by: "Alex layer2-audit.sh + Gate 4 recompute"
  - field: "AGENTS.md closer"
    alex_said: "How-to-use is pointer-only after keyword match"
    actual: "AC1 dump strings gone; leftover sentence 'Only load when the user's task clearly matches keywords' remains (P2, not FAIL)"
    caught_by: "Gate 4 code-reviewer P2"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-09-10
**Project:** TAD Framework
**Task ID:** TASK-20260910-PACK-LOADER-THIN
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A
**Design:** `.tad/evidence/designs/2026-09-10-pack-loader-thin-ondemand.md`
**Prior discuss:** `.tad/evidence/designs/2026-09-10-pack-thin-ondemand-freeze.md`
**Status:** READY_FOR_GATE2

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-09-10 (pending dual expert review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Pointer default + freeze skip (missing=active) + escalate gates |
| Components Specified | ✅ | §7 sites + explicit experiment-path defer |
| Functions Verified | ✅ | Reuse `extract_frontmatter_field`; AC5 forbids `Read "$available_path"` |
| Data Flow Mapped | ✅ | CAPABILITY.md `status` → registry → loaders; live missing field = active |

**Gate 2 结果**: ✅ PASS (P0 from dual review integrated; READY_FOR_GATE2 — human confirms before READY_FOR_BLAKE)

**Alex确认**: Design + AC Methods are complete. Do not implement until human says 当 Blake.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

Change **capability-pack loaders** so a keyword/description match announces a **pointer** (name + when + path) and does **not** Read `SKILL.md`. Skip auto-match when registry `status: frozen`. Files stay on disk. Escalate to full SKILL only if the human names the pack or a **recorded** failure-retry exists. Land the policy in L2 `pack-build-rules.md`. Teach `scan-packs.sh` to emit `status:` (default `active`) from CAPABILITY frontmatter.

### 1.2 Why We're Building It

**业务价值**：强模型默认不再为“碰巧命中关键词”付一整本 pack 税；冻结包从自动匹配消失，磁盘参考仍在。  
**用户受益**：会话开头不再被 pack SKILL dump 占满；真正需要时仍能点名加载。  
**成功的样子**：match → 指针行；frozen → 静默跳过；human-named / recorded retry → Read SKILL；keyword-only → 禁止 dump。

### 1.3 Intent Statement

**真正要解决的问题**：当任务只是“像某个 pack 的领域”时，live Alex/Blake/AGENTS 仍把 Read 整份 SKILL.md 当成义务，冻结文件也不减税。

**不是要做的（避免误解）**：
- ❌ 不是 Pass-2 全量 KEEP/FREEZE 清单，也不是把任何 live pack 标 frozen
- ❌ 不是改 L1 `principles.md`、Epic、tad.sh、hooks、新 Gate、Cordis/pluginize
- ❌ 不是改写 pack 正文 / 卸装 / 删 AGENTS 关键词表
- ❌ 不是并进 v2.44.4 publish
- ❌ 不是 Workshop 第二套 pack SSOT

**Blake请确认理解**：
```
Match = pointer (max 2). Frozen registry status = skip auto-match, files remain.
Read SKILL.md only after human names the pack (incl. *design step1_5b confirm /
explicit handoff pack section) OR a written failure-retry. Keyword match alone
must not dump SKILL.md.
```

---

## 2. Socratic Inquiry Summary (Co-Definition)

Human locked 5Qs in-session (2026-09-10). No further AskUserQuestion. Process depth: **Standard TAD**, **no Epic** (lock 2).

| 阶段 | 问题 | 结果 |
|------|------|------|
| Phase 1 | Q1 ICP | TAD 内部：零上下文的未来 Alex/Blake；最关心不把 match 当成必读手册 |
| Phase 1 | Q2 Problem | 当任务命中 pack 关键词时，协议仍 Read 整份 SKILL.md；磁盘 freeze 不减税 |
| Phase 2 | Q3a Scope | Loader + L2 pattern + scan-packs `status` emit |
| Phase 2 | Q3b Exclusion | Inventory freeze roster; L1; tad.sh/hooks; pack rewrite; Cordis; v2.44.4 |
| Phase 3 | Q4 Risk (user) | 锁 4：禁止 keyword 静默 full-read（最大回归风险） |
| Phase 3 | Q4 Risk (Alex) | scan-packs 覆盖 registry；漏改 dual-platform；1_5a 显式 handoff 引用被误删 |
| Phase 3 | Q5 AC | §9.1 AC1–AC12 |

**ICP Anchor**: Solo/framework maintainer 在 live TAD 会话里需要 pack 判断力按需出现，最关心 token 税与静默 dump。

---

## 3. Requirements

### FR

- **FR1** Auto-match (step4_5, discuss awareness, Blake 1_5a auto-detect, AGENTS keyword table) announces a pointer and MUST NOT Read SKILL.md.
- **FR2** Registry `status: frozen` → skip auto-match. Missing `status` → treat as `active`. Pack files remain.
- **FR3** Escalate to Read SKILL.md only if (a) human names the pack / confirms step1_5b / handoff lists the pack as loaded, or (b) recorded failure-retry (Layer 1 retry / Gate FAIL / human says generalist was wrong, naming the pack).
- **FR4** `references/*.md` only after SKILL escalated, via the pack’s own Step 0/1. Collision advisory only among escalated packs. Max 2 pointers.
- **FR5** L2 pattern documents pointer default / freeze skip / escalate gates. `_index.md` hook updated.
- **FR6** `scan-packs.sh` emits `status:` from CAPABILITY.md frontmatter; omit → `active`. Do not freeze any live pack in this ticket.
- **FR7** Dual-platform byte identity for the three alex reference pairs and the Blake `1_5a` block. AGENTS.md is the Codex catalog (single file).
- **FR8** §7 pathspec only. Forbidden: `tad.sh`, `.tad/hooks/**`, `principles.md`.

### NF

- Surgical edits. Do not slim unrelated Blake/Alex protocol.
- `pack-registry.yaml` is generated — do not hand-edit live registry as the freeze SSOT; do not run live `scan-packs.sh` against the repo packs dir unless needed to prove emit (prefer `--packs-dir` fixture).

---

## 4. Technical Design

See `.tad/evidence/designs/2026-09-10-pack-loader-thin-ondemand.md`.

### 4.1 Pointer announcement (canonical one-liner)

Agents MUST emit (or equivalent):

`Pack pointer: {name} — {one-line when}. Path: {SKILL.md}. Do not load unless escalated.`

Source: registry `description` + `keywords` + `path` already read for matching. **Do not Read SKILL.md** to compose the one-liner.

### 4.2 Freeze

- Durable: optional `status: frozen` (or `active`) in CAPABILITY.md YAML frontmatter.
- Derived: `scan-packs.sh` writes `status: "{value}"` per pack row.
- Loaders: if `status` equals `frozen` (exact), skip that pack in auto-match. Any other/missing value = active.

### 4.3 Escalate

**Allowed Read SKILL.md:**
1. Human names pack or says load pack.
2. `*design` step1_5b user confirms the pack (AskUserQuestion). Until confirm: file-exists check only.
3. Handoff section `🔧 Capability Pack References` lists the pack (human already confirmed).
4. Recorded failure-retry as defined in the design note.

**Forbidden:** keyword/semantic match alone; “weak model” heuristic without a record; collision file at pointer time.

### 4.4 Blake 1_5a split

Keep step 1 (explicit handoff pack section → Read). Change step 2 auto-detect to pointer + freeze skip, same escalate gates. Do not re-Read a pack already escalated in step 1.

### 4.5 AGENTS.md

Replace the paragraph that currently orders “read the pack's SKILL.md BEFORE responding” and the later “When keywords match, read the SKILL.md file.” Keep the keyword table. Instruct: consult registry `status`; skip frozen; pointer on match; escalate per FR3.

---

## 5. Research Evidence

Repo-decidable (research-gate silent). Prior art: discuss 2026-09-10; YOLO Rule Soup L1 (do not edit); pack-build-rules skill-vs-MCP 2026-06-23; `knowledge-maintain` LOW-USAGE is not a freeze trigger; `scan-packs.sh` overwrite contract.

---

## 📚 Project Knowledge

Matched L2: `pack-build-rules.md`, `ac-verification.md`, `pack-evaluation.md` (anti-slop: dump is unearned if a frontier model would emit the same without the pack).

⚠️ Blake 必须注意的历史教训:
- **Skill vs MCP (pack-build-rules 2026-06-23)** — judgment packs stay skills; this ticket does not Cordis-ize them. Loader still must not treat them as must-read manuals.
- **AC Verification Drift** — dry-run greps; do not mentally simulate dual-platform diffs.
- **AC Self-Leak** — absence greps must not be satisfied by this handoff’s rationale comments in the same files; keep forbidden dump phrases out of the loader protocols (cite this task id in evidence reviews, not in the protocol files as “we removed read SKILL.md BEFORE responding”).
- **Deny-list / derived registry** — `pack-registry.yaml` header says do not edit manually; freeze persistence is CAPABILITY frontmatter + scanner.
- **Mechanical Enforcement Rejected** — no hook to prove packs are thin.

---

## 6. Implementation Steps

1. Add L2 pattern to `pack-build-rules.md`: pointer default, freeze skip, escalate gates, durable `status` on CAPABILITY.md. **Mechanic only** — do not paste discuss freeze-candidate scoring or named pack freeze examples. Update `_index.md` hook to include pointer/freeze (stay ≤120 chars; shorten other hook words if needed).
2. `scan-packs.sh`: extract `status` via `extract_frontmatter_field`; default `active`; emit `status: "..."` on each pack YAML block. Header: do not hand-edit registry status.
3. Rewrite Alex `intent-router-protocol.md` step4_5 (both trees): skip **iff** registry `status` equals `frozen`; **missing status = active**; pointer; max 2 pointers; collision only after escalation; delete “Read matched pack(s) SKILL.md” as default. Rewrite the note that “step4_5 already loaded a pack → step1_5b skip re-load”: **pointer ≠ loaded**; step1_5b must still AskUserQuestion to escalate.
4. Rewrite `discuss-path-protocol.md` `capability_pack_awareness` (both trees): same freeze/missing/pointer/escalate contract.
5. Rewrite Blake `1_5a_pack_detection` (both SKILL.md): split explicit vs auto-detect as §4.4; auto-detect must **not** `Read "$available_path"`; include frozen skip + missing=active. Touch only this block; copy whole file to `.agents` after edit so AC5 `diff -q` stays 0.
6. Rewrite `design-protocol.md` step1_5b (both): file-exists only before confirm; **no** “Load CAPABILITY.md directly” / “Load that SKILL.md as the pack content” before AskUserQuestion; AskUserQuestion copy uses registry description/consumes/produces; **frozen packs omitted from the offer list**; missing status = active; on confirm = human-named escalate.
7. Rewrite `AGENTS.md` Capability Packs intro + “How to use” per §4.5. Required tokens: `Do not load unless escalated`, `status: frozen`, `human-named`, `failure-retry`, `missing status`. Keep table rows.
8. Do **not** set any live CAPABILITY.md `status: frozen`. Do **not** regenerate live `pack-registry.yaml` (prefer `--packs-dir` fixture). Live registry today has **no** `status` keys — loaders must treat that as active (lock 3), not as skip-all.
9. Dual-platform: `diff -q` the three alex pairs; Blake SKILL.md files identical.
10. **Explicit defer (not §7):** `experiment-path-protocol.md` `capability_pack_auto_load` still Reads `ai-evaluation/SKILL.md`. Out of this pathspec (discuss Pass-3 loader list). Residual lock-4 dump. Later ticket. Do not “complete FR1” by claiming every TAD path is pointer-only.

### 6.7 AC Dry-Run Log

Filled after step1d (below).

---

## 7. File Structure

### 7.1 Files to Create

None in product tree. (Design already exists. Fixture dirs for AC6 are tmp, not committed.)

### 7.2 Files to Modify (STRICT PATHSPEC — commit only these)

```
.tad/project-knowledge/patterns/pack-build-rules.md
.tad/project-knowledge/patterns/_index.md
.tad/scripts/scan-packs.sh
.claude/skills/alex/references/intent-router-protocol.md
.agents/skills/alex/references/intent-router-protocol.md
.claude/skills/alex/references/discuss-path-protocol.md
.agents/skills/alex/references/discuss-path-protocol.md
.claude/skills/alex/references/design-protocol.md
.agents/skills/alex/references/design-protocol.md
.claude/skills/blake/SKILL.md
.agents/skills/blake/SKILL.md
AGENTS.md
```

**Forbidden in the implementation commit:** `tad.sh`, `.tad/hooks/**`, `.tad/project-knowledge/principles.md`, pack SKILL/CAPABILITY bodies, live freeze roster, CHANGELOG/version unless human later asks.

Alex process files (handoff, design, NEXT, session-state, reviews) are **not** Blake’s pathspec.

### 7.3 Grounded Against (Alex step1c, 2026-09-10)

- `.claude/skills/alex/references/intent-router-protocol.md` (step4_5 L116–173)
- `.claude/skills/alex/references/discuss-path-protocol.md` (capability_pack_awareness)
- `.claude/skills/alex/references/design-protocol.md` (step1_5b)
- `.claude/skills/blake/SKILL.md` (1_5a L557–596)
- `AGENTS.md` (Capability Packs L103–137)
- `.tad/scripts/scan-packs.sh` (full; emit L170–179)
- `.tad/capability-packs/pack-registry.yaml` (header: auto-generated; no `status` field today)
- `.tad/project-knowledge/patterns/pack-build-rules.md` (skill-vs-MCP + architecture)
- `.tad/project-knowledge/patterns/_index.md` (pack-build-rules hook)
- `.agents/skills/alex/references/{intent-router,discuss-path,design}-protocol.md` (exist; dual)
- `.agents/skills/blake/SKILL.md` (1_5a present at L557)

LSP: skipped (`task_type: mixed` protocol/docs; graph probe not used; MUST NOT auto-index).

---

## 8. Testing Requirements

### 8.1 Unit Tests

`scan-packs.sh --packs-dir=<tmp>` with two fake packs (missing status vs `status: frozen`).

### 8.2 Integration Tests

Grep contracts in §9.1. Dual `diff -q`.

### 8.3 Edge Cases

- Missing `status` = active (still pointer, not skip).
- Explicit handoff pack list still allows Read.
- Frozen pack must not appear in pointer list even if keywords match.

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Dual-platform drift | Keep `.claude` / `.agents` pairs identical | Copy after edit + `diff -q` | None | AC10 FAIL |
| Large Blake SKILL.md | Surgical 1_5a only | Search-replace the block | None | Scope FAIL |
| scan-packs live overwrite | Use `--packs-dir` fixture | Do not rewrite live registry | N/A | Avoid dirty last_scanned |
| No new runtime deps | None | — | — | — |

No friction-sensitive missing tools. Reviewers: Layer 2 after impl as usual.

**Status Enum:** READY / BLOCKED / DEGRADED_WITH_APPROVAL / EQUIVALENT_SUBSTITUTE / NOT_APPLICABLE_WITH_REASON

## 8.5 Feedback Collection

```yaml
feedback_required: false
artifact_type: generic
suggested_dimensions: []
notes: "Protocol/docs loader policy; no overlay artifact."
```

## 8.6 Test Evidence Required

- [ ] §9.1 command transcripts
- [ ] `diff -q` dual-platform
- [ ] scan-packs fixture stdout
- [ ] `git diff --stat` scoped to §7.2

---

## Required Evidence Manifest

```yaml
expert_reviews: [".tad/evidence/reviews/2026-09-10-gate2-pack-loader-thin-ondemand-code.md", ".tad/evidence/reviews/2026-09-10-gate2-pack-loader-thin-ondemand-spec.md"]
gate_verdicts: ["Gate 2 in this handoff", "Gate 3 completion", "Gate 4 later"]
completion: ".tad/active/handoffs/COMPLETION-20260910-pack-loader-thin-ondemand.md"
blake_reviews: "Layer 2 Group 0 + code-reviewer after impl"
perf_evidence: []
fixture_results: "scan-packs --packs-dir tmp transcript"
dogfood: []
knowledge_updates: [".tad/project-knowledge/patterns/pack-build-rules.md"]
```

---

## 9. Acceptance Criteria

- [ ] FR1–FR8 true on disk
- [ ] No live pack frozen
- [ ] No tad.sh / hooks / principles.md in the impl commit
- [ ] Dual-platform pairs identical

## 9.1 Spec Compliance Checklist

> Gate 3 must execute the **raw** Method (unescape markdown `\|` → `|` inside `$()` only). Every row uses `test` so a later success cannot hide an earlier fail. `grep -c` zeros: use `|| true` before `test`.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | AGENTS.md no longer orders pre-read SKILL on keyword match | post-impl-verifiable | `a=$(grep -cF -- "read the pack's SKILL.md BEFORE responding" AGENTS.md \|\| true); b=$(grep -cF -- "When keywords match, read the SKILL.md file" AGENTS.md \|\| true); test "$a" -eq 0 && test "$b" -eq 0; echo a=$a b=$b` | `a=0 b=0` and exit 0 | (post-impl) |
| AC2 | AGENTS.md pointer + escalate + freeze skip + missing-status=active | post-impl-verifiable | `a=$(grep -cF -- "Do not load unless escalated" AGENTS.md \|\| true); b=$(grep -cF -- "status: frozen" AGENTS.md \|\| true); c=$(grep -cF -- "human-named" AGENTS.md \|\| true); d=$(grep -cF -- "failure-retry" AGENTS.md \|\| true); e=$(grep -cF -- "missing status" AGENTS.md \|\| true); test "$a" -ge 1 && test "$b" -ge 1 && test "$c" -ge 1 && test "$d" -ge 1 && test "$e" -ge 1; echo a=$a b=$b c=$c d=$d e=$e` | all five `>=1`; exit 0 | (post-impl) |
| AC3 | step4_5 pointer not dump; missing=active; dual trees | post-impl-verifiable | `diff -q .claude/skills/alex/references/intent-router-protocol.md .agents/skills/alex/references/intent-router-protocol.md; dump=$(grep -cF -- "Read matched pack(s) SKILL.md" .claude/skills/alex/references/intent-router-protocol.md \|\| true); ptr=$(grep -cF -- "Do not load unless escalated" .claude/skills/alex/references/intent-router-protocol.md \|\| true); miss=$(grep -cF -- "missing status" .claude/skills/alex/references/intent-router-protocol.md \|\| true); test "$dump" -eq 0 && test "$ptr" -ge 1 && test "$miss" -ge 1; echo dump=$dump ptr=$ptr miss=$miss` | diff exit 0; dump=0; ptr>=1; miss>=1 | (post-impl) |
| AC4 | discuss awareness same contract (both trees) | post-impl-verifiable | `diff -q .claude/skills/alex/references/discuss-path-protocol.md .agents/skills/alex/references/discuss-path-protocol.md; dump=$(grep -cF -- "exists → Read SKILL.md" .claude/skills/alex/references/discuss-path-protocol.md \|\| true); ptr=$(grep -cF -- "Do not load unless escalated" .claude/skills/alex/references/discuss-path-protocol.md \|\| true); miss=$(grep -cF -- "missing status" .claude/skills/alex/references/discuss-path-protocol.md \|\| true); test "$dump" -eq 0 && test "$ptr" -ge 1 && test "$miss" -ge 1; echo dump=$dump ptr=$ptr miss=$miss` | diff exit 0; dump=0; ptr>=1; miss>=1 | (post-impl) |
| AC5 | Blake 1_5a: no available_path Read; escalate+freeze+missing kept; dual SKILL | post-impl-verifiable | `python3 -c 'import pathlib; p=pathlib.Path(".claude/skills/blake/SKILL.md").read_text(); b=p.split("1_5a_pack_detection:")[1].split("1_5b_research_check:")[0]; assert "Do not load unless escalated" in b; assert "frozen" in b; assert "missing status" in b; assert "Capability Pack References" in b; assert "Read \"$available_path\"" not in b'; diff -q .claude/skills/blake/SKILL.md .agents/skills/blake/SKILL.md` | python exit 0; diff exit 0 | (post-impl) |
| AC6 | scan-packs emits frozen and active; both must pass | post-impl-verifiable | `TMP=$(mktemp -d); mkdir -p "$TMP/frozen-pack" "$TMP/active-pack"; printf '%s\n' '---' 'name: frozen-pack' 'description: d' 'status: frozen' 'type: reference-based' 'keywords: ["x"]' '---' '**CONSUMES**: a' '**PRODUCES**: b' > "$TMP/frozen-pack/CAPABILITY.md"; printf '%s\n' '---' 'name: active-pack' 'description: d' 'type: reference-based' 'keywords: ["y"]' '---' '**CONSUMES**: a' '**PRODUCES**: b' > "$TMP/active-pack/CAPABILITY.md"; bash .tad/scripts/scan-packs.sh --packs-dir="$TMP"; fz=$(grep -cF -- 'status: "frozen"' "$TMP/pack-registry.yaml" \|\| true); ac=$(grep -cF -- 'status: "active"' "$TMP/pack-registry.yaml" \|\| true); test "$fz" -ge 1 && test "$ac" -ge 1; echo fz=$fz ac=$ac` | fz>=1 ac>=1; exit 0 | (post-impl) |
| AC7 | L2 pattern exists | post-impl-verifiable | `h=$(grep -c '^### ' .tad/project-knowledge/patterns/pack-build-rules.md \|\| true); p=$(grep -cF -- pointer .tad/project-knowledge/patterns/_index.md \|\| true); f=$(grep -cF -- freeze .tad/project-knowledge/patterns/_index.md \|\| true); test "$h" -ge 20 && test "$p" -ge 1 && test "$f" -ge 1; echo h=$h p=$p f=$f` | h>=20 (pre-impl 19); p>=1; f>=1 | (post-impl) |
| AC8 | design step1_5b: no pre-confirm Load; freeze skip; missing=active; dual | post-impl-verifiable | `diff -q .claude/skills/alex/references/design-protocol.md .agents/skills/alex/references/design-protocol.md; cap=$(grep -cF -- "Load CAPABILITY.md directly from this path" .claude/skills/alex/references/design-protocol.md \|\| true); sk=$(grep -cF -- "Load that SKILL.md as the pack content" .claude/skills/alex/references/design-protocol.md \|\| true); conf=$(grep -cF -- "On confirmation" .claude/skills/alex/references/design-protocol.md \|\| true); miss=$(grep -cF -- "missing status" .claude/skills/alex/references/design-protocol.md \|\| true); frz=$(grep -cF -- "frozen" .claude/skills/alex/references/design-protocol.md \|\| true); test "$cap" -eq 0 && test "$sk" -eq 0 && test "$conf" -ge 1 && test "$miss" -ge 1 && test "$frz" -ge 1; echo cap=$cap sk=$sk conf=$conf miss=$miss frz=$frz` | diff exit 0; cap=0 sk=0; conf/miss/frz >=1 | (post-impl) |
| AC9 | Forbidden paths absent from impl commit | post-impl-verifiable | `git diff-tree --no-commit-id --name-only -r HEAD > /tmp/tad-loader-impl-names.txt; a=$(grep -cF -- tad.sh /tmp/tad-loader-impl-names.txt \|\| true); b=$(grep -cF -- .tad/hooks /tmp/tad-loader-impl-names.txt \|\| true); c=$(grep -cF -- principles.md /tmp/tad-loader-impl-names.txt \|\| true); test "$a" -eq 0 && test "$b" -eq 0 && test "$c" -eq 0; echo a=$a b=$b c=$c` | three 0; Gate 3 runs this on the **implementation commit** SHA in COMPLETION | (post-impl) |
| AC10 | Dual-platform three alex pairs | post-impl-verifiable | `diff -q .claude/skills/alex/references/intent-router-protocol.md .agents/skills/alex/references/intent-router-protocol.md; diff -q .claude/skills/alex/references/discuss-path-protocol.md .agents/skills/alex/references/discuss-path-protocol.md; diff -q .claude/skills/alex/references/design-protocol.md .agents/skills/alex/references/design-protocol.md` | three exit 0 | (post-impl) |
| AC11 | No live pack frozen by this ticket | post-impl-verifiable | `python3 -c "import pathlib; n=sum(1 for p in pathlib.Path('.tad/capability-packs').rglob('CAPABILITY.md') if 'status: frozen' in p.read_text()); print(n); raise SystemExit(0 if n==0 else 1)"` | prints `0`; exit 0 | (post-impl) |
| AC12 | Change scope = §7.2 | post-impl-verifiable | `git diff-tree --no-commit-id --name-only -r HEAD` | names ⊆ §7.2 (plus none of tad.sh/hooks/principles). Gate 3 on impl SHA | (post-impl) |
| AC0 | Pre-impl baseline: dump instruction currently exists | pre-impl-verifiable | `grep -cF -- "read the pack's SKILL.md BEFORE responding" AGENTS.md; grep -cF -- "Read matched pack(s) SKILL.md" .claude/skills/alex/references/intent-router-protocol.md; grep -cF -- "status:" .tad/scripts/scan-packs.sh; grep -c '^### ' .tad/project-knowledge/patterns/pack-build-rules.md` | AGENTS `1`; step4_5 dump `1`; scan-packs `status:` `0`; headings `19` | AGENTS=1; dump=1; status:=0; headings=19 |

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: AC5 did not forbid auto-detect `Read "$available_path"` | AC5 python assert | Resolved |
| code-reviewer | P0: AC6/AC3/AC4/AC8 last-grep-wins `;` chains | §9.1 `test` conjunctions | Resolved |
| code-reviewer | P0: AC9/AC12 worktree diff not impl commit | `git diff-tree … HEAD` on COMPLETION SHA | Resolved |
| spec/arch | P0: missing `status` = active not in loader ACs | AC2–AC5/AC8 `missing status` + §6.3–6.7 | Resolved |
| spec/arch | P1: AC8 missed Tier-2 pre-confirm Load SKILL | AC8 `Load that SKILL.md as the pack content` = 0 | Resolved |
| spec/arch | P1: step1_5b freeze-skip unspecified | §6.6 frozen omitted from offer list | Resolved |
| spec/arch | P1: pointer ≠ already-loaded skip | §6.3 rewrite step4_5/step1_5b note | Resolved |
| spec/arch | P1: experiment-path residual dump | §6.10 explicit defer, not §7 | Resolved |
| code-reviewer | P1: AC7 exact 20 headings | AC7 `test h -ge 20` | Resolved |
| code-reviewer | P1: AC11 markdown pipe | AC11 python rglob | Resolved |

### Experts Selected

1. **code-reviewer** — AC legality, pathspec, dual-platform, scan-packs contract
2. **spec-compliance / architecture (generalPurpose)** — FR vs loader sites, freeze SSOT, escalate gates

### Overall Assessment (post-integration)

- code-reviewer: FAIL → P0 closed in handoff (CONDITIONAL equivalent PASS for Gate 2 design)
- spec/arch: CONDITIONAL → P0/P1 closed in handoff
- Round 1 of 2; no second spawn (fixes are AC/spec text, not new architecture)

---

## 10. Important Notes

### 10.1 Critical Warnings

- ⚠️ Do not freeze a real pack “as a demo.”
- ⚠️ Do not drop AGENTS keyword rows (catalog stays; duty changes).
- ⚠️ Do not delete Blake 1_5a step 1 (explicit handoff Read).
- ⚠️ Absence-grep self-leak: do not put the exact forbidden AGENTS sentence into pack-build-rules as a quoted anti-pattern if AC1 is counted repo-wide — AC1 is scoped to `AGENTS.md` only.

### 10.2 Known Constraints

- Live `pack-registry.yaml` has no `status` until a future scan; loaders must treat missing as active.
- Alex `SKILL.md` body only *mentions* step4_5; the contract lives in the reference file.

### 10.3 Anti-patterns

- Keyword match → silent full-read
- Hook to “prove thin”
- Hand-editing generated registry as freeze SSOT
- Mixing PARK A (principles/_index activation) into this pack policy

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Sequence | inventory-first / strategy-first | strategy then this loader | Human lock 1 |
| 2 | Policy home | L1 Epic / L2+loader / loader-only | L2 + loader | Human lock 2 |
| 3 | Freeze | registry / drop AGENTS rows / deprecation.yaml | registry status + skip; files stay | Human lock 3 |
| 4 | Escalate | human-only / failure / weak-model | human-named OR recorded failure-retry | Human lock 4 |
| 5 | Durable status | hand-edit registry / CAPABILITY frontmatter | CAPABILITY.md + scan-packs emit | registry is generated |

---

## MQ1–MQ6

**MQ1 historical:** Searched `step4_5`, `1_5a_pack_detection`, `capability_pack_awareness`, `AGENTS.md` Capability Packs, `scan-packs.sh`. Reuse those sites; do not invent a new loader.

**MQ2 functions:** `extract_frontmatter_field` exists in `scan-packs.sh` L47–54. No other new functions required.

**MQ3 data flow:** N/A (no UI). Flow: CAPABILITY frontmatter → registry YAML → protocol skip/pointer.

**MQ4 visual:** N/A

**MQ5 state:** Single derived SSOT for match: `pack-registry.yaml`. Durable write: CAPABILITY.md. AGENTS table is a catalog, not freeze SSOT.

**MQ6 research:** Discuss note + existing max-2 / Rule Soup / skill-vs-MCP. Options dump vs pointer vs plugin; pointer+freeze skip chosen by human.

---

## AC Conflict Matrix

No byte-preservation × perf × behavioral triple. AC1 (absence in AGENTS.md) vs documenting the old phrase: keep the old phrase **out** of AGENTS.md; evidence reviews may quote it.

---

## Step1d Dry-Run / AC Dry-Run Log

**AC Dry-Run Log** (Alex step1d 2026-09-10 20:05 UTC):

- AC0: ✅ pre-impl-verifiable. Raw:
  - `grep -cF -- "read the pack's SKILL.md BEFORE responding" AGENTS.md` → `1` (L105)
  - `grep -cF -- "When keywords match, read the SKILL.md file" AGENTS.md` → `1`
  - `grep -cF -- "Read matched pack(s) SKILL.md" .claude/skills/alex/references/intent-router-protocol.md` → `1`
  - `grep -cF -- "status:" .tad/scripts/scan-packs.sh` → `0`
  - `grep -c '^### ' .tad/project-knowledge/patterns/pack-build-rules.md` → captured in AC7 expected pre-impl floor
  - dual `diff -q` intent/discuss/design/blake → all identical (exit 0)
- AC1–AC12: ✅ post-impl-verifiable; Methods rewritten to `grep -cF` / `diff -q` / tmp fixture (no ERE `\|`); syntax of `scan-packs.sh` `bash -n` OK; python 1_5a split probe OK (`Capability Pack References` present)
- Advisory `verify-ac-commands.sh`: first draft had 3 Rule B WARNs (ERE pipes) — Methods revised; re-run after this edit

Pre-impl `grep -c '^### ' pack-build-rules.md` floor for AC7: Blake must increase heading count by adding one new `###` entry (floor = current count from AC0).
