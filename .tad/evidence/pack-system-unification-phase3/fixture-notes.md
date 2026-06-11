# Platform-Skills Verifier Fixture Notes

## Fixtures Used

### AC3: Drift fixture
- Created temp dir, copied `.claude` and `.agents`
- Appended `\nDRIFT-FIXTURE\n` to `$tmp/.agents/skills/alex/SKILL.md`
- Expected: exit 1, output names "alex"
- Result: PASS — verifier detected drift and named the skill

### AC4: Local-only skill fixture
- Created temp dir, copied `.claude` and `.agents`
- Added `$tmp/.agents/skills/local-only-demo/SKILL.md` (not in source)
- Expected: exit 0, output contains "local-skill"
- Result: PASS — local skill reported as INFO, exit 0

### AC5: Missing framework-owned skill fixture
- Created temp dir, copied `.claude` and `.agents`
- Deleted `$tmp/.agents/skills/blake/SKILL.md`
- Expected: exit 1, output names "blake"
- Result: PASS — verifier detected missing file and named the skill

## AC9 Friction Note

AC9 raw command matches `docs/HISTORY.md` line 20 — a historical completion record (`[x] EPIC: Domain Pack Reliable Loading`). This is a historical archive entry, not an active Domain Pack runtime reference. The match is a false positive from the `docs` recursive search scope including HISTORY.md. Documented as friction; the actual active runtime surfaces (`.tad/hooks`, `.claude/skills`, `.agents/skills`) are clean.

## research-methodology Disposition

`research-methodology` was flag-only in Phase 2 (accept `--force`). It is NOT one of the 7 single-sourced target packs. The `platform-skills` verifier covers it as a framework-owned skill because it exists in both `.claude/skills/research-methodology/` and `.agents/skills/research-methodology/`. The current source content matches on both platforms (parity pass). No Phase 3 action needed beyond the verifier covering it.
