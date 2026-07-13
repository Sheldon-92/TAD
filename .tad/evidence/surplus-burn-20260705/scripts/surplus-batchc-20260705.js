export const meta = {
  name: 'surplus-batchc',
  description: 'Rerun 2 P0-fixed surplus tasks (deprecate-domain-pack-yaml, tad-self-test-agent) through yolo-epic review→implement→impl_review. Handoff P0s were fixed by Alex; user explicitly authorized this batch (AskUserQuestion 全部烧, 2026-07-05).',
  phases: [
    { title: 'Execute', detail: 'yolo-epic per task on the P0-fixed handoffs' }
  ]
}

var tasks = [
  {
    id: 'deprecate-domain-pack-yaml',
    phase_name: 'yaml-to-capability-pack-migration',
    note: 'P0s fixed by Alex: AC7/AC8 rewritten discriminative (baseline-anchored, all new anchors verified 0 at baseline); §4.1 routing extended for anti_patterns/quality_criteria/reviewers blocks; AC13 added (per-pack anti_patterns survival check, not a global floor).'
  },
  {
    id: 'tad-self-test-agent',
    phase_name: 'self-test-workflow',
    note: 'P0 fixed by Alex: FR2 rewritten SKILL-driven (agent prompts must not enumerate protocol steps; steps must emerge from reading the real SKILL files, SKILL_PATH consts arg-overridable); FR2b + AC14 added (red/green mutation test: stripped-Socratic SKILL copy must produce SELF-TEST: FAIL + MISSING: socratic); AC15 added (zero spoon-fed steps in agent prompts).'
  }
]

phase('Execute')

var results = { executed: [], failed: [] }

for (var ti = 0; ti < tasks.length; ti++) {
  var task = tasks[ti]
  log('Batch C ' + (ti + 1) + '/' + tasks.length + ': ' + task.id + ' — ' + task.note)
  var beforeSpent = budget.spent()

  var result = await workflow('yolo-epic', {
    epic_path: '.tad/active/epics/EPHEMERAL-surplus-' + task.id + '.md',
    epic_slug: 'surplus-' + task.id,
    phase_number: 1,
    phase_name: task.phase_name,
    handoff_path: '.tad/active/handoffs/HANDOFF-surplus-' + task.id + '.md',
    completion_path: '.tad/active/handoffs/COMPLETION-surplus-' + task.id + '.md',
    steps: ['review', 'implement', 'impl_review']
  })

  var tokenSpent = budget.spent() - beforeSpent

  if (!result || result.error || result.stop_reason) {
    var failReason = 'unknown'
    if (!result) failReason = 'yolo-epic returned null'
    else if (result.error) failReason = String(result.error)
    else if (result.stop_reason) failReason = String(result.stop_reason)
    results.failed.push({ id: task.id, reason: failReason, tokens: tokenSpent })
  } else {
    results.executed.push({ id: task.id, tokens: tokenSpent, result_summary: result })
  }
}

return {
  executed: results.executed,
  failed: results.failed,
  report_path: '.tad/active/SURPLUS-REPORT-2026-07-05-batchc.md',
  note: 'Alex must verify impl_review verdicts manually and check worktree paths for deliverables before accepting (known worktree false-FAIL pattern).'
}
