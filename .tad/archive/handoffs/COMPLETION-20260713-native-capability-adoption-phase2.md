# Completion Report — Phase 2: Subagent Frontmatter Upgrades (YOLO)

- **Epic**: EPIC-20260712-native-capability-adoption (Phase 2/4)
- **Handoff**: `.tad/active/handoffs/HANDOFF-20260713-native-capability-adoption-phase2.md` (read from main working dir; file is untracked there and thus not visible inside the worktree)
- **Blake execution date**: 2026-07-13
- **Worktree**: `/Users/sheldonzhao/01-on progress programs/TAD/.claude/worktrees/wf_f91fb5e4-5de-1`
- **Phase status**: **DEGRADED (honest partial)** — spike gated out the two headline features; unconditional deliverables shipped; zero silent drops.

## Blake understanding confirmation (Intent §1.3)

1. Problem: reviewers cold-start every spawn and pack knowledge reaches them only via handoff transcription; the fix was to adopt native `memory`/`skills` frontmatter — IF a local spike proves the fields real.
2. Usage: reviewer defs in `.claude/agents/` would accumulate defect patterns across sessions and preload code-security for security-auditor.
3. Success standard: behavioral (RUN2 recall of a stored canary; rule citation without Read), never structural presence.

## Spike outcome (drives everything below)

| Topic | Verdict | Evidence |
|---|---|---|
| `memory` frontmatter field | **FAIL** — silently accepted, fully inert (boolean AND path forms; no dir created, nothing injected into system prompt) | spike-report.md §1 |
| `skills` frontmatter field | **FAIL** — not preloaded, not even attached/available | spike-report.md §2 + behavioral-evidence AC6 |
| Project-level shadowing of same-name user agent | **PASS** — complete body replacement, zero merge/leak | spike-report.md §3 |

Degradation matrix branch: rows 1+2 combined (memory FAIL + skills FAIL) → deliver spike report + unconditional spec-compliance-reviewer registration + Escalations. FR2 shadow defs, FR3 active boundary, FR4 gitignore, FR5 preload: not deliverable on CLI 2.1.172 (see §Escalations — value kept, automation deferred, nothing silently dropped).

## Files changed

