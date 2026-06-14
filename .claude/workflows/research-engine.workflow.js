export const meta = {
  name: 'research-engine',
  description: 'Iterative deep-research engine: PLAN → layer-by-layer DEEPEN with DYNAMICALLY-generated follow-up questions → SATURATION stop → adversarial VERIFY → cited SYNTHESIS. Complements the built-in deep-research harness (which fans out + verifies a fixed question set) by adding a research plan, dynamic-deepening loop, and saturation stop condition. Aligned to TAD research-methodology (Plan→Source→Curate→Analyze→Output) but ON-DEMAND/EPHEMERAL — NOT the persistent NotebookLM knowledge base of research-notebook. Input via args={question, max_rounds, saturation_k, evidence_dir} or the top-of-file CONSTs.',
  whenToUse: 'When a research question needs iterative deepening with adaptive follow-ups and a measurable saturation stop — not a one-shot fan-out. Use research-notebook for a PERSISTENT reusable knowledge base; use the built-in deep-research skill for a single fixed-question fan-out; use THIS for a plan-driven loop that decides its own next questions and stops when findings dry up.',
  phases: [
    { title: 'Plan', detail: 'Decompose the question into sub-questions, angles, success criteria' },
    { title: 'Deepen', detail: 'Saturation loop: fan-out research → dedup → dynamically generate next round questions' },
    { title: 'Verify', detail: 'Adversarially fact-check load-bearing claims (WebSearch-verify specifics)' },
    { title: 'Synthesize', detail: 'Cited report + open-questions/saturation-reason + confidence note' }
  ]
}

// ── CONSTs (edit for a manual run, OR pass via args) ────────────────────────
// Tunable for a cheap smoke test: set MAX_ROUNDS=1 and SATURATION_K=1.
const DEFAULT_QUESTION = '' // e.g. 'What is the current state of agent memory frameworks (CoALA, MemGPT, Mem0)?'
const DEFAULT_MAX_ROUNDS = 4
const DEFAULT_SATURATION_K = 2
const DEFAULT_EVIDENCE_DIR = '.tad/evidence/research'
// New-substantive-findings below this in a round counts as a "dry" round.
const DRY_THRESHOLD = 2
// Parallel research agents per round (fan-out width over current open questions).
const FANOUT_PER_ROUND = 3

// ── Args parsing (Object.keys workaround — runtime may not support dot-access) ──

let question = DEFAULT_QUESTION
let maxRounds = DEFAULT_MAX_ROUNDS
let saturationK = DEFAULT_SATURATION_K
let evidenceDir = DEFAULT_EVIDENCE_DIR

if (args) {
  if (typeof args === 'string') {
    question = args
  } else {
    const keys = Object.keys(args)
    for (let i = 0; i < keys.length; i++) {
      if (keys[i] === 'question') question = args[keys[i]]
      if (keys[i] === 'max_rounds') maxRounds = args[keys[i]]
      if (keys[i] === 'saturation_k') saturationK = args[keys[i]]
      if (keys[i] === 'evidence_dir') evidenceDir = args[keys[i]]
    }
  }
}

// ── Loud guards ─────────────────────────────────────────────────────────────

if (!question || String(question).trim() === '') {
  log('ERROR: question is required. Usage: Workflow({..., args: {question: "..."}}) or args: "your question" or set DEFAULT_QUESTION.')
  return { error: 'question required' }
}

// Coerce args-passed values (may arrive as strings) before any clamp logic.
maxRounds = Number(maxRounds) || DEFAULT_MAX_ROUNDS
saturationK = Number(saturationK) || DEFAULT_SATURATION_K

// Bound the run so a smoke test stays cheap.
if (maxRounds < 1) maxRounds = 1
if (maxRounds > 8) maxRounds = 8
if (saturationK < 1) saturationK = 1
if (saturationK > maxRounds) { log('WARN: saturation_k (' + saturationK + ') > max_rounds; clamping to ' + maxRounds + ' — saturation criterion weakened.'); saturationK = maxRounds }

const EV = evidenceDir
const SLUG = String(question).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 50) || 'research'
const REPORT_PATH = EV + '/research-engine-' + SLUG + '.md'

log('research-engine: question="' + String(question).slice(0, 80) + '"')
log('  maxRounds=' + maxRounds + ', saturationK=' + saturationK + ', dryThreshold=' + DRY_THRESHOLD + ', fanout=' + FANOUT_PER_ROUND)
log('  evidence_dir=' + EV + ', report=' + REPORT_PATH)

// ── Schemas ─────────────────────────────────────────────────────────────────

