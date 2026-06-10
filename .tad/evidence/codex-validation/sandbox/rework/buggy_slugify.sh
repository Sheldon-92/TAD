#!/usr/bin/env bash
# Slugify using portable POSIX character classes.
slugify() {
  printf '%s\n' "$1" |
    tr '[:upper:]' '[:lower:]' |
    sed 's/[^[:alnum:]][^[:alnum:]]*/-/g; s/^-//; s/-$//'
}
