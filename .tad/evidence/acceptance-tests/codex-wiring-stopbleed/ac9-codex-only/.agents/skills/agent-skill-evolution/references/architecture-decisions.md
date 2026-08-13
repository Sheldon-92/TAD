# Architecture Decisions (AD1–AD4)

> When to build a self-evolving agent — and when not to.

---

### AD1: Checkable Correctness Signal Required

Before building a self-evolving agent, verify you have a **checkable correctness signal** — a held-out evaluation set where you can programmatically score success vs failure on each item. Without this, the validation gate (VG1) cannot function, and self-modification becomes unguarded drift.

SkillOpt's 52-cell experiment matrix (6 benchmarks × 7 models + harness variants, all best/tied-best) works because every benchmark has a deterministic scoring function: exact-match for MATH/GSM8K, pass@1 for HumanEval/MBPP, structured-output parse for BigCodeBench/USACO.

**When to apply**: Before committing to self-evolution. If your agent's value is subjective (creative writing quality, UX polish, tone), consider LLM-as-judge scoring with calibrated inter-rater agreement (ICC > 0.80) as a proxy — but know the gate becomes softer.

**Counterexample**: A customer-support bot whose "success" is CSAT score available days later. The feedback loop is too slow for step-level gating; batch overnight consolidation (OC1) with weekly CSAT as the gate metric is a better fit.

> Source: SkillOpt paper §4.1; `trainer.py` `evaluate_gate()` — the gate is a pure function that compares candidate score to current/best score.

---

### AD2: Fixed vs Evolvable Instruction

Not every instruction should evolve. A self-evolving instruction needs four mechanisms to be safe: a validation gate (VG1), an edit budget (ES2), protected regions (ES3), and a staging mechanism (OC6). Instructions that lack any of these are better left fixed and manually maintained.

SkillOpt evidence on what happens without the gate: a model that started at 0.554 accuracy collapsed to 0.026 (−52.8 percentage points) over 5 nights of unvalidated self-modification. The four mechanisms are not optimizations — they are the safety contract.

**Decision heuristic**: If you can afford the four mechanisms AND you have a checkable signal (AD1), make the instruction evolvable. If any mechanism is missing, keep it fixed and evolve adjacent instructions instead.

> Source: SkillOpt paper §5 ablation; `docs/sleep/RESULTS.md` — night-over-night collapse trajectory.

---

### AD3: Online vs Offline Consolidation

Two paradigms for applying learned improvements:
- **Online** (during user sessions): lower latency to learn, but risky — a bad edit affects the next real user interaction immediately.
- **Offline** (overnight/batch): safer — learned edits go through a full validation gate on held-out data before going live. SkillOpt uses this exclusively.

SkillOpt's offline results: +23.5 pts on MATH (GPT-4o, ReflACT harness), +24.8 pts on HumanEval (GPT-4o-mini, AIDE), +19.1 pts on GSM8K (GPT-4o-mini, ReflACT). All with zero inference-time overhead — the improved skill is a static prompt at serving time.

The −52.8 collapse (AD2) happened with offline consolidation but **without** the validation gate. Online without a gate would be worse — the agent degrades while serving real users.

**Recommendation**: Default to offline + gate. Online learning is viable only when (a) the gate can run in < 2 seconds, (b) the held-out set is representative, and (c) a rollback mechanism exists.

> Source: SkillOpt paper Table 1 (improvement deltas); `trainer.py` — the entire training loop runs offline.

---

### AD4: Single-Model vs Dual-Model Architecture

SkillOpt uses a **dual-model** architecture: a strong "optimizer" model generates skill edits offline, and a (potentially weaker) "target" model executes the improved skill at inference time. This decouples optimization cost from serving cost.

Evidence: SkillOpt trained skills with GPT-4o as optimizer, then deployed them on GPT-4o-mini — the mini model's accuracy improved by the same margin as if the full model had optimized for itself. The optimizer sees the target's rollout transcripts (including errors), so it understands the target's failure modes even though it's a different model.

**When dual-model matters**: When serving cost is a constraint (GPT-4o-mini is ~30× cheaper than GPT-4o at $0.15/$4.50 per 1M input tokens, 2026 pricing). Train with the expensive model overnight, serve with the cheap one.

**When single-model is fine**: When the agent already runs on a strong model and you're optimizing its prompts in-place (e.g., Claude Opus improving its own SKILL.md). The optimization loop still runs offline with the same validation gate.

> Source: SkillOpt paper §4.2 (optimizer/target split); pricing from OpenAI API docs (2026).
