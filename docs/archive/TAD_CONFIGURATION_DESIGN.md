# TAD配置系统设计 - 基于BMAD的深度研究

## 研究发现：BMAD配置系统分析

### BMAD的配置复杂度
BMAD使用了232个文件，包括：
- 10个agents定义
- 26个tasks任务
- 13个templates模板
- 6个checklists检查清单
- 多层目录嵌套结构

### 为什么TAD不需要这种复杂度
1. **TAD只有2个主agents** - 不是10个
2. **TAD使用真实的Claude Code sub-agents** - 不需要定义假的agents
3. **TAD强调简单文档** - 不需要文档碎片化
4. **TAD是三角协作** - 不需要复杂的角色映射

## TAD配置系统设计

### 1. 核心配置文件结构

```yaml
# .tad/config.yaml - TAD主配置文件
method: TAD
version: 1.1
project:
  name: ${PROJECT_NAME}
  type: ${PROJECT_TYPE}  # web-app, api, cli-tool, library
  status: active

# 三角协作模型
triangle:
  human:
    role: Value Guardian
    decides:
      - Business requirements
      - Value acceptance
      - Priority changes

  agent_a:
    name: Alex
    role: Strategic Architect
    terminal: 1  # 使用终端1
    default_mode: design  # design/review/consult

  agent_b:
    name: Blake
    role: Execution Master
    terminal: 2  # 使用终端2
    default_mode: implement  # implement/test/debug

# Sub-agents映射（真实的Claude Code agents）
subagents:
  # Agent A倾向调用的
  strategic:
    - product-expert      # 需求分析
    - backend-architect   # 架构设计 (opus)
    - api-designer       # API设计
    - code-reviewer      # 代码审查 (opus)
    - performance-optimizer # 性能分析 (opus)

  # Agent B倾向调用的
  execution:
    - parallel-coordinator # 并行协调
    - fullstack-dev-expert # 全栈开发
    - frontend-specialist # 前端开发
    - bug-hunter         # 问题修复
    - test-runner        # 测试执行
    - devops-engineer    # 部署运维

  # Opus级别（需要深度思考）
  opus_level:
    - backend-architect
    - code-reviewer
    - performance-optimizer

# 工作流场景配置
scenarios:
  new_project:
    trigger: "没有任何代码"
    agent_a_flow:
      - task: requirement_analysis
        subagent: product-expert
        output: .tad/context/REQUIREMENTS.md
      - task: architecture_design
        subagent: backend-architect
        output: .tad/context/ARCHITECTURE.md
    agent_b_flow:
      - task: project_setup
        subagent: devops-engineer
        output: 项目框架代码
      - task: mvp_implementation
        subagent: parallel-coordinator
        coordinate:
          - frontend-specialist
          - fullstack-dev-expert
          - test-runner

  add_feature:
    trigger: "项目已存在，添加新功能"
    agent_a_flow:
      - task: feature_analysis
        subagent: product-expert
        output: .tad/working/feature-analysis.md
      - task: design_solution
        subagents: [api-designer, backend-architect]
        output: .tad/working/feature-design.md
    agent_b_flow:
      - task: impact_assessment
        subagent: code-reviewer
      - task: implementation
        subagent: fullstack-dev-expert
      - task: testing
        subagent: test-runner

  bug_fix:
    trigger: "发现问题需要修复"
    agent_a_flow:
      - task: problem_analysis
        output: .tad/working/bug-analysis.md
      - task: fix_strategy
        output: .tad/working/fix-plan.md
    agent_b_flow:
      - task: locate_issue
        subagent: bug-hunter
      - task: implement_fix
        subagent: appropriate_specialist
      - task: verify_fix
        subagent: test-runner

  performance_optimization:
    trigger: "性能问题"
    agent_a_flow:
      - task: performance_diagnosis
        subagent: performance-optimizer
        output: .tad/working/performance-diagnosis.md
    agent_b_flow:
      - task: optimize_code
        subagent: refactor-specialist
      - task: performance_test
        subagent: performance-optimizer

  refactoring:
    trigger: "代码重构"
    agent_a_flow:
      - task: refactor_assessment
        subagent: code-reviewer
        output: .tad/working/refactor-assessment.md
    agent_b_flow:
      - task: gradual_refactor
        subagent: refactor-specialist

  deployment:
    trigger: "准备发布"
    agent_a_flow:
      - task: release_checklist
        output: .tad/working/release-checklist.md
    agent_b_flow:
      - task: deploy_execution
        subagent: devops-engineer
      - task: production_verification
        subagent: test-runner

# 文档管理（简单的两层结构）
documents:
  context_path: .tad/context/  # 长期保存的项目状态
  working_path: .tad/working/  # 当前工作文档

  # 核心文档（始终存在）
  core:
    - PROJECT.md         # 项目单一真相源
    - REQUIREMENTS.md    # 需求文档
    - ARCHITECTURE.md    # 架构决策
    - DECISIONS.md       # 重要决策记录

  # 工作文档（按需创建）
  working:
    - current-sprint.md  # 当前Sprint
    - execution-report.md # 执行报告
    - bug-analysis.md    # Bug分析（临时）
    - feature-design.md  # 功能设计（临时）

# 验证机制
verification:
  technical:
    owner: agents
    gates:
      - Tests passing
      - Code reviewed
      - Performance acceptable

  value:
    owner: human
    gates:
      - User story fulfilled
      - Business value delivered
      - Experience validated

# 扩展规则
scaling:
  small_task:
    criteria: "<2 hours"
    documentation: minimal
    review: informal

  medium_task:
    criteria: "2-8 hours"
    documentation: sprint.md
    review: checkpoint

  large_task:
    criteria: ">1 day"
    documentation: comprehensive
    review: formal_gates

# 与Claude Code集成
claude_code:
  # 使用Task工具调用sub-agents
  task_tool_enabled: true

  # Agent激活命令
  activation:
    agent_a: "Read .tad/agents/agent-a-architect.md"
    agent_b: "Read .tad/agents/agent-b-executor.md"
```

