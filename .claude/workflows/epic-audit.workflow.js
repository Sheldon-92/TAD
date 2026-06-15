export const meta = {
  name: 'epic-audit',
  description: 'Audit active/parked Epics: fan-out independent analysis + adversarial challenge + synthesis',
  whenToUse: 'When reviewing active Epics for status, blocking reasons, and continue/cancel/archive recommendations',
  phases: [
    { title: 'Analyze', detail: 'One agent per Epic, independent deep analysis' },
    { title: 'Challenge', detail: 'Adversarial reviewer challenges each analysis' },
    { title: 'Synthesize', detail: 'Merge all findings into actionable summary' }
  ]
}

const EPIC_SCHEMA = {
  type: 'object',
  properties: {
    epic_file: { type: 'string' },
    title: { type: 'string' },
    total_phases: { type: 'number' },
    completed_phases: { type: 'number' },
    remaining_phases: { type: 'number' },
    last_activity_date: { type: 'string' },
    days_since_activity: { type: 'number' },
    blocking_reason: { type: 'string' },
    recommendation: { type: 'string', enum: ['continue', 'cancel', 'archive', 'reprioritize'] },
    recommendation_rationale: { type: 'string' },
    effort_to_complete: { type: 'string', enum: ['small', 'medium', 'large'] },
    value_if_completed: { type: 'string' }
  },
  required: ['epic_file', 'title', 'total_phases', 'completed_phases', 'recommendation', 'recommendation_rationale']
}

const CHALLENGE_SCHEMA = {
  type: 'object',
  properties: {
    epic_file: { type: 'string' },
    original_recommendation: { type: 'string' },
    challenge_verdict: { type: 'string', enum: ['agree', 'disagree', 'partially_agree'] },
    challenge_reason: { type: 'string' },
    revised_recommendation: { type: 'string', enum: ['continue', 'cancel', 'archive', 'reprioritize'] },
    blind_spots: { type: 'array', items: { type: 'string' } }
  },
  required: ['epic_file', 'original_recommendation', 'challenge_verdict', 'challenge_reason']
}

const SYNTHESIS_SCHEMA = {
  type: 'object',
  properties: {
    summary: { type: 'string' },
    epics: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          title: { type: 'string' },
          final_recommendation: { type: 'string' },
          confidence: { type: 'string', enum: ['high', 'medium', 'low'] },
          analyst_and_challenger_agreed: { type: 'boolean' },
          key_insight: { type: 'string' }
        }
      }
    },
    workflow_meta: {
      type: 'object',
      properties: {
        total_agents_spawned: { type: 'number' },
        pattern_used: { type: 'string' }
      }
    }
  },
  required: ['summary', 'epics', 'workflow_meta']
}

// args: string[] of Epic file paths, OR undefined (auto-detect from .tad/active/epics/)
let epicPaths = []
if (args) {
  for (let i = 0; i < args.length; i++) { epicPaths.push(args[i]) }
}
if (epicPaths.length === 0) {
  const detected = await agent(
    'List all .md files in .tad/active/epics/ (excluding .gitkeep). Return ONLY a JSON object {"paths": [...]} whose paths array holds the file paths relative to project root, e.g. {"paths": [".tad/active/epics/EPIC-20260403-foo.md"]}. No explanation.',
    { label: 'detect-epics', schema: { type: 'object', properties: { paths: { type: 'array', items: { type: 'string' } } }, required: ['paths'] }, model: 'haiku' }
  )
  if (detected && Array.isArray(detected.paths)) { for (let i = 0; i < detected.paths.length; i++) { epicPaths.push(detected.paths[i]) } }
}

if (epicPaths.length === 0) {
  log('No active Epics found. Nothing to audit.')
  return { summary: 'No active Epics found', epics: [], workflow_meta: { total_agents_spawned: 1, pattern_used: 'none' } }
}

log('Auditing ' + epicPaths.length + ' Epic(s): ' + epicPaths.join(', '))

phase('Analyze')
log('Phase 1: Fan-out - ' + epicPaths.length + ' independent analysts')

