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

// ── Args inlined (restart of the user-approved auto-eligible batch after spend-limit
// interruption, 2026-07-05). Rows are VERBATIM from the sidecar (dedup keep-max-EV only,
// no flag mutation) — the workflow's own SAFETY routing stays authoritative. ──

var stamp = '2026-07-05-restart'
var sidecarRows = [{"id": "saveable-skills-from-conversation", "title": "Saveable Skills from Conversation — One-Click Workflow Capture (Linear Agent Pattern)", "source": "ideas", "summary": "Let users save a reusable workflow directly from conversation context with a single *save-workflow command, complementing local-skill-capture with a more discoverable UX inspired by Linear Agent's Skills system.", "value": 4, "confidence": 0.6, "token_cost": "M", "cost_numeric": 3, "expected_value": 2.4, "density": 0.7999999999999999, "cost_rationale": "New skill file + local/ directory; overlaps with local-skill-capture so coordination needed.", "value_rationale": "Natural in-conversation skill emergence lowers the barrier to knowledge capture vs the formal Gate 4 KA cycle.", "deliverable": "A `.claude/skills/save-workflow.md` skill that extracts the current conversation's workflow steps into a structured `.claude/skills/local/{workflow-name}.md` file with auto-detected trigger keywords and usage instructions.", "target_paths": [".claude/skills/save-workflow.md", ".claude/skills/local/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "codex-adapter-yaml", "title": "6-line openai.yaml capability pack Codex adapter", "source": "next", "summary": "IDEA-20260527: Add a minimal codex-adapter.yaml per capability pack so Codex CLI can load pack rules natively via its YAML config format, without needing the full SKILL.md synthesis.", "value": 3, "confidence": 0.75, "token_cost": "S", "cost_numeric": 1, "expected_value": 2.25, "density": 2.25, "cost_rationale": "Schema spec + one install.sh extension + one demo pack; S-sized if kept to the 6-line format.", "value_rationale": "Reduces friction for Codex users to consume capability packs; small concrete artifact with broad downstream impact across all 24 packs.", "deliverable": "codex-adapter.yaml format spec + install.sh extension that writes it to .agents/skills/{pack}/ + one demo pack (e.g., web-backend) with a working adapter verified by codex exec.", "target_paths": [".tad/capability-packs/", ".claude/skills/", ".agents/skills/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "session-health-check", "title": "Framework component integrity check (session-health.sh)", "source": "next", "summary": "IDEA-20260403: A script that verifies core TAD framework components are correctly wired: SKILL.md presence, hook registration in settings.json, version consistency, pack registry coherence.", "value": 3, "confidence": 0.7, "token_cost": "S", "cost_numeric": 1, "expected_value": 2.0999999999999996, "density": 2.0999999999999996, "cost_rationale": "Single new script; no new abstraction; straightforward check logic.", "value_rationale": "Provides fast diagnosis of framework drift that currently requires manual inspection across many files; reusable after every sync.", "deliverable": "session-health.sh with checks for: SKILL.md presence on both platforms, hook wiring in settings.json, version.txt == tad.sh TARGET_VERSION, pack-registry.yaml count matching installed packs — exit 0 or annotated FAIL report.", "target_paths": [".tad/hooks/lib/", ".claude/settings.json"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "structured-feedback-collector", "title": "Structured Feedback Collector — HTML Feedback Interface for Human Judgment", "source": "ideas", "summary": "AI generates both an artifact (code, page, audio, brand) and a structured HTML feedback form alongside it. Human fills the form, exports JSON, and the AI precisely applies the structured changes — replacing ambiguous natural-language feedback.", "value": 4, "confidence": 0.5, "token_cost": "L", "cost_numeric": 8, "expected_value": 2, "density": 0.25, "cost_rationale": "New CLI tool + skill file + HTML template system; large scope but self-contained.", "value_rationale": "Solves the structured human-AI feedback gap that plagues all non-code artifact workflows; applicable across Voice Studio, design, branding, and publishing.", "deliverable": "A CLI command (or TAD skill) that takes an artifact path and generates a paired `{artifact}-feedback.html` form with labeled UI elements; plus a feedback-apply script that reads the exported JSON and maps fields to specific edit instructions.", "target_paths": [".claude/skills/structured-feedback-collector.md", ".tad/hooks/lib/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "agent-capability-packs-phase2-4", "title": "EPIC Agent Capability Packs — remaining phases (real validation, cross-agent, template)", "source": "next", "summary": "EPIC-20260507 is 6/9 phases done. Remaining: Phase 2 (real project validation — use packs in menu-snap, measure quality delta), Phase 3 (cross-agent validation — same pack on Codex), Phase 4 (template extraction — CONSUMES/PRODUCES standard).", "value": 3, "confidence": 0.65, "token_cost": "L", "cost_numeric": 8, "expected_value": 1.9500000000000002, "density": 0.24375000000000002, "cost_rationale": "Three Epic phases each requiring real-project task execution, cross-platform validation, and template authoring for 24 packs.", "value_rationale": "Completing pack validation closes the 'validation theater' gap identified in the YOLO audit; real project deltas are the only proof packs improve agent behavior.", "deliverable": "Pack validation report for menu-snap (quality-delta before/after for >=2 packs) + Codex cross-agent validation result + CONSUMES/PRODUCES template applied to all 24 packs.", "target_paths": [".tad/active/epics/EPIC-20260507-agent-capability-packs.md", ".tad/capability-packs/", ".claude/skills/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "domain-pack-monthly-refresh", "title": "Domain Pack Monthly Refresh — Tools and Skills Periodic Update Mechanism", "source": "ideas", "summary": "Create a repeatable monthly handoff template that audits tools-registry.yaml for stale versions, scans for new MCP servers/CLI tools, and updates domain.yaml skills research.", "value": 3, "confidence": 0.6, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.7999999999999998, "density": 1.7999999999999998, "cost_rationale": "Single template file, no tooling changes required.", "value_rationale": "Keeps packs current with fast-moving tool ecosystem; low cost, repeatable value.", "deliverable": "A `.tad/templates/domain-pack-refresh-handoff.md` template that Blake can execute monthly, with explicit checklist and evidence trail format.", "target_paths": [".tad/templates/", ".tad/domains/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "deterministic-rules-over-llm", "title": "Deterministic Rules Over LLM for Classification (Daria's Desk Pattern)", "source": "ideas", "summary": "Audit TAD's current LLM-based intent routing and identify which classification decisions have clear enough patterns (greeting vs command, *publish vs *sync) to be replaced with 200-line deterministic rules, reducing cost and latency.", "value": 3, "confidence": 0.6, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.7999999999999998, "density": 1.7999999999999998, "cost_rationale": "Audit document plus one small script change; contained and reversible.", "value_rationale": "Faster and cheaper routing for predictable command patterns; Daria's Desk validates the pattern for bounded classification tasks.", "deliverable": "A classification audit report at `.tad/evidence/designs/deterministic-vs-llm-audit.md` listing each TAD routing decision with a deterministic-feasibility score, plus one concrete implementation replacing the lowest-complexity LLM routing with a regex/heuristic equivalent.", "target_paths": [".tad/evidence/designs/", ".tad/hooks/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}]


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
