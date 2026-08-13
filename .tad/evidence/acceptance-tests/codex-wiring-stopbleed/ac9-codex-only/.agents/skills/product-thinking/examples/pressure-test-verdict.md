---
name: pressure-test-verdict
description: "Tests /pressure-test adversarial 6-round flow + BUILD/PIVOT/KILL verdict + product-type adapter detection on a new product idea"
pack: product-thinking
tests_rules:
  - "/pressure-test — adversarial idea diagnosis, 6 rounds with real data"
  - "BUILD / PIVOT / KILL verdict"
  - "Product Type Adapter detection (software/hardware/marketplace/…)"
min_marker_count: 2
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "it's a good idea"/"do
# market research" and input nouns. The /pressure-test protocol, terminal BUILD/PIVOT/KILL
# verdict, product-type adapter, and FACT/ASSUMPTION evidence recording are pack-named.
# min_discriminative=2 (thin pack — mmc was already 2; verdict + protocol name suffice).
discriminative_pattern: "/pressure-test|PIVOT|KILL|product.?type adapter|ASSUMPTION"
min_discriminative: 2
---

# Fixture: Idea Pressure-Test Verdict

## Input Scenario

"I want to build a SaaS app that helps freelancers auto-generate invoices from their calendar. Is this a good idea? Should I build it?"

## Expected Markers

When an AI agent processes the Input Scenario with the product-thinking pack loaded,
the output MUST contain these markers:

1. **BUILD/PIVOT/KILL verdict** [structural]: the pressure-test concludes with one of the three named verdicts, not a vague "it could work"
   grep pattern: `BUILD|PIVOT|KILL|BUILD/PIVOT/KILL`
2. **Adversarial multi-round diagnosis with real data search**: the pack runs ~6 challenge rounds against the idea, not a single encouraging answer
   grep pattern: `pressure.?test|6 rounds|adversarial|challenge round|round [1-6]|real data`
3. **Product-type adapter detection**: the pack detects/loads the software (SaaS) adapter
   grep pattern: `product type|adapter|software adapter|SaaS adapter`

## Verification Command

```bash
grep -oE 'BUILD|PIVOT|KILL|pressure.?test|6 rounds|adversarial|challenge round|round [1-6]|real data|product type|adapter|software adapter' pressure-test-verdict-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 2
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "BUILD / PIVOT / KILL verdict" (the pack's specific terminal decision — a no-pack agent gives soft encouragement)
- ✅ "/pressure-test 6 adversarial rounds with real data search" (the pack's named adversarial protocol)
- ✅ "product-type adapter (software)" (the pack's adapter mechanism)
- ❌ "it's a good idea" (the soft default the pack explicitly replaces with adversarial diagnosis)
- ❌ "do market research" (generic — any agent suggests this without the 6-round structure)
- ❌ "freelancers" / "invoices" (from the input)
