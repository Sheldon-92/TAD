# Phase 1 Design Review — Backend/Systems Architecture Lens

**Reviewer:** backend-architect (re-validation vote on v2)
**Handoff:** HANDOFF-20260712-precompact-session-state-hook.md (v2, post-6-P0-integration)
**Date:** 2026-07-13
**Domain detected:** shell-hook / native-lifecycle integration (`.tad/hooks/*.sh` + `.claude/settings.json`) → backend/systems architecture.

## Verdict: PASS-WITH-P1s (re-validation)

The v2 redesign is architecturally sound and materially better than v1. The core structural
decision — **physical file separation (one snapshot file per compaction, newest-wins) instead of a
shared single-block dual-terminal write** — eliminates the entire class of concurrency/overwrite
hazards that generated 4 of the 6 v1 P0s. I verified this against the live code contracts
(`common.sh` output funcs, both existing SessionStart hooks, the source-guard in
`startup-health.sh`). No new P0s. The findings below are P1/P2 refinements to close residual design
gaps before implementation locks.

Grounding verified:
- `common.sh:37 output_response` / `common.sh:58 output_empty` (`echo '{}'`) contracts match FR4 usage.
- `startup-health.sh:15-19` source-guard confirmed: `output_empty; exit 0` for any non-startup source. FR4 insertion-before-guard is correct.
- `notebook-dormant-sync.sh:30-34` also no-ops with `output_empty` on compact source → AC7's "unaffected" claim is TRUE, and no dual-additionalContext collision on compact. Good.
- No `PreCompact` key in settings.json (MQ1 correct). New top-level array required.

---

## P1 Findings

### P1-1 — Two SessionStart hooks + additionalContext merge semantics on compact is unverified (blast radius: reminder may not surface)
FR4 injects the post-compact reminder as `additionalContext` from `startup-health.sh`. On a
compact-source SessionStart, **both** registered SessionStart hooks fire. `notebook-dormant-sync.sh`
returns `{}` (verified L30-34), so today there is no collision. But the design's AC6 tests
`startup-health.sh` in isolation via piped stdin — it never asserts that Claude Code actually
**consumes** `additionalContext` from a `source==compact` SessionStart event and surfaces it to the
agent. This is the load-bearing behavioral claim of the entire "Layer 0 → second defense" thesis,
and it is exactly the kind of native-runtime assumption that T1 exists to de-risk — yet T1's four
questions (i-iv) confirm the *source value* is `compact` but do NOT confirm that additionalContext on
a compact SessionStart is injected into the agent's context (as opposed to being accepted-but-ignored
by the runtime, which some Claude Code versions do for non-startup sources).
**Recommendation:** Add a fifth T1 question / AC: at the next real /compact, confirm the reminder
line actually appears in the agent's post-compact context (not just that the hook emitted it).
Until confirmed, the reminder's *effectiveness* is PENDING-REAL-EVENT, not proven by AC6. This does
not block implementation (mechanical AC6 is fine as a unit test) but the completion report must not
claim FR4 "works" on the strength of AC6 alone.

### P1-2 — `get_json_field` grep-fallback cannot parse `transcript_path` and nested fields; FR1 field derivation on no-jq hosts silently degrades
`common.sh:26-32` grep-fallback only matches simple top-level `"key":"value"` string pairs. It
cannot handle nested paths and returns empty for any field not shaped that way. The new hook derives
`trigger` and (per T1) possibly `session_id` from stdin. On a host without jq the fallback may yield
empty → the snapshot's Trigger/Session fields become blank rather than the FR3-mandated
`(unavailable: {reason})`. The design says "python3/jq (existing hooks已用)" as a dependency but the
grounding lists jq as merely "READY" and `common.sh` deliberately supports a no-jq path. FR3's
fail-open discipline requires that a *derivation failure* be **distinguishable**, but an empty grep
result is indistinguishable from a legitimately empty field.
**Recommendation:** In the hook, treat empty/`null` field extraction as the `(unavailable: parse)`
branch explicitly (`FIELD=$(get_json_field .trigger); [ -z "$FIELD" -o "$FIELD" = null ] && FIELD="(unavailable: parse)"`).
Make this a per-field rule, not a whole-file fallback. Otherwise FR3's "distinguishable failure"
guarantee is violated precisely on the degraded-host path it's meant to cover.

### P1-3 — Prune step (FR6) and torn-write assembly (FR7/AC5) both operate on the same directory with no ordering guard against a concurrent prune deleting an in-flight `mv` target
AC5 stress-tests 20 concurrent writers and asserts torn-write resistance. But FR6 prune (`keep newest
5, delete rest`) runs **after** each write within each of those 20 processes. Process A can be
selecting its deletion set (globbing `snapshot-*.md`) at the same instant process B's `mv` lands a
new file — A's glob is stale, and more importantly two processes may both decide to delete the same
"6th oldest" file, or A may delete a file B just wrote if timestamps collide at 1-second resolution
(FR1 timestamp is `HHMMSS`, no sub-second). AC4 tests prune serially (7 sequential runs); AC5 tests
concurrency but only asserts *no half files*, not *prune correctness under concurrency*. The two ACs
never intersect. Real /compact is single-writer so this is low-probability in production, but the
design explicitly invites 20-way concurrency in AC5 and leaves prune-under-concurrency unspecified.
**Recommendation:** Either (a) scope FR6 prune to run only in the single-writer real path and
document AC5's concurrent runs as skipping prune, or (b) make prune tolerate races (`rm -f` ignoring
"file already gone", never fail exit-0) AND accept that under same-second collisions the count may
transiently be 4 or 6 — and state that explicitly so AC4's "恰好 5" isn't falsified by an AC5-style
concurrent burst. Pick one and write it into FR6; today the two ACs make contradictory implicit
assumptions.

