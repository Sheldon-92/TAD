# Handoff: TAD v2.8 Phase 5 — Version Bump + Release

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-002
**Epic:** EPIC-20260402-tad-v28-self-evolving.md (Phase 5/5 — FINAL)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task

Version bump 2.7.0 → 2.8.0, CHANGELOG, reference integrity check.

## 2. Version Bump

| File | Field | 2.7.0 → 2.8.0 |
|------|-------|----------------|
| `.tad/config.yaml` | `version:` | 2.8.0 |
| `.tad/config.yaml` | `description:` | 加 "Self-Evolving" |
| `.tad/version.txt` | 全文 | 2.8 |
| `tad.sh` | `TARGET_VERSION` | 2.8 |
| CLAUDE.md | 版本引用 | 检查更新 |
| Alex SKILL.md | `<!-- TAD v2.7.0 -->` | v2.8.0 |
| Blake SKILL.md | 版本引用 | 检查更新 |

## 3. CHANGELOG

```markdown
## [2.8.0] - 2026-04-03

### New Features — Self-Evolving Framework
- **Execution Trace Recording**: PostToolUse hook auto-records file events (JSONL)
- **Step-Level Trace**: trace-step.sh CLI for Domain Pack step start/end recording
- **`*optimize` Command**: Analyze project traces → propose Domain Pack + Project Knowledge improvements
- **`*evolve` Command**: Cross-project trace aggregation → propose TAD framework improvements
- **Human Approval Workflow**: PROPOSAL YAML schema + AskUserQuestion approval + safety constraints
- **Quality Gate Hooks**: pre-accept-check.sh (BLOCK without COMPLETION), pre-gate-check.sh (BLOCK Gate 3 without evidence)

### Domain Packs (14 packs, 6 research areas)
- Phase 1 Web: product-definition, web-ui-design, web-frontend, web-backend, web-testing, web-deployment
- Phase 2 Mobile: mobile-ui-design, mobile-development, mobile-testing, mobile-release
- Phase 3 AI: ai-agent-architecture (9 caps incl self-improvement), ai-prompt-engineering, ai-tool-integration, ai-evaluation
- tools-registry.yaml: 35+ tools across all packs
- Domain Pack creation template + HOW-TO guide + ROADMAP

### AI Agent Self-Improvement
- self_improvement_design capability with 6-step design process
- 6-environment reference table (OpenClaw, LangSmith, Firebase RC, Langfuse, Claude Code, Enterprise)
- Based on production research (Meta-Harness, EvoAgentX, NeMo Guardrails, DeerFlow)

### Quality Enforcement
- pre-accept-check.sh: BLOCK *accept without COMPLETION report (exit 2)
- pre-gate-check.sh: BLOCK /gate 3 without evidence (cold-start safe)
- Enhanced post-write-sync.sh: COMPLETION→Gate3 reminder, HANDOFF→expert review 4-step checklist, Ralph Loop→workflow reminder
- Batch expert review of all 6 initial Domain Packs (4 P0 fixed)

### Architecture Knowledge
- Domain Pack Step Model: Type A (doc) / B (code) / Mixed
- Hook path matching: *.tad/ for relative+absolute
- Judgment-only skill files: 76% reduction safe when hooks handle automation
- Claude Code enforcement priority: deny > hooks > allow
```

## 4. config.yaml version_history

Add v2.8.0 entry.

## 5. Reference Integrity

```bash
grep -rn "v2\.7\|2\.7\.0" . --include="*.md" --include="*.yaml" --include="*.sh" --include="*.txt" | grep -v archive | grep -v backup | grep -v spike | grep -v node_modules | grep -v .git | grep -v version_history | grep -v CHANGELOG
```

## 6. AC

- [ ] AC1: config.yaml version = 2.8.0
- [ ] AC2: version.txt = 2.8
- [ ] AC3: tad.sh TARGET_VERSION = 2.8
- [ ] AC4: No v2.7 in active files (except version_history/CHANGELOG)
- [ ] AC5: CHANGELOG has v2.8.0 entry
- [ ] AC6: config.yaml version_history has v2.8.0
- [ ] AC7: settings.json valid JSON
- [ ] AC8: All hooks pass bash -n
- [ ] AC9: Alex/Blake SKILL.md line counts unchanged (except version refs)

## 7. Domain Pack Roadmap 更新

更新 `.tad/domains/DOMAIN-PACK-ROADMAP.md`：
- Phase 3 AI: 全部标 ✅（4/4 完成，含 self_improvement_design 补充）
- 更新 ai-agent-architecture 行数（+59 行）
- 更新 tools-registry 行数和工具数
- 更新全景进度图

## 8. NEXT.md 更新

更新 NEXT.md 反映 v2.8 完成状态。

## 9. Notes

- ⚠️ Do NOT push or sync — user will do manually
- ⚠️ Only change version refs, not content
- ⚠️ CHANGELOG is comprehensive — this is the biggest release since v2.0

**Handoff Created By**: Alex
