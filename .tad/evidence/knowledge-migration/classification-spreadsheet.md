# Knowledge Migration Classification Spreadsheet

> Phase 1 output. Human reviews and confirms before Phase 2 migration.
> Classification criteria: see .tad/project-knowledge/README.md

## Statistics
- Total entries: 116
- L1 Principle candidates: 13
- L2 Pattern candidates: 76
- L3 Incident candidates: 25
- DISCARD candidates: 2

## Classification

### From: architecture.md (93 entries)

#### Foundational Section (2 entries)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 1 | Two-Agent System | inception | L1 | — | — | Foundational methodology rule: defines TAD's core two-agent architecture | ☐ |
| 2 | Four-Gate Quality System | inception | L1 | — | — | Foundational methodology rule: defines TAD's four-gate quality system | ☐ |

#### Accumulated Learnings (91 entries)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 3 | Ralph Loop Two-Layer Architecture | 2026-01-26 | L2 | gate-design | — | Reusable architectural pattern for iterative quality workflows | ☐ |
| 4 | Gate Responsibility Matrix | 2026-01-26 | L2 | gate-design | — | Reusable pattern: separate technical automation from business judgment | ☐ |
| 5 | Cognitive Firewall: Embed Into Existing Flows | 2026-02-06 | L2 | handoff-design | — | Reusable pattern: cross-cutting concerns embedded into existing flows | ☐ |
| 6 | Standalone Agent Command Pattern | 2026-02-08 | L2 | pack-build-rules | — | Reusable pattern: when to extract sub-phases to standalone commands | ☐ |
| 7 | Manifest + Directory Isolation for Multi-Instance Resources | 2026-02-09 | L2 | handoff-design | — | Reusable pattern: directory isolation + manifest index for multi-instance | ☐ |
| 8 | Intent Router and Mode Addition | 2026-02-16 | L2 | handoff-design | — | Reusable pattern: 5-layer integration checklist for new modes | ☐ |
| 9 | Storage and Lifecycle Patterns | 2026-02-16 | L2 | handoff-design | — | Reusable pattern: reference don't copy, forward-only lifecycle | ☐ |
| 10 | Feature Deprecation Cleanup Pattern | 2026-02-17 | L2 | handoff-design | — | Reusable pattern: function-name targeting + grep-driven completeness | ☐ |
| 11 | Minimal Viable Cross-Cutting Enhancement | 2026-02-19 | L2 | handoff-design | — | Reusable pattern: start with 2 most critical points (producer + consumer) | ☐ |
| 12 | Measure Before Optimizing | 2026-03-23 | L1 | — | — | Permanent methodology rule: always measure actual baseline before optimizing | ☐ |
| 13 | Long Context Enables In-Session Decision Making (4D Protocol) | 2026-03-25 | L2 | research-methodology | — | Reusable pattern: 1M context changes methodology to in-session decisions | ☐ |
| 14 | Claude Code Hook Contract Summary | 2026-03-31 | L2 | hook-contracts | — | Reusable pattern: hook mechanism rules (PascalCase, type:command vs prompt) | ☐ |
| 15 | Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical | 2026-04-04 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): constraint rules cannot be removed during slimming | ☐ |
| 16 | Domain Pack Architecture Patterns | 2026-04-02 | L2 | pack-build-rules | — | Reusable pattern: Type A/B/Mixed step models for capability packs | ☐ |
| 17 | Hook Shell Portability Rules | 2026-04-03 | L2 | shell-portability | — | Reusable pattern: no grep -P on macOS, awk vs grep loop, perl timing | ☐ |
| 18 | Domain Pack Keyword Curation | 2026-04-07 | L2 | pack-build-rules | — | Reusable pattern: strict uniqueness + threshold 1 for pack keywords | ☐ |
| 19 | Epic Architecture: Spike-Driven Pivots | 2026-04-07 | L2 | gate-design | — | Reusable pattern: plan for 2-3 pivots, split design and validation spikes | ☐ |
| 20 | Expert Review Blind Spots | 2026-04-04 | L2 | gate-design | — | Reusable pattern: pre-handoff vs post-impl reviewers catch different things | ☐ |
| 21 | Alex Handoff AC Design Rules | 2026-04-14 | L2 | ac-verification | — | Reusable pattern: imperative AC form, dry-run verification, conflict matrix | ☐ |
| 22 | Gate 4 Verification Integrity | 2026-04-14 | L2 | gate-design | — | Reusable pattern: re-derive from primary evidence, validator dogfood, git status | ☐ |
| 23 | Express Handoff is NOT Review-Exemption | 2026-04-14 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): express may skip e2e but MUST NOT skip expert review | ☐ |
| 24 | Claude Code Sub-Agent Safety Classifier | 2026-04-14 | L2 | hook-contracts | — | Reusable pattern: blue-team framing for security sub-agent invocations | ☐ |
| 25 | Mechanical Enforcement Rejected on Single-User CLI | 2026-04-15 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): soft reminders for single-user CLI, not mechanical hooks | ☐ |
| 26 | Shell Pattern: Word-Boundary Matching for Slugs | 2026-04-24 | L2 | shell-portability | — | Reusable pattern: bracket class not \b for slug matching | ☐ |
| 27 | Drift-Check and Staleness Detection | 2026-04-24 | L2 | memory-and-learning | — | Reusable pattern: allowlists for shared files, quieting paths for smoke-alarm tools | ☐ |
| 28 | Path Layering: Three Defenses Against AR-001 Drift | 2026-04-24 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): three independent defenses against constraint drift | ☐ |
| 29 | DESIGN.md Spec Integration as Type A Capability | 2026-04-25 | L2 | pack-build-rules | — | Reusable pattern: external spec imports as Type A with version pinning | ☐ |
| 30 | Data-Capture and AskUser Hooks | 2026-04-25 | L2 | hook-contracts | — | Reusable pattern: elementwise membership checks for arrays | ☐ |

