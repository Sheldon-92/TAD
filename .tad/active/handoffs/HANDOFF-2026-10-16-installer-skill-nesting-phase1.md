---
dispatch_id: p1-y3-1
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)

**From:** Alex (dispatched by Cora, step Y3) | **To:** Blake | **Date:** 2026-10-16
**Project:** TAD | **Task ID:** TASK-20261016-001 | **Handoff Version:** 4.0.1
**Epic:** EPIC-20261016-installer-skill-nesting.md (Phase 1/1)
**Supersedes:** N/A

Short handoff by design: the human controls cost. Minimal change, no refactor.

---

## Gate 2: Design Completeness

Not claimed here. Gate 2 = the two independent design reviews Cora dispatches next (Y3b/Y4). No expert review was run by Alex.

## Handoff Checklist (Blake)
- [ ] Read all sections, incl. Project Knowledge (§1.5)
- [ ] §9.1 rows are the Gate 3 checklist; each command was dry-run (see §6.7)

---

## 1. Task Overview

### 1.1 What We're Building
A fix to `tad.sh` so that installing/updating over an existing `.agents/skills/<name>/` copies the release's files **into** that directory (flat) on both BSD and GNU `cp`, repairs an already-nested `<name>/<name>/`, and makes the post-install self-check fail on any remaining nesting. Plus the one sibling copy site with the same shape (`.tad/portable-extract.sh`).

### 1.2 Why
Confirmed installer bug (cause in §2.2). On GNU `cp` every non-pack skill (alex, blake, cora, gate, tad-*, ... 39 dirs) never updates after first install: the new release lands in `.agents/skills/<name>/<name>/`, the flat files the harness reads stay stale. Matches the downstream symptom (`alex/alex/references/conductor-dispatch-mode.md`, stale flat `alex/SKILL.md`).

### 1.3 Intent Statement
- Real problem: downstream projects on GNU `cp` silently stop receiving skill updates.
- Not to do: no replace-vs-merge redesign (merge is kept; files deleted upstream are still left behind — out of scope), no change to pack customization logic, no change to the Claude projection/adoption code, no downstream project touched, no push/tag/release/version bump/CHANGELOG release entry, no model test runs.

### 1.4 Offload Log
N/A.

### 1.5 Project Knowledge (Blake must read)
- `.tad/project-knowledge/patterns/shell-portability.md` — BSD/GNU differences; bash 3.2.
- `.tad/project-knowledge/patterns/release-sync.md` — copy paths at every granularity; `diff -rq`/`cmp` as completeness proof.
- principles.md "Deny-List Beats Allow-List ... diff-r is the Universal Omission Catcher" — verify by byte comparison, not by existence.
- Installer guard: every `rm -rf`/`rm -f`/`rmdir`/`-delete` text in `tad.sh` (including in comments) must carry a same-line `# RM-OK:<unique-id>` marker, else `release-verify.sh installer-destructive-guard` fails. Do not write those verbs in comments.

---

## 2. Background Context

### 2.1 Previous Work
`copy_pack_skill_smart` Case 1b (tad.sh:1334) already uses the portable `cp -R "$src_dir/." "$tgt_dir/"`. The Claude adoption verifier (tad.sh:4357) already tolerates "Self-nested duplicate (old cp -r onto an existing directory)" — the defect was seen before; the copy site was never fixed.

### 2.2 Current State (cause, confirmed by Alex 2026-10-16)
- tad.sh:1615 `for skill_dir in "$src"/.agents/skills/*/; do` — `skill_dir` ends in `/`.
- tad.sh:1654 (non-pack branch) `cp -r "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"` — copies a directory onto a possibly existing directory.
  - BSD `cp` (macOS `/bin/cp`): trailing `/` on the source = copy contents → flat merge.
  - GNU `cp`: trailing `/` is ignored → copies the dir **into** the existing one → `<name>/<name>/`.
