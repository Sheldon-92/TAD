---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs:
  - ".tad/hooks/lib"
  - ".claude/skills"
  - ".agents/skills"
  - "docs"
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-11
**Project:** TAD Framework
**Task ID:** TASK-20260611-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260611-pack-system-unification.md (Phase 3/3)
**Supersedes:** N/A

---

## Gate 2: Design Completeness (Alex required)

**Execution time**: 2026-06-11 10:35 UTC / 2026-06-11 06:35 EDT

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | PASS | Phase 3 adds a post-sync/post-install verifier for framework-owned skill symmetry, separate from the existing source-repo `parity` repair mode. |
| Components Specified | PASS | Primary implementation target is `.tad/hooks/lib/release-verify.sh`; protocol/runbook/docs are required consumers. |
| Functions Verified | PASS | Existing `release-verify.sh parity "$PWD"` passes on source repo; current `structural` mode already has the FR7 local-skill INFO precedent for downstream extras. |
| Data Flow Mapped | PASS | Source-owned skill dirs are derived from the TAD source tree, then compared against target `.claude/skills` and `.agents/skills` after sync/install writes occur. |

**Gate 2 Result**: PASS

Alex confirms Blake can implement independently from this handoff.

---

## Handoff Checklist (Blake must read)

Before implementation:
- [ ] Read this entire handoff.
- [ ] Read the Project Knowledge section.
- [ ] Confirm that this phase is verification-focused, not a new pack format.
- [ ] Confirm that local/project-only skills are INFO, not FAIL.
- [ ] Confirm that §9.1 commands are the Gate 3 source of truth.

If any item is unclear, return to Alex before editing.

---

## 1. Task Overview

### 1.1 What We're Building

Add the standing Phase 3 verifier for Pack System Unification:

```text
source TAD framework-owned skills
  -> downstream/project .claude/skills/{skill}
  -> downstream/project .agents/skills/{skill}
  -> byte-symmetry check after sync/install writes
```

The verifier must fail when a framework-owned skill differs between Claude Code and Codex targets, while preserving the FR7 local-skill rule: project-only additions are reported as INFO and do not block sync.

Recommended command shape:

```bash
bash .tad/hooks/lib/release-verify.sh platform-skills <source_root> <target_root>
```

You may choose a better mode name only if every protocol, runbook, and §9.1 command is updated consistently. Do not change the existing `parity` mode semantics.

### 1.2 Why We're Building It

Phase 1 removed YAML Domain Packs as an active mechanism. Phase 2 made the measured transforming installers copy prebuilt `SKILL.md` bytes. Phase 3 closes the remaining risk: a release/sync can still appear successful while `.claude/skills` and `.agents/skills` drift at the project boundary where installers and sync actually write files.

Success looks like:

- source repo check passes after Phase 2
- downstream fixture with injected framework-owned drift fails
- downstream fixture with only local/project skills passes with INFO
- sync/runbook instructions require the check before declaring success

### 1.3 Intent Statement

**Real problem**: TAD now has one active pack format, but it still needs a standing guard that verifies the two platform skill targets remain symmetric after writes.

**Not this task**:
- Do not revive Domain Packs, keyword routers, or SessionStart injection.
- Do not perform pack content upgrades.
- Do not add permanent hooks or settings-based fail-closed checks.
- Do not use the existing `parity --fix` mode as the downstream verifier; it is a source-repo mirror repair tool.
- Do not hardcode a seven-pack allowlist from Phase 2. Derive framework-owned skill names from the TAD source tree.

Blake confirmation prompt:

```text
Before editing, answer in your own words:
1. What counts as framework-owned for this verifier?
2. Why are local-only skills INFO rather than FAIL?
3. Why should existing `parity --fix` not be overloaded for this downstream check?
```

Only human confirmation is needed if your understanding differs from this handoff.

---

## Project Knowledge (Blake must read)

Relevant categories:

