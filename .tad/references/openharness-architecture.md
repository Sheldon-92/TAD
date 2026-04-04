# OpenHarness Architecture Reference

> Source: https://github.com/HKUDS/OpenHarness (HKU Data Intelligence Lab)
> Version analyzed: 2026-04-03 (first public release)
> LOC: 11,733 Python | License: MIT
> Local path: /Users/sheldonzhao/01-on progress programs/OpenHarness/

## How to Use This Document

- 设计新 agent → 查阅 **Agent Design Guidelines** (G1-G10)
- 评估 TAD 能力差距 → 查阅 **TAD Mapping**
- 了解某个子系统细节 → 查阅对应子系统章节
- Domain Pack 引用 → 按路径 `.tad/references/openharness-architecture.md#子系统名`

## Overview

OpenHarness 将 "Agent Harness" 定义为围绕 LLM 的完整基础设施层：模型提供智能，Harness 提供手（Tools）、眼睛（Prompts）、记忆（Memory）和安全边界（Permissions）。

10 个核心子系统及其关系：

```
                    ┌─────────────┐
                    │   Prompts   │ ← 组装 system prompt（环境 + CLAUDE.md + Memory）
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Engine    │ ← Agent Loop：stream → tool_use → execute → loop
                    └──┬───┬───┬──┘
                       │   │   │
            ┌──────────┘   │   └──────────┐
            ▼              ▼              ▼
      ┌──────────┐  ┌───────────┐  ┌────────────┐
      │  Tools   │  │Permissions│  │   Hooks    │
      │(Registry)│  │ (Checker) │  │ (Executor) │
      └──────────┘  └───────────┘  └────────────┘
            │
      ┌─────┴─────┐
      ▼            ▼
┌──────────┐ ┌──────────┐
│  Skills  │ │  Tasks   │ ← 后台任务 + 子 agent 管理
│ (Loader) │ │(Manager) │
└──────────┘ └──────────┘
      │            │
      │     ┌──────┴──────┐
      │     ▼             ▼
      │ ┌──────────┐ ┌──────────┐
      │ │Coordinator│ │  Memory  │
      │ │(Registry) │ │(Manager) │
      │ └──────────┘ └──────────┘
      │
      └──→ ┌──────────┐
           │  Config  │ ← Pydantic Settings + 路径管理
           └──────────┘
```

---

## 1. Engine — Agent Loop

### Core Abstraction

Engine 是 agent 的心脏：一个有限次数的 stream-tool-loop 循环。核心类 `QueryEngine` 持有会话历史，`run_query()` 执行实际循环。

```python
# 来自 engine/query.py
@dataclass
class QueryContext:
    api_client: SupportsStreamingMessages
    tool_registry: ToolRegistry
    permission_checker: PermissionChecker
    cwd: Path
    model: str
    system_prompt: str
    max_tokens: int
    max_turns: int = 8
    hook_executor: HookExecutor | None = None
```

### Data Flow

User Message → `QueryEngine.submit_message()` → `run_query()` loop（max 8 turns）→ stream API response → 检查 `tool_uses` → 执行工具（单个顺序/多个并行）→ 结果追加到 messages → 继续循环 → 无 tool_use 时返回

### Key Code Pattern

```python
# 来自 engine/query.py:53-86 — 核心 Agent Loop
async def run_query(
    context: QueryContext,
    messages: list[ConversationMessage],
) -> AsyncIterator[tuple[StreamEvent, UsageSnapshot | None]]:
    for _ in range(context.max_turns):
        final_message: ConversationMessage | None = None
        usage = UsageSnapshot()

        async for event in context.api_client.stream_message(
            ApiMessageRequest(
                model=context.model,
                messages=messages,
                system_prompt=context.system_prompt,
                max_tokens=context.max_tokens,
                tools=context.tool_registry.to_api_schema(),
            )
        ):
            if isinstance(event, ApiTextDeltaEvent):
                yield AssistantTextDelta(text=event.text), None
                continue
            if isinstance(event, ApiMessageCompleteEvent):
                final_message = event.message
                usage = event.usage

        messages.append(final_message)
        yield AssistantTurnComplete(message=final_message, usage=usage), usage

        if not final_message.tool_uses:
            return
```

```python
# 来自 engine/query.py:90-117 — 并行 vs 顺序工具执行
if len(tool_calls) == 1:
    tc = tool_calls[0]
    yield ToolExecutionStarted(tool_name=tc.name, tool_input=tc.input), None
    result = await _execute_tool_call(context, tc.name, tc.id, tc.input)
    yield ToolExecutionCompleted(tool_name=tc.name, output=result.content, is_error=result.is_error), None
    tool_results = [result]
else:
    for tc in tool_calls:
        yield ToolExecutionStarted(tool_name=tc.name, tool_input=tc.input), None
    async def _run(tc):
        return await _execute_tool_call(context, tc.name, tc.id, tc.input)
    results = await asyncio.gather(*[_run(tc) for tc in tool_calls])
    tool_results = list(results)
```

### Design Decisions

