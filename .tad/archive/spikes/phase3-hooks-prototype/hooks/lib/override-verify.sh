#!/usr/bin/env bash
# override-verify.sh — OV-1 regex + reason validation + nonce lifecycle
# v3-LEAN §6
# Functions:
#   validate_override_prompt <prompt>           → prints: gate\treason   (stdout) | 1 invalid
#   allocate_nonce <gate> <session_id>          → prints: nonce (stdout), idempotent
#   consume_nonce <gate> <session_id>           → 0 consumed | 1 no-match
#   append_override_log <gate> <reason> <nonce> <session_id>

# shellcheck shell=bash
set -uo pipefail

: "${OVERRIDE_VERIFY_LOADED:=0}"
if [[ "$OVERRIDE_VERIFY_LOADED" == "1" ]]; then return 0 2>/dev/null || exit 0; fi
OVERRIDE_VERIFY_LOADED=1

OV_STATE_DIR="${OV_STATE_DIR:-.tad/state}"
OV_NONCES_FILE="${OV_STATE_DIR}/nonces.jsonl"
OV_LOG_FILE="${OV_STATE_DIR}/override-log.jsonl"
OV_TTL_SECONDS="${OV_TTL_SECONDS:-3600}"   # 1h

# Gate enum (§1)
_ov_valid_gate() {
  case "$1" in
    gate2|gate3|gate4|protected-path|cross-role-edit|bootstrap-first-run|emergency|rationalization-ack) return 0 ;;
    *) return 1 ;;
  esac
}

