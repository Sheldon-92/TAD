# Domain Pack Health Check — Monthly Handoff Template

> Monthly health check for TAD's tool/domain knowledge. Instantiated from
> IDEA-20260402-domain-pack-monthly-refresh. Copy this file into
> `.tad/active/handoffs/HANDOFF-<yyyymm>-domain-pack-health-check.md`, fill
> the bracketed fields, and dispatch to Blake. The run's report and the
> changelog entry are the deliverables; silent staleness is the failure
> this template exists to prevent.

**Cadence:** monthly (IDEA open question — default settled 2026-10-31: monthly, manual trigger. A SessionStart "last check was N days ago" reminder is a recorded future option, NOT built by this template.)
**Executor:** Blake. **Reviewer:** independent Gate 3 run reviewer (the executor never self-certifies a registry/pack edit).

---

## 1. Current artifact map (read first — the 2026-04 map is obsolete)

| Artifact | Location | Status |
|----------|----------|--------|
| Tools registry | `.tad/archive/domains/tools-registry.yaml` | **FROZEN.** YAML Domain Packs retired 2026-06-11 (`.tad/domains/README-retired.md`); the archived registry is an audit trail and is NOT edited by a health check. The check audits it and records findings; it never "updates" it. |
| Domain pack sources (audit trail) | `.tad/archive/domains/2026-06-11-domain-pack-retirement/*.yaml` (9 files) | Frozen, untouched. Presence is checked, content is not. |
| Live domain packs | `.claude/skills/<pack>/` + byte-identical mirror `.agents/skills/<pack>/` | Active form: SKILL.md Capability Packs. The 9 migrated domain packs: hw-circuit-design, hw-enclosure, hw-firmware, hw-testing, mobile-development, mobile-release, mobile-testing, mobile-ui-design, supply-chain-security. |
| Changelog | `.tad/domains/domain-pack-health-changelog.md` | Standing file; every run appends one entry. |

Any step below that says "registry" means the archived registry (audit only);
"packs" means the live SKILL.md packs. If this map no longer matches disk,
STOP and report the drift as the run's first finding.

## 2. Inputs

- This template, instantiated as the run's handoff.
- Previous run's report (`.tad/evidence/domain-pack-health/<yyyymm>/`) if any.
- Last entry in `.tad/domains/domain-pack-health-changelog.md`.

## 3. Steps (each step files its raw output; no output = step not done)

1. **Registry audit (read-only).** Parse the archived registry. Report:
   capability count; tool-entry count (recommended / alternatives);
   `last_updated` value and its age in days; entries with `tested: true`
   vs missing `tested`; entries missing `verify` or `install`; duplicate
   tool names (note: the same tool under several capabilities is the
   registry's normal pattern — report, don't "fix"). Run the registry's
   own pre-flight `which` list on the current machine and record which
   are present/absent (label the machine; absence on one VM is a data
   point, not a verdict).
2. **Pack structural check.** For each of the 9 migrated packs: SKILL.md
   exists on both sides; the `.claude/skills/<pack>` and
   `.agents/skills/<pack>` trees are byte-identical (hash walk, not
   eyeballing); `references/` file count per side; archived YAML source
   still present. Record SKILL.md mtime age in days (mtime ≠ content
   freshness — label it as such).
3. **Pack inventory drift.** Count skill dirs under `.agents/skills/`
   and `.claude/skills/` (excluding `_archived`); list any dir present
   on one side only. New packs since last run are named in the report.
4. **New-tool scan (web, bounded).** 2–4 web searches over the last
   month's MCP servers / CLI tools in the registry's capability areas
   (document/diagram generation, web research, evaluation, the 9 pack
   domains). Record each candidate with: name, what it does, source
   URL, retrieval date. Candidates are proposals for a future refresh
   decision — a health check NEVER adds a tool to any registry or pack
   on scan evidence alone.
5. **Findings & changelog.** Classify every finding:
   - `structural` (broken mirror, missing file) → propose a fix handoff;
     the health check itself does not repair packs.
   - `staleness` (ages, untested entries, spec-era drift such as an MCP
     protocol revision) → record with numbers.
   - `candidate` (new tools from step 4) → record with URL + date.
   Append ONE entry to `.tad/domains/domain-pack-health-changelog.md`:
   date, run pointer, counts, findings by class, edits made (normally
   "none — registry frozen, packs healthy" with the evidence pointer).

## 4. Outputs

- Run report: `.tad/evidence/domain-pack-health/<yyyymm>/HEALTH-CHECK-REPORT-<yyyy-mm-dd>.md`
  (raw command outputs filed alongside it; every factual claim carries
  an evidence-strength label per `.tad/tasks/evidence-collection.md`:
  `recomputed` / `disk-read` / `reported`).
- Changelog entry appended to `.tad/domains/domain-pack-health-changelog.md`.
- COMPLETION per `.tad/templates/completion-report.md` mandatory sections.

## 5. Hard rules

- The archived registry and archived YAML sources are NEVER edited
  (audit trail; retirement ruling 2026-06-11).
- Pack edits are out of scope: a health check reports; repairs go
  through their own handoff + Gate chain.
- A run that finds nothing still files its report and changelog entry —
  "checked, all healthy, numbers attached" is a valid outcome; silence
  is not.
- No claim without an on-disk carrier (claims-need-carriers).

## 6. Acceptance checks (for the Gate 3 reviewer)

- [ ] Report exists and its counts recompute from the filed raw outputs.
- [ ] Mirror check was a hash walk, not a visual diff.
- [ ] Every web candidate carries a source URL and retrieval date.
- [ ] Changelog entry appended (not rewritten); archived files untouched.
- [ ] No pack or registry file was modified by the run itself.
