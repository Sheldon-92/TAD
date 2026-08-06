# Release & Sync Patterns (Layer 2)

> Mirror/parity/install hazards — sibling of the L1 deny-list principles.

---

### A Mirror/Parity `--fix` That Copies a Tree Wholesale Destroys the Source's Gitignore Semantics - 2026-07-12
- **Discovery**: `release-verify.sh parity --fix` rsyncs `.claude/skills` → `.agents/skills` wholesale. `.claude/skills/local/` is gitignored by contract (save-skill: local-only, never distributed), but the mirror copied it to `.agents/skills/local/`, where NO ignore rule existed — local-only content became git-visible in a PUBLIC repo. On 2026-07-12 only harmless scaffolds (`_example.md`/`_index.md`) leaked, but any real local skill would have been one `git add -A` from publication. Ignore rules are PATH-specific: they do not travel with mirrored content. Mitigation applied (rm + `.agents/skills/local/` added to .gitignore); ROOT FIX STILL OPEN — parity tool must exclude `local/` (needs an Alex bugfix handoff).
- **Action**: For every mirror/sync/parity tool, make the exclusion set include the source side's ignored-by-contract subtrees (e.g., rsync `--exclude local/`), AND add matching ignore rules on the destination side as defense-in-depth. Whenever a "never distribute" contract is attached to a path, sweep every mirror/copy loop that touches its parent tree — the same every-granularity discipline as the L1 deny-list principles (2026-06-01), extended to ignore semantics.
- **failure_mode**: Naive default: trust that gitignored content stays private because the source path is ignored, then mirror the parent tree wholesale. Why wrong: gitignore semantics are path-specific — the mirrored copy at the destination has no ignore rule, so private-by-contract content silently becomes trackable/publishable in the destination tree, converting an isolation contract into a publication vector.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md finding 1, .tad/hooks/lib/release-verify.sh (parity), .gitignore (`.agents/skills/local/` entry)
- **AMENDED 2026-08-06 — the "ROOT FIX STILL OPEN" note is obsolete; both layers are now closed**:
  verified in place on 2026-08-06 — `.gitignore:16` ignores `.agents/skills/local/` (destination-side
  defense), and `.tad/hooks/lib/release-verify.sh:681` now runs
  `rsync -a --delete --exclude=/local/ …` (tool-side exclusion). **The git-visibility hazard this
  entry describes is closed.** What remains is narrower and must be stated separately: a *bare*
  `rsync` (not via the parity tool) still materializes private `local/` content into the working
  tree of a public repo — invisible to `git status` precisely because of the ignore rule that fixes
  the other half. A guard against whole-tree copying must therefore test the **filesystem**
  (`diff -rq`, `test ! -e`), never `git status`.
  ⚠️ **Why this amendment matters beyond the fact**: on 2026-08-06 a contract cited this entry's
  headline to justify a guard, missed the mitigation clause, and consequently built an AC against
  the already-fixed hazard — one with zero discriminative power against the live residual risk.
  See `ac-verification.md` §`Before Trusting a Guard, Measure Whether Its Trigger Condition Can
  Even Occur`. Read cited entries to the end.

### Identity Early-Exits Blind Downstream Checks: Content Guards Must Run Before Byte-Parity Short-Circuits and Match All Serialization Forms - 2026-08-03
- **Context**: codex-wiring-stopbleed. `release-verify.sh parity` exited 0 as soon as `.claude/skills` and `.agents/skills` were byte-identical — but "byte-identical" includes "identically broken": 36 platform-coupled `reference: ".claude/skills/…"` lines survived a month inside a green parity gate because both trees carried the same bad content. A naive mutation probe (inject bad line into one tree) proved nothing: it broke byte-identity, so the pre-existing diff check FAILed and masked whether the new content guard even ran. Second layer: the guard initially matched only double-quoted `reference: "…"` values; single-quoted and bare YAML forms would have passed.
- **Discovery**: (1) A byte-parity early-exit makes every check placed after it unreachable in the steady state the repo actually lives in (trees synced). Content-level guards must run unconditionally BEFORE the identity short-circuit; in `--fix` mode they must run on the post-rsync final state or they deadlock against the rsync that would fix the tree. (2) The only mutation probe that isolates a content guard from an identity check is a dual-tree injection that PRESERVES byte-identity, asserted via the guard's dedicated failure-message text — plus a single-tree injection as regression proof the identity check still works. (3) A declaration matcher is an allow-list over serialization syntax: it must cover every legal form (double-quoted/single-quoted/bare) or the uncovered form becomes the bypass.
- **Action**: When adding a content guard to a verifier that has an equality/identity early-exit: place the guard before the early-exit; define fix-mode ordering explicitly; prove it with a byte-identity-preserving dual-site mutation asserting the guard's own message; enumerate all serialization forms the guarded declaration can legally take.
- **failure_mode**: Naive default: append the new check after the existing logic and probe it by mutating one side. Why wrong: the early-exit returns before the check in the synced steady state (guard is dead code exactly when needed), and the one-sided probe trips the identity diff — a green "probe" that never exercised the guard.
- **Grounded in**: .tad/hooks/lib/release-verify.sh parity (guard at L552 pre-early-exit), .tad/evidence/acceptance-tests/codex-wiring-stopbleed/AC-06-parity-injection.sh (quote-agnostic dual-tree probe), .tad/archive/handoffs/HANDOFF-20260803-codex-wiring-stopbleed.md §3.2.5 + Audit Trail
