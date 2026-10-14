---
dispatch_id: p4-y3-1
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff for Blake — Phase 4b: the new introduction (all places except the README body) and the README openings

**From:** Alex (design dispatch `p4-y3-1`) · **To:** Blake · **Date:** 2026-10-14
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md`, Phase 4, part b of e
**Starts after:** 4a accepted (its gates PASS). **Human stop after this part:** the human chooses one README opening.
**Index:** `.tad/evidence/yolo/cora-conductor-role/phase4-design-index.md`

Design handoff only; no Gate 2 claim. Questions go to `.tad/evidence/yolo/cora-conductor-role/phase4-questions.md` (line 1 `dispatch_id: <your id>`), then stop. The choice of opening is not your question: you draft the alternatives, Cora asks the human.

## 1. Task overview

### 1.1 What we are building
1. Every place that introduces TAD, rewritten around three roles (the README body is part 4c).
2. `.tad/evidence/yolo/cora-conductor-role/phase4b-readme-openings.md`: two or three alternative README openings for the human to choose from.

### 1.2 Why
TAD has been introduced as two agents in two terminals with the human carrying messages. The main way of working is now: agree a result with Cora, she has an Epic written and stops, you say continue, she runs it through subagents and gates, you look at the result (Epic Phase 4 Scope A). The release is a major one; introductions are rewritten, not patched.

### 1.3 Intent: what every introduction says (the content source is the Epic's Objective and Phase 4 Scope A)
- Three roles: Alex designs, Blake executes, Cora is who you talk to and who dispatches.
- How a piece of work goes: agree a result with Cora → she gets an Epic written and stops → you say "continue" → she runs it to the end through subagents and gates → you look at the result.
- Where quality comes from: the one who checks did not see the reasoning of the one who did the work; only questions a human can answer go to the human. Separate terminals remain one way to get that, described as such (`/alex` and `/blake` still work directly).
- Who to go to: what/why/whether/what next → Cora; how to build it → Cora dispatches Alex, or `/alex` directly; a single handoff, bug or technical discussion → `/alex` or `/blake`; unsure → Cora.
- Per harness, what has been run (facts only, §3.3).
Plain language, short. Never "first-class"; never describe something unrun as verified.

### 1.4 Offload log
None.

## 2. Background and knowledge
Read: `principles.md` ("Three Roles, Independent Judgment"), `patterns/_index.md`, `patterns/release-sync.md`. Facts for the per-harness lines: `.tad/evidence/yolo/cora-conductor-role/phase3-gate-report.md` (section 2 and P4-E), `.tad/evidence/yolo/cora-carry-forward-fixes/run-record.md` with its residuals in `phase2-record-check.md` (do not repeat a residual as fact), the parent `phase2-activation-judge.md`, and the 4a judge files `phase4a-queue-judge.md`, `phase4a-smoke-judge.md`.

## 3. Requirements

### 3.1 Files and what changes in each
| File | Change |
|---|---|
| `AGENTS.md` | Intro paragraph above "Role Switching" says the three roles and the flow in 3–5 lines; nothing else in the file changes (Runtime status, Known Gaps stay; 4d updates versions). |
| `docs/MULTI-PLATFORM.md` | New section `## Cora on each harness` (four rows: Claude Code, Codex, Cursor, OpenCode; what was run, what was not, pointer to the evidence file). Intro paragraph mentions Cora. |
| `INSTALLATION_GUIDE.md` | "Terminal 1/2" lines become: start with `/cora` (or `$cora`); `/alex`, `/blake` still work. |
| `docs/CODEX-USER-GUIDE.md` (line ~389) | The "two terminals, human the only bridge" paragraph becomes the three-role flow with `$cora`; separate sessions described as one way. |
| `docs/value-proposition.md` (line ~19) | "Two agents with enforced separation … the human is the only bridge" → independent judgment by a party that did not do the work; Cora dispatches. |
| `.tad/README.md` | Quick Activation and Triangle Model: Cora first, Alex, Blake. |
| `.tad/project-knowledge/architecture.md` (line 11) | "Two-Agent System" → "Three Roles" (Cora, Alex, Blake), matching `principles.md`; keep its failure_mode. |
| `.agents/skills/tad-help/SKILL.md` | Agent activation block: `/cora` first, then `/alex`, `/blake`; no Terminal 1/2. |
| `.agents/skills/tad-init/SKILL.md` (line ~115) | Next steps: "Say `/cora` to start"; `/alex`/`/blake` direct use. |
| `.agents/skills/tad/SKILL.md` | Banner/triangle and option list include Cora (`/cora`) as the first entry. Version strings: leave for 4d. |
| `package.json` `description` | One line naming the three roles, e.g. "Triangle Agent Development — Cora conducts, Alex designs, Blake builds; independent gates check the work". |
| `.tad/config.yaml` line 4 `description` | Same meaning as package.json; no "Two-Agent". |
| `PROJECT_CONTEXT.md`, `ROADMAP.md` | Current-state and direction lines name Cora and the A-B-C flow. **These files carry uncommitted edits not made by this Epic** (Capability Builder status lines). Keep every one of them, commit them with yours, and list them in your completion report. If a pre-existing hunk restores older text (check with `git log -S '<phrase>' --oneline -- <file>`), stop and ask. |

