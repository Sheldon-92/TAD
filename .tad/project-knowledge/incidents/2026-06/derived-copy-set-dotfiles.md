# A Derived Copy-Set Loop Must Copy DOTFILES

**Date:** 2026-06-01
**Linked to:** L1 "Deny-List Must Be Applied at EVERY Copy Granularity"

---

### A Derived Copy-Set Loop Must Copy DOTFILES, and a Completeness Self-Check Will Catch the Gap — 2026-06-01
- **Context**: tad.sh P2 (self-deriving installer). Replaced the hardcoded 14-dir `copy_framework_files()` loop with a deny-list derivation, and added a post-install `verify_install_complete()` that asserts every derived framework dir is present + non-empty. First dogfood FAILED on `.tad/context/` — a dir whose ONLY content is `.gitkeep`.
- **Discovery**: The copy used `cp -r "$src/.tad/$dir/"* "$dst/"`. A bare `*` glob does NOT expand to dotfiles (no `shopt dotglob`/`setopt globdot`), so a dir containing only `.gitkeep` (or any dotfile-only dir) copies to an EMPTY target → the completeness self-check correctly flags it as MISSING/EMPTY. The old hardcoded list never hit this because `context` wasn't in it; deny-list derivation now includes EVERY live dir, surfacing the dotfile gap. Fix: `cp -R "$src/.tad/$dir/." "$dst/"` — the trailing `/.` copies dir CONTENTS including dotfiles, BSD/macOS-safe with no shell-option dependency. The self-check earned its keep: it caught a real copy bug during dogfood rather than letting a silently-empty dir ship.
- **Action**: When copying directory CONTENTS in a portable installer, use `cp -R src/.  dst/` (trailing `/.`), never `cp -r src/* dst/` — the latter drops dotfiles (`.gitkeep`, `.env.example`). When you broaden a copy-set from a curated allow-list to a derive-everything deny-list, expect dotfile-only / edge-case dirs to surface; pair the broadened copy with a present+non-empty self-check so an empty-target copy bug FAILS the install instead of shipping silently.
- **Grounded in**: tad.sh copy_framework_files (cp -R src/. dst/) + verify_install_complete, COMPLETION-20260601-self-deriving-release-sync-phase2.md AC4(a)
