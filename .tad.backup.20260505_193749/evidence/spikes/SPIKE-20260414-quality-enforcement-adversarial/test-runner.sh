#!/bin/bash
# test-runner.sh — Adversarial spike driver.
#
# Modes:
#   bash test-runner.sh [category]        — run one category (or all if omitted)
#   bash test-runner.sh --re-verify       — recompute everything from fixtures,
#                                           compare against committed TSVs.
#                                           exit 1 on any mismatch. (FR9/AC15)
#
# Fixture format (YAML per file in attack-fixtures/<cat>/<id>.yaml):
#   id: "sb-001"
#   polarity: "attack"              # or "benign"
#   target_hook: "hardened-pretool"  # or override/evidence/bash-watcher
#   attack_input: |                  # verbatim stdin JSON OR file content
#     {...json...}                   # (for hook tests)
#     OR raw markdown (for evidence validator tests)
#   expected_decision: "deny"        # attack→deny; benign→allow (for hook);
#                                    # or "exit_0"/"exit_1" (for validator)
#   ...
#
# TSV output columns (per FR10):
#   id  polarity  decision  expected  verdict  fixture_sha256  decision_sha256  signature
#
# verdict ∈ {BLOCKED, BYPASSED, KNOWN-GAP, FALSE_POSITIVE, PASS}
#   BLOCKED       = attack, decision=deny (hook blocked, as expected)
#   BYPASSED      = attack, decision=allow (hook failed to block)
#   KNOWN-GAP     = attack, decision=allow, but documented in phase2-feed.yaml
#   PASS          = benign, decision=allow (hook correctly permits)
#   FALSE_POSITIVE= benign, decision=deny (hook over-rejects)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT_DIR"
SPIKE_REL=".tad/evidence/spikes/SPIKE-20260414-quality-enforcement-adversarial"
SPIKE="$ROOT_DIR/$SPIKE_REL"

source "$SPIKE/lib/hmac.sh"

# ── Deterministic state setup (Cat 3/4 override detector requires nonce registry seed) ──
reset_override_state() {
  mkdir -p .tad/evidence/overrides
  cat > .tad/evidence/overrides/nonce-registry.txt <<'EOF'
beefcafe12345678
c0ffee00deadbeef
a1b2c3d4e5f60718
d15ea5ed99887766
fa11deadface1234
deadbeef87654321
EOF
  echo 'beefcafe12345678' > .tad/evidence/overrides/nonce-consumed.txt
  : > .tad/evidence/overrides/spike-1b.log
}

CATEGORIES=(sentinel-bypass evidence-forgery override-injection log-integrity hook-file-protection toctou settings-local-bypass evidence-write-path)

# Map category → hook
declare_hook_for_category() {
  case "$1" in
    sentinel-bypass)          echo "hardened-pretool-interceptor.sh" ;;
    evidence-forgery)         echo "hardened-evidence-validator.sh" ;;
    override-injection)       echo "hardened-override-detector.sh" ;;
    log-integrity)            echo "hardened-override-detector.sh" ;;
    hook-file-protection)     echo "hardened-pretool-interceptor.sh" ;;
    toctou)                   echo "hardened-pretool-interceptor.sh" ;;
    settings-local-bypass)    echo "hardened-pretool-interceptor.sh" ;;
    evidence-write-path)      echo "hardened-bash-watcher.sh" ;;
    *) echo "" ;;
  esac
}

