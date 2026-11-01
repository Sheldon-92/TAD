export const meta = {
  name: 'surplus-execute',
  description: 'Budget-loop auto-execution of ranked surplus backlog tasks with SAFETY routing',
  phases: [
    { title: 'Validate', detail: 'Schema-check sidecar rows (fail-closed)' },
    { title: 'Execute', detail: 'Budget loop: synthesize ephemeral Epic + yolo-epic per task' },
    { title: 'Report', detail: 'Compile SURPLUS-REPORT digest' }
  ]
}

// runtime-requirements:
//   agent    — hard   — step executor behind every task agent call; missing =>
//                       the entry probe throws naming it, before any agent activity
//   phase    — hard   — phase marker for Validate/Execute/Report; missing =>
//                       the entry probe throws naming it, before any agent activity
//   budget   — facade — native budget delegation (spent/total/remaining); missing =>
//                       local ledger fallback engages (degradation note only, run continues)
//   workflow — facade — nested step runner (yolo-epic); missing => inline
//                       step-execution fallback engages (degradation note only, run continues)
// The entry probe (Step 0, before phase('Validate')) checks existence only via
// typeof and never calls the probed globals: hard-requirement absence is a red
// light, facade absence is a one-line degradation note — the two are not the same.

// ── Schemas ────────────────────────────────────────────────────────

const EPIC_SYNTH_SCHEMA = {
  type: 'object',
  properties: {
    phase_name: { type: 'string' },
    scope: { type: 'string' },
    files_written: { type: 'boolean' }
  },
  required: ['phase_name', 'scope', 'files_written']
}

const PREFLIGHT_SCHEMA = {
  type: 'object',
  properties: {
    prereq_lock: {
      type: 'object',
      properties: {
        hit: { type: 'boolean' },
        evidence: { type: 'string' }
      },
      required: ['hit', 'evidence']
    },
    landed: {
      type: 'object',
      properties: {
        state: { type: 'string', enum: ['not-landed', 'landed', 'unknown'] },
        evidence_paths: { type: 'array', items: { type: 'string' } },
        status_missing: { type: 'array', items: { type: 'string' } }
      },
      required: ['state', 'evidence_paths', 'status_missing']
    },
    approval: {
      type: 'object',
      properties: {
        state: { type: 'string', enum: ['not-claimed', 'verified', 'unverified'] },
        source_quote: { type: 'string' }
      },
      required: ['state', 'source_quote']
    },
    status_missing: { type: 'array', items: { type: 'string' } }
  },
  required: ['prereq_lock', 'landed', 'approval', 'status_missing']
}

// Inline step-runner schemas (same shapes the nested yolo-epic runner uses).
const DESIGN_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    handoff_written: { type: 'boolean' },
    handoff_path: { type: 'string' },
    line_count: { type: 'number' },
    scope_clarity: { type: 'string', enum: ['CLEAR', 'NEEDS_CLARIFICATION'] },
    open_questions: { type: 'number' }
  },
  required: ['handoff_written', 'handoff_path', 'line_count', 'scope_clarity']
}

const REVIEW_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['PASS', 'CONDITIONAL_PASS', 'NEEDS_WORK', 'FAIL'] },
    p0_count: { type: 'number' },
    p1_count: { type: 'number' },
    evidence_path: { type: 'string' },
    summary: { type: 'string' }
  },
  required: ['verdict', 'p0_count', 'evidence_path']
}

const IMPL_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    completion_written: { type: 'boolean' },
    completion_path: { type: 'string' },
    files_changed: { type: 'number' },
    layer1_passed: { type: 'boolean' },
    summary: { type: 'string' }
  },
  required: ['completion_written', 'completion_path', 'layer1_passed']
}

// ── Args parsing ──────────────────────────────────────────────────

var sidecarRows = null
var stamp = 'undated'
var repoRoot = null
var budgetTotalArg = null
var fallbackEstimateArg = null

var parsedArgs = args
if (typeof args === 'string') {
  parsedArgs = JSON.parse(args)
}

if (parsedArgs) {
  var argKeys = Object.keys(parsedArgs)
  for (var i = 0; i < argKeys.length; i++) {
    if (argKeys[i] === 'sidecar_rows') sidecarRows = parsedArgs[argKeys[i]]
    if (argKeys[i] === 'date') stamp = parsedArgs[argKeys[i]]
    if (argKeys[i] === 'repo_root') repoRoot = parsedArgs[argKeys[i]]
    if (argKeys[i] === 'budget_total') budgetTotalArg = parsedArgs[argKeys[i]]
    if (argKeys[i] === 'fallback_agent_estimate_tokens') fallbackEstimateArg = parsedArgs[argKeys[i]]
  }
}

if (!sidecarRows || !Array.isArray(sidecarRows) || sidecarRows.length === 0) {
  throw new Error('sidecar_rows must be a non-empty array')
}

// ── Budget facade (begin) ──
// Every literal reference to the runtime budget global lives between these
// two markers. Native mode delegates verbatim; ledger mode charges each
// agent() return through chargeAgent() and accumulates a local total.
// The capability probe's budget-touching expression is the first statement
// of this block; the workflow/agent probes may live outside it.
var caps = null
var ledgerSpent = 0
var ledgerEstimated = 0

