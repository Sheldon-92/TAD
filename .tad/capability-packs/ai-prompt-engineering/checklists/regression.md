# Prompt Version Regression Protocol

> Follow this protocol before upgrading a prompt to a new version.
> Applies to: model version upgrades, significant prompt rewrites, provider changes.

---

## When to Run This Protocol

Run regression testing before:
- Upgrading model version (e.g., `claude-sonnet-4-6` → `claude-opus-4-7`)
- Significant prompt rewrite (structural changes, role redefinition)
- Provider change (switching from OpenAI to Anthropic or vice versa)
- After any Tier 3 vulnerability finding is fixed

Do NOT run for:
- Typo fixes (PATCH version)
- Whitespace changes
- Documentation-only changes

---

## Step 1: Baseline Capture

Before making any changes, capture the baseline:

```bash
# Run current (production) prompt against full test suite
npx promptfoo eval \
  --config prompts/promptfooconfig.yaml \
  --output results/baseline-$(date +%Y%m%d)-$(git rev-parse --short HEAD).json \
  --no-cache

# Record baseline metrics
echo "Baseline captured at $(date)" >> regression-log.txt
```

Key metrics to record:
- Overall pass rate
- Pass rate per test category (core / edge / adversarial)
- Average token cost per test
- Average latency (p50, p95)

---

## Step 2: Apply Changes

Make the prompt change (model upgrade, rewrite, etc.):

```bash
# If model upgrade: update provider in promptfooconfig.yaml
# Before:  id: anthropic:messages:claude-sonnet-4-6
# After:   id: anthropic:messages:claude-opus-4-7  # exact new version

# Commit the change
git add prompts/
git commit -m "prompt(regression-test): upgrade model for regression testing"
```

---

## Step 3: Run Regression

```bash
# Run with new configuration
npx promptfoo eval \
  --config prompts/promptfooconfig.yaml \
  --output results/candidate-$(date +%Y%m%d)-$(git rev-parse --short HEAD).json \
  --no-cache
```

---

## Step 4: Compare Results

```bash
# Compare baseline vs candidate (manually — promptfoo has no 'diff' subcommand)
python3 - << 'EOF'
import glob, json, sys

baseline_files = sorted(glob.glob('results/baseline-*.json'))
candidate_files = sorted(glob.glob('results/candidate-*.json'))
if not baseline_files or not candidate_files:
    print("ERROR: missing baseline or candidate result files")
    sys.exit(1)

baseline = json.load(open(baseline_files[-1]))
candidate = json.load(open(candidate_files[-1]))

bt = baseline['stats']['totalTests']
ct = candidate['stats']['totalTests']
if bt == 0 or ct == 0:
    print("ERROR: 0 tests in results — check eval configuration")
    sys.exit(1)

b_rate = baseline['stats']['successes'] / bt
c_rate = candidate['stats']['successes'] / ct

print(f"Baseline pass rate:  {b_rate:.1%} ({baseline['stats']['successes']}/{bt})")
print(f"Candidate pass rate: {c_rate:.1%} ({candidate['stats']['successes']}/{ct})")
print(f"Delta: {(c_rate - b_rate):.1%}")
EOF
```

---

## Step 5: Evaluate Production Sample

Compare outputs on 10 representative production inputs (not from your test suite):

```bash
# Create a sample file with 10 production inputs
cat > regression-sample.yaml << 'EOF'
tests:
  - vars:
      input: "[production sample 1]"
  - vars:
      input: "[production sample 2]"
  # ... 8 more
EOF

# Run both baseline and candidate on the same sample
npx promptfoo eval --config regression-sample.yaml --output results/sample-baseline.json
# Switch provider, then:
npx promptfoo eval --config regression-sample.yaml --output results/sample-candidate.json
```

Review output pairs manually. Flag any behavioral changes.

---

## Step 6: Decision Gate

| Metric | Threshold | Action if Fails |
|--------|-----------|-----------------|
| Pass rate delta | ≥ -2% (not worse than -2 percentage points) | Do not upgrade; investigate failures |
| Adversarial pass rate | 100% (same or better) | Do not upgrade; fix security regression first |
| Production sample quality | No behavioral regressions observed | Do not upgrade; document and escalate |
| Cost delta | ≤ +20% (within 20% of baseline cost) | Flag for review; may still upgrade if justified |

---

## Step 7: Document and Commit

If regression passes all gates:

```markdown
## v1.1.0 (2026-MM-DD)
**Why**: [Reason for upgrade — e.g., "Model upgrade from claude-sonnet-4-6 to claude-opus-4-7 for improved reasoning quality"]
**Fix**: [What changed]
**Regression**: PASS
  - Golden dataset: 18/18 (100%)
  - Production sample: 10/10 (no regressions)
  - Adversarial: 3/3 (100%)
**Test results**: [link to results JSON file in repo]
**Breaking change**: No
```

```bash
git add results/ CHANGELOG.md prompts/
git commit -m "feat(prompts): upgrade to [new version] — regression passed"
```

---

## Canary Deployment (Optional, for High-Stakes Prompts)

After regression passes, deploy at 5% traffic for 24–48h before full rollout:

Monitor during canary:
- Error rate vs baseline
- Output quality score (if monitored in production)
- Refusal rate (sudden spike = model change)
- Format compliance rate

Rollback trigger: >2% degradation in any metric over a 2-hour window.
