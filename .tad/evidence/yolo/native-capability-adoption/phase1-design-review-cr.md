# Phase 1 Design Review (code-reviewer lens) — precompact-session-state-hook

- **Handoff**: `.tad/active/handoffs/HANDOFF-20260712-precompact-session-state-hook.md` (v2)
- **Reviewer**: code-reviewer (RE-VALIDATION vote on already-expert-reviewed v2)
- **Date**: 2026-07-13
- **Verdict**: **APPROVE-WITH-NITS** — no P0. Design is coherent, file list complete, ACs largely
  mechanically verifiable. One P1 (AC5 filename-collision gap) and several P2 clarifications.

The v2 handoff already integrated 6 P0 + 8 P1/P2 from the first expert pass (§9.2). I verified each
claim against actual code (`startup-health.sh`, `lib/common.sh`, `.gitignore`, `CLAUDE.md §4.5`,
settings.json state per grounding). The audit trail holds up. Findings below are NEW, not re-litigation.

---

## Focus 1: File list completeness — PASS

All files that need changing are enumerated across FR/T-tasks and confirmed against real state:

| File | Task | Real-state verified |
|------|------|---------------------|
| `.tad/hooks/precompact-session-snapshot.sh` (new) | T2 | N/A (new); dir `.tad/hooks` in `production_dirs` ✓ |
| `.claude/settings.json` (add PreCompact) | T3/FR5 | Confirmed no PreCompact key exists (grounding + MQ1 grep 0 hits) ✓ |
| `.gitignore` (+`.tad/active/precompact/`) | T3/FR8 | Confirmed tail has `.tad/memory/` block; append point clear ✓ |
| `.tad/hooks/startup-health.sh` (compact branch) | T4/FR4 | Read L14-19: guard is exactly as grounding describes ✓ |
| `CLAUDE.md §4.5` (three-layer model) | T6/NFR | Read L47-59: current 2-layer text present, annotate target valid ✓ |
| `.tad/active/precompact/` (new dir) | T2 | Confirmed absent ✓ |
| session-state.md template tail-note | T6 | Doc-only add ✓ |

No missing production file. `output_response`/`output_empty` single-call contract (MQ2) verified in
`common.sh` L37-60 — the FR4 compact branch calling `output_response "SessionStart" ...; exit 0`
respects the "exactly one output call per path" contract. **Complete.**

---

## Focus 2: AC verifiability — mostly PASS (one P1)

Each AC mapped to a concrete command. AC1/AC2/AC3/AC4/AC6/AC7/AC8/AC9 are mechanically checkable as
written (cp+diff, grep -F, byte-diff baseline, line-set diff, file existence). Strong.

### P1-1 (cr): AC5 concurrency test collides on filename — assertion may be un-satisfiable as written
- **Where**: FR1 filename `snapshot-{YYYYMMDD-HHMMSS}-{sid8}.md`; AC5 "同一 stdin 并发 20 个后台进程".
- **Problem**: Same stdin → same `sid8` AND (within one second) same `HHMMSS` → all 20 processes
  compute the **identical target filename**. The design's own coherence claim ("每进程独立文件名,
  no last-writer semantics") is FALSE for the AC5 test: 20 procs racing to `mv` onto ONE path is
  precisely a last-writer race. AC5's per-file assertion ("每个产出文件要么不存在要么完整") then
  reduces to "there is exactly 1 file and it's complete" — which tests torn-write of a single `mv`
  (atomic on same-filesystem POSIX rename), not the 20-way scenario the AC describes. The AC passes
  trivially but does NOT exercise what it claims to.
