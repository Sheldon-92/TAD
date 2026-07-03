# Journal: surplus-execute-p2 (2026-07-02)

## Workflow args string serialization (scriptPath invocation)

**Finding**: When invoking a workflow via `Workflow({scriptPath: '...', args: {...}})`, the `args` object arrives inside the workflow script as a **string**, not a parsed object. `Object.keys(args)` returns character indices ("0","1","2",...) instead of field names ("sidecar_rows","date").

**Root cause**: The Workflow tool serializes args to JSON string when passing to scriptPath-based scripts. This differs from `workflow('name', {...})` nested calls where args arrives as a parsed object (verified: yolo-epic uses Object.keys pattern and works when called via nested `workflow()`).

**Fix**: Add `typeof args === 'string' ? JSON.parse(args) : args` at the top of any workflow that may be called via scriptPath (top-level invocation from SKILL/Conductor). Nested workflows called via `workflow('name', {...})` don't need this.

**Scope**: Any workflow invoked directly by the SKILL layer (scriptPath). Workflows only called via nested `workflow()` are unaffected.

## Workflow nesting limit (one level only)

**Finding**: `workflow()` inside a child workflow throws "cannot be called from within a child workflow — nesting is limited to one level." A wrapper-workflow → surplus-execute → yolo-epic chain is 2 levels and fails.

**Fix**: The SKILL layer must invoke surplus-execute directly via `Workflow({scriptPath:...})`, not wrapped in another workflow. surplus-execute → yolo-epic is the only nesting level.

**Implication**: Future workflows that need to compose two existing workflows cannot nest them — must inline one or restructure as a single workflow.
