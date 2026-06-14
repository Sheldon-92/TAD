// ════════════════════════════════════════════════════════════════════════════
// CONTRACT INVARIANTS — DO NOT DRIFT
// ────────────────────────────────────────────────────────────────────────────
// This workflow FORMALIZES handoff_creation_protocol step2-4 (Expert Selection →
// Parallel Expert Review → Feedback Integration) WITHOUT changing the contract.
// Source of truth: .claude/skills/alex/references/handoff-creation-protocol.md
//   (expert_selection_rules, step3, step4 audit_trail_requirement,
//    expert_prompt_template, minimum_experts: 2).
//
// The following invariants MUST hold (each enforced location noted):
//   INV-1  MINIMUM 2 distinct experts.        → enforced Stage 1 (select) + hard guard
//   INV-2  code-reviewer ALWAYS present.       → enforced Stage 1 prompt + hard guard
//   INV-3  Output is the 4-column Audit Trail   → enforced Stage 3 schema:
//          table: Reviewer | Issue | Resolution Section | Status.
//   INV-4  NARROW-SCOPE expert prompts (read    → enforced Stage 2 prompt (verbatim
//          ONLY §6/§9/§10 + listed files; NOT     narrow-scope template) + NOT_ALLOWED
//          full handoff; no free-grep).           clause.
//   INV-5  This workflow REVIEWS only — it does  → no Edit/Write of the handoff; Stage 3
//          NOT auto-fix or auto-edit the handoff.  returns the audit trail for ALEX to
//          Alex owns the handoff; Alex integrates   integrate (preserves "Alex integrates
//          P0s.                                      P0s").
//
// Conditional-expert triggers (expert_selection_rules), reproduced exactly:
//   backend-architect      ← API / database / server-side logic        (when_backend_involved)
//   ux-expert-reviewer     ← UI components / user interaction / layout  (when_frontend_involved)
//   security-auditor       ← auth / user data / API keys / permissions  (when_security_involved)
//   performance-optimizer  ← regex / big-data / API calls / caching     (when_performance_critical)
// ════════════════════════════════════════════════════════════════════════════

export const meta = {
  name: 'handoff-review',
  description: "Formalizes Alex's mandatory Gate 2 handoff expert review (handoff_creation_protocol step2-4): select experts (code-reviewer ALWAYS + conditional, min 2 distinct) → parallel narrow-scope review (read only §6/§9/§10 + listed files; P0/P1/P2 + PASS/CONDITIONAL/FAIL) → compile the 4-column Audit Trail table (Reviewer|Issue|Resolution Section|Status). REVIEWS only — does not auto-edit the handoff; Alex integrates P0s.",
  whenToUse: 'When Alex needs the mandatory pre-handoff (Gate 2) expert review of a handoff draft. Replaces hand-spawned parallel Task calls with a contract-preserving workflow. Input via args={handoff_path} or the DEFAULT const.',
  phases: [
    { title: 'Select', detail: 'Read frontmatter task_type + §6/§7 → choose experts: code-reviewer ALWAYS + conditional per triggers; enforce MINIMUM 2 distinct' },
    { title: 'Review', detail: 'Fan out selected experts in PARALLEL with the NARROW-SCOPE prompt; each outputs P0/P1/P2 + verdict; persist each finding to disk' },
    { title: 'Integrate', detail: 'Compile ALL findings into the 4-column Audit Trail table + overall verdict (does NOT edit the handoff)' }
  ]
}

// ── Args parsing (Object.keys loop — canonical convention, matches gate-review) ──
// ⚠️ KNOWN ISSUE: the `args` global does NOT reliably inject in scriptPath mode.
// So we READ args IF present but FALL BACK to the DEFAULT const below.
// Edit DEFAULT_HANDOFF_PATH for your run, OR pass via args={handoff_path:"path/to/HANDOFF.md"}
// (a bare string handoff path is also accepted).

let handoffPath = null

