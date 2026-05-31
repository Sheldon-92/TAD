---
name: research-notebook
description: TAD Research Notebook Manager — NotebookLM multi-source knowledge base for Alex *discuss and research workflows. 19 sub-commands for full research lifecycle management.
---

# /research-notebook Command (NotebookLM Integration)

## Overview

`*research-notebook` manages NotebookLM notebooks as persistent knowledge assets for TAD workflows.
Use for research-intensive topics requiring cross-source synthesis (YouTube + PDF + web).

**Key principle**: NotebookLM is a knowledge asset (stateful, persistent), not a stateless tool call.

**Primary use: Alex design/discuss phase.** Also usable standalone (without /alex) via CLAUDE.md §2 research routing — see "Standalone Usage" below.

---

## Standalone Usage (without /alex)

When invoked via CLAUDE.md research routing (without /alex active):
- Run preflight check (same as below)
- Use the same CLI commands (create / ask / source add-research)
- Skip Alex-specific protocols (Socratic, handoff, Gate, domain_pack_awareness)
- After research completes → soft suggestion of next steps (see below)
- When /alex IS active, Alex's own research protocols (research_notebook_awareness, research_plan_protocol) take precedence

### After Research Completes (Standalone)

Inform user: "研究完成。Findings saved to {path}."
Then suggest (non-blocking text, NOT AskUserQuestion):
"接下来你可以：用 /alex *analyze 进入设计 / 添加到 NEXT.md / 继续深入研究 / 保存到 project-knowledge。"

---

## Preflight Check (runs before every sub-command)

```yaml
preflight:
  venv_path: "~/.tad-notebooklm-venv"
  notebooklm_bin: "~/.tad-notebooklm-venv/bin/notebooklm"
  checks:
    - "notebooklm CLI available: test -x ~/.tad-notebooklm-venv/bin/notebooklm"
    - "Version check: ver=$(~/.tad-notebooklm-venv/bin/notebooklm --version | awk '{print $NF}'); printf '%s\\n0.3.4\\n' \"$ver\" | sort -V | head -1 | grep -qx '0.3.4'"
    - "Auth valid: ~/.tad-notebooklm-venv/bin/notebooklm auth check --test 2>&1 | grep -q 'authenticated'"
  on_fail_missing: "Output: '⚠️ NotebookLM not ready. Run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_fail_version: "Output: '⚠️ notebooklm-py < 0.3.4 has broken AI endpoints — re-run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_fail_auth: "Output: '⚠️ NotebookLM auth expired. Run: bash .tad/cross-model/setup-notebooklm.sh'"
  on_pass: "Proceed to sub-command"
  invocation_pattern: "~/.tad-notebooklm-venv/bin/notebooklm <subcommand>"
```

> Note: All `notebooklm` CLI invocations use the absolute path `~/.tad-notebooklm-venv/bin/notebooklm`
> (not `notebooklm` bare) to avoid PATH/venv activation dependency. The binary lives in the
> venv created by setup-notebooklm.sh at `~/.tad-notebooklm-venv/`.

---

## Commands

### `*research-notebook create <topic>`

Create a new notebook, add initial sources, register to REGISTRY.

```
Step 1: Create NotebookLM notebook
  → ~/.tad-notebooklm-venv/bin/notebooklm create "<topic>"
  → Capture notebook_id from output

Step 2: Guide source addition (AskUserQuestion)
  → "What sources would you like to add?"
  Options:
    - "I'll provide URL list"
    - "Search for conference/official YouTube videos on this topic"
    - "Both"
    - "Add later"

Step 3: If user selects YouTube search:
  → WebSearch: "{topic} conference talk OR official channel 2026 site:youtube.com"
  → Display video list (title + URL)
  → User selects which to add
  → ~/.tad-notebooklm-venv/bin/notebooklm source add <url>  (one by one)

Step 4: If user provides URL list:
  → For each URL: ~/.tad-notebooklm-venv/bin/notebooklm source add <url>
  → Report success/failure per URL

Step 5: Register to REGISTRY
  → Update .tad/research-notebooks/REGISTRY.yaml
  → Record: notebook_id, topic, source_count, sources list, created date, status=active

Step 6: Confirm
  → "✅ Notebook '{topic}' created, {N} sources added.
     Query with: *research-notebook ask 'your question'"
```

---

### `*research-notebook add <url> [--notebook <id>]`

Add a source to the active (or specified) notebook.

```
Step 1: Resolve target notebook
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook field

Step 2: Check source limit
  → Read source_count from REGISTRY
  → If source_count >= max_sources_per_notebook (config-workflow.yaml):
    → "⚠️ Notebook at source limit ({max}). Run *research-notebook curate first."
    → Exit

Step 3: Add source
  → ~/.tad-notebooklm-venv/bin/notebooklm use <notebook_id>
  → ~/.tad-notebooklm-venv/bin/notebooklm source add <url>
  → Capture success/failure

Step 4: Update REGISTRY
  → Append source entry (url, type, added date, title if detectable)
  → Increment source_count
  → Output: "✅ Source added. Total: {N} sources."
```

---

### `*research-notebook add-smart <url> [--notebook <id>]`

Import a source with automatic type detection and preprocessing. Handles X/Twitter threads,
Bilibili videos, academic papers, paywalled articles (Substack/Medium), and generic web content.
Uses `.tad/cross-model/source-preprocessor.sh` for URL routing and handler dispatch.

