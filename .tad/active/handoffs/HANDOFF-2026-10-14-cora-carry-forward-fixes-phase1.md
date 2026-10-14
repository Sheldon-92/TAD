---
dispatch_id: p1-y3-1
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (design subagent, dispatch p1-y3-1) **To:** Blake (subagent dispatched by Cora)
**Date:** 2026-10-14
**Project:** TAD
**Task ID:** TASK-20261014-cora-carry-forward-phase1
**Handoff Version:** 3.3.0
**Epic:** EPIC-20261014-cora-carry-forward-fixes.md (Phase 1/2)
**Supersedes:** N/A
**Base commit:** `1320ba8ffc52179a0d70eeae339def74f46c4333` (branch `feat/cora-role`; from `phase1-grounding.md`)
**Depth:** slim (Epic decision D3). Hard caps: no new step, mechanism, state table or script in the skill; `cora/SKILL.md` ≤ 200 lines; nothing outside §7.

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-10-14 12:30
Not claimed here. This design step stops before expert review (conductor dispatch mode). Per D3 Cora dispatches one P0-only design check, written to `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-p0-check.md`. Design-side self-checks are in §7.3 and the AC Dry-Run Log (§9.1).

---

## 📋 Handoff Checklist (Blake必读)
- [ ] Read §1–§10; read `.tad/project-knowledge/patterns/shell-portability.md` before touching the evidence scripts (bash, `command grep`).
- [ ] The edits are given as exact old → new text in §4.2. Apply them as written; a wording change that is not in §4.2 is a design decision: write it to `phase1-questions.md` instead.
- [ ] If anything is unclear: `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-questions.md` (line 1 `dispatch_id: <your id>`), then stop.

---

## 1. Task Overview

### 1.1 What We're Building
Five small wording fixes in three protocol files of the Cora conductor, so that ids, stops and distillation inputs are defined where the Phase 2 Gate 4 report found them undefined:
- **P2-A**: the id of a retry inside a review round (the human said "no, the earlier session is dead").
- **P2-B**: Y4 design review gets the Y6 round-id scheme and the stale-file rule.
- **C2**: Blake's journal is asked for in Y5, and the Epic-close distillation receives Blake's journals, Cora's journal and the gate reports' `## Knowledge candidates`; the distillation protocol no longer skips a conductor Epic whose only material is gate-report candidates.
- **C6**: a stop says what Cora checked on disk before the question.
- **C7**: the `dispatch_id` freshness check applies only to an output named on a current `Dispatched:` line.

Then: regenerate the Claude provenance ledger (own commit), and rerun the parent Epic's six smoke scenarios on Claude Code and Codex with two rubric rows extended.

### 1.2 Why We're Building It
**业务价值**: without P2-A a retry could count as a review round and trip the circuit breaker one round early; without P2-B a re-dispatched Y4 reviewer can be "answered" by the round-1 FAIL still at the same path; without C2 knowledge from conductor runs is never distilled; C6/C7 make stops readable and stop false stops.
**成功的样子**: `phase1-ac.sh ALL` exits 0 and the independent smoke judge writes `claude: 6/6 pass`, `codex: 6/6 pass`.

### 1.3 🆕 Intent Statement（意图声明）
**真正要解决的问题**: the five gaps named in `.tad/evidence/yolo/cora-conductor-role/phase2-gate-report.md` §5, closed with the smallest text change each.

**不是要做的**:
- ❌ Not a rewrite of the pointer design or of any step; no new step, script in the skill, or mechanism.
- ❌ Not P2-C, P2-D, C5, C12, the README or other Phase 4 wording; no change to `status-roadmap-protocol.md`; not the queue (Phase 2).
- ❌ Not a change to how ordinary (non-round) ids are retried: those still take the next `<n>`.

### 1.4 卸载记录（Offload Log）
无。

---

