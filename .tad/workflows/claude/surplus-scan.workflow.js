export const meta = {
  name: 'surplus-scan',
  description: 'Surplus Burn Mode Phase 1: scan TAD backlog sources + OBJECTIVES-driven generator, rank candidates value-first (expected_value = value x confidence; density tiebreaker), tag risk/safety, render a ranked SURPLUS-PLAN markdown and JSON sidecar and return them with their target paths. The script itself writes nothing: the caller persists the returned plan and JSON. Mutates no backlog source.',
  whenToUse: 'Invoked by *surplus --plan to surface highest-value backlog work. Read-only scan + rank; NO execution (Phase 2).',
  phases: [
    { title: 'Scan', detail: 'Parallel readers, one per backlog source, extract candidates' },
    { title: 'Generate', detail: 'One generator proposes NEW OBJECTIVES-KR-linked directions (downstream of Scan)' },
    { title: 'Rank', detail: 'Plain-JS dedup, anti-theater drop, staleness drop, value-first sort, safety tag, render artifacts' }
  ]
}

// runtime-requirements:
//   agent — hard — step executor behind every reader/generator agent call;
//                  missing => the entry probe throws naming it, before any agent activity
//   phase — hard — phase marker for Scan/Generate/Rank; missing => the entry
//                  probe throws naming it, before any agent activity
//   (No budget or workflow global is required: this script makes no nested
//    calls and keeps no budget ledger.)
// The entry probe (before the first log line) checks existence only via
// typeof and never calls the probed globals.

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

if (!dateStamp) { throw new Error('surplus-scan: no date arg received. Invoke via the *surplus SKILL (it stamps the date). Direct invocation must pass args: {date: "YYYY-MM-DD"}.') }
if (!objectivesPath) objectivesPath = 'OBJECTIVES.md'
if (!outputPath) outputPath = '.tad/active/SURPLUS-PLAN-' + dateStamp + '.md'

// Default scan sources: dir globs + repo-root files. Each entry has a glob-or-file
// path and a kind. A missing dir/file → skip + log(), never throw (P0-4 graceful-skip).
if (!sources) {
  sources = [
    { path: '.tad/active/ideas/', glob: '*.md', kind: 'ideas' },
    { path: '.tad/active/epics/', glob: '*.md', kind: 'epics-parked' },
    { path: 'NEXT.md', glob: null, kind: 'next' }
  ]
}

// JSON sidecar path = same stem as markdown plan, .json extension (P1-2).
var jsonPath = outputPath.replace(/\.md$/, '') + '.json'

// ── Runtime-requirements probe (existence-only; never calls the probed
// globals, costs no agent call and no tokens). Hard requirements throw here
// naming the missing global — before the first phase marker, before any
// agent activity.
if (typeof agent !== 'function') {
  throw new Error('surplus-scan: missing hard runtime requirement: agent — no step executor exists in this runtime; refusing to start')
}
if (typeof phase !== 'function') {
  throw new Error('surplus-scan: missing hard runtime requirement: phase — phase markers do not exist in this runtime; refusing to start')
}
log('probe: hard runtime requirements present: agent, phase')

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
    risk_tag: { type: 'string', enum: ['safe', 'needs-human'] },
    // ── 三查 reader 字段（Phase 4 scan-surface，HANDOFF §4.1；与既有 13 字段并列）──
    source_status: { type: 'string', enum: ['live', 'landed', 'archived', 'completed', 'promoted', 'superseded', 'unknown'] }, // 来源活状态类别，reader 回活状态件核
    source_status_evidence: { type: 'string' }, // 活状态件引用（路径＋所核字段/计数原值）；source_status 非 unknown 时必填
    human_prereq: { type: 'boolean' }, // 是否卡在供给型人供前置（边界见三查指令 ⓐ）
    human_prereq_what: { type: 'string' }, // 前置具体内容；human_prereq=true 时必填
    cited_paths: { type: 'array', items: { type: 'string' } }, // 立论/交付引用的既有文件（不含 target_paths）
    cited_missing: { type: 'array', items: { type: 'string' } } // cited_paths 中逐件实存核验后缺位的子集
  },
  required: ['id', 'title', 'source', 'value', 'confidence', 'token_cost', 'deliverable', 'risk_tag']
}