# Parse a YAML fixture file (minimal parser — we control the schema)
# Outputs (via eval-safe vars): FIXID POLARITY TARGET HOOK EXPECTED STDIN_PAYLOAD PATH_ARG
parse_fixture() {
  local file="$1"
  # Use perl for robust YAML block-scalar parsing (no yq dependency)
  perl -e '
    use strict;
    use warnings;
    my $file = shift;
    # <:raw preserves exact UTF-8 byte sequences (NBSP, ZW chars, etc.).
    # <:encoding(UTF-8) would decode to Perl chars and then corrupt on print
    # because downstream shell pipe expects raw bytes. Fixture integrity requires byte-exactness.
    open(my $fh, "<:raw", $file) or die "open $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    my %fields;
    # Parse top-level scalar fields
    while ($content =~ /^([a-z_]+):\s*"?([^"\n]*?)"?\s*$/mg) {
      $fields{$1} = $2;
    }
    # Parse block scalars (| literal)
    while ($content =~ /^([a-z_]+):\s*\|\s*\n((?:[ ]+[^\n]*\n?)+)/mg) {
      my ($k, $body) = ($1, $2);
      # Strip leading indent (min common)
      my @lines = split /\n/, $body;
      my $min_indent = 999;
      for my $ln (@lines) {
        next if $ln =~ /^\s*$/;
        if ($ln =~ /^(\s+)/) {
          my $n = length($1);
          $min_indent = $n if $n < $min_indent;
        }
      }
      $min_indent = 0 if $min_indent == 999;
      my @dedented = map { s/^\s{$min_indent}//; $_ } @lines;
      $fields{$k} = join("\n", @dedented);
    }
    # v2.1 schema: `input` is alias for `attack_input`; polarity "negative" → attack,
    # "positive_control" → benign. Normalize on output.
    my $input = $fields{attack_input} // $fields{input} // "";
    my $polarity = $fields{polarity} // "";
    if ($polarity eq "negative") { $polarity = "attack"; }
    elsif ($polarity eq "positive_control") { $polarity = "benign"; }
    # Default expected_decision if absent: attack → deny, benign → allow
    my $expected = $fields{expected_decision} // "";
    if ($expected eq "") {
      $expected = ($polarity eq "attack") ? "deny" : "allow";
    }
    my %out = (
      id => $fields{id} // "",
      polarity => $polarity,
      target_hook => $fields{target_hook} // "",
      expected_decision => $expected,
      attack_input => $input,
      path_arg => $fields{path_arg} // "",
    );
    $out{harness_hint} = $fields{harness_hint} // "";
    $out{known_gap_reason} = $fields{known_gap_reason} // "";
    for my $k (qw(id polarity target_hook expected_decision attack_input path_arg harness_hint known_gap_reason)) {
      my $v = $out{$k} // "";
      $v =~ s/\x27/\x27\\\x27\x27/g;
      print "FIXTURE_${\ uc($k) }=\x27$v\x27\n";
    }
  ' "$file"
}

# Run one fixture → returns decision string
# Routes to the correct hook script + verdict-measurement method based on target_hook.
run_fixture() {
  local fixture_file="$1"
  local decision=""

  eval "$(parse_fixture "$fixture_file")"

  # Map short target_hook names to actual script filenames
  local script_name="$FIXTURE_TARGET_HOOK"
  case "$script_name" in
    *.sh) ;;
    hardened-pretool) script_name="hardened-pretool-interceptor.sh" ;;
    hardened-pretool-interceptor) script_name="hardened-pretool-interceptor.sh" ;;
    hardened-override) script_name="hardened-override-detector.sh" ;;
    hardened-override-detector) script_name="hardened-override-detector.sh" ;;
    hardened-evidence) script_name="hardened-evidence-validator.sh" ;;
    hardened-evidence-validator) script_name="hardened-evidence-validator.sh" ;;
    hardened-bash-watcher) script_name="hardened-bash-watcher.sh" ;;
    *) script_name="$FIXTURE_TARGET_HOOK.sh" ;;
  esac
  local hook_script="$SPIKE/$script_name"
  if [ ! -x "$hook_script" ]; then
    # Fallback: derive from category
    local cat
    cat=$(basename "$(dirname "$fixture_file")")
    hook_script="$SPIKE/$(declare_hook_for_category "$cat")"
  fi

  case "$script_name" in
    hardened-evidence-validator.sh)
      # Evidence validator: input is raw markdown; write to temp file; exit code decides.
      # harness_hint options:
      #   symlink_to_valid → create tmp path as a symlink (tests symlink rejection)
      #   old_mtime        → touch tmp with 1970 timestamp (for staleness tests)
      local tmp
      tmp=$(mktemp --suffix=.md 2>/dev/null || mktemp -t fixture.md)
      rm -f "$tmp"  # start fresh
      case "${FIXTURE_HARNESS_HINT:-}" in
        symlink_to_valid)
          # Create a real valid .md file, then symlink tmp → it
          local real="$tmp.real"
          printf '%s' "$FIXTURE_ATTACK_INPUT" > "$real"
          ln -sf "$real" "$tmp"
          ;;
        old_mtime)
          printf '%s' "$FIXTURE_ATTACK_INPUT" > "$tmp"
          touch -t 199501010000 "$tmp" 2>/dev/null || touch -d "1995-01-01" "$tmp" 2>/dev/null || true
          ;;
        *)
          printf '%s' "$FIXTURE_ATTACK_INPUT" > "$tmp"
          ;;
      esac
      if bash "$hook_script" "$tmp" >/dev/null 2>&1; then
        decision="exit_0"
      else
        decision="exit_1"
      fi
      rm -f "$tmp" "$tmp.real" 2>/dev/null
      ;;
    hardened-override-detector.sh)
      # Override detector: input is stdin JSON envelope. Verdict = log file line delta.
      # 0 line delta = rejected (correct deny); +1 line delta = accepted (correct allow).
      local log_file=".tad/evidence/overrides/spike-1b.log"
      local before_count after_count
      before_count=$(wc -l < "$log_file" 2>/dev/null | tr -d ' ' || echo 0)
      printf '%s' "$FIXTURE_ATTACK_INPUT" | bash "$hook_script" >/dev/null 2>&1 || true
      after_count=$(wc -l < "$log_file" 2>/dev/null | tr -d ' ' || echo 0)
      local delta=$((after_count - before_count))
      if [ "$delta" -eq 0 ]; then
        decision="deny"  # reject = no log line written
      else
        decision="allow"  # accept = log line appended
      fi
      ;;
    *)
      # Pretool / bash-watcher / etc: stdin JSON; stdout permissionDecision JSON.
      local out
      out=$(printf '%s' "$FIXTURE_ATTACK_INPUT" | bash "$hook_script" 2>/dev/null || echo '{}')
      decision=$(printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "empty"' 2>/dev/null || echo "empty")
      ;;
  esac

  printf '%s' "$decision"
}

