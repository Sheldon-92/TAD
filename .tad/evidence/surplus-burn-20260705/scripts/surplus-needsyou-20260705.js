export const meta = {
  name: 'surplus-execute',
  description: 'Budget-loop auto-execution of ranked surplus backlog tasks with SAFETY routing',
  phases: [
    { title: 'Validate', detail: 'Schema-check sidecar rows (fail-closed)' },
    { title: 'Execute', detail: 'Budget loop: synthesize ephemeral Epic + yolo-epic per task' },
    { title: 'Report', detail: 'Compile SURPLUS-REPORT digest' }
  ]
}

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

// ── Args inlined (needs-you batch, human-authorized 2026-07-05) ──

var stamp = '2026-07-05-needs-you'
var sidecarRows = [{"id": "gate-roi-measurement", "title": "Gate ROI Measurement — Prove or Falsify TAD's Core Quality Claim", "source": "generated", "summary": "The 2026-06-09 repositioning stress-test (O1/KR2) named 'gate-ROI unproven' as an explicit new gap. TAD's positioning as a quality framework depends on Gates catching real defects, but no measurement exists. Analyze ≥20 historical handoffs from .tad/evidence/traces/ to classify Gate-caught defects by severity and counterfactual impact, producing a verdict: gates net-positive / net-neutral / net-negative vs a no-gate baseline. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved executing this needs-you task via *surplus review.]", "value": 5, "confidence": 0.72, "token_cost": "M", "cost_numeric": 3, "expected_value": 3.5999999999999996, "density": 1.2, "cost_rationale": "Read-only trace analysis across 56 JSONL trace files; no code changes; single output report.", "value_rationale": "O1/KR3 explicitly lists 'gate-ROI unproven' as a new gap; also advances O2/KR1 by producing evidence-grounded upgrade direction (mechanical vs soft enforcement). Without this measurement TAD's core quality positioning remains rhetorical per the repositioning-3-walls research verdict.", "deliverable": "/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/gate-roi-measurement-2026-07.md — analysis of ≥20 handoffs, defect classification table, counterfactual verdict, and a go/no-go recommendation on investing in mechanical gate enforcement", "target_paths": ["/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/gate-roi-measurement-2026-07.md", "/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/"], "safety_flag": false, "risk_tag": "needs-human", "auto_eligible": true}, {"id": "o3-kr3-deep-ask-rounds-4-5", "title": "NotebookLM Deep-Ask Rounds 4+5 — Staleness Trap and Human Skill Growth Evidence", "source": "generated", "summary": "O3/KR3 requires ≥5 cross-source synthesis rounds saved; only 3 exist. The 2026-06-09 research named two unanswered questions: (1) 'Staleness Trap' — how does CLAUDE.md/project-knowledge stay current as Claude capabilities evolve? (2) 'Human skill growth' — is there evidence users gain permanent independent skill or only AI-augmented output? These are the exact research questions for rounds 4 and 5 using the active TAD Evolution Research notebook (37cfefa5, 45 sources). [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved executing this needs-you task via *surplus review.]", "value": 4, "confidence": 0.82, "token_cost": "M", "cost_numeric": 3, "expected_value": 3.28, "density": 1.0933333333333333, "cost_rationale": "Two NotebookLM query sessions plus write-up; no code changes; builds on existing 45-source notebook.", "value_rationale": "Directly closes O3/KR3 (stalled at 3/5 rounds since May) and simultaneously advances O1/KR3 (the two named gaps each map to an O1 capability gap requiring severity assessment).", "deliverable": "Two research findings files: /Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/2026-07-staleness-trap-findings.md and /Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/2026-07-human-skill-growth-findings.md — each with ≥3 cross-source synthesis points and citations. Together these bring O3/KR3 from 3 to 5 rounds (status: DONE).", "target_paths": ["/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/2026-07-staleness-trap-findings.md", "/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/research/2026-07-human-skill-growth-findings.md"], "safety_flag": false, "risk_tag": "needs-human", "auto_eligible": true}, {"id": "pack-behavioral-examples-scaffold", "title": "Pack Behavioral Examples Scaffold — html-anything examples/ Pattern for 3 Pilot Packs", "source": "generated", "summary": "IDEA-20260527-pack-behavioral-examples was promoted but is absent from the backlog. Both Codex and Gemini independent audits named 'validation theater' (13/13 installed confirms file operations, not quality) as a P0 — now codified in principles.md YOLO Audit Findings. The html-anything example.html pattern (each skill ships with a ground-truth output fixture) is the identified solution. Implement examples/ directories for 3 pilot packs with a pack-eval.sh verifier and update Gate 3 to require examples/ for new packs. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved executing this needs-you task via *surplus review.]", "value": 4, "confidence": 0.78, "token_cost": "L", "cost_numeric": 8, "expected_value": 3.12, "density": 0.39, "cost_rationale": "Multiple new files across 3 packs plus a new verifier script and a gate/SKILL.md modification that touches SAFETY zones; L-class scope.", "value_rationale": "O2/KR1 explicitly lists behavioral eval as an upgrade direction (rank #3 in 2026-05-14 prioritization matrix); closes the 'validation theater' P0 from cross-model audit (YOLO Audit Findings principle); the pattern is proven from html-anything evidence.", "deliverable": "examples/ directory with 2 input/output fixture pairs in each of 3 packs (ai-agent-architecture, web-frontend, code-security); /Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/lib/pack-eval.sh running fixtures and checking expected output markers; Gate 3 checklist item 'examples/ present and passing pack-eval.sh' added to gate/SKILL.md", "target_paths": ["/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/ai-agent-architecture/", "/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/web-frontend/", "/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/code-security/", "/Users/sheldonzhao/01-on progress programs/TAD/.tad/hooks/lib/pack-eval.sh", "/Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/gate/SKILL.md"], "safety_flag": false, "risk_tag": "needs-human", "auto_eligible": true}]