**Checkpoint 1 (entries 1-30): L1=7, L2=23, L3=0, DISCARD=0** (L1 count ≤ 15 ✅)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 31 | honest_partial_protocol: Real-Use Validation | 2026-04-25 | L2 | gate-design | — | Reusable pattern: use honest_partial for environmental deadlocks | ☐ |
| 32 | AC Verification Drift Pattern | 2026-04-25 | L2 | ac-verification | — | Reusable pattern (recurring through 4 phases): AC commands must be dry-run on real artifacts | ☐ |
| 33 | YAML String-Form Annotation for Pack Schema Homogeneity | 2026-04-25 | L2 | pack-build-rules | — | Reusable pattern: trailing inline annotation over dict polymorphism | ☐ |
| 34 | Anti-AI-Slop as Cross-Pack Quality Bar | 2026-04-25 | L2 | pack-evaluation | — | Reusable pattern: pair anti-slop negatives with positive direction criteria | ☐ |
| 35 | AC Self-Leak from Removal Rationale | 2026-04-27 | L2 | ac-verification | — | Reusable pattern: removal pointers reference META artifacts, not removed-feature name | ☐ |
| 36 | Cleanup Handoff Scope-Estimation Drift | 2026-04-27 | L2 | handoff-design | — | Reusable pattern: add Downstream Consumers Grep for deletion handoffs | ☐ |
| 37 | .router.log 5-Tuple as Load-Bearing Hook Output Contract | 2026-04-27 | L2 | hook-contracts | — | Reusable pattern: add CONTRACT block to hook scripts with consumed output | ☐ |
| 38 | Two-Layer Compact Recovery Pattern | 2026-04-28 | L2 | memory-and-learning | — | Reusable pattern: trigger in system-prompt, state on-disk, stale detection | ☐ |
| 39 | Codex CLI Feasibility and Patterns | 2026-05-01 | L2 | research-methodology | — | Reusable pattern: codex exec patterns, stdin injection, exit code truth | ☐ |
| 40 | Codex AGENTS.md Auto-Load | 2026-05-02 | L3 | — | L2: research-methodology "Codex CLI Feasibility and Patterns" | One-time discovery about AGENTS.md auto-load behavior | ☐ |
| 41 | Protocol State-Machine Design | 2026-05-02 | L2 | handoff-design | — | Reusable pattern: explicit transitions, bootstrapping path, named blocks with gates | ☐ |
| 42 | Gemini CLI Constraints | 2026-05-03 | L3 | — | L2: research-methodology "Cross-Model Orchestration Principles" | One-time discovery: Gemini -p flag, read-only, regex validation | ☐ |
| 43 | NotebookLM Integration Patterns | 2026-05-03 | L2 | research-methodology | — | Reusable pattern: auth, min version, quality probe after import | ☐ |
| 44 | NotebookLM Research Methodology | 2026-05-05 | L2 | research-methodology | — | Reusable pattern: 5-step methodology, report is baseline, curate before asking | ☐ |
| 45 | Cross-Model Orchestration Principles | 2026-05-03 | L2 | research-methodology | — | Reusable pattern: prompt symmetry, include incumbent baseline, 3-way comparison | ☐ |
| 46 | Registry and Protocol Field Design | 2026-05-04 | L2 | handoff-design | — | Reusable pattern: hybrid persisted+derived state, three protocol field declarations | ☐ |
| 47 | CLAUDE.md Routing Label Conflicts | 2026-05-05 | L3 | — | L2: shell-portability "Hook Shell Portability Rules" | One-time bug: grep-c returning 2 due to label prefix overlap | ☐ |
| 48 | Capability Pack: YAML Frontmatter is Load-Bearing | 2026-05-07 | L2 | pack-build-rules | — | Reusable pattern: name: + description: YAML frontmatter mandatory for SKILL.md | ☐ |
| 49 | Capability Pack: Architecture Spectrum | 2026-05-08 | L2 | pack-build-rules | — | Reusable pattern: reference-based vs deep-skill vs orchestration-router | ☐ |
| 50 | Capability Pack: Design and Build Rules | 2026-05-07 | L2 | pack-build-rules | — | Reusable pattern: multi-agent install, rule sourcing, CONSUMES/PRODUCES | ☐ |
| 51 | Capability Pack: Specific Technical Rules | 2026-05-07 | L2 | pack-build-rules | — | Reusable pattern: K8s preStop, dual-agent CaMeL, saturation detection | ☐ |
| 52 | Research-Methodology Pack as Capability Pack Factory | 2026-05-08 | L2 | pack-build-rules | — | Reusable pattern: run research-methodology as Phase 0 for packs | ☐ |
| 53 | Shell Dispatcher Patterns | 2026-05-09 | L2 | shell-portability | — | Reusable pattern: set -e in case arms, portable timeout, UTM normalization | ☐ |
| 54 | Source Import Quality: False Success Patterns | 2026-05-09 | L2 | research-methodology | — | Reusable pattern: SPA shell capture, login wall, WAF error — PDF only reliable | ☐ |
| 55 | Expert Reviewer Premise Check | 2026-05-09 | L3 | — | L2: gate-design "Expert Review Blind Spots" | One-time discovery: reviewer confused raw CLI with SKILL command | ☐ |
| 56 | Dynamic Research Protocol Design | 2026-05-09 | L2 | research-methodology | — | Reusable pattern: saturation counters, array-index guards, tunnel detection | ☐ |
| 57 | Step Insertion Requires Predecessor Transition Arrow Audit | 2026-05-14 | L2 | handoff-design | — | Reusable pattern: grep for ALL references to old successor when inserting steps | ☐ |
| 58 | Epic Auto-Conductor: Sub-Agent Constraints | 2026-05-14 | L2 | gate-design | — | Reusable pattern: sub-agents have no Agent tool, file is source of truth | ☐ |
| 59 | Sufficiency Check Must Precede the Step It Influences | 2026-05-14 | L2 | handoff-design | — | Reusable pattern: conditional checks before the step they modify | ☐ |
| 60 | Autonomous Protocol Design: Three Mandatory Patterns | 2026-05-14 | L2 | handoff-design | — | Reusable pattern: explicit transitions, verify+on_verify_fail, re-review after P0 | ☐ |

