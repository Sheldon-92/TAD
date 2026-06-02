# Gemini CLI Constraints

**Date:** 2026-05-03
**Linked to:** L2 research-methodology "Cross-Model Orchestration Principles"

---

### Gemini CLI Constraints - 2026-05-03
- **Discovery**: (1) `-p` flag required for non-TTY invocation — hangs without it. All Gemini CLI invocations MUST use `-p` flag. (2) `-p` mode is read-only (no write_file, run_shell_command). (3) Emits PCRE-style regex — MUST validate with `grep -E` on macOS before use in hooks.
- **Action**: Always use `-p` flag. Gemini = read + analyze + text output only. Validate regex with BSD grep.