### 2. 场景上下文模板

```yaml
# .tad/templates/scenario-context.yaml
# 每个场景生成的上下文模板

scenario: ${SCENARIO_NAME}
timestamp: ${TIMESTAMP}
triggered_by: ${TRIGGER_DESCRIPTION}

context:
  current_state:
    - ${STATE_ITEM_1}
    - ${STATE_ITEM_2}

  requirements:
    - ${REQUIREMENT_1}
    - ${REQUIREMENT_2}

  constraints:
    - ${CONSTRAINT_1}
    - ${CONSTRAINT_2}

agent_a_tasks:
  - task: ${TASK_NAME}
    subagent: ${SUBAGENT_NAME}
    input: ${INPUT_DESCRIPTION}
    expected_output: ${OUTPUT_DESCRIPTION}
    document: ${DOCUMENT_PATH}

agent_b_tasks:
  - task: ${TASK_NAME}
    subagent: ${SUBAGENT_NAME}
    depends_on: ${DEPENDENCY}
    expected_output: ${OUTPUT_DESCRIPTION}

handoff:
  from_a_to_b:
    document: ${DOCUMENT_PATH}
    key_decisions:
      - ${DECISION_1}
      - ${DECISION_2}

  from_b_to_a:
    report: ${REPORT_PATH}
    issues:
      - ${ISSUE_1}

verification_points:
  technical:
    - ${TECHNICAL_CHECK_1}
  value:
    - ${VALUE_CHECK_1}
```

### 3. Sprint追踪文件

```yaml
# .tad/working/current-sprint.yaml
sprint:
  number: ${SPRINT_NUMBER}
  started: ${START_DATE}
  scenario: ${SCENARIO_TYPE}

status:
  agent_a:
    current_task: ${CURRENT_TASK}
    completed_tasks:
      - ${COMPLETED_1}
    blocked_on: ${BLOCKER}

  agent_b:
    current_task: ${CURRENT_TASK}
    completed_tasks:
      - ${COMPLETED_1}
    running_subagents:
      - ${SUBAGENT_1}

documents_generated:
  - path: ${DOC_PATH}
    type: ${DOC_TYPE}
    agent: ${CREATING_AGENT}

next_steps:
  - ${NEXT_STEP_1}
  - ${NEXT_STEP_2}
```

### 4. 简化的状态追踪

```yaml
# .tad/state.yaml - 简单的项目状态
project_state:
  phase: ${PHASE}  # planning/developing/testing/deployed
  last_activity: ${TIMESTAMP}
  active_scenario: ${SCENARIO}

recent_decisions:
  - date: ${DATE}
    decision: ${DECISION}
    made_by: ${WHO}

current_focus:
  agent_a: ${CURRENT_FOCUS}
  agent_b: ${CURRENT_FOCUS}
  human: ${WAITING_FOR}
```

## 与BMAD的关键区别

| 方面 | BMAD | TAD |
|------|------|-----|
| 配置文件 | 232个文件 | <10个文件 |
| Agents | 10个虚构agents | 2个主agents + 真实sub-agents |
| 文档结构 | 多层嵌套+碎片化 | 2层简单结构 |
| 场景定义 | 分散在多个文件 | 集中在config.yaml |
| 验证机制 | 复杂的QA gates | 简单的双层验证 |
| 状态追踪 | install-manifest + hash | 简单的state.yaml |

## 实施优势

1. **清晰的场景映射** - 6个场景直接对应配置
2. **真实的sub-agents** - 调用Claude Code真实能力
3. **简单的文档管理** - 不超过2层目录
4. **灵活的扩展** - 根据任务大小自动调整
5. **Human-centric** - Human始终是价值验证者

## 下一步行动

1. 根据这个设计更新现有的config.yaml
2. 为每个场景创建具体的执行模板
3. 确保Agent A和Agent B的定义文件引用正确的配置
4. 创建简单的状态追踪机制

这个配置系统从BMAD学到了结构化和系统化，但保持了TAD的简单性原则。