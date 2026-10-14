---
dispatch_id: p4e-y4-1
task_type: e2e
e2e_required: yes
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Handoff for Blake — Phase 4e: fresh install from the published tag

**From:** Alex (design dispatch `p4-y3-1`; revised by `p4e-y4-1`) · **To:** Blake · **Date:** 2026-10-14
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md`, Phase 4, part e of e
**Starts after:** the human confirmed and the commands in `.tad/evidence/yolo/cora-conductor-role/phase4d-publish-commands.md` were run (push to `main`, annotated tag `v4.0.0`, GitHub release). **After this part:** the Epic's close (distillation, then acceptance, then archiving as its own question).
**Index:** `.tad/evidence/yolo/cora-conductor-role/phase4-design-index.md`

> **Revision `p4e-y4-1` (2026-10-14)**, answering `phase4e-p0-check.md` P0-1: E2 no longer passes on the word "cora" anywhere in the file (the prompt and the path contain it, and both CLIs exit 0 when the skill is not loaded). The install file now has fixed sections; E2 reads the activation marker only from `## Reply` (the session's stdout): the reply must name the conducting actions Intake, Route and Record, which come only from the cora `SKILL.md` body (`AGENTS.md` does not name them; "Intake" appears nowhere in it). E2 also checks `### version: 4.0.0`. P2 taken: new E4 checks the completion report. Only the 4e section of `phase4-ac.sh` changed.

Design handoff only; no Gate 2 claim. Questions go to `.tad/evidence/yolo/cora-conductor-role/phase4-questions.md` (line 1 `dispatch_id: <your id>`), then stop.

## 1. Task overview

### 1.1 What we are building
Proof that someone installing the published release gets Cora: a fresh install from the tag `v4.0.0` on Claude Code and on Codex, each followed by one headless session that activates Cora. Plus the post-publish read-back.

### 1.2 Why
Epic Phase 4 AC "A fresh install from the published tag on Claude Code and on Codex activates Cora"; the download install paths were untested at the last release (Epic Phase 4 Notes).

### 1.3 Intent
Read-only towards GitHub. No commit is needed unless the closeout record is tracked; it is not (evidence is gitignored).

### 1.4 Offload log
None.

## 2. Background and knowledge
`.agents/skills/release-runbook/references/publish-ops.md` §5–6 (read-back commands, no blind retry), `tad.sh` usage (`--release-ref vX.Y.Z --expected-version X.Y.Z` pinned path; the curl one-liner in `INSTALLATION_GUIDE.md`), the 4d install files `phase4d-install-{claude,codex}.md` (same session method).

## 3. Requirements
1. Read-back: `git ls-remote origin refs/heads/main refs/tags/v4.0.0 'refs/tags/v4.0.0^{}'` and `gh release view v4.0.0`; append raw output to `.tad/evidence/releases/4.0.0-closeout.md` under `## Post-publish read-back`.
2. For each of `claude-code` and `codex`: a new empty git project under an owned `mktemp -d` outside the repository; install from the published tag by the download path, not the local tree: fetch `tad.sh` from `https://raw.githubusercontent.com/Sheldon-92/TAD/v4.0.0/tad.sh` and run it with `--yes --platform <p>` and, if the installer accepts it on a fresh project, `--release-ref v4.0.0 --expected-version 4.0.0` (record which form ran and why). Confirm `.tad/version.txt` in the project reads `4.0.0`.
3. One headless session in each project: Claude Code `claude -p "/cora you are Cora." --permission-mode acceptEdits </dev/null`; Codex `codex exec --sandbox workspace-write '$cora you are Cora.' </dev/null`.
4. Write `.tad/evidence/yolo/cora-conductor-role/phase4e-install-{claude,codex}.md` in exactly this shape (header lines start at column 0; E2 parses them):
   ```
   ### source: v4.0.0 (<URL used>)
   ### install exit: <rc>
   ### version: <content of the project's .tad/version.txt>
   ### session exit: <rc>

   ## Prompt
   <the exact command line of item 3>

   ## Reply
   <the session's stdout, verbatim: claude -p stdout; codex exec stdout (its final message)>

   ## Session log
   <stderr and anything else: install output, codex event log>
   ```
   Capture stdout and stderr to separate files (`>out 2>err`) and paste them, so the prompt echo in Codex's stderr never lands in `## Reply`. Do not edit the reply, add words to it, or rerun the session to obtain a passing reply. Activation marker (E2): Cora's activation with no Epic in progress says who she is and names the five conducting actions (cora `SKILL.md` `## Activation`; the actions are Intake, Dispatch, Read, Route, Record); E2 requires Intake, Route and Record as whole words in `## Reply`. If the reply lacks them, record it as is, E2 is FAIL, and stop and ask: that is a finding (the skill did not load, or activation does not name the actions), not a harness glitch. A login or quota failure is NOT RUN with the vendor text, never a pass; then stop and ask.
