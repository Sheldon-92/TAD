export const meta = {
  name: 'surplus-scan',
  description: 'Surplus Burn Mode Phase 1: scan TAD backlog sources + OBJECTIVES-driven generator, rank candidates value-first (expected_value = value x confidence; density tiebreaker), tag risk/safety, write ranked SURPLUS-PLAN markdown + JSON sidecar. Read-only: writes exactly two plan artifacts, mutates no backlog source.',
  whenToUse: 'Invoked by *surplus --plan to surface highest-value backlog work. Read-only scan + rank; NO execution (Phase 2).',
  phases: [
    { title: 'Scan', detail: 'Parallel readers, one per backlog source, extract candidates' },
    { title: 'Generate', detail: 'One generator proposes NEW OBJECTIVES-KR-linked directions (downstream of Scan)' },
    { title: 'Rank', detail: 'Plain-JS dedup, anti-theater drop, staleness drop, value-first sort, safety tag, render artifacts' }
  ]
}

// ── Args parsing (Object.keys loop — loop-discover convention) ─────────────

var sources = null
var outputPath = null
var objectivesPath = null
var dateStamp = null

if (args) {
  var keys = Object.keys(args)
  for (var i = 0; i < keys.length; i++) {
    if (keys[i] === 'sources') sources = args[keys[i]]
    if (keys[i] === 'output_path') outputPath = args[keys[i]]
    if (keys[i] === 'objectives_path') objectivesPath = args[keys[i]]
    if (keys[i] === 'date') dateStamp = args[keys[i]]
  }
}

// ── Defaults (P0-4 / P2-4 corrected paths; date comes from SKILL boundary) ──
// NOTE: zero time/random primitives anywhere — dateStamp is passed in via args.

if (!dateStamp) dateStamp = 'undated'
if (!objectivesPath) objectivesPath = 'OBJECTIVES.md'
if (!outputPath) outputPath = '.tad/active/SURPLUS-PLAN-' + dateStamp + '.md'

// Default scan sources: dir globs + repo-root files. Each entry has a glob-or-file
// path and a kind. A missing dir/file → skip + log(), never throw (P0-4 graceful-skip).
if (!sources) {
  sources = [
    { path: '.tad/active/ideas/', glob: '*.md', kind: 'ideas' },
    { path: '.tad/active/dream-candidates/', glob: '*.md', kind: 'dream-candidates' },
    { path: '.tad/active/epics/', glob: '*.md', kind: 'epics-parked' },
    { path: '.tad/evidence/proposals/', glob: '*.yaml', kind: 'proposals' },
    { path: 'NEXT.md', glob: null, kind: 'next' }
  ]
}

// JSON sidecar path = same stem as markdown plan, .json extension (P1-2).
var jsonPath = outputPath.replace(/\.md$/, '') + '.json'

log('surplus-scan: date=' + dateStamp + ', sources=' + sources.length + ', out=' + outputPath + ', json=' + jsonPath)

// ── Candidate schema (reader output — every field the rank phase needs) ─────

var CANDIDATE_SCHEMA = {
  type: 'object',
  properties: {
    id: { type: 'string' },
    title: { type: 'string' },
    source: { type: 'string' },
    summary: { type: 'string' },
    value: { type: 'number' },          // 1-5 business/strategic value
    confidence: { type: 'number' },     // 0.0-1.0 confidence work pays off
    token_cost: { type: 'string', enum: ['S', 'M', 'L'] },
    cost_rationale: { type: 'string' },   // P2-3: persist WHY this cost
    value_rationale: { type: 'string' },  // P2-3: persist WHY this value
    deliverable: { type: 'string' },      // CONCRETE artifact/AC — required non-empty
    target_paths: { type: 'array', items: { type: 'string' } }, // for mechanical safety
    safety_flag: { type: 'boolean' },
    risk_tag: { type: 'string', enum: ['safe', 'needs-human'] }
  },
  required: ['id', 'title', 'source', 'value', 'confidence', 'token_cost', 'deliverable', 'risk_tag']
}

