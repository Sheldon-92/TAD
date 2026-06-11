# Idea: .agents/skills Auto-Parity Check in Publish Flow

**ID:** IDEA-20260610-agents-skills-auto-parity
**Date:** 2026-06-10
**Status:** promoted
**Scope:** small

---

## Summary & Problem

Every time `.claude/skills/` files are modified (by any Epic or handoff), `.agents/skills/` (Codex platform) must be manually synced. This is repeatedly forgotten — Feedback Collector Epic (3 phases, 6 files changed) shipped without syncing, caught only when user noticed. The gap means Codex users run stale protocols.

Fix: add a `diff -qr .claude/skills .agents/skills` check to the `*publish` flow. If any files differ, auto-copy before publishing. Simple, no symlinks.

## Open Questions

- Should the check also run during `*sync` (to downstream projects)?
- Should it be in release-verify.sh (verify only) or in the publish protocol itself (verify + fix)?
- Should Blake's completion protocol also check this after modifying any SKILL file?

## Notes

- Symlink approach rejected by user (may cause issues with Codex's file expectations)
- Recurring problem: Dual-Platform Parity Fix (f428d70) + Feedback Collector (f84c8fb) both required manual catch-and-fix
- Implementation: ~10 lines in publish-protocol or release-verify.sh

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: HANDOFF-20260610-codex-parity-step3b (commits 16983f6 + ebe92cf + 238a56d + e82704f) — Gate 4 PASS 2026-06-10
