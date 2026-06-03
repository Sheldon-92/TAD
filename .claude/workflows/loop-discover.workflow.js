export const meta = {
  name: 'loop-discover',
  description: 'Loop-until-done discovery: finder agents in rounds, dedup, stop after K dry rounds',
  whenToUse: 'When the amount of work is unknown upfront — bugs, proposals, patterns. Spawns finder agents until K consecutive rounds return zero new findings.',
  phases: [
    { title: 'Discover', detail: 'Iterative finder rounds with dedup' },
    { title: 'Complete', detail: 'Report findings and stats' }
  ]
}

// ── Args parsing (Object.keys workaround — NFR1) ──────────────

let finderPrompt = null
let schema = null
let dedupKey = null
let dryRoundsToStop = 2
let maxRounds = 10
let contextFiles = null
let outputPath = null
let previousFindingsPath = null

if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'finder_prompt') finderPrompt = args[keys[i]]
    if (keys[i] === 'schema') schema = args[keys[i]]
    if (keys[i] === 'dedup_key') dedupKey = args[keys[i]]
    if (keys[i] === 'dry_rounds_to_stop') dryRoundsToStop = args[keys[i]]
    if (keys[i] === 'max_rounds') maxRounds = args[keys[i]]
    if (keys[i] === 'context_files') contextFiles = args[keys[i]]
    if (keys[i] === 'output_path') outputPath = args[keys[i]]
    if (keys[i] === 'previous_findings_path') previousFindingsPath = args[keys[i]]
  }
}

// ── Validation ──────────────────────────────────────────────────

if (!finderPrompt) {
  log('ERROR: finder_prompt is required')
  return { error: 'finder_prompt required' }
}
if (!schema) {
  log('ERROR: schema is required (JSON schema for each finding)')
  return { error: 'schema required' }
}
if (!dedupKey) {
  log('ERROR: dedup_key is required (field name or array of field names for dedup)')
  return { error: 'dedup_key required' }
}

if (maxRounds > 10) maxRounds = 10
if (dryRoundsToStop < 1) dryRoundsToStop = 1

var contextBlock = ''
if (contextFiles && contextFiles.length > 0) {
  contextBlock = '\n\nContext files to read:\n' + contextFiles.map(function(f) { return '- ' + f }).join('\n')
}

log('Loop-discover: dryStop=' + dryRoundsToStop + ', maxRounds=' + maxRounds + ', dedupKey=' + JSON.stringify(dedupKey))

// ── Dedup key function ──────────────────────────────────────────

function getKey(finding, dk) {
  if (typeof dk === 'string') return String(finding[dk] || '')
  var parts = []
  for (var i = 0; i < dk.length; i++) { parts.push(String(finding[dk[i]] || '')) }
  return parts.join('::')
}

// ── Phase: Discover ─────────────────────────────────────────────

phase('Discover')

var allFindings = []

if (previousFindingsPath) {
  log('Loading previous findings from ' + previousFindingsPath)
  var prior = await agent(
    'Read the file at ' + previousFindingsPath + '. Parse it as a JSON array. Return the parsed array. If the file does not exist or is empty, return an empty array [].',
    { label: 'load-prior', schema: { type: 'array', items: schema }, model: 'haiku' }
  )
  if (prior && prior.length) {
    for (var pi = 0; pi < prior.length; pi++) { allFindings.push(prior[pi]) }
    log('Loaded ' + allFindings.length + ' previous findings')
  }
}

var seen = new Set(allFindings.map(function(f) { return getKey(f, dedupKey) }))
var dryRounds = 0
var round = 0
var roundStats = []
var MAX_PREVIOUSLY_SHOWN = 50

while (dryRounds < dryRoundsToStop && round < maxRounds) {
  if (typeof budget !== 'undefined' && budget && budget.total && budget.remaining() < 30000) {
    log('Budget low (' + budget.remaining() + ' remaining). Stopping.')
    break
  }

  round++
  log('Round ' + round + ': spawning finder agent')

  var shownPrior = allFindings.slice(-MAX_PREVIOUSLY_SHOWN)
  var priorText = shownPrior.length > 0
    ? '\n\nALREADY FOUND (do not re-discover — ' + allFindings.length + ' total, showing last ' + shownPrior.length + '):\n' +
      shownPrior.map(function(f) { return '- ' + getKey(f, dedupKey) }).join('\n')
    : ''

  var findings = await agent(
    finderPrompt + contextBlock + priorText,
    { label: 'round-' + round, phase: 'Discover', schema: { type: 'array', items: schema } }
  )

  var validFindings = Array.isArray(findings) ? findings : []
  var newFindings = validFindings.filter(function(f) {
    var k = getKey(f, dedupKey)
    return k && k !== '' && !seen.has(k)
  })

  if (newFindings.length === 0) {
    dryRounds++
    log('Round ' + round + ': 0 new findings (dry round ' + dryRounds + '/' + dryRoundsToStop + ')')
  } else {
    dryRounds = 0
    newFindings.forEach(function(f) { seen.add(getKey(f, dedupKey)); allFindings.push(f) })
    log('Round ' + round + ': ' + newFindings.length + ' new findings (total: ' + allFindings.length + ')')
  }

  roundStats.push({ round: round, new_count: newFindings.length, cumulative: allFindings.length })
}

// ── Phase: Complete ─────────────────────────────────────────────

phase('Complete')

var stoppedReason = dryRounds >= dryRoundsToStop ? 'dry_rounds' : round >= maxRounds ? 'max_rounds' : 'budget'

log('Loop complete: ' + allFindings.length + ' findings in ' + round + ' rounds. Stopped: ' + stoppedReason)

return {
  total_findings: allFindings.length,
  rounds_executed: round,
  stopped_reason: stoppedReason,
  findings: allFindings,
  round_stats: roundStats,
  output_path: outputPath || null
}
