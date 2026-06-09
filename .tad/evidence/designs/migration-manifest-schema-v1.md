# Migration Manifest Schema v1

> Defines the machine-readable contract for TAD version-to-version upgrades.
> A manifest declares what to delete, rename, merge, and verify when upgrading
> from version A to version B.

**Schema Version**: 1
**Status**: Active (Phase 1/6 of Upgrade Lifecycle System Epic)
**Date**: 2026-06-09
**Consumers**: migration-engine.sh (Phase 2), release-verify.sh migration mode (Phase 5)

---

## Overview

A migration manifest is a YAML file at `.tad/migrations/{from}-to-{to}.yaml` that
declares the file-level operations needed when upgrading TAD from one version to the
next. It is a **decision file maintained by humans** (with optional Phase 5 script-assisted
drafting), NOT an auto-generated artifact. The manifest is the "approved operations list"
for an upgrade — it does not attempt to be a complete diff of all changes between versions.

### What the Manifest IS

- A declarative allow-list of approved destructive operations (delete, rename)
- A forward-compatible contract with versioned schema
- A chainable unit: upgrade A→C = apply A→B then B→C in sequence

### What the Manifest is NOT

- NOT a complete diff mirror (many version changes are non-destructive file additions/modifications handled by normal sync/copy)
- NOT an auto-generated artifact (Phase 5 scripts produce drafts; human confirms before committing)
- NOT a coverage gate (the manifest being "incomplete" relative to `git diff` is by design — it only captures operations that require active intervention)

### Path Safety: allow-list vs deny-list — Why This Schema Uses BOTH

The TAD project has established principles about allow-lists and deny-lists
(see principles.md "Deny-List Beats Allow-List for Sync Sets"):

- **Sync sets** use a **deny-list** because the set grows over time; a new directory
  should default to INCLUDED (fail-open-safe, auditable).
- **Path safety** in this schema uses an **allow-list** because destructive operations
  (delete, rename) must default to REJECTED (fail-closed-safe). A path not on the
  approved prefix list is forbidden from being operated on.

These are **opposite tools for opposite problems**: sync inclusion grows organically,
so deny-list prevents omission; destructive operations must be explicitly authorized,
so allow-list prevents accidental harm.

---

## Manifest Structure

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | int | **YES** | Schema version number. Current version = 1. See Forward Compatibility. |
| `from` | string | **YES** | Source version, quoted three-segment semver (e.g., `"2.26.0"`). |
| `to` | string | **YES** | Target version, quoted three-segment semver. |
| `min_engine_version` | string | optional | Minimum migration engine version required to process this manifest. Omission = no requirement. Defined now, enforced in Phase 2. |
| `generated_by` | string | optional | `"manual"` or `"draft-script"`. Makes the "decision file, not generated artifact" boundary machine-visible. |
| `delete` | list | optional | Files/directories to delete. |
| `rename` | list | optional | Files/directories to rename. |
| `merge` | list | optional | Files requiring content merge (frozen shape, Phase 4 implementation). |
| `verify` | list | optional | Post-migration verification checks. |

**Filename-field invariant (FR4e)**: The filename `{from}-to-{to}.yaml` MUST match the
`from` and `to` field values inside the file. The fields are authoritative — if they
disagree, the manifest is invalid.

**Version format (FR4d)**: Both `from` and `to` MUST be quoted three-segment semver strings
(e.g., `"2.26.0"`, not `2.26` which YAML parses as float 2.26, not `"2.30"` which
unquoted becomes `2.3`). Callers (tad.sh via version.txt, *sync via sync-registry.yaml)
MUST normalize their version strings to this format before matching.

### YAML Pitfall Rules (NFR3)

These rules prevent common YAML parsing failures:

