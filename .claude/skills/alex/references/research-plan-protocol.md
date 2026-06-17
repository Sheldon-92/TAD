# Research Plan Protocol — Deep Level of *research
# Called by: research_unified_protocol.deep_execution (alex/SKILL.md)
# Original source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)
# Updated: 2026-06-17 (EPIC-20260616-research-system-consolidation Phase 1 — remove OBJECTIVES hard dep)

research_plan_protocol:
  description: "Deep research — full Phase 0-5 pipeline. Called via *research --deep"
  trigger: |
    Called from: research_unified_protocol when level == Deep
    Also: STEP 3.8 gap detection suggests "💡 运行 *research --deep 来执行深度研究"

  execution:
    step1:
      name: "读取目标 + 现有研究"
      action: |
        0. Preflight:
           → If OBJECTIVES.md found:
             → Read it → use Objectives + Key Results for gap-driven research planning
           → If OBJECTIVES.md not found:
             → Skip gap analysis; use the user's research question directly as the research topic
             → Proceed normally (OBJECTIVES is optional context, not a hard requirement)
           → If REGISTRY.yaml not found:
             → Treat as "no existing research" — proceed normally

        1. If OBJECTIVES.md exists: Read → extract all Objectives + Key Results with status ⬚/🔄
           If not: use user's research question from *research --deep invocation
        2. Read REGISTRY.yaml → list all active notebooks with topics (empty if absent)
        3. Identify gaps: which ⬚/🔄 KRs have NO aligned notebook research? (LLM semantic match)
           If no OBJECTIVES: treat the user's question as the single gap
        4. If OBJECTIVES exists and no gaps → "✅ 所有目标都有对应研究覆盖，暂无空白。" → standby

    step2:
      name: "生成研究计划"
      action: |
        For each identified gap:
        - Research Question: 为了推进 KR-X，需要回答什么问题？
        - Research Method: deep search / targeted ask / report generation
        - Expected Output: notebook 新增源 / 报告 / 决策依据
        - Estimated Time: fast (~1min) / deep (~4min) / report (~2min)

        Output as structured plan:
        ```
        ## 📋 研究计划 (基于 OBJECTIVES.md gap analysis)

        | # | 目标 KR | 研究问题 | 方法 | 预期产出 | 时间 |
        |---|---------|---------|------|---------|------|
        | 1 | O1-KR2 (TTS 工具链) | 哪个 TTS 工具最适合恐怖叙事？ | report | 工具对比报告 | ~2min |
        | 2 | O1-KR3 (分发平台) | 哪些平台对恐怖播客友好？ | deep search | 10+ 源 | ~4min |
        ```

    step3:
      name: "用户确认"
      action: |
        AskUserQuestion:
        "这是基于你的业务目标生成的研究计划。怎么处理？"
        Options:
          - "全部执行" → step4 (逐个执行)
          - "选择性执行" → user picks which rows → step4 (只执行选中的)
          - "调整计划" → user modifies → back to step3
          - "不执行，只记录" → mkdir -p .tad/evidence/research/ → save plan to .tad/evidence/research/research-plan-{YYYY-MM-DD}.md → standby

    step4:
      name: "执行研究"
      action: |
        ⚠️ EXECUTION MECHANISM (CRITICAL — prevents WebSearch fallback):
        *research-notebook commands run IN THIS SESSION using Bash tool.
        DO NOT delegate to background Agent tools.
        DO NOT invoke /deep-research or /research skill.
        
        To execute *research-notebook X:
        1. Read .claude/skills/research-notebook/SKILL.md (if not already in context)
        2. Run preflight: test -x ~/.tad-notebooklm-venv/bin/notebooklm
        3. If preflight PASS → follow sub-command steps using Bash tool (sequential)
        4. If preflight FAIL → announce to user:
           "⚠️ NotebookLM CLI not available. Falling back to WebSearch-based research.
            To enable NotebookLM: bash .tad/cross-model/setup-notebooklm.sh"
           Then SKIP the *research-notebook commands below entirely.
           Instead, use WebSearch/WebFetch IN THIS SESSION (not Agent tools)
           for each research item. Keep results in conversation context.
        
        NotebookLM is STATEFUL — cannot be parallelized across agents.
        Execute research items SEQUENTIALLY in this session.

        For each confirmed research item:

        a0. PHASE 0 — Research Plan (NEW — define before sourcing):
           → Step 1: Define 5-10 specific research questions from the gap analysis
             Format rule: questions MUST include a specificity anchor:
             ✅ "From GitHub repos: what specific CLI tools exist for X?"
             ✅ "What token structure does Shopify Polaris use in its polaris-tokens package?"
             ❌ "What are best practices for X?" (too vague — REJECT and rephrase)
             ❌ "How should we approach X?" (no specificity anchor — REJECT)
           → Step 2: Define source type priority for this research topic:
             | Priority | Source Type | Example |
             |----------|------------|---------|
             | 1 (first) | GitHub awesome-lists | awesome-design-systems, awesome-tailwindcss |
             | 2 | Real company repos | Shopify/polaris, primer/react, adobe/react-spectrum |
             | 3 | Tool official repos | storybookjs/storybook, amzn/style-dictionary |
             | 4 | Tool documentation sites | docs.anthropic.com, storybook.js.org |
             | 5 (last) | Deep research (articles) | ONLY if Phases 1-3 leave gaps |
           → Step 3: Define success criteria:
             "After this research, I should be able to decide: {specific decision}"
           → Display plan to user for confirmation before proceeding

        a0_class. PHASE 0class — Effort-Scaling Classification (NEW — Phase 4 wiring, runs per research item, BEFORE Phase 0c):
           ⚠️ This is the effort-scaling ladder that REPLACES the old opt-in/skip default.
           Default is complexity-derived, NOT "skip". Alex SUGGESTS; the human can override (adaptive_complexity philosophy + DR-20260531 condition).

           → Step 1: Classify THIS research item into exactly ONE complexity tier.
             Mutually exclusive + ORDERED — classify as the LOWEST tier whose EXPLICIT trigger is met.
             Default to `comparison` when ambiguous (NOT complex) — per backend-architect P1-1, vague signals must NOT collapse everything to complex.

             | Complexity | EXPLICIT trigger (must match to qualify) | run_dynamic_seeds | run_adversarial_challenge |
             |------------|-------------------------------------------|-------------------|----------------------------|
             | simple     | single fact / narrow API or syntax lookup / 1 KR, answer is a lookup not a judgment | off | off |
             | comparison (DEFAULT when ambiguous) | research question explicitly compares-and-recommends across ≥2 named options/tools | on | off |
             | complex    | spans ≥3 distinct KRs that are themselves ⬚ incomplete, OR explicit landscape/survey scope | on | on |

             Set the two booleans from the chosen row:
               run_dynamic_seeds      = on for comparison|complex, off for simple
               run_adversarial_challenge = on for complex only, off for simple|comparison
             (These two booleans are cached for the whole *research-plan execution of THIS item.)

           → Step 2: DISPLAY + OVERRIDE (DR-20260531 safety condition — REQUIRED, replaces the per-gate keystroke):
             Show the user:
               "🎚️ Effort classification: {tier}
                  → dynamic adaptive seeds: {run_dynamic_seeds on/off}
                  → adversarial challenge (Codex+Gemini): {run_adversarial_challenge on/off}"
             → AskUserQuestion: "采用这个 effort 等级吗？（可手动覆盖）"
               Options:
                 - "采用 (Recommended)" → keep classification
                 - "改为 simple" → run_dynamic_seeds=off, run_adversarial_challenge=off
                 - "改为 comparison" → run_dynamic_seeds=on, run_adversarial_challenge=off
                 - "改为 complex" → run_dynamic_seeds=on, run_adversarial_challenge=on
             ⚠️ The classification is a SUGGESTION, not a lock. The user MUST be able to turn the adversarial
                challenge off before it executes (DR-20260531 overridable condition). This display+override pair
                is the human-confirmation mechanism that REPLACES the old per-gate "执行/跳过" keystroke.

           → Step 3: Persist for Phase 5 (backend-architect P1-4 forward-compat):
             Record the final (possibly-overridden) tier so Phase 4 Step 3 writes it into the findings file
             frontmatter under the stable key `research_complexity: simple|comparison|complex`.
             Phase 5's persona-seeding + rubric read this key instead of re-deriving complexity.

        a0_c. PHASE 0c — Adversarial Challenge: Research Plan:
           Trigger: After Phase 0 plan confirmed by user, before Phase 1 sourcing.
           CHALLENGE_INSTRUCTION: "Review the research input below. Follow the output format exactly. Be adversarial — challenge quality, do not agree."
           (Symmetric instruction — BOTH Codex and Gemini receive this identical string. Per architecture.md prompt symmetry rule.)

           → Step 1: Effort-scaling gate (NOT_via_alex_auto constraint, now satisfied via DR-20260531 carve-out):
             The challenge runs iff `run_adversarial_challenge` (set + displayed + overridable in Phase 0class).
             ⚠️ Preflight (Step 2) runs REGARDLESS so the cached vars exist for Phase 4c/5b even if this
                Phase 0c challenge is gated off (backend-architect P0-2 preflight-ordering fix).
             → Run Step 2 preflight FIRST (always), THEN:
               If run_adversarial_challenge == off → skip the challenge invocation; go to Phase 1 (step a).
               (No keystroke here — the run/skip decision was already displayed + made overridable in Phase 0class.)
           → Step 2: Preflight (run ONCE per *research-plan execution, ALWAYS — cache result regardless of run_adversarial_challenge):
             codex_available=$(command -v codex >/dev/null 2>&1 && echo 1 || echo 0)
             gemini_available=$(command -v gemini >/dev/null 2>&1 && echo 1 || echo 0)
             (Cache codex_available / gemini_available now even when run_adversarial_challenge==off, so 4c/5b never read an unset var.)
             If run_adversarial_challenge == on AND both == 0 → WARN "adversarial review unavailable — both Codex and Gemini missing" → skip to Phase 1
           → Step 3: Assemble challenge payload:
             Collect all Phase 0 research questions into a temp file:
             rm -f /tmp/tad-challenge-plan.md
             sed -n '/<!-- BEGIN plan -->/,/<!-- END plan -->/{ /<!-- BEGIN/d; /<!-- END/d; p; }' .tad/templates/research-challenge-prompt.md > /tmp/tad-challenge-plan.md
             printf '\n---\n## 研究问题列表\n' >> /tmp/tad-challenge-plan.md
             (Append the Phase 0 question list from conversation context via printf '%s\n' >> /tmp/tad-challenge-plan.md)
           → Step 4: Invoke models (sequential: Codex → Gemini):
             If codex_available == 1:
               codex_result=$(cat /tmp/tad-challenge-plan.md | codex exec --full-auto --skip-git-repo-check \
                 "$CHALLENGE_INSTRUCTION" 2>/dev/null)
               codex_exit=$?
               if [ $codex_exit -eq 0 ] && [ -n "$codex_result" ]; then
                 printf '%s' "$codex_result" > .tad/evidence/research/{slug}/challenge-plan-codex.md
               else
                 printf 'UNAVAILABLE: Codex exit %d' "$codex_exit" > .tad/evidence/research/{slug}/challenge-plan-codex.md
               fi
             If gemini_available == 1:
               gemini_result=$(cat /tmp/tad-challenge-plan.md | gemini -p \
                 "$CHALLENGE_INSTRUCTION" 2>/dev/null)
               gemini_exit=$?
               if [ $gemini_exit -eq 0 ] && [ -n "$gemini_result" ]; then
                 printf '%s' "$gemini_result" > .tad/evidence/research/{slug}/challenge-plan-gemini.md
               else
                 printf 'UNAVAILABLE: Gemini exit %d' "$gemini_exit" > .tad/evidence/research/{slug}/challenge-plan-gemini.md
               fi
           → Step 5: Extract ratings + decide:
             For each model file (challenge-plan-codex.md, challenge-plan-gemini.md):
               rating=$(head -5 <file> | grep -oE 'INSUFFICIENT|ADEQUATE|STRONG' | head -1)
               if [ -z "$rating" ]; then
                 rating=$(grep -ioE 'INSUFFICIENT|ADEQUATE|STRONG' <file> | head -1 | tr '[:lower:]' '[:upper:]')
               fi
               if [ -z "$rating" ]; then rating="INSUFFICIENT"; fi  # fail-closed
               Handle UNAVAILABLE: if file starts with "UNAVAILABLE:" → treat as model unavailable (NFR2 degradation)
             Pass logic:
               Both available: PASS if both ADEQUATE or STRONG
               Single model (other UNAVAILABLE): PASS if that model ADEQUATE or STRONG
               Neither available: auto-PASS (already warned in Step 2)
             If PASS:
               Report: "✅ Phase 0c challenge PASSED (Codex: {rating}, Gemini: {rating})"
               Even on PASS: read dimension-level findings from both reports,
               append as "Advisory: [model] flagged: [gap]" to conversation context
               → Log to challenge-log.md (Step 6) → Proceed to Phase 1 (step a)
             If FAIL (any INSUFFICIENT):
               Report: "⚠️ Phase 0c challenge FAILED — extracting refined questions"
               Extract "修正后的问题列表" from ALL INSUFFICIENT model outputs.
               If both INSUFFICIENT: merge + deduplicate refined questions across models.
               If only one INSUFFICIENT: also read ADEQUATE model's dimension findings for supplementary perspective.
               → AskUserQuestion:
                 question: "Challenge 层修正了研究问题。如何处理？"
                 Options:
                   - "采纳修正后的问题 (Recommended)" → replace Phase 0 questions with refined set → Phase 1
                   - "手动调整" → user edits, then → Phase 1
                   - "忽略 challenge，使用原始问题" → keep original questions → Phase 1
               → Log to challenge-log.md (Step 6) → Proceed to Phase 1 (step a)
           → Step 6: Log to challenge-log.md:
             Append entry to .tad/evidence/research/{slug}/challenge-log.md:
             "Phase 0c | Codex: {rating} | Gemini: {rating} | Gaps: {key gaps} | Led to refinement: {yes/no}"

        a. 确定 target notebook:
           → If existing notebook matches topic → use it
           → If no match → *research-notebook create "{topic}" (new notebook)

        b. PHASE 1 — GitHub-First Sourcing (replaces old "Deep Research"):
           → Step 1: Search for awesome-lists
             WebSearch: "github awesome list {topic} site:github.com"
             For each relevant awesome-list found:
               ~/.tad-notebooklm-venv/bin/notebooklm source add "https://github.com/{org}/{repo}" -n <id>
               sleep 2
           → Step 2: Explore awesome-list sub-pages
             For TOP 3 most relevant awesome-lists:
               gh api "repos/{org}/{repo}/git/trees/main?recursive=1" --jq '[.tree[] | select(.type == "blob" and (.path | test("\\.md$"))) | .path][:20]'
               For each actionable sub-page (DESIGN.md files, specific tool docs, subagent definitions):
                 ~/.tad-notebooklm-venv/bin/notebooklm source add "https://github.com/{org}/{repo}/blob/main/{path}" -n <id>
                 sleep 1
           → Step 3: Add real company repos (if topic involves a specific technology/pattern)
             WebSearch: "github {technology} design system stars:>5000"
             Add top 3-5 repos
           → Step 4: Add tool official repos (for each tool mentioned in Phase 0 questions)
             ~/.tad-notebooklm-venv/bin/notebooklm source add "https://github.com/{tool-org}/{tool-repo}" -n <id>
           → Report: "📦 Phase 1 sourcing: {N} GitHub sources added ({awesome} awesome-lists + {sub} sub-pages + {company} company repos + {tool} tool repos)"

        c. PHASE 2 — Auto-Curate (fully automatic, no user interaction):
           → Step 1: Delete error sources (uses same filter as *research-notebook curate Step 1b)
             → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id>
             → Parse JSON: each source has an `id` field (UUID string). Filter sources where
               `status` field contains "error" (explicit error only).
               Do NOT delete sources with status "preparing" or "processing" — these may succeed.
             → ⚠️ DEFENSIVE: If JSON shape is unexpected (no `id` field), STOP and report:
               "source list JSON format changed — manual curate needed"
             → Step A — Collect error IDs (single Bash call):
               error_ids=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id> | \
                 jq -r '.[] | select(.status | test("error")) | .id')
             → Step B — Parallel delete (single Bash call):
               echo "$error_ids" | xargs -P5 -n1 sh -c '
                 ~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <id> --yes 2>&1 | \
                   grep -q "error\|429" && echo "FAIL:$1" || echo "OK:$1"
                 sleep 0.2
               ' _
             → If any FAIL: lines in output: "⚠️ {N} deletes failed — consider reducing to -P3 or -P1"
             → Report: "🧹 Cleaned {N} error sources"
           → Step 2: Deduplicate (title + domain match)
             → Group sources by (lowercase title, URL domain)
             → Sources without URL (type=text/file) → skip dedup (unique by definition)
             → For each group with count > 1: keep first, collect rest as dedup_ids
             → Parallel delete (single Bash call):
               echo "$dedup_ids" | xargs -P5 -n1 sh -c '
                 ~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <id> --yes 2>&1 | \
                   grep -q "error\|429" && echo "FAIL:$1" || echo "OK:$1"
                 sleep 0.2
               ' _
             → If any FAIL: lines in output: "⚠️ {N} deletes failed — consider reducing to -P3 or -P1"
             → Report: "🔄 Removed {N} duplicates, {M} unique sources remain"
           → Step 3: Source quality tiering (use canonical patterns from *research-notebook curate Step 3)
             → tier1_patterns: [".gov", ".edu", "arxiv.org", "pubmed", ".who.int", "fda.gov",
                  "developer.apple.com", "developers.google.com", "docs.anthropic.com",
                  "owasp.org", "w3.org", "ietf.org"]
             → tier2_patterns: ["medium.com", "dev.to", "stackoverflow.com", "docs.*", "blog.*",
                  ".readthedocs.io", "github.com/*/wiki"]
             → tier3_patterns: ["reddit.com", "x.com", "twitter.com", "forum.*", "community.*",
                  "news.ycombinator.com"]
             → Classify each source; store tier in conversation context (ephemeral judgment)
             → Report: "📊 Source quality: {T1} Tier 1, {T2} Tier 2, {T3} Tier 3"

        d. PHASE 3 — Baseline Report:
           → *research-notebook report "{topic} comprehensive analysis"
           → Save to .tad/evidence/research/{slug}/{date}-report.md
           → Report: "📄 Baseline report saved. This is orientation, not the final deliverable."

        e. PHASE 4 — Seed Questions + Dynamic Ask (depth-first):
           → Step 1: Generate 2-3 seed questions from OBJECTIVES.md KRs
             ⚠️ EFFORT-SCALING DISAMBIGUATION (backend-architect P0-2): this Step 1 baseline seed question tree
                is the CORE deliverable and runs for ALL tiers (simple|comparison|complex). It is NOT gated by
                `run_dynamic_seeds`. Gating it off would degenerate simple-tier research to just the Phase 3 report.
             Note: each seed question triggers dynamic_ask_protocol (step3_5 in *research-notebook ask)
             ONLY IF `run_dynamic_seeds` (on for comparison|complex, off for simple — set in Phase 0class).
             When run_dynamic_seeds == off (simple tier): run each baseline seed as a SINGLE ask (no step3_5
             depth chain) — the baseline tree still executes, just without per-seed dynamic deepening.
             When run_dynamic_seeds == on: depth-first via step3_5 dynamic_ask_protocol as before.
             Alex may generate 4-5 seeds with written justification if KR count is unusually high.
             Latency note: 2-3 seeds × max_depth 4 = 8-12 NotebookLM calls (~23-43s each)
             → ~4-8 min per research item. Inform user before starting Phase 4.
             → If OBJECTIVES.md not found in project root:
               → Display: "No OBJECTIVES.md found — skipping Question Tree + AC Bridge (Phase 4-5)."
               → SKIP Phase 4 and Phase 5 entirely. Phase 3 report is the final deliverable.
               → Proceed to step5 (OBJECTIVES coverage update — which no-ops when OBJECTIVES.md is absent)
             → PERSONA PASS (FR1 — STORM-style breadth-at-question-time; runs ALL tiers, BEFORE KR seeds):
               Generate stakeholder persona perspectives from the research TOPIC, then seed one
               specificity-anchored sub-question per persona. This attacks the single-angle bias of a
               KR-only tree (the question tree otherwise only reflects the author's framing).
               Persona pool (pick by topic relevance): end-user, implementer/builder, skeptic/critic,
               operator/maintainer, domain-expert, cost-owner.
               → Scale stakeholder persona count by the persisted `research_complexity` (READ from the
                 Phase 0class frontmatter — persisted above at :1539; do NOT re-derive the tier):
                 | research_complexity | stakeholder persona count |
                 | simple              | 0 or 1 (DEFAULT 0 — do NOT inflate the simple-tier single-ask path) |
                 | comparison          | 3 |
                 | complex             | 4 |
                 (Greppable scaling row: simple 0|1 · comparison 3 · complex 4.)
               → Each stakeholder persona generates ≥1 sub-question that OBEYS the SAME Question format
                 rules below (specificity anchor MANDATORY; reject "best practices for X" — rephrase).
               → MERGE persona sub-questions INTO the baseline seed tree — they do NOT replace KR-derived
                 seeds. ⚠️ SHARED BUDGET: persona sub-questions + KR-derived seeds TOGETHER count against
                 the existing 2-3 Step 1 cap (4-5 only with the written justification the cap rule already
                 allows). Personas do NOT silently bypass the cap. Allocation order: fill persona seeds
                 first (capped by the scaling table), then KR-derived seeds up to the REMAINING budget; if
                 the combined set would exceed the cap, prioritize the highest-uncertainty KRs and the
                 most topic-relevant personas, dropping the rest.
               → Display the persona set to the user inside the Question Tree (add a Persona column),
                 consistent with the existing display+override ethos (user may edit/drop personas).
               ⚠️ This persona pass AUGMENTS Step 1 (the all-tiers baseline) — it does NOT re-gate Step 1
                  on `run_dynamic_seeds` (preserves the Phase 4 effort-scaling disambiguation above).
             → Read OBJECTIVES.md KRs aligned with this research item
             → For each KR with status ⬚/🔄, generate 1 seed question (max 2-3 total across all KRs):
               (KRs with status ✅ → skip. Prioritize KRs with highest uncertainty.)
               Format: "KR: {KR description} → Q: {specific question this notebook can answer}"
             Question format rules (MANDATORY):
             ✅ Include specificity anchor: "From [source type]: what [specific thing]?"
             ✅ Ask for CLI commands, not concepts: "What CLI tool does X?"
             ✅ Reference specific sources: "From the Shopify Polaris repo: how do they structure tokens?"
             ❌ REJECT "What are best practices for X?" — rephrase to "What do [companies] actually use for X?"
             ❌ REJECT "How should we approach X?" — rephrase to "What specific tools/patterns exist for X?"
             If a generated question matches a ❌ pattern, Alex MUST rephrase before adding to tree.
             → Display Question Tree to user (include Persona column for FR1 persona seeds; KR-derived
               seeds leave Persona blank or "—"):
               "📋 Question Tree (based on {N} KRs + {P} stakeholder persona seeds):"
               | # | KR | Persona | Question | Priority |
             → AskUserQuestion: "这些问题对吗？"
               Options: "确认执行" / "我要调整" / "加自定义问题" / "跳过 ask"
           → Step 2: Execute ask loops (sequential, with 1s delay between asks)
             → For each confirmed question:
               → Construct query: if KR status is ⬚ (incomplete) →
                 query = "{question} — prioritize official/academic sources"
                 else → query = "{question}" as-is
               → If cross-notebook query needed (topic spans multiple notebooks):
                 → Identify relevant notebooks from REGISTRY (LLM semantic match)
                 → If REGISTRY has only 1 active notebook → skip cross-notebook, use single ask
                 → For each relevant notebook:
                   → ~/.tad-notebooklm-venv/bin/notebooklm ask "{constructed_query}" -n <notebook_id>
                   → (Use -n flag ONLY — do NOT call `notebooklm use`. -n is stateless per-command override.
                      `use` mutates global active notebook state which leaks across loop iterations.
                      REGISTRY.yaml active_notebook is unchanged — no save/restore needed with -n.)
                   → PHASE 4b: scan this notebook's answer for gap signals; run enrichment if found (see PHASE 4b below)
                   → sleep 1
                 → Alex synthesizes answers from all notebooks in conversation
                 → Note which notebook contributed what (for traceability)
               → Else (single notebook):
                 → ~/.tad-notebooklm-venv/bin/notebooklm ask "{constructed_query}" -n <id>
                 → PHASE 4b: scan answer for gap signals; run enrichment if found (see PHASE 4b below)
               → sleep 1 between consecutive ask calls (rate limit protection)

           → PHASE 4b — Gap Detection + Auto-Enrichment (CRAG Judge Loop):
             max_reask_per_question: 1  # 1 re-ask attempt; original ask + re-ask = 2 total per question
             gap_signals:  # scan answer text case-insensitive
               - "sources do not contain"
               - "not from your sources"
               - "not mentioned in the provided sources"
             scope: per-notebook answer (cross-notebook mode); per-question answer (single notebook mode)

             When gap signal found in answer:
             1. Report: "🔄 Gap detected on Q{N}. Attempting targeted enrichment for notebook <target_notebook_id>..."
             2. Query narrowing: extract 2-3 most specific noun phrases from the original question.
                Construct: fast_query = "{noun_phrase_1} {noun_phrase_2}"  # NOT the full KR question verbatim
             3. Fast research: ~/.tad-notebooklm-venv/bin/notebooklm source add-research "{fast_query}" --mode fast --import-all -n <target_notebook_id>
             3b. If fast research finds 0 usable sources AND this is the first gap for this topic:
                → Escalate to deep research as fallback:
                  ~/.tad-notebooklm-venv/bin/notebooklm source add-research "{broader_topic}" --mode deep -n <target_notebook_id>
                  Report: "🔍 Gap persists after fast research. Running deep research as fallback..."
                → Auto-curate (error + dedup) after deep research completes
                → Then retry the ask
                → This is the ONLY path where deep research runs. It is a fallback, not a primary.
             3c. External Source Discovery (WebSearch + add-smart) — last resort:
                Trigger: AFTER step 3 (fast research) AND step 3b (deep research fallback, if triggered)
                         AND net new usable sources still == 0
                → Report: "🌐 Internal enrichment found 0 sources. Searching externally..."
                → WebSearch "{gap_noun_phrases} {broader_topic}" (1 search query)
                → From results, select top 3 URLs (prefer: official docs > GitHub > blog posts)
                  Max URLs: 3 (hard cap per user decision — do NOT exceed)
                → For each URL (up to 3):
                  a. Dedup check:
                     source_urls=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id> | jq -r '.[].url // empty')
                     If URL already in source_urls → skip
                  b. Preprocess if URL matches bilibili/youtube/substack/medium handler patterns:
                     result=$(bash .tad/cross-model/source-preprocessor.sh dispatch "$url" <notebook_id>)
                     dispatch_exit=$?
                     If dispatch_exit == 0 → add_target="$result" (local .md)
                     If dispatch_exit == 10 → add_target="$result" (remote URL)
                     If dispatch_exit >= 1 → skip URL (handler failure or unknown type)
                  c. Import: ~/.tad-notebooklm-venv/bin/notebooklm source add "$add_target" -n <id>
                  d. sleep 2
                → Per-source quality verification via source ID (architecture.md "False Success" pattern):
                  Before each source add (step c): capture ids_before (source list --json | jq -r '.[].id')
                  After source add: ids_after = new source list IDs; new_source_id = comm set-diff (same pattern as STEP 3c.a dedup check)
                  For each new_source_id: call verify_import_quality(notebook_id, new_source_id)
                    per research-notebook/SKILL.md HELPER block (source-ID-based, includes title in probe — avoids "most recently added" ambiguity)
                  If FAIL → mark source as failed import; do NOT count toward net new.
                  If WARN or PASS → count as successful import.
                → Re-count quality-verified sources:
                  If net new > 0 → Report: "🌐 Added {N} external sources (quality-verified). Re-asking..."
                             → Proceed to step 5 (lightweight re-curate) then step 6 (re-ask)
                  If net new == 0 → Report: "⚠️ External search also found 0 usable sources for Q{N}."
                             → Proceed to step 4 (zero-source check → skip re-ask)
             4. Zero-source check: count sources before/after (exclude error sources). If net new sources = 0:
                → Report: "⚠️ Fast research found 0 usable sources for Q{N}. Keeping original answer."
                → Skip re-ask, proceed to next question
             5. Lightweight re-curate (error cleanup only — skip dedup + tiering for speed):
                → error_ids=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <target_notebook_id> | \
                    jq -r '.[] | select(.status | test("error")) | .id')
                → echo "$error_ids" | xargs -P5 -n1 sh -c '
                    ~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <target_notebook_id> --yes 2>&1 | \
                      grep -q "error\|429" && echo "FAIL:$1" || echo "OK:$1"
                    sleep 0.2
                  ' _
             6. Report + re-ask:
                → Report: "🔄 Gap detected on Q{N}. Added {M} targeted sources. Re-asking..."
                → ~/.tad-notebooklm-venv/bin/notebooklm ask "{original_question}" -n <target_notebook_id>
                  (Raw CLI call — NOT *research-notebook ask — intentional: avoids nested step3_5 loop.
                   If this is ever migrated to *research-notebook ask, add --no-follow flag.)
             7. Diminishing returns check (after re-ask answer received):
                → original_citations=$(echo "<original_answer>" | grep -oE '\[[0-9]+\]' | sort -u | wc -l)
                → reask_citations=$(echo "<reask_answer>" | grep -oE '\[[0-9]+\]' | sort -u | wc -l)
                → If reask_citations ≤ original_citations AND gap signal still present in re-ask answer:
                  → Report: "📉 Diminishing returns on Q{N}: citation count unchanged ({reask_citations}), gap signal persists. Stopping."
                  → Accept re-ask answer as-is, proceed to next question
                → Else if gap signal still present in re-ask answer:
                  → Report: "⚠️ Gap persists after enrichment for Q{N}. Accepting answer as-is."
                  → Accept re-ask answer as-is, proceed to next question
                → Else (gap resolved): use re-ask answer, proceed to next question

             When no gap signal: skip PHASE 4b entirely, proceed normally

           → Step 2.5: Adaptive Seed Generation (after each seed's chain + Phase 4b completes)
             ⚠️ EFFORT-SCALING GATE (Phase 4 wiring): Step 2.5 runs iff `run_dynamic_seeds`
                (on for comparison|complex, off for simple — set in Phase 0class). This is INTERNAL NotebookLM
                only (no external CLI, no AR-001 constraint) → fully auto by complexity, no keystroke.
                If run_dynamic_seeds == off → skip Step 2.5 entirely, proceed to Step 3 (Save findings).
             MAX_DYNAMIC_SEEDS: 2  # hard cap — total across all seeds, prevents unbounded growth
             TRACK: dynamic_seeds_added = 0 (initialized at Phase 4 entry)
             Compact recovery: dynamic_seeds_added is recoverable from chain frontmatter:
               bash: dynamic_seeds_added=$(grep -rl 'seed_origin: dynamic' .tad/evidence/research/ | wc -l | tr -d ' ')
               (Each dynamic seed's chain .md has `seed_origin: dynamic` in frontmatter — see research-notebook/SKILL.md chain format)
             Scope: runs ONLY for original seeds (NOT for dynamically-added seeds — prevents meta-seed recursion)
             Origin tracking: each seed has `is_dynamic = false` (confirmed_questions) or `is_dynamic = true` (Step 2.5 appended).
               Step 2.5 evaluation: if current seed's `is_dynamic == true` → skip entirely.

             After each original seed's step3_5 chain AND Phase 4b gap enrichment completes:
             → Read the chain's so_what round (or final round if saturated early)
             → Analyze: "Did this chain reveal a sub-topic NOT covered by any existing or pending seed?"
               Detection signals:
                 - Answer mentions a concept/tool/framework not referenced in any seed question
                 - Answer explicitly says "this area needs further investigation"
                 - Chain surfaced a surprising finding (from step3_5 surprising dimension) that opens a new thread
             → If new sub-topic detected AND dynamic_seeds_added < MAX_DYNAMIC_SEEDS:
               a. Generate new seed question following format rules (specificity anchor mandatory):
                  Format: "Based on chain finding '{surprising_finding}': {specific question with anchor}"
               b. AskUserQuestion: "研究中发现了新的子话题。要追加一个新的研究问题吗？"
                  question: "Chain '{original_seed}' revealed: '{finding_summary}'. 追加新问题？"
                  Options:
                    - "追加: {generated_question} (Recommended)" → append to seed queue; dynamic_seeds_added += 1
                    - "跳过这个发现" → continue to next seed
                    - "自定义问题" → user types their own question; dynamic_seeds_added += 1
               c. New seed inherits notebook context (same -n flag, same Phase 4 execution path)
                  Cross-notebook mode: dynamic seeds undergo same notebook relevance check as original seeds
               d. New seed executes AFTER all original seeds complete (append to END of queue, not insert mid-queue)
               e. Dynamic seeds receive full Phase 4b treatment (gap detection + auto-enrichment + Auto Source Discovery)
               f. Adaptive Seed check does NOT run for dynamically-added seeds (prevents meta-seed generation)
                  Queue is flat — all dynamic seeds append to end regardless of which original seed spawned them
             → If dynamic_seeds_added >= MAX_DYNAMIC_SEEDS:
               → Report: "📋 Dynamic seed cap reached (2/2). Remaining findings saved for reference."
               → Continue without adding more seeds

           → Step 3: Save findings
             → Write all ask results to .tad/evidence/research/{slug}/{date}-ask-findings.md
             → Format: per-question sections with KR reference, answer summary, source citations
             → ⚠️ PERSIST EFFORT CLASSIFICATION (backend-architect P1-4 forward-compat): write a YAML
               frontmatter block at the TOP of the findings file with the stable key:
                 ---
                 research_complexity: {simple|comparison|complex}   # final tier from Phase 0class (after any user override)
                 ---
               Phase 5 (persona-seeding + 5-dim rubric) reads `research_complexity` instead of re-deriving it.

        e_c. PHASE 4c — Adversarial Challenge: Research Findings (CORE):
           Trigger: After Phase 4 Step 3 (findings saved to file), before Phase 4.5.
           ⚠️ NOT inside Phase 4b per-question loop — this is batch challenge AFTER all questions complete.
           MAX_CHALLENGE_ROUNDS: 2 (per research item, not global)
           TRACK: challenge_round = 0
           Uses CHALLENGE_INSTRUCTION from Phase 0c (symmetric prompt for both models).

           → Step 1: Effort-scaling gate (NOT_via_alex_auto constraint, now satisfied via DR-20260531 carve-out):
             The challenge runs iff `run_adversarial_challenge` (set + displayed + overridable in Phase 0class).
             If run_adversarial_challenge == off → skip to Phase 4.5 (e_5).
             (No keystroke — the run/skip decision was displayed + made overridable in Phase 0class.)
             ⚠️ Uses cached codex_available / gemini_available from Phase 0c Step 2 (always run, so safe even
                when Phase 0c challenge itself was gated off — backend-architect P0-2).

           → Step 2: Assemble challenge payload (loop entry point for re-challenge):
             challenge_round += 1
             rm -f /tmp/tad-challenge-findings.md
             sed -n '/<!-- BEGIN findings -->/,/<!-- END findings -->/{ /<!-- BEGIN/d; /<!-- END/d; p; }' .tad/templates/research-challenge-prompt.md > /tmp/tad-challenge-findings.md
             printf '\n---\n' >> /tmp/tad-challenge-findings.md
             cat .tad/evidence/research/{slug}/{date}-ask-findings.md >> /tmp/tad-challenge-findings.md

           → Step 3: Invoke models:
             Use cached preflight results (codex_available / gemini_available from Phase 0c).
             Codex: cat /tmp/tad-challenge-findings.md | codex exec --full-auto --skip-git-repo-check \
               "$CHALLENGE_INSTRUCTION" 2>/dev/null
             Save to .tad/evidence/research/{slug}/challenge-findings-r{challenge_round}-codex.md (exit code gate: printf '%s' on success, printf 'UNAVAILABLE: ...' on failure)
             Gemini: cat /tmp/tad-challenge-findings.md | gemini -p \
               "$CHALLENGE_INSTRUCTION" 2>/dev/null
             Save to .tad/evidence/research/{slug}/challenge-findings-r{challenge_round}-gemini.md (exit code gate)

           → Step 4: Extract ratings (same mechanism as Phase 0c Step 5):
             For each model: head -5 grep → case-insensitive fallback → fail-closed INSUFFICIENT
             Handle UNAVAILABLE (NFR2): if file starts with "UNAVAILABLE:" → treat as model unavailable.
             Single-model degradation (inlined): if one model UNAVAILABLE + other ADEQUATE+ → PASS.
             Both UNAVAILABLE → auto-PASS with WARN.

           → Step 4b: Quality Rubric scoring (FR2 — SAME invocation, no new call site):
             The Step 3 Codex+Gemini reports ALSO contain a `## Quality Rubric (5-dim ...)` block
             (added to the `findings` variant of research-challenge-prompt.md — extracted in Step 2).
             ⚠️ This rides the EXISTING challenge invocation — it is NOT a new auto-invoke / external-CLI
                call. (If 4c text is ever too signal-poor to score 4 dims, do NOT add a second targeted
                scoring call — that needs a DR amendment. STOP + escalate instead.)
             → For each model, parse its 4 SCORED sub-scores (each ∈ {0.0, 0.5, 1.0}):
               citation_accuracy (citation mechanics), factual_accuracy (claim truth),
               completeness (KR coverage ratio), source_quality (tier mix);
               plus efficiency (ADVISORY note — NOT scored, never in the aggregate).
               If a model is UNAVAILABLE → use the other model's scores; if both UNAVAILABLE → skip rubric
               (note "rubric unavailable" in findings) and proceed.
             → Combine the two models per scored dim by AVERAGING their sub-scores (mean of Codex+Gemini).
             → Aggregate via the HYBRID FLOOR RULE (NOT a plain mean):
               IF factual_accuracy < 0.5 OR citation_accuracy < 0.5
                 → overall = min(factual_accuracy, citation_accuracy)   # floor: highest-consequence failure wins
               ELSE
                 → overall = mean(citation_accuracy, factual_accuracy, completeness, source_quality)  # 4 scored dims
               (Rationale: a plain mean lets fabrication — factual=0.0 — hide behind 3 good scores; the
                floor surfaces it. See .tad/templates/research-quality-rubric.md for anchors + decision tree.)
             → Append to findings file a "## Quality Rubric (Phase 4c)" section with: the 4 scored sub-scores,
               the efficiency advisory note, and the overall (with which aggregation branch fired).
             → Advisory verdict (overall < 0.6 → WARN; NEVER blocks — single-user CLI principle):
               IF overall < 0.6:
                 Report a WARN line + per-dim severity labels (advisory only, research still PROCEEDS):
                 - factual_accuracy or citation_accuracy low → "accuracy concern — verify before citing"
                 - completeness low → "coverage gap — consider re-ask"
                 - source_quality low → "weak sources — add primary"
                 The WARN is informational: findings PROCEED to Phase 4.5 regardless (it does NOT halt the flow).
               ELSE: note "Quality Rubric overall {score} — OK" and PROCEED.
             (This rubric step runs whenever 4c exits toward Phase 4.5 — on both the PASS path below and the
              FAIL-max-rounds exit. It never changes the PASS/FAIL gate; it only annotates + WARNs.)

           → Step 5: Pass/fail decision:
             Both ADEQUATE or STRONG → PASS
             Any INSUFFICIENT → FAIL

             On PASS:
               Report: "✅ Phase 4c challenge PASSED round {challenge_round} (Codex: {rating}, Gemini: {rating})"
               Read dimension-level findings from both reports even on PASS:
               Append to findings file: "## Advisory (Phase 4c Challenge Round {challenge_round})"
               For each model, append: "### {Model} flagged:\n{dimension findings summary}"
               → Run Step 4b Quality Rubric (if not already emitted this round) → Log to challenge-log.md
                 (Step 6) → Proceed to Phase 4.5 (e_5)

             On FAIL:
               Report: "⚠️ Phase 4c challenge round {challenge_round} FAILED"
               → Log to challenge-log.md (Step 6)
               If challenge_round >= MAX_CHALLENGE_ROUNDS (2):
                 → WARN user: "2 轮 challenge 后仍有未解决弱点："
                 → Display unresolved weaknesses from latest INSUFFICIENT report
                 → Append "## Unresolved Weaknesses (Phase 4c)" section to findings file
                 → Run Step 4b Quality Rubric on the latest reports (annotate + advisory WARN only)
                 → Proceed to Phase 4.5 (e_5) — do NOT halt
               Else (challenge_round < MAX_CHALLENGE_ROUNDS):
                 → Extract "需要补充研究的问题" sections from ALL INSUFFICIENT model reports
                 → Merge + deduplicate gap questions across models
                 → Report: "🔄 Extracted {N} gap questions. Running lightweight re-ask..."
                 → Lightweight re-ask loop (NOT full Phase 4 re-execution):
                   For each gap question:
                     ~/.tad-notebooklm-venv/bin/notebooklm ask "{gap_question}" -n <id>
                     (Raw CLI — NOT *research-notebook ask — avoids nested step3_5)
                     sleep 1
                   Append re-ask results to .tad/evidence/research/{slug}/{date}-ask-findings.md
                 → Return to PHASE 4c Step 2 (re-assemble with updated findings — skip Step 1 gate on re-entry)

           → Step 6: Log to challenge-log.md (called from both PASS and FAIL paths):
             Append: "Phase 4c round {challenge_round} | Codex: {rating} | Gemini: {rating} | Gaps: {key_gaps} | Led to re-ask: {yes/no}"

        e_5. PHASE 4.5 — Structured Paper Extraction (Elicit-style):
           Trigger: ONLY inside *research-plan (never standalone *research-notebook ask)
           → Step 1: Identify academic sources in current notebook
             → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <id>
             → Filter sources where url contains "arxiv.org" OR "scholar" OR ".edu" OR "acm.org" OR "ieee.org"
             → If 0 academic sources → skip Phase 4.5 entirely, proceed to Phase 5
           → Step 2: For each academic source (max 5 papers per research item):
             → Extract structured fields via raw CLI:
               ~/.tad-notebooklm-venv/bin/notebooklm ask \
                 "For the paper from {source_url}, extract in structured format:
                  1. Research Question (one sentence)
                  2. Methodology (one sentence)
                  3. Key Findings (list: finding + metric + value where available)
                  4. Stated Limitations (list)
                  5. Baselines Compared (list)
                  6. Publication Year (if identifiable from source URL or content)" \
                 -n <id>
               (Raw CLI call — NOT *research-notebook ask — intentional: avoids nested step3_5 loop.
                Note: --no-follow is a SKILL protocol flag parsed in Step 0 of *research-notebook ask;
                it is NOT a raw CLI flag and must NOT be passed to the binary here.)
             → sleep 1
           → Step 3: Save all extractions to
             .tad/evidence/research/{slug}/{date}-paper-extractions.md
             Format: one section per paper, structured fields as returned
           → Report: "📄 Extracted structured data from {N} academic papers → {path}"

        f. PHASE 5 — Extract Actionable Items (Research→AC Bridge):
           → Step 1: From all ask answers, extract engineering-actionable items
             → Format: "Based on {KR}, research shows: {finding} → Suggested AC: {concrete acceptance criterion}"
             → Example: "KR1 sesame recall: 担担面 → sesame paste mapping → AC: allergen-rules must contain dandan→sesame rule"

           → Step 1b (PHASE 5b — Adversarial Challenge: Action Recommendations):
             Trigger: After Step 1 extraction, BEFORE Step 2 display to user.
             ⚠️ User sees ACs with support_strength labels already attached — not approve-then-challenge.
             ⚠️ Phase 5b is SINGLE-PASS — no re-challenge loop. Unlike Phase 4c, INSUFFICIENT actions
             are labeled and shown to user, not re-researched. User decides what to do with weak ACs.
             Uses CHALLENGE_INSTRUCTION from Phase 0c (symmetric prompt for both models).

             → Gate: Effort-scaling gate (NOT_via_alex_auto constraint, now satisfied via DR-20260531 carve-out):
               The challenge runs iff `run_adversarial_challenge` (set + displayed + overridable in Phase 0class).
               If run_adversarial_challenge == off → skip to Step 2 (display ACs as-is, no labels).
               (No keystroke — the run/skip decision was displayed + made overridable in Phase 0class.)
               ⚠️ Uses cached codex_available / gemini_available from Phase 0c Step 2 (always run — safe even
                  when Phase 0c challenge was gated off — backend-architect P0-2).

             → Assemble payload:
               rm -f /tmp/tad-challenge-actions.md
               sed -n '/<!-- BEGIN actions -->/,/<!-- END actions -->/{ /<!-- BEGIN/d; /<!-- END/d; p; }' .tad/templates/research-challenge-prompt.md > /tmp/tad-challenge-actions.md
               printf '\n---\n## Extracted ACs\n' >> /tmp/tad-challenge-actions.md
               (Append the Step 1 extracted ACs list + their supporting research findings via printf)

             → Invoke models:
               Use cached preflight results.
               Codex: cat /tmp/tad-challenge-actions.md | codex exec --full-auto --skip-git-repo-check \
                 "$CHALLENGE_INSTRUCTION" 2>/dev/null
               Save to .tad/evidence/research/{slug}/challenge-actions-codex.md (exit code gate)
               Gemini: cat /tmp/tad-challenge-actions.md | gemini -p \
                 "$CHALLENGE_INSTRUCTION" 2>/dev/null
               Save to .tad/evidence/research/{slug}/challenge-actions-gemini.md (exit code gate)

             → Extract overall rating (same mechanism: head-5 grep → fallback → fail-closed):
               Overall rating per model: INSUFFICIENT / ADEQUATE / STRONG
               Handle UNAVAILABLE (NFR2): single-model degradation (inlined from Phase 0c).

             → Parse per-AC support_strength (Alex LLM judgment — NOT mechanical grep):
               The "actions" template produces a Markdown table with per-AC ratings.
               Alex reads BOTH model output tables and applies conservative merge:
               If both models rate an AC → use the MORE CONSERVATIVE rating
               If only one model available → use that model's rating
               UNSUPPORTED by either model → mark as UNSUPPORTED (conservative)

             → Apply labels:
               For each AC, attach support_strength label:
               STRONG → no special marker
               WEAK → "⚠️ WEAK — {model's reason summary}"
               UNSUPPORTED → "🚫 UNSUPPORTED — needs more research or downgrade to hypothesis"

             → Log to challenge-log.md:
               "Phase 5b | Codex: {rating} | Gemini: {rating} | STRONG: {N} | WEAK: {N} | UNSUPPORTED: {N}"

             → Proceed to Step 2 with labeled ACs

           → Step 2: Display extracted ACs to user (now with support_strength labels from Phase 5b if executed)
             → AskUserQuestion: "研究提取了 {N} 个可执行项。哪些要写入下一个 handoff 的 AC？"
               Options: "全部采纳" / "逐条确认" / "只保存，不写 AC"
           → Step 3: Write extracted items per user choice:
             → "全部采纳": write all to {date}-extracted-acs.md, M = N
             → "逐条确认": per-item AskUserQuestion, write only adopted items, M = adopted count
             → "只保存，不写 AC": write all to {date}-research-findings.md (not -acs.md), M = 0
             → In all cases: the saved file is READY TO REFERENCE in future handoff §9
           → Report: "✅ Research complete. {N} actionable items extracted, {M} adopted as future ACs."

    step5:
      name: "更新 OBJECTIVES 研究覆盖"
      action: |
        For each executed research item:
        → Read OBJECTIVES.md
        → Fill "Research needed" field under the corresponding Objective:
          "Research needed: ✅ Covered — see notebook '{topic}', report '{path}'"
        → If a KR's prerequisite research is now complete, note it:
          "Research done. Ready for implementation."

        Output: "✅ 研究计划执行完成。{N} 项研究已完成，OBJECTIVES.md 已更新。"

    step6:
      name: "Research → Action Bridge"
      trigger: "After step5 completes (OBJECTIVES updated)"
      action: |
        AskUserQuestion:
        question: "研究完成，发现已保存。基于这些发现，下一步是什么？"
        Options:
          - "这些发现需要实现 — 进入 *analyze 设计" → transition to adaptive_complexity_protocol
          - "添加到 NEXT.md 作为待办" → append summary to NEXT.md In Progress
          - "继续研究 — 还需要更多信息" → return to step4 (another ask round)
          - "保存到 project-knowledge" → write to .tad/project-knowledge/ appropriate category
          - "只保存，不做行动" → standby
      enters_standby: "After user picks option 5"
      note: "OBJECTIVES.md update already done in step5 — not offered as option here"

  enters_standby: "After step6 completes (option 5) → standby"

  constraints:
    - "每个 research item 执行前不再重复确认（step3 已整体确认）"
    - "如果某个 item 执行失败（auth/timeout）→ 跳过，在最终 summary 中标注失败"
    - "不自动创建 handoff（研究≠实现）— 研究结束后用户决定下一步"
    - "plan 中的 notebook 选择是 Alex LLM 判断，用户可在 step3 修改"

