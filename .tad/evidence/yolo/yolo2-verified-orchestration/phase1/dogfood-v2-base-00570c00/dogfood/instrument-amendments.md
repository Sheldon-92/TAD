# Dogfood instrument amendments (full disclosure)

Changing an acceptance instrument mid-experiment is a real integrity risk, so
every change is recorded here with the evidence state at the time.

## A1 — `S2-invents-nothing` rule, v1 → v2

- **When**: after the control run's executor finished, before ANY run's hidden
  acceptance had been executed and before ANY per-run Gate verdict existed.
  No run had been accepted, and no score had been recorded, at the time.
- **Applies to**: `drivers/slice-check.mjs` and `hidden-acceptance.mjs`
  (identical rule in both; both amended identically).
- **v1 rule**: an identifier in backticks inside the Troubleshooting section is
  "invented" unless it is a `ContractError`/`UsageError` reason string.
- **Defect**: false-positive by construction. A troubleshooting table
  legitimately quotes field names and enum values (`base_commit`,
  `written_by_id`, `outcome_unknown`, `intended_post_sha256`, …) that are not
  error reasons. The control run was failed for 12 such correct references.
- **v2 rule**: an identifier is "invented" iff it appears NOWHERE in
  `.tad/scripts/yolo-recovery.mjs`. This is the property the frozen task
  actually states ("Do not invent reason strings that the source does not
  contain") and it keeps a genuine red state: a fabricated token still fails.
- **Not a relaxation of the bar**: the companion rule
  `S2-quotes-real-reasons` (>= 8 identifiers that ARE real reason strings) is
  unchanged, so a section that quotes only field names and no real reasons
  still fails.
- **Applied uniformly**: every run — control and all three treatments — is
  scored with v2. No run was scored with v1.
