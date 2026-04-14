#!/bin/bash
# Hardened evidence structure validator (Phase 1b).
#
# Extends Phase 1a exp3 with:
#   - Reject `Overall: PASS` inside markdown code fence (```  ... ```)
#   - Require ≥3 file-path references that resolve via `git ls-files`
#   - Reject if sha256 matches any file in .tad/archive/ (copy-paste detection)
#   - Reject if mtime older than corresponding handoff file mtime (staleness)
#   - Reject if non-whitespace byte count ≤ 80 (padding bypass defense)
#   - Reject symlinks
#
# Exit codes: 0 valid, 1 invalid (stderr = specific reason)
# Fail-closed: all errors → exit 1 with diagnostic

set -euo pipefail

# ── TAD Phase 1c AC17 fix: dep-guard (hard-deny if jq/awk missing) ──
source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"
require_dep jq
require_dep awk
# ── end dep-guard block ──

trap 'echo "FAIL: internal error (fail-closed)" >&2; exit 1' ERR

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

if [ $# -lt 1 ]; then
  fail "usage: $0 <path-to-md>"
fi

file="$1"

# Reject symlinks outright
if [ -L "$file" ]; then
  fail "symlink rejected: $file"
fi

if [ ! -f "$file" ]; then
  fail "file not found: $file"
fi

# Readable check
if [ ! -r "$file" ]; then
  fail "unreadable (permissions): $file"
fi

# Size > 100 bytes (inherited from 1a)
size=$(wc -c < "$file" | tr -d ' ')
if [ "$size" -le 100 ]; then
  fail "too small ($size bytes, need > 100)"
fi

# Non-whitespace byte count > 80 (padding bypass defense)
nonws=$(tr -d '[:space:]' < "$file" | wc -c | tr -d ' ')
if [ "$nonws" -le 80 ]; then
  fail "padding-heavy: only $nonws non-whitespace bytes (need > 80)"
fi

# Line-anchored Overall: PASS|FAIL (inherited)
if ! grep -qE '^Overall: (PASS|FAIL)$' "$file"; then
  fail "missing '^Overall: (PASS|FAIL)\$' line"
fi

# Reject if Overall line is inside a ```...``` code fence block
# Algorithm: walk file line by line, tracking fence state.
inside_fence=0
overall_in_fence=0
while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ ^\`\`\` ]]; then
    inside_fence=$((1 - inside_fence))
    continue
  fi
  if [ "$inside_fence" -eq 1 ] && [[ "$line" =~ ^Overall:\ (PASS|FAIL)$ ]]; then
    overall_in_fence=1
  fi
done < "$file"
if [ "$overall_in_fence" -eq 1 ]; then
  # Only fail if THERE IS NO OUTSIDE-FENCE Overall line. Otherwise it's just
  # a quoted example — the outside-fence one is the real verdict.
  outside_count=$(awk '
    /^```/ { in_fence = !in_fence; next }
    !in_fence && /^Overall: (PASS|FAIL)$/ { c++ }
    END { print c+0 }
  ' "$file")
  if [ "$outside_count" -eq 0 ]; then
    fail "Overall verdict found only inside code fence — not trusted"
  fi
fi

# Require ≥3 file-path references resolvable via git ls-files
# Extract candidate paths: look for path-like tokens (letters/digits/_-./)
# containing a slash and at least one dot (file-looking). Skip URLs.
# NOTE: we only count paths that git ls-files knows — bogus invented paths
# (e.g., hallucinated imports) don't count.
# Capture (a) filename.ext AND (b) dir/filename.ext AND (c) .dotfile.ext forms.
# Start class includes `.` to match dot-prefixed paths like `.tad/config.yaml`, `.gitignore.example`.
candidates=$(grep -oE '[a-zA-Z0-9_.][a-zA-Z0-9_./-]*\.[a-zA-Z0-9]+' "$file" 2>/dev/null | sort -u || true)
resolved_count=0
if [ -n "$candidates" ]; then
  # Precompute git-tracked file set ONCE (single subprocess vs N subprocesses)
  # Use process substitution → grep -F. This cuts evidence-validator latency ~10x.
  git_files=$(git ls-files 2>/dev/null || true)
  while IFS= read -r cand; do
    cand="${cand#./}"
    if printf '%s\n' "$git_files" | grep -qxF "$cand"; then
      resolved_count=$((resolved_count + 1))
    fi
  done <<< "$candidates"
fi
if [ "$resolved_count" -lt 3 ]; then
  fail "only $resolved_count resolvable file refs (need >=3 via git ls-files)"
fi

# Archive duplicate detection via pre-built manifest (1 stat + 1 grep vs N openssls)
# Manifest format: <sha256> <filepath> (one per line).
# Build-on-demand if missing; mtime-invalidate if stale.
ARCHIVE_MANIFEST=".tad/archive/.sha-manifest.txt"
if [ -d ".tad/archive" ]; then
  needs_rebuild=0
  if [ ! -f "$ARCHIVE_MANIFEST" ]; then
    needs_rebuild=1
  else
    # Rebuild if any archive file newer than manifest
    newest=$(find .tad/archive -type f -name '*.md' -newer "$ARCHIVE_MANIFEST" 2>/dev/null | head -1)
    [ -n "$newest" ] && needs_rebuild=1
  fi
  if [ "$needs_rebuild" -eq 1 ]; then
    find .tad/archive -type f -name '*.md' 2>/dev/null | while read -r af; do
      openssl dgst -sha256 -r "$af" 2>/dev/null | awk -v p="$af" '{print $1" "p}'
    done > "$ARCHIVE_MANIFEST" 2>/dev/null || :
  fi
  file_sha=$(openssl dgst -sha256 -r "$file" 2>/dev/null | awk '{print $1}')
  if [ -n "$file_sha" ] && [ -s "$ARCHIVE_MANIFEST" ]; then
    if match=$(grep "^$file_sha " "$ARCHIVE_MANIFEST" 2>/dev/null); then
      fail "content sha256 matches archive file: ${match#* }"
    fi
  fi
fi

# Staleness check: if a handoff slug is discoverable from filename/parent dir,
# compare mtime against the handoff. Only active handoffs are considered.
parent_slug=""
case "$(cd "$(dirname "$file")" 2>/dev/null && pwd)" in
  */reviews/blake/*)
    parent_slug=$(basename "$(dirname "$file")")
    ;;
esac
if [ -n "$parent_slug" ]; then
  for hf in .tad/active/handoffs/HANDOFF-*-${parent_slug}.md; do
    if [ -f "$hf" ]; then
      file_mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file")
      hf_mtime=$(stat -f %m "$hf" 2>/dev/null || stat -c %Y "$hf")
      if [ "$file_mtime" -lt "$hf_mtime" ]; then
        fail "stale: mtime $file_mtime < handoff mtime $hf_mtime ($hf)"
      fi
      break
    fi
  done
fi

exit 0
