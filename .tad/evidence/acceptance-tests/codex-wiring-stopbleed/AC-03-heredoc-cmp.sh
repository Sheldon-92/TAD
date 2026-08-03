#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO="$(cd "$SCRIPT_DIR/../../../../" && pwd -P)"
cd "$REPO"
hook_start="$(rg -n "cat > \.codex/hooks\.json << 'HOOKS_EOF'" tad.sh | cut -d: -f1)"
hook_end="$(awk -v start="$hook_start" 'NR > start && /^HOOKS_EOF$/ {print NR; exit}' tad.sh)"
tmpdir="$(mktemp -d)"
sed -n "$((hook_start + 1)),$((hook_end - 1))p" tad.sh > "$tmpdir/hooks.json"
cmp -s "$tmpdir/hooks.json" .codex/hooks.json
echo "AC3 PASS: tad.sh heredoc lines ${hook_start}-${hook_end} cmp repository hooks.json"
