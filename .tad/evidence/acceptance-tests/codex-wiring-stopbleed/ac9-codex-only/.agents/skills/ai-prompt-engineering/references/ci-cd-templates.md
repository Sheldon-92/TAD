# CI/CD Pipeline Templates for Prompt Engineering

> 3-tier pipeline architecture for production prompt deployment.
> Source: Industry patterns from promptfoo documentation + Braintrust engineering blog, 2026.
> All templates use GitHub Actions. Adapt to GitLab CI or CircleCI as needed.

---

## Pipeline Overview

| Tier | When Runs | Duration | Purpose | Gate |
|------|-----------|----------|---------|------|
| Tier 1 | Per-commit (all branches) | <2 min | Deterministic fast checks | Blocks commit |
| Tier 2 | Per-PR (target: main) | 10–20 min | LLM regression on golden set | Blocks merge |
| Tier 3 | Weekly + pre-release | 60–90 min | Security scan + adversarial | Advisory only |

**Implementation sequence**: Deploy Tier 1 first. Add Tier 2 once you have a golden dataset with
≥18 test cases. Add Tier 3 for production-critical or security-sensitive prompts.

---

## Tier 1: Per-Commit Fast Checks (<2 min)

Deterministic checks that don't require LLM calls:
- JSON format validation
- Keyword presence/absence
- Token budget check
- Schema compliance

### GitHub Actions Template

```yaml
# .github/workflows/prompt-tier1.yml
name: Prompt Tier 1 — Fast Checks

on:
  push:
    paths:
      - 'prompts/**'
      - '**.promptfooconfig.yaml'

jobs:
  tier1:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install promptfoo
        run: npm install -g promptfoo

      - name: Run Tier 1 eval
        run: |
          npx promptfoo eval \
            --config prompts/promptfooconfig.yaml \
            --filter-metadata "tier=1" \
            --no-cache \
            --output results/tier1-${{ github.sha }}.json

      - name: Check pass rate
        run: |
          PASS_RATE=$(python3 - << 'EOF'
          import json, sys
          d = json.load(open("results/tier1-${{ github.sha }}.json"))
          total = d['stats']['totalTests']
          if total == 0:
              print("ERROR: 0 tests ran — check --filter-metadata flag", file=sys.stderr)
              sys.exit(1)
          print(d['stats']['successes'] / total * 100)
          EOF
          )
          echo "Pass rate: $PASS_RATE%"
          python3 -c "import sys; sys.exit(0 if float('$PASS_RATE') >= 95 else 1)"

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: tier1-results
          path: results/
```

### promptfoo Tier 1 Test Cases

Tag Tier 1 tests with `metadata.tier: 1` in your promptfooconfig.yaml:

```yaml
tests:
  # Format validation
  - description: "Response is valid JSON"
    metadata:
      tier: 1
    vars:
      input: "Extract company: Acme Corp was founded in 1990."
    assert:
      - type: is-json

  # Keyword presence
  - description: "Response contains required keys"
    metadata:
      tier: 1
    vars:
      input: "Extract company: Acme Corp was founded in 1990."
    assert:
      - type: javascript
        value: |
          const parsed = JSON.parse(output);
          return parsed.hasOwnProperty('company') && parsed.hasOwnProperty('year');

  # Token budget check (deterministic — count the input tokens)
  - description: "Input within token budget"
    metadata:
      tier: 1
    vars:
      input: "{{ longInput }}"
    assert:
      - type: javascript
        value: "prompt.length < 4000"  # approximate character budget
```

---

## Tier 2: Per-PR LLM Regression (10–20 min)

LLM-as-judge regression on golden dataset. Blocks PR merge if pass rate drops.

### GitHub Actions Template

```yaml
# .github/workflows/prompt-tier2.yml
name: Prompt Tier 2 — LLM Regression

on:
  pull_request:
    branches: [main]
    paths:
      - 'prompts/**'

jobs:
  tier2:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install promptfoo
        run: npm install -g promptfoo

      - name: Run Tier 2 eval
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
        run: |
          npx promptfoo eval \
            --config prompts/promptfooconfig.yaml \
            --filter-metadata "tier=2" \
            --no-cache \
            --output results/tier2-${{ github.event.pull_request.number }}.json

      - name: Enforce pass rate
        run: |
          python3 << 'EOF'
          import json, sys

          with open(f"results/tier2-${{ github.event.pull_request.number }}.json") as f:
              data = json.load(f)

          total = data['stats']['totalTests']
          passed = data['stats']['successes']
          rate = passed / total * 100

          print(f"Pass rate: {rate:.1f}% ({passed}/{total})")

          # Block merge if rate drops below threshold
          threshold = 80.0
          if rate < threshold:
              print(f"FAIL: Pass rate {rate:.1f}% < threshold {threshold}%")
              sys.exit(1)
          else:
              print(f"PASS: Pass rate meets threshold")
          EOF

      - name: Comment results on PR
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const results = JSON.parse(fs.readFileSync(
              `results/tier2-${{ github.event.pull_request.number }}.json`
            ));
            const rate = (results.stats.successes / results.stats.totalTests * 100).toFixed(1);
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Prompt Evaluation Results\n\n**Pass rate**: ${rate}% (${results.stats.successes}/${results.stats.totalTests})\n\n[View full results in Actions](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${{ github.run_id }})`
            });