```
Step 1: Resolve target notebook (same as `add`)
  → If --notebook <id> specified → use that
  → Else read .tad/research-notebooks/REGISTRY.yaml active_notebook field
  → If no active notebook → AskUserQuestion: "Which notebook to import into?"
    Options: list of active notebooks + "Cancel"

Step 2: Validate + detect URL type
  → Validate: echo '<url>' | bash .tad/cross-model/source-preprocessor.sh validate
    If exit 1 → "❌ Invalid URL: contains unsafe characters or missing http(s)://" + EXIT
  → Detect: url_type=$(echo '<url>' | bash .tad/cross-model/source-preprocessor.sh detect)
  → Set output_dir: .research/preprocessed/<notebook_id>/
    mkdir -p "$output_dir"

Step 3: Capture existing source IDs before import (BA-P0-1 fix)
  → ids_before=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id> | jq -r '.[].id' | sort)

Step 4: Dispatch handler + import based on url_type

  [Direct path — proven arXiv PDF, no preprocessing]
  If url_type == "arxiv_pdf":
    → ~/.tad-notebooklm-venv/bin/notebooklm source add <url> -n <notebook_id>
    → handler_label="arxiv-direct"

  [Handler paths — preprocessing → local .md or remote URL → source add]
  If url_type in [x_article, x_tweet, bilibili, arxiv_abs, scholar, substack, medium]:
    → result=$(bash .tad/cross-model/source-preprocessor.sh dispatch <url> <notebook_id> <output_dir>)
    → dispatch_exit=$?
    → If dispatch_exit == 2: "❌ Missing dependency: {stderr}" + EXIT
    → If dispatch_exit == 1: "⚠️ Extraction failed. {stderr}" + EXIT
    → If dispatch_exit == 10: source add <result> -n <notebook_id>   [result = remote URL]
    → If dispatch_exit == 0:  source add <result> -n <notebook_id>   [result = local .md path]
    → Else (exit $dispatch_exit, e.g., 124=timeout / 127=missing-tool):
      "❌ Handler dispatch failed (exit $dispatch_exit). Install coreutils or check stderr." + EXIT
    → handler_label="$url_type"

  [Generic web path — try direct first, Jina fallback triggered by quality failure in Step 6]
  If url_type == "generic_web":
    → ~/.tad-notebooklm-venv/bin/notebooklm source add <url> -n <notebook_id>
    → handler_label="generic-direct"
    → Note: if verify_import_quality returns FAIL → Jina fallback runs inside Step 6

Step 5: Identify new source_id via set-difference (BA-P0-1 fix — avoids unreliable .[-1])
  → ids_after=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id> | jq -r '.[].id' | sort)
  → new_source_id=$(comm -13 <(echo "$ids_before") <(echo "$ids_after") | head -1)
  → If new_source_id is empty → "❌ Could not identify newly-added source id. Source may still be importing." + EXIT
  → Capture: source_title=$(notebooklm source list --json -n <notebook_id> | jq -r --arg id "$new_source_id" '.[] | select(.id == $id) | .title // "unknown"')

Step 6: verify_import_quality passing new_source_id (see [HELPER] below)
  → Wait 30s for NotebookLM indexing
  → Run structured quality probe on new_source_id (not .[-1])
  → On PASS: "✅ Source '{title}' imported with good content quality."
  → On WARN: "⚠️ Source '{title}' has mixed quality. Content may include navigation noise."
  → On FAIL (QUALITY:NONE or status=="error"):
     a. Delete bad source (guard against failure — BA-P1-1 fix):
        del_exit=0
        ~/.tad-notebooklm-venv/bin/notebooklm source delete "$new_source_id" -n <notebook_id> --yes || del_exit=$?
        If del_exit != 0: "⚠️ Could not delete bad source (id=$new_source_id, exit=$del_exit). Stopping to avoid duplicates." + EXIT
     b. If url_type == "generic_web":
        → Jina fallback: jina_result=$(bash .tad/cross-model/handlers/jina-handler.sh <url> <output_dir>)
        → If jina exit 0: source add "$jina_result" -n <notebook_id> → re-run verify_import_quality
        → If Jina also fails: "⚠️ Could not import useful content from this URL." + EXIT
     c. If url_type != "generic_web": "⚠️ Handler content failed quality check." + EXIT

Step 7: Update REGISTRY + metadata
  → Update REGISTRY.yaml: increment source_count, append source entry (url, type, added date)
  → Update .research/preprocessed/<notebook_id>/metadata.yaml:
    BA-P1-2 fix — schema + append protocol:
    File schema (top-level `entries` list, YAML-valid):
      # metadata.yaml
      entries:
        - file: "x-article-12345.md"       # path relative to output_dir, or null for URL-direct
          original_url: "https://..."
          handler: "x_article"
          extracted_at: "2026-05-09T12:00:00Z"
          source_id: "<NotebookLM source UUID from Step 5>"
          quality_verified: true
    Create if absent: write header `entries:\n` to new file.
    Append entry: yq -i '.entries += [{"file": "...", "original_url": "...", "handler": "...", "extracted_at": "...", "source_id": "...", "quality_verified": true}]' metadata.yaml
    Concurrency: v1 assumes single-writer — document as v1 constraint.
    Recover: metadata.yaml is an audit log; if lost, rebuild from `notebooklm source list` + dir scan.

Step 8: Report result
  → "✅ Imported via {handler_label}: '{source_title}'"
  → Quality: HIGH / LOW (WARN) / UNKNOWN
  → If preprocessed .md was saved: "📄 Cached: {out_file}"
```

[HELPER] verify_import_quality procedure:
Caller passes: notebook_id + source_id (from set-diff in Step 5 — do NOT use .[-1])
```
verify_import_quality(notebook_id, source_id):

  1. sleep 30                                   [Wait 30s — NotebookLM indexing takes ~30s]

  2. Fetch source record by source_id:
     source_json=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id>)
     source_record=$(echo "$source_json" | jq --arg id "$source_id" '.[] | select(.id == $id)')
     source_title=$(echo "$source_record" | jq -r '.title // "unknown"')
     source_status=$(echo "$source_record" | jq -r '.status')

  2b. BA-P1-3 fix — retry if status is "preparing" or "processing" (indexing can take up to ~90s):
     If source_status in ["preparing", "processing"]:
       sleep 60                                 [second wait, total 90s]
       Re-fetch source_record + source_status (same jq query above)
     If still preparing/processing after retry:
       → return WARN "Source still indexing — re-verify later via *ask"

  3. If source_status == "error" → return FAIL immediately (no probe needed)

  4. If source_status == "ready":

     4a. Structural pre-check — skip LLM if content too short (< 500 chars):
         content_len=$(echo "$source_record" | jq -r '.content_length // .char_count // ""' 2>/dev/null || true)
         If content_len is a non-empty integer AND content_len < 500:
           → return FAIL "content too short (<500 chars) — stub or error page (no LLM call needed)"
         (If content_len field absent from source record → skip pre-check, proceed to 4b)

     4b. LLM probe (force fresh conversation for reliable response):
       response=$(~/.tad-notebooklm-venv/bin/notebooklm ask \
         "Rate the content quality of the most recently added source titled '${source_title}'.
          Respond with ONLY one of these exact labels:
          QUALITY:HIGH — contains substantive article/paper/video text with ≥3 substantive paragraphs
          QUALITY:LOW — contains some useful paragraphs but heavily mixed with navigation noise
          QUALITY:NONE — if content consists PRIMARILY of: navigation menus, sidebar links, footer
            elements, table-of-contents listings without article body text, cookie/privacy banners,
            login/paywall prompts, or fewer than 3 substantive paragraphs of actual content" \
         -n <notebook_id> -c 00000000-0000-0000-0000-000000000000)

     Parse first line of response:
       If starts with "QUALITY:NONE" → return FAIL
       If starts with "QUALITY:LOW"  → return WARN (keep source)
       If starts with "QUALITY:HIGH" → return PASS
       If no QUALITY: prefix found   → return WARN (probe inconclusive — keep source)
```

---

### `*research-notebook ask <question> [--notebook <id>] [--no-follow]`

Query a notebook (cross-source reasoning). By default, triggers dynamic multi-round research (step3_5).
Pass `--no-follow` to preserve single Q→A behavior (no auto follow-up).