if (args) {
  if (typeof args === 'string') {
    handoffPath = args
  } else {
    const keys = Object.keys(args)
    for (let i = 0; i < keys.length; i++) {
      if (keys[i] === 'handoff_path') handoffPath = args[keys[i]]
      if (keys[i] === 'handoff') handoffPath = args[keys[i]]   // alias
    }
  }
}

// ── Default — EDIT THIS FOR YOUR RUN (or pass via args) ──────────────────────
const DEFAULT_HANDOFF_PATH = ''  // e.g. '.tad/active/handoffs/HANDOFF-20260613-example.md'

if (!handoffPath) handoffPath = DEFAULT_HANDOFF_PATH

// Evidence output dir — where each expert's findings (review-<expert>.md) are persisted.
const EVIDENCE_DIR = '.tad/evidence/handoff-reviews'

// Fail LOUD on missing input rather than silently no-op (KNOWN ISSUE guard).
if (!handoffPath) {
  log('ERROR: handoff path required. Edit DEFAULT_HANDOFF_PATH at top of file, or pass args={handoff_path:"path/to/HANDOFF.md"} (or a bare string).')
  return { error: 'handoff path required' }
}

log('handoff-review: ' + handoffPath + ' → ' + EVIDENCE_DIR)

// ── Contract data: the 4 conditional experts + always-required (verbatim from
//    expert_selection_rules). Kept as data so the select agent and the hard guard
//    share ONE source. ──────────────────────────────────────────────────────────
const ALWAYS_REQUIRED = 'code-reviewer'                  // INV-2
const CONDITIONAL_EXPERTS = ['backend-architect', 'ux-expert-reviewer', 'security-auditor', 'performance-optimizer']
const VALID_EXPERTS = [ALWAYS_REQUIRED].concat(CONDITIONAL_EXPERTS)

// ── Schemas ──────────────────────────────────────────────────────────────────

const SELECT_SCHEMA = {
  type: 'object',
  required: ['experts', 'task_type', 'rationale'],
  properties: {
    task_type: { type: 'string' },
    experts: {
      type: 'array',
      description: 'Distinct expert agent names. MUST include code-reviewer. MUST be >= 2.',
      items: { type: 'string', enum: VALID_EXPERTS }
    },
    triggered_by: {
      type: 'array',
      description: 'Per conditional expert chosen: which trigger fired (e.g. "backend-architect ← §6 touches API routes").',
      items: { type: 'string' }
    },
    rationale: { type: 'string' }
  }
}

const REVIEW_SCHEMA = {
  type: 'object',
  required: ['expert', 'verdict', 'p0', 'p1', 'p2'],
  properties: {
    expert: { type: 'string' },
    p0: { type: 'array', items: { type: 'string' }, description: 'Critical issues — must fix before implementation' },
    p1: { type: 'array', items: { type: 'string' }, description: 'Recommendations — should address' },
    p2: { type: 'array', items: { type: 'string' }, description: 'Suggestions — nice to have' },
    verdict: { type: 'string', enum: ['PASS', 'CONDITIONAL PASS', 'FAIL'] },
    evidence_path: { type: 'string', description: 'where this expert wrote its full findings' }
  }
}

// INV-3: the 4-column Audit Trail table is the canonical output shape.
const AUDIT_ROW_SCHEMA = {
  type: 'object',
  required: ['reviewer', 'issue', 'resolution_section', 'status'],
  properties: {
    reviewer: { type: 'string', description: 'expert agent name' },
    issue: { type: 'string', description: 'the P0/P1/P2 finding' },
    resolution_section: { type: 'string', description: 'handoff section/AC that resolves it (Alex fills after integration), e.g. "§Task P1.2 实现提示 #3" / "AC-P1.2-i" — or "—" if Open' },
    status: { type: 'string', enum: ['Resolved', 'Open', 'Deferred'] }
  }
}

