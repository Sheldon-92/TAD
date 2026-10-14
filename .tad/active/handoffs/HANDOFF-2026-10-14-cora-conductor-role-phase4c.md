---
dispatch_id: p4-y3-1
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff for Blake — Phase 4c: the README

**From:** Alex (design dispatch `p4-y3-1`) · **To:** Blake · **Date:** 2026-10-14
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md`, Phase 4, part c of e
**Starts after:** 4b accepted and the human's choice of opening is recorded (Epic `## Run` `Stopped:` answer). **Human stop inside this part:** the human reads the README draft before it is committed.
**Index:** `.tad/evidence/yolo/cora-conductor-role/phase4-design-index.md`

Design handoff only; no Gate 2 claim. Questions go to `.tad/evidence/yolo/cora-conductor-role/phase4-questions.md` (line 1 `dispatch_id: <your id>`), then stop.

## 1. Task overview

### 1.1 What we are building
`README.md` rewritten around three roles, opening with the alternative the human chose. Two dispatches:
- **Step 1 (write):** write the README; do **not** commit it.
- **Step 2 (commit):** only when Cora's dispatch prompt says the human has read the draft and approved it (quoting the human's words); apply any changes the human asked for, then commit `README.md` alone with a subject ending `(human-read)`.

### 1.2 Why
Epic Phase 4 Scope A and ACs: a reader who has never seen TAD, reading only the README, can say what the three roles do, who to talk to first, and what happens after "continue"; the human chose the opening and read the draft before commit.

### 1.3 Intent
Rewritten, not patched. Short: at most 320 lines (now 512). Plain language. Facts per harness only as measured.

### 1.4 Offload log
None.

## 2. Background and knowledge
Read: `.tad/evidence/yolo/cora-conductor-role/phase4b-readme-openings.md` (the chosen section; the letter is in the Epic `## Run` answer and in Cora's prompt), the 4b-edited `docs/MULTI-PLATFORM.md` section `## Cora on each harness` (single source for per-harness facts; the README summarises and links), `principles.md`, the current `README.md` (keep only what is still true and useful: install, platform flags, Lite frozen note, links).

## 3. Requirements

### 3.1 Structure (H2 headings, literal, in this order after the chosen opening)
1. `## Three roles` — Cora, Alex, Blake in one table or three short lines.
2. `## How a piece of work goes` — agree a result with Cora → Epic written, she stops → "continue" → she runs it through subagents and gates → you look at the result; she stops mid-run only for what she cannot get past, a change to the result, or an irreversible/outward action (push, publish, delete).
3. `## Where quality comes from` — the checker did not see the doer's reasoning; four gates; only human-answerable questions go to the human; separate terminals (`/alex`, `/blake`) are one way to get the same independence.
4. `## Who to go to for what` — the four-line rule.
5. `## What has been run on each harness` — four rows, from `docs/MULTI-PLATFORM.md`; Cursor and OpenCode: Cora not run.
6. `## Install` — the curl and npx commands, `--platform` values, one line on what the installer leaves alone (link to INSTALLATION_GUIDE for detail).
7. `## Upgrading from 3.x` — what an existing install does (re-run the installer; `/cora` appears; `/alex` and `/blake` keep working unchanged; nothing to migrate by hand unless 4d's migration manifest says so — link the CHANGELOG entry).
8. Optional short sections after these: Lite (frozen), capability packs, links (Changelog, Installation, Multi-Platform). The "What's New in v2.x" sections and the "Terminal 1 / Terminal 2" walkthrough are removed (the CHANGELOG keeps history).

### 3.2 Opening
The chosen opening verbatim from the openings file (minus its `>` note line); the version line under the title stays `**Version 3.3.0 …**` for now (4d bumps it). Record `chosen_opening: <A|B|C>` in your completion report.

## 4. Technical design
Text only.

## 5. Mandatory questions
MQ1: keep existing install text where still true. Others N/A.

## 6. Implementation steps
Step 1:
1. `git status --short`; write `base: <HEAD>` and `chosen_opening:` in `.tad/evidence/yolo/cora-conductor-role/phase4c-completion.md`.
2. Write `README.md`; run `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh C1 C2 C3 C4 C5`.
3. Completion report: `dispatch_id`, `gate3_verdict:` empty, rc of each command, `git diff --stat -- README.md`, `Journal:`. Leave the README uncommitted. Stop.
Step 2 (its own dispatch id, after the human read the draft):
4. Apply the human's requested changes, if any; rerun C1–C5; `git commit -m "docs(readme): rewrite around Cora, Alex and Blake (human-read)" -- README.md`; run `C7`, `C8`; add `## Step 2` to the completion report with the new `dispatch_id`.

## 7. File structure
### 7.1 Create
`.tad/evidence/yolo/cora-conductor-role/phase4c-completion.md`.
### 7.2 Modify
`README.md` only.
### 7.3 Grounded Against
`README.md` head read 2026-10-14 at `c666a2de`: 512 lines; line 3 version line; line 24 "(Two-Agent Quality Framework)"; line 215 "Default — full TAD (two terminals …)"; Triangle Model section at line 254. Exists.

## 8. Testing
`release-verify.sh path-refs` (links in the README resolve). The fresh-reader check (§9, C6) is run by a subagent Cora dispatches between step 1 and the human's reading: given only `README.md` and the three questions (what do the three roles do; who do you talk to first; what happens after you say "continue"), it writes `.tad/evidence/yolo/cora-conductor-role/phase4c-fresh-reader.md` with the verdict header (PASS only if all three answers match the Epic's Objective).

## 9. Acceptance criteria
`bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh <id>` (or `4c`); expect PASS.

| AC | Checks | When |
|---|---|---|
| C1 | the seven H2 headings of §3.1 | step 1 |
| C2 | README's first 15 lines contain the chosen opening's first line | step 1 |
| C3 | no "Two-Agent", "Terminal 1/2", "only bridge" | step 1 |
| C4 | ≤ 320 lines; no "What's New in v2" | step 1 |
| C5 | `release-verify.sh path-refs` exit 0 | step 1 |
| C6 | `phase4c-fresh-reader.md` PASS, p0 0 | after Cora's reader dispatch |
| C7 | README committed, subject contains `(human-read)` | step 2 |
| C8 | only `README.md` changed since base | step 2 |

Design dry-run (2026-10-14): runs; C5 PASS now; the rest FAIL as expected.

## 9.2 Design checks
Frontmatter filled. Packs: `product-thinking` keyword match; pointer-only per `AGENTS.md`, not loaded, no criteria injected (conflict with the dispatch prompt recorded; repository rule ranks higher). Grounding §7.3. LSP: not applicable. AC dry-run above.

## 10. Important notes
Never commit the README in step 1. No push.

## 11. Learning content
None expected.

## 12. Sub-agent record
None called by this design dispatch.
