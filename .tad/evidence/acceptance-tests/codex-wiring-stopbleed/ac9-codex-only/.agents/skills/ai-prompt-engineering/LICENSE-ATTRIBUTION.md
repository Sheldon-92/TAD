# Source Attribution

This pack was built using research from the following sources.
All content derived from external sources is used in accordance with the respective licenses.

---

## Research Sources

### promptfoo
- **URL**: https://github.com/promptfoo/promptfoo
- **License**: MIT
- **Usage**: CLI commands, YAML config structure, red teaming workflow referenced in Phase 2 and `references/ci-cd-templates.md`

### DSPy (Stanford NLP)
- **URL**: https://github.com/stanfordnlp/dspy
- **License**: MIT
- **Usage**: Optimizer descriptions (MIPROv2, COPRO, BootstrapFewShot) referenced in Phase 3 and `tools/selection-matrix.md`

### DeepEval
- **URL**: https://github.com/confident-ai/deepeval
- **License**: Apache 2.0
- **Usage**: Metric descriptions (G-Eval, hallucination, faithfulness) referenced in Phase 3 and `tools/selection-matrix.md`

### Anthropic Prompt Engineering Documentation
- **URL**: https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering
- **License**: © Anthropic, PBC — referenced for informational purposes
- **Usage**: Claude 4.x-specific rules in `references/claude.md`, anti-pattern identification

### Lakera Prompt Engineering Guide 2026
- **URL**: https://www.lakera.ai/blog/prompt-engineering-guide
- **License**: Referenced for informational purposes
- **Usage**: Adversarial testing patterns, prompt injection defense in Phase 1.6

### "When Better Prompts Hurt" (Research Paper)
- **Usage**: Format drift statistics (-10% JSON accuracy) and hallucination statistics (-13.3% citations) referenced in `references/failure-catalog.md` FM-1 and FM-2
- **Source**: Industry research — cited for data points, not verbatim content

### "Fix the Prompt is a Root Cause Fallacy"
- **Usage**: Failure taxonomy statistics (46% env, 25% config, ~29% prompt) referenced in `references/failure-catalog.md` FM-6 and Phase 3 Optimization escalation gate
- **Source**: Industry research — cited for data points, not verbatim content

### Braintrust 2026 Comparisons
- **URL**: https://www.braintrust.dev/docs
- **License**: Referenced for informational purposes
- **Usage**: Tool comparison context in `tools/selection-matrix.md` "Evaluated but Not Included" section

### Agenta Documentation
- **URL**: https://docs.agenta.ai
- **License**: Referenced for informational purposes
- **Usage**: Tool comparison context in `tools/selection-matrix.md` "Evaluated but Not Included" section

---

## License Statement

This pack (CAPABILITY.md, references/, tools/, checklists/, examples/, install.sh) is
released under Apache 2.0. See LICENSE file.

The research findings are synthesized and paraphrased. No copyrighted text has been
reproduced verbatim. All statistical claims are attributed to their source studies.
