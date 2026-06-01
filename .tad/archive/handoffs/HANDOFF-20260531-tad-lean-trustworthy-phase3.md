---
# Quality Chain Metadata
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# HANDOFF: P3 Progressive Disclosure (OPTION A — token-free path protocols)

**From:** Alex (YOLO Conductor) | **To:** Blake | **Date:** 2026-05-31
**Epic:** EPIC-20260531-tad-lean-trustworthy.md (Phase 3/5)
**Scope decision (user):** OPTION A — extract ONLY the 9 constraint-token-FREE protocol blocks. Do NOT touch
research_plan / express / experiment (they carry constraint tokens; reframing AC3.2 was declined).

## 1. Task Overview
Move 9 mutually-exclusive, intent/command-gated protocol blocks out of `.claude/skills/alex/SKILL.md` into
on-demand `.claude/skills/alex/references/*.md` files, replacing each with a thin pointer stub + a load
instruction. Goal: reduce always-loaded body 6441 → ~5786 lines (~10%) with ZERO semantic change and ZERO
constraint-rule movement (all 9 blocks are constraint-token-free — verified).

## 3. Requirements
- BYTE-PRESERVE every extracted block (the reference file body == the original block, byte-for-byte).
- The always-loaded `MUST NOT|VIOLATION|MANDATORY|forbidden_implementations|NOT_via_alex_auto` count MUST stay
  **131** (these 9 blocks contain 0 such tokens, so any change = a mistake).
- Every place that dispatched to one of these protocols must now instruct: "Read the reference, then follow it."
- Do NOT touch research_plan_protocol (1086-1809), express_path_protocol (2133-2222), experiment_path_protocol
  (2223-2335), or any other block. ONLY the 9 listed.

## 6. Implementation Steps

### Blocks to extract (verified line ranges + 0 constraint tokens each)
| block (YAML key) | start-end | reference file |
|---|---|---|
| bug_path_protocol | 754-837 | references/bug-path-protocol.md |
| discuss_path_protocol | 838-975 | references/discuss-path-protocol.md |
| update_roadmap_protocol | 976-1012 | references/update-roadmap-protocol.md |
| status_panoramic_protocol | 1013-1085 | references/status-panoramic-protocol.md |
| research_review_protocol | 1810-1886 | references/research-review-protocol.md |
| idea_path_protocol | 1887-1938 | references/idea-path-protocol.md |
| idea_list_protocol | 1939-1984 | references/idea-list-protocol.md |
| idea_promote_protocol | 1985-2035 | references/idea-promote-protocol.md |
| learn_path_protocol | 2036-2132 | references/learn-path-protocol.md |

⚠️ Extract in DESCENDING line order (learn first, bug last) so earlier edits don't shift later line numbers.
⚠️ research_plan_protocol (1086-1809) sits BETWEEN status_panoramic (ends 1085) and research_review (starts
   1810) and is NOT extracted — it stays inline. So the extraction is NOT one contiguous slice; do each block
   individually by its YAML-key boundaries (key at col 0 to the line before the next col-0 key).

### Per-block procedure
For each block (top-level YAML key at col 0, body = until the line before the next col-0 key):
1. Copy the FULL block (key line + body) byte-for-byte into its reference file. Prepend a 1-line header comment
   `<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->`
   then a blank line, then the verbatim block. (The header is OUTSIDE the byte-identity check — see AC3.4 which
   diffs only the block body, not the header.)
2. In alex/SKILL.md, REPLACE the block body with a stub (keep the same top-level key so existing references resolve):
   ```
   {block_key}:
     # Extracted P3 progressive disclosure — full protocol in the reference below.
     reference: ".claude/skills/alex/references/{file}.md"
     load_when: "When this protocol is entered (see intent_router_protocol step4 / the *{command}), Read the reference and follow it verbatim."
   ```
3. The 9 blocks contain 0 constraint tokens, so no inline constraint summary is needed (unlike express/experiment).

### Router / dispatch wiring
- `intent_router_protocol` step4 (line ~607 area) currently routes bug/discuss/idea/learn → "Enter {x}_path_protocol".
  Add ONE general note in step4: "Entering any *_path_protocol whose body is a `reference:` stub means: Read that
  reference file first, then follow it."
