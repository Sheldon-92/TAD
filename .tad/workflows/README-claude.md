# TAD workflow scripts (Claude Code only)
Ten `*.workflow.js` scripts live in `.tad/workflows/claude/`: `epic-audit`, `gate-review`,
`handoff-review`, `loop-discover`, `pack-dogfood`, `pack-upgrade`, `surplus-execute`,
`surplus-scan`, `tournament-design`, `yolo-epic`.

## How to call
- Only from a Claude Code main session that has the `Workflow` tool (if it is not visible, run
  `ToolSearch` with `select:Workflow` first). Codex, Cursor, OpenCode and subagents do not have it
  (subagents: earlier project observation, not re-measured in Phase 3). The protocols that call
  these scripts carry a `WORKFLOW-FALLBACK` line for that case.
- By path, `args` as an object:
  `Workflow({ scriptPath: ".tad/workflows/claude/<name>.workflow.js", args: { ... } })`
- If the session is not at the project root, do not launch: first change to the output of
  `git rev-parse --show-toplevel` (or reopen the session there); script-internal paths are root-relative.
- If the `spec-compliance-reviewer` agent type is not registered (not yet projected into
  `.claude/agents/`), spawn a general sub-agent with the body of
  `.tad/agents/claude/spec-compliance-reviewer.md` as its task text.

## Scope
`pack-upgrade`, `pack-dogfood`, `surplus-*` and `epic-audit` maintain the TAD framework repository
itself; they are of limited use in an ordinary project.

## Syntax check
Raw `node --check` is a false gate. Use the wrapped form:
`{ echo 'async function __wf(){'; echo 'let args,agent,parallel,pipeline,phase,log,budget,workflow;'; sed 's/^export const meta/const meta/' FILE; echo '}'; } | node --check /dev/stdin`
