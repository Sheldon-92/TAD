# Phase 3 Adversarial Review — code-security pack — CORRECTNESS lens

- **Lens**: correctness (does the upgraded SKILL.md + references + scripts + fixture meet the dual-layer bar; is guidance internally consistent, actionable, and factually correct against cited sources?)
- **Reviewer posture**: default-skeptic, attempt to REFUTE that it meets the bar.
- **Date**: 2026-06-13
- **meets_bar**: TRUE (clears Layer A 10/10, Layer B bucket-4, discriminative wired) — **but with one material correctness defect that should be fixed before "accepted"** (see Finding F1). The bar as defined (structure + depth + eval-wiring) is met; the defect is a fact-accuracy flaw in a load-bearing deterministic script, which the QUALITY-BAR routes to the Phase 2-5 cross-model DoD rather than the meets_bar scoring gate.

---

## Verification actually run (not paper)

### Layer A — 10/10 (pass line 7)
All grep/structural checks re-run on disk:
- A1 frontmatter name+description present, 3rd-person, what+when. PASS
- A2 aux files: 7 (references/ + scripts/). PASS
- A3 body size: SKILL.md = **160 lines** (< 550). PASS
- A4 routing: Step 0 Context Detection table + Step 1/2. PASS
- A5 contract: CONSUMES/PRODUCES present (line 8-9). PASS
- A6 anti-skip table present (6 excuse→counter rows). PASS
- A7 navigation: "Quick Capability Index" + per-ref "Quick Rule Index". PASS
- A8 fixture: examples/sast-dast-triage-pipeline.md (1). PASS
- A9 eval wired: `discriminative_pattern` + `min_discriminative: 3` present. PASS
- A10 scripts: 2 executable (`triage-prioritize.sh`, `verify-pipeline-gates.sh`, both -rwxr-xr-x). PASS

### Layer B — bucket 4 (pass; ≤2 = fail)
- specN (specific-threshold dedup count over SKILL+references) = **49** → bucket 40-59 → Layer B 4.
- B1 (rule specificity): strong — exit 183, FIRST.org 3.96%/65.2%, EPSS 0.10≈88th pct, Nuclei v3 150 req/s / -c 10 / -bs 25 defaults, osv-scanner v2.3.5 transitive-via-deps.dev, Semgrep v1.163.0.
- B2 (tool freshness): named CLIs + versions + usage, with retrieval dates. Strong.
- B3 (operationalized criteria): P0-P3 formula, gating matrices, exit-code contract tables. Strong.
- B4 (anti-pattern from incidents): 72%-tool-sprawl, alert-fatigue, "scan prod" disruption, rotate-before-cleanup. Strong.

### Discriminative gate — wired and self-consistent
- Re-ran the fixture `discriminative_pattern` against SKILL.md + references/: all marker classes present (3.96%, 65.2%, 72%, 88th percentile, BOD 26-04 ×7, "Detection is NOT Remediation", exit 183 ×3, fastest-fail-first, Four-Gate, interfile ×9, reachability ×14, SSVC ×8). A no-pack agent would not reproduce these verbatim → genuinely discriminative, not validation theater.

### Scripts actually executed (behavioral, not paper)
- `triage-prioritize.sh` on 7-row CSV + JSON: P0/P1/P2/P3 branches all fire correctly per rule V1 formula; exit 0. JSON path (jq) works.
- `verify-pipeline-gates.sh`: GOOD config → PASS exit 0; BAD config (codeql before gitleaks + `semgrep ci || true`) → correctly flags BOTH ordering violation and swallowed exit code, exit 1. The gate discriminates.

### Fact-checks against primary sources (WebSearch/WebFetch, 2026-06-13)
- TruffleHog **exit 183** = verified credentials found with `--fail`. CONFIRMED (GitHub trufflehog docs / appsecsanta). Pack correct.
- FIRST.org EPSS: CVSS≥7 → 57.4% effort / 82.2% coverage / **3.96% efficiency**; EPSS≥0.1 → 2.7% / 63.2% / **65.2% efficiency**. CONFIRMED verbatim (first.org/epss/model). Pack correct.
- CISA **BOD 26-04** issued 2026-06-10, supersedes BOD 22-01 (and 19-02), 4-variable risk model (exposure × KEV × automatable × technical-impact), strictest tier = 3 days + mandatory forensic triage. Directive existence + structure CONFIRMED (cisa.gov, Tenable FAQ, Automox).

---

## Findings

