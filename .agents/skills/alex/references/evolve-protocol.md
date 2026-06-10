# Evolve Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

evolve_protocol:
  description: "Cross-project v2 trace aggregation + framework dream candidates → framework-level proposals → *sync"
  trigger: "User types *evolve"
  minimum_traces: 10
  prerequisite: ".tad/sync-registry.yaml must exist (TAD main project only)"

  distinction: |
    *optimize = single project, lifecycle health + v2 pattern analysis → project-level proposals
    *evolve = cross-project, v2 event aggregation + framework dream candidates → framework-level proposals → *sync

  steps:
    step1_collect:
      name: "Collect Cross-Project Traces"
      action: |
        1. Check .tad/sync-registry.yaml exists
           If not: Output "⚠️ *evolve can only run in the TAD main project (sync-registry.yaml not found)." → return to standby
        2. Read .tad/sync-registry.yaml → get project list
        3. For each project path, apply security validation:
           a. Resolve with realpath (follow symlinks to actual path)
           b. Verify resolved path starts with $HOME (prevent path traversal outside user home)
           c. Verify {resolved_path}/.tad/ directory exists (confirm TAD project)
           d. If any check fails: WARN "Skipping {name}: security check failed ({reason})", continue
           Note: TOCTOU risk from symlink race accepted as low-severity for local single-user CLI.
        4. Output validation summary: "Validated {passed}/{total} projects. Skipped: {skipped_list}"
        5. For each validated project, read {path}/.tad/evidence/traces/*.jsonl
           Parse each line as JSON, tag with project name
           If a JSONL line fails to parse: WARN "Skipping malformed trace in {file}:{line}", continue
        6. Also read local .tad/evidence/traces/*.jsonl (TAD main project)
           Skip local project if it already appears in registry to avoid double-counting
        7. Count total trace entries across all projects
           If total < 10: Output "⚠️ Not enough cross-project trace data ({count} entries across {project_count} projects, need at least 10)." → return to standby
        8. Output collection summary:
           "Collected {total} traces from {project_count} projects:
           {per_project_table: name | traces | date_range}"

    step2_analyze:
      name: "Cross-Project V2 Pattern Analysis"
      action: |
        From aggregated traces, identify cross-project patterns using v2 events:

        1. Cross-project reflexion patterns:
           - For each project's reflexion_diagnosis events:
             Extract what_failed via double-parse (jq '.context | fromjson | .what_failed')
           - Group by what_failed across ALL projects
           - Patterns appearing in 2+ projects → framework-level issue
           - Output: "Cross-project failure patterns:"
             | Pattern | Projects | Count | Suggestion |

        2. Cross-project gate failure correlation:
           - For each project's gate_result events with outcome=fail:
             Group by gate number
           - Compare per-gate fail rates across projects
           - Gates with >20% fail rate in 3+ projects → framework criteria issue
           - Output: "Gate failure correlation:"
             | Gate | Projects Affected | Avg Fail Rate |

        3. Framework dream candidate aggregation:
           - For each project: read {validated_path}/.tad/active/dream-candidates/CAND-*.md
             (using project paths from step1_collect — dream candidate paths
              MUST go through the same realpath + $HOME security validation as trace paths)
           - Filter: scope_tag=framework AND status=pending
           - Group by signal_type
           - Output: "Framework candidates from {N} projects:"
             | Signal Type | Count | Top Pattern |

        4. Lifecycle health comparison:
           - Run *optimize step2 metrics (1-5) per project
           - Compare: zombie rate, cycle time, evidence rate across projects
           - Flag outlier projects (>2σ from mean on any metric)
           - Output: "Project health comparison:"
             | Project | Zombie% | Cycle(h) | Evidence/HO | Status |

        5. Output analysis summary table to user

    step3_propose:
      name: "Generate Framework-Level Proposals"
      action: |
        For each finding, generate a PROPOSAL with scope: "framework":
        ```yaml
        proposal_id: "EVOLVE-{YYYYMMDD}-{NNN}"
        scope: "framework"
        target:
          file: "{SKILL.md | hook script | gate config | project-knowledge/*.md}"
          section: "{specific section to modify}"
        change_type: "{tighten_criteria | add_step | fix_step | add_enforcement | add_capability}"
        change:
          current: "{current definition}"
          proposed: "{suggested modification}"
          diff: |
            - "{current value}"
            + "{proposed value}"
        evidence:
          projects_affected: ["{project1}", "{project2}"]
          trace_count: {N}
          pattern: "{description}"
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

        Write proposals to .tad/evidence/proposals/ (same dir as *optimize)

      safety_constraints:
        description: "Same protection as *optimize — framework files have HIGHER risk surface"
        protected_patterns:
          - "MANDATORY"
          - "VIOLATION"
          - "BLOCKING"
          - "CRITICAL"
          - "forbidden"
          - "circuit_breaker"
          - "escalat"
        check_logic: |
          For each proposal, BEFORE writing the YAML file:
          1. Read the current value from target file
          2. Check if current value matches any protected_pattern (regex)
          3. If proposed REMOVES or WEAKENS the protected term → BLOCK (safety.safe=false)
          4. If proposed KEEPS the protected term intact → ALLOW
          Result: set safety.safe and safety.blocked_reason in proposal YAML

      post_proposals: |
        If no issues found:
          Output: "✅ No framework improvements needed — cross-project traces look healthy."
          → Return to standby

    step4_approve:
      name: "Human Approval (with framework impact warning)"
      action: |
        For proposals with safety.safe == false:
          Display: "⚠️ BLOCKED: {proposal_id} — touches protected term: {blocked_reason}"
          Auto-reject with status → "blocked". Do NOT offer approval.

        For each proposal with safety.safe == true and status == "pending":
        Use AskUserQuestion:
        question: "⚠️ 框架级修改 — 将通过 *sync 影响所有 {N} 个项目"
        Display:
          范围: 框架 (scope: framework)
          目标: {target.file} → {target.section}
          当前: {change.current}
          建议: {change.proposed}
          证据: {evidence.pattern} (来自 {projects_affected})
          置信度: {evidence.confidence}
        options:
          - "接受 — 应用到 TAD 主项目"
          - "修改后接受 — 调整措辞后应用"
          - "拒绝"
          - "稍后处理"

    step5_apply:
      name: "Apply & Remind Sync"
      action: |
        Note: Framework config edits (YAML, SKILL.md protocol sections) are within Alex's scope.
        For each accepted proposal:
        1. Read the target file
           If not found: WARN "Target {file} not found — skipping", continue
        2. Apply modification using Edit tool
        3. Update PROPOSAL YAML: status → "accepted"
        4. Git commit: "evolve({target}): {change_type} — {brief description}"

        5. Write accepted framework proposals to manifest:
           mkdir -p .tad/evidence/proposals/framework
           Write .tad/evidence/proposals/framework/MANIFEST.yaml:
           ```yaml
           last_updated: "{ISO date}"
           accepted_proposals:
             - id: "{proposal_id}"
               target: "{file}"
               change_type: "{type}"
               applied_at: "{date}"
               source_project: "{project_name}"
               proposal_file: ".tad/evidence/proposals/framework/{proposal_id}.yaml"
           ```

        After all proposals processed:
          Output: |
            Applied {count} framework improvements.
            ⚠️ {framework_count} framework proposals staged in .tad/evidence/proposals/framework/
            MANIFEST.yaml updated. Run *sync to push to all {N} downstream projects.
            Note: *sync integration is a future task — proposals are applied locally only.
        If no proposals accepted:
          Output: "No changes applied."

