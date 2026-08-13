# Agentic Testing Rules
<!-- capability: agentic_testing -->

> The CURRENT way AI authors and heals tests. Use these APIs instead of copying
> hand-written tutorial examples — the failure mode this pack exists to fix is
> "agent copies a tutorial test." Playwright now ships first-class agent tooling.

## Quick Rule Index

| # | Rule | When |
|---|------|------|
| G1 | Playwright Test Agents: Planner -> Generator -> Healer | Authoring tests with an LLM |
| G2 | `browser.bind()` exposes a live browser to MCP/CLI agents (v1.59) | Driving a browser from an agent |
| G3 | `--debug=cli` for agent-driven test repair | Healing failing tests |
| G4 | Generate from a plan, not from a tutorial | Avoiding copied boilerplate |

---

## Rules

### G1: Playwright Test Agents (v1.56+)

When using an LLM to author Playwright tests, use the three **Test Agent definitions** shipped in **Playwright v1.56** (current stable **1.60**) — these are LLM-guiding definitions, not hand-written scripts:

- **Planner**: explores the running app and emits a **Markdown test plan** (scenarios, steps, expected outcomes). The plan is reviewable by a human before any code exists.
- **Generator**: turns the approved Markdown plan into **Playwright test files** (`*.spec.ts`). Generation is grounded in the real DOM the Planner observed, not in a guessed selector.
- **Healer**: **runs the tests, and auto-repairs failures** (updated selectors, waits, assertions) by re-inspecting the live page.

The pipeline is **Planner -> (human review) -> Generator -> Healer**. The human-review gate on the Markdown plan is what keeps the agent from inventing flows the product doesn't have.

### G2: Expose a Live Browser to Agents — `browser.bind()` (v1.59)

When an agent needs to drive a browser the test launched:

- **Playwright 1.59 added `browser.bind()`** — it exposes a launched browser instance to **`playwright-cli` / MCP clients**. The agent can attach to the *same* browser the test framework controls, rather than spawning a blind second session.
- This is the integration point for the Chrome MCP / `claude-in-chrome` style tooling: bind, then let the agent observe and act on the real page.

### G3: `--debug=cli` for Agent-Driven Repair (v1.59)

When tests fail and you want an agent to fix them:

```bash
npx playwright test --debug=cli   # agent-driven test repair loop (v1.59+)
```

- Drops into a CLI debug mode designed for an agent (not a human DevTools session) to inspect the failure and propose a fix — pairs with the **Healer** agent (G1).

### G4: Generate From a Plan, Not From a Tutorial

When an agent writes tests:

- **Always run the Planner first** so generation is grounded in the actual rendered app (real roles, real text, real selectors). A test generated from a tutorial uses selectors that don't exist in your app and breaks on first run.
- **Review the Markdown plan** before generating code — cheaper to fix a wrong scenario in prose than in 200 lines of spec.
- Prefer **role/text locators** the Planner discovered (`getByRole`, `getByText`) over CSS selectors — they survive refactors (ties back to test-strategy-rules.md S5 flaky causes).

```bash
# Pin a Playwright with Test Agents (>= 1.56; current 1.60)
npm i -D @playwright/test@^1.60 && npx playwright install
```

---

## Anti-Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| Copying a tutorial `*.spec.ts` | Selectors don't match your app | Run the Planner to ground generation in the real DOM (G4) |
| Hand-fixing every flaky selector | Slow, repetitive | Use the Healer agent + `--debug=cli` (G1/G3) |
| Spawning a second blind browser for the agent | Agent acts on a different page than the test | `browser.bind()` to share the launched browser (G2) |
| Generating code before a reviewed plan | Agent invents nonexistent flows | Planner -> human-review -> Generator (G1) |

---

## Sources

- Playwright release notes (Test Agents v1.56; `browser.bind()` + `--debug=cli` v1.59; current 1.60) — https://playwright.dev/docs/release-notes (retrieved 2026-06-13)
