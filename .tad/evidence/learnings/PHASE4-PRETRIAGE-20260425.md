# Phase 4 Pre-Triage Report — 2026-04-25

**Scope:** Verify Phase 4 plan against 4 source artifacts before drafting Phase 4 handoff.

**Sources read:**
1. `menu-snap/.tad/active/ideas/IDEA-20260419-cost-observability-tad-upgrade.md` (155 lines, status: captured)
2. `.tad/domains/ai-evaluation.yaml` (832 lines, version 1.0.0)
3. `.tad/domains/code-security.yaml` (head 100 + scope analysis)
4. `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md` (Phase Map status)

---

## 🔴 Finding 1: IDEA-20260419 explicitly defers P4.1 launch

**What I assumed:** P4.1 cost-observability pack is ready to formalize from menu-snap blueprint.

**What the idea says:**
- Scope is **larger** than my Epic captured: idea now covers **Cost Observability + LLM I/O Observability** as two sibling capabilities of one Domain Pack (added 2026-04-19 scope expansion).
- LLM I/O Observability part has a **separate Epic in menu-snap** (`EPIC-20260419-llm-observability-foundation`, 5 phases, **not yet started**).
- Idea explicitly says: **"NOT before Menu Tales cost discipline has matured — we need real usage data from the playbook for 4-8 weeks"** + revised: **"probably 2-3 months before Pack abstraction is worth doing"**.
- Idea's reasoning: "Early abstraction = abstracting on theory, not practice. Wait."

**Implication for my Epic:**
Starting P4.1 now (April 25, idea was filed April 19) would be:
- Premature by idea's own design timing (only 6 days of usage data, not 4-8 weeks)
- Missing the LLM I/O Observability sibling capability (menu-snap Epic Phase 1-3 not done)
- Violating the idea's explicit deferral

**Decision required:** Should P4.1 in this Epic be:
- A. Scaffold only (pack name + capability list + quality_criteria draft, not implemented)
- B. Deferred entirely to Phase 4.5 / future Epic
- C. Renamed/reshaped to "cost-observability + LLM I/O observability" combo, but still deferred
- D. Proceed against idea's advice (NOT recommended)

---

## 🔴 Finding 2: P4.2 agent-runtime-security overlaps with Security Chain Phase 2

**What I assumed:** P4.2 is a new pack; existing security packs don't cover agent runtime.

**What I found:**
- `code-security.yaml` v1.0.0 explicitly says scope:
  - Covers: SAST, DAST, secrets, IaC linting (find vulnerabilities in YOUR code)
  - **Does NOT cover: runtime WAF, RASP, CSPM** — this is the runtime security gap
- Security Chain Epic Phase Map:
  - ✅ Phase 0: research (commit e2c325a)
  - ✅ Phase 1: supply-chain + code-security (commit 39e8017)
  - **⬚ Phase 2: Specialized Packs: ai-security + compliance** ← matches our P4.2!
  - ⬚ Phase 3: Monitoring + TAD Integration
  - ⬚ Phase 4: E2E Validation

**The overlap:** Security Chain Phase 2's **ai-security pack** would naturally absorb my P4.2 agent-runtime-security content (my-openclaw's 13 entries on prompt-injection, SSRF via tool choice, terminal escape, systemd hardening, credential drift, phantom config).

**Implication:** Doing P4.2 in TAD Self-Upgrade Epic would either:
- Duplicate work that Security Chain Phase 2 was scoped to do, OR
- Force Security Chain Phase 2 to re-scope to "compliance only" (strange split)

**Decision required:** Should P4.2 be:
- A. **Activate Security Chain Phase 2 instead** — feed my-openclaw 13 entries into ai-security pack scope; remove P4.2 from this Epic
- B. Keep P4.2 in this Epic; tell Security Chain Phase 2 to skip ai-security
- C. Do both (duplicate, NOT recommended)

Recommendation: **A**. Security Chain Phase 2 is paused waiting for "real-project security audit first to validate Pack value" — feeding my-openclaw 13 entries IS that validation.

---

## 🟡 Finding 3: ai-evaluation pack already covers most of my P4.5 plan

**What I assumed:** P4.5 extends ai-evaluation with: determinismLevel metadata, mocks-hide-shape anti-pattern, self-enhancement (judge=optimizer) warning.

**What ai-evaluation.yaml v1.0.0 already has** (832 lines, 7 capabilities):
- `eval_framework_design`: covers capability + reliability + safety + efficiency dimensions
- `benchmark_testing`: 5+ scenarios, ≥3 runs, Pass@k + Pass^k, anti-pattern "只跑 1 次 — 非确定性系统需要多次运行才有信号" (related to determinismLevel)
- `ab_testing`: anti-pattern "样本量太小下结论 → ≥20 cases + ≥3 runs 才有信号"
- `regression_testing`: golden suite, P0 zero-tolerance regression
- `adversarial_testing`: 6-class taxonomy + OWASP mapping
- `automated_pipeline`: CI integration
- `human_eval_protocol`: 5-level anchored rubric, ≥2 raters, inter-rater agreement

