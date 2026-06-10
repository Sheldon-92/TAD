#!/usr/bin/env bash

set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=/dev/null
source "$SCRIPT_DIR/to_upper.sh"

failures=0

assert_eq() {
  local name expected actual
  name=$1
  expected=$2
  actual=$3

  if [ "$actual" = "$expected" ]; then
    printf 'PASS %s\n' "$name"
  else
    printf 'FAIL %s\n' "$name"
    printf '  expected: %q\n' "$expected"
    printf '  actual:   %q\n' "$actual"
    failures=$((failures + 1))
  fi
}

assert_status() {
  local name expected actual
  name=$1
  expected=$2
  actual=$3

  if [ "$actual" -eq "$expected" ]; then
    printf 'PASS %s\n' "$name"
  else
    printf 'FAIL %s\n' "$name"
    printf '  expected status: %s\n' "$expected"
    printf '  actual status:   %s\n' "$actual"
    failures=$((failures + 1))
  fi
}

run_case() {
  local name input expected output
  name=$1
  input=$2
  expected=$3
  output=$(printf '%s' "$input" | to_upper)
  assert_eq "$name" "$expected" "$output"
}

run_case "hello-world" "hello world" "HELLO WORLD"
run_case "mixed-case" "MiXeD cAsE" "MIXED CASE"
run_case "punctuation-digits" "abc-123!? z" "ABC-123!? Z"
run_case "multiline" $'line one\nline Two\nline 3' $'LINE ONE\nLINE TWO\nLINE 3'

empty_output=$(printf '' | to_upper)
empty_status=$?
assert_eq "empty-output" "" "$empty_output"
assert_status "empty-status" 0 "$empty_status"

if [ "$failures" -eq 0 ]; then
  printf 'PASS all\n'
  exit 0
fi

printf 'FAIL total=%s\n' "$failures"
exit 1
