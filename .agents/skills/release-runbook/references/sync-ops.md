# Sync, Register, and List Operations

Load this reference for `sync`, `sync-add`, or `sync-list`. The entry skill's root guard,
plan/execute/verify roles, effective-permission intersection, approval consumption, and ambiguous-result
recovery apply to every write. Registered targets are never implicit write authorization.

## 1. Registry and read-only listing

Read `$repo_root/.tad/sync-registry.yaml`. If it is missing, stop and suggest `sync-add`; if `projects`
is missing or empty, report that no projects are registered and remain read-only.

`sync-list` is always read-only. For every entry report:

| Field | Source |
|---|---|
| name, absolute path, platform, strategy | registry entry |
| current version | readable target `.tad/version.txt`, otherwise `missing/unreadable` |
| last-synced version/date | registry entry |
| status | current vs source/last-synced plus reachability |

Do not update stale metadata while listing.

## 2. Select and validate sync scope

Alex-Lite `plan` records one of: all outdated projects, an explicit target set, or cancel. Cancel
returns without writes. Before any target approval or write, Blake-Lite validates each selected entry:

- path is absolute, resolves canonically, exists, and is readable;
- target contains `.tad/` and readable `.tad/version.txt`;
- platform and `claude_md_strategy` are supported;
- current source and old target versions are captured before copying.

Missing/invalid targets are `skipped` with a reason during planning; never silently redirect a path.

## 3. Managed Write Surface

The following block is the single path authority for target planning, pre/post manifests, copying,
and scoped downstream staging. Paths outside it are forbidden. The derivation interfaces, not a
hand-written expansion, decide the live `.tad` members.

<!-- managed-write-surface:begin -->
```text
.tad/*  (regular maxdepth-1 files minus the single TOP_DENY from derive-sync-set.sh --report)
.tad/<each directory from derive-sync-set.sh --dirs, with capability-packs handled registry-only>
.tad/<path from derive-sync-set.sh --registry-only>
.claude/skills/**
.agents/skills/**
.claude/settings.json
.claude/workflows/**
.codex/hooks.json
CLAUDE.md
AGENTS.md
CLAUDE.md.bak
AGENTS.md.bak
tad.sh
README.md
INSTALLATION_GUIDE.md
CHANGELOG.md
docs/MULTI-PLATFORM.md
.tad-backup/**
```
<!-- managed-write-surface:end -->

Run and record:

```bash
bash "$repo_root/.tad/hooks/lib/derive-sync-set.sh" --dirs "$repo_root"
bash "$repo_root/.tad/hooks/lib/derive-sync-set.sh" --report "$repo_root"
bash "$repo_root/.tad/hooks/lib/derive-sync-set.sh" --zero-touch "$repo_root"
bash "$repo_root/.tad/hooks/lib/derive-sync-set.sh" --registry-only "$repo_root"
```

The report must contain exactly one `(+ top-level file: <name>)` record. Zero or multiple records block.
Exclude the observed basename (currently `sync-registry.yaml`) from target copy and target git-add sets.
`capability-packs` copies only the registry-only path. Hardcoded directory tables are illustrative only.

Zero-touch directories from `--zero-touch` must be captured in pre/post target manifests and remain
unchanged. Source-registry mutations for `sync-add`/successful `last_synced_*` are separate human-gated
source writes, never target MWS entries.

## 4. Platform strategy and safe preparation

Every target receives both authoritative skill trees: canonical `.claude/skills/**` and generated
`.agents/skills/**`. Platform selects settings, workflows, hooks, and entry-document strategy; it never
removes either skill mirror.

- Back up an existing entry document before overwrite/merge.
- For `merge`, require `<!-- TAD:PROJECT-CONTENT-BELOW -->`; if absent, stop that target and ask for a
  new plan. Never silently overwrite.
- Preserve project-owned settings hooks; merge only declared TAD-owned keys.
- Do not run capability-pack `install.sh` after mirroring; it can overwrite authoritative skills from
  a stale secondary source.
- Never run `tad.sh` against the TAD source repo.

All filesystem-changing tests use disposable fixture repositories, never a registered target.

## 5. Execute one target

After a target-specific approval is atomically consumed, perform only the approved MWS operations.
Derive framework paths from the interfaces above; do not add an inline directory table or migration.

Run the migration engine exactly once after the framework copy:

```bash
bash "$repo_root/.tad/hooks/lib/migration-engine.sh" \
  --from "$old_version" --to "$current_version" \
  --target "$target" --source "$repo_root"
```

- `0`: migration applied or no manifest was needed; continue.
- `1`: target is `partial`; preserve/report any `.tad-backup`, stop the entire batch, and forbid
  deprecation, registry advancement, downstream commit, or push.
- `2`: invalid manifest/chain/wiring after copy also means `partial`; same stop behavior.

The migration engine is the sole migration executor. Never inline deletes/renames around it.

Apply deprecations only when `old_version < deprecation_version <= current_version`, comparing full
SemVer numerically. Ignore future entries; an absent file is idempotent, but an unexpected path outside
the approved MWS blocks.

## 6. Verify before advancement

Run both gates after all target writes:

```bash
bash "$repo_root/.tad/hooks/lib/release-verify.sh" structural "$repo_root" "$target"
bash "$repo_root/.tad/hooks/lib/release-verify.sh" platform-skills "$repo_root" "$target"
```

For each gate: `0` passes; `1` is named drift/missing and blocks advancement; `2` is wiring/usage and
hard-blocks. Patch releases do not bypass target verification. Only a target with both exit codes `0`
is `verified` and eligible for `last_synced_*` advancement.

On partial/failure, compare the target with its own pre-state, report exactly what landed, preserve the
backup, and stop. Do not continue to later targets because the source of failure may be systemic.

## 7. Registry advancement and optional downstream git

Updating `last_synced_version/date` is a separate source-repository mutation. Request approval only for
the exact set of verified targets; partial, failed, missing, and skipped entries remain unchanged.
Use structured per-entry updates and re-read the registry; never bulk `sed` every project.

Downstream commit and downstream push are two more independent human gates. Stage only paths generated
from the Managed Write Surface and observed TOP_DENY; never `git add -A`, `.tad/`, or `docs/` broadly.
Record the exact target, branch, path set, commit SHA, and remote ref in each approval digest. Ambiguous
commit/push results follow the entry skill's consume-once recovery and are never blindly retried.

## 8. `sync-add` registration

`sync-add` begins read-only: validate the absolute canonical path, `.tad/`, readable version, platform,
and entry document. Detect strategy:

- marker present: propose `merge` and report the preserved-content region;
- marker absent: propose `overwrite`; choosing `merge` blocks until the marker exists.

Alex-Lite records the proposed entry. Writing the source registry requires its own approval digest and
Blake-Lite `execute` mode. Add `path`, derived `name`, `platform`, strategy, target's current version as
`last_synced_version`, and date. Registration does not claim a sync occurred.

## 9. Summary and recovery

Report every selected target as `verified`, `partial`, `failed`, `skipped`, or `not-started`, with old/new
version, migration/gate exits, backup, registry advancement, commit, push, and recovery action. A partial
batch is not success. Resume starts from recorded state; consumed approvals remain consumed, and any new
write needs a new approval and scope digest.
