# Blake Layer 2 Final Independent Review: codex-wiring-stopbleed

Handoff: `.tad/active/handoffs/HANDOFF-20260803-codex-wiring-stopbleed.md`
Review scope: current diff and the two previously reported P1 fixes only. No product file was modified by this review.

## Verdict

**PASS** — P0 = 0 · P1 = 0 · P2 = 0

## Evidence

- **Parity fail-closed:** `.tad/hooks/lib/release-verify.sh:543-567` scans every `.agents/skills/**/*.md` declaration anchored as `^[[:space:]]*reference:` and containing `.claude/`; the expression is independent of quoting, so double-quoted, single-quoted, and bare values all fail. The check is before the byte-parity early exit. The equal-tree `--fix` path checks before returning, and the divergent `claude-newer` path checks after `rsync` at lines 679-682.
- **AC-06 mutation probe:** the current script injects double-quoted, single-quoted, and bare declarations into both trees, asserts exit 1 plus the specialized `platform-coupled reference path` message, then checks the single-tree byte-parity failure. An isolated scratch execution returned `AC6_RC=0`; pre/post md5 values matched and no injected declaration remained after the trap restore.
- **`--fix` order:** an isolated git scratch with a Claude-only bad bare declaration selected `DIRECTION: claude-newer`, performed `rsync Claude→Codex`, then returned the specialized failure and `parity FIX-FAIL`; both scratch trees contained the bad declaration at that point. This confirms the post-rsync safety check and avoids a pre-rsync deadlock.
- **AC-07:** `AC-07-ledger-delta.sh` returned `AC7 PASS`; alpha was `21/21 PASS`, beta blocked only the pre-registered `ask_user_question_hook`, and the shipped ledger md5 was unchanged by the fixture.
- **`codex_cloud` provenance:** `.tad/runtime-compat/codex.md:31` now contains the official URL `https://developers.openai.com/codex/cloud/` with `retrieved 2026-08-03`; a live read-only check returned HTTP 200 (effective official page: `https://learn.chatgpt.com/docs/cloud`).
- Final read-only checks: canonical parity PASS, zero platform-coupled reference declarations, `bash -n` PASS for the changed shell scripts, and `git diff --check` PASS.

No unresolved finding remains within the requested review scope.
