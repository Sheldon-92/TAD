---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/hooks/lib"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-07-14
**Project:** TAD Framework
**Task ID:** TASK-20260714-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260714-dependency-evolution-awareness.md (Phase 2/3)

---

## Gate 2: Design Completeness

**Execution time**: 2026-07-14

### Gate 2 Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Scan script + scan-results schema + cron prompt + *deps check command |
| Components Specified | ✅ | deps-scan.sh, scan-results.yaml schema, cron-prompt.md, Alex SKILL command |
| Functions Verified | ✅ | gh api, npm view, pip index — all verified available on this machine |
| Data Flow Mapped | ✅ | REGISTRY.yaml → deps-scan.sh → scan-results.yaml; cron triggers scan |

**Gate 2 Result**: ✅ PASS

**Alex Confirmation**: I have verified all design elements. Blake can independently complete implementation based on this document.

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections
- [ ] Read Project Knowledge section for historical lessons
- [ ] All mandatory questions have evidence
- [ ] Understand the true intent (not just literal requirements)
- [ ] Each deliverable and evidence requirement is clear
- [ ] Can independently complete implementation using this document

---

## 1. Task Overview

### 1.1 Title
Dependency Evolution Awareness — Phase 2: Upstream Scan

### 1.2 Background
Phase 1 created a rich dependency registry (`.tad/dependencies/REGISTRY.yaml`) with 6 TAD dependencies. Phase 2 builds the scanning mechanism that checks upstream sources (GitHub Releases, npm, PyPI) for each registered dependency and caches the raw results. The LLM relevance assessment is deliberately deferred to Phase 3 — this phase only collects raw data.

### 1.3 Intent Statement
Enable TAD to automatically discover when registered dependencies have new versions, changelogs, or security advisories. The scan script runs as a weekly scheduled task (session cron) and writes raw upstream data to a cache file that Phase 3 will read and analyze at Alex startup.

**Key design decision**: The scan script does NOT invoke LLM for relevance assessment. It collects raw data only (version, date, changelog text). LLM judgment happens in Phase 3 when Alex reads the results in a conversation context where LLM is naturally available.

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: Scan Script (`deps-scan.sh`)**

A bash script that:
1. Reads `.tad/dependencies/REGISTRY.yaml` (or `$REGISTRY_PATH` if set — for testability)
2. **Input validation (SECURITY)**: Before using any REGISTRY field in a shell command, validate:
   ```bash
   # name: alphanumeric + hyphen + dot + slash + @ (for scoped npm)
   [[ "$name" =~ ^[a-zA-Z0-9@/_.-]+$ ]] || { log_warning "Invalid name: $name"; continue; }
   # repo: owner/repo format only
   [[ "$repo" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]] || { log_warning "Invalid repo: $repo"; continue; }
   ```
   Reject any value containing shell metacharacters (`;`, `$()`, backticks, `|`, `&&`).
3. For each dependency, queries upstream based on `upstream.registry` field:
   - `github_releases`: `gh api repos/{upstream.repo}/releases/latest --jq '.tag_name, .published_at, .body'`
   - `npm`: `npm view {name} version` + `npm view {name} time.modified`
   - `pypi` (curl primary, no pip dependency): `curl -s "https://pypi.org/pypi/${name}/json" | jq '.info.version, .releases | to_entries | sort_by(.key) | last | .value[0].upload_time_iso_8601'`
   - `homebrew`: For **version**: `brew info --json=v2 {name} | jq '.formulae[0].versions.stable'`. For **release date + changelog**: if `upstream.repo` is set, ALSO query GitHub Releases API (same as github_releases handler). Homebrew alone doesn't provide release date or changelog text.
   - `null` or unrecognized: write `scan_status: skipped` with `skip_reason: "no upstream registry configured"`. **Expected behavior for TAD dogfood**: 3/6 deps (notebooklm-cli, rsync, claude-code-cli) currently have `registry: null` and will be skipped — this is acceptable for Phase 2. Blake MAY enrich these entries (e.g., claude-code-cli → npm registry `@anthropic-ai/claude-code`) but is not required to.
4. For GitHub-hosted dependencies, also check for security advisories (best-effort, skip on API error):
   ```bash
   gh api graphql \
     -F eco="$ecosystem" \
     -F pkg="$name" \
     -f query='query($eco:SecurityAdvisoryEcosystem,$pkg:String!){
       securityVulnerabilities(first:5, ecosystem:$eco, package:$pkg) {
         nodes { advisory { summary severity } }
       }
     }'
   ```
   Use `gh api graphql -F` for parameterized variables — NEVER interpolate values into the query string.
