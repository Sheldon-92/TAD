# Design: OCR K1–K5 optional paste into upstream TAD

**Date:** 2026-09-14  
**Channel:** Cursor · `cursor-grok-4.6-medium`  
**Role:** Alex · `*analyze` → Gate2-ready handoff (no Blake this session)  
**Research:** `.tad/evidence/research/2026-09-14-alibaba-open-code-review.md` (PARTIAL OK)

## Human lock (2026-09-14)

KEEP all K1–K5 as **optional paste habits**.  
REJECT: OCR CLI/npm; `rule.json` / language md as SSOT; replacing Gate 2/3/Layer 2; AACR-Bench as TAD KPI.  
Do **not** add gates. Do **not** import Alibaba tooling. Do **not** absorb into v2.44.5.

## Why two carriers (docs + template)

- **SSOT paste home:** `docs/process-tax-cut.md` (user prefer; existing three paste sections).  
- **`tad.sh` does not copy `docs/`.** `.tad/project-knowledge/` is **zero-touch** (knowledge-seam). Downstream agents will not see `docs/` or `patterns/` on a clean install.  
- **Nearest install-visible guide already citing tax-cut:** `.tad/templates/output-formats/spec-compliance-format.md` (copied with `.tad/templates/`).  
- **This-repo agent route:** `.tad/project-knowledge/patterns/process-tax-cut.md` already duplicates §1–§3 paste; add §4 the same way so `_index` loaders see K1–K5 without opening `docs/`. If this file and the guide drift, **docs win**.

## Exact paste (Blake copies byte-identical into the three files)

Use this fenced body (inside the markdown fence in the target files). Do not add a fourth “skip review” checklist. Do not retitle K1–K5 into gates.

```
### Optional Layer 2 review habits (OCR thin borrow, copy)

Status: optional paste. Not a Gate. Not a substitute for Gate 2 dual disk reviews or Alex ≠ Blake.

- K1 Asymmetric-bound, falsify-only second pass. A later look at the same delta sees less evidence (diff + claimed findings only). Veto only when the diff directly contradicts the claim. Do not mint new findings on this pass. Parse/format failure → fail-open (keep the finding).
- K2 Precision over recall as Layer 2 default. Prefer fewer P0/P1 with replayable evidence (path + command/hunk). Comment volume is not quality. Do not lower recall on security-auditor when that Group 2 trigger fired (see K5).
- K3 Dispatch is the pathspec, not agent whim. Review handoff §7 / allowed files only. Do not expand the file set like a free agent. Do not add a rule.json or language-md rule engine.
- K4 Claims must be localizable or labeled unanchored. Every finding cites path + command/hunk, or is labeled unanchored / extra-file. Do not treat model line numbers as SSOT.
- K5 Recall-up is opt-in for high-risk deltas. Extra budget is the existing security-auditor Group 2 trigger — not a named Ultra Gate and not an extra Ralph round by default.

Forbidden in this paste: OCR CLI or npm; replacing Gate 2 / Gate 3 / Layer 2; AACR-Bench as a TAD KPI; Alibaba language rule packs as SSOT.
```

## File ops

1. `docs/process-tax-cut.md` — after §3 fence, before `## What this does **not** change`, insert `## 4) Optional Layer 2 review habits (OCR thin borrow)` + intro sentence + the fence. Amend “What this does not change” with one bullet: optional K1–K5 paste is not a new Gate. Header “paste the three blocks” → “paste the blocks”.  
2. `.tad/project-knowledge/patterns/process-tax-cut.md` — after §3 fence, add matching `## 4)` + same fence. Keep header “SSOT for the three paste blocks” → change to “SSOT for the paste blocks”.  
3. `.tad/templates/output-formats/spec-compliance-format.md` — after the dirty-tree section, add `## Optional Layer 2 review habits (OCR thin borrow)` + one line `SSOT: docs/process-tax-cut.md §4; if drift, docs win.` + the same fence. K1 is Layer 2 only (do not use as Gate 2 “no new findings” protocol).

## Out of scope

`tad.sh`, `principles.md`, alex/blake SKILL, capability-packs, `gate-canonical-checklist.md`, v2.44.5 handoff, NEXT/PROJECT_CONTEXT riders in Blake’s commit, OCR Go/npm, AACR-Bench harness.