```
Step 0: Parse flags
  → If --no-follow in args: set dynamic_follow = false; remove --no-follow before passing to CLI
  → Else: set dynamic_follow = true (default — dynamic protocol runs after answer)

Step 1: Resolve target notebook
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook field
  → If no active notebook → AskUserQuestion: "Which notebook to query?"
    Options: list of active notebooks + "Create new"

Step 2: Activate notebook
  → ~/.tad-notebooklm-venv/bin/notebooklm use <notebook_id>

Step 2b (NEW): Auto-refresh stale sources (with latency cap)
  Field location: `last_refreshed` lives in .tad/research-notebooks/REGISTRY.yaml,
                  per-notebook entry (sibling to last_queried and status fields).
                  (last_refreshed tracks SOURCE REFRESH events; last_queried tracks ASK events — distinct)

  Guard: Check .tad/research-notebooks/REGISTRY.yaml for this notebook's last_refreshed field.
         If last_refreshed is set AND was updated < 24h ago → SKIP entire Step 2b.
         If last_refreshed field is ABSENT → treat as "needs refresh" (bootstrap path for new notebooks).

  If guard passes (refresh needed):
  → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id>
  → Filter: only sources where type == "SourceType.WEB_PAGE"
  → Cap: check at most 10 sources, refresh at most 5 stale ones
  → Wall-clock timeout: record start_ts=$(date +%s) before loop
    abort loop when $(($(date +%s) - start_ts)) -ge 30 (30s ceiling)
  → Wrap each CLI call with `timeout 10` to protect against hung subprocess:
    if timeout 10 ~/.tad-notebooklm-venv/bin/notebooklm source stale <source_id> -n <notebook_id>; then
      timeout 10 ~/.tad-notebooklm-venv/bin/notebooklm source refresh <source_id> -n <notebook_id>
    fi
    (timeout 10: exit 124 on hang → treat as failure → continue loop)
  → On any CLI failure or timeout → skip silently, proceed to ask
  → After refresh loop completes: update last_refreshed in .tad/research-notebooks/REGISTRY.yaml:
      yq -i '(.notebooks[] | select(.id == "<notebook_id>") | .last_refreshed) = "<YYYY-MM-DD>"' \
        .tad/research-notebooks/REGISTRY.yaml
    Fallback if yq unavailable: skip the write and log "last_refreshed not updated (yq absent)"

Step 2.5 (NEW): Source targeting (optional)
  → If user specifies --source <id>:
    → Build source flags: --source <id1> [--source <id2> ...]
    → Display: "🎯 Querying specific sources: {source_titles}"
  → If no --source: query all sources (existing behavior)

Step 3: Execute query (stale conversation fallback)
  Note: --save-as-note flag is CALLER'S RESPONSIBILITY (Alex decides when to use).
        Research-notebook SKILL supports the flag but does NOT auto-add it.
        Use --no-save to suppress auto-save in privacy-sensitive contexts.
  Layer 1 (normal):
    → ~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" {source_flags} {save_flags}
      where {source_flags} = "--source <id>" if Step 2.5 specified, else empty
      where {save_flags} = "--save-as-note --note-title 'TAD Research: {first 40 chars of question}'" if caller passed --save-as-note
                         = "" if --no-save passed or no flag
    → If exit 0 and output non-empty → proceed to Step 4
    → If exit != 0:
  Layer 2 (force fresh conversation — retry on any non-zero exit):
    → ~/.tad-notebooklm-venv/bin/notebooklm ask "<question>" {source_flags} {save_flags} -c 00000000-0000-0000-0000-000000000000
    → If exit 0 → proceed to Step 4
    → If still fails: "⚠️ Query failed. Check auth or notebook state."
  (Note: --new flag does NOT exist in 0.3.4; -c 00000000... is the only fresh-conversation mechanism)

Step 3.5: Dynamic Follow-up Protocol (skip entirely if dynamic_follow == false)
  ─────────────────────────────────────────────────────────────────────────────
  TRIGGER: Every ask where dynamic_follow == true (default)
  MAX DEPTH: max_depth = 4 rounds total (including initial ask in Step 3)
  TRACK: current_depth = 1 (after Step 3); new_citations_this_round; prev_zero_citation_rounds = 0;
         strategies_used: [] (append strategy name each round — for tunnel detection)

  EXTRACT four dimensions from the Step 3 answer:
    surprising:  "最令人惊讶的 1 个发现（与常识/预期不同的）"
    gap:         "答案暗示了什么未被覆盖的领域 ('sources do not contain' signals)"
    conflict:    "不同源之间是否有矛盾 ('Source A says X, but Source B says Y')"
    actionable:  "是否有可以直接转化为决策/代码变更的信息"

  COUNT new citations (saturation signal):
    extract all [N] markers from current answer → count unique markers not seen in prior rounds
    new_citations = count of unique [N] markers not previously seen

  CHAIN STORAGE — incremental writes (compact-safe):
    Path: .tad/evidence/research/{notebook_topic}/{date}-chain-{topic_slug}-{uid}.md
    {notebook_topic}: read from .tad/research-notebooks/REGISTRY.yaml → this notebook's topic field
    {topic_slug}: first 30 chars of seed question, alphanum+hyphens only, lowercase
      (CJK stripped by alphanum filter — if slug ≤4 chars after filter, use "q" prefix e.g. "q-ab12")
    {uid}: first 4 hex chars of md5(seed_question_full_text); prevents same-day same-slug collision
      bash: uid=$(printf '%s' "$seed_question" | { md5 2>/dev/null || md5sum 2>/dev/null; } | cut -c1-4)
    Collision guard: if file exists at chain init AND first line does NOT match same seed_question,
      append "-2" suffix (then "-3" etc.) until a free path is found.
    Append each completed round immediately after it finishes (do NOT batch-write at chain end)
    Saturation state in each round's Analysis block: include `new_citations: N` and `prev_zero_streak: N`
      so compact-recovery can rebuild counter by reading the last round's Analysis block.
    File format (frontmatter + round blocks per §4.3 of HANDOFF-20260509-dynamic-research-strategies):
      --- type: research-chain, notebook_id, seed_question, depth, strategies_used, total_citations, created_at,
          seed_origin: original | dynamic, dynamic_index: N (0-based for dynamic seeds; omit for original) ---
      ## Seed Question / ## Round N — {strategy} / ### Analysis (surprising, strategy chosen, new_citations: N, prev_zero_streak: N)
      ## Chain Summary (key finding + action items + sources cited)
    Compact recovery for dynamic_seeds_added: count chain files with `seed_origin: dynamic` in current Phase 4 output dir.
      bash: dynamic_seeds_added=$(grep -rl 'seed_origin: dynamic' .tad/evidence/research/ | wc -l | tr -d ' ')

  STRATEGY SELECTION (priority order — 6 strategies):
    1. saturated (hard stop — evidence-based)
    2. contradiction (cross-source conflict resolution)
    3. follow_thread (chase surprising findings)
    4. perspective_shift (break tunnel vision — NEW)
    5. gap_enrichment (standalone only, NOT inside *research-plan)
    6. so_what (budget-forced close, TERMINAL)

    # 1. Hard stop — checked FIRST (evidence-based: nothing new to find)
    IF new_citations == 0 AND prev_zero_citation_rounds >= 1:  [saturated: 0 new citations × 2 consecutive rounds]
      → strategy = "saturated"
      → Finalize chain .md. Report: "🔬 Saturated after {current_depth} rounds. Chain saved to {path}"
      → EXIT step 3.5 → go to Step 4.

    # 2. Highest-value: cross-source conflict resolution
    ELIF conflict detected:
      → strategy = "contradiction"
      → Build self-contained follow-up (embed claims as quotes — NEVER use "你提到..." referential phrasing):
        "关于'{topic}'，一些源认为'{claim_A}'，而另一些源认为'{claim_B}'。
         基于你的所有源，哪个说法有更强的证据支撑？请引用具体段落并解释矛盾的原因。"
      → Execute: ~/.tad-notebooklm-venv/bin/notebooklm ask "{follow_up}" -n <notebook_id>
        USE -n flag only. DO NOT use -c 00000000... fresh conversation (follow-ups need prior context).
        If ask fails: fail-fast. Save chain as-is. Do NOT retry. Exit step 3.5.
      → Count new citations in follow-up answer; update saturation counter:
          If new_citations == 0: prev_zero_citation_rounds += 1; else: prev_zero_citation_rounds = 0
      → Append "contradiction" to strategies_used
      → sleep 1; increment current_depth; append round to chain .md; loop back to step 3.5.

    # 3. Chase surprising findings deeper
    ELIF surprising finding AND current_depth < max_depth:
      → strategy = "follow_thread"
      → Build self-contained follow-up (embed the finding as quoted context):
        "关于'{surprising_finding}'（来自关于'{topic}'的研究），这具体是怎么实现的？
         有哪些已知的局限或失败案例？请从你的源中找到具体例子。"
      → Execute follow-up ask (same -n flag rule and fail-fast rule as contradiction above)
      → Count new citations; update saturation counter:
          If new_citations == 0: prev_zero_citation_rounds += 1; else: prev_zero_citation_rounds = 0
      → Append "follow_thread" to strategies_used
      → sleep 1; increment current_depth; append round to chain .md; loop back to step 3.5.

    # 4. Perspective shift — break tunnel vision when same strategy repeats
    # Requires ≥2 prior strategy entries (current_depth >= 3, strategies_used has ≥2 elements)
    ELIF current_depth >= 3 AND current_depth < max_depth
         AND len(strategies_used) >= 2
         AND strategies_used[-1] == strategies_used[-2]  [last 2 rounds used same strategy]
         AND strategies_used[-1] != "perspective_shift"  [prevents consecutive perspective_shifts]
         AND NOT conflict AND NOT gap:
      → strategy = "perspective_shift"
      → Derive expert perspectives from project context (3-tier fallback):
          Tier 1 — If OBJECTIVES.md exists:
            Extract stakeholder roles implied by KR descriptions
            e.g. KR about "user retention" → perspective_role="PM", perspective_focus="retention, onboarding, churn signals"
            e.g. KR about "cold-start latency <2s" → perspective_role="SRE", perspective_focus="latency, reliability, observability"
          Tier 2 — Elif .tad/domains/ has loaded packs:
            Use reviewer persona from the most relevant Domain Pack
          Tier 3 — Else use 3 generic perspectives:
            - engineer → perspective_focus="implementation feasibility, technical debt, performance"
            - end-user → perspective_focus="usability, onboarding friction, error recovery"
            - skeptic → perspective_focus="assumptions being made, missing counter-evidence, claims without data"
      → Select the perspective LEAST represented in strategies_used (favor unexplored angle)
      → Build self-contained follow-up (embed perspective identity in question):
        "作为一个{perspective_role}（关注{perspective_focus}），关于'{topic}'，
         我最关心的问题是什么？现有发现中哪些对{perspective_role}最重要，哪些被忽略了？"
      → Execute: ~/.tad-notebooklm-venv/bin/notebooklm ask "{follow_up}" -n <notebook_id>
        (same -n flag rule and fail-fast rule as contradiction above — raw CLI, not *research-notebook ask)
      → Count new citations; update saturation counter:
          If new_citations == 0: prev_zero_citation_rounds += 1; else: prev_zero_citation_rounds = 0
      → Append "perspective_shift" to strategies_used
      → sleep 1; increment current_depth; append round to chain .md; loop back to step 3.5.

    # 5. Gap enrichment — standalone only (NOT inside *research-plan Phase 4)
    ELIF gap detected AND NOT inside_research_plan:
      → strategy = "gap_enrichment"
      → inside_research_plan detection (two conditions BOTH required):
          (a) .research/research-state.yaml exists AND phase field == "ask"
          (b) the current notebook_id appears in research-state.yaml's notebook_ids list
        If either condition false → inside_research_plan = false (standalone ask context)
      → Trigger Phase 4b CRAG Judge Loop (source add-research fast → re-ask)
      → (gap_enrichment DISABLED inside *research-plan — Phase 4b already handles gaps; would double-loop)

    # 6. Budget-based forced close — checked AFTER saturation
    ELIF current_depth >= max_depth:
      → strategy = "so_what"  [TERMINAL — always exits after one so-what round, never loops back]
      → Read project_context (capped at ~600 chars total):
          If OBJECTIVES.md exists: extract KR bullet descriptions only (max 200 chars/KR, max 3 KRs, skip ✅)
          Elif PROJECT_CONTEXT.md exists: extract "## Current Goal" section only (max 500 chars)
          Else: use the notebook topic string (always ≤ 100 chars)
      → Build self-contained so-what question:
        "基于到目前为止关于'{topic}'的所有发现，对于{project_context}，
         最重要的 3 个行动建议是什么？每个建议请对应具体的源引用。"
      → Execute so-what ask (same -n flag rule)
      → DO NOT loop back. so_what is ALWAYS terminal. Append final round. Finalize chain .md.
      → Report: "🔬 Research chain complete: {current_depth} rounds, strategies used: {list}. Chain saved to {path}"
      → EXIT step 3.5 → go to Step 4.

    ELSE:
      → strategy = "continue" (no auto-follow-up; chain may be partial; user can manually ask next)
      → EXIT step 3.5 → go to Step 4.
  ─────────────────────────────────────────────────────────────────────────────

Step 4: Return results
  → Output query result to user
  → Update REGISTRY.yaml: last_queried = today, status = active
    (if was dormant → auto-transition back to active; archived → warn user first)

Note: If called from Alex *discuss context → result feeds directly into discussion.
If called from research_decision_protocol step2_5 → result supplements WebSearch findings.

Status transition rules:
  → If notebook status == "archived": AskUserQuestion "This notebook is archived. Query anyway?" before proceeding
  → If notebook status == "dormant": query succeeds → set status = active (last_queried update implies reactivation)
  → If notebook status == "active": normal path, no status change needed
```

