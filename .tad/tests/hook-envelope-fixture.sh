#!/bin/bash
# Fixture: post-write-sync.sh reads the file path out of every harness's envelope.
# Feeds envelopes to the real hook inside a mktemp -d project and asserts on
# .tad/evidence/traces/<today>.jsonl. Run from anywhere: /bin/bash <this file>.
# Envelope shapes (sources):
#   Codex apply_patch  - captured live (codex-cli 0.159.3), see
#                        .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4b-codex-postwrite-diagnosis.md
#   Claude Code Write  - tool_input.file_path (Write|Edit matcher in .tad/templates/claude/settings.json)
#   Cursor postToolUse - tool_name Write, tool_input.file_path absolute (.tad/hooks/lib/cursor-post-write.sh)
#   OpenCode           - {tool_name, tool_input:{file_path}, cwd} built in .opencode/plugins/tad-hooks.ts
# The hook runs under /bin/bash; set HOOK_FIXTURE_NOJQ=1 to hide jq (PATH shim) and
# exercise the grep fallback instead.

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
HOOK="$REPO/.tad/hooks/post-write-sync.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
PASS=0; FAILN=0
ok()  { PASS=$((PASS+1)); echo "ok $1"; }
bad() { FAILN=$((FAILN+1)); echo "FAIL $1"; }

# Build a PATH without jq when asked.
RUNPATH="$PATH"
if [ "${HOOK_FIXTURE_NOJQ:-0}" = 1 ]; then
  mkdir -p "$WORK/bin"
  for t in cat grep sed head tail tr cut date basename dirname mkdir rm mv cp ls awk wc sort uniq printf test touch env bash sh; do
    p=$(command -v "$t" 2>/dev/null) && [ -x "$p" ] && ln -sf "$p" "$WORK/bin/$t"
  done
  RUNPATH="$WORK/bin"
fi

