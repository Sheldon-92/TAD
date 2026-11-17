#!/bin/bash
# self-test.sh — TAD Self-Test deterministic assertion runner.
#
# TASK-20261031-005 (HANDOFF-surplus-tad-self-test-agent §4.2 C1).
# Upstreamed 2026-11-06 from the Sober Creator repo into this framework
# source repo (TASK-20261106-004, HANDOFF-20261106-sp2-row4-self-test-agent
# §4.2 C1); built downstream 2026-10-31, this repo is now the source copy.
# Two-layer design (§4.1): this script ASSERTS only — it never spawns
# sub-agents (pack-eval-runner.sh header precedent: "a bash script cannot
# spawn Claude agents. The CONDUCTOR drives sub-agent spawning"). Probe
# spawning belongs to the driving session per self-test-protocol.md; this
# script asserts the captures that session files.
#
# Modes:
#   surface [--root <dir>] [--only S1|S2|S3|S4|S5]
#   assert  --run-dir <dir> [--only A1|A2|A3|A4]
#   run     [--root <dir>] [--run-dir <dir>] [--report-dir <dir>]
#
# Item lines:  ok <ID> <name> | FAIL <ID> <name>: <named bad part> |
#              NOTE <ID> <name>: <note>
# Verdict line carries scope semantics (anti-vacuous, §4.2/D6):
#   run WITH --run-dir : SELF-TEST: PASS | SELF-TEST: FAIL (<items>)
#   surface, run w/o   : same + " (surface-only)" suffix
#   assert             : same + " (probes-only)" suffix
# A bare "SELF-TEST: PASS" may only appear on a run that included probe
# assertions.
# Exit: 0 = pass, 1 = any FAIL, 2 = usage/internal error.
#
# bash 3.2 compatible; intentionally NO set -e (one item's failure must not
# abort the batch — pack-eval-runner precedent; the verdict decides exit).

set -u

SELF_DIR="$(cd "$(dirname "$0")" && pwd -P)"
SELF_PATH="$SELF_DIR/self-test.sh"
ROOT="$(cd "$SELF_DIR/../.." && pwd -P)"
MODE=""
ONLY=""
RUN_DIR=""
REPORT_DIR=""

usage() {
  echo "usage: self-test.sh surface [--root <dir>] [--only S1|S2|S3|S4|S5]" >&2
  echo "       self-test.sh assert --run-dir <dir> [--only A1|A2|A3|A4]" >&2
  echo "       self-test.sh run [--root <dir>] [--run-dir <dir>] [--report-dir <dir>]" >&2
  exit 2
}

[ $# -ge 1 ] || usage
MODE="$1"; shift
case "$MODE" in surface|assert|run) : ;; *) usage ;; esac
while [ $# -gt 0 ]; do
  case "$1" in
    --root)       [ $# -ge 2 ] || usage; ROOT="$2"; shift 2 ;;
    --only)       [ $# -ge 2 ] || usage; ONLY="$2"; shift 2 ;;
    --run-dir)    [ $# -ge 2 ] || usage; RUN_DIR="$2"; shift 2 ;;
    --report-dir) [ $# -ge 2 ] || usage; REPORT_DIR="$2"; shift 2 ;;
    *) usage ;;
  esac
