# PII De-Identification Rules
<!-- capability: pii_deidentification -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| PII1 | Two-engine architecture: AnalyzerEngine (detect) → AnonymizerEngine (transform) | deterministic |
| PII2 | Choose the anonymizer operator by downstream need — replace/redact/hash/mask/encrypt | deterministic |
| PII3 | Use Encrypt + DeanonymizerEngine for round-trip (anonymize before send, restore the response) | deterministic |
| PII4 | Prioritize recall over precision — use the F2 score (β=2), a false negative is a compliance breach | deterministic |
| PII5 | Run heavy transformer NER in an isolated GPU container via RemoteRecognizer to keep the loop fast | deterministic |

---

## Rules

### PII1: Presidio Two-Engine Architecture

Microsoft Presidio is an extensible, modular framework (NOT a static signature-based DLP) split into two engines:

1. **AnalyzerEngine** — detection. Uses regex matchers, check-summed patterns (Aadhaar, credit-card numbers), and NLP NER models (spaCy, Stanza, Hugging Face Transformers). Returns a `RecognizerResult` collection (PII coordinates).
2. **AnonymizerEngine** — transformation. Applies configurable operators to the detected coordinates.

```python
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine
from presidio_anonymizer.entities import OperatorConfig

analyzer = AnalyzerEngine()
results = analyzer.analyze(text=text, language="en")

anonymizer = AnonymizerEngine()
anonymized = anonymizer.anonymize(
    text=text,
    analyzer_results=results,
    operators={
        "EMAIL_ADDRESS": OperatorConfig("mask", {"masking_char": "*", "chars_to_mask": 10, "from_end": True}),
        "DEFAULT": OperatorConfig("replace", {"new_value": "<SECRET>"}),
    },
)
```

**Rule**: Any pipeline that sends unstructured enterprise text to an external LLM API must run Analyzer→Anonymizer first. Do not treat PII redaction as optional for "internal" agents.

> Source: findings.md "Microsoft Presidio: A Pluggable PII Architecture" + code sample [39, 40, 42, 44]

**determinismLevel**: deterministic.

### PII2: Choose the Anonymizer Operator by Downstream Need

| Operator | Behavior | When to use |
|----------|----------|-------------|
| **Replace** | Swaps the value for a placeholder / entity tag (`"Jane Doe"` → `"<PERSON>"`) | Default; human-readable redaction |
| **Redact** | Erases the detected character range entirely | When even the entity type must not appear |
| **Hash** | Deterministic SHA-256 / SHA-512 of the value | Preserve join keys across tables (consistent IDs) |
| **Mask** | Replaces N characters with a masking char (e.g. `*`) | Partial reveal (last 4 of a card) |
| **Encrypt** | Symmetric encryption with a key; reversible | Round-trip — see PII3 |
| **Faker synthetic** | Realistic fake identities preserving format | ML training data needing valid-looking values |
| **AHDS surrogate** | Medically-appropriate PHI placeholders (Azure Health Data Services) | Clinical data preserving utility |

**Rule**: Don't reach for Replace by default everywhere. If downstream systems join on the value, use Hash (deterministic). If you need ML-shaped data, use Faker. If you must restore the original, use Encrypt.

> Source: findings.md AnonymizerEngine operators list [39, 43, 44, 45]

**determinismLevel**: deterministic.

### PII3: Encrypt + DeanonymizerEngine for Round-Trip

The **Encrypt** operator replaces PII with a symmetrically-encrypted string that the **DeanonymizerEngine** can reverse.

**Rule**: When the workflow must anonymize before sending to an external model AND restore real values in the model's response, use Encrypt (not Replace/Redact — those are lossy and irreversible). This is the only operator pairing that gives anonymize-out / decrypt-back.

> Source: findings.md Encrypt operator + DeanonymizerEngine [40, 43, 44]

**determinismLevel**: deterministic.

### PII4: Prioritize Recall — Use the F2 Score (β=2)

Detection/redaction performance is evaluated with precision, recall, and the F_β score:

- Precision = TP / (TP + FP)
- Recall = TP / (TP + FN)
- F_β = (1+β²) · (Precision·Recall) / (β²·Precision + Recall)

Because missing a sensitive entity is a compliance/regulatory risk, the security model **prioritizes recall over precision** and uses the **F2 score (β=2)**, weighting recall twice as heavily as precision to minimize false negatives.

**Rule**: Do not tune a PII detector on F1 (which weights precision and recall equally). For safety-critical redaction, optimize and report F2 (β=2). A missed entity (false negative) is worse than an over-redaction (false positive).

> Source: findings.md "Scale Integrations and Statistical Scoring" — F_β / F2 (β=2) [46]

**determinismLevel**: deterministic.

### PII5: Isolate Heavy NER via RemoteRecognizer

Transformer NER models are slow. Presidio supports running them in an isolated, GPU-accelerated container via a `RemoteRecognizer`, keeping the main analysis loop fast and stable. At enterprise scale, Presidio integrates into PySpark UDFs to de-identify multi-terabyte data lakes in parallel.

**Rule**: Don't run heavy transformer NER inline in the latency-critical path. Offload to a `RemoteRecognizer` (GPU container). For batch/data-lake de-identification, wrap Presidio in PySpark UDFs for horizontal scale.

> Source: findings.md RemoteRecognizer / GPU isolation [29, 42]; PySpark UDF scaling [45]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Skipping redaction for "internal" agents**: sending raw names/emails/cards to any external model is a breach.
- **Tuning on F1**: equal precision/recall weighting under-protects against false negatives; use F2.
- **Lossy operator when you need restore**: Replace/Redact cannot round-trip; only Encrypt + DeanonymizerEngine can.
- **Inline transformer NER**: blocks the latency budget — offload to RemoteRecognizer.
- **Hashing when you need joins but using Replace**: Replace breaks referential joins; Hash is deterministic and preserves them.
