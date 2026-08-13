# Typosquat Detection

> Detect typosquatting package names — character swap, omission, addition, homoglyph substitution.
> Output artifact: `typosquat-report.md`.

## Step 1: Extract Dependencies

Parse all manifest files to get dependency names:

- `package.json` → dependencies + devDependencies
- `requirements.txt` / `pyproject.toml` → all listed packages
- `Cargo.toml` → [dependencies] + [dev-dependencies]
- `go.mod` → require block

Produce a flat list of all dependency names across all ecosystems.
Include both direct and (if SBOM available) transitive dependencies.

**Quality bar**: All manifest files parsed. Complete dependency name list.

## Step 2: Generate Variants

For each dependency name, generate typosquat variants.

Techniques:

1. Character swap: express → exrpess, expreess
2. Character omission: express → expres, xpress
3. Character addition: express → expresss, eexpress
4. Homoglyph substitution: express → еxpress (Cyrillic е)
5. Hyphen/underscore confusion: my-package → my_package → mypackage
6. Scope confusion: @scope/pkg → scope-pkg, @other/pkg

Use the typosquatting CLI for automated variant generation:

    typosquatting check express --ecosystem npm

**Quality bar**: At least 4 variant techniques applied per dependency.

## Step 3: Check Registries

Query package registries for variant names. For each generated variant:

1. Check if the variant name is a registered package
2. If registered, compare publisher with the original package's publisher
3. Check download count (low downloads + similar name = suspicious)
4. Check creation date (recently created + similar name = suspicious)

Also use socket CLI's built-in typosquat detection:

    socket scan create --repo .

Socket automatically flags known typosquat patterns.

**Quality bar**: All variants checked against live registries.

## Step 4: Cross-Reference SBOM

If an SBOM was generated (by the dependency audit capability, CycloneDX format):

    typosquatting scan --sbom sbom.cdx.json

This scans ALL components in the SBOM (including transitive) for typosquat risk.
Cross-reference with the dependency list to ensure no typosquat made it into the
resolved dependency tree.

**Quality bar**: Full SBOM scanned. Transitive deps included.

## Step 5: Alert on Matches

Generate alert for each potential typosquat (`typosquat-report.md`):

    ## Typosquat Detection Report
    - **Date**: {timestamp}
    - **Dependencies Checked**: {N}
    - **Variants Generated**: {M}

    ### Confirmed Typosquats (BLOCK)
    | Original | Typosquat | Registry | Downloads | Publisher Match | Action |

    ### Suspicious (REVIEW)
    | Original | Suspected | Registry | Reason | Action |

    ### Clean
    {N} dependencies checked, no typosquat candidates found.

Maintain an allowlist of verified-safe package names to reduce false positives
on subsequent runs.

**Quality bar**: Every alert has publisher comparison. Allowlist maintained.

## Quality Criteria (pass/fail)

- All direct dependencies checked for typosquat variants
- Flagged packages include publisher identity comparison
- Known-good package names maintained in allowlist
- Detection covers: character swap, omission, addition, homoglyph
- SBOM cross-reference catches typosquats in transitive deps
