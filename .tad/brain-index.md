# TAD Brain Index
Generated: 2026-07-03 16:10

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

## Active Handoffs
| File | Task Type | Summary |
|------|-----------|---------|
| HANDOFF-20260703-gbrain-poc.md | mixed | 安装 gbrain（开源知识图谱 + 语义搜索工具），导入 TAD 的 .tad/ 目录作为知识库，通过 CLI 直接调用测试 5 个预设查询的搜索效果。这是 POC — 证明 gbrain 的搜索核心对 TAD 知识是否有价值。验证通过后 |
| HANDOFF-20260703-tad-brain-native.md | mixed | TAD-native 知识搜索工具 `tad-brain`：一个 bash 脚本生成索引 + 一个 skill/wrapper 调用 Explore agent 做语义搜索。零外部依赖，用 Claude 本身的语义理解能力代替 embedd |

## Active Epics
| File | Summary |
|------|---------|
| EPIC-20260703-claude-science-skill-architecture.md | **Epic ID**: EPIC-20260703-claude-science-skill-architecture |
| EPIC-20260703-gbrain-tad-integration.md | **Epic ID**: EPIC-20260703-gbrain-tad-integration |

## Archived Handoffs (recent 50)
| File | Task Type | Summary |
|------|-----------|---------|
| HANDOFF-surplus-detect-state-glob-arm-hazard.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260703-claude-science-p1-standard-alignment.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260702-trajectory-eval-p3.md | mixed | Quality Chain Metadata (Alex 必填) |
| HANDOFF-20260702-trajectory-eval-p2.md | mixed | Quality Chain Metadata (Alex 必填) |
| HANDOFF-20260702-trajectory-eval-p1.md | research | Quality Chain Metadata (Alex 必填 - Phase 4 Hook 将基于此阻塞 Gate 3) |
| HANDOFF-20260702-surplus-execute-p2.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260701-ldr-poc-phase1.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260623-socratic-redesign-p1.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260623-mece-gate-p2.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260623-gate-ssot-p1.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260622-knowledge-redesign-p4-dogfood.md | mixed | Handoff: Knowledge Recording Redesign — P4 Dogfood + Reference Migration |
| HANDOFF-20260622-knowledge-redesign-p3-maintain.md | mixed | Handoff: Knowledge Recording Redesign — P3 Maintain (dedup/retire/reconcile + lint) |
| HANDOFF-20260622-knowledge-redesign-p2-distill-loop.md | mixed | Handoff: Knowledge Recording Redesign — P2 Capture/Distill Cross-Bridge Loop |
| HANDOFF-20260622-knowledge-redesign-p1-foundation.md | mixed | Handoff: Knowledge Recording Redesign — P1 Foundation (schema + writing rules + L1 principle) |
| HANDOFF-20260618-pack-content-protection-p4.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260618-pack-content-protection-p3.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-research-output-quality.md | yaml | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-research-input-quality.md | yaml | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-research-ecosystem-cleanup.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-release-v2.31.0.md | mixed | Handoff: Release v2.31.0 |
| HANDOFF-20260617-pack-content-protection-p2.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-pack-content-protection-p1.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-installer-audit-fixes.md | code | Handoff: Installer Audit Fixes (5 bugs) |
| HANDOFF-20260617-hotfix-v2.31.1.md | code | Handoff: Hotfix v2.31.1 |
| HANDOFF-20260617-agent-skill-evolution-pack.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260617-agent-computer-interface-pack.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260616-skillopt-tad-methodology.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260616-research-unified-entry.md | yaml | Handoff Document for Agent B (Blake) |
| HANDOFF-20260614-fix-workflow-toplevel-array-schemas.md | code | Handoff: Fix top-level-array StructuredOutput schemas in workflows + surplus undated WARN |
| HANDOFF-20260614-fix-detect-state-semver.md | code | Handoff: Fix tad.sh detect_state glob-arm hazard (numeric semver routing) |
| HANDOFF-20260614-ai-reading-companion-phase4-sinks-multiformat.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260613-pack-quality-phase1-bar-baseline.md | research | Handoff Document for Agent B (Blake) |
| HANDOFF-20260613-ai-reading-companion-phase3-live-bridge.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260613-ai-reading-companion-phase2-epub-reader.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260611-release-v2.29.1.md | yaml | Handoff Document for Agent B (Blake) |
| HANDOFF-20260611-pack-system-unification-phase3.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260611-pack-system-unification-phase2.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260611-pack-system-unification-phase1.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-sep-phase3.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-sep-phase2.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-sep-phase1.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-publish-gate-phase5.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-merge-capability-phase4.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-friction-protocol-phase2.md | code | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-friction-protocol-phase1.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-feedback-collector-phase3.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-feedback-collector-phase2.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-feedback-collector-phase1.md | mixed | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-dual-platform-parity-fix.md | yaml | Handoff Document for Agent B (Blake) |
| HANDOFF-20260610-dual-caller-integration-phase3.md | code | Handoff Document for Agent B (Blake) |

