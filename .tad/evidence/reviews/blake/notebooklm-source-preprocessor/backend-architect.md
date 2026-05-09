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
