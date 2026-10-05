**PM 2026-09-11:** Gate2 dual CONDITIONAL PASS P0=0 + human locks 2,1,2,1,1; PM auto-dispatch Blake (no 当Blake wait).

---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-09-11
**Project:** TAD Framework
**Task ID:** TASK-20260911-KEEP11-KNIFE1
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A
**Design:** `.tad/evidence/designs/2026-09-11-keep11-knife1-cli-refresh.md`
**Prior discuss:** `.tad/evidence/designs/2026-09-11-keep-pointer-11-content-refresh.md`
**Status:** READY_FOR_GATE2 (dual review P0=0; P1 harness integrated)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-09-11

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review (min 2) | ✅ | code-reviewer substitute + security-auditor substitute; both P0=0 |
| All P0 resolved | ✅ | R1 dual CONDITIONAL PASS, P0=0 → `p0_resolved_definition` (b); P1 folded into verify.py AC1–AC9 |
| Architecture Complete | ✅ | Inventory → dry-run/docs-pin → banner + SHA re-pin → dual-tree + cap-pack parity |
| Components Specified | ✅ | Two KEEP packs only; find-action-sha.sh reused; verify.py Alex-owned |
| Functions Verified | ✅ | `find-action-sha.sh` exists; gitleaks banner is the template |
| Data Flow Mapped | ✅ | Escalate Read → copy CLI/SHA; SSOT `.claude` then `.agents` + capability-packs |

**Gate 2 结果**: ✅ PASS (READY_FOR_GATE2 — human confirms before READY_FOR_BLAKE)

Carriers:
- `.tad/evidence/reviews/2026-09-11-gate2-keep11-knife1-code.md`
- `.tad/evidence/reviews/2026-09-11-gate2-keep11-knife1-security.md`

**Alex确认:** Do not implement until human sets READY_FOR_BLAKE and says 当 Blake. Native `security-auditor` / `code-reviewer` types were unavailable (Opus limit / missing type); two independent generalPurpose sessions used as EQUIVALENT_SUBSTITUTE. Self-review was not used.

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building

KEEP11 Knife 1: refresh **body freshness** of `code-security` and `web-deployment` only. Extract documented CLIs, dry-run them (or pin official docs if ABSENT), add `Verified against {ver} on {date}` banners, re-resolve example GitHub Action SHAs, bump retrieval dates on versioned claims in those files. Dual-platform + capability-packs mirrors. Local commit. No push/tag.

### 1.2 Why We're Building It

**业务价值：** Pointer still announces these packs; a wrong command is worse than a stale essay (shipped miss: gitleaks `protect`/`detect` until `58978798`).  
**用户受益：** Escalated KEEP body is dated-true for CLI/SHA.  
**成功的样子：** Reader sees a 2026-09-11 (or Blake run-day) banner per CLI-bearing file; `actions/checkout@v4.1.7` example SHA matches `find-action-sha.sh`; `@v4` remains the anti-pattern, not the recommended pin.

### 1.3 Intent Statement

**真正要解决的问题：** KEEP body may teach a CLI that does not exist or a SHA that no longer matches the named tag.

**不是要做的（避免误解）：**
- ❌ Not unfreezing the 14 / not touching other KEEP 9
- ❌ Not loader / dump vs pointer / experiment-path
- ❌ Not OWASP/SSVC/platform essay rewrite
- ❌ Not discriminative eval re-run
- ❌ Not Epic wrapper; not v2.44.4 absorb; not push/tag
- ❌ Not Gemini

**Blake请确认理解：**
```
1. This knife makes two KEEP packs' CLIs/SHAs checkable with a dated banner.
2. Agents copy commands from the pack; those commands must exist or be docs-pinned.
3. Success = dry-run (or docs URL) + Verified-against line + re-pinned example SHAs + pathspec.
```

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别

- [x] patterns/pack-build-rules.md
- [x] patterns/pack-evaluation.md
- [x] patterns/ac-verification.md
- [x] principles.md (Never Hand-Write What an Existing Tool Already Does; YOLO validation theater)

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件：**

