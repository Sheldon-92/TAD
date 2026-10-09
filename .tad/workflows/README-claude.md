# TAD workflow scripts (Claude Code only)

Ten `*.workflow.js` scripts live in `.tad/workflows/claude/`. They are orchestration scripts for
the Claude Code `Workflow` tool: `epic-audit`, `gate-review`, `handoff-review`, `loop-discover`,
`pack-dogfood`, `pack-upgrade`, `surplus-execute`, `surplus-scan`, `tournament-design`, `yolo-epic`.

## How to call
- Only from a Claude Code main session that has the Workflow tool (if it is deferred, load it with
  `ToolSearch` query `select:Workflow`). Codex, Cursor, OpenCode and subagents do not have it; the
  protocols that call these scripts carry a `WORKFLOW-FALLBACK` line for that case.
- Call by path, with `args` as an object:
  `Workflow({ scriptPath: ".tad/workflows/claude/<name>.workflow.js", args: { ... } })`
- The relative path assumes the session runs in the project root; otherwise use
  `$(git rev-parse --show-toplevel)/.tad/workflows/claude/<name>.workflow.js`.

## Scope
`pack-upgrade`, `pack-dogfood`, `surplus-scan`, `surplus-execute` and `epic-audit` maintain the TAD
framework repository itself; they are of limited use in an ordinary project.

## Syntax check
`node --check` on the raw file is a false gate (top-level `return`/`await`). Use the wrapped form:
`{ echo 'async function __wf(){'; echo 'let args,agent,parallel,pipeline,phase,log,budget,workflow;'; sed 's/^export const meta/const meta/' FILE; echo '}'; } | node --check /dev/stdin`
