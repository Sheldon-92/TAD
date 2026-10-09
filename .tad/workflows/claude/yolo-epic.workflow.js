export const meta = {
  name: 'yolo-epic',
  description: 'YOLO Epic phase execution: design + review + implement + impl-review with budget reporting',
  whenToUse: 'When executing a YOLO or semi-auto Epic phase. Called twice per phase: once for design, once for review+implement+impl_review.',
  phases: [
    { title: 'Design', detail: 'Spawn Alex design agent to write HANDOFF.md' },
    { title: 'Review', detail: 'Parallel reviewers evaluate design' },
    { title: 'Implement', detail: 'Blake agent implements in worktree isolation' },
    { title: 'ImplReview', detail: 'Parallel reviewers evaluate implementation IN THE IMPLEMENT WORKTREE (implRoot-aware)' },
    { title: 'Budget', detail: 'Report budget consumption for human checkpoint' }
  ]
}

// ── Schemas ────────────────────────────────────────────────────────

const DESIGN_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    handoff_written: { type: 'boolean' },
    handoff_path: { type: 'string' },
    line_count: { type: 'number' },
    sections_present: { type: 'array', items: { type: 'string' } }
  },
  required: ['handoff_written', 'handoff_path', 'line_count']
}

const REVIEW_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    reviewer_type: { type: 'string' },
    evidence_path: { type: 'string' },
    p0_count: { type: 'number' },
    p1_count: { type: 'number' },
    p2_count: { type: 'number' },
    summary: { type: 'string' },
    findings: { type: 'array', items: { type: 'string' } }
  },
  required: ['reviewer_type', 'evidence_path', 'p0_count', 'p1_count', 'p2_count', 'summary']
}

const IMPL_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    completion_written: { type: 'boolean' },
    completion_path: { type: 'string' },
    worktree_path: { type: 'string' },
    files_changed: { type: 'array', items: { type: 'string' } },
    commit_message: { type: 'string' },
    layer1_passed: { type: 'boolean' },
    escalations: { type: 'array', items: { type: 'string' } }
  },
  required: ['completion_written', 'completion_path', 'layer1_passed']
}

// ── Args parsing (Object.keys workaround — NFR1) ──────────────────

let epicPath = null
let epicSlug = null
let phaseNumber = null
let phaseName = null
let handoffPath = null
let completionPath = null
let groundingPath = null
let reviewerCount = 2
let steps = null
let worktreePathArg = null

if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'epic_path') epicPath = args[keys[i]]
    if (keys[i] === 'epic_slug') epicSlug = args[keys[i]]
    if (keys[i] === 'phase_number') phaseNumber = args[keys[i]]
    if (keys[i] === 'phase_name') phaseName = args[keys[i]]
    if (keys[i] === 'handoff_path') handoffPath = args[keys[i]]
    if (keys[i] === 'completion_path') completionPath = args[keys[i]]
    if (keys[i] === 'grounding_path') groundingPath = args[keys[i]]
    if (keys[i] === 'reviewer_count') reviewerCount = args[keys[i]]
    if (keys[i] === 'steps') steps = args[keys[i]]
    if (keys[i] === 'worktree_path') worktreePathArg = args[keys[i]]
  }
}

// ── Validation ────────────────────────────────────────────────────

if (!epicPath || !epicSlug || phaseNumber === null || phaseNumber < 1 || !phaseName || !handoffPath || !completionPath) {
  log('ERROR: Missing required args. Required: epic_path, epic_slug, phase_number, phase_name, handoff_path, completion_path')
  return {
    error: 'missing required args',
    required: ['epic_path', 'epic_slug', 'phase_number', 'phase_name', 'handoff_path', 'completion_path']
  }
}

const VALID_STEPS = ['design', 'review', 'implement', 'impl_review']
if (!steps || !Array.isArray(steps) || steps.length === 0) {
  log('ERROR: steps must be a non-empty array. Valid steps: ' + VALID_STEPS.join(', '))
  return { error: 'steps required', valid_steps: VALID_STEPS }
}

