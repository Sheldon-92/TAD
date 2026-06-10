# Phase 6 Design Review — Code Review (CR)

**Reviewer**: code-review-specialist
**Date**: 2026-06-10
**Artifact**: HANDOFF-20260610-acceptance-phase6.md
**Focus**: Epic Success Criteria coverage, gate exercise realism, AC verifiability, tooling/execution separation

---

## Summary

The handoff is well-structured, cleanly separates Blake's deliverables (verification scripts) from human-triggered actions (*sync on 14 projects), and provides concrete implementation guidance. The gate-exercise.sh design correctly proves non-theater by demonstrating exit 1 in an isolated temp dir. However, two Epic-level Success Criteria have no coverage at all in this handoff, and the gate-exercise design has a subtle dependency gap that could produce a false PASS.

---

## P0 — Critical (Must Fix Before Implementation)

### P0-1: Epic Success Criterion #3 (chain upgrade fixture) completely unaddressed

**Epic AC line 256**: "旧 tag（回溯起点）→ 2.27+ 的链式升级 fixture PASS"
**Phase 6 grounding line 17**: "旧 tag (v2.19.0) → current 链式升级 fixture PASS"

The grounding document explicitly identifies this as a Phase 6 deliverable: "Chain fixture: F-chain in run-fixtures.sh -- v0.1.0->v0.3.0 with full manifest chain". However, the handoff document:
- Does NOT include a chain-upgrade fixture in any FR
- Does NOT mention extending run-fixtures.sh
- FR3 only captures existing fixture output (the current 22)
- AC14 only verifies existing "22/22" pass

F5 in the current harness is a v0.1->v0.2->v0.3 chain, but the Epic AC specifically requires **v2.19.0 (backfill origin) -> current** proving the 12 historical manifests form a complete chain. F5 tests synthetic manifests, not the REAL historical chain. This is a distinct verification gap.

**Fix**: Add an FR6 and corresponding AC for a chain-upgrade fixture that exercises the actual `.tad/migrations/` historical manifest chain (v2.19.0 -> ... -> v2.27.0). This can be a new fixture in run-fixtures.sh or a standalone script. The fixture constructs a synthetic target at v2.19.0 state and chains through all 12 manifests sequentially, asserting final state matches expectations.

### P0-2: Epic Success Criterion #6 (3 merge-strategy projects) not addressed or explicitly deferred

**Epic line 21**: "3 个 merge-strategy 项目（my-openclaw-agents / toy / 内存管理）的 CLAUDE.md marker 遗留问题解决"

This Success Criterion is not mentioned anywhere in the handoff. It is neither addressed nor explicitly deferred with rationale. Phase 4 was supposed to fix these, but Phase 6 as the "final acceptance" must verify the fix landed. If Phase 4 already resolved this (in YOLO mode, so executed), the handoff should include a verification AC. If it was deferred, the handoff must say so and explain why the Epic can close without it.

**Fix**: Either (a) add a verification step in upgrade-acceptance.sh or a standalone check that confirms the 3 projects have the marker, OR (b) explicitly document in the handoff that this Success Criterion was satisfied in Phase 4 with a reference to the evidence (commit hash, evidence file), OR (c) state it's deferred and cannot be verified until the 14-project *sync (making it part of the human acceptance step post-sync).

---

## P1 — Important (Should Fix)

### P1-1: gate-exercise.sh has a structural dependency that may not copy correctly

The design (S4.3 step 6) says: "Copy derive-sync-set.sh and release-verify.sh into the temp repo". However, release-verify.sh itself sources derive-sync-set.sh via:
```
DERIVE="$SCRIPT_DIR/derive-sync-set.sh"
```

And release-verify.sh's migration mode (line 365) calls:
```bash
bash "$DERIVE" --zero-touch "$REPO"
```