### F1 (MATERIAL, correctness): BOD 26-04 tiering in the deterministic script is WRONG for the KEV+total-control case
The pack frames `triage-prioritize.sh` as a *fixed contract* ("MUST NOT be punted to the model, because the BOD 26-04 tier deadlines are fixed contracts"). But its 3-day branch is:
`kev AND automatable AND internet_facing AND control∈{partial,total}`.
Per the directive (Tenable BOD 26-04 FAQ, fetched 2026-06-13): **KEV + total system control → 3 days + mandatory forensic triage REGARDLESS of whether the asset is publicly exposed or the exploit is automatable.** The pack additionally *requires* automatable AND internet_facing for the 3-day tier, so it UNDER-classifies the strictest case.
- Reproduced: input `kev=true, control=total, automatable=false, internet_facing=false` → script outputs `risk-band tier (per BOD 26-04)` instead of the correct **3 days + forensic triage**. The single most dangerous tier is silently downgraded.
- The rule V7 prose has the same gap (3-day row conditions = "automatable AND internet-facing AND ≥partial-control"), so the defect is in both the prose contract and the executable contract. It is exactly the "fabricated-precision on a version/deadline-sensitive assertion" failure QUALITY-BAR §6 warns about (verify primary doc before encoding). The *judgment* the rule teaches (deadline ∝ exploitation×automatability×exposure×control) is right; the *operationalized tier boundaries* are wrong.
- Severity: real, but bounded — it is a federal-agency edge tier in a helper script, not a teaching error in the core "CVSS≠risk, stack EPSS/KEV/reachability" thesis. Recommend FIX before marking `accepted` (cheap: add a `kev && control=="total"` → 3-day+forensic branch ahead of the automatable/inet test).

### F2 (MINOR, consistency): baseline-commit idiom differs between S3 and S8
S3 uses `--baseline-commit=$(git merge-base HEAD main)` (fork point); S8 uses `--baseline-commit=$(git rev-parse main)` (tip of main). Both are defensible Semgrep usages but semantically different (fork-point vs branch-tip baseline). A reader following both rules gets inconsistent baselines. Not an error; tighten to one idiom or note why they differ.

### F3 (MINOR, brittleness, NOT incorrect): verify-pipeline-gates SLOW regex `nuclei[^-]*-as`
`[^-]*` stops at the first `-`, so a normal `nuclei -u URL -as` invocation is NOT matched as a slow scanner (verified). Intent was to flag a full auto-scan as the slow runtime gate; the regex only matches `nuclei -as` with no intervening flags. The good/bad config tests still pass because they don't rely on this branch, so no false PASS/FAIL observed — but the SLOW-detection for nuclei auto-scan is effectively dead for realistic invocations. Cosmetic-to-minor; does not break the tested gate behavior.

### F4 (NIT, cosmetic): triage script column alignment
`EPSS%ile` column (`%-9s`) vs the unicode `≥88th`/`<88th` values renders slightly ragged in the table (multibyte width). Output is still readable; no logic impact.

---

## fact_checks
- TruffleHog exit 183 = verified leaked credentials (with --fail): CONFIRMED correct (GitHub trufflehog / appsecsanta, 2026-06-13).
- FIRST.org EPSS efficiency CVSS≥7=3.96% / EPSS≥0.1=65.2% (+ effort 57.4%/2.7%, coverage 82.2%/63.2%): CONFIRMED verbatim against first.org/epss/model (2026-06-13).
- EPSS 0.10 ≈ 88th percentile framing: consistent with FIRST.org "present prob+percentile, do not bin" guidance: CONFIRMED reasonable.
- CISA BOD 26-04 exists, issued 2026-06-10, supersedes BOD 22-01, 4-variable risk model, 3-day+forensic strictest tier: CONFIRMED (cisa.gov / Tenable / Automox, 2026-06-13).
- BOD 26-04 3-day tier trigger as encoded by the pack (requires automatable AND internet_facing): REFUTED — directive triggers 3-day+forensic on KEV+total-control regardless of exposure/automatability (Tenable BOD 26-04 FAQ, 2026-06-13). Pack under-classifies. See F1.
- Nuclei v3 default rate-limit 150 req/s, -c 10, -bs 25, -rl precedence over -c/-bs: plausible and internally consistent; not independently re-verified against projectdiscovery docs this session (pack cites docs.projectdiscovery.io retrieved 2026-06-13). Flagged for cross-model verify per QUALITY-BAR §6.
