# Code Review: loop-discover Workflow

**Reviewer**: Code Review Agent (Gate 3)
**Date**: 2026-06-03
**Files Reviewed**:
- `.claude/workflows/loop-discover.workflow.js` (147 lines, NEW)
- `.claude/skills/alex/SKILL.md` lines 4559-4566 and 5703-5710 (MODIFIED)

**Reference Files**:
- `.claude/workflows/epic-audit.workflow.js` (args workaround pattern)
- `.claude/workflows/gate-review.workflow.js` (args workaround pattern)

---

## Architecture Pass

The workflow follows the established pattern from epic-audit and gate-review:
- `export const meta` with name/description/whenToUse/phases
- `Object.keys` workaround for args parsing
- `phase()` / `log()` / `agent()` / `budget` runtime API usage
- Two-phase structure (Discover + Complete)

The design is clean: a single generic loop with pluggable finder prompt, schema, and dedup key. The workflow is stateless (no direct file I/O) with persistence delegated to the Conductor, which is architecturally correct per the handoff's NFR4 and design note.

**Positive observations**:
- Clear separation of concerns (loop mechanics vs finder logic)
- Triple stop condition (dry rounds + max rounds + budget) prevents all runaway scenarios
- `MAX_PREVIOUSLY_SHOWN = 50` cap prevents context overflow on long-running discoveries
- Consistent use of `var` (not `let`/`const` in loop body) avoids potential workflow runtime compatibility issues

---

## Implementation Pass

### P1-1: `findings.length` truthy check is fragile for non-array returns (P1 - should fix)

**Location**: Line 114
```javascript
var validFindings = (findings && findings.length) ? findings : []
```

If the agent returns an object (not an array) that happens to have a `.length` property (e.g., a string), this would pass the truthiness check but then `.filter()` on line 115 would operate on string characters, not findings. More defensively:

```javascript
var validFindings = (findings && Array.isArray(findings)) ? findings : []
```

`Array.isArray` is available in all JS runtimes that support `Set`, `Map`, and arrow functions (which the workflow runtime clearly does, given epic-audit uses arrow functions in `parallel()`).

**Impact**: If an agent returns a malformed response (string, object), the current code silently treats it as either empty (good for strings with length > 0 that fail `.filter`) or crashes on `.filter()` for non-iterables. The `Array.isArray` guard would be strictly safer.

---

### P2-1: Composite dedup_key with empty array produces degenerate key (P2 - nice to have)

**Location**: Lines 63-68
```javascript
function getKey(finding, dk) {
  if (typeof dk === 'string') return String(finding[dk] || '')
  var parts = []
  for (var i = 0; i < dk.length; i++) { parts.push(String(finding[dk[i]] || '')) }
  return parts.join('::')
}
```

If `dedup_key` is an empty array `[]`, `getKey()` returns `''` (empty string joined). The filter on line 117 (`k && k !== ''`) catches this, so findings with an empty composite key are discarded. This is correct behavior but undocumented. If the caller passes `dedup_key: []`, ALL findings would be silently dropped.

**Suggestion**: Add a validation check after args parsing:
```javascript
if (Array.isArray(dedupKey) && dedupKey.length === 0) {
  log('ERROR: dedup_key array must have at least one field')
  return { error: 'dedup_key array must be non-empty' }
}
```

---

### P2-2: `dryRoundsToStop` type not validated (P2 - nice to have)

**Location**: Line 53
```javascript
if (dryRoundsToStop < 1) dryRoundsToStop = 1
```

If the caller passes `dry_rounds_to_stop: "2"` (string), the comparison `"2" < 1` is `false` (string coercion), so it proceeds with the string value. The while-loop comparison `dryRounds < "2"` would work due to JS coercion (0 < "2" is true, 2 < "2" is false), so it would accidentally work correctly. Not a bug, but fragile.

**Not blocking**: JS coercion happens to produce correct behavior here. This is defense-in-depth, not a real failure case.

---

### P2-3: Budget guard checks `budget.total` but specification only requires `budget.remaining()` (P2 - nice to have)

**Location**: Line 95
```javascript
if (typeof budget !== 'undefined' && budget && budget.total && budget.remaining() < 30000)
```

The `budget.total` check means: if the budget object exists but has no `.total` property (e.g., an unlimited budget), the guard is skipped entirely. This is actually CORRECT behavior -- if there's no total budget, there's nothing to guard against. The handoff says "budget may be undefined when no target set" which this handles.

