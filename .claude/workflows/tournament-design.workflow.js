export const meta = {
  name: 'tournament-design',
  description: 'Tournament design exploration: N competing agents + pairwise judges + synthesized merge',
  whenToUse: 'When facing a design decision with multiple valid approaches. Spawns competing designers, judges pairwise, merges best ideas from all competitors into a single design no single agent would produce.',
  phases: [
    { title: 'Setup', detail: 'Parse args and validate prior_art sources' },
    { title: 'Compete', detail: 'Spawn competing design agents with different prior art' },
    { title: 'Judge', detail: 'Pairwise evaluation against rubric dimensions' },
    { title: 'Synthesize', detail: 'Merge winner with best ideas from losers' }
  ]
}

const DESIGN_SCHEMA = {
  type: 'object',
  properties: {
    approach_name: { type: 'string', description: 'Name of this design approach' },
    prior_art_reference: { type: 'string', description: 'Which prior art source this was based on' },
    design_content: { type: 'string', description: 'The actual design (markdown)' },
    tradeoffs: { type: 'array', items: { type: 'string' }, description: 'Key tradeoffs of this approach' },
    key_innovation: { type: 'string', description: 'What makes this approach unique vs others' }
  },
  required: ['approach_name', 'prior_art_reference', 'design_content', 'tradeoffs', 'key_innovation']
}

const JUDGE_SCHEMA = {
  type: 'object',
  properties: {
    winner: { type: 'string', description: 'Label of the winning design: "A" or "B" (must match the Design A / Design B labels in the prompt)' },
    loser: { type: 'string', description: 'Label of the losing design: "A" or "B"' },
    winner_name: { type: 'string', description: 'Full approach_name of the winning design' },
    loser_name: { type: 'string', description: 'Full approach_name of the losing design' },
    scores: {
      type: 'object',
      description: 'Per-dimension scores for each design (positional: design_a = first design in prompt, design_b = second)',
      properties: {
        design_a: { type: 'object', description: 'Scores for Design A (dimension name to 0-10 number)', additionalProperties: { type: 'number' } },
        design_b: { type: 'object', description: 'Scores for Design B (dimension name to 0-10 number)', additionalProperties: { type: 'number' } }
      },
      required: ['design_a', 'design_b']
    },
    decisive_factor: { type: 'string', description: 'What tipped the decision' },
    what_loser_did_better: {
      type: 'array',
      items: { type: 'string' },
      description: 'Specific sub-ideas from the loser that are worth preserving in a merge'
    }
  },
  required: ['winner', 'loser', 'winner_name', 'loser_name', 'scores', 'decisive_factor', 'what_loser_did_better']
}

const MERGED_DESIGN_SCHEMA = {
  type: 'object',
  properties: {
    tournament_winner: { type: 'string', description: 'Name of the base winner design' },
    win_record: { type: 'string', description: 'Win-loss record summary' },
    best_ideas_from_losers: {
      type: 'array',
      items: { type: 'string' },
      description: 'Specific ideas grafted from losing designs'
    },
    merged_design: { type: 'string', description: 'The final merged design (markdown)' },
    ideas_grafted_from_losers_count: {
      type: 'number',
      description: 'How many sub-ideas from losers survived into the merge'
    }
  },
  required: ['tournament_winner', 'win_record', 'best_ideas_from_losers', 'merged_design', 'ideas_grafted_from_losers_count']
}

// ── Phase 1: Setup ──────────────────────────────────────────────
phase('Setup')

let task = null
let priorArt = null
let rubric = null
let mode = 'standard'
let contextFiles = null
let models = null

if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'task') task = args[keys[i]]
    if (keys[i] === 'prior_art') priorArt = args[keys[i]]
    if (keys[i] === 'rubric') rubric = args[keys[i]]
    if (keys[i] === 'mode') mode = args[keys[i]]
    if (keys[i] === 'context_files') contextFiles = args[keys[i]]
    if (keys[i] === 'models') models = args[keys[i]]
  }
}

if (!task) {
  log('ERROR: args.task is required. Usage: Workflow({name: "tournament-design", args: {task: "...", prior_art: ["source1", "source2"]}})')
  return { error: 'task is required' }
}