// StructuredOutput tool requires a top-level type:'object' schema — a top-level
// array schema is rejected by the Anthropic API (400 input_schema.type). Wrap
// the candidate array under a "candidates" key.
var CANDIDATES_SCHEMA = { type: 'object', properties: { candidates: { type: 'array', items: CANDIDATE_SCHEMA } }, required: ['candidates'] }

// token_cost anchors — embedded IN every reader prompt (P0-2):
var COST_ANCHORS =
  'token_cost rubric (assign exactly one):\n' +
  '  S = single file, no new abstraction, ~<30k tokens.\n' +
  '  M = 2-4 files, moderate change.\n' +
  '  L = new workflow / Epic-phase / SAFETY-adjacent / >~100k tokens.\n'

// 三查指令（Phase 4 scan-surface，HANDOFF §4.1）：Scan 与 Generate 两处 agent
// 指令各加同一段。Generate 合并/改写候选时必须保留来源 reader 的三组字段，不许丢弃。
var THREE_CHECKS =
  '三查（扫描侧分诊，逐候选必填；任一不过由 Rank 门控降 needs-human 并显名）：\n' +
  'ⓐ 人供前置查：逐项列出需人类提供的账号/凭据、grant、出网授权、命名、pins、对接人、人域验收；未备者 human_prereq=true 并在 human_prereq_what 写明具体内容（如「L3 账号＋PM 1:1，只有用户能给」）。边界：只有供给型前置入此面；「未获批/批准出处」类事实不入此面——批准面本身是活状态件，与候选前提矛盾或缺位时走 ⓑ（source_status=unknown、evidence 点名批准面）。反面样本：标 auto-eligible 的候选卡在只有用户能给的 L3 账号＋PM 1:1 上、执行面才发现。\n' +
  'ⓑ 来源活状态查：候选所据的状态断言必须回活状态件本身核（如队列文件的现行计数、台账的现行行），填 source_status（枚举）与 source_status_evidence（路径＋所核字段/计数原值；非 unknown 时必填）；叙述文本与活状态矛盾时以活状态为准；核不到或只有叙述文本可引时 source_status=unknown。反面样本：据父文档叙述立论称队列有 52 条 parked 待处置，活状态件实况是 52 条已全数出队、挂起 0。\n' +
  'ⓒ 引用件在盘查：candidate 的立论与 deliverable 引用的每个既有文件路径逐件实存核验，填 cited_paths（只装引用面，不含 target_paths），缺位件入 cited_missing。反面样本：基线引用的 EPIC 文件本体缺位，扫描未标出。\n'

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
      SCORING_GUIDE + '\n' + COST_ANCHORS + '\n' + THREE_CHECKS + '\n' +
      'Set source to "' + src.kind + '". id = a short slug derived from the item (e.g. file basename).\n' +
      'Return a JSON object {"candidates": [...]} — an array of candidate objects under the "candidates" key. Use {"candidates": []} if nothing actionable.',
      { label: 'scan-' + src.kind, phase: 'Scan', schema: CANDIDATES_SCHEMA }
    )
  }
}))

var scanned = []
for (var s = 0; s < scanResults.length; s++) {
  var r = scanResults[s]; var arr = (r && Array.isArray(r.candidates)) ? r.candidates : []
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
  SCORING_GUIDE + '\n' + COST_ANCHORS + '\n' + THREE_CHECKS + '\n' +
  'Set source to "generated" for every item. Put the cited KR in value_rationale.\n' +
  priorText + '\n\n' +
  'Return a JSON object {"candidates": [...]} — an array (<=5) of candidate objects under the "candidates" key, or {"candidates": []} if no genuinely new KR-linked direction exists.',
  { label: 'generate', phase: 'Generate', schema: CANDIDATES_SCHEMA }
)

var genItems = (generated && Array.isArray(generated.candidates)) ? generated.candidates : []
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

