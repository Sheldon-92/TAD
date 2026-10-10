export const meta = {
  name: 'pack-dogfood',
  description: 'Blind A/B dogfood across a list of capability packs. Per pack: extract the fixture scenario as the task → generate a CONTROL answer (task text only, never touches the pack dir) + a WITH-PACK answer → an independent BLIND judge scores both on a quality rubric, WebSearch-verifies specific claims, and flags any specific-but-wrong claim. Blind order is set by index parity so the judge cannot infer which answer used the pack. Tests real answer quality, not just discrimination. Generalized from the proven dogfood-all workflow; evidence dir is parameterized. Input via args={packs, evidence_dir}; packs has no default and must be passed explicitly. Resumable.',
  whenToUse: 'When validating that upgraded packs produce genuinely better answers than a strong generalist control — winner on CORRECT specifics is real quality; CONTROL/TIE or wrong_claims is a real gap to fix.',
  phases: [
    { title: 'Snapshot', detail: 'Copy existing dogfood baselines to .prev.md for regression comparison' },
    { title: 'Task', detail: 'Extract user-facing scenario from each pack fixture' },
    { title: 'Answers', detail: 'Control + with-pack answers; blind order by index parity' },
    { title: 'Judge', detail: 'Blind rubric scoring + WebSearch fact-check' },
    { title: 'Regression', detail: 'Compare current-pack vs previous-baseline; detect lost knowledge' }
  ]
}

// ── Args parsing (Object.keys loop — canonical convention) ──────────────────
// args: injected as an object (measured 2026-10-09 on claude 2.1.295, inline and scriptPath). packs has NO default: a run that selects packs by itself is unsafe, so it must be passed explicitly.

let packs = null
let evidenceDir = null

if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'packs') packs = args[keys[i]]
    if (keys[i] === 'evidence_dir') evidenceDir = args[keys[i]]
  }
}

// ── Defaults ────────────────────────────────────────────────────────────────

// Deliberately empty: pass the packs via args={packs:[...]}. No pack is selected by default.
const DEFAULT_PACKS = []
// Evidence output dir — where each per-pack judgment (dogfood-<pack>.md) is persisted.
const DEFAULT_EVIDENCE_DIR = '.tad/evidence/pack-dogfood'

if (!packs) packs = DEFAULT_PACKS
if (!evidenceDir) evidenceDir = DEFAULT_EVIDENCE_DIR

// Fail loud on missing input rather than silently no-op.
if (!Array.isArray(packs) || packs.length === 0) {
  log('ERROR: no packs. Packs must be passed explicitly: args={packs:["name",...]}. There is no default.')
  return { error: 'no packs', evidence_dir: evidenceDir }
}

const EV = evidenceDir
log(`pack-dogfood: ${packs.length} packs — ${packs.join(', ')} → ${EV}`)

// Whole-entry (trimmed, lower-cased, trailing punctuation removed) matches only: a judge that has
// nothing to report sometimes writes a note into wrong_claims. No prefix matching, so a real claim
// such as "No rate limit exists; actual is 100/min" is kept.
const NO_FINDING_SENTINELS = ['', 'none', 'n/a', 'no wrong claims', 'no errors found', '未发现明确错误', '未发现错误', '无']
const realClaims = (arr) => (Array.isArray(arr) ? arr : []).filter((c) => {
  const k = String(c).trim().toLowerCase().replace(/[\s.,;:!。，；：！]+$/, '')
  return NO_FINDING_SENTINELS.indexOf(k) === -1
})

// ── Schemas (preserved verbatim from the proven workflow) ───────────────────