**Analysis of my P4.5 plan vs existing pack:**

| P4.5 item | Already in pack? | Action |
|-----------|------------------|--------|
| `determinismLevel` metadata field | Implied via "≥3 runs variance check" but not as explicit metadata field | ✅ Add as new metadata convention |
| Mocks-hide-shape anti-pattern (menu-snap SDK cast) | NOT explicitly | ✅ Add as new anti-pattern |
| Self-enhancement (judge=optimizer) warning | NOT explicit | ✅ Add as anti-pattern in ab_testing |
| Cross-Model Prompt Optimization (P4.3 OPRO pattern reference) | NOT in ai-evaluation (lives in ai-prompt-engineering per P4.3) | Cross-link only |

**Implication:** P4.5 scope is **smaller than I planned** — 3 additions, not a major rewrite.

---

## 🟢 Finding 4: menu-snap cost-observability artifacts confirmed

`scripts/`:
- billing-snapshot.sh ✓
- cost-report.sh ✓
- spike-gemini-caching.ts ✓ (bonus — caching spike)
- use_gemini_v3.py ✓ (bonus — Python integration sample)

`.tad/project-knowledge/cost-observability.md`: 195 lines

If P4.1 proceeds (against idea's deferral advice), these are the canonical sources to extract from. But idea recommends waiting.

---

## 🟢 Finding 5: P4.3 / P4.4 / P4.6 / P4.7-P4.12 likely uncomplicated

These are extensions to existing packs (ai-prompt-engineering / ai-agent-architecture / web-deployment / web-backend / web-ui-design / ai-tool-integration / code-security) + README update + new positive capabilities from Round 2 harvest. Not yet pre-triaged but no obvious blockers.

---

## Recommendations

**Phase 4 launch options (ranked by my preference):**

### Option C (Recommended): Skip blocked items, proceed with rest

**Phase 4 (revised scope):**
- ⏭️ **P4.1 deferred** — wait per IDEA-20260419 (4-8 weeks usage + LLM I/O Foundation done = ~2-3 months). Mark as Phase 4.5 candidate.
- ⏭️ **P4.2 redirected** — activate Security Chain Phase 2 ai-security pack instead. Remove from this Epic.
- ✅ P4.3: ai-prompt-engineering extension (cross-section pollution + capability declaration + 15K char limit + OPRO from P4.3 dogfood) — **OPRO pattern was already documented in earlier Pivots**
- ✅ P4.4: ai-agent-architecture extension (4 positive capabilities: explicit anti-pattern lists / capability declaration / fail-closed toolset / bilingual blocklist + safety state persistence)
- ✅ P4.5: ai-evaluation extension (3 additions: determinismLevel + mocks-hide-shape + self-enhancement) — smaller scope than planned
- ✅ P4.6: README adjustments (cost-observability category label deferred, but frontend-design correction still applies)
- ✅ P4.7: ai-tool-integration extension (Parallel CLI Prefetch + Vision OOM placeholder)
- ✅ P4.8: code-security extension (safe_fetch 7-Layer SSRF reference impl — NOTE: doesn't conflict with Phase 2 ai-security since this is server-side code defense, not agent runtime)
- ✅ P4.9: web-deployment extension (Dashboard-only CLI-resolvable + Binary Verify Secrets via od -c)
- ✅ P4.10: web-backend extension (UUID-Scoped Pub/Sub)
- ✅ P4.11: web-ui-design / playground extension (Design Iteration ADR + Warm Palette)
- ✅ P4.12: Model Reads, Human Verifies pattern (target: ai-agent-architecture or ai-prompt-engineering)

**Phase 4 revised AC count: ~10 actual deliverables** (was 12). 

### Option B: Full Phase 4 重新规划 sub-phase

Phase 4a (prep) — finalize P4.1 / P4.2 scope decisions with user
Phase 4b (execute) — actual handoff per scope

More overhead, justified only if user wants to debate P4.1 deferral / P4.2 redirect choice.

### Option A: Proceed against findings (NOT recommended)

Run P4.1 prematurely + duplicate P4.2 work. Goes against:
- IDEA-20260419 explicit advice ("Early abstraction = abstracting on theory")
- Security Chain Phase 2 already-planned ai-security pack
- 2026-03-23 architecture entry "Measure Before Optimizing" (similar pattern)

---

## Decision Gate

User to choose: A / B / C above. If no answer needed (auto mode), proceed with Option C.

Phase 4 handoff scope (Option C) drafted in next step.
