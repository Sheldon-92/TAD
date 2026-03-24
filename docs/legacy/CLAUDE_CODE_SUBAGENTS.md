# Claude Code Sub-agents 完整说明

## 重要背景
这些sub-agents是**Claude Code实际内置**的专业agents，不是虚构的角色。它们可以通过Task工具被Agent A或Agent B调用。

## 完整的Sub-agents列表及其能力

### 执行与开发类
1. **refactor-specialist** (Sonnet)
   - 能力：代码重构、优化、技术债务清理
   - 典型任务：改进代码质量、提取公共组件、优化性能

2. **parallel-coordinator** (Sonnet)
   - 能力：并行任务编排、多agent协调
   - 典型任务：同时执行前后端开发、协调多个sub-agents

3. **bug-hunter** (Sonnet)
   - 能力：错误诊断、问题定位、修复建议
   - 典型任务：找出bug原因、提供修复方案

4. **fullstack-dev-expert** (Sonnet)
   - 能力：全栈开发、前后端集成
   - 典型任务：完整功能实现、API与UI集成

5. **frontend-specialist** (Sonnet)
   - 能力：React/Vue/Angular开发、UI实现
   - 典型任务：组件开发、响应式设计、用户交互

6. **database-expert** (Sonnet)
   - 能力：数据库设计、查询优化、数据迁移
   - 典型任务：Schema设计、索引优化、数据建模

7. **devops-engineer** (Sonnet)
   - 能力：CI/CD配置、容器化、部署自动化
   - 典型任务：Docker配置、GitHub Actions、云部署

### 设计与架构类
8. **api-designer** (Sonnet)
   - 能力：RESTful/GraphQL API设计、接口规范
   - 典型任务：设计API端点、定义数据格式、编写API文档

9. **backend-architect** (Opus - 高级)
   - 能力：系统架构设计、技术选型、性能架构
   - 典型任务：设计微服务架构、选择技术栈、架构决策

10. **product-expert** (Sonnet)
    - 能力：需求分析、用户故事编写、产品规划
    - 典型任务：分析用户需求、定义功能范围、优先级排序

11. **ux-expert-reviewer** (Sonnet)
    - 能力：UX评估、可用性分析、交互优化建议
    - 典型任务：评审界面设计、提出改进建议、用户流程优化

### 质量保证类
12. **test-runner** (Sonnet)
    - 能力：测试执行、测试用例编写、覆盖率分析
    - 典型任务：单元测试、集成测试、E2E测试

13. **code-reviewer** (Opus - 高级)
    - 能力：代码质量审查、最佳实践检查、安全审查
    - 典型任务：代码评审、提出改进建议、确保代码标准

14. **performance-optimizer** (Opus - 高级)
    - 能力：性能分析、瓶颈诊断、优化方案
    - 典型任务：分析慢查询、优化算法、减少资源消耗

### 支持类
15. **docs-writer** (Sonnet)
    - 能力：技术文档编写、API文档、用户手册
    - 典型任务：编写README、API文档、部署指南

16. **data-analyst** (Sonnet)
    - 能力：数据分析、报告生成、洞察发现
    - 典型任务：分析用户行为、性能数据、生成报告

## 在TAD中的调用方式

### Agent A 调用示例
```markdown
Agent A (在Terminal 1中):
"我需要分析这个功能的需求"
[调用 product-expert]: "分析用户上传功能的需求"
[返回]: 详细的需求分析

"我需要设计系统架构"
[调用 backend-architect]: "设计支持100万用户的架构"
[返回]: 架构方案和技术选型
```

### Agent B 调用示例
```markdown
Agent B (在Terminal 2中):
"我要并行开发前后端"
[调用 parallel-coordinator]:
  任务1: frontend-specialist 开发React组件
  任务2: fullstack-dev-expert 开发API
  任务3: test-runner 编写测试
[返回]: 三个任务并行完成

"发现了一个bug"
[调用 bug-hunter]: "用户上传大文件时崩溃"
[返回]: 问题原因和修复方案
```

## Model级别说明

### Opus级别 (深度思考，更贵但更强)
- backend-architect
- code-reviewer
- performance-optimizer

### Sonnet级别 (快速执行，性价比高)
- 其他所有agents

## 为什么这些是"真正的"sub-agents

1. **Claude Code原生支持**：这些是Claude Code平台实际提供的agents
2. **通过Task工具调用**：使用标准的Task工具接口
3. **经过验证**：已在实际项目中使用并验证有效
4. **持续更新**：Claude团队维护和更新这些agents

## 与BMAD agents的区别

| BMAD Agents | TAD Sub-agents | 区别 |
|-------------|----------------|------|
| analyst.md | data-analyst | BMAD是角色定义文件，TAD是真实可调用的agent |
| pm.md | product-expert | BMAD需要人扮演，TAD是AI agent |
| dev.md | fullstack-dev-expert + 其他 | BMAD是一个角色，TAD是多个专业agents |
| qa.md | test-runner + code-reviewer | 更细分的专业能力 |

## 配置原则

1. **Agent A 主要调用**：
   - 设计和分析类的sub-agents
   - Opus级别的深度思考agents

2. **Agent B 主要调用**：
   - 执行和实现类的sub-agents
   - 需要并行处理时用parallel-coordinator

3. **灵活调用**：
   - 根据实际需要，两个Agent都可以调用任何sub-agent
   - 但要符合其主要职责

这些信息足够让任何Agent正确配置TAD的sub-agents系统。