5. Completion report `.tad/evidence/yolo/cora-conductor-role/phase4e-completion.md`: `dispatch_id`, `base: <HEAD>`, `gate3_verdict:` empty, commands with rc, `Journal:`.

## 4. Technical design
Throwaway projects only; nothing written inside the TAD repository except the evidence files named.

## 5. Mandatory questions
N/A.

## 6. Implementation steps
Items 1–5 in order, then `bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh 4e`.

## 7. File structure
### 7.1 Create
`phase4e-install-claude.md`, `phase4e-install-codex.md`, `phase4e-completion.md` (all under `.tad/evidence/yolo/cora-conductor-role/`).
### 7.2 Modify
`.tad/evidence/releases/4.0.0-closeout.md` (append; created in 4d).
### 7.3 Grounded Against
`tad.sh` read 2026-10-14: `DOWNLOAD_URL` main tarball (line 28), `download_pinned_source` tag archive (line ~3066), `--release-ref/--expected-version` usage (lines 454, 471). `4.0.0-closeout.md` does not exist yet (created by 4d). `gh` is on PATH.

## 8. Testing
These are the tests. A harness failure is recorded, never passed.

## 9. Acceptance criteria
`bash .tad/evidence/yolo/cora-conductor-role/phase4-ac.sh <id>` (or `4e`); expect PASS.

| AC | Checks |
|---|---|
| E1 | `origin/main` equals `release_commit:` of the publish-commands file; tag `v4.0.0` peels to it |
| E2 | per harness (claude, codex): file exists; `### source: v4.0.0 `; `### install exit: 0`; `### version: 4.0.0`; `### session exit: 0`; non-empty `## Reply` section naming Intake, Route and Record (whole words, case-insensitive), read from that section only |
| E3 | `gh release view v4.0.0` exit 0 |
| E4 | `phase4e-completion.md` has `dispatch_id:`, `base: `, `gate3_verdict:`, `Journal:` |

Design dry-run (2026-10-14, after revision `p4e-y4-1`): runs; E1, E1b, E2 (both files missing), E3, E4 FAIL as expected (nothing published yet). E2 fixture check in a scratch copy: a reply naming the actions passes; a reply without them fails even when `## Prompt` and `## Session log` contain all three words (the self-leak control).

## 9.2 Design checks
Frontmatter filled (`skip_knowledge_assessment: yes`: a verification-only part). Packs: `web-deployment` keyword match; pointer-only per `AGENTS.md`, not loaded (conflict with the dispatch prompt recorded). Grounding §7.3. LSP: not applicable. AC dry-run above.

## 10. Important notes
No push, tag, release edit, or repository edit. If E1 or E3 is red, do not "fix" it: record and stop (publish-ops §5: read back, never blind retry).

## 11. Learning content
None expected.

## 12. Sub-agent record
None called by this design dispatch.