done
case "$ROOT" in /*) : ;; *) ROOT="$(pwd -P)/$ROOT" ;; esac
ROOT="${ROOT%/}"
[ -d "$ROOT" ] || { echo "self-test: root not a directory: $ROOT" >&2; exit 2; }
if [ "$MODE" = "assert" ] && [ -z "$RUN_DIR" ]; then usage; fi
if [ -n "$RUN_DIR" ]; then
  case "$RUN_DIR" in /*) : ;; *) RUN_DIR="$(pwd -P)/$RUN_DIR" ;; esac
  RUN_DIR="${RUN_DIR%/}"
fi

VER=""
[ -f "$ROOT/.tad/version.txt" ] && VER="$(cat "$ROOT/.tad/version.txt")"

FAILS=""
note_fail() { if [ -z "$FAILS" ]; then FAILS="$1"; else FAILS="$FAILS, $1"; fi; }
item_ok()   { echo "ok $1 $2"; }
item_note() { echo "NOTE $1 $2: $3"; }
item_fail() { echo "FAIL $1 $2: $3"; note_fail "$1"; }

want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# ---------------------------------------------------------------- S1 wiring
# Oracle = the shipped template (D5: live-derived, never hardcoded).
s1_triples() {
  jq -r '.hooks | to_entries[] | .key as $ev | .value[] | (.matcher // "") as $m
         | .hooks[]
         | [$ev, $m, ((.command | split(" ") | map(select(startswith(".tad/"))) | .[0]) // "")]
         | join("|")' "$1" 2>/dev/null | LC_ALL=C sort -u
}
s1_degraded_set() {
  {
    grep -oE '\.tad/[^" ]+\.sh' "$1" 2>/dev/null
    grep -oE '"(SessionStart|PostToolUse|PreToolUse|PreCompact|PostCompact|UserPromptSubmit|Notification|Stop|SubagentStop)"' "$1" 2>/dev/null | tr -d '"'
  } | LC_ALL=C sort -u
}
check_s1() {
  local live="$ROOT/.claude/settings.json" tmpl="$ROOT/.tad/templates/claude/settings.json"
  if [ ! -s "$live" ] || [ ! -s "$tmpl" ]; then
    item_fail S1 wiring "UNVERIFIABLE settings file missing (live or template)"; return
  fi
  local a b degraded=""
  if command -v jq >/dev/null 2>&1; then
    a="$(s1_triples "$live")"; b="$(s1_triples "$tmpl")"
  else
    degraded=" (degraded: no jq)"
    a="$(s1_degraded_set "$live")"; b="$(s1_degraded_set "$tmpl")"
  fi
  if [ -z "$a" ] || [ -z "$b" ]; then
    item_fail S1 wiring "UNVERIFIABLE registration extraction empty on live or template"; return
  fi
  if [ "$a" != "$b" ]; then
    local diffset
    diffset=$( { printf '%s\n' "$a"; printf '%s\n' "$b"; } | LC_ALL=C sort | uniq -u | tr '\n' ' ' )
    item_fail S1 wiring "registration set differs from template: $diffset"; return
  fi
  # every registered script path must exist under root
  local scripts missing="" s
  if command -v jq >/dev/null 2>&1; then
    scripts=$(printf '%s\n' "$a" | while IFS= read -r line; do printf '%s\n' "${line##*|}"; done | LC_ALL=C sort -u)
  else
    scripts=$(grep -oE '\.tad/[^" ]+\.sh' "$live" | LC_ALL=C sort -u)
  fi
  for s in $scripts; do
    [ -f "$ROOT/$s" ] || missing="$missing $s"
  done
  if [ -n "$missing" ]; then
    item_fail S1 wiring "registered script(s) missing on disk:$missing"; return
  fi
  if [ -n "$degraded" ]; then echo "ok S1 wiring (degraded: no jq)"; else item_ok S1 wiring; fi
}

# ------------------------------------------------------- S2 skill-discovery
check_s2() {
  local dir="$ROOT/.claude/skills"
  if [ ! -d "$dir" ]; then
    item_fail S2 skill-discovery "UNVERIFIABLE .claude/skills directory missing"; return
  fi
  local broken
  broken=$(find "$dir" -maxdepth 1 -xtype l 2>/dev/null | wc -l | tr -d ' ')
  if [ "$broken" != "0" ]; then
    local names
    names=$(find "$dir" -maxdepth 1 -xtype l 2>/dev/null | while IFS= read -r p; do basename "$p"; done | tr '\n' ' ')
    item_fail S2 skill-discovery "broken symlink(s): $names"; return
  fi
  local role nm
  for role in alex blake cora; do
    if [ ! -f "$dir/$role/SKILL.md" ]; then
      item_fail S2 skill-discovery "role chain unresolvable: $role"; return
    fi
    nm=$(awk -F': *' '/^name:/{print $2; exit}' "$dir/$role/SKILL.md")
    if [ "$nm" != "$role" ]; then
      item_fail S2 skill-discovery "frontmatter name mismatch on chain: $role reports '$nm'"; return
    fi
  done
  item_ok S2 skill-discovery
}

# ---------------------------------------------------------- S3 pack-surface
check_s3() {
  local reg="$ROOT/.tad/capability-packs/pack-registry.yaml" agents="$ROOT/AGENTS.md"
  if [ ! -s "$reg" ] || [ ! -s "$agents" ]; then
    item_fail S3 pack-surface "UNVERIFIABLE pack-registry.yaml or AGENTS.md missing"; return
  fi
  local reg_names tab_names
  reg_names=$(grep -E '^  - name: ' "$reg" | sed -E 's/^  - name: *"?([^"]+)"?/\1/' | LC_ALL=C sort -u)
  tab_names=$(grep -F '.agents/skills/' "$agents" | grep -oE '^\| [^ |]+' | sed -e 's/^| *//' | LC_ALL=C sort -u)
  if [ -z "$reg_names" ] || [ -z "$tab_names" ]; then
    item_fail S3 pack-surface "UNVERIFIABLE pack name extraction empty (registry or routing table)"; return
  fi
  local d1 d2
  d1=$(comm -23 <(printf '%s\n' "$reg_names") <(printf '%s\n' "$tab_names") | tr '\n' ' ')
  d2=$(comm -13 <(printf '%s\n' "$reg_names") <(printf '%s\n' "$tab_names") | tr '\n' ' ')
  if [ -n "$d1" ] || [ -n "$d2" ]; then
    item_fail S3 pack-surface "registry/table set mismatch: registry-only:$d1 table-only:$d2"; return
  fi
  local n missing_proj=""
  for n in $reg_names; do
    [ -f "$ROOT/.agents/skills/$n/SKILL.md" ] || missing_proj="$missing_proj $n"
  done
  if [ -n "$missing_proj" ]; then
    item_fail S3 pack-surface "registry pack(s) without projected SKILL.md:$missing_proj"; return
  fi
  local dir_names extra regonly
  dir_names=$(for d in "$ROOT/.tad/capability-packs"/*/; do [ -d "$d" ] && basename "$d"; done | LC_ALL=C sort -u)
  extra=$(comm -13 <(printf '%s\n' "$reg_names") <(printf '%s\n' "$dir_names") | tr '\n' ' ')
  if [ -n "$extra" ]; then
    item_fail S3 pack-surface "source dir(s) not in registry: $extra"; return
  fi
  item_ok S3 pack-surface
  regonly=$(comm -23 <(printf '%s\n' "$reg_names") <(printf '%s\n' "$dir_names"))
  if [ -n "$regonly" ]; then
    for n in $regonly; do
      item_note S3 pack-surface "registry-only (registered, no source dir): $n"
    done
  fi
}

# -------------------------------------------------------- S4 hook-execution
# Whole-repo copy under mktemp; HOME/XDG_CACHE_HOME redirected into the temp
# dir; every hook invoked with cwd = the copy root (isolation triple, §4.2):
# the hooks read/write cwd-relative paths, so any leg outside the copy would
# write into the real repo or read the wrong tree.
check_s4() {
  local tmp copy home4 fails4=""
  tmp=$(mktemp -d) || { item_fail S4 hook-execution "UNVERIFIABLE mktemp failed"; return; }
  copy="$tmp/repo"; home4="$tmp/home"
  mkdir -p "$copy" "$home4"
  cp -a "$ROOT/." "$copy/" 2>/dev/null
  if [ ! -d "$copy/.tad/hooks" ]; then
    rm -rf "$tmp"; item_fail S4 hook-execution "UNVERIFIABLE whole-repo copy failed"; return
  fi
  local out rc
  # SessionStart
  out=$(cd "$copy" && printf '%s' '{"source":"startup","session_id":"tad-selftest"}' \
        | HOME="$home4" XDG_CACHE_HOME="$home4/.cache" bash .tad/hooks/startup-health.sh 2>/dev/null)
  rc=$?
  if [ $rc -ne 0 ]; then
    fails4="${fails4} sessionstart(exit=$rc)"
  else
    if command -v jq >/dev/null 2>&1; then
      printf '%s' "$out" | jq -e . >/dev/null 2>&1 || fails4="${fails4} sessionstart(non-json-output)"
    elif command -v python3 >/dev/null 2>&1; then
      printf '%s' "$out" | python3 -m json.tool >/dev/null 2>&1 || fails4="${fails4} sessionstart(non-json-output)"
    else
      fails4="${fails4} sessionstart(UNVERIFIABLE no json parser)"
    fi
    case "$out" in
      *"Components: OK (v${VER})"*)
        item_note S4 hook-execution/sessionstart "observed: Components: OK (v${VER})" ;;
      *) fails4="${fails4} sessionstart(missing Components OK line)" ;;
    esac
  fi
  # PreCompact (envelope session_id pinned to exactly 8 chars: sid8 naming
  # contract — the snapshot is snapshot-<ts>-<first 8 chars of session_id>.md)
  (cd "$copy" && printf '%s' '{"session_id":"selftest","transcript_path":"/tmp/none.jsonl"}' \
     | HOME="$home4" XDG_CACHE_HOME="$home4/.cache" bash .tad/hooks/precompact-session-snapshot.sh >/dev/null 2>&1)
  rc=$?
  local snaps
  snaps=$(ls "$copy/.tad/active/precompact"/snapshot-*-selftest.md 2>/dev/null | wc -l | tr -d ' ')
  if [ $rc -ne 0 ] || [ "$snaps" = "0" ]; then
    fails4="${fails4} precompact(no snapshot-*-selftest.md appeared, exit=$rc)"
  fi
  # AskUser capture
  if command -v jq >/dev/null 2>&1; then
    local marker="TAD-SELFTEST-PROBE-Q-$(date +%s)-$$"
    local envj
    envj=$(jq -n --arg q "$marker" '{session_id:"selftest", tool_name:"AskUserQuestion",
      tool_input:{questions:[{question:$q, multiSelect:false, options:[{label:"A"},{label:"B"}]}]},
      tool_response:{answers:{($q):"A"}}}')
    (cd "$copy" && printf '%s' "$envj" \
       | HOME="$home4" XDG_CACHE_HOME="$home4/.cache" bash .tad/hooks/lib/askuser-capture.sh >/dev/null 2>&1)
    rc=$?
    local today cnt=0
    today=$(date +%Y-%m-%d)
    if [ -f "$copy/.tad/evidence/decisions/$today.jsonl" ]; then
      cnt=$(grep -F "$marker" "$copy/.tad/evidence/decisions/$today.jsonl" | wc -l | tr -d ' ')
    fi
    if [ $rc -ne 0 ] || [ "$cnt" != "1" ]; then
      fails4="${fails4} askuser(marker-lines=$cnt, exit=$rc)"
    fi
  else
    fails4="${fails4} askuser(UNVERIFIABLE no jq)"
  fi
  # PostWrite: fold in the existing envelope fixture (D4 — do not rebuild)
  local pwout pwlast
  pwout=$(bash "$copy/.tad/tests/hook-envelope-fixture.sh" 2>/dev/null); rc=$?
  pwlast=$(printf '%s\n' "$pwout" | tail -1)
  case "$pwlast" in
    *"HOOK-ENVELOPE-FIXTURE: PASS"*)
      echo "ok S4 hook-execution/postwrite (via hook-envelope-fixture)" ;;
    *) fails4="${fails4} postwrite(envelope fixture last line: $pwlast)" ;;
  esac
  rm -rf "$tmp"
  if [ -n "$fails4" ]; then
    item_fail S4 hook-execution "failed sub-checks:$fails4"
  else
    item_ok S4 hook-execution
  fi
}

# --------------------------------------------- S5 component-health (consume)
# Consumption only (D3/NFR3): this runner never recomputes a sha baseline;
# it reads the health checker's --line conclusion and judges its shape.
check_s5() {
  local script="$ROOT/.tad/hooks/lib/component-health-check.sh"
  if [ ! -s "$script" ]; then
    item_fail S5 component-health-consume "UNVERIFIABLE component-health-check.sh missing"; return
  fi
  local out rc
  out=$(bash "$script" --root "$ROOT" --line 2>/dev/null); rc=$?
  if [ $rc -eq 0 ] && [ "$out" = "Components: OK (v${VER})" ]; then
    item_ok S5 component-health-consume
  else
    item_fail S5 component-health-consume "$(printf '%s' "$out" | head -1)"
  fi
}

# ------------------------------------------------------------- assert mode
# Ground truth is recomputed from the live tree at assertion time (D7) —
# never read out of the fixture or the capture.
truth_version() {
  if [ -f "$ROOT/.tad/version.txt" ]; then cat "$ROOT/.tad/version.txt"; else echo ABSENT; fi
}
truth_count() { # <file> <grep-pattern>
  if [ -f "$1" ]; then grep -c "$2" "$1"; else echo ABSENT; fi
}
truth_hooks_top() {
  if [ -d "$ROOT/.tad/hooks" ]; then
    ls "$ROOT/.tad/hooks"/*.sh 2>/dev/null | wc -l | tr -d ' '
  else echo ABSENT; fi
}
truth_skill_name() { # <role>
  local f="$ROOT/.agents/skills/$1/SKILL.md"
  if [ -f "$f" ]; then awk -F': *' '/^name:/{print $2; exit}' "$f"; else echo ABSENT; fi
}
block_field() { # <file> <key> -> single-line field value from SELFTEST-REPORT
  awk -v k="$2" '
    /^SELFTEST-REPORT[[:space:]]*$/ { inb=1; next }
    /^END-SELFTEST-REPORT[[:space:]]*$/ { inb=0 }
    inb {
      line=$0; sub(/^[[:space:]]+/, "", line)
      if (line ~ ("^" k ":")) { v=line; sub("^" k ":[[:space:]]*", "", v); print v }
    }' "$1"
}
pack_action_value() { # <file> -> pack_action value (may span following lines)
  awk '
    /^SELFTEST-REPORT[[:space:]]*$/ { inb=1; next }
    /^END-SELFTEST-REPORT[[:space:]]*$/ { inb=0 }
    inb && /^pack_action:/ { grab=1; v=$0; sub(/^pack_action:[[:space:]]*/, "", v); if (v != "") print v; next }
    inb && grab { print }
  ' "$1"
}
capture_for() { # <probe-suffix> -> capture path (a try2 capture wins, §4.2/C3)
  if [ -f "$RUN_DIR/capture-$1-try2.md" ]; then
    echo "$RUN_DIR/capture-$1-try2.md"
  else
    echo "$RUN_DIR/capture-$1.md"
  fi
}