- No GNU `cp` on this Mac (no `gcp`, no coreutils, no docker). GNU semantics shown with a PATH shim that strips trailing `/` from source operands and execs `/bin/cp` (BSD without a trailing slash behaves as GNU does for this form). Shim (Blake: reuse verbatim; keep it in the evidence dir):
  ```bash
  #!/bin/bash
  # GNU-cp semantics shim: GNU ignores a trailing "/" on a source operand; BSD treats it as "copy contents".
  a=(); for x in "$@"; do case "$x" in -*) a+=("$x");; */) while [ "${x%/}" != "$x" ] && [ "$x" != / ]; do x="${x%/}"; done; a+=("$x");; *) a+=("$x");; esac; done
  exec /bin/cp "${a[@]}"
  ```
- Alex reproduction with the real installer (`tad.sh --source <repo>`, target `.tad/version.txt` lowered to 4.0.0 to force an update):
  - GNU shim: second run rc=0, self-check "passed: 92 derived paths", and **39** `<name>/<name>` dirs (every non-pack skill incl. `_archived`, `alex`, `blake`, `cora`); the 26 registry packs stayed flat.
  - BSD: 0 nested; `alex/references/conductor-dispatch-mode.md` byte-identical.
  - BSD with a pre-seeded `alex/alex/` + stale flat `alex/SKILL.md`: flat file refreshed, `alex/alex` **left in place** (no repair today).
- Packs: Case 1a (tad.sh:1326-1329) copies only when the target does not exist (safe on both); Case 1b portable; Cases 2+ per-file. Not affected.
- Verify loop (tad.sh:1904-1925) only checks `-d "$TARGET_SKILL_DIR/$skill_name"` → cannot see nesting.
- Rollback: `take_rollback_snapshot` (tad.sh:2419, call 5614) snapshots `.agents/skills` (tad.sh:2444) before `copy_framework_files` (5647/5746/5833) → a removal inside the skill loop is covered by rollback.

### 2.3 Dependencies
None.

---

## 3. Requirements

### 3.1 Functional
- FR1 Portable copy: the non-pack branch copies the skill's contents into `$TARGET_SKILL_DIR/$skill_name/` (create it if absent) so the result is flat under BSD and GNU.
- FR2 Repair: before copying a skill (after the existing `local/` and project-owned skips), if `$TARGET_SKILL_DIR/$skill_name/$skill_name` is a real directory (not a symlink) **and** the source has no `$src/.agents/skills/$skill_name/$skill_name`, remove it (log one info line). Applies to pack and non-pack skills alike (forked packs included: the nested copy is an installer artifact).
- FR3 Verify: in `verify_install_complete`'s skill loop, for each checked skill that is not `local` and not project-owned (same predicates as the copy loop), a remaining `$TARGET_SKILL_DIR/$skill_name/$skill_name` directory (with no same-named dir in the source) logs `✗ NESTED skill: ...` and counts as missing (→ existing FAILED path → rollback).
- FR4 Sibling site: `.tad/portable-extract.sh:78-79` (`cp -r "$src" "$dst"` with `.tad/codex/` onto a possibly existing `codex-tad-bundle/.tad/codex/`) gets the same portable form.

### 3.2 Non-Functional
bash 3.2 compatible; no new dependency; `note_created_top` behaviour unchanged (still records a skill dir that did not exist pre-run).

---

## 4. Technical Design

