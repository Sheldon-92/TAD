# Lockfile Integrity

> Validate lockfile hash integrity, HTTPS-only sources, and lockfile-manifest consistency.
> Output artifact: `lockfile-report.md`.
> Known limitation: full coverage for npm/yarn; partial for pip/go (no hash verification equivalent).

## Step 1: Detect Lockfiles

Find all lockfiles in the repository:

- `package-lock.json` / `yarn.lock` → npm/yarn
- `Cargo.lock` → Rust
- `poetry.lock` / `uv.lock` → Python
- `go.sum` → Go
- `Gemfile.lock` → Ruby
- `composer.lock` → PHP
- `pnpm-lock.yaml` → pnpm

Record:

- Which lockfiles exist
- Which lockfiles are MISSING (manifest without lockfile = risk)
- Whether lockfiles are in `.gitignore` (they should NOT be for apps)

**Quality bar**: All lockfiles found. Missing lockfiles flagged.

## Step 2: Validate Hashes

For npm/yarn lockfiles:

    lockfile-lint --path package-lock.json --type npm \
      --allowed-hosts npm --validate-https --validate-integrity

Checks performed:

- sha512 integrity hashes present for every entry
- All packages resolved from HTTPS sources (no http://, git://)
- No packages from unauthorized registries

For Cargo.lock — includes sha256 checksums by default; verify file isn't manually edited:

    cargo generate-lockfile --check

(fails if lockfile is stale)

Known limitation: pip `requirements.txt` has no hashes by default.
For pip: recommend `pip-compile --generate-hashes` (pip-tools) or `uv lock`.

**Quality bar**: All npm/yarn entries have sha512. No non-HTTPS sources.

## Step 3: Check Lockfile-Manifest Consistency

Compare lockfile against manifest to detect drift.

npm:

    npm ls --all 2>&1 | grep "missing:"    # finds orphan deps
    diff <(jq '.dependencies | keys' package.json) <(jq '.packages | keys' package-lock.json)

Cargo:

    cargo generate-lockfile --check    # exits non-zero if lockfile is stale

Flag issues:

- Lockfile has packages not in manifest (orphan deps)
- Manifest has packages not in lockfile (unresolved deps)
- Lockfile was manually modified (no corresponding manifest change)

**Quality bar**: Lockfile matches manifest. No orphan deps.

## Step 4: Enforce Policy

Produce policy enforcement result.

FAIL pipeline if:

- Any lockfile is missing for a manifest file
- npm/yarn lockfile has entries without integrity hashes
- Any package resolved from non-HTTPS source
- Lockfile modified without corresponding manifest change

WARN if:

- pip requirements.txt lacks hash pins
- go.sum has entries not corresponding to go.mod

Report format (`lockfile-report.md`):

    ## Lockfile Integrity Report
    | Lockfile | Hashes | HTTPS-only | Manifest Match | Status |
    |----------|--------|------------|----------------|--------|

**Quality bar**: Clear pass/fail per lockfile with actionable remediation.

## Quality Criteria (pass/fail)

- All lockfiles have integrity hashes (sha512 for npm, sha256 for Cargo)
- No packages resolved from non-HTTPS sources
- Lockfile-to-manifest consistency verified
- Pre-commit hook recommendation for lockfile modification
- Known limitations documented (pip hash gaps)