The temp repo must have derive-sync-set.sh at the SAME relative path (`$SCRIPT_DIR/derive-sync-set.sh` where SCRIPT_DIR is the dir containing release-verify.sh). The design correctly says "Copy ... into temp repo's .tad/hooks/lib/" which satisfies this. But the temp repo also needs a `.tad/` directory structure that `--zero-touch` can scan (it runs `ls -d "$root"/.tad/*/`). If the temp repo only has `.claude/skills/test-file.md` (as designed in step 4-5), there are no `.tad/*/` subdirectories, so `--zero-touch` will fail or return empty.

The migration mode flow:
1. Calls `bash "$DERIVE" --zero-touch "$REPO"` on the TEMP repo
2. If no `.tad/*/` dirs exist there, `ls -d` will glob-fail under `set -e`

**Fix**: The gate-exercise.sh design should create at least a minimal `.tad/` structure in the temp repo (e.g., `mkdir -p "$tmp/.tad/hooks/lib"` is already needed for copying the scripts, but also one zero-touch dir like `mkdir -p "$tmp/.tad/active"` so derive-sync-set.sh doesn't fail). Add this to the implementation steps. Alternatively, verify what derive-sync-set.sh does when no `.tad/*/` dirs match the glob.

### P1-2: deprecation.yaml awk parser does not handle the `files: []` empty-array case

The deprecation.yaml (line 63-66) contains:
```yaml
  "2.8.4":
    ...
    files: []  # No standalone files removed
```

The awk parsing approach (S4.4) tracks state via `in_files` and captures `^      - ` lines. With `files: []`, the `files:` line is `    files: []` which matches `/^    files:/`, setting `in_files=1`. But there will be no subsequent `^      - ` lines. The next line will be `    note: |` which does NOT match `!/^      /` (it has 4 spaces which is NOT 6 spaces, so the guard fires and resets `in_files=0`). This actually works correctly by accident, but the awk state machine description in S4.4 does not account for this edge case.

More concerning: the `files: []` inline syntax means the `files:` line itself CONTAINS `[]`. If the awk sees `/^    files:/` it enters `in_files` mode. The `[]` on the same line is not consumed as a path. This works, but only because there's no `- ` on that line. The design should explicitly note that `files: []` (empty array) is handled safely.

**Fix**: Add a note in S4.4 or the implementation steps that `files: []` (YAML inline empty array) is a known format variant that the parser handles correctly because it lacks `^      - ` lines. Suggest an explicit early-exit: `if the files: line contains []`, skip to next version block.

### P1-3: AC14 asserts "22/22" but fixture count may increase during implementation

The handoff claims 22 fixtures exist. If P0-1 is fixed and a chain-upgrade fixture is added to run-fixtures.sh, the count becomes 23 (or more). AC14 hardcodes `"ALL FIXTURES PASS (22/22)"`. This creates a false-fail if the count changes.

**Fix**: AC14 verification should use a pattern that accommodates count changes: `grep -c 'ALL FIXTURES PASS' ...` (already AC16) rather than asserting exact "22/22". Or, if the chain fixture is a standalone script (not added to run-fixtures.sh), clarify that in the design.

### P1-4: upgrade-acceptance.sh --snapshot design takes a PRE-sync snapshot directory, but the snapshot example is incomplete

Section 10.1 says: "the human must take a snapshot BEFORE running *sync: `cp -a project/.tad/project-knowledge project-snapshot/`". But this example only copies ONE zero-touch directory (project-knowledge). The actual zero-touch set is 9 directories (active, archive, decisions, evidence, github-registry, pair-testing, project-knowledge, research-notebooks, skillify-candidates). A user following this example would get an incomplete snapshot.

**Fix**: Change the example to: `cp -a project/.tad project-snapshot-tad/` (copy the entire .tad tree) or list all 9 dirs. The script should document clearly what `--snapshot` expects (a directory containing the same structure as `$target/.tad/` for the zero-touch subdirectories).

### P1-5: Epic Success Criterion #5 ("14/14 注册项目升级后 diff -rq 双向验证 PASS") has no AC to verify it was done

The handoff correctly states the 14-project *sync is NOT Blake's job (human-triggered). But there is no AC or evidence requirement that RECORDS the 14-project results after the human runs them. The Phase 6 Epic AC explicitly requires "14/14 ... diff -rq ... PASS" with "抽 3 项目全量 diff 断言". The upgrade-acceptance.sh script is the TOOL, but where is the evidence that it was run 14 times and all passed?

**Fix**: Add to the evidence README template (or a separate section) a placeholder structure for recording the 14-project run results. E.g., a `14-project-results.txt` file in the evidence dir that the human populates post-sync. The handoff should explicitly state that Gate 4 cannot pass until this evidence exists (even though Blake doesn't create it -- Gate 4 checks it).

---

## P2 — Suggestions (Consider)

### P2-1: gate-exercise.sh asserts "UNMANIFESTED DELETE" string, but release-verify.sh outputs have changed

The assertion (step 10): `Assert output contains "UNMANIFESTED DELETE"`. Looking at release-verify.sh line 445:
```
findings_list="${findings_list}  UNMANIFESTED DELETE: ${d_path}..."
```
This currently matches. But the gate-exercise design creates a file at `.claude/skills/test-file.md`, removes it without a manifest, then checks for "UNMANIFESTED DELETE". This requires that:
- The file is in the framework-scoped diff paths (`.claude/` is included in line 375 of release-verify.sh)
- The file path doesn't match ZERO_TOUCH regex

Both conditions are satisfied by the design. The assertion is sound.

### P2-2: Consider adding a `--verbose` flag to upgrade-acceptance.sh

For debugging failed checks on the 14 projects, a verbose mode that shows exactly which deprecated files were checked, which zero-touch dirs were diffed, etc., would reduce human troubleshooting time.

### P2-3: The deprecation.yaml awk regex `/^  "[0-9]/` is fragile

It matches version block headers by looking for 2-space indent + double-quote + digit. If a future version like `"10.0.0"` is added, this works. But if someone adds a comment or metadata field that starts with `"` + digit at 2-space indent, it would confuse the parser. Consider tightening to `/^  "[0-9]+\.[0-9]/ ` for better discrimination.

### P2-4: The evidence README recommendation could reference gate fixture evidence

The warn-to-hard-block recommendation references "22/22 engine fixtures pass" and "gate exercise proves exit 1". Consider adding the exact evidence file names so a future reader can verify the claims without searching.

---

## Positive Observations

1. **Tooling/execution separation** is handled correctly. The handoff is explicit and repeated (S1.3 "NOT running *sync on 14 projects", S10.1 critical warning, the "NOT" list) about what Blake builds vs what the human does. This is the right design.

2. **gate-exercise.sh temp-dir isolation** is well-designed. Using mktemp + trap EXIT ensures no mutation of the real repo. The exit code contract (0=gate correctly blocked, 1=gate failed to catch) is clear and inverted from the gate itself (gate exit 1 = gate working correctly).

3. **NFR coverage** is solid: BSD compatibility, idempotency, clear exit codes, human-readable output, cleanup. These match the project's shell-portability pattern knowledge.

4. **Expert review** was done with relevant specialties (shell-security, test-architect) and issues were actually resolved in the design.

5. **AC verification commands** are all concrete, copy-pasteable, and have expected outputs. This makes Gate 3 objective verification straightforward.

---

## Verdict

**CONDITIONAL PASS** -- P0-1 (missing chain fixture) and P0-2 (missing merge-strategy verification) represent Epic Success Criteria with zero coverage. These must be addressed before Blake implements, or the Epic cannot close with "all Success Criteria verified." The P1 items are implementation-quality issues that can be fixed during or after implementation without architectural rework.

---

## Findings Summary

| Severity | Count | Key Theme |
|----------|-------|-----------|
| P0 | 2 | Missing Epic Success Criteria coverage (chain fixture + merge-strategy) |
| P1 | 5 | Dependency gap in gate exercise, parser edge case, count brittleness, snapshot docs, evidence gap |
| P2 | 4 | Minor robustness/UX suggestions |