### 4.2 Component Specifications (not prescriptive on exact text; prescriptive on shape)
tad.sh skill loop, replacing line 1654 and adding the repair just before the `if is_pack_skill` at 1652:
```bash
            # Repair a self-nested copy left by an older installer under GNU cp
            # (a copy of the skill INSIDE itself). Never when the source really has one.
            if [ -d "$TARGET_SKILL_DIR/$skill_name/$skill_name" ] && [ ! -L "$TARGET_SKILL_DIR/$skill_name/$skill_name" ] \
               && [ ! -e "$src/.agents/skills/$skill_name/$skill_name" ]; then
                log_info "  → Repairing nested skill copy: $skill_name/$skill_name"
                rm -rf "$TARGET_SKILL_DIR/$skill_name/$skill_name" # RM-OK:skill-self-nested-repair
            fi
            ...
            else
                # Copy CONTENTS ("dir/.") so an existing target is merged in place on BSD and GNU cp.
                mkdir -p "$TARGET_SKILL_DIR/$skill_name"
                cp -R "${skill_dir%/}/." "$TARGET_SKILL_DIR/$skill_name/"
            fi
```
- Keep `_skill_new` computed **before** the `mkdir -p` (it already is, line 1650) so `note_created_top` still fires only for new dirs.
- `cp -R` (uppercase) matches the file's convention (tad.sh:823 comment: BSD `-r` dereferences dangling symlinks).
- Verify loop (after the `-d` check at ~1921): nested check per FR3. Use the same `local` / `ownership: project-owned` predicates as tad.sh:1631-1640.
- portable-extract.sh dir branch: `mkdir -p "$dst"; cp -R "${src%/}/." "${dst%/}/"`.

### 4.3-4.5 N/A.

---

## 5. Mandatory Questions
- MQ1 history search: done (§2.1, tad.sh:4357; Case 1b precedent).
- MQ2 functions exist: `log_info`, `is_pack_skill` (1097), `copy_pack_skill_smart` (1319), `verify_install_complete` (1848), `note_created_top`, `take_rollback_snapshot` (2419) — all present.
- MQ3 data flow: loop source path → target path, unchanged except copy form + repair + verify.
- MQ4/MQ5: N/A (no UI, no state sync).

---

## 6. Implementation Steps

### Phase 1 (one step, ~1h)
1. Copy the shim into `.tad/evidence/yolo/installer-skill-nesting/gnu-cp-shim/cp` (chmod +x).
2. Pre-fix: record the reproduction (AC1) into `.tad/evidence/yolo/installer-skill-nesting/phase1-repro.md` (commands + counts, GNU shim and BSD).
3. Edit tad.sh (FR1-FR3) and portable-extract.sh (FR4).
4. Post-fix: run the §9.1 scenarios; record outputs in the same evidence file (section "after fix").
5. Run guards/tests per §9.1; one local commit (no push).

### 6.7 AC Dry-Run Log (Alex step1d, 2026-10-16)
Throwaway targets were made under the session scratchpad (`$S`); source = repo root (`$R`); `TAD_BACKUP_ROOT=$S/bk`; each target `git init -q`.
- AC1: ✅ pre-impl-verifiable, ran. GNU shim, install then update (version lowered to 4.0.0): `find .agents/skills -mindepth 2 -maxdepth 2 -type d | awk -F/ '$3==$4' | wc -l` → `39`; self-check line `✓ Self-check passed: 92 derived paths` (i.e. undetected).
- AC2 (BSD half): ✅ ran pre-fix → `0`, `cmp` of conductor-dispatch-mode.md OK. GNU half: post-impl (pre-fix value is 39, so the row discriminates).
- AC3: ✅ ran pre-fix under BSD → `alex/alex still present` (row discriminates; expected to flip post-fix).
- AC5 guard: ✅ `bash .tad/hooks/lib/release-verify.sh installer-destructive-guard .` → `VERDICT: installer-destructive-guard PASS (exit 0)` (Marked 66) pre-impl; post-impl must stay PASS with one more marker.
- AC5 `bash -n tad.sh` → syntax-ok pre-impl.
- AC4/AC6/AC7: post-impl; commands syntax-checked.
- Note: a plain second run with the same version prints "Nothing to do" — lowering `.tad/version.txt` in the target is what forces the update path (used in all scenarios).

---

## 7. File Structure

### 7.1 Files to Create
- `.tad/evidence/yolo/installer-skill-nesting/phase1-repro.md` (evidence)
- `.tad/evidence/yolo/installer-skill-nesting/gnu-cp-shim/cp` (evidence helper)

### 7.2 Files to Modify
- `tad.sh` — skill loop 1613-1660 (repair + portable copy), verify loop 1904-1925 (nested check).
- `.tad/portable-extract.sh` — lines 78-79.