if (!priorArt || priorArt.length < 2) {
  log('ERROR: args.prior_art must be an array with >= 2 entries (one per competitor)')
  return { error: 'prior_art requires >= 2 entries' }
}

if (mode !== 'standard' && mode !== 'deep') {
  mode = 'standard'
}

const competitorCount = mode === 'deep' ? 3 : 2
if (priorArt.length < competitorCount) {
  log('WARNING: prior_art has ' + priorArt.length + ' entries but mode "' + mode + '" needs ' + competitorCount + '. Reusing last source for extra competitor(s).')
}

const defaultRubric = {
  dimensions: ['feasibility', 'elegance', 'extensibility', 'principle_alignment']
}
const effectiveRubric = rubric || defaultRubric

const contextFilesBlock = contextFiles
  ? '\n\nAdditional context files to read:\n' + contextFiles.map(function(f) { return '- ' + f }).join('\n')
  : ''

log('Tournament: mode=' + mode + ', competitors=' + competitorCount + ', rubric dimensions=' + effectiveRubric.dimensions.join(','))

// ── Phase 2: Compete ────────────────────────────────────────────
phase('Compete')

const competitorPrompts = []
for (let i = 0; i < competitorCount; i++) {
  const source = i < priorArt.length ? priorArt[i] : priorArt[priorArt.length - 1]
  competitorPrompts.push({
    index: i,
    source: source,
    label: String.fromCharCode(65 + i)
  })
}

const designs = await parallel(competitorPrompts.map(function(c) {
  return function() {
    var opts = { label: 'competitor-' + c.label, phase: 'Compete', schema: DESIGN_SCHEMA }
    if (models && models[c.index]) opts.model = models[c.index]
    return agent(
      'You are Design Competitor ' + c.label + '. Your task:\n\n' +
      task + '\n\n' +
      'Your assigned prior art / inspiration source (read this first, base your approach on it):\n' +
      c.source + '\n\n' +
      'Scoring rubric dimensions: ' + effectiveRubric.dimensions.join(', ') + '\n' +
      'Optimize your design for these dimensions.' +
      contextFilesBlock + '\n\n' +
      'Produce a complete, concrete design. Be specific — include data structures, APIs, file layouts, or whatever the task demands. ' +
      'Name your approach something descriptive.',
      opts
    )
  }
}))

const validDesigns = designs.filter(Boolean)
if (validDesigns.length < 2) {
  log('ABORT: Only ' + validDesigns.length + ' competitor(s) succeeded. Need >= 2 for a tournament.')
  return { error: 'insufficient competitors', succeeded: validDesigns.length }
}

if (mode === 'deep' && validDesigns.length === 2) {
  log('DEGRADE: Deep mode requested 3 competitors but only 2 succeeded. Degrading to standard mode (1 judge).')
  mode = 'standard'
}

log('Compete phase done: ' + validDesigns.length + ' designs received')

// ── Phase 3: Judge ──────────────────────────────────────────────
phase('Judge')

function buildJudgePrompt(designA, designB, rubricDims) {
  return 'You are an impartial design judge. Compare these two designs:\n\n' +
    '## Design A: ' + designA.approach_name + '\n' +
    designA.design_content + '\n' +
    'Key innovation: ' + designA.key_innovation + '\n' +
    'Tradeoffs: ' + designA.tradeoffs.join('; ') + '\n\n' +
    '## Design B: ' + designB.approach_name + '\n' +
    designB.design_content + '\n' +
    'Key innovation: ' + designB.key_innovation + '\n' +
    'Tradeoffs: ' + designB.tradeoffs.join('; ') + '\n\n' +
    'Score each design 0-10 on these dimensions: ' + rubricDims.join(', ') + '\n\n' +
    'Pick a winner. Return the LABEL ("A" or "B") as winner/loser, plus the full approach_name as winner_name/loser_name.\n' +
    'Critically: identify what the LOSER did better — specific sub-ideas ' +
    'that the winner lacks and should incorporate. This is the most important part of your evaluation.'
}

var judgeResultsRaw = []