5. Computes `days_since_release = (today - release_date)` for each
6. Writes all results to `.tad/dependencies/scan-results.yaml` using **Option A ONLY** (build JSON → convert to YAML via jq/yq). Option B (heredoc templating) is **FORBIDDEN** for any field containing upstream-sourced text (changelog, error messages) due to YAML injection risk.
7. **Error message sanitization**: Before writing error_message to scan-results, truncate to 200 chars and strip patterns matching `token=`, `ghp_`, `gho_`, `Authorization:` to prevent auth token leakage into git-tracked files.
8. Exits 0 on success (even if individual deps fail — log warnings, continue)

**FR2: Scan Results Schema (`scan-results.yaml`)**

```yaml
version: 1.0.0
last_scan: YYYY-MM-DD
scan_duration_seconds: N
scanner_version: "1.0.0"

results:
  - dependency: "<name>"               # Join key to REGISTRY.yaml
    scan_status: success | skipped | error
    error_message: null                 # If scan_status == error
    upstream_latest: "<version>"
    released: "YYYY-MM-DD"
    days_since_release: N
    changelog_text: |                   # Raw changelog/release notes (truncated to 2000 chars)
      <raw text from GitHub release body or npm changelog>
    security_advisories:               # Empty list if none found
      - summary: "<advisory summary>"
        severity: "CRITICAL | HIGH | MEDIUM | LOW"
    current_version: "<from REGISTRY>"  # Snapshot for comparison
    version_changed: true | false       # upstream_latest != current_version
```

**FR3: `*deps check` Command**

Alex SKILL command that:
1. Runs `bash .tad/hooks/lib/deps-scan.sh` immediately (bypasses cron schedule)
2. Reads the generated scan-results.yaml
3. Displays a summary table:
   ```
   📦 Upstream Scan Results (6 dependencies, 2026-07-14)

   | Dependency | Current | Latest | Released | Days | Changed | Security |
   |-----------|---------|--------|----------|------|---------|----------|
   | notebooklm-cli | 0.5.2 | 0.6.1 | 2026-07-10 | 4 | ✅ Yes | None |
   | gh | 2.78.0 | 2.78.0 | 2026-07-01 | 13 | — | None |
   ```
4. If any `security_advisories` exist, highlight with warning
5. Raw changelog available via follow-up: "要看某个依赖的 changelog 吗？"

**FR4: Scheduled Task (Session Cron)**

Follow the GitHub Registry scan pattern:
1. Create `.tad/evidence/spikes/cron-deps-scan/cron-prompt.md` — the prompt file for re-registering the cron
2. Cron schedule: weekly (e.g., Sunday 23:30, offset from GitHub scan at 23:07)
3. The cron prompt should invoke `bash .tad/hooks/lib/deps-scan.sh`
4. Session-bound — dies with the session, re-register from prompt file when needed
5. Alex STEP 3.9 already has a staleness warning pattern — Phase 3 will add a similar one for deps scan

**FR5: Changelog Truncation**

Raw changelog text is truncated to 2000 characters per dependency to keep scan-results.yaml manageable. If truncated, append `\n[... truncated, full text at {changelog_url}]`.

### 2.2 Non-Functional Requirements

- Scan completes within 60 seconds for ≤20 dependencies (sequential API calls, ~3s each max)
- Script must work on macOS (BSD tools, no GNU-only flags)
- Script must handle network errors gracefully (skip failing deps, continue)
- scan-results.yaml must be valid YAML parseable by yq
- No Claude CLI dependency — pure bash + gh + npm/pip + jq/yq

---

## 3. Design Summary

### Architecture
```
deps-scan.sh (bash)
  ├─ Read REGISTRY.yaml (yq)
  ├─ For each dependency:
  │   ├─ Dispatch by upstream.registry type
  │   ├─ Query upstream API (gh/npm/pip/brew/curl)
  │   ├─ Extract: version, date, changelog, security
  │   ├─ Compare version vs current_version
  │   └─ Append to results array
  └─ Write scan-results.yaml (yq or heredoc)

Cron (session-bound)
  └─ weekly: bash deps-scan.sh

*deps check (Alex SKILL)
  ├─ bash deps-scan.sh
  ├─ Read scan-results.yaml
  └─ Display summary table
```

### Data Flow
```
REGISTRY.yaml ──→ deps-scan.sh ──→ scan-results.yaml
   (P1 input)        (P2)            (P2 output, P3 input)
```

---

## 4. Implementation Guidance

### 4.1 Shell Portability
Per project knowledge (shell-portability.md):
- No `grep -P` (use `grep -o` + `sed` on macOS)
- Use `jq` for JSON API responses, `yq` for YAML
- Single awk process for multi-field extraction
- Portable timeout: `gtimeout` → `timeout` → no-op fallback
- `set -euo pipefail` for the script

### 4.2 API Authentication
- GitHub: `gh api` uses existing `gh auth` — no extra setup needed
- npm: `npm view` is unauthenticated (public registry)
- PyPI: `curl` to JSON API is unauthenticated
- Homebrew: `brew info` is local (no auth)