const INTEGRATE_SCHEMA = {
  type: 'object',
  required: ['experts', 'audit_trail', 'p0_count', 'verdict'],
  properties: {
    experts: { type: 'array', items: { type: 'string' } },
    audit_trail: { type: 'array', items: AUDIT_ROW_SCHEMA },
    p0_count: { type: 'number' },
    verdict: { type: 'string', enum: ['PASS', 'CONDITIONAL PASS', 'FAIL'] }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// STAGE 1 — SELECT (handoff_creation_protocol step2: Expert Selection)
// ════════════════════════════════════════════════════════════════════════════
phase('Select')
log('Stage 1: reading frontmatter task_type + §6/§7 to select experts')

const selection = await agent(
  'You are selecting the expert reviewers for a TAD Gate 2 handoff review. Read the handoff at ' + handoffPath + '.\n\n' +
  'READ ONLY: the YAML frontmatter (`task_type`), §6 (Implementation Steps / Files to Modify), §7 (Files to Modify list). Do NOT read the whole handoff.\n\n' +
  'EXPERT SELECTION RULES (from handoff_creation_protocol.expert_selection_rules — apply EXACTLY):\n' +
  '  • code-reviewer is ALWAYS required (type safety, tests, code structure, execution order). It MUST be in your list.\n' +
  '  • backend-architect    ← add if the work involves API / database / server-side logic.\n' +
  '  • ux-expert-reviewer   ← add if the work involves UI components / user interaction / page layout.\n' +
  '  • security-auditor     ← add if the work involves auth / user data / API keys / permission control.\n' +
  '  • performance-optimizer← add if the work involves regex / big-data processing / API calls / caching.\n\n' +
  'MINIMUM 2 DISTINCT EXPERTS (contract: minimum_experts: 2). If ONLY code-reviewer is triggered by the rules above, you MUST add the single most-relevant SECOND expert for this task_type ' +
  '(judgment: pick the conditional expert whose domain is closest to §6\'s dominant concern — e.g. a yaml/config handoff → backend-architect; a docs/UX handoff → ux-expert-reviewer). Never return fewer than 2.\n\n' +
  'Return: task_type, experts (distinct array, code-reviewer included, length >= 2), triggered_by (which trigger fired per conditional expert), rationale.',
  { label: 'select-experts', phase: 'Select', schema: SELECT_SCHEMA }
)

// ── Hard guard: enforce INV-1 (min 2 distinct) + INV-2 (code-reviewer present) ──
let experts = (selection && Array.isArray(selection.experts)) ? selection.experts.slice() : []
// dedupe + keep only valid expert names
const seen = {}
experts = experts.filter(function (e) {
  if (!e || VALID_EXPERTS.indexOf(e) === -1) return false
  if (seen[e]) return false
  seen[e] = true
  return true
})
// INV-2: code-reviewer ALWAYS present — inject if the agent dropped it
if (experts.indexOf(ALWAYS_REQUIRED) === -1) {
  log('GUARD: code-reviewer missing from selection — injecting (INV-2).')
  experts.unshift(ALWAYS_REQUIRED)
}
// INV-1: minimum 2 distinct — backfill the most-relevant second per task_type
if (experts.length < 2) {
  const tt = (selection && selection.task_type ? String(selection.task_type) : '').toLowerCase()
  // task_type-keyed default second expert (judgment fallback when no trigger fired)
  let second = 'backend-architect'
  if (tt.indexOf('ui') !== -1 || tt.indexOf('front') !== -1 || tt.indexOf('doc') !== -1) second = 'ux-expert-reviewer'
  else if (tt.indexOf('research') !== -1 || tt.indexOf('e2e') !== -1) second = 'performance-optimizer'
  if (second === ALWAYS_REQUIRED) second = 'backend-architect'
  log('GUARD: only ' + experts.length + ' expert(s) selected — backfilling "' + second + '" to satisfy minimum_experts: 2 (INV-1).')
  experts.push(second)
}

// ── TERMINAL assert (INV-1 + INV-2): guarantee >= 2 distinct experts AND at least
//    one non-code-reviewer. Last-resort deterministic backfill from CONDITIONAL_EXPERTS
//    (which can NEVER be code-reviewer). This is the load-bearing guard — earlier
//    backfills are enforced-by-construction, this one ASSERTS the invariant. ──────
if (experts.length < 2 || experts.filter(function (e) { return e !== ALWAYS_REQUIRED }).length < 1) {
  for (let i = 0; i < CONDITIONAL_EXPERTS.length && experts.length < 2; i++) {
    if (experts.indexOf(CONDITIONAL_EXPERTS[i]) === -1) experts.push(CONDITIONAL_EXPERTS[i])
  }
  log('GUARD(terminal): enforced minimum_experts:2 with non-code-reviewer second.')
}

// ── P1-3/P1-4 (cheap honesty): if the select agent died (null/no experts), warn that
//    conditional experts may be missing and we fell back to a safe default. ─────────
if (!selection || !Array.isArray(selection.experts) || selection.experts.length === 0) {
  log('WARN: select agent returned no experts — conditional experts may be MISSING; using safe default selection (' + experts.join(', ') + '). triggered_by/rationale unavailable.')
}

log('Selected ' + experts.length + ' experts: ' + experts.join(', ') + '  (task_type=' + (selection ? selection.task_type : '?') + ')')

// ════════════════════════════════════════════════════════════════════════════
// STAGE 2 — REVIEW (handoff_creation_protocol step3: Parallel Expert Review)
// NARROW-SCOPE prompt = expert_prompt_template verbatim (INV-4).
// ════════════════════════════════════════════════════════════════════════════
phase('Review')
log('Stage 2: fanning out ' + experts.length + ' experts in PARALLEL (narrow-scope)')

const reviews = await parallel(experts.map(function (expertName) {
  return function () {
    return agent(
      'You are the **' + expertName + '** expert reviewing a TAD handoff draft for Gate 2.\n\n' +
      '⚠️ NARROW-SCOPE INSTRUCTION (expert_prompt_template, L6 2026-04-27): Read ONLY the focused sections listed below. ' +
      'Do NOT read the full handoff. Do NOT free-grep the wider codebase except for explicit blast-radius checks you can justify from the sections below. ' +
      'This saves ~50% per review without reducing P0 finding rate (P0s mostly live in §6/§9/diff range).\n\n' +
      'REQUIRED READS:\n' +
      '  - ' + handoffPath + ' §6 (Implementation Steps)\n' +
      '  - ' + handoffPath + ' §9 (Acceptance Criteria) + §9.1 (Spec Compliance Checklist)\n' +
      '  - ' + handoffPath + ' §10 (Important Notes — anti-patterns + warnings)\n' +
      '  - the specific files listed in §7 (Files to Modify) of the handoff\n\n' +
      'OPTIONAL READS (only if the REQUIRED reads alone are ambiguous for a finding you are evaluating):\n' +
      '  - ' + handoffPath + ' §3 (Requirements), §4 (Technical Design), §11 (Decision Summary)\n\n' +
      'FOCUS AREAS (your expert lens — ' + expertName + '):\n' +
      expertFocus(expertName) + '\n\n' +
      'NOT ALLOWED:\n' +
      '  - Free-exploring the wider codebase outside REQUIRED + OPTIONAL + any blast-radius grep you justify\n' +
      '  - Reading the full handoff if §6 + §9 + §10 + listed files is sufficient\n' +
      '  - Writing/editing the handoff or any implementation code (this is a REVIEW only)\n\n' +
      'OUTPUT FORMAT:\n' +
      '  1. Critical Issues (P0 — must fix before implementation)\n' +
      '  2. Recommendations (P1 — should address)\n' +
      '  3. Suggestions (P2 — nice to have)\n' +
      '  4. Overall Assessment (PASS / CONDITIONAL PASS / FAIL)\n\n' +
      'PERSIST your full findings to ' + EVIDENCE_DIR + '/review-' + expertName + '.md, then return the structured result ' +
      '(expert, p0[], p1[], p2[], verdict, evidence_path).',
      { label: 'review:' + expertName, phase: 'Review', schema: REVIEW_SCHEMA }
    )
  }
}))

const validReviews = (reviews || []).filter(Boolean)
log('Stage 2 complete: ' + validReviews.length + '/' + experts.length + ' expert reviews returned')

// ── P1-2 (empty-reviews guard): if ALL expert agents died, do NOT run Stage 3 on
//    empty input — that would compile a vacuous PASS. Fail loud. ─────────────────
if (validReviews.length === 0) {
  log('ERROR: all expert reviews failed (0 valid reviews) — cannot compile an Audit Trail. Returning FAIL.')
  return {
    error: 'all expert reviews failed',
    handoff: handoffPath,
    evidence_dir: EVIDENCE_DIR,
    experts: experts,
    audit_trail: [],
    p0_count: 0,
    verdict: 'FAIL',
    triggered_by: (selection && Array.isArray(selection.triggered_by)) ? selection.triggered_by : [],
    note: 'REVIEW aborted — every expert agent failed to return a result. This is NOT a pass; re-run the review.'
  }
}
// ── P1-2 (honest_partial): partial review is NOT silently complete. ──────────────
if (validReviews.length < experts.length) {
  log('WARN: partial review — only ' + validReviews.length + '/' + experts.length + ' experts returned (honest_partial: the Audit Trail below covers fewer experts than selected, NOT a clean full review).')
}

// ════════════════════════════════════════════════════════════════════════════
// STAGE 3 — INTEGRATE (handoff_creation_protocol step4: Feedback Integration)
// Compile the 4-column Audit Trail table (INV-3). Does NOT edit the handoff (INV-5).
// ════════════════════════════════════════════════════════════════════════════
phase('Integrate')
log('Stage 3: compiling the 4-column Audit Trail from ' + validReviews.length + ' reviews')

const integration = await agent(
  'Compile the expert findings below into the TAD handoff **Audit Trail** — the canonical 4-column table ' +
  '(handoff_creation_protocol step4 audit_trail_requirement; template §9.2).\n\n' +
  'HANDOFF: ' + handoffPath + '\n' +
  'EXPERTS: ' + experts.join(', ') + '\n\n' +
  'ALL EXPERT FINDINGS (JSON):\n' + JSON.stringify(validReviews, null, 2) + '\n\n' +
  'RULES:\n' +
  '  - Produce ONE audit_trail row per distinct issue (P0/P1/P2) across ALL experts.\n' +
  '  - Columns EXACTLY: Reviewer | Issue | Resolution Section | Status.\n' +
  '  - Status MUST be one of: Resolved / Open / Deferred. (At review time, before Alex integrates, ' +
  '    expect most rows to be "Open" — Resolution Section "—". Resolved rows MUST point at a concrete handoff ' +
  '    section/AC (e.g. "§Task P1.2 实现提示 #3" or "AC-P1.2-i"), NOT free text like "已修复".)\n' +
  '  - ⚠️ Do NOT edit the handoff. You only REVIEW and compile the table; ALEX integrates the P0s and fills ' +
  '    the Resolution Section column when he updates the handoff. (Contract: "Alex integrates P0s" — Alex owns the handoff.)\n\n' +
  'Compute p0_count = total distinct P0 issues across all experts. ' +
  'overall verdict: FAIL if any expert FAILed or any P0 exists; CONDITIONAL PASS if only P1/P2 (or any CONDITIONAL PASS); PASS if all experts PASS with no P0.\n\n' +
  'Return: experts[], audit_trail[] (the 4-column rows), p0_count, verdict.',
  { label: 'integrate-audit-trail', phase: 'Integrate', schema: INTEGRATE_SCHEMA }
)

const out = integration || { experts: experts, audit_trail: [], p0_count: 0, verdict: 'CONDITIONAL PASS' }
// Ensure the returned expert list reflects the GUARDED selection (not whatever the agent echoed).
out.experts = experts

// ── P1-1 (INV-3 free-text resolution validator): contract says a "Resolved" row MUST
//    point at a concrete §/AC/step reference — free text ("已修复"/"fixed"/"done"/"—")
//    is NOT acceptable. Downgrade any such row to "Open" so a vacuous "Resolved" can't
//    mask an unaddressed finding. ───────────────────────────────────────────────────
const auditRows = Array.isArray(out.audit_trail) ? out.audit_trail : []
const CITE_RE = /§|AC[-\s]|\bstep\b|#\d/i   // a real resolution cites a section / AC / step / item ref
const FREETEXT_RE = /^\s*(已修复|已解决|修复|fixed|done|resolved|n\/?a|—|-|tbd|todo)?\s*$/i
let downgraded = 0
for (let i = 0; i < auditRows.length; i++) {
  const row = auditRows[i]
  if (!row || row.status !== 'Resolved') continue
  const rs = (row.resolution_section == null) ? '' : String(row.resolution_section)
  const cites = CITE_RE.test(rs)
  const isFreeText = FREETEXT_RE.test(rs)
  if (!cites && (isFreeText || rs.trim() === '')) {
    row.status = 'Open'
    downgraded++
    log('GUARD(INV-3): row "' + (row.issue ? String(row.issue).slice(0, 60) : '?') + '" marked Resolved with non-citing resolution ("' + rs.trim() + '") — downgraded to Open (Resolved MUST cite a §/AC/step).')
  }
}
if (downgraded > 0) log('GUARD(INV-3): downgraded ' + downgraded + ' free-text "Resolved" row(s) to Open.')

// ── P1-5 (verdict reconciliation): contract = any P0 → FAIL. Don't trust the LLM's
//    verdict; recompute the floor from p0_count. ────────────────────────────────────
const p0Count = (typeof out.p0_count === 'number') ? out.p0_count : 0
if (p0Count > 0 && out.verdict !== 'FAIL') {
  log('GUARD(P1-5): p0_count=' + p0Count + ' but verdict was "' + out.verdict + '" — forcing verdict=FAIL (contract: any P0 → FAIL).')
  out.verdict = 'FAIL'
}

log('Stage 3 complete: ' + auditRows.length + ' audit-trail rows, p0_count=' + out.p0_count + ', verdict=' + out.verdict)

return {
  handoff: handoffPath,
  evidence_dir: EVIDENCE_DIR,
  experts: experts,                       // INV-1/INV-2: >= 2 distinct, code-reviewer present
  triggered_by: (selection && Array.isArray(selection.triggered_by)) ? selection.triggered_by : [],  // P1-4: thread Stage 1 trigger provenance
  audit_trail: out.audit_trail || [],     // INV-3: 4-column Reviewer|Issue|Resolution Section|Status (free-text "Resolved" downgraded to Open)
  p0_count: out.p0_count || 0,
  verdict: out.verdict,                   // P1-5: reconciled — any P0 forces FAIL
  partial_review: validReviews.length < experts.length,  // honest_partial signal
  note: 'REVIEW only — Alex must integrate P0s and fill the Resolution Section column when updating the handoff. This workflow does not edit the handoff (INV-5).'
}

// ── Expert-specific FOCUS AREAS (prompt_focus, verbatim from expert_selection_rules) ──
function expertFocus(name) {
  if (name === 'code-reviewer') return '    Review code snippets for type safety, missing interfaces, required tests, code structure, execution order.'
  if (name === 'backend-architect') return '    Review data flow, type extensions, storage patterns, API contracts, system architecture, state management.'
  if (name === 'ux-expert-reviewer') return '    Review UI patterns, accessibility (WCAG), touch targets, visual hierarchy, interaction design, visual consistency.'
  if (name === 'security-auditor') return '    Review auth flows, data exposure risks, injection vulnerabilities, API-key/secret handling, permission control.'
  if (name === 'performance-optimizer') return '    Review regex patterns (ReDoS risk), cost estimates, caching strategies, bottlenecks, big-data handling.'
  return '    Apply your domain expertise to §6/§9/§10 and the listed files.'
}
