# Phase 1 Design Review — code-reviewer

**Handoff:** HANDOFF-surplus-o1-landscape-refresh-2026q3.md
**Reviewer:** code-reviewer (AC executability / grep-regex correctness / scope-lock)
**Date:** 2026-07-06
**Verdict:** CONDITIONAL — 1 P0 (blocking, false-fail on scope-lock AC), 2 P1, 2 P2

---

## Summary

Well-structured research handoff. Frontmatter is complete and correct, the file
list matches the requirements, and the design (single-chain research flow with a
WebSearch degrade branch) is internally coherent. I verified the ground-truth
claims against the repo (CLI binary present, REGISTRY.yaml entry at L54-61 with
`status: dormant`/`source_count: 45`, OBJECTIVES.md O1 KR1-KR3 all 🔄, target dir
absent) — all accurate.

The problems are concentrated in §9.1's Verification Methods: two AC commands do
not mechanically verify what their Expected Evidence claims, and one of them will
false-fail a correct implementation. Since Gate 3 "executes each row" literally,
these are verification-integrity defects, not cosmetic ones.

---

## P0 (Blocking)

### P0-1 — AC8 scope-lock false-fails on the YOLO workflow's own evidence artifacts

AC8 command (pipes un-escaped):
```
git status --porcelain | grep -vE '(framework-landscape|research-notebooks/REGISTRY.yaml|\.tad/evidence/traces/|\.tad/active/)' | wc -l   # expected 0
```
The exclusion list omits `.tad/evidence/yolo/`. But this Epic's evidence dir is
exactly `.tad/evidence/yolo/surplus-o1-landscape-refresh-2026q3/`, and the YOLO
workflow writes review artifacts there (this design review, the impl-review, gate
reports) BEFORE Gate 3 runs. Those are untracked files that `git status --porcelain`
lists and the regex does NOT exclude.

Reproduced:
```
printf '?? .tad/evidence/yolo/.../phase1-design-review-cr.md\n M .tad/research-notebooks/REGISTRY.yaml\n' \
 | grep -vE '(framework-landscape|research-notebooks/REGISTRY.yaml|\.tad/evidence/traces/|\.tad/active/)' | wc -l
# => 1   (expected 0)  → AC8 FAILS even though Blake changed nothing out of scope
```
Impact: a fully correct implementation is marked FAIL at Gate 3 → blocking.

Fix: add `\.tad/evidence/yolo/` to the exclusion alternation (and, for symmetry
with §7, keep the intent "only findings + REGISTRY + trace/session/yolo byproducts").
```
git status --porcelain | grep -vE '(framework-landscape|research-notebooks/REGISTRY\.yaml|\.tad/evidence/traces/|\.tad/evidence/yolo/|\.tad/active/)' | wc -l
```

---

## P1 (Should Fix)

### P1-1 — AC5 counts matching LINES, not distinct KRs; false-fails a valid one-line assessment

AC5 command:
```
sed -n '/## O1 KR Status Assessment/,/^## /p' FINDINGS | grep -c 'KR[123]'   # expected >=3
```
`grep -c` counts matching lines. Expected Evidence says "KR1/KR2/KR3 各至少 1 次
出现". Reproduced on a valid findings file whose assessment reads
"KR1, KR2 and KR3 all remain in progress" on one line:
```
sed -n '/## O1 KR Status Assessment/,/^## /p' f.md | grep -c 'KR[123]'          # => 1  (FALSE FAIL)
sed -n '/## O1 KR Status Assessment/,/^## /p' f.md | grep -o 'KR[123]' | sort -u | wc -l  # => 3  (correct)
```
It also false-PASSES garbage ("KR1" repeated on 3 lines with no KR2/KR3).
Fix: `... | grep -o 'KR[123]' | sort -u | wc -l`  (expected `3`).

### P1-2 — AC11 has no deterministic command (manual "计数其输出条目")

AC11 Verification Method is `notebooklm source list -n ...` with "计数其输出条目"
and Expected `>=50`. There is no concrete count command, so Gate 3 cannot execute
the row mechanically — it depends on live cloud state and human counting. This is
acceptable as a live check but should be pinned, e.g.
`notebooklm source list -n <id> | grep -c '<per-source-line-pattern>'` with the
pattern confirmed against real `source list` output during preflight, else the row
is inherently non-reproducible. (Degrade path already handled via
NOT_APPLICABLE_WITH_REASON — good.)

---

## P2 (Nice to Have)

### P2-1 — AC4 verifies `Sources:` line COUNT, not point↔source pairing
`grep -c 'Sources:' >=5` passes if five `Sources:` lines are dumped at the end
detached from any synthesis point. The handoff already mitigates via a Gate-3
manual spot-check note ("一一配对，非堆在文末"), so this is only a hardening
suggestion — consider requiring each `Sources:` to be preceded by a numbered/bulleted
claim, verifiable with an awk adjacency check if you want it mechanical.

### P2-2 — AC10 only scans `head -20`; retrieval date must live in the header
Fine as written, but flag to Blake that the retrieval date / `Degraded-Mode:`
marker MUST be in the first 20 lines or AC10 false-fails despite the date existing
lower in the file. A one-line note in FR4/§4.2 ("检索日期与降级标记必须在文件头20行内")
removes the ambiguity.

---

## Passed Checks (no action)

- **Frontmatter**: `task_type: research`, `e2e_required: no`, `research_required: yes`
  all filled and correct for a zero-code research task. `git_tracked_dirs: []` is
  justified (evidence/doc artifacts verified by direct file-existence ACs, not the
  git-tracked smoke alarm) — consistent with the AC design.
- **File list completeness**: §7.1 (create findings) + §7.2 (modify REGISTRY.yaml)
  match FR4/FR5 and NFR3's scope-lock exactly. No missing target files; source-add
  is an external cloud mutation, correctly out of the repo file list.
- **Design coherence**: FR1-FR6 map cleanly onto §4.1's flow diagram; the degrade
  branch is symmetric (same product structure, `Degraded-Mode:` marker, notes-only
  registry, status stays `dormant` so registry never lies about cloud) and each
  degrade case has a matching AC (AC6 title-suffix, AC9 `-A9`+`Degrade`, AC10 marker).
- **Ground-truth accuracy**: every §2/§7.3 claim I could check against the repo is
  accurate (CLI path, REGISTRY L54-61 baseline, OBJECTIVES O1 status, absent dir).
- **AC6 / AC9 regex**: verified correct — `^## Deep-Ask Round [12]` matches the
  degraded `(Degraded: WebSearch)` suffix; `-A6`/`-A9` windows cover status/
  last_queried/notes lines as intended (=2 and Degrade=1 respectively).

---

## Recommended Next Steps
1. Fix P0-1 (add `\.tad/evidence/yolo/` to AC8 exclusion) — required before Gate 3.
2. Fix P1-1 (AC5 → distinct-count) and P1-2 (pin AC11 count command).
3. Optional P2-1/P2-2 hardening notes to Blake.