| 文件 | 关键提醒 |
|------|----------|
| principles.md | Do not invent SHAs/CLIs from memory — run `find-action-sha.sh` / `--help`. |
| pack-build-rules.md | Verify API/CLI names against the tool, not the citation. |
| pack-evaluation.md | Structural-gold ≠ rewrite; ~6 month anti-slop clock not elapsed — this knife is CLI landmines, not essay gold. |
| ac-verification.md | Dry-run AC commands; no prose-only Methods. |

**⚠️ Blake 必须注意的历史教训：**

1. **Never Hand-Write What an Existing Tool Already Does** (principles.md, 2026-05-28) — use `scripts/find-action-sha.sh`; do not paste a remembered SHA.
2. **gitleaks 8.x subcommand rename** (`58978798`, NEXT 0e) — `protect`/`detect` gone; banner template already in `secret-detection-rules.md`. Copy that HTML-comment shape.
3. **Research provenance** (pack-build-rules) — do not interpolate per-tool versions from a blog range; only `--version` or a named docs URL.
4. **Cross-model API review** (pack-evaluation) — human lock: **no Gemini**. CLI/docs are the fact check. Do not skip banners because a reviewer is missing.
5. **AC dry-run** (ac-verification) — Alex already ran verify.py; post-impl rows must go green for real.

Stale-check: frontend-design Warm Palette STALE — **not relevant**; skip.

Local Wiki: no freshness page. Notebooks: 0 active. No new notebook.

---

## 2. Functional Requirements

- **FR1** Every documented CLI invocation in the two pack trees is inventoried.
- **FR2** Each unique `{tool} {subcommand}` is dry-run via `--help`/`--version` **or** pinned to official docs with URL when PATH ABSENT.
- **FR3** Each file in verify.py `BANNER_REL` contains `Verified against {ver} on {date}` (HTML comment, gitleaks shape).
- **FR4** Example good-pin SHAs for `actions/checkout@v4.1.7` match live `find-action-sha.sh` output. Rotten `b4ffde65…` gone from both packs' trees including CAPABILITY.md.
- **FR5** CI6 Quick Rule Index does not teach `actions/cache@v4` as the pin. CI2 still forbids tag pins (must keep `@v4` as anti-pattern somewhere).
- **FR6** `2026-05-20` example deadline removed from `vulnerability-triage-rules.md`.
- **FR7** `.claude` ↔ `.agents` byte-identical for listed twins. Existing capability-packs files updated in lockstep.
- **FR8** Impl commit ⊆ allow prefixes in verify.py. No frozen packs, loader, experiment-path, version/tag, NEXT.md.

---

## 3. Technical Requirements

- Banner format (copy): `<!-- Verified against {tool} {version} on {YYYY-MM-DD}. … -->`
- If ABSENT: `<!-- Verified against {tool} {version} on {YYYY-MM-DD} via docs {url} (CLI ABSENT on impl host). -->` — URL required. Do not bump a date while keeping an old version with neither `--version` nor that URL.
- Dry-run is **only** `--help`, `--version`, or `-h`. **Never** run documented scan/deploy verbs against this repo, any URL, or any bucket — including `gitleaks git`, `trufflehog git`/`filesystem`/`s3`, `nuclei -u`/`-update-templates`, `semgrep ci`/`scan .`, `checkov -d`, `trivy`/`grype` `fs`/`image`, `docker build`/`run` as the verify step.
- Reuse `.claude/skills/web-deployment/scripts/find-action-sha.sh`. Do not reimplement `git ls-remote`.
- Do not run pack `install.sh`.
- Do not create missing SKILL.md under `.tad/capability-packs/code-security/` (source tree uses CAPABILITY.md).

---

## 4. Technical Design

### 4.1 Edit order

