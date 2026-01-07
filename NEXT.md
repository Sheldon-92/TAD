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
- [x] agent-a-architect-v1.1.md - 添加 skills_integration (推荐场景，无限制)
- [x] agent-b-executor-v1.1.md - 添加 skills_integration (推荐场景，无限制)
- [x] config.yaml - 完善 skills_inventory (通用策略 + MQ/Gate 映射)

## 今天

- [x] Skills 混合策略研究与实施 (v1.4.1)
  - 研究 Anthropic 三层设计：Hooks(强制) / CLAUDE.md(建议) / Skills(自动匹配)
  - 确定 3 个强制调用 Skills: security-checklist, test-driven-development, verification
  - 更新 config.yaml 添加 mandatory_skills 配置
  - 更新 agent-a-architect-v1.1.md 添加强制调用逻辑
  - 更新 agent-b-executor-v1.1.md 添加强制调用逻辑
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

- [ ] 测试 v1.4 安装脚本在新项目中的效果
- [ ] 测试 v1.3 → v1.4 升级脚本
- [ ] 提交新增的 42 个 Skills 到 GitHub (5批共42个)

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