const TASK_SCHEMA = {
  type: 'object',
  required: ['task'],
  properties: { task: { type: 'string', description: 'the realistic domain task/question ONLY (the scenario prompt a user would ask) — NOT any expected answer or pack rule' } },
}
const JUDGE_SCHEMA = {
  type: 'object',
  required: ['winner', 'margin', 'pack_correctness', 'control_correctness', 'wrong_claims', 'rationale'],
  properties: {
    winner: { type: 'string', enum: ['1', '2', 'tie'] },
    margin: { type: 'string', enum: ['slight', 'clear', 'decisive'] },
    pack_correctness: { type: 'number', description: 'leave 0; filled by conductor' },
    control_correctness: { type: 'number', description: 'leave 0; filled by conductor' },
    answer1_score: { type: 'object', properties: { correctness: { type: 'number' }, actionability: { type: 'number' }, specificity: { type: 'number' }, completeness: { type: 'number' } } },
    answer2_score: { type: 'object', properties: { correctness: { type: 'number' }, actionability: { type: 'number' }, specificity: { type: 'number' }, completeness: { type: 'number' } } },
    wrong_claims: { type: 'array', items: { type: 'string' }, description: 'specific-but-WRONG claims in EITHER answer, with which answer + correct value (WebSearch-verified). If there are none this MUST be [] - never put a note such as "no errors found" here.' },
    rationale: { type: 'string' },
  },
}
const REGRESSION_SCHEMA = {
  type: 'object',
  required: ['regression_found', 'lost_knowledge'],
  properties: {
    regression_found: { type: 'boolean', description: 'true if any correct knowledge from the previous baseline was lost in the current version' },
    lost_knowledge: { type: 'array', items: { type: 'string' }, description: 'list of specific knowledge/rules/thresholds that the previous version had correctly but the current version lost or weakened' },
    analysis: { type: 'string', description: 'brief explanation of the regression comparison methodology and findings' },
  },
}

// ── Snapshot: copy existing baselines for regression comparison ──────────────

phase('Snapshot')
for (let i = 0; i < packs.length; i++) {
  const p = typeof packs[i] === 'string' ? packs[i] : packs[i].name
  await agent(
    `If the file ${EV}/dogfood-${p}.md exists, copy it to ${EV}/dogfood-${p}.prev.md (overwrite if exists). ` +
    `If it does not exist, do nothing. Report what you did.`,
    { label: `snapshot:${p}`, phase: 'Snapshot' }
  )
}

// ── Pipeline (orchestration unchanged from the proven workflow) ─────────────

const results = await pipeline(
  packs,
  // Stage 1: extract the task from the pack's fixture (returns task text only)
  (pack) => agent(
    `Read the fixture under .agents/skills/${pack}/examples/ (the *.md file(s)). Extract ONLY the scenario/task prompt — the realistic question or request a user would pose in this pack's domain. Return it verbatim (or lightly cleaned) as "task". Do NOT include any expected answer, rubric, or the pack's own rules — only the user-facing task.`,
    { label: `task:${pack}`, phase: 'Task', schema: TASK_SCHEMA }
  ).then((t) => (t && t.task) ? t.task : `Give expert, concrete guidance for a realistic ${pack} task.`),
  // Stage 2: persist fixture for future regression baselines
  async (task, pack) => {
    await agent(
      `Write the following task text to ${EV}/fixtures/${pack}.task.md (create dir if needed, ` +
      `overwrite if exists):\n\n${task}`,
      { label: `persist:${pack}`, phase: 'Task' }
    )
    return task
  },
  // Stage 3: control + with-pack answers (blind order by index parity)
  (task, pack, idx) => parallel([
    () => agent(
      `You are a competent senior generalist. Answer this WITHOUT loading any specialized skill — use only your own knowledge. Do NOT read any file under .agents/skills/, nor any file under any .claude directory. Task:\n\n${task}\n\nGive your best concrete answer.`,
      { label: `control:${pack}`, phase: 'Answers' }
    ),
    () => agent(
      `Answer the task below by FIRST reading .agents/skills/${pack}/SKILL.md and its references/, then applying its concrete rules. Task:\n\n${task}`,
      { label: `withpack:${pack}`, phase: 'Answers' }
    ),
  ]).then((ans) => {
    const control = ans[0] || '(control failed)'
    const withpack = ans[1] || '(with-pack failed)'
    const packFirst = (idx % 2 === 1)              // odd idx → pack is Answer 1
    return {
      pack, task,
      answer1: packFirst ? withpack : control,
      answer2: packFirst ? control : withpack,
      pack_is: packFirst ? '1' : '2',
    }
  }),
  // Stage 4: blind judge with WebSearch fact-check
  (b, pack) => agent(
    `You are a strict independent technical judge. Two answers respond to the SAME task. ONE used a specialized domain skill, the OTHER did not — you do NOT know which. Judge PURELY on merit. A confident WRONG specific is worse than an honest general statement — do not reward verbosity or unverified specificity.\n\n` +
    `TASK:\n${b.task}\n\n=== ANSWER 1 ===\n${b.answer1}\n\n=== ANSWER 2 ===\n${b.answer2}\n\n` +
    `Score each 1-5 on correctness, actionability, specificity, completeness. ⚠️ WebSearch-verify the key specific claims (numbers, tool/model names, versions, thresholds, APIs) in BOTH answers against current primary docs; list EVERY specific-but-wrong claim (which answer + correct value). A wrong specific tanks that answer's correctness. Then pick winner (1/2/tie) + margin + rationale (did the winner win on CORRECT specifics or just verbosity?).\n` +
    `Write full judgment to ${EV}/dogfood-${pack}.md`,
    { label: `judge:${pack}`, phase: 'Judge', schema: JUDGE_SCHEMA }
  ).then((j) => ({ pack, pack_is: b.pack_is, task: b.task, verdict: j || null, judge_failed: !j })),
  // Stage 5: regression check (uses .prev.md baseline from snapshot)
  (judged, pack) => agent(
    `REGRESSION CHECK for capability pack "${pack}".\n\n` +
    `1. Check if ${EV}/dogfood-${pack}.prev.md exists. If NOT → return regression_found=false\n` +
    `   (no previous baseline — this is the first run or first run after adding regression).\n` +
    `2. Read ${EV}/dogfood-${pack}.prev.md — this is the PREVIOUS run's judgment (baseline).\n` +
    `3. Read the task from: ${EV}/fixtures/${pack}.task.md (persisted by the current run).\n` +
    `   Fallback: use this task text: "${judged.task || '(unavailable)'}"\n` +
    `4. Read .agents/skills/${pack}/SKILL.md and references/ (the CURRENT version).\n` +
    `5. Answer the task using the CURRENT pack rules.\n` +
    `6. Compare your answer against the PREVIOUS judgment's winning answer.\n` +
    `7. Identify any knowledge/rules/specifics that the PREVIOUS answer had correctly\n` +
    `   but the CURRENT answer LOST.\n\n` +
    `regression_found = true if any correct knowledge was lost.\n` +
    `Write analysis to ${EV}/regression-${pack}.md`,
    { label: `regression:${pack}`, phase: 'Regression', schema: REGRESSION_SCHEMA }
  ).then((reg) => ({
    pack: judged.pack || pack,
    pack_is: judged.pack_is,
    task: judged.task,
    verdict: judged.verdict,
    judge_failed: !!judged.judge_failed,
    regression: reg || { regression_found: false, lost_knowledge: [] },
  }))
)

