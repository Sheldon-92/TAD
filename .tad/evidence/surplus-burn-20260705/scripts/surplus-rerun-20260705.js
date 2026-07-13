export const meta = {
  name: 'surplus-rerun',
  description: 'Rerun 2 P0-fixed surplus tasks (gate-roi, pack-behavioral) through yolo-epic review→implement→impl_review, skipping synth (handoffs already exist and were P0-fixed by Alex)',
  phases: [
    { title: 'Execute', detail: 'yolo-epic per task on the fixed handoffs' }
  ]
}

// Date stamped at SKILL boundary; args-quirk workaround: everything inlined.
var stamp = '2026-07-05'

var tasks = [
  {
    id: 'gate-roi-measurement',
    phase_name: 'gate-roi-report',
    note: 'P0 fixed by Alex: AC7 rewritten to baseline-diff (comm -13 vs pre-impl snapshot); AC10 counts numeric occurrences not lines.'
  },
  {
    id: 'pack-behavioral-examples-scaffold',
    phase_name: 'examples-scaffold-and-eval',
    note: 'P0 fixed by Alex: §7 file list now includes .agents/skills/ byte-identical mirrors (3 fixtures + gate/SKILL.md); micro-task 8b added; AC row 14 added (release-verify.sh parity + per-file cmp).'
  }
]

phase('Execute')

var results = { executed: [], failed: [] }
var consecutiveFail = 0

for (var ti = 0; ti < tasks.length; ti++) {
  var task = tasks[ti]
  var epicPath = '.tad/active/epics/EPHEMERAL-surplus-' + task.id + '.md'
  var handoffPath = '.tad/active/handoffs/HANDOFF-surplus-' + task.id + '.md'
  var completionPath = '.tad/active/handoffs/COMPLETION-surplus-' + task.id + '.md'

  log('Rerun ' + (ti + 1) + '/' + tasks.length + ': ' + task.id + ' — ' + task.note)

  var beforeSpent = budget.spent()

  var result = await workflow('yolo-epic', {
    epic_path: epicPath,
    epic_slug: 'surplus-' + task.id,
    phase_number: 1,
    phase_name: task.phase_name,
    handoff_path: handoffPath,
    completion_path: completionPath,
    steps: ['review', 'implement', 'impl_review']
  })

  var tokenSpent = budget.spent() - beforeSpent

  if (!result || result.error || result.stop_reason) {
    var failReason = 'unknown'
    if (!result) failReason = 'yolo-epic returned null'
    else if (result.error) failReason = String(result.error)
    else if (result.stop_reason) failReason = String(result.stop_reason)
    results.failed.push({ id: task.id, reason: failReason, tokens: tokenSpent })
    consecutiveFail++
    if (consecutiveFail >= 2) { log('Circuit breaker: 2 consecutive failures'); break }
  } else {
    results.executed.push({ id: task.id, tokens: tokenSpent, result_summary: result })
    consecutiveFail = 0
  }
}

return {
  executed: results.executed,
  failed: results.failed,
  report_path: '.tad/active/SURPLUS-REPORT-' + stamp + '-rerun.md',
  note: 'Alex must verify impl_review verdicts manually (known gap: yolo-epic success != review PASS) and check worktree paths for deliverables before accepting.'
}