// token_cost anchors — embedded IN every reader prompt (P0-2):
var COST_ANCHORS =
  'token_cost rubric (assign exactly one):\n' +
  '  S = single file, no new abstraction, ~<30k tokens.\n' +
  '  M = 2-4 files, moderate change.\n' +
  '  L = new workflow / Epic-phase / SAFETY-adjacent / >~100k tokens.\n'

var SCORING_GUIDE =
  'value = 1..5 (strategic/business value, 5 = highest).\n' +
  'confidence = 0.0..1.0 (how sure the work pays off as described).\n' +
  'deliverable MUST be a CONCRETE artifact or acceptance criterion (a file, a workflow, a passing test, a shipped feature). ' +
  'A vacuous deliverable like "explore X" / "investigate Y" / "improve Z" with no concrete artifact will be DROPPED downstream — do not pad.\n' +
  'cost_rationale + value_rationale = one short sentence each explaining the score.\n' +
  'target_paths = files this work would touch (best guess), for downstream safety routing.\n' +
  'safety_flag = true if this touches SAFETY anchors (principles.md, alex/blake SKILL SAFETY zones, ' +
  'security/auth/token/encrypt/password, or destructive ops like delete/rm). risk_tag = "needs-human" if safety_flag else "safe".\n'

// ── Phase: Scan (parallel barrier — readers independent, all needed before rank) ──

phase('Scan')
log('Phase 1: Scan — ' + sources.length + ' parallel source readers')

var scanResults = await parallel(sources.map(function(src) {
  return function() {
    var locator = src.glob
      ? 'all ' + src.glob + ' files in the directory ' + src.path
      : 'the file ' + src.path
    return agent(
      'You are a backlog reader for TAD Surplus Burn Mode (read-only scan).\n' +
      'Read ' + locator + '. If the path does not exist or has no matching files, return an empty array [] (do NOT error).\n\n' +
      'For each distinct backlog item / idea / proposal / candidate / parked-phase you find, extract ONE candidate object.\n' +
      'Skip any item whose file content shows status: archived | completed | promoted (it is no longer actionable).\n\n' +
      SCORING_GUIDE + '\n' + COST_ANCHORS + '\n' +
      'Set source to "' + src.kind + '". id = a short slug derived from the item (e.g. file basename).\n' +
      'Return a JSON array of candidate objects. Empty array if nothing actionable.',
      { label: 'scan-' + src.kind, phase: 'Scan', schema: { type: 'array', items: CANDIDATE_SCHEMA }, model: 'sonnet' }
    )
  }
}))

var scanned = []
for (var s = 0; s < scanResults.length; s++) {
  var arr = Array.isArray(scanResults[s]) ? scanResults[s] : []
  if (!arr.length) {
    log('  source "' + sources[s].kind + '" (' + sources[s].path + '): 0 candidates (missing/empty/skipped)')
  } else {
    log('  source "' + sources[s].kind + '": ' + arr.length + ' candidates')
    for (var a = 0; a < arr.length; a++) { scanned.push(arr[a]) }
  }
}
log('Phase 1 complete: ' + scanned.length + ' raw candidates scanned')

// ── Phase: Generate (downstream of Scan — pipeline, NOT a barrier peer; P0-3/P0-4) ──

phase('Generate')

var priorTitles = scanned.map(function(c) { return c.title || c.id || '' }).filter(Boolean)
var priorText = priorTitles.length
  ? '\n\nALREADY ON THE BACKLOG (do NOT re-propose any of these):\n' +
    priorTitles.map(function(t) { return '- ' + t }).join('\n')
  : '\n\n(The existing backlog is empty.)'

var generated = await agent(
  'You are the OBJECTIVES-driven direction generator for TAD Surplus Burn Mode.\n' +
  'Read ' + objectivesPath + ' (TAD OKRs). If it does not exist, return [].\n\n' +
  'Propose ONLY NEW high-value directions that are ABSENT from the backlog list below. ' +
  'Each proposal MUST cite a specific OBJECTIVES Key Result (e.g. "O2/KR1") it advances — ' +
  'drop any idea you cannot tie to a concrete KR.\n' +
  'HARD CAP: at most 5 proposals. Quality over quantity.\n\n' +
  SCORING_GUIDE + '\n' + COST_ANCHORS + '\n' +
  'Set source to "generated" for every item. Put the cited KR in value_rationale.\n' +
  priorText + '\n\n' +
  'Return a JSON array (<=5) of candidate objects, or [] if no genuinely new KR-linked direction exists.',
  { label: 'generate', phase: 'Generate', schema: { type: 'array', items: CANDIDATE_SCHEMA }, model: 'sonnet' }
)

