> **Runtime status (v3.2.0)**: TAD supports **Codex**, **OpenCode**, and **Cursor**.
> `.agents/skills/` is a first-party discovery path on all three and `AGENTS.md`
> is read natively by all three, so roles, gates, and capability packs load
> open-box. Codex is the **hook-enabled** runtime (SessionStart / PostToolUse);
> OpenCode and Cursor currently get skills + routing + packs but **no lifecycle
> hooks** (Platform Adapters P2 — see Known Gaps).
> See `.tad/codex/README.md` for adapter details and activation status.
> Version of record: `.tad/version.txt`. Do not restate a version number anywhere else; link here instead.

## Knowledge Ingress (read on activation)

- Every role activation reads `.tad/project-knowledge/principles.md` first.

## Known Gaps (OpenCode / Cursor)

- **P2 — Hook adapters (implemented 2026-10-06, Epic Phase 3)**: OpenCode lifecycle hooks ship as the tad.sh-projected plugin `.opencode/plugins/tad-hooks.ts` (session.created → startup-health side effects; tool.execute.after on write/edit → post-write-sync with output injection; experimental.session.compacting → compact reminder push; session.compacted → precompact snapshot). Cursor lifecycle hooks ship as the tad.sh-projected `.cursor/hooks.json` plus transcoding shims `.tad/hooks/lib/cursor-session-start.sh` / `.tad/hooks/lib/cursor-post-write.sh` (sessionStart / postToolUse Write / preCompact → the same shared scripts). The shared `.tad/hooks/*.sh` remain the single behavior source on all three runtimes. Residual boundaries, each named and owned: **R-OC-1** OpenCode has no SessionStart context-injection surface (side effects only; the compacting push is partial parity); **R-OC-2** no ask-user tool exists in the OpenCode headless surface, so ask-user capture is not registered there; **R-CU-1** Cursor exposes no question-tool event, so ask-user capture has no Cursor point. Detail: `.tad/project-knowledge/patterns/runtime-adapter-instance-opencode.md` / `runtime-adapter-instance-cursor.md`.