**Verdict**: Well-considered defensive check. No issue.

---

### P2-4: `outputPath` is captured but never used inside the workflow (P2 - nice to have)

**Location**: Lines 19 (declaration), 27 (assignment), 146 (returned)
```javascript
let outputPath = null
// ...
if (keys[i] === 'output_path') outputPath = args[keys[i]]
// ...
output_path: outputPath || null
```

The `outputPath` is captured from args and passed through in the return value, but the workflow never writes to it. This is **by design** per the handoff: "Persisting findings to disk is the Conductor's responsibility after receiving the return value." The return value includes `output_path` so the Conductor knows where to write.

**Verdict**: Correct. The pass-through pattern is intentional.

---

## Quality Pass

### Naming and Style

- Consistent `camelCase` for JS variables, `snake_case` for args/return fields (matching the workflow API convention from other workflows).
- Comments are clear and sufficient.
- The code is 147 lines, within the handoff's estimate of "~150-200 lines".
- No dead code or unused variables (except `outputPath` which is intentionally a pass-through).

### Consistency with Reference Workflows

Compared to `epic-audit.workflow.js` and `gate-review.workflow.js`:

| Pattern | epic-audit | gate-review | loop-discover | Consistent? |
|---------|-----------|-------------|---------------|-------------|
| `export const meta` | Yes | Yes | Yes | OK |
| `Object.keys` workaround | No (uses array args) | Yes | Yes | OK |
| `phase()` calls | Yes | Yes | Yes | OK |
| `agent()` with schema | Yes | Yes | Yes | OK |
| `parallel()` | Yes | Yes | No (sequential) | OK - sequential is correct for loop-discover |
| `model: 'haiku'` for lightweight tasks | Yes | No | Yes (load-prior) | OK |
| Error return format | `{ summary: ... }` | `{ error: ... }` | `{ error: ... }` | OK |

**Note**: `epic-audit` uses `args` as a direct array (`args[i]`), while `gate-review` and `loop-discover` use the `Object.keys` workaround for object args. This is correct -- `epic-audit` takes an array, the other two take objects.

### SKILL.md Integration Quality

The two `loop_discover_option` blocks (lines 4559-4566 and 5703-5710) are well-placed:
- *optimize block uses `dedup_key: "proposal_id"` (single string) -- exercises the string path
- *dream block uses `dedup_key: ["file_path", "entry_title"]` (composite array) -- exercises the array path

Both include appropriate schemas with `required` fields that match the dedup key. Both are clearly marked as optional ("If Workflow tool available") which is correct since the Workflow tool may not be present in all sessions.

---

## Security Review

- No user input reaches shell commands (workflow uses `agent()` API, not `bash`)
- No file system access (delegated to agents)
- No sensitive data in prompts
- `previousFindingsPath` is passed to an agent prompt as a string -- the agent reads the file, not the workflow. No path traversal risk at the workflow layer (the agent runtime handles its own sandboxing).

---

## Findings Summary

### P0 (Critical / Must Fix)

None.

### P1 (Important / Should Fix)

| ID | Issue | Location | Fix |
|----|-------|----------|-----|
| P1-1 | `findings.length` check is fragile for non-array agent returns | Line 114 | Replace `findings && findings.length` with `findings && Array.isArray(findings)` |

### P2 (Suggestions / Nice to Have)

| ID | Issue | Location | Fix |
|----|-------|----------|-----|
| P2-1 | Empty `dedup_key` array silently drops all findings | After line 49 | Add `Array.isArray(dedupKey) && dedupKey.length === 0` validation |
| P2-2 | `dryRoundsToStop` type not validated | Line 53 | Add `Number()` coercion or type check |
| P2-3 | Budget guard `budget.total` check | Line 95 | No fix needed -- correct as-is |
| P2-4 | `outputPath` pass-through | Line 146 | No fix needed -- correct by design |

---

## Overall Assessment

Solid implementation. The workflow is clean, well-structured, and follows established patterns from sibling workflows. The core loop logic (dry rounds counter, dedup, budget guard, max rounds) is correct. The single P1 is a defensive improvement, not a functional bug in the expected happy path. The SKILL.md integration is minimal and correctly scoped, with no SAFETY impact (AC8 = 20, unchanged).

**Recommendation**: Fix P1-1 (one-line change), optionally fix P2-1. Ship.