const PLAN_SCHEMA = {
  type: 'object',
  required: ['sub_questions', 'angles', 'success_criteria'],
  properties: {
    sub_questions: { type: 'array', items: { type: 'string' }, description: '≥3 concrete sub-questions decomposing the research question' },
    angles: { type: 'array', items: { type: 'string' }, description: 'sources/angles to pursue (e.g. primary docs, GitHub repos, benchmarks, dissent)' },
    success_criteria: { type: 'string', description: 'what a complete answer must cover for this to be "done"' }
  }
}

const FINDING_SCHEMA = {
  type: 'object',
  required: ['claim', 'source_url'],
  properties: {
    claim: { type: 'string', description: 'one substantive finding — a single factual claim' },
    source_url: { type: 'string', description: 'the URL the claim was extracted from (anti-hallucination: every claim carries a source)' },
    source_title: { type: 'string' },
    retrieved_at: { type: 'string', description: 'ISO date the source was retrieved' },
    sub_question: { type: 'string', description: 'which open question this answers' },
    confidence: { type: 'string', enum: ['high', 'medium', 'low'] }
  }
}

const ROUND_SCHEMA = {
  type: 'object',
  required: ['findings', 'next_questions'],
  properties: {
    findings: { type: 'array', items: FINDING_SCHEMA, description: 'NEW substantive findings this round (deduped against accumulated)' },
    contradictions: { type: 'array', items: { type: 'string' }, description: 'conflicts between sources surfaced this round' },
    gaps: { type: 'array', items: { type: 'string' }, description: 'questions the current findings raised but did NOT answer' },
    next_questions: { type: 'array', items: { type: 'string' }, description: 'DYNAMICALLY generated follow-up questions for the next round, derived from gaps + contradictions (empty array = nothing left to pursue)' }
  }
}

const VERIFY_SCHEMA = {
  type: 'object',
  required: ['claim', 'verdict'],
  properties: {
    claim: { type: 'string' },
    verdict: { type: 'string', enum: ['confirmed', 'refuted', 'unverifiable', 'outdated'] },
    correct_value: { type: 'string', description: 'if refuted/outdated: the correct current value with its source' },
    verify_source_url: { type: 'string' }
  }
}

const SYNTH_SCHEMA = {
  type: 'object',
  required: ['report_path', 'sources_count', 'confidence'],
  properties: {
    report_path: { type: 'string' },
    sources_count: { type: 'number' },
    open_questions: { type: 'array', items: { type: 'string' } },
    confidence: { type: 'string', enum: ['high', 'medium', 'low'] }
  }
}

// ── Dedup helper (claim text, case/space-normalized) ────────────────────────

function findingKey(f) {
  return String(f && f.claim ? f.claim : '').toLowerCase().replace(/\s+/g, ' ').trim()
}

// ════════════════════════════════════════════════════════════════════════════
// STAGE 1 — PLAN
// An agent decomposes the question into a structured research plan.
// ════════════════════════════════════════════════════════════════════════════

phase('Plan')
log('Stage 1: decomposing the research question into a plan')

const plan = await agent(
  'You are a research lead writing a PLAN (do not research yet, just plan).\n\n' +
  'RESEARCH QUESTION:\n' + question + '\n\n' +
  'Decompose this into:\n' +
  '1. sub_questions: at least 3 concrete, separately-answerable sub-questions.\n' +
  '2. angles: the sources/angles to pursue — prefer PRIMARY sources (official docs, GitHub repos, benchmarks, papers) and include at least one DISSENT/contradiction angle.\n' +
  '3. success_criteria: a one-paragraph definition of what a complete answer must cover for this research to be considered "done".\n\n' +
  'Return ONLY the structured plan. Be specific to THIS question — no generic boilerplate.',
  { label: 'plan', phase: 'Plan', schema: PLAN_SCHEMA }
)

if (!plan || !plan.sub_questions || plan.sub_questions.length === 0) {
  log('Plan stage produced no sub-questions. Aborting.')
  return { error: 'plan failed', question: question }
}

log('Plan: ' + plan.sub_questions.length + ' sub-questions, ' + (plan.angles || []).length + ' angles')

// ════════════════════════════════════════════════════════════════════════════
// STAGE 2 — DEEPEN (saturation loop, loop-discover shape)
// Each round: fan-out research on CURRENT open questions → dedup new findings →
// DYNAMICALLY generate next round's questions from gaps/contradictions.
// STOP when dry counter >= saturationK OR rounds >= maxRounds.
// ════════════════════════════════════════════════════════════════════════════

phase('Deepen')

