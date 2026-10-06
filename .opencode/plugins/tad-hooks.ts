// TAD hooks adapter for OpenCode (thin dialect shim — no TAD business logic).
//
// Role: translate OpenCode plugin events into the shared TAD hook envelope,
// invoke the shared scripts under .tad/hooks/ (the single behavior source),
// and translate their output back into OpenCode's dialect. All health, sync,
// and capture behavior lives in the shared scripts; this file only maps
// event names, synthesizes envelope JSON, and rewrites tool output.
//
// Point mapping (TAD point -> OpenCode event -> shared script):
//   session start health  -> event session.created          -> .tad/hooks/startup-health.sh (side effects only)
//   post-compact reminder -> experimental.session.compacting -> .tad/hooks/startup-health.sh with source "compact", context push
//   pre-compact snapshot  -> event session.compacted        -> .tad/hooks/precompact-session-snapshot.sh (side effects only)
//   post-write sync       -> tool.execute.after (write set) -> .tad/hooks/post-write-sync.sh, context appended to output
//
// Write-tool roster (measured 2026-10-06 on OpenCode 1.18.33, grokbox skeleton
// probe; see .tad/evidence/designs/2026-10-06-p3-phase0-probes.md OC-1):
//   write (args: filePath, content), edit (args: filePath, oldString, newString)
// The roster mirrors the Codex surface, where only the dedicated write tool
// (apply_patch) triggers post-write sync; the general bash tool is excluded.
//
// Residual boundaries (see runtime-adapter instance for OpenCode):
//   R-OC-1: OpenCode has no SessionStart additionalContext equivalent, so the
//           startup context cannot be injected at session start; the
//           script still runs for its side effects, and the compacting hook
//           provides partial parity for the compact reminder.
//   R-OC-2: no question/ask-user tool exists in the headless `opencode run`
//           surface (measured OC-1), so the ask-user capture branch is not
//           registered. If a future version exposes one, add its name to
//           QUESTION_TOOLS and the branch below activates.
//
// Output-rewrite parity (measured OC-4, 2026-10-06): text appended to
// output.output in tool.execute.after does reach the model, so the
// post-write injection branch is enabled.
//
// Fail-open contract: every invocation is wrapped so errors and timeouts are
// swallowed; this plugin never throws and never blocks a session.

const WRITE_TOOLS = ["write", "edit"]
const QUESTION_TOOLS: string[] = []
const CALL_TIMEOUT_MS = 5000

async function callHook(
  $: any,
  directory: string,
  script: string,
  envelope: Record<string, unknown>,
): Promise<string> {
  try {
    const payload = JSON.stringify(envelope)
    const run = (async () => {
      const res = await $`printf '%s' ${payload} | bash ${script}`.cwd(directory).nothrow().quiet()
      return res && res.stdout ? res.stdout.toString() : ""
    })()
    const timeout = new Promise<string>((resolve) => setTimeout(() => resolve(""), CALL_TIMEOUT_MS))
    return await Promise.race([run, timeout])
  } catch (e) {
    return ""
  }
}

function extractContext(stdout: string): string {
  try {
    if (!stdout) return ""
    const parsed = JSON.parse(stdout)
    const ctx = parsed && parsed.hookSpecificOutput && parsed.hookSpecificOutput.additionalContext
    return typeof ctx === "string" ? ctx : ""
  } catch (e) {
    return ""
  }
}

export const TadHooksPlugin = async (input: any) => {
  const $ = input && input.$
  const directory = (input && (input.directory || input.worktree)) || "."
  if (!$) return {}
  return {
    event: async (inp: any) => {
      try {
        const ev = inp && inp.event
        const type = ev && ev.type
        if (type === "session.created") {
          await callHook($, directory, ".tad/hooks/startup-health.sh", {
            hook_event_name: "SessionStart",
            source: "startup",
            cwd: directory,
          })
        } else if (type === "session.compacted") {
          const props = (ev && ev.properties) || {}
          await callHook($, directory, ".tad/hooks/precompact-session-snapshot.sh", {
            hook_event_name: "PreCompact",
            session_id: props.sessionID || props.sessionId || "",
            cwd: directory,
          })
        }
      } catch (e) {}
    },
    "experimental.session.compacting": async (inp: any, out: any) => {
      try {
        const stdout = await callHook($, directory, ".tad/hooks/startup-health.sh", {
          hook_event_name: "SessionStart",
          source: "compact",
          cwd: directory,
        })
        const ctx = extractContext(stdout)
        if (ctx && out && Array.isArray(out.context)) out.context.push(ctx)
      } catch (e) {}
    },
    "tool.execute.after": async (inp: any, out: any) => {
      try {
        const tool = inp && inp.tool
        const args = (inp && inp.args) || {}
        if (WRITE_TOOLS.indexOf(tool) >= 0) {
          const stdout = await callHook($, directory, ".tad/hooks/post-write-sync.sh", {
            hook_event_name: "PostToolUse",
            tool_name: tool,
            tool_input: { file_path: args.filePath || args.file_path || "" },
            cwd: directory,
          })
          const ctx = extractContext(stdout)
          if (ctx && out && typeof out.output === "string") {
            out.output = out.output + "\n" + ctx
          }
        } else if (QUESTION_TOOLS.indexOf(tool) >= 0) {
          await callHook($, directory, ".tad/hooks/lib/askuser-capture.sh", {
            hook_event_name: "PostToolUse",
            tool_name: tool,
            tool_input: args,
            cwd: directory,
          })
        }
      } catch (e) {}
    },
  }
}

export default TadHooksPlugin
