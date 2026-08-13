# Behavioral Analysis

> Detect suspicious behavioral changes in new or updated dependencies (network calls, fs writes, eval).
> Output artifacts: `socket-scan-results.json`, `behavioral-report.md`.
> ⚠️ NO GRACE PERIOD: behavioral anomalies in new/updated dependencies block merge immediately (litellm rule).

## Step 1: Select Packages

Identify new or updated dependencies from lockfile diff:

    git diff HEAD~1 -- package-lock.json yarn.lock Cargo.lock poetry.lock uv.lock go.sum

For each changed entry, extract:

- Package name and version (old → new)
- Whether it's new (added) or updated (version changed)
- Whether it's a direct or transitive dependency

Priority: new packages > version updates > transitive updates.

**Quality bar**: All lockfile changes captured. Old → new version pairs recorded.

## Step 2: Run Behavioral Scan

Execute socket CLI scan on changed packages.

Enable socket wrapper (intercepts npm/yarn install):

    socket wrapper on

Or create explicit scan report:

    socket scan create --repo .

Socket checks for:

- Network access patterns (unexpected outbound connections)
- Filesystem writes outside expected paths
- Shell command execution (child_process, exec, system)
- Obfuscated code (base64 encoding, eval usage)
- Install scripts with side effects

For Python packages, also run:

    depscan --src $PWD --deep

(dep-scan's deep mode checks for dependency confusion attacks)

**Quality bar**: Every new/updated package scanned. Behavioral profile generated.

## Step 3: Evaluate Risk Signals

Compare behavioral profile against baselines.

HIGH RISK signals (block immediately):

- New network calls to unknown domains
- New filesystem writes outside package directory
- New eval/exec/system usage that wasn't in previous version
- Install script added where none existed before
- Obfuscated code detected

MEDIUM RISK signals (review required):

- New optional dependencies added
- Maintainer change between versions
- Significant code size change (>50% increase)

LOW RISK signals (informational):

- Minor version bump with no behavioral change
- Dev dependency update

For each flagged package, produce evidence:

- What changed (diff summary)
- Why it's suspicious (which signal triggered)
- Comparison to known-good baseline

**Quality bar**: Every flagged package has evidence. No block without explanation.

## Step 4: Generate Decision

Produce allow/block/review recommendation for each package (`behavioral-report.md`):

    ## Behavioral Analysis Report
    - **Date**: {timestamp}
    - **Packages Analyzed**: {N} new, {M} updated

    ### Blocked (DO NOT MERGE)
    | Package | Version | Signal | Evidence | Action |

    ### Review Required
    | Package | Version | Signal | Evidence | Reviewer |

    ### Allowed
    | Package | Version | Note |

    ### litellm-class Attack Coverage
    Would this scan have caught the litellm 1.82.7 behavioral change?
    Answer: {yes/no with explanation}

**Quality bar**: Every package has a clear allow/block/review decision with evidence.

## Quality Criteria (pass/fail)

- Every new/updated dependency scanned before merge
- Behavioral changes between versions explicitly documented
- Network access patterns listed (domains, ports)
- litellm-class attack coverage: would this have caught the 1.82.7 behavioral change? (must answer)
- HIGH RISK signals block pipeline immediately (no grace period)