1. Write `.tad/evidence/acceptance-tests/keep11-knife1/cli-inventory.md` (evidence; not impl commit).
2. For each tool: `command -v`; if yes, capture `--version` + `--help` and grep documented subcommands; if no, WebSearch official CLI reference (no Gemini) and record URL.
3. Patch command strings that fail (subcommand rename class).
4. Insert/update banners; bump `retrieved YYYY-MM-DD` on versioned claims in those files; update SKILL tool-table versions.
5. Re-pin checkout (and any other **good-pin** example SHA you touch) via find-action-sha.sh. Alex 2026-09-11: v4.1.7 → `692973e3d937129bcbf40652eb9f2f61becf3332`.
6. Fix CI6 wording; fix 2026-05-20 example.
7. `cp`/write twins + capability-packs.
8. Worktree: `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC1` … `AC5`, `AC8`, `AC9`. Then `git add` **only** allow-prefix paths. Local commit. Then `IMPL_SHA=<sha> python3 … AC6` `AC7`.

### 4.2 Allowed hunk classes

Command lines, version tokens, HTML banners, SHA pins, retrieval dates, CI6 index wording, triage example deadline. **Not** new capabilities, new tools, frozen packs, eval fixtures unless a command inside them is factually illegal (then one-line command fix only).

### 4.3 Monitoring / rollback CLIs

In scope for `--help` of `docker`/`vercel`/`netlify`/`flyctl`/`gh` **if present**; banners on those reference files. Do not rewrite DORA/SLO essays beyond the retrieval date on the same page if you already opened it for a CLI check.

---

## 5. 强制问题回答（MQ）

### MQ1 Historical code

Reuse: gitleaks banner in `secret-detection-rules.md`; `find-action-sha.sh`; freeze/loader pathspec discipline. Do not add a new Gate or hook.

### MQ2 Function existence

| Symbol | Location | Exists |
|--------|----------|--------|
| find-action-sha.sh | `.claude/skills/web-deployment/scripts/find-action-sha.sh` | ✅ |
| verify-deploy-hardening.sh | same `scripts/` | ✅ (do not require behavior change) |
| gitleaks banner | `secret-detection-rules.md` L3 | ✅ |
| verify.py | `.tad/evidence/acceptance-tests/keep11-knife1/verify.py` | ✅ Alex-owned |

### MQ3 Data flow

N/A UI. Agent reads markdown → copies CLI.

### MQ4 Visual hierarchy

N/A.

### MQ5 State sync

`.claude` is skill SSOT; `.agents` must match; capability-packs is install source for `references/` + CAPABILITY.md. Forget a twin → AC2 FAIL.

### MQ6 Technical research

| Option | Adopt |
|--------|--------|
| PATH `--help` | ✅ primary |
| Official docs URL when ABSENT | ✅ EQUIVALENT_SUBSTITUTE, recorded |
| Gemini | ❌ human lock |
| Discriminative eval re-run | ❌ lock Q4 |
| Invent SHA from training data | ❌ |

---

## 6. Implementation Steps

### Phase 1: Inventory + verify + patch + mirror (one sitting)

Follow §4.1. Human: Gate 3 then Gate 4 later. Not this session.

#### 验证方法

`python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py ACn`

#### Phase 1 完成证据

- [ ] cli-inventory.md with ABSENT vs CLI column
- [ ] verify.py AC1–AC5, AC8 green on worktree; AC6–AC7 green on impl SHA
- [ ] `git diff-tree --no-commit-id --name-only -r <impl SHA>` ⊆ allow prefixes

---

## 7. File Structure

### 7.1 Files to Create

- `.tad/evidence/acceptance-tests/keep11-knife1/cli-inventory.md` (evidence; **not** impl commit)
- Completion + Layer 2 reviews after impl (not impl commit)

### 7.2 Files to Modify (STRICT PATHSPEC — impl commit only these prefixes)

```
.claude/skills/code-security/**
.agents/skills/code-security/**
.tad/capability-packs/code-security/**
.claude/skills/web-deployment/**
.agents/skills/web-deployment/**
.tad/capability-packs/web-deployment/**
```

Likely bodies: SKILL.md, listed `references/*.md`, CAPABILITY.md, optionally examples if a documented command is illegal. Scripts only if a comment documents a dead CLI.

**Forbidden in the implementation commit:** frozen 14 packs, other KEEP 9, `pack-registry.yaml`, loaders, `experiment-path-protocol.md`, `AGENTS.md`, `CLAUDE.md`, `tad.sh`, `.tad/hooks/**`, `principles.md`, CHANGELOG/version, NEXT.md, this handoff, verify.py (already in tree; do not stage unless you did not touch it — do not add it to the impl commit).