function probeCapabilities() {
  var budgetMode = (typeof budget !== 'undefined' && budget && typeof budget.spent === 'function') ? 'native' : 'ledger'
  var stepMode = (typeof workflow === 'function') ? 'nested' : ((typeof agent === 'function') ? 'inline' : null)
  return { budget: budgetMode, steps: stepMode }
}

function budgetTotal() {
  if (caps.budget === 'native') return (typeof budget.total === 'number') ? budget.total : null
  return budgetTotalArg
}

function budgetSpent() {
  if (caps.budget === 'native') return budget.spent()
  return ledgerSpent
}

function budgetRemaining() {
  if (caps.budget === 'native') return budget.remaining()
  return budgetTotalArg - ledgerSpent
}

function chargeAgent(result) {
  if (!caps || caps.budget !== 'ledger') return
  var amount = null
  if (result && typeof result === 'object') {
    if (typeof result.usage_tokens === 'number') amount = result.usage_tokens
    else if (typeof result.token_usage === 'number') amount = result.token_usage
    else if (result.usage && typeof result.usage === 'object' && typeof result.usage.total_tokens === 'number') amount = result.usage.total_tokens
    else if (typeof result.tokens === 'number') amount = result.tokens
  }
  if (amount === null) {
    var est = (typeof fallbackEstimateArg === 'number' && fallbackEstimateArg > 0) ? fallbackEstimateArg : perTaskReserve
    ledgerSpent += est
    ledgerEstimated++
  } else {
    ledgerSpent += amount
  }
}
// ── Budget facade (end) ──

// ── Step 0: Sidecar validation (fail-closed — SA P0-2) ───────────
// Capability probe + new-arg checks run FIRST (they name what the caller
// must fix before any row is even read); the row checks below are unchanged.

// ── Runtime-requirements probe (existence-only; never calls the probed
// globals, costs no agent call and no tokens). Hard requirements throw here
// naming the missing global — before the Validate marker, before any agent
// activity. Facade-covered globals only log a degradation line each; their
// designed fallbacks (ledger / inline) engage downstream.
if (typeof agent !== 'function') {
  throw new Error('surplus-execute: missing hard runtime requirement: agent — no step executor exists in this runtime; refusing to start')
}
if (typeof phase !== 'function') {
  throw new Error('surplus-execute: missing hard runtime requirement: phase — phase markers do not exist in this runtime; refusing to start')
}
log('probe: hard runtime requirements present: agent, phase')
if (typeof budget === 'undefined') {
  log('probe: degradation — budget global absent; ledger facade fallback engages (local totals, estimated charges marked)')
}
if (typeof workflow !== 'function') {
  log('probe: degradation — workflow global absent; inline step-execution fallback engages (no nested runs)')
}

phase('Validate')

caps = probeCapabilities()
if (!caps.steps) {
  throw new Error('surplus-execute: no step executor available (neither the workflow global nor the agent global exists in this runtime)')
}
if (caps.budget === 'ledger' && caps.steps === 'nested') {
  throw new Error('surplus-execute: ledger mode does not support nested workflow (a nested run\'s internal agent costs are invisible to the local ledger); refusing to run rather than fabricate the ledger')
}
if (!repoRoot || typeof repoRoot !== 'string' || repoRoot.charAt(0) !== '/') {
  throw new Error('surplus-execute: repo_root arg is required and must be an absolute path (no default: a defaulted root silently writes outside the repo), got: ' + String(repoRoot))
}
if (caps.budget === 'ledger' && typeof budgetTotalArg !== 'number') {
  throw new Error('surplus-execute: budget_total arg is required in ledger mode (this runtime exposes no native budget global to delegate to), got: ' + String(budgetTotalArg))
}
log('Modes: budget=' + caps.budget + ', steps=' + caps.steps + ', repo_root=' + repoRoot)

var repoRootNorm = repoRoot.replace(/\/+$/, '')
function anchored(rel) { return repoRootNorm + '/' + rel }

log('Validating ' + sidecarRows.length + ' sidecar rows...')

for (var vi = 0; vi < sidecarRows.length; vi++) {
  var row = sidecarRows[vi]
  if (typeof row.id !== 'string' || row.id.length === 0) {
    throw new Error('Sidecar validation failed: row ' + vi + ' missing or invalid id (string required)')
  }
  if (typeof row.safety_flag !== 'boolean') {
    throw new Error('Sidecar validation failed: row ' + vi + ' (' + row.id + ') safety_flag must be boolean, got ' + typeof row.safety_flag)
  }
  if (typeof row.auto_eligible !== 'boolean') {
    throw new Error('Sidecar validation failed: row ' + vi + ' (' + row.id + ') auto_eligible must be boolean, got ' + typeof row.auto_eligible)
  }
  if (typeof row.expected_value !== 'number') {
    throw new Error('Sidecar validation failed: row ' + vi + ' (' + row.id + ') expected_value must be number, got ' + typeof row.expected_value)
  }
  if (typeof row.summary !== 'string' || row.summary.length === 0) {
    throw new Error('Sidecar validation failed: row ' + vi + ' (' + row.id + ') missing or invalid summary (non-empty string required)')
  }
}

