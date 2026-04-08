# Epic: Domain Pack 可靠加载机制

**Epic ID**: EPIC-20260407-domain-pack-reliable-loading
**Created**: 2026-04-07
**Owner**: Alex

---

## Objective

让 Alex 和 Blake 在所有相关任务流程中**可靠地**加载并应用对应的 Domain Pack。从依赖 LLM 自觉转为系统级强制机制，覆盖所有任务入口（`*analyze`、`*bug`、`*discuss`、Blake 实现阶段）。

## Success Criteria

- [ ] 用户描述任务时如果匹配某个 Domain Pack，Alex/Blake 100% 加载该 pack（当前估计 < 30%）
- [ ] 加载机制覆盖所有入口：`*analyze`、`*bug`、`*discuss`、Blake 实现起始
- [ ] Hook 平均延迟 < 500ms，每条用户消息额外成本 < $0.0002
- [ ] 误报率（无关任务被注入 pack 提示）< 10%
- [ ] Hook 失败时降级为不注入，绝不阻塞 session

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Spike: Hook 可行性 + Haiku 准确率验证 | ✅ Done | HANDOFF-20260407-domain-pack-hook-spike.md | SPIKE-REPORT verdict: PARTIAL (integration:GO / accuracy:GO / latency:NO-GO-proxy-caveat) |
| 2a | 微 spike: 验证 type:prompt 对 UserPromptSubmit 契约 | ✅ Done | HANDOFF-20260407-phase2a-prompt-hook-contract-spike.md | NO-GO on type:prompt for injection. Decisive contract evidence + stdin payload schema |
| 2b | Architecture C 实现:type:command hook + 关键词匹配 | 🔄 Active | TBD | bash hook 脚本 + 关键词 YAML + skill 检查点 |
| 3 | 多 Pack 集成测试 + 准确率/误报率数据 | ⬚ Planned | — | 5+ 真实场景测试报告 |
| 4 | (Optional) Tuning：阈值/prompt/检查点位置调整 | ⬚ Planned | — | 调优后的 hook v2 |

### Phase Dependencies

Phase 1 → Phase 2 → Phase 3 → Phase 4 (顺序执行)。Phase 4 是可选的，如果 Phase 3 数据已经达标可跳过。

### Derived Status

- **Status**: Planning（所有 phase 为 ⬚）
- **Progress**: 0/4

---

## ⚠️ 关键注意事项 / 风险

### 技术风险

1. **Claude Code 是否支持 UserPromptSubmit hook？**
   - 这是 Phase 1 spike 的核心问题
   - 如果不支持，fallback 是 PreToolUse on Skill，但触发时机会晚（用户已经开始执行命令）
   - **必须先验证再设计**

2. **Haiku Prompt 设计是关键**
   - 输入：user message + N 个 capabilities 列表（当前 14 个 pack × 多个 capabilities = ~80 个）
   - 输出：匹配的 pack 名 + 置信度
   - Prompt 太宽 → 误报飙升；太严 → 漏报
   - 需要 Phase 1 spike 测试多种 prompt 模板

3. **跨平台兼容（macOS/Linux Bash 差异）**
   - 历史教训：之前踩过 `grep -P` 在 macOS BSD 上不支持的坑（见 `architecture.md` 知识："Hook Shell Portability"）
   - 这次写 hook 必须只用 BSD-compatible 命令
   - Hook case pattern 必须用 `*.tad/` 而非 `*/.tad/`（见同上知识）

### 设计风险

4. **additionalContext token 膨胀**
   - 如果每条消息都注入完整 pack 提示，长会话上下文会爆
   - 需要"已加载就不再提示"的去重机制
   - 状态存储位置：可能用 `.tad/.session-state` 临时文件

5. **Hook 失败必须降级**
   - Haiku 超时（>10s）/ API error / 网络问题都不能 block 用户
   - 设计原则：hook 永远 exit 0，注入失败就不注入
   - 参考：startup-health.sh 的设计

6. **预留 Recipe 字段（Epic 3 接口）**
   - Hook 输出 schema 现在就要为未来 recipe 匹配预留字段
   - 避免 Epic 3 时大改 hook 接口
   - 例如输出 schema：`{matched_packs: [...], matched_recipes: []}`，recipes 现在恒为空

### 流程风险

7. **Skill 检查点不能成为新的"自觉机制"**
   - 单纯在 skill 文件加 "remember to load pack" 还是会失效（这就是当前的问题）
   - 检查点必须配合 hook 注入的 system-reminder 才有强制力
   - skill 检查点的角色是"hook 的二次确认"，不是主防线

8. **Blake 侧不能漏**
   - 当前 Blake 只在 handoff 有 `Domain Pack References` section 时才读 pack
   - 如果 Alex 漏了，Blake 必然漏（cascading failure）
   - Hook 必须同时覆盖 Alex 和 Blake 两个 terminal

---

