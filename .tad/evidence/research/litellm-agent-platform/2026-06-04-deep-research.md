# LiteLLM Agent Platform — Deep Research Report

**Date:** 2026-06-04
**Notebook:** 7804448b-3489-494c-a6c9-4efde9634ef2 (13 sources, all ready)
**Method:** NotebookLM cross-source synthesis (5 deep ask rounds + summary)

---

## 1. What It Is

A self-hosted Kubernetes-based infrastructure platform for running AI coding agents (Claude Code, Codex, Hermes, OpenCode, Pi AI) in isolated sandboxes with a vault proxy for credential isolation.

- **Organization:** BerriAI / LiteLLM-Labs
- **Released:** 2026-05-08 (Alpha Public Preview)
- **Repo:** github.com/LiteLLM-Labs/litellm-agent-platform
- **Stats:** 592 stars, 60 forks, 36 open issues (as of 2026-06-04)
- **License:** MIT (confirmed by MarkTechPost/Aicosoft articles, though repo lacks LICENSE file)
- **Tech Stack:** TypeScript (platform), MJS (SDK server), Python (SDK client), Kubernetes

---

## 2. Architecture (Three-Layer Model)

### Layer 1: LiteLLM AI Gateway (Dependency)
Model routing, guardrails, cost tracking, rate limiting across 100+ LLM APIs. The Platform builds on top of this existing product.

### Layer 2: lite-harness-sdk (Core Innovation)
Unified NDJSON stream-JSON protocol that abstracts multiple agent harnesses:

- **Wire format:** One JSON object per line, UTF-8, `\n` terminated, flush after every line
- **Multiplexed:** user/assistant/system/control/result messages share single stdin/stdout stream, demuxed by `type` field
- **Provider adapters:** Anthropic (canonical — minimal translation), Codex, Hermes (ACP client), Pi AI
- **Forward compatibility:** Unknown message/block types decode to safe fallbacks, never crash
- **Session modes:** One-shot (`query()`) or long-lived (keep process open, write additional user lines)
- **HTTP bridge:** Managed Agents server translates subprocess frames to Claude Managed Agents wire format (api.anthropic.com/v1 compatible)

### Layer 3: K8s Sandbox (kubernetes-sigs/agent-sandbox)
Official Kubernetes SIG Apps project with 4 CRDs:

| CRD | Purpose |
|-----|---------|
| Sandbox | Core: stateful pod + stable hostname + persistent storage |
| SandboxTemplate | Reusable configs for stamping out identical sandboxes |
| SandboxClaim | Dynamic request abstraction (frameworks like LangChain use this) |
| SandboxWarmPool | Pre-warmed idle pods for instant allocation |

- **Isolation backends:** gVisor (syscall interception, user-space) and Kata Containers (per-pod VM, own kernel)
- **Cold start:** ~10s without warm pool, <2s with SandboxWarmPool
- **LiteLLM usage:** Creates Sandbox CR per session, deletes on cleanup

---

## 3. Security Model: Vault Proxy

The most innovative security design:

1. Agent process only sees **stub credentials** (e.g., `sk-stub-xxx`)
2. All outbound HTTPS intercepted by vault **sidecar container**
3. Sidecar swaps stubs for real API keys **at wire level**
4. Real keys exist **only in sidecar memory** — never logged, never stored, never accessible to agent
5. `GIT_TOKEN` special handling: clone-and-wipe (token erased after repo clone)
6. User-defined env vars via `CONTAINER_ENV_` prefix are injected verbatim (these ARE visible to agent)
7. Limits: max 50 env var keys, total ≤16 KB JSON-encoded

**Security guarantee:** Prompt injection that exfiltrates environment variables only gets stubs. Real keys are never in agent's address space.

---

## 4. Integrations Framework

Provider-based pattern with 3 adapters per provider: OAuth + Webhook + Outbound.

| Provider | Status | Notes |
|----------|--------|-------|
| Linear | ✅ Full | GraphQL activity creation, webhook + HMAC-SHA256 |
| Slack | 🔧 Code exists | OAuth + webhook handlers present |
| GitHub | 📋 Planned | — |
| JIRA | 📋 Planned | — |

**Known gaps:** No UI for integration management, `forwardSessionEvent` not fully wired, "one binding per install" per workspace.

**Token storage:** AES-256-GCM encryption at rest.
**CSRF limitation:** In-process memory with 10-min TTL — single instance only.

---

## 5. Session Persistence (Split Model)

| Component | Persistence | Survives restarts? |
|-----------|-------------|-------------------|
| Main Platform | Postgres-backed | ✅ Yes |
| Managed Agents Server (V0) | In-memory only | ❌ No |

Important distinction: the platform's marketing says "persistent sessions" but the V0 Managed Agents bridge is entirely in-memory.

---

## 6. Production Readiness Assessment

| Dimension | Status | Details |
|-----------|--------|---------|
| API stability | 🟡 Alpha | Forward-compat at wire level, but features still "v1 scope" |
| Auth model | 🔴 Single-tenant | MASTER_KEY only, no RBAC, no multi-user |
| Horizontal scaling | 🔴 Limited | CSRF in-memory, V0 sessions in-memory |
| Isolation | 🟢 Strong | gVisor + Kata + vault proxy |
| Session persistence | 🟡 Split | Main platform yes, V0 bridge no |
| Integrations | 🟡 Partial | Linear only, 3 planned |
| Documentation | 🟢 Good | PROTOCOL.md + DEVELOPER.md + README chain |
| Testing | 🟢 Good | Parity tests, E2E tests, behavior tests in repo |

---

## 7. Competitive Positioning

| Platform | vs LiteLLM Agent Platform |
|----------|--------------------------|
| Anthropic hosted Claude Code | SaaS, no ops, but data leaves your env |
| E2B | Managed sandbox provider — less control, no vault proxy |
| Modal | Serverless compute, not agent-specific |
| Daytona/Gitpod | Dev environments, not agent runtime |
| kubernetes-sigs/agent-sandbox | LiteLLM's dependency — only isolation, no agent management |
| Northflank | Commercial managed sandbox (GPU, multi-cloud) |

**Unique value:** Multi-harness abstraction + vault proxy + K8s CRD + session persistence in one self-hosted package.

**Best for:** Regulated enterprises (data sovereignty), multi-team production environments.
**Overkill for:** Simple inference tasks, teams without K8s expertise.

---

## 8. Relevance to TAD

| TAD Concern | LiteLLM Insight |
|-------------|----------------|
| Cross-model orchestration | lite-harness-sdk's NDJSON protocol is a production-grade answer to "how to abstract multiple agent runtimes" |
| Dynamic Workflow Adapter | Provider adapter pattern (anthropic/codex/hermes transformation.mjs) maps directly to TAD's dual-platform adapter idea |
| Security | Vault proxy's stub-swap pattern is superior to TAD's direct env var approach |
| Agent Templates | Their `agent-templates/` (skill.md files) mirrors TAD's Capability Pack concept |
| Session Management | Fire-and-forget + SSE + turn lock is a clean pattern for async agent communication |