for (let si = 0; si < steps.length; si++) {
  if (VALID_STEPS.indexOf(steps[si]) === -1) {
    log('ERROR: Invalid step "' + steps[si] + '". Valid: ' + VALID_STEPS.join(', '))
    return { error: 'invalid step: ' + steps[si], valid_steps: VALID_STEPS }
  }
}

const runDesign = steps.indexOf('design') !== -1
const runReview = steps.indexOf('review') !== -1
const runImplement = steps.indexOf('implement') !== -1
const runImplReview = steps.indexOf('impl_review') !== -1

const evidenceBase = '.tad/evidence/yolo/' + epicSlug + '/'
const phasePrefix = 'phase' + phaseNumber

log('YOLO Phase ' + phaseNumber + ' (' + phaseName + '): steps=[' + steps.join(',') + '], reviewers=' + reviewerCount)

var agentsSpawned = 0
const result = {}

// ── Phase: Design (Y3) ───────────────────────────────────────────

if (runDesign) {
  phase('Design')
  log('Y3: Spawning Alex design agent')

  const designPrompt =
    'You are Alex designing a feature for YOLO Epic execution. Follow these steps:\n\n' +
    '1. Read the Epic: ' + epicPath + ' — find Phase ' + phaseNumber + ' (' + phaseName + ') Detail Block\n' +
    '2. Read the grounding file: ' + (groundingPath || evidenceBase + phasePrefix + '-grounding.md') + '\n' +
    '3. Read the handoff template: .tad/templates/handoff-a-to-b.md for section structure\n' +
    '4. Write a complete HANDOFF to: ' + handoffPath + '\n' +
    '   Follow the template section numbering exactly.\n' +
    '   Include YAML frontmatter (task_type, e2e_required, research_required, git_tracked_dirs).\n' +
    '   Include Acceptance Criteria with verification commands.\n' +
    '5. After writing, verify the file exists and report its line count.\n\n' +
    'CONSTRAINTS:\n' +
    '- Prompt contains ONLY file paths — read all content from disk\n' +
    '- Do NOT do expert review — Conductor handles that\n' +
    '- Do NOT call any sub-agents or reviewers\n' +
    '- Do NOT make assumptions about code — read the grounding file for actual state'

  var designResult = await agent(designPrompt, {
    label: 'y3-design',
    phase: 'Design',
    schema: DESIGN_RESULT_SCHEMA
  })
  agentsSpawned++

  if (!designResult || !designResult.handoff_written || designResult.line_count < 50) {
    log('Y3: First attempt produced incomplete handoff (' + (designResult ? designResult.line_count : 0) + ' lines). Retrying...')

    designResult = await agent(
      'Your first attempt produced an incomplete handoff (' +
      (designResult ? designResult.line_count : 0) + ' lines, need > 50).\n' +
      'Re-read these files and produce a COMPLETE handoff:\n' +
      '1. Epic: ' + epicPath + ' — Phase ' + phaseNumber + ' Detail Block\n' +
      '2. Grounding: ' + (groundingPath || evidenceBase + phasePrefix + '-grounding.md') + '\n' +
      '3. Template: .tad/templates/handoff-a-to-b.md\n' +
      '4. Write COMPLETE handoff to: ' + handoffPath + '\n' +
      'Ensure all sections from the template are filled. Include YAML frontmatter.',
      { label: 'y3-design-retry', phase: 'Design', schema: DESIGN_RESULT_SCHEMA }
    )
    agentsSpawned++

    if (!designResult || !designResult.handoff_written || designResult.line_count < 50) {
      log('Y3: Circuit breaker — design failed after 2 attempts')
      return {
        error: 'design_circuit_breaker',
        phase: 'design',
        attempts: 2,
        last_line_count: designResult ? designResult.line_count : 0,
        message: 'Handoff too short after 2 attempts. Conductor should handle honest_partial.'
      }
    }
  }

  log('Y3: Handoff written (' + designResult.line_count + ' lines)')
  result.handoff_path = designResult.handoff_path || handoffPath
  result.handoff_line_count = designResult.line_count
}

