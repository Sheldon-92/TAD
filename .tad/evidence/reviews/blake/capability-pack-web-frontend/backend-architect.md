# Architecture Review — Web Frontend Capability Pack

**Reviewer**: backend-architect sub-agent
**Date**: 2026-05-08
**Verdict**: GO with P0 fixes (now resolved)

## P0 Findings (All Resolved)

- P0-1: Lighthouse INP/TBT silent fallback → FIXED: dynamic label + disclosure in both script and rule
- P0-2: axe CLI `--reporter=json` invalid flag → FIXED: removed, `--save` alone is correct; stderr captured for diagnostics
- P0-3: bundle-check.sh scans server bundles (Next.js false positives) → FIXED: auto-detects client bundle path (.next/static/chunks, dist/assets, build/static/js)
- P0-4: `bc` precision bug → FIXED: using `printf '%.1f'` with `bc -l` instead
- P0-5: `context` keyword too broad in Step 1 → FIXED: changed to "react context / context api"
- P0-6: Disambiguation rule contradictory → FIXED: loads first match + announces other matches for user confirmation

## P1 Findings (Unresolved — documented for v1.1)

- P1-1: Style Dictionary Tailwind citation too generic (styledictionary.com generic page)
- P1-2: RSC 20% threshold invented — no industry source
- P1-3: DTCG types undercounted (says 5, spec has many more)
- P1-4: TanStack Query "replaces Redux" citation could be stronger
- P1-5: WebAIM Million 2024 stats may be stale
- P1-6: Testing pyramid 60/30/10 from 2015 — Testing Trophy is 2019 view
- P1-7: State management "AI-amplified" research finding has no external citation
- P1-8: install.sh overwrite doesn't rm -rf before copy (hybrid state risk)
- P1-9: install.sh missing YAML frontmatter pre-flight check
- P1-10: CLS toFixed(3) truncation → FIXED (changed to toFixed(4))
- P1-11: frontend-quality.md hardcodes Next.js App Router path

## Strengths
- CAPABILITY.md Step 0 DESIGN.md detection: 3 extraction modes (CSS props/DTCG JSON/Tailwind) - well-designed
- YAML frontmatter present (passes load-bearing check)
- Phase N stub pattern in install.sh correct (exit 2 + future target documented)
- LICENSE-ATTRIBUTION.md comprehensive
- Cross-pack contract with web-ui-design clear and enforced
- 3-tier checklist framing matches frontend reality