### 4.3 Error Handling Strategy
```bash
for dep in deps; do
  result=$(query_upstream "$dep") || {
    log_warning "Failed to scan $dep: $?"
    write_error_result "$dep"
    continue  # Don't fail entire scan
  }
  write_success_result "$dep" "$result"
done
```

### 4.4 Writing scan-results.yaml
**Option A is REQUIRED** — build results as JSON array, convert to YAML at the end (`jq → yq`).
Option B (heredoc templating) is **FORBIDDEN** for any field containing upstream-sourced text (changelog_text, error_message). Upstream release bodies can contain arbitrary YAML control characters (`---`, `: `, `- `, `#`) that would corrupt the output file or inject fake entries. `jq` properly escapes all special characters when building JSON strings.

### 4.5 Alex SKILL Changes
Add `*deps-check` (hyphenated, matching existing `*deps-init`/`*deps-add` pattern) to:
- `commands:` section: `deps-check: "Run upstream scan immediately and display results"`
- `explicit_commands` array: add `"*deps-check"`
- `route_targets` mapping: `deps-check: deps_check_protocol`

Protocol goes in the existing `deps-protocol.md` reference file (append a new section).
Add `load_when`: `"When *deps-check is invoked, Read the reference for the check flow."`

### 4.6 Cron Prompt File
Follow the pattern from `.tad/evidence/spikes/cron-github-scan-2026-07/cron-prompt.md`:
```markdown
# Deps Scan Cron Prompt
Schedule: weekly, Sunday 23:30
Command: bash .tad/hooks/lib/deps-scan.sh
Re-register: /schedule create with this prompt
```

---

## 5. Scope

### 5.1 In Scope
- `deps-scan.sh` bash script (GitHub/npm/PyPI/Homebrew support)
- `scan-results.yaml` schema and output
- `*deps check` Alex command
- Session cron setup + cron prompt file
- Security advisory check (best-effort)

### 5.2 Out of Scope
- LLM relevance assessment (Phase 3)
- Alex startup integration (Phase 3)
- Safety buffer computation (Phase 3)
- Known limitation resolution detection (Phase 3)
- `*deps update` command (Phase 3)

---

## 6. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `.tad/hooks/lib/deps-scan.sh` | CREATE | Upstream scanning script |
| `.tad/dependencies/scan-results.yaml` | CREATE (by script) | Cached scan output |
| `.claude/skills/alex/SKILL.md` | MODIFY | Add *deps-check command + route |
| `.claude/skills/alex/references/deps-protocol.md` | MODIFY | Add deps_check section |
| `.tad/evidence/spikes/cron-deps-scan/cron-prompt.md` | CREATE | Cron re-registration prompt |

---

## 7. Testing Checklist

- [ ] `deps-scan.sh` runs without error on TAD's 6 registered dependencies
- [ ] scan-results.yaml is produced and valid YAML
- [ ] Each result has: dependency, scan_status, upstream_latest, released, days_since_release
- [ ] At least 1 dependency shows version_changed: true or false (version comparison works)
- [ ] A non-existent dependency (injected for test) produces scan_status: error, not a script crash
- [ ] Changelog text is present for at least 1 GitHub-hosted dependency
- [ ] `*deps check` triggers the scan and displays results
- [ ] Scan completes within 60 seconds

---

## 8. Additional Metadata

### 8.1 Priority
Medium — builds on Phase 1, enables Phase 3

### 8.2 Estimated Effort
Medium — bash scripting + API integration + YAML output

### 8.3 Risk Assessment
- API rate limits: low risk (6 deps << 5000/h GitHub limit)
- Network dependency: scan gracefully handles offline/timeout
- PyPI API format: verify `pip index versions` works on current pip version; fallback to curl

### 8.4 Friction Preflight
- `gh` CLI required (already installed, verified in P1 dogfood)
- `npm` required for npm-type deps (may not be installed if no Node project — handle as skip)
- `pip` or `curl` for PyPI deps
- `brew` for homebrew deps (macOS standard)
- Friction Status: READY (all tools already available on this machine)