var allFindings = []
var seen = new Set()
var allContradictions = []
var openQuestions = plan.sub_questions.slice() // seed from the plan
var dryRounds = 0
var round = 0
var roundStats = []
var stoppedReason = null

while (round < maxRounds) {
  // Budget guard — same convention as loop-discover.
  if (typeof budget !== 'undefined' && budget && budget.total && budget.remaining() < 30000) {
    log('Budget low (' + budget.remaining() + ' remaining). Stopping.')
    stoppedReason = 'budget'
    break
  }
  if (openQuestions.length === 0) {
    log('No open questions remain. Stopping (exhausted).')
    stoppedReason = 'questions_exhausted'
    break
  }

  round++
  log('Round ' + round + ': researching ' + openQuestions.length + ' open question(s)')

  // Show the synthesizer what we already know so it dedups + only chases gaps.
  var MAX_SHOWN = 40
  var shownPrior = allFindings.slice(-MAX_SHOWN)
  var priorText = shownPrior.length > 0
    ? '\n\nALREADY-ACCUMULATED FINDINGS (' + allFindings.length + ' total, showing last ' + shownPrior.length + ' — DO NOT repeat these; only report NEW substantive findings):\n' +
      shownPrior.map(function(f) { return '- ' + findingKey(f) + '  [' + (f.source_url || 'no-src') + ']' }).join('\n')
    : ''

  // ── 2a. Fan out parallel research agents over the current open questions ──
  // Each agent owns a slice of the open questions and MUST hit real sources.
  var batches = []
  var perAgent = Math.ceil(openQuestions.length / FANOUT_PER_ROUND)
  for (var b = 0; b < openQuestions.length; b += perAgent) {
    batches.push(openQuestions.slice(b, b + perAgent))
  }

  var researchResults = await parallel(batches.map(function(qBatch, bi) {
    return function() {
      return agent(
        'You are a research agent. Investigate ONLY these open questions using REAL sources.\n\n' +
        'OPEN QUESTIONS FOR YOU:\n' + qBatch.map(function(q, i) { return (i + 1) + '. ' + q }).join('\n') + '\n\n' +
        'PARENT RESEARCH QUESTION (for context): ' + question + '\n' +
        'ANGLES TO PREFER: ' + (plan.angles || []).join('; ') + '\n' +
        priorText + '\n\n' +
        'METHOD (anti-hallucination — MANDATORY):\n' +
        '- Use WebSearch to find primary/authoritative sources, then WebFetch to read them.\n' +
        '- EVERY finding MUST carry a real source_url you actually fetched + the retrieved_at date (today).\n' +
        '- Do NOT invent URLs or paraphrase from memory. If you cannot source a claim, drop it.\n' +
        '- Report ONLY NEW substantive findings (not already in the accumulated list above).\n\n' +
        'Return findings[] (each with claim + source_url + retrieved_at + sub_question + confidence). ' +
        'Leave next_questions empty — the synthesizer generates those.',
        { label: 'research-r' + round + '-b' + bi, phase: 'Deepen', schema: ROUND_SCHEMA, model: 'sonnet' }
      )
    }
  }))

  // Flatten raw findings from all fan-out agents this round.
  var rawFindings = []
  var rawGaps = []
  var rawContradictions = []
  for (var ri = 0; ri < researchResults.length; ri++) {
    var rr = researchResults[ri]
    if (!rr) continue
    if (Array.isArray(rr.findings)) { for (var fi = 0; fi < rr.findings.length; fi++) rawFindings.push(rr.findings[fi]) }
    if (Array.isArray(rr.gaps)) { for (var gi = 0; gi < rr.gaps.length; gi++) rawGaps.push(rr.gaps[gi]) }
    if (Array.isArray(rr.contradictions)) { for (var ci = 0; ci < rr.contradictions.length; ci++) rawContradictions.push(rr.contradictions[ci]) }
  }

  // ── 2b. Synthesizer: dedup new vs accumulated + DYNAMICALLY generate next questions ──
  var synth = await agent(
    'You are the round synthesizer. Dedup new findings against what we already know, ' +
    'and — KEY — DYNAMICALLY GENERATE the next round\'s follow-up questions from the GAPS and CONTRADICTIONS this round surfaced. ' +
    'The next questions must be NEW (not the ones we just researched), specific, and chase what is still UNANSWERED. ' +
    'If the round answered everything and surfaced no real gaps, return next_questions: [] (this lets the loop saturate and stop).\n\n' +
    'PARENT QUESTION: ' + question + '\n' +
    'SUCCESS CRITERIA: ' + (plan.success_criteria || '(none)') + '\n\n' +
    'QUESTIONS RESEARCHED THIS ROUND:\n' + openQuestions.map(function(q) { return '- ' + q }).join('\n') + '\n\n' +
    'RAW FINDINGS THIS ROUND:\n' + JSON.stringify(rawFindings, null, 2) + '\n\n' +
    'RAW GAPS:\n' + JSON.stringify(rawGaps, null, 2) + '\n\n' +
    'RAW CONTRADICTIONS:\n' + JSON.stringify(rawContradictions, null, 2) + '\n\n' +
    'ALREADY-ACCUMULATED (dedup against these):\n' + shownPrior.map(function(f) { return '- ' + findingKey(f) }).join('\n') + '\n\n' +
    'Return: findings[] = only the genuinely NEW, source-carrying findings (drop dupes + any claim missing a source_url); ' +
    'contradictions[] = conflicts worth flagging; gaps[] = what stays unanswered; ' +
    'next_questions[] = the dynamically-derived follow-ups for the next round (or [] if saturated).',
    { label: 'synth-r' + round, phase: 'Deepen', schema: ROUND_SCHEMA, model: 'sonnet' }
  )

  // Synth-death fallback: if the synthesizer died but the round produced raw findings,
  // don't silently discard a productive round — raw findings already carry source_url,
  // so the existing source_url + dedup filter below still applies.
  var basis = (synth && Array.isArray(synth.findings)) ? synth.findings : rawFindings
  var newFindings = basis.filter(function(f) {
    var k = findingKey(f)
    return k && k !== '' && f.source_url && !seen.has(k)
  })

  newFindings.forEach(function(f) { seen.add(findingKey(f)); allFindings.push(f) })
  if (synth && Array.isArray(synth.contradictions)) {
    for (var sc = 0; sc < synth.contradictions.length; sc++) allContradictions.push(synth.contradictions[sc])
  }

  // ── 2c. Dry-round bookkeeping + saturation ──
  if (newFindings.length < DRY_THRESHOLD) {
    dryRounds++
    log('Round ' + round + ': ' + newFindings.length + ' new findings (< ' + DRY_THRESHOLD + ') → dry round ' + dryRounds + '/' + saturationK)
  } else {
    dryRounds = 0
    log('Round ' + round + ': ' + newFindings.length + ' new findings (productive). Total: ' + allFindings.length)
  }

  roundStats.push({
    round: round,
    questions_researched: openQuestions.length,
    new_findings: newFindings.length,
    cumulative: allFindings.length,
    dry_counter: dryRounds
  })

  // Persist this round to disk for resumability / audit.
  await agent(
    'Append a round log to ' + EV + '/research-engine-' + SLUG + '-round-' + round + '.md (create the directory if needed). Write this content verbatim as markdown:\n\n' +
    '# Round ' + round + ' — ' + SLUG + '\n\n' +
    '- Questions researched: ' + openQuestions.length + '\n' +
    '- New findings: ' + newFindings.length + ' (cumulative ' + allFindings.length + ')\n' +
    '- Dry counter: ' + dryRounds + '/' + saturationK + '\n\n' +
    '## New findings\n' + JSON.stringify(newFindings, null, 2) + '\n\n' +
    '## Next questions (dynamically generated)\n' + JSON.stringify((synth && synth.next_questions) || [], null, 2) + '\n',
    { label: 'persist-r' + round, phase: 'Deepen', model: 'haiku' }
  )

  // Saturation stop (after recording the round).
  if (dryRounds >= saturationK) {
    stoppedReason = 'saturated'
    log('Saturation reached (' + dryRounds + ' consecutive dry rounds >= ' + saturationK + '). Stopping.')
    break
  }

  // Hand the dynamically-generated follow-ups to the next round.
  // Clamp to MAX_OPEN to prevent per-agent prompt bloat / cost blowup across rounds.
  var MAX_OPEN = 12
  openQuestions = ((synth && Array.isArray(synth.next_questions)) ? synth.next_questions.filter(Boolean) : []).slice(0, MAX_OPEN)
}

