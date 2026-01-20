# 下一步行动

## 已完成 (2026-01-06)

### TAD v1.4 发布
- [x] MQ6 强制技术搜索 - 所有技术决策触发搜索，深度自动判断
- [x] Research Phase - 过程中按需搜索 + 最终技术回顾
- [x] Skills 知识库系统 - `.claude/skills/` 自动发现
- [x] Learn 记忆系统 - `/tad-learn` 框架级建议记录
- [x] 内置 Skills - ui-design.md, skill-creator.md
- [x] 更新 install.sh 安装脚本
- [x] 创建 upgrade-to-v1.4.sh 升级脚本
- [x] 更新版本号和配置文件
- [x] 提交 v1.4 代码到 GitHub (v1.4.0 tag)

### 开源 Skills 补充 - 第一批 (来源: obra/superpowers)
- [x] test-driven-development.md - TDD 红绿重构循环
- [x] systematic-debugging.md - 系统性调试四阶段
- [x] code-review.md - 代码审查清单和流程
- [x] brainstorming.md - 头脑风暴设计三阶段
- [x] verification.md - 完成前验证必须有证据

### 开源 Skills 补充 - 第二批 (综合多个开源仓库)
- [x] parallel-agents.md - 并行 Agent 调度策略
- [x] git-worktrees.md - Git Worktree 隔离开发
- [x] software-architecture.md - 架构设计原则和模式
- [x] api-design.md - RESTful/GraphQL API 设计
- [x] security-checklist.md - OWASP Top 10 安全检查
- [x] performance-optimization.md - 前后端性能优化
- [x] receiving-feedback.md - 技术反馈处理协议
- [x] writing-skills.md - TDD 方法创建新 Skill
- [x] database-patterns.md - 数据库设计模式和优化
- [x] error-handling.md - 错误处理策略和模式
- [x] git-workflow.md - Git 分支策略和提交规范
- [x] refactoring.md - 代码重构手法和异味识别
- [x] testing-strategy.md - 测试金字塔和最佳实践

### 开源 Skills 补充 - 第三批 (非开发类，来源: anthropics/skills)
- [x] pdf-processing.md - PDF 文件处理 (提取/合并/转换)
- [x] pptx-creation.md - PowerPoint 演示文稿创建
- [x] xlsx-analysis.md - Excel 数据分析和报表
- [x] canvas-design.md - 视觉设计和 Canvas 绘图
- [x] algorithmic-art.md - 生成艺术和创意编程 (p5.js)
- [x] theme-factory.md - 配色方案和主题系统生成
- [x] content-research-writer.md - 内容研究和写作
- [x] scientific-writing.md - 学术论文和科学写作

### 开源 Skills 补充 - 第四批 (广泛搜索，综合多个仓库)
- [x] data-science.md - 数据科学和 Jupyter 工作流 (EDA/ML/可视化)
- [x] product-management.md - 产品管理 (PRD/用户故事/OKR/Sprint)
- [x] legal-documents.md - 法律文档 (合同审阅/GDPR合规/条款库)
- [x] marketing-copywriting.md - 营销文案 (AIDA/PAS/FAB/SEO)
- [x] i18n-translation.md - 国际化翻译 (i18n文件/复数规则/本地化)
- [x] media-processing.md - 音视频处理 (FFmpeg/ImageMagick/编辑)
- [x] meeting-notes.md - 会议记录 (纪要模板/行动项/议程)
- [x] email-communication.md - 商务邮件 (模板/语气/礼仪)
- [x] knowledge-graph.md - 知识图谱 (Neo4j/本体/关系抽取)
- [x] interview-prep.md - 面试准备 (简历/STAR/技术面/Offer谈判)

### 开源 Skills 补充 - 第五批 (用户指定需求)
- [x] prompt-engineering.md - Prompt工程 (CoT/ReAct/ToT/RAG/Agent设计)
- [x] ux-research.md - UX研究 (用户访谈/可用性测试/Persona/旅程图)
- [x] competitive-analysis.md - 竞品分析 (SWOT/五力/策略画布/定价分析)
- [x] ai-integration.md - AI应用集成 (LLM API/RAG/向量库/Agent架构)

