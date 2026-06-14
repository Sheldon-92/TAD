export const meta = {
  name: 'pack-upgrade',
  description: 'Upgrade a list of capability packs to a dual-layer quality bar via a per-pack 4-stage pipeline: Plan (domain research → upgrade plan) → Upgrade (apply Layer A structure + Layer B research-grounded depth) → Eval (behavioral discriminative eval) → Review (3-lens adversarial review, fact/API WebSearch-verified, findings persisted to disk). Any-refute → validate-then-fix (a single lens refute can be a real P0; the fix agent validates each finding first and skips false positives). Generalized from the proven batch-upgrade workflow; evidence output dir + label are parameterized so it is not tied to any one epic. No Codex. Input via args={packs, evidence_dir, label, quality_bar, baseline_audit} or the top-of-file CONSTs.',
  whenToUse: 'When raising one or more capability packs to a structure+depth quality bar with research-grounded specifics and adversarial review. Conductor re-reads persisted evidence + judges a gate before accepting.',
  phases: [
    { title: 'Plan', detail: 'Per-pack GitHub-First + WebSearch research → structured upgrade plan with sourced Layer B additions' },
    { title: 'Upgrade', detail: 'Apply the plan, editing only that pack dir (disjoint → safe concurrent)' },
    { title: 'Eval', detail: 'Behavioral discriminative eval: with-pack vs control on the fixture pattern' },
    { title: 'Review', detail: '3 adversarial lenses (correctness / fact-api / anti-slop), persisted; any refute → validate-then-fix' }
  ]
}

// ── Args parsing (Object.keys loop — canonical convention) ──────────────────
// ⚠️ KNOWN ISSUE: the `args` global does NOT reliably inject in scriptPath mode
// (observed: a batch workflow got 'no packs in args'). So we READ args IF present
// but FALL BACK to the CONSTs below. Edit the CONSTs for your run, OR pass via args.

let packs = null
let evidenceDir = null
let label = null
let qualityBar = null
let baselineAudit = null

if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'packs') packs = args[keys[i]]
    if (keys[i] === 'evidence_dir') evidenceDir = args[keys[i]]
    if (keys[i] === 'label') label = args[keys[i]]
    if (keys[i] === 'quality_bar') qualityBar = args[keys[i]]
    if (keys[i] === 'baseline_audit') baselineAudit = args[keys[i]]
  }
}

// ── Defaults — EDIT THESE FOR YOUR RUN (or pass via args) ───────────────────

// List of packs to upgrade. needs_fixture=true means the pack has NO fixture yet
// and the plan MUST author a new one (fixture_action=author-new).
const DEFAULT_PACKS = [
  { name: 'rag-retrieval', needs_fixture: false },
  { name: 'web-deployment', needs_fixture: false },
]
// Evidence output dir — where eval + review + fix findings are persisted.
const DEFAULT_EVIDENCE_DIR = '.tad/evidence/pack-upgrade'
// Run label — used as the filename prefix for persisted artifacts (e.g. eval-<label>-<pack>.md).
// Not tied to any epic; set it to your run/phase identifier.
const DEFAULT_LABEL = 'run1'
// The quality-bar spec the upgrade + review are graded against.
const DEFAULT_QUALITY_BAR = '.tad/evidence/pack-quality/QUALITY-BAR.md'
// The baseline audit listing each pack's current scores + gaps (optional; '' to skip).
const DEFAULT_BASELINE_AUDIT = '.tad/evidence/pack-quality/BASELINE-AUDIT.md'
// Today's date for retrieval-date stamping of sourced claims (passed via args.date in
// SKILL boundary mode; fallback string keeps the workflow runnable standalone).
const DEFAULT_TODAY = '(today)'

if (!packs) packs = DEFAULT_PACKS
if (!evidenceDir) evidenceDir = DEFAULT_EVIDENCE_DIR
if (!label) label = DEFAULT_LABEL
if (!qualityBar) qualityBar = DEFAULT_QUALITY_BAR
if (baselineAudit == null) baselineAudit = DEFAULT_BASELINE_AUDIT
let today = DEFAULT_TODAY
if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) if (keys[i] === 'date') today = args[keys[i]]
}

// Fail loud on missing input rather than silently no-op (KNOWN ISSUE guard).
if (!Array.isArray(packs) || packs.length === 0) {
  log('ERROR: no packs. Edit DEFAULT_PACKS at top of file, or pass args={packs:[{name,needs_fixture}]}.')
  return { error: 'no packs', evidence_dir: evidenceDir, label }
}
// Normalize string entries → {name, needs_fixture:false}
packs = packs.map((p) => (typeof p === 'string' ? { name: p, needs_fixture: false } : p))

