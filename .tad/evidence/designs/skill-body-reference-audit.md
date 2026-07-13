# SKILL Body vs Reference Audit — Phase 1 Classification Table

**Auditor:** Blake
**Date:** 2026-06-09
**Epic:** EPIC-20260609-skill-body-reference-boundary (Phase 1/3)
**Re-audit:** 2026-07-12 — verdict: **0 CIRCULAR-RISK / 0 DISCIPLINE-LEAK** across the current 31 reference files (29 alex + 2 blake). The 3 must-body items (completion-protocol, execution-checklist, ralph-loop) confirmed still inlined in blake/SKILL.md body; their reference files remain deleted. Retired refs (dream/evolve/optimize/skillify) removed from inventory; distillation-loop-protocol.md + knowledge-maintain-protocol.md added (both reference-ok). Verifier extended with an alex section in `.tad/hooks/lib/skill-body-verify.sh`.
**Criterion:** Two-part test: (1) "If agent doesn't proactively read this, will it unknowingly **skip** a mandatory step?" (2) "If agent doesn't proactively read this, will it **execute** a step but **miss critical constraints/protection**?"

## Summary
- Total reference files in inventory (2026-07-12): 31 (29 alex + 2 blake)
- Must-body: 3 (all Blake — inlined into SKILL body in Phase 2; reference files deleted)
- Reference-ok: 31
- Partial-body: 0

**Key finding:** All 3 must-body files are Blake references with **circular trigger patterns** — the `load_when` stub refers to a step that the reference itself defines (e.g., "Read ralph-loop when entering Ralph Loop" but Ralph Loop IS defined in ralph-loop.md). Without the reference, Blake doesn't know the step exists. All 29 Alex references and 2 remaining Blake references have **non-circular triggers** — the agent knows the triggering event independently of the reference content.

---

## Alex References (29)

### accept-command.md
- **Classification:** reference-ok
- **Line count:** 253 lines
- **Trigger mechanism:** *accept command (explicit user invocation)
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (1)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered exclusively by the *accept command, which the user types explicitly. The SKILL body stub instructs "When *accept is invoked, Read the reference." Agent knows it is archiving a handoff (deliberate action). Without reading, the agent wouldn't know the full step sequence (Epic update, pair testing assessment, document sync), but this is a "how to execute" gap, not a "silently skip a mandatory process" gap. The agent would not unknowingly violate process — it would simply not know the *accept steps.
- **Key content summary:** Full *accept workflow: git check, archive handoff/completion, Epic update logic, PROJECT_CONTEXT update, pair testing assessment, document sync.

