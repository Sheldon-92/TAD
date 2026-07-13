# Phase 2 Design Review — Backend/Systems Architecture Lens

**Reviewer:** backend-architect (Conductor 3-lens, arch lens)
**Handoff:** HANDOFF-20260713-native-capability-adoption-phase2.md
**Date:** 2026-07-13
**Domain auto-detect:** Files to Modify = agent-definition markdown (`.claude/agents/*.md`) + evidence files + `.gitignore`. No frontend/API/DB code. → **Default: backend/systems architecture** (config-file + distribution-mechanism architecture is the relevant surface).

**Verdict:** APPROVE WITH CHANGES. Design is unusually rigorous (spike-gated, explicit degradation matrix, behavioral-evidence ACs, anti-anchoring boundary in system-prompt body). One P1 rests on a factually wrong claim about the distribution mechanism, plus two P1 completeness gaps and several P2 hardening notes. None block the spike (Phase 1); the P1s must be resolved before Phase 2/3 defs land or the completion report will carry a false safety assertion.

---

## Grounding performed (facts I verified, not took on trust)

| Claim in handoff | My verification | Result |
|---|---|---|
| CLI 2.1.172 | `claude --version` | ✅ `2.1.172 (Claude Code)` |
| repo has no `.claude/agents/` | `ls .claude/agents` | ✅ No such file or directory |
| 30 user-level agents, frontmatter only name/description/model | `head -12 ~/.claude/agents/code-reviewer.md`, security-auditor | ✅ confirmed (model: opus both) |
| Blake 1_5a is the sole pack-transcription consumer | `sed -n '540,600p' blake/SKILL.md` | ✅ L550/L584 confirmed; 1_5a self-contains pack≤2 + collision check |
| code-security pack exists | `ls .claude/skills/code-security/SKILL.md` | ✅ |
| gitignore has memory/session block ~L18, L60-68 | `grep -n` | ✅ L18-20 session block, L60-68 memory block |
| **`.claude/agents/` auto-enters publish/sync derived set (deny-list, fail-open-safe)** | `derive-sync-set.sh` operates on `ls -d .tad/*/` ONLY; `tad.sh` L787-834 copies `.claude/skills/*`, `settings.json`, `workflows`, root_files — **NOT `.claude/agents/`** | ❌ **FALSE — see P1-1** |

---

## P0 (blocking) — none

The spike-first architecture is correct: every UNKNOWN (`memory` shape, `skills` preload semantics, project-level shadowing) has an explicit VERDICT gate and a degradation-matrix row. This is the right structural answer to "doc-level research, unverified locally." No blind assumption is load-bearing. No P0.

---

## P1 (should fix before Phase 2/3 defs land)

### P1-1 — The sync/publish safety claim is factually wrong; `.claude/agents/` is invisible to BOTH distribution paths, not "fail-open-safe SYNC+REPORTED"

**Where:** §10.2 Known Constraint ("`.claude/agents/` 新目录将默认进入 publish/sync 派生集（deny-list fail-open-safe）"); Project-Knowledge Lesson #4 ("derive-sync-set 是 deny-list … 新目录默认 SYNC+REPORTED"); completion-report guidance to "prompt next *publish to decide sync vs deny."

**The reality (verified):**
- `derive-sync-set.sh` derives its set from `ls -d "$ROOT"/.tad/*/` MINUS deny-list. Its entire universe is `.tad/*/` subdirectories. `.claude/agents/` is **not under `.tad/`**, so the deny-list mechanism never sees it — it is neither included nor reportable by that tool.
- `tad.sh`'s `.claude/` framework copy block (L787-834) enumerates exactly: `.claude/skills/*/`, `.claude/settings.json`, `.claude/workflows/`, and platform `root_files`. There is **no copy path for `.claude/agents/`**.

**Consequence — this is the exact failure class the Project-Knowledge base already burned an Epic on** (principles.md 2026-06-01 "Deny-List Must Be Applied at EVERY Copy Granularity"): a NEW git-tracked framework directory that no copy loop enumerates → **silent omission**. If these reviewer defs are ever meant to ship to downstream projects, they will silently NOT ship, and no verifier (`diff -rq`, structural gate) currently inspects `.claude/agents/` granularity. This is `portable-extract.sh` / `.tad/codex/` all over again.

**Why P1 not P0:** the handoff's actual *intent* is that these defs are TAD-repo-specific and lean toward NOT syncing (deny). The end-state (not distributed) happens to be correct by accident. But the **stated reasoning is false**, and a completion report that says "deny-list will fail-open-safe, human decides at next *publish" will mislead the maintainer into believing a governance mechanism is watching this directory when nothing is.