// ── Phase: Design Review (Y4) ────────────────────────────────────

if (runReview) {
  phase('Review')
  log('Y4: Spawning ' + reviewerCount + ' design reviewer(s)')

  var reviewPrompts = []

  // code-reviewer is always first (mandatory)
  var crEvidencePath = evidenceBase + phasePrefix + '-design-review-cr.md'
  reviewPrompts.push(function() {
    return agent(
      'You are a code-reviewer for YOLO Epic Phase ' + phaseNumber + ' design review.\n\n' +
      'Read the handoff at: ' + handoffPath + '\n\n' +
      'Focus on:\n' +
      '- File list completeness — are all files that need changing listed?\n' +
      '- AC verifiability — can each AC be mechanically verified?\n' +
      '- Frontmatter correctness — task_type, e2e_required, research_required filled?\n' +
      '- Design coherence — do the requirements match the technical design?\n\n' +
      'First run: mkdir -p ' + evidenceBase + '\n' +
      'Write your review to: ' + crEvidencePath + '\n' +
      'Report findings as P0 (blocking), P1 (should fix), P2 (nice to have).',
      {
        label: 'y4-cr',
        phase: 'Review',
        schema: REVIEW_RESULT_SCHEMA,
        agentType: 'code-reviewer'
      }
    )
  })

  // domain expert (if reviewer_count >= 2)
  if (reviewerCount >= 2) {
    var domainEvidencePath = evidenceBase + phasePrefix + '-design-review-arch.md'
    reviewPrompts.push(function() {
      return agent(
        'You are a domain expert reviewing YOLO Epic Phase ' + phaseNumber + ' design.\n\n' +
        'Read the handoff at: ' + handoffPath + '\n\n' +
        'Auto-detect your domain from the handoff Files to Modify section:\n' +
        '- >50% frontend files (.tsx/.jsx/.css) → focus on frontend architecture\n' +
        '- >50% API/service/DB files → focus on backend architecture\n' +
        '- Auth/secrets/credentials → focus on security\n' +
        '- Default: backend architecture review\n\n' +
        'Focus on architecture quality, blast radius, and design completeness.\n' +
        'First run: mkdir -p ' + evidenceBase + '\n' +
        'Write your review to: ' + domainEvidencePath + '\n' +
        'Report findings as P0/P1/P2.',
        {
          label: 'y4-domain',
          phase: 'Review',
          schema: REVIEW_RESULT_SCHEMA,
          agentType: 'backend-architect'
        }
      )
    })
  }

  var reviewResults = await parallel(reviewPrompts)
  agentsSpawned += reviewPrompts.length

  var validReviews = reviewResults.filter(Boolean)

  if (validReviews.length === 0) {
    log('Y4: Circuit breaker — all reviewers failed/returned null')
    return {
      error: 'review_circuit_breaker',
      phase: 'review',
      message: 'All design reviewers failed. Conductor should handle honest_partial.',
      reviewers_attempted: reviewPrompts.length
    }
  }

  var totalP0 = 0
  for (var ri = 0; ri < validReviews.length; ri++) {
    totalP0 += validReviews[ri].p0_count || 0
  }

  log('Y4: ' + validReviews.length + ' review(s) complete, ' + totalP0 + ' P0(s) found')

  result.design_reviews = validReviews
  result.design_review_p0_count = totalP0

  if (totalP0 > 0) {
    log('Y4: STOPPING — ' + totalP0 + ' P0(s) found in design review. Conductor must fix before proceeding.')
    result.stopped_at = 'review'
    result.stop_reason = 'design review found ' + totalP0 + ' P0(s)'
    return result
  }
}

// ── Phase: Implement (Y5) ────────────────────────────────────────