log('Validation passed: ' + sidecarRows.length + ' rows OK')

// ── Step 1: Filter (SA P0-1: strict equality, not truthiness) ────

var eligible = sidecarRows
  .filter(function(r) { return r.auto_eligible === true && r.safety_flag === false })
  .sort(function(a, b) { return b.expected_value - a.expected_value })

var needsYou = sidecarRows.filter(function(r) { return r.safety_flag === true })

var notEligible = sidecarRows.filter(function(r) {
  return r.auto_eligible !== true && r.safety_flag !== true
})

for (var nyi = 0; nyi < needsYou.length; nyi++) needsYou[nyi].reason = 'safety_flag'

log('Eligible: ' + eligible.length + ' | Needs You (SAFETY): ' + needsYou.length + ' | Not eligible: ' + notEligible.length)

// ── Branch 0: pre-flight routing (per row, before synthesis) ─────
// Stage A: zero-cost deterministic signal pre-screen over the row text.
// Stage B: one read-only agent adjudicates three dimensions from on-disk
// evidence. Routing is fail-closed: a missing dimension, a missing status
// field, or an adjudication error never defaults to "proceed" — defaults
// do not get to overrule a human's recorded disposition.

var PREREQ_SIGNALS = ['grant', '授权', '批准', '命名', 'pins', 'Gate 4', 'acceptance', 'resumption', 'pending human', 'Needs human', '待人', '人授', '出网']
var DECIDED_SIGNALS = ['已决策', '已批准', 'decided', 'approved', '待应用', 'DECIDED']

function stageASignals(task) {
  var text = ((task.title || '') + '\n' + (task.summary || '') + '\n' + (task.deliverable || '')).toLowerCase()
  var found = []
  var tables = [['prereq', PREREQ_SIGNALS], ['decided', DECIDED_SIGNALS]]
  for (var t = 0; t < tables.length; t++) {
    for (var s = 0; s < tables[t][1].length; s++) {
      var sig = tables[t][1][s]
      if (text.indexOf(sig.toLowerCase()) >= 0) found.push(tables[t][0] + ':' + sig)
    }
  }
  return found
}

function preflightPrompt(task, signals) {
  var targets = (task.target_paths && task.target_paths.length) ? task.target_paths.join(', ') : '(none listed)'
  return 'You are a READ-ONLY pre-flight adjudicator for one surplus-burn execution row. Do not modify, create, or delete any file. Investigate the on-disk evidence and return the structured verdict only.\n\n' +
    'Repo root (resolve every relative path below against it): ' + repoRootNorm + '\n\n' +
    'Row under adjudication:\n' +
    '- id: ' + task.id + '\n' +
    '- title: ' + (task.title || '') + '\n' +
    '- summary: ' + (task.summary || '') + '\n' +
    '- deliverable: ' + (task.deliverable || '') + '\n' +
    '- source kind: ' + (task.source || '') + '\n' +
    '- target_paths (repo-relative): ' + targets + '\n\n' +
    'Deterministic pre-screen signals found in the row text: ' + (signals.length ? signals.join(', ') : 'none') + '\n\n' +
    'Read the target files (if a target path is a directory, inspect its contents as relevant) and adjudicate THREE dimensions:\n\n' +
    '1) prereq_lock — completion of this row is gated on a concrete input that only a human can supply and that has not yet been supplied: a grant, an authorization to proceed with THIS row, a naming decision, staging pins, a Gate 4 pass for this row, or a human acceptance act named as a step in the deliverable. hit=true requires an evidence quote copied verbatim from the row text or a target file, and the quote must name the outstanding input or state that the row is parked or waiting for it. Scope limit: a statement that merely records that a past decision or approval does NOT exist or was never granted (for example "Needs human — not approved") is provenance evidence for dimension 3 (approval), NOT a prereq_lock hit, unless the same statement also names a concrete outstanding input of the kinds listed above.\n\n' +
    '2) landed — has the work this row asks for already been delivered on disk, with only the source-row close-out missing? Judge ONLY from decidable status surfaces: (i) structured status fields in target files (e.g. frontmatter status:), (ii) checklist close-out marks in source lists (checked / struck / archived lines), (iii) Status/Progress lines in HANDOFF or Epic files and the existence plus verdict of COMPLETION or review files for the same work. state=\'landed\' requires positive on-disk evidence — cite the paths in evidence_paths. Work that is merely described or planned is \'not-landed\'. If a target file does not exist, cannot be read, or exposes NO decidable status surface, state=\'unknown\'. \'unknown\' is the restrictive value of this dimension: never return \'not-landed\' when the status surface you relied on is missing. In landed.status_missing, list each status field that was absent or unreadable and that you would otherwise have relied on.\n\n' +
    '3) approval — does the row text claim a decision or approval (decided / approved / awaiting application)? If it claims none, state=\'not-claimed\'. If it claims one, find its provenance in the source files: a recorded approval by the deciding party means \'verified\' (quote it in source_quote); the source records the opposite or no provenance exists means \'unverified\' (quote what the source actually says in source_quote). Attribution: statements about whether a claimed decision EXISTS — including a Status line stating the row was never approved (e.g. "Needs human — not approved") — belong to THIS dimension, even when they contain words like "Needs human"; dimension 1 captures only concrete outstanding human-supplied inputs.\n\n' +
    'Missing-status rule: whenever a status field you would rely on is absent or unreadable in a source file, treat that dimension by its RESTRICTIVE value (locked / unknown / unverified) and add the bare field name to the top-level status_missing list (e.g. "status", "approval status"). For the landed dimension the restrictive value is \'unknown\': \'not-landed\' is a pass-through value that requires positive on-disk evidence of unfinished work, and must never be returned for a dimension whose status surface is missing. Report every absent field in status_missing even when you also set the dimension\'s restrictive value — the executor re-derives the restrictive routing deterministically from the status_missing list.\n\n' +
    'Non-default rule: every pre-screened signal above MUST receive a non-default adjudication grounded in evidence you actually read — never return a clean/default verdict for a signaled dimension without reading the evidence.\n\n' +
    'Return the verdict object only.'
}

