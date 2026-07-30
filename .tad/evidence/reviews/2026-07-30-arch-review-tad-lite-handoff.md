# Architecture Review — HANDOFF-20260730-tad-lite-channel

**Reviewer**: backend-architect (narrow-scope, pre-implementation)
**Date**: 2026-07-30
**Verdict**: CONDITIONAL PASS

## P0 (5)

- **arch-P0-1** — CLAUDE.md amendment incomplete: §3 规则 0/1/2/3/5 与 §4 同-terminal 禁令均与 lite 流程明文冲突，仅豁免 §1 不够。Fix: 合并为一个 consolidated lite block，声明豁免范围一次，含反向互斥条款。
- **arch-P0-2** — Guard 单向：blake-lite 拒 HANDOFF-*.md，但 full Blake/Alex 无 "忽略 LITE-*" 条款。Blake 激活规则含 `*.md` glob（已实测证实），full Blake 会捡走无 frontmatter/无 §9.1 的 LITE 文件 → 成本模型自反转。Fix: CLAUDE.md 加互斥条款 + AC。
- **arch-P0-3** — LITE 文件生命周期未定义 = 僵尸生成器 + 成本税。实测：zombie 检测 glob `HANDOFF-*.md`（LITE 隐形，永不归档）；full Alex 启动扫描按目录计数（每次激活为积累的 LITE 文件付费）；PreCompact hook glob `HANDOFF-*.md`（LITE 无 Layer-0 恢复）。Fix: blake-lite L5 人验收后 `mv` 到 `.tad/archive/handoffs/`；"pending = 存在于 active/" 成为自清洁机械不变量。
- **arch-P0-4** — "最新 LITE-*.md" 选择器未定义（mtime vs 文件名日期；同日并列）；Completion append 使 DONE 文件成为 mtime 最新 → 重复拾取；header Status 写一次即失真（DESIGNED 永存）。Fix: mv-on-acceptance + 去掉 Status 字段 + >1 pending → 请人指定 + alex-lite 创建前警告已有 pending。
- **arch-P0-5** — 12 条 AC 全是结构检查，核心声明（~90% 降本、25-45K/周期）零载体 = Validation Theater 重演。25-45K 估算未计入 reviewer subagent 继承 CLAUDE.md + 8 个 @import（可能 20-40K）。AC12 可不跑 smoke test 而通过。Fix: AC13 dogfood（真实 lite 周期 + 实测成本；>2× 45K → 设计声明证伪须修订）；AC12 要求原始 transcript。

## P1 (7)

- **arch-P1-1** — 升级阀门是 deny-list，向 lite 方向 fail-open。至少加兜底条款"清单未覆盖但无法确信影响面 → 升级 full"（放最后一行作 catch-all）。
- **arch-P1-2** — 漏网类别（逐一核对 §4.1 字面 pattern）：`.agents/**` 镜像、`tad.sh`、`.claude/settings.local.json`、`.claude/agents/*`、`.claude/workflows/*`、`patterns/_index.md`、`.tad/active/epics/**`、依赖升级（1-2 文件轻松过 >5 门槛）、release/publish/sync 操作、破坏性 VCS 操作。另 ">5 文件" 量的是数量不是耦合度——加耦合条款。
- **arch-P1-3** — §10.1 "禁止 Read .tad/…" 字面上禁掉了 blake-lite 读自己的契约文件和写 journal。改为禁"加载 TAD 协议/配置/知识文件"，读写契约与 journal 允许；AC2 相应调整。
- **arch-P1-4** — lite-discoveries.md 当前 write-only（蒸馏循环没被接线读它，NFR1 又禁改 full 协议）。要么声明接线为必需 follow-up handoff，要么删"复利"声明。且需 `mkdir -p`。
- **arch-P1-5** — escalated_review 在 §4.1 是例外、在 §11 是政策，二义漂移向"敏感文件常规走 lite"。修齐 + 加 NOT_via_suggestion 镜像禁令。
- **arch-P1-6** — reviewer prompt 的 `git diff` 无界（脏树噪声 + 成本随树脏度扩张）。改 scoped diff + 清单外 hunk 报 P0。
- **arch-P1-7** — lite 无压缩后恢复路径，§4.5 恢复文本会把 lite 导回重模式。skills 内明确："压缩后重读唯一 pending LITE 文件 + 重跑 lite 命令，不要跑 /alex /blake"。

## P2 (6)

- arch-P2-1 "不读 project-knowledge" 措辞误导（@import 是 session 常量）→ "不额外主动读取"
- arch-P2-2 AC3 只查 alex-lite；AC9 应改哨兵注释 + 机械 diff
- arch-P2-3 AC10 匹配不到 settings.local.json；AC11 会被 evidence 产物假 FAIL
- arch-P2-4 AC4 `&&` 链在首 grep 为 0 时静默截断 → 用 `;`
- arch-P2-5 文件名加 HHMM 消同日歧义
- arch-P2-6 AC13 dogfood 必须用 throwaway 任务；Codex $ 退化诊断属协议类，作 lite 首个 dogfood 会当天违反阀门

## Overall

CONDITIONAL PASS。核心架构成立（独立自包含入口是唯一能同时砍两类成本的选项；四精髓提炼正确）。阻塞点 = 低估集成面：真实面 ≥5 层（skill 入口 / CLAUDE.md 三处 / handoffs 目录 consumer 集 / 蒸馏接线 / Codex 镜像）。P0-2/3/4 可折叠为两个廉价机制：consolidated CLAUDE.md block + mv-on-acceptance。
