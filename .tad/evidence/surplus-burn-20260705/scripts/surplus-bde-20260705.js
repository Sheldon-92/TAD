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

// ── Args inlined (batch B/D/E, HUMAN-AUTHORIZED 2026-07-05) ──
// User explicitly approved via AskUserQuestion ('全部烧'): B = 10 safe below-value-floor
// cleanup tasks, D = O1 landscape research refresh, E = TAD universal methodology skeleton.
// Flags reflect that explicit authorization; SAFETY routing was already satisfied by the human decision.

var stamp = '2026-07-05-bde'
var sidecarRows = [{"id": "tad-methodology-skeleton", "title": "TAD universal methodology skeleton for non-dev domains", "source": "next", "summary": "IDEA-20260527: Extract TAD methodology as a domain-agnostic process framework usable by non-developers (design, research, writing, audio production), distinct from the code-specific implementation. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 4, "confidence": 0.6, "token_cost": "L", "cost_numeric": 8, "expected_value": 2.4, "density": 0.3, "cost_rationale": "Requires synthesis across multiple domains and careful abstraction to avoid software-specific assumptions; L-level design work.", "value_rationale": "Enables TAD to expand beyond software development — the user's stated goal (see memory); already validated in practice via voice studio and academic research pack.", "deliverable": "tad-methodology.md core document (domain-agnostic two-agent / four-gate / knowledge-layer model) + one concrete example instantiation for a non-dev domain (e.g., voice production or academic research).", "target_paths": ["docs/", ".tad/project-knowledge/principles.md"], "safety_flag": false, "risk_tag": "needs-human", "auto_eligible": true}, {"id": "o1-landscape-refresh-2026q3", "title": "O1 Competitive Landscape Refresh — reactivate framework-landscape notebook with 2026 Q3 ecosystem update", "source": "generated-alex", "summary": "Reactivate the dormant NotebookLM notebook \"TAD Evolution — AI Agent Framework Landscape 2025-2026\" (id 37cfefa5-52b3-4a8a-a8e3-a83f32150759, 45 sources). Add 2026 Q2-Q3 sources covering: Claude Fable 5 / Mythos 5 release, Codex subagents GA, Claude Code Workflow tool + agent teams, LangGraph/CrewAI/AutoGen current state, agent framework consolidation trends. Then run 2 deep-ask rounds against OBJECTIVES.md O1 KR1-KR3 (framework comparison refresh, TAD differentiators still valid?, new capability gaps). CLI: ~/.tad-notebooklm-venv/bin/notebooklm (use -n 37cfefa5..., use --new on each opening ask per conversation-isolation lesson). Write findings to .tad/evidence/research/framework-landscape/2026-07-q3-refresh-findings.md with Sources: citations per synthesis point + update REGISTRY.yaml status active + last_queried. Degrade to WebSearch if CLI preflight fails. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "deliverable": ".tad/evidence/research/framework-landscape/2026-07-q3-refresh-findings.md with >=5 cross-source synthesis points (each with Sources: line), REGISTRY.yaml updated for notebook 37cfefa5-52b3-4a8a-a8e3-a83f32150759 (topic 'TAD Evolution — AI Agent Framework Landscape', the O1/O3 shared notebook: status active + last_queried + new source_count), and an O1 KR status assessment paragraph", "value": 4, "confidence": 0.7, "expected_value": 2.8, "cost_numeric": 3, "density": 0.93, "token_cost": "M", "risk_tag": "safe", "safety_flag": false, "auto_eligible": true, "value_rationale": "O1 KR1-KR3 all stuck at 🔄 since Q2; ecosystem shifted (Fable 5, Codex subagents GA); dormant notebook is the designated O1 instrument", "cost_rationale": "research task, NotebookLM CLI + 2 ask rounds", "target_paths": [".tad/evidence/research/framework-landscape/"]}, {"id": "classify-scope-word-boundary", "title": "Fix classify_scope: bracket-class word-boundary for hook/trace/registry globs", "source": "next", "summary": "Unbounded substring globs *hook*/*trace*/*registry* false-classify project slugs (webhook-handler→framework, registry-of-products→framework), causing framework candidates to incorrectly fan out cross-project in *evolve. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.9, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.8, "density": 1.8, "cost_rationale": "One hook file, pattern replacement; S-sized.", "value_rationale": "False-positive framework classification causes cross-project evolution noise; fix is known and low-risk.", "deliverable": "Updated classify_scope with bracket-class word-boundary patterns (per architecture.md 2026-04-24) + fixture showing webhook-handler classified as project not framework.", "target_paths": [".tad/hooks/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "version-scheme-inconsistency", "title": "Unify tad.sh version stamp: 2-part TARGET_VERSION vs 3-part source", "source": "next", "summary": "tad.sh stamps downstream version.txt = 2-part MAJOR.MINOR via TARGET_VERSION:537, while source version.txt is 3-part MAJOR.MINOR.PATCH. Deferred from release cycle; decide unified scheme and fix. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.9, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.8, "density": 1.8, "cost_rationale": "Two-file change with a clear decision to make; S-sized.", "value_rationale": "Version inconsistency between source and downstream causes confusing version-gate noise; small fix with permanent clarity benefit.", "deliverable": "Updated tad.sh using 3-part version throughout (or documented decision for 2-part with CHANGELOG entry) + release-verify.sh version check updated to match + all downstream projects stamped consistently.", "target_paths": ["tad.sh", ".tad/hooks/lib/release-verify.sh"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "dream-scanner-pass-c-hardening", "title": "Bundle: Dream scanner Pass C — dedup, scope mis-tag, fromjson error guard", "source": "next", "summary": "Three pending bugs in dream-scanner Pass C: (a) no dedup against existing project-knowledge before emit; (b) file=null on decision_point causes framework overrides to mis-classify as project scope; (c) fromjson error on malformed context yields junk candidate instead of safe fallback. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.85, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.7, "density": 1.7, "cost_rationale": "Three targeted fixes in one hook file; no new abstraction; S-sized bundle.", "value_rationale": "Prevents junk/duplicate candidates from polluting the dream queue, improving the signal-to-noise ratio of the auto-evolve pipeline.", "deliverable": "Updated dream-scanner hook with all three fixes + 3 fixtures: (a) duplicate suppressed, (b) file=null classified as framework, (c) malformed context → 'unknown' with no junk candidate emitted.", "target_paths": [".tad/hooks/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "multi-table-decision-parser-rebind", "title": "Fix emit_decision_points: re-bind havehdr on new Decision Summary tables", "source": "next", "summary": "emit_decision_points locks havehdr on the FIRST Decision Summary table and never re-binds, so 2nd+ decision tables in one §11 are silently dropped. Also a trailing non-Decision table over-emits with stale indices. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.85, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.7, "density": 1.7, "cost_rationale": "Single hook file fix with clear logic change; S-sized.", "value_rationale": "Silent data loss in multi-table handoffs corrupts the trace record used by *optimize and trajectory eval; worth fixing before more traces accumulate.", "deliverable": "Updated hook with havehdr re-bind logic when a fresh row's cells are decision+chosen + fixture proving a 2-table §11 emits both tables' decisions correctly.", "target_paths": [".tad/hooks/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "express-frontmatter-tier-marker", "title": "Add express: true frontmatter field consumed by layer2-audit", "source": "next", "summary": "layer2-audit currently uses slug-naming convention as proxy for express tier, causing false >=2-reviewer WARN for any express handoff that forgets 'express' in its slug. Durable fix: express: true frontmatter field that layer2-audit reads directly. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.85, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.7, "density": 1.7, "cost_rationale": "2-file change (template + audit script); clear spec already defined by backend-architect review.", "value_rationale": "Eliminates recurring false-positive review warnings that erode trust in layer2-audit output.", "deliverable": "Handoff template updated with optional express: true field + layer2-audit consumer that reads the field + test fixture showing no false WARN on an express handoff without 'express' in slug.", "target_paths": [".tad/active/handoffs/", ".tad/hooks/lib/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "run-optimize-menu-snap", "title": "Run *optimize on menu-snap to surface execution patterns from 14 traces", "source": "next", "summary": "Pending operational task: run *optimize on the menu-snap project which has 14 trace files, to surface recurring patterns and improvement candidates for the first time since trajectory eval harness landed. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.8, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.6, "density": 1.6, "cost_rationale": "Running an existing command and producing a report; S-sized operational task.", "value_rationale": "First real *optimize run after auto-evolve epic and trajectory eval; will validate the pipeline with real data and produce actionable signal.", "deliverable": "*optimize output report for menu-snap (.tad/evidence/optimize-menu-snap-YYYY-MM-DD.md) listing the top 3 actionable improvement candidates with supporting trace citations.", "target_paths": [".tad/evidence/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "config-env-override", "title": "TAD_* environment variable config override for tad.sh settings", "source": "next", "summary": "IDEA-20260403: Allow TAD settings to be overridden via TAD_* environment variables (e.g. TAD_RELEASE_GATE=warn, TAD_SYNC_DRY_RUN=1) without editing files, enabling non-interactive CI use. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.7, "token_cost": "S", "cost_numeric": 1, "expected_value": 1.4, "density": 1.4, "cost_rationale": "Single-file env-var section + documentation; S-sized.", "value_rationale": "Enables non-interactive CI usage without file edits; already partially needed (TAD_RELEASE_GATE=warn exists for shadow mode).", "deliverable": "tad.sh env-var parsing section + documented override table in README (variable name, default, effect) + CI example in docs/.", "target_paths": ["tad.sh", "docs/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "dream-auto-scope", "title": "Dream scanner auto-scope via git remote hash + 2-project promotion threshold", "source": "next", "summary": "IDEA-20260527: Dream scanner currently has manual scope; add auto-scope using git remote hash to detect which project the trace belongs to, and enforce the 2-project promotion threshold before elevating a pattern to framework-level. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.65, "token_cost": "M", "cost_numeric": 3, "expected_value": 1.3, "density": 0.43333333333333335, "cost_rationale": "Git integration + threshold logic; 2-file change; M-sized.", "value_rationale": "Prevents premature promotion of single-project patterns to the framework knowledge base, improving knowledge quality.", "deliverable": "Updated dream-scanner with git-remote-hash-based project detection + 2-project threshold check against existing project-knowledge + fixture showing a single-project pattern is held vs a 2-project pattern promoted.", "target_paths": [".tad/hooks/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "single-loop-agent-no-framework", "title": "Single-Loop Agent No-Framework Architecture Validation (PostHog Pattern)", "source": "ideas", "summary": "Document TAD's alignment with PostHog's no-framework single-loop agent architecture and evaluate if TAD's multi-skill orchestration could benefit from a dual-model strategy (Claude Sonnet for main loop, cost-effective model for specific reasoning steps). [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 2, "confidence": 0.5, "token_cost": "S", "cost_numeric": 1, "expected_value": 1, "density": 1, "cost_rationale": "Design document only; no code changes unless a specific optimization is accepted.", "value_rationale": "Confirms existing architecture rather than changing it; incremental value from dual-model strategy.", "deliverable": "An ADR at `.tad/evidence/designs/single-loop-validation-adr.md` confirming TAD's architecture matches single-loop principles and recommending specific TAD steps (if any) that would benefit from a cheaper reasoning model.", "target_paths": [".tad/evidence/designs/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}, {"id": "stale-doc-mentions-sep", "title": "Fix stale carry-forward doc mentions from Self-Evolution Pruning", "source": "next", "summary": "Stale T2-era mentions in intent-router-protocol.md L150/L198 + accept-command.md L251 + handoff-a-to-b.md L24 left over from the Self-Evolution Pruning Epic cleanup pass. [HUMAN-AUTHORIZED 2026-07-05: user explicitly approved burning this batch (B/D/E, AskUserQuestion \"全部烧\") beyond the auto-eligible floor.]", "value": 1, "confidence": 0.95, "token_cost": "S", "cost_numeric": 1, "expected_value": 0.95, "density": 0.95, "cost_rationale": "4 targeted line edits across 3 files; trivial S-sized cleanup.", "value_rationale": "Cosmetic but prevents future confusion when maintainers read protocol docs that reference retired concepts.", "deliverable": "3 files updated with stale references removed or corrected — git diff showing only the 4 targeted lines changed, verified by grep confirming no remaining stale T2 terminology.", "target_paths": [".tad/", ".claude/skills/"], "safety_flag": false, "risk_tag": "safe", "auto_eligible": true}]


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
