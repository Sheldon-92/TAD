#!/usr/bin/env bash
# ============================================================================
# pack-eval-runner.sh — Capability Pack Behavioral Eval ASSERTION engine
# ============================================================================
# SAFETY HEADER (advisory — NEVER fail-closed):
#   - This is NOT a hook. It is a developer-run assertion tool.
#   - It NEVER blocks, denies, or gates any agent action. It only PRINTS
#     PASS/FAIL verdicts for captured agent outputs against pack fixtures.
#   - It MUST NOT use `set -e` (a parse miss on one fixture must not abort
#     a batch run). Missing files / unparseable fixtures degrade to a
#     skip/0-count, never a non-zero abort.
#   - Division of labour: this script ASSERTS (greps a captured agent
#     output for fixture markers, checks min_discriminative). The CONDUCTOR
#     drives sub-agent spawning to PRODUCE those outputs — a bash script
#     cannot spawn Claude agents. That separation is intentional.
#   - PRIMARY GATE = DISCRIMINATIVE markers only (pack-specific named rules /
#     numbers / pack-introduced terms). The combined `## Verification Command`
#     pattern MIXES pack-specific + generic markers, so a no-pack agent can
#     pass on generic markers alone (proven: the ai-evaluation CONTROL scored
#     3/3 combined but 0 discriminative). PASS/FAIL is driven by the
#     discriminative_pattern + min_discriminative frontmatter fields. The
#     combined count is reported as a SECONDARY context number ONLY.
#   - Backward compat: a fixture with NO discriminative_pattern falls back to
#     the old combined gate and prints a WARN. New fixtures MUST set it.
#   - Portability: BSD/macOS-safe. No `grep -P`. The runner's OWN match
#     uses `grep -oE <pattern> | sort -u | wc -l` (NOT `grep -c`, which
#     counts lines, not distinct matches — that is the P4 lint Rule A bug).
# ============================================================================

# Intentionally NO `set -e`. See SAFETY HEADER.
set -u

# ---------------------------------------------------------------------------
# Resource bounds (Phase 2 — advisory, never fail-closed).
# Caps + wall-clock guard + pattern-length caps. Bound trips degrade to
# SKIP/timeout verdict TEXT, process exit stays 0 (see main).
# Check order in assert_one (before EVERY grep, incl. validity probe):
#   1. symlink/regular -> fixture AND output ([ -f ] && [ ! -L ])
#   2. fixture 512 KiB cap BEFORE awk parsing; output 1 MiB cap
#   3. post-unescape byte-length on BOTH patterns, 4 KiB each
#   4. guarded probe + guarded counts (full pipeline under guard)
# Guard chain: gtimeout 10s -> timeout 10s -> perl alarm 10s -> SKIP w/ WARN.
# No-op fallback FORBIDDEN for catastrophic (oversize) inputs; allowed+logged
# for benign small inputs only. Probe order: gtimeout || timeout || perl.
# Frozen strings: TIMEOUT → SKIP (bounded) vs OVERSIZE → SKIP (bounded) are
# DISTINCT; Gate matches with grep -F -e (never bare grep).
# ---------------------------------------------------------------------------
EVAL_TIMEOUT_S_DEFAULT=10
EVAL_MAX_OUTPUT_B_DEFAULT=1048576
EVAL_MAX_PATTERN_B_DEFAULT=4096
EVAL_MAX_FIXTURE_B_DEFAULT=524288

# resolve_eval_int <raw> <default> <min> <max> <name> -> prints effective value.
# Strict ^[0-9]+$ guard with closed ranges; violation -> default + WARN to stderr.
# Quoted expansion only, no eval.
resolve_eval_int() {
  _raw="$1"; _def="$2"; _min="$3"; _max="$4"; _nm="$5"
  if printf '%s' "$_raw" | grep -qE '^[0-9]+$' 2>/dev/null; then
    if [ "$_raw" -ge "$_min" ] 2>/dev/null && [ "$_raw" -le "$_max" ] 2>/dev/null; then
      printf '%s' "$_raw"
      return 0
    fi
  fi
  printf 'WARN: invalid %s=%s, using default %s\n' "$_nm" "$_raw" "$_def" >&2
  printf '%s' "$_def"
  return 0
}