## 📚 Project Knowledge（Blake 必读）
- `principles.md` "Three Roles, Independent Judgment": you implement and run Layer 1; you do not grade the smoke run and you do not fill any verdict.
- `patterns/shell-portability.md`: scripts run under `bash`; zsh does not word-split unquoted variables; this host aliases `grep`, so scripts use `command grep`.
- `patterns/gate-design.md` / `handoff-design.md`: verdicts are files with the verdict header, bound to a commit.
- AR-002 (grounding file): before an edit over 20 lines to a SKILL.md, list the contract changes. The SKILL.md edit here is 3 lines; the contract changes are listed anyway in §4.1.

### Blake 确认
Record in the completion report that you read the three items above.

## 🔧 Capability Pack References (Blake 必读)
Matched by keyword: `agent-orchestration` (checkpoint/resume, human-in-the-loop). Pack pointer: agent-orchestration — orchestration and HITL interrupt/resume judgment. Path: `.agents/skills/agent-orchestration/SKILL.md`. Do not load unless escalated. Not loaded: per `AGENTS.md` a keyword match alone never loads a pack, and no human named it; so no pack criteria are merged into §9 (recorded conflict: the dispatch prompt asked for injection, `AGENTS.md` ranks above it).

---

## 2. Background Context

### 2.1 Previous Work
Parent Epic `EPIC-20261013-cora-conductor-role.md`, Phases 1–2 (commits up to `1320ba8f`). Phase 2 Gate 4 (`phase2-gate-report.md` §5) sent P2-A, P2-B, C2, C6, C7 to Phase 3, which this Epic runs.

### 2.2 Current State (read at `1320ba8f`)
- `cora/SKILL.md` 132 lines. Resume section 91–101: line 99 holds the dispatch_id rule and the re-dispatch question; nothing says which outputs the freshness check covers, nor what id a retry inside a round takes. "When Cora stops" 65–73: line 70 only says the stop is recorded before she asks.
- `conductor-protocol.md` 306 lines. `dispatch_id_rule` 35–37. `step_Y4` 130–153: step 1 "one id per reviewer" (no form), 5a no design-fix id, 5b re-dispatches only the code reviewer with no round id. `step_Y5` 154–185: no journal. `step_Y6` 186–209: round ids `p{N}-y6-r<k>-cr/-dom` (line 190, 203), no retry form. `epic_completion` 3b (256) names the inputs but no paths.
- `distillation-loop-protocol.md` 106 lines. Precondition 3–6 skips when there is no journal; the conductor section 101–106 names only Cora's journal.

### 2.3 Dependencies
`.tad/scripts/gen-claude-provenance.sh` (ledger regen); `claude` and `codex` CLIs for the smoke run; the parent's `phase1-slim-behaviour.sh` and `phase1-slim-ac.sh` (read-only).

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1 (P2-A): a retry of a review-round reviewer keeps `k` and appends `-t<m>`; Y6 states "A retry does not start a new round"; the Resume section of the skill uses the same form.
- FR2 (P2-B): Y4 has reviewer ids `p{N}-y4-r<k>-cr` / `p{N}-y4-r<k>-dom`, design-fix id `p{N}-y4-<n>`, the "output not on disk" rule for another round's file, and 5b writes the pointer before re-dispatching both reviewers.
- FR3 (C2): Y5 asks for the journal and a `Journal:` line in the completion report; epic_completion 3b names the input paths; the distillation protocol has a conductor exception and names Blake's journals and the gate reports.
- FR4 (C6): a stop first says what she checked on disk.
- FR5 (C7): the freshness-scope sentence in the Resume section and in `dispatch_id_rule`.
- FR6: provenance ledger regenerated in its own commit; FR7: smoke rerun on both harnesses.

### 3.2 Non-Functional Requirements
- Every `[A###]` tag in the two Cora files stays. No concrete model name in added lines. `cora/SKILL.md` ≤ 200 lines (133 after the edits).

### 3.3 Optimization Target
N/A.

---

## 4. Technical Design

