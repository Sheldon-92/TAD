---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/evidence/codex-validation/sandbox"]
skip_knowledge_assessment: no
gate4_delta: []
---

# HANDOFF-20260607-slugify-bash-sandbox

From: Alex, Solution Lead  
To: Blake, Execution Master  
Date: 2026-06-07  
Task ID: TASK-20260607-001  
Status: Ready for implementation after Blake confirms understanding

## Gate 2: Design Completeness

Architecture Complete: PASS  
Components Specified: PASS  
Functions Verified: N/A, create-only task  
Data Flow Mapped: PASS  

Expert review note: This inline non-interactive run did not create review files. Blake must still produce code-review and testing-review evidence under the sandbox evidence directory before Gate 3.

## 1. Task Overview

Build a Bash `slugify` function in:

`.tad/evidence/codex-validation/sandbox/slugify.sh`

Add a companion plain Bash test script in:

`.tad/evidence/codex-validation/sandbox/test_slugify.sh`

All task-created files, including evidence, must live under:

`.tad/evidence/codex-validation/sandbox/`

## 2. Intent

After this lands, users can source one small Bash file and convert arbitrary labels, titles, or filenames into predictable kebab-case slugs without pulling in external dependencies.

This is not a general Unicode transliteration library, not a URL encoder, and not a filesystem sanitizer beyond simple ASCII slug output.

## 3. Requirements

FR1: `slugify.sh` defines a Bash function named `slugify`.

FR2: `slugify` accepts a string input and writes the slug to stdout with a trailing newline.

FR3: Lowercase ASCII letters.

FR4: Convert whitespace and separator-like punctuation runs to a single `-`.

FR5: Strip characters that cannot be represented in the final ASCII kebab-case slug.

FR6: Collapse repeated hyphens and trim leading/trailing hyphens.

FR7: Empty input and all-special input return an empty line with exit code 0.

FR8: `slugify.sh` must be source-safe: sourcing it should not print test output or run assertions.

FR9: `test_slugify.sh` must source `slugify.sh` relative to its own location and run deterministic assertions.

NFR1: Use Bash plus standard macOS-compatible Unix tools only. Avoid GNU-only flags such as `grep -P`.

NFR2: Keep the implementation compact and readable.

NFR3: No files outside `.tad/evidence/codex-validation/sandbox/`.

## 4. Technical Design

Use a custom Bash function because the scope is tiny and dependencies would add more risk than value.

Behavior contract:

| Input | Expected Output |
|-------|-----------------|
| `Hello World` | `hello-world` |
| `  Hello   World  ` | `hello-world` |
| `Hello, World!` | `hello-world` |
| `Already--Sluggy` | `already-sluggy` |
| `C++ Guide: Intro` | `c-guide-intro` |
| `rock & roll` | `rock-roll` |
| `Version 2.0 Release` | `version-2-0-release` |
| `___` | empty string |
| empty string | empty string |

Implementation guidance, not code:

Use a simple text-normalization pipeline inside `slugify`: join arguments into one logical input string, lowercase, replace non-alphanumeric runs with hyphens, collapse hyphens, and trim edges. Set locale behavior deliberately for deterministic ASCII handling.

## 5. Project Knowledge

Relevant knowledge loaded:

| File | Relevance | Key reminder |
|------|-----------|--------------|
| `.tad/project-knowledge/patterns/shell-portability.md` | High | Avoid GNU-only shell options; macOS/BSD compatibility matters. |
| `.tad/project-knowledge/patterns/ac-verification.md` | High | AC commands are the contract; every required evidence file must be explicit. |
| `.claude/skills/web-testing/references/test-strategy-rules.md` | Low/Medium | Use fastest-fail-first local verification; this does not need E2E or browser tooling. |

Blake must read the two project-knowledge files above before implementation.

## 6. Files to Create

`.tad/evidence/codex-validation/sandbox/slugify.sh`

`.tad/evidence/codex-validation/sandbox/test_slugify.sh`

`.tad/evidence/codex-validation/sandbox/evidence/syntax-check.txt`

`.tad/evidence/codex-validation/sandbox/evidence/test-output.txt`

