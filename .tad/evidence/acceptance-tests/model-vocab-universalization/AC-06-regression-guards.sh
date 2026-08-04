#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

BASELINE=".tad/evidence/acceptance-tests/model-vocab-universalization/baseline.md"
BASELINE_SHA="$(sed -n 's/^BASELINE_COMMIT=//p' "$BASELINE")"

bash .tad/hooks/lib/release-verify.sh parity .
bash .tad/hooks/lib/skill-body-verify.sh
bash .tad/hooks/lib/runtime-freshness-verify.sh .

frontmatter_files="$(git diff --name-only "$BASELINE_SHA" -- .claude/skills .agents/skills | grep -E '/SKILL\.md$' || true)"
if [ -z "$frontmatter_files" ]; then
  echo "FAIL AC6: no changed SKILL front matter files discovered"
  exit 1
fi
for file in $frontmatter_files; do
 ruby -e 'require "yaml"; path=ARGV.fetch(0); text=File.read(path); parts=text.split(/^---[[:space:]]*$/, 3); abort("front matter missing: #{path}") unless parts.length == 3; YAML.safe_load(parts[1], aliases: true); puts("front matter PASS: #{path}")' -- "$file"
done

echo "AC6 PASS: parity, skill-body, and runtime-freshness regression guards passed"
