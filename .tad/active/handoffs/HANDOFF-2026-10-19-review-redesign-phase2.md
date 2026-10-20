---
dispatch_id: p2-y3-1
task_type: mixed       # protocol text (md), one config (yaml), templates; no shell edit in this phase
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
# Review routing (this phase introduces these two keys; closed list per §4.2.1 §5)
risk_triggers: [platform]   # reviewer dispatch must work on Claude Code, Codex, Cursor, OpenCode (subagent names are examples; reviewers cannot spawn subagents)
real_paths:
  # Protocol text: each path is walked through the NEW text; the completion report quotes the deciding file:line at each step. No model runs.
  - id: RP1
    path: "Cora Epic phase: Y4 Gate 2 and Y6 Gate 3 on a handoff with risk_triggers [platform]"
    run: "walk S1 of §9.1 AC7 through conductor-protocol step_Y4/step_Y6 and the review contract"
  - id: RP2
    path: "Cora simple tier: one Blake pass, two light reviewers, one rework"
    run: "walk D5 through cora/SKILL.md Triage (Simple) and the review contract §7-§8"
  - id: RP3
    path: "Direct /alex *handoff -> Gate 2 in Alex's hands -> direct /blake Layer 2 -> Gate 3 verdict not signed by Blake"
    run: "walk D1 and D4 through handoff-creation-protocol step2-step3 and blake/SKILL.md Layer 2 / completion_protocol"
  - id: RP4
    path: "Direct /alex *bug mini-handoff and *express"
    run: "walk D2 and D3 through bug-path-protocol and express-path-protocol"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead), dispatched by Cora (p2-y3-1)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-19
**Project:** TAD
**Task ID:** TASK-20261019-002
**Handoff Version:** 4.0.3
**Epic:** EPIC-20261019-review-redesign.md (Phase 2/3)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

Not run in this dispatch (conductor dispatch mode, Design kind: stop before step2). Gate 2 for this phase = the Y4 review files on disk. No PASS claimed here.

---

## 📋 Handoff Checklist (Blake必读)
- [ ] Read all sections, incl. §📚 lessons, §4.0 (every contradicted line and its resolution) and §4.3 (Phase 3 seams)
- [ ] Every §9.1 row understood; walks S1–S8 and D1–D5 planned
- [ ] Unclear → write `.tad/evidence/yolo/review-redesign/phase2-questions.md` (dispatch_id line 1) and stop

---

## 1. Task Overview

