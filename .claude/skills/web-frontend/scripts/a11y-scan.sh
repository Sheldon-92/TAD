#!/usr/bin/env bash
# a11y-scan.sh — Run axe-core accessibility scan on a live URL
# Usage: bash scripts/a11y-scan.sh [URL]
# Default URL: http://localhost:3000
# Exit 0: 0 critical + 0 serious violations
# Exit 1: violations found
# Exit 2: axe CLI not installed

set -euo pipefail

URL="${1:-http://localhost:3000}"

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Usage: bash scripts/a11y-scan.sh [URL]"
  echo "       Default URL: http://localhost:3000"
  echo ""
  echo "Runs axe-core accessibility scan and checks for critical/serious violations."
  echo "Violations at 'moderate' and 'minor' severity are reported but do not fail."
  echo ""
  echo "Exit codes:"
  echo "  0  0 critical + 0 serious violations"
  echo "  1  Violations found (critical or serious)"
  echo "  2  @axe-core/cli not installed (npm install -g @axe-core/cli)"
  exit 0
fi

# Check axe CLI is installed
if ! command -v axe &>/dev/null; then
  echo "ERROR: @axe-core/cli not found."
  echo "Install with: npm install -g @axe-core/cli"
  exit 2
fi

echo "Running axe-core scan on: $URL"
echo "This may take 15-30 seconds..."

OUTPUT_FILE="/tmp/axe-report-$$.json"
STDERR_FILE="/tmp/axe-stderr-$$.log"
trap 'rm -f "$OUTPUT_FILE" "$STDERR_FILE"' EXIT

# Run axe-core, output JSON via --save (axe CLI does not use --reporter flag).
# Allow exit 1 from axe (violations found) — we'll check ourselves.
if ! axe "$URL" \
  --save="$OUTPUT_FILE" \
  --chrome-options="no-sandbox,disable-dev-shm-usage" \
  2>"$STDERR_FILE"; then
  : # axe exits non-zero on violations — continue to parse output
fi

if [[ ! -f "$OUTPUT_FILE" ]]; then
  echo "ERROR: axe-core failed to produce output."
  if [[ -s "$STDERR_FILE" ]]; then
    echo "Diagnostic (stderr):"
    sed 's/^/  /' "$STDERR_FILE"
  fi
  exit 1
fi

node -e "
  const fs = require('fs');
  const report = JSON.parse(fs.readFileSync('$OUTPUT_FILE', 'utf8'));

  // axe JSON report: array of page results, each with violations[]
  const results = Array.isArray(report) ? report : [report];
  let critical = 0, serious = 0, moderate = 0, minor = 0;
  const allViolations = [];

  for (const page of results) {
    for (const v of (page.violations || [])) {
      const count = v.nodes?.length || 1;
      switch (v.impact) {
        case 'critical': critical += count; break;
        case 'serious':  serious  += count; break;
        case 'moderate': moderate += count; break;
        case 'minor':    minor    += count; break;
      }
      allViolations.push({ id: v.id, impact: v.impact, description: v.description, count });
    }
  }

  console.log('');
  console.log('axe-core Accessibility Scan Results:');
  console.log(\`  Critical:  \${critical}\`);
  console.log(\`  Serious:   \${serious}\`);
  console.log(\`  Moderate:  \${moderate} (informational)\`);
  console.log(\`  Minor:     \${minor}    (informational)\`);
  console.log('');

  if (allViolations.length > 0) {
    console.log('Violations:');
    for (const v of allViolations.sort((a, b) => {
      const order = { critical: 0, serious: 1, moderate: 2, minor: 3 };
      return order[a.impact] - order[b.impact];
    })) {
      const icon = (v.impact === 'critical' || v.impact === 'serious') ? '❌' : '⚠️';
      console.log(\`  \${icon} [\${v.impact}] \${v.id} (\${v.count} element(s))\`);
      console.log(\`     \${v.description}\`);
    }
    console.log('');
  }

  if (critical === 0 && serious === 0) {
    console.log('RESULT: ✅ PASS — 0 critical, 0 serious violations');
    process.exit(0);
  } else {
    console.log('RESULT: ❌ FAIL — Critical or serious violations found');
    process.exit(1);
  }
"