**Checkpoint 2 (entries 1-60): L1=7, L2=49, L3=4, DISCARD=0** (L1 count ≤ 15 ✅)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 61 | YOLO Epic Execution: Cross-Model Audit Findings | 2026-05-15 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): validation theater, rule soup, behavioral eval needed | ☐ |
| 62 | YOLO Mode Strengths and Constraints | 2026-05-15 | L2 | gate-design | — | Reusable pattern: pipeline research ahead of build, lighter verification on repetitions | ☐ |
| 63 | Capability Pack Quality Bar: Anti-Slop Metrics | 2026-05-15 | L2 | pack-evaluation | — | Reusable pattern: specific thresholds from research > generic principles | ☐ |
| 64 | Shell Env-Var Convention for Backward-Compatible Function Extension | 2026-05-19 | L2 | shell-portability | — | Reusable pattern: env-var convention for >3 positional params in shell | ☐ |
| 65 | Double-Parse Pattern for String-Encoded JSON Fields | 2026-05-20 | L2 | shell-portability | — | Reusable pattern: single-pass jq with fromjson, file-based multi-field extraction | ☐ |
| 66 | AC Verification Command Bug: grep -ocE sort -u wc -l | 2026-05-27 | L3 | — | L2: ac-verification "Alex Handoff AC Design Rules" | One-time bug: grep -c + sort -u + wc -l always returns 1 | ☐ |
| 67 | Layer 2 Audit Canonical Reviewer Name Drift | 2026-05-27 | L3 | — | L2: gate-design "Gate 4 Verification Integrity" | One-time incident: audit script reviewer names didn't match Blake naming convention | ☐ |
| 68 | ScienceClaw Skill Decoupling — Migration Feasibility Pattern | 2026-05-28 | L3 | — | L2: pack-build-rules "Capability Pack: Design and Build Rules" | One-time analysis of ScienceClaw architecture for migration feasibility | ☐ |
| 69 | Source Citation Integrity for Adapted Values | 2026-05-28 | L2 | pack-build-rules | — | Reusable pattern: cite BOTH original source AND adaptation document | ☐ |
| 70 | Scoring Rubrics in Reference Files Need Methodology Review | 2026-05-28 | L3 | — | L2: pack-evaluation "Anti-AI-Slop as Cross-Pack Quality Bar" | One-time discovery: UX-reviewer catches scoring rubric bugs code-reviewer misses | ☐ |
| 71 | Per-Tool Numeric Thresholds Require Research Provenance, Not Interpolation | 2026-05-28 | L2 | pack-build-rules | — | Reusable pattern: only include tools with individually measured values | ☐ |
| 72 | Academic Research Pack Pilot: Quality Gap Analysis | 2026-05-28 | L3 | — | L2: pack-evaluation "Capability Pack Quality Bar: Anti-Slop Metrics" | One-time pilot test: soy sauce study, ScholarEval 0.626, 3 structural gaps | ☐ |
| 73 | ChatTTS Consistency Pattern: Seed Reset + Saved Embedding > Batch Mode | 2026-05-28 | L3 | — | L2: research-methodology "Source Import Quality" | One-time dogfood: ChatTTS batch impractical on 16GB, sequential + fixed seed works | ☐ |
| 74 | Never Hand-Write What an Existing Tool Already Does | 2026-05-28 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): fix the tool, don't rewrite it ad-hoc | ☐ |
| 75 | Cloud Compute Resource Awareness — Hardware Limitation ≠ Infeasibility | 2026-05-29 | L2 | research-methodology | — | Reusable pattern: local hardware insufficient → cloud alternatives, not terminal | ☐ |
| 76 | Observational > Imperative Trace Emission; Stable Marker Contract | 2026-05-30 | L2 | memory-and-learning | — | Reusable pattern: observational parsing of artifacts vs imperative emission | ☐ |
| 77 | Parser Self-Trigger: Evidence Prose Documenting a Finding-Label Regex | 2026-05-30 | L3 | — | L2: memory-and-learning "Observational > Imperative Trace Emission" | One-time bug: review file documenting parser regex triggered false P0 count | ☐ |
| 78 | Ad-hoc Dead Code Audit Tools Are Themselves Validation Theater | 2026-05-30 | L3 | — | L1: YOLO "validation theater" / L2: gate-design | One-time incident: grep scanner labeled in-progress work as dead code | ☐ |
| 79 | A Parser Feeding a Human-Review Queue Must Propagate VALUE Fields | 2026-05-31 | L2 | memory-and-learning | — | Reusable pattern: verify parser propagates value/rationale fields, not just labels | ☐ |
| 80 | Rewiring a Gate's Prose Can Trip a grep -c SAFETY Count | 2026-05-31 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): line-SET diff as ground truth, count as smoke alarm | ☐ |
| 81 | Verify the Worktree Base Contains the Prerequisite Commits | 2026-05-31 | L2 | handoff-design | — | Reusable pattern: check grounding commit exists in working tree before implementing | ☐ |
| 82 | Progressive Disclosure: Extract Only Constraint-Token-FREE Blocks | 2026-05-31 | L3 | — | L1: Judgment-Only Skill Files "constraint rules cannot be removed" | One-time incident: 9-block extraction from SKILL.md with safety count preservation | ☐ |
| 83 | Pack Collision Detection is Orthogonal to Per-Pack Eval | 2026-05-31 | L3 | — | L2: pack-evaluation "Anti-AI-Slop as Cross-Pack Quality Bar" | One-time build: collision detector found 3 real contradictions + 1 false positive | ☐ |
| 84 | Non-Dev Execution Track: A Rubric Gate Is Only Credible If It Can FAIL | 2026-05-31 | L2 | gate-design | — | Reusable pattern: prove gate can FAIL via PARTIAL, judge≠producer, additive sibling | ☐ |
| 85 | Cross-Model Adversarial Review Catches a Defect Class Same-Model Misses | 2026-06-01 | L2 | pack-evaluation | — | Reusable pattern: run cross-model review, triage findings, verify reviewer claims | ☐ |
| 86 | Capability Pack Value Is Non-Monotonic in Model Strength | 2026-06-01 | L3 | — | L2: pack-evaluation "Capability Pack Quality Bar: Anti-Slop Metrics" | One-time measurement: sweet spot is Sonnet-tier, value non-monotonic | ☐ |
| 87 | Capability Pack Value Is Cross-Vendor (Codex + Gemini) | 2026-06-01 | L3 | — | L2: pack-evaluation "Cross-Model Adversarial Review" | One-time measurement: packs add value to both Codex and Gemini | ☐ |
| 88 | Codex-Edition Parity: 3-Layer Mechanizable Criterion | 2026-06-01 | L3 | — | L2: pack-build-rules "Capability Pack: Design and Build Rules" | One-time spike: 3-layer parity check + grep -c || echo 0 bug | ☐ |
| 89 | A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss | 2026-06-01 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): per-category presence checks, not global count floor | ☐ |
| 90 | Cross-Agent Parity Check: Source-Condition Feature Markers | 2026-06-01 | L3 | — | L2: pack-build-rules "Capability Pack: Design and Build Rules" | One-time discovery: hardcoded markers fail cross-agent, source-condition each | ☐ |