### 4.1 Architecture Overview — contract changes (AR-002 list)
1. Ids: review-round retries get `-t<m>` (Y4 and Y6); Y4 gets round ids and a design-fix id. Ordinary ids unchanged (next `<n>`).
2. Y4 5b now re-dispatches **both** reviewers on v2 (was: the code reviewer only), as Y6 4b does. Reason: with round ids in the pointer, a reviewer not re-dispatched would leave its round-1 file as "output not on disk" for round k, and a round-1 FAIL left in the routing set would loop. This is the "Y6 scheme" the Epic names.
3. Freshness scope: the dispatch_id check covers only outputs named on a current `Dispatched:` line. The existence checks of the Resume section ([A020], "disk is ahead") are unchanged.
4. Y5 Blake prompt gains one line (journal); the completion report gains a `Journal:` line.
5. Distillation: a conductor Epic close with gate-report candidates is distilled even without a journal.
6. Stops: the stop text lists the on-disk checks first.

### 4.2 Component Specifications — exact edits (old → new; each `old` occurs exactly once)

**`.agents/skills/cora/SKILL.md`**

E1 (Resume, line 99; one line becomes two):
- old: `- Every output file carries \`dispatch_id: <id>\` in its first lines; it counts as the result of the recorded dispatch only if that equals the pointer's, and a re-dispatch takes the next \`<n>\`. A dispatch is recorded but its output is not on disk (or carries another id): ask the human one question, is the earlier session still running? Re-dispatch only on "no".`
- new line 1: `- Every output file carries \`dispatch_id: <id>\` in its first lines; it counts as the result of the recorded dispatch only if that equals the pointer's. The freshness check applies only to an output named on a current \`Dispatched:\` line; a result the pointer already records as read (its step is behind \`Pointer:\`/\`Next:\` and no \`Dispatched:\` line names it) is not re-checked and is not a stop.`
- new line 2: `- A dispatch is recorded but its output is not on disk (or carries another id): ask the human one question, is the earlier session still running? Re-dispatch only on "no", with the next \`<n>\`; a review-round id (\`-r<k>-\`) keeps its \`k\` and appends \`-t<m>\` (m = 2, 3, …), because a retry does not start a new round.`

E2 ("When Cora stops", line 70):
- old: `- A stop is recorded in the pointer (\`Stopped:\`) before she asks.`
- new: `- A stop is recorded in the pointer (\`Stopped:\`) before she asks. The stop first says what she checked on disk (each file or directory she read and what it showed), then asks the question.`

**`.agents/skills/cora/references/conductor-protocol.md`** (keep the YAML indentation of the surrounding lines)

E3 (`dispatch_id_rule`, line 37; 4-space indent; one line becomes two):
- old: `An output counts as the result of the recorded dispatch only if its dispatch_id equals the pointer's; otherwise it is "output not on disk". A re-dispatch takes the next <n>.`
- new line 1: `An output counts as the result of the recorded dispatch only if its dispatch_id equals the pointer's; otherwise it is "output not on disk". A re-dispatch takes the next <n>; a retry of a review-round id keeps the round (step_Y6 4b).`
- new line 2: `The freshness check applies only to an output named on a current \`Dispatched:\` line; a result the pointer already records as read (its step is behind \`Pointer:\`/\`Next:\` and no \`Dispatched:\` line names it) is not re-checked and is not a stop.`

E4 (`step_Y4` step 1, 8-space indent):
- old: `1. Write the pointer (one id per reviewer). Cora does not read the handoff; the reviewers do.`
- new: `1. Write the pointer with one id per reviewer, \`p{N}-y4-r<k>-cr\` and \`p{N}-y4-r<k>-dom\` (k = round number; round 1 here: \`p{N}-y4-r1-cr\`, \`p{N}-y4-r1-dom\`), and the two review paths. Cora does not read the handoff; the reviewers do.`

E5 (`step_Y4` 5a, prefix only; the rest of the line stays):
- old: `a. Dispatch an Alex subagent with the two review file paths. Prompt opens:`
- new: `a. Write the pointer first (design-fix id \`p{N}-y4-<n>\`, output {handoff_path}), then dispatch an Alex subagent with the two review file paths. Prompt opens:`

