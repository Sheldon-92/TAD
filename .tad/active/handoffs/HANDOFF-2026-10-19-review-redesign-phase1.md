---
dispatch_id: p1-y3-1
task_type: mixed       # protocol text (md), config (yaml), one shell marker edit
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
real_paths:
  # Protocol text: each path is walked through the NEW text (completion report quotes the deciding lines). No model runs.
  - id: RP1
    scenario: 'Human to Cora: "修一下 README 第 3 行的错字然后提交"'
    walk: "Triage (work) -> decompose -> no unclear block -> zero questions -> per-block playback (one line per block) -> his confirmation -> tier simple + plan + depth line stated -> start in the same turn, no second question -> journal entry carries blocks/qa/assumptions -> commit local only; push would be stop reason 3"
  - id: RP2
    scenario: 'Human to Cora: "帮我研究一下 X"'
    walk: "Triage (work) -> research decomposition table (blocks shown, no type named) -> research pack named only as pointer (frozen pack not loaded) -> unclear blocks asked one at a time, <=4 questions, options + recommended + other -> playback -> confirmation -> tier + plan"
  - id: RP3
    scenario: 'Human to Cora: "我们下一步该往哪走？"'
    walk: "Direction discussion -> she discusses only, runs no clarification [A134][A140] and no complexity assessment -> nothing starts until he says to do something -> then Triage clarification begins"
  - id: RP4
    scenario: "Direct /alex *analyze with a vague request"
    walk: "alex SKILL loads .agents/skills/cora/references/requirement-clarification.md (no socratic file exists) -> process-depth question still asked -> clarification by clarity -> playback confirmed -> requirement written to handoff §1.5"
risk_triggers:
  - "Entry path of every request changes (Cora Triage and Intake): a wrong order would start work without a confirmed playback, or add a second question to simple/reversible matters"
  - "SAFETY constraint lines reworded (AR-001 cross-model bypass, NOT_via_alex_auto anchor, forbidden list, handoff prerequisite/violation): principle 'Judgment-Only Skill Files' (SAFETY) and 'Rewiring a Gate's Prose…' apply"
  - "[A###] tag carriage on rewritten Cora lines"
  - "Files shipped downstream are removed (tad-elicit skill, socratic reference, task, template): deprecation entry + release-sync 'deprecation entries are permanent' pattern"
  - "Shell edit: .tad/hooks/lib/skill-body-verify.sh marker (read patterns/shell-portability.md first)"
  - "Index drift: git index holds stale staged entries (Syncthing); commit only with explicit pathspecs"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead), dispatched by Cora (p1-y3-1)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-19
**Project:** TAD
**Task ID:** TASK-20261019-001
**Handoff Version:** 4.0.3
**Epic:** EPIC-20261019-review-redesign.md (Phase 1/3)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

Not run in this dispatch (conductor dispatch mode, Design kind: stop before step2). Gate 2 for this phase = the Y4 review files on disk. No PASS claimed here.

---

## 📋 Handoff Checklist (Blake必读)
- [ ] Read all sections, incl. §📚 lessons and §4.0 (contradiction resolutions)
- [ ] Every §9.1 row understood; scenario walks S1–S10 planned
- [ ] Unclear → write `.tad/evidence/yolo/review-redesign/phase1-questions.md` (dispatch_id line 1) and stop

---

## 1. Task Overview

### 1.1 What We're Building
Write down the requirement clarification method the human set in Epic `## Requirement` Part 1 A–F, and make it the only method: in Cora (Triage, Intake, Route, stops, direction discussion) and in direct `/alex` (replacing the Socratic Inquiry protocol and the `tad-elicit` skill, which are removed, not left alongside). Add the requirement section to the Epic template (and the handoff template for direct `/alex` without an Epic), rewrite the dispatched-Alex Gate 1 hand-over lines, and re-carry every constraint the old text carried.

### 1.2 Why
The human's words: macro/hypothetical questions and paragraph playback are useless; the value is decomposing into concrete small blocks with options so he can correct through "other"; "when you can decompose a problem you can execute it". Today Cora is told she "runs no requirement questioning" and starts simple work "without asking", while Alex runs a fixed Q1–Q5 Socratic script and a dead BMAD 0–9 menu skill.

### 1.3 Intent Statement
**真正要解决的问题**: every piece of work starts from the human's requirement taken out of his head block by block, confirmed by one-line-per-block playback, recorded where the gates can check it.

**不是要做的**:
- ❌ Not Gate 1 conditions / format script, reviewer contract, lenses, Gates 2–4 (Phases 2–3)
- ❌ Not `*learn` Socratic teaching (kept), not Lite channel files (frozen), not research-plan "Elicit-style"
- ❌ Not changing the recommended-option rule (Assumption 1), not editing principles.md, no model test runs, no release/version/provenance/brain-index regeneration, no push

### 1.4 卸载记录（Offload Log）
| 时间 | 卸载项 | 依据 | 原文指针 | 回取方式 |
|---|---|---|---|---|
| 2026-10-19 17:30 | intake Phase 2/3 sections, full research files | out of this phase | `.tad/evidence/yolo/review-redesign/intake-details-3.md`, `.tad/evidence/research/requirement-elicitation-methods-2026-10-19.md` | Read on demand |

### 1.5 Requirement (human's words)
See Epic `## Requirement` Part 1 A–F, Q→A log, Assumptions (authoritative; do not restate differently). This phase delivers Part 1 A–F and the D1/D2 record shape; D3's Gate 1 condition list is Phase 3.

---

## 📚 Project Knowledge（Blake 必读）

Read: `.tad/project-knowledge/principles.md`; patterns `release-sync.md`, `shell-portability.md` (before editing `skill-body-verify.sh`), `gate-design.md`.