### acceptance-protocol.md
- **Classification:** reference-ok
- **Line count:** 387 lines
- **Trigger mechanism:** *review or *accept command (explicit user invocation)
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (13)
- **Contains forbidden_implementations:** yes (3 blocks: step7 KA, gate4_delta, step4c audit)
- **Rationale:** Triggered by *review/*accept — explicit commands the user invokes. Contains Gate 4 v2 business acceptance logic, AC line-by-line verification, evidence completeness check, Layer 2 audit smoke-alarm, Knowledge Assessment with skip_KA routing, and gate4_delta capture. Despite the 13 constraint keywords and 3 forbidden_implementations blocks, all constraints apply ONLY during the acceptance ceremony. The acceptance ceremony is a deliberate, user-initiated action with an explicit load_when stub. The forbidden_implementations protect specific mechanisms (KA override, gate4_delta population, Layer 2 audit) from mechanical enforcement drift — they are defense-in-depth within the triggered protocol, not always-needed execution discipline.
- **Key content summary:** Gate 4 v2 acceptance workflow: step-by-step AC verification, evidence completeness, Layer 2 audit (smoke-alarm), Knowledge Assessment (3-branch routing: skip/override/full), gate4_delta capture, violations list.

### adaptive-complexity-protocol.md
- **Classification:** reference-ok
- **Line count:** 225 lines
- **Trigger mechanism:** Workflow step — after intent router routes to *analyze
- **load_when assessment:** truly_conditional (despite body stub noting "MANDATORY")
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered as the first step of the *analyze flow (intent router → adaptive complexity → Socratic → design → handoff). The SKILL body contains the chain structure that indicates this step exists, and the stub instructs the agent to read when assessment begins. Without reading, the agent would know it should assess complexity (from the body's flow structure) but would default to a simplified assessment. The risk is that the agent skips the Full/Standard/Light/Skip choice and Epic assessment. However, the agent enters this through a conscious workflow step (routed to analyze), and "ask user about process depth" is intuitive enough that even a degraded execution would likely include some form of the question. The MANDATORY hint in the body stub further reduces the risk of skipping entirely.
- **Key content summary:** Complexity assessment (small/medium/large), process depth options (Full/Standard/Light/Skip), Epic assessment signals, Phase Detail Block sufficiency check, GitHub Registry check.

### bug-path-protocol.md
- **Classification:** reference-ok
- **Line count:** 87 lines
- **Trigger mechanism:** *bug command or intent router routes to bug mode
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by explicit *bug command. Contains the bug diagnosis → express mini-handoff workflow. Agent knows it's in bug mode and reads the reference. Without reading, agent would do some form of bug handling but without the structured mini-handoff template. No mandatory constraints would be silently violated.
- **Key content summary:** Bug diagnosis workflow: understand → diagnose → propose action → generate express mini-handoff → record.

### cancel-protocol.md
- **Classification:** reference-ok
- **Line count:** 121 lines
- **Trigger mechanism:** *cancel command (explicit user invocation only)
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (8)
- **Contains forbidden_implementations:** yes (2 blocks)
- **Rationale:** Triggered exclusively by user typing *cancel — the protocol explicitly states `NOT_via_alex_suggestion: true`, meaning Alex MUST NOT proactively recommend it. This NOT_via_alex_suggestion constraint is a Test 2 concern (mis-execution in OTHER contexts). However, the constraint is ALSO enforced by the protocols it restricts: adaptive_complexity_protocol defines its own option set (Full/Standard/Light/Skip — no *cancel), and intent_router_protocol's step3 options are built from signal detection (not arbitrary command suggestions). The cancel-protocol's enforcement is defense-in-depth, not the sole barrier. Without reading cancel-protocol, the agent wouldn't know about NOT_via_alex_suggestion, but it also wouldn't have a reason to suggest *cancel since *cancel isn't in the intent router's signal word detection.
- **Key content summary:** Cancel workflow with 4-reason taxonomy (pivoted/obsolete/superseded/scope-change), mandatory rationale, cancelled/ archive, Gate 4 skip by design, NEXT.md [c] marker.

### design-protocol.md
- **Classification:** reference-ok
- **Line count:** 284 lines
- **Trigger mechanism:** *design workflow (part of *analyze chain)
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (1)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered when the *design workflow is entered as part of the standard *analyze chain (after Socratic + research). Contains Domain Pack loading (step1_5/1_5b/1_5c), tournament option, architecture creation. Agent knows it's in design phase and the stub tells it to read. Without reading, the agent would create some design but miss pack loading and tournament options — a capability gap, not a mandatory violation.
- **Key content summary:** Design workflow: Domain Pack loading, Capability Pack loading with 3-tier lookup, tournament option (competitive design exploration), frontend detection, architecture creation, data flow diagrams.

### discuss-path-protocol.md
- **Classification:** reference-ok
- **Line count:** 140 lines
- **Trigger mechanism:** *discuss command or intent router routes to discuss mode
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *discuss. Contains discussion behavior rules, domain pack awareness, research notebook awareness, forbidden actions (no handoff creation). Agent knows it's in discuss mode. Without reading, agent might create a handoff during discussion (violating the forbidden list), but the SKILL body's command separation (discuss ≠ analyze) provides a natural barrier.
- **Key content summary:** Free-form discussion mode: consultant persona, domain pack + research notebook awareness, forbidden actions (no handoff/gate/code), soft checkpoint at 6+ exchanges, exit protocol with ROADMAP option.

### distillation-loop-protocol.md
- **Classification:** reference-ok (added 2026-07-12 re-audit)
- **Line count:** 95 lines
- **Trigger mechanism:** Gate 4 Knowledge Assessment execution (distillation_loop trigger defined in SKILL body)
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Non-circular: the distillation_loop trigger, blocking:false status, high_level_flow, AND the 3-layer note_blocking_taxonomy all live in the SKILL body — the reference only holds detailed execution steps, so skipping it degrades quality but cannot silently skip the KA step.

### experiment-path-protocol.md
- **Classification:** reference-ok
- **Line count:** 114 lines
- **Trigger mechanism:** *experiment command or task_type=experiment frontmatter
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (8)
- **Contains forbidden_implementations:** yes (1 block)
- **Rationale:** Triggered by explicit *experiment command. Contains critical AUGMENT-not-REPLACE semantics for Gate 3/4 (experiment checks are ADDITIONAL to standard checks, not replacements). The forbidden_implementations block prevents silently replacing Gate 3/4. Without reading, the agent in *experiment mode wouldn't know the 5 experiment-specific Gate 3 checks or 4 Gate 4 checks, but would still execute standard gates (which the SKILL body defines). The AUGMENT semantics ensure no regression — standard gates remain even without reading. Test 2 risk: agent might miss experiment-specific checks, but wouldn't weaken standard gates.
- **Key content summary:** Experiment path: auto-detection signals, domain pack auto-load (ai-evaluation), 5 Gate 3 augmentation checks, 4 Gate 4 augmentation checks, evidence manifest template, AUGMENT-not-REPLACE semantics.

### express-path-protocol.md
- **Classification:** reference-ok
- **Line count:** 89 lines
- **Trigger mechanism:** *express command (explicit user invocation only)
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (10)
- **Contains forbidden_implementations:** yes (1 block)
- **Rationale:** Triggered exclusively by user typing *express. Contains NOT_via_alex_suggestion constraint (AR-001 defense: Alex MUST NOT proactively recommend *express). This is a Test 2 concern — without reading, Alex might suggest *express in other contexts. However, the NOT_via_alex_suggestion defense is ALSO enforced in intent_router_protocol (step3: "*express MUST NOT appear as Option 1 Recommended even if signal-word detection favors it"). The express-path-protocol's constraint is one of three independent defenses (per principles.md "Path Layering: Three Defenses Against AR-001 Drift"). The slug convention for layer2-audit.sh detection is important but only relevant when *express is already in use. The scope constraint (≤5 files) and required_steps (expert review mandatory) are within the *express execution context.
- **Key content summary:** Express path: NOT_via_alex_suggestion (AR-001), scope constraint (≤5 files with override), required steps (expert review ≥1), skipped steps (Socratic, adaptive complexity, KA), slug convention for audit detection.

### handoff-creation-protocol.md
- **Classification:** reference-ok
- **Line count:** 850 lines
- **Trigger mechanism:** *handoff command or handoff_creation_protocol entry
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (50)
- **Contains forbidden_implementations:** yes (4 blocks: step1c grounding, LSP step0_graph, step1b frontmatter, principles protection)
- **Rationale:** This is the largest reference and contains the most constraint keywords (50). It includes critical steps: AC Conflict Matrix Self-Check (step0_5_conflict_matrix, BLOCKING), Context Refresh with knowledge matching (step0_5), Grounding Pass (step1c), LSP Impact Analysis, AC Auto-Generation (step1_ac_generation), Expert Review with selection rules (step2), Audit Trail (step4), and Blake message generation (step7). Despite the volume of constraints, the trigger IS explicit and deliberate — creating a handoff is the single most intentional action in Alex's workflow. The agent enters this after completing adaptive complexity → Socratic → research → design, meaning it has full context and knows exactly what it's doing. The SKILL body stub explicitly says "When *handoff is invoked or handoff_creation_protocol is entered, Read the reference and follow it verbatim." The 50 MUST keywords and 4 forbidden_implementations blocks are all step-level constraints WITHIN the handoff creation flow — they don't need to be always-loaded because handoff creation is never an unconscious action. The agent would degrade (simpler handoff, skip AC Conflict Matrix) without reading, but would not unknowingly violate process because the agent KNOWS it's creating a handoff and the stub tells it to read.
- **Key content summary:** Full handoff creation: AC Conflict Matrix, knowledge reload + matching, research asset check, deliverable classification, draft creation (template + frontmatter), AC auto-generation, Domain Pack injection, frontmatter validation, grounding pass (step1c), LSP provision + impact analysis, expert review selection + invocation, audit trail, AC dry-run, Blake message generation.

### idea-list-protocol.md
- **Classification:** reference-ok
- **Line count:** 48 lines
- **Trigger mechanism:** *idea-list command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *idea-list. Simple scan-and-display workflow. No constraints that could be silently violated.
- **Key content summary:** Browse ideas: scan .tad/active/ideas/, display table, status update actions.

### idea-path-protocol.md
- **Classification:** reference-ok
- **Line count:** 55 lines
- **Trigger mechanism:** *idea command or intent router routes to idea mode
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *idea. Lightweight capture workflow. No mandatory constraints.
- **Key content summary:** Idea capture: ask, structure, store to .tad/active/ideas/, cross-reference NEXT.md.

### idea-promote-protocol.md
- **Classification:** reference-ok
- **Line count:** 53 lines
- **Trigger mechanism:** *idea-promote command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *idea-promote. Simple promotion workflow: select idea → choose Epic or Handoff → update status → transition to *analyze. No mandatory constraints.
- **Key content summary:** Promote idea to Epic/Handoff: select, choose target, update status, transition to *analyze with idea context.

### intent-router-protocol.md
- **Classification:** reference-ok
- **Line count:** 271 lines
- **Trigger mechanism:** Ambiguous user input (not explicit *command, not idle)
- **load_when assessment:** truly_conditional (high frequency trigger, but agent knows it needs to route)
- **Contains MUST/MANDATORY/VIOLATION:** yes (3)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered when user input is ambiguous — a frequent event, but the agent knows it's routing (the user said something, agent needs to figure out intent). The SKILL body has the commands list and the flow structure, so even without reading, the agent would do SOME form of intent matching. The reference adds: idle detection (step1_5), signal word analysis (step2), *express-never-Recommended rule (step3), Pack Awareness Scan (step4_5), standby state definition, and path transition rules (allowed/forbidden). Test 2 concern: without reading, agent might recommend *express as Option 1 (violating AR-001 constraint). However, this constraint is ALSO enforced in express-path-protocol itself (NOT_via_alex_suggestion) — the three independent defenses (per principles.md "Path Layering") ensure the constraint survives even if one layer is unread. The forbidden path transitions (analyze→express/experiment) are defense-in-depth against mid-flight scope downgrade. Without reading, the agent would still route based on explicit commands (the SKILL body has the command list), and the degradation would be in AskUserQuestion refinement for ambiguous cases.
- **Key content summary:** Intent routing: idle detection, 7-mode signal detection, *express-never-Recommended (AR-001), user confirmation with 4-option strategy, Pack Awareness Scan, standby state definition, path transition matrix (allowed/forbidden).

### knowledge-maintain-protocol.md
- **Classification:** reference-ok (added 2026-07-12 re-audit)
- **Line count:** 110 lines
- **Trigger mechanism:** *knowledge-maintain command or distillation_loop step6 completion
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Non-circular: triggered by an explicit *knowledge-maintain command (user-typed) or a chained event from distillation_loop whose trigger lives in the SKILL body; blocking:false — skipping loses a maintenance pass, never a mandatory step.

### learn-path-protocol.md
- **Classification:** reference-ok
- **Line count:** 100 lines
- **Trigger mechanism:** *learn command or intent router routes to learn mode
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *learn. Socratic teaching mode. No constraints that could be silently violated.
- **Key content summary:** Socratic teaching: identify topic, assess understanding, teach via Q&A loop, optional quiz/flashcard generation, wrap up.

### publish-protocol.md
- **Classification:** reference-ok
- **Line count:** 140 lines
- **Trigger mechanism:** *publish command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (4)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *publish. Contains TAD-main-only guard (CRITICAL safety: prevents wrong-repo push), version consistency check, CHANGELOG check, release verification gate. All constraints are within *publish context. Without reading, agent wouldn't execute *publish at all.
- **Key content summary:** Publish workflow: TAD-main-only guard, mandatory runbook read, version consistency, CHANGELOG check, self-deriving release verification gate, confirm & execute (push+tag), post-publish.

### research-decision-protocol.md
- **Classification:** reference-ok
- **Line count:** 168 lines
- **Trigger mechanism:** Workflow step — after Socratic Inquiry completes
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (4)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered after Socratic Inquiry as part of the *analyze chain. Contains the "Cognitive Firewall" — research before designing, present options, human decides. The VIOLATION markers ("Designing without researching = VIOLATION") enforce the research-before-design principle. Without reading, the agent might skip research and go directly to design. However, the SKILL body's chain structure (Socratic → research → design) makes the agent aware that a research step exists. The stub instructs the agent to read when the protocol begins. The "research before design" concept is core TAD philosophy visible in the body's flow. Test 2 concern: without reading, agent might do some research but miss the research-gate logic (DEFAULT-SAFE decidability test, declined_research_domains dedup, notebook integration). These are refinement constraints within the research workflow, not always-needed execution discipline. The trigger is a conscious workflow step — the agent knows it should research before designing.
- **Key content summary:** Research Decision Protocol (Cognitive Firewall): decision point identification, research-gate (nudge only, never stops flow), landscape search (min 3 WebSearch), notebook integration, depth rules (simple/important), decision presentation with comparison tables, decision recording.

### research-plan-protocol.md
- **Classification:** reference-ok
- **Line count:** 727 lines
- **Trigger mechanism:** *research-plan command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (10)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *research-plan. Contains OBJECTIVES-driven research planning and execution. Prerequisite: OBJECTIVES.md must exist. All constraints apply within the *research-plan context.
- **Key content summary:** Research planning: read OBJECTIVES + REGISTRY, identify KR gaps, generate research plan with methods/outputs/timelines, user confirmation, batch execution (deep search, report generation, notebook-level research), OBJECTIVES progress update.

### research-review-protocol.md
- **Classification:** reference-ok
- **Line count:** 79 lines
- **Trigger mechanism:** *research-review command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *research-review. Research portfolio review and classification. No mandatory constraints.
- **Key content summary:** Research portfolio review: scan all notebooks, classify (strengthen/maintain/pivot/close) by goal alignment, OBJECTIVES alignment check, execute per category.

### socratic-inquiry-protocol.md
- **Classification:** reference-ok
- **Line count:** 171 lines
- **Trigger mechanism:** Workflow step — after adaptive_complexity assessment
- **load_when assessment:** truly_conditional (despite body stub noting "MANDATORY")
- **Contains MUST/MANDATORY/VIOLATION:** yes (4)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered as part of the *analyze chain (adaptive complexity → Socratic → research). The SKILL body already identifies Socratic Inquiry as a mandatory step ("写 handoff 之前必须用 AskUserQuestion" is the core concept). Without reading the reference, the agent knows it must do Socratic (the body says so) but wouldn't follow the TAD-specific structure (complexity-based dimension selection, specific question templates, format requirements). The VIOLATION markers ("不调用 AskUserQuestion 直接写 handoff = VIOLATION") reinforce the mandatory nature, but this mandatory nature is already established in the body. The reference adds the detailed execution (6 dimensions, complexity_detection rules, AskUserQuestion format) — these are "how to do Socratic well" rather than "whether to do Socratic." The agent would degrade to a simplified inquiry without reading, but would not skip it entirely because the body already mandates it.
- **Key content summary:** Socratic Inquiry: complexity detection (small/medium/large), 6 question dimensions (value, boundary, risk, acceptance, user scenarios, technical), AskUserQuestion format, follow-up discussion, final confirmation, output summary.

### status-panoramic-protocol.md
- **Classification:** reference-ok
- **Line count:** 75 lines
- **Trigger mechanism:** *status command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *status. Read-only panoramic view of project state. No mandatory constraints.
- **Key content summary:** Project status panoramic: scan ROADMAP, Epics, handoffs, ideas, research notebooks; display compact summary; return to standby.

### sync-add-protocol.md
- **Classification:** reference-ok
- **Line count:** 41 lines
- **Trigger mechanism:** *sync-add command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *sync-add. Simple registration workflow. No constraints.
- **Key content summary:** Register project for sync: validate path, detect CLAUDE.md strategy, add to sync-registry.yaml.

### sync-list-protocol.md
- **Classification:** reference-ok
- **Line count:** 15 lines
- **Trigger mechanism:** *sync-list command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *sync-list. Simple display command. No constraints.
- **Key content summary:** Display registered projects and sync status table.

### sync-protocol.md
- **Classification:** reference-ok
- **Line count:** 233 lines
- **Trigger mechanism:** *sync command
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (7)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by *sync. Contains TAD-main-only guard (CRITICAL safety: prevents wrong-source sync) and mandatory runbook read. All constraints apply within *sync context.
- **Key content summary:** Sync workflow: TAD-main-only guard, mandatory runbook read, load registry, verify projects, self-deriving structural verification, execute sync (framework dirs + skills + CLAUDE.md merge), post-flight verification.

### update-roadmap-protocol.md
- **Classification:** reference-ok
- **Line count:** 39 lines
- **Trigger mechanism:** *discuss exit → "Update ROADMAP" option
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (1)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered from *discuss exit protocol. Simple read-propose-confirm workflow. No constraints that could be silently violated.
- **Key content summary:** ROADMAP update: read current state, propose changes based on discussion, confirm with user via AskUserQuestion.

### workflow-completion-trigger.md
- **Classification:** reference-ok
- **Line count:** 29 lines
- **Trigger mechanism:** Workflow tool returns with agent_count >= 3
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** no (0)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered by a specific event (workflow completion with ≥3 agents). Marked as `blocking: false`. Contains a lightweight 3-question assessment (knowledge, skill, workflow improvement). Without reading, the agent would process workflow results without the assessment — missing a knowledge capture opportunity. But this is advisory, not mandatory. No process violation from skipping. The trigger is a specific, detectable event, and the stub tells the agent to read.
- **Key content summary:** Post-workflow 3-question assessment: knowledge discovery, reusable pattern detection (Skillify), workflow improvement, lightweight single AskUserQuestion.

### yolo-execution-protocol.md
- **Classification:** reference-ok
- **Line count:** 50 lines
- **Trigger mechanism:** step7_execution_mode user chose YOLO/semi-auto
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (3)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered when user explicitly chooses YOLO execution mode. Contains the hybrid Conductor + Workflow invocation pattern, evidence file naming, judgment rules. Without reading, the agent wouldn't know how to execute YOLO mode, but wouldn't silently violate process — it would either fail to execute or ask for guidance. The trigger is an explicit user choice.
- **Key content summary:** YOLO Epic execution: workflow invocation pattern (2 calls per phase: design then review+implement+impl_review), evidence file naming convention, judgment rules, epic completion + archive.

---

## Blake References (2 files + 3 must-body inlined)

> 2026-07-12 note: the 3 must-body files below were inlined into blake/SKILL.md body in Phase 2
> and their reference files deleted. Entries retained for classification rationale.
> `.tad/hooks/lib/skill-body-verify.sh` enforces both the body markers and the negative presence.

### completion-protocol.md
- **Classification:** must-body (locked — inlined into body, file deleted)
- **Line count:** 333 lines
- **Trigger mechanism:** none (always needed when Blake completes implementation)
- **load_when assessment:** always_needed — **CIRCULAR TRIGGER**: the stub says "When Blake completes implementation and writes completion report" but this reference DEFINES what the completion report IS and that Blake must write one. Without it, Blake doesn't know to create a completion report at all.
- **Contains MUST/MANDATORY/VIOLATION:** yes (40)
- **Contains forbidden_implementations:** yes (2 blocks)
- **Rationale:** **Codex dogfood evidence: Blake skipped completion report entirely.** Test 1: YES — without reading, Blake will unknowingly skip creating the completion report, session-state update, reflexion history section, gate3_verdict marker, and the structured Alex message. Test 2: YES — without reading, Blake would finish implementation and stop, never generating the deviation-detection document that Gate 3 and Gate 4 depend on. The load_when is a circular trigger: "read this when you complete implementation and write the completion report" — but the completion report IS defined by this reference. Without the reference, Blake doesn't know to write the report, so the trigger never fires. This is the canonical "execution discipline" failure pattern observed in Codex dogfood. The 40 MUST keywords and anti-rationalization markers ("Completion Report 只是文书工作" — NO, it forces explicit comparison of plan vs delivery) are rules Blake must follow during EVERY implementation, not just when a specific command is invoked.
- **Key content summary:** Full completion protocol: Ralph Loop steps 1-8, acceptance verification, git commit + evidence check + slug contract, Gate 3 v2, gate3_verdict frontmatter marker, reflexion history section, session-state update, structured Alex message with 人话版 + raw-metric citations.

### cross-model-invocation.md
- **Classification:** reference-ok
- **Line count:** 62 lines
- **Trigger mechanism:** On-demand when cross-model CLI (Codex/Gemini) is needed
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (5)
- **Contains forbidden_implementations:** yes (1 block, 5 items)
- **Rationale:** Triggered only when Blake needs to invoke Codex or Gemini CLI — an on-demand capability, not a mandatory step. Test 1: Without reading, Blake won't use cross-model tools at all, which is fine (not mandatory). Test 2: If Blake somehow attempts cross-model invocation without reading (unlikely — the user or handoff would need to request it), it might skip the preflight check or the "not a substitute for Layer 2" constraint. But this scenario requires an external trigger that would also prompt reading the reference. Standard Blake execution (implement → Layer 1 → Layer 2 → Gate 3 → complete) never requires cross-model tools.
- **Key content summary:** Cross-model CLI invocation: preflight checks (command -v), Codex review/implement scenarios, Gemini research scenario, error handling + timeout, forbidden (no auto-invoke, no substitute for Layer 2 reviewer, no auto-commit).

### execution-checklist.md
- **Classification:** must-body (locked — inlined into body, file deleted)
- **Line count:** 240 lines
- **Trigger mechanism:** none (always needed when Blake executes any handoff)
- **load_when assessment:** always_needed — **CIRCULAR TRIGGER**: the stub says "When Blake starts executing a handoff task (after reading handoff)" but this reference DEFINES the execution checklist Blake must follow. Without it, Blake doesn't know about task_type_branching, Layer 1 self-check requirements, reflexion step, Layer 2 expert review requirements, or the absolute_forbidden list.
- **Contains MUST/MANDATORY/VIOLATION:** yes (16)
- **Contains forbidden_implementations:** yes (3 blocks: distinct reviewers, expert prompt template, step1c grounding)
- **Rationale:** **Codex dogfood evidence: Blake skipped Gate 3 checklist.** Test 1: YES — without reading, Blake will unknowingly skip the before_start checks (reading all ACs, confirming handoff frontmatter), the task_type_branching rules (how to verify different task types), the Layer 2 expert review requirements (≥2 distinct sub-agents for code/mixed, ≥1 for yaml/research), and the after_development steps (completion report, Gate 3, Alex message). Test 2: YES — without reading, Blake would execute implementation but miss: the reflexion step (structured diagnosis before fix), the hard_requirement_distinct_reviewers (≥2 distinct reviewers), the expert_prompt_template (narrow-scope mandate), and research/e2e compliance checks. The anti-rationalization markers are critical execution discipline ("只有 lint warning 不是 error，可以跳过" → Layer 1 standard is ALL PASS). The execution checklist IS the rulebook for every Blake implementation — it's not triggered by a specific command, it's needed for EVERY handoff execution.
- **Key content summary:** Full execution checklist: before_start rules, task_type_branching (code/yaml/research/e2e/mixed/rubric), Layer 1 self-check, reflexion step (structured diagnosis), Layer 2 expert review (distinct reviewer requirement with tier rules, expert prompt template), research/e2e compliance, after_development steps, absolute_forbidden list, 6 anti-rationalization markers.

### notebooklm-access.md
- **Classification:** reference-ok
- **Line count:** 62 lines
- **Trigger mechanism:** On-demand when Blake needs to query a NotebookLM notebook
- **load_when assessment:** truly_conditional
- **Contains MUST/MANDATORY/VIOLATION:** yes (2)
- **Contains forbidden_implementations:** no
- **Rationale:** Triggered only when Blake needs to interact with NotebookLM — an on-demand capability. Test 1: Without reading, Blake won't use NotebookLM at all (fine — not mandatory). Test 2: If Blake attempts to use NotebookLM without reading, it might run forbidden commands (create, research, configure) that are Alex-only. But this scenario requires Blake to actively seek NotebookLM interaction, which would prompt reading the reference. The default_rule: "deny" provides defense-in-depth even if Blake uses NotebookLM from general knowledge. Standard execution doesn't require NotebookLM.
- **Key content summary:** NotebookLM access rules: allowed commands (ask, fulltext, guide, topics, list, language), forbidden commands (create, research, report, configure, consolidate, curate, archive, add, sync, use, language set), default deny rule, ingest mutation scope with confirmation gate.

### ralph-loop.md
- **Classification:** must-body (locked — inlined into body, file deleted)
- **Line count:** 719 lines
- **Trigger mechanism:** none (always needed when Blake enters the Ralph Loop execution cycle)
- **load_when assessment:** always_needed — **CIRCULAR TRIGGER**: the stub says "When Blake enters the Ralph Loop execution cycle for a task" but this reference DEFINES the Ralph Loop. Without it, Blake doesn't know about the Layer 1 → Layer 2 → Gate 3 flow, Agent Team implementation mode, circuit breaker mechanics, escalation thresholds, or state persistence. The Ralph Loop IS Blake's core execution mechanism.
- **Contains MUST/MANDATORY/VIOLATION:** yes (5)
- **Contains forbidden_implementations:** yes (1 block)
- **Rationale:** **Codex dogfood evidence: Blake skipped Layer 2 expert review.** Test 1: YES — without reading, Blake will unknowingly skip the entire Ralph Loop structure: Agent Team dependency analysis, Layer 1 self-check flow, Layer 2 expert review groups (Group 0 spec-compliance → Group 1 code-reviewer → Group 2 parallel experts), circuit breaker mechanics, escalation to human/Alex. Test 2: YES — without reading, Blake would implement code but not follow the iterative quality cycle. It wouldn't know about the Layer 2 group ordering (spec-compliance MUST pass before code-reviewer, which MUST pass before parallel experts), the circuit breaker (3 consecutive same errors → escalate), or the escalation threshold (3 same-category failures → return to Alex). The Ralph Loop is not triggered by a specific command — it's the CORE MECHANISM for every implementation. The *develop command in the SKILL body says to use the Ralph Loop, but the Ralph Loop's details are entirely in this reference.
- **Key content summary:** Full Ralph Loop: Agent Team implementation (parallel with file ownership), dependency analysis, team prompt template, phase1 parallel → phase2 integration → phase3 expert review, fallback protocol, Layer 1 mechanics, Layer 2 expert group ordering, circuit breaker, escalation, state persistence, shared files strategy.

---

## Cross-Reference: Known Failures

| Reference | Codex Dogfood Evidence | Classification |
|-----------|----------------------|----------------|
| completion-protocol.md | Blake skipped completion report entirely | must-body |
| execution-checklist.md | Blake skipped Gate 3 checklist | must-body |
| ralph-loop.md | Blake skipped Layer 2 expert review | must-body |

---

## Size Impact Projection
- Total must-body lines: 1292 (Alex: 0, Blake: 1292)
- Current body: Alex 1485, Blake 737
- Projected after Phase 2 inline: Alex 1485 + 0 = 1485, Blake 737 + 1292 = 2029

---

## Machine-Parseable Summary (refreshed 2026-07-12 — current 31 reference files: 29 alex + 2 blake)

```yaml
# Re-audit 2026-07-12: 0 CIRCULAR-RISK / 0 DISCIPLINE-LEAK.
# Retired refs removed: dream-protocol.md, evolve-protocol.md, optimize-protocol.md,
#   skillify-command-protocol.md (commands retired by Self-Evolution Pruning / v2.8+ consolidation).
# Added: distillation-loop-protocol.md, knowledge-maintain-protocol.md (both reference-ok).
must_body:
  alex: []
  blake:  # inlined into blake/SKILL.md body (Phase 2) — reference files deleted; still must-body
    - completion-protocol.md
    - execution-checklist.md
    - ralph-loop.md
reference_ok:
  alex:
    - accept-command.md
    - acceptance-protocol.md
    - adaptive-complexity-protocol.md
    - bug-path-protocol.md
    - cancel-protocol.md
    - design-protocol.md
    - discuss-path-protocol.md
    - distillation-loop-protocol.md
    - experiment-path-protocol.md
    - express-path-protocol.md
    - handoff-creation-protocol.md
    - idea-list-protocol.md
    - idea-path-protocol.md
    - idea-promote-protocol.md
    - intent-router-protocol.md
    - knowledge-maintain-protocol.md
    - learn-path-protocol.md
    - publish-protocol.md
    - research-decision-protocol.md
    - research-plan-protocol.md
    - research-review-protocol.md
    - socratic-inquiry-protocol.md
    - status-panoramic-protocol.md
    - sync-add-protocol.md
    - sync-list-protocol.md
    - sync-protocol.md
    - update-roadmap-protocol.md
    - workflow-completion-trigger.md
    - yolo-execution-protocol.md
  blake:
    - cross-model-invocation.md
    - notebooklm-access.md
partial_body: []
```