E6 (`step_Y4` 5b):
- old: `b. Re-dispatch the code reviewer on v2 to verify the fix.`
- new: `b. Write the pointer first with the next round's reviewer ids (\`p{N}-y4-r<k>-cr\`, \`p{N}-y4-r<k>-dom\`; never equal to the design-fix id or an earlier round's) and the same two review paths, then re-dispatch both reviewers on v2 with those ids as {id}. On resume only the current round's ids count: a review file whose \`dispatch_id\` is another round's is "output not on disk", so a round-1 FAIL at the same path is never read as the new result. A retry inside a round follows step_Y6 4b (same k, suffix \`-t<m>\`).`

E7 (`step_Y6` 4b, append to the end of line 203, after `otherwise ask whether the earlier session still runs).`):
- append: ` If the human answers "no" for a reviewer of round k, its retry keeps k and takes \`p{N}-y6-r<k>-cr-t<m>\` (or \`p{N}-y6-r<k>-dom-t<m>\`), m = 2, 3, …, written into the pointer before the retry is dispatched. A retry does not start a new round: the circuit breaker in 4c counts rounds, not retries.`

E8 (`step_Y5` prompt, new line after `Leave \`gate3_verdict:\` empty; you do not judge your own work.`; 11-space indent):
- new: `Journal: if you have human corrections, failed steps or surprises to note, write them to .tad/evidence/journal/{epic-slug}-phase{N}-{date}.md and put the line \`Journal: <that path>\` in the report; otherwise write no journal and put \`Journal: No discoveries\`.`

E9 (`epic_completion` 3b):
- old: `on Blake's journals, Cora's journal and every gate report's \`## Knowledge candidates\`;`
- new: `on the paths its prompt names: Blake's journals (\`.tad/evidence/journal/{epic-slug}-phase*-*.md\`, from each completion report's \`Journal:\` line), Cora's journal (\`.tad/evidence/journal/conductor-{epic-slug}-{date}.md\`) and the \`## Knowledge candidates\` of every \`.tad/evidence/yolo/{epic-slug}/phase*-gate-report.md\`;`

**`.agents/skills/alex/references/distillation-loop-protocol.md`**

E10 (Precondition, new bullet after line 6 `- If journal exists but content is too short (<3 lines) → skip distillation, leave journal`):
- new: `- Conductor exception: at a conductor Epic close (Cora's epic_completion step 3b) the skips above do not apply while any \`phase*-gate-report.md\` of the Epic has entries under \`## Knowledge candidates\`; the distiller works from those candidates even with no journal.`

E11 (conductor section, line 102):
- old: `- The doer is the conductor, not Blake. The journal is \`.tad/evidence/journal/conductor-{epic-slug}-{date}.md\`: human corrections, failed steps, surprises.`
- new: `- The doer is the conductor, not Blake. Inputs, as the dispatch names them: Blake's journals (\`.tad/evidence/journal/{epic-slug}-phase{N}-{date}.md\`), the conductor's journal \`.tad/evidence/journal/conductor-{epic-slug}-{date}.md\` (human corrections, failed steps, surprises), and the \`## Knowledge candidates\` of each \`phase*-gate-report.md\`.`

E12 (conductor section, line 104, sentence only):
- old: `It reads the journal, then runs Steps 2 to 4 above unchanged.`
- new: `It reads these inputs, then runs Steps 2 to 4 above unchanged; gate-report candidates go through the same variabilize test.`

(The backslashes before backticks above are only markdown escaping in this handoff: the file text has plain backticks.)

### 4.3 Data Models / 4.4 API / 4.5 UI
N/A (protocol text).

---

## 5. 🆕 强制问题回答（Evidence Required）
- **MQ1 历史代码搜索**: `grep -rnF 'y6-r'` outside evidence/archive/handoffs/epics finds only `conductor-protocol.md:190,203`; no other file defines review-round ids, so no second place to keep in step. `distillation-loop-protocol` is referenced by `alex/SKILL.md`, `conductor-dispatch-mode.md`, `skill-body-verify.sh` (anchor file check only, unaffected) and the provenance ledger.
- **MQ2 函数存在性**: N/A (no functions). The anchors E1–E12 were each matched exactly once by a scripted replacement on a scratch copy (§9.1 log).
- **MQ3 数据流**: id flow is pointer → prompt → output file line 1 → Cora's comparison; the edits change only the id forms and which outputs are compared.
- **MQ4 视觉层级 / MQ5 状态同步**: N/A; state stays in the Epic's `## Run` block.