**Required fix (design-doc + completion-report, no code):**
1. Correct §10.2 and Lesson #4: state the truth — `.claude/agents/` is currently in **neither** distribution path (`derive-sync-set` only walks `.tad/*/`; `tad.sh` `.claude/` copy is a hardcoded allow-list of skills/settings/workflows). It will silently not sync.
2. Escalation must record an explicit DECISION for the human, not a false reassurance: "Do we want reviewer defs distributed? If YES → a new copy-granularity + matching verifier must be added to `tad.sh` (this is a separate handoff — the allow-list-at-`.claude`-granularity is the known omission disease). If NO (recommended) → document that `.claude/agents/` is intentionally main-repo-only and add it to whatever *published* deny manifest exists so the omission is *auditable* rather than accidental."
3. This directly satisfies NFR2 (no silent degradation) applied to distribution, not just spike outcomes.

---

### P1-2 — Shadow-def duplication has no drift-detection carrier; "manual follow-up" is an unenforced promise

**Where:** §11 secondary decision ("接受与 user-level 的内容重复… 若未来 user-level persona 升级，project-level def 需手动跟进—写入 def 头部注释"); FR2 ("以 user-level body 为基底复制").

**Architectural concern:** the design consciously chooses copy-over-DRY (precision > DRY) for `code-reviewer.md` / `security-auditor.md`, which is defensible for self-containment + git-auditability. But the only mitigation for the resulting divergence risk is a **header comment** telling a future human to manually re-sync. Project-Knowledge repeatedly shows unenforced "remember to update X" promises are exactly what rots (the 14-dir allow-list, the extension glob). A comment is not a carrier.

**Why P1:** the two shadowed defs now become a **fork** of a machine-global source that can change under them silently. When the user-level `code-reviewer` persona improves, the project-level copy stays frozen and — because of shadowing (if VERDICT-shadowing=PASS) — the *stale project copy wins*, silently downgrading the reviewer for this repo only. That is a correctness regression with no alarm.

**Required fix (low-cost, design-level):**
- Record provenance mechanically, not prose: each shadow def's body should carry a `<!-- shadowed-from: ~/.claude/agents/<name>.md @ <git-or-mtime-fingerprint> 2026-07-13 -->` line (a fingerprint an eyeball or a future one-line check can diff), OR
- Prefer the cheaper structural answer the design already hints at: for `code-reviewer`/`security-auditor`, keep the project-level def **thin** — frontmatter (`memory`/`skills`) + the TAD Memory Protocol boundary section + an explicit "inherits base persona" note — rather than a full body copy, IF the shadowing VERDICT shows project-level *merges* rather than *replaces* body. The spike (FR1 shadowing) will tell you which; the design should branch the def-authoring strategy on that VERDICT, not pre-commit to full-copy. Right now §11 pre-commits to full-copy before the spike result is known — that's a small design-completeness gap.

---

### P1-3 — AC5 memory-recall behavioral test has an attribution hole: it can pass on in-context recall without proving *persistence*

**Where:** FR6 / AC5; Friction Preflight row 2 (nested-spawn limitation → "跨两个 Blake bash/Task 轮次执行").

**Concern:** AC5 spawns the reviewer twice (RUN1 stores a pattern, RUN2 recalls it without prompting). The design correctly anticipates the nested-spawn limit and allows RUN1/RUN2 across two Blake Task rounds. But there is an **attribution ambiguity the AC doesn't close**: if RUN2 happens in a context where the RUN1 pattern is still reachable through *any* channel other than the persistent memory dir (same parent conversation carrying the pattern, or the pattern being generic enough — "BSD grep has no -P" — that a cold reviewer produces it from general knowledge), then `RUN2-RECALL: PASS` proves nothing about the `memory` mechanism. This is the Validation-Theater trap one level up: a behavioral test that passes for the wrong reason.

**Why P1:** the entire Epic success criterion is "reviewer actually USED memory on a second review." A recall test that a *memory-less* reviewer would also pass is not evidence. The pattern chosen as bait ("BSD grep used `grep -P`") is **too generic** — a competent cold security-auditor flags `grep -P` on BSD anyway.

**Required fix (design-level, tighten the AC):**
1. RUN1 must store a **repo-idiosyncratic, non-guessable** fact — e.g. a fabricated-but-plausible project convention the model cannot derive from general knowledge ("in THIS repo, AC pipe-escapes are written `\|` and must be restored before running" or a deliberately unusual token). If RUN2 surfaces the *specific* stored token, attribution to memory is clean.
2. Add a **negative control** to the AC: one RUN with memory disabled / a fresh agent that has never stored the fact, confirming it does NOT surface the idiosyncratic token. Discriminative gate, not presence gate (pattern-eval principle, patterns/pack-evaluation.md).
3. Ensure RUN2's parent context does not itself carry the RUN1 pattern text (otherwise the frontmatter `memory` is bypassed by conversation memory). The evidence file should note the isolation method.

---

## P2 (advisable hardening)