# Effective bounds (resolved once at startup; inherited env is untrusted).
EVAL_TIMEOUT_S_EFF="$EVAL_TIMEOUT_S_DEFAULT"
EVAL_MAX_OUTPUT_B_EFF="$EVAL_MAX_OUTPUT_B_DEFAULT"
EVAL_MAX_PATTERN_B_EFF="$EVAL_MAX_PATTERN_B_DEFAULT"
EVAL_MAX_FIXTURE_B_EFF="$EVAL_MAX_FIXTURE_B_DEFAULT"
_EVAL_HAVE_OVERRIDE=0
if [ "${EVAL_TIMEOUT_S+set}" = "set" ]; then
  EVAL_TIMEOUT_S_EFF=$(resolve_eval_int "$EVAL_TIMEOUT_S" "$EVAL_TIMEOUT_S_DEFAULT" 1 60 "EVAL_TIMEOUT_S")
  _EVAL_HAVE_OVERRIDE=1
fi
if [ "${EVAL_MAX_OUTPUT_B+set}" = "set" ]; then
  EVAL_MAX_OUTPUT_B_EFF=$(resolve_eval_int "$EVAL_MAX_OUTPUT_B" "$EVAL_MAX_OUTPUT_B_DEFAULT" 65536 16777216 "EVAL_MAX_OUTPUT_B")
  _EVAL_HAVE_OVERRIDE=1
fi
if [ "${EVAL_MAX_PATTERN_B+set}" = "set" ]; then
  EVAL_MAX_PATTERN_B_EFF=$(resolve_eval_int "$EVAL_MAX_PATTERN_B" "$EVAL_MAX_PATTERN_B_DEFAULT" 1024 16384 "EVAL_MAX_PATTERN_B")
  _EVAL_HAVE_OVERRIDE=1
fi
if [ "${EVAL_MAX_FIXTURE_B+set}" = "set" ]; then
  EVAL_MAX_FIXTURE_B_EFF=$(resolve_eval_int "$EVAL_MAX_FIXTURE_B" "$EVAL_MAX_FIXTURE_B_DEFAULT" 65536 4194304 "EVAL_MAX_FIXTURE_B")
  _EVAL_HAVE_OVERRIDE=1
fi

# Guard detection (probe order: gtimeout || timeout || perl). 127 = harness state.
GUARD_MODE="none"
if command -v gtimeout >/dev/null 2>&1; then
  GUARD_MODE="gtimeout"
elif command -v timeout >/dev/null 2>&1; then
  GUARD_MODE="timeout"
elif command -v perl >/dev/null 2>&1 && perl -e 'exit 0' >/dev/null 2>&1; then
  GUARD_MODE="perl"
else
  GUARD_MODE="none"
fi

# Override audit: log EVERY effective value when overrides present (defaults
# included in the set). Defaults-only runs stay silent on stdout/stderr so the
# E2 eval-compat cmp (which captures 2>&1) remains byte-identical; --all header
# always logs (stripped by E2a grep -v before cmp). Violation WARNs above fire
# regardless (to stderr, only when violated).
if [ "$_EVAL_HAVE_OVERRIDE" -eq 1 ]; then
  printf 'EVAL bounds: timeout=%ss output=%s pattern=%s fixture=%s guard=%s\n' "$EVAL_TIMEOUT_S_EFF" "$EVAL_MAX_OUTPUT_B_EFF" "$EVAL_MAX_PATTERN_B_EFF" "$EVAL_MAX_FIXTURE_B_EFF" "$GUARD_MODE" >&2
fi

# file_size_bytes <file> -> bytes via wc -c (bytes, portable). Caller ensures -f.
file_size_bytes() {
  wc -c < "$1" 2>/dev/null | tr -d '[:space:]'
}

# pattern_bytes <string> -> bytes via printf %s | wc -c (bytes, not ${#} chars).
pattern_bytes() {
  printf '%s' "$1" 2>/dev/null | wc -c 2>/dev/null | tr -d '[:space:]'
}

