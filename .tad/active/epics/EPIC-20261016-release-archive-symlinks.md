# Epic: Release archive carries the source repo's `.claude/skills` links — download install refuses v4.0.2

**Epic ID**: EPIC-20261016-release-archive-symlinks
**Created**: 2026-10-16
**Owner**: Cora
**Conductor**: Cora
**Tier**: handoff (one-phase Epic, Cora triage 2026-10-16)
**Budget**: estimate 10 subagent dispatches (intake, design, 2 design reviews, implementation, 2 implementation reviews, Gate 3, Gate 4, distillation); no model test runs. Then release 4.0.3 as a simple-tier task (~2 dispatches).
**Depth**: standard — Risk: reversible (repo files; the release itself is asked separately); blast radius: every downstream download install/update.
**Approved**: yes — "你来修，按 handoff 档，用 export-ignore，修完把轻量流程一起发 4.0.3。我告诉 PM 不用修了。" (2026-10-16)

---

## Objective
Make the official download install/update path work again. Since `99fe7f02` the source repo tracks 64 relative symlinks `.claude/skills/<name> -> ../../.agents/skills/<name>`; GitHub's tag archive carries them, and `tad.sh` `validate_tar_members` (tar-slip guard) rejects any link target with `..`, so every download install of v4.0.2 refuses the archive. Fix by keeping the links out of the release archive (`.gitattributes` `export-ignore`), leaving the security check as strict as it is, and adding a release-verify check so no `..`-target link enters a release archive again.

## Result contract
What the human gets: a local commit with the `.gitattributes` rule and the release-verify check; proof that an archive built the way GitHub builds it (`git archive` honours `export-ignore`) passes `validate_tar_members` and installs end to end into a throwaway project; the source repo's own `/cora` still works (links stay in the working tree). Then release 4.0.3 (with the lighter-flow commits), push/tag asked at the moment, and one real download install from GitHub after the tag.
Not wanted: loosening `validate_tar_members`; removing the links from the source repo; changes to downstream projects; model test runs.
Evidence of the defect: the human's two pasted reports (2026-10-16): 13 downstream repos updated via `--source` because the download path refuses; `tad.sh` `validate_tar_members` (dot-dot link target rejected).

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Keep links out of the release archive | ✅ Done | HANDOFF-2026-10-16-release-archive-symlinks-phase1.md | export-ignore + release-verify check + archive/install proof |

---

## Phase Details
(Filled by the Intake Alex subagent: `.tad/evidence/yolo/release-archive-symlinks/intake-details.md`.)

---

## Run
Pointer: phase 1 | step distill
Dispatched: p1-distill-1 -> .tad/evidence/yolo/release-archive-symlinks/distillation-report.md
Next: release 4.0.3 prep (simple tier), push/tag asked
Stopped: —
Owner: claude-code 2026-10-16

---

## Notes
- Cora's mistake recorded: `99fe7f02` was made without design or review; its later single review recommended KEEP; the download path was known untested and stated so in the 4.0.2 notes. That gap is where the defect shipped.
- Ownership: the human assigned the fix to Cora and tells the TAD PM agent not to fix it (2026-10-16).