- Decision: max_turns=8 硬上限 | Rationale: 防止 agent 无限循环，超限抛 RuntimeError | TAD Implication: TAD 的 Ralph Loop 无 turn 上限，依赖 circuit breaker（3 次相同错误）代替硬上限
- Decision: 单工具顺序执行、多工具 `asyncio.gather` 并行 | Rationale: 单工具时立即 yield event 提升响应性；多工具时并行提升吞吐量 | TAD Implication: TAD 的 parallel-coordinator 在更高层面做并行（多 agent），OpenHarness 在工具层并行
- Decision: 工具执行错误返回 `ToolResultBlock(is_error=True)` 而非抛异常 | Rationale: 保留会话上下文，让模型看到错误并恢复 | TAD Implication: TAD 可借鉴此模式——让 agent 看到失败原因而非 crash

---

## 2. Tools — Tool Registry & Execution

### Core Abstraction

声明式工具系统：每个工具继承 `BaseTool`，声明 name/description/input_model，`ToolRegistry` 负责存储和查询。Pydantic schema 自动生成 Anthropic API 所需的 JSON schema。

```python
# 来自 tools/base.py — BaseTool 抽象基类
class BaseTool(ABC):
    name: str
    description: str
    input_model: type[BaseModel]

    @abstractmethod
    async def execute(self, arguments: BaseModel, context: ToolExecutionContext) -> ToolResult: ...

    def is_read_only(self, arguments: BaseModel) -> bool:
        return False

    def to_api_schema(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "description": self.description,
            "input_schema": self.input_model.model_json_schema(),
        }
```

### Data Flow

工具注册（`register(tool)`）→ Engine 调用 `registry.to_api_schema()` 生成 API 工具列表 → 模型返回 `tool_use` → Engine 通过 `registry.get(name)` 查找工具 → Pydantic `model_validate(tool_input)` 验证输入 → `tool.execute(parsed_input, context)` 执行 → 返回 `ToolResult`

### Key Code Pattern

```python
# 来自 tools/base.py — ToolRegistry
class ToolRegistry:
    def __init__(self) -> None:
        self._tools: dict[str, BaseTool] = {}

    def register(self, tool: BaseTool) -> None:
        self._tools[tool.name] = tool

    def get(self, name: str) -> BaseTool | None:
        return self._tools.get(name)

    def to_api_schema(self) -> list[dict[str, Any]]:
        return [tool.to_api_schema() for tool in self._tools.values()]
```

```python
# 来自 tools/bash_tool.py — BashTool 执行（async subprocess + timeout）
async def execute(self, arguments: BashToolInput, context: ToolExecutionContext) -> ToolResult:
    cwd = Path(arguments.cwd).expanduser() if arguments.cwd else context.cwd
    process = await asyncio.create_subprocess_exec(
        "/bin/bash", "-lc", arguments.command,
        cwd=str(cwd),
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    try:
        stdout, stderr = await asyncio.wait_for(
            process.communicate(), timeout=arguments.timeout_seconds,
        )
    except asyncio.TimeoutError:
        process.kill()
        await process.wait()
        return ToolResult(output=f"Command timed out after {arguments.timeout_seconds} seconds", is_error=True)
```

### Design Decisions

- Decision: Pydantic `model_json_schema()` 自动生成 API schema | Rationale: 比手写 JSON schema 更安全，类型变更自动同步 | TAD Implication: TAD 的 Domain Pack 工具声明可借鉴——YAML 定义 + schema 自动生成
- Decision: `is_read_only()` 方法声明读写属性 | Rationale: 权限系统根据此标记决定是否需要用户确认 | TAD Implication: TAD 的 PreToolUse hook 做类似的事，但基于 tool_name 匹配而非工具自声明
- Decision: `ToolResult` 使用 `frozen=True` dataclass | Rationale: 不可变结果保证线程安全 | TAD Implication: TAD 的 evidence 文件是类似模式——产出后不修改

---

## 3. Permissions — Multi-Layer Access Control

### Core Abstraction

三层过滤器架构：从最严格（显式拒绝）到最宽松（auto mode），每层都可以直接返回决策。

```python
# 来自 permissions/modes.py
class PermissionMode(str, Enum):
    DEFAULT = "default"      # 写操作需确认
    PLAN = "plan"            # 阻止所有写操作
    FULL_AUTO = "full_auto"  # 允许一切
```

```python
# 来自 permissions/checker.py
@dataclass(frozen=True)
class PermissionDecision:
    allowed: bool
    requires_confirmation: bool = False
    reason: str = ""
```

### Data Flow

`evaluate(tool_name, is_read_only, file_path, command)` → Layer 1: 检查 denied_tools/allowed_tools → Layer 2: path rules (fnmatch glob) + command deny patterns → Layer 3: mode 判断（FULL_AUTO→允许, 只读→允许, PLAN→拒绝, DEFAULT→需确认）

### Key Code Pattern

