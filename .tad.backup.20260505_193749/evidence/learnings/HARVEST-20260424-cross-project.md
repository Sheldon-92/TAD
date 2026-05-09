# Cross-Project Learning Harvest — 2026-04-24

**Trigger:** User asked Alex to scan experience from downstream projects using latest TAD and feed learnings back to upgrade TAD itself.

**Scope:** 4 high-activity consumer projects + TAD main baseline
**Method:** 4 parallel `general-purpose` subagents (Explore agents failed due to sandbox restrictions — logged as recovery pattern)
**Output scale:** ~300KB knowledge entries + 17 sampled handoffs read by subagents
**Follow-on:** Epic `EPIC-20260424-tad-self-upgrade-from-consumers.md` created to track all 20+ proposals.

---

## Project Inventory Scanned

| Project | Traces | Knowledge files | Knowledge volume | Archive handoffs | Last activity |
|---------|--------|----------------|------------------|------------------|---------------|
| menu-snap | 285 lines | 5 (arch/code-quality/**cost-observability**/testing/ux) | ~115 KB | 102 | Active |
| my-openclaw-agents | 91 lines | 6 (arch/code-quality/**security**/api-integration/testing/ux) | ~113 KB | 85 | Active |
| toy | 304 lines | 2 (arch/security) | ~84 KB | 27 (+3 active) | Very active |
| Next Guest | 75 lines | 2 (arch/frontend-design) | ~18 KB | 17 (+4 active) | Active |
| TAD main (baseline) | 401 lines | 2 (arch/security) | ~63 KB | 96 | Active (framework dev) |

Lower-activity consumers skipped in deep read: O1 for builder, OpenClaw Hack, 合规ai, 下载md插件, 内存管理, 运动打卡小助手, ArtForge, Sober Creator.

---

## Subagent Report Summaries

### menu-snap
- **Unique category `cost-observability.md` (7 entries)** — candidate for promotion to Domain Pack (user already filed IDEA-20260419-cost-observability-tad-upgrade.md). 4-layer model: Collection → Attribution → Intelligence → Discipline. Ships `billing-snapshot.sh`, `cost-report.sh`, `gemini-logger.ts`.
- **Gate 4 staging smoke catches SDK shape bugs that 100% coverage + 4 reviewers miss** (architecture.md:42,55) — direct TAD Gate protocol upgrade candidate.
- **Vercel production alias doesn't auto-follow latest Ready deploy** (architecture.md:7) — Gate 4 verification integrity hole.
- **Slug consistency** (code-quality.md:9) — layer2-audit false-negatives fired twice in 8 days because Alex's manifest slug diverged from filename regex.
- **Zombie Handoff detection** (code-quality.md:36) — retrospective completion pattern proposed.
- **"Dashboard-only" ops often CLI-resolvable** (architecture.md:165) — Supabase, Vercel were both CLI-doable.
- **Aspirational Socratic answers** (code-quality.md:15) — user's Socratic answers describe conceptual capability, not actual code path.
- **Determinism-aware testing** — Gemini temp=0 only same-session deterministic; snapshot strategy must match determinism level.

### my-openclaw-agents
- **13 security entries (~richest in sample)** covering runtime agent self-defense (TAD main has none of these):
  - Prompt-injection filter eating system files (SOUL.md blocked by Hermes filter)
  - `platform_toolsets` missing key → silently enables all tools (SSRF bypass)
  - Terminal subprocess bypass of prompt-level MUST NEVER (Qwen: `python3 -c "from skill import main"`)
  - Systemd per-agent-role hardening gaps
  - rsync REDACTED credential clobber
  - Bilingual blocklist as minimum
  - Phantom config (zod warning-only)
- **AGENTS.md bloat → routing drift at 15-20K chars** — direct implication for TAD SKILL.md sizing
- **Agent LLM function-name / path / schema hallucination** — fixed by explicit "does NOT exist" anti-pattern lists
- **LLM self-awareness gap** — text-model says "I cannot see images" even when vision pipeline exists; system prompt must declare capabilities
- **20 code-quality entries** mostly genuine bash/CLI patterns (not bug residue)
- **Independent verification of TAD 2026-04-15 Epic 1 cancellation**: "prompt-level MUST NEVER" insufficient against terminal-subprocess escape

### toy
- **Project character:** Physical hardware (ESP32-S3 + Waveshare boards) running two parallel AI products:
  - PianoCoach (piano note + LLM coaching)
  - Loop ("Connection Rabbit" for loneliness, NYC exhibition Apr 30)