# guarded_exec <timeout_s> -- <cmd...> -> run cmd under wall-clock guard.
# TERM then KILL semantics; 124 on timeout; else child rc. Group-kill: timeout
# -k 5 where available, else perl fork+setpgid+kill -- -pgid (no setsid needed).
# -- end-of-options preserved THROUGH wrapper for dash-leading patterns.
guarded_exec() {
  _gt="$1"; shift
  if [ "${1:-}" = "--" ]; then shift; fi
  # NOTE: gtimeout/timeout -k kills the direct child only (no process-group kill);
  # group-kill is proven on the perl path (live path on macOS w/o coreutils) — Gate-3 on a timeout-equipped host must run the orphan-sleep pipeline test.
  if [ "$GUARD_MODE" = "gtimeout" ]; then
    gtimeout -k 5 "${_gt}s" "$@"
    return $?
  elif [ "$GUARD_MODE" = "timeout" ]; then
    timeout -k 5 "${_gt}s" "$@"
    return $?
  elif [ "$GUARD_MODE" = "perl" ]; then
    perl -MPOSIX -e '
      $t = shift @ARGV;
      $pid = fork();
      die "fork failed: $!" unless defined $pid;
      if ($pid == 0) {
        POSIX::setpgid(0,0);
        exec @ARGV;
        exit 127;
      }
      eval {
        local $SIG{ALRM} = sub { die "TIMEOUT\n" };
        alarm($t);
        waitpid($pid, 0);
        alarm(0);
      };
      if ($@ && $@ eq "TIMEOUT\n") {
        kill("TERM", -$pid);
        sleep(1);
        if (kill(0, -$pid)) {
          kill("KILL", -$pid);
        }
        waitpid($pid, 0);
        exit 124;
      }
      $rc = $? >> 8;
      exit $rc;
    ' "$_gt" "$@"
    return $?
  else
    printf 'WARN: no wall-clock guard available\n' >&2
    "$@"
    return $?
  fi
}

# ---------------------------------------------------------------------------
# parse_min_count <fixture.md>  → prints min_marker_count (default 3)
# ---------------------------------------------------------------------------
parse_min_count() {
  fixture="$1"
  [ -f "$fixture" ] || { echo 3; return 0; }
  # Read frontmatter only (between the first two '---' lines).
  awk '
    /^---[[:space:]]*$/ { fence++; next }
    fence==1 && /^min_marker_count:/ {
      v=$0
      sub(/^min_marker_count:[[:space:]]*/, "", v)
      gsub(/[^0-9]/, "", v)
      if (v != "") { print v; found=1; exit }
    }
    fence>=2 { exit }
    END { if (!found) print 3 }
  ' "$fixture"
}