if (mode === 'standard') {
  const result = await agent(
    buildJudgePrompt(validDesigns[0], validDesigns[1], effectiveRubric.dimensions),
    { label: 'judge-AvB', phase: 'Judge', schema: JUDGE_SCHEMA }
  )
  if (result) judgeResultsRaw.push({ result: result, pair: [0, 1] })
} else {
  var deepPairs = [[0, 1], [1, 2], [0, 2]]
  judgePairs = deepPairs
  var pairLabels = ['AvB', 'BvC', 'AvC']

  var rawResults = await parallel(deepPairs.map(function(pair, idx) {
    return function() {
      return agent(
        buildJudgePrompt(validDesigns[pair[0]], validDesigns[pair[1]], effectiveRubric.dimensions),
        { label: 'judge-' + pairLabels[idx], phase: 'Judge', schema: JUDGE_SCHEMA }
      )
    }
  }))

  for (var ri = 0; ri < rawResults.length; ri++) {
    if (rawResults[ri]) {
      judgeResultsRaw.push({ result: rawResults[ri], pair: deepPairs[ri] })
    }
  }

  if (mode === 'deep' && judgeResultsRaw.length < 2) {
    log('ABORT: Deep mode needs >= 2 judge results but only ' + judgeResultsRaw.length + ' succeeded.')
    return { error: 'insufficient judge results for deep mode', designs: validDesigns }
  }
  if (mode === 'deep' && judgeResultsRaw.length === 2) {
    log('DEGRADE: 1 of 3 deep-mode judges failed. Proceeding with 2 pairwise results.')
  }
}

if (judgeResultsRaw.length === 0) {
  log('ABORT: No judge results. Cannot proceed to synthesis.')
  return { error: 'no judge results', designs: validDesigns }
}

var judgeResults = []
for (var jri = 0; jri < judgeResultsRaw.length; jri++) {
  judgeResults.push(judgeResultsRaw[jri].result)
}

log('Judge phase done: ' + judgeResults.length + ' pairwise evaluation(s)')

// Derive win record using positional labels for reliable identity mapping
var winCounts = {}
var scoreSums = {}
var maxSingleDim = {}
for (var di = 0; di < validDesigns.length; di++) {
  winCounts[validDesigns[di].approach_name] = 0
  scoreSums[validDesigns[di].approach_name] = 0
  maxSingleDim[validDesigns[di].approach_name] = 0
}

function sumScores(scoresObj) {
  var total = 0
  var maxDim = 0
  var sk = Object.keys(scoresObj || {})
  for (var si = 0; si < sk.length; si++) {
    var v = scoresObj[sk[si]] || 0
    total += v
    if (v > maxDim) maxDim = v
  }
  return { total: total, maxDim: maxDim }
}

for (var j = 0; j < judgeResultsRaw.length; j++) {
  var jr = judgeResultsRaw[j].result
  var pair = judgeResultsRaw[j].pair

  // Map positional label (A/B) to actual design via the pair indices
  var designAName = validDesigns[pair[0]].approach_name
  var designBName = validDesigns[pair[1]].approach_name

  var winnerLabel = (jr.winner || '').toUpperCase().trim()
  var winnerName = winnerLabel === 'A' ? designAName : designBName

  if (winCounts[winnerName] !== undefined) {
    winCounts[winnerName] = (winCounts[winnerName] || 0) + 1
  }

  // Attribute scores using positional mapping (design_a = pair[0], design_b = pair[1])
  var sumA = sumScores(jr.scores.design_a || {})
  var sumB = sumScores(jr.scores.design_b || {})

  if (scoreSums[designAName] !== undefined) scoreSums[designAName] += sumA.total
  if (scoreSums[designBName] !== undefined) scoreSums[designBName] += sumB.total
  if (maxSingleDim[designAName] !== undefined && sumA.maxDim > maxSingleDim[designAName]) {
    maxSingleDim[designAName] = sumA.maxDim
  }
  if (maxSingleDim[designBName] !== undefined && sumB.maxDim > maxSingleDim[designBName]) {
    maxSingleDim[designBName] = sumB.maxDim
  }
}

// 3-tier tiebreaker: wins → total score → highest single dimension
var tournamentWinner = null
var maxWins = -1
var designNames = Object.keys(winCounts)
for (var wi = 0; wi < designNames.length; wi++) {
  var name = designNames[wi]
  if (winCounts[name] > maxWins) {
    maxWins = winCounts[name]
    tournamentWinner = name
  } else if (winCounts[name] === maxWins && tournamentWinner) {
    if ((scoreSums[name] || 0) > (scoreSums[tournamentWinner] || 0)) {
      tournamentWinner = name
    } else if ((scoreSums[name] || 0) === (scoreSums[tournamentWinner] || 0)) {
      if ((maxSingleDim[name] || 0) > (maxSingleDim[tournamentWinner] || 0)) {
        tournamentWinner = name
      }
    }
  }
}