```python
# 来自 permissions/checker.py:42-98 — 三层权限检查
def evaluate(self, tool_name: str, *, is_read_only: bool,
             file_path: str | None = None, command: str | None = None) -> PermissionDecision:
    # Layer 1: Explicit deny/allow lists
    if tool_name in self._settings.denied_tools:
        return PermissionDecision(allowed=False, reason=f"{tool_name} is explicitly denied")
    if tool_name in self._settings.allowed_tools:
        return PermissionDecision(allowed=True, reason=f"{tool_name} is explicitly allowed")

    # Layer 2: Path and command rules
    if file_path and self._path_rules:
        for rule in self._path_rules:
            if fnmatch.fnmatch(file_path, rule.pattern):
                if not rule.allow:
                    return PermissionDecision(allowed=False,
                        reason=f"Path {file_path} matches deny rule: {rule.pattern}")

    if command:
        for pattern in getattr(self._settings, "denied_commands", []):
            if isinstance(pattern, str) and fnmatch.fnmatch(command, pattern):
                return PermissionDecision(allowed=False, reason=f"Command matches deny pattern: {pattern}")

    # Layer 3: Mode-based policy
    if self._settings.mode == PermissionMode.FULL_AUTO:
        return PermissionDecision(allowed=True, reason="Auto mode allows all tools")
    if is_read_only:
        return PermissionDecision(allowed=True, reason="read-only tools are allowed")
    if self._settings.mode == PermissionMode.PLAN:
        return PermissionDecision(allowed=False,
            reason="Plan mode blocks mutating tools until the user exits plan mode")
    return PermissionDecision(allowed=False, requires_confirmation=True,
        reason="Mutating tools require user confirmation in default mode")
```

### Design Decisions

- Decision: 分层过滤器而非单一检查函数 | Rationale: 各层独立、可扩展、短路返回提升性能 | TAD Implication: TAD 的 `permissions.deny > hooks > allow` 优先级链是类似设计
- Decision: `fnmatch.fnmatch()` 做 glob 匹配 | Rationale: Python 标准库，无额外依赖，支持通配符 | TAD Implication: TAD hook 的 `matcher` 字段也用 glob 模式
- Decision: `PermissionDecision` 用 frozen dataclass | Rationale: 决策不可变，防止后续代码篡改 | TAD Implication: Gate 结果也应不可变——一旦判定不应被修改

---

## 4. Hooks — Lifecycle Event System

### Core Abstraction

4 种生命周期事件（session_start/end, pre/post_tool_use）+ 4 种 hook 类型（command, http, prompt, agent）。每种 hook 独立执行，结果聚合后判断是否 block。

```python
# 来自 hooks/events.py
class HookEvent(str, Enum):
    SESSION_START = "session_start"
    SESSION_END = "session_end"
    PRE_TOOL_USE = "pre_tool_use"
    POST_TOOL_USE = "post_tool_use"
```

### Data Flow

Engine 执行工具前 → `hook_executor.execute(PRE_TOOL_USE, payload)` → 遍历匹配的 hooks → 按类型分发（command=shell, http=POST, prompt=LLM 验证, agent=深度 LLM 验证）→ 聚合结果 `AggregatedHookResult` → 如果 `blocked=True` 则工具调用被阻止

### Key Code Pattern

```python
# 来自 hooks/executor.py — 主执行流程
async def execute(self, event: HookEvent, payload: dict[str, Any]) -> AggregatedHookResult:
    results: list[HookResult] = []
    for hook in self._registry.get(event):
        if not _matches_hook(hook, payload):
            continue
        if isinstance(hook, CommandHookDefinition):
            results.append(await self._run_command_hook(hook, event, payload))
        elif isinstance(hook, HttpHookDefinition):
            results.append(await self._run_http_hook(hook, event, payload))
        elif isinstance(hook, PromptHookDefinition):
            results.append(await self._run_prompt_like_hook(hook, event, payload, agent_mode=False))
        elif isinstance(hook, AgentHookDefinition):
            results.append(await self._run_prompt_like_hook(hook, event, payload, agent_mode=True))
    return AggregatedHookResult(results=results)
```

```python
# 来自 hooks/schemas.py — Command Hook 定义
class CommandHookDefinition(BaseModel):
    type: Literal["command"] = "command"
    command: str
    timeout_seconds: int = Field(default=30, ge=1, le=600)
    matcher: str | None = None
    block_on_failure: bool = False
```

```python
# 来自 hooks/executor.py — glob 匹配机制
def _matches_hook(hook: HookDefinition, payload: dict[str, Any]) -> bool:
    matcher = getattr(hook, "matcher", None)
    if not matcher:
        return True
    subject = str(payload.get("tool_name") or payload.get("prompt") or payload.get("event") or "")
    return fnmatch.fnmatch(subject, matcher)
```

### Design Decisions

- Decision: 4 种 hook 类型（command/http/prompt/agent） | Rationale: 从简单 shell 到复杂 LLM 验证的完整光谱 | TAD Implication: TAD 目前只用 command hook；prompt hook（Haiku gating）是已验证的扩展方向
- Decision: `block_on_failure` 可选标记 | Rationale: 不是所有 hook 都应阻止执行（如日志 hook） | TAD Implication: TAD 的 pre-gate-check.sh 用 exit code 控制 block，概念等价
- Decision: 环境变量传递 payload（`OPENHARNESS_HOOK_PAYLOAD`） | Rationale: Shell 命令无法接收结构化参数 | TAD Implication: TAD 的 hook 通过 `$ARGUMENTS` 占位符注入，本质相同

---

## 5. Skills — Skill Registry & Loader

### Core Abstraction

