---
# Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3)
task_type: mixed       # docs edits + gh CLI public writes
e2e_required: no      # Express: no e2e; ACs are gh/grep runnable
research_required: no # MQ6 answered from gh help + prior art on disk

# Optional: production directories that must have ≥1 git-tracked file at Gate 3
git_tracked_dirs: []

# Doc + metadata facade single: no new reusable knowledge expected by default.
skip_knowledge_assessment: yes

# gate4_delta: [] default — handoff predictions held (filled only at *accept)
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-09-04
**Project:** TAD Framework (upstream public facade)
**Task ID:** TASK-20260904-FACADE
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A
**Design:** `.tad/active/designs/DESIGN-20260904-public-facade-cleanup.md` (Express, human-picked)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-09-04

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | FR1–FR4 + Non-goals cover all 4 facade defects; nothing else in scope |
| Components Specified | ✅ | Exact strings/flags/SHAs pinned (§3–§4); draft-first sequence explicit |
| Functions Verified | ✅ | `gh 2.46.0` at `/usr/bin/gh`; externals = gh/git/node/grep only (MQ2) |
| Data Flow Mapped | ✅ | MQ3 N/A (derived strings only); MQ5 SoT = tags > Releases > text |

**Gate 2 结果**: ✅ PASS

**Review trail:** R1 release-ops CONDITIONAL (4 P0/6 P1) → R2 spec-compliance CONDITIONAL (2 P0/6 P1) → all P0 fixed → re-review `rereview-p0.md` PASS (6/6 verified). P1s: all fixed except H1 carve-out (waived with rationale in DESIGN FR1) — Express-legal.
**Human decisions honored:** D1–D6 fidelity table in spec-compliance report (D2/D3 partials closed via R1d footer + H1 carve-out).

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
Upstream public-facade cleanup (docs + metadata + Release objects only): 2 missing GitHub Releases (v2.44.0/v2.44.1, draft-first), patch-honest README headline + footer + pointer line + hybrid naming line, package.json canon verify, repo description hybrid-c. Zero protocol/logic changes.

### 1.2 Why We're Building It
**业务价值**：GitHub Latest stuck at v2.43.0 understates the tree by 2 releases; README sells the wrong version story; naming split erodes trust.
**用户受益**：Public page tells the truth at a glance.
**成功的样子**：`gh release list` Latest = v2.44.1; README headline names the patch; repo/package/README all carry the hybrid canon; v2.43.0 Release byte-identical.

### 1.3 🆕 Intent Statement（意图声明）

**真正要解决的问题**：public facade (tags✅/Releases❌, headline, naming) 与树内真相脱节。

**不是要做的（避免误解）**：
- ❌ 不是改 Gate/hook/模板/PM Bridge 行为（AC5 钉死零触碰）
- ❌ 不是动旧 Release（AC4 哈希钉死未动）
- ❌ 不是扫 config.yaml/CLAUDE.md/AGENTS.md（另起单）
- ❌ 不是 live-publish-first（draft → 人确认渲染 → publish，顺序写死）

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

**Mandatory reads before implementing:**
1. `.tad/project-knowledge/principles.md` — esp. *Express Handoff is NOT Review-Exemption*, *Never Hand-Write What an Existing Tool Already Does*, *Deny-List* entries (not directly exercised, but the discipline applies to the `--latest`/scope guards).
2. `.tad/project-knowledge/patterns/release-sync.md` — esp. *Version-Staleness Grep Gate Without Exclusion Contract* (2026-09-04, written from the v2.44.0 publish): classify identity vs historical before touching any version string; never "fix" history.
3. `.tad/project-knowledge/patterns/handoff-design.md` — *Concurrent Terminals Share the Git Index* (pathspec-scope commits; this repo has sibling tracks active) and *git grep Is Blind to Untracked Files*.

**⚠️ Blake 必须注意的历史教训**
- H1: v2.44.0 publish shipped via scoped exception because the version-grep gate fired on historical references — your AC5/AC6 greps are scoped for exactly this reason. Do NOT bump fixture pins, CHANGELOG history, or dated records to "make a grep green."
- H2: Shared git index — commit ONLY with explicit pathspec (`git commit -- README.md package.json`); never bare `git commit`.
- H3: `gh release create` is a public write — draft-first is not ceremony, it is the human-render check for AC2 anchors.

---

## 2. 强制问题回答 MQ (with evidence)

| MQ | Answer + evidence |
|----|-------------------|
| MQ1 | 复用 prior art，不新造：`.tad/archive/handoffs/COMPLETION-20260904-publish-v2440-bundle-FINAL.md` (bundle precedent) + `release-runbook/references/publish-ops.md` (detect/write separation). Evidence: both files exist on disk. |
| MQ2 | Externals: `gh release view/create/edit`, `gh repo view/edit`, `git ls-remote --tags`, `node -e`, `grep`. `gh 2.46.0` at `/usr/bin/gh` verified; `gh auth status` must be re-verified pre-write (§8.4). No repo-internal functions. |
| MQ3 | N/A — derived strings only (Release bodies cite CHANGELOG subsections). |
| MQ4 | Old vs new: `Version 2.44.1 - Verified Orchestration…` (:3, :504) → `Version 2.44.1 — Optional PM Bridge (patch on the v2.44.0 bundle)` + pointer line; bundle narrative retained in body. Carriers: README:3, pointer line, README:504. |
| MQ5 | SoT: tags (immutable, on origin) > Release objects (derived, to create) > README/package text (derived, to edit). Peeled SHAs: v2.44.0=`40cf3234ade45a5ef1fdf0afc729b2537347a1ca`, v2.44.1=`83e835d8dfcdd78465d2757253d38001e308b5a5`. `.tad/version.txt`=`2.44.1`. |
| MQ6 | `gh help release create` (`--target` full SHA, `--verify-tag`, `--draft`, `--latest`) + `gh help repo edit`. No newer alternative for Release objects. |

