# Release & Sync Patterns (Layer 2)

> Mirror/parity/install hazards — sibling of the L1 deny-list principles.

---

### A Mirror/Parity `--fix` That Copies a Tree Wholesale Destroys the Source's Gitignore Semantics - 2026-07-12
- **Discovery**: `release-verify.sh parity --fix` rsyncs `.claude/skills` → `.agents/skills` wholesale. `.claude/skills/local/` is gitignored by contract (save-skill: local-only, never distributed), but the mirror copied it to `.agents/skills/local/`, where NO ignore rule existed — local-only content became git-visible in a PUBLIC repo. On 2026-07-12 only harmless scaffolds (`_example.md`/`_index.md`) leaked, but any real local skill would have been one `git add -A` from publication. Ignore rules are PATH-specific: they do not travel with mirrored content. Mitigation applied (rm + `.agents/skills/local/` added to .gitignore); ROOT FIX STILL OPEN — parity tool must exclude `local/` (needs an Alex bugfix handoff).
- **Action**: For every mirror/sync/parity tool, make the exclusion set include the source side's ignored-by-contract subtrees (e.g., rsync `--exclude local/`), AND add matching ignore rules on the destination side as defense-in-depth. Whenever a "never distribute" contract is attached to a path, sweep every mirror/copy loop that touches its parent tree — the same every-granularity discipline as the L1 deny-list principles (2026-06-01), extended to ignore semantics.
- **failure_mode**: Naive default: trust that gitignored content stays private because the source path is ignored, then mirror the parent tree wholesale. Why wrong: gitignore semantics are path-specific — the mirrored copy at the destination has no ignore rule, so private-by-contract content silently becomes trackable/publishable in the destination tree, converting an isolation contract into a publication vector.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md finding 1, .tad/hooks/lib/release-verify.sh (parity), .gitignore (`.agents/skills/local/` entry)
