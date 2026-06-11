# HANDOFF: Codex Parity Gate (step3b) — verify draft + land via quality chain

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10 (v2 — post expert review)
**Type:** Express (small protocol/infra change) — Express ≠ review-exemption: Gate 3 Layer 2 expert review REQUIRED
**task_type:** bash + markdown (protocol files)
**e2e_required:** no
**research_required:** no
**Expert review of this handoff:** code-reviewer + backend-architect, 2026-06-10. P0=0; both flagged
the prose-only direction guard as P0-adjacent → design AMENDED in v2 (see §2 rows 4-5, FR3-FR4).

---

## ⚠️ Process Note (read first)

A prior session implemented a v1 draft WITHOUT going through Blake (violation of terminal
isolation — recurrence of the 2026-06-03 alex-no-code incident, recorded in memory + incidents).
Human decision: **the draft is RETAINED as reference, but it is NOT pre-approved.** Additionally,
the v2 design below SUPERSEDES the draft in two places (direction signal + `--fix` subcommand),
so the draft cannot be adopted as-is. Treat it as a starting point: cherry-pick, then implement
the v2 deltas, then verify every AC independently.

**Draft location:** worktree branch `worktree-codex-parity-step3b`, commit `75ef98c`
(based on local main `89b20b0`). 5 files, +123/-2. NOT merged.
**Draft gaps vs v2:** no direction signal; rsync lives in protocol prose (quoting/trailing-slash
risk on a space-containing repo path); no scoped-commit assertion; missing orphan-file and
clean-tree-final ACs.

---

## 1. Problem

`.claude/skills/` (source of truth) and `.agents/skills/` (Codex mirror) must stay byte-identical,
but the publish flow's documented "step3b (codex parity)" check was a **dangling reference** —
named in release-runbook (~L239), never implemented in publish-protocol.md. Result: skills
edited on the Claude side twice shipped with a stale Codex mirror (f428d70, f84c8fb), caught
only by the human. Source: IDEA-20260610-agents-skills-auto-parity.

## 2. Design Decisions (resolved with human + amended per expert review 2026-06-10)

| Question | Decision | Why |
|---|---|---|
| Verify-only vs verify+fix, where? | Detection in `release-verify.sh parity` (read-only default); **fix in `parity --fix` subcommand of the SAME script** (v2 amendment) | Both reviewers: quoting, trailing-slash semantics, and BSD portability of the destructive rsync must live in tested code, not protocol prose. The repo path contains a space. |
| Also run during *sync? | No (publish-only for now) | Publish is the source-side distribution choke point |
| Also in Blake completion protocol? | **Deferred — recorded as KNOWN RESIDUAL GAP, not silently dropped** | Honest framing (architect P1): both historical drifts were introduced by edit-time misses, not publish-time. The publish gate guarantees the published artifact, but the in-repo drift window between a skill edit and the next *publish remains. Follow-up idea required at Gate 4. |
| Direction safety | **Mechanical, in-script** (v2 amendment): on drift, parity computes and prints `DIRECTION: claude-newer (safe to mirror)` or `DIRECTION: agents-newer (STOP)`; `--fix` REFUSES (exit 1) on agents-newer | Both reviewers: prose-only STOP guard is decorative — the failure is silent irreversible data loss, and this codebase's own history proves documented-but-not-mechanical fails. Bias to false-positive (when unsure → agents-newer → STOP). |
| Patch-release downgrade? | **None for parity** — drift is fixed unconditionally regardless of release_type; only exit 2 blocks | A stale mirror is never acceptable to ship. Document this asymmetry vs step3c/step3d in the script header (architect P1-4). |

Symlink approach previously rejected by user (Codex file-expectation risk).

## 3. Functional Requirements

- **FR1** `release-verify.sh` gains `parity <repo_root>` mode: `diff -rq .claude/skills .agents/skills`.
  Exit 0 = byte-identical; exit 1 = drift (each path NAMED); exit 2 = missing dir / usage.
  Contract header documents the mode incl. the no-patch-downgrade asymmetry.
- **FR2** On exit 1, parity prints a computed `DIRECTION:` line. Heuristic (bias to STOP):
  a differing/orphan `.agents` path that is working-tree-modified, untracked, or whose last
  commit touches ONLY the `.agents` side → `agents-newer (STOP)`. Otherwise → `claude-newer`.
  When the heuristic cannot decide → `agents-newer (STOP)` (false-positive preferred).
- **FR3** `parity --fix <repo_root>`: re-runs detection; if `claude-newer` → verbatim mirror copy
  (rsync -a --delete, Claude→Codex, paths quoted, trailing-slash correct), then re-verifies to
  exit 0; if `agents-newer` → REFUSE with exit 1 and name the offending paths; never partial-fix.
- **FR4** publish-protocol.md step3b (between step3 and step3c): run parity; exit 0 → proceed;
  exit 2 → ALWAYS HARD BLOCK; exit 1 → run `parity --fix`; on fix success commit ONLY the mirror
  (`git add .agents/skills` — NEVER `-A`), message
  `chore(TAD): sync .agents/skills from .claude/skills (step3b parity)`, re-run step3, proceed;
  on fix REFUSAL → STOP and ask the human (someone edited the mirror directly).
- **FR5** release-runbook: pre-flight checklist gains the parity command; EVERY occurrence of
  "step3b" in the runbook points at the real command (no dangling reference anywhere).
- **FR6** The two edited skill files are themselves mirrored to `.agents/skills/` (dogfood).

## 4. Scope

