# Epic: SKILL Progressive Loading — Body ≤5000 Tokens, On-Demand References

**Epic ID**: EPIC-20260608-skill-progressive-loading
**Created**: 2026-06-08
**Owner**: Alex
**Target Release**: v2.27.0

---

## Objective

将 Alex SKILL.md (6202 行 / 349KB) 和 Blake SKILL.md (2113 行 / 114KB) 的 body 压缩到 ≤5000 tokens (~1500 行)，协议实现移到 references/ 按需加载。这让两个平台都受益：Codex 激活从 65 秒降到 ~10 秒，Claude Code 减少 context 占用。

**核心原则**: "移动，不删除"——所有协议内容完整保留在 references/ 中，body 只保留每次激活必定执行的逻辑。

**安全基线**: v2.7 质量链失效教训——约束规则 (MUST/MANDATORY/VIOLATION/forbidden/BLOCKING) 必须留在 body 中或 body 内有显式引用。grep 计数 (body + references 总和) 不允许下降。

**为什么现在做**:
- Cross-Platform Unification Epic (2026-06-08) dogfood 验证：Codex $alex 激活成功但耗时 65 秒
- Codex Layer 2 推荐 SKILL body ≤5000 tokens，当前 ~80K tokens（16 倍超标）
- Claude Code 也受益于更低的 context 占用

## Success Criteria

- [ ] Alex SKILL.md body ≤1500 行 (~5000 tokens)
- [ ] Blake SKILL.md body ≤800 行 (~2700 tokens)
- [ ] grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden' (body + references 总和) ≥ 瘦身前基线值
- [ ] Claude Code /alex 激活正常，所有 *mode 可用（功能零回归）
- [ ] Codex $alex 激活时间 ≤20 秒
- [ ] anti_rationalization_registry 完整保留在 body 中

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | **Spike — handoff_creation_protocol 提取** | ✅ Done | HANDOFF-20260608-skill-slim-phase1.md | 846 行提取成功，安全计数 142=142，双平台验证 PASS |
| 2 | **Alex SKILL 全量瘦身** | ✅ Done | HANDOFF-20260608-skill-slim-phase2.md | body 6202→1485 行 (-76%)，21 个协议提取，安全计数 142=142 |
| 3 | **Blake SKILL 全量瘦身** | ✅ Done | HANDOFF-20260608-skill-slim-phase3.md | Blake 2114→737 行 (-65%)，5 个部分提取，安全计数 114=114 |

### Phase Dependencies

- **P1 → P2**: Spike 验证"移动不删除"模式可行后才全量执行
- **P2 → P3**: Alex 完成后再做 Blake（同一套模式，降低风险）
- Spike 失败 → STOP（重新评估方案）

### Derived Status

Status and progress are computed from the Phase Map.

---

## Phase Details

### Phase 1: Spike — handoff_creation_protocol 提取

**Status:** ⬚ Planned
**Execution:** pending

#### Scope

从 Alex SKILL.md body 中提取 handoff_creation_protocol (~800 行) 到 references/handoff-creation-protocol.md。验证提取后 Claude Code /alex *handoff 和 Codex $alex 仍正常工作。NOT in scope: 其他协议的提取（Phase 2）、Blake SKILL（Phase 3）。

#### Input

- 现有 .claude/skills/alex/SKILL.md (6202 行)
- 已有的 reference stub 模式（9 个已提取协议）
- 安全基线：grep 计数 before

#### Output

- references/handoff-creation-protocol.md (CREATE — ~800 行)
- SKILL.md body 减少 ~800 行（handoff_creation_protocol 替换为 reference stub）
- 安全验证报告：grep 计数 before vs after

#### Acceptance Criteria

- [ ] AC1: references/handoff-creation-protocol.md 存在且 ≥700 行
- [ ] AC2: SKILL.md body 减少 ≥700 行（before - after）
- [ ] AC3: SKILL.md body 中 handoff_creation_protocol 只剩 reference stub（≤5 行）
- [ ] AC4: grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden' (body + all references) ≥ baseline
- [ ] AC5: Claude Code /alex 激活正常 + *handoff 命令可用
- [ ] AC6: Codex $alex 激活正常（在 /tmp/tad-codex-dogfood 测试）

#### Files Likely Affected

- .claude/skills/alex/SKILL.md (MODIFY — 提取 handoff_creation_protocol)
- .claude/skills/alex/references/handoff-creation-protocol.md (CREATE)

#### Dependencies

None

#### Notes

- handoff_creation_protocol 包含多个 step (step0-step7) + expert_selection_rules + expert_prompt_template
- 其中 expert_prompt_template 和 step1c_lsp 等子协议可能需要作为独立 reference 文件
- 安全基线需要在提取前记录：grep -c 计数 + 行数

### Phase 2: Alex SKILL 全量瘦身

**Status:** ⬚ Planned
**Execution:** pending

#### Scope

