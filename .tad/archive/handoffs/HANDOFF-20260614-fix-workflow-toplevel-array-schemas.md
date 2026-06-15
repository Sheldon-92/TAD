---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: ["."]
skip_knowledge_assessment: no
gate4_delta: []
express: true
---

# Handoff: Fix top-level-array StructuredOutput schemas in workflows + surplus undated WARN

**From:** Alex  **To:** Blake  **Date:** 2026-06-14
**Source:** SURPLUS-PLAN-2026-06-14 #9/#14 (surplus filename/write bug) — grounding expanded it: surplus-scan itself is clean, but a repo-wide sweep found the SAME top-level-array schema bug class in 2 OTHER workflows.
**Tier:** express (mechanical schema-wrap following an established precedent). Express ≠ review-exempt → ≥1 independent reviewer at Gate 3.

## 1.3 Intent
1. **Problem:** The Workflow `agent({schema})` StructuredOutput contract requires a **top-level OBJECT** schema. Three `agent()` calls pass a **top-level ARRAY** schema (`{ type: 'array', items: ... }`), which StructuredOutput rejects at runtime → those agent calls fail. This is the exact class already fixed in surplus-scan (wrapped as `{candidates:[...]}`). Affected: `loop-discover.workflow.js:80` (load-prior) + `:111` (the CORE discovery loop — so the whole workflow is broken) and `epic-audit.workflow.js:80` (detect-epics).
2. **Also (the original #9 symptom):** `surplus-scan.workflow.js` silently falls back to `dateStamp='undated'` when no `date` arg arrives (e.g. invoked directly as the `/surplus-scan` workflow instead of via the `*surplus` SKILL, which is the only path that stamps the date AND writes the files). The silent fallback is why this session's breakage was invisible. Add a loud WARN.
3. **Success:** all three schemas are object-wrapped, their consumption sites read the wrapper key, both workflows parse, and surplus-scan logs a clear WARN (with remediation) when it falls back to undated.

## 6 Scope (files — ALL under .claude/workflows/)
- `.claude/workflows/epic-audit.workflow.js` — line ~80 schema + consumption.
- `.claude/workflows/loop-discover.workflow.js` — lines ~80 + ~111 schemas + consumption.
- `.claude/workflows/surplus-scan.workflow.js` — add WARN log at the dateStamp fallback (~line 32).
- **OUT OF SCOPE (DO NOT TOUCH):** `.claude/skills/reading-companion/**` (another Alex owns Phase 4), tad.sh, anything else.

## 9 Design (exact edits)

### A. epic-audit.workflow.js (~80)
```js
// BEFORE
{ label: 'detect-epics', schema: { type: 'array', items: { type: 'string' } }, model: 'haiku' }
// ...
if (detected) { for (let i = 0; i < detected.length; i++) { epicPaths.push(detected[i]) } }
```
```js
// AFTER
{ label: 'detect-epics', schema: { type: 'object', properties: { paths: { type: 'array', items: { type: 'string' } } }, required: ['paths'] }, model: 'haiku' }
// ...
if (detected && Array.isArray(detected.paths)) { for (let i = 0; i < detected.paths.length; i++) { epicPaths.push(detected.paths[i]) } }
```
Also update that agent's PROMPT text: replace "Return ONLY a JSON array of file paths" → "Return ONLY a JSON object {\"paths\": [...]} whose paths array holds the file paths". Keep the example.

### B. loop-discover.workflow.js (~80, load-prior)
```js
// BEFORE: schema: { type: 'array', items: schema }   ; result `prior` used as array (prior.length, prior[pi])
// AFTER:  schema: { type: 'object', properties: { items: { type: 'array', items: schema } }, required: ['items'] }
```
Consumption: replace `if (prior && prior.length)` → `var priorArr = (prior && Array.isArray(prior.items)) ? prior.items : []; if (priorArr.length)` and push from `priorArr[pi]`. Update the prompt "Parse it as a JSON array. Return the parsed array...return an empty array []" → "Return a JSON object {\"items\": [...]} whose items array is the parsed findings (use {\"items\": []} if the file is missing/empty)".

### C. loop-discover.workflow.js (~111, round-N — core loop)
```js
// BEFORE: schema: { type: 'array', items: schema }   ; result `findings`, then `Array.isArray(findings) ? findings : []`
// AFTER:  schema: { type: 'object', properties: { items: { type: 'array', items: schema } }, required: ['items'] }
```
Consumption: `var validFindings = (findings && Array.isArray(findings.items)) ? findings.items : []`. The finder PROMPT comes from the caller (`finderPrompt`) — do NOT rewrite it, but the `agent()` call site may append a one-line instruction: "Return your findings as a JSON object {\"items\": [...]}." Append that to the prompt string passed at the call site so the model targets the wrapper key.

### D. surplus-scan.workflow.js (~32, undated fallback)
```js
// BEFORE
if (!dateStamp) dateStamp = 'undated'
// AFTER
if (!dateStamp) { dateStamp = 'undated'; log('⚠️ surplus-scan: no date arg received → output stamped "undated" and the sandboxed workflow writes NO files. Invoke via the *surplus SKILL (it stamps the date AND writes the two artifacts); a direct workflow invocation only returns content.') }
```

## Gate 2 Audit Trail (expert review integrated)
| Reviewer | Issue | Resolution | Status |
|----------|-------|-----------|--------|
| general-purpose (runtime checker) | **P0** AC4 command (`node --input-type=module --check`) is a FALSE gate — fails on UNMODIFIED files (they have module-level top-level `return`, not just `await`) | AC4 replaced with the empirically-verified async-wrap parse command | ✅ AC4 below |
| code-reviewer | AC1 grep would false-POSITIVE — single-line wrapper puts nested `items:{type:'array'}` on the `schema:` line | AC1 rewritten to match the TOP-LEVEL pattern `schema:{type:'array'` only | ✅ AC1 below |
| code-reviewer | design correctness (all 3 reads covered, no `items`/`schema` collision, return key `findings:` at :144 correctly untouched, WARN safe) | confirmed PASS, 0 P0/P1 | ✅ no change |

> Note (code-reviewer): the workflow's OWN return key `findings: allFindings` (loop-discover:144) is an array and MUST stay untouched — it is NOT an agent schema. Edit C only touches the `agent()` result `findings` at :111/:114.

## 9.1 Acceptance Criteria (Blake MUST run — actual output, not paper)
- AC1 (no TOP-LEVEL array schema remains): `grep -rnE "schema:[[:space:]]*\{[[:space:]]*type:[[:space:]]*'array'" .claude/workflows/epic-audit.workflow.js .claude/workflows/loop-discover.workflow.js` returns **nothing**. (This matches `schema: { type: 'array'` specifically — a legit NESTED `items: { type: 'array' }` is allowed and must NOT trip this.)
- AC2: each fixed schema is object-typed — `grep -c "type: 'object', properties:" ` shows the new wrappers present (≥1 in epic-audit, ≥2 in loop-discover).
- AC3: consumption sites updated — `grep -n "detected.paths" .claude/workflows/epic-audit.workflow.js` and `grep -n "findings.items\|prior.items\|priorArr" .claude/workflows/loop-discover.workflow.js` each return matches; NO remaining `detected[i]` / `Array.isArray(findings) ?` un-wrapped reads (grep to confirm absent).
- AC4 (parse — VERIFIED working command; the naive `node --check` / `--input-type=module` FALSE-fails these function-wrapped bodies that use top-level `return`+`await`):
  ```bash
  for f in epic-audit loop-discover surplus-scan; do
    out=$( { printf 'async function __wf__(agent,log,args,parallel,phase,pipeline,budget,workflow){\n'; \
             sed '1s/^export const /const /' .claude/workflows/$f.workflow.js; \
             printf '\n}\n'; } | node --check --input-type=commonjs 2>&1 )
    [ -z "$out" ] && echo "$f OK" || { echo "$f FAIL:"; echo "$out" | head -3; }
  done
  ```
  All three must print `OK`. (Wraps the body in an async function so top-level `return`/`await` are legal, strips the line-1 `export`, then syntax-checks. Verified at Gate 2 to PASS clean files and CATCH an injected mid-file syntax error.)
- AC5: surplus WARN present — `grep -n 'no date arg received' .claude/workflows/surplus-scan.workflow.js` returns the new line.
- AC6 (scope): `git status --porcelain` shows ONLY the 3 workflow files touched; nothing under `reading-companion/`, no tad.sh.

## 10 Notes
- This is a contract-shape fix; the StructuredOutput tool enforces the object shape, but the agent PROMPTS are updated so the model targets the wrapper key (reduces retries).
- `loop-discover` round-N is the core loop — its breakage means the workflow never produced findings; this is the highest-value part of the fix.
- Express tier: skip e2e; Gate 3 needs ≥1 independent reviewer on the diff + the AC outputs (actual run).