**Checkpoint 3 (entries 1-90): L1=11, L2=61, L3=18, DISCARD=0** (L1 count ≤ 15 ✅)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 91 | Decouple Detect-from-Heal at Release Gates | 2026-06-01 | L2 | gate-design | — | Reusable pattern: detect-only in release flow, separate human-invoked regen | ☐ |
| 92 | Deny-List Beats Allow-List for Sync Sets | 2026-06-01 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): deny-list not allow-list, diff-r as universal catcher | ☐ |
| 93 | Deny-List Must Be Applied at EVERY Copy Granularity | 2026-06-01 | L1 | — | — | Permanent methodology rule (SAFETY ENTRY): fix deny-list at every granularity, verifiers must match | ☐ |

### From: code-quality.md (15 entries)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 94 | Recurring failure: tsc missing type | 2026-05-19 | L2 | ac-verification | — | Recurring pattern (not one-time): add tsc --noEmit AC to TypeScript handoffs | ☐ |
| 95 | AC grep-count for reference-based pack files | 2026-05-27 | L3 | — | L2: ac-verification "Alex Handoff AC Design Rules" | One-time discovery: reference filenames appear 2x in pack SKILL.md | ☐ |
| 96 | Bash heredoc Python injection via unvalidated CLI args | 2026-05-28 | L2 | shell-portability | — | Reusable pattern: validate numeric args before interpolating into embedded language | ☐ |
| 97 | Reading provenance rules ≠ following them during pack builds | 2026-05-29 | L2 | pack-build-rules | — | Reusable pattern: mandatory per-number self-check against findings.md | ☐ |
| 98 | Heredoc injection depends on the SINK: file-write ≠ interpreter-exec | 2026-05-31 | L2 | shell-portability | — | Reusable pattern: distinguish executing sink from writing sink for heredoc security | ☐ |
| 99 | mikefarah yq -i Normalizes Once Then Is Idempotent | 2026-05-31 | L3 | — | L2: shell-portability "Hook Shell Portability Rules" | One-time discovery: yq v4 first-write reformat, then byte-stable | ☐ |
| 100 | Line-Anchored blockquote to col-0 sed Single-Line CONSUMES PRODUCES | 2026-05-31 | L3 | — | L2: shell-portability "Shell Dispatcher Patterns" | One-time bug: single-line two-marker blockquote only yields one col-0 marker | ☐ |
| 101 | Section 9.1 Region Marker is ### 9.1 (3-hash), NOT ## 9.1 | 2026-05-31 | L3 | — | L2: ac-verification "AC Verification Drift Pattern" | One-time bug: wrong heading depth in awk region extractor | ☐ |
| 102 | Behavioral-Fixture Discrimination: Anti-Slop = Threshold/Named-Rule | 2026-05-31 | L2 | pack-evaluation | — | Reusable pattern: markers from pack-specific numbers, not domain nouns | ☐ |
| 103 | Auto-Generated Registry → Persisted Decision State in Side-File | 2026-05-31 | L2 | handoff-design | — | Reusable pattern: decision state in side-file when registry is auto-generated | ☐ |
| 104 | Behavioral-Eval Gate Must Run on SEPARATE Discriminative Field | 2026-05-31 | L2 | pack-evaluation | — | Reusable pattern: discriminative_pattern field separate from combined count | ☐ |
| 105 | comm -12 Set-Intersection CJK Needs LC_ALL=C on BOTH sorts AND comm | 2026-05-31 | L2 | shell-portability | — | Reusable pattern: byte collation on every participant for CJK set ops | ☐ |
| 106 | Anchorless .tad/ sed Strips Inconsistently on Relative ls -d Paths | 2026-06-01 | L3 | — | L2: shell-portability "Shell Dispatcher Patterns" | One-time bug: unanchored regex + relative path = inconsistent basename extraction | ☐ |
| 107 | A Derived Copy-Set Loop Must Copy DOTFILES | 2026-06-01 | L3 | — | L1: Deny-List Every Copy Granularity | One-time bug: bare * glob drops dotfiles in cp -r | ☐ |
| 108 | Embedded-Copy Drift Check: Reconstruct Authoritative Set From Lib | 2026-06-01 | L3 | — | L1: Deny-List Beats Allow-List | One-time pattern: drift check derives canonical value from original, compares as sorted sets | ☐ |

