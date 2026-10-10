---
name: multi-harness-restore-v330
description: "v3.3.0 (2026-10-10) restored Claude Code as an install target; what is measured per harness, wording rules, and release mechanics that changed"
metadata:
  node_type: memory
  type: project
  originSessionId: 3169baea-e191-4c1c-b1a7-5517fe00e6ae
  modified: 2026-10-10T13:52:53.898Z
---

EPIC-20261008 shipped as v3.3.0 on 2026-10-10 (`main` and annotated tag `v3.3.0` at `a81ca299`). Four install targets share `.agents/skills/`; Claude Code reads it through per-skill links under `.claude/skills/`. Workflows live in `.tad/workflows/claude/` and are invoked by `scriptPath` (this supersedes the `.claude/workflows/` location in [[tier1-workflow-formalization]]).

**Why this matters later:** the evidence is uneven and the docs were written to say exactly that. Do not describe any harness as "first-class / 一等 / hook-enabled / verified on all four" in public docs (this supersedes the "一等公民" positioning in [[codex-adapter-validation]]). Settled wording is the status table in `docs/MULTI-PLATFORM.md`.

**Not measured as of 2026-10-10 (still open for a human):** Codex with a completed hook trust review (only default-trust and `--dangerously-bypass-hook-trust` runs of `codex exec`); interactive Claude Code sessions (headless only); download install paths (`curl`, `npx github:`, `tad-update.sh`) for the Claude Code projection; legacy `.claude/` adoption on a real downstream project (sandbox fixtures only).

**How to apply:**
- Releasing: the repo's own procedure requires the user's explicit confirmation before pushing `main` or tagging; prepare the release commit locally and ask. After any commit that touches `.agents/skills/**`, run `bash .tad/scripts/gen-claude-provenance.sh` and commit the ledger, or the `provenance` gate is red. The commit to tag is the last one containing the regenerated ledger.
- `release-verify.sh version <repo> <new> <old>` exits 1 by design on history lines; it is cleared by a per-hit triage record under `.tad/evidence/releases/`, not by editing history.
- Running installer fixtures: they pin their own backup root now; the 35 entries in the user's `~/.tad-backups` are old test leftovers the user has not yet decided about.
- The user's three uncommitted files (two `secret-detection-rules.md`, `docs/pm/status.md`) and the untracked repo `.claude/` are theirs: never stage, edit or read them.
- Sub-agents that idle "waiting for a background run" do not wake reliably: probe them at once and require foreground runs.