var genItems = Array.isArray(generated) ? generated : []
// Enforce source tag + KR-linkage (P2-1) + cap (defensive).
var genClean = []
for (var g = 0; g < genItems.length && genClean.length < 5; g++) {
  var gi = genItems[g]
  if (!gi) continue
  gi.source = 'generated' // always tagged generated (P2-2: never auto-eligible)
  var kr = (gi.value_rationale || '') + ' ' + (gi.summary || '') + ' ' + (gi.title || '')
  var hasKR = /\bO\d+\s*[\/\-: ]\s*KR\d+|\bKR\d+\b/i.test(kr)
  if (!hasKR) {
    log('  generated item dropped (no KR linkage): ' + (gi.title || gi.id))
    continue
  }
  genClean.push(gi)
}
log('Phase 2 complete: ' + genClean.length + ' KR-linked generated direction(s) (of ' + genItems.length + ' proposed)')

// ── Phase: Rank (plain JS, no agents) ───────────────────────────────────────

phase('Rank')

var all = scanned.concat(genClean)

// Mechanical SAFETY path-match list (P1-3 defense-in-depth). String/regex literals only.
var SAFETY_PATTERNS = [
  /principles\.md/i,
  /alex\/SKILL\.md/i,
  /blake\/SKILL\.md/i,
  /\bSAFETY\b/i,
  /anti_rationalization_registry/i,
  /forbidden_implementations/i,
  /NOT_via_alex_auto/i,
  /security|auth|token|encrypt|password/i,
  /\bdelete\b|\brm\s+-/i
]

function pathMatchesSafety(deliverable, targetPaths) {
  var hay = String(deliverable || '')
  if (targetPaths && targetPaths.length) { hay = hay + ' ' + targetPaths.join(' ') }
  // any path outside the repo (absolute path or parent-escape) is safety-relevant
  if (targetPaths && targetPaths.length) {
    for (var t = 0; t < targetPaths.length; t++) {
      var p = String(targetPaths[t] || '')
      if (p.charAt(0) === '/' || p.indexOf('..') !== -1) return true
    }
  }
  for (var k = 0; k < SAFETY_PATTERNS.length; k++) {
    if (SAFETY_PATTERNS[k].test(hay)) return true
  }
  return false
}

// Vacuous-deliverable detector (anti-theater, load-bearing — Rank.2).
function isVacuous(deliverable) {
  var d = String(deliverable || '').trim().toLowerCase()
  if (d === '') return true
  // pure exploratory verbs with no concrete artifact noun
  var verbOnly = /^(explore|investigate|improve|research|look into|consider|think about|understand|review|study)\b/
  var hasArtifact = /\b(file|workflow|skill|test|script|template|gate|epic|handoff|report|\.md|\.js|\.yaml|\.json|\.sh|ac\d|criteri|passing|ship|implement|build|add|create|write|fix|migrat|refactor)\b/
  if (verbOnly.test(d) && !hasArtifact.test(d)) return true
  return false
}

// Staleness detector (P1-4): summary/source markers indicating no longer actionable.
function isStale(c) {
  var blob = (String(c.summary || '') + ' ' + String(c.source || '') + ' ' + String(c.title || '')).toLowerCase()
  if (/status:\s*(archived|completed|promoted)/.test(blob)) return true
  if (/\b(archived|completed|promoted)\b/.test(blob) && /\bepic\b|\bcompletion\b/.test(blob)) return true
  return false
}

function normTitle(t) { return String(t || '').toLowerCase().trim().replace(/\s+/g, ' ') }
function costNumeric(tc) { return tc === 'L' ? 8 : tc === 'M' ? 3 : 1 } // S/M/L → 1/3/8

// Step 1: dedup by normalized title, keep higher expected_value (P0-3).
function expectedValueOf(c) {
  var v = typeof c.value === 'number' ? c.value : 0
  var conf = typeof c.confidence === 'number' ? c.confidence : 0
  return v * conf
}

