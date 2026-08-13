#!/usr/bin/env bash
# lighthouse-check.sh — Run Lighthouse CLI and check Core Web Vitals thresholds
# Usage: bash scripts/lighthouse-check.sh [URL]
# Default URL: http://localhost:3000
# Exit 0: all metrics in "Good" range
# Exit 1: one or more metrics fail thresholds
# Exit 2: Lighthouse CLI not installed

set -euo pipefail

URL="${1:-http://localhost:3000}"

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Usage: bash scripts/lighthouse-check.sh [URL]"
  echo "       Default URL: http://localhost:3000"
  echo ""
  echo "Checks Core Web Vitals thresholds:"
  echo "  LCP  < 2.5s  (Largest Contentful Paint)"
  echo "  INP  < 200ms (Interaction to Next Paint)"
  echo "  CLS  < 0.1   (Cumulative Layout Shift)"
  echo ""
  echo "Exit codes:"
  echo "  0  All metrics in Good range"
  echo "  1  One or more metrics failed"
  echo "  2  Lighthouse CLI not installed (npm install -g lighthouse)"
  exit 0
fi

# Check Lighthouse is installed
if ! command -v lighthouse &>/dev/null; then
  echo "ERROR: Lighthouse CLI not found."
  echo "Install with: npm install -g lighthouse"
  exit 2
fi

OUTPUT_FILE="/tmp/lighthouse-report-$$.json"
trap 'rm -f "$OUTPUT_FILE"' EXIT

echo "Running Lighthouse on: $URL"
echo "This may take 30-60 seconds..."

lighthouse "$URL" \
  --output=json \
  --output-path="$OUTPUT_FILE" \
  --only-categories=performance \
  --chrome-flags="--headless --no-sandbox --disable-dev-shm-usage" \
  --quiet

if [[ ! -f "$OUTPUT_FILE" ]]; then
  echo "ERROR: Lighthouse failed to produce output."
  exit 1
fi

# Extract metrics using node (available wherever npm/lighthouse is installed)
node -e "
  const report = JSON.parse(require('fs').readFileSync('$OUTPUT_FILE', 'utf8'));
  const audits = report.audits;

  // LCP — numeric value in ms
  const lcpMs = audits['largest-contentful-paint']?.numericValue || 0;
  const lcpS = (lcpMs / 1000).toFixed(2);

  // INP cannot be measured in lab mode. TBT (Total Blocking Time) is the Lighthouse proxy.
  // True INP requires Real User Monitoring (web-vitals library in production).
  const inpAudit = audits['interaction-to-next-paint'];
  const tbtAudit = audits['total-blocking-time'];
  const inpMs = inpAudit?.numericValue ?? tbtAudit?.numericValue ?? 0;
  const inpLabel = (inpAudit?.numericValue !== undefined) ? 'INP' : 'TBT (INP lab proxy)';

  // CLS — unitless score
  const cls = audits['cumulative-layout-shift']?.numericValue || 0;

  const lcpPass = lcpMs < 2500;
  const inpPass = inpMs < 200;
  const clsPass = cls < 0.1;

  const lcpIcon = lcpPass ? '✅' : '❌';
  const inpIcon = inpPass ? '✅' : '❌';
  const clsIcon = clsPass ? '✅' : '❌';

  console.log('');
  console.log('Core Web Vitals Results:');
  console.log(\`  \${lcpIcon} LCP: \${lcpS}s    (threshold: <2.5s)\`);
  console.log(\`  \${inpIcon} \${inpLabel}: \${inpMs}ms  (threshold: <200ms)\`);
  console.log(\`  \${clsIcon} CLS: \${cls.toFixed(4)}   (threshold: <0.1)\`);
  console.log('');

  const allPass = lcpPass && inpPass && clsPass;
  if (allPass) {
    console.log('RESULT: ✅ PASS — All Core Web Vitals in Good range');
    process.exit(0);
  } else {
    console.log('RESULT: ❌ FAIL — One or more metrics exceed threshold');
    process.exit(1);
  }
"
