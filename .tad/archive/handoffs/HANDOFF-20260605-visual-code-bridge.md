---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/web-frontend"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-05
**Project:** TAD Framework
**Task ID:** TASK-20260605-003
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Fiber bridge script + reference file + SKILL.md routing |
| Components Specified | ✅ | 3 files, clear interfaces |
| Functions Verified | ✅ | React __source confirmed (babel/plugin-transform-react-jsx-source, default in dev) |
| Data Flow Mapped | ✅ | fiber __source → DOM data-source → claude-in-chrome read → Edit → hot reload |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**Title:** Visual Code Bridge — Browser element → source code location for web-frontend pack

**Summary:** Add a new capability to web-frontend pack that bridges the gap between rendered UI elements and their source code locations. When an agent (Blake doing UI polish, or Alex doing design review) looks at a browser element, they can instantly know which .tsx file and line renders it, and edit it directly.

**How it works:**
1. Agent injects a ~40-line JS script via claude-in-chrome that traverses the React fiber tree
2. The script reads each fiber's `_debugSource` (populated by `@babel/plugin-transform-react-jsx-source` in dev mode) and writes `data-source="ComponentName.tsx:42"` on the corresponding DOM element
3. Agent uses claude-in-chrome to inspect any element → reads `data-source` attribute → uses Edit tool on that file:line
4. Hot reload refreshes the browser automatically

**Fallback (non-React or production build):**
When React fiber is unavailable, fall back to className + textContent grep search across the codebase.

---

## 3. Requirements

### FR1: Source Locator Injection Script
Write a JavaScript function that:
- Finds the React fiber root via `document.querySelector('[data-reactroot]')?.__reactFiber$` or `Object.keys(el).find(k => k.startsWith('__reactFiber$'))` pattern
- Traverses the fiber tree recursively
- For each fiber with `_debugSource`, sets `data-source="{fileName}:{lineNumber}"` on the corresponding `stateNode` DOM element
- Returns a count of annotated elements
- Handles: no React (returns 0), production builds without __source (returns 0), SSR hydrated components

### FR2: Reference File
Create `references/visual-code-bridge.md` in the web-frontend pack with:
- The injection script as a code block
- Step-by-step workflow: inject → inspect → identify → edit → verify
- Fallback workflow for non-React projects (grep-based)
- Known limitations

### FR3: SKILL.md Context Detection Update
Add a new row to the Step 1 context detection table:
- Signal words: "visual edit, browser edit, fix this element, UI polish, visual bridge, 看到的, 这个元素, 这个按钮, 改这里"
- Routes to: `references/visual-code-bridge.md`

### FR4: Auto-Inject Pattern
The reference file should instruct agents to:
- Inject the script automatically when opening a browser for UI work (not requiring user to say "enable bridge")
- Re-inject after page navigation (SPA client-side nav preserves annotations, full page load needs re-inject)
- Never inject in production environments (check `process.env.NODE_ENV` or absence of React DevTools hook)

---

## 6. Implementation Steps

### Task 1: Create the reference file

**File:** `.claude/skills/web-frontend/references/visual-code-bridge.md`

Content structure:

```markdown
# Visual Code Bridge

> Browser element → source code location. Inject once, click any element,
> get the exact file:line that renders it. Edit in place, hot reload confirms.

## When to Use
- After implementation, for UI polish (spacing, alignment, color tweaks)
- During pair testing, to fix visual issues in real time
- During design review, to trace rendered elements back to source

## VCB1: Source Locator Injection (React)

**Rule**: Before any visual editing session, inject the source locator script.
This annotates every React-rendered DOM element with its source file and line.

### Injection Script (v2 — P0 fixes applied)

\`\`\`javascript
function injectSourceLocator() {
  if (!window.__REACT_DEVTOOLS_GLOBAL_HOOK__) {
    return { success: false, reason: 'likely-production', count: 0 };
  }
  const rootEl = document.getElementById('__next') || document.getElementById('root') || document.querySelector('[data-reactroot]');
  if (!rootEl) return { success: false, reason: 'no-react-root', count: 0 };
  const fiberKey = Object.keys(rootEl).find(k => k.startsWith('__reactFiber$'));
  if (!fiberKey) return { success: false, reason: 'no-fiber', count: 0 };

  let count = 0, hasAnyDebugSource = false;

  function findNearestDOM(fiber) {
    if (!fiber) return null;
    if (fiber.stateNode && fiber.stateNode.nodeType === 1) return fiber.stateNode;
    return findNearestDOM(fiber.child);
  }

  function traverse(startFiber) {
    let node = startFiber;
    while (node) {
      if (node._debugSource) {
        hasAnyDebugSource = true;
        const domNode = (node.stateNode && node.stateNode.nodeType === 1)
          ? node.stateNode : findNearestDOM(node.child);
        if (domNode && !domNode.getAttribute('data-source')) {
          const src = node._debugSource;
          const fileName = src.fileName.split(/[/\\]/).slice(-3).join('/');
          domNode.setAttribute('data-source', fileName + ':' + src.lineNumber);
          count++;
        }
      }
      if (node.child) traverse(node.child);
      node = node.sibling;
    }
  }

  traverse(rootEl[fiberKey]);
  if (!hasAnyDebugSource) return { success: false, reason: 'no-debug-source', count: 0 };
  return { success: true, count };
}
injectSourceLocator();
\`\`\`

Execute via claude-in-chrome `javascript_tool`. Expected output: `{ success: true, count: N }`.
If count is 0 or success is false, fall back to VCB3 (grep-based).

**P0 Fixes** (Expert Review 2026-06-05):
- P0-1: `findNearestDOM()` — functional components have `stateNode=null`, walk to nearest DOM child
- P0-2: Sibling traversal via `while` loop (only recurse into `child`), prevents stack overflow
- P0-3: React 19 / production detection via `hasAnyDebugSource` + DevTools hook guard
- P1-3: Path `slice(-3)` + Windows `\\` separator support
- P1-4: SPA navigation claim corrected below

### Re-injection
Re-inject after ANY navigation (full page loads AND SPA route changes).
Client-side nav destroys and recreates DOM nodes; existing annotations are lost.
Check: `document.querySelectorAll('[data-source]').length` — if 0 after navigation, re-inject.

## VCB2: Edit Workflow

**Rule**: After injection, use this 4-step loop for each visual fix:

1. **Identify**: Use claude-in-chrome to inspect the problematic element.
   Read its `data-source` attribute. Example: `data-source="components/Card.tsx:42"`
2. **Resolve path**: The `data-source` value is a relative suffix. Find the full path:
   `find . -path "*components/Card.tsx" -not -path "*/node_modules/*" | head -1`
3. **Edit**: Use Read tool to read the file at the identified line, then Edit tool to fix.
4. **Verify**: Hot reload updates the browser. Re-inspect the element to confirm the fix.

Repeat for each element that needs adjustment.

### Batch Mode
For multiple fixes in the same file, collect all `data-source` annotations first,
then make all edits in one pass to minimize hot reload cycles.

## VCB3: Fallback — grep-based (non-React or production)

**Rule**: When fiber injection returns `{ success: false }`, use this workflow:

1. **Identify**: Use claude-in-chrome to read the element's:
   - `className` (most discriminating for Tailwind projects)
   - `textContent` (for unique text)
   - `tagName` + position context
2. **Search**: `grep -rn "className.*{unique-class-fragment}" --include="*.tsx" --include="*.jsx" src/`
   Or for text: `grep -rn "{unique-text}" --include="*.tsx" --include="*.jsx" src/`
3. **Disambiguate**: If multiple matches, use claude-in-chrome to get parent element context
   and narrow with: `grep -B5 -A5 "{class}" {file}` to verify component structure matches.
4. **Edit + Verify**: Same as VCB2 steps 3-4.

## VCB4: Known Limitations

- **Production builds**: `_debugSource` is stripped. Fallback to VCB3.
- **Third-party components**: Elements rendered by node_modules packages show
  the library's source, not your code. Look for the nearest parent with a project path.
- **CSS-in-JS**: Styled-components/emotion generate dynamic classNames. Use textContent
  or structural position instead of className for search.
- **Shadow DOM**: Web components with shadow roots are not traversed by the fiber walker.
```

