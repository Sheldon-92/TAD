export const meta = {
  name: 'agent-pack-factory-build',
  description: 'Build 8 agent-adjacent capability packs from NotebookLM research findings, then adversarially review + fix each',
  phases: [
    { title: 'Build', detail: 'one agent per pack writes full pack grounded in findings.md' },
    { title: 'Review', detail: 'two adversarial reviewers per pack (code-reviewer + domain-expert)' },
    { title: 'Fix', detail: 'apply P0 fixes per pack' },
  ],
}

// 8 agent-adjacent packs. Each build agent reads its findings.md (NotebookLM-researched,
// source-cited) and writes the pack to BOTH the installed-skill dir and the source dir.
const PACKS = [
  { slug: 'rag-retrieval',       title: 'RAG & Retrieval Engineering' },
  { slug: 'agent-memory',        title: 'Agent Memory & Context Engineering' },
  { slug: 'llm-observability',   title: 'LLM Observability & LLMOps' },
  { slug: 'ai-guardrails',       title: 'AI Guardrails & LLM I/O Security' },
  { slug: 'data-engineering',    title: 'Data Engineering for AI' },
  { slug: 'agent-orchestration', title: 'Agent Orchestration Frameworks' },
  { slug: 'synthetic-data',      title: 'Synthetic Data & Fine-Tune Dataset Curation' },
  { slug: 'knowledge-graph',     title: 'Knowledge Graphs & GraphRAG' },
]

const ROOT = '/Users/sheldonzhao/01-on progress programs/TAD'
const FINDINGS = (slug) => `${ROOT}/.tad/evidence/research/agent-pack-factory/${slug}/findings.md`
const SKILL_DIR = (slug) => `${ROOT}/.claude/skills/${slug}`
const SRC_DIR = (slug) => `${ROOT}/.tad/capability-packs/${slug}`
const EXEMPLAR = `${ROOT}/.tad/capability-packs/ai-evaluation`
const EXEMPLAR_SKILL = `${ROOT}/.claude/skills/ai-evaluation`
const FIXTURE_TMPL = `${ROOT}/.tad/templates/pack-example-fixture.md`

const BUILD_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['slug', 'files_written', 'reference_files', 'provenance_ok', 'notes'],
  properties: {
    slug: { type: 'string' },
    files_written: { type: 'array', items: { type: 'string' } },
    reference_files: { type: 'integer' },
    provenance_ok: { type: 'boolean', description: 'true if every number/tool in the pack traces to a Source in findings.md' },
    notes: { type: 'string' },
  },
}

const REVIEW_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['verdict', 'p0', 'p1'],
  properties: {
    verdict: { type: 'string', enum: ['PASS', 'CONDITIONAL', 'FAIL'] },
    p0: { type: 'array', items: { type: 'string' } },
    p1: { type: 'array', items: { type: 'string' } },
  },
}

const FIX_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['slug', 'p0_fixed', 'remaining_p0', 'summary'],
  properties: {
    slug: { type: 'string' },
    p0_fixed: { type: 'integer' },
    remaining_p0: { type: 'integer' },
    summary: { type: 'string' },
  },
}

const buildPrompt = (p) => `You are a capability-pack builder. Build the "${p.slug}" capability pack (${p.title}) for the TAD framework.

GROUND TRUTH (read first, in order):
1. ${FINDINGS(p.slug)} — your NotebookLM-researched, source-cited findings. This is your ONLY source of tools, numbers, and named rules.
2. ${EXEMPLAR}/CAPABILITY.md — the exact structure to mirror (frontmatter, CONSUMES/PRODUCES, "What This Pack Does", Cross-Cutting Rule, Step 0 Context Detection table, Step 1 Apply Rules, Quick Rule Index).
3. ${EXEMPLAR}/references/adversarial-rules.md — the reference-file format (Quick Rule Index table + Rules with "> Source:" citations + specific CLI commands/numbers).
4. ${EXEMPLAR}/install.sh — copy this verbatim, then change only the pack name "ai-evaluation"→"${p.slug}" and the COPY_PAIRS reference-file list to match the files you create.
5. ${EXEMPLAR_SKILL}/examples/llm-judge-ab-eval.md — the behavioral fixture format (discriminative_pattern of pack-SPECIFIC markers + Anti-Slop ✅/❌ lists).
6. ${FIXTURE_TMPL} — the fixture template.

WRITE THESE FILES (to BOTH locations — source dir AND installed-skill dir):

A. Source pack dir ${SRC_DIR(p.slug)}/ :
   - CAPABILITY.md  (frontmatter: name, description, keywords[] [CJK + English, ~15], type: reference-based; then CONSUMES/PRODUCES lines at col-0; then the full skill body)
   - references/<capability>.md  × 4-6 (one per capability in findings; each: Quick Rule Index + Rules with "> Source:" citations)
   - install.sh  (adapted copy of exemplar)
   - LICENSE  (copy ${EXEMPLAR}/LICENSE verbatim — Apache 2.0)
B. Installed skill dir ${SKILL_DIR(p.slug)}/ :
   - SKILL.md  (BYTE-IDENTICAL to your CAPABILITY.md)
   - references/<same files>
   - LICENSE
   - examples/${p.slug}-fixture.md  (the behavioral fixture)

HARD QUALITY RULES (TAD anti-slop, non-negotiable — these are why the pack has value over a no-pack LLM):
- PROVENANCE: every tool name, version, number, threshold, exit code MUST appear in findings.md with a Source. If findings.md lacks a number, DO NOT invent it — write "data not available from research" or omit. NEVER interpolate a per-tool number from a method-level range. (architecture.md "Per-Tool Numeric Thresholds Require Research Provenance")
- ANTI-SLOP: rules must be SPECIFIC named-rules / numbers / CLI commands / exit codes a no-pack frontier LLM would NOT produce from training data — NOT generic vocabulary. (code-quality.md "Anti-Slop = Threshold/Named-Rule, Not Vocabulary")
- FIXTURE DISCRIMINATION: the fixture's discriminative_pattern MUST contain ONLY pack-specific markers (named rules / specific numbers from findings), NEVER generic domain nouns or words from the input scenario. Include a "## Anti-Slop Check" with ✅ pack-specific and ❌ generic-excluded lists. The fixture must plausibly FAIL a no-pack control. min_discriminative ≥ 2 (≥3 if the pack is rich). Verification Command MUST use \`grep -oE 'a|b|c' file | sort -u | wc -l\` — NEVER \`grep -c\`.
- FRONTMATTER: name + description + keywords + type are MANDATORY (Capability Pack: YAML Frontmatter is Load-Bearing — without it the skill never activates).
- One Cross-Cutting Rule surfaced at the top (like Judge≠Optimizer) — the single most important rule of the domain, pulled from findings.

Return the structured manifest. Do NOT review your own work — a separate reviewer handles that.`

