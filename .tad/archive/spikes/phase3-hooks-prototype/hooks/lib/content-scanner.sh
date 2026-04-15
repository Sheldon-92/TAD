#!/usr/bin/env bash
# content-scanner.sh — HP-2 env-injection + OV-2 fake-override literal
# v3-LEAN §1 HP-2, §1 OV-2
# Source from dispatcher. Loads .tad/schemas/protected-paths.yaml (env_injection_patterns)
# and .tad/schemas/sentinel-patterns.yaml (fake_override_literal) once.
# Functions:
#   scan_env_injection <content>   → 0 clean | 1 deny with reason on stderr
#   scan_fake_override <content>   → 0 clean | 1 deny with reason on stderr

# shellcheck shell=bash
set -uo pipefail

: "${CONTENT_SCANNER_LOADED:=0}"
if [[ "$CONTENT_SCANNER_LOADED" == "1" ]]; then return 0 2>/dev/null || exit 0; fi
CONTENT_SCANNER_LOADED=1

CS_PG_SCHEMA="${CS_PG_SCHEMA:-.tad/schemas/protected-paths.yaml}"
CS_SENT_SCHEMA="${CS_SENT_SCHEMA:-.tad/schemas/sentinel-patterns.yaml}"

# Load patterns once. Store as newline-joined for single awk scan.
CS_ENV_PATTERNS=""
if [[ -f "$CS_PG_SCHEMA" ]]; then
  CS_ENV_PATTERNS=$(yq -r '.env_injection_patterns[]?' "$CS_PG_SCHEMA" 2>/dev/null || true)
fi
CS_FAKE_OV=""
if [[ -f "$CS_SENT_SCHEMA" ]]; then
  CS_FAKE_OV=$(yq -r '.fake_override_literal' "$CS_SENT_SCHEMA" 2>/dev/null || true)
  [[ "$CS_FAKE_OV" == "null" ]] && CS_FAKE_OV=""
fi

# HP-2: scan for env-injection substrings in content.
# Uses a SINGLE awk pass (per Phase 1c knowledge #3 — no N×grep loop).
# Content is passed via env var CS_INPUT to avoid \n/\t parsing in awk -v.
scan_env_injection() {
  local content="$1"
  [[ -z "$content" ]] && return 0
  [[ -z "$CS_ENV_PATTERNS" ]] && return 0

  local hit
  # Single awk: msg in ENVIRON["CS_INPUT"]; patterns as positional args.
  hit=$(CS_INPUT="$content" printf '%s\n' "$CS_ENV_PATTERNS" | CS_INPUT="$content" awk '
    BEGIN { msg = ENVIRON["CS_INPUT"] }
    NF > 0 {
      pat = $0
      if (index(msg, pat) > 0) {
        print pat
        exit 0
      }
    }
  ')
  if [[ -n "$hit" ]]; then
    printf 'HP-2: env-injection pattern "%s" matched in content\n' "$hit" >&2
    return 1
  fi
  return 0
}

# OV-2: scan for fake TAD_OVERRIDE literal (post-canonicalization).
# Canonicalization pipeline: strip invisible formatters + casefold, then literal match.
# Covers the zero-width bypass case: "TAD\u200BOVERRIDE:" → after strip → "TADOVERRIDE:"
# ... note: zero-width between T+A+D+\u200B+O... strip produces "TADOVERRIDE" not "TAD_OVERRIDE".
# So we only strip ZW chars; casefold normalizes case. We match the fake_override_literal
# (default "tad_override:") after pipeline.
scan_fake_override() {
  local content="$1"
  [[ -z "$content" ]] && return 0
  [[ -z "$CS_FAKE_OV" ]] && return 0

  # Canonicalize via perl (single spawn). Fail-closed: if perl refuses → treat as clean
  # since dep-guard already required perl.
  local canon
  canon=$(printf '%s' "$content" | perl -CSD -Mutf8 -e '
    local $/;
    my $s = <STDIN>;
    # Strip invisible formatters
    $s =~ s/[\x{200B}-\x{200F}\x{202A}-\x{202E}\x{2060}-\x{2069}\x{FEFF}]//g;
    $s = lc $s;
    print $s;
  ' 2>/dev/null || printf '%s' "$content" | tr '[:upper:]' '[:lower:]')

  if [[ "$canon" == *"$CS_FAKE_OV"* ]]; then
    printf 'OV-2: fake-override literal "%s" in tool content\n' "$CS_FAKE_OV" >&2
    return 1
  fi
  return 0
}
