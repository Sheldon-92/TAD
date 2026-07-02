
# HANDOFF: notebooklm-source-preprocessor

---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/research-notebook", ".tad/cross-model"]
skip_knowledge_assessment: no
gate4_delta: []
---

---

## §9.1 Spec Compliance Checklist (excerpt)
### 9.1 Spec Compliance Checklist

| # | AC | Verification Method | Expected Evidence |
|---|-----|--------------------|--------------------|
| AC1 | `add-smart` command exists in SKILL.md | `grep -c "add-smart" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC2 | source-preprocessor.sh exists and is executable | `test -x .tad/cross-model/source-preprocessor.sh` | exit 0 |
| AC3 | 4 handler scripts exist | `ls .tad/cross-model/handlers/*.sh \| wc -l` | 4 |
| AC4 | X handler reads API key from correct path | `grep -c "openclaw/workspace/data/twitterapi.key" .tad/cross-model/handlers/x-handler.sh` | ≥1 |
| AC5 | Bilibili handler uses yt-dlp | `grep -c "yt-dlp" .tad/cross-model/handlers/bilibili-handler.sh` | ≥1 |
| AC6 | Quality verification probe implemented | `grep -c "verify_import_quality\|EMPTY" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC7 | Preprocessed files saved to .research/preprocessed/ | `grep -c "preprocessed" .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC8 | 30s timeout enforced on handlers | `grep -c "timeout 30\|timeout_seconds" .tad/cross-model/source-preprocessor.sh` | ≥1 |
| AC9 | Metadata header in preprocessed .md | `grep -c "source:\|original_url:\|extracted_at:" .tad/cross-model/handlers/x-handler.sh` | ≥3 |
| AC10 | All handler scripts have #!/usr/bin/env bash | All 4 handlers + preprocessor start with shebang | 5 files |
| AC11 | URL type detection works (functional) | `echo 'https://x.com/user/status/12345' \| bash .tad/cross-model/source-preprocessor.sh detect` | Output: `x_tweet` |
| AC12 | URL validation rejects metacharacters | `echo 'https://evil.com/$(whoami)' \| bash .tad/cross-model/source-preprocessor.sh validate` | exit 1 |
| AC13 | Handler contract: exit 0 produces .md, exit 10 produces URL | `bash .tad/cross-model/handlers/scholar-handler.sh arxiv 'https://arxiv.org/abs/2401.13178' /tmp/test-out` | exit 10 + stdout contains arxiv.org/pdf |
| AC14 | Quality probe uses structured QUALITY: prefix | `grep -c 'QUALITY:HIGH\|QUALITY:LOW\|QUALITY:NONE' .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC15 | Verification wait is ≥30s (not 3s) | `grep -E '(sleep 30\|Wait 30\|30s)' .claude/skills/research-notebook/SKILL.md` | ≥1 |
| AC16 | `-n` flag used for all source add calls (not `use`) | `grep -c 'source add.*-n' .claude/skills/research-notebook/SKILL.md` | ≥1 in add-smart section |

### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: URL injection in curl | §4.2 validate_url() + §4.3 all handlers use `--` before URL | Resolved |
| code-reviewer | P0-2: x_thread undefined | §4.1 removed x_thread, handled inside x_tweet §4.3 | Resolved |
| code-reviewer | P0-3: URL patterns are pseudocode | §4.2 rewritten as shell `case` + extraction regexes | Resolved |
| code-reviewer | P0-4: Quality probe 3s wait + fragile | §4.4 rewritten: 30s wait + structured QUALITY: prefix | Resolved |
| code-reviewer | P1-1: Handler contract underspecified | §4.3 "Handler Interface Contract" block added | Resolved |
| code-reviewer | P1-3: API key file not checked | §4.3 x-handler.sh preflight added | Resolved |
| code-reviewer | P1-4: `use` vs `-n` inconsistency | §4.1 router uses `-n` everywhere | Resolved |
| code-reviewer | P1-5: No functional ACs | AC11-AC16 added | Resolved |
| code-reviewer | P1-6: handlers/ path couples to cross-model | Deferred — .tad/cross-model/ is acceptable for v1 | Open (P2) |
| backend-architect | P0-1: 3s wait duplicates ingest | §4.4 rewritten: 30s wait, reuse ingest timing | Resolved |
| backend-architect | P0-2: generic fallback no recovery | §4.1b try_direct_then_jina with delete+retry | Resolved |
| backend-architect | P0-3: Handler output polymorphic | §4.3 Handler Interface Contract: exit 0 vs exit 10 | Resolved |
| backend-architect | P0-4: x_thread referenced not defined | §4.1 removed, §4.3 x_tweet handles threads internally | Resolved |
| backend-architect | P1-2: Jina rate limits | §4.3 jina-handler.sh HTTP 429 handling added | Resolved |
| backend-architect | P1-4: No URL normalization | §4.2 normalize_url() function added | Resolved |
| backend-architect | P1-5: research-plan step4 scope unclear | §7 Task 6 clarified: add-smart for new URLs only | Deferred (Blake judgment) |
| backend-architect | P1-6: /tmp cleanup not specified | §4.3 bilibili-handler.sh step 9 cleanup added | Resolved |

---

## 10. Important Notes

---

## §6 Implementation Steps (head)
## 6. Files to Modify / Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.claude/skills/research-notebook/SKILL.md` | MODIFY | Add `add-smart` command section (~80 lines) |
| 2 | `.tad/cross-model/source-preprocessor.sh` | CREATE | Core preprocessing script with URL detection + handlers |
| 3 | `.tad/cross-model/handlers/x-handler.sh` | CREATE | X/Twitter content extraction via twitterapi.io |
| 4 | `.tad/cross-model/handlers/bilibili-handler.sh` | CREATE | Bilibili subtitle extraction via yt-dlp |
| 5 | `.tad/cross-model/handlers/scholar-handler.sh` | CREATE | Academic paper PDF discovery via Semantic Scholar API |
| 6 | `.tad/cross-model/handlers/jina-handler.sh` | CREATE | Generic content extraction via Jina Reader |

**Grounded Against** (Alex step1c):
- .claude/skills/research-notebook/SKILL.md (head 180, read at 2026-05-09)
- .tad/cross-model/ (directory exists — contains setup-notebooklm.sh, codex files)

---

## 7. Implementation Details

---

## §9.2 Expert Review Audit Trail
### 9.2 Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: URL injection in curl | §4.2 validate_url() + §4.3 all handlers use `--` before URL | Resolved |
| code-reviewer | P0-2: x_thread undefined | §4.1 removed x_thread, handled inside x_tweet §4.3 | Resolved |
| code-reviewer | P0-3: URL patterns are pseudocode | §4.2 rewritten as shell `case` + extraction regexes | Resolved |
| code-reviewer | P0-4: Quality probe 3s wait + fragile | §4.4 rewritten: 30s wait + structured QUALITY: prefix | Resolved |
| code-reviewer | P1-1: Handler contract underspecified | §4.3 "Handler Interface Contract" block added | Resolved |
| code-reviewer | P1-3: API key file not checked | §4.3 x-handler.sh preflight added | Resolved |
| code-reviewer | P1-4: `use` vs `-n` inconsistency | §4.1 router uses `-n` everywhere | Resolved |
| code-reviewer | P1-5: No functional ACs | AC11-AC16 added | Resolved |
| code-reviewer | P1-6: handlers/ path couples to cross-model | Deferred — .tad/cross-model/ is acceptable for v1 | Open (P2) |
| backend-architect | P0-1: 3s wait duplicates ingest | §4.4 rewritten: 30s wait, reuse ingest timing | Resolved |
| backend-architect | P0-2: generic fallback no recovery | §4.1b try_direct_then_jina with delete+retry | Resolved |
| backend-architect | P0-3: Handler output polymorphic | §4.3 Handler Interface Contract: exit 0 vs exit 10 | Resolved |
| backend-architect | P0-4: x_thread referenced not defined | §4.1 removed, §4.3 x_tweet handles threads internally | Resolved |
| backend-architect | P1-2: Jina rate limits | §4.3 jina-handler.sh HTTP 429 handling added | Resolved |
| backend-architect | P1-4: No URL normalization | §4.2 normalize_url() function added | Resolved |
| backend-architect | P1-5: research-plan step4 scope unclear | §7 Task 6 clarified: add-smart for new URLs only | Deferred (Blake judgment) |
| backend-architect | P1-6: /tmp cleanup not specified | §4.3 bilibili-handler.sh step 9 cleanup added | Resolved |

---

## 10. Important Notes

---


# COMPLETION: notebooklm-source-preprocessor

# Completion Report — TASK-20260509-001

**Handoff**: HANDOFF-20260509-notebooklm-source-preprocessor.md  
**Date**: 2026-05-09  
**Git Commit**: cce7306  
**Status**: Gate 3 PASS

---

## What Was Delivered

| Item | Delivered |
|------|-----------|
| `*research-notebook add-smart` command in SKILL.md | ✅ |
| `source-preprocessor.sh` core router | ✅ |
| `x-handler.sh` (twitterapi.io article/tweet) | ✅ |
| `bilibili-handler.sh` (yt-dlp subtitles) | ✅ |
| `scholar-handler.sh` (arXiv PDF + Semantic Scholar) | ✅ |
| `jina-handler.sh` (Jina Reader generic fallback) | ✅ |
| `verify_import_quality` HELPER in SKILL.md | ✅ |

## Acceptance Criteria

| AC | Description | Result |
|----|-------------|--------|
| AC1 | add-smart in SKILL.md | ✅ PASS (2 occurrences) |
| AC2 | source-preprocessor.sh executable | ✅ PASS |
| AC3 | 4 handler scripts | ✅ PASS |
| AC4 | API key path in x-handler.sh | ✅ PASS |
| AC5 | yt-dlp in bilibili-handler.sh | ✅ PASS |
| AC6 | verify_import_quality in SKILL.md | ✅ PASS |
| AC7 | preprocessed path in SKILL.md | ✅ PASS |
| AC8 | timeout 30 enforcement | ✅ PASS |
| AC9 | metadata header fields in x-handler.sh | ✅ PASS (6 occurrences) |
| AC10 | shebang in all 5 files | ✅ PASS |
| AC11 | x_tweet detection (functional) | ✅ PASS |
| AC12 | validate rejects metacharacters | ✅ PASS |
| AC13 | scholar-handler arxiv exit 10 + PDF URL | ✅ PASS |
| AC14 | QUALITY: prefix labels in SKILL.md | ✅ PASS |
| AC15 | 30s wait in SKILL.md | ✅ PASS |
| AC16 | source add -n in add-smart section | ✅ PASS |

**All 16 ACs: PASS**

## Key Implementation Decisions

| # | Decision | Context | Chosen | Escalated? |
|---|----------|---------|--------|------------|
| 1 | timeout portability | macOS has no `timeout` (GNU coreutils) | run_with_timeout() with gtimeout/timeout/no-op detection | No — self-caught in code-reviewer Round 1 |
| 2 | UTM normalization approach | `sed -E s/utm_*//g` silently corrupts leading utm params | tr-split per-param + `grep -v '^utm_'` + rejoin | No — caught in backend-architect review |
| 3 | Source ID identification | `.[-1]` unreliable → potential data deletion | set-difference via `comm -13` on ids_before/ids_after | No — caught in backend-architect review |
| 4 | research-plan step4 update | Handoff §7 Task 6 deferred per backend-architect P1-5 | Deferred — generic_web URLs already take direct path | No — per handoff §9.2 decision |

## Deviations from Handoff

- **research-plan step4 update deferred**: Backend-architect confirmed this is P1-5 (advisory deferred). GitHub source URLs (generic_web type) use direct `source add` path anyway — add-smart provides no benefit here.
- **Step numbering in add-smart command**: Added Steps 3, 5 (source ID capture and set-diff) not in original handoff §7, required by BA-P0-1 fix.

## Evidence Files

- `.tad/evidence/reviews/blake/notebooklm-source-preprocessor/code-reviewer.md`
- `.tad/evidence/reviews/blake/notebooklm-source-preprocessor/backend-architect.md`
- `.tad/evidence/completions/notebooklm-source-preprocessor/GATE3-REPORT.md`
- `.tad/evidence/acceptance-tests/notebooklm-source-preprocessor/ac-verification.sh`

---

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Category**: architecture (CLI tool integration patterns)

**Summary**: Shell dispatcher with `set -e` propagates non-zero handler exit codes (exit 10) correctly through case statement arms — no explicit exit needed. The `run_with_timeout()` pattern (detect gtimeout/timeout/no-op) is the standard portable wrapper for GNU coreutils tools on macOS. Set-difference via `comm -13 <(sorted_before) <(sorted_after)` is the reliable pattern for identifying newly-added items in any append-only list (applies to any NotebookLM CLI output that doesn't guarantee insertion order). UTM tracking param normalization should use per-param `tr '&' '\n' | grep -v '^utm_'` not bulk regex — bulk regex silently corrupts `?utm_first&real=param` shape.

---

## Gate 3: ✅ PASS

---


# REVIEW: backend-architect.md

# Backend Architecture Review — TASK-20260509-001 NotebookLM Source Preprocessor Pipeline

**Reviewer**: backend-architect sub-agent  
**Date**: 2026-05-09  
**Status**: PASS (Round 2 — all P0s resolved)

## Findings

| Severity | ID | Description | Status |
|----------|-----|-------------|--------|
| P0 | BA-P0-1 | `.[-1]` source identification unreliable → potential silent data deletion | ✅ Fixed: set-diff pattern (ids_before/ids_after + comm -13) in SKILL Step 3→5 |
| P0 | BA-P0-2 | UTM normalize regex corrupts URLs where utm_* is first query param | ✅ Fixed: tr-split per-param approach replaces fragile sed regex |
| P0 | BA-P0-3 | Missing `*)` default arm in dispatch case → silent exit 0 with empty stdout | ✅ Fixed: explicit `*) exit 1` arm added with error message |
| P1 | BA-P1-1 | delete-before-Jina lacks failure guard → partial state on delete error | ✅ Fixed: del_exit guard added to SKILL Step 6 Jina fallback |
| P1 | BA-P1-2 | metadata.yaml has no schema, no creation protocol, no concurrency story | ✅ Fixed: explicit schema + yq append + v1 single-writer constraint documented |
| P1 | BA-P1-3 | verify_import_quality no retry when status=preparing (could take ~90s) | ✅ Fixed: 60s retry loop added to HELPER (aligns with ingest command pattern) |
| P1 | BA-P1-4 | x-handler thread detection doesn't tag thread presence in metadata | Advisory — thread_status field added in review recommendation |
| P2 | BA-P2-1 | validate_url rejects too-narrow set of unsafe chars | Advisory |
| P2 | BA-P2-2 | Bilibili "unknown" BV id uses full md5 hash (cosmetic) | Fixed as part of CR-P1-3 |
| P2 | BA-P2-3-5 | Various advisory hardening items | Noted for v1.1 |

## Architecture Assessment

Handler contract (exit 0/1/2/10) is sound and well-implemented. set -e + exit 10 propagation verified correct. jq @uri is semantically equivalent to Python urllib.parse.quote. Cross-file blast radius: clean — no consumers of new files outside the implementation itself.

## Round 2 Verdict

All P0s resolved. P1-1/P1-2/P1-3 fixed. P1-4 advisory (cosmetic metadata field).

**Overall**: PASS — P0=0, P1=1 (advisory), P2=0

---


# REVIEW: code-reviewer.md

# Code Review — TASK-20260509-001 NotebookLM Source Preprocessor Pipeline

**Reviewer**: code-reviewer sub-agent  
**Date**: 2026-05-09  
**Status**: PASS (Round 2 — all P0s resolved)

## Round 1 Findings

| Severity | ID | Description | Status |
|----------|-----|-------------|--------|
| P0 | CR-P0-1 | `timeout` unavailable on stock macOS → dispatch exits 127 silently | ✅ Fixed: gtimeout/timeout/fallback detection via run_with_timeout() |
| P0 | CR-P0-2 | SKILL Step 3 ignores exit codes outside 0/1/2/10 (127, 124) | ✅ Fixed: else branch added to SKILL dispatch block |
| P0 | CR-P0-3 | Python `-c "...${query}..."` interpolation risk in scholar-handler.sh | ✅ Fixed: switched to `printf '%s' | jq -sRr '@uri'` |
| P1 | CR-P1-1 | UTM regex `s/[?&]utm_*//g` corrupts URLs with utm_source as first param | ✅ Fixed: tr-split per-param + grep -v '^utm_' approach (later superseded by BA-P0-2) |
| P1 | CR-P1-2 | Jina fallback calls jina-handler.sh directly bypassing URL validation | Advisory noted — URL already validated in Step 2, low immediate risk |
| P1 | CR-P1-3 | bilibili md5 truncation incorrect (full 32-char hash, not 8-char) | ✅ Fixed: awk '{print substr($1,1,8)}' |
| P1 | CR-P1-4 | API key trailing newline included in HTTP header | ✅ Fixed: `tr -d '\r\n' < "$KEY_FILE"` |
| P2 | CR-P2-1 | BSD sed `\|` alternation not supported for slug trim | ✅ Fixed: separate sed passes + parameter expansion |

