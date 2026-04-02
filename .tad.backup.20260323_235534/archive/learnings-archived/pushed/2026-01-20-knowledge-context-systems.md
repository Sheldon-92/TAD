## Learning Entry

- **Date**: 2026-01-20 16:30
- **Agent**: Human + Claude (协作设计)
- **Category**: methodology
- **Status**: pushed

### 发现

**问题 1: Generic Skills 价值有限**
- 配置了 40+ Skills，但 LLM 本身已具备这些通用知识
- 真正有价值的是项目特异性的积累知识，而非通用 checklist

**问题 2: 项目上下文缺失**
- NEXT.md 只有待办，没有历史
- CLAUDE.md 只有规则，没有演进
- 每次都需要重新了解项目全貌，成本随项目增大

**问题 3: Completion Report 和归档不是强制阻塞点**
- Blake 有时会忘记创建 Completion Report
- Alex 归档 handoff 不是强制步骤

### 建议

**新增两个系统：**

1. **Project Knowledge 系统** (`.tad/project-knowledge/`)
   - 按类别分文件（code-quality, security, ux, architecture, performance, testing, api-integration, mobile-platform）
   - 触发点：Blake Gate 3 通过后 + Alex *review 完成后
   - 判断标准：impact-based（surprise factor, recurrence, impact）而非 time-based
   - 支持动态创建新类别
   - 软限制 + 整合机制（而非硬截断）

2. **PROJECT_CONTEXT 系统**
   - 核心文件 < 150 行，分层结构（TL;DR → Current → History）
   - 老化机制：最近详细，历史压缩归档
   - 归档到 docs/DECISIONS.md 和 docs/HISTORY.md
   - 触发点：Alex *accept 命令

**阻塞点强化：**

1. Gate 3 新增 Prerequisite：检查 Completion Report 存在
2. *accept 命令成为阻塞点：必须完成归档和 PROJECT_CONTEXT 更新才能开始新任务

### 来源

menu-snap 项目实践中发现并实施验证

### 相关文件

- `.claude/commands/tad-alex.md` (accept_command, project_context_update)
- `.claude/commands/tad-gate.md` (Gate 3 Prerequisite, Post_Pass_Action)
- `.tad/project-knowledge/README.md` (完整规则)
- `PROJECT_CONTEXT.md` (模板)
- `docs/DECISIONS.md`, `docs/HISTORY.md` (归档)

### 实施要点

**触发点设计原则：**
- 必须嵌入已有的强制流程（Gate, *accept），不能是独立步骤
- 判断标准必须明确，避免模糊的时间估算

**容量控制原则：**
- 软限制 + 整合，而非硬截断
- 分类文件隔离，Agent 只读相关文件
- 定期老化/归档，保持核心文件恒定大小

**动态演化原则：**
- 类别可以根据项目需要动态新增
- 通过目录扫描发现可用类别

---

> 此记录由 /tad-learn 命令生成
> 待 Human 确认后推送到 TAD 仓库
