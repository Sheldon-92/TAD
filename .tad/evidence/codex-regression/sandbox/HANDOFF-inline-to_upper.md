---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/evidence/codex-regression/sandbox"]
skip_knowledge_assessment: yes
gate4_delta: []
---

# Inline Handoff: `to_upper` Shell Sandbox

**From:** Alex (Solution Lead)  
**To:** Blake (Execution Master)  
**Date:** 2026-06-09  
**Scope:** Carrier-task regression sandbox only  
**Output boundary:** All created files must stay under `.tad/evidence/codex-regression/sandbox/`

## 1. Task Overview

Create a small Bash utility that exposes a shell function `to_upper` and a matching test script.

The function must:

- read from `stdin` rather than positional arguments
- convert ASCII lowercase to uppercase using `LC_ALL=C`
- handle empty input gracefully
- be source-safe

This is a sandbox carrier task for regression evidence, not a framework feature.

## 2. Deliverables

Create exactly these task files:

1. `.tad/evidence/codex-regression/sandbox/to_upper.sh`
2. `.tad/evidence/codex-regression/sandbox/test_to_upper.sh`
3. `.tad/evidence/codex-regression/sandbox/evidence/`

Suggested evidence files:

1. `syntax-check.txt`
2. `test-output.txt`
3. `source-check.txt`
4. `completion-report.md`

## 3. Design Constraints

### 3.1 Function contract

`to_upper` should:

- consume all stdin until EOF
- emit uppercase text to stdout
- return exit `0` on normal empty input
- emit nothing for empty input

### 3.2 Locale safety

Use `LC_ALL=C` at the transformation point so behavior is deterministic and ASCII-oriented.

Recommended transformation shape:

```bash
LC_ALL=C tr '[:lower:]' '[:upper:]'
```

### 3.3 Accepted limitation

Under `LC_ALL=C`, only ASCII lowercase letters are guaranteed to uppercase. Non-ASCII bytes are outside scope for this carrier task and should be treated as pass-through behavior, not a bug.

### 3.4 Source safety

Sourcing `to_upper.sh` must define the function and produce no stdout/stderr output.

## 4. Implementation Guidance

### 4.1 `to_upper.sh`

- Use `#!/usr/bin/env bash`
- Define `to_upper()` only
- Avoid side effects at file load time
- Avoid reading arguments; read from stdin through the pipeline

### 4.2 `test_to_upper.sh`

The test script should:

- `source` `to_upper.sh`
- run deterministic assertions
- exit `0` only when all assertions pass
- print concise PASS/FAIL lines

Include at least these cases:

1. `hello world` -> `HELLO WORLD`
2. mixed case input -> fully uppercased
3. punctuation and digits preserved
4. multi-line input preserved with letters uppercased
5. empty input -> empty output

## 5. Verification Commands

Blake should run and capture:

```bash
bash -n .tad/evidence/codex-regression/sandbox/to_upper.sh
bash -n .tad/evidence/codex-regression/sandbox/test_to_upper.sh
bash -c 'source .tad/evidence/codex-regression/sandbox/to_upper.sh'
bash .tad/evidence/codex-regression/sandbox/test_to_upper.sh
```

## 6. Acceptance Criteria

- AC1: All task-created files remain under `.tad/evidence/codex-regression/sandbox/`.
- AC2: `to_upper.sh` exists and passes `bash -n`.
- AC3: `test_to_upper.sh` exists and passes `bash -n`.
- AC4: Sourcing `to_upper.sh` produces no output and no error.
- AC5: `to_upper` reads stdin and uppercases ASCII text with `LC_ALL=C` behavior.
- AC6: Empty stdin yields empty stdout and exit `0`.
- AC7: The test script passes independently when run with Bash.

## 7. Out Of Scope

- project-root file changes
- locale-dependent Unicode case folding
- CLI wrapper flags or argument parsing
- framework docs or knowledge-file updates

## 8. Completion Report Requirements

Blake's completion report should state:

- created files
- verification command results
- whether AC1-AC7 passed
- any deviation from the output boundary

## 9. Handoff Note

This is an inline sandbox handoff produced for Codex regression evidence. It is intentionally narrow and does not authorize broader repo changes.
