---
title: TAD Self-Test Agent — Automated Agent Behavior Verification
date: 2026-04-01
status: captured
scope: medium
---

## Summary & Problem

TAD 的功能验证目前完全靠人工：开新 terminal → 启动 /alex 或 /blake → 手动跑流程 → 观察行为。这很慢且不可复现。

需要一个自动化测试机制，让 TAD 能自己验证自己的功能是否正常。

## Proposed Solution

利用 Claude Code 的 Agent tool spawn sub-agent 能力，创建一个"TAD 自测 agent"：

```
主 terminal → spawn test agent → test agent 自动执行检查 → 报告结果
```

Sub-agent 继承父级的完整项目上下文（CLAUDE.md、hooks、skills、.tad/ 文件），所以可以：
- 读取配置文件，验证完整性
- 调用 /alex（通过 Skill tool），验证 agent 启动行为
- 检查 hook 是否触发（SessionStart 输出是否包含预期内容）
- 验证 Domain Pack 是否被识别和加载
- 模拟用户输入，检查 agent 响应

## Use Cases

1. **TAD 升级后的回归测试**：修改了 skill/hook/config 后，跑一次自测确认没破坏现有功能
2. **Domain Pack 集成测试**：验证 domain.yaml 是否被正确加载和应用
3. **Sync 后的下游验证**：同步到其他项目后，自动检查 TAD 是否正常

## Technical Basis

从 Claude Code 源码分析（2026-03-31）：
- Agent tool spawn 的 sub-agent 继承 CLAUDE.md、hooks、skills、CWD
- Sub-agent 有独立对话上下文（fresh eyes）
- Coordinator 模式的 Verification worker 就是同一个原理

## Open Questions

- Sub-agent 能否调用 Skill tool 启动 /alex？（嵌套 agent）
- 测试结果格式：简单 PASS/FAIL 还是详细报告？
- 测试脚本放在哪？.tad/tests/ ？

## Promoted To

(Not yet promoted)
