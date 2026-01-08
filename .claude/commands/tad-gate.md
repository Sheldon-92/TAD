# /gate Command (Execute Quality Gate)

## 🎯 自动触发条件

**Claude 应主动调用此 skill 的场景：**

### 必须执行 Gate 的时机
- **Gate 1**: Alex 完成 3-5 轮需求挖掘后，**进入设计前**
- **Gate 2**: Alex 完成设计，**创建 handoff 前**
- **Gate 3**: Blake 完成实现，**提交代码前**
- **Gate 4**: Blake 完成集成，**交付用户前**

### ⚠️ 强制规则
```
规则 1: Alex 创建 handoff → 必须先执行 Gate 2
规则 2: Blake 完成实现 → 必须执行 Gate 3
规则 3: Blake 完成集成 → 必须执行 Gate 4
规则 4: Gate 不通过 → 阻塞下一步，必须修复
```

### 如何激活
```
场景 1: Alex 准备创建 handoff
Alex: 设计已完成，准备创建 handoff
     → 必须先调用 /gate 2
     [调用 Skill tool with skill="tad-gate" args="2"]

场景 2: Blake 实现完成
Blake: 代码已实现，准备提交
      → 必须先调用 /gate 3
      [调用 Skill tool with skill="tad-gate" args="3"]
```

**核心原则**: Gate 是强制检查点，不可跳过

---

When this command is triggered, execute the appropriate quality gate based on current context:

## Gate Detection and Execution

```
Quality Gate Execution
======================

Detecting current context...

Available Gates:
1. Gate 1: Requirements Clarity (Agent A - After elicitation)
2. Gate 2: Design Completeness (Agent A - Before handoff)
3. Gate 3: Implementation Quality (Agent B - After coding)
4. Gate 4: Integration Verification (Agent B - Before delivery)

Which gate to execute? (1-4):
```

## Gate 1: Requirements Clarity (Alex) - Optional Quick Check
```yaml
When: After requirement elicitation
Owner: Agent A (Alex)
Quick Check (3 items):
  - [ ] User confirmed understanding
  - [ ] Success criteria defined
  - [ ] Requirements documented
Output: Quick summary, no formal evidence required
```

## Gate 2: Design Completeness (Alex) - **MANDATORY** 🔴
```yaml
When: Before creating handoff (BLOCKING)
Owner: Agent A (Alex)
Critical Check (4 items):
  - [ ] Architecture complete
  - [ ] Components specified
  - [ ] Functions verified (exist in codebase)
  - [ ] Data flow mapped
Evidence: Record in handoff header
Output Format:
  ### Gate 2 Result
  | Item | Status | Note |
  |------|--------|------|
  | Architecture | ✅ Pass | ... |
  | Components | ✅ Pass | ... |
  | Functions | ⚠️ Partial | 缺少 xxx |
  | Data Flow | ✅ Pass | ... |
```

## Gate 3: Implementation Quality (Blake) - **MANDATORY** 🔴
```yaml
When: After implementation (BLOCKING)
Owner: Agent B (Blake)
Critical Check (3 items):
  - [ ] Code complete (all handoff tasks done)
  - [ ] Tests pass (no failing tests)
  - [ ] Standards met (linting, formatting)
Evidence: Record in completion report
Output Format:
  ### Gate 3 Result
  | Item | Status | Note |
  |------|--------|------|
  | Code Complete | ✅ Pass | ... |
  | Tests Pass | ✅ Pass | ... |
  | Standards | ✅ Pass | ... |
```

## Gate 4: Integration Verification (Blake) - **MANDATORY** 🔴
```yaml
When: Before delivery (BLOCKING)
Owner: Agent B (Blake)
Critical Check (2 items):
  - [ ] Integration works (system-level test)
  - [ ] Ready for user (no known blockers)
Evidence: Record in NEXT.md or completion report
Output Format:
  ### Gate 4 Result
  | Item | Status | Note |
  |------|--------|------|
  | Integration | ✅ Pass | ... |
  | User Ready | ✅ Pass | ... |
```

## Interactive Gate Execution

For each gate, use 0-9 options format:

```
Gate [N]: [Name] Execution

Status Check:
✅ [Criterion]: Pass
❌ [Criterion]: Fail - [Issue]
⚠️ [Criterion]: Warning - [Concern]

Please select action (0-8) or 9 to pass gate:
0. Review checklist again
1. Fix failing items
2. Collect more evidence
3. Run additional tests
4. Use sub-agent for help
5. Document issues found
6. Request clarification
7. Partial pass with notes
8. Fail gate (restart phase)
9. Pass gate (all criteria met)

Select 0-9:
```

## Violation Handling

```
⚠️ GATE VIOLATION DETECTED ⚠️
Type: Attempting to skip Gate [N]
Required: Must execute gate before proceeding
Action: BLOCKED until gate executed

To continue:
1. Execute gate properly
2. Address any failures
3. Collect evidence
4. Get pass result
```

[[LLM: This command executes the appropriate quality gate based on current agent and project phase. Gates are mandatory checkpoints that ensure quality.]]