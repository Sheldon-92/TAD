> **Runtime status (v3.2.0)**: TAD supports **Codex**, **OpenCode**, and **Cursor**.
> `.agents/skills/` is a first-party discovery path on all three and `AGENTS.md`
> is read natively by all three, so roles, gates, and capability packs load
> open-box. All three runtimes are **hook-enabled** (Epic Phase 3, 2026-10-06):
> Codex natively; OpenCode via the projected plugin and Cursor via projected
> hooks + shims, both over the shared `.tad/hooks/*.sh` behavior source
> (residual boundaries R-OC-1/R-OC-2/R-CU-1 — see Known Gaps).
> See `.tad/codex/README.md` for adapter details and activation status.
> Version of record: `.tad/version.txt`. Do not restate a version number anywhere else; link here instead.

## Knowledge Ingress (read on activation)

- Every role activation reads `.tad/project-knowledge/principles.md` first.

## Known Gaps (OpenCode / Cursor)

- **P4 — Live behavioral regression (first baselines landed 2026-10-06, Epic Phase 3 item 3.3)**: full-chain live transcripts for all three runtimes are on disk at `.tad/evidence/live-regression/` (OpenCode PASS, Cursor PASS, Codex FAIL — blocked by the provider account usage limit before any tool use; retry on/after 2026-10-10). step3f grading is HARD for all three from v3.2.0; the Codex PASS baseline remains outstanding under that attribution.
