# Notebooklm Access (extracted from blake/SKILL.md for progressive loading)
# Source: .claude/skills/blake/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 3)

notebooklm_access:
  description: "Blake can query existing notebooks for implementation context"
  scope: "read-only + controlled ingest (see mutation_scope)"

  allowed:
    - "*research-notebook ask --notebook <id> 'question'"  # query existing research (explicit notebook)
    - "*research-notebook fulltext <id>"                   # read source content
    - "*research-notebook guide <id>"                      # source summary
    - "*research-notebook topics --notebook <id>"          # notebook overview (explicit notebook required)
    - "*research-notebook ingest <file>"                   # feed implementation findings back (see mutation_scope)
    - "*research-notebook list"                            # see available notebooks
    - "*research-notebook language get"                    # read current language setting
    - "*research-notebook language list"                   # list available languages

  forbidden:
    - "*research-notebook create"           # Alex creates notebooks
    - "*research-notebook research"         # Alex directs research
    - "*research-notebook report"           # Alex generates reports
    - "*research-notebook configure"        # Alex sets persona/mode
    - "*research-notebook consolidate"      # Alex manages portfolio
    - "*research-notebook curate"           # Alex manages lifecycle
    - "*research-notebook archive"          # Alex manages lifecycle
    - "*research-notebook add"              # Alex manages sources
    - "*research-notebook sync"             # Alex reconciles with cloud
    - "*research-notebook use <id>"         # writes REGISTRY active_notebook — Alex-owned state
    - "*research-notebook language set"     # writes persistent per-notebook config — Alex configures

  default_rule: "deny"
  default_rule_explanation: |
    Any *research-notebook subcommand NOT listed in `allowed` is forbidden,
    even if not explicitly listed in `forbidden`. New subcommands added in
    future research-notebook versions require explicit classification before use.

  mutation_scope:
    description: "ingest is the only allowed command that writes persistent state"
    ingest_writes:
      - "NotebookLM: adds a permanent queryable source to the target notebook"
      - "REGISTRY.yaml: increments source_count for the notebook entry"
    ingest_constraints:
      - "Blake MUST use AskUserQuestion to confirm before running ingest (confirmation already in *research-notebook ingest Step 2)"
      - "Findings ingested should be factual, notebook-relevant, and complete (not draft notes)"
      - "The ingest target notebook must be explicitly declared with --notebook <id>"
    rationale: "Treating Blake findings as notebook knowledge is intentional — this is the knowledge feedback loop. Constrained by confirmation gate."

  when_to_use: |
    During *develop, if Blake needs context that might exist in a research notebook:
    1. Check: is there a relevant notebook? → *research-notebook list
    2. Query: ask a specific implementation question → always use --notebook <id>
    3. After implementation: if Blake discovers something noteworthy AND confirms with user,
       use *research-notebook ingest --notebook <id> to feed the finding back

  terminal_isolation: |
    Blake accesses NotebookLM via the same CLI as Alex (*research-notebook commands).
    Read-only commands (ask, fulltext, guide, topics, list, language get/list) do NOT
    mutate shared state — terminal isolation is preserved. The single mutation channel
    (ingest) requires explicit --notebook <id> and user confirmation, preventing
    silent cross-agent state changes. REGISTRY.yaml mutation routes through Alex only.

