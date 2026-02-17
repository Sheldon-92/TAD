# Epic: Alex Flexibility + Learning + Project Management

**Epic ID**: EPIC-20260216-alex-flexibility-and-project-mgmt
**Created**: 2026-02-16
**Owner**: Alex
**Inspiration**: Lenny's Podcast — Zevi Arnovitz (Meta PM) workflow analysis

---

## Objective
让 Alex 从"单一标准 TAD 流程"进化为灵活的多模式助手，同时补齐 TAD 在人类学习机制和项目管理层级上的缺失。最终实现：Alex 能应对 bug 诊断、自由讨论、想法捕捉、标准开发 4 种场景，人类在流程中获得学习机会，产品从 Idea 到 Roadmap 到 Epic 到 Handoff 有完整的管理链路。

## Success Criteria
- [ ] Alex 支持 4 种意图模式（*bug / *discuss / *idea / *analyze），可通过命令或自动检测进入
- [ ] *discuss 和 *idea 路径不会默认走向 handoff 生成
- [ ] *learn 命令可用，Alex 能切换到教学模式
- [ ] Handoff 交出后 Alex 自动提供学习邀请（非阻塞）
- [ ] Idea Pool 目录和模板可用，*idea 路径可存储结构化想法
- [ ] ROADMAP.md 可用，Alex 启动时读取作为上下文
- [ ] *status 命令展示全景视图（Roadmap 主题 / Epic / Handoff / Ideas）
- [ ] Idea 可升级为 Epic 或 Handoff（*idea promote）

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Intent Router (Alex Multi-mode) | ✅ Done | HANDOFF-20260216-intent-router.md | Alex 支持 *bug / *discuss / *idea / *analyze 4 条路径 + 自动意图检测 |
| 2 | Learning Opportunity | ✅ Done | HANDOFF-20260216-learning-opportunity.md | *learn 路径 (Socratic teaching) + standby 定义 + idle 检测 |
| 3 | Idea Pool | ✅ Done | HANDOFF-20260216-idea-pool.md | .tad/active/ideas/ + idea 模板 + *idea-list + 结构化存储 |
| 4 | Roadmap | ⬚ Planned | — | ROADMAP.md + Alex 启动加载 + *discuss 可更新 |
| 5 | Layer Integration | ⬚ Planned | — | *idea promote + *status 全景视图 + 层级流转机制 |

### Phase Dependencies
- Phase 1 是基础设施，Phase 2-5 均依赖于 Phase 1（*discuss / *idea 路径定义）
- Phase 2 独立于 Phase 3-5，可在 Phase 1 之后任意时机实现
- Phase 3 → Phase 4 → Phase 5 顺序依赖（Idea Pool → Roadmap → 整合）

```
Phase 1 (Intent Router)
  ├── Phase 2 (Learning) — 独立分支
  └── Phase 3 (Idea Pool)
        └── Phase 4 (Roadmap)
              └── Phase 5 (Layer Integration)
```

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase

### Completed Work Summary
- **Phase 1: Intent Router** (2026-02-16) — Gate 3 PASS + Gate 4 PASS
  - Added intent_modes to config-workflow.yaml (4 modes, signal words, priority order)
  - Added intent_router_protocol + bug/discuss/idea path protocols to tad-alex.md (+230 lines)
  - Updated CLAUDE.md §2 table (3 new rows)
  - Knowledge entry: "Intent Router: Route Before Process" in architecture.md
  - Key finding: "Route before process" pattern — insert router before existing protocol, don't modify it