1. **Version numbers MUST be quoted**: `"2.26.0"` not `2.26.0` (unquoted `2.30` becomes float `2.3`)
2. **`schema_version` is explicitly int**: `schema_version: 1` (no quotes, integer type)
3. **Sections MUST be list-of-maps**: `delete: [{path: "...", type: "..."}]`, NOT map-keyed-by-path (`delete: {"path/a": {type: "..."}}`) — map keys silently deduplicate, swallowing duplicate path entries
4. **Free-text fields (`reason`, `strategy`) MUST be quoted**: prevents YAML interpreting colons in values as key-value separators
5. **Empty section equivalence**: `delete: []` is equivalent to omitting `delete:` entirely, and equivalent to `delete:` with null value. Consumers MUST treat all three as "no delete operations"

---

## Section: delete

Declares files and directories to be removed during the upgrade.

### Field Specification

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | **YES** | Relative path from repo root. Must pass Path Safety Pipeline. |
| `type` | string | **YES** | `"file"` or `"dir"`. Explicit declaration — trailing slash is NOT used to indicate directories. |
| `reason` | string | recommended | Why this file is being deleted. Quoted string. |

### Valid Example

```yaml
delete:
  - path: ".claude/skills/blake/references/completion-protocol.md"
    type: "file"
    reason: "v2.27.0 progressive loading restructure — protocol inlined to SKILL.md body"
```

### Invalid Example

```yaml
delete:
  - path: "../../../etc/passwd"    # REJECTED: contains ".." (path traversal)
    type: "file"
  - path: ".tad/active/my-data"   # REJECTED: .tad/active/ is ZERO_TOUCH
    type: "dir"
  - path: "src/app.ts"            # REJECTED: prefix not in allow-list
    type: "file"
```

---

## Section: rename

Declares files and directories to be renamed (moved) during the upgrade.

### Field Specification

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `from` | string | **YES** | Current path. Must pass Path Safety Pipeline. |
| `to` | string | **YES** | New path. Must pass Path Safety Pipeline. |
| `type` | string | **YES** | `"file"` or `"dir"`. Explicit declaration, consistent with delete section. |
| `reason` | string | recommended | Why this rename is needed. Quoted string. |

### Valid Example

```yaml
rename:
  - from: ".tad/old-config.yaml"
    to: ".tad/new-config.yaml"
    type: "file"
    reason: "Config naming convention change in v2.28.0"
```

### Invalid Example

```yaml
rename:
  - from: ".tad/hooks/my-hook.sh"
    to: "/usr/local/bin/my-hook.sh"   # REJECTED: absolute path
    reason: "Move hook to system path"
  - from: ".tad/project-knowledge/patterns/old.md"  # REJECTED: .tad/project-knowledge/ is ZERO_TOUCH
    to: ".tad/project-knowledge/patterns/new.md"
```

---

## Section: merge

Declares files that require content merging during the upgrade. The merge operation
preserves user-authored content below a marker while updating framework-managed content above it.

### Field Specification

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `path` | string | **YES** | Path to the file requiring merge. Must pass Path Safety Pipeline. |
| `strategy` | string | **YES** | Merge strategy identifier. Currently only `"tad-head-marker"`. |
| `marker` | string | **YES** | The marker string that separates framework content from user content. |
| `on_missing_marker` | string | **YES** | Behavior when marker is not found in the target file. Currently only `"skip_and_report"`. |

**Shape freeze**: This section's complete field set is frozen in this Phase. Phase 4 implements
the execution logic but MUST NOT change the field names, types, or semantics.

### Valid Example

```yaml
merge:
  - path: "CLAUDE.md"
    strategy: "tad-head-marker"
    marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->"
    on_missing_marker: "skip_and_report"
```

### Invalid Example

```yaml
merge:
  - path: "CLAUDE.md"
    strategy: "overwrite"          # INVALID: only "tad-head-marker" is a valid strategy in schema v1
    marker: "<!-- TAD:PROJECT-CONTENT-BELOW -->"
```

---

## Section: verify

Declares post-migration verification checks. Each entry is an assertion about the
expected state of the filesystem after migration operations complete.

