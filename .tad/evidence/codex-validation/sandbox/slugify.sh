#!/usr/bin/env bash

slugify() {
  local input
  local output
  input="$*"

  output="$(printf '%s' "$input" |
    LC_ALL=C tr '[:upper:]' '[:lower:]' |
    LC_ALL=C tr '\n' '-' |
    LC_ALL=C sed \
      -e 's/[^a-z0-9][^a-z0-9]*/-/g' \
      -e 's/^-//' \
      -e 's/-$//')"

  printf '%s\n' "$output"
}
