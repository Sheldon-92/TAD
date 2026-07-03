# EPHEMERAL Epic: Fix detect_state Glob-Arm Hazard

**Type:** Ephemeral (surplus burn, single-phase)
**Source:** SURPLUS-PLAN (task #8/9 across plans)
**Created:** 2026-07-02

## Goal

Prevent `detect_state()` in `tad.sh` from misclassifying 3-part semver versions (e.g., `2.19.x` matching a `2.1*` glob) when cross-major migration case arms are added for v2.x routing. The current v1.x case arms (`1.8*`, `1.6*|1.5*`, `1.4*`) use prefix globs that would exhibit the same ambiguity if replicated for v2.x (e.g., `2.1*` matches both `2.1.0` and `2.19.1`). The `_tad_ver_cmp` function handles same-major correctly, but the cross-major case arms need glob-safe patterns preemptively.

## Scope

- **In scope:** `tad.sh` `detect_state()` function (lines ~1343-1373) — audit existing v1.x glob arms for the same hazard, fix if present, and ensure the pattern style is safe for future v2.x arms.
- **Out of scope:** Migration engine, version bump logic, `_tad_ver_cmp` (already handles 3-part correctly).

## Phase 1 (only phase)

| Step | Description |
|------|-------------|
| 1 | Audit `detect_state` case arms for prefix-glob ambiguity |
| 2 | Fix glob patterns to use dot-delimited matching (e.g., `1.8.*` not `1.8*`) |
| 3 | Verify `_tad_ver_cmp` handles edge cases (2.19.1 vs 2.2.0) correctly |
| 4 | Run tad.sh self-check (`--verify-denylist` or equivalent) |

## Exit Criteria

- No glob pattern in `detect_state` can match a version from a different minor series
- Existing self-checks pass