- architecture: verifier must match write granularity
- shell-portability: macOS/BSD-safe shell and temp fixtures
- testing: AC commands must prove pass/fail behavior, not just success output
- pack-build-rules: `SKILL.md` is the only active pack runtime artifact

Historical lessons to apply:

1. **Verifier must match write granularity**
   - Prior release/sync defects came from verifying the wrong layer. This phase must verify `.claude/skills/{skill}` and `.agents/skills/{skill}` exactly where sync/install writes them.

2. **FR7 local-skill model is already validated**
   - v2.29.0 sync proved project-local skills must survive sync. Target-only skill dirs not present in the TAD source-owned list should be INFO, not FAIL.

3. **Deny-list/copy-set logic should be derived**
   - Do not maintain a static list of framework skills. Derive ownership from the source tree so future packs are automatically covered.

4. **Advisory checks stay manual**
   - Mechanical hooks were rejected for this single-user CLI. Add a command that runbook/sync protocols invoke manually or as part of release scripts; do not wire fail-closed settings hooks.

5. **AC output must include negative fixtures**
   - A verifier without an injected failure fixture is theater. §9.1 requires both drift-fails and local-extra-passes cases.

6. **Optional package probes can hang**
   - Gate 4 for Phase 2 found unbounded `npx <package> --version` unsafe under restricted network. Avoid network-dependent probes in this phase's tests.

---

## 2. Background Context

### 2.1 Previous Work

Phase 1 accepted:

- archived YAML Domain Packs
- removed active Domain Pack runtime/sync references
- documented Capability Packs as the live pack system

Phase 2 accepted:

- created prebuilt source `SKILL.md` for seven target packs
- converted seven installers to deterministic copy semantics
- added `--agent=codex` support for the target installers
- accepted `research-methodology` as flag-only for Phase 2

### 2.2 Current State

Observed before this handoff:

- `bash .tad/hooks/lib/release-verify.sh parity "$PWD"` passes on the source repo.
- `.claude/skills` and `.agents/skills` currently have matching top-level skill names and byte-identical source content.
- `release-verify.sh structural <src> <target>` already treats target-only `.claude/skills` dirs as local-skill INFO.
- `release-verify.sh parity [--fix] <repo_root>` compares source repo `.claude/skills` to `.agents/skills` with `.claude` as source-of-truth; this is not local-skill aware and should keep its current semantics.

### 2.3 Carry-forward Risk

`research-methodology` was deliberately not converted to Phase 2 single-sourcing. If the new framework-owned verifier exposes a real downstream symmetry issue involving it, fix the issue in Phase 3 unless the completion report explicitly justifies a narrow deferral. Do not hide it by using a Phase 2 seven-pack allowlist.

---

## 3. Requirements

### 3.1 Functional Requirements

- FR1: Add a verification mode to `.tad/hooks/lib/release-verify.sh` that compares framework-owned skill dirs between a source TAD root and a target project root.
- FR2: Framework-owned skills must be derived from source `.claude/skills/*` and `.agents/skills/*`, not hardcoded.
- FR3: For every framework-owned skill, target `.claude/skills/{skill}` and `.agents/skills/{skill}` must both exist and be byte-identical after sync/install.
- FR4: Missing framework-owned skill on either target platform is FAIL.
- FR5: Byte drift in any framework-owned file is FAIL and names the skill.
- FR6: Target-only/project-only skill dirs not owned by source are INFO, not FAIL.
- FR7: The verifier must pass when `<source_root>` and `<target_root>` are the current source repo after Phase 2.
- FR8: The verifier must fail on an injected drift fixture.
- FR9: Update sync protocol and release runbook so this verifier runs after capability pack install/sync writes and before declaring success.
- FR10: Update platform docs to state that `SKILL.md` Capability Packs are the only active pack system for both Claude Code and Codex.

### 3.2 Non-Functional Requirements

