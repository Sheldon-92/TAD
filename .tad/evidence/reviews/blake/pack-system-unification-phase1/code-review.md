# Code Review: Pack System Unification Phase 1 — Domain Pack Retirement

**Reviewer**: code-reviewer (independent)
**Commit**: 0d965bb
**Date**: 2026-06-11
**Scope**: 56 files changed, -514/+357 lines

---

## Summary

Phase 1 retires YAML Domain Packs as an active runtime mechanism. The core work is clean: startup-health injection removed, post-write-sync domain handler removed, portable-extract updated, sync derivation updated, protocols rewritten from Domain Pack to Capability Pack language, archive + T2 references created, deprecation.yaml entry added.

The implementation is well-executed for its primary scope. Three orphaned identifier references survive the rename, and the migration manifest (handoff FR4/AC7 preferred path) was skipped without explicit documentation in the completion artifacts.

---

## P0 — Blocking

None.

---

## P1 — Should Fix

### P1-1: Orphaned `domain_pack_awareness` identifier in discuss-path-protocol.md (both platforms)

**File**: `.claude/skills/alex/references/discuss-path-protocol.md` line 50
**Mirror**: `.agents/skills/alex/references/discuss-path-protocol.md` line 50

The block header was correctly renamed from `domain_pack_awareness` to `capability_pack_awareness` (line 26), but the `research_notebook_awareness` action text still reads:

```
⚠️ 以下步骤在 domain_pack_awareness 之后、首次回答之前执行。
```

This should read `capability_pack_awareness` to match the renamed block. An agent loading this protocol may fail to resolve the cross-reference.

### P1-2: Orphaned `domain_pack_auto_load` identifiers in experiment-path-protocol.md (both platforms)

**File**: `.claude/skills/alex/references/experiment-path-protocol.md` lines 51, 107
**Mirror**: `.agents/skills/alex/references/experiment-path-protocol.md` lines 51, 107

The top-level key was renamed to `capability_pack_auto_load` (line 30), but two internal references still use the old name:

- Line 51: `"step1 explicit Read of .claude/skills/ai-evaluation/SKILL.md (per domain_pack_auto_load)"`
- Line 107: `"Loaded explicitly via domain_pack_auto_load (above) at protocol entry."`

These should reference `capability_pack_auto_load`.

### P1-3: Orphaned `domain_pack_awareness` in research-notebook/SKILL.md (both platforms)

**File**: `.claude/skills/research-notebook/SKILL.md` line 24
**Mirror**: `.agents/skills/research-notebook/SKILL.md` line 24

```
- Skip Alex-specific protocols (Socratic, handoff, Gate, domain_pack_awareness)
```

This parenthetical list still uses the old identifier. Should read `capability_pack_awareness`.

### P1-4: Missing migration manifest (handoff FR4 / AC7 preferred path)

The handoff (section 4.2 "Migration/deprecation path") specified that the preferred path was a migration manifest entry (`delete: [{path: ".tad/domains", type: "dir"}]`), with `deprecation.yaml` as explicit fallback. The implementation went directly to `deprecation.yaml` (which works), but no migration manifest was created in `.tad/migrations/`. The `git diff --name-only` confirms no migration file was touched.

AC7 passes because it uses `rg -n "domain-pack-retirement" .tad/deprecation.yaml .tad/migrations 2>/dev/null` with an OR across both locations, and deprecation.yaml satisfies it. However, the completion report should document why the migration manifest was skipped (e.g., migration engine doesn't support directory-level deletion, or deprecation.yaml was judged sufficient).

---

## P2 — Nice to Have

### P2-1: `post-write-sync.sh` research path lost its trace emission

The `*.tad/active/research/*` case branch previously called `record_trace "domain_pack_step"` before `output_empty`. The Domain Pack trace type was correctly retired, but the branch now emits no trace at all for research file writes. This is likely fine (research trace was Domain Pack-specific), but if research file tracking is still desired independently, a neutral trace type could replace it.

### P2-2: `trace-step.sh` parameter name `$DOMAIN` is a vestige

The script's second positional argument is still named `DOMAIN` (line 14: `DOMAIN="$2"`), and the JSON fields still use `"domain"` as the key. Since the comment now says "Capability Pack execution," the parameter/field name could be updated to something more generic (e.g., `PACK` or `CONTEXT`), though this would require updating any existing consumers of the JSONL schema. Not blocking.

### P2-3: `derive-sync-set.sh` comment count unchanged

The header comment on line 48 says `14 dirs` in the deny-list, which was correct before adding `domains` (10 zero-touch + 4 transient = 14). After adding `domains`, the count is now 15 (10 + 5). The comment should read `15 dirs`.

Line 48 currently says:
```
# DENY_LIST = category-A (zero-touch, 10) + category-C (transient/main-only, 4) = 14 dirs.
```

Should be:
```
# DENY_LIST = category-A (zero-touch, 10) + category-C (transient/main-only, 5) = 15 dirs.
```

### P2-4: README.md historical release notes preserve "Domain Pack" references

Lines 311, 325, 327 in README.md still contain "Domain Pack" in historical version descriptions (v2.19.0, v2.8.2, v2.8.0). This is correct behavior per handoff section 8.3 ("Historical release notes should remain"), but AC5's sweep pattern `Domain Pack Loading|Domain Pack References` may flag them if re-run with broader scope. The anchor-map correctly classifies README historical entries, so this is just a note for future awareness.

### P2-5: `domains` in TRANSIENT vs ZERO_TOUCH classification

Adding `domains` to TRANSIENT (category C = "transient/main-only, do NOT sync") is the correct classification for an archived directory that only exists in the source repo. ZERO_TOUCH would be wrong because ZERO_TOUCH means "preserve target's own copy" (implying the target has its own version), whereas TRANSIENT means "main-only, don't copy at all." Since downstream projects should DELETE their `.tad/domains/` (per deprecation.yaml), TRANSIENT is the right choice. No action needed; this is a confirmation.

---

## Positive Observations

1. **Archive structure is thorough**: The dated archive directory with README manifest, T2 skill-library references with what-to-reuse/what-not-to-reuse sections, and deprecation.yaml entry form a complete archival chain.

2. **Claude/Codex parity maintained**: All 11 `.claude/skills/` changes have matching `.agents/skills/` counterparts. The anchor-map explicitly tracks parity per file.

3. **Startup-health removal is clean**: The 47-line Domain Pack detection block was removed without leaving dangling variables. The `SUMMARY` build on line 50 no longer references `DOMAIN_DETAIL`.

4. **Post-write-sync removal is surgical**: Only the `*.tad/domains/*.yaml` case branch and the `domain_pack_step` trace call were removed. Adjacent branches are untouched.

5. **Deprecation.yaml entry is well-structured**: Lists all 13 individual files for downstream deletion, includes a clear note about the replacement.

6. **Blast radius is controlled**: No files outside the handoff section 7 scope were modified (verified by comparing `git diff --name-only` against section 7.1/7.2 lists). The `codex-tad-bundle` was already clean from v2.26.0 deprecation.

7. **Anchor-map is comprehensive**: 45 rows covering every reference with classification, action, rationale, and AC mapping.

---

## Verdict

**CONDITIONAL PASS** — 4 P1 issues. P1-1 through P1-3 are straightforward identifier renames (6 lines across 6 files). P1-4 requires either creating a migration manifest or documenting the fallback decision. After P1 resolution, this implementation is ready for Gate 3.