| File | Op | Purpose |
|---|---|---|
| `.claude/agents/spec-compliance-reviewer.md` | create | AC8 unconditional deliverable — persona registered project-level (behaviorally verified by spawn); carries dormant Memory Protocol boundary (with literal `MUST NOT store past verdicts` anchor) for the day a memory mechanism exists; no `memory:` key (field is inert — dead config would be theater and would break AC3's sanctioned VACUOUS-PASS branch) |
| `.tad/evidence/spikes/subagent-frontmatter-2026-07/START_MARKER` | create | FR7 baseline |
| `.tad/evidence/spikes/subagent-frontmatter-2026-07/spike-report.md` | create | FR1 — 3 VERDICT lines + raw transcripts + landing-point evidence |
| `.tad/evidence/spikes/subagent-frontmatter-2026-07/fm-lint.sh` | create | AC2 stdlib-only frontmatter lint (T1 deliverable; bash 3.2 / BSD-safe) |
| `.tad/evidence/spikes/subagent-frontmatter-2026-07/fixtures/tad-spike-memory-agent.md` | create (moved) | Spike agent preserved as fixture — `.claude/agents/` left with zero spike residue (CR P1-2 deterministic cleanup) |
| `.tad/evidence/spikes/subagent-frontmatter-2026-07/fixtures/code-reviewer.md` | create (moved) | Temp shadowing-test def preserved as fixture |
| `.tad/evidence/yolo/native-capability-adoption/phase2-behavioral-evidence.md` | create | FR6/AC5/AC6 evidence + SPAWN-METHOD + FR7 raw output |
| `.tad/evidence/yolo/native-capability-adoption/phase2-completion.md` | create | this report |
| `.gitignore` | **unchanged** | FR4 NOT_APPLICABLE_WITH_REASON — no memory landing point exists anywhere (field inert; `~/.claude/agent-memory` and repo `.claude/agent-memory` both nonexistent, spike-report §1) |
| Blake SKILL / handoff template | **unchanged** | AC9 — dynamic-scenario transcription mechanism (1_5a) intentionally retained |

## Layer 1 results

| Check | Result | Note |
|---|---|---|
| `npx tsc --noEmit` | N/A (exit 1: "no tsconfig.json / not a TS project" — tsc printed usage help) | Repo contains no TypeScript; handoff §2.3/§8.1 explicitly designates the Layer 1 substitute for this repo: frontmatter lint + spawn-tests |
| Layer 1 substitute: `fm-lint.sh` | **PASS** — `FM-OK (1 files)` | AC2 |
| Layer 1 substitute: spawn-tests | **PASS** — 8 independent headless spawns, all resolved and responded | spike-report + behavioral-evidence |
| `npm test` | **PASS** (exit 0) | stub: `echo "No tests yet"` |
| `npm run lint` | N/A | no lint script in package.json |

## AC verification table (§9.1, executed 2026-07-13)

| AC | Result | Actual output |
|---|---|---|
| AC0 CLI baseline | PASS | `2.1.172 (Claude Code)` |
| AC0b code-security pack exists | PASS | `.claude/skills/code-security/SKILL.md` |
| AC0c no project agents baseline | PASS | `ls: .claude/agents: No such file or directory` (pre-impl) |
| AC1 spike 3 verdicts | PASS | grep count = `3` |
| AC2 frontmatter lint | PASS | `FM-OK (1 files)` |
| AC3 boundary in memory-enabled defs | PASS (sanctioned branch) | `VACUOUS-PASS (no memory defs)` — legal ONLY under memory-VERDICT=FAIL, which is the case |
| AC4 memory landing gitignored | NOT_APPLICABLE_WITH_REASON | No landing point exists in-repo OR out — field inert (spike-report §1) |
| AC5 memory recall behavioral (expect 2) | DEGRADED (0) | Mechanism absent; three-run test not runnable without contamination theater — sanctioned degradation, Escalation E1 |
| AC6 skills preload behavioral (expect 1) | DEGRADED (0) / NOT_APPLICABLE_WITH_REASON | Test WAS executed (tool-banned spawn): `NO-PRELOADED-SKILLS` → `SKILLS-PRELOAD: FAIL` — Escalation E2 |
| AC7 zero machine-global writes | PASS | `find -newer START_MARKER` → `0` |
| AC8 spec-compliance-reviewer registered | PASS | grep count = `1` + independent behavioral spawn responded in-persona |
| AC9 Blake SKILL / template zero diff | PASS | grep count = `0` |
| AC10 change scope = §7 files | PASS (1 documented exception) | After restoring hook-flipped `.tad/research-notebooks/REGISTRY.yaml` (not my edit — staleness hook fired during nested sessions), only `.tad/evidence/traces/2026-07-13.jsonl` remains outside scope: emitted by TAD's own PostToolUse trace hook recording THIS task's evidence writes; left uncommitted rather than deleted (deleting a trace = tampering with the audit trail). See E5 |

## Sub-Agent usage record (handoff §12)

| Sub-Agent | Called | When | Output summary | Evidence |
|---|---|---|---|---|
| tad-spike-memory-agent (spawn-test ×5) | ✅ | Phase 1 | SPIKE-ALIVE; NO-MEMORY-DIRECTORY (both field forms); NO-PRELOADED-SKILLS; NO-ATTACHED-SKILLS | spike-report.md |
| code-reviewer temp shadow (spawn-test ×2) | ✅ | Phase 1 | SHADOW-MARKER echoed; user-level body NOT present (clean replacement) | spike-report.md §3 |
| spec-compliance-reviewer (spawn-test ×1) | ✅ | Phase 3 | In-persona role + report-format statement (registration is behavioral) | phase2-behavioral-evidence.md |
| memory-enabled reviewer ×2 RUN | ❌ | — | Not runnable: mechanism absent (degradation matrix row 1) | behavioral-evidence AC5 section |
| security-auditor preload (spawn-test) | ❌ | — | Pairing not delivered (skills FAIL); equivalent test already executed on spike agent | behavioral-evidence AC6 section |

Spawn mechanism note: this Blake context has no Task tool; spawns were performed as independent headless CLI sessions (`claude -p --agent <name>` from repo root) — each a fresh session, no state reuse (documented as SPAWN-METHOD in evidence, per Friction Preflight row 2's allowed substitute).

## §Escalations

- **E1 (memory FAIL — Epic NFR2)**: `memory` frontmatter field is inert on CLI 2.1.172 (accepted silently, no semantics). Reviewer persistent memory NOT deliverable natively. Options for human/Alex: (a) wait for CLI support and re-spike on a later version; (b) new design — `.tad/`-managed self-managed memory files injected via prompt (explicitly NOT built here per handoff §4.1: proposal only). The dormant boundary section already ships in spec-compliance-reviewer.md so option (a)/(b) inherits it.
- **E2 (skills FAIL — Epic NFR2)**: `skills` frontmatter field neither preloads nor attaches packs. `security-auditor ← code-security` static pairing NOT delivered; handoff transcription + Blake 1_5a remains the only pack-delivery mechanism (AC9 confirms zero changes to it).
- **E3 (.claude/agents/ distribution policy — handoff §Project-Knowledge lesson 4)**: new `.claude/agents/` dir is invisible to BOTH distribution paths (derive-sync-set walks `.tad/*/` only; tad.sh .claude copy is a hardcoded allow-list). No automatic fallback exists. Human decision required before next *publish: recommend **main-repo-only** (spec-compliance-reviewer def is TAD-project-specific); if ever distributed, add explicit copy path + same-granularity verifier.
- **E4 (machine-global data)**: none created — memory field inert, `~/.claude/agents/` untouched (AC7 = 0). No machine-global concern this phase.
- **E5 (trace file)**: `.tad/evidence/traces/2026-07-13.jsonl` (3 lines) was auto-emitted by the TAD trace hook during this task, in-worktree, outside AC10's exemption list. Left uncommitted + undeleted. Suggest AC10-style scope checks exempt `.tad/evidence/traces/` in future handoffs.
- **E6 (minor design decision)**: spec-compliance-reviewer `model:` not specified by handoff — set to `sonnet` (row-by-row mechanical verification; user-level reviewers use opus). Flag if opus preferred.
- **E7 (handoff visibility)**: the handoff file is untracked in the main repo, hence absent from this worktree; read from the main working dir (read-only). No cross-project modification made.

## Spike fixture disposition (handoff §4.2 item 1)

`tad-spike-memory-agent.md` and the temp `code-reviewer.md` were **moved to `fixtures/`** (not deleted): they are the reproducible test rig for re-running the spike on a future CLI version (E1 option a). `.claude/agents/` contains only the production def.
