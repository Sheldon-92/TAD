# Gate 2 review — KEEP11 Knife 1 (security-auditor substitute)

**Date:** 2026-09-11  
**Handoff:** `.tad/active/handoffs/HANDOFF-20260911-keep11-knife1-cli-refresh.md`  
**Reviewer:** generalPurpose as security-auditor (`EQUIVALENT_SUBSTITUTE` — native `security-auditor` spawn failed: Opus usage limit)

Model: harness=other | model=inherit/cursor-grok | route=host

## 1. Critical Issues (P0)

**P0: 0**

Handoff does not instruct secret dump, production DAST, invented SHAs, or `@v4` as the recommended pin.

## 2. P1 (binding procedure — integrated into handoff §3 / §8.4)

- Dry-run denylist was example-based → closed: only `--help`/`--version`/`-h`
- ABSENT + docs URL not AC-enforced → AC1 min-date + AC8 ABSENT/http
- AC4 CI6-only → three-tree CI6; SHA re-pin still via find-action-sha (AC3)

## 3. P2

- Prefer docs-pin over brew/pip install of scanners on the TAD host
- Gitleaks banner shape is the template; `protect`/`detect` only in the warning
- CI11 “migrate to v4-line, SHA-pin” if that sentence is touched

## 4. Overall Assessment

**CONDITIONAL PASS**. No P0. P1-1/P1-2 treated as binding in the revised §3/§8.4.