### Skills 与 TAD 系统集成
- [x] manifest.yaml - 添加 Skills 追踪 (42个 Skills，通用访问)
- [x] agent-a-architect.md - 添加 skills_integration (推荐场景，无限制)
- [x] agent-b-executor.md - 添加 skills_integration (推荐场景，无限制)
- [x] config.yaml - 完善 skills_inventory (通用策略 + MQ/Gate 映射)

## 今天 (2026-01-20)

### TAD v1.5.1 - menu-snap 实践同步

- [x] 从 menu-snap 项目同步最新 TAD 实践改进
  - **CLAUDE.md 增强** (113 → 315 行)
    - 新增 Alex 验收规则（必须调用 subagents 进行实际验证）
    - 新增 Output Template 规则（Gate 3/4 证据文件强制要求）
    - 新增 Project Knowledge 记录规则（Gate 通过后触发）
    - 新增版本发布规则（Alex/Blake 分工）
  - **tad-alex.md 增强** (7055 → 15987 bytes)
    - 新增 *accept 命令（强制更新 PROJECT_CONTEXT.md）
    - 新增 *exit 协议（退出前检查 NEXT.md）
    - 新增版本发布职责
    - 新增验收时 subagent 强制调用
  - **tad-blake.md 增强** (8057 → 10453 bytes)
    - 新增 *exit 协议（退出前检查 NEXT.md）
    - 新增版本发布职责（日常发布执行）
    - 新增 NEXT.md 维护规则
    - 新增 knowledge_capture 触发
  - **tad-gate.md 增强** (4400 → 13743 bytes)
    - Gate 3 新增前置条件（Completion Report 必须存在）
    - Gate 3 新增必须调用 test-runner subagent
    - Gate 4 新增必须调用 security-auditor + performance-optimizer
    - 所有 Gate 新增 Post-Pass Actions（更新 NEXT.md、知识记录）
    - 新增证据文件存储到 .tad/evidence/reviews/
  - **config.yaml 同步** (1600 → 1910 行)
    - 新增 next_md_maintenance 配置（500行上限、归档规则）
    - 新增 release_management 配置（版本策略、发布流程）
    - 新增 template_triggers 配置（模板触发和存储系统）
  - **目录结构同步**
    - 新增 .tad/evidence/reviews/
    - 新增 .tad/evidence/completions/
    - 新增 .tad/active/designs/
    - 新增 .tad/active/handoffs/
    - 新增 .tad/archive/handoffs/
    - 新增 .tad/project-knowledge/
    - 新增 .tad/reports/
  - **模板同步**
    - 新增 12 个 output-formats 模板
    - 新增 next-md-template.md
    - 新增 history-md-template.md
    - 新增 release-handoff.md
    - 更新 handoff-b-to-a.md（Alex 验收规则）
  - **Skills 同步**
    - 新增 .claude/skills/code-review/ 目录结构

- [x] 记录批判性意见供未来验证
  - 创建 .tad/learnings/pending/2026-01-20-v15-critical-review.md
  - 记录对 Gate 4 多 subagent、Skills 规则、Evidence 存储的保留意见
  - 计划 2-4 周后验证

### 全面审核补充同步 (第二轮)

- [x] 补充遗漏文件同步
  - **新增 research.md** - Deep Research skill (424 行，多阶段研究模板)
  - **新增 release-execution.md** - 版本发布执行任务 (335 行)
  - **同步 elicitation-methods.md** - 从 data/ 移到 templates/
  - **同步 tad-init.md** - 更新目录结构匹配 v1.5
  - **同步 handoff-a-to-b.md** - 增强交接模板 (TAD v3.1 Evidence-Based Development)
  - **同步 gate-execution-guide.md** - 增加 Gate 3/4 强制要求
  - **同步 quality-gate-checklist.md** - 增加 subagent 验证和知识记录
  - **更新 .tad/README.md** - 更新目录结构说明，激活方式改为 /alex /blake
  - **更新 settings.json** - 激活方式从文件读取改为命令调用

- [x] Skills 目录结构简化（匹配 menu-snap 精简策略）
  - **归档 42 个 Skills** - 移至 `.claude/skills/_archived/`
  - **仅保留活跃**：`code-review/` 目录 + `doc-organization.md`
  - **原因**：Skills 过多导致上下文膨胀，精简为实际使用的核心技能