三层 skill 来源：bundled（内置）→ user（~/.config/openharness/skills/*.md）→ plugin（动态加载）。Skill 是 Markdown 文件 + 可选 YAML frontmatter。

```python
# 来自 skills/types.py
@dataclass(frozen=True)
class SkillDefinition:
    name: str
    description: str
    content: str
    source: str           # "bundled" | "user" | "plugin"
    path: str | None = None
```

### Data Flow

`load_skill_registry(cwd)` → 注册 bundled skills → 扫描 `~/.config/openharness/skills/*.md` 注册 user skills → 加载 plugins 注册 plugin skills → `registry.get(name)` 查找 → 返回 `SkillDefinition.content` 作为 prompt 注入

### Key Code Pattern

```python
# 来自 skills/loader.py — 三层 skill 加载
def load_skill_registry(cwd: str | Path | None = None) -> SkillRegistry:
    registry = SkillRegistry()
    for skill in get_bundled_skills():
        registry.register(skill)
    for skill in load_user_skills():
        registry.register(skill)
    if cwd is not None:
        from openharness.plugins.loader import load_plugins
        settings = load_settings()
        for plugin in load_plugins(settings, cwd):
            if not plugin.enabled:
                continue
            for skill in plugin.skills:
                registry.register(skill)
    return registry
```

```python
# 来自 skills/loader.py — Markdown + YAML frontmatter 解析
def _parse_skill_markdown(default_name: str, content: str) -> tuple[str, str]:
    name = default_name
    description = ""
    lines = content.splitlines()
    if lines and lines[0].strip() == "---":
        for i, line in enumerate(lines[1:], 1):
            if line.strip() == "---":
                for fm_line in lines[1:i]:
                    fm_stripped = fm_line.strip()
                    if fm_stripped.startswith("name:"):
                        val = fm_stripped[5:].strip().strip("'\"")
                        if val:
                            name = val
                    elif fm_stripped.startswith("description:"):
                        val = fm_stripped[12:].strip().strip("'\"")
                        if val:
                            description = val
                break
    return name, description
```

### Design Decisions

- Decision: 三层来源优先级（bundled < user < plugin） | Rationale: 用户可覆盖内置 skill，plugin 在运行时扩展 | TAD Implication: TAD 的 skill 只有一层（.claude/commands/），无 plugin 覆盖机制
- Decision: Skill 是 Markdown 文件（不是代码） | Rationale: Skill 是 prompt 注入，不是可执行代码 | TAD Implication: TAD 的 skill 也是 Markdown，设计一致
- Decision: `frozen=True` SkillDefinition | Rationale: 注册后不可修改 | TAD Implication: TAD 的 skill 文件也是只读加载

---

## 6. Coordinator — Multi-Agent Orchestration

### Core Abstraction

极简的多 agent 协调：`TeamRegistry` 管理 team（agent 列表 + 消息队列），agent 通过 task_id 引用。不是复杂的调度系统——只是注册表 + 消息传递。

```python
# 来自 coordinator/coordinator_mode.py
@dataclass
class TeamRecord:
    name: str
    description: str = ""
    agents: list[str] = field(default_factory=list)      # task_id list
    messages: list[str] = field(default_factory=list)     # append-only log
```

### Data Flow

`create_team(name)` → `add_agent(team, task_id)` → `send_message(team, msg)` → 消息追加到 team 的 messages 列表 → `list_teams()` 返回所有 team 状态

### Key Code Pattern

```python
# 来自 coordinator/coordinator_mode.py — TeamRegistry
class TeamRegistry:
    def __init__(self) -> None:
        self._teams: dict[str, TeamRecord] = {}

    def create_team(self, name: str, description: str = "") -> TeamRecord:
        if name in self._teams:
            raise ValueError(f"Team '{name}' already exists")
        team = TeamRecord(name=name, description=description)
        self._teams[name] = team
        return team

    def add_agent(self, team_name: str, task_id: str) -> None:
        team = self._require_team(team_name)
        if task_id not in team.agents:
            team.agents.append(task_id)

    def send_message(self, team_name: str, message: str) -> None:
        self._require_team(team_name).messages.append(message)
```

```python
# 来自 coordinator/agent_definitions.py — 内置 agent 角色
def get_builtin_agent_definitions() -> list[AgentDefinition]:
    return [
        AgentDefinition(name="default", description="General-purpose local coding agent"),
        AgentDefinition(name="worker", description="Execution-focused worker agent"),
        AgentDefinition(name="explorer", description="Read-heavy exploration agent"),
    ]
```

### Design Decisions

- Decision: 纯内存状态，无持久化 | Rationale: Coordinator 是运行时协调，不是长期存储 | TAD Implication: TAD 的 Alex/Blake 通过 handoff 文件持久化协调——更可靠但更重
- Decision: 字符串 task_id 引用 agent（松耦合） | Rationale: 不直接引用对象，支持分布式场景 | TAD Implication: TAD 的 terminal 隔离是更强的解耦——完全不共享状态
- Decision: 3 种内置角色（default/worker/explorer） | Rationale: 预定义常用 persona | TAD Implication: TAD 有 2 种固定角色（Alex/Blake），但通过 subagent 扩展到 10+ 种

---

## 7. Memory — Persistent Context

### Core Abstraction

基于文件的持久化记忆系统：每个项目一个独立目录（SHA1 hash 隔离），MEMORY.md 作为索引，topic 文件存储具体记忆。搜索用 token 匹配而非向量。

```python
# 来自 memory/types.py
@dataclass(frozen=True)
class MemoryHeader:
    path: Path
    title: str
    description: str
    modified_at: float
```

### Data Flow

`get_project_memory_dir(cwd)` → SHA1(cwd) 生成唯一目录 → `add_memory_entry()` 写入 topic 文件 + 更新 MEMORY.md 索引 → `scan_memory_files()` 扫描目录返回 MemoryHeader 列表 → `find_relevant_memories(query)` 用 token 匹配搜索相关记忆

### Key Code Pattern

```python
# 来自 memory/manager.py — 添加记忆条目
def add_memory_entry(cwd: str | Path, title: str, content: str) -> Path:
    memory_dir = get_project_memory_dir(cwd)
    slug = sub(r"[^a-zA-Z0-9]+", "_", title.strip().lower()).strip("_") or "memory"
    path = memory_dir / f"{slug}.md"
    path.write_text(content.strip() + "\n", encoding="utf-8")

    entrypoint = get_memory_entrypoint(cwd)
    existing = entrypoint.read_text(encoding="utf-8") if entrypoint.exists() else "# Memory Index\n"
    if path.name not in existing:
        existing = existing.rstrip() + f"\n- [{title}]({path.name})\n"
        entrypoint.write_text(existing, encoding="utf-8")
    return path
```

```python
# 来自 memory/search.py — token 匹配搜索
def find_relevant_memories(query: str, cwd: str | Path, *, max_results: int = 5) -> list[MemoryHeader]:
    tokens = {token for token in re.findall(r"[A-Za-z0-9_]+", query.lower()) if len(token) >= 3}
    if not tokens:
        return []
    scored: list[tuple[int, MemoryHeader]] = []
    for header in scan_memory_files(cwd, max_files=100):
        haystack = f"{header.title} {header.description}".lower()
        score = sum(1 for token in tokens if token in haystack)
        if score:
            scored.append((score, header))
    scored.sort(key=lambda item: (-item[0], -item[1].modified_at))
    return [header for _, header in scored[:max_results]]
```

### Design Decisions

- Decision: SHA1 hash 隔离项目目录 | Rationale: 不同路径的同名项目不会冲突 | TAD Implication: TAD 用项目路径做隔离（`.claude/projects/-path-hash/memory/`），概念等价
- Decision: token 匹配搜索而非向量搜索 | Rationale: 零依赖，足够简单的场景够用 | TAD Implication: TAD 的 memory 也用基于文件名/描述的匹配，无向量索引
- Decision: MEMORY.md 作为索引但可从目录重建 | Rationale: 目录是真相源，索引可再生 | TAD Implication: TAD 的 MEMORY.md 也是索引模式，与 OpenHarness 一致

---

## 8. Tasks — Background Task Management

### Core Abstraction

`BackgroundTaskManager` 管理异步子进程任务。4 种任务类型（local_bash, local_agent, remote_agent, in_process_teammate）。每个任务有独立日志文件，支持输入/输出流和自动重启。

```python
# 来自 tasks/types.py
TaskType = Literal["local_bash", "local_agent", "remote_agent", "in_process_teammate"]
TaskStatus = Literal["pending", "running", "completed", "failed", "killed"]

@dataclass
class TaskRecord:
    id: str
    type: TaskType
    status: TaskStatus
    description: str
    cwd: str
    output_file: Path
    command: str | None = None
    prompt: str | None = None
```

### Data Flow

`create_shell_task(command)` → 生成唯一 task_id（类型前缀 + UUID 前 8 位）→ 创建 log 文件 → `asyncio.create_subprocess_exec("/bin/bash", "-lc", command)` → 后台 `_watch_process()` 异步读取 stdout → 写入 log 文件 → 进程结束时更新 status（returncode=0→completed, 否则 failed）

### Key Code Pattern

```python
# 来自 tasks/manager.py — 创建 shell 任务
async def create_shell_task(self, *, command: str, description: str,
                            cwd: str | Path, task_type: TaskType = "local_bash") -> TaskRecord:
    task_id = _task_id(task_type)
    output_path = get_tasks_dir() / f"{task_id}.log"
    record = TaskRecord(
        id=task_id, type=task_type, status="running",
        description=description, cwd=str(Path(cwd).resolve()),
        output_file=output_path, command=command,
        created_at=time.time(), started_at=time.time(),
    )
    output_path.write_text("", encoding="utf-8")
    self._tasks[task_id] = record
    self._output_locks[task_id] = asyncio.Lock()
    await self._start_process(task_id)
    return record
```

```python
# 来自 tasks/manager.py — generation 防竞态
async def _watch_process(self, task_id: str, process, generation: int) -> None:
    reader = asyncio.create_task(self._copy_output(task_id, process))
    return_code = await process.wait()
    await reader
    current_generation = self._generations.get(task_id)
    if current_generation != generation:
        return  # Stale watcher, ignore
    task = self._tasks[task_id]
    task.return_code = return_code
    if task.status != "killed":
        task.status = "completed" if return_code == 0 else "failed"
```

### Design Decisions

- Decision: 任务 ID 前缀按类型（b=bash, a=agent, r=remote, t=teammate） | Rationale: 前缀使 ID 可读且可过滤 | TAD Implication: TAD 的 task ID 格式是 TASK-{date}-{seq}，按时间排序而非类型
- Decision: generation 计数器防竞态 | Rationale: agent 任务可重启，旧 watcher 需被忽略 | TAD Implication: TAD 的 state persistence（ralph loop state）是类似的状态管理策略
- Decision: 分离 input/output 锁 | Rationale: 读写互不阻塞 | TAD Implication: TAD 不直接管理子进程锁，但通过文件系统做隔离

---

## 9. Prompts — System Prompt Assembly

### Core Abstraction

分层 system prompt 组装：base prompt → 环境信息 → session mode → reasoning settings → skills → CLAUDE.md → issue/PR context → memory。每层可选，组合灵活。

```python
# 来自 prompts/system_prompt.py
_BASE_SYSTEM_PROMPT = """\
You are an AI assistant integrated into an interactive CLI coding tool. \
You help users with software engineering tasks including writing code, \
debugging, explaining code, running commands, and managing files.
"""
```

### Data Flow

`build_runtime_system_prompt(settings, cwd)` → 基础 prompt → `_format_environment_section()` 检测 OS/shell/git → fast_mode/effort/passes → skills 列表 → `discover_claude_md_files()` 向上遍历发现 CLAUDE.md → `load_memory_prompt()` + `find_relevant_memories(query)` → 拼接所有 section 返回

### Key Code Pattern

```python
# 来自 prompts/claudemd.py — CLAUDE.md 向上遍历发现
def discover_claude_md_files(cwd: str | Path) -> list[Path]:
    current = Path(cwd).resolve()
    results: list[Path] = []
    seen: set[Path] = set()
    for directory in [current, *current.parents]:
        for candidate in (
            directory / "CLAUDE.md",
            directory / ".claude" / "CLAUDE.md",
        ):
            if candidate.exists() and candidate not in seen:
                results.append(candidate)
                seen.add(candidate)
        rules_dir = directory / ".claude" / "rules"
        if rules_dir.is_dir():
            for rule in sorted(rules_dir.glob("*.md")):
                if rule not in seen:
                    results.append(rule)
                    seen.add(rule)
    return results
```

```python
# 来自 prompts/context.py — 运行时 prompt 组装（关键节选）
def build_runtime_system_prompt(settings, *, cwd, latest_user_prompt=None) -> str:
    sections = [build_system_prompt(custom_prompt=settings.system_prompt, cwd=str(cwd))]
    if settings.fast_mode:
        sections.append("# Session Mode\nFast mode is enabled...")
    sections.append(f"# Reasoning Settings\n- Effort: {settings.effort}\n- Passes: {settings.passes}")
    claude_md = load_claude_md_prompt(cwd)
    if claude_md:
        sections.append(claude_md)
    if settings.memory.enabled:
        memory_section = load_memory_prompt(cwd, max_entrypoint_lines=settings.memory.max_entrypoint_lines)
        if memory_section:
            sections.append(memory_section)
    return "\n\n".join(section for section in sections if section.strip())
```

### Design Decisions

- Decision: 向上遍历 CLAUDE.md（从 cwd 到根目录） | Rationale: 嵌套项目可继承/覆盖上层指令 | TAD Implication: TAD 也支持 CLAUDE.md 层级加载，设计一致
- Decision: 每个 section 有截断保护（max_chars_per_file=12000） | Rationale: 防止单个文件占满 context | TAD Implication: TAD 的 project-knowledge 也有 30KB 整合阈值，概念等价
- Decision: Memory 集成到 prompt 组装流程 | Rationale: 记忆是 context 的一部分，不是独立系统 | TAD Implication: TAD 的 @import 机制做类似的事——自动加载相关知识

---

## 10. Config — Settings & Path Management

### Core Abstraction

Pydantic `Settings` 模型作为唯一配置真相源。加载优先级：hardcoded defaults → `settings.json` → 环境变量 → CLI 参数。目录结构分离 config（配置）和 data（数据）。

```python
# 来自 config/settings.py
class Settings(BaseModel):
    api_key: str = ""
    model: str = "claude-sonnet-4-20250514"
    max_tokens: int = 16384
    permission: PermissionSettings = Field(default_factory=PermissionSettings)
    hooks: dict[str, list[HookDefinition]] = Field(default_factory=dict)
    memory: MemorySettings = Field(default_factory=MemorySettings)
    fast_mode: bool = False
    effort: str = "medium"
    passes: int = 1
```

### Data Flow

`load_settings()` → 读取 `~/.openharness/settings.json` → `Settings.model_validate(raw)` → `_apply_env_overrides()` 覆盖环境变量 → `merge_cli_overrides(**overrides)` 覆盖 CLI 参数 → 返回最终 Settings 实例

### Key Code Pattern

```python
# 来自 config/settings.py — Settings 加载与合并
def load_settings(config_path: Path | None = None) -> Settings:
    if config_path is None:
        config_path = get_config_file_path()
    if config_path.exists():
        raw = json.loads(config_path.read_text(encoding="utf-8"))
        return _apply_env_overrides(Settings.model_validate(raw))
    return _apply_env_overrides(Settings())

def _apply_env_overrides(settings: Settings) -> Settings:
    updates: dict[str, Any] = {}
    model = os.environ.get("ANTHROPIC_MODEL") or os.environ.get("OPENHARNESS_MODEL")
    if model:
        updates["model"] = model
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        updates["api_key"] = api_key
    if not updates:
        return settings
    return settings.model_copy(update=updates)
```

```python
# 来自 config/paths.py — 路径管理
def get_config_dir() -> Path:
    env_dir = os.environ.get("OPENHARNESS_CONFIG_DIR")
    if env_dir:
        config_dir = Path(env_dir)
    else:
        config_dir = Path.home() / ".openharness"
    config_dir.mkdir(parents=True, exist_ok=True)
    return config_dir
```

### Design Decisions

- Decision: Pydantic `model_copy(update=...)` 创建新实例而非原地修改 | Rationale: 不可变设置防止运行时意外变更 | TAD Implication: TAD 的 YAML config 是可读不可写的，但没有 Pydantic 的类型验证
- Decision: 支持 Anthropic 标准和 OpenHarness 专用环境变量 | Rationale: 兼容 Anthropic SDK 生态 | TAD Implication: TAD 不依赖环境变量配置，全部在 .tad/ 目录内
- Decision: 分离 config_dir 和 data_dir | Rationale: 配置可同步（git），数据本地存储 | TAD Implication: TAD 的 .tad/ 混合了 config 和 data，可考虑分离

---

## TAD Mapping

| OpenHarness 子系统 | TAD 对应物 | 差距 / 可借鉴 |
|---|---|---|
| Engine (Agent Loop) | Blake 执行循环 (Ralph Loop) | TAD 无显式 turn 上限；OpenHarness 默认 max_turns=8。TAD 用 circuit breaker（3 次相同错误）代替 |
| Tools (Registry) | Claude Code 内置工具 + MCP | TAD 不自建工具，依赖 Claude Code 平台。可借鉴：声明式工具注册 + Pydantic schema 自动生成 |
| Permissions (Checker) | settings.json permissions.deny + PreToolUse hook | TAD 有 2 层（deny + hook），OpenHarness 有 3 层（deny/allow + path rules + mode）。可借鉴：path-level rules |
| Hooks (Executor) | settings.json hooks（command type） | TAD 只用 command hook；OpenHarness 额外支持 http/prompt/agent hook。prompt hook 是 TAD 已验证可用的扩展 |
| Skills (Loader) | .claude/commands/*.md | TAD 和 OpenHarness 都用 Markdown skill 文件。OpenHarness 额外支持 plugin 覆盖。TAD 无 plugin 机制 |
| Coordinator (Registry) | Alex/Blake terminal isolation + parallel-coordinator | TAD 用人类作为唯一信息桥梁（更安全但更慢）；OpenHarness 用 TeamRegistry（更快但无人类审核） |
| Memory (Manager) | .claude/projects/.../memory/ | 两者都用文件系统 + MEMORY.md 索引。搜索方式相同（token 匹配）。设计高度一致 |
| Tasks (Manager) | Agent tool (subagent spawning) | TAD 通过 Agent tool 启动子 agent，不直接管理进程。OpenHarness 有完整的进程生命周期管理（包括 stdin/stdout 流） |
| Prompts (Assembly) | CLAUDE.md + @import + SessionStart hook | 两者都用 CLAUDE.md 分层加载。OpenHarness 额外集成 memory、issue context、reasoning settings 到 prompt |
| Config (Settings) | .tad/config.yaml + config-*.yaml 模块 | TAD 用 YAML 手动管理；OpenHarness 用 Pydantic JSON 自动验证。可借鉴：环境变量覆盖链、config/data 目录分离 |

---

## Agent Design Guidelines

### G1. Loop Control — 有限循环 + 安全阀（基于 Engine）

**Pattern**: 有限次数 agent loop + 多层安全机制
**When to use**: 任何 agent 都需要防止无限循环。设计 agent loop 时第一个决策就是循环上限。
**TAD implication**: TAD 的 Ralph Loop 用 circuit breaker（3 次相同错误升级到人类）代替硬上限，适合需要深度迭代的场景。对于轻量级 agent（如 MCP tool），建议加 max_turns 硬上限。

### G2. Tool Registration — 声明式注册 + Schema 自动生成（基于 Tools）

**Pattern**: 工具继承基类，声明 name/description/input_model，registry 自动聚合
**When to use**: 需要管理 5+ 个工具时。单个工具直接定义即可。
**TAD implication**: Domain Pack 的 tool_registry 可借鉴此模式——每个工具声明 capabilities 和 input schema，Domain Pack loader 自动聚合。

### G3. Permission Layering — 分层过滤器（基于 Permissions）

**Pattern**: deny list → allow list → path rules → mode policy，每层短路返回
**When to use**: 任何需要访问控制的 agent 系统。分层比单函数更易扩展和调试。
**TAD implication**: TAD 的 `permissions.deny > hooks > allow` 优先级已符合此模式。可补充：path-level rules 做更细粒度的文件保护（如禁止修改 .env）。

### G4. Lifecycle Hooks — 事件驱动扩展（基于 Hooks）

**Pattern**: 定义生命周期事件（pre/post），hook 按类型分发执行，支持阻止继续
**When to use**: 需要在不修改核心代码的情况下添加行为（日志、验证、安全检查）。
**TAD implication**: TAD 已用 command hook 做 PostToolUse 日志和 PreToolUse 验证。可扩展：用 prompt hook（Haiku 模型）做智能 gating。

### G5. Skill as Prompt Injection — Markdown 文件即能力（基于 Skills）

**Pattern**: Skill 不是代码而是 prompt，通过注入 system prompt 改变 agent 行为
**When to use**: 需要模块化的 agent 能力且不想写代码时。Markdown 比代码更易被非工程师编辑。
**TAD implication**: TAD 的 .claude/commands/*.md 完全是此模式。可借鉴 OpenHarness 的 plugin 覆盖机制——允许项目级 skill 覆盖全局 skill。

### G6. Minimal Coordination — 注册表 + 消息队列（基于 Coordinator）

**Pattern**: Team = agent 列表 + append-only 消息日志，无复杂调度
**When to use**: 需要多 agent 协作但不需要复杂编排时。大多数场景下简单的 team registry 就够了。
**TAD implication**: TAD 用文件化 handoff + 人类桥梁做协调，是更重但更安全的选择。对于 agent 间自动协调（如 Agent Team），可参考 OpenHarness 的轻量 TeamRegistry。

### G7. File-Based Memory — 文件系统即数据库（基于 Memory）

**Pattern**: 每个项目一个目录，MEMORY.md 索引 + topic 文件，token 匹配搜索
**When to use**: agent 需要跨 session 记忆但不需要向量搜索的场景（大多数）。
**TAD implication**: TAD 的 memory 系统与 OpenHarness 高度一致。可借鉴：`find_relevant_memories(query)` 基于用户当前输入动态搜索相关记忆并注入 prompt。

### G8. Layered Prompt Assembly — 分层组装 system prompt（基于 Prompts）

**Pattern**: base → environment → settings → skills → project instructions → memory，每层可选
**When to use**: 设计任何非 trivial 的 agent system prompt 时。
**TAD implication**: TAD 的 prompt 已是分层的（CLAUDE.md → @import → SessionStart hook → skill），但没有 OpenHarness 的 reasoning settings（effort/passes）和 issue context 层。可考虑：在 SessionStart hook 中注入 effort 设置。

### G9. Settings Validation — Pydantic 配置模型（基于 Config）

**Pattern**: Pydantic BaseModel 定义配置 schema，`model_validate()` 加载，`model_copy()` 合并
**When to use**: 配置项超过 10 个时。小项目用 dict 即可。
**TAD implication**: TAD 用 YAML 手动管理配置，无运行时 schema 验证。对于 Domain Pack YAML，可用 Pydantic 做加载时验证（已有 JSON schema，但不自动执行）。

### G10. Error as Context — 错误返回给模型而非抛异常（基于 Engine + Tools）

**Pattern**: 工具执行失败返回 `ToolResult(is_error=True)` 而非 raise，让模型看到错误并决定下一步
**When to use**: 任何 agent 工具系统。异常会中断 agent loop；错误上下文让模型能自我修正。
**TAD implication**: TAD 的 Ralph Loop 在 Layer 1 就是此模式——build/test 失败不终止，而是让 Blake 看到错误并修复。可推广到 Domain Pack 工具执行：失败结果返回给 agent 而非 crash。

---

## Key Metrics

| Metric | OpenHarness Default | Source File | TAD Equivalent |
|--------|--------------------:|-------------|----------------|
| max_turns | 8 | engine/query.py (QueryContext) | 无（Ralph Loop 无 turn 上限，用 circuit breaker） |
| max_tokens | 16,384 | config/settings.py (Settings) | 由 Claude Code 平台控制 |
| max_retries (API) | 3 | api/client.py | 无显式配置 |
| permission_modes | 3 (default/plan/full_auto) | permissions/modes.py | 2 (deny + hook gating) |
| hook_types | 4 (command/http/prompt/agent) | hooks/schemas.py | 1 (command only) |
| hook_timeout | 30s (command/http/prompt), 60s (agent) | hooks/schemas.py | 无超时控制 |
| tool_count | 43 built-in | tools/ directory | 依赖 Claude Code 内置工具 |
| skill_sources | 3 (bundled/user/plugin) | skills/loader.py | 1 (.claude/commands/) |
| agent_roles | 3 (default/worker/explorer) | coordinator/agent_definitions.py | 2 (Alex/Blake) + 10+ subagent types |
| memory_search_limit | 5 results, tokens ≥3 chars | memory/search.py | 由 MEMORY.md 行数限制（200 行） |
| config_precedence | 4 layers (default→file→env→CLI) | config/settings.py | 2 layers (YAML file → no override) |
| task_output_limit | 12,000 bytes (tail) | tasks/manager.py | 无限制（由 context window 约束） |

---

## Other Modules

以下 17 个模块不在本文档的 10 个核心子系统范围内，列出排除原因：

| Module | 排除原因 |
|--------|----------|
| `api` | 封装 Anthropic SDK，是实现细节不是架构模式 |
| `bridge` | UI 通信桥接（WebSocket/stdio），TAD 不需要 |
| `commands` | CLI 命令路由（typer），与 agent 架构无关 |
| `mcp` | MCP 客户端实现，TAD 已有 MCP 支持 |
| `keybindings` | 键盘快捷键配置，非 Harness 核心 |
| `vim` | Vim 模式支持，非 Harness 核心 |
| `voice` | 语音输入支持，非 Harness 核心 |
| `output_styles` | 输出渲染格式（markdown/plain），非 Harness 核心 |
| `ui` | 终端 UI 组件（Rich/Textual），非 Harness 核心 |
| `plugins` | 插件加载器；在 Skills 和 Config 章节已简要提及 |
| `services` | 内部服务胶水（dependency injection），非独立子系统 |
| `state` | 应用状态存储（session persistence），可在 Memory 章节参考 |
| `types` | 共享类型定义（TypeAlias），工具类 |
| `utils` | 工具函数（hash, slug, truncate），工具类 |
| `__init__.py` | 包入口，版本号 |
| `__main__.py` | CLI 入口点 |
| `cli.py` | typer 应用定义 |