将 Alex SKILL.md body 中所有剩余的大协议提取到 references/，最终 body ≤1500 行。NOT in scope: Blake SKILL（Phase 3）。

#### Input

- Phase 1 完成后的 Alex SKILL（已提取 handoff_creation_protocol）
- Spike 验证的"移动不删除"模式

#### Output

- ~15-20 个新 reference 文件
- Alex SKILL.md body ≤1500 行
- 安全验证报告

#### Acceptance Criteria

- [ ] AC1: Alex SKILL.md body ≤1500 行
- [ ] AC2: grep 安全计数 ≥ baseline
- [ ] AC3: Claude Code /alex 所有 *mode 正常（*bug, *discuss, *idea, *learn, *analyze, *express, *experiment）
- [ ] AC4: anti_rationalization_registry 完整保留在 body 中
- [ ] AC5: Codex $alex 激活时间 ≤20 秒

#### Files Likely Affected

- .claude/skills/alex/SKILL.md (MODIFY)
- .claude/skills/alex/references/*.md (CREATE — ~15 个新文件)

#### Dependencies

Phase 1 (spike 验证模式可行)

#### Notes

- 需要提取的大协议包括：intent_router_protocol, adaptive_complexity_protocol, socratic_inquiry_protocol, research_decision_protocol, design_protocol, acceptance_protocol, express_path_protocol, experiment_path_protocol, cancel_protocol, research_plan_protocol, optimize_protocol, evolve_protocol, dream_protocol, publish_protocol, sync_protocol, yolo_execution_protocol
- 每个协议的 forbidden_implementations 必须留在 body 或有显式引用

### Phase 3: Blake SKILL 全量瘦身

**Status:** ⬚ Planned
**Execution:** pending

#### Scope

为 Blake SKILL.md 创建 references/ 目录，将协议实现提取出去，body ≤800 行。

#### Input

- Phase 2 完成后的 Alex SKILL 作为参考模式
- Blake SKILL.md (2113 行)

#### Output

- .claude/skills/blake/references/ 目录 (CREATE)
- ~8-10 个 reference 文件
- Blake SKILL.md body ≤800 行

#### Acceptance Criteria

- [ ] AC1: Blake SKILL.md body ≤800 行
- [ ] AC2: grep 安全计数 ≥ baseline
- [ ] AC3: Claude Code /blake 正常工作
- [ ] AC4: Codex $blake 激活正常
- [ ] AC5: .claude/skills/blake/references/ 存在且有 ≥5 个 .md 文件

#### Files Likely Affected

- .claude/skills/blake/SKILL.md (MODIFY)
- .claude/skills/blake/references/*.md (CREATE — ~8 个新文件)

#### Dependencies

Phase 2 (Alex 模式验证后再做 Blake)

---

## Context for Next Phase

### Completed Work Summary
- Phase 1 (2026-06-08): handoff_creation_protocol 846 行提取到 references/，body 6202→5361 行 (-14%)，安全计数 142=142 精确匹配 (commit 96e02b9)
- Phase 2 (2026-06-08): 21 个协议全量提取，body 5361→1485 行 (-76% total)，31 个 reference 文件，安全计数 142=142，intent_router 23 行加强版 stub (commit cb56049)
- Phase 3 (2026-06-08): Blake 5 个部分提取，body 2114→737 行 (-65%)，5 个 reference 文件，安全计数 114=114 (commit 6f06e94)

### Decisions Made So Far
- 2026-06-08: 目标两平台受益，body ≤5000 tokens (~1500 行 Alex, ~800 行 Blake)
- 2026-06-08: 保留原则——"每次激活都跑的"留 body，"特定模式才跑的"移 references/
- 2026-06-08: 安全验证——grep 计数 (body + references) 总和不下降
- 2026-06-08: 回滚策略——Git revert
- 2026-06-08: Spike 选 handoff_creation_protocol (~800 行，最大最复杂)

### Known Issues / Carry-forward
- v2.7 质量链失效：精简时删除了约束规则 → 本次用"移动不删除"策略
- Codex Layer 2 推荐 ≤5000 tokens，但我们的 SKILL 包含大量 YAML 结构（token 密度比纯文本高）
- anti_rationalization_registry 必须留 body（安全审计 grep 目标）
- Blake SKILL 目前没有 references/ 目录（Phase 3 从零创建）

### Next Phase Scope
Phase 1: Spike — handoff_creation_protocol (~800 行) 提取到 references/

---

## Notes

### 与前序 Epic 的关系
- 前序：EPIC-20260608-cross-platform-unification（已完成）
- 该 Epic 的 Phase 3 dogfood 发现了 SKILL body 过大的问题
- 本 Epic 解决该问题，是跨平台统一架构的"最后一公里"

### Safety Contract
本 Epic 操作的是 TAD 最核心的文件。每个 Phase 的 Gate 3 必须包含：
1. grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden' 计数对比
2. Claude Code /alex 或 /blake 激活验证
3. Codex $alex 或 $blake 激活验证
