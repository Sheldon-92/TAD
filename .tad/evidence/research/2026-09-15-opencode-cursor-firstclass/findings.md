# OpenCode / Cursor "First-Class Platform" — Research Findings

- **Task**: `TASK-2026-09-15-OPENCODE-CURSOR-FIRSTCLASS` (research only; no code)
- **Author**: Alex (Solution Lead) — research identity
- **Date**: 2026-09-16
- **Baseline**: TAD `v3.0.0` (commit `20223774`, tag `v3.0.0`); Claude Code path removed,
  skill SSOT = `.agents/skills/`, `tad.sh` platform matrix converged to `codex`.
- **Boundaries honored**: `docs/pm/` read-only; no commit; no production edits.

---

## 0. Verdict (lead)

**Current state is "open-box usable, not first-class."** Both OpenCode and Cursor
natively discover `.agents/skills/` and read `AGENTS.md`, so TAD's core value
(Alex/Blake roles, Gate skills, capability packs) loads with zero changes — but the
installer actively rejects non-Codex targets, no OpenCode/Cursor hooks are generated
(losing session-health, trace, askuser-capture, compact-recovery), and the documented
activation route (`$alex` / `$blake`) plus the "Codex-Specific Notes" are harness-wrong.

**Recommendation**: Do **not** stand up a broad new Epic. If OpenCode/Cursor usage is
real, ship a single bounded "Platform Adapters v1" mini-track (overall **M**, 3 small
deliverables). If Codex stays the house runtime, defer P2 (hooks) and only do the
**S**-sized honesty/install fixes. The marginal user value today is small because the
dominant asset — the skill tree — already works.

---

## 1. Part 1 — Native `.agents/skills/` discovery (verified against vendor docs)

| Harness | Project discovery | Global discovery | Other instruction file | Source |
|---|---|---|---|---|
| **OpenCode** | `.agents/skills/<name>/SKILL.md` (agent-compatible) + `.opencode/skills/` | `~/.agents/skills/`, `~/.config/opencode/skills/` | `AGENTS.md` (project root + global) | `dev.opencode.ai/docs/skills`, `opencode.ai/docs/rules` |
| **Cursor** | `.agents/skills/` + `.cursor/skills/` (recursive, nested subdirs, monorepo) | `~/.agents/skills/`, `~/.cursor/skills/` | `AGENTS.md` (root + nested subdirs); also reads `CLAUDE.md` | `cursor.com/docs/skills`, `cursor.com/docs/context/rules` |

Findings:

1. **`.agents/skills/` is a first-party discovery path in both.** OpenCode lists it as
   "Project agent-compatible"; Cursor lists `.agents/skills/` as its top project-level
   location. Neither is a compatibility shim for Claude/Codex — it is a native root.
2. **`AGENTS.md` is natively read by both** (OpenCode's primary rules file; Cursor's
   "simple markdown alternative" to `.cursor/rules`). TAD's role routing / knowledge
   ingress in `AGENTS.md` therefore loads without conversion.
3. **Skills surface on demand**: OpenCode via its native `skill` tool + `/name`
   commands; Cursor by agent-decides or `/name`. This is exactly the progressive
   disclosure TAD's SKILL+`references/` layout assumes.
4. **Cursor additionally reads `.codex/skills/`** (compat), but TAD keeps skills under
   `.agents/skills/`, so that path is unused.
5. **OpenCode flat-file quirk (low severity)**: OpenCode V2 also discovers `*.md` files
   *at the skills source root*, not only `*/SKILL.md`. TAD's `.agents/skills/`
   root contains a stray `doc-organization.md` (no SKILL.md frontmatter) → it surfaces
   as a pseudo-skill / possible invalid entry in OpenCode only. `_archived/*.md`
   (47 files) is nested and named `.md` (not `SKILL.md`), so it is **not** discovered.
   Cursor requires folder+`SKILL.md`, so it ignores the stray entirely.

**Conclusion for Part 1**: TAD v3.0.0's skill tree is **open-box usable** on both
harnesses at the discovery layer. No mirror/copy step is needed. This is the intended
payoff of the "SSOT = `.agents/skills/`" reversal.

---

## 2. Part 2 — What is still Codex-only in TAD v3.0.0