---

## 已完成 (2026-01-07)

- [x] TAD v1.5 - 框架与用户数据分离架构重构
  - **核心改进**: 彻底分离框架文件和用户数据
  - 创建 `tad-work/` 目录存放所有用户数据
  - `.tad/` 只保留框架文件（可安全删除重装）
  - 更新所有路径引用：config.yaml、命令文件、模板
  - 创建 `migrate-to-v1.5.sh` 自动迁移脚本
  - 更新 `install.sh` 支持 v1.5 新结构
  - 更新所有版本号到 v1.5
  - 更新 README.md 和文档
  - 提交 v1.5 到 GitHub (commits: 84e8bc1, 148f815)

- [x] 修复 6 个学习记录问题（来自 menu-snap 项目）
  - **问题 1**: 学习记录未积累 → 修复 /tad-learn 添加 GitHub API 自动推送
  - **问题 2**: Skill 触发条件不明确 → 添加触发条件到 tad-alex/blake/gate.md
  - **问题 3**: Handoff 绕过 → 创建 CLAUDE.md 规则文件
  - **问题 4**: Gates 未执行 → 简化 Gates，添加执行记录模板
  - **问题 5**: Handoff 闭环 → 添加完成协议和验收流程
  - 创建 `upgrade.sh` 智能升级脚本
  - 提交所有修复到 GitHub (commit: 9fff65a)

- [x] 修复 /tad-alex 配置文件超限问题 (2026-01-07)
  - 拆分 config.yaml (2202行 → 1599行，减少27%)
  - 提取 Skills 配置到 skills-config.yaml (611行)
  - 备份原配置到 config-backup.yaml
  - 解决 token 超限错误 (25595 → ~18000 tokens)
  - 提交到 GitHub (commit 2929df0)

- [x] 实现 /tad-learn 真正的跨项目学习积累 (2026-01-07)
  - **问题**: /tad-learn 只保存到本地项目，无法推送到 TAD 框架仓库
  - **解决**: 添加 GitHub API 自动推送功能
  - 修改 .claude/commands/tad-learn.md (Step 5 添加 gh api 推送逻辑)
  - 修改 .tad/skills-config.yaml (更新 step4_push 配置)
  - 推送现有 6 条学习记录到 GitHub (commit 0399f90)
  - 提交自动推送功能 (commit 2934e64)
  - 现在用户在任何项目中调用 /tad-learn 都能自动推送到 TAD 仓库 ✅

- [x] Skills 混合策略研究与实施 (v1.4.1)
  - 研究 Anthropic 三层设计：Hooks(强制) / CLAUDE.md(建议) / Skills(自动匹配)
  - 确定 3 个强制调用 Skills: security-checklist, test-driven-development, verification
  - 更新 config.yaml 添加 mandatory_skills 配置
  - 更新 agent-a-architect.md 添加强制调用逻辑
  - 更新 agent-b-executor.md 添加强制调用逻辑
  - 更新 manifest.yaml 添加混合策略追踪

- [x] Skills 质量升级 (基于 Codex 评估报告，87/100→目标95+)
  - [x] 统一 Frontmatter 格式 (version 3.0, tad_gates, TL;DR checklist)
  - [x] API Design - 版本化/RFC7807错误/幂等性/限流/GraphQL增强
  - [x] Security Checklist - ASVS映射/SSRF/CSRF/供应链/工具矩阵
  - [x] Testing Strategy + TDD - Gate绑定/覆盖率证据/E2E模板
  - [x] Database Patterns - 零停机迁移/慢日志分析/多租户隔离
  - [x] Performance Optimization - 性能预算/APM追踪/k6负载测试
  - [x] Git Workflow + Refactoring - 保护分支/GPG签名/静态分析/微提交
  - [x] i18n Translation - ICU MessageFormat/CLDR数据/RTL双向文字/回退策略
  - [x] Data Science - 复现性(随机种子)/实验追踪(MLflow/W&B)/模型卡
  - [x] 前端/设计类 (Canvas/Theme/UI) - 可访问性证据(WCAG对比度/色盲安全)
  - [x] 媒体/办公类 (PDF/PPTX/XLSX) - 版权合规/字体许可/跨平台兼容性
  - [x] 协作类 (Verification/Brainstorming/Meeting Notes) - Gate映射/证据模板

