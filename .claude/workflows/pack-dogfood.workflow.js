export const meta = {
  name: 'pack-dogfood',
  description: 'Blind A/B dogfood across a list of capability packs. Per pack: extract the fixture scenario as the task → generate a CONTROL answer (task text only, never touches the pack dir) + a WITH-PACK answer → an independent BLIND judge scores both on a quality rubric, WebSearch-verifies specific claims, and flags any specific-but-wrong claim. Blind order is set by index parity so the judge cannot infer which answer used the pack. Tests real answer quality, not just discrimination. Generalized from the proven dogfood-all workflow; evidence dir is parameterized. Input via args={packs, evidence_dir} or the top-of-file CONSTs. Resumable.',
  whenToUse: 'When validating that upgraded packs produce genuinely better answers than a strong generalist control — winner on CORRECT specifics is real quality; CONTROL/TIE or wrong_claims is a real gap to fix.',
  phases: [
    { title: 'Task', detail: 'Extract the user-facing scenario from each pack fixture (task text only)' },
    { title: 'Answers', detail: 'Control (no pack) + with-pack answers in parallel; blind order by index parity' },
    { title: 'Judge', detail: 'Blind rubric scoring + WebSearch fact-check of specific claims; persisted per pack' }
  ]
}

// ── Args parsing (Object.keys loop — canonical convention) ──────────────────
// ⚠️ KNOWN ISSUE: the `args` global does NOT reliably inject in scriptPath mode.
// So we READ args IF present but FALL BACK to the CONSTs below.
// Edit the CONSTs for your run, OR pass via args={packs:[...], evidence_dir:"..."}.

let packs = null
let evidenceDir = null

if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'packs') packs = args[keys[i]]
    if (keys[i] === 'evidence_dir') evidenceDir = args[keys[i]]
  }
}

// ── Defaults — EDIT THESE FOR YOUR RUN (or pass via args) ───────────────────

// List of pack names to dogfood.
const DEFAULT_PACKS = [
  // EXAMPLE — replace with the packs you want to dogfood (or pass via args={packs:[...]}).
  'rag-retrieval', 'code-security',
]
// Evidence output dir — where each per-pack judgment (dogfood-<pack>.md) is persisted.
const DEFAULT_EVIDENCE_DIR = '.tad/evidence/pack-dogfood'

if (!packs) packs = DEFAULT_PACKS
if (!evidenceDir) evidenceDir = DEFAULT_EVIDENCE_DIR

// Fail loud on missing input rather than silently no-op (KNOWN ISSUE guard).
if (!Array.isArray(packs) || packs.length === 0) {
  log('ERROR: no packs. Edit DEFAULT_PACKS at top of file, or pass args={packs:["name",...]}.')
  return { error: 'no packs', evidence_dir: evidenceDir }
}

const EV = evidenceDir
log(`pack-dogfood: ${packs.length} packs — ${packs.join(', ')} → ${EV}`)

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
    wrong_claims: { type: 'array', items: { type: 'string' }, description: 'specific-but-WRONG claims in EITHER answer, with which answer + correct value (WebSearch-verified)' },
    rationale: { type: 'string' },
  },
}

// ── Pipeline (orchestration unchanged from the proven workflow) ─────────────

const results = await pipeline(
  packs,
  // Stage 1: extract the task from the pack's fixture (returns task text only)
  (pack) => agent(
    `Read the fixture under .claude/skills/${pack}/examples/ (the *.md file(s)). Extract ONLY the scenario/task prompt — the realistic question or request a user would pose in this pack's domain. Return it verbatim (or lightly cleaned) as "task". Do NOT include any expected answer, rubric, or the pack's own rules — only the user-facing task.`,
    { label: `task:${pack}`, phase: 'Task', schema: TASK_SCHEMA }
  ).then((t) => (t && t.task) ? t.task : `Give expert, concrete guidance for a realistic ${pack} task.`),
  // Stage 2: control + with-pack answers (blind order by index parity)
  (task, pack, idx) => parallel([
    () => agent(
      `You are a competent senior generalist. Answer this WITHOUT loading any specialized skill — use only your own knowledge. Do NOT read any file under .claude/skills/. Task:\n\n${task}\n\nGive your best concrete answer.`,
      { label: `control:${pack}`, phase: 'Answers' }
    ),
    () => agent(
      `Answer the task below by FIRST reading .claude/skills/${pack}/SKILL.md and its references/, then applying its concrete rules. Task:\n\n${task}`,
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
  // Stage 3: blind judge with WebSearch fact-check
  (b, pack) => agent(
    `You are a strict independent technical judge. Two answers respond to the SAME task. ONE used a specialized domain skill, the OTHER did not — you do NOT know which. Judge PURELY on merit. A confident WRONG specific is worse than an honest general statement — do not reward verbosity or unverified specificity.\n\n` +
    `TASK:\n${b.task}\n\n=== ANSWER 1 ===\n${b.answer1}\n\n=== ANSWER 2 ===\n${b.answer2}\n\n` +
    `Score each 1-5 on correctness, actionability, specificity, completeness. ⚠️ WebSearch-verify the key specific claims (numbers, tool/model names, versions, thresholds, APIs) in BOTH answers against current primary docs; list EVERY specific-but-wrong claim (which answer + correct value). A wrong specific tanks that answer's correctness. Then pick winner (1/2/tie) + margin + rationale (did the winner win on CORRECT specifics or just verbosity?).\n` +
    `Write full judgment to ${EV}/dogfood-${pack}.md`,
    { label: `judge:${pack}`, phase: 'Judge', schema: JUDGE_SCHEMA }
  ).then((j) => ({ pack, pack_is: b.pack_is, verdict: j || { winner: 'tie', wrong_claims: ['judge failed'] } }))
)

const clean = results.filter(Boolean)
const rows = clean.map((r) => {
  const v = r.verdict
  const packWon = v.winner === r.pack_is
  const s1 = v.answer1_score || {}, s2 = v.answer2_score || {}
  const packScore = r.pack_is === '1' ? s1 : s2
  return {
    pack: r.pack,
    result: v.winner === 'tie' ? 'TIE' : (packWon ? 'WITH-PACK' : 'CONTROL'),
    margin: v.margin || '',
    pack_score: packScore,
    wrong_claims: v.wrong_claims || [],
  }
})
return {
  evidence_dir: EV,
  total: rows.length,
  pack_wins: rows.filter((r) => r.result === 'WITH-PACK').length,
  ties: rows.filter((r) => r.result === 'TIE').length,
  control_wins: rows.filter((r) => r.result === 'CONTROL').length,
  packs_with_wrong_claims: rows.filter((r) => r.wrong_claims.length > 0).map((r) => r.pack),
  rows,
  note: 'WITH-PACK wins on correct specifics = real quality. CONTROL/TIE or wrong_claims = a real gap to fix. Conductor must read dogfood-*.md before judging.',
}