- **Production code not git-tracked** (2026-04-22) — 38 files weeks of work nearly shipped untracked. **Direct Gate 3 check candidate.**
- **Qwen Cloud Prompt Tuning (OPRO loop)** — Claude Sonnet 4.5 as judge + optimizer, Qwen Plus as generator, 15 Solo + 11 Dyadic rubric. **Key failure mode:** Alex cited 2026-04-07 knowledge claiming `model = qwen-plus`; actual `loop_voice/config.py` had `QWEN_OMNI_MODEL = "qwen3-omni-flash"` since Z1 migration M1-M5 (Apr 11-14). **OPRO scores reflected Qwen Plus not the voice-optimized model users actually talk to.** User caught at Gate 4. Reval on Omni revealed 3 Omni-specific regressions: sparse reflection ("嗯."), voice filler bias ("嗯/啊/呢"), turn-1 rule violation.
- **Cross-section example pollution in unified system prompts** — Solo-section phrases ("又见面了", "回来了。") bled into Dyadic scenarios on qwen3-omni-flash.
- **Ghost Task Pattern** — 3 handoffs in 4 days where Alex cited stale state, caught by Blake/code-reviewer.
- **Partial Gate 4 Acceptance Pattern** — when Phase N blocked on human/hardware/external, split Phase N+1 into 2a (scaffold) + 2b (blocked segment).
- **Gate 4 Evidence Slug Convention Mismatch** — `loop-mpr121-da7280` vs `-integration` caused layer2-audit false-negative.
- **Alex Pre-Handoff Review + Blake Gate 3 Layer 2 = 20 unique P0, zero overlap** — empirical validation that two review rounds find different P0 classes.
- **Self-enhancement risk acknowledged-not-mitigated** — OPRO used Claude Sonnet as both judge and optimizer (documented bias), but TAD has no mechanism to review experimental methodology.
- **Bilingual blocklist minimum** (security.md:2026-04-11) — language-detection-gated scanners bypassed by code-switching ("I 不想活").
- **Safety state persistence outside process memory** — crisis cooldown in process memory = `kill -9` re-engages harmed users.

### Next Guest
- **Project character:** Small Next.js + Supabase operational app (Harlem United pilot). Sub-day "express" mini-handoffs dominate. Live-iPhone-testing driven iteration.
- **Express handoff as first-class path** — `Type: Express Bugfix (skip Socratic, skip epic review)` annotated explicitly in 3 of 4 active handoffs. Users are voting with their feet.
- **Supersedes chain not auto-archived** — 3 handoffs on 2026-04-14 (sticky → collapse → flip-divider), 10+ days in active/.
- **frontend-design.md is NOT under-used when triggered** — 4 entries all on 2026-04-10 (v1 design build moment, playground session). Event-triggered not continuous.
- **Supabase Realtime channel uniqueness** — StrictMode double-mount requires UUID-scoped channel names.
- **Backup tables inherit anon exposure** — `CREATE TABLE AS SELECT` re-exposes PII via PostgREST + anon key.
- **echo pipe to `vercel env add` injects trailing newline** — WebSocket URL had `\n`, REST stripped it, Realtime didn't. Use `od -c` to binary-verify secrets.
- **Compliance acceptance ≥1 business day before external meeting** — Gate 4 as legitimate spec-revision checkpoint.
- **70% capture rate is healthy** — 12 entries / 17 handoffs. Trivial CSS/copy handoffs legitimately skip Knowledge Assessment.

---

## Cross-Project Pattern Matrix (signals hitting 2+ projects)

| # | Pattern | Projects | Implication |
|---|---------|----------|-------------|
| P-1 | Mocks/prompt-only guards ≠ enforcement | menu-snap, my-openclaw, toy | Invocation-chokepoint mechanical checks beat text rules; but targeted, not global |
| P-2 | Handoff lifecycle drift (4 modes: Supersedes/Ghost/Zombie/Slug) | All 4 | `/tad-maintain` must evolve from cleanup → drift detector |
| P-3 | Gate 4 does technical, not just business | menu-snap, toy | TAD v2.0 Gate 3/4 split partially collapsed in practice |
| P-4 | Express handoff as formal path | Next Guest, my-openclaw, toy (Partial Gate 4) | Users annotating their way around 5-round Socratic for trivial work |
| P-5 | LLM drift patterns (routing, determinism, cross-section pollution) | menu-snap, my-openclaw, toy | ai-prompt-engineering pack needs expansion |
| P-6 | Silent failure class | menu-snap, my-openclaw, toy | Fail-closed defaults + schema linter |

### Handoff lifecycle drift — 4 types observed

| Drift type | Example | TAD coverage |
|-----------|---------|--------------|
| Supersedes chain | Next Guest 3 handoffs same-day on sticky→collapse→flip | None |
| Ghost Task | toy 3 housekeeping handoffs citing stale repo state | None |
| Zombie Handoff | menu-snap: code committed but active/ not cleared | Partial (step0_git_check prevents new but not existing) |
| Slug drift | toy: `loop-mpr121-da7280` vs `-integration` → layer2-audit FN | layer2-audit.sh shipped 2026-04-15, hit bug 2x in 8 days |