```

### promptfoo Tier 2 Test Cases

```yaml
tests:
  # LLM-as-judge: quality check
  - description: "Response quality meets bar"
    metadata:
      tier: 2
    vars:
      input: "{{ typicalUserQuery }}"
    assert:
      - type: llm-rubric
        value: |
          The response should:
          1. Directly answer the question asked
          2. Not include unnecessary preamble
          3. Follow the specified output format
          Score pass if all 3 criteria are met.

  # Regression: previously-passing golden case
  - description: "Golden case: customer extraction"
    metadata:
      tier: 2
    vars:
      input: "Acme Corp (NYSE: ACME) reported Q3 earnings of $2.4B."
    assert:
      - type: javascript
        value: |
          const parsed = JSON.parse(output);
          return parsed.company === "Acme Corp" && parsed.ticker === "ACME";
```

---

## Tier 3: Weekly Security + Adversarial Scan (60–90 min)

Full vulnerability scan, jailbreak testing, edge-case hallucination detection.
Advisory — does not block deployments but creates an issue for tracking.

### GitHub Actions Template

```yaml
# .github/workflows/prompt-tier3.yml
name: Prompt Tier 3 — Security & Adversarial

on:
  schedule:
    - cron: '0 6 * * 1'  # Monday 6am UTC
  workflow_dispatch:    # Manual trigger for pre-release

jobs:
  tier3:
    runs-on: ubuntu-latest
    timeout-minutes: 90
    steps:
      - uses: actions/checkout@v4

      - name: Install promptfoo
        run: npm install -g promptfoo

      - name: Generate red team config
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          PROMPTFOO_PURPOSE: ${{ vars.PROMPTFOO_PURPOSE || 'AI assistant' }}  # Set in repo variables
        run: |
          npx promptfoo redteam generate \
            --config prompts/promptfooconfig.yaml \
            --output prompts/redteam-generated.yaml \
            --purpose "$PROMPTFOO_PURPOSE" \
            --plugins "harmful:default,jailbreak,prompt-injection" \
            --num-tests 50

      - name: Run red team eval
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          npx promptfoo redteam run \
            --config prompts/redteam-generated.yaml \
            --output results/tier3-$(date +%Y%m%d).json

      - name: Check security thresholds
        run: |
          python3 << 'EOF'
          import json
          from datetime import date

          filename = f"results/tier3-{date.today().strftime('%Y%m%d')}.json"
          with open(filename) as f:
              data = json.load(f)

          # Advisory: create tracking data, don't fail the workflow
          total = data['stats']['totalTests']
          passed = data['stats']['successes']
          failed = total - passed

          print(f"Adversarial tests: {passed}/{total} defended")
          print(f"Vulnerabilities found: {failed}")

          # Write summary for issue creation
          with open("tier3-summary.txt", "w") as f:
              f.write(f"## Tier 3 Security Scan — {date.today()}\n\n")
              f.write(f"- Tests run: {total}\n")
              f.write(f"- Defended: {passed}\n")
              f.write(f"- Vulnerabilities: {failed}\n\n")
              if failed > 0:
                  f.write("**Action required**: Review failed cases in Actions artifacts.\n")
          EOF

      - name: Create tracking issue if vulnerabilities found
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const summary = fs.readFileSync('tier3-summary.txt', 'utf8');
            if (summary.includes('Vulnerabilities: 0')) return;

            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `[Prompt Security] Tier 3 vulnerabilities found ${new Date().toISOString().split('T')[0]}`,
              body: summary + `\n\n[View details](${context.serverUrl}/${context.repo.owner}/${context.repo.repo}/actions/runs/${{ github.run_id }})`,
              labels: ['prompt-security', 'needs-review']
            });

      - name: Upload results
        uses: actions/upload-artifact@v4
        with:
          name: tier3-results-${{ github.run_id }}
          path: results/
          retention-days: 90
```

---

## promptfooconfig.yaml — Complete Template

```yaml
# prompts/promptfooconfig.yaml
description: "[Your system name] prompt evaluation suite"

prompts:
  - file://system-prompt.txt

providers:
  - id: anthropic:messages:claude-sonnet-4-6
    config:
      max_tokens: 1024
      temperature: 0.0  # deterministic for testing

defaultTest:
  options:
    timeout: 30000  # 30 second timeout per test

# Tier 1: fast, deterministic (no LLM calls)
# Tier 2: LLM regression on golden set
# Tier 3: adversarial (generated by redteam generate)

tests:
  # ── Tier 1 ──────────────────────────────────────────────────────
  - description: "T1-01: Response is valid JSON"
    metadata: {tier: 1}
    vars: {input: "sample input"}
    assert:
      - type: is-json

  - description: "T1-02: Required fields present"
    metadata: {tier: 1}
    vars: {input: "sample input"}
    assert:
      - type: javascript
        value: "const p = JSON.parse(output); return 'result' in p && 'confidence' in p;"

  # ── Tier 2 ──────────────────────────────────────────────────────
  - description: "T2-01: Golden case (happy path)"
    metadata: {tier: 2}
    vars: {input: "representative production input 1"}
    assert:
      - type: contains
        value: "expected key phrase"

  # Add 17+ more cases following the 10/5/3 structure:
  # 10 core cases + 5 edge cases + 3 adversarial
  # See tools/promptfoo-starter.yaml for complete 18-case template
```
