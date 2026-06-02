# Line-Anchored blockquote to col-0 sed Single-Line CONSUMES PRODUCES

**Date:** 2026-05-31
**Linked to:** L2 shell-portability "Shell Dispatcher Patterns"

---

### Line-Anchored blockquote→col-0 sed Does NOT Fix Single-Line `CONSUMES … PRODUCES` Blockquotes — 2026-05-31
- **Context**: tad-lean-trustworthy-phase2 Step 1b converted blockquote `> **CONSUMES**:`/`> **PRODUCES**:` to col-0 across academic-research, ml-training, video-creation so scan-packs' `^\*\*CONSUMES\*\*:` col-0 grep would index real values. academic-research & ml-training carry CONSUMES and PRODUCES on SEPARATE blockquote lines → both converted cleanly. video-creation carries BOTH on ONE line (`> **CONSUMES**: … **PRODUCES**: …`).
- **Discovery**: A line-anchored `sed 's/^> \*\*CONSUMES\*\*:/.../'` strips the leading `> ` so the line starts col-0 with `**CONSUMES**:` (now matched) — but the `**PRODUCES**:` token sits MID-LINE on that same line, so scan-packs' `grep -m1 '^\*\*PRODUCES\*\*:'` still misses it → produces stays "Not specified". This is NOT a regression when the committed registry already had produces "Not specified" for that pack (video-creation did), but it IS a silent gap: a single-line two-marker blockquote can only ever yield ONE col-0 marker via line-anchored sed. To get BOTH indexed, the markers must be on their own lines (split into two col-0 lines), not just de-blockquoted. The AC2.6 "no-degradation" check (committed vs post-scan `grep -c 'Not specified'`) correctly passed because the count went 2→1 (improved), masking that video-creation's produces is still unindexed.
- **Action**: When converting blockquote pack metadata to col-0 for scan-packs indexing, first check whether CONSUMES and PRODUCES share a line. If so, SPLIT them onto separate col-0 lines (not just strip `> `), or scan-packs will only index the first. For AC verification prefer a per-marker grep (`grep -c '^\*\*PRODUCES\*\*:' CAPABILITY.md` == 1 per pack) over a registry-wide `Not specified` count, which an improvement elsewhere can mask.
- **Grounded in**: .tad/capability-packs/video-creation/CAPABILITY.md:12, .tad/scripts/scan-packs.sh:79-85 (extract_produces), COMPLETION-20260531-tad-lean-trustworthy-phase2.md Step 1b note