## Evidence Directories
| Directory | Files | Topic |
|-----------|-------|-------|
| evidence/acceptance-tests/ | 57 | acceptance-tests |
| evidence/codex-regression/ | 10 | codex-regression |
| evidence/codex-validation/ | 4 | codex-validation |
| evidence/completions/ | 71 | completions |
| evidence/decisions/ | 0 | decisions |
| evidence/designs/ | 8 | designs |
| evidence/dogfood/ | 3 | dogfood |
| evidence/dual-platform-regression/ | 4 | dual-platform-regression |
| evidence/e2e/ | 3 | e2e |
| evidence/eval/ | 2 | eval |
| evidence/failures/ | 0 | failures |
| evidence/fixtures/ | 9 | fixtures |
| evidence/gates/ | 0 | gates |
| evidence/handoff-reviews/ | 4 | handoff-reviews |
| evidence/handoffs/ | 5 | handoffs |
| evidence/journal/ | 4 | journal |
| evidence/knowledge-migration/ | 2 | knowledge-migration |
| evidence/learnings/ | 3 | learnings |
| evidence/maintenance/ | 1 | maintenance |
| evidence/metrics/ | 1 | metrics |
| evidence/overrides/ | 0 | overrides |
| evidence/pack-dogfood/ | 11 | pack-dogfood |
| evidence/pack-eval/ | 56 | pack-eval |
| evidence/pack-quality/ | 4 | pack-quality |
| evidence/pack-system-unification-phase1/ | 0 | pack-system-unification-phase1 |
| evidence/pack-system-unification-phase2/ | 0 | pack-system-unification-phase2 |
| evidence/pack-system-unification-phase3/ | 1 | pack-system-unification-phase3 |
| evidence/pair-tests/ | 0 | pair-tests |
| evidence/patterns/ | 2 | patterns |
| evidence/poc/ | 6 | poc |
| evidence/project-logs/ | 0 | project-logs |
| evidence/ralph-loops/ | 5 | ralph-loops |
| evidence/releases/ | 2 | releases |
| evidence/research/ | 142 | research |
| evidence/reviews/ | 403 | reviews |
| evidence/spikes/ | 47 | spikes |
| evidence/traces/ | 0 | traces |
| evidence/yolo/ | 197 | yolo |