---

## TAD Original-Assumption Critique

9 foundational assumptions evaluated against 4-project evidence:

| # | Assumption | Verdict | Evidence |
|---|-----------|---------|----------|
| A | Alex writes handoff; reading project-knowledge is enough | **REFUTED** | toy OPRO: knowledge was stale (Apr 7 → Apr 14 code change), no staleness detection |
| B | All tasks fit requirements → design → implementation | **REFUTED** | toy OPRO/prompt-tuning doesn't fit; experimental loops need different gates |
| C | Alex designs, Blake implements, Terminal isolation is sacred | **FUZZY** | Blake reverse-teaches Alex (menu-snap 3-Session pacing, toy Phase 2a/2b, my-openclaw agent-bloat insight) |
| D | Gate 4 = business acceptance, technical is in Gate 3 | **REFUTED IN PRACTICE** | All 4 projects: Gate 4 catches technical (staging smoke, git-tracked, deploy alias, Qwen model mismatch) |
| E | Handoff is Blake's only info source | **PARTIAL** | Blake cross-reads knowledge + git + prior handoffs; current template has no "read these prior artifacts" section |
| F | Socratic Inquiry 3-5 rounds ensures requirement quality | **PARTIAL** | menu-snap uses heavily and well; Next Guest skips for trivial; toy OPRO: Socratic answered correctly on stale premise |
| G | Expert Review ≥2 must stay | **CONFIRMED** | toy 20 unique P0 zero overlap — but with known systemic blind spot (SDK shape needs staging smoke, not review) |
| H | Domain Pack categorization covers all task types | **REFUTED** | cost-observability, agent-runtime-security, experiment-design all uncovered by 21 existing packs |
| I | Mechanical enforcement vs soft reminder = binary | **NUANCED** | 2026-04-15 cancellation correct for behavior gates; state-consistency checks are different threat model |
| J | 3-layer doc stack (PROJECT_CONTEXT / NEXT / ROADMAP) is sufficient | **CONFIRMED** | menu-snap, toy use well |

---

## Data Capture Gaps (what TAD needs to collect but doesn't)

1. **Alex proposal → reality delta**: no structured record of "Alex said X in handoff, Gate 4 proved X is Y". Currently stored as prose in knowledge entries.
2. **Knowledge freshness / TTL**: no `grounded_in` field linking entries to code/config; no staleness detection.
3. **Experimental/research tasks**: no `*experiment` mode, no experiment-design gates.
4. **AskUserQuestion history**: user choices vs Alex recommendations never logged; no drift detection on Alex judgment quality.
5. **Cancelled handoffs**: silently archived; abandonment reasons and pivots lost.

---

## Meta Findings

**From this session's dogfooding:**

- **Explore subagent has sandbox restrictions** (no cross-directory reads, no Bash). **Switch to `general-purpose` for any cross-project scanning.** Update Alex SKILL or docs.
- **userprompt-domain-router.sh triggers on task-notification events** (observed in this session: a subagent completion notification mentioning Vercel matched web-deployment 2/14 — false positive). Hook should filter to user events only; threshold ≥3.
- **Project diversity > project volume for cross-learning**: toy (22 handoffs) produced the most unique category insights (bilingual safety, fail-closed safety, hardware bringup) vs menu-snap (102 handoffs) which has volume but less unique. Diversity matters more than activity count.

---

## Positive Patterns Catalog (Round 2 — re-scan 2026-04-24)

User pointed out that Round 1 harvest defaulted to anti-pattern extraction, missing reusable **positive** engineering patterns. Re-scanned the same 4 subagent reports with a success-pattern lens and surfaced 23 additional patterns. No new subagent runs — same source data, different extraction filter.

### Framework-level positive patterns (TAD SKILL / Gate / Protocol)

| # | Pattern | Source | Epic disposition |
|---|---------|--------|-----------------|
| F1 | Dual-Gate Review Non-Overlap (Alex pre-handoff + Blake Gate 3 Layer 2 = 20 unique P0, zero overlap) | toy arch.md 2026-04-22 | Positive evidence added to P6.1 (refutes "compress to single round" proposals) |
| F2 | Staging Smoke as Gate 4 Prerequisite for external-SDK tasks | menu-snap arch.md:42 | Positive evidence added to P6.2 (Gate 3/4 split redesign) |
| F3 | Partial Gate 4 Acceptance Pattern (compliance / external-blocker accepts partial with roadmap) | toy arch.md 2026-04-23 + Next Guest compliance lesson | New P6.8 |
| F4 | Phase N+1a/N+1b Split for user-coordinated blockers | toy 2026-04-24 + Loop M9 model | Confirmed as positive methodology (existing P6.5, description clarified) |
| F5 | Expert Review Audit Trail 4-column table (reviewer / issue / resolution-section / status) | toy emergent pattern across handoffs | Upgraded from Icebox Z.2 → new P1.5 (mechanical template change) |
| F6 | Per-Handoff Trace Subdir Convention (substrate for smoke-alarm audits) | toy emergent | Upgraded from Icebox Z.3 → new P5.4 (fits Phase 5 infrastructure) |
| F7 | "Model Reads, Human Verifies" decomposed filtering (model returns all + classification, human checks boxes — eliminates silent-drop class) | Next Guest arch.md:31 | New P4.12 (positive capability for ai-prompt-engineering + ai-agent-architecture) |

