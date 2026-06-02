# Phase 2 Gate Report (YOLO) — tad.sh Installer Self-Derivation

**Verdict: Gate 3+4 PASS** (Conductor independently re-verified). 2026-06-01.
Commits: f053f50 (impl) + de952b5 (epic) + a24a166 (P1-fix: top-level deny-list + diff self-check).

## Conductor re-run (anti-theater)
| Check | Result |
|-------|--------|
| bash -n tad.sh + lib | clean ✅ |
| `--verify-denylist` drift check | exit 0, "12 entries match" ✅ (I ran it; flipped negative → exit 1 per reviewers) |
| top-level files deny-list (killed `*.yaml *.md *.txt` allow-list) | `derive_framework_top_files` + `TAD_TOP_DENY`=sync-registry only → portable-extract.sh (.sh) now installs ✅ |
| copy-set derived (not 14-dir hardcode) | `derive_framework_dirs` → codex auto-included ✅ |
| diff self-check (not just presence) | `diff -rq src vs target` per dir → catches partial copies ✅ |
| version-from-source | derive_target_version from src/.tad/version.txt + fallback ✅ |
| lib `--transient` flag (drift-check via public interface) | checklists reports spike-v3 working ✅ |

## Review
2 impl reviewers: cr PASS (0 P0), arch CONDITIONAL PASS (0 P0). Both independently re-ran the drift-check
+ install dogfood (not theater). arch caught the load-bearing P1: the disease survived at the TOP-LEVEL
FILE extension-glob (dropped portable-extract.sh) → FIXED (a24a166). Mid-dogfood Blake caught a real
dotfile bug (context/ dropped) → fixed cp -R src/.

## Honest residual (P3-tier follow-up, recorded)
P1's `release-verify.sh structural` diffs dirs + .claude/skills only — does NOT yet cover top-level .tad/
files. tad.sh's own self-check now DOES cover them, so the installer path is closed; the sync-side
structural gate's top-level coverage is a small follow-up (not a P0, sync copies top-level via the deny-list
derivation already; the gap is only in the post-sync VERIFICATION of top-level files).
