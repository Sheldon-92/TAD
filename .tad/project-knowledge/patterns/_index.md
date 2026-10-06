# Knowledge Patterns Index (Layer 2)

> One-line summary per pattern file. Blake's 1_5_context_refresh matches task keywords
> against this index, then loads only the matched pattern files.
> Format: `- [title](filename.md) — one-line hook (max 120 chars)`

---

- [Gate Design](gate-design.md) — Gate responsibility, honest_partial, verification integrity, claims-need-carriers, expert review, YOLO mode, rubric gates, quality gate, Gate 3, Gate 4, blocking, PASS/FAIL
- [Handoff Design](handoff-design.md) — Protocol state machines, lifecycle, scope estimation, worktree grounding, registry state, handoff creation, Epic phase, express, archive, completion report
- [Shell Portability](shell-portability.md) — macOS/BSD compat, grep/awk/jq patterns, heredoc security, CJK locale, env-var convention, bash script, sed, comm, sort, diff, md5
- [AC Verification](ac-verification.md) — AC design, dry-run, extraction-boundary invariants, behavioral fixtures, self-leak prevention, verification commands, AC realism, vacuous AC
- [Process Tax Cut](process-tax-cut.md) — AC realism; Layer2 dirty-tree prior-knife adjudicate; process Gate2 = dual disk reviews (ban wait-for-human /gate 2)
- [Capability Ownership](capability-ownership.md) — Internalized capability vs hidden runtime dependency; require positive behavior plus absence proof
- [Hook Contracts](hook-contracts.md) — Hook events, sub-agent safety classifier, array membership, router.log output contract, PreToolUse, PostToolUse, SessionStart, settings.json
- [Pack Build Rules](pack-build-rules.md) — Pack architecture, pointer/freeze/escalate, invocation-split, hard-vs-soft setup, docs-cache-env, skill-vs-MCP
- [Pack Evaluation](pack-evaluation.md) — Anti-slop, cross-model, discriminative gates, dogfood, blind A/B, 噪声地板, held-out, 一轮一改
- [Research Methodology](research-methodology.md) — Local Wiki primary, WebSearch fallback, cross-model orchestration, source quality, deep research, *research
- [Memory and Learning](memory-and-learning.md) — Staleness detection, compact recovery, trace emission, parser value propagation, knowledge assessment, journal, distillation, reflexion
- [Release & Sync](release-sync.md) — Mirror/parity hazards, gitignore semantics don't survive mirroring, --fix exclusion sets, deny-list at every granularity, privacy leak, parity, rsync
- [Runtime Adapter Checklist](runtime-adapter-checklist.md) — New-runtime onboarding declaration: six dimensions (entry/auth/extensions/permissions/status/evidence), instance-before-wiring rule, residual register R-OC/R-CU
- [Runtime Adapter Instance — Codex](runtime-adapter-instance-codex.md) — Codex 实例六维声明：codex 0.159.3 无头面、ChatGPT 登录态与限额失效信号（exit 1＋厂商原文）、.codex/hooks.json 三点位、workspace-write 沙箱口径、traces 与 live-regression 证据出口
- [Runtime Adapter Instance — Cursor](runtime-adapter-instance-cursor.md) — Cursor 实例六维声明：agent CLI 无头面与 --trust 前置、项目 .cursor/hooks.json 实测触发与垫片转码注入、cli.json permissions 可编程声明面、退出码失败信号、R-CU-1 残项
- [Runtime Adapter Instance — OpenCode](runtime-adapter-instance-opencode.md) — OpenCode 实例六维声明：opencode 1.18.33 run 无头面与 stdin 关闭前置、.opencode/plugins/tad-hooks.ts 四点位映射、permission 配置面实测 deny、事件总线状态信号、R-OC-1/R-OC-2 残项
