# workflow-repo-anchoring

**Source project**: TAD
**Date**: 2026-10-31
**Origin**: conversation light path (*discuss) — 首条轻路径条目，即该提示的 worked example（见 .tad/evidence/surplus-phase2-20261031/saveable-skills-from-conversation/DEMO-light-path-save.md）
**Type**: workflow
**Triggers**: surplus 扫描、workflow 子代理读文件、跨仓 backlog 扫描、路径锚定、扫错根、SAFETY 虚高

## Workflow

用 workflow 脚本（surplus-scan 一类）扫某个目标仓时，子代理文件工具的相对路径以家目录 `~` 为基准解析——不先定锚就会扫错根或把仓内件误判仓外。步骤：

1. **定锚**：先确认目标仓绝对路径，并确认本 harness 子代理文件工具的相对基准（本环境为 `~`）。
2. **传参**：跨仓扫描时 sources／objectives_path 传目标仓**绝对路径**锚定；扫本仓时传 `workspace/yun-sync/<repo>/…` 前缀式路径（自 `~` 起算可达）。
3. **验回填**：检查 reader 返回的 target_paths——若被回填成绝对路径，下游的机械规则（如「绝对路径＝仓外」）会把仓内候选误判 SAFETY，先怀疑锚定、改前缀式重跑，再怀疑内容。
4. **对账**：ranked／needs-human 计数异常（如 epics 候选整类消失）时，先按锚定问题处置；首跑整份作废重跑的成本远低于在错根结果上继续。

## Gotchas

- 绝对路径不是万能锚：musecloud 席首跑传绝对 sources，reader 把绝对路径回填进 target_paths，8 件 epics 候选被机械规则全误判 SAFETY（ranked 17、needs-human 虚高 14），改前缀式重跑才校正。
- 裸相对路径会静默扫错根：商业洞见席首跑误扫 TAD 仓（54 条、整份作废）；Menu 席相对路径同样须改前缀式才命中本仓。
- 正面例：grok-cloud 席传 grok-cloud 绝对路径一次命中（ranked 25）——锚法随「扫本仓还是跨仓」而异，没有一种写法通吃。