- [x] 文档一致性项目 Phase 1
  - [x] 创建 docs/ 门户结构 (docs/README.md, releases/, legacy/)
  - [x] 添加 v1.4 发布说明 (docs/releases/v1.4-release.md)
  - [x] 创建遗留文档索引 (docs/legacy/index.md)
  - [x] 为 5 个历史文档添加 Legacy 横幅
  - [x] 生成审计报告 (docs/AUDIT_REPORT.md)
  - [x] 完成 3 个原子提交

- [x] 文档一致性项目 Phase 2
  - [x] 更新 README.md 版本引用 (v1.3 → v1.4)
  - [x] 添加文档门户入口链接
  - [x] 更新 "What's New" 为 v1.4 特性
  - [x] 更新升级命令
  - [x] 更新审计报告

- [x] 文档一致性项目 Phase 3 (Final)
  - [x] 移动 5 个遗留文档到 docs/legacy/
  - [x] 移动 12 个归档文档到 docs/archive/
  - [x] 创建 docs/archive/index.md
  - [x] 更新所有内部链接
  - [x] 完成最终审计报告

- [x] Agent 文件整理
  - [x] 合并 agent-a-architect (v1.1 → base)
  - [x] 合并 agent-b-executor (v1.1 → base)
  - [x] 删除未追踪的 v3 文件
  - [x] 更新所有活跃文件的引用
  - [x] 归档旧脚本到 scripts/archive/

- [x] TAD v1.4 - Skills 自动匹配机制
  - [x] 更新 config.yaml 添加 skill_auto_match 配置 (165行)
  - [x] 意图映射：20+ 意图关键词 → Skill
  - [x] 文件模式映射：10+ 文件模式 → Skill
  - [x] 命令触发器：15+ 命令 → Skill
  - [x] 更新 agent-a-architect.md 添加 STEP 3.5 自动匹配步骤
  - [x] 更新 agent-b-executor.md 添加 STEP 3.5 自动匹配步骤
  - [x] 为 20 个关键 Skills 添加 triggers frontmatter

- [x] 测试 v1.4 安装脚本在新项目中的效果
- [x] 测试 v1.3 → v1.4 升级脚本
- [x] 提交新增的 42 个 Skills 到 GitHub (5批共42个)
- [x] 修复升级脚本 404 错误 (复制 upgrade-to-v1.1/v1.2/v1.3.sh 到根目录)
- [x] 修复 .gitignore 版本控制问题 (2026-01-07)
  - [x] 修改 install.sh 不再忽略 TAD 文件，添加"建议版本控制"说明
  - [x] 修改 upgrade.sh 自动清理旧的 TAD 忽略规则
  - [x] 更新 TAD 项目自身的 .gitignore，移除所有 TAD 忽略规则
  - [x] 同步修改到 GitHub，确保后续安装能获取完整 TAD 文件

## 本周

- [ ] 在实际项目中测试 MQ6 和 Research Phase
- [ ] 收集使用反馈，优化 Skills 内容

## 待定

- [ ] 根据使用反馈优化 /tad-learn 工作流
- [ ] 考虑 Skills 的版本管理机制
- [ ] 探索 MQ6 搜索结果的缓存/复用

## 阻塞/等待

（无）

---

## v1.4 变更摘要