function routePreflight(record) {
  if (record.prereq_lock && record.prereq_lock.hit) return { disposition: 'needs_you', reason: 'human-prerequisite-lock' }
  if (record.landed && record.landed.state === 'landed') return { disposition: 'skipped', reason: 'already-landed' }
  if (record.approval && record.approval.state === 'unverified') return { disposition: 'needs_you', reason: 'approval-unverified' }
  if (record.landed && record.landed.state === 'unknown') return { disposition: 'needs_you', reason: 'status-unverified' }
  return null
}

function preflightEvidenceText(record) {
  var parts = []
  if (record.prereq_lock && record.prereq_lock.evidence) parts.push(record.prereq_lock.evidence)
  if (record.landed && record.landed.evidence_paths && record.landed.evidence_paths.length) parts.push(record.landed.evidence_paths.join(', '))
  if (record.approval && record.approval.source_quote) parts.push(record.approval.source_quote)
  if (record.status_missing && record.status_missing.length) parts.push(record.status_missing.join(', '))
  if (record.normalization && record.normalization.length) parts.push(record.normalization.join(', '))
  return parts.join(' | ')
}

function normalizePreflightRecord(record) {
  record.normalization = []
  var implicated = { prereq: false, landed: false, approval: false }
  var via = { prereq: '', landed: '', approval: '' }
  var landMissing = (record.landed && record.landed.status_missing) || []
  if (landMissing.length) { implicated.landed = true; via.landed = landMissing[0] }
  var merged = record.status_missing || []
  for (var i = 0; i < merged.length; i++) {
    var bare = String(merged[i]).replace(/^status-missing: /, '')
    if (/gate|prereq|grant|前置/i.test(bare)) { if (!implicated.prereq) { implicated.prereq = true; via.prereq = bare } }
    else if (/approval|批准|decision|决策/i.test(bare)) { if (!implicated.approval) { implicated.approval = true; via.approval = bare } }
    else { if (!implicated.landed) { implicated.landed = true; via.landed = bare } }
  }
  if (implicated.prereq && record.prereq_lock && !record.prereq_lock.hit) {
    record.prereq_lock.hit = true
    if (!record.prereq_lock.evidence) record.prereq_lock.evidence = 'status-missing gate field (normalized)'
    record.normalization.push('normalized: prereq_lock.hit false -> true (status-missing: ' + via.prereq + ')')
  }
  if (implicated.landed && record.landed && record.landed.state === 'not-landed') {
    record.landed.state = 'unknown'
    record.normalization.push('normalized: landed.state not-landed -> unknown (status-missing: ' + via.landed + ')')
  }
  if (implicated.approval && record.approval && record.approval.state !== 'unverified') {
    var oldApproval = record.approval.state
    record.approval.state = 'unverified'
    record.normalization.push('normalized: approval.state ' + oldApproval + ' -> unverified (status-missing: ' + via.approval + ')')
  }
  return record
}

async function runPreflight(task) {
  var signals = stageASignals(task)
  var verdict = await agent(preflightPrompt(task, signals), { label: 'preflight:' + task.id, phase: 'Execute', schema: PREFLIGHT_SCHEMA })
  chargeAgent(verdict)
  if (!verdict || !verdict.prereq_lock || !verdict.landed || !verdict.approval) {
    return { error: 'preflight agent returned no valid verdict' }
  }
  var missing = []
  var rawMissing = verdict.status_missing || []
  for (var m = 0; m < rawMissing.length; m++) missing.push('status-missing: ' + rawMissing[m])
  var landMissing = (verdict.landed && verdict.landed.status_missing) || []
  for (var n = 0; n < landMissing.length; n++) {
    var entry = 'status-missing: ' + landMissing[n]
    if (missing.indexOf(entry) < 0) missing.push(entry)
  }
  var record = { signals: signals, prereq_lock: verdict.prereq_lock, landed: verdict.landed, approval: verdict.approval, status_missing: missing }
  normalizePreflightRecord(record)
  return { record: record, route: routePreflight(record) }
}

