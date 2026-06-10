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

```javascript
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
```

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
2. **Search**: `grep -rn "className.*{unique-class-fragment}" --include="*.tsx" --include="*.jsx" src/ app/`
   Or for text: `grep -rn "{unique-text}" --include="*.tsx" --include="*.jsx" src/ app/`
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
- **React Server Components (RSC)**: In Next.js App Router, only `'use client'` components
  carry `_debugSource`. Server-rendered RSC output has no fiber annotations — fallback to VCB3.
