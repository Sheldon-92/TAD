# Inline Handoff: to_upper Strict Sandbox

## Task Overview

Create a small shell utility in the current working directory only.

Files to create:
- `./to_upper.sh`
- `./test_to_upper.sh`

## Requirements

- Function reads only from `stdin`
- Function writes transformed content to `stdout`
- Force `LC_ALL=C` for the transformation step
- Empty input must return success and emit nothing
- Preserve whitespace, newlines, digits, punctuation, and non-lowercase bytes unchanged
- Include an executable test script that can be run locally from the current directory

## Design

Implementation target: POSIX `sh`-compatible script

Proposed function shape:

```sh
to_upper() {
  LC_ALL=C tr '[:lower:]' '[:upper:]'
}
```

## Acceptance Criteria

- `printf 'abc\n' | ./to_upper.sh` outputs `ABC`
- `printf '' | ./to_upper.sh` outputs nothing and exits `0`
- `printf 'Abc 123 !?\n' | ./to_upper.sh` outputs `ABC 123 !?`
- `printf 'hello\nworld\n' | ./to_upper.sh` preserves line structure as uppercase
- Tests pass via `sh ./test_to_upper.sh`

## Notes

- Keep to ASCII-safe behavior only; do not attempt Unicode case mapping
- Do not use bash-only features unless necessary
- Keep all artifacts in `./`