var winRecordParts = []
for (var wri = 0; wri < designNames.length; wri++) {
  winRecordParts.push(designNames[wri] + ': ' + winCounts[designNames[wri]] + 'W')
}
var winRecordStr = winRecordParts.join(', ')

log('Tournament winner: ' + tournamentWinner + ' (' + winRecordStr + ')')

// Collect all loser insights using label-based identity
var loserInsights = []
for (var li = 0; li < judgeResultsRaw.length; li++) {
  var ljr = judgeResultsRaw[li].result
  var lpair = judgeResultsRaw[li].pair
  var lWinnerLabel = (ljr.winner || '').toUpperCase().trim()
  var lLoserName = lWinnerLabel === 'A' ? validDesigns[lpair[1]].approach_name : validDesigns[lpair[0]].approach_name

  if (ljr.what_loser_did_better) {
    for (var lk = 0; lk < ljr.what_loser_did_better.length; lk++) {
      loserInsights.push('[from ' + lLoserName + '] ' + ljr.what_loser_did_better[lk])
    }
  }
}

// Find the winner's full design by name
var winnerDesign = null
for (var fi = 0; fi < validDesigns.length; fi++) {
  if (validDesigns[fi].approach_name === tournamentWinner) {
    winnerDesign = validDesigns[fi]
    break
  }
}
if (!winnerDesign) winnerDesign = validDesigns[0]

// ── Phase 4: Synthesize ─────────────────────────────────────────
phase('Synthesize')

const result = await agent(
  'You are a design synthesizer. Your job is to create the BEST POSSIBLE merged design.\n\n' +
  '## Tournament Winner (use as base):\n' +
  'Name: ' + winnerDesign.approach_name + '\n' +
  winnerDesign.design_content + '\n\n' +
  '## Win Record:\n' + winRecordStr + '\n\n' +
  '## Best Ideas from Losers (MUST incorporate where they improve the winner):\n' +
  loserInsights.map(function(insight, idx) { return (idx + 1) + '. ' + insight }).join('\n') + '\n\n' +
  '## All Judge Evaluations:\n' +
  judgeResultsRaw.map(function(entry) {
    var wl = (entry.result.winner || '').toUpperCase().trim()
    var wName = wl === 'A' ? validDesigns[entry.pair[0]].approach_name : validDesigns[entry.pair[1]].approach_name
    var lName = wl === 'A' ? validDesigns[entry.pair[1]].approach_name : validDesigns[entry.pair[0]].approach_name
    return '- ' + wName + ' beat ' + lName + ': ' + entry.result.decisive_factor +
      '\n  Loser strengths: ' + entry.result.what_loser_did_better.join('; ')
  }).join('\n') + '\n\n' +
  'Create a merged design that:\n' +
  '1. Uses the winner as the foundation\n' +
  '2. Grafts in specific sub-ideas from losers where they genuinely improve the design\n' +
  '3. Resolves any conflicts between grafted ideas and the base\n' +
  '4. Produces a design that NO single competitor would have created\n\n' +
  'Be specific about which loser ideas you incorporated and why.',
  { label: 'synthesizer', phase: 'Synthesize', schema: MERGED_DESIGN_SCHEMA }
)

if (!result) {
  log('WARNING: Synthesizer failed. Returning winner design as-is.')
  return {
    tournament_winner: tournamentWinner,
    win_record: winRecordStr,
    merged_design: winnerDesign.design_content,
    best_ideas_from_losers: loserInsights,
    ideas_grafted_from_losers_count: 0,
    designs: validDesigns,
    judge_results: judgeResults,
    synthesis_failed: true
  }
}

return {
  tournament_winner: result.tournament_winner,
  win_record: result.win_record,
  best_ideas_from_losers: result.best_ideas_from_losers,
  merged_design: result.merged_design,
  ideas_grafted_from_losers_count: result.ideas_grafted_from_losers_count,
  designs: validDesigns,
  judge_results: judgeResults
}