| # | Surface | Where (v3.0.0) | Behavior under OpenCode / Cursor | Severity |
|---|---|---|---|---|
| C-1 | **Platform matrix** | `tad.sh` `KNOWN_PLATFORMS="codex"`; `validate_platform()` rejects everything else; `.tad/platform-codes.yaml` has only `codex`; default `PLATFORM=codex` (tad.sh:514, 519-545) | `--platform opencode\|cursor\|both` is a hard error before any mutation. You must install with `--platform codex` even for a Cursor/OpenCode-only project. | **High** (installer semantics wrong, not blocking) |
| C-2 | **Platform-codes adapter deltas** | `.tad/platform-codes.yaml` — `extra_deny: []`, `extra_root_files: ["AGENTS.md"]` | No `opencode`/`cursor` entries → no per-platform hook/config projection, no platform-specific deny. | Medium |
| C-3 | **Lifecycle hooks** | `.codex/hooks.json` (codex-only schema): `SessionStart`→`startup-health.sh`; `PostToolUse ^apply_patch$`→`post-write-sync.sh` (trace + session-state metadata); `PostToolUse ^ask_user_question$`→`askuser-capture.sh` (tad.sh:1297-1334) | **None of the three fire.** Losses: framework health summary, TAD trace emission (`session.diff`/journal), ask-user capture, post-compact recovery hint. | **High** (silent capability loss) |
| C-4 | **Hook portability** | `.tad/guides/hooks-platform-mapping.md` documents only the Codex mapping | Ports *exist* but are unwritten: **OpenCode** → `.opencode/plugins/*.ts` (`session.created`, `session.compacted`, `tool.execute.after`, `file.edited`); **Cursor** → `.cursor/hooks.json` (`sessionStart`, `afterFileEdit`, `postToolUse`, `preCompact`). Existing `.tad/hooks/*.sh` + `hook-envelope.sh` normalization are reusable. | Medium (work, not a wall) |
| C-5 | **Command projection** | `tad.sh` projects exactly one file: `.opencode/commands/tad-update.md` (updater-only); nothing under `.cursor/` (tad.sh:2293-2334) | `/tad-update` works in OpenCode; Cursor gets no command. No `/alex`,`/blake` slash projection on either. | Low-Medium |
| C-6 | **Role activation syntax** | `AGENTS.md` Role Switching says `$alex` / `$blake` | `$` is a Codex skill-invocation convention; OpenCode/Cursor use `/name` or model-decided loading. Documented route is harness-wrong (the skills still load, just not by that trigger). | Medium |
| C-7 | **"Codex-Specific Notes"** | `AGENTS.md` section: `codex exec resume --last`, `.codex/hooks.json`, manual gate pre-checks | Loaded into every session on every harness as inapplicable instructions (context tax + misleading). | Low |
| C-8 | **Capability-pack installer** | `tad.sh --packs` / `pack-registry.yaml` / `is_pack_skill` | **Platform-agnostic in substance** — it copies `.agents/skills/<pack>` + `.tad/capability-packs/`. Works once C-1 stops rejecting the target. Not actually Codex-specific. | Low |
| C-9 | **Model pin** | Only a **draft**: `.tad/evidence/designs/codex-runtime-candidates/config.toml.draft` (`model="gpt-5.5"`), explicitly "Not active" per `.tad/codex/README.md` | **Non-issue — there is no active model pin to port.** (Runtime ledger `.tad/runtime-compat/codex.md` pins the *Codex CLI version*, not a model.) | None (report only) |
| C-10 | **Subagents / Layer 2** | `.codex/agents/*.toml` are draft-only; Layer 2 runs via explicit sequential prompting | OpenCode has native Task subagents; Cursor has subagents. Roughly at parity — no blocker. | None |
| C-11 | **Updater** | `.tad/scripts/tad-update.sh`: `--platform must be codex`; `detect_platform()` keys off `.agents/skills/alex` | Detection returns `codex` on any TAD v3 project, so `--check` / `--yes` actually work on OpenCode/Cursor projects. Misnomer, not a break. | Low |
| C-12 | **Runtime freshness** | `.tad/hooks/lib/runtime-freshness-verify.sh` + `.tad/runtime-compat/codex.md` | No OpenCode/Cursor runtime ledger → no freshness gate for those harnesses. | Low |
| C-13 | **Stale Claude residue** | e.g. `.agents/skills/alex/SKILL.md` frontmatter body still says "当前 harness 有该工具（Claude Code）→ 直接调用" | Cosmetic/hygiene leftover from the v3.0.0 removal; unrelated to OpenCode/Cursor but surfaced during this audit. | Low (flag only) |

