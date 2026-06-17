// ⚠️ cost ≈ packs × (~25 agent calls each at research_max_rounds=2); keep packs × research_max_rounds modest (e.g. ≤ ~12 round-units) per run.
// ════════════════════════════════════════════════════════════════════════════
// PLAN IS NOW DEEP-RESEARCH-GROUNDED (encodes the research-before-upgrade rule).
//
// The Plan stage no longer does a single inline WebSearch. Instead it COMPOSES the
// research-engine workflow inline (PLAN → multi-round DEEPEN with dynamic follow-ups
// → SATURATION → adversarial VERIFY → cited SYNTHESIS) to produce a cited report +
// an honest UNVERIFIED/open-questions list for each pack's domain BEFORE writing the
// upgrade plan. The plan agent then reads that report: every Layer-B addition must
// cite a report source, and the report's UNVERIFIED items are carried forward as
// "flag, do NOT assert."
//
// This encodes a flow proven manually: research-engine deep research →
// research-grounded upgrade → clean dogfood win. (video-creation went from
// "slight win + 1 wrong LUFS claim" to "clear win + 0 errors" purely by doing the
// deep research first — the deep research caught the false "-14 LUFS unified
// standard" claim that an inline single search asserted.)
//
// NESTING: pack-upgrade stays a TOP-LEVEL workflow; calling research-engine from it
// is exactly ONE level (workflow() inside a child workflow throws). Cost is bounded
// by RESEARCH_MAX_ROUNDS (default 2) — a tunable const below.
// ════════════════════════════════════════════════════════════════════════════
export const meta = {
  name: 'pack-upgrade',
  description: 'Upgrade a list of capability packs to a dual-layer quality bar via a per-pack 4-stage pipeline: Plan (DEEP-research-grounded: compose research-engine inline → cited report + UNVERIFIED list → upgrade plan whose Layer-B additions each cite a report source) → Upgrade (apply Layer A structure + Layer B research-grounded depth; every load-bearing specific traces to a source OR is flagged estimate/convention/UNVERIFIED) → Eval (behavioral discriminative eval) → Review (3-lens adversarial review, fact/API WebSearch-verified, findings persisted to disk). Any-refute → validate-then-fix (a single lens refute can be a real P0; the fix agent validates each finding first and skips false positives). Generalized from the proven batch-upgrade workflow; evidence output dir + label are parameterized so it is not tied to any one epic. No Codex. Input via args={packs, evidence_dir, label, quality_bar, baseline_audit} or the top-of-file CONSTs.',
  whenToUse: 'When raising one or more capability packs to a structure+depth quality bar with research-grounded specifics and adversarial review. Conductor re-reads persisted evidence + judges a gate before accepting.',
  phases: [
    { title: 'Plan', detail: 'Per-pack DEEP research (compose research-engine inline) → cited report + UNVERIFIED list → structured upgrade plan with each Layer-B addition citing a report source' },
    { title: 'Upgrade', detail: 'Apply the plan, editing only that pack dir (disjoint → safe concurrent); every load-bearing specific traces to a research source or is flagged estimate/convention/UNVERIFIED' },
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
// Cost bound for the composed deep-research per pack. research-engine clamps internally
// to [1,8]; 2 rounds = PLAN + 2 DEEPEN rounds + VERIFY + SYNTHESIZE — enough to catch
// false "unified standard"-class claims without runaway cost. Tune up for deeper packs.
const RESEARCH_MAX_ROUNDS = 2

if (!packs) packs = DEFAULT_PACKS
if (!evidenceDir) evidenceDir = DEFAULT_EVIDENCE_DIR
if (!label) label = DEFAULT_LABEL
if (!qualityBar) qualityBar = DEFAULT_QUALITY_BAR
if (baselineAudit == null) baselineAudit = DEFAULT_BASELINE_AUDIT
let today = DEFAULT_TODAY
let researchMaxRounds = RESEARCH_MAX_ROUNDS
if (args) {
  const keys = Object.keys(args)
  for (let i = 0; i < keys.length; i++) {
    if (keys[i] === 'date') today = args[keys[i]]
    if (keys[i] === 'research_max_rounds') researchMaxRounds = Number(args[keys[i]]) || RESEARCH_MAX_ROUNDS
  }
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
  required: ['pack', 'files_changed', 'body_lines_after', 'fixture_written', 'summary', 'edit_list'],
  properties: {
    pack: { type: 'string' },
    files_changed: { type: 'array', items: { type: 'string' } },
    body_lines_before: { type: 'number' },
    body_lines_after: { type: 'number' },
    fixture_written: { type: 'boolean' },
    summary: { type: 'string' },
    edit_list: { type: 'array', items: { type: 'object', required: ['op', 'file', 'content'],
      properties: { op: { type: 'string' }, file: { type: 'string' }, rule_id: { type: 'string' },
      content: { type: 'string' }, rationale: { type: 'string' } } } },
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

const RESEARCH_DIR = `${EV}/research`

const results = await pipeline(
  packs,
  async (p) => {
    // ── Plan stage, step 1: DEEP research (compose research-engine inline) ──
    // PREFERRED implementation = composition (DRY): one level of nesting is legal
    // (pack-upgrade is top-level; research-engine is its child). The research-engine
    // child does its OWN fan-out via agent()/parallel() but NEVER calls workflow(),
    // so the one-level constraint holds. The question is domain-scoped from the pack
    // name + its BASELINE-AUDIT gaps, so the deep research chases exactly the depth
    // the upgrade needs (not generic domain trivia). max_rounds bounds cost.
    const researchQuestion =
      `For the "${p.name}" capability-pack domain (it advises AI coding agents), ` +
      `what are the EXACT, source-verified, version-sensitive specifics — numbers, thresholds, ` +
      `current tool/API names and versions, decision rules — that a senior practitioner applies ` +
      `but a generalist would get WRONG or assert as a false "unified standard"? ` +
      `Prioritize the gaps listed for the "${p.name}" row in ${BA || 'the baseline audit'} ` +
      `and the current SKILL at .claude/skills/${p.name}/SKILL.md. ` +
      `Surface per-source disagreements explicitly; flag anything you cannot source as UNVERIFIED.`

    const research = await workflow('research-engine', {
      question: researchQuestion,
      max_rounds: researchMaxRounds, // tunable cost bound (RESEARCH_MAX_ROUNDS / args.research_max_rounds)
      evidence_dir: RESEARCH_DIR,
    })

    // ── Research-failure detection: research-engine has error early-returns
    // ({error:'question required'}, {error:'plan failed'}) with NO report_path.
    // If research is null/undefined OR produced no report_path, it FAILED — do NOT
    // point the plan agent at a fake path (it would fail the read and may revert to
    // UNGROUNDED training-knowledge assertion, the exact blind-upgrade failure this
    // whole change exists to prevent). Degrade to maximally-conservative instead.
    const researchOk = !!(research && research.report_path)
    const reportPath = researchOk ? research.report_path : null
    const openQs = (researchOk && research.open_questions) || []
    const researchConfidence = (researchOk && research.confidence) || 'medium'
    if (researchOk) {
      log(`plan:${p.name} — deep research done: report=${reportPath}, sources=${(research && research.sources_count) || '?'}, confidence=${researchConfidence}, open_questions=${openQs.length}`)
    } else {
      log(`WARN plan:${p.name} — deep research FAILED (no report_path${research && research.error ? `; error="${research.error}"` : ''}). Forcing flag-everything conservative plan (no fake report path, no training-knowledge assertion).`)
    }

    // ── Plan stage, step 2: write the upgrade plan ──
    // P2 (cheap insurance): clamp open_questions before interpolating into the prompt.
    const openQsClamped = (openQs || []).slice(0, 20)
    // The prompt BRANCHES on researchOk. researchOk=true → report-grounded (cite the
    // report). researchOk=false → research FAILED → force flag-EVERYTHING conservative
    // plan (no fake report path, no training-knowledge assertion).
    const planPrompt = researchOk
      ? (
        `You are upgrading the capability pack "${p.name}" toward a dual-layer quality bar.\n\n` +
        `A DEEP-RESEARCH report for this pack's domain has ALREADY been produced (research-engine: ` +
        `cited, adversarially verified). Your upgrade plan MUST be grounded in it — do NOT do fresh ` +
        `unsourced research or assert numbers from training.\n\n` +
        `READ FIRST:\n- ${QB} (Layer A meta-design structure /10, Layer B domain depth 0/2/5 with specN)\n` +
        (BA ? `- ${BA} (find the "${p.name}" row: its Layer A / Layer B scores + listed gaps)\n` : '') +
        `- .claude/skills/${p.name}/SKILL.md (current)\n` +
        `- ${reportPath} (the DEEP-RESEARCH report — cited findings + a "## Sources" list. READ IT FULLY.)\n\n` +
        `RESEARCH RESULT META: confidence=${researchConfidence}; the report's OPEN/UNVERIFIED questions are:\n` +
        (openQsClamped.length ? openQsClamped.map((q) => `  - ${q}`).join('\n') : '  (none reported)') + '\n\n' +
        `RULES FOR THE PLAN (calibrated honesty > false precision):\n` +
        `1. EACH layerB_additions entry MUST cite a source_url drawn from the research report (its findings/Sources), ` +
        `with the retrieval date (today is ${today}). If a desired specific is NOT in the report, do NOT add it as a ` +
        `Layer-B assertion — either drop it or mark it as an estimate/practitioner-convention to be FLAGGED, not asserted.\n` +
        `2. CARRY FORWARD the report's UNVERIFIED / open-questions list above as "flag, do NOT assert" items: ` +
        `the upgrade must present these as uncertain (per-source-varies / no official value / practitioner heuristic), ` +
        `NEVER as a settled "unified standard". (This is exactly the false "-14 LUFS unified standard" failure class ` +
        `the deep research exists to catch.)\n` +
        `3. Do NOT invent numbers. A confident WRONG specific is worse than an honest "varies by X / unverified".\n\n` +
        `Produce a structured upgrade plan. ${p.needs_fixture ? 'THIS PACK HAS NO FIXTURE — fixture_action MUST be author-new.' : 'Pack has a fixture — refresh-existing or none.'}`
      )
      : (
        `You are upgrading the capability pack "${p.name}" toward a dual-layer quality bar.\n\n` +
        `⚠️ NO research report was produced (deep research failed). You MUST therefore flag EVERY ` +
        `non-trivial specific as UNVERIFIED and MUST NOT assert any number/version/threshold/cross-platform-standard ` +
        `from training knowledge — produce a conservative plan that only proposes changes you can hedge as ` +
        `estimate/convention. Do NOT invent grounding.\n\n` +
        `READ FIRST:\n- ${QB} (Layer A meta-design structure /10, Layer B domain depth 0/2/5 with specN)\n` +
        (BA ? `- ${BA} (find the "${p.name}" row: its Layer A / Layer B scores + listed gaps)\n` : '') +
        `- .claude/skills/${p.name}/SKILL.md (current)\n` +
        `(There is NO research report to read — do NOT attempt to read one; none exists.)\n\n` +
        `RULES FOR THE CONSERVATIVE PLAN (flag-everything mode — MANDATORY):\n` +
        `1. layerB_additions: every entry's source_url MUST be set to "UNVERIFIED" (no fabricated URL) and the claim ` +
        `worded as a hedged estimate/practitioner-convention, NEVER as a settled fact. If you cannot hedge a specific ` +
        `honestly, DROP it — do not add it.\n` +
        `2. Do NOT assert any number, version, threshold, constant, or cross-platform/cross-tool "unified standard" ` +
        `from training knowledge. Present any such specific as UNVERIFIED / "varies / needs verification".\n` +
        `3. Do NOT invent numbers or grounding. A confident WRONG specific is worse than an honest "unverified".\n\n` +
        `Produce a structured upgrade plan. ${p.needs_fixture ? 'THIS PACK HAS NO FIXTURE — fixture_action MUST be author-new.' : 'Pack has a fixture — refresh-existing or none.'}`
      )
    return agent(
      planPrompt,
      { label: `plan:${p.name}`, phase: 'Plan', schema: PLAN_SCHEMA }
    )
  },
  (plan, p) => agent(
    `Apply this upgrade plan to capability pack "${p.name}" using BOUNDED EDIT mode.\n\n` +
    `STEP 1: Read the CURRENT .claude/skills/${p.name}/SKILL.md and all references/*.md files.\n` +
    `STEP 2: For each change in the plan, generate a structured edit:\n` +
    `  - add_rule: add a new rule to the specified reference file\n` +
    `  - modify_rule: change an existing rule's content (cite the old rule_id)\n` +
    `  - delete_rule: remove an outdated/wrong rule\n` +
    `STEP 3: Apply each edit to the corresponding file. Edit ONLY files under .claude/skills/${p.name}/ (disjoint from other packs — safe concurrent). Do NOT rewrite files that have no edits.\n` +
    `STEP 4: Report the edit_list in your structured output.\n\n` +
    `⚠️ BOUNDED EDIT RULE: Do NOT rewrite rules that the plan does not mention. Preserve all ` +
    `unchanged rules VERBATIM. Read each file, locate the specific rules, make ONLY those changes.\n\n` +
    `EXCEPTION: If the plan's layerA_gaps include structural reorganization (restructure/` +
    `reorganize/split/merge), full rewrite is acceptable for the affected files. State this ` +
    `explicitly in your summary and set edit_list to [].\n\n` +
    `The plan was produced from a DEEP-RESEARCH report (research-engine). HONOR THE RESEARCH — this is an anti-blind-upgrade gate.\n\n` +
    `PLAN (each layerB_additions entry carries its source_url + retrieval date):\n${JSON.stringify(plan, null, 2)}\n\n` +
    `REQUIREMENTS (read ${QB} for exact criteria):\n` +
    `- Layer A: YAML frontmatter (name+description preserved); body < 500 lines via progressive disclosure to references/*.md; routing/steps; CONSUMES/PRODUCES; anti-skip table; navigation index; fixture present; validation scripts (executable, no Windows paths).\n` +
    `- Layer B: every domain rule carries research-grounded specifics (numbers/thresholds/exact APIs) with sources — NOT generic restatable rules.\n` +
    `- Refresh/keep the existing examples/ fixture; ensure its discriminative_pattern stays pack-specific.\n\n` +
    `RESEARCH-HONORING RULES (calibrated honesty > false precision — MANDATORY):\n` +
    `1. EVERY load-bearing specific (number, threshold, version, API name, constant) you write MUST either (a) trace to a source in the plan / research report, OR (b) be EXPLICITLY flagged inline as an estimate / practitioner-convention / UNVERIFIED. No silent assertions from training.\n` +
    `2. FORBIDDEN: asserting a cross-platform / cross-tool "unified standard"-type claim without per-source verification. If sources disagree or no official value exists, say so explicitly (e.g. "varies by platform: A=x, B=y; TikTok publishes none") — NEVER collapse it into one false number. This is the EXACT class of error (the false "-14 LUFS unified standard") the deep research caught and exists to prevent.\n` +
    `3. CARRY the plan's UNVERIFIED / open-questions items into the SKILL as flagged-uncertain guidance, not as settled fact.\n` +
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
