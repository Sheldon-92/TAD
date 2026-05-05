# Acceptance Verification Guide

> Blake's reference guide for generating and executing acceptance criterion verifications.
> Each Handoff Acceptance Criterion must have at least one runnable verification before Gate 3.

---

## 1. Purpose

Convert Handoff Acceptance Criteria from text checklists into **runnable verifications** that produce objective PASS/FAIL results. This replaces subjective "looks OK" assessments with executable evidence.

---

## 2. When to Execute

```
Ralph Loop Layer 2 (expert review) passes
    ↓
step3b: Acceptance Verification  ← YOU ARE HERE
    ↓
step4: Gate 3 v2
```

**Trigger**: After Ralph Loop completes (step3 done), before Gate 3 (step4).

---

## 3. Verification Placement: Project Tests vs TAD Evidence

Each acceptance criterion falls into one of two categories. **Choose the right destination**:

| Criterion Category | Destination | Why |
|--------------------|------------|-----|
| **Functional/behavioral** (user-facing logic, API behavior, UI interaction) | **Project's own test suite** (`src/tests/`, `__tests__/`, etc.) | Becomes permanent regression test — Layer 1 runs it on every future change |
| **Structural/protocol** (file exists, config format, YAML keys, framework compliance) | **TAD evidence** (`.tad/evidence/acceptance-tests/`) | One-time verification of delivery, not reusable as product test |

**Rule: If a verification tests product functionality, it MUST go into the project's test suite, not `.tad/evidence/`.**

This ensures the project's test coverage grows with every feature Blake implements. Over time, Layer 1's `npm test` (or equivalent) automatically covers all historical features — no separate smoke test mechanism needed.

### Examples

```
AC: "用户登录后跳转到首页"
  → Write: src/__tests__/auth/login-redirect.test.ts  (project test)
  → Also copy to: .tad/evidence/ as AC-01 (for step3b report)

AC: "tad-blake.md 包含 step3b"
  → Write: .tad/evidence/acceptance-tests/{task_id}/AC-02-step3b.sh  (TAD evidence only)
```

For criteria that produce project tests, the verification report should reference the project test path:

```
| 1 | Login redirects to home | src/__tests__/auth/login-redirect.test.ts | PASS | npm test output |
```

---

## 4. Verification Type Selection

| Criterion Type | Verification Form | Example Filename | Destination |
|----------------|-------------------|------------------|-------------|
| File/directory exists | bash (`test -f` / `test -d`) | AC-01-file-exists.sh | TAD evidence |
| Content/format correct | bash (`grep` / `yq` / `jq`) | AC-02-yaml-structure.sh | TAD evidence |
| Code functionality | Test file (Jest/pytest) | login-redirect.test.ts | **Project tests** |
| Config value correct | bash (check specific values) | AC-04-config-value.sh | TAD evidence |
| UI behavior correct | Test file or E2E test | dashboard-load.test.ts | **Project tests** |
| API behavior correct | Test file (supertest/httpx) | api-users.test.ts | **Project tests** |
| Protocol structure correct | bash (grep YAML keys) | AC-06-protocol.sh | TAD evidence |
| No impact / no regression | bash (diff / grep unchanged) | AC-07-no-impact.sh | TAD evidence |

---

## 5. Naming Convention

```
AC-{NN}-{brief-slug}.{sh|test.ts|test.py}
```

- `NN`: Two-digit number matching the criterion order in Handoff (01, 02, ...)
- `brief-slug`: 2-4 word kebab-case description
- Extension: `.sh` for bash, `.test.ts` for Jest, `.test.py` for pytest

**TAD evidence directory**: `.tad/evidence/acceptance-tests/{task_id}/`
**Project tests**: Follow the project's existing test directory convention

### Task ID Mapping

`task_id` is derived from the Handoff filename:
- Handoff: `.tad/active/handoffs/HANDOFF-20260204-acceptance-testing.md`
- Task ID: `acceptance-testing` (strip `HANDOFF-{date}-` prefix and `.md` suffix)
- Output directory: `.tad/evidence/acceptance-tests/acceptance-testing/`

---

## 6. Quality Requirements

- **Independent**: Each verification runs standalone, no dependency on execution order
- **Deterministic**: Produces clear PASS or FAIL (never "looks OK")
- **Fast**: Single verification completes within 30 seconds (timeout = FAIL)
- **Exit codes**: Bash scripts use `exit 0` (PASS) or `exit 1` (FAIL)
- **Framework**: Use project's test framework when available; bash as fallback

---

## 7. Report Format

After executing all verifications, generate `acceptance-verification-report.md`:

```markdown
# Acceptance Verification Report
Task: {task_id}
Date: {date}
Handoff: {handoff filename}
Total: {N} criteria, {P} PASS, {F} FAIL

| # | Acceptance Criterion | Verification | Result | Evidence |
|---|---------------------|-------------|--------|----------|
| 1 | {criterion text}    | AC-01-xxx.sh | PASS | {stdout} |
| 2 | {criterion text}    | AC-02-xxx.sh | PASS | {stdout} |
| ... | ... | ... | ... | ... |
```

---

## 8. Failure Handling

| Failure Scenario | Action | Re-run Scope |
|-----------------|--------|-------------|
| **Script bug** (wrong path, logic error) | Fix verification script only | Re-run fixed script only |
| **Code defect** (verification reveals real issue) | Fix code, then re-verify | Ralph Loop Layer 1 + ALL verifications |
| **Ambiguous criterion** | Write best-effort verification + note | Flag for Alex in Gate 4 |

---

## 9. Common Verification Patterns

### File Exists
```bash
#!/bin/bash
if [ -f ".tad/references/design-curations.yaml" ]; then
  echo "PASS: design-curations.yaml exists"
  exit 0
else
  echo "FAIL: design-curations.yaml not found"
  exit 1
fi
```

### YAML Key Check
```bash
#!/bin/bash
if grep -q "step3b:" .claude/commands/tad-blake.md; then
  echo "PASS: step3b found in completion_protocol"
  exit 0
else
  echo "FAIL: step3b not found"
  exit 1
fi
```

### Count Verification
```bash
#!/bin/bash
count=$(grep -c "^  [a-z_]*:" .tad/references/design-curations.yaml)
if [ "$count" -ge 5 ]; then
  echo "PASS: Found $count entries (>= 5 required)"
  exit 0
else
  echo "FAIL: Found only $count entries (5 required)"
  exit 1
fi
```

### No Impact Check
```bash
#!/bin/bash
# Verify specific file was NOT modified
if git diff HEAD -- .claude/commands/tad-maintain.md | grep -q "^[-+]"; then
  echo "FAIL: tad-maintain.md was modified (should not be)"
  exit 1
else
  echo "PASS: tad-maintain.md unchanged"
  exit 0
fi
```

### Python Structure Check
```bash
#!/bin/bash
python3 -c "
import sys, yaml
with open('.tad/config-quality.yaml', 'r') as f:
    data = yaml.safe_load(f)
evidence = data.get('gate3_v2_implementation_integration', {}).get('acceptance_verification_evidence', {})
if evidence.get('required') == True:
    print('PASS: acceptance_verification_evidence is required')
    sys.exit(0)
else:
    print('FAIL: acceptance_verification_evidence not marked as required')
    sys.exit(1)
"
```
