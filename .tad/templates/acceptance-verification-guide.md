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

## 3. Verification Type Selection

| Criterion Type | Verification Form | Example Filename |
|----------------|-------------------|------------------|
| File/directory exists | bash (`test -f` / `test -d`) | AC-01-file-exists.sh |
| Content/format correct | bash (`grep` / `yq` / `jq`) | AC-02-yaml-structure.sh |
| Code functionality | Test file (Jest/pytest) | AC-03-function.test.ts |
| Config value correct | bash (check specific values) | AC-04-config-value.sh |
| UI behavior correct | bash (`curl` + check) or E2E test | AC-05-api-response.sh |
| Protocol structure correct | bash (grep YAML keys) | AC-06-protocol.sh |
| No impact / no regression | bash (diff / grep unchanged) | AC-07-no-impact.sh |

---

## 4. Naming Convention

```
AC-{NN}-{brief-slug}.{sh|test.ts|test.py}
```

- `NN`: Two-digit number matching the criterion order in Handoff (01, 02, ...)
- `brief-slug`: 2-4 word kebab-case description
- Extension: `.sh` for bash, `.test.ts` for Jest, `.test.py` for pytest

**Output directory**: `.tad/evidence/acceptance-tests/{task_id}/`

### Task ID Mapping

`task_id` is derived from the Handoff filename:
- Handoff: `.tad/active/handoffs/HANDOFF-20260204-acceptance-testing.md`
- Task ID: `acceptance-testing` (strip `HANDOFF-{date}-` prefix and `.md` suffix)
- Output directory: `.tad/evidence/acceptance-tests/acceptance-testing/`

---

## 5. Quality Requirements

- **Independent**: Each verification runs standalone, no dependency on execution order
- **Deterministic**: Produces clear PASS or FAIL (never "looks OK")
- **Fast**: Single verification completes within 30 seconds (timeout = FAIL)
- **Exit codes**: Bash scripts use `exit 0` (PASS) or `exit 1` (FAIL)
- **Framework**: Use project's test framework when available; bash as fallback

---

## 6. Report Format

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

## 7. Failure Handling

| Failure Scenario | Action | Re-run Scope |
|-----------------|--------|-------------|
| **Script bug** (wrong path, logic error) | Fix verification script only | Re-run fixed script only |
| **Code defect** (verification reveals real issue) | Fix code, then re-verify | Ralph Loop Layer 1 + ALL verifications |
| **Ambiguous criterion** | Write best-effort verification + note | Flag for Alex in Gate 4 |

---

## 8. Common Verification Patterns

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