assert_role() { # <id> <name> <file> <role>
  local id="$1" name="$2" file="$3" role="$4"
  if [ ! -f "$file" ]; then
    item_fail "$id" "$name" "missing $(basename "$file")"; return
  fi
  if ! grep -q '^SELFTEST-REPORT' "$file"; then
    item_fail "$id" "$name" "SELFTEST-REPORT block missing in $(basename "$file")"; return
  fi
  local bad="" v t
  v=$(block_field "$file" role)
  [ "$v" = "$role" ] || bad="$bad role(expected=$role got=${v:-<missing>})"
  v=$(block_field "$file" tad_version); t=$(truth_version)
  [ "$v" = "$t" ] || bad="$bad tad_version(expected=$t got=${v:-<missing>})"
  v=$(block_field "$file" skill_name); t=$(truth_skill_name "$role")
  [ "$v" = "$t" ] || bad="$bad skill_name(expected=$t got=${v:-<missing>})"
  if [ "$id" = "A1" ]; then
    v=$(block_field "$file" principles_entries)
    t=$(truth_count "$ROOT/.tad/project-knowledge/principles.md" '^### ')
    [ "$v" = "$t" ] || bad="$bad principles_entries(expected=$t got=${v:-<missing>})"
    v=$(block_field "$file" patterns_entries)
    t=$(truth_count "$ROOT/.tad/project-knowledge/patterns/_index.md" '^- \[')
    [ "$v" = "$t" ] || bad="$bad patterns_entries(expected=$t got=${v:-<missing>})"
  else
    v=$(block_field "$file" hooks_top); t=$(truth_hooks_top)
    [ "$v" = "$t" ] || bad="$bad hooks_top(expected=$t got=${v:-<missing>})"
    v=$(block_field "$file" gate3_owner)
    if ! grep -Fq 'run reviewer — not the builder' "$ROOT/.tad/gates/gate-canonical-checklist.md"; then
      bad="$bad gate3_owner(truth source line missing in gate-canonical-checklist.md)"
    elif [ "${v#*run reviewer — not the builder}" = "$v" ]; then
      bad="$bad gate3_owner(verbatim excerpt missing)"
    fi
  fi
  if [ -n "$bad" ]; then
    item_fail "$id" "$name" "field mismatch:$bad"
  else
    item_ok "$id" "$name"
  fi
}

