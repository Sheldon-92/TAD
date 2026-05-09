# Menu Snap AI — Safety Design Report

> Agent: Menu Snap AI (菜品推荐 agent)
> Domain: Food recommendation with allergy safety
> Date: 2026-04-02
> Capability: `safety_design` from ai-agent-architecture Domain Pack

---

## Step 1: Risk Research (search_risks)

### 1.1 AI Agent Security Landscape (2025-2026)

**Prompt Injection** remains the #1 attack vector, appearing in 73% of production AI deployments in 2025, with attacks surging 340% in 2026. Indirect injection (80%+ of attacks) is more dangerous than direct injection — for a food agent, this means menu images or restaurant descriptions could contain embedded adversarial instructions.

Key incident: In June 2025, a crafted email to Microsoft 365 Copilot triggered data exfiltration through hidden instructions ingested during summarization (CVE-2025-32711, CVSS 9.3). This demonstrates how agents processing external content (like menu photos) are vulnerable to indirect injection.

**Memory Poisoning** is a new attack surface where injected "facts" persist across sessions. For Menu Snap AI, this could mean: a poisoned preference ("user loves peanuts") overriding a real allergy declaration — with potentially fatal consequences.

**AI Recommendation Poisoning** (documented by Microsoft Security, Feb 2026) shows how recommendation systems can be manipulated for profit. In the food domain, this could mean restaurants injecting hidden prompts into menus to bias recommendations.

