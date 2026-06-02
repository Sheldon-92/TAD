# DR-20260601-B: Self-Deriving + Self-Verifying Release/Sync (kill the hardcoded-list disease)

**Status**: Accepted (human-authorized 2026-06-01)
**Touches**: `release-runbook` SKILL, `*publish`/`*sync` protocols (alex SKILL), new verification lib in `.tad/hooks/lib/`, `tad.sh` (P2)
**Epic**: EPIC-20260601-self-deriving-release-sync.md
**Decided by**: Human (explicit), via Alex `*analyze` Socratic (2 rounds / 6 questions)
**Sibling**: DR-20260601-codex-edition-parity-architecture.md (same "derive-don't-hardcode" principle, applied to the release process itself)

## Context
TAD's publish/sync has recurring silent-omission failures, all the SAME root cause: **hardcoded lists go
stale when the doc structure evolves**. Evidence (2026-06-01): `.tad/codex/` was never in the standard
sync's 14-dir allow-list → downstream codex editions frozen at 2026-05-04 for a month; `tad.sh`
TARGET_VERSION stuck at 2.19.1 (not in the 18-item version-string list); runbook's own history: config.yaml
stuck at 2.8.0, tad.sh missed `hooks/`+`domains/`, tad.sh missed deprecations. A per-release script pinned
to a snapshot's structure is brittle by construction — the next version's structure changes and the script
silently misses things. The user's framing: "each release should be a FRESH script, not the old one, AND
there must be a PROCESS that checks it and guarantees no error."

## Decision: encode RULES (derive + verify), not LISTS
Replace the three hardcoded lists with structure-derived rules + structure-agnostic verification gates,
baked into the `release-runbook` SKILL as the standing standard operation.

| Hardcoded (brittle) | Derived (structure-proof) |
|---|---|
| 14-dir framework allow-list | **deny-list**: sync everything under `.tad/` EXCEPT zero-touch {project-knowledge, active, archive, evidence, pair-testing, decisions} + sync-registry.yaml (main-only). New dirs auto-included. |
| 18-item version-string list | **grep-derived**: `grep -rl "<old-version>"` finds ALL occurrences → bump → `grep` confirms zero stale. New refs auto-covered. |
| per-file verification checklist | **`diff -r` source==target** (sync) + **`grep` zero-stale** (publish) — structure-agnostic; any omission surfaces regardless of how structure evolves. |

## Form: a SKILL upgrade, NOT a capability pack
- Capability packs = portable DOMAIN judgment for any project/agent. TAD's release process is TAD's own
  internal SOP — wrong fit (you wouldn't "install" it into other projects).
- A skill IS a procedure the agent executes — exactly this. `release-runbook` already exists → UPGRADE it,
  don't proliferate a new artifact type.

## Key design choices (Socratic)
1. **deny-list** (pure) — new framework dirs auto-included.
2. **Per-release: generate a fresh one-time script** from current structure (`sync-vX.Y.Z.sh`, archived
   after) — honors "fresh script each release" + audit trail. The VERIFICATION PRIMITIVES are a STABLE lib
   in `.tad/hooks/lib/` (these are the only "written-in-stone" part — structure-agnostic, never go stale).
3. **The real guarantee is the verification gate, not the script's freshness.** `diff -r` doesn't care how
   the structure changed; source-has-target-lacks → it reports.
4. **Release-time HARD BLOCK** (minor+) in `*publish`/`*sync` on verification failure — same model as the
   Codex parity gate (DR sibling). NOT a settings.json hook (single-user-CLI lesson, architecture.md
   2026-04-15).
5. **Old runbook hardcoded tables → demoted to non-authoritative** ("DERIVED — see {script/rule}; this
   table is illustrative only"). They are the stale source; leaving them authoritative re-creates the bug.
6. **tad.sh installer fixed too** (P2) — it has the SAME disease (hardcoded copy_framework_files dir list +
   TARGET_VERSION). Codex friends install via tad.sh; a stale list = incomplete installs. P2: tad.sh
   deny-list derivation + post-install diff self-check.

## Execution: 2-Phase Epic
- **P1**: verification lib (stable) + deny-list sync + grep-derived version bump + release-runbook upgrade +
  release-time verification gate in `*publish`/`*sync`.
- **P2**: tad.sh installer self-derivation + post-install diff self-check (separate code path, isolated risk).

## Anti-theater requirement
Dogfood must PROVE structure-resilience: inject a synthetic new framework dir + a new version-ref into
source → confirm (a) the deny-list auto-includes the dir, (b) grep-derivation auto-covers the ref, (c) the
verification gate would BLOCK if either were omitted. A mechanism that only works on today's structure is
exactly the failure this DR exists to kill.

## Consequences
- `.tad/hooks/lib/` gains stable verification primitives (semver-relevant — consumed by the release gate).
- The release-runbook becomes a derive+verify procedure; its hardcoded tables become non-authoritative.
- The release/sync gates can BLOCK a release — a real stop, not advisory (minor+).
