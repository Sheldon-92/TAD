# Security Review: LDR POC Phase 1 (Gate 4 Rework Round)

**Reviewer**: Security Auditor (Claude)
**Date**: 2026-07-02
**Scope**: `.mcp.json`, `.tad/evidence/research/ldr-poc/` (all files), secret leakage, MCP config, network binding, data isolation
**Repo visibility**: PUBLIC (GitHub)

---

## Secret / Credential Scan

### Method
1. Regex scan for API key patterns: `sk-ant-`, `sk-or-v1-`, `sk-`, `sk-kimi-`, `Bearer`, `api_key=`, `token=` across `.mcp.json` + all evidence files
2. Keyword scan for `password`, `secret`, `credential`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `DASHSCOPE_API_KEY`, `LDR_API_KEY` (literal values, not env-var references)
3. Manual review of all 4 required files + `ab-corpus.md`, `ab-mapping*.md`, `pip-audit.txt`, `requirements-lock.txt`, `headless-run/q1-mcp-transport.md`
4. Scan of 9 untracked library-round answer files for leaked keys/paths

### Result: NO hardcoded secrets found

- `.mcp.json` line 9: `"LDR_LLM_OPENAI_ENDPOINT_API_KEY": "${LDR_API_KEY}"` -- env-var reference, not literal. PASS.
- `mcp-transcript.md` line 9: documents the env-var reference pattern. PASS.
- `ab-judge-input-manifest-lib.txt`: whitelist of 6 answer files + 5 source files. No mapping file included. PASS.
- `ab-judge-verdict.md` / `ab-judge-verdict-lib.md`: zero occurrences of `nbm`, `NotebookLM`, `Local Deep Research`, `mapping`, or `CONFIDENTIAL`. Blind evaluation integrity confirmed. PASS.
- `POC-REPORT.md` line 118: mentions "Kimi API key invalid" (status note, no actual key value). PASS.
- All 9 untracked `lib-*` and `ldr-lib-*` answer files: zero secret matches. PASS.

---

## Findings

### P2-1: Local Filesystem Paths Disclose macOS Username in Public Repo

**Severity**: P2 (Low)
**CWE**: CWE-200 (Exposure of Sensitive Information to an Unauthorized Actor)
**Location**:
- `.mcp.json` lines 4, 6
- `.tad/evidence/research/ldr-poc/mcp-transcript.md` lines 8, 25
- `.tad/evidence/research/ldr-poc/pip-audit.txt` line 1

**Description**: Five lines across 3 committed files contain absolute paths of the form `/Users/sheldonzhao/...`. Since the repo is public on GitHub, this discloses:
- macOS username: `sheldonzhao`
- Venv location: `~/.tad-ldr-venv/`
- Data directory: `~/.tad-ldr-data/`

**Impact**: Minimal. The username is likely already public via the GitHub profile. The venv/data paths confirm directory structure but are not directly exploitable since both are outside the repo and the LDR web server binds to loopback only.

**Remediation** (optional, not blocking):
- `.mcp.json`: No portable alternative exists for STDIO `command` paths in Claude Code project config. Acceptable as-is. If desired, add `.mcp.json` to `.gitignore` and document setup in README.
- Evidence files: Redact to `~/.tad-ldr-venv/...` in transcript/pip-audit before commit, or accept as informational.

---

### P2-2: Collection UUID and Research ID Committed to Public Repo

**Severity**: P2 (Low)
**Location**:
- `POC-REPORT.md` line 40: `collection_cf98d582-311a-410f-830c-fa08b39f6925`
- `mcp-transcript.md` line 32: Research ID `8604556e-395d-420c-a607-760964faae6a`

**Description**: Two UUIDs from the local LDR instance are committed. These identify a specific collection and research run on the local server.

**Impact**: Negligible. LDR binds to `127.0.0.1` (loopback), so these UUIDs are unreachable from any external network. They are only meaningful while the local LDR server is running, and carry no authentication value.

**Remediation**: None required. Informational only.

---

### P2-3: 14 Known Vulnerabilities in Transitive Dependencies (POC Venv)

**Severity**: P2 (Low -- POC context)
**Location**: `.tad/evidence/research/ldr-poc/pip-audit.txt`

**Description**: `pip-audit` reports 14 known vulnerabilities across 5 packages:
- `pypdf 6.10.2`: 8 CVEs (fix: 6.13.3)
- `lxml 5.4.0`: PYSEC-2026-87 (fix: 6.1.0)
- `requests 2.32.5`: CVE-2026-25645 (fix: 2.33.0)
- `torch 2.10.0`: 2 vulns (PYSEC-2026-139, CVE-2025-3000)
- `nltk 3.9.4`: PYSEC-2026-597 (no fix listed)

**Impact**: Low for a local POC venv that processes only controlled MCP documentation sources. The vulnerabilities are in transitive dependencies pulled by `local-deep-research 1.7.0`, not in project code. The venv is isolated at `~/.tad-ldr-venv/` (not in repo, not deployed).

**Remediation**: Acceptable for POC. If Phase 2 proceeds, pin updated versions via `uv pip install --override` or wait for LDR upstream to bump dependencies.

---

## Positive Findings (PASS)

| Check | Status | Evidence |
|-------|--------|----------|
| No hardcoded API keys | PASS | Regex scan: 0 matches across all files |
| API key uses env-var reference | PASS | `.mcp.json` L9: `${LDR_API_KEY}` |
| MCP transport is STDIO only | PASS | `.mcp.json`: `command` field, no `url` key; `jq` verification in transcript |
| No HTTP/SSE/WebSocket MCP exposure | PASS | `jq -e '[.mcpServers[] \| select(has("url"))] \| length == 0'` = true |
| LDR web host binds to loopback | PASS | `.mcp.json` L12: `LDR_WEB_HOST=127.0.0.1` |
| Data directory outside repo | PASS | `LDR_DATA_DIR=/Users/sheldonzhao/.tad-ldr-data` (not under repo root) |
| A/B blind evaluation integrity | PASS | Judge verdicts contain zero system-identity terms |
| Judge input manifest excludes mapping | PASS | `ab-judge-input-manifest-lib.txt` lists only answer + source files |
| Venv isolated from repo | PASS | `~/.tad-ldr-venv/` is outside repo, not committed |
| No `.env` or credential files committed | PASS | `git ls-files` shows no `.env`, `credentials.*`, or key files |

---

## Verdict

**CONDITIONAL PASS**

Condition: P2-1 (local path disclosure) should be acknowledged as accepted risk before pushing to the public remote. All 3 P2 findings are low-severity and appropriate for a local POC that will not be deployed.

No P0 or P1 findings. The implementation correctly follows defense-in-depth:
1. Secrets via env-var reference (not hardcoded)
2. STDIO transport (no network-exposed MCP server)
3. Loopback binding for LDR web interface
4. Data directory outside repo
5. Blind evaluation integrity maintained