// ── Step runner ──────────────────────────────────────────────────
// Nested mode: the original yolo-epic workflow() call, argument object
// unchanged (scriptPath anchored). Inline mode: the same four steps run
// sequentially with agent(), same ctx in, same result contract out
// (failure surfaces as an `error` or `stop_reason` field, never a throw).
// Known inline differences: no worktree isolation; steps run sequentially
// inside this script. The mode is recorded on each executed row.

function designPromptInline(ctx) {
  return 'You are Alex, a Solution Lead executing YOLO Epic Phase ' + ctx.phase_number + ' design (inline step runner).\n\n' +
    '## Context\nThis is Phase ' + ctx.phase_number + ' of a surplus-burn EPHEMERAL epic.\nEpic: ' + ctx.epic_path + '\nPhase name: ' + ctx.phase_name + '\n\n' +
    'IMPORTANT: Read the Epic file above — it defines exactly what this phase builds. Do NOT re-read the whole repo history.\n\n' +
    '## Step 1: Design Verification\nRead the Epic (Phase ' + ctx.phase_number + ' section) and verify:\n- Scope is clear and bounded\n- Deliverables are well-defined\n- Any blocking decision has already been made by the human (surplus rows are pre-approved); if something is genuinely ambiguous, make the smallest reasonable choice and record it as an assumption in the handoff.\n\n' +
    '## Step 2: Write Handoff\n1. Read template: ' + anchored('.tad/templates/handoff-a-to-b.md') + '\n2. Write handoff to: ' + ctx.handoff_path + '\n\n' +
    'The handoff MUST be at least 50 lines and MUST include: context (why this phase, what it delivers), exact file paths to create/modify, acceptance criteria, implementation notes, and verification steps.\n\n' +
    'Do NOT spawn subagents (no Agent tool, no Task tool). Do all the work yourself.\n\n' +
    '## Output\nReport: handoff_written (bool), handoff_path, line_count, scope_clarity (CLEAR or NEEDS_CLARIFICATION), open_questions count.'
}

function reviewPromptInline(ctx, kind) {
  var evidenceDir = anchored('.tad/evidence/yolo/' + ctx.epic_slug + '/')
  var role = kind === 'cr'
    ? 'You are a code-reviewer for YOLO Epic Phase ' + ctx.phase_number + ' design review (inline step runner).'
    : 'You are a domain expert (backend architecture) reviewing YOLO Epic Phase ' + ctx.phase_number + ' design (inline step runner).'
  var focus = kind === 'cr'
    ? '- Is the handoff actionable (exact paths, explicit ACs)?\n- Any missing edge cases or error handling?\n- Verification steps present and concrete?'
    : '- Architecture soundness of the design\n- Blast radius: does the phase touch more than it should?\n- Alignment with existing patterns in the repo'
  var file = evidenceDir + 'phase' + ctx.phase_number + '-review-' + kind + '.md'
  return role + '\n\nRead the Epic: ' + ctx.epic_path + ' (Phase ' + ctx.phase_number + ')\nRead the handoff: ' + ctx.handoff_path + '\n\nFocus on:\n' + focus + '\n\nWrite your review to: ' + file + '\nReport findings as P0 (blocking) / P1 (important) / P2 (minor) counts with a verdict.'
}

function implPromptInline(ctx) {
  return 'You are Blake, an Execution Master implementing YOLO Epic Phase ' + ctx.phase_number + ' (inline step runner).\n\n' +
    '## Input\nRead the handoff FIRST: ' + ctx.handoff_path + '\nThe handoff is your specification: exact files, acceptance criteria, verification steps.\n\n' +
    '## Rules\n- Implement EXACTLY what the handoff specifies. Do not expand scope.\n- Run every verification step the handoff lists before claiming completion.\n- Do NOT spawn subagents (no Agent tool, no Task tool). Do all the work yourself.\n- Do NOT run git commands: this repo forbids git in the working folder; the conductor handles version control.\n\n' +
    '## Completion report\nWrite to: ' + ctx.completion_path + '\nAt least 30 lines, including: deliverables produced (paths), how each acceptance criterion was verified (with evidence), any friction encountered, and a self-check statement (Layer 1: did you run the handoff\'s own verification steps and did they pass?).\n\n' +
    '## Output\nReport: completion_written (bool), completion_path, files_changed (count), layer1_passed (bool), summary.'
}