---

## 3. Phases (Express: 2 phases, sequential — Phase 2 publishes NOTHING live before human draft approval)

### Phase 1 — Local edits (reversible): README.md R1a/R1b/R1c/R1d + package.json verify
Exact strings in DESIGN §3 FR1–FR2. Commit pathspec-scoped. Verify AC2/AC3-drift/AC6/AC7 local greps before proceeding.

### Phase 2 — Public writes (draft-first, human-gated): repo desc + 2 draft Releases → human render check → publish
1. Pre-write: `gh auth status`; `gh release view v2.44.0/v2.44.1` → both "not found"; re-capture v2.43.0 body sha256 (pre-hash).
2. `gh repo edit --description "TAD Method — Triangle Agent Development (Two-Agent Quality Framework): Design (Alex) + Execute (Blake) + 4-Gate quality system + 25 capability packs."`
3. Draft v2.44.0 (full SHA + `--verify-tag --draft`, NO `--latest`, retitled per S-P0-1), then draft v2.44.1 (full SHA + `--verify-tag --draft --latest`). Bodies: bullets cite CHANGELOG subsections.
4. STOP — human confirms draft renders + both anchors resolve (AC2). Only then: `gh release edit v2.44.0 --draft=false`, `gh release edit v2.44.1 --draft=false`.
5. Post: AC1/AC4 (Latest + v2.43.0 post-hash == pre-hash).

---

## 4. ACs (Verification Methods — Blake must run each exactly as written)

- **AC1:** `gh release view v2.44.0 --json tagName,targetCommitish -q .targetCommitish` starts with `40cf3234`; v2.44.1 starts with `83e835d8`. (FAIL today: not found.)
- **AC2:** `grep -F '**Version 2.44.1 — Optional PM Bridge (patch on the v2.44.0 bundle)**' README.md`; `grep -c '^## \[2\.44' CHANGELOG.md` == 2; human draft-page click-through of both anchors (fallback: bare section link if 404 at draft review).
- **AC3:** `node -e "console.log(require('./package.json').description)"` == `Triangle Agent Development - Two-Agent Quality Framework for AI-assisted development` (drift-guard); `gh repo view --json description -q .description` contains `Triangle` AND `Two-Agent` (change-proof).
- **AC4:** `gh release list --limit 3` Latest = v2.44.1; v2.43.0 body post-hash == pre-hash recorded in completion evidence.
- **AC5:** `git status --porcelain -- README.md package.json` shows at most those two; `git diff --name-only | grep -cE 'tad/templates/completion-report|(^|/)gate[^/]*|(^|/)hook'` == 0.
- **AC6:** `grep -rn '2\.44\.1 - Verified Orchestration' README.md` == 0; `grep -c 'Optional PM Bridge' README.md` ≥ 2.
- **AC7:** `grep -c 'Two-Agent Quality Framework' README.md` ≥ 1.

---

## 5. Execution Mandate (draft — human acceptance required before Blake writes)

- **Scope:** `README.md`, `package.json` (verify-or-edit), `gh repo edit --description` (1 reversible call), 2× `gh release create --draft` + 2× `gh release edit --draft=false` (post-approval only). NOTHING else.
- **Consequence binding:** public-facing writes to `Sheldon-92/TAD` (repo description + 2 Release objects). Drafts are invisible until published; publishing is the irreversible-ish step → gated on human draft-render approval inside Phase 2.
- **Recovery:** file edits → `git checkout -- README.md package.json`; repo-desc → re-edit prior string (record prior desc in completion); draft Releases → `gh release delete <tag>` (pre-publish only); published Releases → delete + recreate (noisy — hence draft-first).
- **Preconditions:** HEAD/`origin` tags unchanged (peeled SHAs re-verified); `gh auth status` logged in; human accepted this mandate.
- **Friction:** if `gh` unauthed/network-blocked → BLOCKED, stop (no "files-only half-delivery").

---

## 6. Evidence required (completion report carriers)

- `.tad/active/COMPLETION-20260904-public-facade-cleanup.md` (AC1–AC7 row-by-row results, pre/post v2.43.0 hashes, prior repo-desc string, draft-approval record with approver + timestamp).
- Draft URLs + publish timestamps. `git log --oneline -3` + `git status --porcelain -- README.md package.json` outputs pasted.
- No build/test/lint tree exists for this docs task — the AC commands above ARE the self-check (Blake runs build/test/lint equivalents = all AC verifies, recorded).

---

## 7. Knowledge Assessment (pre-declared)
`skip_knowledge_assessment: yes` — docs/metadata facade single; Blake flips to `no` with a `## Knowledge Assessment` section in the completion report ONLY if implementation surfaces a reusable finding (e.g. a new gh/anchor gotcha).
