# Decision Record: 恢复 Claude Code 为一等运行时的方式

**Date**: 2026-10-08
**Status**: Accepted
**Decider**: Human (Value Guardian)
**Context**: EPIC-20261008-multi-harness-restore-and-cleanup。v3.0.0（2026-09-16，commit `20223774`）删除了 `.claude/` 运行时树；人判断该次剔除造成损伤，要求恢复 Claude Code 并与 Codex / Cursor / OpenCode 并列。

## Problem
v3.0.0 之后 TAD 对 Claude Code 的支持只剩「原生读 AGENTS.md」一层。实测与文档核查显示这一层不足以构成兼容，且需要在不重新引入双份 skill 正本的前提下补齐其余各层。

## Evidence

### 剔除了什么（`git show 20223774`）
- `.claude/skills` 555 文件、`.claude/workflows` 10 个、`.claude/agents` 2 个、`.claude/settings.json`（PreCompact / SessionStart / PreToolUse×3 / PostToolUse×2）、根 `CLAUDE.md`；合计 715 文件变更、115,636 行删除
- 删除前 `.claude/skills` 与 `.agents/skills` 的顶层 skill 名单经 `diff` 比对完全一致——skill 正文未丢，丢的是装载点
- 无 `.agents` 侧等价物的：10 个 workflow、2 个子代理定义、hook 注册、`CLAUDE.md`

### 官方文档核查（2026-10-08，code.claude.com 与官方 CHANGELOG）
| 事项 | 结论 | 出处 |
|---|---|---|
| AGENTS.md | 2.1.277 起默认读取，但仅当工作目录及上级无 `CLAUDE.md` / `CLAUDE.local.md` / `.claude/CLAUDE.md`；`~/.claude/CLAUDE.md` 不计。Bedrock/Vertex/网关/关遥测会话需 ≥ 2.1.281。`CLAUDE.md` 内 `@AGENTS.md` 引用是受支持的替代 | docs/en/memory.md「AGENTS.md」；CHANGELOG 2.1.277、2.1.281 |
| skill 发现 | 只认 `.claude/skills/`（项目/用户/企业/嵌套/`--add-dir`）与插件 `skills/`；`.agents/` 在文档中不出现 | docs/en/skills.md「Choose where skills load」 |
| skill 符号链接 | 逐 skill 条目可为指向他处目录的链接，有明文；目录级 `.claude/skills` 整体链接无文档 | docs/en/skills.md「Symlinked folders」 |
| hook 位置 | `~/.claude/settings.json`、`.claude/settings.json`、`.claude/settings.local.json`、托管策略、插件 `hooks/hooks.json`、skill/子代理 frontmatter | docs/en/hooks.md |
| 子代理 / workflow | `.claude/agents/`、`.claude/workflows/`（及用户级、插件）；无跨厂商位置 | docs/en/sub-agents.md、docs/en/workflows.md |
| 插件 | 可一并分发 skills/agents/hooks/workflows；清单 `.claude-plugin/plugin.json` | docs/en/plugins/create.md |

### 本机实测（2026-10-08）
- `claude --version` = 2.1.295；自仓根向上无 `CLAUDE.md`（仅 `~/.claude/CLAUDE.md`）
- 本次会话上下文中未见 `AGENTS.md` 内容；用户说「你是 alex」后须靠搜索定位 `.agents/skills/alex/SKILL.md`。原因未明，列为 Epic Phase 1 未知项 (a)
- `tad.sh validate_platform` 对 `both|*claude*` 在写入前拒绝；`detect-platform.sh` 仅返回 `codex|none`
- 活跃面中约 30 个 skill 文件仍引用 `.claude/` 路径

### 仓内既有可复用机制
- `runtime-adapter-checklist.md` 六维清单＋「实例未立不许接线」硬规；Codex/Cursor/OpenCode 三份实例在册
- `tad.sh` 的单文件投影三件套（preflight / project / rollback），Cursor 与 OpenCode hook 即按此落地

## Options Considered

### D1 Claude Code 如何取得 skill
| | A 安装时逐 skill 符号链接 | B 安装时生成指路文件 | C 恢复完整镜像 | D Claude Code 插件为主 |
|---|---|---|---|---|
| 正本份数 | 1 | 1＋短指路 | 2 | 1 |
| 文档支持 | 明文支持 | 属普通 skill 文件 | 属普通 skill 文件 | 明文支持 |
| 主要风险 | 同步盘、Windows 上链接不稳 | 每次激活多一次读取；指路 frontmatter 须与正本一致 | 漂移——即 3.0.0 剔除的原因 | 与 `tad.sh` 形成两条安装路径；项目级状态仍需安装器 |
| 与现有投影模式契合 | 高 | 高 | 低 | 中 |

自建方案（C）已有历史教训：principles「Judgment-Only Skill Files」条记录了 commands/skills 双源漂移导致的质量链失效。

### D2 workflow / 子代理恢复
历史恢复后逐个翻新 ｜ 只恢复在用的 ｜ 全部重写

### D3 AGENTS.md 兜底
在已有 `CLAUDE.md` 内维护带标记引用块 ｜ 总是创建 `CLAUDE.md` ｜ 不兜底只写文档

### D4 版本号
3.3.0 ｜ 4.0.0

## Recommendation
D1 取 A 为主、B 为退路，由 Phase 1 实测定案；D2 历史恢复后翻新；D3 只在已有 `CLAUDE.md` 内维护引用块；D4 取 3.3.0。把 Claude Code 当作第四个运行时实例走既有清单与投影模式，不新造机制。

## Decision
人于 2026-10-08 逐项选定，四项均与 Recommendation 一致：
- **D1** A 为主、B 为退路
- **D2** 历史恢复后逐个翻新
- **D3** 在已有 `CLAUDE.md` 里维护引用块
- **D4** 3.3.0

同场裁定：先恢复多 harness 再清残余；不做 OBJECTIVES 重写、协议瘦身、直接改下游仓、新能力或新 harness。

## Consequences
- **What this enables**: 四个 harness 共用一份 skill 正本与一套 `.tad/hooks` 行为面；Claude Code 侧重新获得角色入口、生命周期 hook 与 workflow 编排
- **What this prevents**: 不再回到双树镜像；不以插件市场作为主分发路径（留作后续可选）
- **Risks to monitor**:
  - 链接在同步盘上失效 → Phase 1 实测，失败即退 B
  - 写入存量 `.claude/settings.json` 时覆盖用户配置 → Phase 4 以 fixture 证明只动 TAD 管辖块
  - 下游项目多数已有 `CLAUDE.md`，会压住 AGENTS.md 的默认加载 → D3 引用块是下游生效的必要条件，而非可选兜底
  - 历史 workflow 带回已退役引用 → Phase 3 以 grep 归零为 AC
  - AGENTS.md 加载条件在 2.1.277–2.1.281 间变过两次 → 须进 `.tad/runtime-compat/claude-code.md` 新鲜度台账定期复核