The verify section has a **dual role (NFR4)**:
1. **Post-migration validation**: confirms operations applied correctly
2. **Idempotency oracle**: `type: absent` checks serve as "already applied" indicators — if all verify assertions pass before running the migration, the migration has already been applied and can be skipped

### Field Specification

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | **YES** | Verification type: `"absent"` (path must not exist) or `"present"` (path must exist). |
| `path` | string | **YES** | Path to check. Must pass Path Safety Pipeline (prefix check only — the path may not exist). |

### Valid Example

```yaml
verify:
  - type: "absent"
    path: ".claude/skills/blake/references/completion-protocol.md"
  - type: "present"
    path: ".claude/skills/blake/SKILL.md"
```

### Invalid Example

```yaml
verify:
  - type: "contains"              # INVALID: only "absent" and "present" in schema v1
    path: "CLAUDE.md"
    content: "v2.27.0"
```

---

## Consumer Semantics Contract (FR1.5)

This section defines MANDATORY behavior for any consumer (engine, verifier) of migration manifests.

### a. Unknown `schema_version` Handling

When a consumer reads a manifest with `schema_version` higher than its supported maximum:
- **MUST**: hard-fail immediately (refuse to execute the entire manifest)
- **MUST**: emit an error message suggesting the user upgrade the migration engine or perform a clean reinstall
- **MUST NOT**: attempt partial execution or silently ignore unknown features

This is the primary forward-compatibility safety mechanism. A remote user running an
old engine against a new manifest gets a clear error, not silent mis-execution.

### b. Unknown Field Strategy (per-section)

| Section | Unknown field behavior | Rationale |
|---------|----------------------|-----------|
| `delete` | **fail-closed** — reject the entire manifest | An unknown field in a delete entry could carry safety-relevant semantics (e.g., a future `platform:` filter). Ignoring it risks executing a delete that should have been filtered. |
| `rename` | **fail-closed** — reject the entire manifest | Same rationale as delete — rename is destructive. |
| `merge` | **fail-closed** — reject the entire manifest | Merge involves content manipulation; unknown fields could alter merge behavior. |
| `verify` | **warn and ignore** — skip the unknown field, process the entry | Verification is non-destructive. An unknown field in a verify entry cannot cause data loss. |

### c. Cross-Section Path Conflict