const clean = results.filter(Boolean)
// A failed judge is reported on its own: it is not a tie, a win, or a wrong claim.
const judgeFailures = clean.filter((r) => r.judge_failed || !r.verdict).map((r) => ({ pack: r.pack, reason: 'judge failed' }))
// A pack whose pipeline produced no result at all (a stage threw, or the agent was skipped) is reported too,
// so total === judged + judge_failures.length always holds.
const seen = new Set(clean.map((r) => r.pack))
packs.forEach((p, i) => {
  const name = typeof p === 'string' ? p : p.name
  if (!results[i] && !seen.has(name)) judgeFailures.push({ pack: name, reason: 'no result' })
})
const rows = clean.filter((r) => !r.judge_failed && r.verdict).map((r) => {
  const v = r.verdict
  const packWon = v.winner === r.pack_is
  const s1 = v.answer1_score || {}, s2 = v.answer2_score || {}
  const packScore = r.pack_is === '1' ? s1 : s2
  return {
    pack: r.pack,
    result: v.winner === 'tie' ? 'TIE' : (packWon ? 'WITH-PACK' : 'CONTROL'),
    margin: v.margin || '',
    pack_score: packScore,
    wrong_claims: realClaims(v.wrong_claims),
    regression: r.regression || {},
  }
})
return {
  evidence_dir: EV,
  total: packs.length,
  judged: rows.length,
  judge_failures: judgeFailures,
  pack_wins: rows.filter((r) => r.result === 'WITH-PACK').length,
  ties: rows.filter((r) => r.result === 'TIE').length,
  control_wins: rows.filter((r) => r.result === 'CONTROL').length,
  packs_with_wrong_claims: rows.filter((r) => r.wrong_claims.length > 0).map((r) => r.pack),
  packs_with_regression: rows.filter((r) => r.regression && r.regression.regression_found).map((r) => r.pack),
  rows,
  note: 'WITH-PACK wins on correct specifics = real quality. CONTROL/TIE or wrong_claims = a real gap to fix. regression_found = knowledge lost in upgrade. judge_failures = packs whose judge returned nothing (not counted anywhere else). Conductor must read dogfood-*.md before judging.',
}