assert_pack_pos() {
  local file; file=$(capture_for pack-pos)
  if [ ! -f "$file" ]; then
    item_fail A3 probe-pack-pos "missing $(basename "$file")"; return
  fi
  local bad=""
  grep -Fq 'Pack pointer: web-testing' "$file" \
    || bad="$bad no 'Pack pointer: web-testing' line in capture"
  local pa; pa=$(pack_action_value "$file")
  case "$pa" in
    *web-testing*) : ;;
    *) bad="$bad pack_action lacks web-testing" ;;
  esac
  if [ -n "$bad" ]; then item_fail A3 probe-pack-pos "$bad"; return; fi
  local nptrs
  nptrs=$(printf '%s\n' "$pa" | grep -oF 'Pack pointer:' | wc -l | tr -d ' ')
  if [ "$nptrs" -gt 1 ]; then
    item_note A3 probe-pack-pos "multiple pointers announced (tolerated by contract): $(printf '%s' "$pa" | tr '\n' ' ')"
  fi
  item_ok A3 probe-pack-pos
}

assert_pack_neg() {
  local file; file=$(capture_for pack-neg)
  if [ ! -f "$file" ]; then
    item_fail A4 probe-pack-neg "missing $(basename "$file")"; return
  fi
  local bad="" cnt pa
  cnt=$(grep -oF 'Pack pointer:' "$file" | wc -l | tr -d ' ')
  [ "$cnt" = "0" ] || bad="$bad found $cnt 'Pack pointer:' line(s) in capture"
  pa=$(pack_action_value "$file" | tr -d '[:space:]')
  [ "$pa" = "NONE" ] || bad="$bad pack_action is not NONE"
  if [ -n "$bad" ]; then
    item_fail A4 probe-pack-neg "$bad"
  else
    item_ok A4 probe-pack-neg
  fi
}

