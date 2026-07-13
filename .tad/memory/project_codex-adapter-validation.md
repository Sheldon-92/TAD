---
name: project_codex-adapter-validation
description: "Codex adapter 端到端验证全 PASS (2026-06-07) — 13 能力项 + 2 高风险假设,定位升级为\"一等公民\""
metadata: 
  node_type: memory
  type: project
  originSessionId: a474a854-fdd2-475f-b7b0-fde1260d30c6
---

2026-06-07 首次验证 TAD Codex adapter（此前从未验证"造的钥匙能不能开真锁"）。在 Alex session 内用真实 `codex exec`(codex-cli 0.130.0, gpt-5.5) 跑了 9 个实验,全部 PASS。

**已验证 13 项能力**: 激活 · grounding(真读文件) · 苏格拉底提问 · design-only(Alex 不写代码) · handoff 产出 · 文件写入 · 零越界 · Gate 3 · Layer 2 review · 多轮 resume 上下文保持 · Gate 失败返工(Ralph Loop,改实现非改测试作弊) · **专家审查(并行→顺序 reviewer 不同质化,质量不输 Claude)** · **交互入口(AGENTS.md "当 Alex" 角色路由)**。

**两个新发现(对 adapter 有用)**:
- `codex exec "<prompt>"` 不带 stdin 会阻塞在 "Reading additional input from stdin..."(非交互/后台) → 脚本化须 `</dev/null` 或 `cat file | codex exec`。真 TUI `codex` 无此问题。
- `codex exec resume` 不接受 `-s` flag(sandbox 继承自原 session)。

**用户决策**: Codex 通道定位 = **一等公民**(非仅应急 fallback)。

**剩余 roadmap**: 跨模型(codex 调 gemini) · 改已有代码正式压测(Codex 无 LSP,step1c_lsp degrade 到 grep) · 完整 Gate 4 验收 · **固化 eval harness(下一步最该做 — 锁成回归,补 parity gate 查不出的"行为漂移")** · n>1 稳定性 · 真 TUI 交互体验。

**首个"一等公民"交付落地 (2026-06-07, commit 18a7e80, Gate 4 PASS+归档)**: npx 跨平台安装器 — 选平台(Codex 装 13K 瘦版,deny-delta 排除 86K alex/blake SKILL + hooks) + 选 packs 带一句话介绍(超越 BMAD 的纯代号)。复用 tad.sh 不重写(2026-05-28 铁律);tad.sh 加 `--platform`/`--packs` + while-loop parser + parse_platform_extra_deny + verifier scope + KNOWN_PLATFORMS ordering 解。**专家审查在设计阶段拦截 allow-list 复发(P0-2,未进实现)** = deny-delta 原则(principles 2026-06-01)首次扩展到平台维度。研究: `.tad/evidence/research/npx-installer-benchmark/`(BMAD 深挖 + landscape notebook 31445e5a:QwenPaw hot-load / GitLaw 模块化 / Letta paging / BMAD web bundles)。分发推荐 Option A(`npx github:Sheldon-92/TAD#v2.24.0`)。

报告: `.tad/evidence/codex-validation/REPORT-2026-06-07.md`;证据: `.tad/evidence/codex-validation/`(transcripts + sandbox + flawed-handoff)。
相关: [[project_conductor-architecture]](codex parity epic 背景)。