# Compute verdict from decision + polarity + expected
# Returns: BLOCKED | BYPASSED | PASS | FALSE_POSITIVE
compute_verdict() {
  local polarity="$1"
  local decision="$2"
  local expected="$3"
  local known_gap_reason="${4:-}"

  if [ "$polarity" = "benign" ]; then
    # benign should be ALLOWED (allow / exit_0)
    case "$decision" in
      allow|exit_0) echo "PASS" ;;
      *)            echo "FALSE_POSITIVE" ;;
    esac
  else
    # attack should be BLOCKED (deny / exit_1)
    case "$decision" in
      deny|exit_1) echo "BLOCKED" ;;
      *)
        # If fixture explicitly declares known_gap_reason, emit KNOWN-GAP
        # (per AC5: must include PoC + Phase 2 cost in phase2-feed.yaml).
        if [ -n "$known_gap_reason" ]; then
          echo "KNOWN-GAP"
        else
          echo "BYPASSED"
        fi
        ;;
    esac
  fi
}

# Run all fixtures in a category and write TSV
run_category() {
  local cat="$1"
  local fix_dir="$SPIKE/attack-fixtures/$cat"
  local out_tsv="$SPIKE/results/${cat}-results.tsv"

  if [ ! -d "$fix_dir" ]; then
    echo "  no fixtures for $cat (skipping)" >&2
    return
  fi

  printf 'id\tpolarity\tdecision\texpected\tverdict\tfixture_sha256\tdecision_sha256\tsignature\n' > "$out_tsv"

  local count=0
  while IFS= read -r fixture_file; do
    eval "$(parse_fixture "$fixture_file")"
    local decision
    decision=$(run_fixture "$fixture_file")
    local verdict
    verdict=$(compute_verdict "$FIXTURE_POLARITY" "$decision" "$FIXTURE_EXPECTED_DECISION" "$FIXTURE_KNOWN_GAP_REASON")

    local fixture_sha
    fixture_sha=$(sha256_file "$fixture_file")
    local decision_sha
    decision_sha=$(sha256_string "$decision")
    local sig
    sig=$(hmac_sign "$FIXTURE_ID" "$FIXTURE_POLARITY" "$decision" "$verdict" "$fixture_sha" "$decision_sha")

    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$FIXTURE_ID" "$FIXTURE_POLARITY" "$decision" "$FIXTURE_EXPECTED_DECISION" \
      "$verdict" "$fixture_sha" "$decision_sha" "$sig" \
      >> "$out_tsv"

    count=$((count + 1))
  done < <(find "$fix_dir" -maxdepth 1 -type f -name '*.yaml' | sort)

  echo "  $cat: $count fixtures → $out_tsv" >&2
}