### Domain Pack positive patterns

| # | Pattern | Source | Epic disposition |
|---|---------|--------|-----------------|
| DP1 | 4-Layer Cost Observability Model (Collection → Attribution → Intelligence → Discipline) | menu-snap cost-observability.md | Already core of P4.1 (confirmed centrality) |
| DP2 | Monthly MTD Audit Playbook (15-min discipline ritual) | menu-snap | P4.1 — ensure ritual format preserved in pack |
| DP3 | "Dashboard-Only" Ops CLI-Resolvable pattern (default assumption: SaaS "dashboard only" usually CLI-doable via REST/psql) | menu-snap arch.md:165 | New P4.9 (extend web-deployment pack) |
| DP4 | Binary Verify Secrets via `od -c` (defends shell-pipe trailing-newline injection) | Next Guest arch.md:66 | Bundled with P4.9 |
| DP5 | UUID-Scoped Pub/Sub Channel Names (StrictMode + topic-sharing defense for any pub/sub client) | Next Guest arch.md:9 | New P4.10 (extend web-backend pack) |
| DP6 | safe_fetch 7-Layer SSRF Defense Architecture (scheme → DNS → pin → redirect → body) | my-openclaw security entries | New P4.8 (extend code-security pack as reference implementation) |
| DP7 | Parallel CLI Prefetch (background subshells + wait + per-agent tmp = 58% speedup) | my-openclaw code-quality.md | New P4.7 (extend ai-tool-integration pack) |
| DP8 | Claude Vision OOM Prevention via text placeholder (never base64 in conversation history) | my-openclaw code-quality.md | Bundled with P4.7 |
| DP9 | Explicit Anti-Pattern Lists in System Prompt ("does NOT exist: ~wrong~") counters LLM function/path/schema hallucination | my-openclaw code-quality.md × 3 entries | Added to P4.4 extended scope |
| DP10 | Capability Declaration in System Prompt (enumerate system capabilities to prevent LLM self-awareness gap) | my-openclaw code-quality.md | Added to P4.4 extended scope |
| DP11 | Fast-Path Safety Layering (performance-tiered safety: cheap fast path + expensive thorough path in parallel, short-circuit on cheap hit) | toy security.md | Added to P4.4 extended scope |
| DP12 | Bilingual Blocklist as Minimum (language-detection-gated scanners bypassed by code-switching) | toy security.md 2026-04-11 | Already listed in P4.4 |
| DP13 | Model Reads, Human Verifies Pattern (decompose filtering) | Next Guest arch.md:31 | Same as F7 above |
| DP14 | Cross-Model Prompt Optimization (OPRO with LLM-as-Judge + LLM-as-Optimizer) | toy HANDOFF/COMPLETION-20260421-prompt-tuning-design | Already added to P4.3 (this morning) |
| DP15 | Design Iteration as ADR (playground output captures design decisions as ADR format — positioning + palette + reference images + iteration log) | Next Guest frontend-design.md 2026-04-10 × 4 entries | New P4.11 (extend web-ui-design pack / playground docs) |
| DP16 | Warm Palette Learning rule (warm ≠ visible earth tones — design interpretation heuristic) | Next Guest frontend-design.md | Bundled with P4.11 |

### Meta-observation on Round 1 vs Round 2

- Round 1 extraction ratio: ~6 positive items vs ~30+ anti-patterns/remediations (1 : 5)
- Round 2 added: 16 domain-pack positive patterns + 7 framework-level positive patterns
- Combined ratio: ~29 positive vs ~30 negative (roughly 1 : 1)
- **Implication for Alex behavior**: future `*evolve` / cross-project harvest should default to **paired extraction** (what went wrong + remediation AS WELL AS what worked + reusable asset). Note this in P5 evolve infrastructure or Alex SKILL.

---

## Follow-on

Full 20+ (Round 1) + 23 (Round 2) = 43+ proposals tabled into Epic: `.tad/active/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md`

This file (HARVEST-20260424) is the evidence reference for that Epic. Any Phase handoff should cite this file for provenance.