### 8.5 Feedback Collection
- feedback_required: false (infrastructure script, not UI)

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|-------------------|-------------------|
| AC1 | deps-scan.sh exists and is executable | `test -x .tad/hooks/lib/deps-scan.sh && echo OK` | OK |
| AC2 | Script reads REGISTRY.yaml | `grep -c 'REGISTRY.yaml\|registry' .tad/hooks/lib/deps-scan.sh` | ≥2 |
| AC3 | Script handles github_releases type | `grep -c 'gh api\|github_releases' .tad/hooks/lib/deps-scan.sh` | ≥1 |
| AC4 | Script handles npm type | `grep -c 'npm view\|npm' .tad/hooks/lib/deps-scan.sh` | ≥1 |
| AC5 | scan-results.yaml produced after scan | `bash .tad/hooks/lib/deps-scan.sh && yq '.last_scan' .tad/dependencies/scan-results.yaml` | Today's date |
| AC6 | Results contain required fields | `yq '.results[0] \| keys' .tad/dependencies/scan-results.yaml` | Lists: dependency, scan_status, upstream_latest, released, days_since_release, changelog_text, security_advisories, current_version, version_changed |
| AC7 | Error handling: bad dep doesn't crash | `yq '.dependencies += [{"name":"nonexistent-xyz","upstream":{"registry":"npm"}}]' .tad/dependencies/REGISTRY.yaml > /tmp/test-reg.yaml && REGISTRY_PATH=/tmp/test-reg.yaml bash .tad/hooks/lib/deps-scan.sh; echo $?` | Exit 0 (not crash) |
| AC8 | *deps-check command in SKILL (hyphenated) | `grep -c 'deps-check\|deps_check_protocol' .claude/skills/alex/SKILL.md` | ≥2 |
| AC9 | Cron prompt file exists | `test -f .tad/evidence/spikes/cron-deps-scan/cron-prompt.md && echo OK` | OK |
| AC10 | Scan ≤60s for TAD's 6 deps | `time bash .tad/hooks/lib/deps-scan.sh 2>&1 \| grep real` | Under 1m0s |
| AC11 | Change scope as planned | `git diff --stat` | Only §6 files changed |

---

## 10. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/deps-upstream-scan/spec-compliance.md
  - .tad/evidence/reviews/blake/deps-upstream-scan/code-review.md
gate_verdicts:
  - .tad/evidence/reviews/blake/deps-upstream-scan/gate3-report.md
completion:
  - .tad/active/handoffs/COMPLETION-20260714-deps-upstream-scan.md
blake_reviews: []
knowledge_updates: []
```

---

## 11. Decision Summary

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| D1 | Scan collects raw data only, no LLM | Scan runs in cron (no Claude context). LLM assessment deferred to Phase 3 where Alex has natural LLM access | LLM in scan via `claude -p` (rejected: adds Claude CLI dependency to a bash script) |
| D2 | Session cron + re-register prompt | Same proven pattern as GitHub Registry scan. Durable cron not yet supported by CLI | Durable cron (not available), pure manual (too easy to forget) |
| D3 | Changelog truncated to 2000 chars | Keeps scan-results.yaml manageable. Full text available via changelog_url | No truncation (rejected: large changelogs bloat YAML), no changelog (rejected: Phase 3 needs it for relevance) |
| D4 | Sequential API calls, not parallel | Simpler, respects rate limits, 6 deps × ~3s = ~18s total | Parallel (rejected: complexity for minimal gain at this scale) |
| D5 | REGISTRY_PATH env var for testability | AC7 needs to inject a bad dep without modifying the real registry | Temp file copy (alternative, Blake can choose) |

---

## Project Knowledge

### Blake must note these historical lessons:

- **Shell Portability Rules** (patterns/shell-portability.md) — No `grep -P`, use `jq` for JSON, single awk for multi-field. Portable timeout chain: `gtimeout` → `timeout` → no-op.
- **Double-Parse Pattern for String-Encoded JSON** (patterns/shell-portability.md) — If changelog text contains embedded JSON, use single-pass `jq` with `fromjson`, never two-step pipeline.
- **yq -i Normalizes Whole File** (patterns/shell-portability.md) — If using yq -i to write scan-results.yaml, expect first-write normalization. Consider building JSON then converting, or use Write tool.
- **Deny-List: scan-results.yaml is in .tad/dependencies/ which is already ZERO_TOUCH** (Phase 1 established) — no additional sync exclusion needed for this file.

---

## Message to Blake

📨 **Blake Implementation Task**

| Field | Value |
|-------|-------|
| **Task** | Dependency Evolution Awareness — Phase 2: Upstream Scan |
| **Handoff** | `.tad/active/handoffs/HANDOFF-20260714-deps-upstream-scan.md` |
| **Epic** | EPIC-20260714-dependency-evolution-awareness.md (Phase 2/3) |
| **Priority** | Medium |
| **Scope** | deps-scan.sh + scan-results.yaml + *deps check + session cron |
| **Key Files** | `.tad/hooks/lib/deps-scan.sh` (CREATE), `.tad/dependencies/scan-results.yaml` (CREATE by script), `.claude/skills/alex/SKILL.md` (MODIFY), cron-prompt.md (CREATE) |
| **Critical** | Script must NOT depend on Claude CLI — pure bash + gh/npm/pip + jq/yq. Error handling: individual dep failures skip, don't crash. Changelog truncated to 2000 chars. |
