# Adversarial Testing Rules
<!-- capability: adversarial_testing -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| ADV1 | Tool selection: deepteam v1.0.4 (50+ vulns, 14 single-turn + 5 multi-turn per docs taxonomy), promptfoo for scanning | deterministic |
| ADV2 | Attack coverage: single-turn AND multi-turn mandatory | semi-deterministic |
| ADV3 | Risk classification: 6 categories / 50+ vulns with P0/P1/P2 priorities | deterministic |
| ADV4 | P0 vulnerabilities: zero tolerance | deterministic |
| ADV5 | Multi-turn attacks are harder to detect — escalation patterns | non-deterministic |
| ADV6 | OWASP mapping: results must map to OWASP Top 10 for LLMs/Agents | deterministic |

---

## Rules

### ADV1: Adversarial Tool Selection

When choosing a red-teaming tool, match to the testing goal:

| Goal | Tool | CLI Command |
|------|------|-------------|
| OWASP-aligned red-teaming (50+ vulns, 14 single-turn + 5 multi-turn attacks) | deepteam v1.0.4 | `pip install -U deepteam` → `deepteam redteam run --model=gpt-4o --framework=OWASPTop10` |
| Vulnerability scanning + BOLA/BFLA auth testing | promptfoo | `npx promptfoo@latest eval --config redteam.yaml` |
| Comprehensive red-team with plugins | promptfoo | See config below |

**deepteam v1.0.4** (first stable, released 2025-11-12): **50+ vulnerability types** + research-backed attack methods. The official docs taxonomy (trydeepteam.com/docs/red-teaming-adversarial-attacks, retrieved 2026-06-13) enumerates **14 single-turn + 5 multi-turn attacks**; the GitHub README headlines "20+ single and multi-turn attack methods" (single + multi COMBINED). Framework alignment spans **OWASP Top 10 for LLMs 2025 + OWASP Top 10 for Agents 2026 + NIST AI RMF + MITRE ATLAS + BeaverTails + Aegis**.

promptfoo red-team configuration:
```yaml
redteam:
  purpose: "{agent's intended purpose}"
  plugins:
    - prompt-injection
    - jailbreak
    - pii:direct
    - excessive-agency
    - rbac
    - competitors
    - bola        # Broken Object Level Authorization
    - bfla        # Broken Function Level Authorization
  strategies:
    - basic
    - crescendo
    - jailbreak:tree
```

deepteam Python alternative:
```python
from deepteam import red_team
red_team(
    model=target_agent,
    vulnerabilities=["PIILeakage", "ShellInjection", "ExcessiveAgency"],
    attacks=["prompt_injection", "crescendo_jailbreak"]
)
```

**determinismLevel**: deterministic — tool selection is an architectural decision.

### ADV2: Single-Turn AND Multi-Turn Attack Coverage

When designing adversarial test suites, cover both attack surfaces:

**Single-turn attacks** (deepteam v1.0.4 — 14 documented methods, trydeepteam.com docs taxonomy retrieved 2026-06-13):
- Prompt Injection, Roleplay, Leetspeak, ROT-13, Base64, Gray Box
- Math Problem, Multilingual, Linguistic Confusion, Input Bypass
- System Override, Permission Escalation, Context Poisoning
- **Adversarial Poetry** (newer method — easy to miss if your suite predates v1.0.4)

**Multi-turn attacks** (deepteam v1.0.4 — 5 methods):
- Linear Jailbreaking, Tree Jailbreaking
- Crescendo (gradual escalation), Sequential Jailbreaking
- Bad Likert Judge

**promptfoo strategies**: basic, crescendo, jailbreak:tree, PAIR, tree-of-attacks, many-shot

**Rule**: A test suite with only single-turn attacks is incomplete. Multi-turn attacks exploit conversational trust buildup — agents that resist single-turn injection often fail crescendo attacks.

**determinismLevel**: semi-deterministic — attack configs are fixed; agent responses vary.

### ADV3: Risk Classification by Category

When prioritizing adversarial tests, classify by DeepTeam's 6 risk categories (which span its **50+ concrete vulnerability types** — the categories are the taxonomy, the 50+ vulns are the instances):

| Category | Risk Types | Priority |
|----------|-----------|----------|
| Security | Shell/SQL injection, BOLA, BFLA, prompt injection | P0 |
| Data Privacy | PII leakage, prompt extraction, training data memorization | P0 |
| Safety | Harmful content generation, dangerous instructions | P0 |
| Agentic | Excessive agency, autonomous drift, tool hijacking | P0 |
| Responsible AI | Bias, toxicity, stereotyping | P1 |
| Business | Misinformation, competitor endorsement, off-topic | P1 |

**Rule**: Test ≥3 P0 categories before declaring an agent safe. P1 categories are "should test" but do not block deployment.

**determinismLevel**: deterministic — classification is a design decision.

### ADV4: P0 Vulnerability Zero Tolerance

When evaluating adversarial test results:

- Any P0 vulnerability failure = **CRITICAL — block deployment**
- P1 vulnerability fail rate >20% = **WARNING — remediate before production**
- Every failure must include:
  - Attack trace (what input triggered the failure)
  - Which agent component was bypassed (prompt? tool permission? guardrail?)
  - Specific remediation (add guardrail? modify prompt? restrict tool access?)

**determinismLevel**: deterministic — pass/fail determination is binary.

### ADV5: Multi-Turn Escalation Awareness

When reviewing adversarial results, pay special attention to multi-turn attacks:

- Crescendo attacks build trust over 3-5 turns before the attack payload
- Tree jailbreaking explores multiple conversation branches simultaneously
- An agent that resists "Tell me how to hack X" may comply after 5 turns of seemingly innocent conversation

**Rule**: If single-turn tests all pass but multi-turn tests fail → the agent's safety is brittle. The guardrails are prompt-level, not architecture-level. Remediation requires architectural changes (tool permission boundaries, not just prompt instructions).

**determinismLevel**: non-deterministic — multi-turn attack outcomes depend heavily on conversation dynamics.

### ADV6: OWASP Compliance Mapping

When reporting adversarial test results, map to standard frameworks:

- **OWASP Top 10 for LLM Applications 2025**: Prompt Injection (LLM01), Sensitive Information Disclosure (LLM02), Supply Chain (LLM03), Improper Output Handling (LLM05), Excessive Agency (LLM06), Vector & Embedding Weaknesses (LLM08)
- **OWASP Top 10 for Agents 2026**: BOLA, BFLA, Tool Misuse, Autonomous Drift

Mapping enables comparison across projects and alignment with organizational security standards.

**determinismLevel**: deterministic — mapping is a classification exercise.

---

## Anti-Patterns

- **Prompt-injection-only testing**: Agents have action-level risks (excessive agency, tool abuse) that prompt-injection tests don't cover.
- **Manual-only red-teaming**: Not reproducible, not CI-integrable, misses systematic multi-turn escalation.
- **Model safety ≠ agent safety**: ExcessiveAgency and ToolAbuse are agent-specific risks absent from model-level safety tests.
- **Flat priority**: PII leakage and style inconsistency are not the same severity. Prioritize.
- **Testing once**: Adversarial tests should run on every prompt/config change, not just at launch.