function implReviewPromptInline(ctx, kind) {
  var evidenceDir = anchored('.tad/evidence/yolo/' + ctx.epic_slug + '/')
  var role = kind === 'cr'
    ? 'You are a code-reviewer for YOLO Epic Phase ' + ctx.phase_number + ' implementation review (inline step runner).'
    : 'You are a domain expert reviewing YOLO Epic Phase ' + ctx.phase_number + ' implementation (inline step runner).'
  var focus = kind === 'cr'
    ? '- Are all ACs from the handoff met?\n- Code quality: no obvious bugs, security issues, or regressions\n- The work matches what the completion report claims'
    : '- Architecture quality, blast radius, and implementation completeness'
  var file = evidenceDir + 'phase' + ctx.phase_number + '-impl-review-' + kind + '.md'
  return role + '\n\nRead the completion report: ' + ctx.completion_path + '\nRead the original handoff: ' + ctx.handoff_path + '\nInspect the changed files named in the completion report.\n\nFocus on:\n' + focus + '\n\nWrite your review to: ' + file + '\nReport findings as P0/P1/P2 counts with a verdict.'
}

async function runStepsInline(ctx) {
  var out = { handoff_path: ctx.handoff_path, completion_path: ctx.completion_path, steps_executed: ctx.steps, step_mode: 'inline' }
  var spawned = 0
  var want = function (s) { return ctx.steps.indexOf(s) >= 0 }

  if (want('design')) {
    var design = await agent(designPromptInline(ctx), { label: 'y3-alex-inline', phase: 'Execute', schema: DESIGN_RESULT_SCHEMA })
    chargeAgent(design); spawned++
    if (!design || !design.handoff_written || design.line_count < 50) {
      log('Inline design: first attempt insufficient — one coaching retry')
      design = await agent(designPromptInline(ctx) + '\n\nRETRY: the previous attempt did not produce a qualifying handoff (missing or under 50 lines). Write the complete handoff now, at least 50 lines, to the exact path above.', { label: 'y3-alex-inline-retry', phase: 'Execute', schema: DESIGN_RESULT_SCHEMA })
      chargeAgent(design); spawned++
    }
    if (!design || !design.handoff_written) return { error: 'design_failed_inline', detail: design || null }
    out.design = design
    if (design.line_count < 50) {
      out.stopped_at = 'design'
      out.stop_reason = 'handoff too short after retry (' + design.line_count + ' lines)'
      return out
    }
  }

  if (want('review')) {
    var cr = await agent(reviewPromptInline(ctx, 'cr'), { label: 'y4-cr-inline', phase: 'Execute', schema: REVIEW_RESULT_SCHEMA, agentType: 'code-reviewer' })
    chargeAgent(cr); spawned++
    var arch = await agent(reviewPromptInline(ctx, 'arch'), { label: 'y4-arch-inline', phase: 'Execute', schema: REVIEW_RESULT_SCHEMA, agentType: 'backend-architect' })
    chargeAgent(arch); spawned++
    var reviews = []
    if (cr) reviews.push(cr)
    if (arch) reviews.push(arch)
    if (reviews.length === 0) return { error: 'review_failed_inline', detail: 'all reviewers returned null' }
    var p0 = 0
    for (var rv = 0; rv < reviews.length; rv++) p0 += reviews[rv].p0_count || 0
    out.design_reviews = reviews
    out.design_review_p0_count = p0
    if (p0 > 0) {
      out.stopped_at = 'review'
      out.stop_reason = 'design review found ' + p0 + ' P0 issue(s)'
      return out
    }
  }

  var implOk = false
  if (want('implement')) {
    var impl = await agent(implPromptInline(ctx), { label: 'y5-blake-inline', phase: 'Execute', schema: IMPL_RESULT_SCHEMA })
    chargeAgent(impl); spawned++
    if (!impl || !impl.completion_written) {
      out.implementation = { error: 'no completion report', raw: impl || null }
      out.impl_skipped_reason = 'implementation failed — no completion to review'
    } else {
      out.implementation = impl
      implOk = true
    }
  }

  if (want('impl_review')) {
    if (want('implement') && !implOk) {
      out.impl_reviews = []
      out.impl_review_p0_count = 0
      out.impl_review_skipped = true
    } else {
      var icr = await agent(implReviewPromptInline(ctx, 'cr'), { label: 'y6-cr-inline', phase: 'Execute', schema: REVIEW_RESULT_SCHEMA, agentType: 'code-reviewer' })
      chargeAgent(icr); spawned++
      var iarch = await agent(implReviewPromptInline(ctx, 'arch'), { label: 'y6-arch-inline', phase: 'Execute', schema: REVIEW_RESULT_SCHEMA, agentType: 'backend-architect' })
      chargeAgent(iarch); spawned++
      var ireviews = []
      if (icr) ireviews.push(icr)
      if (iarch) ireviews.push(iarch)
      if (ireviews.length === 0) {
        out.impl_reviews = []
        out.impl_review_p0_count = -1
        out.stopped_at = 'impl_review'
        out.stop_reason = 'all_reviewers_failed'
        return out
      }
      var ip0 = 0
      for (var ir = 0; ir < ireviews.length; ir++) ip0 += ireviews[ir].p0_count || 0
      out.impl_reviews = ireviews
      out.impl_review_p0_count = ip0
    }
  }

  out.agents_spawned = spawned
  return out
}

async function runSteps(ctx) {
  if (caps.steps === 'nested') {
    return await workflow({ scriptPath: anchored('.tad/workflows/claude/yolo-epic.workflow.js') }, ctx)
  }
  return await runStepsInline(ctx)
}