### Net effect
- **Works open-box**: skills discovery, `AGENTS.md` routing, capability packs, Gate
  skill bodies, updater.
- **Silently degrades**: hooks (C-3) — the biggest real loss.
- **Misleading/documentation-level**: installer `--platform` rejection (C-1),
  activation syntax (C-6), Codex notes (C-7).
- **Non-issues**: model pin (C-9), subagents (C-10).

---

## 3. Part 3 — Minimal scope for true first-class support

Deliverables sized **S** (≤ half day), **M** (1-2 days incl. verification), **L** (> 2 days).

| Phase | Deliverable | Size | Notes |
|---|---|---|---|
| **P1 — Installer target** | Accept `opencode` / `cursor` (and `all`); add `platform-codes.yaml` entries with per-platform `extra_deny` / roots; gate hook generation per platform; extend self-check/verify. | **S** | Lowest-risk; mostly `tad.sh` + YAML. No behavior for existing Codex users. |
| **P2 — Hook adapters** | (a) `.opencode/plugins/tad.ts` mapping `session.created`/`session.compacted` → `startup-health.sh`; `tool.execute.after`/`file.edited` → `post-write-sync.sh`. (b) `.cursor/hooks.json` mapping `sessionStart`→`startup-health.sh`, `afterFileEdit`/`postToolUse`→`post-write-sync.sh`. Reuse `hook-envelope.sh` for input normalization. | **M** | The real work + the only place quality can regress; needs per-harness contract tests. |
| **P3 — Routing & hygiene** | Platform-neutral activation text (`$alex` on Codex vs `/alex` elsewhere); scope/relocate "Codex-Specific Notes"; remove stray `.agents/skills/doc-organization.md` (or move under a folder) so OpenCode doesn't surface a pseudo-skill; sweep stale Claude refs (C-13). | **S** | Doc + one file move; no logic. |
| **P4 — Behavioral regression** | Install into a scratch project and *observe* on live OpenCode + Cursor: skills listed, `/alex` loadable, hooks actually fire, updater works. Record transcripts. | **M** | Mandatory or P2 is "validation theater". Needs live harness runs. |

**Overall: M** (one mini-track / Epic, ~4 phases as above; not an L). P2+P4 are the
load-bearing 60%; P1+P3 are cheap honesty fixes.

### Decision guidance
- **Do it if**: there is demonstrated/named OpenCode or Cursor usage, or a distribution
  goal (TAD installs cleanly into non-Codex shops).
- **Defer if**: Codex remains the house runtime and no user is asking — then only ship
  **P1+P3 (S)** so the installer and docs stop lying, and leave P2/P4 as a documented
  known gap (`AGENTS.md` / `INSTALLATION_GUIDE.md`).

---

## 4. Sources & retrieval

| Claim | Source | Retrieved |
|---|---|---|
| OpenCode discovers `.agents/skills/` + `~/.agents/skills/`; flat `.md` at root; SKILL.md any depth | `https://dev.opencode.ai/docs/skills`, `https://v2.opencode.ai/docs/skills` | 2026-09-16 |
| OpenCode reads `AGENTS.md` (project + global) as rules | `https://opencode.ai/docs/rules/` | 2026-09-16 |
| OpenCode plugin events (`session.created/compacted`, `tool.execute.after`, `file.edited`) | `https://opencode.ai/docs/plugins/` | 2026-09-16 |
| Cursor discovers `.agents/skills/` (project+user), loads `AGENTS.md`, walks recursively | `https://cursor.com/docs/skills`, `https://cursor.com/docs/context/skills` | 2026-09-16 |
| Cursor hooks `.cursor/hooks.json` (`sessionStart`, `afterFileEdit`, `postToolUse`, `preCompact`) | `https://cursor.com/docs/agent/hooks` | 2026-09-16 |
| TAD v3.0.0 state | repo `20223774`; `.tad/version.txt`=3.0.0; `tad.sh`; `.codex/hooks.json`; `.tad/platform-codes.yaml`; `.tad/codex/README.md`; `.tad/guides/hooks-platform-mapping.md` | 2026-09-16 |

> Note: vendor docs are current as of retrieval. Skill/hook schemas are moving targets;
> P4's live regression is the freshness control, not this doc snapshot.
