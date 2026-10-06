# Embedded-Copy Drift Check: Reconstruct Authoritative Set From Lib

**Date:** 2026-06-01
**Linked to:** L1 "Deny-List Beats Allow-List for Sync Sets"

---

### Embedded-Copy Drift Check: Reconstruct the Authoritative Set From the Lib, Compare as a SORTED SET — 2026-06-01
- **Context**: tad.sh P2 must INLINE derive-sync-set.sh's DENY_LIST (curl|bash on a fresh machine can't `source` a lib that isn't installed yet). Two copies of the same constant → drift risk (arch P1-3). Added `tad.sh --verify-denylist` (repo-only, run at release).
- **Discovery**: The drift check must NOT re-hardcode the lib's list a third time (that just adds another copy to drift). Instead it RECONSTRUCTS the lib's authoritative set by extracting the `ZERO_TOUCH="..."` + `TRANSIENT="..."` multi-line quoted blocks from the lib file via `awk` (open-quote → close-quote range), unions them, and compares as `LC_ALL=C sort -u` SETS (order-independent). On mismatch it prints `comm -23` / `comm -13` to name exactly which entries are only-in-tad.sh vs only-in-lib. Verified: in-sync → exit 0 (12 entries); flip one entry in a temp copy → exit 1 naming both sides. This keeps the LIB the single source of truth even for the drift check itself — tad.sh's inlined copy is validated AGAINST the lib, never the reverse.
- **Action**: When a constant must be embedded in a second file (no-source constraint), make the drift check derive the canonical value from the ORIGINAL (parse the lib), compare as sorted sets with `LC_ALL=C`, and on failure emit a two-sided `comm` diff. Never give the check its own third hardcoded copy. Gate the check on "release touches either file" and document it as a HARD BLOCK in the pre-flight.
- **Grounded in**: tad.sh verify_denylist_drift (awk-extract ZERO_TOUCH+TRANSIENT from derive-sync-set.sh, comm -23/-13), .tad/hooks/lib/derive-sync-set.sh, COMPLETION-20260601-self-deriving-release-sync-phase2.md drift dogfood