**⚠️ Blake 必须注意的历史教训**:
1. **Judgment-Only Skill Files** (principles.md, SAFETY) — a retired MUST/VIOLATION is replaced by its new form in the same edit, never dropped.
2. **Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count** (principles.md) — prove by line-set diff, keep the constraint name in reworded prose; `NOT_via_alex_auto: true` line byte-identical (`grep -Fxq`).
3. **Global-Count Floor Cannot Detect Must-Cover Loss** (principles.md) — per-constraint greps (§9.1 AC5), not counts.
4. **Execution Discipline Content Must Stay in SKILL Body** (principles.md) — the obligation (clarify first, playback confirmed, ask only unclear blocks) stays in the Cora and Alex bodies; the method detail goes to the reference with a non-circular `load_when` (must contain "When", skill-body-verify checks this for Alex).
5. **AI/Human Judgment Domain Awareness** (principles.md) — choice questions, not "对吗?" verification; see §4.0 row P1 for the playback tension.
6. **Deprecation entries are permanent and run after the copy** (patterns/release-sync.md) — a deprecated path must never be shipped again; keys are floor keys (entry applies when key ≤ the target's pre-upgrade version).
7. **Syncthing ↔ git drift** (memory) — `git status` shows `MM` on files whose worktree equals HEAD; the index holds stale staged content. Use `git diff HEAD`, commit only with `git commit -- <paths>`, never `-A` or a bare commit.

---

## 2. Background Context

### 2.1 Previous Work
This Epic's own Intake already used the method by hand (Epic `## Requirement`). Research: `.tad/evidence/research/requirement-elicitation-methods-2026-10-19.md` §1, §4 — where it differs from the Epic (pre-mortem, no-recommendation on human-domain questions, paragraph playback), the Epic wins.

### 2.2 Current State
- Cora `SKILL.md`: L19/L23/L29–30/L97/L101 start simple and reversible work "without asking"; L138 "She runs no requirement questioning [A134][A140]"; Intake L42 "Talk with the human until the result is clear" (no method, no record).
- Alex: body L1029–1032 loads `references/socratic-inquiry-protocol.md` (fixed Q1–Q5, question counts by depth, `icp_anchor`); `tad-elicit` skill (BMAD 0–9 menu, 3-round minimum) + `.tad/tasks/requirement-elicitation.md` + `.tad/templates/elicitation-methods.md`; interaction rule L1488 "Always use 0-9 numbered options".
- Epic template has no requirement section.

### 2.3 Dependencies
None (first phase). Phases 2–3 rely on `## Requirement` existing in the Epic template.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1 Method reference holds Part 1 A–F + the forbidden list + plain-text fallback (§4.2.1).
- FR2 Decomposition tables for app, research, science, learning, process/method, bug, packs by registry name as pointers (§4.2.2).
- FR3 Cora: clarify → per-block playback confirmed → tier + plan → start; E1, E3, F1, F2; simple-tier journal record; Intake writes `## Requirement` (§4.2.3).
- FR4 Direct `/alex` uses the same method; Socratic protocol, `tad-elicit`, the elicitation task and methods template removed; every reference rewired (§4.2.4–4.2.6).
- FR5 Epic template `## Requirement` (+ `### Q→A log`, `### Assumptions (not asked; Gate 4 lists them)`); handoff template `### 1.5 Requirement` (§4.2.7).
- FR6 Dispatched-Alex Gate 1 hand-over lines rewritten to D3 (§4.2.5).

### 3.2 Non-Functional Requirements
- NFR1 Every `[A###]` tag of Cora SKILL and conductor-protocol survives, on the line now carrying its constraint.
- NFR2 No weakening: stop list, [A060][A078][A081][A086], AR-001, "Express Handoff is NOT Review-Exemption", simple tier's one independent reviewer.
- NFR3 Harness-neutral: no tool name required; plain-text numbered options + "other" where no question tool exists (AGENTS.md "Interaction decisions", Cora [A038]).

---

## 4. Technical Design

### 4.0 Unchanged lines the change contradicts — and their resolution
Listed before writing (Alex design step). "Edit" = Blake changes it in this phase; tags stay on the line.

| # | File:line (today) | Text (short) | Contradicts | Resolution |
|---|---|---|---|---|
| C1 | cora/SKILL.md:21 | states the tier "every time, before acting" | F3 clarify first | Edit: tier and plan are stated after the confirmed playback |
| C2 | cora/SKILL.md:23 | simple/reversible "starts in the same turn, without asking"; "asks before starting only for an Epic or a one-way handoff" | A3 playback confirmed before work | Edit: after his confirmation of the playback she states tier/plan and starts in the same turn without a second question; the playback confirmation is the one question for every tier; Epic/one-way still ask as today |
| C3 | cora/SKILL.md:19 | `**Approved**: yes — request: "<his words>"; stated plan, started without a question` | A3 | Edit: `yes — request: "<his words>"; playback confirmed: "<his words>"; stated plan, started without a second question (date)`; [A016][A162] stay |
| C4 | cora/SKILL.md:29–30 [A010] | "do X" → triage, then starts | A3/F3 | Edit: "do X" (even "fix it and commit") → clarification, playback confirmed, then tier and plan; [A010] stays |
| C5 | cora/SKILL.md:97, :101 | grant = request + stated plan; "without one she may only discuss, show status, triage and run intake" | A3 | Edit: grant = request + confirmed playback + stated plan; add "clarify" to what she may do without a grant [A010] stays on :101 |
| C6 | cora/SKILL.md:138 | "She runs no requirement questioning [A134][A140]" | F1/F2 | Edit: "Inside a direction discussion she runs no requirement clarification [A134][A140]; it starts when he brings work and says to do it (Triage)" |
| C7 | cora/SKILL.md:42 | Intake "Talk with the human until the result is clear" | A–D | Edit: clarify by the method; write `## Requirement` before `## Result contract` |
| C8 | cora/SKILL.md:68 | subagent question "hers to answer only if the Epic answers it" | E1 (cite) | Edit: she answers from `## Requirement` / Result contract, citing the requirement line, written in the phase grounding file; else stop asking only that block |
| C9 | cora/SKILL.md:18 | simple-tier journal line fields | D1 | Edit: add `blocks:`, `qa:`, `assumptions:` |
| C10 | conductor-protocol.md:321 [A053] | "bypass requirement questions" | wording | Edit: "bypass requirement clarification [A053]" |
| C11 | conductor-dispatch-mode.md:10–11 | Gate 1 = approval of the result contract | D3 | Edit (§4.2.5) |
| C12 | alex/SKILL.md:60 | "写 handoff 前必须先做苏格拉底提问，不得跳过" | F4 | Edit: "写 handoff 前必须先做需求澄清（拆块、只问不清楚的块、逐块复述经人确认），不得跳过" |
| C13 | alex/SKILL.md:382, :446, :536, :1536, :1552 | "3-5 rounds mandatory", Socratic inquiry | A (depth by clarity) | Edit (§4.2.4) |
| C14 | alex/SKILL.md:570, :573 | "(Socratic, design, handoff_creation)"; "bypass Socratic Inquiry … complete Socratic rounds first" | F4 | Edit: "(requirement clarification, design, handoff_creation)"; "MUST NOT use cross-model delegation to bypass requirement clarification — any handoff delegating implementation to external CLI must have its per-block playback confirmed first"; next line `NOT_via_alex_auto: true …` untouched |
| C15 | alex/SKILL.md:1029–1036 | MANDATORY Socratic header + load_when | F4 | Edit (§4.2.4) + skill-body-verify marker same edit |
| C16 | alex/SKILL.md:1151 | gate1 `when: "After Socratic Inquiry…"` | F4 | Edit `when` only: "After the per-block playback is confirmed (requirement clarification), before *design"; items are Phase 3 |
| C17 | alex/SKILL.md:1462 | forbidden "Skipping elicitation rounds" | F4 | Edit: "Skipping requirement clarification (decomposition, questions on unclear blocks, confirmed per-block playback)" |
| C18 | alex/SKILL.md:1488–1490 | "Always use 0-9 numbered options" / "Never use yes/no" / "When elicit:true, MUST stop and wait" | C1–C4 (options + recommended + other; no meta-menu) | Edit: `format: "Numbered options, a marked recommended option and \"other\" (requirement clarification method)"`; `never: "Never ask a bare yes/no or \"X 对吗?\" verification question"`; `wait: "After asking, MUST stop and wait for the answer"`; `violation` line unchanged |
| C19 | alex refs (handoff-creation :7,:12,:13,:33,:55,:87,:167–168,:201,:220; research-decision :7,:20; design :11–12,:22,:220; adaptive-complexity :38,:42,:46,:120,:138–158,:169,:201,:212–225; express :48; experiment :23,:48,:112; bug :52,:74; discuss :16,:117; idea :14; idea-promote :47–48; intent-router :268,:275) | Socratic prerequisites, depth→question counts, icp_anchor | F4, A | Edit (§4.2.6) |
| C20 | tad-elicit/SKILL.md (whole) | 3-round minimum, 0–9 menu | Forbidden list | Delete (+ `.claude/skills/tad-elicit` link, `.tad/tasks/requirement-elicitation.md`, `.tad/templates/elicitation-methods.md`) |
| C21 | AGENTS.md:5 | "Requirements, design, Socratic inquiry, handoffs" | F4 | Edit: "Requirements (clarified block by block), design, handoffs, Gate 4 acceptance" |
| C22 | README.md:141 | "Handoff created without Socratic inquiry" | F4 | Edit: "Handoff created without a confirmed requirement playback: Alex must clarify the requirement block by block and get the playback confirmed before writing a handoff; re-run with the proper flow." |
| C23 | docs/CODEX-USER-GUIDE.md:87 | "Alex: [Socratic 提问 3-5 轮，澄清需求]" | A | Edit: "Alex: [拆成小块，只问不清楚的块，逐块复述经你确认]" (lines 144/420 are `*learn`, kept) |
| C24 | .tad/templates/epic-template.md | no requirement section | D1 | Edit (§4.2.7) |
| C25 | .tad/templates/handoff-a-to-b.md:557 | "Socratic 确定的域标准" | F4 | Edit: "需求澄清确定的域标准" (+ §1.5 added) |
| C26 | .tad/templates/session-state-template.md:18 | example "Socratic Inquiry Round 3/5" | A | Edit: example "Requirement clarification — block 3/5" |
| C27 | .tad/templates/skillify-candidate-template.md:51 | "existing Socratic / Gate 1" | F4 | Edit: "existing requirement clarification / Gate 1" |
| C28 | principles.md "AI/Human Judgment Domain Awareness" | give choice questions, not "对吗?" verification; preview anchoring | per-block playback confirmation (A3, D3); recommended on every question (C3) | Not edited (out of scope; not SAFETY but principles edits excluded). Resolved by AGENTS.md File authority order rank 1 (the human's explicit answers A3/C3/D3) over rank 2; the method keeps the principle's intent: playback is one line per block so he corrects a block, never one "对吗?" over a paragraph; Assumption 1 (anchoring watched). Blake writes this conflict line in the method file's Notes |
| C29 | principles.md "Judgment-Only Skill Files" (SAFETY) | constraints not removed | removal of Socratic protocol | Satisfied: every MUST/VIOLATION re-carried (§9.1 AC5); principle not edited |
| C30 | gate/SKILL.md:68–72, gate-canonical-checklist.md:9–14, tad/SKILL.md:124 | Gate 1 "After Socratic Inquiry", "Socratic Q1/Q2/Q3" | F4 | **Phase 3** (intake scope). Interim inconsistency accepted; listed as allowed sweep hits |
| C31 | .tad/config-workflow.yaml:331–604, :4–5, :683; config.yaml:48,:55,:62,:137–139; config-agents.yaml:49; config-cognitive.yaml:183 | legacy elicitation/socratic blocks and module registry | F4 | Edit (§4.2.6); config.yaml:392 is version history, kept |
| C32 | .tad/guides/anti-rationalization-tables.md:13–20,:52; skill-pressure-testing.md:13,:43–60; portable-rules.md:51; blake/SKILL.md:1249; .tad/tasks/gate-execution.md:24; .tad/tasks/handoff-creation.md:25; CARRIER-MAP :98,:102; tad/SKILL.md:43,:75,:88,:110,:132,:140 | Socratic/elicit wording | F4 | Edit (§4.2.6) |
| C33 | .tad/scripts/path-refs-allowlist.txt:48 | row for the removed task file | file removed | Delete row (else STALE-ALLOW); add a row for `.tad/agents/agent-a-architect.md` → `.tad/tasks/requirement-elicitation.md` (historical v1 agent definition, loaded by no harness; the task file was removed by EPIC-20261019) |

Out of scope, not touched: `research/canon/README.md:67`, `research/canon/_questions.yaml:1` (comments naming a nonexistent `question_dimensions`; research tooling), `.tad/agents/agent-a-architect.md`, `docs/legacy/`, `.tad/provenance/*`, `.tad/brain-index.md` (regenerated at release).

### 4.1 Architecture Overview
- One method file (harness-neutral) + one decomposition-tables file, both under `.agents/skills/cora/references/`, loaded by Cora (Triage/Intake) and by Alex (body `requirement_clarification:` block) via the repo-root path `.agents/skills/cora/references/requirement-clarification.md` (precedent: `cross_model_awareness.reference` uses a repo-root path; `.agents/skills/` exists on every harness install).
- Obligations stay in the bodies (principle "Execution Discipline…"); detail lives in the reference.
- Design decisions (class `design`, settled here):
  - D-1 Location: `cora/references/` (Cora is the main user; Alex loads by repo-root path).
  - D-2 Direct `/alex` order: unchanged position — intent router → adaptive complexity (assessment + process-depth question, Epic detection, Phase Detail check) → clarification → research/design. Rationale: the process-depth question is about ceremony, not the requirement; S7 requires it to stay; moving clarification ahead of `step2b_phase_detail_check` would invert that check. Clarification depth follows clarity at every process depth.
  - D-3 `*bug` / `*express` / `*experiment`: clarification runs (a clear bug report usually leaves no unclear block: zero questions, playback confirmed). The "skip Socratic" entries become this.
  - D-4 Deprecation: append the removed paths to the existing floor key `"3.0.0"` files list in `.tad/deprecation.yaml` with a comment line naming EPIC-20261019 and the four paths' replacement. Rationale: `apply_deprecations` applies an entry only when key ≤ the target's pre-upgrade version (tad.sh:2148–2176), so a key at the next version would be inert for every 4.0.x upgrade; the floor key needs no version number at release. List `.agents/skills/tad-elicit/` (directory, like `.tad/codex/schemas/`), `.agents/skills/alex/references/socratic-inquiry-protocol.md`, `.tad/tasks/requirement-elicitation.md`, `.tad/templates/elicitation-methods.md`. `.claude/skills/tad-elicit` is not listed: `.claude/` entries are skipped on claude-code projection and tad.sh prunes dangling skill links (tad.sh:4084).
  - D-5 Where Cora writes an E1 answer: the phase grounding file `phase{N}-grounding.md` (a file she may write), with the `## Requirement` line quoted; the next dispatch prompt names it.
  - D-6 `icp_anchor` re-carried as: if the requirement has a "who uses it" block, design-protocol step3 uses that line as the design test anchor.

### 4.2 Component Specifications

#### 4.2.1 CREATE `.agents/skills/cora/references/requirement-clarification.md`
Plain markdown, short sections, harness-neutral (no tool name required). Must contain (AC1 tokens in quotes, case-insensitive):
1. **When and how deep** (A): applies to every work request, at every tier, in Cora and direct `/alex`; depth is set by whether the request itself is clear, "not by tier"; "decompose" first, ask only the blocks still unclear, until every block is clear or written as an assumption.
2. **Decompose** (B): show the blocks, never announce a problem type; big blocks first; an unclear block is split further; use the matching table in `decomposition-tables.md`, else decompose on the spot; a block for "done check" (how the result is judged) is always present.
3. **Ask** (C): "one block at a time", "at most 4" questions per block; each question has concrete options that show the current understanding, one marked "recommended" (Assumption 1: kept, anchoring watched), and "other"; numbered. An answer through "other" → that block restated in one line "in his words", and the "Q→A log" updated.
4. **Playback and start** (A3, D3): "per-block playback", one line per block, in his words; he confirms before any work starts — also when he says "just do it" (then no questions, but the playback is still confirmed); blocks not asked appear as assumptions in the playback. For a simple or reversible matter the confirmation is the only question before start (tier and plan follow in the same turn).
5. **Record** (D): Epic `## Requirement` (block lines + `### Q→A log` + `### Assumptions (not asked; Gate 4 lists them)`); simple tier: the journal entry fields `blocks:`, `qa:`, `assumptions:`; direct `/alex` without an Epic: handoff `### 1.5 Requirement`, same three parts. Gate 1 (requirement half, D3): his confirmed playback + an Alex subagent confirming it can design from it (conditions list: Phase 3).
6. **Downstream** (E): E1 a designer's question is answered from the requirement first, citing the "requirement line"; only what it cannot answer goes to the human, asking only that block. E2 design review and Gate 4 check against it (Phases 2–3 wire the gates). E3 found wrong or changed mid-run → stop, re-ask "only that block", update its line and the Q→A log; other blocks untouched.
7. **Relation to rules** (F): clarification questions are not "blocking the human" (the stop reasons govern execution only); in a direction discussion only discussion, work starts when he says so; clarify first, then tier and plan; direct `/alex` uses this method (replaces Socratic Inquiry and `tad-elicit`).
8. **Forbidden**: macro or "hypothetical" questions incl. "pre-mortem" ("if you are disappointed in three weeks, why?"); "paragraph" playback; fixed question slots that ignore the kind of problem; "minimum" round or question counts; a 0–9 "meta-menu" of elicitation methods; a bare verification question ("X 对吗?").
9. **No question tool**: numbered options + "other" as "plain text", then stop and wait (AGENTS.md "Interaction decisions").
10. **Notes**: the C28 conflict line (human answers A3/C3/D3 over principle "AI/Human Judgment Domain Awareness", authority order).
Keep it under ~90 lines.

#### 4.2.2 CREATE `.agents/skills/cora/references/decomposition-tables.md`
Header: one line saying packs are pointers under the AGENTS.md "Capability Packs" rule (by reference, no copy of its wording; frozen packs are not auto-matched; naming a pack here loads nothing). Then six sections with exact headings `## App`, `## Research`, `## Science`, `## Learning`, `## Process / method`, `## Bug`, each a small table `| Block | What it settles |` (4–6 rows, last row always "Done check") and one line `Packs:` with packs written as `` `pack:<registry name>` `` or `none`. Suggested blocks/packs (designer may adjust; names must be registry `name:` values):
- App: who uses it and where; what they do (core flows); what it must not do; data and accounts; platform and look; done check. Packs: `pack:web-frontend`, `pack:web-backend`, `pack:web-ui-design`, `pack:web-testing`; `pack:product-thinking` (frozen).
- Research: the question and why; the decision it feeds; scope (sources, period, depth); output form; done check. Packs: `pack:research-methodology` (frozen), `pack:academic-research` (frozen).
- Science: question or hypothesis; method and measurement; data and materials; controls and validity threats; done check. Packs: `pack:academic-research` (frozen), `pack:ai-evaluation`.
- Learning: what he wants to be able to do; where he starts; depth and time; form (explanation, exercises); done check. Packs: none.
- Process / method: which flow changes; who uses it; what it replaces (not alongside); rules touched; done check (scenario walks). Packs: `pack:agent-orchestration`, `pack:ai-agent-architecture`.
- Bug: what he saw and where; what he expected; steps and frequency; since when / what changed; done check (reproduce, then passes). Packs: `pack:web-testing`.
Footer: a type not listed is decomposed on the spot; a table is added when a new type is met (Assumption 2).

#### 4.2.3 MODIFY `.agents/skills/cora/SKILL.md`
- Triage (body): after the "not work" bullet, add one bullet: work is first clarified by the method (`references/requirement-clarification.md`): decompose, show the blocks, ask only unclear blocks (one block at a time, at most 4 questions, options + recommended + "other"), per-block playback confirmed by him; only then tier and plan. Clarification questions are not "blocking the human": the stop reasons govern execution only (F1). Edit C1, C2, C3, C9 as in §4.0 (tags kept: [A016][A162] on :19, [A078][A086] line :22 untouched).
- When an instruction meets a rule: C4 (and :29 "she then starts that way" → "after the confirmed playback she starts that way").
- Intake: C7; add after `## Result contract` bullet order: `## Requirement` comes first (block lines, Q→A log, Assumptions); :49 intake Alex is Gate 1's Alex half ("confirms it can design from `## Requirement`, else questions").
- Route: C8 (E1).
- When Cora stops: under reason 2 add E3: requirement found wrong or changed mid-run → stop (reason 2), ask only that block, update its line and the Q→A log on his answer; other blocks untouched.
- C5 (:97, :101). Direction discussion: C6; line :140 add "or he brings work and says to do it: clarification starts (Triage)" (F2).
- References: add `reference: references/requirement-clarification.md` with `load_when: "When the human brings work (Triage, before the tier is stated) or Intake begins, and when a subagent question or a mid-run change touches the requirement"`, and `reference: references/decomposition-tables.md` with `load_when: "When decomposing a request (requirement-clarification, Decompose)"`.
- Keep unchanged: the simple tier's "one reviewer (middle tier) that did not do the work" phrase, the stop list, [A038], [A040], [A083]/[A084].
- Before the >20-line edit list what contract changed (AR-002 [A092]) in the completion report.

#### 4.2.4 MODIFY `.agents/skills/alex/SKILL.md`
C12, C13 (:382 "Requirement clarification by decomposition: ask only unclear blocks; per-block playback confirmed"; :446 `analyze: Start requirement clarification (decompose, ask only unclear blocks, per-block playback)`; :536 replace with `- requirement clarification (.agents/skills/cora/references/requirement-clarification.md)`; :1536 "3. **Understand** → Requirement clarification: blocks, unclear-block questions, per-block playback confirmed"; :1552 "`*analyze` - Start requirement clarification (blocks, playback confirmed)"), C14, C16, C17, C18. :1029–1036 becomes:
```
# ⚠️ MANDATORY: Requirement Clarification (Before Handoff)
requirement_clarification:
  reference: ".agents/skills/cora/references/requirement-clarification.md"
  load_when: "When the requirement clarification begins after adaptive_complexity assessment (and before *design or a handoff), Read the reference and follow it verbatim."
# ⚠️ MANDATORY: Research & Decision Protocol (Cognitive Firewall - Pillar 1 & 2)
research_decision_protocol:
  reference: "references/research-decision-protocol.md"
  load_when: "When Research and Decision Protocol begins after the requirement playback is confirmed, Read the reference and follow it verbatim."
```
Leave `*learn` lines (:443, :1520, :1551) and the `NOT_via_alex_auto` line byte-identical.

#### 4.2.5 MODIFY `.agents/skills/alex/references/conductor-dispatch-mode.md`
Lines 10–11 become:
```
## Gate 1 is passed for you
Gate 1 is the human's confirmed per-block playback, recorded in the Epic's `## Requirement`, plus your confirmation that you can design from it. If `## Requirement` and the phase block do not let you say what is to be built and how it is judged, return that as a question naming the block; do not guess.
```
Line 14: `The intent router, complexity assessment, the requirement clarification (the Epic's ` + "`## Requirement`" + ` is your requirement), and every question to the human.`

#### 4.2.6 MODIFY the rewiring set (one line each unless noted)
- `alex/references/handoff-creation-protocol.md`: :7 `prerequisite: "必须先完成需求澄清（逐块复述经人确认；Cora 派发的 Epic 阶段即 Epic ## Requirement）"`; :12 `action: "检查需求澄清是否完成（逐块复述已经人确认）"`; :13 `violation: "未完成需求澄清（逐块复述未经人确认）就开始写 handoff = VIOLATION"`; :33/:55 "the requirement (block lines, Q→A log)"; :87 "(post-clarification)"; :167–168 "Clarification depth follows clarity; a sufficient Phase Detail Block leaves fewer unclear blocks (step2b_phase_detail_check). This step only pre-fills handoff sections."; :201 "+ requirement"; :220 "requirement-determined quality standards".
- `research-decision-protocol.md` :7 `prerequisite: "Requirement clarification completed (per-block playback confirmed)"`; :20 "After the requirement playback is confirmed, …".
- `design-protocol.md` :11 `name: "Review the Requirement"`; :12 `action: "Confirm every block of the requirement is clear or listed as an assumption"`; :22 trigger "After the requirement review (step1)"; :220 D-6 wording.
- `adaptive-complexity-protocol.md`: process_depths descriptions drop question counts (full: "Requirement clarification (depth by clarity) → Expert Review → Detailed Handoff → All Gates"; standard: "Requirement clarification → Handoff → Gates"; light: "Requirement clarification → Quick Handoff → Streamlined Gates"); :120 "derive from the confirmed requirement"; step2b_phase_detail_check (:138–158): name "(pre-clarification)", trigger "before requirement clarification", ALL pass → "blocks the Detail Block answers are shown as clear in the playback; ask only blocks it leaves unclear", announce "Phase {N} 已有详细定义：只问它没说清的块。", ANY fail → "clarify the blocks the failed check names"; :169, :201, :212 "requirement clarification"; step3 (:216–220): "full / standard / light: run requirement clarification (depth follows clarity, same method at every depth); skip: as today"; integration (:223–228): "Process depth sets the ceremony (reviews, handoff detail, gates); it does not set the number of questions — clarity does."
- `express-path-protocol.md` :48 → move to required_steps as "requirement clarification (a clear request leaves no unclear block: zero questions, per-block playback confirmed)"; skipped_steps loses the line.
- `experiment-path-protocol.md` :23 "Clarification answers mention…"; :48 "Requirement clarification (method reference) — DO follow"; :112 "MUST NOT bypass *analyze requirement clarification for *experiment — all Standard TAD steps DO run".
- `bug-path-protocol.md` :52 "(requirement playback confirmed; skip expert review)"; :74 "This is an express bugfix — requirement clarification was a playback (no unclear block), no expert review".
- `discuss-path-protocol.md` :16, :117 "requirement clarification (it starts when work is brought)".
- `idea-path-protocol.md` :14 "(NOT the requirement clarification method; an idea is clarified when promoted)".
- `idea-promote-protocol.md` :47 "at the start of requirement clarification"; :48 "Open Questions → seed the unclear blocks".
- `intent-router-protocol.md` :268 "(clarification/Design/Handoff)"; :275 "with the requirement playback confirmed".
- `.tad/hooks/lib/skill-body-verify.sh` :129 `"MANDATORY: Requirement Clarification"`, :138 `"Requirement Clarification (MANDATORY body header)"` (same edit as alex SKILL header).
- `.agents/skills/tad/SKILL.md`: delete :43 and renumber 5–7 → 4–6; :75 "**Requirement clarification**: decompose into blocks, ask only unclear blocks (options + recommended + other), per-block playback confirmed before work"; delete :88 `/elicit` line; :110 "Requirement clarification → blocks, questions on unclear blocks, playback confirmed"; :132 "Clarify the requirement block by block before designing"; :140 "Skip requirement clarification or its playback".
- `.agents/skills/blake/SKILL.md` :1249 "AC 是 Alex 依据经人确认的需求（逐块复述）和专家审查确定的".
- `.tad/config.yaml` :48 description "…requirement clarification pointer…"; remove `- requirement_elicitation (research_phase)` and `- socratic_inquiry_protocol` from `contains`, add `- requirement_clarification (pointer)`; remove `- tad-elicit.md` from `loaded_by`; remove the `tad-elicit:` module entry (:137–139).
- `.tad/config-workflow.yaml` :4–5 header (drop socratic/tad-elicit names); replace :331–604 (both legacy blocks) with:
```
# ==================== Requirement clarification (EPIC-20261019) ====================
# Replaces requirement_elicitation (BMAD rounds) and socratic_inquiry_protocol.
requirement_clarification:
  reference: ".agents/skills/cora/references/requirement-clarification.md"
  tables: ".agents/skills/cora/references/decomposition-tables.md"
```
  :683 "Full TAD workflow: requirement clarification → design → handoff".
- `.tad/config-agents.yaml` :49 "需求分析 → 需求澄清（拆块、逐块复述确认）→ 设计 → 写 handoff"; `.tad/config-cognitive.yaml` :183 `insert_after: "requirement_clarification"`.
- `.tad/portable-rules.md` :51 "Requirement clarification method (Cora and Alex)".
- `.tad/guides/anti-rationalization-tables.md`: Category 1 renamed "Requirement Clarification Bypass"; S1 excuse "描述已经很详细，直接开始写" → rebuttal "清楚的请求可以零提问，但拆块和逐块复述经人确认不能省"; S2 "对话里问更快，不用记录" → "问答进 Q→A log；没有提问工具时用纯文本编号选项 + 其他"; S3 unchanged; S4 "问够了可以开始写了" → "够不够看每块是否清楚；不清楚的块要么问，要么作为假设写进复述"; :52 location "alex SKILL requirement_clarification (method reference: Forbidden)".
- `.tad/guides/skill-pressure-testing.md` :13 example rule "Alex must get the per-block requirement playback confirmed before writing a handoff"; worked example (:43–60) retitled "Requirement Clarification Rule", same RED/GREEN/REFACTOR shape: RED skips playback; GREEN decomposes, asks only unclear blocks, plays back; REFACTOR bypasses "user said fast → skip playback" → anti-rationalization "just do it still gets the playback", "options steer to my design" → "options show understanding, 'other' always offered".
- `.tad/tasks/gate-execution.md` :24 "**Enforced by:** requirement clarification (`.agents/skills/cora/references/requirement-clarification.md`); Gate 1 conditions: Phase 3 of EPIC-20261019"; `.tad/tasks/handoff-creation.md` :25 "Requirement clarified and per-block playback confirmed".
- `.tad/active/designs/CARRIER-MAP-alex-constraints.md` :98 "bypass requirement clarification via delegation | 正文 cross_model_awareness.forbidden_implementations + refs"; :102 "bypass requirement clarification via shortcut | `experiment-path-protocol.md:112`".
- C21, C22, C23, C25, C26, C27, C33.
- `.tad/deprecation.yaml`: D-4.
- DELETE with `git rm`: `.agents/skills/tad-elicit/` (dir), `.claude/skills/tad-elicit` (symlink), `.agents/skills/alex/references/socratic-inquiry-protocol.md`, `.tad/tasks/requirement-elicitation.md`, `.tad/templates/elicitation-methods.md`.

#### 4.2.7 Templates
- `.tad/templates/epic-template.md`: insert after `## Objective` block, before `## Success Criteria`:
```
## Requirement
{One line per block, in the human's words (requirement-clarification method). Gate 1: he confirmed this playback.}
- **{block}**: {his words}

### Q→A log
- {block}{n}: {question} → {his answer, in his words}

### Assumptions (not asked; Gate 4 lists them)
- {what was not asked, and what is assumed}
```
- `.tad/templates/handoff-a-to-b.md`: add `### 1.5 Requirement (human's words)` after §1.4 with: "Epic phase: point to the Epic's `## Requirement` (and name the blocks this phase covers). Direct /alex without an Epic: block lines, `Q→A log`, `Assumptions (not asked; Gate 4 lists them)`."

### 4.3–4.5 Data / API / UI
N/A (protocol text).

---

## 5. 强制问题回答
- MQ1 历史搜索: yes — grounded in `git show HEAD:` texts listed in §7.3; nothing reused beyond the rewired lines.
- MQ2 函数: no functions; scripts used: `.tad/hooks/lib/skill-body-verify.sh` (exists, exit 0 today), `.tad/scripts/check-path-refs.mjs` (exists), `tad.sh apply_deprecations` (read, tad.sh:2153).
- MQ3–MQ5: N/A (no data flow / UI / state).

---

## 6. Implementation Steps

| # | File | Operation | Verification |
|---|------|-----------|-------------|
| 1 | cora/references/requirement-clarification.md | CREATE (§4.2.1) | AC1 |
| 2 | cora/references/decomposition-tables.md | CREATE (§4.2.2) | AC2 |
| 3 | cora/SKILL.md, conductor-protocol.md :321 | MODIFY (§4.2.3, C10) | AC6, AC10 |
| 4 | alex/SKILL.md + skill-body-verify.sh (same edit) | MODIFY (§4.2.4, §4.2.6) | AC5, AC8 |
| 5 | alex references (§4.2.5, §4.2.6) | MODIFY | AC4, AC5 |
| 6 | templates, configs, guides, tasks, docs, AGENTS/README, CARRIER-MAP, allowlist, deprecation | MODIFY (§4.2.6–4.2.7) | AC3, AC4, AC7, AC11, AC12 |
| 7 | removed files | `git rm` | AC3 |
| 8 | scenario walks S1–S10 + RP1–RP4 | completion report | AC9 |

Commit: local only, explicit pathspecs (`git add -- <paths>`, `git commit -- <paths>`), tag `[YOLO Phase 1]`; never `-A`, never a bare commit (stale index, §📚 lesson 7); no push.

Phase completion evidence: `.tad/evidence/yolo/review-redesign/phase1-completion.md` with `dispatch_id` of Blake's dispatch, the AC outputs, the AR-002 contract list, the remaining sweep hits with reasons, and the scenario walks.

---

## 7. File Structure

### 7.1 Files to Create
```
.agents/skills/cora/references/requirement-clarification.md   # method (Part 1 A–F)
.agents/skills/cora/references/decomposition-tables.md        # six type tables
```

### 7.2 Files to Modify / Delete
```
.agents/skills/cora/SKILL.md
.agents/skills/cora/references/conductor-protocol.md            # :321 only
.agents/skills/alex/SKILL.md
.agents/skills/alex/references/{conductor-dispatch-mode,handoff-creation-protocol,research-decision-protocol,design-protocol,adaptive-complexity-protocol,express-path-protocol,experiment-path-protocol,bug-path-protocol,discuss-path-protocol,idea-path-protocol,idea-promote-protocol,intent-router-protocol}.md
.agents/skills/tad/SKILL.md
.agents/skills/blake/SKILL.md                                   # :1249 comment
.tad/hooks/lib/skill-body-verify.sh                             # :129, :138
.tad/templates/{epic-template,handoff-a-to-b,session-state-template,skillify-candidate-template}.md
.tad/config.yaml  .tad/config-workflow.yaml  .tad/config-agents.yaml  .tad/config-cognitive.yaml
.tad/portable-rules.md  .tad/guides/anti-rationalization-tables.md  .tad/guides/skill-pressure-testing.md
.tad/tasks/gate-execution.md  .tad/tasks/handoff-creation.md
.tad/active/designs/CARRIER-MAP-alex-constraints.md
.tad/scripts/path-refs-allowlist.txt  .tad/deprecation.yaml
AGENTS.md  README.md  docs/CODEX-USER-GUIDE.md
DELETE: .agents/skills/tad-elicit/  .claude/skills/tad-elicit  .agents/skills/alex/references/socratic-inquiry-protocol.md  .tad/tasks/requirement-elicitation.md  .tad/templates/elicitation-methods.md
NOT by hand: .tad/brain-index.md, .tad/provenance/*  (release)
```

### 7.3 Grounded Against (Alex step1c, read 2026-10-19 17:00–17:36)
- `.agents/skills/cora/SKILL.md` (full, 159 lines)
- `.agents/skills/cora/references/conductor-protocol.md` (:40–70, :300–334)
- `.agents/skills/alex/SKILL.md` (:50–70, :370–390, :440–580, :1020–1045, :1140–1160, :1450–1560)
- `.agents/skills/alex/references/socratic-inquiry-protocol.md` (full), `adaptive-complexity-protocol.md` (:1–60, :110–229), `design-protocol.md` (:1–30, :212–232), `research-decision-protocol.md` (:1–25), `express-path-protocol.md` (:40–56), `experiment-path-protocol.md` (:18–26, :44–50, :106–116), `bug-path-protocol.md` (:48–76), `discuss-path-protocol.md` (:10–20, :112–120), `idea-path-protocol.md` (:8–18), `idea-promote-protocol.md` (:40–52), `intent-router-protocol.md` (:262–280), `conductor-dispatch-mode.md` (full), `handoff-creation-protocol.md` (:1–560)
- `.agents/skills/tad-elicit/SKILL.md` (full), `.agents/skills/tad/SKILL.md` (:38–142)
- `.tad/templates/epic-template.md` (full), `.tad/templates/handoff-a-to-b.md` (full)
- `.tad/config.yaml` (:40–70, :130–145), `.tad/config-workflow.yaml` (structure, :331–345, :595–605, :676–690), `.tad/config-cognitive.yaml` (:175–190), `.tad/config-agents.yaml` (:44–52)
- `.tad/guides/anti-rationalization-tables.md` (:10–56), `.tad/guides/skill-pressure-testing.md` (:10–70), `.tad/portable-rules.md` (:45–56), `.tad/tasks/gate-execution.md` (:20–27), `.tad/tasks/handoff-creation.md` (:22–27)
- `.tad/hooks/lib/skill-body-verify.sh` (:15–60, :100–175), `.tad/scripts/check-path-refs.mjs` (:33–75), `.tad/scripts/path-refs-allowlist.txt` (:1–12, :48)
- `.tad/deprecation.yaml` (:1–60, tail), `tad.sh` (:1562–1572, :2146–2275), `.tad/capability-packs/pack-registry.yaml` (names/status)
- `.tad/active/designs/CARRIER-MAP-alex-constraints.md` (:90–105), `.tad/codex/README.md` (:95–109)
- Note: `git status` lists several of these as `MM`, but `git diff HEAD` on all §7.2 paths is empty — worktree equals HEAD; HEAD is the baseline for every before/after AC.

---

## 8. Testing Requirements
Protocol text: no unit tests, no model runs. Verification = §9.1 commands + scenario walks (AC9).

### 8.3 Edge Cases
- Dangling symlink: `test ! -e` passes on a dangling link; AC3 uses `git ls-files` and `-e || -L`.
- `grep` may be aliased (ugrep) in interactive shells: run ACs with `bash -c` and `command grep`.

## 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| ruby absent | AC12 YAML parse | install not allowed silently; ask | `python3 -c 'import yaml'` if available | unresolved → BLOCKED |
| node absent | AC11 path refs | ask | none | BLOCKED |
| stale git index | commit | explicit pathspecs | none | wrong commit content = Gate 3 FAIL |

## 8.5 Feedback Collection
N/A.

---

## 9. Acceptance Criteria
All §9.1 rows pass; scenario walks reach their stated ends; no weakening (AC10).

## 9.1 Spec Compliance Checklist
Run every command with `bash -c '…'` from the repo root (`command grep` avoids aliases). In table cells `\|` stands for `|`; run the raw form (dry-run log below).

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| AC1 | Method file holds every Scope-1 element | post-impl | see raw R1 | `0` (no token missing) | today: no output (file absent) → FAIL as expected |
| AC2 | Six type tables; every pack name is a registry name; pointer rule by reference | post-impl | R2a, R2b, R2c, R2d | R2a `6`; R2b `0`; R2c ≥ `1`; R2d `≥1 0` | today: R2a/R2c error, file absent |
| AC3 | Old files replaced, not alongside; deprecation lists them; skill dir parity unchanged | post-impl | R3a, R3b, R3c | R3a `0`; R3b `4`; R3c `_archived local ` | R3a `5`; R3b `0`; R3c `_archived local ` (invariant) |
| AC4 | Sweep: only allowed hits remain | post-impl | R4 (sweep with allow-filter) | `0` | `114` |
| AC5 | Constraints re-carried | post-impl | R5a–R5j | R5a `4` and R5b `4`; R5c–R5j each `1` (R5e `1` before and after) | R5a `0`, R5b `0`; R5c,d,f–j `0`; R5e `1` |
| AC6 | [A###] tags ⊇ before; tags on rewritten lines | post-impl | R6a, R6b, R6c, R6d | R6a `0`; R6b ≥`1`; R6c ≥`1`; R6d ≥`1` | R6a `0` (invariant); R6b–d `0` |
| AC7 | Epic template `## Requirement` with sub-heads before Success Criteria; handoff §1.5 | post-impl | R7a, R7b, R7c | `1`, `OK`, `1` | `0`, `FAIL`, `0` |
| AC8 | Body marker moved in the same edit; verifier green | post-impl | R8a, R8b | R8a `1 1`; R8b `0` | R8a `0 0`; R8b `0` |
| AC9 | Scenario walks S1–S10 and RP1–RP4 in the completion report, quoting deciding lines | post-impl | R9 | `14` | file absent |
| AC10 | No weakening (tags/stop words/AR-001/Express principle counts not lower; simple-tier reviewer phrase kept) | post-impl | R10a, R10b | R10a `0`; R10b `1` | R10a `0` (invariant); R10b `1` |
| AC11 | No new dangling/stale path refs for the touched names | post-impl | R11 | `0` | `0` (guard; fails if allowlist row 48 is left or C33 row missing) |
| AC12 | YAML files still parse | post-impl | R12 | `YAML_OK` | `YAML_OK` (invariant) |
| AC13 | Cora body carries the method obligations | post-impl | R13 | each count ≥ `1`, line `0` | see log |

Raw commands:
```
R1:  f=.agents/skills/cora/references/requirement-clarification.md; test -f "$f" && for p in 'decompose' 'not by tier' 'one block at a time' 'at most 4' 'recommended' '"other"' 'in his words' 'per-block playback' 'just do it' 'Q→A log' 'assumption' 'pre-mortem' 'hypothetical' 'paragraph' 'minimum' 'meta-menu' '对吗' 'plain text' 'only that block' 'requirement line' 'blocking the human'; do printf '%s=%s\n' "$p" "$(command grep -ciE -- "$p" "$f")"; done | command grep -c '=0$'
R2a: command grep -cE '^## (App|Research|Science|Learning|Process / method|Bug)$' .agents/skills/cora/references/decomposition-tables.md
R2b: comm -23 <(command grep -oE '`pack:[a-z0-9-]+`' .agents/skills/cora/references/decomposition-tables.md | sed -e 's/`pack://' -e 's/`//' | sort -u) <(command grep -E '^[[:space:]]*- name:' .tad/capability-packs/pack-registry.yaml | sed -E 's/.*name: "?([^"]+)"?.*/\1/' | sort -u) | wc -l
R2c: command grep -oE '`pack:[a-z0-9-]+`' .agents/skills/cora/references/decomposition-tables.md | sort -u | wc -l
R2d: echo "$(command grep -c 'AGENTS.md' .agents/skills/cora/references/decomposition-tables.md) $(command grep -c 'Keyword match alone never loads' .agents/skills/cora/references/decomposition-tables.md)"
R3a: git ls-files -- .agents/skills/tad-elicit .claude/skills/tad-elicit .agents/skills/alex/references/socratic-inquiry-protocol.md .tad/tasks/requirement-elicitation.md .tad/templates/elicitation-methods.md | wc -l; for p in .agents/skills/tad-elicit .claude/skills/tad-elicit .agents/skills/alex/references/socratic-inquiry-protocol.md .tad/tasks/requirement-elicitation.md .tad/templates/elicitation-methods.md; do { [ -e "$p" ] || [ -L "$p" ]; } && echo "PRESENT $p"; done
R3b: command grep -cE 'tad-elicit/|socratic-inquiry-protocol\.md|tasks/requirement-elicitation\.md|templates/elicitation-methods\.md' .tad/deprecation.yaml
R3c: comm -3 <(ls .agents/skills) <(ls .claude/skills) | tr -d '\t' | sort | tr '\n' ' '
R4:  command grep -rniI -e socratic -e tad-elicit -e '/elicit\b' -e requirement-elicitation -e '3-5 rounds' -e 'elicitation rounds' -e '苏格拉底' .agents/skills .tad/templates .tad/gates .tad/hooks .tad/config.yaml .tad/config-agents.yaml .tad/config-cognitive.yaml .tad/config-workflow.yaml .tad/config-execution.yaml .tad/config-platform.yaml .tad/config-quality.yaml .tad/portable-rules.md .tad/guides .tad/tasks .tad/codex/README.md .tad/active/designs/CARRIER-MAP-alex-constraints.md AGENTS.md README.md docs/CODEX-USER-GUIDE.md | command grep -vE 'Socratic teach|Socratic Loop|style: "socratic"|3\+ Socratic rounds|skip Socratic, skip epic review|苏格拉底式学习|苏格拉底式教学|Socratically|^\.agents/skills/(research-notebook|academic-research|_archived)/|^\.agents/skills/gate/SKILL\.md:(68|71|72):|^\.tad/gates/gate-canonical-checklist\.md:(9|12|13|14):|^\.tad/codex/README\.md:107:|changes: \["Socratic Inquiry Protocol"' | wc -l
R5a: comm -23 <(git show HEAD:.agents/skills/alex/SKILL.md | command grep -E 'MUST|VIOLATION|必须' | sort -u) <(command grep -E 'MUST|VIOLATION|必须' .agents/skills/alex/SKILL.md | sort -u) | wc -l
R5b: comm -23 <(git show HEAD:.agents/skills/alex/SKILL.md | command grep -E 'MUST|VIOLATION|必须' | sort -u) <(command grep -E 'MUST|VIOLATION|必须' .agents/skills/alex/SKILL.md | sort -u) | command grep -cE 'Socratic|苏格拉底|elicit'
R5c: command grep -c '^- 写 handoff 前必须先做需求澄清' .agents/skills/alex/SKILL.md
R5d: command grep -c 'MUST NOT use cross-model delegation to bypass requirement clarification' .agents/skills/alex/SKILL.md
R5e: command grep -Fxc '  NOT_via_alex_auto: true  # Alex NEVER auto-invokes external CLI — suggest or delegate only' .agents/skills/alex/SKILL.md
R5f: command grep -c 'from any Alex protocol step (requirement clarification, design, handoff_creation)' .agents/skills/alex/SKILL.md
R5g: command grep -c '^  - Skipping requirement clarification' .agents/skills/alex/SKILL.md
R5h: command grep -c 'MUST NOT bypass \*analyze requirement clarification for \*experiment' .agents/skills/alex/references/experiment-path-protocol.md
R5i: echo $(( $(command grep -c 'prerequisite: "必须先完成需求澄清' .agents/skills/alex/references/handoff-creation-protocol.md) * $(command grep -c 'violation: "未完成需求澄清' .agents/skills/alex/references/handoff-creation-protocol.md) ))
R5j: echo $(( $(command grep -c 'bypass requirement clarification \[A053\]' .agents/skills/cora/references/conductor-protocol.md) * ( $(command grep -c 'bypass requirement clarification via' .tad/active/designs/CARRIER-MAP-alex-constraints.md) / 2 ) ))
R6a: for g in .agents/skills/cora/SKILL.md .agents/skills/cora/references/conductor-protocol.md; do comm -23 <(git show "HEAD:$g" | command grep -o '\[A[0-9]*\]' | sort -u) <(command grep -o '\[A[0-9]*\]' "$g" | sort -u); done | wc -l
R6b: command grep '\[A134\]\[A140\]' .agents/skills/cora/SKILL.md | command grep -c 'clarification'
R6c: command grep '\[A010\]' .agents/skills/cora/SKILL.md | command grep -c 'playback'
R6d: command grep '\[A016\]' .agents/skills/cora/SKILL.md | command grep -c 'playback'
R7a: command grep -c '^## Requirement$' .tad/templates/epic-template.md
R7b: awk '/^## Requirement$/{r=NR} /^### Q→A log/{q=NR} /^### Assumptions/{a=NR} /^## Success Criteria/{s=NR} END{print (r&&q>r&&a>q&&s>a)?"OK":"FAIL"}' .tad/templates/epic-template.md
R7c: command grep -c '^### 1.5 Requirement' .tad/templates/handoff-a-to-b.md
R8a: echo "$(command grep -c 'MANDATORY: Requirement Clarification' .agents/skills/alex/SKILL.md) $(command grep -c '"MANDATORY: Requirement Clarification"' .tad/hooks/lib/skill-body-verify.sh)"
R8b: bash .tad/hooks/lib/skill-body-verify.sh >/dev/null 2>&1; echo $?
R9:  command grep -cE '^#+ (S([1-9]|10)|RP[1-4])\b' .tad/evidence/yolo/review-redesign/phase1-completion.md
R10a: for g in $(git diff HEAD --name-only -- .agents/skills .tad/templates .tad/hooks AGENTS.md README.md docs); do test -f "$g" || continue; for tk in '\[A060\]' '\[A078\]' '\[A081\]' '\[A086\]' 'AR-001' 'Express Handoff is NOT Review-Exemption' 'push' 'credentials' 'spending'; do b=$(git show "HEAD:$g" 2>/dev/null | command grep -c -- "$tk"); a=$(command grep -c -- "$tk" "$g"); [ "$a" -ge "$b" ] || echo "LOST $tk $g"; done; done | wc -l
R10b: command grep -c 'one reviewer (middle tier) that did not do the work' .agents/skills/cora/SKILL.md
R11: node .tad/scripts/check-path-refs.mjs 2>&1 | command grep -cE 'tad-elicit|socratic|requirement-elicitation|elicitation-methods|requirement-clarification|decomposition-tables'
R12: ruby -ryaml -e 'ARGV.each{|f| YAML.load_file(f)}; puts "YAML_OK"' .tad/config.yaml .tad/config-workflow.yaml .tad/config-cognitive.yaml .tad/config-agents.yaml .tad/deprecation.yaml
R13: f=.agents/skills/cora/SKILL.md; for p in 'references/requirement-clarification.md' 'references/decomposition-tables.md' 'per-block playback' 'blocking the human' 'only that block' 'requirement line' 'assumptions:' 'without a second question'; do printf '%s=%s\n' "$p" "$(command grep -c -- "$p" "$f")"; done | command grep -c '=0$'
```
AC13 expected `0`; today `8` (dry-run: none of these tokens is in cora/SKILL.md yet — "without a second question" also absent).

R9 note: Blake writes the walks as headings `### S1 …` … `### S10 …`, `### RP1 …` … `### RP4 …` (S1–S10 as in intake-details-3.md AC1.8). Each walk quotes the deciding lines (file:line) and reaches the stated end; a walk that does not reach it is a FAIL, not a note.

R4 note: every remaining hit that the filter allows is listed in the completion report with file:line and reason (`*learn` teaching; Phase 3 Gate 1 items; migration history; frozen/deprecated skills; config.yaml version history).

### AC Dry-Run Log (Alex step1d, 2026-10-19 17:25–17:36, `bash -c`, `command grep`)
- R1: post-impl; syntax `bash -n` OK; today prints nothing (file absent). Known-good/known-bad: a scratch file with only "decompose first" → `decompose=1`, `not by tier=0`, `"other"=0`, `Q→A log=0`, `对吗=0` (tokens detected/missed as intended).
- R2b: known-bad scratch with `pack:web-frontend`, `pack:bogus-pack`, `pack:product-thinking` → prints `bogus-pack` only (registry extraction correct, quoted names handled). Today: file absent.
- R3a: today `5` tracked; R3b today `0` (existing `.claude/commands/tad-elicit.md` entries do not match `tad-elicit/`); R3c today `_archived local ` (pre-existing difference, must stay identical).
- R4: today `114` hits across 34 files (alex SKILL 15, adaptive-complexity 17, handoff-creation 10, config-workflow 8, …); filter keeps `*learn`, Phase-3 Gate 1 lines, migration history, frozen/deprecated/archived skills.
- R5a/R5b: syntax OK; today `0`/`0`. Expected 4 after: alex SKILL :60, :570, :573, :1490 (the `elicit: … MUST stop and wait` line) — each reworded, not dropped; any other missing line = FAIL.
- R5e: today `1` (anchor present, must stay byte-identical).
- R5c,d,f,g,h,i,j: today `0` each (new wording absent) → fail for the right reason.
- R6a: today `0` (unchanged files); R6b–R6d today `0`.
- R7a `0`, R7b `FAIL`, R7c `0` today.
- R8a `0 0` today; R8b `0` today (verifier green on the old marker; must stay green on the new one).
- R10a: today `0`; R10b `1`.
- R11: today `0`; after deletion without the allowlist fix it would report `STALE-ALLOW …:48` and `DANGLING .tad/agents/agent-a-architect.md:18` (both match the pattern) → guard row. Note: the whole tool exits 1 today for unrelated reasons (sync-conflict NEXT copies, rulings rows), so only the targeted count is checked.
- R12: today `YAML_OK` (ruby 2.6; python3 has no yaml module here).
- R13: today `8`.
- verify-ac-commands.sh: advisory tail not run in this dispatch (no tool calls beyond reading/dry-runs requested); Blake may run it, advisory only.

---

## 9.2 Expert Review Status
Not run in this dispatch (Design kind stops before step2). Y4 reviewers (consistency + fit) write their files under `.tad/evidence/yolo/review-redesign/`.

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| — | (Y4 pending) | — | — |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Do not add a second question for simple/reversible matters: the playback confirmation is the one question; tier and plan follow in the same turn (S1).
- ⚠️ `NOT_via_alex_auto: true  # …` line byte-identical; AR-001 lines reworded with the constraint name kept.
- ⚠️ Rules do not change under this running phase (Epic Notes): this run continues to use the protocol as approved at "continue".
- ⚠️ Do not edit principles.md, NEXT.md, session-state.md, provenance, brain-index; no version bump; no push.
- ⚠️ Gate 1 items in gate/SKILL.md and gate-canonical-checklist.md stay for Phase 3 (they will name "Socratic Q1/Q2" until then — accepted interim).

### 10.2 Known Constraints
- The Epic itself has no inline Phase Detail block (it points to `intake-details-3.md`); this dispatch writes no Epic edit.
- AR-002 [A092]: Cora SKILL edit > 20 lines → list the changed contracts in the completion report.

### 10.3 Sub-Agent使用建议
None required; Blake does not call reviewers (Cora dispatches them).

---

## 11. Learning Content

### 11.1 Decision Rationale: deprecation key
| 方案 | 优点 | 缺点 | 为什么没选 |
|---|---|---|---|
| Append to floor key "3.0.0" (chosen) | applies to every 3.x/4.x upgrade; no version to set at release | key description widens | ✅ |
| New key at next version | reads naturally | inert for upgrades from 4.0.x (tad.sh applies key ≤ old version) | removes nothing downstream |
| Migration manifest | per-hop | needs a git source; download installs skip it (release-sync pattern) | proven not to run |

**💡 Human学习点**: in this installer a deprecation key means "projects at or above this version had the file", not "removed in this version".

---

**Handoff Created By**: Alex (Agent A), conductor dispatch p1-y3-1
**Date**: 2026-10-19
**Version**: 4.0.3