# ---------------------------------------------------------------------------
# parse_pack <fixture.md> → prints pack name (frontmatter `pack:` or dir)
# ---------------------------------------------------------------------------
parse_pack() {
  fixture="$1"
  pk=""
  if [ -f "$fixture" ]; then
    pk=$(awk '
      /^---[[:space:]]*$/ { fence++; next }
      fence==1 && /^pack:/ {
        v=$0; sub(/^pack:[[:space:]]*/, "", v); gsub(/["'"'"']/, "", v)
        gsub(/[[:space:]]+$/, "", v); print v; exit
      }
      fence>=2 { exit }
    ' "$fixture")
  fi
  if [ -z "$pk" ]; then
    # Fallback: derive from path .claude/skills/<pack>/examples/<name>.md
    pk=$(printf '%s\n' "$fixture" | sed -n 's#.*/skills/\([^/]*\)/examples/.*#\1#p')
  fi
  [ -z "$pk" ] && pk="unknown"
  printf '%s' "$pk"
}

# ---------------------------------------------------------------------------
# parse_skill <fixture.md> → prints skill name (frontmatter `skill:`)
# ---------------------------------------------------------------------------
parse_skill() {
  fixture="$1"
  sk=""
  if [ -f "$fixture" ]; then
    sk=$(awk '
      /^---[[:space:]]*$/ { fence++; next }
      fence==1 && /^skill:/ {
        v=$0; sub(/^skill:[[:space:]]*/, "", v); gsub(/["'"'"']/, "", v)
        gsub(/[[:space:]]+$/, "", v); print v; exit
      }
      fence>=2 { exit }
    ' "$fixture")
  fi
  printf '%s' "$sk"
}

# ---------------------------------------------------------------------------
# parse_pack_raw <fixture.md> → prints pack name from frontmatter only (no fallback)
# ---------------------------------------------------------------------------
parse_pack_raw() {
  fixture="$1"
  pk=""
  if [ -f "$fixture" ]; then
    pk=$(awk '
      /^---[[:space:]]*$/ { fence++; next }
      fence==1 && /^pack:/ {
        v=$0; sub(/^pack:[[:space:]]*/, "", v); gsub(/["'"'"']/, "", v)
        gsub(/[[:space:]]+$/, "", v); print v; exit
      }
      fence>=2 { exit }
    ' "$fixture")
  fi
  printf '%s' "$pk"
}

# ---------------------------------------------------------------------------
# parse_name <fixture.md> → prints fixture name (frontmatter `name:` or base)
# ---------------------------------------------------------------------------
parse_name() {
  fixture="$1"
  nm=""
  if [ -f "$fixture" ]; then
    nm=$(awk '
      /^---[[:space:]]*$/ { fence++; next }
      fence==1 && /^name:/ {
        v=$0; sub(/^name:[[:space:]]*/, "", v); gsub(/["'"'"']/, "", v)
        gsub(/[[:space:]]+$/, "", v); print v; exit
      }
      fence>=2 { exit }
    ' "$fixture")
  fi
  if [ -z "$nm" ]; then
    nm=$(basename "$fixture" .md)
  fi
  printf '%s' "$nm"
}

# ---------------------------------------------------------------------------
# parse_pattern <fixture.md> → prints the grep -oE '...' pattern from the
# bash block under '## Verification Command'. Returns "" if not found.
# ---------------------------------------------------------------------------
parse_pattern() {
  fixture="$1"
  [ -f "$fixture" ] || { printf ''; return 0; }
  awk '
    /^##[[:space:]]+Verification Command/ { invc=1; next }
    invc && /^##[[:space:]]/ { invc=0 }
    invc && /grep -oE/ {
      line=$0
      # Strip everything up to and including the first quote after grep -oE (handles optional --).
      sub(/.*grep -oE([[:space:]]+--[[:space:]]+|[[:space:]]+)'"'"'/, "", line)
      # Strip from the closing quote onward.
      sub(/'"'"'.*/, "", line)
      print line
      exit
    }
  ' "$fixture"
}

# ---------------------------------------------------------------------------
# parse_disc_pattern <fixture.md> → prints the discriminative_pattern value
# from frontmatter (the grep -oE alternation of ONLY pack-specific markers).
# Returns "" if absent (→ fallback to combined gate). Reads frontmatter only.
# Handles optional surrounding single/double quotes; un-escapes YAML \\ → \.
# ---------------------------------------------------------------------------
parse_disc_pattern() {
  fixture="$1"
  [ -f "$fixture" ] || { printf ''; return 0; }
  awk '
    /^---[[:space:]]*$/ { fence++; next }
    fence==1 && /^discriminative_pattern:/ {
      v=$0
      sub(/^discriminative_pattern:[[:space:]]*/, "", v)
      # Strip a single pair of surrounding quotes (double or single) if present.
      if (v ~ /^".*"$/)      { v=substr(v,2,length(v)-2) }
      else if (v ~ /^'"'"'.*'"'"'$/) { v=substr(v,2,length(v)-2) }
      # YAML double-quoted strings escape backslash as \\ — collapse to a single \.
      gsub(/\\\\/, "\\", v)
      print v
      exit
    }
    fence>=2 { exit }
  ' "$fixture"
}

# ---------------------------------------------------------------------------
# parse_min_disc <fixture.md> → prints min_discriminative (default 3).
# ---------------------------------------------------------------------------
parse_min_disc() {
  fixture="$1"
  [ -f "$fixture" ] || { echo 3; return 0; }
  awk '
    /^---[[:space:]]*$/ { fence++; next }
    fence==1 && /^min_discriminative:/ {
      v=$0
      sub(/^min_discriminative:[[:space:]]*/, "", v)
      gsub(/[^0-9]/, "", v)
      if (v != "") { print v; found=1; exit }
    }
    fence>=2 { exit }
    END { if (!found) print 3 }
  ' "$fixture"
}

# ---------------------------------------------------------------------------
# count_matches <pattern> <output-file> → distinct-match count via
# grep -oE -- | LC_ALL=C sort -u | wc -l (NOT grep -c). Never aborts; 0 on miss.
# Uses -- to avoid pattern starting with - being misparsed. Full pipeline UNDER
# wall-clock guard (TERM then KILL, group-kill). 124 = timeout (caller emits
# TIMEOUT verdict); 127 = harness state (never PASS). LC_ALL=C pinned (CJK).
# ---------------------------------------------------------------------------
count_matches() {
  _pat="$1"; _out="$2"
  [ -n "$_pat" ] || { printf '0'; return 0; }
  [ -f "$_out" ] || { printf '0'; return 0; }
  _n=$(guarded_exec "$EVAL_TIMEOUT_S_EFF" -- bash -c 'grep -oE -- "$0" "$1" 2>/dev/null | LC_ALL=C sort -u | wc -l | tr -d " "' "$_pat" "$_out" 2>/dev/null)
  _rc=$?
  if [ "$_rc" -eq 124 ]; then
    return 124
  fi
  if [ "$_rc" -eq 127 ]; then
    printf '0'
    return 127
  fi
  [ -z "$_n" ] && _n=0
  printf '%s' "$_n"
  return 0
}

# is_invalid_regex <pattern> → 0 invalid (grep 2), 1 valid, 124 timeout, 127 harness.
# Probe executes UNDER wall-clock guard. -- preserved; exit-2 vs no-match kept.
is_invalid_regex() {
  _pat="$1"
  [ -n "$_pat" ] || return 1
  guarded_exec "$EVAL_TIMEOUT_S_EFF" -- grep -oE -- "$_pat" /dev/null >/dev/null 2>&1
  _rc=$?
  if [ "$_rc" -eq 124 ]; then return 124; fi
  if [ "$_rc" -eq 127 ]; then return 127; fi
  [ "$_rc" -eq 2 ]
}

# ---------------------------------------------------------------------------
# assert_one <fixture.md> <output-file> → prints verdict line, returns 0 PASS
# / 1 FAIL / 2 skipped (no output). NEVER aborts the caller.
#
# PRIMARY GATE = DISCRIMINATIVE (pack-specific) markers. PASS iff
#   disc_count >= min_discriminative.
# The combined `## Verification Command` count is reported as a SECONDARY
# context number only (it mixes pack-specific + generic markers, so it does
# NOT discriminate a with-pack agent from a no-pack one).
# BACKWARD COMPAT: if the fixture has no discriminative_pattern, fall back to
# the old combined gate and print a WARN.
# ---------------------------------------------------------------------------
assert_one() {
  fixture="$1"
  output="$2"
  # ---- Step 1: reject non-regular/symlinks BEFORE any awk (TOCTOU note: local
  # evidence files only; -f follows links so -L is load-bearing; FIFO/dir/link→SKIP).
  if [ ! -f "$fixture" ] || [ -L "$fixture" ]; then
    _bn=$(basename "$fixture" .md 2>/dev/null || printf '%s' "$fixture")
    printf 'PACK unknown FIXTURE %s: non-regular or symlink fixture → SKIP (bad fixture: non-regular input)\n' "$_bn"
    return 2
  fi
  if [ -e "$output" ]; then
    if [ ! -f "$output" ] || [ -L "$output" ]; then
      _fbn=$(basename "$fixture" .md 2>/dev/null || printf '%s' "$fixture")
      printf 'PACK unknown FIXTURE %s: non-regular or symlink output → SKIP (bad fixture: non-regular input)\n' "$_fbn"
      return 2
    fi
  fi
  # ---- Step 2: size caps BEFORE awk parsing (parse fns otherwise uncapped DoS).
  # wc -c bytes | tr -d [:space:]; quoted expansion only, no eval.
  _fsize=$(file_size_bytes "$fixture" 2>/dev/null || printf '0')
  case "$_fsize" in ""|*[!0-9]*) _fsize=0 ;; esac
  if [ "$_fsize" -gt "$EVAL_MAX_FIXTURE_B_EFF" ] 2>/dev/null; then
    _bn=$(basename "$fixture" .md 2>/dev/null || printf '%s' "$fixture")
    printf 'PACK unknown FIXTURE %s: fixture oversize (%s bytes > %s) → OVERSIZE → SKIP (bounded)\n' "$_bn" "$_fsize" "$EVAL_MAX_FIXTURE_B_EFF"
    return 2
  fi
  _osize=""
  _output_oversize=0
  if [ -e "$output" ]; then
    _osize=$(file_size_bytes "$output" 2>/dev/null || printf '0')
    case "$_osize" in ""|*[!0-9]*) _osize=0 ;; esac
    if [ "$_osize" -gt "$EVAL_MAX_OUTPUT_B_EFF" ] 2>/dev/null; then
      _output_oversize=1
    fi
  fi
  # ---- Parse (now safe: fixture size already capped). Parsers/gates unchanged.
  skill=$(parse_skill "$fixture")
  pack_raw=$(parse_pack_raw "$fixture")
  pack=$(parse_pack "$fixture")
  # Dual-field detection: both skill: and pack: present in frontmatter → bad fixture SKIP
  if [ -n "$skill" ] && [ -n "$pack_raw" ]; then
    _subj="$skill"
    name=$(parse_name "$fixture")
    printf 'PACK %s FIXTURE %s: conflicting subject fields → SKIP (bad fixture: conflicting subject fields)\n' "$_subj" "$name"
    return 2
  fi
  # Subject resolution: skill → pack → path fallback (pack fallback handled inside parse_pack)
  subject=""
  if [ -n "$skill" ]; then
    subject="$skill"
  else
    subject="$pack"
  fi
  name=$(parse_name "$fixture")
  min=$(parse_min_count "$fixture")
  pattern=$(parse_pattern "$fixture")
  disc_pattern=$(parse_disc_pattern "$fixture")
  min_disc=$(parse_min_disc "$fixture")

  # Output oversize deferred verdict (with subject; before ANY grep).
  if [ "$_output_oversize" -eq 1 ]; then
    printf 'PACK %s FIXTURE %s: output oversize (%s bytes > %s) → OVERSIZE → SKIP (bounded)\n' "$subject" "$name" "$_osize" "$EVAL_MAX_OUTPUT_B_EFF"
    return 2
  fi

  if [ -z "$pattern" ]; then
    printf 'PACK %s FIXTURE %s: no verification pattern → SKIP (bad fixture)\n' "$subject" "$name"
    return 2
  fi
  if [ ! -f "$output" ]; then
    printf 'PACK %s FIXTURE %s: no output captured → SKIP\n' "$subject" "$name"
    return 2
  fi

  # ---- Step 3: post-unescape byte-length on BOTH patterns, 4 KiB each.
  # printf %s | wc -c = bytes, not ${#} chars. Oversize before ANY grep.
  if [ -n "$pattern" ]; then
    _plen=$(pattern_bytes "$pattern" 2>/dev/null || printf '0')
    case "$_plen" in ""|*[!0-9]*) _plen=0 ;; esac
    if [ "$_plen" -gt "$EVAL_MAX_PATTERN_B_EFF" ] 2>/dev/null; then
      printf 'PACK %s FIXTURE %s: pattern oversize (%s bytes > %s) → SKIP (bad fixture: pattern oversize)\n' "$subject" "$name" "$_plen" "$EVAL_MAX_PATTERN_B_EFF"
      return 2
    fi
  fi
  if [ -n "$disc_pattern" ]; then
    _dlen=$(pattern_bytes "$disc_pattern" 2>/dev/null || printf '0')
    case "$_dlen" in ""|*[!0-9]*) _dlen=0 ;; esac
    if [ "$_dlen" -gt "$EVAL_MAX_PATTERN_B_EFF" ] 2>/dev/null; then
      printf 'PACK %s FIXTURE %s: discriminative pattern oversize (%s bytes > %s) → SKIP (bad fixture: pattern oversize)\n' "$subject" "$name" "$_dlen" "$EVAL_MAX_PATTERN_B_EFF"
      return 2
    fi
  fi

  # ---- Step 4: validity probe + counts UNDER wall-clock guard (frozen strings).
  is_invalid_regex "$pattern"
  _prc=$?
  if [ "$_prc" -eq 124 ]; then
    printf 'PACK %s FIXTURE %s: match timeout after %ss → TIMEOUT → SKIP (bounded)\n' "$subject" "$name" "$EVAL_TIMEOUT_S_EFF"
    return 2
  fi
  if [ "$_prc" -eq 127 ]; then
    printf 'PACK %s FIXTURE %s: harness missing guard tool → SKIP (bad fixture: harness state)\n' "$subject" "$name"
    return 2
  fi
  if [ "$_prc" -eq 0 ]; then
    printf 'PACK %s FIXTURE %s: invalid regex → SKIP (bad fixture: invalid pattern)\n' "$subject" "$name"
    return 2
  fi
  if [ -n "$disc_pattern" ]; then
    is_invalid_regex "$disc_pattern"
    _drc=$?
    if [ "$_drc" -eq 124 ]; then
      printf 'PACK %s FIXTURE %s: match timeout after %ss → TIMEOUT → SKIP (bounded)\n' "$subject" "$name" "$EVAL_TIMEOUT_S_EFF"
      return 2
    fi
    if [ "$_drc" -eq 127 ]; then
      printf 'PACK %s FIXTURE %s: harness missing guard tool → SKIP (bad fixture: harness state)\n' "$subject" "$name"
      return 2
    fi
    if [ "$_drc" -eq 0 ]; then
      printf 'PACK %s FIXTURE %s: invalid discriminative regex → SKIP (bad fixture: invalid pattern)\n' "$subject" "$name"
      return 2
    fi
  fi

  # SECONDARY (context only): combined count over the mixed pattern (guarded).
  combined=$(count_matches "$pattern" "$output")
  _crc=$?
  if [ "$_crc" -eq 124 ]; then
    printf 'PACK %s FIXTURE %s: match timeout after %ss → TIMEOUT → SKIP (bounded)\n' "$subject" "$name" "$EVAL_TIMEOUT_S_EFF"
    return 2
  fi
  if [ "$_crc" -eq 127 ]; then
    printf 'PACK %s FIXTURE %s: harness missing guard tool → SKIP (bad fixture: harness state)\n' "$subject" "$name"
    return 2
  fi

  # ---- BACKWARD-COMPAT path: no discriminative_pattern → old combined gate.
  if [ -z "$disc_pattern" ]; then
    if [ "$combined" -ge "$min" ] 2>/dev/null; then
      printf 'PACK %s FIXTURE %s: combined %s/%s → PASS  [WARN: no discriminative_pattern — using combined (non-discriminative) gate]\n' "$subject" "$name" "$combined" "$min"
      return 0
    else
      printf 'PACK %s FIXTURE %s: combined %s/%s → FAIL  [WARN: no discriminative_pattern — using combined (non-discriminative) gate]\n' "$subject" "$name" "$combined" "$min"
      return 1
    fi
  fi

  # ---- PRIMARY path: discriminative gate (guarded).
  disc=$(count_matches "$disc_pattern" "$output")
  _dcc=$?
  if [ "$_dcc" -eq 124 ]; then
    printf 'PACK %s FIXTURE %s: match timeout after %ss → TIMEOUT → SKIP (bounded)\n' "$subject" "$name" "$EVAL_TIMEOUT_S_EFF"
    return 2
  fi
  if [ "$_dcc" -eq 127 ]; then
    printf 'PACK %s FIXTURE %s: harness missing guard tool → SKIP (bad fixture: harness state)\n' "$subject" "$name"
    return 2
  fi

  if [ "$disc" -ge "$min_disc" ] 2>/dev/null; then
    printf 'PACK %s FIXTURE %s: disc %s/%s [combined %s/%s] → PASS\n' "$subject" "$name" "$disc" "$min_disc" "$combined" "$min"
    return 0
  else
    printf 'PACK %s FIXTURE %s: disc %s/%s [combined %s/%s] → FAIL\n' "$subject" "$name" "$disc" "$min_disc" "$combined" "$min"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# run_all <outputs-dir> → iterate every fixture, match captured output by
# fixture basename, emit results table + summary.
# ---------------------------------------------------------------------------
run_all() {
  outdir="$1"
  pass=0; fail=0; skip=0
  printf '%s\n' "=== Pack Behavioral Eval — batch (--all) ==="
  printf '%s\n' "outputs dir: $outdir"
  printf '%s\n' "--- bounds: timeout=${EVAL_TIMEOUT_S_EFF}s output=${EVAL_MAX_OUTPUT_B_EFF} pattern=${EVAL_MAX_PATTERN_B_EFF} fixture=${EVAL_MAX_FIXTURE_B_EFF} guard=${GUARD_MODE}"
  printf '%s\n' "--- worst-case: N fixtures x (${EVAL_TIMEOUT_S_EFF}s timeout+1s grace) (batch may stall N x (timeout+1s grace); CI stall is visible, not silent)"
  printf '%s\n' "-------------------------------------------------------------"

  # Glob; if no fixtures, nullglob-style guard.
  found_any=0
  for fixture in .claude/skills/*/examples/*.md; do
    [ -f "$fixture" ] || continue
    found_any=1
    base=$(basename "$fixture" .md)
    output="$outdir/$base.md"
    line=$(assert_one "$fixture" "$output")
    rc=$?
    printf '%s\n' "$line"
    case "$rc" in
      0) pass=$((pass+1)) ;;
      1) fail=$((fail+1)) ;;
      *) skip=$((skip+1)) ;;
    esac
  done

  if [ "$found_any" -eq 0 ]; then
    printf '%s\n' "(no fixtures found under .claude/skills/*/examples/)"
  fi
  printf '%s\n' "-------------------------------------------------------------"
  printf '%s pass / %s fail / %s skipped (no output captured)\n' "$pass" "$fail" "$skip"
  return 0
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
usage() {
  cat <<'USAGE'
pack-eval-runner.sh — capability pack behavioral eval ASSERTION engine (advisory)

Usage:
  pack-eval-runner.sh <fixture.md> <agent-output-file>
      Assert one captured output against one fixture.
      PRIMARY gate = DISCRIMINATIVE (pack-specific) markers.
      Prints: PACK <pack> FIXTURE <name>: disc <d>/<min_disc> [combined <c>/<min>] → PASS|FAIL
      (PASS/FAIL is driven by the DISCRIMINATIVE count; combined is context only.)
      Fixtures lacking discriminative_pattern fall back to the combined gate with a WARN.

  pack-eval-runner.sh --all <outputs-dir>
      Iterate every .claude/skills/*/examples/*.md fixture, match a captured
      output at <outputs-dir>/<fixture-basename>.md, run each assertion, and
      print a results table + summary (P pass / F fail / S skipped).

Notes:
  - Advisory only. Never fail-closed. Not a hook.
  - Run from the TAD repo root (paths are relative to .claude/skills/).
USAGE
}

main() {
  if [ "$#" -lt 1 ]; then
    usage
    return 0
  fi
  case "$1" in
    --all)
      if [ "$#" -lt 2 ]; then
        printf 'error: --all requires <outputs-dir>\n' >&2
        usage
        return 0
      fi
      run_all "$2"
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [ "$#" -lt 2 ]; then
        printf 'error: single-fixture mode requires <fixture.md> <agent-output-file>\n' >&2
        usage
        return 0
      fi
      assert_one "$1" "$2"
      # Map verdict rc to 0 for advisory mode (never fail-closed at exit).
      return 0
      ;;
  esac
  return 0
}

main "$@"
