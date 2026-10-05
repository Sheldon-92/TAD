# Harness Security Blocker Report — Cursor Agent Headless Execution

**Task:** `TASK-20260908-research-route-local-wiki`  
**Date:** 2026-09-08  
**Agent:** Alex (Solution Lead)  

## Issue Description
The PM dispatch loop repeatedly re-invoked Alex via `cursor-run.sh -c` instructing:
> "EXECUTE now — do not only print commands. (1) rm active handoffs ... (2) pathspec git add ... commit ... (3) report sha"

However, inside the Cursor Agent runtime:
1. `/home/box/.cursor/cli-config.json` is configured with:
   ```json
   "approvalMode": "allowlist",
   "permissions": {
     "allow": ["Shell(ls)"],
     "deny": []
   }
   ```
2. When the agent invokes `Shell(rm ...)` or `Shell(git ...)`, Cursor CLI pauses for interactive user approval on stdin.
3. In `cursor-run.sh`, stdin is redirected from `/dev/null`:
   ```bash
   "$BIN" -p --trust --workspace "$DIR" --model "$MODEL" "${CONT[@]}" "$PROMPT" </dev/null >"$LOG" 2>&1
   ```
4. Because stdin is closed, Cursor CLI immediately receives EOF on approval prompts and rejects the call (`Rejected:`).
5. The `Delete` tool is similarly unapproved and fails with `File deletion rejected`.
6. Cursor CLI protects its own config (`~/.cursor/cli-config.json` and `.cursor/cli.json`), so the agent cannot modify its permissions.

## Resolution
All files on disk (`CLAUDE.md`, 12 mirror pairs, guides, patterns, `NEXT.md`, `PROJECT_CONTEXT.md`, and archival files under `.tad/archive/handoffs/`) are 100% prepared and verified.

The PM host script or Human operator must either:
1. Execute the 2 shell commands (`rm` and `git commit`) directly from host terminal; OR
2. Dispatch the commit command via `oc-run.sh` (OpenCode has permissions configured); OR
3. Update `/home/box/.cursor/cli-config.json` to allow `"Shell(git:*)"` and `"Shell(rm:*)"` for future headless Cursor runs.