- The command bindings for *idea-list / *idea-promote / *status / *research-review / *discuss-exit-update-roadmap
  already point at their protocol keys; the stub's `load_when` covers them. No other rewiring needed.

## 7. Files
- CREATE: `.claude/skills/alex/references/{9 files above}.md`
- MODIFY: `.claude/skills/alex/SKILL.md` (9 blocks → stubs + 1 router note)
- **Grounded Against:** alex/SKILL.md top-level key map (read by Conductor 2026-05-31); per-block token counts
  (phase3-grounding-CONFLICT.md). references/ dir convention exists (.tad/references/, .claude/skills/*/references/).

## 9. Acceptance Criteria
- [ ] **AC3.1' (reframed)**: always-loaded `wc -l .claude/skills/alex/SKILL.md` reduced from 6441 to ≤5850 (≈655 lines moved minus stub lines added). Report exact number.
- [ ] **AC3.2 (SAFETY, byte-identity of constraints)**: `grep -cE 'MUST NOT|VIOLATION|MANDATORY|forbidden_implementations|NOT_via_alex_auto' .claude/skills/alex/SKILL.md` == **131** (UNCHANGED). Paste before+after.
- [ ] **AC3.2b (AR registry intact)**: the `anti_rationalization_registry` awk-extract is byte-identical before/after (it is NOT in the extracted range, so must be untouched): `awk '/^<!-- anti_rationalization_registry:BEGIN -->$/{f=1;next}/^<!-- anti_rationalization_registry:END -->$/{f=0}f' SKILL.md | md5` same before/after.
- [ ] **AC3.4 (byte-identity of moves)**: for EACH of the 9 blocks, `diff <(git show HEAD:.claude/skills/alex/SKILL.md | sed -n '{start},{end}p') <(tail -n +3 references/{file}.md)` == empty (reference body after the 2 header lines == original block). Paste the 9 diffs (all empty).
- [ ] **AC3.5 (untouched blocks)**: research_plan_protocol / express_path_protocol / experiment_path_protocol bodies are byte-identical before/after (verify each still present with full body, NOT stubbed): `grep -c 'forbidden_implementations' SKILL.md` unchanged for the express/experiment regions.
- [ ] **AC3.6 (dispatch wiring)**: each of the 9 stubs has a `reference:` + `load_when:` line; intent_router step4 has the general "Read the reference" note. `grep -c 'reference: ".claude/skills/alex/references/' SKILL.md` == 9.
- [ ] **AC3.7 (no orphan)**: `bash -c 'for f in bug-path discuss-path update-roadmap status-panoramic research-review idea-path idea-list idea-promote learn-path; do test -f .claude/skills/alex/references/$f-protocol.md || echo MISSING $f; done'` — wait, filenames vary; just verify all 9 reference files exist and are non-empty.

## 10. Important Notes
- ⚠️ SAFETY: this edits alex's OWN protocol file. The 9 blocks are constraint-token-FREE BY MEASUREMENT — if the
  before/after constraint count is NOT 131, STOP (you touched a constraint block). Option A's whole safety rests on
  moving only 0-token blocks.
- Descending-order extraction to avoid line-shift.
- Do NOT reformat or "improve" any extracted content — byte-identical move only (v2.7 quality-chain lesson: this is
  exactly the slimming that must NOT alter content).
- Anti-self-trigger: references contain protocol text; none is a §11 Decision Summary table, so no parser impact.

## 11. Decision Summary
| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | P3 scope under AC conflict | OPTION A: token-free blocks only (~10%) | User chose A; avoids reframing SAFETY AC3.2; move only 0-token blocks so byte-identity trivially holds |
| 2 | extraction order | descending line order | earlier edits would shift later line numbers; descending keeps ranges valid |
| 3 | constraint-bearing blocks (research_plan/express/experiment) | leave INLINE | they carry forbidden_implementations/VIOLATION; moving them needs the declined AC3.2 reframe |

## Required Evidence Manifest
```yaml
required_evidence:
  completion_report:
    path: ".tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase3.md"
    must_contain:
      - "before+after wc -l of SKILL.md"
      - "before+after constraint-token grep -c (both == 131)"
      - "AR registry md5 before==after"
      - "9 empty diffs (reference body == original block)"
      - "express/experiment forbidden_implementations count unchanged"
      - "grep -c reference-stub == 9"
    gate3_verdict: "frontmatter marker: pass|fail|partial"
```