### P2-1 — `.gitignore` placement + public-repo leak surface is under-specified for the "memory falls inside repo" branch
If VERDICT-memory shows the memory dir lands under the repo (e.g. `.claude/agent-memory/`), FR4 adds a gitignore entry. Good. But two gaps: (a) the design names one candidate path (`.claude/agent-memory/security-auditor`) — the gitignore entry must ignore the **whole tree**, not a per-agent leaf, or a second agent's memory leaks. Use a directory-level ignore (`.claude/agent-memory/`). (b) security-lens: memory content is model-authored free text; even with the "patterns only, no verdicts" boundary, a reviewer *could* transcribe a snippet of the code under review (which may contain a secret) into a "pattern." The gitignore protects the public repo, but if the dir is repo-internal the risk is a stray `git add -f`. Recommend the memory dir live **outside** git-tracked paths if the spike allows a path form (prefer `~/.claude/...` or `.tad/`-gitignored), and record the chosen location's leak-surface in the spike report.

### P2-2 — `skills: [code-security]` vs pack≤2 budget is asserted in prose but has no cross-checking carrier
FR5 says the static preload "占 pack≤2 预算中的 1" and must be noted in def body. But Blake's 1_5a pack≤2 governance counts packs loaded **at handoff time via 1_5a**, and it has zero awareness of a pack preloaded via frontmatter `skills`. So the *real* budget for a security-auditor spawned during a task is: 1 (frontmatter code-security) + up-to-2 (1_5a). The "occupies 1 of ≤2" claim is aspirational — nothing enforces it and 1_5a can't see the frontmatter load. This is fine for now (advisory), but the design should state plainly that **frontmatter preload and 1_5a preload are two independent budgets that don't currently compose**, and flag it as a known limitation (candidate for a future collision/budget-unification handoff). Otherwise the "≤2" invariant silently becomes "≤3."

### P2-3 — spike agent lifecycle ("delete or keep as fixture — Blake decides") leaves a governance seam
`tad-spike-memory-agent.md` is a registered agent while it exists. If kept as a fixture, it becomes a permanent project-level agent with `memory`/`skills` test fields that a future reader may mistake for a real reviewer, and it's the ONE def AC3 explicitly excludes from the boundary-phrase check (`grep -v tad-spike`). Recommend: default to **delete** post-spike; if kept, rename to a clearly inert namespace (e.g. `.tad/evidence/spikes/.../fixtures/`) OUTSIDE `.claude/agents/` so it's never a live agent and never needs an AC exclusion carve-out. AC exclusions are a smell — they mean the invariant has a hole shaped exactly like this file.

### P2-4 — AC10 scope regex is fragile against the very files this handoff creates
AC10 (`git status --porcelain | grep -vE '...'`) whitelists `.claude/agents/` and the two evidence dirs and `.gitignore` and `.tad/active/`. On BSD grep this is fine (no `-P` used). But note the alternation includes `^ M \.gitignore` which only matches the modified state with a leading space-M; a staged `.gitignore` (`M ` or `A `) would fall through and fail AC10 spuriously. Minor, but since AC10 is a Gate-3 PRIMARY row, loosen to match `.gitignore` in any porcelain state. Not blocking; flagging because Gate 3 executes it verbatim.

---

## What the design got right (worth preserving under review pressure)

- **Spike-first with an explicit degradation matrix** is the correct architecture for doc-level-only research. The four-row FAIL matrix (memory-only / skills-only / shadowing-fail / all-fail) with an unconditional `spec-compliance-reviewer` deliverable even in the worst branch is a genuinely resilient design — the phase always produces *something* auditable, never a silent zero.
- **Content boundary in system-prompt body, not documentation** (FR3, anti-anchoring `MUST NOT store past verdicts`) is the right altitude — it binds at spawn time, not at reviewer discretion. The literal-phrase-as-grep-anchor (AC3 `grep -L`) is a sound, cheap carrier.
- **Zero-machine-global-write discipline** (FR7 START_MARKER + `find -newer` at AC7) is exactly the right way to prove a negative for `~/.claude/agents/`. Good instinct.
- **Preserving Blake 1_5a untouched (AC9)** and confining `skills` frontmatter to the *static* pairing is the correct expressiveness match — static field for static relationship, runtime mechanism for per-task. §11's rejection of option C (per-handoff thin defs) is well-reasoned.

---

## Summary for Conductor

- **P0:** 0
- **P1:** 3 — (P1-1) false sync/publish safety claim, `.claude/agents/` invisible to both distribution paths → must correct §10.2/Lesson#4 + make the distribution decision an explicit auditable escalation, not a false reassurance; (P1-2) shadow-def full-copy pre-commits before the shadowing spike result and has no drift carrier — branch def strategy on the VERDICT + add a fingerprint provenance line; (P1-3) AC5 recall bait is too generic to attribute recall to the `memory` mechanism — use a repo-idiosyncratic token + a negative control.
- **P2:** 4 — gitignore should ignore the whole memory tree + prefer out-of-repo location; frontmatter-preload vs 1_5a pack≤2 are two non-composing budgets (document it); spike-agent fixture should default-delete / move out of `.claude/agents/` to kill the AC3 exclusion carve-out; AC10 regex fragile on staged `.gitignore`.

None block Phase 1 (the spike). P1-1 and P1-3 must be resolved before their respective phases produce deliverables/evidence; P1-2's def-strategy branch should be decided the moment VERDICT-shadowing is known.
