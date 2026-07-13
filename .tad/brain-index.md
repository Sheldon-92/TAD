# TAD Brain Index
Generated: 2026-07-12 22:38

## Principles
| Entry | Keywords | Summary |
|-------|----------|---------|
| Two-Agent System - inception | two-agent system - inception | Naive default: one agent does everything (design + implement + review). Why wrong: self-review has no second perspective |
| Four-Gate Quality System - inception | four-gate quality system - inception | Naive default: ship after implementation passes tests, skipping design review and business acceptance. Why wrong: tests  |
| Measure Before Optimizing | measure before optimizing | TAD's context loading is already well-optimized (~8.5% session start overhead). @import zero-cost for non-existent files |
| Judgment-Only Skill Files: Constraint Rules Are NOT Mechanical — AMENDED 2026-04-04 | judgment-only skill files constraint rules are not mechanical amended 2026-04-04 | v2.7 slim skills removed constraint rules alongside mechanical logic → quality chain failure. Constraint rules (MUST/MAN |
| Express Handoff is NOT Review-Exemption | express handoff is not review-exemption | "Express → exempt" rationalization is persistent. "Small edit" pattern-matches to "low risk" but bypasses the real quest |
| Mechanical Enforcement Rejected on Single-User CLI | mechanical enforcement rejected on single-user cli | PreToolUse hooks work as designed but fail-closed on missing deps (Homebrew PATH not in pin list) → deny all tool calls  |
| Path Layering: Three Defenses Against AR-001 Drift | path layering three defenses against ar-001 drift | Three independently sufficient defenses: (1) SKILL grep for CI detection, (2) NOT_via_alex_suggestion 3-rule constraint, |
| YOLO Epic Execution: Cross-Model Audit Findings | yolo epic execution cross-model audit findings | YOLO mode executed a full Epic (5 capability pack builds + validation + freeze + cross-agent + template) in one session. |
| Never Hand-Write What an Existing Tool Already Does | never hand-write what an existing tool already does | Installing TAD v2.18.0 to a new project (Colin声音项目). `tad.sh` failed due to interactive `/dev/tty` prompt in non-TTY con |
| Rewiring a Gate's Prose Can Trip a `grep -c` SAFETY Count — Use Line-Set Diff + Re-cite the Constraint | rewiring a gate s prose can trip a grep -c safety count use line-set diff re-cite the constraint | research-engine-wire-phase4 rewired the Phase 0c/4c/5b adversarial-challenge gates in alex/SKILL.md from opt-in AskUserQ |
| A Coverage Gate's Global-Count Floor Cannot Detect Must-Cover SAFETY Loss When Legit Stripping Also Lowers the Count | a coverage gate s global-count floor cannot detect must-cover safety loss when legit stripping also lowers the count | Gate 4 acceptance of the Codex-parity Phase-1 spike (Alex raw-recompute). The parity criterion's constraint layer checks |
| Deny-List Beats Allow-List for Sync Sets; Version Grep Must Scope to git-ls-files; diff-r is the Universal Omission Catcher | deny-list beats allow-list for sync sets version grep must scope to git-ls-files diff-r is the universal omission catcher | TAD publish/sync had recurring silent-omission failures — `.tad/codex/` (+~11 other framework dirs) never in the hardcod |
| Deny-List Must Be Applied at EVERY Copy Granularity, and Verifiers Must Match Each Granularity | deny-list must be applied at every copy granularity and verifiers must match each granularity | P2 of the self-deriving-release-sync Epic killed the hardcoded 14-DIR allow-list in tad.sh (deny-list derivation). But a |
| Execution Discipline Content Must Stay in SKILL Body — Circular Trigger Test | execution discipline content must stay in skill body circular trigger test | SKILL Progressive Loading (v2.26.0) extracted 36 protocols to references/. Codex dogfood: Blake skipped Layer 2, Gate 3, |
| Knowledge Is Forged at Distill, Not Captured | knowledge is forged at distill not captured | The doer who just did the work cannot write reusable knowledge — the curse of |
| AI/Human Judgment Domain Awareness — Agent 应自觉判断域归属 | ai human judgment domain awareness agent  | Voice Studio 播客制作中反复验证：切点精度（人 — 听觉感知）vs 语义分析（AI — 文本理解）；配乐品味（人 — 从 shortlist 挑）vs 情绪/能量/速度匹配（AI — 可计算）。学术佐证：HitL LLM Jud |

## Patterns
| File | Keywords | Summary |
|------|----------|---------|
| Gate Design | Gate responsibility, honest_partial, verification integrity, claims-need-carriers, expert review | Gate responsibility, honest_partial, verification integrity, claims-need-carriers, expert review, YOLO mode, rubric gates, quality gate, Gate 3, Gate 4, blocking, PASS/FAIL |
| Handoff Design | Protocol state machines, lifecycle, scope estimation, worktree grounding, registry state | Protocol state machines, lifecycle, scope estimation, worktree grounding, registry state, handoff creation, Epic phase, express, archive, completion report |
| Shell Portability | macOS/BSD compat, grep/awk/jq patterns, heredoc security, CJK locale, env-var convention | macOS/BSD compat, grep/awk/jq patterns, heredoc security, CJK locale, env-var convention, bash script, sed, comm, sort, diff, md5 |
| AC Verification | AC design rules, dry-run discipline, self-leak prevention, tsc type checks, fixture discrimination | AC design rules, dry-run discipline, self-leak prevention, tsc type checks, fixture discrimination, acceptance criteria, verification command, grep -c |
| Hook Contracts | Hook events, sub-agent safety classifier, array membership, router.log output contract, PreToolUse | Hook events, sub-agent safety classifier, array membership, router.log output contract, PreToolUse, PostToolUse, SessionStart, settings.json |
| Pack Build Rules | Pack architecture, keyword curation, YAML frontmatter, rule sourcing, security pack scope | Pack architecture, keyword curation, YAML frontmatter, rule sourcing, security pack scope, cross-cutting rules, quality delta, capability pack, SKILL.md install, skill-vs-MCP boundary, judgment-vs-capability |
| Pack Evaluation | Anti-slop metrics, cross-model review, discriminative behavioral eval gates, dogfood, blind A/B | Anti-slop metrics, cross-model review, discriminative behavioral eval gates, dogfood, blind A/B, pack quality, WebSearch fact-check |
| Research Methodology | NotebookLM, Codex/Gemini CLI, cross-model orchestration, source quality, cloud compute | NotebookLM, Codex/Gemini CLI, cross-model orchestration, source quality, cloud compute, deep research, *research, web search |
| Memory and Learning | Staleness detection, compact recovery, trace emission, parser value propagation, knowledge assessment | Staleness detection, compact recovery, trace emission, parser value propagation, knowledge assessment, journal, distillation, reflexion |
| Release & Sync | Mirror/parity hazards, gitignore semantics don't survive mirroring, --fix exclusion sets, deny-list at every granularity, privacy leak | Mirror/parity hazards, gitignore semantics don't survive mirroring, --fix exclusion sets, deny-list at every granularity, privacy leak, parity, rsync |

## Project Knowledge
| File | Keywords | Summary |
|------|----------|---------|
| architecture.md | architecture | Foundational: TAD Framework Architecture |
| code-quality.md | code-quality | Foundational: Code Quality Standards |
| frontend-design.md | frontend-design | Foundational: Frontend Design Heuristics |
| principles.md | principles | Principles |
| security.md | security | Foundational: Security Domain Pack Architecture |

## CLAUDE.md Sections
| Section | Keywords | Summary |
|---------|----------|---------|
| 1. Handoff 读取规则 ⚠️ CRITICAL | 1 handoff critical | 读取 `.tad/active/handoffs/` → 必须调用 /blake → 必须过 Gate 3 + Gate 4。 |
| 2. 使用场景 | 2  | \| 命令 \| 触发条件 \| |
| 3. Quality Gates | 3 quality gates | - 规则 0: Handoff 前必须苏格拉底提问 (⚠️ BLOCKING) |
| 4. Terminal 隔离 ⚠️ CRITICAL | 4 terminal critical | Alex = Terminal 1, Blake = Terminal 2。**人类是唯一信息桥梁。** |
| 4.5 Post-Compact Recovery ⚠️ | 4 5 post-compact recovery  | **每次回复前自检（强制）：** |
| 5. 违规处理 | 5  | 违规 → 立即停止 → 调用正确 agent → 从头执行。 |
| 6. 协议位置 | 6  | \| 协议 \| 位置 \| |
| 7. Project Knowledge (Auto-loaded) | 7 project knowledge auto-loaded  | @import 自动加载，不存在的文件静默跳过。超 30KB 时整合。 |
| 7.5 Memory Capture Layer | 7 5 memory capture layer | 原生 auto-memory 已重定向至 `.tad/memory/`(via settings.local.json,DR-20260712)。 |

## Active Handoffs
| File | Task Type | Summary |
|------|-----------|---------|
| HANDOFF-surplus-codex-adapter-yaml.md | code       # bash installer extension + spec doc + generated YAML artifact | Zero-cost Codex CLI compatibility for capability packs, proven on one demo pack: |
| HANDOFF-surplus-pack-behavioral-examples-scaffold.md | mixed      # bash script (code) + fixture docs (md) + gate doc edit | Three deliverables, closing the "validation theater" P0 from the cross-model YOLO audit: |
| HANDOFF-surplus-tad-methodology-skeleton.md | doc-only   # code | yaml | research | e2e | mixed | doc-only | A single new standalone document, `docs/tad-methodology.md`, that extracts the TAD |

## Active Epics
| File | Summary |
|------|---------|

## Archived Handoffs (recent 50)
| File | Task Type | Summary |
|------|-----------|---------|
| HANDOFF-surplus-saveable-skills-from-conversation.md | code | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-surplus-repositioning-capability-acquisition.md | doc-only | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-surplus-o3-kr3-deep-ask-rounds-4-5.md | research | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-surplus-local-skill-capture.md | mixed | Identity (carried over from surplus-scan stub — replaced in place by Alex design step) |
| HANDOFF-surplus-gate-roi-measurement.md | research | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-surplus-detect-state-glob-arm-hazard.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-surplus-detect-state-glob-arm-hazard-fixture-20260705.md | code | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-surplus-deprecate-domain-pack-yaml.md | mixed | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-20260712-memory-redirect-capture-layer.md | mixed | Handoff Document for Agent B (Blake) |
