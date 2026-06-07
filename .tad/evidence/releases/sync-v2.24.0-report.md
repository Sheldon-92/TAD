# TAD v2.24.0 Sync Report

- **Date**: 2026-06-07
- **Source**: `/Users/sheldonzhao/01-on progress programs/TAD` (version 2.24.0)
- **Targets**: 14 projects in `.tad/sync-registry.yaml`
- **Script**: `.tad/evidence/releases/sync-v2.24.0.sh`
- **Log**: `.tad/evidence/releases/sync-v2.24.0.log`
- **Strategy**: mixed (framework full-refresh, capability-packs registry-only, settings.json JSON-merge, CLAUDE.md per-strategy, deprecation cleanup)
- **Gate mode**: `TAD_RELEASE_GATE=warn` (first-cutover shadow mode — drift reported, not aborting)

## Result: 14/14 reached 2.24.0, 0 skipped, all packs install clean (25/25)

| Project | version | framework | packs(ok/fail) | CLAUDE.md | structural-gate | status |
|---------|---------|-----------|----------------|-----------|-----------------|--------|
| menu-snap | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| my-openclaw-agents | 2.24.0 | full-refresh | 25/0 | merge-NO-MARKER (untouched, WARN) | FAIL (1, benign*) | ok |
| OpenClaw Hack | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| 运动打卡小助手 | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| 合规ai | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| ArtForge | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| Sober Creator | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| toy | 2.24.0 | full-refresh | 25/0 | merge-NO-MARKER (untouched, WARN) | FAIL (1, benign*) | ok |
| 内存管理 | 2.24.0 | full-refresh | 25/0 | merge-NO-MARKER (untouched, WARN) | FAIL (1, benign*) | ok |
| Next Guest | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| 下载md插件 | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| 买卖 | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| Monica-website | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |
| Colin声音项目 | 2.24.0 | full-refresh | 25/0 | overwritten | FAIL (1, benign*) | ok |

## WARNINGs

### W1 — merge-strategy CLAUDE.md without marker (3 projects, untouched)
`my-openclaw-agents`, `toy`, `内存管理` are registered `claude_md_strategy: merge` but their
`CLAUDE.md` lacks the `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker. Per protocol they were
**left untouched** (verified: not modified this run — mtime/git unchanged; no new `.bak` created).
Action for user: add the marker to these 3 files if you want TAD's CLAUDE.md head to sync, OR
switch their strategy to `overwrite` in `.tad/sync-registry.yaml`.

### W2 — structural gate "benign" drift (*all 14, WARN-only, NOT a sync defect)
The structural verifier compares `.claude/skills/` byte-for-byte between source and target.
After step (d) full-refreshes `.claude/skills`, step (f) runs each pack's `install.sh`, which
**by design** copies the pack's `CAPABILITY.md` → target `.claude/skills/<pack>/SKILL.md`.
That CAPABILITY.md content differs from the source repo's rendered `SKILL.md` (e.g. `references/`-
prefixed load paths). Affected files (identical set on all 14):
- `.claude/skills/academic-research/SKILL.md`
- `.claude/skills/ai-voice-production/SKILL.md`
- `.claude/skills/video-creation/SKILL.md`

This is the documented step-(d)-vs-step-(f) interaction, consistent across every project →
systematic and benign, not per-project corruption. Gate ran in `warn` mode (first cutover), so
it reported and proceeded as intended. **Recommendation before flipping the gate to hard-block:**
align the pack `CAPABILITY.md` content with the repo's `SKILL.md`, OR teach `release-verify.sh`
to exclude pack-install-owned skill files from the byte-identity comparison.

### W3 — pack installers without `--force` (fixed in script, 0 fails)
`academic-research` and `research-methodology` `install.sh` do **not** accept `--force` (they
print usage + exit 1 on unknown flags). The first run counted them as 2 fails (23/2). The script
was patched to detect `--force` support per-installer and call the idempotent no-arg form for
those that lack it. Final run: **25/0 on every project.** (`ai-podcast-production` tolerates the
flag and always passed.) Action for maintainer: add a `--force` no-op to those two installers for
consistency.

## Verification performed
- All 14 `.tad/version.txt` == `2.24.0`.
- `settings.json` valid JSON post-merge; TAD-owned hook events (SessionStart/PreToolUse/PostToolUse)
  present; non-TAD keys (`permissions`, others) preserved (spot-checked `toy`, `menu-snap`).
- Zero-touch dirs not in copy set (derive-sync-set deny-list honored); `sync-registry.yaml` and
  `version.txt` excluded from top-level `.tad` file copy.
- Deprecation cleanup: 42 paths (all versions ≤ 2.24.0) processed idempotently per project.