LAST_RC=0; LAST_OUT=""
feed() { # feed <dir> <json>
  LAST_OUT=$(cd "$1" && printf '%s' "$2" | PATH="$RUNPATH" /bin/bash "$HOOK" 2>/dev/null); LAST_RC=$?
}
mkp() { d="$WORK/$1"; mkdir -p "$d/.tad/evidence"; echo "$d"; }
rows()  { cat "$1"/.tad/evidence/traces/*.jsonl 2>/dev/null | grep -c "$2"; }
allrows() { cat "$1"/.tad/evidence/traces/*.jsonl 2>/dev/null | grep -c .; }
patch_env() { # patch_env <dir> <patch text as JSON string body>
  printf '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"%s","tool_input":{"command":"%s"},"tool_response":"ok"}' "$1" "$2"
}

d=$(mkp codex_add)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: .tad/evidence/c-add.md\n+diag\n*** End Patch')"
[ "$(rows "$d" '"type":"evidence_created".*c-add.md')" -ge 1 ] \
  && ok "codex Add File: evidence_created row for the file" || bad "codex Add File: no row"
[ "$LAST_RC" = 0 ] && ok "codex Add File: exit 0" || bad "codex Add File: exit $LAST_RC"

d=$(mkp codex_upd)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Update File: .tad/evidence/c-upd.md\n@@\n-x\n+y\n*** End Patch')"
[ "$(rows "$d" 'c-upd.md')" -ge 1 ] && ok "codex Update File: row" || bad "codex Update File: no row"

d=$(mkp codex_move)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Update File: old/place.md\n*** Move to: .tad/evidence/c-moved.md\n@@\n-x\n+y\n*** End Patch')"
[ "$(rows "$d" 'c-moved.md')" -ge 1 ] && [ "$(rows "$d" 'place.md')" = 0 ] && ok "codex Move to: row for the new path only" || bad "codex Move to: wrong rows"

# Multi-file patches: the hook runs the normal handling once per path (loop).
d=$(mkp codex_multi)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: notes.txt\n+a\n*** Add File: .tad/evidence/m1.md\n+b\n*** Update File: .tad/evidence/m2.md\n@@\n-x\n+y\n*** Add File: .tad/evidence/m1.md\n+dup\n*** End Patch')"
[ "$(rows "$d" 'm1.md')" = 1 ] && [ "$(rows "$d" 'm2.md')" = 1 ] && [ "$(rows "$d" 'notes.txt')" = 0 ] \
  && ok "multi-file patch: one row per TAD path, duplicates collapsed, non-TAD path skipped" || bad "multi-file patch: m1=$(rows "$d" 'm1.md') m2=$(rows "$d" 'm2.md')"
[ "$(printf '%s\n' "$LAST_OUT" | grep -c .)" -le 1 ] && ok "multi-file patch: a single response object on stdout" || bad "multi-file patch: several response lines"

d=$(mkp codex_multi_handoff); mkdir -p "$d/.tad/active/handoffs"
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: .tad/evidence/h1.md\n+x\n*** Add File: .tad/active/handoffs/HANDOFF-20261009-zz.md\n+x\n*** End Patch')"
printf '%s' "$LAST_OUT" | grep -q 'Handoff created' && ok "multi-file patch: a later path's reminder is not lost" || bad "multi-file patch: handoff reminder lost ($LAST_OUT)"

d=$(mkp codex_del)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Delete File: .tad/evidence/gone.md\n*** End Patch')"
[ "$(allrows "$d")" = 0 ] && [ "$LAST_RC" = 0 ] && ok "Delete File only: no row, exit 0" || bad "Delete File only: rows=$(allrows "$d") rc=$LAST_RC"

# Hostile paths: each hostile header is paired with a legitimate one at the end, so
# the assertion needs extraction to work (exactly one row, for the legitimate path)
# and fails if any of the filters is removed (each hostile path below would match a
# TAD pattern and leave a row without its filter).
d=$(mkp codex_evil)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: ../../.tad/evidence/esc-fx.md\n+x\n*** Add File: /tmp/.tad/evidence/abs-fx.md\n+x\n*** Add File: .tad/evidence/../../up-fx.md\n+x\n*** Add File: ~/.tad/evidence/home-fx.md\n+x\n*** Add File: .tad/evidence/tab\tfx.md\n+x\n*** Add File: .tad/evidence/cr-fx.md\r\n+x\n*** Add File: .tad/evidence/ctl-fx.md\n+x\n*** End Patch')"
[ "$(allrows "$d")" = 1 ] && [ "$(rows "$d" 'ctl-fx.md')" = 1 ] && [ "$LAST_RC" = 0 ] \
  && ok "hostile paths (.., absolute, ~, control chars): only the legitimate path leaves a row, exit 0" \
  || bad "hostile paths: rows=$(allrows "$d") legit=$(rows "$d" 'ctl-fx.md') rc=$LAST_RC"

# A line break inside a name ends the name; the text after it is a new line, not a header.
# Positive control: the truncated name is what a real patch parser would also see.
d=$(mkp codex_nl)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: .tad/evidence/nl-a\n.tad/evidence/nl-inj-fx.md\n+x\n*** End Patch')"
[ "$(rows "$d" 'nl-a"')" = 1 ] && [ "$(rows "$d" 'nl-inj-fx')" = 0 ] && ok "newline inside a name: name ends at the break, injected second line ignored" || bad "newline-split name: a=$(rows "$d" 'nl-a"') inj=$(rows "$d" 'nl-inj-fx')"

# Performance bound: 20,000 rejected headers must not run the hook past its 10 s limit.
d=$(mkp codex_flood_late)
big=$(awk 'BEGIN{printf "*** Begin Patch"; for(i=0;i<20000;i++) printf "\\n*** Add File: ../x%d", i; printf "\\n*** Add File: .tad/evidence/late-fx.md\\n*** End Patch"}')
t0=$(date +%s); feed "$d" "$(patch_env "$d" "$big")"; t1=$(date +%s)
[ "$LAST_RC" = 0 ] && [ $((t1-t0)) -le 6 ] && ok "20,000 hostile headers: finished in $((t1-t0))s (limit 6s), exit 0" || bad "20,000 hostile headers: ${t1}-${t0}s rc=$LAST_RC"
d=$(mkp codex_flood_early)
big=$(awk 'BEGIN{printf "*** Begin Patch\\n*** Add File: .tad/evidence/early-fx.md"; for(i=0;i<20000;i++) printf "\\n*** Add File: ../x%d", i; printf "\\n*** End Patch"}')
t0=$(date +%s); feed "$d" "$(patch_env "$d" "$big")"; t1=$(date +%s)
[ "$LAST_RC" = 0 ] && [ $((t1-t0)) -le 6 ] && [ "$(rows "$d" 'early-fx.md')" = 1 ] && [ "$(allrows "$d")" = 1 ] && ok "20,000 hostile headers after a legitimate one: its row is kept (${t1}-${t0}s)" || bad "flood after legit header: rows=$(allrows "$d") rc=$LAST_RC"

# Forgery attempts through envelope parts that are not the patch header lines.
d=$(mkp forge_bsn)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: src/a.c\n+x\\n*** Add File: .tad/evidence/forged-bsn-fx.md\n*** Add File: .tad/evidence/real-bsn-fx.md\n+y\\\\n*** Add File: .tad/evidence/forged-bsn2-fx.md\n*** End Patch')"
[ "$(rows "$d" 'forged-bsn')" = 0 ] && [ "$(rows "$d" 'real-bsn-fx.md')" = 1 ] && ok "literal backslash-n in patch content does not forge a header" || bad "backslash-n forged a row (forged=$(rows "$d" 'forged-bsn') real=$(rows "$d" 'real-bsn-fx.md'))"
d=$(mkp forge_resp)
feed "$d" '{"tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":"*** Begin Patch\n*** Delete File: gone.md\n*** End Patch"},"tool_response":"err\n*** Add File: .tad/evidence/forged-resp-fx.md\n"}'
[ "$(allrows "$d")" = 0 ] && ok "header text in tool_response is not read (valid command)" || bad "tool_response header forged a row"
d=$(mkp forge_resp2)
feed "$d" '{"tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":""},"tool_response":"err\n*** Add File: .tad/evidence/forged-resp2-fx.md\n"}'
[ "$(allrows "$d")" = 0 ] && ok "header text in tool_response is not read (empty command)" || bad "tool_response header forged a row (empty command)"
d=$(mkp forge_top)
feed "$d" '{"tool_name":"apply_patch","cwd":"'"$d"'","command":"*** Add File: .tad/evidence/forged-top-fx.md\n","tool_input":{"other":"x"}}'
[ "$(allrows "$d")" = 0 ] && ok "top-level command is not read" || bad "top-level command forged a row"
d=$(mkp forge_top2)
feed "$d" '{"tool_name":"apply_patch","cwd":"'"$d"'","tool_input":"x","command":"*** Add File: .tad/evidence/forged-top2-fx.md\n"}'
[ "$(allrows "$d")" = 0 ] && ok "top-level command after a non-object tool_input is not read" || bad "top-level command (tool_input string) forged a row"
d=$(mkp explicit_path)
feed "$d" '{"tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"path":".tad/evidence/real-path-fx.md","command":"*** Begin Patch\n*** Add File: .tad/evidence/other-path-fx.md\n*** End Patch"}}'
# Without jq the generic extraction never read tool_input.path (unchanged since
# 9c2ad3bb), so there the row for it is not expected; the patch body must stay unread.
want_real=1; [ "${HOOK_FIXTURE_NOJQ:-0}" = 1 ] && want_real=0
[ "$(rows "$d" 'real-path-fx')" = "$want_real" ] && [ "$(rows "$d" 'other-path-fx')" = 0 ] && ok "explicit tool_input.path wins over the patch body" || bad "tool_input.path did not win (real=$(rows "$d" 'real-path-fx') other=$(rows "$d" 'other-path-fx'))"

# Text inside file content that looks like a header must not count.
d=$(mkp codex_inbody)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: readme.txt\n+*** Add File: .tad/evidence/inbody-fx.md\n*** End Patch')"
[ "$(rows "$d" 'inbody-fx')" = 0 ] && ok "header text inside patch content is ignored" || bad "header text inside content was taken as a path"

# More than 20 paths: capped at 20.
d=$(mkp codex_cap); body='*** Begin Patch'
i=1; while [ $i -le 25 ]; do body="$body\\n*** Add File: .tad/evidence/cap$i.md\\n+x"; i=$((i+1)); done
feed "$d" "$(patch_env "$d" "$body"'\n*** End Patch')"
[ "$(allrows "$d")" = 20 ] && ok "25-path patch: capped at 20 rows" || bad "25-path patch: $(allrows "$d") rows"

# Other harnesses keep working unchanged.
d=$(mkp claude_write)
feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"Write","cwd":"'"$d"'","tool_input":{"file_path":"'"$d"'/.tad/evidence/cc-fx.md","content":"x"}}'
[ "$(rows "$d" 'cc-fx.md')" = 1 ] && ok "Claude Code Write envelope: one row" || bad "Claude Code Write envelope: no row (regression)"
d=$(mkp cursor_write)
feed "$d" '{"hook_event_name":"postToolUse","tool_name":"Write","cwd":"'"$d"'","tool_input":{"file_path":"'"$d"'/.tad/evidence/cur-fx.md","contents":"x"}}'
[ "$(rows "$d" 'cur-fx.md')" = 1 ] && ok "Cursor Write envelope: one row" || bad "Cursor Write envelope: no row (regression)"
d=$(mkp opencode_write)
feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"write","tool_input":{"file_path":".tad/evidence/oc-fx.md"},"cwd":"'"$d"'"}'
[ "$(rows "$d" 'oc-fx.md')" = 1 ] && ok "OpenCode write envelope (relative path): one row" || bad "OpenCode write envelope: no row (regression)"
d=$(mkp opencode_empty)
feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","tool_input":{"file_path":""},"cwd":"'"$d"'"}'
[ "$(allrows "$d")" = 0 ] && [ "$LAST_RC" = 0 ] && [ "$LAST_OUT" = "{}" ] && ok "OpenCode apply_patch with empty path: {} , no row, exit 0" || bad "OpenCode apply_patch empty path: out=$LAST_OUT rc=$LAST_RC"

# An explicit file_path wins over the patch body even for apply_patch.
d=$(mkp explicit_wins)
feed "$d" '{"tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"file_path":".tad/evidence/explicit-fx.md","command":"*** Begin Patch\n*** Add File: .tad/evidence/other-fx.md\n*** End Patch"}}'
[ "$(rows "$d" 'explicit-fx')" = 1 ] && [ "$(rows "$d" 'other-fx')" = 0 ] && ok "explicit file_path takes precedence over the patch body" || bad "explicit file_path precedence broken"

# Non-TAD write, non-patch tool with a command field, empty and malformed input.
d=$(mkp plain)
feed "$d" "$(patch_env "$d" '*** Begin Patch\n*** Add File: plain.txt\n+x\n*** End Patch')"
[ "$(allrows "$d")" = 0 ] && ok "write outside TAD paths: no row" || bad "write outside TAD paths left a row"
d=$(mkp bash_tool)
feed "$d" '{"tool_name":"Bash","cwd":"'"$d"'","tool_input":{"command":"*** Add File: .tad/evidence/bash-fx.md\n"}}'
[ "$(allrows "$d")" = 0 ] && ok "non-apply_patch tool: patch parsing not applied" || bad "patch parsing ran for a non-apply_patch tool"
d=$(mkp junk)
feed "$d" 'not json at all {{{'
[ "$LAST_RC" = 0 ] && [ "$(allrows "$d")" = 0 ] && ok "malformed input: exit 0, no row" || bad "malformed input: rc=$LAST_RC"
feed "$d" ''
[ "$LAST_RC" = 0 ] && ok "empty input: exit 0" || bad "empty input: rc=$LAST_RC"

echo "passed=$PASS failed=$FAILN"
if [ "$FAILN" = 0 ]; then echo "HOOK-ENVELOPE-FIXTURE: PASS"; else echo "HOOK-ENVELOPE-FIXTURE: FAIL"; exit 1; fi