if (runImplement) {
  phase('Implement')
  log('Y5: Spawning Blake implementation agent (worktree isolation)')

  var implResult = await agent(
    'You are Blake implementing a feature for YOLO Epic Phase ' + phaseNumber + '.\n\n' +
    'Follow these steps exactly:\n' +
    '1. Read the handoff: ' + handoffPath + '\n' +
    '2. Implement all tasks described in the handoff\n' +
    '3. Run these checks (Layer 1):\n' +
    '   - npx tsc --noEmit (must pass)\n' +
    '   - npm test (must pass)\n' +
    '   - npm run lint (if available)\n' +
    '4. Write a completion report to: ' + completionPath + '\n' +
    '   Include: files changed, tsc result, test result, AC verification table\n' +
    '5. Git commit with message: "feat(' + epicSlug + '): ' + phaseName + ' [YOLO Phase ' + phaseNumber + ']"\n' +
    '6. Determine your repo root: run `git rev-parse --show-toplevel` and report the result as worktree_path in your structured output\n' +
    '   Note: if you are running in an isolated worktree, all your paths are relative to THAT root and reviewers will be pointed there.\n\n' +
    'LIMITS:\n' +
    '- Max 3 Layer 1 retry attempts. If same error 3 times → write progress to completion and exit\n' +
    '- Only modify files within the current project root\n' +
    '- If cross-project changes needed → note in completion §Escalations\n\n' +
    'DO NOT:\n' +
    '- Call any reviewer or expert sub-agent\n' +
    '- Make design decisions not in the handoff (note in §Escalations)\n' +
    '- Skip Layer 1 checks',
    {
      label: 'y5-blake',
      phase: 'Implement',
      schema: IMPL_RESULT_SCHEMA,
      isolation: 'worktree'
    }
  )
  agentsSpawned++

  if (!implResult || !implResult.completion_written) {
    log('Y5: Blake did not produce completion report — skipping impl_review')
    result.implementation = { error: 'no completion report', raw: implResult }
    result.impl_skipped_reason = 'implementation failed — no completion to review'
  } else {
    log('Y5: Implementation complete, Layer 1 ' + (implResult.layer1_passed ? 'PASSED' : 'FAILED') + ', worktree_path=' + (implResult.worktree_path || 'unreported'))
    result.completion_path = implResult.completion_path || completionPath
    result.implementation = implResult
    result.worktree_path = implResult.worktree_path || null
  }
}

// ── Phase: Impl Review (Y6) ─────────────────────────────────────

