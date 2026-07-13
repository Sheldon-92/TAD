# Phase 1 Design Review — Architecture Lens

**Handoff**: HANDOFF-surplus-saveable-skills-from-conversation.md
**Reviewer**: Architecture (backend/framework-integration)
**Date**: 2026-07-05
**Verdict**: CONDITIONAL PASS — design is coherent and correctly scoped; 1 P1 blast-radius gap + 2 P2s to address before/at implementation.

## Domain auto-detection
Files to Modify = a single markdown skill file (`.claude/skills/save-workflow/SKILL.md`).
No frontend, API/DB, or auth files → **default: architecture / framework-integration review**.
The relevant "architecture" here is TAD's skill-file layout + sync/copy pipeline (tad.sh, derive-sync-set.sh) and the capture→retrieve knowledge loop.

## Grounding I verified independently (live repo, 2026-07-05)
- `.claude/skills/*/` is the registered form; the one flat file `doc-organization.md` is indeed absent from the harness skill list → the handoff's "flat `.md` not discovered" claim holds. The dir/SKILL.md deviation from the Epic's literal flat path is a **correct, grounded call**, not a preference.
- `trigger:` frontmatter field IS an established convention (`surplus/SKILL.md` L3 uses it) → FR1's `trigger:` line is fine, NOT non-standard. (Pre-empting a likely false positive.)
- tad.sh install loop (L785-812) iterates `for skill_dir in "$src"/.claude/skills/*/` and copies each directory; the only exclusion is `is_denied` against the **platform** deny-list (codex vs claude-code). There is **no deny-list entry for `.claude/skills/local`**. derive-sync-set.sh governs `.tad/*` dirs only — it does not cover `.claude/skills/`. Confirmed.

---

## P0 — none
The design does not block implementation. It is honestly grounded, scope-fenced, and the AC greps in §9.1 are runnable and mostly discriminative.

---

## P1-1 — `local/` isolation has NO mechanical backstop; in-repo dogfood clobbers downstream user data

**This is the strongest finding.** The entire isolation guarantee (NFR2/NFR3/§11) rests on one human convention: *"don't create `.claude/skills/local/` in the TAD source repo."* There is no mechanism enforcing it.

Failure path:
1. save-workflow ships as `.claude/skills/save-workflow/` → it IS synced to downstream projects (correct, intended).
2. The most likely place it gets **exercised/dogfooded is the TAD source repo itself** (that is where it's built and demoed).
3. First real invocation there runs FR6: `mkdir .claude/skills/local/ + README + <name>.md` **inside the source tree**.
4. Next `*publish`/`tad.sh` install copies `.claude/skills/*/` — `local/` is now a matched directory with no deny entry → it propagates downstream. `cp -R src/. tgt/` merges same-name files, so a source `local/README.md` **overwrites every downstream user's `local/README.md`** and seeds their captured-workflow dir with source content.

This is the exact failure class principles.md 2026-06-01 rates as **worse than omission**: *"leaking a zero-touch dir into the sync set CLOBBERS downstream project data."* §11 correctly diagnoses the copy-granularity trap but then chooses zero enforcement — relying on the same "just remember not to" discipline the framework's own lessons say fails.

`.gitignore` does NOT save this: `cp -R src/. tgt/` copies the working tree regardless of git tracking, so an untracked/ignored `local/` still gets copied.

**Recommended fixes (any one closes it; all are in-scope for a markdown-only deliverable except C):**
- **(A) Add a MUST guard to SKILL.md**: before Step 5 Write, detect "am I inside the TAD framework source repo" (presence of `tad.sh` + `.tad/hooks/lib/derive-sync-set.sh` at repo root). If yes → still allowed, but the generated `local/README.md` MUST carry a prominent "NEVER publish this directory — add a tad.sh deny entry before any release" banner, and the skill MUST surface that warning to the user at write time. (Pure instruction text, zero framework mutation.)
- **(B) Register a follow-up** in the Epic: add `.claude/skills/local` to tad.sh's skills deny-list (the `is_denied` path). This is the actual root fix but touches tad.sh (Epic-scoped-out) → make it an explicit tracked follow-up, not a silent gap.
- **Minimum acceptable**: promote this from a §11 rationale note to an explicit **Known Limitation + required follow-up** so it is not lost. Right now the risk is described but nothing owns closing it.

I would not let this ship as "isolation solved" — it is "isolation solved *as long as nobody ever runs the feature where it's developed*," which is precisely the fragile-convention pattern the codebase has been burned by twice.

---

## P2-1 — Capture is designed; retrieval is unspecified → write-only knowledge

§1.1 sells "a **discoverable**, reusable local workflow file" and FR3 spends real design budget deriving 3-6 trigger keywords into the generated `description:`. But §10.2 concedes flat `local/*.md` files are **not harness-registered**, so nothing ever reads that `description` — the trigger keywords are decorative in v1. Retrieval reduces to "user remembers the name and asks the agent to Read the file," and **no component teaches any agent that `local/` exists or to consult it**. save-workflow is capture-only; the read side is out of scope.

Net: this builds the write half of a capture→retrieve loop with the read half absent, which undercuts the stated success criteria. The handoff acknowledges the limitation, so this is P2 not P1 — but the design should:
- State plainly in SKILL.md/README that captured workflows are **not auto-discoverable in v1** and how to invoke one (by name/Read), so users aren't misled by the "discoverable" framing.
- Consider having the generated `local/README.md` double as a lightweight index (append a one-line entry per captured workflow) — a near-free retrieval affordance that keeps FR3's keywords useful. Optional, but it turns dead metadata into a working lookup.

---

## P2-2 — AC row 8 scope guard excludes too much; can mask stray writes

Row 8: `git status --porcelain | grep -vE '^\?\? \.claude/skills/save-workflow/|\.tad/(active|evidence)/' | grep -vE 'session-state'` → expects empty. The `\.tad/(active|evidence)/` exclusion whitelists **any** change anywhere under those two trees, not just this task's bookkeeping files. A stray edit to an unrelated handoff, epic, or evidence file would pass the "zero framework mutation" gate silently. Tighten to the specific expected paths (this handoff + this epic + this review dir), e.g. anchor to `surplus-saveable-skills-from-conversation`, so the guard actually discriminates the deliverable's footprint from collateral.

---

## Design strengths (keep)
- Grounding honesty is exemplary: the absent `phase1-grounding.md` is disclosed and grounding was redone against the live tree (§2.2/§7.3) — verified accurate.
- The dir/SKILL.md-vs-flat decision and the runtime-creation-vs-source-preseed decision are both grounded in real copy semantics, not taste (§4.1, §11).
- MUST rules for confirm-before-write, overwrite-guard, and variabilize correctly heed the "Judgment-Only Skill Files" and "Knowledge Forged at Distill" principles.
- AC greps are runnable and reproduce; §9.1 is a legitimate primary verification source, not paper acceptance.

## Summary for Conductor
No P0 blockers — Blake can implement. Before marking the phase accepted, close **P1-1** (add the in-repo guard MUST rule to SKILL.md, or register the tad.sh deny follow-up — do not leave isolation as an unenforced convention). P2-1 and P2-2 are cheap and worth folding into the same write.