// ── Step 0: Sidecar validation (fail-closed — SA P0-2) ───────────

phase('Validate')
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

log('Eligible: ' + eligible.length + ' | Needs You (SAFETY): ' + needsYou.length + ' | Not eligible: ' + notEligible.length)

// ── Step 2+3: Budget loop with ephemeral Epic synthesis ──────────

phase('Execute')

var perTaskReserve = 250000
var consecutiveFail = 0
var results = { executed: [], failed: [], skipped: [] }

for (var ti = 0; ti < eligible.length; ti++) {
  var task = eligible[ti]

  if (budget.total && budget.remaining() < perTaskReserve) {
    log('Budget exhausted: ' + Math.round(budget.remaining() / 1000) + 'K remaining < ' + Math.round(perTaskReserve / 1000) + 'K reserve')
    for (var ri = ti; ri < eligible.length; ri++) {
      results.skipped.push({ id: eligible[ri].id, reason: 'budget exhausted' })
    }
    break
  }

  log('Task ' + (ti + 1) + '/' + eligible.length + ': ' + task.id + ' (EV=' + task.expected_value + ')')

  var beforeSpent = budget.spent()

  // Step 2: Synthesize ephemeral Epic + handoff
  var epicPath = '.tad/active/epics/EPHEMERAL-surplus-' + task.id + '.md'
  var handoffPath = '.tad/active/handoffs/HANDOFF-surplus-' + task.id + '.md'
  var completionPath = '.tad/active/handoffs/COMPLETION-surplus-' + task.id + '.md'

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

  if (!synth || !synth.phase_name || !synth.files_written) {
    results.failed.push({ id: task.id, reason: 'epic synthesis incomplete: ' + (synth ? 'missing phase_name or files_written' : 'agent returned null'), tokens: budget.spent() - beforeSpent })
    consecutiveFail++
    if (consecutiveFail >= 3) { log('Circuit breaker: 3 consecutive failures'); break }
    continue
  }

  // Step 3: Call yolo-epic
  var result = await workflow('yolo-epic', {
    epic_path: epicPath,
    epic_slug: 'surplus-' + task.id,
    phase_number: 1,
    phase_name: synth.phase_name,
    handoff_path: handoffPath,
    completion_path: completionPath,
    steps: ['design', 'review', 'implement', 'impl_review']
  })

  var tokenSpent = budget.spent() - beforeSpent

  if (!result || result.error || result.stop_reason) {
    var failReason = 'unknown'
    if (!result) failReason = 'yolo-epic returned null'
    else if (result.error) failReason = String(result.error)
    else if (result.stop_reason) failReason = String(result.stop_reason)

    results.failed.push({ id: task.id, reason: failReason, tokens: tokenSpent })
    consecutiveFail++
    if (consecutiveFail >= 3) { log('Circuit breaker: 3 consecutive failures'); break }
  } else {
    results.executed.push({ id: task.id, title: task.title || task.id, tokens: tokenSpent, result_summary: result })
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
reportLines.push('- Total budget spent: ~' + Math.round(budget.spent() / 1000) + 'K tokens')
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

var reportMarkdown = reportLines.join('\n')

return {
  executed: results.executed,
  failed: results.failed,
  skipped: results.skipped,
  needs_you: needsYou,
  not_eligible: notEligible,
  report_markdown: reportMarkdown,
  report_path: '.tad/active/SURPLUS-REPORT-' + stamp + '.md'
}