### Task 2: Update SKILL.md context detection

**File:** `.claude/skills/web-frontend/SKILL.md`

Add a new row to the Step 1 context detection table (after the "test / coverage" row):

```
| "visual edit / browser edit / fix this element / UI polish / visual bridge / 看到的 / 这个元素 / 改这里" | [`references/visual-code-bridge.md`](references/visual-code-bridge.md) |
```

Also update the SKILL.md YAML frontmatter keywords to include "visual edit" and "browser edit":

Current keywords line ends with: `"WCAG"`
Add: `"visual edit", "browser edit", "UI polish", "visual bridge"`

### Task 3: Update SKILL.md description

In the YAML frontmatter `description:` field, append "visual-code bridge" to the capability list.

---

## 7. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| .claude/skills/web-frontend/references/visual-code-bridge.md | CREATE | Reference file with injection script + workflow + fallback |
| .claude/skills/web-frontend/SKILL.md | MODIFY | Add context detection row + keywords + description update |

**Grounded Against** (Alex step1c):
- .claude/skills/web-frontend/SKILL.md (head 60, read at 2026-06-05)
- .claude/skills/web-frontend/references/ directory listing (7 existing files)

---

## 9. Acceptance Criteria

- [ ] AC1: `references/visual-code-bridge.md` exists with VCB1-VCB4 sections
- [ ] AC2: VCB1 injection script is syntactically valid JavaScript (`node -e "..." exits 0`)
- [ ] AC3: SKILL.md Step 1 table has "visual edit" row routing to visual-code-bridge.md
- [ ] AC4: SKILL.md keywords include "visual edit" and "browser edit"
- [ ] AC5: VCB3 fallback section provides grep-based workflow
- [ ] AC6: No existing reference files or SKILL.md content modified (append-only for routing table)

### 9.1 Spec Compliance Checklist

| # | Check | Verification | Expected |
|---|-------|-------------|----------|
| AC1 | Sections exist | `grep -c '^## VCB' .claude/skills/web-frontend/references/visual-code-bridge.md` | 4 |
| AC2 | JS valid | Extract script from fenced code block, run `node --check` (syntax only, no DOM needed) | exit 0 |
| AC3 | Route exists | `grep 'visual-code-bridge' .claude/skills/web-frontend/SKILL.md` | ≥1 match |
| AC4 | Keywords | `grep 'visual edit' .claude/skills/web-frontend/SKILL.md` | ≥1 match |
| AC6 | No regression | `git diff .claude/skills/web-frontend/SKILL.md` shows only additions | 0 deletions in existing content |

---

## 10. Important Notes

- The injection script depends on React's `_debugSource` which is only available in dev mode via `@babel/plugin-transform-react-jsx-source`. This is enabled by default in Next.js, Vite, and CRA development builds.
- The script does NOT modify any React state or DOM behavior — it only adds `data-source` attributes (read-only annotation).
- The `fileName` in `_debugSource` is an absolute path on the build machine. The script strips it to the last 2 path segments to keep it portable.

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Pack Build Rules: Cross-Cutting Rules Layer** (2026-06-05): VCB rules are capability-specific, not cross-cutting. They stay in the reference file, not SKILL.md body.
- **CLI-first Tool Design** (feedback): The injection script runs via claude-in-chrome javascript_tool — this IS CLI-compatible (executed programmatically by the agent, no GUI needed).

---

## Required Evidence Manifest

```yaml
evidence:
  expert_reviews: ".tad/evidence/reviews/blake/visual-code-bridge/"
  completion: ".tad/active/handoffs/COMPLETION-20260605-visual-code-bridge.md"
  blake_reviews: ".tad/evidence/reviews/blake/visual-code-bridge/"
```
