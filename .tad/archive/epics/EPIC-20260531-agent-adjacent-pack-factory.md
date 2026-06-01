# EPIC: Agent-Adjacent Capability Pack Factory (8 packs, batch-parallel)

**Created**: 2026-05-31
**Mode**: YOLO batch-parallel via Workflow tool (user opted into multi-agent + max-usage)
**Objective**: Mass-produce 8 new agent-adjacent capability packs to fill the real gaps an AI-agent builder hits daily, each research-grounded + anti-slop + behaviorally testable.

## Success Criteria
- 8 packs built: rag-retrieval, agent-memory, llm-observability, ai-guardrails, data-engineering, agent-orchestration, synthetic-data, knowledge-graph
- Each pack: valid YAML frontmatter (name+description+keywords+type), CONSUMES/PRODUCES, Step0 context table, ≥4 reference files with `> Source:` citations, install.sh, ≥1 discriminative behavioral fixture
- Anti-slop bar: every number/tool/threshold traces to a real source URL (no training-data interpolation — architecture.md "Per-Tool Numeric Thresholds Require Research Provenance")
- Each fixture has `discriminative_pattern` of pack-SPECIFIC markers + Anti-Slop ❌ exclusion list (must plausibly FAIL a no-pack control)
- registry regenerated via scan-packs.sh; behavioral-eval-status = pending (honest — verified only after real eval run); collision scan run; ≥1 pack spot-eval'd for real

## Phase Map
| # | Phase | Status | Engine | Key Deliverable |
| 1a | Deep Research (NotebookLM, 8 notebooks) | ✅ Done | Conductor seq | 8 findings.md, ~401 sources, ~370KB cited synthesis (import-all timed out → pivoted to research-status-json report extraction) |
| 1b | Batch Build+Review+Fix (8 tracks) | ✅ Done | Workflow (32 agents, 3.7M tok) | 8 packs, 0 P0 remaining; 4 P0 caught+fixed in-loop (2 fixture-theater, 1 fabricated-number, 1 wrong-OWASP-code) |
| 2 | Integration + Verification | ✅ Done | Conductor (Alex) | registry 16→24; collision scan; behavioral-eval-status 8 pending (3 flipped verified via REAL spot-eval); 8 notebooks registered |
| 3 | (optional) Deepen / P1 follow-ups | ⬚ Planned | Conductor | citation-pointer audit, keyword-overlap signatures, 5 remaining packs real-eval, prompt-caching-min-len gap |

## ✅ COMPLETE 2026-06-01

**8 packs shipped** (24 total registered): rag-retrieval, agent-memory, llm-observability, ai-guardrails, data-engineering, agent-orchestration, synthetic-data, knowledge-graph.

**Quality proof (anti-validation-theater)**:
- Adversarial review+fix loop caught 4 real P0: llm-observability + synthetic-data **fixture-theater** (negative control scored ≥3 → false PASS → fixed to pack-unique markers), agent-orchestration **fabricated ~50-step number** (re-grounded as derived w/ math), ai-guardrails **wrong OWASP code** (LLM08→LLM06).
- REAL spot-eval on 3 packs (WITH-pack vs knowledgeable-no-pack CONTROL): rag-retrieval 13/4 vs 2/4 · llm-observability 4/3 vs 0/3 · synthetic-data 9/4 vs 0/4 — all clean deltas, fixture-theater fixes HOLD on real agent output. These 3 → `verified`; other 5 honestly `pending`.
- Provenance: all packs built from NotebookLM deep research (~401 sources, ~370KB cited synthesis); every number grounded in findings.md.

**P1 follow-ups (tracked, non-blocking)**: see NEXT.md.

## Quality Guardrails (baked into workflow — anti YOLO-audit failure)
1. Research stage returns real source URLs → build grounds every number in them → reviewer checks provenance
2. Behavioral fixture = discriminative (pack-only markers), not vocabulary → reviewer checks it would FAIL no-pack control
3. Reviewers are ADVERSARIAL (told to refute quality + hunt fabricated numbers)
4. Conductor post-workflow: pending-not-verified, real spot-eval, collision scan, no hand-set verified

## Notes
- WebSearch/GitHub-first sourcing inside parallel agents (NotebookLM is stateful → can't parallelize; deep-notebook research is Phase 3 deepening).
- No worktree: 8 packs write to unique dirs (.claude/skills/{name}/ + .tad/capability-packs/{name}/) → zero file overlap.