---

### `*research-notebook list`

List all registered notebooks + status + source count. Runs lightweight sync.

```
Step 1: Read REGISTRY.yaml

Step 2: Lightweight sync (single cloud call — do NOT call per notebook)
  → cloud_json=$(~/.tad-notebooklm-venv/bin/notebooklm list --json)
  → For each REGISTRY active/dormant notebook:
    → Check membership: echo "$cloud_json" | jq -e --arg id "$notebook_id" '.notebooks[] | select(.id == $id)' >/dev/null
    → If not found (jq exit 1) → mark with ⚠️ "cloud-deleted"
  (cloud_json schema: {"notebooks": [{"id": "<uuid>", "title": "...", ...}]})

Step 3: Apply lifecycle rules (from config-workflow.yaml research_notebook section)
  → active: last_queried within dormant_after_days → show normally
  → dormant: last_queried between dormant_after_days and archive_suggest_after_days
    → show with 💤 badge + "consider curate or archive"
  → archived: show with 📦 badge (collapsed)

Step 4: Output table
  | Notebook | Status | Sources | Last Queried | Notes |
  |----------|--------|---------|--------------|-------|
  | {topic}  | ✅/💤/📦 | {N}  | {date}       | {flags} |
```

---

### `*research-notebook sync`

Full sync: compare REGISTRY with NotebookLM cloud state.