## Round 2 Verdict

All P0 findings resolved. P1s addressed except P1-2 (advisory, low risk). P2s addressed.

**Overall**: PASS — P0=0, P1=1 (advisory), P2=0

---


# REVIEW: test-runner.md

# Test Runner Review — TASK-20260509-001 NotebookLM Source Preprocessor Pipeline

**Reviewer**: test-runner sub-agent  
**Date**: 2026-05-09  
**Status**: PASS (post P0-1 fix)

## Test Suite Summary

**Original ACs (1-16)**: 21/21 PASS  
**Extended tests (17-20)**: 20/20 PASS  
**Total**: 41/41 PASS

## Findings

| Severity | ID | Description | Status |
|----------|-----|-------------|--------|
| P0 | TR-P0-1 | curl `--` before `-H` in x-handler.sh — `-H` treated as URL arg, exit 3 | ✅ Fixed: moved all 3 `-H` flags before `--` |
| P0 | TR-P0-2 | dispatch subcommand untested (10 routing branches uncovered) | ✅ Fixed: AC19a-c added (arxiv_pdf, generic_web, invalid URL) |
| P0 | TR-P0-3 | Only 1 of 10 detect types tested (AC11 was x_tweet only) | ✅ Fixed: AC17a-j test all 10 types |
| P1 | TR-P1-1 | URL normalization untested (utm strip, twitter/bilibili rewrites) | ✅ Fixed: AC18a-d added |
| P1 | TR-P1-2 | dep-missing exit 2 contract not tested for any handler | ✅ Fixed: AC20 tests x-handler missing key → exit 2 (not exit 3) |

## Verified Exit Code Contracts

| Path | Expected Exit | Test | Result |
|------|---------------|------|--------|
| dispatch arxiv_pdf | 10 | AC19a | ✅ PASS |
| dispatch generic_web | 10 | AC19b | ✅ PASS |
| dispatch invalid URL | 1 | AC19c | ✅ PASS |
| scholar-handler arxiv | 10 | AC13 | ✅ PASS |
| x-handler missing key | 2 | AC20 | ✅ PASS |

## Test Coverage Assessment

- **URL type detection**: 10/10 types covered (AC17a-j)
- **URL normalization**: 4/4 cases covered (AC18a-d: twitter, mobile.twitter, m.bilibili, utm strip)
- **Dispatch routing**: 3 paths (arxiv_pdf, generic_web, invalid) — substack/medium/x require real API keys
- **Handler contracts**: scholar arxiv (exit 10 + PDF URL) verified; x/bilibili/jina require external deps
- **Security**: validate_url rejects `$(whoami)` metacharacters (AC12)

## Overall Verdict: PASS

P0 defects fixed. 41/41 tests pass. Coverage is appropriate for a shell pipeline without external API dependencies.

---