// ── 分层声明（Phase 4）：扫描侧三查是信号＋分诊层——它让计划在产出时就显名
// 降级；执行侧 surplus-execute 分支 0 仍是硬闸，本 workflow 不改、不弱化
// 执行侧任何判定。log() 行是运行注记，不是证据面：分类的全部判定落进
// sidecar 字段面（status_unknown／gate_reasons 等）与回放报告面。

// ── Phase: Rank (plain JS, no agents) ───────────────────────────────────────

phase('Rank')

var all = scanned.concat(genClean)

// === classify-block BEGIN (replay-extractable; keep dependency-free; ANY edit to this block requires re-running .tad/scripts/surplus-scan-replay.mjs to 12/12 PASS before the edit counts as done) ===

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

// Staleness TEXT detector (P1-4): summary/source markers indicating no longer
// actionable. Per D11 this is a SIGNAL only (sidecar stale_text_signal): it
// never decides a disposition on its own — the field layer (§4.2 order) does.
function isStale(c) {
  var blob = (String(c.summary || '') + ' ' + String(c.source || '') + ' ' + String(c.title || '')).toLowerCase()
  if (/status:\s*(archived|completed|promoted)/.test(blob)) return true
  if (/\b(archived|completed|promoted)\b/.test(blob) && /\bepic\b|\bcompletion\b/.test(blob)) return true
  return false
}

function normTitle(t) { return String(t || '').toLowerCase().trim().replace(/\s+/g, ' ') }

// Field-layer terminal states (§4.2 step 2): a source_status in this set drops
// the row as dropped-stale. 'live' and 'unknown' are NOT here — they flow on
// to the gate step; a missing/unknown status is gated, never text-dropped (D11).
var DROP_STATUSES = ['landed', 'archived', 'completed', 'promoted', 'superseded']

// classifyCandidate(c) -> {disposition, auto_eligible, status_unknown, reasons,
// stale_text_signal, risk_tag}; disposition is a closed set:
// ranked | dropped-stale | dropped-vacuous | needs-human.
// Decision order is pinned (§4.2): 1 vacuous -> dropped-vacuous; 2 field-enum
// stale -> dropped-stale; 3 any gate reason -> needs-human (auto=false,
// risk_tag derived 'needs-human'); 4 else ranked (auto = derived
// risk_tag==='safe' AND value>=3 AND source!=generated — the pre-Phase-4
// rule). risk_tag derivation (§4.2 steps 3-4): any gate hit derives
// 'needs-human'; otherwise the reader tag stands (a reader 'needs-human'
// stays, anything else reads 'safe'). The safety reason folds in the reader
// flag OR the mechanical path-match (P1-3), as before.
function classifyCandidate(c) {
  var reasons = []
  var staleText = isStale(c)
  var readerRisk = (c.risk_tag === 'needs-human') ? 'needs-human' : 'safe'
  if (isVacuous(c.deliverable)) {
    return { disposition: 'dropped-vacuous', auto_eligible: false, status_unknown: false, reasons: reasons, stale_text_signal: staleText, risk_tag: readerRisk }
  }
  var ss = c.source_status
  if (DROP_STATUSES.indexOf(ss) !== -1) {
    return { disposition: 'dropped-stale', auto_eligible: false, status_unknown: false, reasons: reasons, stale_text_signal: staleText, risk_tag: readerRisk }
  }
  var statusUnknown = (ss == null || ss === 'unknown')
  if (statusUnknown) reasons.push('status-unknown')
  if (c.human_prereq === true) reasons.push('human-prereq')
  var cm = Array.isArray(c.cited_missing) ? c.cited_missing : []
  if (cm.length) reasons.push('cited-missing')
  if (c.safety_flag === true || pathMatchesSafety(c.deliverable, c.target_paths)) reasons.push('safety')
  if (reasons.length) {
    return { disposition: 'needs-human', auto_eligible: false, status_unknown: statusUnknown, reasons: reasons, stale_text_signal: staleText, risk_tag: 'needs-human' }
  }
  var v = typeof c.value === 'number' ? c.value : 0
  var auto = (readerRisk === 'safe') && (v >= 3) && (c.source !== 'generated')
  return { disposition: 'ranked', auto_eligible: auto, status_unknown: false, reasons: reasons, stale_text_signal: staleText, risk_tag: readerRisk }
}

