#!/usr/bin/env bash
set -u
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$dir/buggy_slugify.sh"
fail=0
check(){ local got; got="$(slugify "$1")"; if [ "$got" = "$2" ]; then echo "PASS: [$1] -> [$got]"; else echo "FAIL: [$1] expected [$2] got [$got]"; fail=$((fail+1)); fi; }
check "Hello World" "hello-world"
check "a  b" "a-b"
check "Hello, World!" "hello-world"
if [ "$fail" -eq 0 ]; then echo "all assertions pass"; exit 0; else echo "$fail assertion(s) failed"; exit 1; fi