const QB = qualityBar
const BA = baselineAudit
const EV = evidenceDir

log(`pack-upgrade [${label}]: ${packs.length} packs — ${packs.map((p) => p.name).join(', ')} → ${EV}`)

// ── Schemas (preserved verbatim from the proven workflow) ───────────────────

const PLAN_SCHEMA = {
  type: 'object',
  required: ['pack', 'layerA_gaps', 'layerB_additions', 'fixture_action', 'sources'],
  properties: {
    pack: { type: 'string' },
    layerA_gaps: { type: 'array', items: { type: 'string' } },
    layerB_additions: { type: 'array', items: { type: 'object', required: ['claim', 'source_url', 'retrieved'], properties: { claim: { type: 'string' }, source_url: { type: 'string' }, retrieved: { type: 'string' } } } },
    fixture_action: { type: 'string' },
    sources: { type: 'array', items: { type: 'string' } },
  },
}
const UPGRADE_SCHEMA = {
  type: 'object',
  required: ['pack', 'files_changed', 'body_lines_after', 'fixture_written', 'summary'],
  properties: {
    pack: { type: 'string' },
    files_changed: { type: 'array', items: { type: 'string' } },
    body_lines_before: { type: 'number' },
    body_lines_after: { type: 'number' },
    fixture_written: { type: 'boolean' },
    summary: { type: 'string' },
  },
}
const EVAL_SCHEMA = {
  type: 'object',
  required: ['pack', 'discriminative_pass', 'with_pack_disc', 'control_disc'],
  properties: {
    pack: { type: 'string' },
    discriminative_pass: { type: 'boolean' },
    with_pack_disc: { type: 'number' },
    control_disc: { type: 'number' },
    detail: { type: 'string' },
  },
}
const VERDICT_SCHEMA = {
  type: 'object',
  required: ['lens', 'meets_bar', 'findings'],
  properties: {
    lens: { type: 'string' },
    meets_bar: { type: 'boolean' },
    findings: { type: 'array', items: { type: 'string' } },
    fact_checks: { type: 'array', items: { type: 'string' } },
  },
}

const LENSES = [
  { key: 'correctness', instr: 'Does the upgraded SKILL.md actually meet the dual-layer bar? Is the guidance internally consistent and actionable? Try to REFUTE that it meets the bar.' },
  { key: 'fact-api', instr: 'Hunt for factual / API errors: wrong class names, deprecated or renamed APIs, wrong metric types, wrong constants/versions. You MUST WebSearch every version-sensitive claim against CURRENT primary documentation and report each check in fact_checks. This lens replaces cross-model review — be ruthless about unverified specifics.' },
  { key: 'anti-slop', instr: 'Are the Layer B "specifics" genuinely research-grounded (numbers/thresholds an LLM could NOT emit from training), or generic rules dressed up? Flag any vague/restatable rule masquerading as depth. Flag unsourced numbers.' },
]

// ── Pipeline (orchestration unchanged from the proven workflow) ─────────────

