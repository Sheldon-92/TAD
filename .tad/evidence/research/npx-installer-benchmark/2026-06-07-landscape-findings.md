# Landscape: AI Agent Framework Installers — 平台选择 / 选择性 / 渐进加载

**Date:** 2026-06-07 · **Method:** NotebookLM 持久 notebook (id `31445e5a-77ad-4d71-bba8-2939cdcefaa1`)
**Sources:** awesome-cli-coding-agents + BMAD-METHOD + awesome-ai-agents-2026 (GitHub-First)
**补:** 第一轮 BMAD 单源对标 (`2026-06-07-findings.md`) 的广度扩展 + 纠偏

---

## 三个维度的业界图景

### 1. 平台/IDE 选择 → config-driven 是主流
- **BMAD**: `platform-codes.yaml` + `IdeManager`,40+ 工具统一配置模型。
- **Crab Code** (Rust CLI): "layered config system" 处理 multi-provider,非硬编码。
- **结论**: TAD 选 **config-driven `platform-codes.yaml`**(用户已拍板)与业界一致。

### 2. 模块选择 UX → BMAD 有描述(纠正第一轮判断)⚠️
第一轮单源(docs/deepwiki)说"BMAD 模块只显示代号无描述"。**跨源纠偏**:BMAD 实际**有**描述:
- **Web Bundles** (bmadcode.com/web-bundles): 模块显示为**视觉卡片 + 人类可读描述**("brainstorming"/"PRFAQ"/"UX specs")。
- CLI 也按 domain 描述:"Test Architect (TEA) - Risk-based test strategy"。
- `bmad-help` 交互助手:读上下文解释下一步。
- **OpenClaw**: 专门的 **onboarding wizard**,视觉+顺序配置 skills/tools/channels。
- Terse 反例: Claude Code(手动 .zip/URL)、Genkit(读 raw SKILL.md)、OpenCastle(`npx init` 直接全装)。
- **结论**: TAD pack 选择 = checkbox + 一句话描述(复用 frontmatter),达到 BMAD 水平;可借鉴 OpenClaw **onboarding wizard** 思路。

### 3. Context 最小化 / 渐进加载 → 用户 Codex 减压的核心,模式丰富 🎯
BMAD 第一轮看似"无 context 概念" — 跨源后发现**有**(Web Bundles),且业界有成熟模式:
| 机制 | 代表 | 做法 |
|------|------|------|
| **Hot-loadable skills** | QwenPaw | 只在 workflow 需要时动态加载 toolset |
| **模块化文件(反 monolith)** | GitClaw | identity/rules/memory/tools/skills 拆成独立文件,避免注入 monolithic rule sets |
| **Paged retrieval** | Letta | 启动只给工具**索引**,主动 "page" 进 context |
| **Pointer/按需** | Claude Code plugin / BMAD Copilot `.agent.md` | 装小指针,内容按需加载 |
| **Web Bundles 阶段分离** | BMAD | 重的规划(brainstorm/PRD/UX)放 flat-rate web(ChatGPT GPT/Gemini Gem),只把最终产物带回 IDE 作"concentrated pointer" |
| **LSP 语义索引** | agent-lsp | 索引代替读整文件,**5-34× token 节省** |

**直接启发 TAD**: 我们的 `alex/SKILL.md` 86K = GitClaw 批判的 "monolithic rule set injected into prompt"。用户选的"**渐进加载不删内容**"= 业界验证的方向:**核心激活层(小,启动读)+ 按需 page 的 reference 层**(= QwenPaw hot-load + Letta paging + GitClaw 模块化 + BMAD pointer 的合成)。**不是删 SKILL,是拆 SKILL。**

---

## 对 TAD 的整合 Actionable(叠加第一轮 A-F)
- **G**: SKILL 瘦身走"核心激活层 + 按需 reference page"路线(对齐用户"渐进加载不删内容")— 业界有 QwenPaw/Letta/GitClaw 多重背书。TAD 已有 step4_5 max_packs:2 + reference 文件(bug-path-protocol.md 等)的雏形,可深化。
- **H**: pack 选择 UX 达到 BMAD 水平(描述)+ 借 OpenClaw onboarding wizard。
- **I**: 平台 config-driven 与业界一致(已拍板)。

## 局限
- n=2 ask 轮;source 为 awesome-list(二手编目),个别工具细节未直读其 repo。
- 第一轮"BMAD 无描述"判断已被本轮纠正 — 单源对标风险的实例。

## Sources
- [awesome-cli-coding-agents](https://github.com/bradAGI/awesome-cli-coding-agents) · [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) · [awesome-ai-agents-2026](https://github.com/Zijian-Ni/awesome-ai-agents-2026)
- NotebookLM notebook: `31445e5a-77ad-4d71-bba8-2939cdcefaa1`(持久,可反复 ask)