- **Two independent things to fix (pick one, Blake's call at impl)**:
  1. **Make filename collision-free for the test**: append `$$`/PID or a temp-mktemp suffix to the
     temp file (already implied by FR7) AND to the final name, OR
  2. **Re-scope AC5 honestly**: state that same-stdin/same-second collapses to one target path by
     design, so AC5 verifies (a) the single surviving file is complete (atomic `mv`) and (b) no
     `snapshot-*.md.tmp` / half-file residue remains. Drop the "20 files" mental model.
- **Why P1 not P0**: torn-write safety (the real goal) is still achieved by temp→`mv`; this is an
  AC-precision defect, not a design-soundness defect. But left as-is it's an AC that "passes" without
  proving its stated property — exactly the validation-theater failure mode this repo warns against
  (principles.md YOLO audit). Fix the AC text or the filename before T5.

### P2-1 (cr): AC4 pruning vs AC5 concurrency ordering unspecified
- FR6 prunes "after successful write, keep newest 5". If AC5's 20 procs each prune concurrently,
  two procs can `rm` the same victim (harmless — `rm` of missing file, and FR6 says delete-failure
  ≠ block). Worth a one-line note in FR6 that concurrent prune races are benign (rm idempotent,
  exit 0 regardless). Non-blocking; just prevents a reviewer at Gate 3 from flagging it.

### P2-2 (cr): AC3 "把脚本内 git 调用临时改为不存在命令" mutates the script under test
- The fault-injection method edits the production script. Cleaner + more repeatable: inject via a
  stubbed `PATH` (prepend a dir with a `git` that `exit 1`), leaving the script byte-stable. Either
  works; PATH-stub avoids "did we fully revert the edit?" doubt and pairs with AC7's byte-identical
  requirement. Suggestion only.

---

## Focus 3: Frontmatter correctness — PASS

- `task_type: code` ✓ (shell hook implementation — correct; not a doc/research task).
- `epic` + `phase: 1` ✓ consistent with EPIC-20260712-native-capability-adoption.
- `production_dirs: [.tad/hooks]` ✓ — but see P2-3.
- `gate4_delta: []` ✓ acceptable (no cross-phase gate carry).
- `skip_knowledge_assessment: no` ✓.
- `e2e_required` / `research_required`: **NOT present as frontmatter keys.** Per the review brief
  these should be checked. In THIS handoff schema they are expressed in-body instead: §8.5
  `feedback_required: false`, and e2e is covered by T5 (real /compact ≥2 + fault injection). This
  matches the repo's actual handoff convention (grounding confirms no npm/tsc Layer-1), so I treat
  it as **PASS by substitution**, flagged P2-4 for schema consistency only.

### P2-3 (cr): `production_dirs` omits three touched production files outside `.tad/hooks`
- The change also writes `.claude/settings.json`, `.gitignore`, and `CLAUDE.md` — all production,
  none under `.tad/hooks`. If `production_dirs` gates anything mechanical (Gate 3 scope check /
  worktree diff scoping), the settings.json + CLAUDE.md edits fall outside the declared scope.
  Consider adding `.claude` and root (for `.gitignore`/`CLAUDE.md`) or documenting that these are
  intentionally single-file edits outside the dir list. Low impact (Blake owns settings.json per
  FR5), hence P2.

### P2-4 (cr): `e2e_required`/`research_required` keys absent from frontmatter
- Not a defect against this repo's schema, but the review brief expects them. Recommend Alex either
  add the keys explicitly (`e2e_required: yes` — T5 mandates real /compact) or the Epic documents
  that this schema encodes them in-body. Cosmetic/schema-hygiene.

---

## Focus 4: Design coherence — PASS

Requirements ↔ technical design are consistent and I verified the load-bearing couplings:

- **FR4 insertion point is real**: `startup-health.sh` L14-19 guard matches grounding exactly; the
  "insert compact branch BEFORE the `output_empty` guard" instruction is executable, and AC7's
  byte-identical-for-startup requirement is satisfiable because the startup path is untouched when
  the compact branch `exit 0`s early. Coherent.
- **FR2 physical boundary ↔ AC2 full-file diff**: because the hook never targets session-state.md,
  a whole-file `diff` (no region stripping) is the correct verifier. The v1→v2 refactor (shared
  block → per-compaction file) genuinely removed the BSD-sed/read-modify-write class of bugs. Sound.
- **FR3 fail-open ↔ 2026-04-15 SAFETY**: exit-0-always + `(unavailable)` breadcrumb + debug-log is
  the "smoke alarm not suppressor" pattern; no deny/block path. Coherent with principles.md.
- **FR7 temp→mv ↔ AC5 torn-write**: atomic rename is the right primitive (modulo P1-1's filename
  collision precision issue).
- **Data model = consumption contract (§4.3)**: field names (When/Trigger/Git HEAD/…) declared
  breaking-change-guarded and cross-referenced to §4.5. Good discipline; matches the repo's
  "文件格式即契约" project-knowledge note.
- **T1 gates everything + honest-partial**: spike-before-architecture is correct (hook-contracts
  pattern), and the grounding's PENDING-REAL-EVENT guidance keeps T1 honest rather than faking a
  live-compact capture. Coherent with the "先 spike 验证机制" principle.

One coherence nit already covered by P1-1 (the "no last-writer, independent files" claim breaks
under same-stdin concurrency). No other requirement/design contradiction found.

---

## Summary of findings

- **P0 (blocking)**: 0
- **P1 (should fix)**: 1 — AC5 filename-collision makes the concurrency AC un-representative /
  self-contradictory with the "independent files" coherence claim; fix filename uniqueness OR
  re-scope AC5 text before T5.
- **P2 (nice to have)**: 4 — (1) note benign concurrent-prune race in FR6; (2) prefer PATH-stub over
  editing script for AC3 fault injection; (3) `production_dirs` omits settings.json/.gitignore/
  CLAUDE.md; (4) `e2e_required`/`research_required` keys absent from frontmatter (schema hygiene).

**Recommendation**: APPROVE for implementation. Address P1-1 by tightening AC5 (cheapest: add PID
suffix to snapshot filename so the 20-way test produces 20 real files, restoring the AC's stated
property). P2s can be folded in at impl or deferred to completion notes.