### 7.3 Grounded Against (Alex step1c, 2026-09-11)

- `.claude/skills/code-security/SKILL.md` (head 50 + tool table L153–160)
- `.claude/skills/code-security/references/secret-detection-rules.md` (gitleaks banner L3–7)
- `.claude/skills/code-security/references/vulnerability-triage-rules.md` (deadline example L191)
- `.claude/skills/web-deployment/SKILL.md` (SHA example L75–76, find-action-sha L68)
- `.claude/skills/web-deployment/references/ci-cd-pipeline-rules.md` (CI2/CI6 L9–13, SHA L63)
- `.claude/skills/web-deployment/scripts/find-action-sha.sh` (head 50)
- `.tad/capability-packs/code-security/CAPABILITY.md` / `web-deployment/CAPABILITY.md` (no SKILL.md in cap-pack)
- `.agents/skills/{code-security,web-deployment}/` twins exist
- Design + discuss files above

LSP: skipped (`task_type: mixed` docs; MUST NOT auto-index). Graph probe: skip.

---

## 8. Testing Requirements

### 8.1 Unit Tests

N/A new product scripts. Optional: `--help` transcripts in inventory.

### 8.2 Integration Tests

verify.py AC1–AC8.

### 8.3 Edge Cases

- Tool ABSENT → docs pin, not skip banner.
- Tag `v4.1.7` yanked → pick current v4.x tag, update **both** tag label and SHA; keep CI2 anti-pattern.
- Fixture `examples/cicd-sha-pin-oidc.md` uses `@v4` as the **bad** input — keep that; do not “fix” the scenario to a SHA.

## 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Scanner CLIs ABSENT on host | Inventory each tool | **Default:** official docs URL (do not brew/pip scanners onto TAD unless human asks) | Docs pin EQUIVALENT_SUBSTITUTE | Banner still required; AC1 FAIL if missing/stale |
| `git ls-remote` network | find-action-sha.sh | sandbox network | None for SHA re-pin | AC3 FAIL |
| Dual-tree drift | copy after edit | `diff -q` | None | AC2 FAIL |
| No Gemini | Do not call gemini | WebSearch / CLI | Codex optional, not required | — |
| Reviewers after impl | Group 0 spec + code-reviewer | usual Layer 2 | security-auditor on pack CLI changes | Gate 3 |

**Status Enum:** READY / BLOCKED / DEGRADED_WITH_APPROVAL / EQUIVALENT_SUBSTITUTE / NOT_APPLICABLE_WITH_REASON

ABSENT CLI + docs URL = EQUIVALENT_SUBSTITUTE (record URL). Inventing a version without CLI or URL = forbidden.

## 8.5 Feedback Collection

```yaml
feedback_required: false
artifact_type: generic
notes: pack markdown refresh; no Feedback Collector
```

## 8.6 Test Evidence Required

- [ ] verify.py transcripts AC1–AC9
- [ ] cli-inventory.md
- [ ] impl SHA + diff-tree names
- [ ] find-action-sha.sh stdout for each re-pinned action

Coverage % N/A.

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/2026-09-11-gate2-keep11-knife1-code.md
  - .tad/evidence/reviews/2026-09-11-gate2-keep11-knife1-security.md
gate_verdicts:
  - this handoff §Gate 2
completion: .tad/active/handoffs/COMPLETION-20260911-keep11-knife1-cli-refresh.md
blake_reviews: .tad/evidence/reviews/blake/keep11-knife1/
perf_evidence: []
fixture_results:
  - .tad/evidence/acceptance-tests/keep11-knife1/verify.py
  - .tad/evidence/acceptance-tests/keep11-knife1/cli-inventory.md