```
Step 1: Read REGISTRY.yaml (all active/dormant notebooks)

Step 2: Single cloud call to get all notebooks
  → ~/.tad-notebooklm-venv/bin/notebooklm list --json
  → Compare each REGISTRY notebook: source count, existence

Step 3: Classify discrepancies
  → Local only (cloud deleted) → ⚠️ "REGISTRY outdated"
  → Source count mismatch (web UI edits) → ⚠️ "sources changed"
  → Consistent → ✅

Step 4: Present sync report + AskUserQuestion
  Options:
    - "Update REGISTRY to match cloud"
    - "Keep local state"
    - "Confirm each discrepancy individually"

Step 5: Apply user choice → update REGISTRY.yaml
```

---

### `*research-notebook curate [--notebook <id>]`

Audit and maintain source quality for a notebook.

```
Step 1: Read REGISTRY.yaml sources for target notebook

Step 1b: Auto-clean error sources (NEW — fully automatic)
  → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id>
  → Parse JSON: each source object has an `id` field (server-side UUID string).
    Filter sources where `status` field contains "error" (explicit error state only).
    Do NOT delete sources with status "preparing" or "processing" — these may complete successfully.
  → Step A — Collect error IDs (single Bash call):
    error_ids=$(~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id> | \
      jq -r '.[] | select(.status | test("error")) | .id')
  → Step B — Parallel delete (single Bash call):
    echo "$error_ids" | xargs -P5 -n1 sh -c '
      ~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <notebook_id> --yes 2>&1 | \
        grep -q "error\|429" && echo "FAIL:$1" || echo "OK:$1"
      sleep 0.2
    ' _
  → If any FAIL: lines in output: "⚠️ {N} deletes failed — consider reducing to -P3 or -P1"
  → Report: "🧹 Cleaned {N} error sources ({M} remaining)"
  → If N == 0: "✅ No error sources found"
  → ⚠️ DEFENSIVE: If `source list --json` output structure is unexpected (no `id` field,
    different JSON shape), STOP and report: "source list JSON format changed — manual curate needed"

Step 1c: Auto-deduplicate (NEW — fully automatic)
  → From remaining sources, group by (lowercase(title), extract_domain(url))
  → extract_domain: parse URL to domain only (e.g., "arxiv.org", "developer.apple.com")
    → Sources without URL (type=text/file) → skip dedup (unique by definition)
  → For each group with count > 1: keep FIRST source (by add date), collect rest as dedup_ids
  → Parallel delete (single Bash call):
    echo "$dedup_ids" | xargs -P5 -n1 sh -c '
      ~/.tad-notebooklm-venv/bin/notebooklm source delete "$1" -n <notebook_id> --yes 2>&1 | \
        grep -q "error\|429" && echo "FAIL:$1" || echo "OK:$1"
      sleep 0.2
    ' _
  → If any FAIL: lines in output: "⚠️ {N} deletes failed — consider reducing to -P3 or -P1"
  → Report: "🔄 Removed {N} duplicates ({M} unique sources remain)"
  → If N == 0: "✅ No duplicates found"

Step 2: Check each source (age-based staleness)
  → Added >90 days ago (source_stale_after_days) → ⚠️ possibly stale
  → URL unreachable (if WebFetch available) → ❌ broken
  → Same type >5 sources → suggest pruning (quality > quantity)

Step 2b (content-staleness check — URL-type sources only):
  → For each URL-type source (skip type=youtube/text/file; max 20 to avoid slowness):
    → ~/.tad-notebooklm-venv/bin/notebooklm source stale <source_id> -n <notebook_id>
    → ⚠️ INVERTED exit codes (shell `if` compatible):
      exit 0 = stale (content changed at source URL)
      exit 1 = fresh (no change)
  → Display combined age + content staleness:
    | Source | Age-Stale | Content-Stale | Action |
    | {title} | 🟢/🔴 (>90 days) | 🟢/🔴 (CLI check) | — / "Refresh?" |

Step 2c (refresh stale sources — URL-type only):
  → If content-stale URL sources found:
    → AskUserQuestion: "Found {N} content-stale sources. Refresh?"
      Options:
        - "Refresh all content-stale" → ~/.tad-notebooklm-venv/bin/notebooklm source refresh <source_id> -n <id> for each
          (Note: refresh only works for URL/Drive sources, not YouTube/text/file types)
        - "Skip, review manually" → continue
        - "Skip all refreshes" → continue

Step 3: Output curation report with quality tier
  Tier classification rules (by URL pattern):
    tier1_patterns: [".gov", ".edu", "arxiv.org", "pubmed", ".who.int", "fda.gov",
                     "developer.apple.com", "developers.google.com", "docs.anthropic.com",
                     "owasp.org", "w3.org", "ietf.org"]
    tier2_patterns: ["medium.com", "dev.to", "stackoverflow.com", "docs.*", "blog.*",
                     ".readthedocs.io", "github.com/*/wiki"]
    tier3_patterns: ["reddit.com", "x.com", "twitter.com", "forum.*", "community.*",
                     "news.ycombinator.com"]
    unknown: everything else → ❓
  Tier values: 🏛️ T1 (official/academic) / 📰 T2 (industry) / 💬 T3 (community) / ❓ Unknown
  | # | Source | Type | Tier | Added | Age-Stale | Content-Stale | Suggestion |
  |---|--------|------|------|-------|-----------|---------------|------------|

Step 4: AskUserQuestion (for removal suggestions)
  Options:
    - "Apply all removal suggestions"
    - "Decide each manually"
    - "Skip, no changes"

Step 5: Execute confirmed removals
  → ~/.tad-notebooklm-venv/bin/notebooklm source delete <source_id> -n <notebook_id> --yes
  → Update REGISTRY.yaml source list + source_count
```

---

### `*research-notebook archive [--notebook <id>]`

Archive a notebook: export history → update registry → mark archived.

```
Step 1: Confirm with user (AskUserQuestion)
  → "Archive notebook '{topic}'? It will remain in NotebookLM but marked archived in REGISTRY."
  Options: "Yes, archive" / "Cancel"

Step 2: Ensure archive directory exists
  → mkdir -p .tad/research-notebooks/archived/

Step 3: Export query history (if any recorded in REGISTRY)
  → Write to .tad/research-notebooks/archived/{notebook_id}-history.md
  → If Write fails → ABORT (do NOT proceed to Step 4); report error to user

Step 4: Update REGISTRY.yaml (only after Step 3 succeeds)
  → Set status: archived
  → Record archived_date
  → If active_notebook == this notebook_id → clear active_notebook field (set to null)

Step 5: Confirm
  → "📦 Notebook '{topic}' archived. REGISTRY updated."
```

---

### `*research-notebook use <notebook_id>`

Set active notebook for this session (session-scoped override).

```
Step 1: Verify notebook_id exists in REGISTRY.yaml
  → If not found → "⚠️ Notebook not found. Run *research-notebook list to see available."

Step 2: Update REGISTRY.yaml active_notebook field

Step 3: Confirm
  → "✅ Active notebook set to '{topic}' ({notebook_id})"
```

---

### `*research-notebook research <topic> [--mode fast|deep]`

High-level command: automated source discovery + import + summary in one step.