| 模块 | 文件 | 说明 |
|------|------|------|
| MQ6 | `.tad/config.yaml` | 新增 MQ6_technical_research 配置 |
| Research Phase | `.tad/config.yaml` | 新增 research_phase 配置 |
| Skills System | `.tad/config.yaml` | 新增 skills_system 配置 |
| Learn System | `.tad/config.yaml` | 新增 learn_system 配置 |
| **Skill Auto-Match** | `.tad/config.yaml` | 新增 skill_auto_match 配置 (165行) |
| Agent A Auto-Match | `.tad/agents/agent-a-architect.md` | 添加 STEP 3.5 + auto_match section |
| Agent B Auto-Match | `.tad/agents/agent-b-executor.md` | 添加 STEP 3.5 + auto_match section |
| /tad-learn | `.claude/commands/tad-learn.md` | 新命令 |
| ui-design | `.claude/skills/ui-design.md` | 内置 Skill |
| skill-creator | `.claude/skills/skill-creator.md` | 元技能 |
| TDD | `.claude/skills/test-driven-development.md` | 开源 Skill (obra/superpowers) |
| Debugging | `.claude/skills/systematic-debugging.md` | 开源 Skill (obra/superpowers) |
| Code Review | `.claude/skills/code-review.md` | 开源 Skill (obra/superpowers) |
| Brainstorming | `.claude/skills/brainstorming.md` | 开源 Skill (obra/superpowers) |
| Verification | `.claude/skills/verification.md` | 开源 Skill (obra/superpowers) |
| Parallel Agents | `.claude/skills/parallel-agents.md` | 开源 Skill (综合) |
| Git Worktrees | `.claude/skills/git-worktrees.md` | 开源 Skill (综合) |
| Architecture | `.claude/skills/software-architecture.md` | 开源 Skill (综合) |
| API Design | `.claude/skills/api-design.md` | 开源 Skill (综合) |
| Security | `.claude/skills/security-checklist.md` | 开源 Skill (综合) |
| Performance | `.claude/skills/performance-optimization.md` | 开源 Skill (综合) |
| Feedback | `.claude/skills/receiving-feedback.md` | 开源 Skill (综合) |
| Writing Skills | `.claude/skills/writing-skills.md` | 开源 Skill (综合) |
| Database | `.claude/skills/database-patterns.md` | 开源 Skill (综合) |
| Error Handling | `.claude/skills/error-handling.md` | 开源 Skill (综合) |
| Git Workflow | `.claude/skills/git-workflow.md` | 开源 Skill (综合) |
| Refactoring | `.claude/skills/refactoring.md` | 开源 Skill (综合) |
| Testing | `.claude/skills/testing-strategy.md` | 开源 Skill (综合) |
| PDF Processing | `.claude/skills/pdf-processing.md` | 开源 Skill (anthropics) |
| PPTX Creation | `.claude/skills/pptx-creation.md` | 开源 Skill (anthropics) |
| XLSX Analysis | `.claude/skills/xlsx-analysis.md` | 开源 Skill (anthropics) |
| Canvas Design | `.claude/skills/canvas-design.md` | 开源 Skill (anthropics) |
| Algorithmic Art | `.claude/skills/algorithmic-art.md` | 开源 Skill (anthropics) |
| Theme Factory | `.claude/skills/theme-factory.md` | 开源 Skill (anthropics) |
| Content Research | `.claude/skills/content-research-writer.md` | 开源 Skill (anthropics) |
| Scientific Writing | `.claude/skills/scientific-writing.md` | 开源 Skill (K-Dense-AI) |
| Data Science | `.claude/skills/data-science.md` | 开源 Skill (综合搜索) |
| Product Management | `.claude/skills/product-management.md` | 开源 Skill (综合搜索) |
| Legal Documents | `.claude/skills/legal-documents.md` | 开源 Skill (综合搜索) |
| Marketing Copywriting | `.claude/skills/marketing-copywriting.md` | 开源 Skill (综合搜索) |
| i18n Translation | `.claude/skills/i18n-translation.md` | 开源 Skill (综合搜索) |
| Media Processing | `.claude/skills/media-processing.md` | 开源 Skill (综合搜索) |
| Meeting Notes | `.claude/skills/meeting-notes.md` | 开源 Skill (综合搜索) |
| Email Communication | `.claude/skills/email-communication.md` | 开源 Skill (综合搜索) |
| Knowledge Graph | `.claude/skills/knowledge-graph.md` | 开源 Skill (综合搜索) |
| Interview Prep | `.claude/skills/interview-prep.md` | 开源 Skill (综合搜索) |
| Prompt Engineering | `.claude/skills/prompt-engineering.md` | 开源 Skill (用户指定) |
| UX Research | `.claude/skills/ux-research.md` | 开源 Skill (用户指定) |
| Competitive Analysis | `.claude/skills/competitive-analysis.md` | 开源 Skill (用户指定) |
| AI Integration | `.claude/skills/ai-integration.md` | 开源 Skill (用户指定) |
| install.sh | `install.sh` | 更新到 v1.4 |
| upgrade | `upgrade-to-v1.4.sh` | 新升级脚本 |