If the same path appears in multiple sections with conflicting semantics:
- `delete` + `rename.from`: **manifest is invalid** (deleting a file that's being renamed away)
- `delete` + `rename.to`: **manifest is invalid** (renaming a file in, then deleting it)
- `delete` + `merge.path`: **manifest is invalid** (deleting a file that needs merging)
- `delete` + `verify.present`: **manifest is invalid** (delete then assert present is contradictory)
- `rename.from` + `rename.to` (same path, same entry): **manifest is invalid**
- `rename.to` + `rename.to` (different entries, same destination): **manifest is invalid** (two renames targeting the same path)
- `rename.from` + `merge.path`: **manifest is invalid** (renaming away a file targeted for merge)
- `delete` + `verify.absent`: **valid** (delete then confirm deletion — normal pattern)
- `rename.from` + `verify.absent`: **valid** (rename away then confirm old location is gone)

**Duplicate path rule**: The same path appearing twice within the same section is **manifest is invalid** (ambiguous which entry's fields are authoritative).

Consumers MUST validate cross-section path conflicts and within-section duplicates BEFORE
executing any operation. Conflict detection is a manifest-level validation step, not a
per-operation runtime check.

### d. Section Execution Order

Sections MUST be executed in this fixed order: **rename → delete → merge → verify**.

This order is a manifest-level declaration, not a consumer implementation choice.
Rationale:
- Rename before delete: if a file is renamed and another file at the old location is
  deleted, rename must happen first to avoid deleting the wrong file
- Delete before merge: merge operates on the new file state
- Verify last: confirms the final state after all operations

Within each section, entries are executed in file order (top to bottom in the YAML list).

### e. Empty Section Equivalence

`delete: []` is equivalent to `delete:` (null) is equivalent to omitting the `delete:` key entirely.
Consumers MUST treat all three forms as "no operations for this section."

---

## Path Safety Pipeline (FR2)

Every path in `delete`, `rename`, `merge`, and `verify` sections MUST pass through this
five-step validation pipeline. The pipeline is an **allow-list** design — a path must be
explicitly approved at each step, not merely "not forbidden."

### Step 1: Normalize

Reject paths with:
- Leading or trailing whitespace
- Empty string or whitespace-only string
- NUL (`\0`) or other control characters (bytes 0x00-0x1F, 0x7F)
- Newline characters (`\n`, `\r`)
- Trailing slash (directory operations use explicit `type: dir` field)

### Step 2: Reject-if-Forbidden

Reject paths containing or matching:
- `*` `?` `[` — glob/wildcard characters
- `..` — path traversal (at any position: start, middle, end)
- `~` at start — tilde expansion
- `/` at start — absolute path
- `\\` — Windows path separator (backslash)
- `-` at start — leading-dash option injection. Schema additionally requires that engines use `rm --` (end-of-options) before any path argument, but this is defense-in-depth, not a substitute for rejecting leading-dash paths in the manifest.

### Step 3: Assert-Prefix

Path MUST start with one of:
- `.tad/`
- `.claude/`
- `.codex/`
- `.agents/`

OR be one of the explicitly enumerated root files:
- `CLAUDE.md`
- `AGENTS.md`
- `tad.sh`

Any path not matching these prefixes is rejected. This is the allow-list that prevents
manifest entries from reaching outside the framework's managed file space.

### Step 4: Assert-Realpath-Containment + Not-Symlink (engine-layer)

This step is declared in the schema but executed by the migration engine (Phase 2):
- Before executing any `delete` or `rename`, the engine MUST resolve the path's realpath
  and verify it is contained within the repository root directory
- The engine MUST verify that NO component of the path is a symlink
- This is the "last defense" against repo escape via symlink: `rm -rf` through a symlink
  like `a → $HOME` would delete `$HOME/b` when targeting `a/b`

### Step 5: ZERO_TOUCH Protection

No path may target a directory listed by `derive-sync-set.sh --zero-touch`.
This applies to ALL path fields: `delete.path`, `rename.from`, `rename.to`,
`merge.path`, and `verify.path`. For rename operations specifically, BOTH the
source (`from`) and destination (`to`) are checked — renaming INTO a ZERO_TOUCH
directory is equally dangerous as renaming OUT of one (it would inject framework
content into the user's project-specific data space).

This check uses the public flag as the sole authority — the manifest MUST NOT
hardcode the directory list (to avoid drift when the list changes).

At schema validation time (manifest authoring): human verifies no entry targets a
zero-touch directory. At engine execution time (Phase 2): engine calls
`derive-sync-set.sh --zero-touch` and rejects any operation targeting those directories.

### Runnable Validator Snippet (BSD-compatible)

The following snippet implements Steps 1-3 of the pipeline. It can be extracted and
used directly by the Phase 2 engine.

```bash
#!/bin/bash
# Migration manifest path validator — Steps 1-3
# Usage: echo "path/to/check" | bash validator.sh
# Exit 0 = valid, Exit 1 = invalid (reason on stderr)

set -euo pipefail

validate_path() {
    local p="$1"

    # Step 1: Normalize
    if [ -z "$p" ] || [ -z "$(printf '%s' "$p" | tr -d '[:space:]')" ]; then
        echo "REJECT: empty or whitespace-only path" >&2; return 1
    fi
    if printf '%s' "$p" | grep -qE '^[[:space:]]|[[:space:]]$'; then
        echo "REJECT: leading or trailing whitespace" >&2; return 1
    fi
    if printf '%s' "$p" | LC_ALL=C grep -q '[[:cntrl:]]'; then
        echo "REJECT: control character detected" >&2; return 1
    fi
    if printf '%s' "$p" | grep -qE '/$'; then
        echo "REJECT: trailing slash (use type: dir instead)" >&2; return 1
    fi

    # Step 2: Reject-if-Forbidden
    case "$p" in
        *'*'*|*'?'*|*'['*)
            echo "REJECT: glob character (*?[)" >&2; return 1 ;;
        *'..'*)
            echo "REJECT: path traversal (..)" >&2; return 1 ;;
        '~'*)
            echo "REJECT: tilde expansion" >&2; return 1 ;;
        '/'*)
            echo "REJECT: absolute path" >&2; return 1 ;;
        *\\*)
            echo "REJECT: backslash (Windows separator)" >&2; return 1 ;;
        '-'*)
            echo "REJECT: leading dash (option injection)" >&2; return 1 ;;
    esac

    # Step 3: Assert-Prefix
    case "$p" in
        .tad/*|.claude/*|.codex/*|.agents/*) ;;  # valid prefix
        CLAUDE.md|AGENTS.md|tad.sh) ;;            # valid root file
        *)
            echo "REJECT: path prefix not in allow-list" >&2; return 1 ;;
    esac

    echo "VALID" >&2
    return 0
}

while IFS= read -r path; do
    validate_path "$path"
done
```

### Validator Test: Legal/Illegal Pair

**Legal** (exit 0):
```bash
echo ".claude/skills/blake/references/completion-protocol.md" | bash validator.sh
# Output: VALID
```

**Illegal** (exit 1, contains `..`):
```bash
echo ".tad/../../../etc/passwd" | bash validator.sh
# Output: REJECT: path traversal (..)
```

---

## ZERO_TOUCH Protection Design (FR3)

Migration manifests interact with ZERO_TOUCH directories (project-specific data
that must never be modified by framework operations) through a dual-layer design:

### Schema Layer (this document)

- A manifest entry whose path starts with any ZERO_TOUCH directory prefix is
  **invalid by construction** — it should never appear in a committed manifest
- The human author (or Phase 5 draft script) checks paths against
  `derive-sync-set.sh --zero-touch` output during authoring

### Engine Layer (Phase 2)

- Before executing any operation, the engine calls `derive-sync-set.sh --zero-touch`
  and builds a runtime rejection list
- Any operation targeting a ZERO_TOUCH path is rejected with a clear error

### Authority Reference

The ZERO_TOUCH directory list is maintained in `derive-sync-set.sh` (the ZERO_TOUCH
array, currently at L53-61). This manifest schema **references the public flag**
(`--zero-touch`) as the sole authority. The schema document intentionally does NOT
reproduce the directory list — doing so would create a second source of truth that
drifts when the array is updated (per principles.md "BA-P1-5: lib annotation 8-vs-9
drift would be inherited by schema if numbers are transcribed").

---

## Chain Upgrade Rules (FR4)

### Adjacent Version Definition (FR4a)

"Adjacent" = the next version in the manifest existence set, sorted by `sort -V`.
This includes patch versions: `2.22.0 → 2.22.1 → 2.23.0` is a valid chain of
three adjacent pairs, each requiring its own manifest.

### Forward-Only Constraint (FR4b)

Migration manifests are **forward-only**. If `from >= to` (by `sort -V` comparison),
the engine MUST refuse execution with an explicit error. Running a delete list in
reverse would be a safety violation (deleting files that should exist in the older version).

### Chain Gap Handling (FR4c)

If there is no complete chain of adjacent manifests from `from` to `to`, the engine
MUST refuse execution and suggest a clean reinstall. Example: upgrading from v2.20.0 to
v2.25.0 requires manifests for 2.20.0→2.21.0, 2.21.0→2.22.0, 2.22.0→2.22.1,
2.22.1→2.23.0, 2.23.0→2.23.1, 2.23.1→2.24.0, 2.24.0→2.24.1, 2.24.1→2.25.0.
If any link is missing, the chain is broken.

### Version Format (FR4d)

`from` and `to` fields MUST be quoted three-segment semver strings: `"2.26.0"`.
Both callers (tad.sh reading version.txt, *sync reading sync-registry.yaml) MUST
normalize to this format before matching manifest filenames.

### Filename-Field Invariant (FR4e)

The filename `{from}-to-{to}.yaml` MUST match the `from` and `to` fields inside
the manifest. The fields are authoritative — a mismatch means the manifest is invalid.

---

## Forward Compatibility (NFR1)

### schema_version Semantics (NFR1a)

`schema_version` is an integer (currently 1). When a consumer encounters a
`schema_version` higher than its maximum supported version, it MUST hard-fail
(see Consumer Semantics Contract §a). This ensures old engines don't silently
mis-process new manifest features.

### Merge Shape Freeze (NFR1b)

The `merge` section's field set (`path`, `strategy`, `marker`, `on_missing_marker`)
is **fully frozen in this schema version**. Phase 4 implements the execution logic
for these exact fields. No field addition, removal, or semantic change is permitted
without incrementing `schema_version`.

### min_engine_version (NFR1c)

An optional manifest-level field. When present, the engine checks its own version
against this value and hard-fails if below. This allows future schema additions to
require an engine update even within the same `schema_version` — a softer evolution
mechanism than incrementing the schema version.

Omission = no engine version requirement (backward compatible with engines that
don't check this field).

### Platform Scope Extension (NFR1d)

Schema v1 does not define a `platform:` field on entries. The forward-compatibility
contract declares the additive extension rule:

- An entry **without** a `platform:` key applies to **all platforms**
- A future schema version MAY add an optional `platform:` key (e.g.,
  `platform: "codex"`) to scope an entry to a specific platform
- Adding `platform:` is additive from a schema design perspective. However,
  because FR1.5b requires fail-closed on unknown fields in destructive sections
  (delete/rename/merge), an old engine WILL reject manifests containing `platform:`
  entries. This is the correct behavior — it forces engine upgrade. The
  `min_engine_version` field (NFR1c) should be set in any manifest using `platform:`
  to give the user a clear error message instead of an opaque "unknown field" rejection.

### New Section Types

Adding a new top-level section (beyond delete/rename/merge/verify) REQUIRES
incrementing `schema_version`. An engine that encounters an unknown section at
its supported schema_version MUST reject the manifest (fail-closed, consistent
with the unknown-field-in-destructive-section strategy from FR1.5b). This ensures
new operation types are never silently ignored by old engines.

### generated_by Source Field (NFR1e)

Optional field making the "decision file vs generated artifact" boundary machine-visible:
- `"manual"`: human-authored manifest
- `"draft-script"`: Phase 5 script-generated draft (requires human review before commit)

Omission = unspecified (treated as manual by consumers).

---

## Consumer Reference Table (MQ3)

| Manifest Section | Consumer | When Consumed | Phase |
|-----------------|----------|---------------|-------|
| `schema_version` | All consumers | On manifest load (forward-compat gate) | All |
| `min_engine_version` | migration-engine.sh | On manifest load (engine compat gate) | 2 |
| `from` / `to` | migration-engine.sh, release-verify.sh | Chain resolution, version matching | 2, 5 |
| `delete` | migration-engine.sh | Upgrade execution (after rename, before merge) | 2 |
| `rename` | migration-engine.sh | Upgrade execution (first operation) | 2 |
| `merge` | migration-engine.sh | Upgrade execution (after delete, before verify) | 4 |
| `verify` | migration-engine.sh, release-verify.sh | Post-operation validation + idempotency check | 2, 5 |
| `generated_by` | release-verify.sh | Audit trail: distinguish manual vs draft manifests | 5 |

---

## Relationship to deprecation.yaml

See DR-20260609-deprecation-yaml-disposition.md for the full decision record on
how migration manifests relate to the existing `deprecation.yaml` mechanism.