```
Step 0: Resolve target notebook
  → If --notebook <id> specified → use that
  → Else read REGISTRY.yaml active_notebook
  → If no active notebook → AskUserQuestion: "Which notebook?"
    Options: list of active notebooks + "Create new notebook for '{topic}'"

Step 1: Mode selection
  → If --mode fast explicitly specified by user → skip AskUserQuestion, proceed directly
  → If --mode deep explicitly specified by user:
    → AskUserQuestion confirmation:
      "Deep mode 将搜索 50+ 源并永久导入 (~3-4min)。确认？"
      Options: "确认 Deep" / "改用 Fast" / "Cancel"
  → If no --mode specified → AskUserQuestion:
    "即将让 NotebookLM 搜索 '{topic}' 并自动导入源。"
    Options: "Fast (10 sources, ~1s)" / "Deep (50+ sources, ~3-4min)" / "Cancel"

Step 2: Execute
  → If fast mode:
    → ~/.tad-notebooklm-venv/bin/notebooklm source add-research "{topic}" --mode fast --import-all -n <id>
  → If deep mode:
    → ~/.tad-notebooklm-venv/bin/notebooklm source add-research "{topic}" --mode deep --no-wait -n <id>
    → ~/.tad-notebooklm-venv/bin/notebooklm research wait -n <id> --timeout 600 --import-all
    → (--timeout 600: native CLI flag, max 10min. --import-all: required to import sources after wait)
    → If exit != 0 (including timeout): "⚠️ Deep research timed out or failed. Sources may be partially imported. Check: *research-notebook list" + EXIT
  → Capture output (source count + titles)
  → ⚠️ ERROR HANDLING:
    - If exit code != 0 (non-timeout): "❌ Research failed: {stderr}" + EXIT (do NOT proceed to Step 3)
    - If source_count == 0: "⚠️ No sources found for '{topic}'. Try broader keywords." + EXIT

Step 3: Summary
  → ~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id>
  → Display: "✅ {N} sources added. Notebook summary: {summary}"
  → Display: "Suggested topics to explore: {topics}"

Step 4: Post-research source review (deep mode only)
  → If --mode deep AND source_count > 20:
    → ~/.tad-notebooklm-venv/bin/notebooklm source list -n <id>
    → AskUserQuestion: "Deep research 添加了 {N} 个源。要现在清理不相关的源吗？"
      Options:
        - "查看并清理" → display source titles, user picks which to delete
          → For each selected: ~/.tad-notebooklm-venv/bin/notebooklm source delete <source_id> -n <id> --yes
        - "全部保留" → continue
        - "稍后用 *research-notebook curate 清理" → continue
  → If fast mode: skip (10 sources, low cleanup urgency)

Step 5: Update REGISTRY
  → Update source_count (after any deletions), last_queried, status=active
```

---

### Source Strategy Note (GitHub-First)

When building a notebook for a new topic, source quality matters more than quantity.
Preferred order:
1. GitHub awesome-lists (`source add "https://github.com/org/awesome-topic"`)
2. GitHub sub-pages from awesome-lists (explore with `gh api` tree, add key .md files)
3. Real company repos (how production systems actually do it)
4. Tool repos (official source, not blog posts about the tool)
5. `source add-research --mode deep` (LAST RESORT for gaps only)

10 curated GitHub repos > 350 deep research articles.

---

### `*research-notebook report <description>`

Generate a structured report + download as local markdown.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Validate download capability (first-time only per session)
  → If preflight version check passed (0.3.4+), `download report` is available — proceed directly
  → Preflight already ensures CLI capability; no additional check needed
  → Cache validation result: skip this step entirely on subsequent *report calls in same session
  (Note: `download report` ships in all notebooklm-py 0.3.4+ builds)

Step 1.5 (NEW): Customize report (optional)
  → AskUserQuestion: "要给报告追加特殊要求吗？"
    Options:
      - "使用默认模板" → no --append, no --source filter
      - "追加自定义指令" → user types instruction → append_flag="--append '{instruction}'"
      - "限定特定源" → show source list from notebooklm source list -n <id> → user picks → source_flags="--source <id>" (repeatable)
      - "追加指令 + 限定源" → combine both

Step 2: Generate
  → ~/.tad-notebooklm-venv/bin/notebooklm generate report "{description}" {append_flag} {source_flags} --retry 3 -n <id> --wait
  → Display: "Generating report... (typically 30-90s)"
  → If exit code != 0: "❌ Report generation failed: {stderr}" + EXIT

Step 3: Download with exponential backoff retry
  → output_path: .tad/evidence/research/{notebook_topic}/{YYYY-MM-DD}-{slug}.md
    where {slug} = first 50 chars of {description}, lowercase, non-alphanumeric → "-",
    collapse multiple "-", trim leading/trailing "-"
    (collision: if file exists, append "-2", "-3", etc.)
    (mkdir -p the directory if missing)
  → ~/.tad-notebooklm-venv/bin/notebooklm download report --latest -n <id> "{output_path}"
  → If download returns empty or error:
    → Wait 20s, retry (attempt 2)
    → Wait 30s, retry (attempt 3)
    → If still fails: "⚠️ Report generated but download failed. View in NotebookLM web UI."

Step 4: Display
  → Read first 20 lines of downloaded file
  → Count lines + words
  → Output: "✅ Report saved: {path} ({line_count} lines, {word_count} words)"
```

---

### `*research-notebook guide [--source <id>]`

Per-source AI summary: understand what each source contributes.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Source selection
  → If --source <id> specified → use that source directly
  → If no --source: ~/.tad-notebooklm-venv/bin/notebooklm source list -n <id>
    → AskUserQuestion: "Which source(s) to summarize?" (display numbered list)

Step 2: For each selected source:
  → ~/.tad-notebooklm-venv/bin/notebooklm source guide <source_id> -n <id> --json
  → Parse JSON: {summary, keywords[]}

Step 3: Display formatted summary + keywords
  → "📖 Source: {title}"
  → Summary paragraph
  → "Keywords: {kw1}, {kw2}, ..."
```

---

### `*research-notebook configure [--persona <text>] [--mode <mode>]`

Set notebook research persona and query mode.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: If no flags → show current config + AskUserQuestion for what to change
  Options:
    - "Set custom persona (up to 10,000 chars)"
    - "Use preset mode (learning-guide / concise / detailed)"
    - "Reset to default"
    - "Cancel"

Step 1b: Resolve action from flags OR menu
  → After flags/menu, resolve to a tuple: (persona_action, mode_action)
    persona_action: one of {none, set:"<text>", reset}
    mode_action: one of {none, set:<mode>, reset}
  → If user chose "Reset to default" from menu: persona_action=reset, mode_action=reset
  → If user chose "Set custom persona" from menu: prompt for text → persona_action=set:"<text>", mode_action=none
  → If user chose "Use preset mode" from menu: prompt for mode → persona_action=none, mode_action=set:<mode>
  → If --persona flag passed: persona_action=set:"<text>"
  → If --mode flag passed: mode_action=set:<mode>

Step 2: Execute based on resolved action tuple
  Case A — Reset (persona_action=reset AND/OR mode_action=reset):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --mode default --persona "" -n <id>
    (Use both flags together — required to reset both axes per spike T2 evidence)
  Case B — Set both (persona_action=set AND mode_action=set):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --persona "{text}" --mode {mode} -n <id>
  Case C — Persona only (persona_action=set, mode_action=none):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --persona "{text}" -n <id>
  Case D — Mode only (persona_action=none, mode_action=set):
    → ~/.tad-notebooklm-venv/bin/notebooklm configure --mode {mode} -n <id>