---

## 6. Implementation Steps（分Phase）

### Phase 1: edits, ledger, smoke (one session)

#### 实施步骤
1. `git status --short -- .agents .tad/provenance` must be empty (it was at design time). Record HEAD; it must be `1320ba8f` or a descendant with no change to §7 files.
2. Apply E1–E12 exactly. Run `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-1 AC-2 AC-3 AC-4 AC-5` → all PASS.
3. Commit 1 (explicit pathspecs, never `-A`, no push): the three skill files. Message: `fix(cora): carry-forward phase 1 - retry ids, Y4 round ids, distillation inputs, stop text, freshness scope [YOLO Phase 1]`.
4. Run `bash .tad/scripts/gen-claude-provenance.sh`; commit 2: `.tad/provenance/claude-legacy.tsv` and `.tad/provenance/MANIFEST.sha1` only, message `chore(cora): carry-forward phase 1 - regenerate claude provenance ledger`.
5. Run `phase1-ac.sh AC-6 AC-7` → PASS.
6. Smoke script: copy `.tad/evidence/yolo/cora-conductor-role/phase1-slim-behaviour.sh` to `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke.sh` and change only:
   - header comments: script name; judge file `phase1-smoke-judge.md`; transcripts under `phase1-smoke/`.
   - rubric: replace `smoke/` by `phase1-smoke/`; `Write phase1-slim-judge.md` → `Write phase1-smoke-judge.md`; add `dispatch_id: <the id in your prompt>` as the first line inside the header block; `fails AC-10` → `fails AC-8`.
   - rubric row d, append: `C7: the two review files carry no dispatch_id and the pointer records step Y4 as read (Dispatched: —); she raises no stop and asks nothing about them.`
   - rubric row f, append: `C6: the stop names as checked the Epic's Phase Map (two phases, phase 2 Planned), the handoff directory (no handoff) and the evidence directory (no evidence), each with what it showed.`
   - fixtures, NOTE, prompts: unchanged. `bash -n` it.
7. Run, in bash, after commit 1 (fixtures go outside the repo):
   `W=$(mktemp -d); bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke.sh all claude "$W/claude" .tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke` and the same with `codex` and `"$W/codex"`. Run in the background if long. You do not grade the transcripts.
   If Codex cannot run (usage limit, login, sandbox): write `phase1-smoke/codex-not-run.md` (line 1 the reason, then the error text). That is reported as not run, never as passed.
8. Journal (per the new E8 rule): `.tad/evidence/journal/cora-carry-forward-fixes-phase1-2026-10-14.md` if you have anything to note; `Journal:` line in the report either way.
9. Completion report at the path Cora names (expected `.tad/active/handoffs/COMPLETION-2026-10-14-cora-carry-forward-fixes-phase1.md`), `dispatch_id` in its first lines, `gate3_verdict:` empty. Contents: both commit shas; output of `phase1-ac.sh AC-1 AC-2 AC-3 AC-4 AC-5 AC-6 AC-7`; `wc -l` of the three files; the transcript list with each `### harness exit:` line; the `Journal:` line; anything not done.

#### 验证方法 / 完成证据
AC-1..AC-7 of `phase1-ac.sh` PASS at the final commit; 12 transcripts (or 6 + `codex-not-run.md`). AC-8 and AC-9 need files that Cora's independent dispatches write; they FAIL until then, which is expected.

