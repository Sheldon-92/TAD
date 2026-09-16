# TAD Installation Guide

**Version 3.0.0 — Alex / Blake is the Default, Codex is the Runtime**

## 安装方式

### 方式 1: curl（推荐，一行全量安装）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

默认安装（Codex）+ 全部 25 个 packs。无需 Node.js，只需 bash + curl。首次安装与后续升级用同一命令；升级不会删除你的既有文件，项目数据（handoffs、evidence、project-knowledge）保持不变。

平台参数（显式覆盖默认值）：

```bash
# Codex（默认，也是唯一目标）
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes --platform codex --packs web-frontend,web-backend
```

> `--platform claude-code` / `--platform both` 自 v3.0.0 起被拒绝：
> 安装器会在改动任何文件前报错，并打印恢复命令（改传 `--platform codex` 即可）。
> 详见下方「升级到 v3.0.0」。

CI / 脚本化（跳过确认提示）：

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

### 方式 2: npx（交互式，需要 Node.js）

```bash
npx github:Sheldon-92/TAD
```

交互式选择 capability packs，每个 pack 附一句话说明（安装目标恒为 Codex）。

> 需要 Node.js 14+。不想装 Node.js 就用上面的 curl。

### 方式 3: Git clone

```bash
git clone https://github.com/Sheldon-92/TAD.git .tad-source
cd .tad-source && bash tad.sh
cd .. && rm -rf .tad-source
```

## 安装后

```bash
# 验证安装
cat .tad/version.txt          # 应显示 3.0.0
ls .agents/skills/ | wc -l    # 应 >= 20（框架 skills + packs）

# 默认（Alex / Blake —— 两个 terminal，人是唯一信息桥梁）
/alex           # Terminal 1: 设计与规划
/blake          # Terminal 2: 实现与执行

# 🧊 已冻结的实验（lite —— 显式调用仍完全可用）
/alex-lite      # 设计与规划（已冻结）
/blake-lite     # 实现与执行（已冻结）
```

## 升级现有项目

```bash
# 任选其一：
npx github:Sheldon-92/TAD                            # npx（推荐）
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes  # curl
```

脚本自动检测现有安装，保留你的 handoffs、evidence、project-knowledge，只更新框架文件。

### 项目内更新（`$tad-update` / `/tad-update`）

安装后，当前项目内置一个更新入口，两个 harness 共用同一个 helper：

- **Codex**：`$tad-update`（skill）
- **OpenCode**：`/tad-update`（**updater-only**：仅提供更新入口，不包含 Alex/Blake/Gate 角色、hooks 或 gate 能力）

流程：先运行 `--check` 查看当前/远程版本与备份位置（只读、不改任何文件）；确认要更新后再显式确认并执行 apply。helper 会在每次项目变更前自动备份，且仅在你确认后调用官方安装器。不支持静默自动更新——`--yes` 只能在你明确批准后使用。

### 升级到 v3.0.0（Claude Code 路径移除）

1. **只用 Codex 的用户**：无需操作。`npx tad-framework` / `curl | bash` 现在默认装
   `.agents/skills`；`--platform codex` 为默认。
2. **仍装 Claude Code 的用户**：Claude 路径自 v3.0.0 起**不再更新**。升级**不会删除、
   不会改写**你现有的 `.claude/`（含 skills、settings.json、hooks、MCP、权限配置）。
   如需清理请手动操作：`rm -rf .claude/skills .claude/workflows .claude/settings.json`
  （**TAD 不会代删**）。
3. **脚本里传 `--platform claude-code` 或 `--platform both` 的用户**：v3 会**在改动任何文件前**
   报错，并打印恢复命令。请改传 `--platform codex`，或直接重跑：
   - 本地 updater：`bash .tad/scripts/tad-update.sh --platform codex --yes`
   - npm：`npx tad-framework@latest --platform codex`
   - curl：`curl -fsSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform codex --yes`

   > 若你用**旧版（≤2.44.6）自带 updater**：它会自动探测出 `both` 并原样透传 →
   > v3 会 fail-before-mutation 停下。用上面任一条恢复命令即可，**不会丢文件**。
4. **直接调用某个 capability pack 的 `install.sh`**：目标现在是 `.agents/skills/`；
   旧的 `~/.claude/skills/` 安装不会自动迁移或删除。
5. **迁移安全保证**：v3.0.0 **不生成**删除用户 `.claude/**` 的 migration manifest；
   历史 manifest 只读保留。

## 平台说明

| 平台 | 说明 | 安装大小 |
|------|------|----------|
| Codex CLI | 完整安装，含 alex/blake SKILL + hooks | ~120KB |

Codex 用户可以用更少的 context 跑 TAD 工作流。详见 [Codex CLI 指南](#codex-cli)。

## Capability Packs

TAD 包含 25 个 capability packs，每个提供特定领域的判断规则：

| 类别 | Packs |
|------|-------|
| Web 开发 | web-frontend, web-backend, web-ui-design, web-testing, web-deployment |
| AI/Agent | ai-agent-architecture, ai-prompt-engineering, ai-evaluation, ai-tool-integration, ai-guardrails, agent-memory, agent-orchestration |
| 内容制作 | ai-voice-production, ai-podcast-production, video-creation |
| 数据/检索 | data-engineering, rag-retrieval, knowledge-graph, synthetic-data |
| 安全 | code-security |
| 可观测性 | llm-observability |
| 产品/研究 | product-thinking, research-methodology, academic-research |
| 机器学习 | ml-training |

安装时选择需要的 packs（npx 方式有交互选择）。不选 = 全部安装。

## Codex CLI

TAD 完整支持 Codex CLI（v0.130+），使用同一套 SKILL.md 文件：

```bash
# 前提：已安装 codex CLI + 配置 OpenAI 认证
codex --version

# 安装（skills 安装到 .agents/skills/）
bash tad.sh --platform codex --yes

# 使用：在 Codex 中输入 $alex 或 $blake 激活角色
```

**安装内容**：
- `.agents/skills/` — 完整 SKILL.md + 24 capability packs
- `.codex/hooks.json` — 按 Codex CLI 0.146+ schema 自动生成的 lifecycle hooks
- `AGENTS.md` — 角色触发词和 capability pack 表

**已知限制**：
- Codex hooks 不支持 `type: prompt`（LLM 内联安全检查），详见 `.tad/guides/hooks-platform-mapping.md`
- Codex 无等价的 Skill matcher，`pre-accept-check.sh` 和 `pre-gate-check.sh` 需手动运行
- skill 引用按各自 `.agents/skills/<skill>/` 基目录解析；激活时间约 65 秒

## 常见问题

**Q: Codex 没有识别 TAD？**
A: 检查 `.agents/skills/` 目录是否存在且包含 SKILL.md 文件。确认 `AGENTS.md` 在项目根目录。

**Q: /alex 命令不可用？**
A: 确认 `.agents/skills/alex/SKILL.md` 存在。如果缺失，重新运行安装命令。

**Q: 如何只安装特定 packs？**
A: `npx github:Sheldon-92/TAD --packs web-frontend,web-backend` 或 `bash tad.sh --packs web-frontend,web-backend`

**Q: npm 和 curl 有什么区别？**
A: npm 有完整的交互式 pack 选择（每个 pack 附说明）；curl 只选平台，packs 通过参数指定。功能完全相同。
