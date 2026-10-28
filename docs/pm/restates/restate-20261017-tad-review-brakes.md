# 复述 · TAD · TASK-20261017-TAD-REVIEW-BRAKES-RESEARCH

- **人要（1:1 ET 17:12 2026-10-17）**：「你可以把这个任务给alex，给他一个方向，让他设计方案，或者先做研究」。上下文：人问分角色 review 是否冗余、增量审查，并让看 pstack；PM 建议给 Blake Layer 2 补审查刹车。
- **本段**：Alex · *research → *discuss 方案草稿 · Codex `gpt-6.1-sol` max（非 Blake；不落地；不写 REQ/handoff）。
- **人点头迹**：上句即点名派 Alex 研究+设计 → 理解对了。

## Alex AC
1. 研究来源：Anthropic《Solving code review at Anthropic》https://claude.dev/blog/solving-code-review-at-anthropic/ ；Cursor pstack https://github.com/cursor/plugins/tree/main/pstack （/interrogate、/blast-radius、/create-verification-skill）。
2. 对照 TAD 现状（指针：.agents/skills/blake/SKILL.md ~:930-973,:1036；.tad/ralph-config/loop-config.yaml:127-134；docs/RALPH-LOOP.md:34-35,121-130；Gate2 写法 .agents/skills/alex/references/handoff-creation-protocol.md:816-857；.agents/skills/blake-lite/SKILL.md:313-367）。
3. 方向（PM定）：Layer 2 轮数上限 3 后退回 Alex；第 2 轮起增量审（上轮 finding+修复 diff+被牵连文件）；Pre-existing 分类不卡 Gate 3；每条 finding 处置 fixed/pre-existing/dismissed+理由；波及面检查补漏；多模型共识审与仓级验证技能只评估、可列后续。
4. 产出到 .tad/evidence/pm/2026-10-17-tad-review-brakes/：RESEARCH.md（来源要点+TAD 对照表 file:line）、PROPOSAL.md（改哪些文件、取舍、风险）、STATUS.md（Verdict PASS|CONDITIONAL|FAIL；要人拍的分叉列表；next_knife_candidate）。
5. 硬停：不改 skill/配置/文档正文；不写 REQ/handoff；不派 Blake；不 push/tag/release；新分叉问人不自定。

> 无本路径 → 禁止正式派活。