var byTitle = {}
var dedupMerges = 0
for (var di = 0; di < all.length; di++) {
  var c = all[di]
  var nt = normTitle(c.title)
  if (!nt) nt = normTitle(c.id) || ('anon-' + di)
  if (!byTitle[nt]) {
    byTitle[nt] = c
  } else {
    dedupMerges++
    var existing = byTitle[nt]
    if (expectedValueOf(c) > expectedValueOf(existing)) {
      log('  dedup: "' + nt + '" — keeping higher expected_value duplicate')
      byTitle[nt] = c
    } else {
      log('  dedup: "' + nt + '" — keeping existing higher/equal expected_value')
    }
  }
}
var deduped = []
var titleKeys = Object.keys(byTitle)
for (var tk = 0; tk < titleKeys.length; tk++) { deduped.push(byTitle[titleKeys[tk]]) }
if (dedupMerges) log('Dedup merged ' + dedupMerges + ' duplicate title(s)')

// Steps 2 & 3: anti-theater drop + staleness drop.
var ranked = []
var droppedCount = 0
var staleCount = 0
for (var ri = 0; ri < deduped.length; ri++) {
  var cand = deduped[ri]
  if (isVacuous(cand.deliverable)) {
    droppedCount++
    log('  DROP (vacuous deliverable): ' + (cand.title || cand.id))
    continue
  }
  if (isStale(cand)) {
    staleCount++
    log('  DROP (stale: archived/completed/promoted): ' + (cand.title || cand.id))
    continue
  }
  ranked.push(cand)
}

// Steps 4-8: enrich every surviving candidate with derived fields.
for (var ei = 0; ei < ranked.length; ei++) {
  var r = ranked[ei]
  var v2 = typeof r.value === 'number' ? r.value : 0
  var cf = typeof r.confidence === 'number' ? r.confidence : 0
  r.cost_numeric = costNumeric(r.token_cost)
  r.expected_value = v2 * cf
  r.density = r.expected_value / r.cost_numeric

  // Step 7: mechanical SAFETY override — agent flag OR mechanical path-match (P1-3).
  var agentFlag = r.safety_flag === true
  var mech = pathMatchesSafety(r.deliverable, r.target_paths)
  r.safety_flag = agentFlag || mech
  if (r.safety_flag) { r.risk_tag = 'needs-human' }
  if (!r.risk_tag) { r.risk_tag = 'safe' }

  // Step 8: auto_eligible = safe AND value>=3 AND NOT generated (P0-1 floor + P2-2).
  r.auto_eligible = (r.risk_tag === 'safe') && (v2 >= 3) && (r.source !== 'generated')
}

// Step 6: sort expected_value DESC, density DESC tiebreaker (value-first — P0-1).
ranked.sort(function(x, y) {
  if (y.expected_value !== x.expected_value) return y.expected_value - x.expected_value
  return y.density - x.density
})

var autoEligibleCount = ranked.filter(function(r) { return r.auto_eligible }).length
var needsHumanCount = ranked.filter(function(r) { return r.risk_tag === 'needs-human' }).length
var generatedCount = ranked.filter(function(r) { return r.source === 'generated' }).length

log('Phase 3 complete: ' + ranked.length + ' ranked, ' + droppedCount + ' dropped(vacuous), ' +
    staleCount + ' stale, ' + autoEligibleCount + ' auto-eligible, ' + needsHumanCount + ' needs-human')

// ── Render markdown plan (from template shape) + JSON sidecar ────────────────

function fmtNum(n, dp) {
  var f = Number(n)
  if (!isFinite(f)) return '0'
  return f.toFixed(dp)
}
function esc(s) { return String(s == null ? '' : s).replace(/\|/g, '\\|').replace(/\n/g, ' ') }

var header =
  '# Surplus Plan — ' + dateStamp + '\n\n' +
  '> Value-first ranking. expected_value = value x confidence. density = expected_value / cost_numeric (tiebreaker only).\n' +
  '> cost legend: S/M/L → 1/3/8.\n\n' +
  '**Totals:** total ranked ' + ranked.length +
  ' · dropped (vacuous) ' + droppedCount +
  ' · stale ' + staleCount +
  ' · auto-eligible ' + autoEligibleCount +
  ' · needs-human ' + needsHumanCount + '\n\n'