if (!stoppedReason) stoppedReason = (round >= maxRounds) ? 'max_rounds' : 'questions_exhausted'
log('Deepen complete: ' + allFindings.length + ' findings in ' + round + ' rounds. Stopped: ' + stoppedReason)

// ════════════════════════════════════════════════════════════════════════════
// STAGE 3 — VERIFY (adversarial fact-check of load-bearing claims)
// Reuses the spirit of deep-research's adversarial verify: WebSearch-verify
// version-sensitive specifics on the highest-confidence / most-cited claims.
// ════════════════════════════════════════════════════════════════════════════

phase('Verify')

// Verify a bounded set of load-bearing claims (keeps cost low on a small run).
var MAX_VERIFY = Math.min(8, allFindings.length)
var toVerify = allFindings.slice(0, MAX_VERIFY)
var verifyResults = []

if (toVerify.length === 0) {
  log('No findings to verify — skipping.')
} else {
  log('Stage 3: adversarially verifying ' + toVerify.length + ' load-bearing claim(s)')
  verifyResults = await parallel(toVerify.map(function(f) {
    return function() {
      return agent(
        'You are an adversarial fact-checker. Try to REFUTE this claim with current primary sources.\n\n' +
        'CLAIM: ' + f.claim + '\n' +
        'ALLEGED SOURCE: ' + (f.source_url || 'none') + '\n\n' +
        'Focus on version-sensitive specifics (numbers, versions, model/tool names, API shapes, thresholds, dates). ' +
        'WebSearch (and WebFetch the primary doc) to check the CURRENT value. ' +
        'Verdict: confirmed / refuted / unverifiable / outdated. ' +
        'If refuted or outdated, give the correct_value WITH its verify_source_url.',
        { label: 'verify', phase: 'Verify', schema: VERIFY_SCHEMA, model: 'sonnet' }
      )
    }
  }))
  verifyResults = verifyResults.filter(Boolean)
  var refuted = verifyResults.filter(function(v) { return v.verdict === 'refuted' || v.verdict === 'outdated' }).length
  log('Verify complete: ' + verifyResults.length + ' checked, ' + refuted + ' refuted/outdated')
}

