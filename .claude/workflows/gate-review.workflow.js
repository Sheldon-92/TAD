export const meta = {
  name: 'gate-review',
  description: 'Rule Adherence gate review: per-AC verifier agents + skeptic filter for false positives',
  whenToUse: 'When reviewing a handoff completion with 5+ ACs. Replaces single-context serial review with independent per-AC verification.',
  phases: [
    { title: 'Extract', detail: 'Parse ACs from handoff + completion report' },
    { title: 'Verify', detail: 'One verifier agent per AC in clean context' },
    { title: 'Skeptic', detail: 'Challenge flagged violations to filter false positives' },
    { title: 'Verdict', detail: 'Compile final gate report' }
  ]
}

const AC_ITEM_SCHEMA = {
  type: 'object',
  properties: {
    ac_id: { type: 'string' },
    requirement: { type: 'string' },
    verification_method: { type: 'string' },
    expected_evidence: { type: 'string' }
  },
  required: ['ac_id', 'requirement']
}

const EXTRACT_SCHEMA = {
  type: 'object',
  properties: {
    handoff_title: { type: 'string' },
    total_acs: { type: 'number' },
    acs: { type: 'array', items: AC_ITEM_SCHEMA },
    completion_report_path: { type: 'string' },
    key_files: { type: 'array', items: { type: 'string' } }
  },
  required: ['handoff_title', 'total_acs', 'acs']
}

const VERIFY_SCHEMA = {
  type: 'object',
  properties: {
    ac_id: { type: 'string' },
    verdict: { type: 'string', enum: ['PASS', 'FAIL', 'PARTIAL', 'CANNOT_VERIFY'] },
    evidence_found: { type: 'string' },
    issue_description: { type: 'string' },
    severity: { type: 'string', enum: ['P0', 'P1', 'P2', 'none'] },
    files_checked: { type: 'array', items: { type: 'string' } }
  },
  required: ['ac_id', 'verdict', 'evidence_found']
}

const SKEPTIC_SCHEMA = {
  type: 'object',
  properties: {
    ac_id: { type: 'string' },
    original_verdict: { type: 'string' },
    skeptic_verdict: { type: 'string', enum: ['confirmed', 'false_positive', 'downgrade'] },
    reason: { type: 'string' },
    revised_severity: { type: 'string', enum: ['P0', 'P1', 'P2', 'none'] }
  },
  required: ['ac_id', 'original_verdict', 'skeptic_verdict', 'reason']
}

const GATE_REPORT_SCHEMA = {
  type: 'object',
  properties: {
    handoff_title: { type: 'string' },
    total_acs: { type: 'number' },
    passed: { type: 'number' },
    failed: { type: 'number' },
    false_positives_filtered: { type: 'number' },
    overall_verdict: { type: 'string', enum: ['PASS', 'CONDITIONAL_PASS', 'FAIL'] },
    confirmed_issues: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          ac_id: { type: 'string' },
          severity: { type: 'string' },
          issue: { type: 'string' }
        }
      }
    },
    ac_results: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          ac_id: { type: 'string' },
          verifier_verdict: { type: 'string' },
          skeptic_verdict: { type: 'string' },
          final_verdict: { type: 'string' }
        }
      }
    }
  },
  required: ['handoff_title', 'total_acs', 'passed', 'failed', 'overall_verdict', 'confirmed_issues', 'ac_results']
}

// args: { handoff: string, completion?: string } OR just a string (handoff path)
// Workaround: workflow runtime may not support dot-access on args objects
let handoffPath = null
let completionPath = null
if (args) {
  if (typeof args === 'string') {
    handoffPath = args
  } else {
    const keys = Object.keys(args)
    for (let i = 0; i < keys.length; i++) {
      if (keys[i] === 'handoff') handoffPath = args[keys[i]]
      if (keys[i] === 'completion') completionPath = args[keys[i]]
    }
  }
}

if (!handoffPath) {
  log('ERROR: args required. Usage: Workflow({..., args: {handoff: "path/to/HANDOFF.md"}}) or args: "path/to/HANDOFF.md"')
  return { error: 'handoff path required' }
}

// Phase 1: Extract ACs from handoff
phase('Extract')
log('Extracting ACs from ' + handoffPath)

const extracted = await agent(
  'Read the handoff at ' + handoffPath + ' and extract ALL acceptance criteria.\n\n' +
  'Look for:\n' +
  '- Section 9 / "Acceptance Criteria" — the main AC table\n' +
  '- Section 9.1 / "Spec Compliance Checklist" — verification commands\n' +
  '- Any numbered AC items (AC1, AC2, ... or AC-XXX-a, AC-XXX-b, ...)\n\n' +
  'For each AC, extract:\n' +
  '- ac_id: the AC number/label\n' +
  '- requirement: what must be true\n' +
  '- verification_method: the command or check (if specified)\n' +
  '- expected_evidence: what output is expected\n\n' +
  'Also find the completion report. If not provided, look for COMPLETION-*.md with matching slug ' +
  'in .tad/active/handoffs/ or .tad/archive/handoffs/.\n' +
  (completionPath ? 'Completion report at: ' + completionPath : 'Auto-detect completion report from slug.') +
  '\n\nAlso list the key files mentioned in the handoff Files to Modify section.',
  { label: 'extract-acs', phase: 'Extract', schema: EXTRACT_SCHEMA }
)

if (!extracted || !extracted.acs || extracted.acs.length === 0) {
  log('No ACs found in handoff. Cannot proceed.')
  return { error: 'No ACs found', handoff: handoffPath }
}