If Y6 rework changes a skill file later: re-run step 4 (ledger) and step 7 (smoke), because AC-8 binds the judge to the final skill commit and AC-8 requires transcripts newer than it.

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke.sh        # gitignored; copy of the parent's smoke script, two rubric rows extended
.tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke/          # gitignored; 12 transcripts
.tad/evidence/journal/cora-carry-forward-fixes-phase1-2026-10-14.md  # gitignored; only if there is something to note
(phase1-ac.sh already exists: written by this design step; do not change it — if it is wrong, say so in the completion report)
```

### 7.2 Files to Modify
```
.agents/skills/cora/SKILL.md                                    # E1, E2 (P2-A, C7, C6)
.agents/skills/cora/references/conductor-protocol.md            # E3-E9 (C7, P2-B, P2-A, C2)
.agents/skills/alex/references/distillation-loop-protocol.md    # E10-E12 (C2)
.tad/provenance/claude-legacy.tsv, .tad/provenance/MANIFEST.sha1 # REGEN, own commit
```

### 7.3 Grounded Against (Alex step1c, 2026-10-14 12:25–12:30, HEAD 1320ba8f, tree clean for these paths)
- `.agents/skills/cora/SKILL.md` (whole file, 132 lines; Resume 91–101, stops 65–73 confirmed)
- `.agents/skills/cora/references/conductor-protocol.md` (head 60 + 125–270; line anchors 35/37, 130, 154, 186, 190, 203, 210, 249, 256 confirmed by grep)
- `.agents/skills/alex/references/distillation-loop-protocol.md` (1–20, 95–106; Precondition 3–6 and conductor section 101–106 confirmed)
- `.tad/scripts/gen-claude-provenance.sh` (head 25; writes `claude-legacy.tsv` + `MANIFEST.sha1`, deterministic)
- `.tad/provenance/claude-legacy.tsv`, `MANIFEST.sha1` (exist; last regen `56b04d45`)
- `.tad/evidence/yolo/cora-conductor-role/phase1-slim-behaviour.sh` (whole file, 172 lines; fixture d already has review files with no dispatch_id and `Dispatched: —`, as the C7 row needs)
- `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke.sh`, `phase1-smoke/` (new — will be created)
- LSP impact: not applicable (Markdown/YAML-in-Markdown; no language server). Blast radius by grep instead (MQ1): no other definer of the ids; `skill-body-verify.sh` checks only that `research-track-protocol.md` exists in alex references. 0 scope gaps added.

---

## 8. Testing Requirements

### 8.1 Unit Tests / 8.2 Integration Tests
`phase1-ac.sh` AC-1..AC-7 (§9.1); the regression set inside AC-6 (parent ACs, `skill-body-verify.sh`, `state-surface-check.sh`, `release-verify.sh path-refs .` and `provenance .`).

### 8.3 Edge Cases (the rules must read right for these; the smoke run covers d and f)
- Review files with no `dispatch_id` behind the pointer (fixture d): no stop (C7).
- Pointer ahead of the disk (fixture f): the stop lists Phase Map, handoff directory, evidence directory with what each showed (C6).
- Reviewer retry in round 2: id `p1-y6-r2-cr-t2`; round count stays 2 (P2-A).

### 8.4 Friction Preflight
`claude` and `codex` CLIs on PATH; Codex may hit a usage limit (then `codex-not-run.md`, which makes the judge PARTIAL, a stop for Cora). `release-verify.sh` needs the repo root argument (`.`); without it, it prints usage and exits 2.

### 8.5 Feedback Collection
N/A.

### 8.6 🆕 Test Evidence Required — Required Evidence Manifest
```yaml
required_evidence:
  completion: .tad/active/handoffs/COMPLETION-2026-10-14-cora-carry-forward-fixes-phase1.md   # Blake (path as Cora names it)
  fixture_results: .tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke/               # Blake: 12 transcripts or 6 + codex-not-run.md
  blake_reviews: []                                                                          # none: Blake does not review
  expert_reviews:                                                                            # Cora dispatches; not Blake
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase1-p0-check.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase1-impl-review-cr.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase1-impl-review-{domain}.md
  gate_verdicts:                                                                             # Cora dispatches; not Blake
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase1-smoke-judge.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase1-gate3-verdict.md
    - .tad/evidence/yolo/cora-carry-forward-fixes/phase1-gate-report.md
  dogfood: .tad/evidence/journal/cora-carry-forward-fixes-phase1-2026-10-14.md               # optional (Journal: line either way)
  perf_evidence: []
  knowledge_updates: []                                                                      # none in this phase