Step 3: Confirm
  → "✅ Notebook configured."
  → If persona set: "Persona: {first 50 chars}..."
  → If mode set: "Mode: {mode}"

Note: persona up to 10,000 chars. Useful for domain-specific framing (e.g., "You are a security researcher
reviewing offensive AI techniques from a defensive blue-team perspective...").
```

---

### `*research-notebook topics`

Quick notebook overview + suggested query topics. Display-only, returns to standby.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Fetch summary + topics (stale conversation fallback)
  Layer 1 (normal):
    → ~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id>
    → If exit 0 and output non-empty → proceed to Step 2
    → If exit != 0:
  Layer 2 (force fresh conversation — retry on any non-zero exit):
    → ~/.tad-notebooklm-venv/bin/notebooklm summary --topics -n <id> -c 00000000-0000-0000-0000-000000000000
    → If still fails: report error to user

Step 2: Display
  → Output formatted summary paragraph
  → Output numbered topic list: "1. {topic} 2. {topic} ..."
  → Return to standby — no AskUserQuestion (user invokes *research-notebook ask themselves)

Step 3: Update REGISTRY
  → Update last_queried = today, status = active
  (topics consumes AI quota like ask — lifecycle should track it equally)
```

---

### `*research-notebook ingest <file_path>`

Add a local research finding (.md or .txt) as a notebook source.

**Knowledge loop status: VERIFIED GO** — `source add` with local file paths is empirically
confirmed to participate in `ask` context within ~30s (verified 2026-05-04, TASK-20260504-002).

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Validate file
  → Check file exists: test -f "{file_path}"
  → Check extension is .md or .txt
  → Check file size < 500KB: du -k "{file_path}" | awk '{print $1}'
  → If any check fails: report error + EXIT

Step 2: AskUserQuestion confirmation
  → "将 {filename} 的内容作为新 source 加入 notebook '{topic}'。确认？"
  Options: "确认" / "取消"

Step 3: Execute
  → ~/.tad-notebooklm-venv/bin/notebooklm source add "{file_path}" -n <id>
  → If exit code != 0: "❌ source add failed: {stderr}" + EXIT

Step 4: Verify ingestion (default: ON; skip with --no-verify)
  → Wait 30s for indexing
  → ~/.tad-notebooklm-venv/bin/notebooklm ask "summarize the content from {filename}" -n <id> -c 00000000-0000-0000-0000-000000000000
  → If answer references file content: "✅ Ingestion verified — content is queryable."
  → If answer doesn't reference content:
    → Wait 60s, retry once more (indexing can be variable, up to ~90s)
    → If still no reference: "⚠️ Content added but not yet appearing in answers. It is indexed — try *ask again in ~60s."
    (Content IS added regardless of verification result; verification is a confidence check)
  → If --no-verify flag: skip Step 4 entirely (use when batch-ingesting multiple files)

Step 5: Update REGISTRY
  → Increment source_count, add source entry (filename, type=file, added date)
  → Update last_queried = today, status = active

Step 6: Confirm
  → "✅ {filename} added as source to notebook '{topic}'. Total sources: {N}."
  → Reminder: "Content will be queryable via *ask within ~30s."
```

---

### `*research-notebook fulltext <source_id>`

Preview or save the full text content of a source.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Get source ID
  → If <source_id> provided → use it
  → If not → ~/.tad-notebooklm-venv/bin/notebooklm source list -n <id>
    → Display numbered list
    → AskUserQuestion: "Which source to view fulltext?"

Step 2: Extract fulltext
  → ~/.tad-notebooklm-venv/bin/notebooklm source fulltext <source_id> -n <id> -o /tmp/tad-fulltext-{source_id}.txt
  → Read first 100 lines for preview

Step 3: Display + option to save
  → Display preview (first 100 lines)
  → AskUserQuestion: "Save fulltext to project?"
    Options:
      - "Save to .tad/evidence/research/" → mkdir -p .tad/evidence/research/{topic}/ → cp /tmp/tad-fulltext-{source_id}.txt .tad/evidence/research/{topic}/fulltext-{source_id}.txt
      - "Just preview, don't save" → rm -f /tmp/tad-fulltext-{source_id}.txt

Use case: Alex Research Director evaluates source quality before recommending deep dives
```

---

### `*research-notebook language [set|get|list]`

Manage NotebookLM output language setting.

```
*research-notebook language set <code>:
  Step 0: Resolve target notebook (same as ask command)
  Step 1: → ~/.tad-notebooklm-venv/bin/notebooklm language set <code> -n <id>
  Step 2: → "✅ NotebookLM output language set to {language_name}. Affects all future reports/quizzes."

*research-notebook language get:
  Step 0: Resolve target notebook
  Step 1: → ~/.tad-notebooklm-venv/bin/notebooklm language get --local -n <id>
  Step 2: → Display current language setting

*research-notebook language list:
  Step 1: → ~/.tad-notebooklm-venv/bin/notebooklm language list
  Step 2: → Display supported languages table
```

---

### `*research-notebook consolidate`

Merge overlapping notebooks: detect → confirm → execute. Execution layer for A4.

```
Step 1: List all active notebooks with topics
  → ~/.tad-notebooklm-venv/bin/notebooklm list → display table

Step 2: Analyze overlap (LLM semantic judgment)
  → Group notebooks by semantic similarity of topic field
  → For each group with >1 notebook:
    → Display: "这 {N} 个 notebook 话题重叠: {list with source counts}"

Step 3: AskUserQuestion for each group:
  "建议整合这组 notebook。选择操作："
  Options:
    - "整合为一个" → Step 4
    - "保留独立" → skip this group
    - "删除其中 N 个" → user picks which to delete → *research-notebook archive for each selected

Step 4: Execute merge
  → AskUserQuestion: "合并后的 notebook 名称是什么？" (suggest: combined topic summary)
  → ~/.tad-notebooklm-venv/bin/notebooklm create "{merged_topic_name}"
  → Capture new notebook_id
  → For each old notebook in group:
    → ~/.tad-notebooklm-venv/bin/notebooklm source list -n <old_id> → get source URLs/IDs
    → For each source URL: ~/.tad-notebooklm-venv/bin/notebooklm source add <url> -n <new_id>
    → (Skip file-type sources — these cannot be re-added by URL)
  → Register new notebook to REGISTRY.yaml
  → *research-notebook archive for each old notebook (with user confirmation)
  → "✅ Merged {N} notebooks into '{merged_topic_name}'. Old notebooks archived."

Note: A4 (notebook_consolidation_suggestion) in Alex SKILL calls this command with
pre-selected groups. Pass groups via context — no extra parameters needed.
```

---

### `*research-notebook quiz [--difficulty easy|medium|hard] [--quantity fewer|standard|more]`

Generate a quiz from notebook content + download as markdown.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Generate quiz
  → defaults: --difficulty medium --quantity standard
  → ~/.tad-notebooklm-venv/bin/notebooklm generate quiz --difficulty {d} --quantity {q} -n <id> --retry 3 --wait
  → Display: "Generating quiz... (typically 15-30s)"
  → If exit code != 0: "❌ Quiz generation failed: {stderr}" + EXIT

Step 2: Download as markdown
  → output_path: .tad/evidence/research/{notebook_topic}/quiz-{YYYY-MM-DD}.md
    (mkdir -p the directory if missing; collision: append -2, -3 etc.)
  → ~/.tad-notebooklm-venv/bin/notebooklm download quiz --format markdown "{output_path}" -n <id>
  → If download fails:
    → Wait 20s, retry once
    → If still fails: "⚠️ Quiz generated but download failed. Try *research-notebook list to verify."

Step 3: Display + confirm
  → Read downloaded file content
  → Display full quiz to user
  → "✅ Quiz saved: {path}"
```

---

### `*research-notebook flashcards [--difficulty easy|medium|hard] [--quantity fewer|standard|more]`

Generate flashcards from notebook content + download as markdown.

```
Step 0: Resolve target notebook (same as ask command)

Step 1: Generate flashcards
  → defaults: --difficulty medium --quantity standard
  → ~/.tad-notebooklm-venv/bin/notebooklm generate flashcards --difficulty {d} --quantity {q} -n <id> --retry 3 --wait
  → Display: "Generating flashcards... (typically 15-30s)"
  → If exit code != 0: "❌ Flashcard generation failed: {stderr}" + EXIT

Step 2: Download as markdown
  → output_path: .tad/evidence/research/{notebook_topic}/flashcards-{YYYY-MM-DD}.md
    (mkdir -p the directory if missing; collision: append -2, -3 etc.)
  → ~/.tad-notebooklm-venv/bin/notebooklm download flashcards --format markdown "{output_path}" -n <id>
  → If download fails:
    → Wait 20s, retry once
    → If still fails: "⚠️ Flashcards generated but download failed."

Step 3: Display + confirm
  → Read downloaded file content
  → Display flashcards to user
  → "✅ Flashcards saved: {path}"
```

---

## Notebook Lifecycle Rules

```yaml
lifecycle_rules:
  states:
    active:
      condition: "last_queried within dormant_after_days"
      display: "✅ Active"
      action: "Normal use"
    dormant:
      condition: "last_queried between dormant_after_days and archive_suggest_after_days"
      display: "💤 Dormant"
      action: "Suggest curate or archive at list time"
    archived:
      condition: "User executed *archive"
      display: "📦 Archived"
      action: "REGISTRY entry retained, notebook remains in NotebookLM"

  thresholds: "Configured in .tad/config-workflow.yaml research_notebook section"
  source_limit: "Configured in .tad/config-workflow.yaml research_notebook.max_sources_per_notebook"

  status_field_semantics: |
    The `status` field in REGISTRY.yaml is a HYBRID:
    - "archived" is USER-SET (only changes via *archive, never auto)
    - "active" and "dormant" are DERIVED from last_queried at display time (*list)
    AND persisted by *ask and *topics (both set status=active on success)
    RESOLUTION: *list always recomputes active/dormant from last_queried when status != "archived"
    This means a persisted "dormant" that gets queried → *ask/*topics sets it to "active" immediately
    PASSIVE RECOMPUTE (Phase 4 wiring): the SessionStart hook .tad/hooks/notebook-dormant-sync.sh
    also recomputes active/dormant on every session start (no command run required), via the
    library function recompute_notebook_dormancy() in .tad/hooks/lib/notebook-lifecycle.sh.
    It reads dormant_after_days from config-workflow.yaml, edits ONLY changed non-archived entries
    via yq (atomic temp+mv, per-entry targeting), and is strictly NON-BLOCKING (derived state only —
    never blocks session start, no-ops if yq is absent). This prevents persisted status from going
    stale between *list runs. Archived entries are never touched.

  state_transitions:
    active_to_dormant: "Computed at *list time AND passively at SessionStart (notebook-dormant-sync.sh) when last_queried > dormant_after_days"
    dormant_to_active: "*ask or *topics success → REGISTRY.yaml status = active"
    active_to_archived: "*archive command only"
    dormant_to_archived: "*archive command only"
    archived_to_active: "NOT automatic — user must *ask with explicit confirmation prompt"
    topics_updates_last_queried: "YES — *topics consumes AI quota like *ask and updates last_queried"
```

---

## Integration Notes

- **Auth expiry**: NotebookLM sessions expire (Google cookies). When CLI returns auth error,
  prompt user: "Run bash .tad/cross-model/setup-notebooklm.sh to refresh auth."
- **YouTube sources**: Only videos with captions work via CLI. Use conference talks
  (CCC, RSAC, Black Hat) or official channels (Anthropic, Google) for reliable ingestion.
- **Query latency**: 23-43s per query. Normal for research tasks (not for real-time workflows).
- **REGISTRY is local index, cloud is canonical**: Use `*sync` when discrepancies appear. Local metadata (notes, titles, added dates) is preserved during sync — only source presence/count is compared to cloud.
- **Cross-topic isolation**: Different topics → different notebooks. Cross-source redundancy is OK.
- **URL curate skip**: Sources with `url` starting with `(web-UI added` are exempt from reachability checks — these were added via NotebookLM web UI and URL was not captured at add-time.
- **Stale conversation**: Layer 2 retry (`-c 00000000...`) fires ONLY on stale-specific stderr signals ("timeout", "stale", "conversation not found", "expired") — NOT on all exit != 0.
- **Minimum version**: notebooklm-py 0.3.4+. Earlier versions (0.1.1) have deprecated RPC endpoints — all AI-dependent commands fail.
- **Local file ingestion**: `source add /path/to/file.md` is VERIFIED GO — local .md and .txt files are accepted and queryable via `ask` within ~30s.
- **source refresh**: Only works for URL/Drive source types. YouTube, text, and file sources cannot be refreshed.

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `*research-notebook create <topic>` | New notebook + guide sources + register |
| `*research-notebook add <url>` | Add source to active notebook (direct) |
| `*research-notebook add-smart <url>` | Auto-detect URL type + preprocess + import + quality verify |
| `*research-notebook ask <question>` | Query notebook (cross-source reasoning) |
| `*research-notebook list` | List all notebooks + lightweight sync |
| `*research-notebook sync` | Full cloud sync |
| `*research-notebook curate` | Audit + prune + content-staleness check |
| `*research-notebook archive` | Archive notebook |
| `*research-notebook use <id>` | Set active notebook (session) |
| `*research-notebook research <topic>` | Auto source discovery + import + summary |
| `*research-notebook report <desc>` | Generate + download report as local .md |
| `*research-notebook guide` | Per-source AI summary + keywords |
| `*research-notebook configure` | Set notebook persona / query mode |
| `*research-notebook topics` | Quick overview + suggested query topics |
| `*research-notebook ingest <file>` | Add local .md/.txt as source (knowledge loop GO) |
| `*research-notebook fulltext <source_id>` | Preview or save full source text content |
| `*research-notebook language [set\|get\|list]` | Manage NotebookLM output language |
| `*research-notebook consolidate` | Merge overlapping notebooks (A4 execution layer) |
| `*research-notebook quiz` | Generate quiz from notebook → download as .md |
| `*research-notebook flashcards` | Generate flashcards from notebook → download as .md |