// ── Step 2+3: Budget loop with ephemeral Epic synthesis ──────────

phase('Execute')

var perTaskReserve = 250000
var consecutiveFail = 0
var results = { executed: [], failed: [], skipped: [], routed: [] }

for (var ti = 0; ti < eligible.length; ti++) {
  var task = eligible[ti]

  // Loop step 1 — budget gate. On trigger, this row and all remaining rows
  // are skipped and the loop exits (no snapshot, no pre-flight for them).
  if (budgetTotal() && budgetRemaining() < perTaskReserve) {
    log('Budget exhausted: ' + Math.round(budgetRemaining() / 1000) + 'K remaining < ' + Math.round(perTaskReserve / 1000) + 'K reserve')
    for (var ri = ti; ri < eligible.length; ri++) {
      results.skipped.push({ id: eligible[ri].id, reason: 'budget exhausted', tokens: 0 })
    }
    break
  }

  log('Task ' + (ti + 1) + '/' + eligible.length + ': ' + task.id + ' (EV=' + task.expected_value + ')')

  // Loop step 2 — row-start snapshot (after the budget gate, before branch 0).
  var beforeSpent = budgetSpent()

  var epicPath = anchored('.tad/active/epics/EPHEMERAL-surplus-' + task.id + '.md')
  var handoffPath = anchored('.tad/active/handoffs/HANDOFF-surplus-' + task.id + '.md')
  var completionPath = anchored('.tad/active/handoffs/COMPLETION-surplus-' + task.id + '.md')

  // Loop step 3 — branch 0: pre-flight routing. A rerouted row is final
  // here; its tokens (the adjudication cost) are accounted before it
  // leaves the loop, and the failure counter is left unchanged.
  var pf = await runPreflight(task)
  if (pf.error) {
    results.failed.push({ id: task.id, reason: 'preflight-error: ' + pf.error, tokens: budgetSpent() - beforeSpent })
    consecutiveFail++
    if (consecutiveFail > 2) { log('Circuit breaker: 3 consecutive failures'); break }
    continue
  }
  if (pf.route) {
    var routedRow = { id: task.id, disposition: pf.route.disposition, reason: pf.route.reason, tokens: budgetSpent() - beforeSpent, preflight: pf.record, evidence: preflightEvidenceText(pf.record) }
    if (pf.route.disposition === 'skipped') routedRow.evidence_paths = (pf.record.landed && pf.record.landed.evidence_paths) || []
    results.routed.push(routedRow)
    log('Pre-flight routed ' + task.id + ' -> ' + pf.route.disposition + ' (' + pf.route.reason + ')')
    continue
  }

  // Step 2: Synthesize ephemeral Epic + handoff
  var synthPrompt = 'Create an ephemeral Epic and handoff for a TAD surplus task, then WRITE both files to disk.\n\n'
    + 'Task ID: ' + task.id + '\n'
    + 'Title: ' + (task.title || task.id) + '\n'
    + 'Summary: ' + task.summary + '\n'
    + 'Deliverable: ' + (task.deliverable || 'implementation per summary') + '\n'
    + 'Source: ' + (task.source || 'backlog') + '\n'
    + 'Value rationale: ' + (task.value_rationale || 'ranked by expected value') + '\n\n'
    + 'You MUST write TWO files using the Write tool:\n'
    + '1. Epic file at: ' + epicPath + '\n'
    + '   Content: minimal Epic markdown (title, goal, single phase, scope)\n'
    + '2. Handoff file at: ' + handoffPath + '\n'
    + '   Content: TAD handoff markdown with YAML frontmatter (task_type: code), requirements, implementation steps, and >=3 acceptance criteria\n\n'
    + 'After writing both files, return phase_name (short name), scope (one-line), and files_written: true.\n'
    + 'Keep it concise — this is for automated execution, not human review.'

  var synth = await agent(synthPrompt, {
    label: 'synth:' + task.id,
    phase: 'Execute',
    schema: EPIC_SYNTH_SCHEMA
  })
  chargeAgent(synth)

  if (!synth || !synth.phase_name || !synth.files_written) {
    results.failed.push({ id: task.id, reason: 'epic synthesis incomplete: ' + (synth ? 'missing phase_name or files_written' : 'agent returned null'), tokens: budgetSpent() - beforeSpent, preflight: pf.record })
    consecutiveFail++
    if (consecutiveFail >= 3) { log('Circuit breaker: 3 consecutive failures'); break }
    continue
  }

  // Step 3: Run the phase (nested yolo-epic workflow, or inline steps)
  var result = await runSteps({
    epic_path: epicPath,
    epic_slug: 'surplus-' + task.id,
    phase_number: 1,
    phase_name: synth.phase_name,
    handoff_path: handoffPath,
    completion_path: completionPath,
    steps: ['design', 'review', 'implement', 'impl_review']
  })

  var tokenSpent = budgetSpent() - beforeSpent

  if (!result || result.error || result.stop_reason) {
    var failReason = 'unknown'
    if (!result) failReason = 'yolo-epic returned null'
    else if (result.error) failReason = String(result.error)
    else if (result.stop_reason) failReason = String(result.stop_reason)

    results.failed.push({ id: task.id, reason: failReason, tokens: tokenSpent, preflight: pf.record })
    consecutiveFail++
    if (consecutiveFail >= 3) { log('Circuit breaker: 3 consecutive failures'); break }
  } else {
    results.executed.push({ id: task.id, title: task.title || task.id, tokens: tokenSpent, result_summary: result, preflight: pf.record, step_mode: caps.steps })
    consecutiveFail = 0
  }
}