var tableHeader =
  '| # | Task | Source | Value | Cost | Conf | ExpVal | Density | Risk | Auto? | Deliverable | Why |\n' +
  '|---|------|--------|-------|------|------|--------|---------|------|-------|-------------|-----|\n'

var rows = ''
if (ranked.length === 0) {
  rows = '| — | _(0 ranked, ' + droppedCount + ' dropped, ' + staleCount + ' stale)_ | — | — | — | — | — | — | — | — | — | — |\n'
} else {
  for (var rr = 0; rr < ranked.length; rr++) {
    var row = ranked[rr]
    rows += '| ' + (rr + 1) +
      ' | ' + esc(row.title) +
      ' | ' + esc(row.source) +
      ' | ' + esc(row.value) +
      ' | ' + esc(row.token_cost) +
      ' | ' + fmtNum(row.confidence, 2) +
      ' | ' + fmtNum(row.expected_value, 2) +
      ' | ' + fmtNum(row.density, 2) +
      ' | ' + esc(row.risk_tag) +
      ' | ' + (row.auto_eligible ? 'yes' : 'no') +
      ' | ' + esc(row.deliverable) +
      ' | ' + esc(row.value_rationale || row.summary) +
      ' |\n'
  }
}

// "🔒 Needs You" section: not auto-eligible rows (safety/needs-human/generated).
var needsYou = ranked.filter(function(r) { return !r.auto_eligible })
var needsBlock = '\n## 🔒 Needs You (not auto-eligible)\n\n'
if (needsYou.length === 0) {
  needsBlock += '_None — every ranked item is auto-eligible (Phase 2 will still require your go-ahead)._\n'
} else {
  needsBlock += '| Task | Source | Risk | Why not auto |\n|------|--------|------|-------------|\n'
  for (var ny = 0; ny < needsYou.length; ny++) {
    var n = needsYou[ny]
    var why = n.source === 'generated' ? 'generated (unvetted)'
      : n.risk_tag === 'needs-human' ? 'safety/needs-human'
      : 'value < 3 floor'
    needsBlock += '| ' + esc(n.title) + ' | ' + esc(n.source) + ' | ' + esc(n.risk_tag) + ' | ' + why + ' |\n'
  }
}

var planMarkdown = header + tableHeader + rows + needsBlock +
  '\n---\n_Phase 1 (scan only) — NO execution, NO mutation beyond this plan + its .json sidecar._\n'

var sidecar = {
  date: dateStamp,
  generated_from: 'surplus-scan',
  totals: {
    total: ranked.length,
    dropped: droppedCount,
    stale: staleCount,
    auto_eligible: autoEligibleCount,
    needs_human: needsHumanCount,
    generated: generatedCount
  },
  rows: ranked.map(function(r) {
    return {
      id: r.id,
      title: r.title,
      source: r.source,
      summary: r.summary,
      value: r.value,
      confidence: r.confidence,
      token_cost: r.token_cost,
      cost_numeric: r.cost_numeric,
      expected_value: r.expected_value,
      density: r.density,
      cost_rationale: r.cost_rationale,
      value_rationale: r.value_rationale,
      deliverable: r.deliverable,
      target_paths: r.target_paths || [],
      safety_flag: r.safety_flag,
      risk_tag: r.risk_tag,
      auto_eligible: r.auto_eligible
    }
  })
}

var sidecarJson = JSON.stringify(sidecar, null, 2)

// Sandbox constraint: the workflow runtime has NO filesystem API. The two plan
// artifacts (markdown + JSON sidecar) are returned as rendered content; the
// invoking `surplus` SKILL persists them to plan_path / json_path with the Write
// tool. plan_path/json_path are the agreed write targets (Phase-2 reads json_path).
return {
  plan_path: outputPath,
  json_path: jsonPath,
  plan_markdown: planMarkdown,
  sidecar_json: sidecarJson,
  total: ranked.length,
  dropped: droppedCount,
  stale: staleCount,
  auto_eligible: autoEligibleCount,
  needs_human: needsHumanCount,
  generated: generatedCount
}
