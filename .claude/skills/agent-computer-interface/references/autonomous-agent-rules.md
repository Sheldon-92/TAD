# L4: Autonomous Agent Rules
last_verified: 2026-06-17

## Tools in This Layer

| Tool | License | Stars/Status | Primary Use | Token Cost (type) |
|------|---------|-------------|-------------|-------------------|
| Browser Use | MIT | ~99k stars | Full autonomous browser agent (goal→plan→execute→verify) | Per-session: high (LLM cost per step, multi-step) |
| Skyvern | OSS + commercial | Cloud platform | Vision+LLM autonomous agent, no-code UI | Per-session: 10x+ vs DOM-based (vision overhead) |
| Open Operator | MIT | OpenAI-backed | Autonomous browser agent | Per-session: high |
| Vercel Agent Browser | Rust CLI | ~5k stars | Semantic snapshot CLI agent (@e1 labels) | Per-session: moderate (token-efficient snapshots) |

## Decision Rules

### R1: Browser Use for Complex Cross-Site Autonomous Tasks
> When the task requires autonomous multi-step browsing across different sites with reasoning (e.g., "research competitors and compile a comparison"), use Browser Use as the default L4 agent.

Browser Use achieved 89.1% success rate on the WebVoyager benchmark (586 tasks). It uses an LLM+DOM agent loop with natural language instructions, supports multi-tab browsing, and handles complex cross-site reasoning. The trade-off: high LLM cost per step (each action requires an LLM call for decision-making).

Source: theaiagentindex.com "Browser Use Review 2026" + GitHub repository (~99k stars as of 2026-06). WebVoyager benchmark result from official documentation.

### R2: Skyvern for Non-Technical Users and Form-Heavy Legacy Systems
> When the end user is non-technical or the target site is a form-heavy legacy system (insurance portals, government forms), prefer Skyvern's no-code UI over Browser Use's developer-oriented API.

Skyvern uses a vision+LLM plan-execute-verify loop with a graphical interface. This means non-developers can configure and monitor autonomous browsing workflows. The cost is 10x+ higher than DOM-based agents (vision processing overhead per step). Use Skyvern when the audience is non-technical; use Browser Use when developers control the workflow.

Source: aimultiple.com "Best 30+ Open Source Web Agents" + Skyvern documentation (retrieved 2026-06-17).

### R3: Session Isolation — Fresh Context Per Task
> Every autonomous browsing session MUST start with a clean browser context (no cookies, no history, no cached credentials from previous sessions).

Autonomous agents that inherit state from previous sessions risk: (a) acting on stale authentication, (b) mixing data between unrelated tasks, (c) exposing credentials from task A to task B's target site. Use a fresh browser profile for each autonomous session. Browser Use supports `--new-context` flag; Skyvern creates isolated sessions by default.

Source: security best practice derived from agent architecture analysis.

### R4: Domain Scoping — Restrict Navigation to Approved Sites
> Before starting an autonomous browsing session, define an explicit allowlist of domains the agent may visit. Navigation to unlisted domains MUST be blocked or require user confirmation.

An unrestricted autonomous agent can follow links to malicious sites, trigger unintended downloads, or visit sites that capture the agent's IP/fingerprint. Define the domain scope upfront: `allowed_domains: ["example.com", "api.example.com"]`. Log all navigation attempts outside the scope.

Source: derived from Browser Use architecture analysis + general agent safety practice.

### R5: Credential Entry — Require User Confirmation Before Typing Passwords
> An autonomous agent MUST NOT type passwords or sensitive credentials without explicit user confirmation per instance. Pre-configured credentials in environment variables are acceptable; ad-hoc credential entry is not.

If the task requires login: (a) prefer pre-configured credentials in `.env` files, (b) if interactive login is needed, pause and ask the user to enter credentials manually, (c) NEVER have the agent type credentials it discovered from page content or previous sessions. Log every credential-entry event.

Source: security best practice for autonomous agent systems.

### R6: Cost Estimation Before Execution
> Before starting a multi-step autonomous browsing session, estimate the total LLM token cost and present it to the user. If estimated cost exceeds 100k tokens, require explicit user confirmation.

Each Browser Use step costs roughly 2-5k tokens (LLM prompt + page context + response). A 20-step autonomous task costs 40-100k tokens. Complex tasks (50+ steps) can exceed 250k tokens. Present the estimate: "This task will take approximately {N} steps, estimated cost: {tokens}k tokens. Proceed?"

Source: estimated from Browser Use per-step token overhead, cross-referenced with session cost reports.

## Security Considerations (MANDATORY)

### Domain Isolation
- Define `allowed_domains` before every autonomous session
- Block or prompt on out-of-scope navigation
- Log all navigation events for audit

### Credential Safety
- Credentials in `.env` only (add to `.gitignore`)
- Never type credentials from page content
- User confirmation before every password entry
- Session credential isolation (no cross-session leakage)

### Session Hygiene
- Fresh browser context per task
- Clear cookies/storage after session
- No persistent state between autonomous runs

## Configuration Guide

### Browser Use Setup
```bash
# Install (use virtual environment)
python -m venv .venv && source .venv/bin/activate
pip install browser-use

# Set LLM API key in .env (add to .gitignore!)
echo "OPENAI_API_KEY=YOUR_API_KEY_HERE" >> .env
echo ".env" >> .gitignore

# For Claude as the LLM backend:
echo "ANTHROPIC_API_KEY=YOUR_API_KEY_HERE" >> .env
```

### Browser Use Node SDK
```bash
# Node.js SDK (newer)
npm install @anthropic-ai/browser-use
```

## Fallback Chain

1. **Browser Use** (preferred for developer-controlled autonomous browsing)
2. → Skyvern (if non-technical user or no-code UI needed)
3. → Open Operator (if Browser Use unavailable)
4. → **Degrade to L3**: Stagehand with manual step orchestration (cross-layer DOWN — automatic, no confirmation needed)
5. → **Report to user**: "No autonomous agent available. Install: `pip install browser-use`"

L4 → L3 degradation is same-direction (down), no confirmation needed. L4 → L5 escalation (e.g., to Computer Use for non-browser tasks) requires user confirmation per Cross-Cutting Rule 3.