# ─────────────────────────────────────────────────────────────────
# --re-verify mode: recompute and diff against committed TSVs (FR9/AC15)
# ─────────────────────────────────────────────────────────────────
reverify() {
  local diff_found=0
  local tmp_dir
  tmp_dir=$(mktemp -d)

  for cat in "${CATEGORIES[@]}"; do
    local fix_dir="$SPIKE/attack-fixtures/$cat"
    [ -d "$fix_dir" ] || continue
    local fix_count
    fix_count=$(find "$fix_dir" -maxdepth 1 -type f -name '*.yaml' 2>/dev/null | wc -l | tr -d ' ')
    [ "$fix_count" -gt 0 ] || continue

    # Reset override state before each override-related category for determinism
    case "$cat" in
      override-injection|log-integrity) reset_override_state ;;
    esac

    # Recompute all TSVs into tmp_dir (NOT touching committed results/)
    local committed="$SPIKE/results/${cat}-results.tsv"
    local recomputed="$tmp_dir/${cat}-results.tsv"

    printf 'id\tpolarity\tdecision\texpected\tverdict\tfixture_sha256\tdecision_sha256\tsignature\n' > "$recomputed"
    while IFS= read -r fixture_file; do
      eval "$(parse_fixture "$fixture_file")"
      local decision
      decision=$(run_fixture "$fixture_file")
      local verdict
      verdict=$(compute_verdict "$FIXTURE_POLARITY" "$decision" "$FIXTURE_EXPECTED_DECISION" "$FIXTURE_KNOWN_GAP_REASON")
      local fixture_sha
      fixture_sha=$(sha256_file "$fixture_file")
      local decision_sha
      decision_sha=$(sha256_string "$decision")
      local sig
      sig=$(hmac_sign "$FIXTURE_ID" "$FIXTURE_POLARITY" "$decision" "$verdict" "$fixture_sha" "$decision_sha")
      printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$FIXTURE_ID" "$FIXTURE_POLARITY" "$decision" "$FIXTURE_EXPECTED_DECISION" \
        "$verdict" "$fixture_sha" "$decision_sha" "$sig" \
        >> "$recomputed"
    done < <(find "$fix_dir" -maxdepth 1 -type f -name '*.yaml' | sort)

    if [ ! -f "$committed" ]; then
      echo "MISSING: $committed (not committed yet)" >&2
      diff_found=$((diff_found + 1))
      continue
    fi

    # Compare — ignoring any trailing whitespace, but full content otherwise
    if ! diff -q "$recomputed" "$committed" >/dev/null 2>&1; then
      echo "MISMATCH: $cat" >&2
      echo "  Committed: $committed" >&2
      echo "  Recomputed: $recomputed" >&2
      echo "  --- diff (committed → recomputed) ---" >&2
      diff "$committed" "$recomputed" | head -30 >&2
      diff_found=$((diff_found + 1))
    fi

    # Verify every committed row's HMAC (catches post-hoc signature tampering too)
    local bad_hmac=0
    while IFS=$'\t' read -r id polarity decision expected verdict fsha dsha sig; do
      [ "$id" = "id" ] && continue  # skip header
      local expected_sig
      expected_sig=$(hmac_sign "$id" "$polarity" "$decision" "$verdict" "$fsha" "$dsha")
      if [ "$sig" != "$expected_sig" ]; then
        echo "HMAC MISMATCH: $cat $id (expected $expected_sig, got $sig)" >&2
        bad_hmac=$((bad_hmac + 1))
      fi
    done < "$committed"
    if [ "$bad_hmac" -gt 0 ]; then
      diff_found=$((diff_found + 1))
    fi
  done

  rm -rf "$tmp_dir"

  if [ "$diff_found" -gt 0 ]; then
    echo "" >&2
    echo "❌ --re-verify FAILED: $diff_found category mismatches" >&2
    exit 1
  fi
  echo "✅ --re-verify PASSED: all committed TSVs match recomputed" >&2
  exit 0
}

# ─────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────
if [ "${1:-}" = "--re-verify" ]; then
  reset_override_state
  reverify
fi

mkdir -p "$SPIKE/results"
reset_override_state

if [ "${1:-}" = "" ] || [ "${1:-}" = "all" ]; then
  for cat in "${CATEGORIES[@]}"; do
    # Reset override state before each override-related category to ensure determinism
    case "$cat" in
      override-injection|log-integrity) reset_override_state ;;
    esac
    run_category "$cat"
  done
else
  run_category "$1"
fi