Sources:
- [AI Agent Security in 2026 — Swarm Signal](https://swarmsignal.net/ai-agent-security-2026/)
- [OWASP LLM01:2025 Prompt Injection](https://genai.owasp.org/llmrisk/llm01-prompt-injection/)
- [Microsoft: AI Recommendation Poisoning](https://www.microsoft.com/en-us/security/blog/2026/02/10/ai-recommendation-poisoning/)
- [Lakera: Indirect Prompt Injection](https://www.lakera.ai/blog/indirect-prompt-injection)

### 1.2 Guardrails Frameworks

| Framework | Approach | Latency | Best For |
|-----------|----------|---------|----------|
| NeMo Guardrails (NVIDIA) | Colang DSL, 5 rail types (input/output/dialog/retrieval/execution) | 100-300ms | Complex multi-rail policies |
| Guardrails AI | RAIL schema validation + correction | 50-200ms | Structured output validation |
| Llama Guard | Classification model | ~100ms | Content safety classification |

For Menu Snap AI, a **layered approach** is recommended: NeMo-style input/output rails for safety, plus schema validation for structured allergen data.

Sources:
- [Galileo: 5 Best AI Guardrails Platforms](https://galileo.ai/blog/best-ai-guardrails-platforms)
- [PremAI: NeMo vs Guardrails AI vs Llama Guard](https://blog.premai.io/production-llm-guardrails-nemo-guardrails-ai-llama-guard-compared/)
- [Guardrails AI + NeMo Integration](https://guardrailsai.com/blog/nemoguardrails-integration)

### 1.3 Food/Allergy Domain Risks

The annual economic cost of food allergies in the US is $19-25 billion. Allergen contamination can cause anaphylaxis and death — this is an **irreversible health risk** that demands the highest safety tier.

Key findings from IAFP 2025 and food safety research:
- AI food safety models must be **auditable, explainable, and validated** under food compliance standards
- False negatives in allergen detection **risk public health** — near-perfect accuracy required
- No specific AI food recommendation liability cases found in 2025-2026 [UNVERIFIED — may exist but not indexed]

Sources:
- [Food Safety Magazine: AI Implications for Food Industry](https://www.food-safety.com/articles/10456-welcome-to-the-machine-ai-and-potential-implications-for-the-food-industry)
- [PMC: Food Allergen AI Detection](https://pmc.ncbi.nlm.nih.gov/articles/PMC11011628/)
- [New Food Magazine: AI at IAFP 2025](https://www.newfoodmagazine.com/news/253921/ai-in-food-safety-iafp-2025/)

---

## Step 2: Threat Model (analyze_threats)

### Three-Rail Threat Model for Menu Snap AI

#### 2.1 Input Rails — 输入安全

| Threat | Detection (Mechanical) | Detection (Cognitive) | Response |
|--------|----------------------|---------------------|----------|
| **Prompt injection via menu image** | OCR text pattern matching for known injection templates | LLM classifier on extracted text: "Is this a menu item or an instruction?" | Reject extracted text, use only structured menu data; alert |
| **Allergen data poisoning** | Schema validation: allergen field must be from controlled vocabulary (FDA Top 9) | LLM cross-check: "Does ingredient list match declared allergens?" | Block recommendation until human verification |
| **PII in user preferences** | Regex for email, phone, SSN patterns | N/A (mechanical sufficient) | Strip PII before storage; log access |
| **Malicious menu photo** | File type validation, image size limits, EXIF strip | Vision model adversarial detection | Reject non-food images |
| **Memory poisoning** | Preference change audit: flag if allergen profile changes | LLM review: "Is this preference change consistent with history?" | **BLOCK allergen removal without explicit re-confirmation** |

#### 2.2 Execution Rails — 执行安全

| Threat | Detection (Mechanical) | Detection (Cognitive) | Response |
|--------|----------------------|---------------------|----------|
| **Infinite recommendation loop** | Counter: max 3 retries per recommendation request | N/A | Circuit breaker → return "unable to recommend" |
| **Hallucinated menu items** | Schema check: recommended item must exist in extracted menu list | LLM verification: "Is [item] present in the original menu?" | Mark as [UNVERIFIED], do not recommend |
| **Incorrect nutritional info** | Cross-reference with USDA FoodData Central API | LLM plausibility check on calorie/macro ranges | Label as "estimated", add disclaimer |
| **Tool abuse (excessive API calls)** | Rate limiter: max 10 vision API calls per session, budget ceiling | N/A | Stop processing, return cached results |
| **Cross-contamination blind spot** | Rule: if restaurant type is in high-risk list (Asian, bakery, etc.) → add cross-contamination warning | LLM analysis of menu for shared-fryer/shared-kitchen indicators | Always append cross-contamination disclaimer for allergy users |

#### 2.3 Output Rails — 输出安全

| Threat | Detection (Mechanical) | Detection (Cognitive) | Response |
|--------|----------------------|---------------------|----------|
| **Recommending allergenic food** | **HARD BLOCK**: Post-filter checks every recommended item against user's allergen profile (ingredient-level, not just dish name) | LLM double-check: "Could [dish] contain [allergen] even if not listed?" (hidden ingredients like soy sauce in marinades) | **NEVER output. Architecture-level block. No override.** |
| **Misleading confidence** | Confidence score must be <0.8 if menu text was partially OCR'd | LLM self-assessment of uncertainty | Add confidence indicator; if low → "Please verify with restaurant staff" |
| **Data leakage (other users' preferences)** | Session isolation check; no cross-user data in response | N/A | Strip any leaked data; alert |
| **Unverified health claims** | Keyword filter: block "healthy", "diet-friendly", "safe for" without sourced evidence | LLM review for implicit health claims | Remove unsupported claims; add "consult healthcare provider" |

---

## Step 3: Human-in-the-Loop Boundaries (derive_boundaries)

### 3.1 Irreversibility Matrix

| Operation | Reversibility | Impact Scope | Policy |
|-----------|--------------|--------------|--------|
| Recommend a dish | Low (user might order & eat) | Individual health | **Auto with guardrails** (output rails) |
| Recommend dish to allergy user | **IRREVERSIBLE** (anaphylaxis) | Life-threatening | **Architecture-level block** — allergen filter is NOT a prompt, it's a code-level post-filter that cannot be bypassed |
| Save user preference | Reversible (can edit) | Individual | Auto |
| Modify allergen profile | **Semi-irreversible** (removing allergy = future risk) | Life-threatening | **Human confirmation required** — "You are removing Peanut from your allergy list. This means we will recommend peanut-containing dishes. Please type CONFIRM." |
| Share recommendation publicly | Semi-reversible (can delete, but cached) | Social/reputation | Human confirmation |
| Process menu from unknown source | N/A (information only) | System integrity | Auto with input rails |

### 3.2 Circuit Breaker Design

| Trigger Condition | State Transition | Action | Recovery |
|-------------------|-----------------|--------|----------|
| 3 consecutive OCR failures on same image | CLOSED → OPEN | Stop processing, return "Unable to read menu. Please try a clearer photo." | User submits new photo (auto-reset) |
| Allergen filter flags a recommended item | N/A (not a breaker — this is a **hard architectural block**) | Item silently removed from results; if ALL items filtered → "No safe options found. Please consult restaurant staff about allergen-free options." | N/A |
| 3 same-type errors in recommendation engine | CLOSED → OPEN | Stop session, save state, notify: "Recommendation engine experiencing issues." | Auto-retry after 60s (HALF-OPEN); if fails → remain OPEN, human ops review |
| API budget exceeded ($X per user/day) | CLOSED → OPEN | Return cached/pre-computed results only | Daily reset; or human approval for budget increase |
| Suspected prompt injection detected | CLOSED → OPEN | Reject input, log full context for security review | Human security review required to clear |

### 3.3 Degradation Strategy (Fail-Closed)

| Failure | Degradation | Rationale |
|---------|-------------|-----------|
| Allergen checking service down | **STOP all recommendations for allergy users** | Fail-closed. Cannot risk recommending allergenic food. Non-allergy users can still get recommendations. |
| Vision/OCR model unavailable | Return "Camera feature temporarily unavailable. Please browse the restaurant's online menu." | Fail-closed on vision; redirect to alternative |
| LLM recommendation engine down | Return menu items as plain list (no AI curation) | Degrade to "menu viewer" mode — still useful, zero AI risk |
| Preference database unavailable | Treat as new user (no preferences) | Fail-closed on personalization; safe default |
| All services down | Display: "Service temporarily unavailable. For allergy safety, please consult restaurant staff directly." | Full stop. Never guess. |

### 3.4 Audit Log Schema

```json
{
  "timestamp": "2026-04-02T14:30:00Z",
  "session_id": "uuid",
  "user_id": "uuid",
  "event_type": "recommendation_filtered | allergen_block | preference_change | circuit_breaker | injection_detected",
  "decision": "allow | deny | escalate",
  "context": {
    "input": "dish name or action attempted",
    "allergen_profile": ["peanut", "shellfish"],
    "matched_allergen": "peanut",
    "confidence": 0.95
  },
  "reason": "Dish 'Pad Thai' contains peanut (ingredient list match). User has peanut allergy.",
  "outcome": "Item removed from recommendation list. 4 of 5 items returned."
}
```

---

## Step 4: Architecture Diagrams

See `safety-architecture.d2` → compiled to `safety-architecture.svg`

---

## Step 5: Summary

### Critical Design Decisions

1. **Allergen safety is architecture-level, not prompt-level**: A code-level post-filter on EVERY output that checks ingredients against the user's allergen profile. This filter runs OUTSIDE the LLM — it cannot be prompt-injected away.

2. **Allergen profile changes require explicit human confirmation**: Removing an allergen from a user's profile is treated as a semi-irreversible action requiring typed confirmation.

3. **Fail-closed on safety service failure**: If the allergen checking pipeline is down, allergy users get NO recommendations (not degraded recommendations).

4. **Three-rail defense in depth**: Input rails catch poisoned data, execution rails prevent hallucinations, output rails enforce allergen safety — each layer operates independently.

5. **Memory poisoning protection**: Allergen profile is the highest-integrity data in the system. Changes are audited, confirmed, and never auto-inferred from conversation.
