#!/bin/sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

assert_stdout() {
  input=$1
  expected=$2

  actual=$(printf '%s' "$input" | "$SCRIPT_DIR/to_upper.sh")
  if [ "$actual" != "$expected" ]; then
    printf 'FAIL: expected [%s], got [%s]\n' "$expected" "$actual" >&2
    exit 1
  fi
}

assert_empty_success() {
  actual=$(printf '' | "$SCRIPT_DIR/to_upper.sh")
  status=$?

  if [ "$status" -ne 0 ]; then
    printf 'FAIL: empty input exited with %s\n' "$status" >&2
    exit 1
  fi

  if [ -n "$actual" ]; then
    printf 'FAIL: expected empty output for empty input, got [%s]\n' "$actual" >&2
    exit 1
  fi
}

assert_stdout 'abc
' 'ABC'
assert_empty_success
assert_stdout 'Abc 123 !?
' 'ABC 123 !?'
assert_stdout 'hello
world
' 'HELLO
WORLD'

printf 'PASS\n'