### 7.3 Grounded Against (Alex step1c, actually read)
- tad.sh:1300-1345 (`copy_pack_skill_smart`), 1600-1670 (skill loop), 1810-1830, 1895-1930 (verify loop), 2060-2075 (FAILED → return 1), 2395-2450 (snap_one, take_rollback_snapshot), 2535-2580 (restore), 4340-4370, 4990-5010, 5780-5800; grep of every `cp` in tad.sh.
- `.tad/portable-extract.sh:1-85`; `.tad/hooks/lib/migration-engine.sh:645-662`; `.tad/hooks/lib/release-verify.sh:84-100,780-840`; `.tad/tests/installer-data-safety-fixture.sh:430-470`; `.tad/tests/run-all.sh:1-40`.
- Sibling sites judged **not** affected (destination fresh or removed first, or contents form): tad.sh:826 (fresh backup dir), 1328 (target absent), 1334/1597 (`dir/.` form), 2408 (fresh mktemp snap), 2548/2572 (stage removed first), 5002 (fresh archive tree), 5790 (name loop guarantees absent), 5816-5825 (glob contents); migration-engine.sh:661 (refuses existing dst). Only tad.sh:1654 and portable-extract.sh:79 have the shape.

---

## 8. Testing Requirements
No model test runs. No new test framework. The FR3 self-check is the permanent regression guard (every install checks itself). Existing offline suite: `bash .tad/tests/run-all.sh` must stay PASS; the slow installer fixtures (`TAD_TEST_FULL=1`) — run `installer-data-safety-fixture.sh` only if time allows and note it; do not add cases.

### 8.3 Edge Cases
- Source legitimately has `<n>/<n>` → no repair, no NESTED warning (guarded by the source check).
- Nested path is a symlink → not removed.
- `local/` and project-owned skills → untouched (existing skips run before the repair).
- Fresh install (target absent) → `mkdir -p` + contents copy; `note_created_top` still records it.

---

## 9. Acceptance Criteria
- AC1 Cause evidence with tad.sh line numbers and the pre-fix reproduction (GNU shim and BSD), shim named as the GNU method.
- AC2 Post-fix, install + forced update into a fresh throwaway target: 0 nested dirs and conductor-dispatch-mode.md byte-identical — under BSD **and** GNU shim.
- AC3 Post-fix, pre-seeded `alex/alex/` + stale flat `alex/SKILL.md` → after forced update: no `alex/alex`, flat `alex/SKILL.md` byte-identical to source — under BSD **and** GNU shim.
- AC4 Protected content untouched: a pre-existing `.agents/skills/local/` file and a project-owned skill survive the update byte-identical.
- AC5 `bash -n tad.sh` OK; installer-destructive-guard PASS; `run-all.sh` PASS.
- AC6 Self-check catches nesting: with the repair disabled in a scratch copy of tad.sh (or by planting a nested dir after copy in a scratch copy), the self-check prints `NESTED` and the run fails. (Scratch copy only; the repo tad.sh is not mutated for this.)
- AC7 No downstream project modified; no push/tag/release; one local commit.

## 9.1 Spec Compliance Checklist (Gate 3 runs each row)

Runnable forms below: in table cells `\|` is markdown escaping — run with a bare `|`. Setup for rows 2-4 (per scenario, fresh dir each time): `T=$(mktemp -d); cd "$T" && git init -q . && TAD_BACKUP_ROOT="$T.bk" bash "$R/tad.sh" --source "$R" --platform codex --yes; echo 4.0.0 > .tad/version.txt; TAD_BACKUP_ROOT="$T.bk" bash "$R/tad.sh" --source "$R" --platform codex --yes; echo rc=$?` — GNU variant prefixes both runs with `PATH="$R/.tad/evidence/yolo/installer-skill-nesting/gnu-cp-shim:$PATH"`.

