#!/usr/bin/env bash
set -u

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/slugify.sh"

failures=0

assert_slug() {
  local input="$1"
  local expected="$2"
  local actual

  actual="$(slugify "$input")"
  if [[ "$actual" == "$expected" ]]; then
    printf 'PASS: %q -> %q\n' "$input" "$actual"
  else
    printf 'FAIL: %q expected %q got %q\n' "$input" "$expected" "$actual"
    failures=$((failures + 1))
  fi
}

assert_slug 'Hello World' 'hello-world'
assert_slug '  Hello   World  ' 'hello-world'
assert_slug 'Hello, World!' 'hello-world'
assert_slug 'Already--Sluggy' 'already-sluggy'
assert_slug 'C++ Guide: Intro' 'c-guide-intro'
assert_slug 'rock & roll' 'rock-roll'
assert_slug 'Version 2.0 Release' 'version-2-0-release'
assert_slug $'Line One\nLine Two' 'line-one-line-two'
assert_slug '___' ''
assert_slug '' ''

if (( failures == 0 )); then
  printf 'all assertions pass\n'
  exit 0
fi

printf '%d assertion(s) failed\n' "$failures"
exit 1