// === classify-block END ===

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

// Steps 2-8: classification by the classify-block （判定序见 §4.2：vacuous →
// field-enum stale → gate → ranked). The isStale TEXT layer no longer decides
// any disposition on its own (D11): its hit is recorded per row as the
// stale_text_signal sidecar field. safety_flag keeps its prior merged
// semantics (reader flag OR the mechanical path-match). risk_tag is DERIVED
// by the classify-block (§4.2 steps 3-4: any gate hit -> 'needs-human';
// otherwise the reader tag stands) and consumed verbatim below, so the plan
// Risk column, totals.needs_human and the Needs You section cannot disagree.
var ranked = []
var droppedCount = 0
var staleCount = 0
var statusUnknownCount = 0
for (var ri = 0; ri < deduped.length; ri++) {
  var cand = deduped[ri]
  var cls = classifyCandidate(cand)
  cand.status_unknown = cls.status_unknown
  cand.gate_reasons = cls.reasons
  cand.stale_text_signal = cls.stale_text_signal
  if (cls.disposition === 'dropped-vacuous') {
    droppedCount++
    log('  DROP (vacuous deliverable): ' + (cand.title || cand.id))
    continue
  }
  if (cls.disposition === 'dropped-stale') {
    staleCount++
    log('  DROP (stale: source_status=' + cand.source_status + '): ' + (cand.title || cand.id))
    continue
  }
  cand.auto_eligible = cls.auto_eligible
  if (cls.reasons.indexOf('safety') !== -1) { cand.safety_flag = true }
  cand.risk_tag = cls.risk_tag
  if (cls.status_unknown) statusUnknownCount++
  ranked.push(cand)
}

// Enrich every surviving candidate with derived fields.
for (var ei = 0; ei < ranked.length; ei++) {
  var r = ranked[ei]
  var v2 = typeof r.value === 'number' ? r.value : 0
  var cf = typeof r.confidence === 'number' ? r.confidence : 0
  r.cost_numeric = costNumeric(r.token_cost)
  r.expected_value = v2 * cf
  r.density = r.expected_value / r.cost_numeric
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
    staleCount + ' stale, ' + autoEligibleCount + ' auto-eligible, ' + needsHumanCount + ' needs-human, ' +
    statusUnknownCount + ' status-unknown')

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
  ' · needs-human ' + needsHumanCount +
  ' · status-unknown ' + statusUnknownCount + '\n\n'

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
    var why
    if (n.gate_reasons && n.gate_reasons.length) {
      var firstReason = n.gate_reasons[0]
      why = firstReason === 'status-unknown' ? 'status unknown'
        : firstReason === 'human-prereq' ? 'human prerequisite: ' + (n.human_prereq_what || '')
        : firstReason === 'cited-missing' ? 'cited artifact missing: ' + (n.cited_missing || []).join(', ')
        : 'safety/needs-human'
    } else {
      why = n.source === 'generated' ? 'generated (unvetted)'
        : n.risk_tag === 'needs-human' ? 'safety/needs-human'
        : 'value < 3 floor'
    }
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
    generated: generatedCount,
    status_unknown: statusUnknownCount
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
      auto_eligible: r.auto_eligible,
      source_status: (r.source_status == null ? null : r.source_status),
      source_status_evidence: r.source_status_evidence || null,
      status_unknown: r.status_unknown === true,
      human_prereq: r.human_prereq === true,
      human_prereq_what: r.human_prereq_what || null,
      cited_paths: r.cited_paths || [],
      cited_missing: r.cited_missing || [],
      gate_reasons: r.gate_reasons || [],
      stale_text_signal: r.stale_text_signal === true
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
  status_unknown: statusUnknownCount,
  generated: generatedCount
}