do_surface() {
  want S1 && check_s1
  want S2 && check_s2
  want S3 && check_s3
  want S4 && check_s4
  want S5 && check_s5
}

do_assert() {
  want A1 && assert_role A1 probe-alex "$(capture_for alex)" alex
  want A2 && assert_role A2 probe-blake "$(capture_for blake)" blake
  want A3 && assert_pack_pos
  want A4 && assert_pack_neg
}

print_verdict() { # <suffix> -> verdict line on stdout; rc 0/1
  if [ -z "$FAILS" ]; then
    echo "SELF-TEST: PASS$1"; return 0
  fi
  echo "SELF-TEST: FAIL ($FAILS)$1"; return 1
}

# ---------------------------------------------------------------- run mode
do_run() {
  [ -n "$REPORT_DIR" ] || REPORT_DIR="$ROOT/.tad/evidence/self-test"
  mkdir -p "$REPORT_DIR" || { echo "self-test: cannot create report dir: $REPORT_DIR" >&2; exit 2; }
  local surf_out surf_rc probe_out probe_rc=0
  surf_out=$(bash "$SELF_PATH" surface --root "$ROOT"); surf_rc=$?
  local surf_lines probe_lines scope suffix
  surf_lines=$(printf '%s\n' "$surf_out" | sed '$d')
  if [ -n "$RUN_DIR" ]; then
    scope="surface+probes"; suffix=""
    probe_out=$(bash "$SELF_PATH" assert --run-dir "$RUN_DIR"); probe_rc=$?
    probe_lines=$(printf '%s\n' "$probe_out" | sed '$d')
    # try2 passes are named in the report (C3 disposition; §4.6 NOTE lines)
    local pair pid pslug
    for pair in "A1 alex" "A2 blake" "A3 pack-pos" "A4 pack-neg"; do
      pid="${pair%% *}"; pslug="${pair##* }"
      if [ -f "$RUN_DIR/capture-$pslug-try2.md" ] \
         && printf '%s\n' "$probe_lines" | grep -q "^ok $pid "; then
        probe_lines="$probe_lines
NOTE $pid probe-$pslug: passed on try2"
      fi
    done
  else
    scope="surface-only"; suffix=" (surface-only)"
    probe_lines="not-run: no --run-dir given"
  fi
  # verdict from the two legs' exit codes; failing ids parsed from FAIL lines
  local run_fails verdict rc
  run_fails=$(printf '%s\n%s\n' "$surf_lines" "$probe_lines" \
    | awk '/^FAIL /{printf "%s%s", (n++ ? ", " : ""), $2}')
  if [ $surf_rc -eq 0 ] && [ $probe_rc -eq 0 ]; then
    verdict="SELF-TEST: PASS$suffix"; rc=0
  else
    verdict="SELF-TEST: FAIL ($run_fails)$suffix"; rc=1
  fi
  # prior report = newest existing report file other than today's target
  local today fname prior_name="none" prior_verdict="-" f base
  today=$(date +%Y-%m-%d)
  fname="SELF-TEST-$today-v$VER.md"
  for f in "$REPORT_DIR"/SELF-TEST-*.md; do
    [ -e "$f" ] || continue
    base=$(basename "$f")
    [ "$base" = "$fname" ] && continue
    if [ "$prior_name" = "none" ] || [ "$base" \> "$prior_name" ]; then prior_name="$base"; fi
  done
  if [ "$prior_name" != "none" ]; then
    prior_verdict=$(tail -1 "$REPORT_DIR/$prior_name")
  fi
  {
    echo "# TAD Self-Test Report — $today — TAD v$VER"
    echo "root: $ROOT"
    echo "scope: $scope"
    echo "prior report: $prior_name（$prior_verdict）"
    echo "## Surface"
    printf '%s\n' "$surf_lines"
    echo "## Probes"
    printf '%s\n' "$probe_lines"
    echo "$verdict"
  } > "$REPORT_DIR/$fname"
  printf '%s\n' "$surf_lines"
  if [ -n "$RUN_DIR" ]; then printf '%s\n' "$probe_lines"; fi
  echo "$verdict"
  return $rc
}

# ---------------------------------------------------------------- dispatch
case "$MODE" in
  surface)
    case "$ONLY" in ""|S1|S2|S3|S4|S5) : ;; *) usage ;; esac
    do_surface
    print_verdict " (surface-only)"
    ;;
  assert)
    case "$ONLY" in ""|A1|A2|A3|A4) : ;; *) usage ;; esac
    do_assert
    print_verdict " (probes-only)"
    ;;
  run)
    do_run
    ;;
esac