const analyses = await parallel(epicPaths.map(epicPath => () =>
  agent(
    'You are an independent Epic analyst. Read the Epic file at ' + epicPath + ' carefully.\n' +
    'Also check:\n' +
    '- git log --oneline --since="2026-05-01" -- "' + epicPath + '" (recent activity)\n' +
    '- ls .tad/active/handoffs/ (any active handoffs referencing this epic)\n' +
    '- The NEXT.md file for any references to this epic slug\n' +
    '- .tad/active/ideas/ for related ideas\n\n' +
    'Based on your analysis, determine:\n' +
    '1. How many phases total vs completed\n' +
    '2. When was the last meaningful activity\n' +
    '3. What specifically is blocking progress\n' +
    '4. Your honest recommendation: continue, cancel, archive, or reprioritize\n' +
    '5. How much effort remains and what value completion would deliver\n\n' +
    'Be brutally honest. "Parked" epics that sit for 60+ days with no activity are\n' +
    'candidates for cancellation unless there is a concrete reason to keep them.',
    { label: epicPath.split('/').pop(), phase: 'Analyze', schema: EPIC_SCHEMA, model: 'sonnet' }
  )
))

const validAnalyses = analyses.filter(Boolean)
log('Phase 1 complete: ' + validAnalyses.length + '/' + epicPaths.length + ' analyses returned')

phase('Challenge')
log('Phase 2: Adversarial challenge - each analysis gets a skeptic')

const challenges = await parallel(validAnalyses.map(analysis => () =>
  agent(
    'You are a skeptical reviewer. An analyst just reviewed an Epic and recommended: "' + analysis.recommendation + '".\n\n' +
    'Their rationale: "' + analysis.recommendation_rationale + '"\n' +
    'Epic: ' + analysis.epic_file + '\n' +
    'Phases: ' + analysis.completed_phases + '/' + analysis.total_phases + ' done\n' +
    'Blocking: ' + (analysis.blocking_reason || 'unknown') + '\n\n' +
    'Read the Epic file yourself at ' + analysis.epic_file + ' and CHALLENGE this recommendation:\n\n' +
    '1. Try to REFUTE it - find reasons the opposite recommendation would be better\n' +
    '2. Check if the analyst missed any context (NEXT.md references, related ideas in .tad/active/ideas/)\n' +
    '3. Consider sunk cost fallacy - is "continue" recommended just because work was already done?\n' +
    '4. Consider premature cancellation - is "cancel" recommended just because it has been quiet?\n' +
    '5. Identify blind spots the analyst may have had\n\n' +
    'After your challenge, give your HONEST verdict: agree, disagree, or partially_agree.\n' +
    'If you disagree, provide a revised recommendation.',
    { label: 'challenge-' + analysis.epic_file.split('/').pop(), phase: 'Challenge', schema: CHALLENGE_SCHEMA, model: 'sonnet' }
  )
))

const validChallenges = challenges.filter(Boolean)
log('Phase 2 complete: ' + validChallenges.length + ' challenges returned')

phase('Synthesize')
log('Phase 3: Synthesis - merge analyst + challenger perspectives')

const result = await agent(
  'You are synthesizing the results of a structured Epic audit.\n\n' +
  'For each Epic, an independent analyst gave a recommendation, and then a separate\n' +
  'skeptical challenger tried to refute it. Your job is to produce the final verdict.\n\n' +
  'ANALYST FINDINGS:\n' + JSON.stringify(validAnalyses, null, 2) + '\n\n' +
  'CHALLENGER FINDINGS:\n' + JSON.stringify(validChallenges, null, 2) + '\n\n' +
  'For each Epic, determine:\n' +
  '1. Final recommendation (weight challenger view when they found concrete blind spots)\n' +
  '2. Confidence level (high if analyst+challenger agreed, low if they disagreed)\n' +
  '3. The single most important insight',
  { label: 'synthesis', phase: 'Synthesize', schema: SYNTHESIS_SCHEMA }
)

return result