Out of scope: role skills' own "Terminal 2" operating text (`blake/SKILL.md`, `alex/references/handoff-creation-protocol.md`), `tad-scenario`, `.tad/workflows/new-project.yaml`, `.tad/agents/*`, archived/legacy docs, `CHANGELOG.md` (4d), version numbers (4d), the GitHub repository description (prepared in 4d, set only after the human confirms).

### 3.2 README openings file
`phase4b-readme-openings.md`: line 1 `dispatch_id: <your id>`, then two or three sections `## Opening A`, `## Opening B` (optionally `## Opening C`). Each: a one-line note saying what it leads with (as a `>` quote line), then the opening exactly as it would stand at the top of the README: title line, one short paragraph, and the first screen (≤ 25 lines). Make them genuinely different (for example: lead with the flow "you talk to Cora"; lead with where quality comes from; lead with who to go to for what). Each must stand on its own for someone who has never seen TAD. No README edit in this part.

### 3.3 Per-harness facts (state only what is on disk)
Claude Code: Cora headless smoke and queue fixtures, plus one live conducted run (Phase 3). Codex: headless smoke/fixtures; in the live run, resume and steps Y1–Y5 only, no gates or acceptance on Codex; conducting a run whose fixtures need `claude -p` was blocked (R-CC-9). Cursor, OpenCode: Cora not run. Update with the 4a judge results (counts as they stand in the judge files).

## 4. Technical design
Text only. No API, data model, UI.

## 5. Mandatory questions
MQ1: edit existing files; create only the openings file. MQ3/4/5: N/A.

## 6. Implementation steps
1. `git status --short`; write `base: <HEAD>` in the completion report.
2. Edit per §3.1; run `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh B2 B3 B4 B5`.
3. Regenerate the ledger (`bash .tad/scripts/gen-claude-provenance.sh`; skills changed) and run `B6`.
4. Commit by explicit paths (docs commit, then ledger commit). No push.
5. Write the openings file; run `B1`, then `B7`.
6. Completion report `.tad/evidence/yolo/cora-conductor-role/phase4b-completion.md`: `dispatch_id`, `base:`, `gate3_verdict:` empty, commits, commands with rc, the list of pre-existing hunks kept, `Journal:`.

## 7. File structure
### 7.1 Create
`.tad/evidence/yolo/cora-conductor-role/phase4b-readme-openings.md`, `phase4b-completion.md`.
### 7.2 Modify
The 14 files of §3.1, `.tad/provenance/claude-legacy.tsv`, `.tad/provenance/MANIFEST.sha1`.
### 7.3 Grounded Against
Heads (50 lines) read 2026-10-14 at `c666a2de`: `AGENTS.md` (199 lines), `docs/MULTI-PLATFORM.md` (246; status table line ~22), `INSTALLATION_GUIDE.md` (209; "Terminal 1" line 69), `docs/CODEX-USER-GUIDE.md` (462; line 389), `docs/value-proposition.md` (119; line 19), `.tad/README.md` (Terminal 1/2 at line 31), `.tad/project-knowledge/architecture.md` (31; line 11), `tad-help/SKILL.md` (228; lines 36, 122), `tad-init/SKILL.md` (126; line 115), `tad/SKILL.md` (v2.5.0 banner, line 106), `package.json` (80; line 4), `.tad/config.yaml` (438; line 4), `PROJECT_CONTEXT.md` (116; uncommitted +1/−1), `ROADMAP.md` (54; uncommitted +4/−4, newer content, not a stale copy by inspection). All exist.

## 8. Testing
`release-verify.sh path-refs` and `provenance` after the edits. Plain-text checks only.

## 9. Acceptance criteria
Run `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh <id>` (or `4b`); expect PASS, rc 0.

| AC | Checks |
|---|---|
| B1 | openings file: `dispatch_id` on line 1, 2–3 `## Opening A..C` sections |
| B2 | none of the 14 introducing files contains "Two-Agent", "two terminals", "Terminal 1/2", "only bridge", "唯一桥梁", "两个终端" |
| B3 | `package.json` and `.tad/config.yaml` descriptions name Cora; `docs/MULTI-PLATFORM.md` has `## Cora on each harness` |
| B4 | `tad-help`, `tad-init`, `tad` skills mention `/cora` |
| B5 | the pre-existing PROJECT_CONTEXT/ROADMAP edits are still there |
| B6 | `release-verify.sh provenance` and `path-refs` exit 0 |
| B7 | only the files of §7.2 changed since base |

Design dry-run (2026-10-14): runs; B5, B6 PASS now; the rest FAIL as expected.

## 9.2 Design checks
Frontmatter filled. Packs: `product-thinking` and `web-ui-design` match keywords (positioning, design); pointer-only per `AGENTS.md`, not loaded, no criteria injected (the dispatch prompt asked for injection; the repository rule ranks higher). Grounding §7.3. LSP: not applicable. AC dry-run above.

## 10. Important notes
No push, no `gh repo edit`, no publish. No README edit here.

## 11. Learning content
None expected.

## 12. Sub-agent record
None called by this design dispatch.
