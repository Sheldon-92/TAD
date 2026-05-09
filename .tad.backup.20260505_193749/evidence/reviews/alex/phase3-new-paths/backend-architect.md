# Alex Pre-Handoff Review — backend-architect

**Phase:** 3 — New Paths for Real Usage Patterns
**Reviewer:** backend-architect (Alex-side, pre-handoff to Blake)
**Date:** 2026-04-24
**Source:** Extracted from `HANDOFF-20260424-phase3-new-paths.md` §10 Audit Trail

## Verdict
**CONDITIONAL PASS → PASS** (3 P0 + 4 P1 + 4 P2 all Resolved post-integration)

## P0 Findings

### P0-1: Intent Router 7-mode vs AskUserQuestion 4-option 溢出
- **What:** 现 step3 hardcoded 5-mode display strategy; Phase 3 加 *express + *experiment = 7 mode，6 候选 modes 抢 3 非 analyze 槽位，未指定 tiebreaker
- **Why P0:** Intent Router 是 ALL paths 的 gatekeeper; 未定义 display rule 产 nondeterministic UX
- **Resolution:** §P3.1.b step3 7-mode display strategy 扩展 + priority_order tiebreaker (in config-workflow.yaml.intent_modes.detection.priority_order); analyze 始终在第 4 位; *express 永不 pre-selected as Recommended; AC-P3.1-k fixture

### P0-2: experiment Gate "REPLACES" 太激进
- **What:** P3.2 用 `gate3_focus_replacement` 语义 — 原 build/test/lint 不再 apply。但 experiment harness 含真代码（rubric runner / fixture loader / eval scripts），harness syntax error 时实验空跑但 Gate 显示 PASS
- **Why P0:** Quality regression vector; combined with `task_type=experiment` 跳 Adaptive Complexity，实验 handoff 可能 ship broken harness 同时双 Gate 通过
- **Resolution:** §P3.2.a 重命名 gate3_focus_AUGMENTATION (not _replacement); semantics 显式 "AUGMENT not REPLACE"; 5 实验检查项是 ADDITIONAL; 原 Gate 3/4 仍 apply for harness code; AC-P3.2-h fixture (harness syntax error → Gate 3 FAIL)

### P0-3: skip_KA 缺 forbidden_implementations clause
- **What:** P3.1 + P3.2 各有 5-item forbidden_implementations 防 hook/settings.json 机械化。P3.3 没有 — Anti-Epic-1 attack surface 不对称
- **Why P0:** Misguided implementer 可能加 PostToolUse hook 自动 skip step7A based on frontmatter，that IS 机械 enforcement (2026-04-15 取消的 pattern)
- **Resolution:** §P3.3.c 加 5-item forbidden_implementations 同 P3.1/P3.2 parity; AC-P3.3-g extended grep 含 `skip_knowledge.*hook|knowledge_assessment.*hook` 返回 0

## P1 Findings

### P1-1: path_transitions matrix 不全
- **Resolution:** §P3.1.b path_transitions 完整: 3 new allowed (express→analyze, express→experiment, experiment→analyze) + forbidden (analyze→express, analyze→experiment 防 AR-001 中途降级 attack)

### P1-2: AskUserQuestion-as-suggestion 漏洞
- **What:** Decision #5 "Alex 不可推荐 *express in adaptive_complexity step2" 字面对，但 Intent Router step3 始终显 AskUserQuestion；signal detection 如倾向 *express 可能 pre-select Recommended → Alex 满足字面但违反精神 (letter-not-spirit attack)
- **Resolution:** §P3.1.a trigger.NOT_via_alex_suggestion 加三条规则 (a/b/c)，第二条显式 "step3 MUST NOT pre-select *express as Recommended"; AC-P3.1-j fixture

### P1-3: ai-evaluation pack auto-load 契约未定义
- **What:** P3.2 说 *experiment 跟 ai-evaluation pack "互补不冲突" 但未定义 WHEN pack loads。其他 pack 通过 UserPromptSubmit keyword hook 加载，但 *experiment 是 router mode 不是 keyword
- **Resolution:** §P3.2.a domain_pack_auto_load 显式: experiment_path_protocol step1 强制 Read .tad/domains/ai-evaluation.yaml; AC-P3.2-i fixture

### P1-4: AC count 错乱 (重叠 CR-P0-1)
- **Resolution:** 同 CR-P0-1 解决

## P2 Findings (all Resolved)
- step7 missing-section behavior PARTIAL not FAIL (BA-P2-1)
- Audit Trail 在 *express 中保留 (BA-P2-2)
- Layer 2 audit decouple skip_KA (BA-P2-3)
- Real-archive backward-compat fixture (BA-P2-4)

## Architect Assessment
The handoff is **structurally sound**, **dogfoods Phase 1+2 correctly**, and respects **2026-04-15 Mechanical Enforcement Rejected boundary** on its two flagged paths. The 3 P0s are surgical: (1) Intent Router 7-mode step3 logic, (2) Gate AUGMENT-not-replace, (3) skip_KA forbidden_implementations parity. Address those before moving to Gate 2; P1s should fold into the same revision pass since they share files.