| # | Requirement | Verification Method | Expected Evidence | Verified Output |
|---|---|---|---|---|
| 1 | AC1 cause + repro | `grep -n -e 'tad.sh:1654' -e 'tad.sh:1615' -e 'shim' .tad/evidence/yolo/installer-skill-nesting/phase1-repro.md` | ≥3 lines; repro shows 39 nested pre-fix (GNU), 0 (BSD) | pre-impl repro by Alex: 39 / 0 (§6.7); file post-impl |
| 2 | AC2 flat, BSD + GNU | after setup: `find .agents/skills -mindepth 2 -maxdepth 2 -type d \| awk -F/ '$3==$4' \| wc -l` and `cmp "$R/.agents/skills/alex/references/conductor-dispatch-mode.md" .agents/skills/alex/references/conductor-dispatch-mode.md && echo same` | `0` and `same`, rc=0, both variants | BSD pre-fix: 0/same; GNU pre-fix: 39 (post-impl) |
| 3 | AC3 repair, BSD + GNU | after first install: `cp -R .agents/skills/alex "$T.a" && mv "$T.a" .agents/skills/alex/alex; echo old > .agents/skills/alex/SKILL.md; echo 4.0.0 > .tad/version.txt`, update, then `test ! -e .agents/skills/alex/alex && cmp -s "$R/.agents/skills/alex/SKILL.md" .agents/skills/alex/SKILL.md && echo repaired` | `repaired`, rc=0, both variants | BSD pre-fix: alex/alex still present (post-impl) |
| 4 | AC4 protected | before update: `mkdir -p .agents/skills/local/x && echo mine > .agents/skills/local/x/f; mkdir -p .agents/skills/alex-lite && printf -- '---\nownership: project-owned\n---\nmine\n' > .agents/skills/alex-lite/SKILL.md`; after update: `cat .agents/skills/local/x/f; tail -1 .agents/skills/alex-lite/SKILL.md` | `mine` / `mine` | post-impl |
| 5 | AC5 | `bash -n tad.sh && bash -n .tad/portable-extract.sh && bash .tad/hooks/lib/release-verify.sh installer-destructive-guard . \| tail -1 && bash .tad/tests/run-all.sh \| tail -1` | `VERDICT: installer-destructive-guard PASS (exit 0)`, `RUN-ALL: PASS` | guard PASS pre-impl (Marked 66) |
| 6 | AC6 self-check catches nesting | scratch copy of tad.sh with the repair line removed, run on a pre-seeded nested target: `grep -c 'NESTED skill' <log>`; rc≠0 | ≥1, rc≠0 | post-impl |
| 7 | FR4 sibling | `grep -n 'cp -R "${src%/}/."' .tad/portable-extract.sh` and `grep -n 'cp -r "\$skill_dir"' tad.sh \| wc -l` | 1 line; `0` | post-impl |
| 8 | AC7 | `git show --stat --oneline HEAD` lists only tad.sh, .tad/portable-extract.sh, evidence files; `git tag --points-at HEAD` empty; no push | as stated | post-impl |

## 9.2 Expert Review Status
Not run by Alex (dispatch rule). Cora dispatches two design reviewers.

---

## 10. Important Notes

### 10.1 Critical Warnings
- Do not put `rm -rf` / `rm -f` / `rmdir` / `-delete` text in comments in tad.sh (the guard counts lines, not calls).
- Every scenario runs in a throwaway dir with `TAD_BACKUP_ROOT` outside the repo; never run tad.sh with cwd = the repo.
- Do not mutate the repo tad.sh to test AC6; use a scratch copy.

### 10.2 Known Constraints
- Merge semantics kept: files removed upstream from a skill are not deleted downstream (pre-existing behaviour; out of scope).
- GNU shown by shim, not a real GNU `cp` (none available without installing packages; user rule forbids global installs). State this in the evidence.

### 10.3 Sub-Agent use
None needed.

---

## Alex template checks (step1b-1d)
- step1b frontmatter: task_type=code, e2e_required=no, research_required=no, dispatch_id=p1-y3-1 — valid.
- step1c grounding: every Files-to-Modify line range was read (§7.3); every sibling `cp` site in tad.sh enumerated by grep and classified.
- step1d AC dry-run: rows 2/3/5 run pre-impl with real output (§6.7); others syntax-checked, deferred to Gate 3.
- step1a: no capability pack loaded.