const reviewPrompt = (p, lens) => `Adversarially review the just-built "${p.slug}" capability pack. Be a skeptic — hunt for failures, do NOT rubber-stamp.

READ:
- ${SKILL_DIR(p.slug)}/SKILL.md + all ${SKILL_DIR(p.slug)}/references/*.md + ${SKILL_DIR(p.slug)}/examples/*.md
- ${FINDINGS(p.slug)} (the source-of-truth research findings)

LENS: ${lens}

CHECK (P0 = must-fix before this pack ships):
${lens === 'provenance-and-antislop' ? `- FABRICATED NUMBERS (P0): is there ANY tool / version / number / threshold in the pack that is NOT present in findings.md with a Source? List each.
- ANTI-SLOP FAILURE (P0): are the reference rules generic restatements a no-pack LLM would emit (e.g. "use a good embedding model", "add tests")? Quote the worst offenders.
- FIXTURE THEATER (P0): would the fixture's discriminative_pattern markers be emitted by a no-pack control? If yes, the gate is theater. Check the Anti-Slop ❌ list is real. Confirm Verification Command uses grep -oE not grep -c.
- FRONTMATTER (P0): name/description/keywords/type all present and valid?` : `- TECHNICAL CORRECTNESS (P0): are any rules wrong or outdated vs the domain? Any CLI command that would error? Any tool described incorrectly vs findings?
- CAPABILITY COVERAGE (P1): does Step 0 Context Detection cover the capabilities in findings? Gaps?
- CONSUMES/PRODUCES (P1): is the interface contract sensible + at col-0 (registry-readable)?
- install.sh (P0): does the COPY_PAIRS list match the actual reference files? Pack name replaced everywhere?`}

Return verdict (PASS = 0 P0; CONDITIONAL = P1 only; FAIL = ≥1 P0) + the p0[] and p1[] lists with specifics.`

const fixPrompt = (p, reviews) => `Fix P0 issues in the "${p.slug}" capability pack.

Two adversarial reviews:
=== Reviewer A (provenance/anti-slop) ===
verdict: ${reviews[0]?.verdict}
P0: ${JSON.stringify(reviews[0]?.p0 || [])}
=== Reviewer B (technical/structure) ===
verdict: ${reviews[1]?.verdict}
P0: ${JSON.stringify(reviews[1]?.p0 || [])}

If there are NO P0 across both reviewers → return p0_fixed=0, remaining_p0=0, summary="no P0 — clean".
Otherwise: read ${SKILL_DIR(p.slug)}/ files + ${FINDINGS(p.slug)}, fix EVERY P0 (edit files in BOTH ${SKILL_DIR(p.slug)}/ and ${SRC_DIR(p.slug)}/ to keep them identical). For fabricated-number P0s: remove or re-ground the number in findings.md. Re-verify the fixture's discriminative_pattern. Return the fix manifest.`

// ── Execute: pipeline per pack (build → review → fix), all 8 in parallel ──
const results = await pipeline(
  PACKS,
  (p) => agent(buildPrompt(p), { label: `build:${p.slug}`, phase: 'Build', schema: BUILD_SCHEMA }),
  (_build, p) => parallel([
    () => agent(reviewPrompt(p, 'provenance-and-antislop'), { label: `review-A:${p.slug}`, phase: 'Review', schema: REVIEW_SCHEMA }),
    () => agent(reviewPrompt(p, 'technical-and-structure'), { label: `review-B:${p.slug}`, phase: 'Review', schema: REVIEW_SCHEMA }),
  ]),
  (reviews, p) => agent(fixPrompt(p, reviews.filter(Boolean)), { label: `fix:${p.slug}`, phase: 'Fix', schema: FIX_SCHEMA })
    .then((fix) => ({ slug: p.slug, reviews: reviews.filter(Boolean), fix })),
)

return results.filter(Boolean)