### 1.1 What We're Building
One reviewer contract file that every review, verification and acceptance dispatch loads, and one set of review rules on every path TAD has (Cora's simple / handoff / Epic tiers; direct `/alex` incl. `*express` and `*bug`; direct `/blake` Layer 2; the gate skill): Gate 2 = two reviewers with different lenses (consistency, plus a risk reviewer or fit); Gate 3 = a real-run reviewer plus a consistency reviewer (plus a domain reviewer for security/data/money); the simple tier = two light reviewers; one P1 rule, one round rule, and a Gate 3 verdict that is never signed by the builder.

### 1.2 Why
The inventory (`.tad/evidence/yolo/review-redesign/review-paths-inventory.md` §2) shows three review regimes that disagree on reviewer counts, P1 handling, round caps and who signs Gate 3. The human: "统一为cora"; G1 every entry keeps its door but follows Cora's rules; G2 "小事的审查人数：一律至少 2 人"; Cora's recommendation applied (Epic Part 3 G): Gate 3 = real-run + consistency (+ domain), simple tier = two light reviewers.

### 1.3 Intent Statement
**真正要解决的问题**: whoever starts the work, it is reviewed by two independent reviewers who look through different lenses and judge against the human's requirement, by one contract, with one rule for what blocks and when to stop and look upstream.

**不是要做的**:
- ❌ Not Gate 1 conditions or a format script, not the scripted AC re-run inside Gate 3, not Gate 4 real-run/browser acceptance, not the escape log (Phase 3; seams in §4.3)
- ❌ Not the advisory hooks (`pre-gate-check.sh`, `layer2-audit.sh`, `audit-yolo.sh`, `post-write-sync.sh`), not user docs/README/AGENTS wording (Phase 3)
- ❌ Not Lite (frozen), not principles.md, no model test runs, no release/version/provenance/brain-index regeneration, no push

### 1.4 卸载记录（Offload Log）
| 时间 | 卸载项 | 依据 | 原文指针 | 回取方式 |
|---|---|---|---|---|
| 2026-10-19 18:10 | intake Phase 1/3 sections; research §1–§3 | out of this phase except seams | `.tad/evidence/yolo/review-redesign/intake-details-3.md`, `.tad/evidence/research/review-design-pstack-bmad-tad-2026-10-19.md` | Read on demand |

### 1.5 Requirement (human's words)
See Epic `## Requirement` Part 2 (Gate 2, Gate 3, reviewer contract) and Part 3 G with G1, G2 and Cora's recommendation (authoritative). Where Part 2 says "one Gate 3 reviewer", Part 3 G supersedes it (run + consistency). Where intake-details-3 AC2.8 says the simple tier "keeps one independent reviewer", G2 supersedes it (two). Where intake put Blake direct-mode Layer 2 and the gate skill in Phase 3, G1 and this dispatch move their review rules (counts, lenses, P1, rounds, Gate 3 signer) into this phase; the rest stays in Phase 3 (§4.3).

---

## 📚 Project Knowledge（Blake 必读）

Read: `.tad/project-knowledge/principles.md`; patterns `gate-design.md`, `handoff-design.md`.

**⚠️ Blake 必须注意的历史教训**:
1. **Judgment-Only Skill Files** (SAFETY) — a retired MUST/VIOLATION is restated in its new form in the same edit, never dropped; per-file MUST/MANDATORY/VIOLATION counts must not fall (§9.1 AC8).
2. **Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count** — keep the constraint name (AR-001, "Express Handoff is NOT Review-Exemption", code-reviewer MANDATORY) in reworded lines; prove by line-set diff.
3. **Global-Count Floor Cannot Detect Must-Cover Loss** — per-constraint checks (AC6 R6b, AC10, AC11), not totals.
4. **Execution Discipline Content Must Stay in SKILL Body** — `skill-body-verify.sh` needs the Blake markers `Layer 2`, `gate3_verdict`, `hard_requirement_distinct_reviewers` and ≥70 safety keywords; keep the key names, change their content.
5. **Express Handoff is NOT Review-Exemption** (principles.md) — stays true: two reviewers ≥ one.
6. **Independence of judgment** (principles.md "Three Roles") — the builder never signs its own Gate 3; reviewers are fresh subagents; reviewers dispatch no one (subagent nesting).
7. **Syncthing ↔ git drift** — `git status` shows `MM` on files whose worktree equals HEAD; use `git diff HEAD`, commit only with `git commit -- <paths>`, never `-A`.

---

## 2. Background Context

### 2.1 Previous Work
Phase 1 (✅) installed the requirement method; the Epic's `## Requirement` is the reviewer reference (E2). Research: `review-design-pstack-bmad-tad-2026-10-19.md` §4 (contract fields, lenses, "third round = upstream"), `review-redesign-synthesis-2026-10-19.md`.

### 2.2 Current State (inventory §1–§2, re-grounded today; Cora SKILL line numbers shifted by Phase 1)
- Cora: Y4/Y6 = code-reviewer + domain expert picked by file ratio, prompts with "Focus on …" (`conductor-protocol.md:144–158, :204–217`); separate Gate 3 verifier (`:235–238`); P0 definition inline (`:39`); convergence by `new_p0` (`:165 [A108]`, `:225 [A119]`); simple tier one reviewer (`cora/SKILL.md:19, :58`).
- Direct /alex: "min 2, max 2 rounds", round-2 new issues forced to P1 (`handoff-creation-protocol.md:814–880`, `alex/SKILL.md:1159`); express ≥1 (`express-path-protocol.md:41,45`); `*bug` "skip expert review" (`bug-path-protocol.md:52,74`).
- Direct /blake: Layer 2 groups, `P0=0, P1=0, P2≤10`, max 5 rounds, task_type tiers, Blake signs Gate 3 (`blake/SKILL.md:105–121, :930–985, :1340–1402, :1618–1645, :2097–2117`).
- Gate skill / canonical: Gate 2 "min 2" (`gate/SKILL.md:86`, canonical `:26`); Gate 3 "Owner: Agent B (Blake)" (`gate/SKILL.md:112`, canonical `:38`); marker "Blake writes it" (`gate/SKILL.md:386–392`); Gate 4 "all P0/P1 addressed" (`:745, :774`, canonical `:77`, `alex/SKILL.md:1577`, `config-quality.yaml:226`).

### 2.3 Dependencies
Phase 1 (`## Requirement` exists). Phase 3 builds on this phase's contract, lenses, `real_paths`/`risk_triggers` and Gate 3 reviewers.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1 CREATE `.tad/templates/review-contract.md` with the content of §4.2.1 (header + self-consistency, finding fields, P0 definition moved verbatim with the AR-001 sentence, empty review allowed / no minimum, reference = `## Requirement` + Result contract + handoff, lenses, real run, rounds and blocking, who reviews what, harness mapping, cross-model off by default; no ad-hoc questions from the dispatcher).
- FR2 Cora path: verdict_header and P0 definition become pointers to the contract; evidence names per lens; Y4 = Gate 2 two lenses; Y6 = Gate 3 run + consistency (+ domain); the separate Gate 3 verifier in Y7 is retired; round-3 upstream rule merged with the `new_p0` trigger; simple tier two light reviewers; depth names (§4.2.2–4.2.3).
- FR3 Direct /alex: handoff creation Gate 2 = contract; `real_paths` and `risk_triggers` required in the frontmatter; express, `*bug`, experiment paths aligned; Alex SKILL Gate 2 lines (§4.2.4–4.2.6).
- FR4 Direct /blake Layer 2 = the contract's Gate 3 reviewers; Gate 3 verdict written by the run reviewer, never Blake; one P1 rule; round-3 escalation replaces "max 5 rounds" and "same category 3×" (§4.2.7).
- FR5 Gate skill + canonical checklist + config-quality: Gate 2 review item, Gate 3 owner and marker writer, the Gate 4 P0/P1 line (P1 handling only) (§4.2.8).
- FR6 Templates: handoff (`risk_triggers`, `real_paths`, §9.1 note, §9.2 lens rows), completion report Layer 2 rows (§4.2.9).

### 3.2 Non-Functional Requirements
- NFR1 Every `[A###]` tag of Cora SKILL and conductor-protocol survives; [A105][A132][A116][A106][A117][A107][A118][A108][A119] sit on the lines that now carry their (changed) constraints (AC6).
- NFR2 No weakening (AC8): stop list, [A060][A078][A081][A086], AR-001, "Express Handoff is NOT Review-Exemption", per-file safety keyword counts, the byte-exact anti-rationalization registry, `skill-body-verify.sh` green.
- NFR3 Harness-neutral: reviewer types are Claude Code examples only; reviewers never dispatch subagents.
- NFR4 Cora still never reads a handoff's content (`cora/SKILL.md` "What Cora never does"): lens choice that depends on the handoff is made by a reviewer and reported in its header (§4.1).

---

## 4. Technical Design

### 4.0 Unchanged lines the change contradicts — and their resolution
Listed before writing. "Edit" = Blake changes it in this phase (tags stay on the line); "Stays" = still true; "Phase 3" = left with its seam (§4.3).

| # | File:line (today) | Says | Contradicts | Resolution |
|---|---|---|---|---|
| K1 | conductor-protocol.md:28–40 verdict_header | header keys and P0 definition inline | one source (contract) | Edit: pointer block (§4.2.2); P0 text only in the contract; [A107][A118][A081] on the pointer line |
| K2 | conductor-protocol.md:55–68 evidence_structure | `design-review-cr`, `-{domain}`, `impl-review-cr`, `-{domain}`, `gate3-verdict` (verifier) | per-lens files | Edit (§4.2.2) |
| K3 | conductor-protocol.md:144–169 step_Y4 | "≥2 distinct reviewer types", code-reviewer + domain by file ratio, "Focus on", convergence by `new_p0` only | Gate 2 lenses; prompt = contract; round-3 rule | Edit (§4.2.2) |
| K4 | conductor-protocol.md:204–229 step_Y6 | two implementation reviewers | Gate 3 = run + consistency (+ domain) | Edit (§4.2.2) |
| K5 | conductor-protocol.md:231–261 step_Y7 | separate Gate 3 verifier; Gate 4 reads "implementation reviews" | verifier replaced by Y6 run reviewer | Edit: Y7 = Gate 4 only + a pointer line for Gate 3 (§4.2.2) |
| K6 | conductor-protocol.md:12, :14, :15 | review only from Cora's own dispatch; Blake subagent Layer 1 only; Cora writes no verdict | — | Stays (Y6 is Layer 2 in a run) |
| K7 | conductor-protocol.md:302 workflow_path `reviewer_count` | optional arg of the not-enabled Workflow | — | Stays (contract preserved as-is, Workflow not enabled) |
| K8 | conductor-protocol.md:310 [A019] | "must_call scenario → matching reviewer type" | lenses | Edit: "… dispatches the matching reviewer lens (review contract) [A019]" |
| K9 | cora/SKILL.md:19, :22, :23, :45, :58, :63, :68 | simple tier one reviewer; estimate "at most four"; depth `standard` "two distinct types … Gate 3"; "at least two distinct reviewer types … exception the simple tier's one reviewer"; header "defined in the conductor protocol"; Route convergence | G2, lenses, contract, round-3 | Edit (§4.2.3); "Express Handoff is NOT Review-Exemption" phrase kept on :58 |
| K10 | cora/SKILL.md:83 | Cora does not read a handoff's content | lens choice needs `risk_triggers` | Stays: the risk reviewer copies `risk_triggers` into its header; Cora reads headers only (§4.1) |
| K11 | conductor-dispatch-mode.md:22 Design fix | no class-fix rule | contract §3 `introduced_by_fix` | Edit (§4.2.4) |
| K12 | handoff-creation-protocol.md:47, :272–279 step1b, :534–543 step2/3, :545–613 step3_agent_team, :729–812 expert_selection_rules + expert_prompt_template, :814–880 minimum/rounds/p0_resolved/violations | min 2 experts by subagent type; max 2 rounds; round-2 new findings forced to P1; agent-team cross-challenge "Could it be downgraded?"; narrow-scope prompt with Model first line | lenses, contract prompt, round-3 rule, AR-001 | Edit (§4.2.5); agent-team mode retired (its downgrade challenge contradicts AR-001); Model line → header `model:` key |
| K13 | express-path-protocol.md:6, :41, :42, :45, :94–97 | "≥1 review", "≥1 expert", "Layer 2 ≥1 expert", "legitimately keeps only ≥1 code-reviewer" | two lenses everywhere | Edit (§4.2.6); AR-001 guarantee tokens "expert review" + "code-reviewer" kept within the first 45 lines |
| K14 | bug-path-protocol.md:46–76 | "skip expert review"; Blake "Layer 1 → verify AC → done" | G1, contract §8 | Edit (§4.2.6) |
| K15 | experiment-path-protocol.md:55 | "recommend security-auditor SKIP" | security lens by `risk_triggers` | Edit (§4.2.6) |
| K16 | alex/SKILL.md:1159, :1466, :1500, :1539, :1577 | "min 2, max 2 rounds"; "min 2 experts"; "2+ experts"; "all P0/P1 addressed" | lenses, round-3, P1 carried | Edit (§4.2.6) |
| K17 | alex/SKILL.md:1621, :1639 (anti_rationalization_registry, byte-exact) | express "min 1 expert"; spike "≥2 experts" | — | Stays: floors still true (2 ≥ 1; 2 ≥ 2); registry untouched (AC8 R8c) |
| K18 | alex/SKILL.md:1163–1168 gate4_v2 "Quality evidence"; acceptance-protocol.md:46–100 step4c tier mapping | Gate 4 evidence types; task_type tiers for layer2-audit | — | Phase 3 (Gate 4 + hook; interim advisory WARN may be false; §4.3) |
| K19 | blake/SKILL.md:79–87, :105–121, :419, :931–985, :1033–1047, :1220–1226, :1331–1338, :1340–1402, :1404–1445, :1618–1645, :1770, :2034–2047, :2059, :2078, :2097–2117 | Layer 2 groups, P1=0, P2≤10, max 5 rounds, tiers, express exception, narrow-scope + Model first line, Blake signs Gate 3 | contract | Edit (§4.2.7); keys `hard_requirement_distinct_reviewers`, `Layer 2`, `gate3_verdict` kept |
| K20 | gate/SKILL.md:57, :86, :112, :386–392, :745, :774 | Gate 3 "Agent B"; "min 2"; "Owner: Agent B (Blake)"; "Blake writes it"; "all P0/P1 addressed" | contract | Edit (§4.2.8) |
| K21 | gate/SKILL.md:58, :579–840 (Gate 4 owner, Structural_Subagent_Conditionality, Required_Subagents, Quality evidence) | security/performance/code-reviewer required at Gate 4 for code/mixed | — | Phase 3 (Gate 4; not a Gate 2/3 reviewer rule) |
| K22 | gate/SKILL.md:63–76, canonical :8–19 Gate 1 | Socratic items | — | Phase 3 |
| K23 | canonical :26, :38, :77 | "min 2"; "Owner: Blake"; "P0/P1 已处理" | contract | Edit first (SSOT), then gate skill (§4.2.8) |
| K24 | config-quality.yaml:74, :226; :9–37 must_call | "min 2 experts"; "all P0/P1 addressed"; legacy must_call (product-expert, backend-architect for design help; code-reviewer for quality review) | contract | Edit :74, :226; must_call stays (design consults, not review composition; code-reviewer = consistency on Claude Code) + one comment line pointing to the contract |
| K25 | handoff-a-to-b.md frontmatter, :555 "spec-compliance-reviewer 自动核对", §9.2 rows | no routing keys; reviewer type rows | contract | Edit (§4.2.9) |
| K26 | completion-report.md:33–41 | Layer 2 rows `P0=0, P1=0`, coverage, security/performance | contract | Edit rows only; run evidence + not-run list are Phase 3 |
| K27 | hooks: pre-gate-check.sh Check 10/11, layer2-audit.sh (KNOWN_REVIEWERS, express PASS at 1), audit-yolo.sh (`-cr`, `-{domain}` names; already stale: looks for `COMPLETION-*` while runs write `phase{N}-completion.md`), post-write-sync.sh:150 comment | old names/counts | contract | Phase 3 (advisory, exit codes unchanged; §4.3) |
| K28 | docs/, README.md, AGENTS.md, tad/SKILL.md, patterns/process-tax-cut.md "min 2" wording | old wording | contract | Phase 3 sweep (intake AC3.6) |

### 4.1 Architecture Overview
- One file, `.tad/templates/review-contract.md`, holds everything a reviewer needs (Part A: header, finding, P0, reference, lenses, real run) and everything a dispatcher needs to compose a review (Part B: rounds and blocking, who reviews what, harness mapping). Cora's protocol keeps only her mechanics (ids, pointer, spike, premise, re-plan) and points to the contract.
- **Lens choice without Cora reading the handoff** (NFR4, AGENTS.md "Reading HANDOFF-* requires Blake plus Gate 3/4"): Gate 2 always has exactly two reviewers — `consistency` and a second reviewer that reads the handoff's `risk_triggers` and applies every listed lens in one file (`lens: risk`), or `fit` when the list is `[none]` (`lens: fit`). Every review file that reads a handoff copies its `risk_triggers` into the header. Cora decides Gate 3's domain reviewer from the `risk_triggers:` header key of the phase's latest design review file. Design decision (intake left "one per class or one for the highest" to the designer): **one risk reviewer covering every listed trigger**, one section per lens — the only choice that lets Cora compose the review from headers, keeps Gate 2 at two dispatches for the Budget, and needs no handoff read.
- **Gate 3 in a run**: step_Y6 becomes Gate 3 (run reviewer writes `phase{N}-gate3-verdict.md`; consistency writes `phase{N}-impl-review-consistency.md`; domain `phase{N}-impl-review-domain.md`). Y7 keeps Gate 4 only. Direct /blake: Blake dispatches the same three; the run reviewer writes `.tad/evidence/reviews/blake/<slug>/gate3-verdict.md` and the `gate3_verdict:` marker. The builder signs nothing.
- **Rounds**: round 1 all lenses of the stage; round k ≥ 2 only lenses with an open P0/FAIL/PARTIAL (Gate 3: the run lens re-runs after every rework); a third review round (counted from round 1 or the last re-plan) with an open P0 → upstream (Cora: the existing Y4 5c / Y6 4c premise re-plan; direct /alex: premise + one re-plan, then the human; direct /blake: escalate to Alex). Merge with [A108]/[A119]: the former trigger (two consecutive re-review rounds with `new_p0` > 0) can only fire at round 3 or later and implies an open P0 at round 3, so the new trigger contains it; `new_p0` stays in every review header for the record (S3).
- **Blocking**: only P0, FAIL or PARTIAL; a P1 is carried (CONDITIONAL; path into the next dispatch; listed in the completion report / handoff §10; Gate 4 lists open P1s). No P1/P2 caps.
- **Simple tier and `*bug`**: no Gate 2 (no design choice); Gate 3's run + consistency as "two light reviewers"; domain when security/data/money is listed on the journal line / mini-handoff.

### 4.2 Component Specifications

#### 4.2.1 CREATE `.tad/templates/review-contract.md`
Write this content (wording may be polished; every token in R1 must stay; §3 sentence verbatim):

````markdown
# Review contract
Loaded by every review, verification and acceptance dispatch in TAD: Gate 2 design reviewers, Gate 3 reviewers (Cora's runs, the simple tier, direct /blake Layer 2, *express and *bug), the rubric judge and the Gate 4 acceptor. Part A is for the reviewer; Part B is for whoever dispatches (Cora, Alex, Blake).

## Part A — for the reviewer

### 0. The prompt
A dispatch prompt names only: the lens; the object (a path, or `commit:<sha>` / a commit range); the reference; the same lens's previous-round file (or none); a spike or premise file (or none); the output path; the `dispatch_id`. The dispatcher adds no ad-hoc questions or focus lines: anything a reviewer should look at is written in the Epic or the handoff, where the reviewer reads it.

### 1. Verdict header
Every review, verdict and gate file starts with:
```
---
dispatch_id: <id>
verdict: PASS | CONDITIONAL | FAIL | PARTIAL
p0_count: <number>
judged: <path of the file judged, or commit:<sha> for code>
lens: consistency | risk | fit | run | domain | judge | acceptor
risk_triggers: <the handoff's list, copied from its frontmatter; every review file that reads a handoff>
new_p0: <number>   (review files only, not gate or acceptor files. Round 1: equal to p0_count. Round k ≥ 2: the P0s not already in the same lens's round k-1 file. A review file of round k ≥ 2 without it reads as new_p0 = p0_count.)
empirical_p0: <number>   (review files only, ≤ p0_count; absent reads 0: how many of the P0s a run or measurement settles)
model: harness=<…> | model=<self-reported id> | route=<host|native|unknown>   (direct /alex and /blake reviews; missing = provenance-incomplete, never blocking)
---
```
Self-consistency rule (the writer checks it before saving; the dispatcher checks it on reading):
- PASS or CONDITIONAL ⇒ `p0_count: 0`.
- FAIL ⇒ `p0_count` ≥ 1 (a fail names what it blocks).
- PARTIAL ⇒ a `## Blocked` section says what could not be judged and why.
- `empirical_p0` ≤ `p0_count`; `new_p0` ≤ `p0_count`.
- `lens: fit` ⇒ PASS or CONDITIONAL.
A file whose header breaks a rule counts as not returned: the dispatcher re-dispatches that writer once (same round), then stops (Cora: reason 1; direct /alex or /blake: tells the human). Nobody reads the body to reinterpret a header.
CONDITIONAL: no P0, with findings the next step must carry; routed like PASS, and the file's path goes into the next dispatch prompt.

### 2. A finding
Each P0 and P1 carries:
- `location`: file:line, or the command
- `scenario`: input or situation -> wrong result
- `blocks`: what it blocks (§3)
- `checked`: the lines read or the command run, with its result; a P0 without `checked` is not a P0
- `kind: empirical | design`
- `origin: introduced_by_fix | missed_earlier | preexisting` (required from round 2; in round 1 only `preexisting` is marked: the defect was there before the change)
Read the object and the reference first and form your own judgment; read the author's own account (completion report, handoff rationale) after.
Empty review allowed: "no P0, no P1" is a valid result. There is no minimum number of findings; do not pad.

### 3. What a P0 is
For every file with `p0_count`, a P0 states (a) a concrete failure scenario (input or situation -> wrong result) and (b) what it blocks: a Result-contract deliverable, an AC, a SAFETY principle, a stop-list rule or a security constraint (simple tier: the verification on the journal line, or the plan item it breaks). A defect touching credentials, destructive commands, the stop list or a SAFETY principle is a P0 with (a) alone. Review files add (c) the label `empirical` (a run or measurement settles it) or `design`; a P0 that a spike file named in the reviewer's prompt already tested is labelled `design`. A finding the reviewer cannot write (a) and (b) for goes in its own file section as a P1; a file with no other P0 is then at most CONDITIONAL. This defines a P0; it is not a licence to discount one: a finding that meets it is a P0, and "this P0 is not important" stays a VIOLATION (AR-001). The writer applies it in its own file; no dispatcher reclassifies a finding.
A P0 with `origin: introduced_by_fix` is fixed as a class: the next fix covers every place the earlier fix made the same change.

### 4. The reference
Judge against the Epic's `## Requirement` and `## Result contract` plus the handoff (Epic and handoff tiers); the handoff's §1.5 Requirement and §9 (direct /alex without an Epic); the journal line (simple tier: request, blocks, verification, `risk_triggers`). A finding that the change departs from the requirement names the requirement line.

### 5. Lenses
`risk_triggers` closed list: security | data | money | ui | platform | domain, or none.
- **consistency** (Gate 2 and Gate 3; always): contradictions between the change and unchanged rules, code and other files, and every consumer of a changed line (grep). At Gate 2 it runs every §9.1 acceptance command on the baseline, before the change, and records that each post-implementation command fails there for the right reason (one that already passes is a vacuous AC). It checks the handoff's `risk_triggers` against the change: a missing or wrong trigger is a finding.
- **risk** (Gate 2, when `risk_triggers` lists any): one reviewer applies every listed lens, one section each — security: auth, secrets and credentials, permissions, untrusted input, hook and sandbox trust; data: user or project data written, migrated, synced or deleted (installers and sync included); money: payments, paid API or model calls, billing; ui: what a person sees or clicks; platform: install, OS, shell and harness differences; domain: correctness of a field rule outside code.
- **fit** (Gate 2, only when `risk_triggers: [none]`): is this what the requirement asks (list the readings of the Result contract and which one the handoff builds), is the size proportionate, does the premise hold. It yields questions or P1, never P0: a question that would change the result or scope is written to the phase questions file as class 2 (Cora's run) or, in direct /alex, goes to the human through Alex; anything else is a P1.
- **run** (Gate 3; always; writes the Gate 3 verdict file): runs every §9.1 Verification Method and every `real_path` (simple tier: the verification on the journal line) as a real run (§6), one row each: command, output, result; checks the Gate 3 rows that need no design judgment (completion report present, Knowledge Assessment present, commit recorded); writes the completion report's `gate3_verdict:` marker. A rubric row is decided by the judge's file named in the prompt.
- **domain** (Gate 3, only when `risk_triggers` lists security, data or money): one reviewer applies those lenses to the built change and runs what it needs.
- **judge** (rubric ACs): the gate skill's Rubric Evaluation Protocol. **acceptor** (Gate 4): the gate skill and the acceptance protocol.

### 6. A real run
- One real use of each path: the install, build, command or call a user makes. Never a batch, a loop or a measurement.
- In a scratch or temp location; never change the work under review.
- Protocol or prompt text: walk a named scenario through the changed text, quoting file:line at each step, and say where it ends.
- `not-run: <reason>` under `## Not run` for a path whose run is paid, touches production or makes an outward post or push, needs the human's own account or a real device, or needs a capability this harness does not have. It is a recorded item, never a silent skip and never a PASS for that path; it goes to Gate 4 and to the human. Anything paid is asked first (Cora: stop reason 3).
- Friction (a missing tool or dependency that could be installed, an approval) is not `not-run`: ask for the fix; unresolved, the file is PARTIAL with the item under `## Blocked` (BLOCKED never routes as PASS).

## Part B — for the dispatcher

### 7. Rounds and blocking
- Only a P0, a FAIL or a PARTIAL blocks. A P1 is carried: the file is CONDITIONAL, its path goes into the next dispatch, the completion report (or handoff §10) lists it, and Gate 4 lists open P1s to the human. No cap on P1 or P2 counts.
- Round 1: every lens of the stage. Round k ≥ 2: only the lens(es) whose round k-1 file had a P0, FAIL or PARTIAL, given the fix diff, the open P0 list with full reasons and every section or file the fix touches; at Gate 3 the run lens also re-runs in every round after a rework (its verdict must judge the final commit). Each reviewer judges the current version first, then labels `new_p0` and `origin` from its own lens's previous file.
- Round 3, counted from round 1 or from the last re-plan, still has an open P0: stop reviewing and look upstream. Cora: the root-cause re-plan with the premise file (conductor protocol step_Y4 5c / step_Y6 4c). Direct /alex: Alex writes the premise (one sentence the failed fixes share, one observation that differs if it is false), checks it by a read, grep or local command and re-plans the handoff once; a second time, or a re-plan that would change the result or scope, goes to the human (narrow the scope, change the approach, withdraw) — there is no "accept the risk and continue". Direct /blake: Blake stops and escalates to Alex with the review files. There is no round 4 without a re-plan.
- A round count alone never stops a Cora run (her runaway guard is twice the Budget estimate).

### 8. Who reviews what
| Stage | Reviewers (fresh subagents; none is the builder) | Files |
|---|---|---|
| Gate 2 — a handoff was written (Cora handoff and Epic phases, /alex *handoff, *express, spike, *experiment) | consistency + risk (every listed trigger), or fit when `none` | design-review-consistency, design-review-risk or design-review-fit |
| Gate 3 — the change was built (every path) | run + consistency, + domain when security, data or money is listed | gate3-verdict (run), impl-review-consistency, impl-review-domain |
| Simple tier, *bug mini-handoff | no Gate 2 (no design choice: the change is named by the request or the diagnosis); Gate 3 as above ("two light reviewers": same lenses, small object) | as the path names them |
| Gate 4 | the acceptor | gate report |
Never two reviewers with the same lens; a self-review never counts. Two reviewers is the floor everywhere (principle "Express Handoff is NOT Review-Exemption": at least one independent reviewer).
Paths: Cora's runs `.tad/evidence/yolo/{epic-slug}/phase{N}-<file>.md`; simple tier `.tad/evidence/simple/{YYYY-MM-DD}-{slug}-review-<lens>.md`; direct /alex `.tad/evidence/reviews/alex/<slug>/design-review-<lens>.md`; direct /blake `.tad/evidence/reviews/blake/<slug>/gate3-verdict.md`, `consistency-review.md`, `domain-review.md`. Round k ≥ 2 adds `-r<k>` before `.md`; no verdict file is overwritten.
Who dispatches: Cora in her runs; Alex for Gate 2 in direct /alex; Blake for Gate 3 (Layer 2) in direct /blake; a rubric judge is dispatched by the same party before the run reviewer. Reviewers dispatch no one.

### 9. Harness mapping and cross-model
Claude Code examples: consistency → code-reviewer; run → general-purpose (test-runner for a test suite); risk and domain → security-auditor (security), database-expert or backend-architect (data, money), ux-expert-reviewer (ui), devops-engineer (platform), product-expert or general-purpose (domain, fit). Other harnesses: any fresh subagent given the lens.
Cross-model is an optional slot, off by default: a lens may be held by another model family only on the human's confirmation, under the existing cross-model rules (conductor protocol, NOT_via_alex_auto).
````

#### 4.2.2 MODIFY `.agents/skills/cora/references/conductor-protocol.md`
- **verdict_header** (:28–40) → replace with:
  `Every review, verdict and gate file starts with the verdict header of .tad/templates/review-contract.md §1 (keys and self-consistency rule). Each reviewer, verifier and acceptor prompt says: "start your file with the verdict header".` / `Cora routes on this header only, and on the spike and premise headers below. A file with no header, a header that breaks the contract's self-consistency rule, or a missing file, means the step did not return.` / `What a P0 is, including AR-001 ("this P0 is not important" = VIOLATION), is defined once in .tad/templates/review-contract.md §3; the writer applies it in its own file; Cora never reclassifies [A107][A118][A081].` / keep the CONDITIONAL line. (AC2: the P0 definition text lives only in the contract.)
- **dispatch_id_rule** :47 spike file: "one entry per P0 labelled `empirical` in each review file of the round" — Stays.
- **evidence_structure** per_phase_files → `phase{N}-grounding.md`; `phase{N}-design-review-consistency.md`; `phase{N}-design-review-risk.md` or `phase{N}-design-review-fit.md`; `phase{N}-gate3-verdict.md (Gate 3 run reviewer)`; `phase{N}-impl-review-consistency.md`; `phase{N}-impl-review-domain.md (only when security, data or money is listed)`; `phase{N}-gate-report.md`; premise/spike/questions unchanged. review_rounds example → `phase{N}-impl-review-consistency-r2.md`.
- **step_Y4**: name `"Design Review — Gate 2 (Cora dispatches two reviewers with different lenses, middle tier)"`. Keep the harness Note. Rule line (tags here): `Gate 2 = two reviewers with different lenses: consistency plus one risk reviewer covering the handoff's risk_triggers, or fit when they are none (review contract §5, §8); never two of the same lens [A105][A132].`
  1. ids `p{N}-y4-r<k>-consistency` and `p{N}-y4-r<k>-risk` (the second reviewer writes `…-design-review-risk.md`, or `…-design-review-fit.md` when it finds `risk_triggers: [none]`: the pointer names both possible paths for that id, and the file whose `dispatch_id` matches is its result).
  2. `Dispatch the consistency reviewer (MANDATORY; code-reviewer on Claude Code) [A106]:` prompt first line exactly begins `prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION) [A107]. Lens: consistency.` then `Object: {handoff_path}. Reference: {epic_path} ## Requirement and ## Result contract, and the handoff. Previous round: {same lens's file or none}. Spike/premise: {file or none}. Write .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-consistency.md. Put dispatch_id: {id} in your file's first lines and start your file with the verdict header."`
  3. `Dispatch the risk-or-fit reviewer:` prompt begins `prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 [A107]. Lens: risk for every entry of the handoff's risk_triggers, or fit when they are none.` … output `phase{N}-design-review-risk.md` (or `-fit.md`) … same tail.
  4. Read both headers from disk [A109][A131]. A file with `lens: fit` that wrote the phase questions file (line 1 = its id): class 2 → stop (reason 2); class `design` → named in the next design-fix prompt.
  5. "If ANY P0, FAIL or PARTIAL across the files": 5.0 spike — unchanged text; 5a design fix — add: "a P0 with origin introduced_by_fix is fixed as a class (review contract §3)"; 5b next round — "only the lens(es) whose file had a P0, FAIL or PARTIAL are re-dispatched, with ids `p{N}-y4-r<k>-<lens>`, on the fix diff, the open P0 list and the sections the fix touches (review contract §7)"; the rest of 5b (resume/ids/retries `-t<m>`/previous file for `new_p0`) unchanged with lens ids.
  5c. Replace the trigger sentence, keep everything else of 5c (premise file, spike_needed, class 2, counts, budget, "No stop by review-round count …"): `Convergence, then upstream [A108]: while the reviews converge, the next round is another design fix on the same handoff. When review round 3, counted from round 1 or from the last re-plan, still has an open P0 in any file, the fault is above the patches (this contains the former trigger, two consecutive re-review rounds with new_p0 above 0, which cannot fire earlier): write the pointer, then dispatch an Alex subagent …` (rest verbatim). `new_p0` stays in every review header.
  output: `"2 review files on disk (consistency + risk or fit) + HANDOFF.md (v2 if fixed)"`.
- **step_Y6**: name `"Gate 3 review (Cora dispatches the run and consistency reviewers, plus domain when listed; middle tier)"`. Rule line (tags here): `Gate 3 = run plus consistency, plus one domain reviewer when the risk_triggers header key of the phase's latest design review file lists security, data or money (review contract §5, §8); they replace the two implementation reviewers and the separate verifier; never two of the same lens [A116][A132].`
  1. ids `p{N}-y6-r<k>-run`, `p{N}-y6-r<k>-consistency` (`p{N}-y6-r<k>-domain`), paths per evidence_structure. A rubric AC: the judge first (gate skill Rubric Evaluation Protocol), its file named in the run prompt.
  2. `Dispatch the run reviewer (MANDATORY; it writes the Gate 3 verdict):` prompt begins `prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION) [A118]. Lens: run.` then `Object: the commits listed in {completion_path}. Reference: {epic_path} ## Requirement and ## Result contract, and {handoff_path} (§9.1 and real_paths). Previous round: … Write .tad/evidence/yolo/{epic-slug}/phase{N}-gate3-verdict.md and set the completion report's gate3_verdict marker. …tail"`.
  3. `Dispatch the consistency reviewer (MANDATORY; code-reviewer on Claude Code) [A117]:` prompt begins `prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 [A118]. Lens: consistency.` … output `phase{N}-impl-review-consistency.md`.
  3b. When listed: `prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001. Lens: domain (the security, data or money entries of the handoff's risk_triggers).` … output `phase{N}-impl-review-domain.md`.
  4. "If ANY P0, FAIL or PARTIAL": a PARTIAL whose `## Blocked` names friction a rework cannot fix (a dependency to install, an approval) is a stop (reason 1), reported as it is; otherwise as now. 4.0 spike unchanged; 4a rework prompt reads "the review files named" (not `impl-review-cr.md`) and adds the class-fix sentence; 4b lens ids, only lenses with an open P0/FAIL/PARTIAL plus the run lens after every rework, retries `p{N}-y6-r<k>-<lens>-t<m>`; 4c trigger sentence as Y4 5c with `[A119]` and "round 3", rest verbatim.
  5. [A120] unchanged. output: `"Gate 3 review files on disk: phase{N}-gate3-verdict.md (run), phase{N}-impl-review-consistency.md (+ phase{N}-impl-review-domain.md)"`.
- **step_Y7**: name `"Gate 4 (one independent dispatch; Cora writes no verdict)"`. Step 0 "state after Y6" stays. Step 1 → `Gate 3 was settled in step_Y6: the run reviewer's phase{N}-gate3-verdict.md (latest round) with the consistency (and domain) files; Cora dispatches no separate verifier.` Step 2 Gate 4 prompt: replace "the design and implementation reviews, and phase{N}-gate3-verdict.md" with "the design review files and the Gate 3 review files (phase{N}-gate3-verdict*.md, phase{N}-impl-review-*.md)"; every other sentence of the Gate 4 prompt unchanged ([A095][A007][A088][A005][A037][A089]). Step 3 "Cora reads the gate report header". Step 5 "Gate 4 PASS (or CONDITIONAL with no P0)". Step 6 unchanged. output: `"phase{N}-gate-report.md on disk"`.
- Rules :310 [A019]: `A must_call scenario means Cora dispatches the matching reviewer lens (review contract) [A019].`

#### 4.2.3 MODIFY `.agents/skills/cora/SKILL.md`
- :19 Simple: "one reviewer (middle tier) that did not do the work writes a verdict file with the verdict header" → `two reviewers (middle tier) that did not do the work, lenses run and consistency, each load .tad/templates/review-contract.md and write a verdict file with the verdict header ("two light reviewers"); a domain reviewer is added when the journal line's risk_triggers lists security, data or money`. Journal line gains `risk_triggers:` (closed list of the contract). Reviewer prompts: "step_Y6's run and consistency prompts (and domain) with that journal file as object and reference; outputs `…-review-run.md`, `…-review-consistency.md` (`…-review-domain.md`; re-review `-r2`)". "P0 or FAIL: one Blake rework and one fresh review" → `P0, FAIL or PARTIAL: one Blake rework and a fresh review by the lens(es) with the P0 plus the run lens`; the rest (retriage as handoff, reason 2) unchanged.
- :22 estimate "for the simple tier at most four: Blake, review, one rework, one re-review" → `for the simple tier at most six (eight with a domain reviewer): Blake, the reviewers, one rework, one re-review`.
- :45 depths: `simple`: `Blake plus two light reviewers (run and consistency), simple tier only`; `standard`: `design, Gate 2 with two reviewers of different lenses (consistency plus risk or fit), implementation, Gate 3 with run and consistency reviewers (plus domain for security, data or money), Gate 4, distillation`; `extended` unchanged ("a third reviewer type" → "an extra lens").
- :58 → `She dispatches reviewers and acceptor herself, never through another subagent; every review has at least two reviewers with different lenses, the simple tier included (review contract §8), above the floor of principle "Express Handoff is NOT Review-Exemption" (at least one independent reviewer).`
- :63 "(… defined in the conductor protocol)" → "(defined in the review contract)".
- :68 Route: "No P0 and not FAIL" → `No P0, not FAIL and not PARTIAL (a P1 is carried: CONDITIONAL)`; "P0 or FAIL on a review" → "P0, FAIL or PARTIAL on a review"; replace "From round 2 each reviewer writes `new_p0` … two consecutive re-review rounds … above 0 in at least one reviewer's file" with `From round 2 only the lens(es) with an open P0, FAIL or PARTIAL are re-dispatched (at Gate 3 also the run lens after a rework), each writing new_p0 and an origin per P0; an introduced_by_fix P0 is fixed as a class. When review round 3, counted from round 1 or from the last re-plan, still has an open P0, the fault is above the patches:` (rest of the bullet verbatim: re-plan, class 2, "After a re-plan the count starts again", "A review-round count is never a stop by itself", guard, spike/premise).

#### 4.2.4 MODIFY `.agents/skills/alex/references/conductor-dispatch-mode.md`
- Design fix (:22): append `A P0 with origin introduced_by_fix is fixed as a class (review contract §3): fix every place the earlier fix made the same change, and say so in §1.`
- Design (:21): append `Fill risk_triggers and real_paths in the frontmatter (handoff template).`

#### 4.2.5 MODIFY `.agents/skills/alex/references/handoff-creation-protocol.md`
- :47 → `- review composition: .tad/templates/review-contract.md §8 (Gate 2: consistency + risk or fit; two reviewers)`.
- step1b validation add: `risk_triggers: "list from the closed set security | data | money | ui | platform | domain, or [none]"`; `real_paths: "≥1 entry {id, path, run} or {id, path, not-run: <reason>}; protocol text: a named scenario walk"`; violation line unchanged.
- step2 → name "Gate 2 reviewers", rule `"Two reviewers with different lenses per the review contract: consistency (MANDATORY; code-reviewer on Claude Code) plus one risk reviewer covering risk_triggers, or fit when none"`. step3 → "dispatch both in parallel; each prompt = the contract's §0 list; outputs under `.tad/evidence/reviews/alex/<slug>/`".
- step3_agent_team (:545–613): replace the block with one comment line `# Agent Teams review mode retired 2026-10-19 (EPIC-20261019-review-redesign): its cross-challenge asked reviewers whether a P0 "could be downgraded", against AR-001; Gate 2 composition is the review contract's.`
- expert_selection_rules (:729–757) → `lens_selection:` consistency always; risk lenses from `risk_triggers`; fit when none; the contract §9 mapping as Claude Code examples.
- expert_prompt_template (:759–812) → `reviewer_prompt: "Load .tad/templates/review-contract.md and follow it. Lens: {lens}. Object: {handoff_path}. Reference: the handoff's §1.5 and §9 (or the Epic's ## Requirement and ## Result contract). Previous round: {file|none}. Write {path}; start with the verdict header (model: key included)."` The narrow-scope rule is replaced by contract §2 ("read the object and the reference first") — consistency needs the consumers of changed lines.
- :814–880 → `minimum_reviewers: 2  # two different lenses; never below one independent reviewer (AR-001)`; `rounds:` = contract §7 restated for direct /alex (round 1 both lenses; round ≥ 2 only lenses with an open P0, fix diff + open P0 list with full reasons + full text of touched sections, never the whole handoff; round 3 with an open P0 → premise + one re-plan; a second time or a scope/result change → the human: narrow / change approach / withdraw; no "accept the risk and continue"); `p0_resolved_definition:` Gate 2 "P0 resolved" = the latest round's file of every lens is PASS or CONDITIONAL (`p0_count: 0`); Alex's own "fixed" is not resolved; open P1s go to handoff §10 as known trade-offs (carried). `violations:` keep four, reworded: no handoff to Blake without the two Gate 2 lenses = VIOLATION; ignoring a P0 = VIOLATION; a 4th review round with an open P0 and no premise re-plan = VIOLATION (whatever the human says); a FAIL handoff to Blake, or re-sending the whole handoff from round 2 = VIOLATION; plus `offering "accept the risk and continue" = VIOLATION`.

#### 4.2.6 MODIFY Alex express / bug / experiment / SKILL
- express-path-protocol.md :6 → `"… Skips ceremony, keeps both review lenses."`; :41 → `"step2 expert review per .tad/templates/review-contract.md: consistency (code-reviewer 必选 on Claude Code) + risk or fit — two reviewers, never fewer than one (AR-001)"`; :42 "记录 ≥1 review" → "记录两个 review 的可审计证据"; :45 → `"Gate 3 (Blake side: Layer 1, then the Gate 3 reviewers run + consistency per the review contract)"`; :94–97 rationale: drop "even though *express legitimately keeps only ≥1 code-reviewer" (keep the false-WARN history sentence).
- bug-path-protocol.md step4 template: add a YAML frontmatter block before the title with `express: true`, `task_type: code`, `risk_triggers: [none]` (Alex fills), `real_paths:` (the repro command); `**Type:**` → `Express Bugfix (requirement playback confirmed; no Gate 2 — the fix is named by the diagnosis; Gate 3 reviewers per .tad/templates/review-contract.md)`; Blake Instructions → `Apply fix → Layer 1 → commit → Gate 3 reviewers run + consistency (+ domain if security/data/money) per the review contract → done`; :74 "no expert review" sentence removed (replaced by the line above).
- experiment-path-protocol.md :55 → `"step2 Gate 2 review per the review contract (consistency + risk or fit); security only when risk_triggers lists it; add product-expert as the domain lens IF stakeholder validation matters"`.
- alex/SKILL.md :1159 → `items: "Gate 2 review — two lenses per .tad/templates/review-contract.md (round 3 with an open P0 → premise) + P0 resolved (见 handoff-creation-protocol.md p0_resolved_definition) + Architecture/Components/Functions/DataFlow"`; :1466 → "Sending handoff to Blake without the two Gate 2 review lenses"; :1500 → "ALWAYS run the two Gate 2 review lenses on handoff drafts (review contract)"; :1539 → "**Gate 2 Review** → two reviewers, different lenses (MANDATORY)"; :1577 → "✅ Subagent issues resolved — every P0 resolved; each open P1 listed (fixed, or carried with reason)". Registry (:1595–1660) untouched.

#### 4.2.7 MODIFY `.agents/skills/blake/SKILL.md` (Layer 2 = the contract's Gate 3 reviewers)
- Concepts/diagram (:79–87, :105–121, :419, :1770, :2059, :2078, :2097–2117): Layer 2 = "Gate 3 reviewers (review contract): run + consistency (+ domain for security/data/money); only P0/FAIL/PARTIAL blocks, P1 carried; round 3 with an open P0 → escalate to Alex"; "Experts say PASS, not me" kept; ":2117 I own Gate 3 v2" → "I prepare Gate 3 (Layer 1, commit, completion report, journal); the run reviewer writes its verdict; Alex owns Gate 4".
- 3_layer2_loop (:930–976): description `"Gate 3 reviewers (review contract §5, §7, §8), on commit:<sha>"`; keep the express-not-exempt comment, reworded "MUST call both lenses (never fewer than one independent reviewer, AR-001)"; replace priority_groups with `reviewers:` run (`blocking: true`, writes `.tad/evidence/reviews/blake/<slug>/gate3-verdict.md` and the `gate3_verdict:` marker), consistency (`blocking: true`, code-reviewer on Claude Code, `consistency-review.md`), domain (`trigger: risk_triggers lists security|data|money`, `blocking: true`, `domain-review.md`); `pass_rule: "no P0, no FAIL, no PARTIAL in the latest round; P1 carried (listed in the completion report); no P1/P2 cap; coverage thresholds only when §9.1 states one"`; on_failure: fix → Layer 1 → commit → next round per contract §7 (only lenses with an open item, run after every rework); round 3 with an open P0 → escalate_to_alex.
- 4_gate3_v2 (:978–985): items → "Layer 1 passing", "Gate 3 reviewer files with no P0/FAIL/PARTIAL (run reviewer's gate3-verdict.md is the verdict)", "Evidence files", "Knowledge Assessment", "commit recorded".
- escalation (:1033–1047): trigger `"an open P0 in Layer 2 round 3, counted from round 1 or the last re-plan"`, message accordingly; circuit_breaker (Layer 1) unchanged.
- mandatory (:1220–1226): layer2_pass → "MUST pass the Gate 3 reviewers of the review contract (run + consistency, + domain) before Gate 3"; escalation → "MUST escalate to Alex when Layer 2 round 3 still has an open P0".
- layer2_expert_review bullets (:1331–1338) → the three lenses + "Reviewers say PASS — not Blake".
- hard_requirement_distinct_reviewers (:1340–1402): key kept; rule → "Layer 2 MUST dispatch two reviewers with different lenses — run and consistency — plus domain when listed, on every task_type, express and *bug included (review contract §8). No task_type tiers, no express exception, never two of the same lens."; remove `rationale_single_source` and `exception_express` (KNOWN_REVIEWERS/express tiers belong to the advisory script, aligned in Phase 3); forbidden: keep self-review / feedback-integration / substitution lines; the gate3-verdict line → `"gate3-verdict.md written by Blake does NOT count — the Gate 3 verdict file is the run reviewer's, never Blake's"`; enforcement and forbidden_implementations kept, item 4 → `"Anti-AR-001: 'this task is simple, one reviewer covers it' is a forbidden interpretation on every path — both lenses run"`.
- expert_prompt_template (:1404–1445) → `reviewer_prompt:` contract §0 list; Model provenance becomes the header `model:` key (non-blocking, as today); narrow-scope rule replaced by contract §2.
- completion_protocol (:1618–1645): step3 → "Layer 2 = the Gate 3 reviewers, dispatched after step3c on commit:<sha>"; step4 → "Gate 3: the run reviewer's verdict (gate skill Gate 3)"; step4b → "the run reviewer writes the `gate3_verdict:` marker (Blake never does: no one judges their own work)"; timing note kept.
- forbidden/success (:2034–2047): "Ignoring escalation threshold (continuing after 3 same-category failures)" → "Starting a 4th Layer 2 round with an open P0 instead of escalating to Alex"; "Let experts judge completion" kept.

#### 4.2.8 MODIFY gate skill, canonical checklist, config-quality (canonical first)
- canonical :26 → `- [ ] Gate 2 review complete — two reviewers with different lenses (consistency + risk or fit; .tad/templates/review-contract.md). Why ME: 流程检查（审查是否发生）`; :38 → `**Owner:** the Gate 3 run reviewer — not the builder (Blake prepares: completion report, journal, commit) | **When:** After implementation (Layer 1 and commit)`; :77 → `- [ ] Subagent issues resolved — every P0 resolved; each open P1 listed (fixed, or carried with reason). Why ME: 只检查问题修复状态`.
- gate/SKILL.md :57 → `3. Gate 3: Implementation Quality (run reviewer, not the builder - After coding)`; :86 = canonical :26; :112 → `Owner: the Gate 3 run reviewer (not the builder; Blake prepares)`; :386–392 Gate3_Verdict_Marker.who → `The Gate 3 run reviewer writes the marker (it wrote the Gate 3 verdict) — never the builder, never Cora. A rubric judge is a distinct subagent dispatched before it by Blake (direct) or Cora (run); the run reviewer reads the judge's verdict line for those rows. Single rule: the Gate 3 run reviewer owns the marker; the judge is always a distinct sub-agent.`; :745 and :774 = canonical :77 wording.
- config-quality.yaml :74 → `"Gate 2 review complete — two lenses (review contract)"`; :226 → `"Subagent issues resolved — every P0 resolved; open P1 listed (carried with reason)"`; above `subagents_enforcement:` add `# Review composition (Gate 2/3 reviewers): .tad/templates/review-contract.md. The must_call entries below are design consults, not review composition.`

#### 4.2.9 MODIFY templates
- handoff-a-to-b.md frontmatter (after `gate4_delta`): the `risk_triggers` and `real_paths` keys, shaped as in this handoff's frontmatter, with these comment lines: `# risk_triggers: closed list — security | data | money | ui | platform | domain, or [none] (review contract §5; Gate 2 risk or fit, Gate 3 domain for security/data/money)` and `# real_paths: each path the change takes in the real environment, run once by the Gate 3 run reviewer; protocol text = a named scenario walk; impossible → not-run: <reason> (paid, the human's own account or device, production/outward, a capability this harness lacks)`. §9.1 line "Blake的实现将由 spec-compliance-reviewer 自动核对以下条目：" → "Gate 3 的 run reviewer（review contract）逐行运行以下条目和每个 real_path：". §9.2 Audit Trail example rows → `consistency` / `risk (security)`; "Experts Selected" → "Lenses" (consistency + risk or fit, why).
- completion-report.md :33–41 → rows `run (Gate 3 verdict)` | `[every §9.1 row and real_path]`; `consistency` | `[P0=0; open P1 carried, listed]`; `domain (if security/data/money)` | `[N/A or result]`.

### 4.3 Seams left to Phase 3 (named so Phase 3 attaches, not re-opens)
- **Gate 3 scripted re-run + real_path evidence check**: attaches to the run reviewer's Gate 3 file (contract §5 run; conductor-protocol step_Y6 2 and step_Y7 1; gate skill Gate 3). Phase 2 adds no script.
- **Gate 4 real-run / browser acceptance**: step_Y7 2 (Gate 4 prompt), gate skill :579–840 (incl. Required_Subagents, Structural_Subagent_Conditionality, Quality evidence — K21), acceptance-protocol step4c tiers (K18), alex/SKILL.md :1163–1168, `conductor-dispatch-mode.md` Gate 4 kind. The contract's `acceptor` lens points there.
- **Gate 1**: gate skill :63–76, canonical :8–19, Alex gate1, config-quality gate1 (K22).
- **Escape log**: no file, no writer change in this phase.
- **Advisory hooks** (K27) and **wording sweep** (K28): exit codes unchanged; until Phase 3, `layer2-audit.sh`/`audit-yolo.sh`/`pre-gate-check.sh` may report false WARN/FAIL on lens-named files (advisory only; no release in between).
- **Completion-report run evidence + not-run list** (K26).

### 4.4–4.5 Data / API / UI
N/A (protocol text).

---

## 5. 强制问题回答
- MQ1 历史搜索: yes — the research §4 design (contract fields, lenses, round 3) and Phase 1's handoff format reused; inventory §2 drives §4.0.
- MQ2 函数: no functions. Scripts used by ACs: `.tad/hooks/lib/skill-body-verify.sh` (exists, exit 0 today); `ruby -ryaml` (present).
- MQ3–MQ5: N/A.

---

## 6. Implementation Steps

| # | File | Operation | Verification |
|---|------|-----------|-------------|
| 1 | `.tad/templates/review-contract.md` | CREATE (§4.2.1) | AC1, AC2, AC4 |
| 2 | conductor-protocol.md | MODIFY (§4.2.2) | AC2, AC3, AC5, AC6, AC10 |
| 3 | cora/SKILL.md | MODIFY (§4.2.3) | AC3, AC5, AC11, AC13 |
| 4 | conductor-dispatch-mode.md | MODIFY (§4.2.4) | AC5 |
| 5 | handoff-creation, express, bug, experiment, alex SKILL | MODIFY (§4.2.5–4.2.6) | AC4, AC5, AC10, AC12 |
| 6 | blake/SKILL.md | MODIFY (§4.2.7) | AC5, AC8, AC9, AC10 |
| 7 | canonical → gate SKILL → config-quality | MODIFY (§4.2.8) | AC5, AC9, AC11 |
| 8 | handoff + completion templates | MODIFY (§4.2.9) | AC4, AC5 |
| 9 | walks S1–S8, D1–D5 | completion report | AC7 |

Commit: local only, explicit pathspecs (`git add -- <paths>`, `git commit -- <paths>`), tag `[YOLO Phase 2]`; never `-A`; no push.
Completion report: `.tad/evidence/yolo/review-redesign/phase2-completion.md` with Blake's `dispatch_id`, AC outputs, the AR-002 [A092] contract list (cora SKILL, blake SKILL, gate SKILL, config edits > 20 lines), and the walks.

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/templates/review-contract.md   # the reviewer contract (Part A reviewer, Part B dispatcher)
```

### 7.2 Files to Modify
```
.agents/skills/cora/references/conductor-protocol.md
.agents/skills/cora/SKILL.md
.agents/skills/alex/references/conductor-dispatch-mode.md
.agents/skills/alex/references/handoff-creation-protocol.md
.agents/skills/alex/references/express-path-protocol.md
.agents/skills/alex/references/bug-path-protocol.md
.agents/skills/alex/references/experiment-path-protocol.md
.agents/skills/alex/SKILL.md
.agents/skills/blake/SKILL.md
.agents/skills/gate/SKILL.md
.tad/gates/gate-canonical-checklist.md
.tad/config-quality.yaml
.tad/templates/handoff-a-to-b.md
.tad/templates/completion-report.md
```
`.claude/skills/*` are symlinks to `.agents/skills/*`: no separate copies.

### 7.3 Grounded Against (Alex step1c, read 2026-10-19 17:50–18:49)
Head 50 (or whole file) read and path confirmed: conductor-protocol.md (334 lines, read whole), cora/SKILL.md (167; :14–88 read), conductor-dispatch-mode.md (30, whole), handoff-creation-protocol.md (880; :30–52, :272–291, :534–640, :726–880), express-path-protocol.md (98, whole), bug-path-protocol.md (89, whole), experiment-path-protocol.md (113; :50–62), alex/SKILL.md (1667; :1060–1075, :1145–1170, :1460–1660), blake/SKILL.md (2157; :72–125, :412–422, :925–1060, :1210–1230, :1320–1445, :1613–1660, :1765–1775, :2028–2120), gate/SKILL.md (1004; :1–130, :370–410, :579–780), gate-canonical-checklist.md (80, whole), config-quality.yaml (875; :1–100, :215–232), handoff-a-to-b.md (703; :1–124, :529–703), completion-report.md (330; :28–48). Also read (not modified): acceptance-protocol.md :44–104, layer2-audit.sh (grep), audit-yolo.sh :1–330, post-write-sync.sh :130–175, skill-body-verify.sh :20–230. `.tad/templates/review-contract.md`: (new — will be created).
LSP: N/A (markdown/yaml). Pack check: `agent-orchestration` and `ai-evaluation` match keywords (multi-agent review, judge) — pointers only, not loaded (AGENTS.md: keyword match never loads); no pack criteria injected.

---

## 8. Testing Requirements
Protocol text: no unit tests, no model runs. Verification = §9.1 commands + walks (AC7).

### 8.3 Edge Cases
- `grep` may be aliased in interactive shells: run ACs with `bash -c` and `command grep`.
- macOS `sed -i ''` vs GNU: no shell file is edited in this phase.
- The risk reviewer's output path depends on `risk_triggers` (`-risk.md` vs `-fit.md`): the pointer names both; the file whose `dispatch_id` matches counts (§4.2.2 Y4 1).

## 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| ruby absent | AC8 R8d YAML parse | ask; no silent install | `python3 -c 'import yaml'` if present | BLOCKED |
| stale git index | commit | explicit pathspecs | none | wrong commit content = Gate 3 FAIL |

## 8.5 Feedback Collection
N/A.

---

## 9. Acceptance Criteria
All §9.1 rows pass; walks reach their stated ends; no weakening (AC8).

## 9.1 Spec Compliance Checklist
Run every command with `bash -c '…'` from the repo root. In table cells `\|` stands for `|`; run the raw form below. Variables: `C=.tad/templates/review-contract.md CP=.agents/skills/cora/references/conductor-protocol.md CS=.agents/skills/cora/SKILL.md`.

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---|---|---|---|---|
| AC1 | Contract holds every element (header, self-consistency, finding fields, P0 + AR-001 sentence verbatim, empty/no minimum, reference, lenses + closed list, real run, not-run, no ad-hoc, class fix, round 3, upstream, P1 carried, cross-model off, model key) | post-impl | R1 | `0` | today: no output (file absent) → fails |
| AC2 | P0 definition in one place; protocol holds the pointer with [A107][A118] | post-impl | R2a, R2b | R2a `.tad/templates/review-contract.md `; R2b `1` | R2a `…conductor-protocol.md `; R2b `0` |
| AC3 | Every reviewer prompt in Y4/Y6 loads the contract and names a lens; no "Focus on"; simple tier names contract + both lenses | post-impl | R3, R3d | R3 `Y4 load≥2 nolens=0 focus=0` and `Y6 load≥3 nolens=0 focus=0`; R3d `1` | `Y4 load=0 nolens=2 focus=2`, `Y6 load=0 nolens=2 focus=1`; R3d `0` |
| AC4 | `risk_triggers` + `real_paths` in template and handoff creation; closed list with `none` in template, creation protocol and contract | post-impl | R4a, R4b | R4a each ≥`1 1`; R4b each `=1` (≥1) | R4a `0 0` ×2; R4b `=0` ×3 |
| AC5 | Sweep: no old rule left in the Phase-2 file set (registry lines allowed) | post-impl | R5 | `0` | `54` |
| AC6 | Tags ⊇ before; tags on the lines carrying the changed constraints | post-impl | R6a, R6b | R6a `0`; R6b `0` | R6a `0` (invariant); R6b `7` |
| AC7 | Walks S1–S8 and D1–D5 in the completion report, quoting deciding lines | post-impl | R7 | `13` | file absent |
| AC8 | No weakening: tokens and MUST/MANDATORY/VIOLATION per file not lower (AR-001 of the protocol counted with the contract); skill-body-verify green; registry byte-identical; YAML parses | post-impl | R8a–R8d | `0`, `exit=0`, `0`, `YAML_OK` | `0`, `exit=0`, `0`, `YAML_OK` (invariants) |
| AC9 | Gate 3 signer is not the builder (canonical, gate skill, Blake) | post-impl | R9 | `1 1 ≥1` | `0 0 0` |
| AC10 | Round-3 rule present in contract, protocol, Cora SKILL, handoff creation, Blake SKILL | post-impl | R10 | `0` | `4` (contract absent not counted) |
| AC11 | P1 carried stated in contract, canonical, gate skill, Alex SKILL, config-quality, Blake SKILL, Cora SKILL | post-impl | R11 | `0` | `6` |
| AC12 | `*bug` and `*express` load the contract; express keeps "expert review … code-reviewer" in its first 45 lines | post-impl | R12 | `≥1 ≥1 ≥1` | `0 0 2` |
| AC13 | Cora depth line names run and consistency | post-impl | R13 | `1` | `0` |

Raw commands:
```
R1:  test -f "$C" && for p in 'dispatch_id:' 'verdict: PASS | CONDITIONAL | FAIL | PARTIAL' 'p0_count' 'judged:' 'new_p0' 'empirical_p0' 'lens:' 'risk_triggers:' 'self-consistency' 'location' 'scenario' 'blocks' 'checked' 'kind: empirical | design' 'origin: introduced_by_fix | missed_earlier | preexisting' 'This defines a P0; it is not a licence to discount one' '"this P0 is not important" stays a VIOLATION (AR-001)' 'empty review' 'no minimum' '## Requirement' 'Result contract' 'consistency' 'fit' 'security | data | money | ui | platform | domain' 'never a batch' 'not-run:' 'paid' 'quoting' 'no ad-hoc' 'introduced_by_fix' 'class' 'round 3' 'upstream' 'carried' 'cross-model' 'off by default' 'model:'; do printf '%s=%s\n' "$p" "$(command grep -ciF -- "$p" "$C")"; done | command grep -c '=0$'
R2a: command grep -rlF 'a concrete failure scenario' .agents/skills .tad/templates .tad/gates | sort | tr '\n' ' '
R2b: awk '/^  verdict_header:/,/^  dispatch_id_rule:/' $CP | command grep 'review-contract.md' | command grep -c '\[A107\]\[A118\]'
R3:  for st in Y4:Y5 Y6:Y7; do a=${st%:*}; b=${st#*:}; blk=$(awk "/^    step_${a}:/,/^    step_${b}:/" $CP); n=$(printf '%s\n' "$blk" | command grep -c 'prompt: "Load'); m=$(printf '%s\n' "$blk" | command grep -E '^[[:space:]]*prompt: "' | command grep -vc 'review-contract.md.*Lens:'); f=$(printf '%s\n' "$blk" | command grep -c 'Focus on'); echo "$a load=$n nolens=$m focus=$f"; done
R3d: command grep '\*\*Simple\*\*' $CS | command grep 'review-contract.md' | command grep -c 'consistency'
R4a: for f in .tad/templates/handoff-a-to-b.md .agents/skills/alex/references/handoff-creation-protocol.md; do printf '%s %s %s\n' $f $(command grep -c 'risk_triggers' $f) $(command grep -c 'real_paths' $f); done
R4b: for f in .tad/templates/handoff-a-to-b.md .agents/skills/alex/references/handoff-creation-protocol.md $C; do printf '%s=%s\n' $f "$(command grep -F 'security | data | money | ui | platform | domain' $f 2>/dev/null | command grep -c 'none')"; done
R5:  command grep -nE -e '≥2 distinct|≥2 DISTINCT|at least two distinct|min 2|max 2 rounds|max 5 rounds|最多 5 轮|P1=0|P0/P1 = 0|P0/P1 blocking|P0/P1 addressed|P0/P1 from subagent|P0/P1 已处理|skip expert review|no expert review|Owner: Agent B \(Blake\)$|\*\*Owner:\*\* Blake|Gate 3: Implementation Quality \(Agent B|Blake writes it|one reviewer \(middle tier\)|Focus on|≥1 expert|minimum_experts: 2|max_review_rounds: 2|NOT_SATISFIED=0|2\+ experts|一律记为 P1|自行进入第 3 轮|Gate 3 verifier|independent verifier|I own Gate 3' $CP $CS .agents/skills/alex/references/conductor-dispatch-mode.md .agents/skills/alex/references/handoff-creation-protocol.md .agents/skills/alex/references/express-path-protocol.md .agents/skills/alex/references/bug-path-protocol.md .agents/skills/alex/references/experiment-path-protocol.md .agents/skills/alex/SKILL.md .agents/skills/blake/SKILL.md .agents/skills/gate/SKILL.md .tad/gates/gate-canonical-checklist.md .tad/config-quality.yaml .tad/templates/handoff-a-to-b.md .tad/templates/completion-report.md | command grep -vE "rule: \"(Express may justify skipping e2e test, MUST NOT skip expert review \(min 1 expert\)|Spike handoffs require ≥2 experts)|AC8: no expert review needed|label: \"spike evidence = no expert review\"|override marker" | wc -l
R6a: for g in $CS $CP; do comm -23 <(git show "HEAD:$g" | command grep -o '\[A[0-9]*\]' | sort -u) <(command grep -o '\[A[0-9]*\]' "$g" | sort -u); done | wc -l
R6b: for pr in 'A105:consistency plus' 'A132:consistency' 'A106:consistency' 'A116:run plus consistency' 'A117:consistency' 'A107:AR-001' 'A118:AR-001' 'A108:round 3' 'A119:round 3'; do t=${pr%%:*}; w=${pr#*:}; printf '%s=%s\n' $t "$(command grep -F "[$t]" $CP | command grep -ciF -- "$w")"; done | command grep -c '=0$'
R7:  command grep -cE '^### (S[1-8]|D[1-5]) ' .tad/evidence/yolo/review-redesign/phase2-completion.md
R8a: FILES="$CP $CS .agents/skills/alex/references/conductor-dispatch-mode.md .agents/skills/alex/references/handoff-creation-protocol.md .agents/skills/alex/references/express-path-protocol.md .agents/skills/alex/references/bug-path-protocol.md .agents/skills/alex/references/experiment-path-protocol.md .agents/skills/alex/SKILL.md .agents/skills/blake/SKILL.md .agents/skills/gate/SKILL.md .tad/gates/gate-canonical-checklist.md .tad/config-quality.yaml .tad/templates/handoff-a-to-b.md .tad/templates/completion-report.md"; for g in $FILES; do for tk in '\[A060\]' '\[A078\]' '\[A081\]' '\[A086\]' 'AR-001' 'Express Handoff is NOT Review-Exemption' 'push' 'credentials' 'spending' 'MUST' 'MANDATORY' 'VIOLATION'; do b=$(git show "HEAD:$g" | command grep -c -- "$tk"); a=$(command grep -c -- "$tk" "$g"); [ "$g" = "$CP" ] && [ "$tk" = AR-001 ] && a=$((a + $(command grep -c -- AR-001 "$C" 2>/dev/null || echo 0))); [ "$a" -ge "$b" ] || echo "LOST $tk $g $b>$a"; done; done | wc -l
R8b: bash .tad/hooks/lib/skill-body-verify.sh >/dev/null 2>&1; echo "exit=$?"
R8c: blk(){ awk '/^<!-- anti_rationalization_registry:BEGIN -->$/{f=1;next}/^<!-- anti_rationalization_registry:END -->$/{f=0}f'; }; diff <(git show HEAD:.agents/skills/alex/SKILL.md | blk) <(blk < .agents/skills/alex/SKILL.md) | wc -l
R8d: ruby -ryaml -e 'YAML.load_file(".tad/config-quality.yaml"); puts "YAML_OK"'
R9:  echo "$(command grep -A1 '^## Gate 3: Implementation Quality' .tad/gates/gate-canonical-checklist.md | command grep -c 'not the builder') $(awk '/^## Gate 3: Implementation Quality/,/^## Rubric/' .agents/skills/gate/SKILL.md | command grep '^Owner:' | command grep -c 'not the builder') $(command grep -c 'gate3-verdict.md.*run reviewer\|run reviewer.*gate3-verdict.md' .agents/skills/blake/SKILL.md)"
R10: for f in $C $CP $CS .agents/skills/alex/references/handoff-creation-protocol.md .agents/skills/blake/SKILL.md; do printf '%s=%s\n' $f "$(command grep -ci 'round 3' $f 2>/dev/null)"; done | command grep -c '=0$'
R11: for f in $C .tad/gates/gate-canonical-checklist.md .agents/skills/gate/SKILL.md .agents/skills/alex/SKILL.md .tad/config-quality.yaml .agents/skills/blake/SKILL.md $CS; do printf '%s=%s\n' $f "$(command grep -ci 'P1.*carried\|carried.*P1' $f 2>/dev/null)"; done | command grep -c '=0$'
R12: B=.agents/skills/alex/references/bug-path-protocol.md; E=.agents/skills/alex/references/express-path-protocol.md; echo "$(command grep -c 'review-contract.md' $B) $(command grep -c 'review-contract.md' $E) $(awk '/^express_path_protocol:/{s=NR} s && NR<=s+45' $E | command grep -c 'expert review.*code-reviewer')"
R13: command grep -F '**Depth**' $CS | command grep 'run' | command grep -c 'consistency'
```

R7 walks (Blake writes each as a heading `### S1 …` etc.; each quotes the deciding file:line and reaches the stated end; a walk that does not reach it is a FAIL, not a note):
- S1 handoff `risk_triggers: [platform]` → Y4 r1 = consistency + risk (platform section); Gate 3 = run + consistency, no domain; the run reviewer runs the install path or writes `not-run: <reason>`.
- S2 `[none]` → consistency + fit; a fit doubt → phase questions file (class 2 → stop) or P1, never P0.
- S3 r1: consistency P0=0, risk P0=1 → r2 = risk lens only, on the fix diff; `new_p0` still in its header.
- S4 r2 P0 `origin: introduced_by_fix` → the design-fix prompt requires a class fix (dispatch mode + contract §3).
- S5 round 3 with an open P0 → premise re-plan (Y4 5c); no round 4 review.
- S6 `[security]` → Gate 3 = run + consistency + domain (security); all three run.
- S7 header `CONDITIONAL`, `p0_count: 1` → not returned → one re-dispatch → stop (reason 1).
- S8 empirical P0 at Y4 → spike route unchanged.
- D1 direct `/alex *handoff`, `[none]` → Alex dispatches consistency + fit to `.tad/evidence/reviews/alex/<slug>/`; round 3 open P0 → premise + one re-plan; second time → human (narrow / change / withdraw).
- D2 `*express` → Gate 2 two lenses; Gate 3 run + consistency (no "≥1" left).
- D3 `*bug` → mini-handoff with frontmatter; no Gate 2; Blake → Layer 1 → commit → run + consistency.
- D4 direct `/blake`, code task, open P1 only → not blocking (carried); run reviewer writes `gate3-verdict.md` and the marker; Blake signs nothing; round 3 open P0 → escalate to Alex (no 5-round cap).
- D5 Cora simple tier with a P0 from consistency → one Blake rework → re-review by consistency + run → a P0 again → retriage as handoff (stop, reason 2).

### AC Dry-Run Log (Alex step1d, 2026-10-19 18:30–18:49, `bash`, `command grep`)
- R1: post-impl; today prints nothing (contract absent). Tokens chosen so the §4.2.1 text satisfies them (checked by reading).
- R2a today `.agents/skills/cora/references/conductor-protocol.md ` (definition inline at :39) → must become the contract only. R2b today `0`.
- R3 today `Y4 load=0 nolens=2 focus=2`, `Y6 load=0 nolens=2 focus=1`; spike and rework "Prompt:" lines are not matched (anchored `^\s*prompt: "`). R3d today `0`.
- R4a today `0 0` for both; R4b today `=0` ×3.
- R5 today `54` lines across the 14 files (cp 8, cora SKILL 3, handoff-creation 6, express 2, bug 2, alex SKILL 5, blake 14, gate 7, canonical 3, config 2, completion 1, …); registry lines 1616/1621/1633/1639 and blake :1996 (override marker) filtered.
- R6a today `0`; R6b today `7` (only [A107]/[A118] carry AR-001).
- R8a today `0`; R8b `exit=0`; R8c `0`; R8d `YAML_OK` — invariants that must hold after.
- R9 today `0 0 0`; R10 today `4`; R11 today `6`; R12 today `0 0 2`; R13 today `0`.
- verify-ac-commands.sh advisory tail: not run in this dispatch; Blake may run it (advisory only).

---

## 9.2 Expert Review Status
Not run in this dispatch (Design kind stops before step2). Y4 reviewers write their files under `.tad/evidence/yolo/review-redesign/`.

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| — | (Y4 pending) | — | — |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Edit the canonical checklist before the gate skill (SSOT rule at its head).
- ⚠️ Keep Blake markers `Layer 2`, `gate3_verdict`, `hard_requirement_distinct_reviewers`; restate every removed MUST/VIOLATION in its new form (AC8 per-file counts).
- ⚠️ Do not touch the anti-rationalization registry (byte-exact), principles.md, hooks, docs/README/AGENTS (Phase 3), NEXT.md, session-state.md, provenance, brain-index; no version bump; no push.
- ⚠️ This run's own Phase 2 reviews follow the protocol as approved at "continue" (Epic Notes); the new rules apply from the next run.

### 10.2 Known Constraints
- The Epic has no inline Phase Detail block (it points to `intake-details-3.md`); this dispatch writes no Epic edit (same as Phase 1).
- Until Phase 3, the advisory hooks and Gate 4 text still describe the old composition (§4.3); nothing ships before the Epic ends.
- AR-002 [A092]: edits > 20 lines to Cora SKILL, Blake SKILL, gate SKILL, handoff-creation → list the changed contracts in the completion report.

### 10.3 Sub-Agent使用建议
None required; Blake does not call reviewers in this run (Cora dispatches them).

---

## 11. Learning Content

### 11.1 Decision Rationale: how the second Gate 2 reviewer gets its lens
| 方案 | 优点 | 缺点 | 为什么没选 |
|---|---|---|---|
| One risk reviewer covering every listed trigger; lens and triggers reported in its header (chosen) | Cora composes from headers only; Gate 2 always two dispatches; Gate 3 domain decided from a header | one reviewer may carry 2–3 lenses | ✅ |
| One reviewer per trigger | each lens gets full attention | Cora must read the handoff to know how many (AGENTS.md forbids); dispatch count varies | breaks the Cora-reads-no-handoff rule |
| One reviewer for the highest trigger only | cheapest | a second listed risk class goes unreviewed | silent coverage loss |

**💡 Human学习点**: when the conductor must not read the work, put the routing facts the conductor needs into the reviewers' headers — the people who read the work report what the router needs.

---

**Handoff Created By**: Alex (Agent A), conductor dispatch p2-y3-1
**Date**: 2026-10-19
**Version**: 4.0.3