dogfood: []
knowledge_updates: []
```

---

## 9. Acceptance Criteria

Blake done iff FR1–FR8 hold and §9.1 every row PASS.

### 9.1 Spec Compliance Checklist

Alex-owned runner (not Blake pathspec): `.tad/evidence/acceptance-tests/keep11-knife1/verify.py`

Each Method is a single backtick command. For AC6–AC7 set `IMPL_SHA` to the impl commit.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC1 | BANNER_REL banners dated on/after 2026-09-11 | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC1` | `OK`, exit 0 | missing 13 + gitleaks date stale, `FAIL` (expected) |
| AC2 | `.claude` / `.agents` twins byte-identical (incl. monitoring-rules.md) | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC2` | `drift []` `OK` | (re-run after P1 list add) |
| AC3 | Rotten `b4ffde65…` gone AND live v4.1.7 SHA present in pin files | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC3` | `old_sha []` live SHA present `OK` | rotten SHA still present, `FAIL` (expected) |
| AC4 | CI6 index row has no `@v4` in .claude/.agents/capability-packs | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC4` | `CI6_ok` `OK` | teaches `@v4`, `FAIL` (expected) |
| AC5 | `2026-05-20` absent from triage rules in all three trees | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC5` | `OK` | still present, `FAIL` (expected) |
| AC6 | Impl commit names only allow-prefix paths | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC6` | `extra []` `OK` | (post-impl) |
| AC7 | Forbidden snips absent from impl commit | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC7` | `forbidden []` `OK` | (post-impl) |
| AC8 | cli-inventory.md names gitleaks + checkout and ABSENT + PATH/http | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC8` | `OK` | file missing `FAIL` (expected) |
| AC9 | capability-packs `references/*` that exist match `.claude` twins | post-impl-verifiable | `python3 .tad/evidence/acceptance-tests/keep11-knife1/verify.py AC9` | `cappack_drift []` `OK` | 2026-09-11 pre-impl `FAIL` (8 files already drifted — Blake must lockstep, FR7) |

### 9.2 AC Dry-Run (Alex 2026-09-11)

See design § step1d. Live `find-action-sha.sh actions/checkout v4.1.7` → `692973e3d937129bcbf40652eb9f2f61becf3332`. Scanner CLIs ABSENT.

---

## 10. Important Notes

### 10.1 Anti-patterns

- Do not “fix” CI2 examples that show `@v4` as the **wrong** form.
- Do not SHA-pin a dead v3 artifact action.
- Do not freeze or unfreeze anyone.
- Do not stage dirty NEXT / PROJECT_CONTEXT / handoff in the impl commit.

### 10.2 Warnings

`gh` on some hosts is distro-old (this design host: 2.46.0). Docs-pin `gh attestation verify` if `--help` lacks the subcommand.

### 10.3 Sub-agents

After impl: spec-compliance-reviewer (Group 0) + code-reviewer. Security-auditor recommended (CLI/supply-chain docs). UX N/A. Perf N/A.

### 10.4 Pack Anti-Patterns

Do not dump frozen packs. Do not load web-ui-design 1202-line SKILL this knife.

---

## 11. Decision Summary

| Decision | Choice | Research source |
|----------|--------|-----------------|
| Knife 1 packs | code-security + web-deployment | Human Q3=2 |
| Depth | CLI + retrieval/banner | Human Q1=2 |
| Slice | No Epic | Human Q2=1 |
| Done bar | dry-run + Verified-against | Human Q4=1 |
| Gemini | No | Human lock |
| checkout example | re-resolve v4.1.7 (Alex: 692973e3…) | find-action-sha.sh this session |

---

## 12. Audit Trail

- Discuss 5Qs locked 2,1,2,1,1 this dispatch.
- Gate 2 expert reviews: both CONDITIONAL PASS, P0=0. Carriers under `.tad/evidence/reviews/2026-09-11-gate2-keep11-knife1-{code,security}.md`. P1 integrated into verify.py AC1–AC9 and §3 denylist.
- Conflict matrix: essay byte-preservation vs CLI refresh — resolved by allowed hunk classes (§4.2); all three (banners, SHA truth, no-essay-rewrite) simultaneously satisfiable.

---

## Conflict Matrix (step0_5)

Banner/SHA/date updates vs “do not rewrite essays”: allowed hunk list is the resolution. No PARTIAL-GO. Discriminative eval not in the triple (explicitly out).