### From: security.md (7 entries)

#### Foundational Section (3 entries)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 109 | Pack Scope Boundaries | inception | L2 | pack-build-rules | — | Reusable pattern: security pack scope definitions (supply-chain vs code vs monitoring) — domain-specific, not universal TAD methodology | ☐ |
| 110 | Key Tool Insight: litellm-class Attack Detection | inception | L2 | pack-build-rules | — | Reusable pattern: only Socket CLI detects behavioral changes — tool-specific, not universal TAD | ☐ |
| 111 | AI Security Hard Gaps (CLI Tooling) | inception | DISCARD | — | — | Outdated: LLM03/LLM08/LLM10 gap list is ecosystem snapshot, not actionable methodology | ☐ |

#### Accumulated Learnings (4 entries)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 112 | Security Packs Use Cross-Cutting Review Pattern | 2026-04-04 | L2 | pack-build-rules | — | Reusable pattern: single top-level review persona for security packs | ☐ |
| 113 | Nested output_structure Enhancement | 2026-04-04 | DISCARD | — | — | Superseded: description+tree nested format is now standard in all packs, no longer a discovery | ☐ |
| 114 | Compliance CLI vs SaaS Boundary | 2026-04-03 | L2 | pack-build-rules | — | Reusable pattern: CLI covers ~60% SOC2 technical controls, declare boundary explicitly | ☐ |
| 115 | Cross-Domain Tool Overlap is Intentional | 2026-04-03 | L2 | pack-build-rules | — | Reusable pattern: don't deduplicate tools across packs, document different usage context | ☐ |