- **Phase 2: Learning Opportunity** (2026-02-16) — Gate 3 PASS + Gate 4 PASS
  - Added learn_path_protocol (Socratic teaching, 4-step: identify → assess → teach → wrap up) to tad-alex.md (+~85 lines)
  - Added step1.5 idle detection to Intent Router (conservative heuristic for non-task messages)
  - Added standby state definition with 7 enter conditions and automatic re-trigger
  - Updated Intent Router to 5 modes with 4-option display strategy (recommended + 2 relevant + analyze)
  - Updated config-workflow.yaml (learn mode, priority_order)
  - Updated CLAUDE.md §2 table (+1 row)
  - Knowledge entry: "Mode Addition Checklist Pattern" (5-layer integration) in architecture.md
  - Key decision: Post-handoff learning invite REMOVED — user self-initiates via *learn

- **Phase 3: Idea Pool** (2026-02-16) — Gate 3 PASS + Gate 4 PASS
  - Created .tad/active/ideas/ directory + .tad/templates/idea-template.md (26 lines, 5 fields)
  - Replaced idea_path_protocol step3: NEXT.md → individual IDEA-{date}-{slug}.md files + NEXT.md cross-reference
  - Added idea_list_protocol (*idea-list command: scan → display → view/update/done)
  - Status lifecycle: captured → evaluated → promoted → archived (forward-only)
  - Updated Quick Reference with *idea-list
  - Knowledge entry: "Lightweight Storage Upgrade Pattern" in architecture.md
  - Key pattern: Cross-reference in NEXT.md preserves quick visibility while ideas/ has full detail

### Decisions Made So Far
- Hybrid approach (Option C): Explicit commands (*bug, *discuss, *idea) + auto-detect with confirmation
- ~~Learning: Both *learn command and post-handoff auto-prompt adopted~~ → **Updated**: Post-handoff invite removed, user self-initiates *learn
- Project management: Local files first, MCP integration as optional future enhancement
- Multi-model: Not pursuing "different models for quality assurance" — TAD's existing gate system is sufficient
- Inspiration source: Zevi Arnovitz's workflow (single PM, slash command driven, multi-model, post-mortem learning)
- **P0-1 Decision (2026-02-16)**: Alex NEVER writes code, even for bugs. *bug path = diagnose only + express mini-handoff to Blake. User chose "移除直接修复".
- **P0-2 (2026-02-16)**: Added path transition rules + trigger timing clarification
- **P0-3 (2026-02-16)**: *discuss allowed/forbidden lists clarified; compatible with Research Protocol
- **Phase 2 P0-1 (2026-02-16)**: Post-handoff learning invite removed — user self-initiates *learn when they have questions
- **Phase 2 P0-2 (2026-02-16)**: Idle detection added (step1.5) for non-task messages in standby
- **Phase 2 P0-3 (2026-02-16)**: Signal word overlap *discuss/*learn intentionally kept — resolved by AskUserQuestion + priority_order
- **Phase 2 P0-4 (2026-02-16)**: 5-mode display: recommended + 2 relevant + analyze (always). User can type *learn via "Other"

### Known Issues / Carry-forward
- Alex 的 tad-alex.md 已经很长（~1845 lines），需要注意新增内容的组织方式，避免文件膨胀
- ~~Epic 系统本身未在实战中端到端测试过~~ → Phase 1-2 完成，Epic 系统运作正常
- ~~*bug 路径中 Alex 能否"自己修"需要明确边界~~ → **已解决**: Alex 不修 bug，只诊断
- *learn persistence deferred — no file writes in learning mode (may revisit in future)

### Next Phase Scope
Phase 1: ✅ Complete
Phase 2: ✅ Complete
Phase 3: ✅ Complete
Phase 4 (next): Roadmap — ROADMAP.md + Alex 启动加载 + *discuss 可更新。依赖 Phase 3 的 Idea Pool（已完成）。

---

## Notes
- 此 Epic 源于对 Zevi Arnovitz (Meta PM) 在 Lenny's Podcast 访谈的分析，结合用户实践中的 TAD 痛点
- Phase 3-5 的 MCP 集成（Linear 等）作为可选增强，不列入 Epic 核心 scope
- 此 Epic 也是 TAD Epic 系统的首次实战测试