## Context for Next Phase

### Completed Work Summary

**Phase 1 (✅ Done, 2026-04-07, ~50 min actual)**:
- Verified `UserPromptSubmit` hook event EXISTS and FIRES in Claude Code 2.1.92 (3/3 sentinel hits + 3/3 MARKER_SEEN responses)
- Haiku-4.5 classification accuracy 93.75% on high-confidence labels (15/16) — well over 80% bar
- Recipe envelope schema (`matched_packs` + `matched_recipes`) validated
- Settings.json byte-identical restore verified (sha256)
- Architecture.md gained "UserPromptSubmit Hook Verified" entry
- Verdict: ✅ PARTIAL — Phase 2 unblocked

### Decisions Made (Phase 1 → Phase 2 carry-forward)

1. **TC04 label dispute resolution (Alex's design call)**:
   "组件状态管理用 useState 还是 useReducer?" type discussion questions should be **context-aware matched**:
   - Under `*analyze` path → strict mode (only intent-to-build = match)
   - Under `*learn` / `*discuss` path → loose mode (discussion also = match)
   Phase 2 hook design must accept an "intent context" hint from the Intent Router and pass it to the Haiku prompt.

2. **Latency measurement is invalid until re-measured**:
   Phase 1's 4567ms mean is a `claude -p` proxy artifact (process spawn + 19k cache_creation tokens + extended thinking). Phase 2 **first action** must be: configure ANTHROPIC_API_KEY and re-run accuracy + latency benchmark via direct curl with `max_tokens: 80`. If direct API still > 1500ms → take NO-GO fallback (build-time matching).

3. **Haiku JSON fence stripper is mandatory**:
   Haiku-4.5 ALWAYS wraps JSON in ```json fences despite explicit instruction. Production hook MUST include a fence-stripper OR use stop_sequences. Non-negotiable.

4. **3 deferred code-reviewer P0s** (from spike review, deferred because spike script was one-shot):
   - Path injection risk in run-spike.sh
   - Atomic write missing for results.json
   - Minor code style issues
   **If Phase 2 reuses any spike artifact (test-cases.yaml, prompt template are likely candidates)**, these P0s become Phase 2 preconditions. If Phase 2 writes a fresh hook script, they're discharged.

### Known Issues / Carry-forward

- **Proxy mode latency uncertainty**: 4567ms mean has no signal until re-measured with direct API
- **Haiku output format drift**: 18/18 raw responses had ```json fences (100% format violation despite prompt rules)
- **Single-capability test only**: Phase 1 used only `web-frontend.component_development`. Phase 2 must test multi-pack disambiguation
- **Cost question open**: $0.0054/call OAuth tier vs $0.0002/call API target — unconfirmed

### Phase 2 Split Rationale (2026-04-07 post-expert-review pivot)

**Original Phase 2 plan**: single handoff doing contract verification + production hook + skill changes.

**Why split into 2a + 2b**: Expert review (code-reviewer + backend-architect) on the Phase 2 draft surfaced 4 P0 issues:

1. **Contract unverified at deeper level**: Phase 1 validated UserPromptSubmit event via `command` type hook. But Phase 2 wants `type: prompt` — and existing PreToolUse prompt hook returns `{"ok":bool}` (permission gating), NOT `additionalContext` envelope. The substitution variable name (`$ARGUMENTS`?), payload shape, and injection response contract are ALL unverified.
2. **Pack count wrong**: Alex said "14 packs"; actual count in `.tad/domains/` is **20 production packs** (~160 capabilities total). Prompt size impact ~10k input tokens.
3. **UX latency disaster**: UserPromptSubmit fires on every message including "yes"/"ok"/"继续". Without pre-filter, a 5-round Socratic inquiry gets taxed 5× the Haiku latency. Within a week user would remove the hook.
4. **Skill checkpoint "secondary defense" was incoherent**: trigger fires only when hook successfully injects → fully coupled to primary mechanism → not a defense.

**Token cost (P0-2)** was NOT a real problem — user is on Claude Code Max, token cost is absorbed by subscription.

**Split resolution**:
- **Phase 2a (this active phase)**: Micro-spike (~30 min) to verify contract, measure real latency, test pre-filter approach in prompt
- **Phase 2b (planned)**: Production hook design based on 2a's real data. Will include:
  - Pre-filter (early-exit for trivial messages)
  - Honest defense framing (rename `domain_pack_loading_enforcement`, no fake defense-in-depth claim)
  - Auto-generated capability list from `.tad/domains/*.yaml` (all 20 packs)
  - Exact skill file insertion points (line ranges, not abstract refs)
  - Step 5 test set = reuse Phase 1's 18 cases (not regress to 5)

### Phase 2a Findings (✅ Done 2026-04-07)

**Architecture A is DEAD**. Decisive evidence from 5 probes:

| Contract | Result |
|----------|--------|
| A (explicit `hookSpecificOutput` envelope) | ❌ Discarded by Claude Code |
| B (auto-find `additionalContext` field) | ❌ Discarded |
| C (`{ok:bool, reason:str}` permission gate) | ✅ Works — but ONLY as gate, NOT injection |

**Smoking gun**: P3b sent `{ok:false}` → Claude Code blocked the message (`result=""`, model never ran). Proves Contract C is real, not silent ignore.

**Bonus discoveries**:
- `type: prompt` on UserPromptSubmit is **permission gate only** (same as PreToolUse `type:prompt`)
- For context injection, MUST use `type: command` (Phase 1 proven pattern)
- stdin payload for command hooks: `{session_id, transcript_path, cwd, permission_mode, hook_event_name, prompt}` — user message is in **`prompt`** field, NOT `$ARGUMENTS`
- Architecture.md updated with sub-finding (existing UserPromptSubmit Verified entry extended)

### Phase 2a → 2b Decisions (Alex Gate 4)

1. **Architecture pivot**: A → C (keyword matching) — user explicit choice
2. **AC12 deviation accepted**: Blake used `claude -p` instead of new terminal; P3b smoking gun proves hook output IS processed in `-p` mode (else blocking wouldn't work). Equivalent to Phase 1's sentinel-based ground truth.
3. **No retroactive 5-min interactive smoke test required** (research reviewer's optional rec)

### Next Phase Scope (Phase 2b — Architecture C)

**Phase 2a: Contract + Latency Micro-Spike** (~30 min)

Verify 3 things before designing production hook:
1. Does `type: prompt` work with UserPromptSubmit event?
2. What's the exact response contract for additionalContext injection?
3. Real latency with realistic prompt size (not echo test)
4. Bonus: can in-prompt pre-filter (early-exit for short messages) work?

If 2a GO → 2b handoff will be designed with full knowledge of the contract.
If 2a NO-GO → escalate to Alex for architecture C (keyword matching) redesign.

### Next Phase Scope (Phase 2b - planned)

**Phase 2b: Hook 实现 + Skill 强制检查点**

Sub-phases (recommend running as a single Standard TAD task):

1. **Latency re-validation** (~30 min): direct curl benchmark, max_tokens: 80, ≥10 cases. Hard gate: if mean > 1500ms → switch to NO-GO fallback (build-time matching). Otherwise → proceed.
2. **Production hook design**: `userprompt-domain-router.sh` script + settings.json integration. Pattern follows existing PreToolUse prompt hook. Must include fence-stripper, intent-context routing (TC04 decision), confidence threshold (≥0.7).
3. **Domain Pack discovery**: hook reads `.tad/domains/*.yaml` capabilities at session start, caches them. Re-classification only when capabilities change.
4. **Skill checkpoint hardening**: add explicit "Read Domain Pack" mandatory steps to Alex's `*analyze` step1 and Blake's implementation_start. Hook is primary defense, checkpoints are secondary.
5. **Integration test**: 5+ real task scenarios across 3+ packs, measure end-to-end accuracy.

### Background

由用户在 2026-04-07 提出。当前 Domain Pack 加载机制的问题：

- **没有用 Haiku 判断**：现状是 SessionStart hook 把 pack 列表注入为被动文本 blob，依赖 LLM 自觉扫描匹配
- **检查点严重不足**：只有 `*design` step1_5 和 `*discuss` 首次回答有显式加载逻辑
- **Blake 完全依赖上游**：Alex 漏了 Blake 必漏

用户接受方案 B + A（Haiku UserPromptSubmit hook + Alex/Blake 强制检查点）。

### Decisions Made So Far

- **方案选择**：B + A 组合（hook 为主防线，skill 检查点为次防线）
- **预留 Recipe 接口**：为未来 Epic 3（Cross-Project Skill Harvest）的 hook 复用做准备
- **Phase 1 必须 spike**：先验证 Claude Code 是否支持 UserPromptSubmit hook，避免设计走死路

### Next Phase Scope

**Phase 1: Spike**
- 验证 UserPromptSubmit hook（或 fallback 方案）的 Claude Code 支持情况
- 写一个最小 PoC：1 个 capability（如 `web-frontend.component_development`）
- 用 5-10 条真实 user message 测试 Haiku 分类准确率
- 测延迟（端到端从 user 输入到注入 system-reminder）
- 输出可行性结论 + 推荐方案 + 准确率/延迟数据

---

## Notes

- 这个 Epic 是 "Domain Pack 三连 Epic" 的第一个：
  - **Epic 1（本文）**：Domain Pack 可靠加载
  - **Epic 2（idea，待 promote）**：本地 Skill 捕获机制
  - **Epic 3（idea，待 promote）**：跨项目 Skill Harvest
- Epic 2 和 Epic 3 暂存为 ideas，等 Epic 1 完成后再 promote
- Epic 1 的 hook 设计要为 Epic 3 留扩展接口
