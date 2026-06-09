# Optimize Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

optimize_protocol:
  description: "Analyze execution traces + dream candidates → lifecycle health + v2 pattern analysis → project-level proposals"
  trigger: "User types *optimize"
  minimum_traces: 3
  loop_discover_option: |
    If Workflow tool available, *optimize can use loop-discover for open-ended proposal finding:
    Workflow({name: 'loop-discover', args: {
      finder_prompt: "Find improvement proposals from TAD execution traces in .tad/evidence/traces/. Look for recurring failures, slow patterns, skipped steps.",
      schema: {type: "object", properties: {proposal_id: {type: "string"}, category: {type: "string"}, description: {type: "string"}, evidence: {type: "string"}}, required: ["proposal_id", "category", "description"]},
      dedup_key: "proposal_id", dry_rounds_to_stop: 2,
      context_files: [".tad/evidence/traces/"]
    }})

  steps:
    step1_read_traces:
      name: "Read Traces"
      action: |
        1. Read all .tad/evidence/traces/*.jsonl files
        2. Parse each line as JSON, collect into array
        3. Count total trace entries (JSONL lines across all files)
        4. If total < 3:
           Output: "⚠️ Not enough trace data ({count} traces found, need at least 3).
           Continue using TAD to accumulate more execution history, then try again."
           → Return to standby (do not proceed to step2)
        5. If total >= 3: proceed with analysis
        6. Also read .tad/archive/traces/*.jsonl (rotation-safe)
        7. Separate v1 events (no schema_version field) from v2 events (schema_version="2.0")
        8. Output: "Found {N_v1} v1 events + {N_v2} v2 events across {F} trace files"
        9. If v2 count == 0: WARN "No v2 trace data found. V2 metrics will show N/A.
           Run a full TAD cycle (handoff → implement → gate) to generate v2 events."
           Proceed with v1-only analysis (existing 5 metrics).

    step2_aggregate:
      name: "Lifecycle Health Analysis"
      action: |
        From collected traces, compute lifecycle health metrics:

        1. Trace type breakdown:
           Count per type: handoff_created, evidence_created, task_completed, domain_pack_step
           Output: pie chart (text-based) showing distribution

        2. Zombie rate:
           Join key: the `file` field in each trace JSON line. Both handoff_created and
           task_completed use the full file path (e.g., "/path/.tad/active/handoffs/HANDOFF-20260504-foo.md").
           Normalization: extract slug from file path using regex:
             slug = basename(file).replace(/^(HANDOFF|COMPLETION)-\d{8}-/, '').replace(/\.md$/, '')
           This produces identical slugs regardless of HANDOFF vs COMPLETION prefix.

           - Extract unique slugs from handoff_created events (using normalized slug)
           - Check which slugs also appear in task_completed events (same normalization)
           - zombie_rate = (handoff_slugs - completed_slugs) / handoff_slugs
           - Fallback: if both trace types exist but zero slug matches found,
             WARN "slug format mismatch detected — check trace file field format"
             instead of reporting 100% zombie rate
           - Output: "Zombie rate: {rate}% ({N} handoffs never completed)"
           - If zombie_rate > 20%: flag as unhealthy

        3. Completion cycle time:
           - For each slug with both handoff_created AND task_completed:
             cycle_time = task_completed.ts - handoff_created.ts (first occurrence of each)
           - Compute: median, p90, max
           - Output: "Cycle time: median {N}h, p90 {N}h, max {N}h"

        4. Evidence production rate:
           - evidence_per_handoff = evidence_created_count / handoff_created_unique_slugs
           - Output: "Evidence rate: {N} evidence files per handoff"
           - If < 1.0: flag as low (healthy projects produce ≥2 evidence per handoff)

        5. Activity timeline:
           - Group traces by week (from ts field)
           - Output: bar chart (text-based) showing weekly activity
           - Identify inactive periods (>2 weeks gap)

        # --- V2 Metrics (require schema_version="2.0" events) ---
        # Skip this section entirely if v2 count == 0 (per step1 line 9)

        6. Gate pass rate (from gate_result events; outcome read from TOP-LEVEL .outcome field):
           - Group by gate number (extract from context field, e.g., "Gate 3:")
           - Per gate: pass_count / total_count
           - ⚠️ N=0 skip guard (FR6): SKIP any gate whose total_count == 0 — do NOT print it
             and do NOT flag it. The observational instrumentation MVP emits ONLY Gate 3, so
             Gate 2 / Gate 4 legitimately have zero events; printing "Gate 2 pass rate 0% ⚠️"
             would be a false alarm, not a real failure.
           - Output ONLY gates with total_count > 0, e.g.: "Gate pass rates: Gate 3: {N}%"
           - Append the note: "(gate pass rate currently reflects Gate 3 only — Gate 2/4 not yet instrumented)"
           - Flag: any gate with total_count > 0 AND < 80% → "⚠️ Gate {N} pass rate is {rate}% — review criteria"

        7. Reflexion efficiency (from reflexion_diagnosis events):
           - Total reflexion events
           - Validated: reflexion with confidence=high AND same slug has subsequent gate_result pass
             (requires double-parse: jq '.context | fromjson | .confidence')
           - Efficiency = validated / total
           - Minimum sample size: N≥10 before displaying percentage
             If N<10: output raw counts only: "Reflexion: {validated}/{total} validated (too few for %)"
           - If N≥10: output "Reflexion efficiency: {rate}% ({validated}/{total} hypotheses validated)"
           - Baseline (when N≥10): >50% is healthy, <30% suggests Blake's hypotheses are often wrong

        8. Decision pattern (from decision_point events):
           - Group by decision field (via double-parse of context)
           - Count per decision, sort descending
           - For each decision: count actor_tag=human_overridden / total
           - Output: top 5 decisions with override rate
           - Flag: override rate >30% → "⚠️ Agent's default for '{decision}' is overridden {rate}% of the time"

        9. Expert review density (from expert_review_finding events):
           - Group by slug
           - Emission contract (FR3/FR6): each event carries the priority in the TOP-LEVEL
             .outcome field (e.g., outcome="P0") and the finding count in .context
             (e.g., "2 P0 findings"). To total P0s per slug, select events with .outcome=="P0"
             and sum the leading integer parsed from .context (`grep -oE '^[0-9]+'`-style),
             NOT a per-event count of 1. (Earlier wording conflated the two fields — the
             priority lives at top-level .outcome; only the numeric count lives in .context.)
           - Output: "Expert P0 density: median {N}, max {N} per handoff"
           - Flag: any slug with >5 P0s → "⚠️ {slug} had {N} P0s — design quality concern"

        10. Output summary table to user

    step2b_project_knowledge:
      name: "Identify Project-Specific Learnings"
      action: |
        From trace data, identify project-specific patterns (NOT Domain Pack generic issues):
        1. Repeated search term modifications (user keeps changing search scope → default scope wrong for this project)
        2. Repeated tool replacements (user keeps switching tools → recommended tool doesn't fit this project)
        3. Project-specific failure patterns (only appear in this project, not cross-project)

        4. Check .tad/active/dream-candidates/CAND-*.md for files with:
           - status: pending
           - scope_tag: project
        5. If any found: include them in step4 display under "📚 Dream Candidates (project-scope)"
           These are SEPARATE from trace-derived proposals — they come from Phase 3 scanner
        6. User approves/rejects in same step4 flow as trace-derived proposals

        For each finding, generate a project-knowledge proposal:
        {
          "target": ".tad/project-knowledge/{category}.md",
          "type": "add_knowledge",
          "content": "### {Title} - {date}\n- **Context**: {what was happening}\n- **Discovery**: {what was learned}\n- **Action**: {what to do differently}",
          "evidence": "trace refs with specific line numbers"
        }
        These proposals join the lifecycle health proposals in step3 for YAML persistence and step4 for approval.
        In step4, display project-knowledge proposals under a separate "📚 项目知识更新" heading.

    step3_generate_proposals:
      name: "Generate Improvement Proposals + Write PROPOSAL YAML"
      action: |
        For each identified issue:
        1. Generate proposal_id: "PROPOSAL-{YYYYMMDD}-{NNN}" (NNN = zero-padded sequence)
        2. Run safety check BEFORE writing (see safety_constraints below)
        3. Write PROPOSAL YAML file to .tad/evidence/proposals/{proposal_id}.yaml:

        ```yaml
        proposal_id: "PROPOSAL-{date}-{NNN}"
        created: "{ISO 8601 timestamp}"
        status: "pending"  # pending | accepted | rejected | modified | deferred | blocked | stale
        scope: "project"  # project | framework

        target:
          file: ".tad/project-knowledge/{category}.md"  # or ".claude/skills/{skill}/SKILL.md"
          # was: ".tad/domains/{domain}.yaml" — Domain Packs are frozen
          capability: "{optional — only if targeting a specific SKILL capability}"
          section: "{quality_criteria | steps | anti_patterns | protocol_section}"

        change:
          type: "{tighten_criteria | add_step | fix_step | add_anti_pattern}"
          current: "{current value}"
          proposed: "{proposed value}"
          diff: |
            - "{current value}"
            + "{proposed value}"

        evidence:
          trace_count: {N}
          failure_pattern: "{description of pattern found}"
          trace_refs:
            - "{trace_file}:line{N}"
          confidence: {0.0-1.0}

        safety:
          checked: true
          safe: {true|false}
          blocked_reason: "{reason if unsafe, null if safe}"

        review:
          reviewed_at: null
          reviewer: null
          decision: null
          notes: null
        ```

        4. If safety check flags unsafe → set safe: false, blocked_reason, status: "blocked"
        5. Classify proposal scope (3-tier heuristic):
           If target.file matches '.claude/skills/*' or '.tad/hooks/*' → scope: framework
           If target.file is empty/generic: check slug — if slug contains "capability-pack" or SKILL reference → scope: framework
           Default: scope: project
        6. If scope == framework:
           Also copy proposal to .tad/evidence/proposals/framework/{proposal_id}.yaml
        7. If no issues found:
           Output: "✅ No improvement proposals — execution traces look healthy.
           Stats: {summary}"
           → Return to standby

      safety_constraints:
        description: |
          Hardcoded regex check on protected_patterns list below.
          Independence: the patterns are hardcoded strings, not LLM-generated judgment.
          The LLM executes the regex match, but CANNOT modify the pattern list or skip the check.
        protected_patterns:
          - "编造.*FAIL"
          - "fabricat.*FAIL"
          - "MANDATORY"
          - "VIOLATION"
          - "编造数据"
        check_logic: |
          For each proposal, BEFORE writing the YAML file:
          1. Read the current value from target file
          2. Check if current value matches any protected_pattern (regex)
          3. If current matches a protected pattern:
             a. Check if proposed value ALSO contains the same protected pattern
             b. If proposed REMOVES or WEAKENS the protected term → BLOCK
                (e.g., "FAIL" → "WARNING", or protected term deleted entirely)
             c. If proposed KEEPS the protected term intact → ALLOW
          4. If current does NOT match any protected pattern → ALLOW (no protection needed)
          Result: set safety.safe and safety.blocked_reason in proposal YAML
        recheck_on_modify: |
          When user chooses "修改后接受" (option 2), re-run safety check on user's modified text
          before queuing for step5. If modified text fails safety → BLOCK, inform user.

    step4_human_approval:
      name: "Human Approval (4-option)"
      action: |
        Group proposals by scope before display:
          🔧 Framework proposals: proposals where scope == "framework"
          📚 Project knowledge: proposals where scope == "project"
          🧠 Dream candidates: dream candidates from step2b (if any)
        Display each group under its heading, then process proposals one-by-one.

        For each proposal with safety.safe == true and status == "pending":
        Use AskUserQuestion:
        question: "基于 {trace_count} 次执行 trace，建议修改 {target.file}:"
        Display:
          目标: {target.capability} → {target.section}
          当前: {change.current}
          建议: {change.proposed}
          证据: {evidence.failure_pattern}
          置信度: {evidence.confidence}
        options:
          1. "接受 — 直接应用修改"
          2. "修改后接受 — 你调整措辞后应用"
          3. "拒绝 — 不修改"
          4. "稍后处理 — 保留提议，下次再看"

        On response:
          - "接受": update PROPOSAL status→"accepted", queue for step5
          - "修改后接受": ask user for modified text, update proposed in PROPOSAL,
            status→"modified", queue for step5
          - "拒绝": update PROPOSAL status→"rejected", review.decision→"rejected",
            review.reviewed_at→now, review.reviewer→"human"
          - "稍后处理": update PROPOSAL status→"deferred", skip (file stays for next *optimize run)

        For proposals with safety.safe == false:
          Display: "⚠️ BLOCKED: {proposal_id} — 触碰受保护条款: {blocked_reason}"
          Do NOT offer approval — auto-reject with status→"blocked"

    step5_apply:
      name: "Apply Accepted Changes"
      action: |
        Scope: Domain Pack YAML edits are configuration, not code — within Alex's scope.
        Authorization: Handoff HANDOFF-20260402-tad-v28-approval-workflow.md Section 3.3 explicitly assigns
        this Edit responsibility to Alex ("Alex 执行应用").
        For each accepted/modified proposal:
        1. Read the target file
           If file not found: WARN "Target {file} not found — skipping", update PROPOSAL status→"rejected", continue
        2. Locate the target section (capability → section)
        3. Staleness check: verify that change.current still matches the actual file content.
           If mismatch (file was modified by a prior proposal in this batch or externally):
           → WARN "Stale proposal: {proposal_id} — target content changed since proposal was generated"
           → Skip this proposal, update PROPOSAL status→"stale"
        4. Use Edit tool to replace current → proposed
        5. Update PROPOSAL YAML: status→"accepted", review.reviewed_at→now, review.reviewer→"human"
        6. Git commit with message: "optimize({target}): {change_type} — {brief description}"
        7. Output per proposal: "✅ Applied: {proposal_id} → {target.file}"

        After all proposals processed:
          Output: "Applied {accepted_count}/{total_count} improvements. {rejected_count} rejected, {deferred_count} deferred."
        If no proposals accepted:
          Output: "No changes applied."

