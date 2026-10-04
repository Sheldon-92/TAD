# HANDOFF-2026-09-15-claude-removal-plan-codex

状态：DRAFT（结论摘要；完整正文因执行沙箱只读未能落盘）
作者：Alex（Codex / gpt-5.6-sol，独立方案，未参考 DeepSeek 版）
日期：2026-09-15
方向：彻底移除 Claude 路径（Claude Code CLI 机制 + Claude 模型绑定），只保留以 Codex 为主的中立机制

> 注：本文件由 thin-PM 根据 Alex 返回的结论摘要整理落盘，原始完整方案正文未能写入（沙箱只读）。
> 摘要内容未经改写，仅做结构化。

## 结论

建议直接发布 **v3.0.0**，不经过 2.45 过渡版。

## 实施顺序

1. 建立审计基线和升级安全 fixtures。
2. 将 skill SSOT 从 `.claude/skills` 原子反转到 `.agents/skills`。
3. 同步修改 `tad.sh`、`release-verify.sh` 及全部路径消费者。
4. 将安装矩阵收敛为 Codex-only。
5. 删除仓库内 tracked `.claude/**`、根 `CLAUDE.md`、Claude workflows/agents/model pins。
6. `claude_websearch`、`claude_code_reviewer` 分别改为 `websearch`、`code_reviewer`；
   两者经核查都只是历史标签，并未调用 Claude。
7. 保留并验证 `.codex/hooks.json`；OpenCode 本批只维持 updater-only，
   完整一等支持后续单独设计。
8. 完成 2.44.6 → 3.0.0 升级、用户 `.claude` 数据不变、clean-clone、零运行时残留验证。

## 独立审查补出的关键约束（必须纳入方案）

- 历史 migration manifests 仍须能够只读解析 `.claude` 路径，
  但 v3 不得生成自动删除用户 `.claude/**` 的新 manifest。
- 旧 2.44.6 updater 可能自动传 `--platform both`，
  必须提供 fail-before-mutation 行为和明确的 `--platform codex` 恢复命令。
- SSOT 消费者不只 installer/parity，还包括 capability-pack installers、
  `capability-skill.sh`、pack 验证器、brain index、runtime freshness、pair driver 等。
- 真正的 Claude 调用还包括 pair-driver 的 `claude -p --model sonnet`
  和 YOLO harness profile，必须纳入硬性零残留 AC。
- 下游 `.claude` 可能包含用户 hooks、MCP 和权限配置，绝不能自动递归删除。

## 待办

- 在可写会话中补全完整方案正文，或以 DeepSeek 版
 （`HANDOFF-2026-09-15-claude-removal-plan.md`）为执行基线、
  将本摘要的 5 条约束并入。