// ── Report generation ────────────────────────────────────────────

phase('Report')

var reportLines = []
reportLines.push('# Surplus Report — ' + stamp)
reportLines.push('')
reportLines.push('## Summary')
reportLines.push('- Executed: ' + results.executed.length + ' tasks')
reportLines.push('- Failed: ' + results.failed.length + ' tasks (skipped, honest_partial)')
reportLines.push('- Skipped (budget): ' + results.skipped.length + ' tasks')
reportLines.push('- Needs You: ' + needsYou.length + ' SAFETY tasks (not executed)')
reportLines.push('- Not eligible: ' + notEligible.length + ' tasks')
reportLines.push('- Budget mode: ' + caps.budget)
reportLines.push('- Step mode: ' + caps.steps)
var spentTotal = budgetSpent()
var totalSpentLine = '- Total budget spent: ~' + Math.round(spentTotal / 1000) + 'K tokens'
if (caps.budget === 'ledger' && ledgerEstimated > 0) totalSpentLine += ' (ledger est.)'
reportLines.push(totalSpentLine)
reportLines.push('')

reportLines.push('## Executed Tasks')
if (results.executed.length === 0) {
  reportLines.push('(none)')
} else {
  reportLines.push('| # | Task | Tokens | Evidence |')
  reportLines.push('|---|------|--------|----------|')
  for (var ei = 0; ei < results.executed.length; ei++) {
    var ex = results.executed[ei]
    reportLines.push('| ' + (ei + 1) + ' | ' + ex.id + ' | ~' + Math.round(ex.tokens / 1000) + 'K | .tad/active/handoffs/COMPLETION-surplus-' + ex.id + '.md |')
  }
}
reportLines.push('')

reportLines.push('## Failed Tasks (skipped)')
if (results.failed.length === 0) {
  reportLines.push('(none)')
} else {
  reportLines.push('| # | Task | Error | Tokens Wasted |')
  reportLines.push('|---|------|-------|---------------|')
  for (var fi = 0; fi < results.failed.length; fi++) {
    var fl = results.failed[fi]
    reportLines.push('| ' + (fi + 1) + ' | ' + fl.id + ' | ' + fl.reason + ' | ~' + Math.round((fl.tokens || 0) / 1000) + 'K |')
  }
}
reportLines.push('')

reportLines.push('## 🔒 Needs You (SAFETY — not auto-executed)')
if (needsYou.length === 0) {
  reportLines.push('(none)')
} else {
  reportLines.push('| # | Task | Risk | Why |')
  reportLines.push('|---|------|------|-----|')
  for (var ni = 0; ni < needsYou.length; ni++) {
    var ny = needsYou[ni]
    reportLines.push('| ' + (ni + 1) + ' | ' + ny.id + ' | ' + (ny.risk_tag || 'safety') + ' | safety_flag=true |')
  }
}
reportLines.push('')

if (notEligible.length > 0) {
  reportLines.push('## Not Eligible (informational)')
  reportLines.push('| # | Task | Reason |')
  reportLines.push('|---|------|--------|')
  for (var nei = 0; nei < notEligible.length; nei++) {
    var ne = notEligible[nei]
    reportLines.push('| ' + (nei + 1) + ' | ' + ne.id + ' | auto_eligible=false |')
  }
  reportLines.push('')
}

reportLines.push('## Pre-flight Routing (disposition changes)')
if (results.routed.length === 0) {
  reportLines.push('(none)')
} else {
  reportLines.push('| # | Task | From | To | Reason | Evidence | Tokens |')
  reportLines.push('|---|------|------|----|--------|----------|--------|')
  for (var di = 0; di < results.routed.length; di++) {
    var dr = results.routed[di]
    reportLines.push('| ' + (di + 1) + ' | ' + dr.id + ' | eligible | ' + dr.disposition + ' | ' + dr.reason + ' | ' + (dr.evidence || '') + ' | ' + dr.tokens + ' |')
  }
}
reportLines.push('')

var reportMarkdown = reportLines.join('\n')

return {
  executed: results.executed,
  failed: results.failed,
  skipped: results.skipped,
  needs_you: needsYou.concat(results.routed.filter(function (x) { return x.disposition === 'needs_you' })),
  not_eligible: notEligible,
  routed: results.routed,
  budget_mode: caps.budget,
  step_mode: caps.steps,
  budget_spent: spentTotal,
  report_markdown: reportMarkdown,
  report_path: anchored('.tad/active/SURPLUS-REPORT-' + stamp + '.md')
}
