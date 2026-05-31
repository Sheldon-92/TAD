# Backend-Architect Review — release-hygiene-conventions (H1 debt bundle)

- **Reviewer**: backend-architect (post-implementation, Layer 2)
- **Subject**: commit `ae387ef` — "chore(TAD): release-hygiene + conventions debt bundle [YOLO H1]"
- **Spec**: HANDOFF-20260531-release-hygiene-conventions.md (§4.2 version-scheme, §6 files)
- **Method**: Adversarial — all findings derived from `git show ae387ef` blobs and pre-vs-post `diff`, NOT the completion report.
- **Date**: 2026-05-31

---

## 1. Critical findings

None.

Every adversarial probe traced to the committed blob passed. Specifically the four highest-risk axes:

### Version-scheme equality match now resolves "current"
`git show ae387ef:tad.sh` confirms `TARGET_VERSION="2.19.1"` (line 18). `git show ae387ef:.tad/version.txt` = `2.19.1`. In the committed `detect_state()`, the first arm `[[ "$ver" == "$TARGET_VERSION" ]]` is a string-equality compare of `2.19.1` == `2.19.1` → emits `current`. Before the bump (`TARGET_VERSION="2.19"`) this compare was `2.19.1` == `2.19` → false → fell through to the `2.1*` glob → mislabeled an up-to-date install. The fix is internally consistent because the same `$TARGET_VERSION` stamps downstream `version.txt`, so detect and stamp use one source. Verified.

### 4-segment fallback eliminated
Committed `apply_deprecations()` (the no-version.txt branch) reads `current_version="${TARGET_VERSION}"`, not `"${TARGET_VERSION}.0"`. With `TARGET_VERSION="2.19.1"` this yields `2.19.1`, not the malformed 4-segment `2.19.1.0`. The patch segment is already carried by `TARGET_VERSION`. Verified at the actual line in the blob.

### detect_state glob arms untouched (recorded next-bump debt preserved)
`diff` of the full `detect_state()` body pre-commit (`ae387ef^`) vs post-commit (`ae387ef`) returns IDENTICAL. The `2.1*` / `2.2*` / `2.0*` / `1.8*` glob arms are byte-for-byte unchanged. The only delta in `tad.sh` is the three spec-sanctioned edits (line 18 version, line ~171 fallback, the new `*)` default arm). No silent glob-arm rewrite occurred.

### SKILL contract edit is purely additive and downstream of the AR-001 anchor
`diff` of the entire `express_path_protocol:` region (pre vs post) shows the ONLY change is a 19-line `slug_convention` block appended AFTER `required_steps`, `forbidden_implementations`, and `when_NOT_appropriate`. Zero deletions. `NOT_via_alex_suggestion`, `required_steps` (incl. the "step2 expert review with at-least-one expert; code-reviewer mandatory" line), `forbidden_implementations` (incl. the "express = review-exempt is forbidden" item and "MUST NOT auto-downgrade Standard to express" item), and the AR-001 hard-guarantee comment are all intact and unmoved. The new block's own text reaffirms "does NOT relax required_steps" and "audit logic ... MUST NOT be changed." The slug_convention claim was checked against the live `is_express_slug()` in `layer2-audit.sh` (`express|*-express|*-express-*|express-*`) — the documented examples all match and the `bugfix-foo` non-match claim is accurate.

---

## 2. Recommendations

### AR-001 phrase-proximity delta sits just past the doc-comment's "~30 lines" — pre-existing, not introduced here
The `required_steps` comment asserts the "expert review" + "code-reviewer" phrase "must remain ... within ~30 lines following the header." Measured delta in the committed file is 35 lines (header 2133 → phrase 2168). However the pre-commit delta is ALSO 35 — the slug_convention insertion is downstream, so it displaced the phrase by zero lines. AC9's operative wording ("phrase present, not displaced upward") is satisfied. The 35-vs-30 gap is a latent inconsistency in the doc-comment's own self-estimate that predates this commit; worth tightening the comment to "~40 lines" or moving the literal-phrase grep target, but it is out of this handoff's scope and is not a regression.

### blake mirror note is correctly placed but duplicates the rationale prose
The blake/SKILL.md `slug_convention` note is nested in `execution_checklist` after `slug_detection` (downstream of the express AR-001 anchor at lines 1382-1384) — correct placement. It restates the same rationale as alex's block. Acceptable for a mirror note; if these ever drift, the alex block is the declared source of truth (the blake note says "mirrors alex/SKILL.md").

---

## 3. Suggestions

### Document the next-bump glob-arm debt where a future releaser will see it
§6 instructs recording the deferred `detect_state` glob arms in NEXT.md. This review confirms the arms were left untouched as required, but does not verify NEXT.md was updated (out of the 9-file commit scope by design). Confirm the debt note landed somewhere a future MAJOR.MINOR bump will surface it, since `2.19.1` still matches no glob arm should `TARGET_VERSION` later move to e.g. `2.20.0` without arm maintenance.

### Codex header bump vs date preservation worked — keep the dual-rule explicit in runbook
The codex files correctly bumped header `TAD v2.19.0` → `v2.19.1` while preserving `Generated: 2026-05-04`. This "bump version, freeze date" split is subtle; the runbook rows added in this commit (855/632 greeting lines) help, but a one-line note that the line-3 header version bumps while the Generated date is frozen would prevent a future blind-sed regression.

---

## 4. Scope-creep check

`git show ae387ef --stat` = 10 files: the 9 spec-§6 files (`tad.sh`, `README.md`, `INSTALLATION_GUIDE.md`, `tad-help/SKILL.md`, `codex-alex-skill.md`, `codex-blake-skill.md`, `release-runbook/SKILL.md`, `alex/SKILL.md`, `blake/SKILL.md`) + the COMPLETION doc. No out-of-list file was committed. No scope creep.

Supporting AC re-derivations from the committed blob:
- AC1: `grep -c 'TARGET_VERSION="2.19.1"'` = 1; old 2-part full-quote pattern = 0.
- AC2: `tad.sh --bogusflag` → "unknown option" message, exit 1.
- AC3: exactly one `2.19.0` straggler — `README.md:354` (version-history row, preserved). No current-display stragglers.
- AC4: CHANGELOG `[2.19.0]` preserved (count 1); codex `Generated:` date preserved.
- AC5: runbook `855|632` row references = 2.
- AC7: `bash -n` on committed tad.sh = exit 0.
- AC9: express step2 expert-review phrase present, delta unchanged from pre-commit (not displaced upward).

---

## 5. Overall verdict

**PASS**

All four required verification axes (version-scheme equality, 4-segment fallback fix, glob-arm preservation, SKILL contract integrity) confirmed directly against the committed diff. The change is internally consistent, purely additive on the contract side, and the deferred glob-arm debt was correctly left untouched. No P0. The only follow-ups are a pre-existing doc-comment proximity estimate and a NEXT.md confirmation, both non-blocking.

**P0 count: 0**