# Forbidden substrings in reason (§6 sanitize rule).
_ov_reason_valid() {
  local reason="$1"
  # Length ≥20 non-whitespace chars
  local nows
  nows=$(printf '%s' "$reason" | perl -CSD -ne 'chomp; s/\s+//g; print')
  if (( ${#nows} < 20 )); then
    printf 'OVERRIDE_INVALID: reason has %d non-whitespace chars (<20)\n' "${#nows}" >&2
    return 1
  fi
  # No literal \t or \n
  if printf '%s' "$reason" | grep -qP '[\t\n]' 2>/dev/null; then :; fi   # grep -P may not work on mac
  if printf '%s' "$reason" | perl -ne 'exit 0 if /[\t\n]/; END { exit 1 }'; then
    printf 'OVERRIDE_INVALID: reason contains raw tab/newline\n' >&2
    return 1
  fi
  # Forbidden substrings
  local forbid
  for forbid in 'prev_hmac=' 'hmac=' 'ts=' 'source=' 'FAKE_ROW'; do
    if [[ "$reason" == *"$forbid"* ]]; then
      printf 'OVERRIDE_INVALID: reason contains forbidden substring "%s"\n' "$forbid" >&2
      return 1
    fi
  done
  return 0
}

# Parse prompt for ^TAD_OVERRIDE: <gate> <reason>$ (line-start strict).
# Stdout: "gate\treason"   on success.
validate_override_prompt() {
  local prompt="$1"
  [[ -z "$prompt" ]] && return 1
  # Line-start strict: must be at start of prompt or after \n, exactly one line.
  local line
  line=$(printf '%s' "$prompt" | perl -CSD -e '
    local $/;
    my $p = <STDIN>;
    if ($p =~ /^TAD_OVERRIDE:[ \t]+(\S+)[ \t]+(.+?)$/m) {
      print "$1\t$2";
    }
  ')
  if [[ -z "$line" ]]; then
    return 1
  fi
  local gate reason
  gate="${line%%$'\t'*}"
  reason="${line#*$'\t'}"
  if ! _ov_valid_gate "$gate"; then
    printf 'OVERRIDE_INVALID: unknown gate=%s\n' "$gate" >&2
    return 1
  fi
  if ! _ov_reason_valid "$reason"; then
    return 1
  fi
  printf '%s\t%s\n' "$gate" "$reason"
  return 0
}

_ov_now_iso() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
_ov_now_epoch() { date -u +%s; }

_ov_ensure_state() {
  mkdir -p "$OV_STATE_DIR" 2>/dev/null || true
  chmod 700 "$OV_STATE_DIR" 2>/dev/null || true
  : > /dev/null
  for f in "$OV_NONCES_FILE" "$OV_LOG_FILE"; do
    if [[ ! -f "$f" ]]; then
      ( umask 077; : > "$f" )
    fi
    chmod 600 "$f" 2>/dev/null || true
  done
}

# Idempotent nonce allocation: if an unconsumed+unexpired match (session+gate)
# exists, return its nonce. Otherwise, generate new.
allocate_nonce() {
  local gate="$1" session_id="$2"
  _ov_ensure_state

  local now_epoch; now_epoch=$(_ov_now_epoch)
  local existing
  existing=$(perl -CSD -e '
    my ($file, $gate, $sid, $now, $ttl) = @ARGV;
    open(my $fh, "<", $file) or exit 0;
    while (my $line = <$fh>) {
      chomp $line;
      next unless $line =~ /^\{/;
      my ($nonce) = $line =~ /"nonce"\s*:\s*"([^"]+)"/;
      my ($g)     = $line =~ /"gate"\s*:\s*"([^"]+)"/;
      my ($s)     = $line =~ /"session_id"\s*:\s*"([^"]+)"/;
      my ($ts)    = $line =~ /"issued_epoch"\s*:\s*(\d+)/;
      my ($c)     = $line =~ /"consumed_ts"\s*:\s*(null|"[^"]*")/;
      next unless $g && $s && $nonce && defined $ts;
      next if $g ne $gate || $s ne $sid;
      next if $c ne "null";
      next if ($now - $ts) > $ttl;
      print $nonce;
      exit 0;
    }
  ' -- "$OV_NONCES_FILE" "$gate" "$session_id" "$now_epoch" "$OV_TTL_SECONDS")

  if [[ -n "$existing" ]]; then
    printf '%s\n' "$existing"
    return 0
  fi

  # Generate new nonce: openssl rand base32
  local nonce
  nonce=$(openssl rand -hex 16 2>/dev/null || perl -e 'my @c=("a".."z",0..9); print join "", map { $c[rand @c] } 1..32')
  local iso; iso=$(_ov_now_iso)
  local rec
  rec=$(perl -CSD -e '
    my ($nonce, $iso, $epoch, $gate, $sid) = @ARGV;
    my %h = (
      nonce => $nonce, issued_ts => $iso, issued_epoch => $epoch + 0,
      gate => $gate, session_id => $sid, consumed_ts => undef,
    );
    my @parts;
    for my $k (qw(nonce issued_ts issued_epoch gate session_id consumed_ts)) {
      my $v = $h{$k};
      if ($k eq "issued_epoch") { push @parts, "\"$k\":$v"; next; }
      if (!defined $v) { push @parts, "\"$k\":null"; next; }
      $v =~ s/\\/\\\\/g; $v =~ s/"/\\"/g;
      push @parts, "\"$k\":\"$v\"";
    }
    print "{", join(",", @parts), "}";
  ' -- "$nonce" "$iso" "$now_epoch" "$gate" "$session_id")
  printf '%s\n' "$rec" >> "$OV_NONCES_FILE"
  printf '%s\n' "$nonce"
}

# Consume a nonce: find unconsumed match and mark consumed_ts.
# Returns 0 on successful consumption, 1 if no unconsumed match.
consume_nonce() {
  local gate="$1" session_id="$2"
  _ov_ensure_state
  local now_iso; now_iso=$(_ov_now_iso)
  local now_epoch; now_epoch=$(_ov_now_epoch)

  # Rewrite file in place (simple, acceptable for small JSONL).
  local tmp="${OV_NONCES_FILE}.tmp.$$"
  local consumed
  consumed=$(perl -CSD -e '
    my ($in, $out, $gate, $sid, $now_iso, $now_epoch, $ttl) = @ARGV;
    open(my $fh, "<", $in) or exit 0;
    open(my $oh, ">", $out) or die "open $out: $!";
    my $done = 0;
    while (my $line = <$fh>) {
      my $orig = $line;
      chomp $line;
      if (!$done && $line =~ /^\{/) {
        my ($g) = $line =~ /"gate"\s*:\s*"([^"]+)"/;
        my ($s) = $line =~ /"session_id"\s*:\s*"([^"]+)"/;
        my ($ts) = $line =~ /"issued_epoch"\s*:\s*(\d+)/;
        my ($c)  = $line =~ /"consumed_ts"\s*:\s*(null|"[^"]*")/;
        if ($g && $s && $g eq $gate && $s eq $sid && $c eq "null"
            && defined $ts && ($now_epoch - $ts) <= $ttl) {
          $line =~ s/"consumed_ts"\s*:\s*null/"consumed_ts":"$now_iso"/;
          print $oh "$line\n";
          print "ok";
          $done = 1;
          next;
        }
      }
      print $oh $orig;
    }
  ' -- "$OV_NONCES_FILE" "$tmp" "$gate" "$session_id" "$now_iso" "$now_epoch" "$OV_TTL_SECONDS" 2>&1)

  if [[ "$consumed" == "ok" ]]; then
    mv "$tmp" "$OV_NONCES_FILE"
    chmod 600 "$OV_NONCES_FILE" 2>/dev/null || true
    return 0
  fi
  rm -f "$tmp"
  return 1
}

append_override_log() {
  local gate="$1" reason="$2" nonce="$3" session_id="$4"
  _ov_ensure_state
  local iso; iso=$(_ov_now_iso)
  local rec
  rec=$(perl -CSD -e '
    my ($iso, $gate, $reason, $nonce, $sid) = @ARGV;
    my %h = (ts=>$iso, gate=>$gate, reason=>$reason, nonce=>$nonce, user_session=>$sid);
    my @parts;
    for my $k (qw(ts gate reason nonce user_session)) {
      my $v = $h{$k} // "";
      $v =~ s/\\/\\\\/g; $v =~ s/"/\\"/g; $v =~ s/\n/\\n/g; $v =~ s/\t/\\t/g;
      push @parts, "\"$k\":\"$v\"";
    }
    print "{", join(",", @parts), "}";
  ' -- "$iso" "$gate" "$reason" "$nonce" "$session_id")
  printf '%s\n' "$rec" >> "$OV_LOG_FILE"
  chmod 600 "$OV_LOG_FILE" 2>/dev/null || true
}
