# Code Review — HANDOFF-20260730-tad-lite-channel

**Reviewer**: code-reviewer (narrow-scope, pre-implementation)
**Date**: 2026-07-30
**Verdict**: CONDITIONAL PASS
**插入点核实**: CLAUDE.md L9 豁免行 / L22 `/blake` 行均存在且在 L100 标记上方 ✓；`grep -n handoffs` 仅 L7/L52，豁免不与其他规则冲突 ✓

## P0 (7)

- **P0-1** — reviewer prompt 用 `git diff`：对新建（untracked）文件输出为空 → reviewer 无对象可审，必然假 PASS，精髓 1 失效。Fix: prompt 改 `git status --short` 确认改动集 + `git diff HEAD -- <路径>` + 新建文件直接 Read 全文 + 明示"禁止仅凭 git diff 判断"。
- **P0-2** — 升级审查"其中一个在实现前先审"写在 L3（实现后）→ 时序不可能，敏感文件唯一额外保护不存在。Fix: 提升为独立 L0.5 步骤（BLOCKING，在 L1 前），FAIL/P0 → 停；Forbidden 加"escalated yes 却直接进 L1"。
- **P0-3** — blake-lite L0 step3 字面逻辑使 `escalated_review: yes` 成为 fatal operations 通行证，与 alex-lite "fatal 无例外必须 full" 矛盾；例外条款没随清单一起重复。Fix: 三分支改写（fatal 无条件停 / 其余三类无 yes 停 / 有 yes 进 L0.5）。
- **P0-4** — CLAUDE.md §3 规则 0/1/2/3/5 + §4 同-terminal CRITICAL + §1 "跳过 Gate/不通过 Blake" 禁令均与 lite 明文冲突，§5 "违规→立即停止" 使正确加载 CLAUDE.md 的 agent 跑 lite 即处于违规态。Fix: §1 豁免行覆盖禁令句 + §3 末尾作用域限定行 + §4 不改而改 alex-lite L3 措辞（"由人输入 /blake-lite；agent 不得自行调用"）。
- **P0-5** — AC2 self-leak：SKILL 正文的自包含**禁令文本**本身含 `references/` → 假 FAIL；二阶风险 = Blake 删禁令让 AC 变绿（AC 销毁它保护的约束）。且 `config-.*\.yaml` 匹配不到 `.tad/config.yaml`（假阴性）。Fix: 只抓运行时加载指令 `(Read|读取|加载)[^\n]*(references/|\.tad/config)` + `^\s*load_when:`，Expected 注明禁令句不计入 + 人工复核 grep -n 行上下文。
- **P0-6** — handoff 定位黑名单（只拒 HANDOFF-*）可被 EPIC-*/COMPLETION-*/改名文件穿过；"最新"未定义；无状态检查（DONE 文件会被重复实现）。MQ5 声明的状态机没有任何步骤实现。Fix: 白名单准入（basename 必须 LITE-*.md + 无 `## Completion` 段 + 同日多文件请人指定）。
- **P0-7** — AC10 `git diff --name-only` 看不到 untracked/staged → NFR1 唯一守卫真空通过；`settings.json` 匹配不到 settings.local.json。Fix: `git status --porcelain | awk '{print $NF}' | grep -cE 'settings(\.local)?\.json|\.tad/hooks/|\.tad/config[^/]*\.yaml|skills/(alex|blake|gate)/|^tad\.sh$'` = 0。（确认安全项：`skills/(alex|blake|gate)/` 可捕获 references/ 且不误伤 alex-lite。）

## P1 (9)

- **P1-1** — §4.2 未内嵌清单原文却要求"全文重复"（授权现场再造）；AC9 是 LLM 判断非可运行。Fix: 哨兵注释块 `<!-- ESCALATION-LIST-BEGIN/END -->` + sed 提取 diff = 0 + 非空断言。
- **P1-2** — 清单漏 `.agents/skills/*/SKILL.md`、`tad.sh`、`.claude/settings.local.json`。
- **P1-3** — "全绿才进 L3" 无 honest_partial 出口 + Forbidden 禁改 AC = AC 卡住时无合法路径。Fix: "AC BLOCKED: {原因}" 报告人裁定的合法出口。
- **P1-4** — 自审替代 subagent 未被禁令命名。Fix: Forbidden 加"以自审替代 spawn"+"禁止把实现推理塞进 reviewer prompt"。
- **P1-5** — blake-lite 无"改清单外文件"兜底禁令（2 个以内静默合法）；Forbidden 未涵盖 git commit/push、归档移动、写 project-knowledge。
- **P1-6** — escalated_review 是无出处布尔值，alex-lite 可自我授权。Fix: 字段带用户原话 `escalated_review: yes (用户原话: "...")` + 双侧禁令/检查。
- **P1-7** — AC3 全局计数证不了四类完整且漏 blake-lite；AC4 恒真（prompt 模板必含 P0）；AC5 期望与命令不一致。Fix: 分类别锚点 loop（4 keys × 2 files）+ 锚点句 grep。
- **P1-8** — AC11 会被 Evidence Manifest 强制产物 + hook 落盘 jsonl 假 FAIL。Fix: 允许集明确化 + `grep -vE` 可运行形式。
- **P1-9** — FR7/NFR2/≤N 行硬约束无 AC 载体。Fix: 补模板内嵌 AC、numstat AC、无脚本依赖 AC。

## P2 (7)

- P2-1 AC1 改可机械判定 loop（OK/FAIL per file）
- P2-2 AC12 文件不存在时 grep 退出码 2 误读 → `2>/dev/null || echo MISSING`；README 补进 §7.1
- P2-3 P0 修复改动 reviewer 未见文件 → 增量复核（成本 ≈1/5 首轮）
- P2-4 阈值叠加：清单 ">5" + L1 "清单外 >2" = 合规上限 7 文件，超 "≤5" 承诺 → L1 改"总改动 >5 → 停"
- P2-5 Forbidden 补 EnterPlanMode（继承 CLAUDE.md §4）
- P2-6 alex-lite 无重名检查 → "文件已存在 → 停，请人确认"
- P2-7 保留勿丢：L3 标题内嵌证据型反合理化措辞；L0 先判断硬顺序；journal 改道尊重 memory 只读契约

## Overall

CONDITIONAL PASS。方向/成本模型/四精髓成立，无需推倒。原样交付则"强制独立审查"在三条真实路径失效（P0-1/2/3）、两条安全 AC 真空（P0-5/7）、准入可绕过（P0-6）、CLAUDE.md 自相矛盾（P0-4）。修订后同 reviewer 增量复核 §4.1/§4.2/§4.3/§9.1 即可。