const results = await pipeline(
  packs,
  (p) => agent(
    `You are upgrading the capability pack "${p.name}" toward a dual-layer quality bar.\n\n` +
    `READ FIRST:\n- ${QB} (Layer A meta-design structure /10, Layer B domain depth 0/2/5 with specN)\n` +
    (BA ? `- ${BA} (find the "${p.name}" row: its Layer A / Layer B scores + listed gaps)\n` : '') +
    `- .claude/skills/${p.name}/SKILL.md (current)\n\n` +
    `THEN do GitHub-First + WebSearch domain research for THIS pack's domain to find the latest tools/repos and SPECIFIC research-grounded numbers/thresholds/APIs. Every Layer B addition MUST carry a source_url + retrieval date (today is ${today}). Do NOT invent numbers.\n\n` +
    `Produce a structured upgrade plan. ${p.needs_fixture ? 'THIS PACK HAS NO FIXTURE — fixture_action MUST be author-new.' : 'Pack has a fixture — refresh-existing or none.'}`,
    { label: `plan:${p.name}`, phase: 'Plan', schema: PLAN_SCHEMA }
  ),
  (plan, p) => agent(
    `Apply this upgrade plan to capability pack "${p.name}". Edit ONLY files under .claude/skills/${p.name}/ (disjoint from other packs — safe concurrent).\n\n` +
    `PLAN:\n${JSON.stringify(plan, null, 2)}\n\n` +
    `REQUIREMENTS (read ${QB} for exact criteria):\n` +
    `- Layer A: YAML frontmatter (name+description preserved); body < 500 lines via progressive disclosure to references/*.md; routing/steps; CONSUMES/PRODUCES; anti-skip table; navigation index; fixture present; validation scripts (executable, no Windows paths).\n` +
    `- Layer B: every domain rule carries research-grounded specifics (numbers/thresholds/exact APIs) with sources — NOT generic restatable rules.\n` +
    `- Refresh/keep the existing examples/ fixture; ensure its discriminative_pattern stays pack-specific.\n` +
    `Make real, substantive edits — production pack synced to downstream projects.`,
    { label: `upgrade:${p.name}`, phase: 'Upgrade', schema: UPGRADE_SCHEMA }
  ),
  (up, p) => agent(
    `Run a behavioral discriminative eval for the upgraded capability pack "${p.name}".\n\n` +
    `1. Read .claude/skills/${p.name}/examples/ fixture for its discriminative_pattern + min_discriminative.\n` +
    `2. Take the fixture's scenario. Produce a WITH-PACK answer (apply SKILL.md rules) and a CONTROL answer (generalist, NO pack).\n` +
    `3. Apply the discriminative_pattern (grep -oE PATTERN | sort -u | wc -l) to both.\n` +
    `4. discriminative_pass = true ONLY IF with-pack disc >= min_discriminative AND control disc < min_discriminative.\n` +
    `Write output to ${EV}/${label}-eval-${p.name}.md`,
    { label: `eval:${p.name}`, phase: 'Eval', schema: EVAL_SCHEMA }
  ),
  (ev, p) => parallel(
    LENSES.map((lens) => () =>
      agent(
        `Adversarially review the upgraded capability pack "${p.name}" through the "${lens.key}" lens.\n\n${lens.instr}\n\n` +
        `READ: .claude/skills/${p.name}/SKILL.md (+ references/) and ${QB}.\n` +
        `Default to skepticism: meets_bar=true only if it genuinely clears the bar on your lens.\n` +
        `PERSIST your verdict + findings to ${EV}/${label}-review-${p.name}-${lens.key}.md (markdown: lens, meets_bar, findings, fact_checks).`,
        { label: `review:${p.name}:${lens.key}`, phase: 'Review', schema: VERDICT_SCHEMA }
      ).then((v) => v || { lens: lens.key, meets_bar: false, findings: ['agent died'] })
    )
  ).then(async (verdicts) => {
    const refutes = verdicts.filter((v) => !v.meets_bar)
    let fixed = false
    // ⚠️ Lesson: a SINGLE lens refute can be a real P0 (a fixture taught wrong behavior;
    // a pack had fabricated APIs) — factual/correctness errors are NOT a majority vote.
    // So fix on ANY refute, but the fix agent VALIDATES each finding first and skips
    // false positives (a lone refute can also be a false positive).
    if (refutes.length >= 1) {
      const allFindings = verdicts.flatMap((v) => (v.findings || []).map((f) => `[${v.lens}] ${f}`))
      await agent(
        `The upgraded capability pack "${p.name}" was refuted by ${refutes.length}/${LENSES.length} adversarial reviewers. For EACH finding below: first VALIDATE it (WebSearch for factual/API claims against current primary docs; check internal consistency against the pack's own rules for correctness claims). If a finding is a FALSE POSITIVE, skip it and document why. FIX the genuine ones by editing files under .claude/skills/${p.name}/ only:\n\n` +
        allFindings.map((f) => `- ${f}`).join('\n') +
        `\n\nAppend a "## FIX applied (validated)" note to ${EV}/${label}-review-${p.name}-correctness.md: for each finding, state FIXED (what changed) or SKIPPED-FALSE-POSITIVE (why).`,
        { label: `fix:${p.name}`, phase: 'Review' }
      )
      fixed = true
    }
    return { pack: p.name, eval: ev, verdicts, refute_count: refutes.length, fixed }
  })
)

const clean = results.filter(Boolean)
return {
  label,
  evidence_dir: EV,
  packs_total: packs.length,
  packs_completed: clean.length,
  per_pack: clean.map((r) => ({ pack: r.pack, eval_pass: r.eval && r.eval.discriminative_pass, with_pack_disc: r.eval && r.eval.with_pack_disc, control_disc: r.eval && r.eval.control_disc, refutes: r.refute_count, fixed: r.fixed })),
  note: 'Conductor must re-read persisted evidence from disk + judge gate before accepting / proceeding.',
}
