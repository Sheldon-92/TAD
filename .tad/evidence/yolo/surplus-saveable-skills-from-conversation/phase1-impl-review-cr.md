# Phase 1 Implementation Review — code-reviewer lens

**Task:** surplus-saveable-skills-from-conversation (YOLO Epic Phase 1/1)
**Reviewer:** code-reviewer
**Date:** 2026-07-06
**Deliverable:** `.claude/skills/save-workflow/SKILL.md` (173 lines)
**Implementation location:** isolated worktree `wf_296b021c-f0e-5`, commit `ef93bb5`
**Verdict:** ✅ PASS — 0 P0, 0 P1, 2 P2

---

## Scope of what was reviewed

- Handoff: `HANDOFF-surplus-saveable-skills-from-conversation.md` (FR1–FR6, NFR1–NFR4, §9.1 AC rows 0a–11)
- Completion report (in worktree): `COMPLETION-surplus-saveable-skills-from-conversation.md`
- Deliverable SKILL.md (worktree)
- Git commit scope + diff

Note: the deliverable is committed in an isolated worktree branch, NOT on `main`.
The main-repo `.tad/active/handoffs/COMPLETION-...md` path referenced by the review
task does not exist yet — the completion report lives in the worktree commit
(`ef93bb5`) alongside the deliverable. This is expected for a YOLO phase (Conductor
merges); flagged here only so the reviewer trail is unambiguous.

---

## AC re-verification (independently re-run, not trusted from report)

Every §9.1 grep was re-run against the worktree SKILL.md. All reproduce the
completion report's claimed outputs exactly:

| AC | Claimed | Re-run | Match |
|----|---------|--------|-------|
| 1 frontmatter (`---` / name=1 / description=1) | `---`/1/1 | `---`/1/1 | ✅ |
| 2 3-6 keywords + trigger rule | 1 / 5 | 1 / 5 | ✅ |
| 3 template (local:true / source / sections≥4) | 3 / 1 / 9 | 3 / 1 / 9 | ✅ |
| 4 confirm-before-write MUST | 3 | 3 | ✅ |
| 5 overwrite guard | 5 / 6 | 5 / 6 | ✅ |
| 6 variabilize/placeholder ≥2 | 6 | 6 | ✅ |
| 7 local/ + README | 9 / 2 | 9 / 2 | ✅ |
| 9 local/ not created in repo | 1 | 1 | ✅ |
| 11 length ≤300 | 173 | 173 | ✅ |

- **AC8 scope guard**: commit `ef93bb5` touches exactly 2 files — the deliverable
  and the completion report. `git diff --name-only` confirms zero framework files
  (alex/blake SKILL.md, CLAUDE.md, tad.sh, derive-sync-set.sh, `.tad/hooks`)
  changed. NFR2 honored.
- **AC9/NFR3**: `.claude/skills/local/` does NOT exist in the repo or worktree. Honored.
- **The frontmatter self-collision trap was handled correctly**: the generated-file
  template embedded in Step 3 is indented as a 4-space fenced block, so the
  template's own `description:` line does NOT match `grep -c '^description:'`
  (result stays 1 = the real frontmatter only). This was a genuine correctness
  risk that the implementer anticipated (report §7). Good.

## FR/NFR coverage (content-level, not just grep)

- FR1 ✅ valid frontmatter; `description` routes cleanly against future `*save-skill`
  ("workflow/steps we just did" vs "reusable pattern/rule"). `trigger:` line present.
- FR2 ✅ Step 1 Extract captures goal / ordered steps with concrete commands /
  inputs / outputs / gotchas, with an explicit "ACTUALLY performed (not idealized)"
  instruction — matches the anti-diary intent.
- FR3 ✅ Step 2 mandates 3-6 keywords derived from goal+step vocabulary, embedded in
  generated `description` `Triggers:` clause; prefers user's actual phrasing.
- FR4 ✅ exact template embedded verbatim; variabilize MUST rule present with a
  concrete before/after (`podcasts/EP04-colin/final/` → `{project_output_dir}`).
- FR5 ✅ Step 4 confirm-before-write as MUST, framed as choices (save/rename/edit/
  discard) not a yes/no rubber-stamp — correctly applies the AI/Human Judgment
  Domain Awareness principle.
- FR6 ✅ Step 5 write path + runtime `local/` creation + README + overwrite guard
  ("STOP and ask … never silently overwrite … REFUSE without explicit confirmation").
- NFR1 ✅ no scripts/hooks; NFR2 ✅ zero framework mutation; NFR3 ✅ no source-repo
  `local/`; NFR4 ✅ 173 lines (within 150-250 target).
- §8.3 edge cases ✅ all four encoded in the "Edge cases" behavior table.

## Historical-lesson adherence (Project Knowledge)

- **Judgment-Only Skill Files** (constraint rules NOT mechanical): all constraint
  rules are written in MUST/MUST NOT voice in a dedicated "Constraints (MUST)"
  block + inline — not weakened. ✅
- **Deny-List / copy-granularity sync isolation**: the design correctly does NOT
  pre-create `local/` in the source repo (would be clobbered by tad.sh's
  `cp -R src/. tgt/` directory copy). Runtime-only creation. ✅
- **Knowledge Forged at Distill (anti-diary)**: variabilize MUST rule + "a workflow
  that can only replay one specific session is a diary, not a skill" is present. ✅

## `trigger:` frontmatter key — checked, NOT a defect

`trigger:` is an existing repo convention (the `surplus` skill uses the same key),
so it is not dead/invented metadata. Consistent with §2.2 grounding.

---

## Findings

### P0 (must fix): none

### P1 (should fix): none

### P2 (consider)

- **P2-1 — Structural validation only; no behavioral proof the skill captures a
  usable workflow.** Every AC is a grep/string-presence check. Per the project's
  own YOLO-audit "Validation Theater" principle, greps confirm the file contains
  the right words, not that invoking `*save-workflow` actually reconstructs a
  correct, variabilized, reusable capture. The handoff consciously deferred real
  dogfood to post-Gate-4 natural use (§8.2, to avoid fake e2e), so this is an
  accepted tradeoff — but the behavioral gap is real and should be closed by one
  live capture-and-replay dogfood before this skill is relied on. Not blocking.

- **P2-2 — `local/` files are not harness-registered (documented v1 limitation).**
  The skill's own "Known behavior" section states files under `.claude/skills/local/`
  are NOT auto-registered as callable skills (not `dir/SKILL.md` form); v1 usage is
  "user mentions name/keyword → agent Reads the file". This is honestly documented
  and out of scope per the handoff, but it means the captured "skill" is discoverable
  only if the user or agent remembers to look — the trigger keywords in the generated
  `description` are inert to the harness router. Worth a future promotion/registration
  path (already noted out-of-scope). Informational.

---

## Conclusion

Implementation faithfully satisfies all FR1–FR6 / NFR1–NFR4 and every §9.1 AC row;
independently re-run greps match the completion report byte-for-byte. Diff scope is
exactly the two claimed files with zero framework mutation. No bugs, no security
surface (pure instruction markdown, no scripts/API), no regressions. The two P2s are
accepted-tradeoff / out-of-scope items, not defects. **PASS.**