### From: frontend-design.md (1 entry)

#### Foundational Section (1 entry)

| # | Entry Title | Date | Proposed Layer | Theme Group | Linked L1/L2 | Rationale | Human Confirmed |
|---|------------|------|---------------|-------------|-------------|-----------|----------------|
| 116 | Warm Palette Interpretation Rule | 2026-04-25 | L2 | — | — | Explicitly single-project evidence (demoted from Domain Pack per README rule). Not universal TAD methodology. | ☐ |

**Final count: L1=13, L2=76, L3=25, DISCARD=2** (L1 count ≤ 15 ✅)

## L2 Theme Group Summary

| Theme Group | Entry Count | Proposed Filename |
|-------------|-------------|-------------------|
| shell-portability | 9 | shell-portability.md |
| ac-verification | 5 | ac-verification.md |
| gate-design | 10 | gate-design.md |
| pack-build-rules | 16 | pack-build-rules.md |
| pack-evaluation | 6 | pack-evaluation.md |
| handoff-design | 12 | handoff-design.md |
| hook-contracts | 4 | hook-contracts.md |
| research-methodology | 9 | research-methodology.md |
| memory-and-learning | 4 | memory-and-learning.md |
| (no group - standalone L2) | 1 | (Warm Palette - stays in frontend-design or standalone) |

> Note per ARCH P1-2: pack-build-rules (16 entries) pre-split into pack-build-rules.md + pack-evaluation.md (6 entries already separated).
