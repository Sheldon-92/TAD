export const meta = {
  name: 'pack-quality-batch-upgrade',
  description: 'Upgrade one batch of capability packs to the dual-layer quality bar: per-pack domain research → SKILL.md upgrade (Layer A structure + Layer B research-grounded depth) → behavioral discriminative eval → Workflow adversarial review (3 lenses, fact/API WebSearch-verified, findings persisted to disk). No Codex. Parameterized via args={batch, packs}.',
  phases: [
    { title: 'Plan' },
    { title: 'Upgrade' },
    { title: 'Eval' },
    { title: 'Review' },
  ],
}

const QB = '.tad/evidence/pack-quality/QUALITY-BAR.md'
const BA = '.tad/evidence/pack-quality/BASELINE-AUDIT.md'
const EV = '.tad/evidence/yolo/capability-pack-quality-leveling'

// ⚠️ args global not injected in scriptPath mode — hardcode current batch here, edit between batches.
const BATCH = 3
const PHASE = BATCH + 1            // Batch 1 = Phase 2, etc.
const PACKS = [
  { name: 'ai-agent-architecture', needs_fixture: false },
  { name: 'ai-evaluation', needs_fixture: false },
  { name: 'ai-guardrails', needs_fixture: false },
  { name: 'ai-voice-production', needs_fixture: false },
  { name: 'ai-prompt-engineering', needs_fixture: false },
]

if (!PACKS.length) {
  return { error: 'no packs', batch: BATCH }
}
log(`Batch ${BATCH} (Phase ${PHASE}): ${PACKS.length} packs — ${PACKS.map(p => p.name).join(', ')}`)

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

const results = await pipeline(
  PACKS,
  (p) => agent(
    `You are upgrading the capability pack "${p.name}" toward a dual-layer quality bar.\n\n` +
    `READ FIRST:\n- ${QB} (Layer A meta-design structure /10, Layer B domain depth 0/2/5 with specN)\n- ${BA} (find the "${p.name}" row: its Layer A / Layer B scores + listed gaps)\n- .claude/skills/${p.name}/SKILL.md (current)\n\n` +
    `THEN do GitHub-First + WebSearch domain research for THIS pack's domain to find the latest tools/repos and SPECIFIC research-grounded numbers/thresholds/APIs. Every Layer B addition MUST carry a source_url + retrieval date (today is 2026-06-13). Do NOT invent numbers.\n\n` +
    `Produce a structured upgrade plan. ${p.needs_fixture ? 'THIS PACK HAS NO FIXTURE — fixture_action MUST be author-new.' : 'Pack has a fixture — refresh-existing or none.'}`,
    { label: `plan:${p.name}`, phase: 'Plan', schema: PLAN_SCHEMA }
  ),
  (plan, p) => agent(
    `Apply this upgrade plan to capability pack "${p.name}". Edit ONLY files under .claude/skills/${p.name}/ (disjoint from other packs — safe concurrent).\n\n` +
    `PLAN:\n${JSON.stringify(plan, null, 2)}\n\n` +
    `REQUIREMENTS (read ${QB} for exact criteria):\n` +
    `- Layer A: YAML frontmatter (name+description preserved); body < 500 lines via progressive disclosure to references/*.md; routing/steps; CONSUMES/PRODUCES; anti-skip table; navigation index; fixture present; validation scripts (executable, no Windows paths).\n` +
    `- Layer B: every domain rule carries research-grounded specifics (numbers/thresholds/exact APIs) with sources — NOT generic restatable rules.\n` +
    (`- Refresh/keep the existing examples/ fixture; ensure its discriminative_pattern stays pack-specific.\n`) +
    `Make real, substantive edits — production pack synced to 14 projects.`,
    { label: `upgrade:${p.name}`, phase: 'Upgrade', schema: UPGRADE_SCHEMA }
  ),
  (up, p) => agent(
    `Run a behavioral discriminative eval for the upgraded capability pack "${p.name}".\n\n` +
    `1. Read .claude/skills/${p.name}/examples/ fixture for its discriminative_pattern + min_discriminative.\n` +
    `2. Take the fixture's scenario. Produce a WITH-PACK answer (apply SKILL.md rules) and a CONTROL answer (generalist, NO pack).\n` +
    `3. Apply the discriminative_pattern (grep -oE PATTERN | sort -u | wc -l) to both.\n` +
    `4. discriminative_pass = true ONLY IF with-pack disc >= min_discriminative AND control disc < min_discriminative.\n` +
    `Write output to ${EV}/phase${PHASE}-eval-${p.name}.md`,
    { label: `eval:${p.name}`, phase: 'Eval', schema: EVAL_SCHEMA }
  ),
  (ev, p) => parallel(
    LENSES.map((lens) => () =>
      agent(
        `Adversarially review the upgraded capability pack "${p.name}" through the "${lens.key}" lens.\n\n${lens.instr}\n\n` +
        `READ: .claude/skills/${p.name}/SKILL.md (+ references/) and ${QB}.\n` +
        `Default to skepticism: meets_bar=true only if it genuinely clears the bar on your lens.\n` +
        `PERSIST your verdict + findings to ${EV}/phase${PHASE}-review-${p.name}-${lens.key}.md (markdown: lens, meets_bar, findings, fact_checks).`,
        { label: `review:${p.name}:${lens.key}`, phase: 'Review', schema: VERDICT_SCHEMA }
      ).then((v) => v || { lens: lens.key, meets_bar: false, findings: ['agent died'] })
    )
  ).then(async (verdicts) => {
    const refutes = verdicts.filter((v) => !v.meets_bar)
    let fixed = false
    // ⚠️ Batch 2 lesson: a SINGLE lens refute can be a real P0 (product-thinking fixture taught
    // wrong behavior; llm-observability had 2 fabricated APIs) — factual/correctness errors are
    // NOT a majority vote. So fix on ANY refute, but the fix agent VALIDATES each finding first
    // and skips false positives (agent-orchestration's lone refute was a false positive).
    if (refutes.length >= 1) {
      const allFindings = verdicts.flatMap((v) => (v.findings || []).map((f) => `[${v.lens}] ${f}`))
      await agent(
        `The upgraded capability pack "${p.name}" was refuted by ${refutes.length}/3 adversarial reviewers. For EACH finding below: first VALIDATE it (WebSearch for factual/API claims against current primary docs; check internal consistency against the pack's own rules for correctness claims). If a finding is a FALSE POSITIVE, skip it and document why. FIX the genuine ones by editing files under .claude/skills/${p.name}/ only:\n\n` +
        allFindings.map((f) => `- ${f}`).join('\n') +
        `\n\nAppend a "## FIX applied (validated)" note to ${EV}/phase${PHASE}-review-${p.name}-correctness.md: for each finding, state FIXED (what changed) or SKIPPED-FALSE-POSITIVE (why).`,
        { label: `fix:${p.name}`, phase: 'Review' }
      )
      fixed = true
    }
    return { pack: p.name, eval: ev, verdicts, refute_count: refutes.length, fixed }
  })
)

const clean = results.filter(Boolean)
return {
  batch: BATCH,
  phase: PHASE,
  packs_total: PACKS.length,
  packs_completed: clean.length,
  per_pack: clean.map((r) => ({ pack: r.pack, eval_pass: r.eval && r.eval.discriminative_pass, with_pack_disc: r.eval && r.eval.with_pack_disc, control_disc: r.eval && r.eval.control_disc, review_refutes: r.refute_count, fixed: r.fixed })),
  note: 'Conductor (Alex) must re-read evidence from disk + judge gate before next batch.',
}
