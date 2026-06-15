# Phase 4 Grounding — Sinks + Multi-Format (FINAL)

Spec: HANDOFF-20260614-ai-reading-companion-phase4-sinks-multiformat.md (Gate 2 PASS; code-reviewer + backend-architect P0/P1 integrated).

## Load-bearing (Gate 2 — fail these = Gate 3 FAIL)
1. **Schema-match**: every adapter emits content.json byte-compatible with epub-ingest — incl. paragraph `tag` (plan-gen splits heading/body on it!) + chapter `href`/`title`. AC1 = key-set shape-diff vs epub across ALL 4 adapters.
2. **Determinism**: adapters = pure functions of input bytes (same bytes → identical source_hash + pid map). ONE shared normalize+hash+write helper imported by all (don't re-implement). AC5 = re-ingest twice byte-identical.
3. **Fail-loud / ≥1 chapter**: empty TXT / extraction-empty URL / image-only PDF / no-pdftotext → non-zero exit + reason, NO content.json. Never a silent empty book.
4. **URL security**: reuse epub SKIP_TAGS + nav/footer/aside; html escaped+whitelist (no stored XSS); timeout + size cap + Content-Type=text/html + http(s)-only + no SSRF/internal-redirect.
5. **PDF**: subprocess.run([...], shell=False) to pdftotext; `\f` page-split ladder; image-only/no-text → BLOCKED.
6. **FR4 export-notes**: plan.md `## Questions` parse + thread user-`?` turns; group by anchor pid's chapter + "General" bucket.
7. stdlib-only (subprocess ONLY in pdf-ingest). Reuse render/plan/bridge UNCHANGED.

## Conductor will independently verify: AC1 shape-diff (all 4), AC5 determinism, AC3b XSS-strip, AC4c image-PDF fail-loud, AC2b tag, render-through, AC8 subprocess hygiene. Real render of a TXT/MD book in browser optional.
