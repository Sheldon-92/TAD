export const meta = {
  name: 'agent-pack-factory-fix',
  description: 'Apply codex Cat-A (confirmed factual/API errors) + Cat-C (unsourced numbers) fixes to 8 packs, then verify',
  phases: [
    { title: 'Fix', detail: 'one agent per pack: verify each codex finding, apply confirmed Cat-A + Cat-C fixes' },
    { title: 'Verify', detail: 'confirm fixes landed, skill==source byte-identical, no new breakage' },
  ],
}

const PACKS = [
  'rag-retrieval', 'agent-memory', 'llm-observability', 'ai-guardrails',
  'data-engineering', 'agent-orchestration', 'synthetic-data', 'knowledge-graph',
]

const ROOT = '/Users/sheldonzhao/01-on progress programs/TAD'
const SKILL = (s) => `${ROOT}/.claude/skills/${s}`
const SRC = (s) => `${ROOT}/.tad/capability-packs/${s}`
const CODEX = (s) => `${ROOT}/.tad/evidence/pack-eval/2026-06-01/codex-review/${s}-codex.md`
const SYNTH = `${ROOT}/.tad/evidence/pack-eval/2026-06-01/codex-review/SYNTHESIS.md`

const FIX_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['slug', 'catA_applied', 'catA_skipped', 'catC_applied', 'files_edited', 'byte_identical', 'summary'],
  properties: {
    slug: { type: 'string' },
    catA_applied: { type: 'integer', description: 'confirmed Cat-A fixes applied' },
    catA_skipped: { type: 'integer', description: 'codex Cat-A items SKIPPED because codex itself was wrong/outdated' },
    catC_applied: { type: 'integer', description: 'unsourced-number fixes applied' },
    files_edited: { type: 'array', items: { type: 'string' } },
    byte_identical: { type: 'boolean', description: 'SKILL.md == CAPABILITY.md and all references match after edits' },
    summary: { type: 'string', description: 'per-fix one-liners incl any skipped codex claim + why' },
  },
}

const VERIFY_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['slug', 'byte_identical', 'frontmatter_intact', 'spot_checks', 'verdict', 'issues'],
  properties: {
    slug: { type: 'string' },
    byte_identical: { type: 'boolean' },
    frontmatter_intact: { type: 'boolean' },
    spot_checks: { type: 'string', description: 'which specific codex Cat-A errors were confirmed gone (grep evidence)' },
    verdict: { type: 'string', enum: ['PASS', 'FAIL'] },
    issues: { type: 'array', items: { type: 'string' } },
  },
}

const fixPrompt = (s) => `Apply confirmed fixes to the "${s}" capability pack based on a Codex cross-model review.

READ:
1. ${CODEX(s)} — the Codex adversarial review (P0/P1 findings for THIS pack).
2. ${SYNTH} — the triage (Category A = confirmed code/factual errors; Category C = unsourced numbers; Category B = over-absolute claims, DO NOT touch in this pass).
3. ${SKILL(s)}/SKILL.md + all ${SKILL(s)}/references/*.md (+ examples/ if a fix touches the fixture).

TASK — apply ONLY Category A + Category C fixes:
- **Category A (confirmed factual/API/code errors)**: For EACH Cat-A item, FIRST confirm it is actually wrong using your own knowledge. If it is version-sensitive (API names, version numbers, deprecations) and you are NOT certain, run a WebSearch to check the CURRENT official API/docs before editing. Apply the fix ONLY if confirmed. If a Codex claim is ITSELF wrong or outdated, SKIP it and record why in summary (increment catA_skipped). Do NOT blindly apply — Codex has its own blind spots.
- **Category C (unsourced/suspicious specific numbers)**: re-label as benchmark/source-specific (state the exact source + scope) OR remove the number and keep the qualitative rule. Do not invent new numbers.
- **DO NOT touch Category B** (over-absolute claims) this pass.

CONSTRAINTS:
- Edit BOTH ${SKILL(s)}/ (SKILL.md + references) AND ${SRC(s)}/ (CAPABILITY.md + references) so they stay BYTE-IDENTICAL (SKILL.md must equal CAPABILITY.md; each reference file must match its source copy). The fixture lives only under ${SKILL(s)}/examples/.
- If you change a value the fixture's discriminative_pattern depends on, update the fixture too and keep its markers pack-unique (grep -oE form, never grep -c).
- Preserve frontmatter (name/description/keywords/type) and all "> Source:" provenance lines (update the source text if the number's framing changed).
- After editing, run \`diff -q\` (conceptually) between each SKILL/CAPABILITY pair and confirm byte-identical; set byte_identical accordingly.

Return the fix manifest. summary must list each applied fix as a one-liner + each skipped Codex claim with the reason.`

const verifyPrompt = (s) => `Verify the codex-driven fixes to the "${s}" pack are correct and complete, and introduced no breakage.

READ ${SKILL(s)}/ files + ${SRC(s)}/ files + ${CODEX(s)}.

CHECK:
1. Byte-identity: does ${SKILL(s)}/SKILL.md match ${SRC(s)}/CAPABILITY.md, and each reference match its source copy? (report any drift)
2. Frontmatter intact (name/description/keywords/type present, valid YAML)?
3. Spot-check the specific Cat-A errors Codex named for this pack: are the WRONG strings now GONE / corrected? (e.g. for ai-guardrails: \`result_type\` replaced by \`output_type\`, \`DeanonymizerEngine\`→\`DeanonymizeEngine\`, \`Rebuff(\`→\`RebuffSdk\`; for knowledge-graph: Leiden level semantics no longer reversed; etc.) Quote grep-style evidence.
4. No NEW breakage: edits didn't corrupt tables, code fences, or the Step 0 routing.

verdict = PASS if byte-identical + frontmatter intact + the named Cat-A errors are corrected; else FAIL with specifics in issues[].`

const results = await pipeline(
  PACKS,
  (s) => agent(fixPrompt(s), { label: `fix:${s}`, phase: 'Fix', schema: FIX_SCHEMA }),
  (_fix, s) => agent(verifyPrompt(s), { label: `verify:${s}`, phase: 'Verify', schema: VERIFY_SCHEMA })
    .then((v) => ({ slug: s, fix: _fix, verify: v })),
)

return results.filter(Boolean)