var implSucceeded = result.implementation && !result.implementation.error
if (runImplReview && !implSucceeded && runImplement) {
  log('Y6: SKIPPED — implementation did not succeed, nothing to review')
  result.impl_reviews = []
  result.impl_review_p0_count = 0
  result.impl_review_skipped = true
} else if (runImplReview) {
  phase('ImplReview')
  log('Y6: Spawning ' + reviewerCount + ' implementation reviewer(s)')

  // Resolve where the implementation actually lives (worktree-visibility fix).
  var implRoot = null
  if (result.implementation && result.implementation.worktree_path) implRoot = result.implementation.worktree_path
  if (!implRoot && worktreePathArg) implRoot = worktreePathArg

  var implCompletionRef = completionPath
  if (implRoot) {
    implCompletionRef = completionPath.charAt(0) === '/' ? completionPath : implRoot + '/' + completionPath
  }

  var implLocationNote = ''
  if (implRoot) {
    implLocationNote =
      'The implementation lives in an isolated git worktree at: ' + implRoot + '\n' +
      'Read the completion report at: ' + implCompletionRef + '\n' +
      'Inspect changed files under: ' + implRoot + '\n' +
      'Use `git -C "' + implRoot + '" log -1 --stat` and `git -C "' + implRoot + '" diff HEAD~1` to see the implementation commit.\n' +
      'Your evidence review file is still written to the MAIN repo path given below.\n'
  } else {
    implLocationNote =
      'Read the completion report: ' + completionPath + '\n' +
      'Check the git diff for recent changes.\n' +
      'If the diff/files appear absent, the implementation may live in an unreported worktree — classify as UNVERIFIABLE (P0 with reason \'worktree path unreported\'), never as \'implementation absent\'.\n'
  }

  var implReviewPrompts = []

  // code-reviewer (mandatory)
  var implCrPath = evidenceBase + phasePrefix + '-impl-review-cr.md'
  implReviewPrompts.push(function() {
    return agent(
      'You are a code-reviewer for YOLO Epic Phase ' + phaseNumber + ' implementation review.\n\n' +
      implLocationNote +
      'Read the original handoff: ' + handoffPath + '\n\n' +
      'Focus on:\n' +
      '- Are all ACs from the handoff met?\n' +
      '- Code quality: no obvious bugs, security issues, or regressions\n' +
      '- Diff matches what completion report claims\n\n' +
      'First run: mkdir -p ' + evidenceBase + '\n' +
      'Write your review to: ' + implCrPath + '\n' +
      'Report findings as P0/P1/P2.',
      {
        label: 'y6-cr',
        phase: 'ImplReview',
        schema: REVIEW_RESULT_SCHEMA,
        agentType: 'code-reviewer'
      }
    )
  })

  // domain expert (if reviewer_count >= 2)
  if (reviewerCount >= 2) {
    var implDomainPath = evidenceBase + phasePrefix + '-impl-review-arch.md'
    implReviewPrompts.push(function() {
      return agent(
        'You are a domain expert reviewing YOLO Epic Phase ' + phaseNumber + ' implementation.\n\n' +
        implLocationNote +
        'Read the original handoff: ' + handoffPath + '\n\n' +
        'Focus on architecture quality, blast radius, and implementation completeness.\n' +
        'First run: mkdir -p ' + evidenceBase + '\n' +
        'Write your review to: ' + implDomainPath + '\n' +
        'Report findings as P0/P1/P2.',
        {
          label: 'y6-domain',
          phase: 'ImplReview',
          schema: REVIEW_RESULT_SCHEMA,
          agentType: 'backend-architect'
        }
      )
    })
  }

  var implReviewResults = await parallel(implReviewPrompts)
  agentsSpawned += implReviewPrompts.length

  var validImplReviews = implReviewResults.filter(Boolean)

  if (validImplReviews.length === 0) {
    log('Y6: STOPPING — all impl reviewers failed/returned null (fail-closed)')
    result.impl_reviews = []
    result.impl_review_p0_count = -1
    result.stopped_at = 'impl_review'
    result.stop_reason = 'all_reviewers_failed'
    return result
  } else {
    var implTotalP0 = 0
    for (var iri = 0; iri < validImplReviews.length; iri++) {
      implTotalP0 += validImplReviews[iri].p0_count || 0
    }

    log('Y6: ' + validImplReviews.length + ' review(s) complete, ' + implTotalP0 + ' P0(s) found')

    result.impl_reviews = validImplReviews
    result.impl_review_p0_count = implTotalP0
  }
}

// ── Budget Report ────────────────────────────────────────────────
// Budget REPORTING only — human decides at checkpoint. NOT enforcement.

phase('Budget')

var budgetReport = {
  phase_number: phaseNumber,
  phase_name: phaseName,
  agents_spawned: agentsSpawned,
  steps_executed: steps,
  budget_spent: null,
  budget_remaining: null,
  budget_total: null
}

if (typeof budget !== 'undefined' && budget && budget.total) {
  budgetReport.budget_total = budget.total
  budgetReport.budget_spent = typeof budget.spent === 'function' ? budget.spent() : null
  budgetReport.budget_remaining = typeof budget.remaining === 'function' ? budget.remaining() : null
  log('Budget: spent=' + budgetReport.budget_spent + ', remaining=' + budgetReport.budget_remaining + ', total=' + budgetReport.budget_total)
} else {
  log('Budget: no target set (budget.total is null)')
}

result.budget_report = budgetReport

log('YOLO Phase ' + phaseNumber + ' workflow complete: ' + agentsSpawned + ' agents spawned')

return result