### P1-4 — Snapshot filename collision at 1-second resolution loses data (newest-wins reader + prune both key on the timestamp)
FR1 filename = `snapshot-{YYYYMMDD-HHMMSS}-{sid8}.md`. Two compactions of the *same session* within
the same wall-clock second produce the **identical filename** → the second `mv` silently overwrites
the first. The reader rule is "newest-wins by name-sort", and prune is "name-sort keep 5"; both are
blind to the overwrite. For the real single-user /compact path this is near-impossible (compactions
are minutes apart), so it is P1 not P0 — but it interacts with AC5 (which deliberately runs 20
processes with, per the AC, "同一 stdin" → same session_id → **same filename** → 19 of 20 files
overwrite each other, leaving 1 file). AC5's assertion "每个产出文件要么不存在要么完整" is
technically satisfiable with a single surviving file, but the AC reads as if it expects 20 distinct
files. This is an AC-design ambiguity that will bite the implementer.
**Recommendation:** Clarify AC5: with identical stdin the expected outcome is **1 complete file**
(last mv wins), not 20 — and that IS the torn-write guarantee (every intermediate mv either
completes or doesn't). If distinct-file torn-write coverage is wanted, the AC must vary the sid8 or
add a `$$`/nanosecond suffix. Recommend adding a short disambiguator to the filename
(`...-{sid8}-{RANDOM}.md` or `$$`) so same-second compactions don't silently lose the earlier
snapshot; the reader is already newest-wins-tolerant of extra files.

---

## P2 Findings

### P2-1 — `ahead/behind origin` derivation will be `(unavailable)` on the common no-upstream / offline path, with no design note on expected frequency
FR1 Git line includes `ahead {A} / behind {B} origin`. `git rev-list --count @{u}...HEAD` fails when
there's no upstream tracking branch or when the branch is local-only (common on TAD worktrees, which
the grounding notes Blake runs in). This isn't a bug — FR3 covers it with `(unavailable)` — but the
*most recovery-valuable* field (arch F1's whole point in v1→v2) will frequently render unavailable in
exactly the worktree context this Epic runs in. Worth a design note that HEAD-sha + branch (which
always resolve) are the primary recovery anchors and ahead/behind is best-effort. Otherwise a
reviewer will read a snapshot full of `(unavailable)` and mistake it for a hook failure.

### P2-2 — Reminder text hardcodes two file paths; drift risk if `precompact/` dir is ever renamed
FR4 reminder string literally embeds `.tad/active/precompact/snapshot-*.md`. FR8 gitignores that
dir. Data-model §4.3 already flags "field names are a contract"; the *directory path* is now equally
a contract shared across the hook, the reminder, `.gitignore`, and §4.5 docs. No single source of
truth. Low severity (paths rarely move) but worth one line in §4.3: "the `precompact/` path is a
4-way contract (hook write target, reminder text, .gitignore, §4.5); changing it is a coordinated
edit."

### P2-3 — timeout ≤10s (FR3) vs git operations on a large/slow repo
FR3 caps runtime at 10s. `git status`, `git rev-list --count`, `git log -1` are normally sub-second
but can stall on a cold FS cache or a huge worktree. Since the whole hook is fail-open, a timeout
just means a missed snapshot — acceptable — but the design should confirm the 10s budget is enforced
by the hook's *own* guard (e.g. wrapping git calls) rather than relying solely on Claude Code's hook
timeout, because a runtime-killed hook mid-`mv` is the one path FR7's temp→mv discipline must still
survive (it does, since mv is atomic, but the interaction deserves an explicit line).

---

## What the design got right (re-validation confirmations)
- **Physical file separation** correctly dissolves v1 P0s #1-3 (dual-terminal overwrite, sed block
  replacement, read-modify-write race). This is the right architectural axis — verified there is no
  shared mutable write target.
- **fail-open + distinguishable breadcrumb** (`(unavailable)` fields + `.hook-debug.log`) satisfies
  the 2026-04-15 SAFETY principle without becoming a blocker; no deny/block path exists in the design.
- **Single reminder carrier** (startup-health.sh branch, no new hook registration) correctly
  minimizes the multi-script interaction surface — and I verified the sibling SessionStart hook
  no-ops on compact so there's no additionalContext collision.
- **T1-gates-everything** ordering is the correct native-runtime de-risking posture; the honest-partial
  PENDING-REAL-EVENT protocol in the grounding is the right call for un-triggerable auto-compact.
- **hook writes ONLY its own snapshot file** (FR2, AC2 full-file diff) is the correct blast-radius
  containment — session-state.md stays 100% agent-owned.

## Blast-radius summary
Write surface = `.tad/active/precompact/` (new, gitignored) + one bounded annotation to CLAUDE.md
§4.5 (AC8 line-set-diff-gated) + one branch in startup-health.sh (AC7 byte-identical startup path) +
one settings.json array. All four are contained and independently verified. No production data path,
no network, no shared-state mutation. Residual risk is entirely in **unverified native-runtime
behavior** (P1-1) and **concurrency-AC internal contradictions** (P1-3/P1-4), both closable in
implementation without redesign.