```

---

## 9. Acceptance Criteria
Blake's work is complete when AC-1..AC-7 pass at the final commit and the smoke transcripts are on disk. AC-8 and AC-9 close the phase once Cora's independent dispatches have written their files. Not done: any FAIL, a PASS claimed for a NOT RUN cell, or a verdict written by Blake.

## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE — Gate 3 executes each row

Script: `.tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh` (run from the repo root, under bash; rc 0 = pass). Literals checked are the ones fixed in §4.2.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|--------------------|-------------------------------|
| AC-1 | P2-A: `p{N}-y6-r<k>-cr-t<m>` and "A retry does not start a new round" in step_Y6; `-t<m>` and "a retry does not start a new round" in Resume | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-1` | `PASS AC-1`, rc 0 | today: 4 FAIL (literals absent), rc 1; on the scratch copy with E1–E12: PASS |
| AC-2 | P2-B: step_Y4 has `p{N}-y4-r<k>-cr`, `p{N}-y4-r<k>-dom`, `p{N}-y4-<n>`, "output not on disk", "Write the pointer first with the next round's reviewer ids", `-t<m>` | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-2` | `PASS AC-2`, rc 0 | today: 6 FAIL, rc 1; scratch copy: PASS |
| AC-3 | C2: Y5 names the journal path and `Journal: No discoveries`; epic_completion names `.tad/evidence/journal/`, `gate-report`, `Knowledge candidates`; distillation has `Conductor exception:`, "Blake's journals", `gate-report.md` | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-3` | `PASS AC-3`, rc 0 | today: 7 FAIL (`Knowledge candidates` already present), rc 1; scratch copy: PASS |
| AC-4 | C6: "what she checked on disk" in "When Cora stops" | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-4` | `PASS AC-4`, rc 0 | today: 1 FAIL, rc 1; scratch copy: PASS |
| AC-5 | C7: "freshness check applies only to an output named on a current" in Resume and in dispatch_id_rule | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-5` | `PASS AC-5`, rc 0 | today: 2 FAIL, rc 1; scratch copy: PASS |
| AC-6 | No regression: SKILL.md ≤ 200 lines; `[A###]` tag sets equal to BASE; parent `phase1-slim-ac.sh` AC-1..5,7..9; skill-body-verify; state-surface-check; `release-verify.sh path-refs .` and `provenance .` | pre-impl-verifiable (re-run post-impl) | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-6` | `PASS AC-6`, rc 0 at the final commit | today: `PASS AC-6: SKILL.md 132 lines; tags kept; ...`, rc 0. Scratch copy after E1–E12: 133 lines, tag sets identical. After commit 1 provenance is red until commit 2 (expected) |
| AC-7 | Scope: changed paths ⊆ §7.2; no NEXT/PROJECT_CONTEXT/ROADMAP/status/epics/memory path in a phase commit; no model name in added lines | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-7` | `PASS AC-7`, rc 0 | today: `FAIL AC-7: no commit after BASE 1320ba8f… yet`, rc 1 (right reason) |
| AC-8 | Smoke judged by an independent subagent: header (`dispatch_id`, `verdict: PASS`, `p0_count: 0`, `judged: commit:<final skill commit>`), `claude: 6/6 pass`, `codex: 6/6 pass`; 12 transcripts, `### harness exit: 0`, newer than the judged commit | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-8` | `PASS AC-8`, rc 0 | today: `FAIL AC-8: missing …/phase1-smoke-judge.md`, rc 1 |
| AC-9 | Independent verdicts: `phase1-p0-check.md` (judged = this handoff), `phase1-impl-review-cr.md`, one other `phase1-impl-review-{domain}.md`, `phase1-gate3-verdict.md`, `phase1-gate-report.md`; headers PASS/CONDITIONAL, `p0_count: 0`, commits equal to HEAD in the skill files; gate report names P2-A, P2-B, C2, C6, C7 | post-impl-verifiable | `bash .tad/evidence/yolo/cora-carry-forward-fixes/phase1-ac.sh AC-9` | `PASS AC-9`, rc 0 | today: 5 FAIL (files missing), rc 1 |
| AC-10 | Change scope as planned | post-impl-verifiable | `git diff --stat 1320ba8f..HEAD` | only the 3 skill files and the 2 provenance files | (post-impl) |

**AC Dry-Run Log** (Alex step1d, 2026-10-14 12:28–12:35, HEAD `1320ba8f`):
- `bash -n phase1-ac.sh`: syntax OK.
- AC-1..AC-5: ✅ run on the live tree, each FAILs for the right reason (literal absent). Known-good: E1–E12 applied by an exact-match script (each `old` matched once) to a scratch copy of `.agents/` → AC-1..AC-5 all PASS; SKILL.md 133 lines; `[A###]` tag sets unchanged; no model name in the diff; parent `phase1-slim-ac.sh` AC-1..AC-5 and AC-8 PASS against the copy (its AC-7/AC-9 failed there only because the scratch copy lacks the hooks and transcripts, not because of the edits).
- AC-6: ✅ pre-impl PASS on the live tree (rc 0). Note `release-verify.sh` needs `.` as repo root; without it rc 2 (usage).
- AC-7: ✅ FAIL for the right reason (no commit yet).
- AC-8, AC-9: ✅ syntax-validated; FAIL for the right reason (files missing). Not mocked.
- AC-10: `git diff --stat` syntax trivially valid; post-impl.
- Advisory linter `bash .tad/hooks/lib/verify-ac-commands.sh <this handoff>`: "0 warnings, 0 info".

**Design-step self-checks (dispatch items a–e):** (a) frontmatter `task_type: mixed`, `e2e_required: no`, `research_required: no`, `dispatch_id: p1-y3-1` — filled. (b) packs: `agent-orchestration` matched by keyword, not loaded (AGENTS.md pack rule), no criteria merged. (c) grounding: §7.3, every §7.2 path exists at the stated lines. (d) LSP: not applicable to Markdown; grep blast radius in MQ1, 0 gaps. (e) AC dry-run: above; `phase1-ac.sh` written by this step as evidence.

---

## 9.2 Expert Review Status (Alex 必填)
Not run by the designer (conductor dispatch mode). Cora dispatches the P0-only design check (D3) and, after implementation, two reviewers of distinct types.

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| (P0 check, dispatched by Cora) | — | — | Open |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Keep every `[A###]` tag; the parent's acceptance script reads them.
- ⚠️ Commit with explicit pathspecs only; no push, no tag. Do not touch `NEXT.md`, the Epic, `session-state.md`, `.tad/memory/`, `PROJECT_CONTEXT.md`, `ROADMAP.md`, `docs/pm/status.md` (some are already dirty in the tree: leave them as they are).
- ⚠️ Do not grade the smoke transcripts and do not write any verdict file.

### 10.2 Known Constraints
- The smoke run shows what Cora says on six fixed scenarios, one run each; it does not exercise a real retry inside a round (P2-A) or the Y4 round ids (P2-B). Those are checked by text only (AC-1, AC-2). The real run of this Epic exercises Y4/Y6 in practice.
- Under D3 this Epic's own Y4 dispatches one P0-only check; the protocol text still describes two reviewers. That is a recorded Epic-level decision, not a protocol change.

### 10.3 🆕 Sub-Agent使用建议
None: you cannot call reviewers; Cora does.

---

## 11. 🆕 Learning Content（可选）

### 11.1 Decision Rationale: retry suffix instead of a new `k` or a new `<n>`
A new `k` would count as a round and trip the breaker early (the P2-A defect); a new `<n>` does not exist in a round id. Appending `-t<m>` keeps `k`, keeps the id unique (so the dead session's late file is still "output not on disk"), and is one rule for Y4 and Y6.

---

## 12. 🆕 Sub-Agent使用记录
Design step: no subagent called.
