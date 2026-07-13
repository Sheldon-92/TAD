export const meta = {
  name: 'surplus-rerun2',
  description: 'Rerun 2 spend-limit casualties on existing handoffs: local-skill-capture (approved auto batch, design stage was killed by spend limit) + pack-behavioral-examples-scaffold (human-authorized, P0-fixed handoff, review stage was killed by spend limit)',
  phases: [
    { title: 'Execute', detail: 'yolo-epic per task on existing handoffs, synth skipped' }
  ]
}

var stamp = '2026-07-05'

var tasks = [
  {
    id: 'local-skill-capture',
    phase_name: 'save-skill-command',
    steps: ['design', 'review', 'implement', 'impl_review'],
    note: 'From the user-approved auto-eligible batch; first attempt died on monthly spend limit during design (design_circuit_breaker). Handoff exists from synth.'
  },
  {
    id: 'pack-behavioral-examples-scaffold',
    phase_name: 'examples-scaffold-and-eval',
    steps: ['review', 'implement', 'impl_review'],
    note: 'Human-authorized needs-you task; Alex fixed design-review P0 (.agents mirrors + parity AC14). Prior rerun died on spend limit (review_circuit_breaker) before reviewing the fixed handoff.'
  }
]

phase('Execute')

var results = { executed: [], failed: [] }

for (var ti = 0; ti < tasks.length; ti++) {
  var task = tasks[ti]
  log('Rerun ' + (ti + 1) + '/' + tasks.length + ': ' + task.id + ' — ' + task.note)
  var beforeSpent = budget.spent()

  var result = await workflow('yolo-epic', {
    epic_path: '.tad/active/epics/EPHEMERAL-surplus-' + task.id + '.md',
    epic_slug: 'surplus-' + task.id,
    phase_number: 1,
    phase_name: task.phase_name,
    handoff_path: '.tad/active/handoffs/HANDOFF-surplus-' + task.id + '.md',
    completion_path: '.tad/active/handoffs/COMPLETION-surplus-' + task.id + '.md',
    steps: task.steps
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
  report_path: '.tad/active/SURPLUS-REPORT-' + stamp + '-rerun2.md',
  note: 'Alex must verify impl_review verdicts manually and check worktree paths for deliverables before accepting (known worktree false-FAIL pattern).'
}