Files (1)-(5) as in the draft: `release-verify.sh`, `publish-protocol.md` (.claude + .agents),
`release-runbook/SKILL.md` (.claude + .agents). v2 deltas land in the same 5 files.
Out of scope: `*sync` protocol, Blake completion-protocol check (residual gap, follow-up idea),
symlinks, IDEA card lifecycle (human/Alex after Gate 4).

## 5. Acceptance Criteria (Blake: verify independently; run in this order)

- **AC1** `bash -n .tad/hooks/lib/release-verify.sh` exits 0.
- **AC2** Clean state: `parity "$PWD"` exits **0**, prints PASS verdict.
- **AC3** Content drift (append line to an existing `.agents/skills` file): exit **1**, file NAMED,
  `DIRECTION: agents-newer (STOP)` printed (the edit is working-tree-only on the .agents side).
  `parity --fix "$PWD"` REFUSES (exit 1, names the path, changes nothing). Restore via
  `git checkout -- .agents/skills`.
- **AC4** Orphan file (create a new untracked file under `.agents/skills/` only): exit **1**, orphan
  NAMED (`Only in ...`), `DIRECTION: agents-newer (STOP)`; `--fix` REFUSES. Remove the orphan.
- **AC5** Claude-side drift (append line to a `.claude/skills` file, leaving `.agents` untouched):
  exit **1**, `DIRECTION: claude-newer`; `parity --fix "$PWD"` succeeds, re-verify exits **0**.
  Restore via `git checkout -- .claude/skills .agents/skills`.
- **AC6a** `parity "$(mktemp -d)"` exits **2** (missing dirs).
- **AC6b** No-arg `parity` exits **2**; usage output lists the parity mode (incl. `--fix`).
- **AC7** publish-protocol.md step3b sits between step3 and step3c; exit 0/1/2 branches handled
  SEPARATELY; exit 2 = ALWAYS HARD BLOCK; fix path commits ONLY `.agents/skills` (assert the text
  forbids `git add -A`); refusal path = STOP and ask human; re-run-step3 instruction present.
- **AC8** Runbook: `grep -n "step3b" .claude/skills/release-runbook/SKILL.md` — every hit is in a
  context that names the real `release-verify.sh parity` command (no dangling reference remains).
- **AC9** Regression: `version "$PWD" <current>` (no old) exits 0; `derive-sync-set.sh --dirs "$PWD"`
  exits 0; `git diff main -- .tad/hooks/lib/release-verify.sh` hunks are confined to the parity
  case + usage + CONTRACT header (no edits inside structural/version/freshness/migration blocks).
- **AC10** Script CONTRACT header documents parity exit codes 0/1/2 + DIRECTION semantics + the
  no-patch-downgrade asymmetry.
- **AC11 (FINAL — after all mutation ACs)** Working tree clean (`git status --porcelain` empty of
  `.claude/skills` / `.agents/skills` entries) AND `parity "$PWD"` exits **0**. This is the
  clean-tree final gate; do not cite earlier AC2 (code-reviewer P1-4).

## 6. Execution Notes for Blake

- Start from the draft (cherry-pick `75ef98c` or re-implement); then add v2 deltas (FR2/FR3 +
  step3b rewrite to call `--fix` + scoped-commit text + header asymmetry note + AC-driven runbook
  re-check). The draft's test approach for exit codes is reusable.
- DIRECTION heuristic: keep it simple and biased to STOP. `git status --porcelain` on the named
  paths + `git log -1 --format=%H -- <path>` comparison is sufficient; do NOT over-engineer
  mtime logic. When in doubt the answer is `agents-newer (STOP)`.
- Worktree `.claude/worktrees/codex-parity-step3b` can be removed after landing; delete the
  branch after merge.
- Layer 1 for task_type=bash/markdown: run AC1–AC11 directly (no build/test suite applies).
- Layer 2: spec-compliance + code-reviewer minimum.

## 7. Gate Requirements

- Gate 3 (Blake): Layer 1 = AC1–AC11 results; Layer 2 = independent expert review; Knowledge
  Assessment MANDATORY; completion report to
  `.tad/archive/handoffs/COMPLETION-20260610-codex-parity-step3b.md`.
- Gate 4 (Human + Alex): acceptance per AC list; update IDEA-20260610-agents-skills-auto-parity
  → promoted (Promoted To: landing commit); **capture the residual edit-time drift window as a
  new idea** (Blake-completion parity check) so the deferral is recorded, not lost.

---

## Gate 2 Result (2026-06-10)

| Item | Status | Note |
|------|--------|------|
| Architecture | ✅ Pass | Verify(detect-only)/fix(--fix guarded) layer split; gate composition with step3/3c/3d; mechanical DIRECTION signal — amended per 2-expert review (P0=0, all P1 incorporated in v2) |
| Components | ✅ Pass | 5 files scoped (§4); FR1–FR6 map one-to-one onto them; out-of-scope explicit |
| Functions verified | ✅ Pass | Anchors verified in repo: step3/step3c insertion point (2 hits), sibling modes structural/version/migration (3 hits), runbook step3b refs (2 hits), derive-sync-set.sh exists, draft commit 75ef98c exists, both skills trees exist |
| Data flow | ✅ Pass | drift detect → DIRECTION compute → fix/refuse → scoped commit → re-verify → step3 re-run (FR1–FR4); failure paths (exit 2, refusal, fix-failure) each have a defined terminal action |

**Expert review evidence:** code-reviewer + backend-architect (2026-06-10), both P0=0;
P1 findings (mechanical direction guard, in-script --fix, scoped commit, orphan AC,
clean-tree final AC, residual-gap logging, no-patch-downgrade doc) all incorporated into v2.

**Gate 2 verdict: PASS**

---

**Handoff Created By:** Alex (Agent A)
**Status:** ready-for-blake (v2, expert-reviewed, Gate 2 PASS)
