---
name: "TDD Enforcement"
id: "tdd-enforcement"
version: "1.0"
claude_subagent: "test-runner"
fallback: "self-check"
min_tad_version: "2.5"
platforms: ["claude"]
# New fields for opt-in skills (establishing pattern for future opt-in skills):
opt_in: true
config_key: "optional_features.tdd_enforcement.enabled"
---

# TDD Enforcement Skill

## Purpose
Guide Blake through RED-GREEN-REFACTOR cycle for each implementation unit.
Opt-in via config.yaml — disabled by default.

## When to Use
- Enabled: `tdd_enforcement.enabled: true` in `.tad/config.yaml`
- Best for: New features, API changes, business logic
- Less suited for: UI prototyping, config changes, documentation

## RED-GREEN-REFACTOR Cycle

### RED: Write Failing Test First
1. Read the acceptance criterion / task requirement
2. Write a test that verifies the requirement
3. Run test — confirm it FAILS (this proves the test checks something real)
4. If test passes without implementation → test is not specific enough, rewrite

### GREEN: Write Minimum Code to Pass
1. Write the simplest code that makes the failing test pass
2. Run test — confirm it PASSES
3. Do NOT add extra functionality beyond what the test requires

### REFACTOR: Clean Up
1. Review both test and implementation code
2. Remove duplication, improve naming, simplify
3. Run tests again — confirm all still pass
4. Commit

## Per-Task Application
For each task/AC in the handoff:
1. Run one RED-GREEN-REFACTOR cycle
2. Commit after each GREEN (small, atomic commits)
3. Move to next task/AC

## Anti-Rationalization (TDD-Specific)

| # | Excuse | Rebuttal |
|---|--------|----------|
| TDD1 | "太简单不需要测试" | 简单代码也会在重构中坏掉。测试只要 30 秒写。 |
| TDD2 | "我先写完代码再补测试" | 事后测试只测你写的，不测应该写的。先写测试确保测试独立于实现。 |
| TDD3 | "这是 UI 代码，没法 TDD" | UI 逻辑（状态管理、数据转换）可以 TDD。视觉渲染不需要。分离逻辑层。 |
| TDD4 | "测试框架还没配好" | 配置测试框架是实现的第一步，不是跳过 TDD 的理由。 |
| TDD5 | "时间紧迫，TDD 太慢" | TDD 前期投入换来后期零调试时间。总时间通常更短。 |

## Checklist (for Blake's self-check)

### Before Writing Any Implementation Code
- [ ] Test file created for this task/AC
- [ ] Test written and confirmed FAILING (RED)

### After Implementation
- [ ] Test passes (GREEN)
- [ ] Code refactored if needed (REFACTOR)
- [ ] No extra code beyond test requirements
- [ ] Committed with descriptive message