log('Found ' + extracted.total_acs + ' ACs. Completion: ' + (extracted.completion_report_path || 'not found'))

// Phase 2: Per-AC verification (fan-out)
phase('Verify')
log('Phase 2: ' + extracted.acs.length + ' independent verifiers')

const verifications = await pipeline(
  extracted.acs,
  function(ac) {
    return agent(
      'You are verifying a SINGLE acceptance criterion. You have a CLEAN context — ' +
      'you know NOTHING about other ACs or the overall handoff.\n\n' +
      'AC TO VERIFY:\n' +
      '  ID: ' + ac.ac_id + '\n' +
      '  Requirement: ' + ac.requirement + '\n' +
      '  Verification method: ' + (ac.verification_method || 'not specified — use your judgment') + '\n' +
      '  Expected evidence: ' + (ac.expected_evidence || 'not specified') + '\n\n' +
      'WHAT TO DO:\n' +
      '1. If a verification command is specified, RUN IT and check the output\n' +
      '2. If files are referenced, READ them and check the requirement\n' +
      '3. If a completion report exists at ' + (extracted.completion_report_path || 'unknown') +
      ', check what Blake reported for this AC\n\n' +
      'Key files from handoff: ' + (extracted.key_files || []).join(', ') + '\n\n' +
      'BE STRICT. If the evidence does not CLEARLY satisfy the requirement, mark FAIL.\n' +
      'If you cannot verify (file missing, command errors), mark CANNOT_VERIFY.\n' +
      'Do NOT assume PASS — verify.',
      { label: ac.ac_id, phase: 'Verify', schema: VERIFY_SCHEMA, model: 'sonnet' }
    )
  }
)

const validVerifications = verifications.filter(Boolean)
const flagged = validVerifications.filter(function(v) { return v.verdict !== 'PASS' })
log('Verification complete: ' + (validVerifications.length - flagged.length) + ' PASS, ' + flagged.length + ' flagged')

// Phase 3: Skeptic reviews flagged items
phase('Skeptic')

if (flagged.length === 0) {
  log('No flagged items — skipping skeptic phase')
} else {
  log('Phase 3: Skeptic reviewing ' + flagged.length + ' flagged items')
}

const skepticResults = flagged.length > 0
  ? await parallel(flagged.map(function(flag) {
      return function() {
        return agent(
          'You are a SKEPTIC. A verifier flagged an AC as ' + flag.verdict + '.\n' +
          'Your job is to CHALLENGE the flag — try to prove it is a FALSE POSITIVE.\n\n' +
          'FLAGGED AC:\n' +
          '  ID: ' + flag.ac_id + '\n' +
          '  Verifier verdict: ' + flag.verdict + '\n' +
          '  Verifier issue: ' + (flag.issue_description || 'none stated') + '\n' +
          '  Evidence found: ' + flag.evidence_found + '\n' +
          '  Files checked: ' + (flag.files_checked || []).join(', ') + '\n' +
          '  Severity: ' + (flag.severity || 'unrated') + '\n\n' +
          'YOUR TASK:\n' +
          '1. Re-read the same files the verifier checked\n' +
          '2. Try to find evidence the verifier MISSED that would make this a PASS\n' +
          '3. Consider: is the verifier being too strict? Is the requirement ambiguous?\n' +
          '4. Consider: is this a real problem or a technicality?\n\n' +
          'VERDICT:\n' +
          '- confirmed: the flag is real, this AC genuinely fails\n' +
          '- false_positive: the verifier was wrong, this AC actually passes\n' +
          '- downgrade: the issue exists but severity should be lower (P0→P1 or P1→P2)\n\n' +
          'Default to CONFIRMED if uncertain. False negatives are worse than false positives.',
          { label: 'skeptic-' + flag.ac_id, phase: 'Skeptic', schema: SKEPTIC_SCHEMA, model: 'sonnet' }
        )
      }
    }))
  : []

const validSkeptic = (skepticResults || []).filter(Boolean)
const falsePositives = validSkeptic.filter(function(s) { return s.skeptic_verdict === 'false_positive' })
log('Skeptic complete: ' + falsePositives.length + ' false positives filtered out of ' + flagged.length + ' flags')

// Phase 4: Compile gate report
phase('Verdict')
log('Compiling final gate report')

const result = await agent(
  'Compile a final Gate review report from the verification results.\n\n' +
  'HANDOFF: ' + handoffPath + '\n' +
  'TITLE: ' + extracted.handoff_title + '\n' +
  'TOTAL ACs: ' + extracted.total_acs + '\n\n' +
  'ALL VERIFICATION RESULTS:\n' + JSON.stringify(validVerifications, null, 2) + '\n\n' +
  'SKEPTIC RESULTS (for flagged items only):\n' + JSON.stringify(validSkeptic, null, 2) + '\n\n' +
  'RULES:\n' +
  '- If skeptic says false_positive → treat as PASS\n' +
  '- If skeptic says downgrade → use revised severity\n' +
  '- If skeptic says confirmed → keep original verdict\n' +
  '- If no skeptic review (item was PASS) → keep PASS\n' +
  '- Overall: PASS if 0 confirmed P0. CONDITIONAL_PASS if P1 only. FAIL if any confirmed P0.\n\n' +
  'Produce the final ac_results table showing: verifier verdict, skeptic verdict (if any), final verdict.',
  { label: 'verdict', phase: 'Verdict', schema: GATE_REPORT_SCHEMA }
)

return result