## Decision Records
| File | Summary |
|------|---------|
| DR-20260531-ar001-research-challenge-carveout.md | DR-20260531: AR-001 Carve-Out for Auto-Running Adversarial Challenge Inside *research-plan |
| DR-20260601-codex-edition-parity-architecture.md | DR-20260601: Codex-Edition Parity Architecture — Automated Regeneration (B) |
| DR-20260601-self-deriving-release-sync.md | DR-20260601-B: Self-Deriving + Self-Verifying Release/Sync (kill the hardcoded-list disease) |
| DR-20260606-checklist-shape-dogfood-deferral.md | DR-20260606: checklist verdict_shape ships gate-logic-only (real dogfood deferred) |
| DR-20260609-deprecation-yaml-disposition.md | DR-20260609: deprecation.yaml Disposition — Relationship to Migration Manifest |
| DR-20260609-migration-backfill-depth.md | DR-20260609: Migration Manifest Backfill Depth |
| DR-20260609-user-modified-detection.md | DR-20260609: User-Modified File Detection Method |

## Config Files
| File | Contains |
|------|---------|
| config-agents.yaml | "跳过任何步骤 → 警告并重新激活",    - "身份混淆 → 立即纠正",    - "未显示help → 自动补充",        - "需求分析 → 苏格拉底式提问 → 设计 → 写 handoff",        - "输出: |
| config-cognitive.yaml | "Framework or library selection (e.g., React vs Vue, Redis vs Memcached)",      - "Architecture pattern choice (e.g., mo |
| config-execution.yaml | Layer 1: Self-Check (build, test, lint, tsc),    - Layer 2: Expert Review (spec-compliance-reviewer, code-reviewer, test |
| config-platform.yaml | "Next.js",          - "React",          - "Vue",          - "Tailwind",          - "TypeScript" |
| config-quality.yaml | pre_task: "检查是否需要sub-agent",      - during_task: "确认sub-agent被调用",      - post_task: "验证sub-agent完成工作",        - "Proble |
| config-workflow.yaml | tasks         # 任务追踪,      - designs       # 设计文档,      - handoffs      # 交接文档,      - epics         # Epic 多阶段任务追踪,     |
| config.yaml | activation_protocol,      - triangle (terminal_isolation, agent_a, agent_b, human),      - interaction_protocol,      -  |

## Skills
| Skill | Summary |
|-------|---------|
| academic-research | name: academic-research |
| agent-computer-interface | name: agent-computer-interface |
| agent-memory | name: agent-memory |
| agent-orchestration | name: agent-orchestration |
| agent-skill-evolution | name: agent-skill-evolution |
| ai-agent-architecture | name: ai-agent-architecture |
| ai-evaluation | name: ai-evaluation |
| ai-guardrails | name: ai-guardrails |
| ai-podcast-production | name: ai-podcast-production |
| ai-prompt-engineering | name: ai-prompt-engineering |
| ai-tool-integration | name: ai-tool-integration |
| ai-voice-production | name: ai-voice-production |
| alex | name: alex |
| blake | name: blake |
| capability-upgrade | name: capability-upgrade |
| code-security | name: code-security |
| data-engineering | name: data-engineering |
| gate | name: gate |
| knowledge-audit | name: knowledge-audit |
| knowledge-graph | name: knowledge-graph |
| llm-observability | name: llm-observability |
| ml-training | name: ml-training |
| playground | name: playground |
| product-thinking | name: product-thinking |
| rag-retrieval | name: rag-retrieval |
| reading-companion | name: reading-companion |
| release-runbook | name: release-runbook |
| research-github | name: research-github |
| research-notebook | name: research-notebook |
| surplus | name: surplus |
| synthetic-data | name: synthetic-data |
| tad-elicit | name: tad-elicit |
| tad-handoff | name: tad-handoff |
| tad-help | name: tad-help |
| tad-init | name: tad-init |
| tad-maintain | name: tad-maintain |
| tad-parallel | name: tad-parallel |
| tad-scenario | name: tad-scenario |
| tad-status | name: tad-status |
| tad-test-brief | name: tad-test-brief |
| tad | name: tad |
| video-creation | name: video-creation |
| web-backend | name: web-backend |
| web-deployment | name: web-deployment |
| web-frontend | name: web-frontend |
| web-testing | name: web-testing |
| web-ui-design | name: web-ui-design |

---
Total indexed entries: (see above tables)