- NFR1: Keep shell macOS/BSD compatible. Avoid `grep -P`, GNU-only flags, and network-dependent commands.
- NFR2: Do not add persistent hooks, settings entries, or SessionStart checks.
- NFR3: Do not mutate target projects in verifier mode.
- NFR4: Keep source `.claude/skills` and `.agents/skills` counterpart protocol/runbook files byte-identical where they already are paired.
- NFR5: Failure output must be actionable: include mode, target root, skill name, and whether the issue is missing or drift.
- NFR6: Evidence must include raw output for pass, fail, and INFO-local-skill cases.

---

## 4. Technical Design

### 4.1 Recommended Architecture

Add a new `release-verify.sh` mode:

```text
platform-skills <source_root> <target_root>
```

Suggested ownership model:

```text
framework_owned(skill) =
  skill dir exists in source_root/.claude/skills/{skill}
  OR
  skill dir exists in source_root/.agents/skills/{skill}
```

Then verify target:

```text
target_root/.claude/skills/{skill}
target_root/.agents/skills/{skill}
```

For each framework-owned skill:

- both target dirs must exist
- `diff -qr` between target Claude and target Codex dirs must be clean
- if source has both source dirs, source Claude and source Codex should be clean too or the verifier should fail early with a source-precondition error

Target-only extras:

```text
target skill dir not in framework_owned set
  -> INFO local-skill
  -> no failure
```

### 4.2 Integration Points

Update these paired protocol/runbook files:

- `.claude/skills/alex/references/sync-protocol.md`
- `.agents/skills/alex/references/sync-protocol.md`
- `.claude/skills/release-runbook/SKILL.md`
- `.agents/skills/release-runbook/SKILL.md`

Required placement:

- after platform-aware skill copy/install has run
- after deprecation/migration cleanup if that cleanup can affect skills
- before declaring structural/sync success

Keep existing `structural` mode unless a small internal helper can share local-skill listing logic without changing old behavior.

### 4.3 Documentation Updates

Update:

- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`

Required doc claim:

```text
SKILL.md Capability Packs are the only active pack system for both Claude Code and Codex.
```

Docs should also explain local-skill exceptions briefly: framework-owned skills must be symmetric; project-local additions may exist on one or both platforms and are reported as INFO by the verifier.

---

## 5. Implementation Guidance

Suggested implementation steps:

1. Add `platform-skills` mode to `release-verify.sh`.
2. Implement helper functions for listing skill dir basenames and comparing dirs.
3. Add fixture-based manual tests in `.tad/evidence/pack-system-unification-phase3/`.
4. Update sync protocol/runbook files in both `.claude` and `.agents`.
5. Update multi-platform docs.
6. Run §9.1 exactly and capture raw output.
7. Run Layer 2 review and fix P0/P1 findings.
8. Write completion report and update Epic/NEXT/session-state.

Do not use `rm -rf` outside temp dirs created by `mktemp -d`. Keep every destructive cleanup under a trap tied to that temp dir.

---

## 6. Files Expected to Change

Expected:

- `.tad/hooks/lib/release-verify.sh`
- `.claude/skills/alex/references/sync-protocol.md`
- `.agents/skills/alex/references/sync-protocol.md`
- `.claude/skills/release-runbook/SKILL.md`
- `.agents/skills/release-runbook/SKILL.md`
- `docs/MULTI-PLATFORM.md`
- `.tad/codex/README.md`
- `.tad/evidence/pack-system-unification-phase3/*`
- `.tad/active/epics/EPIC-20260611-pack-system-unification.md`
- `NEXT.md`
- `.tad/active/session-state.md`

Possible, only if verifier exposes real drift:

- `.tad/capability-packs/research-methodology/install.sh`
- `.claude/skills/research-methodology/SKILL.md`
- `.agents/skills/research-methodology/SKILL.md`

Out of scope:

- `.tad/domains/`
- new Domain Pack docs
- settings hooks
- pack content upgrades unrelated to symmetry

---

## 7. Acceptance Criteria

- AC1: Existing source-repo parity still passes.
- AC2: New platform-skill verifier passes on current source repo.
- AC3: Injected framework-owned drift fails and names the drifted skill.
- AC4: Target-only local skill additions pass with INFO, not FAIL.
- AC5: Missing framework-owned target skill fails and names the missing skill.
- AC6: Sync protocol files in `.claude` and `.agents` are byte-identical and include the new verifier at the post-install point.
- AC7: Release runbook files in `.claude` and `.agents` are byte-identical and include the new verifier.
- AC8: Platform docs state that `SKILL.md` Capability Packs are the only active pack system for Claude Code and Codex.
- AC9: No active Domain Pack runtime references are reintroduced.
- AC10: Evidence directory contains raw pass/fail/INFO outputs and completion report states the `research-methodology` disposition.
- AC11: Layer 2 reviews are present and no P0/P1 remains unresolved.

---

## 8. Required Evidence

Write evidence under:

```text
.tad/evidence/pack-system-unification-phase3/
```

Minimum artifacts:

- `ac-outputs.txt`
- `platform-skills-source-pass.txt`
- `platform-skills-drift-fail.txt`
- `platform-skills-local-info.txt`
- `fixture-notes.md`
- `COMPLETION-20260611-pack-system-unification-phase3.md`

Review artifacts:

```text
.tad/evidence/reviews/blake/pack-system-unification-phase3/spec-compliance-review.md
.tad/evidence/reviews/blake/pack-system-unification-phase3/code-review.md
```

Completion report must include:

- commits
- exact verifier mode name
- AC table with raw command references
- Friction Status
- `research-methodology` disposition
- Knowledge Assessment

---

## 9. Gate 3 Verification

### 9.1 Commands Blake Must Run

Run from repo root with `/bin/bash`. Save raw output to `.tad/evidence/pack-system-unification-phase3/ac-outputs.txt`.

```bash
set -euo pipefail
mkdir -p .tad/evidence/pack-system-unification-phase3

echo "AC1 existing parity"
bash .tad/hooks/lib/release-verify.sh parity "$PWD"

echo "AC2 platform-skills source pass"
bash .tad/hooks/lib/release-verify.sh platform-skills "$PWD" "$PWD"

echo "AC3 injected framework-owned drift fails"
tmp="$(mktemp -d)"
tmp_local=""
tmp_missing=""
cleanup() { rm -rf "${tmp:-}" "${tmp_local:-}" "${tmp_missing:-}"; }
trap cleanup EXIT
cp -R .claude "$tmp/.claude"
cp -R .agents "$tmp/.agents"
printf '\nDRIFT-FIXTURE\n' >> "$tmp/.agents/skills/alex/SKILL.md"
if bash .tad/hooks/lib/release-verify.sh platform-skills "$PWD" "$tmp" > .tad/evidence/pack-system-unification-phase3/platform-skills-drift-fail.txt 2>&1; then
  echo "AC3 FAIL: drift fixture unexpectedly passed"
  exit 1
fi
drift_skill="alex"
grep -F "$drift_skill" .tad/evidence/pack-system-unification-phase3/platform-skills-drift-fail.txt

echo "AC4 local-only target skill is INFO and pass"
tmp_local="$(mktemp -d)"
cp -R .claude "$tmp_local/.claude"
cp -R .agents "$tmp_local/.agents"
mkdir -p "$tmp_local/.agents/skills/local-only-demo"
cat > "$tmp_local/.agents/skills/local-only-demo/SKILL.md" <<'EOF'
---
name: local-only-demo
description: "Fixture local skill"
---
# Local Only Demo
EOF
bash .tad/hooks/lib/release-verify.sh platform-skills "$PWD" "$tmp_local" > .tad/evidence/pack-system-unification-phase3/platform-skills-local-info.txt 2>&1
grep -F "local-skill" .tad/evidence/pack-system-unification-phase3/platform-skills-local-info.txt

echo "AC5 missing framework-owned target skill fails"
tmp_missing="$(mktemp -d)"
cp -R .claude "$tmp_missing/.claude"
cp -R .agents "$tmp_missing/.agents"
rm -f "$tmp_missing/.agents/skills/blake/SKILL.md"
if bash .tad/hooks/lib/release-verify.sh platform-skills "$PWD" "$tmp_missing" > .tad/evidence/pack-system-unification-phase3/platform-skills-missing-fail.txt 2>&1; then
  echo "AC5 FAIL: missing fixture unexpectedly passed"
  exit 1
fi
missing_skill="blake"
grep -F "$missing_skill" .tad/evidence/pack-system-unification-phase3/platform-skills-missing-fail.txt

echo "AC6 sync protocol counterparts"
cmp -s .claude/skills/alex/references/sync-protocol.md .agents/skills/alex/references/sync-protocol.md
mode_name="platform-skills"
grep -F "$mode_name" .claude/skills/alex/references/sync-protocol.md

echo "AC7 release runbook counterparts"
cmp -s .claude/skills/release-runbook/SKILL.md .agents/skills/release-runbook/SKILL.md
grep -F "$mode_name" .claude/skills/release-runbook/SKILL.md

echo "AC8 docs active pack system"
grep -F "SKILL.md Capability Packs are the only active pack system" docs/MULTI-PLATFORM.md .tad/codex/README.md

echo "AC9 no active Domain Pack runtime reintroduced"
if rg -n "userprompt-domain-router|keywords.yaml|domain_pack_trace|SessionStart.*Domain Pack" .tad/hooks .claude/skills .agents/skills docs README.md tad.sh; then
  echo "AC9 FAIL: active Domain Pack runtime reference found"
  exit 1
fi

echo "AC10 evidence and completion"
test -s .tad/evidence/pack-system-unification-phase3/platform-skills-drift-fail.txt
test -s .tad/evidence/pack-system-unification-phase3/platform-skills-local-info.txt
test -s .tad/active/handoffs/COMPLETION-20260611-pack-system-unification-phase3.md
grep -F "research-methodology" .tad/active/handoffs/COMPLETION-20260611-pack-system-unification-phase3.md

echo "AC11 layer2 reviews"
test -s .tad/evidence/reviews/blake/pack-system-unification-phase3/spec-compliance-review.md
test -s .tad/evidence/reviews/blake/pack-system-unification-phase3/code-review.md
if rg -n "P0|P1" .tad/evidence/reviews/blake/pack-system-unification-phase3 | rg -v "resolved|fixed|no P0|no P1|0 P0|0 P1"; then
  echo "AC11 FAIL: unresolved P0/P1 review text found"
  exit 1
fi
```

### 9.2 Additional Verification

Also run:

```bash
bash -n .tad/hooks/lib/release-verify.sh
bash .tad/hooks/lib/verify-ac-commands.sh .tad/active/handoffs/HANDOFF-20260611-pack-system-unification-phase3.md
git diff --check
```

If `verify-ac-commands.sh` emits advisory warnings, either fix the handoff/commands or document why the warning is a false positive in Friction Status.

---

## 10. Layer 2 Review Requirements

Required independent reviews:

- spec-compliance reviewer: verify every FR/AC maps to code/docs/evidence.
- code reviewer: inspect shell correctness, local-skill classification, failure modes, and fixture reliability.

Reviewers must have distinct artifacts. Blake must fix all P0/P1 findings or document a human-approved deferral.

---

## 11. Knowledge Assessment Prompts

Answer in the completion report:

1. Did this work reveal a reusable verifier pattern for platform-symmetric artifacts?
2. Did the implementation change any workflow habit around post-install verification placement?
3. Did any shell portability or fixture-construction issue deserve a project-knowledge update?

---

## 12. Done Definition

Phase 3 is done when:

- `release-verify.sh platform-skills "$PWD" "$PWD"` passes.
- Injected drift fails.
- Local-only skill fixture passes with INFO.
- Sync/runbook docs require the check at the right point.
- Platform docs identify `SKILL.md` Capability Packs as the only active pack system.
- Gate 3 passes with evidence and reviews.