// ════════════════════════════════════════════════════════════════════════════
// STAGE 4 — SYNTHESIZE (cited report + open questions + confidence)
// ════════════════════════════════════════════════════════════════════════════

phase('Synthesize')
log('Stage 4: writing cited report to ' + REPORT_PATH)

var uniqueSources = new Set()
allFindings.forEach(function(f) { if (f.source_url) uniqueSources.add(f.source_url) })
var sourcesCount = uniqueSources.size

var synthResult = await agent(
  'Write a CITED research report to ' + REPORT_PATH + ' (create the directory if needed).\n\n' +
  'RESEARCH QUESTION: ' + question + '\n' +
  'SUCCESS CRITERIA: ' + (plan.success_criteria || '(none)') + '\n' +
  'PLAN SUB-QUESTIONS: ' + JSON.stringify(plan.sub_questions) + '\n\n' +
  'ALL FINDINGS (each carries a source_url — every claim in the report MUST cite its source):\n' +
  JSON.stringify(allFindings, null, 2) + '\n\n' +
  'CONTRADICTIONS SURFACED:\n' + JSON.stringify(allContradictions, null, 2) + '\n\n' +
  'ADVERSARIAL VERIFY RESULTS (apply these — drop or caveat any refuted/outdated claim, use correct_value):\n' +
  JSON.stringify(verifyResults, null, 2) + '\n\n' +
  'SATURATION: stopped after ' + round + ' round(s), reason = ' + stoppedReason + '. Round stats: ' + JSON.stringify(roundStats) + '\n\n' +
  'REPORT STRUCTURE (markdown):\n' +
  '1. # Title + one-line question\n' +
  '2. ## Summary — the answer, 3-6 bullets, EACH bullet ends with its source URL in [brackets]\n' +
  '3. ## Findings by sub-question — group claims under each plan sub-question; every claim cites its source_url\n' +
  '4. ## Contradictions / open debates\n' +
  '5. ## Open questions / saturation reason — list what is still unanswered AND why we stopped (saturation_reason = ' + stoppedReason + ')\n' +
  '6. ## Confidence note — overall high/medium/low + what would raise it (note any refuted claims from verify)\n' +
  '7. ## Sources — deduped list of every source_url used\n\n' +
  'Do NOT add any claim that lacks a source_url in the findings. ' +
  'Return report_path, sources_count (' + sourcesCount + '), open_questions[], and overall confidence.',
  { label: 'synthesize', phase: 'Synthesize', schema: SYNTH_SCHEMA }
)

var openQs = (synthResult && synthResult.open_questions) || []
var confidence = (synthResult && synthResult.confidence) || 'medium'

log('research-engine complete: ' + allFindings.length + ' findings, ' + sourcesCount + ' sources, confidence=' + confidence)

return {
  rounds_run: round,
  saturation_reason: stoppedReason,
  findings_count: allFindings.length,
  sources_count: sourcesCount,
  report_path: (synthResult && synthResult.report_path) || REPORT_PATH,
  open_questions: openQs,
  confidence: confidence,
  round_stats: roundStats
}