`.tad/evidence/codex-validation/sandbox/evidence/code-review.txt`

`.tad/evidence/codex-validation/sandbox/evidence/testing-review.txt`

`.tad/evidence/codex-validation/sandbox/evidence/completion-report.md`

Grounding pass: target implementation files do not currently exist, so this is create-only.

## 7. Implementation Steps

1. Create the sandbox directory if missing.
2. Create `slugify.sh` with a source-safe `slugify` function.
3. Ensure the file has no side effects when sourced.
4. Create `test_slugify.sh` with assertion helpers and the table of required cases.
5. Ensure the test script resolves `slugify.sh` relative to `test_slugify.sh`, not the caller’s current directory.
6. Run syntax checks and tests.
7. Save all command output evidence under `sandbox/evidence/`.
8. Perform code-review and testing-review passes and save notes under `sandbox/evidence/`.

## 8. Required Evidence Manifest

```yaml
required_evidence:
  syntax_check:
    path: ".tad/evidence/codex-validation/sandbox/evidence/syntax-check.txt"
    must_include:
      - "bash -n .tad/evidence/codex-validation/sandbox/slugify.sh"
      - "bash -n .tad/evidence/codex-validation/sandbox/test_slugify.sh"
      - "exit 0"
  test_output:
    path: ".tad/evidence/codex-validation/sandbox/evidence/test-output.txt"
    command: "bash .tad/evidence/codex-validation/sandbox/test_slugify.sh"
    must_show: "all assertions pass"
  code_review:
    path: ".tad/evidence/codex-validation/sandbox/evidence/code-review.txt"
    reviewer: "code-reviewer"
  testing_review:
    path: ".tad/evidence/codex-validation/sandbox/evidence/testing-review.txt"
    reviewer: "test-runner or testing reviewer"
  completion_report:
    path: ".tad/evidence/codex-validation/sandbox/evidence/completion-report.md"
```

## 9. Acceptance Criteria

AC1: Only files under `.tad/evidence/codex-validation/sandbox/` are created or modified.

Verification:
`find .tad/evidence/codex-validation/sandbox -type f -print`

AC2: `slugify.sh` exists and defines `slugify`.

Verification:
`bash -n .tad/evidence/codex-validation/sandbox/slugify.sh`

AC3: `test_slugify.sh` exists and is syntactically valid.

Verification:
`bash -n .tad/evidence/codex-validation/sandbox/test_slugify.sh`

AC4: Sourcing `slugify.sh` produces no output.

Verification:
`bash -c 'source .tad/evidence/codex-validation/sandbox/slugify.sh'`

AC5: Required slug cases pass.

Verification:
`bash .tad/evidence/codex-validation/sandbox/test_slugify.sh`

AC6: No non-sandbox task evidence files are produced.

Verification:
Review `git status --porcelain` and confirm task-created paths are sandbox-scoped.

## 10. AC Dry-Run Log

All verification commands are post-implementation verifiable. Target files do not exist yet, so Alex did not execute file-specific syntax checks during design.

Conflict matrix: no conflict between structure, performance, and behavior ACs. The task has no byte-preservation or numeric performance budget.

## 11. Notes for Blake

Use portable shell constructs. Do not use `grep -P`, GNU-only `sed -r`, Python, Perl, Node, or external test frameworks for this task.

The function should be easy to source from another script. Keep tests explicit and boring: input, expected output, actual output, pass/fail line.

## Message to Blake

After this lands, your sandbox gains a reusable Bash slug utility plus a deterministic self-test, so future validation tasks can create clean kebab-case names without ad hoc one-off transformations.

Task: slugify Bash utility  
Handoff: inline content from Alex, `HANDOFF-20260607-slugify-bash-sandbox`  
Priority: P2  
Scope: create `slugify.sh`, `test_slugify.sh`, and sandbox-local evidence only  
Key files: `.tad/evidence/codex-validation/sandbox/slugify.sh`, `.tad/evidence/codex-validation/sandbox/test_slugify.sh`  
Notes: all task-created files must stay under `.tad/evidence/codex-validation/sandbox/`  
Action: implement from this handoff in Blake mode.
