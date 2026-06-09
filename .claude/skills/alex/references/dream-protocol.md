# Dream Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

dream_protocol:
  description: "Consolidate project-knowledge files: dedup, merge, prune stale refs, reduce bloat"
  trigger: "User types *dream"
  safety_principle: "NEVER modify originals directly — produce candidates for human review"
  loop_discover_option: |
    If Workflow tool available, *dream can use loop-discover for open-ended knowledge gap finding:
    Workflow({name: 'loop-discover', args: {
      finder_prompt: "Scan .tad/project-knowledge/ files for stale entries, duplicates, missing cross-references, and entries that should be merged.",
      schema: {type: "object", properties: {file_path: {type: "string"}, entry_title: {type: "string"}, issue_type: {type: "string"}, description: {type: "string"}}, required: ["file_path", "entry_title", "issue_type"]},
      dedup_key: ["file_path", "entry_title"], dry_rounds_to_stop: 2,
      context_files: [".tad/project-knowledge/"]
    }})

  flags:
    default: "Generate candidates only (no promotion)"
    auto: "*dream --auto — manually run dream scanner (same as cron trigger)"
    promote: "*dream --promote — backup originals + replace with accepted candidates"
    rollback: "*dream --rollback — restore from latest snapshot"

  steps:
    step0_auto:
      name: "Auto-Scan Mode (--auto flag)"
      trigger: "*dream --auto"
      action: |
        1. Run: bash .tad/hooks/lib/dream-scanner.sh
        2. Read output: candidate count
        3. If candidates > 0:
           Proceed to candidate review (skip format consolidation steps 1-3).
           Show candidates for human review using STEP 3.56 per-candidate review logic
           (accept/modify/reject/defer loop).
        4. If candidates == 0:
           Output: "No new patterns detected. Try again after more sessions."
           Return to standby.
      note: "Auto mode SKIPS format consolidation (steps 1-3). Only runs scanner + review."

    step1_orient:
      name: "Orient — Map Current Knowledge State"
      action: |
        1. List all .tad/project-knowledge/*.md files (exclude README.md)
        2. For each file:
           a. Count ### entries: `grep -c '^### ' "$file"`
           b. Count lines: `wc -l < "$file"`
           c. Extract entry titles + dates: `grep -E '^### .+ [—-] [0-9]{4}-[0-9]{2}-[0-9]{2}' "$file"`
           d. Count safety keywords: `grep -coE 'MUST|MANDATORY|VIOLATION|BLOCKING' "$file"`
        3. Output orientation report as table:
           | File | Entries | Lines | Safety Keywords | Oldest | Newest |
        4. Store baseline counts (used by validator in step4)

    step2_gather_signal:
      name: "Gather Signal — Identify Consolidation Opportunities"
      action: |
        For each knowledge file:

        1. **Stale file refs**: For every "Grounded in" line, extract file paths and
           check if each path exists on disk. Mark entries where ALL grounded-in paths
           are missing as [STALE].

        2. **AMENDED pairs**: Search for entries containing "AMENDED" in title or body.
           Find the corresponding original entry (usually referenced by title).
           These are merge candidates.

        3. **Topic overlap**: Group entries by semantic topic similarity:
           - Entries sharing the same primary subject (e.g., "Hook Performance" entries)
           - Entries about the same Epic/Phase (e.g., multiple Phase 1c entries)
           - Entries where one supersedes another (look for "superseded" keyword)

        4. **Foundational section boundary**: Identify the line "## Accumulated Learnings"
           Everything ABOVE this line is Foundational and MUST NOT be modified.

        5. Output signal report:
           "📊 Consolidation opportunities found:
            - {N} stale ref entries
            - {N} AMENDED pairs ready to merge
            - {N} topic overlap groups
            - Foundational section: lines 1-{M} (protected)"

        6. **Graduation candidates**: Scan incidents/_index.md for entries with the same
           "linked" L2 pattern. If ≥2 incidents link to the same L2 pattern:
           → Propose graduation: "Pattern '{pattern}' has {N} supporting incidents.
             Consider promoting the common finding to a stronger pattern entry."
           → In step4 review, show these as "🎓 Graduation candidate" with option to:
             - "Accept graduation" → merge incident findings into the L2 pattern entry,
               archive the incidents
             - "Keep separate" → incidents stay, no merge

        7. **Expired incidents**: For each incident in incidents/_index.md:
           a. Extract date from the entry (YYYY-MM-DD format in title or _index.md)
           b. Compute age_days = today - date
           c. If age_days > 90:
              Check: has the linked L2 pattern had a NEW incident in the last 60 days?
              → If no new incident (pattern is stable) → propose archival:
                "Incident '{title}' is {age_days} days old and its linked pattern
                '{pattern}' has been stable for 60+ days. Archive?"
              → If yes (pattern still active) → keep incident (still relevant evidence)
           d. In step4 review, show these as "🗄️ Expiration candidate" with options:
              - "Archive" → mv incident file to .tad/archive/knowledge/{YYYY-MM}/
              - "Keep" → incident stays (resets the 90-day clock via Revalidated date)
              - "Revalidate" → add Revalidated: {today} date, keep for another 90 days

    step3_consolidate:
      name: "Consolidate — Produce Candidate Files"
      action: |
        For each knowledge file, create a candidate in .tad/active/dream-candidates/:

        0. **Copy Foundational section byte-exactly** from original to candidate.
           Everything from line 1 to (and including) the "## Accumulated Learnings" line.

        1. **Dedup & Merge** (deterministic rules — merge when ANY of these hold):
           a. AMENDED+ORIGINAL pair: entry title contains "AMENDED" and references an original
           b. Identical title prefix: two entries share the first 5+ words of title
           c. Same handoff Context: entries reference the same handoff/phase in Context line
           - Keep the MOST RECENT entry's date and structure
           - Combine unique Action items from all merged entries
           - Add provenance: "Supersedes: {old title 1}, {old title 2}"

        2. **Contradiction Resolution**:
           - Entries containing MUST/MANDATORY/VIOLATION/BLOCKING keywords:
             → NEVER auto-resolve. Keep ALL such entries unchanged. Add a flag:
             "⚠️ SAFETY ENTRY — requires human review for any modification"
           - Non-safety contradictions: newest entry wins.
             Add provenance note: "Supersedes: {old title}"

        3. **Stale Ref Cleanup**:
           - Entries where ALL "Grounded in" paths are missing from disk:
             → Remove the entry entirely (it references nothing that still exists)
           - Entries where SOME paths are missing:
             → Keep the entry, remove only the missing paths from "Grounded in"

        4. **Inline Compression** (target: ≤50% of original line count):
           - Entries >15 lines: compress to ≤8 lines while preserving:
             Context (1 line), Discovery (2-3 lines), Action (1-2 lines)
           - Remove verbose examples that repeat the same point
           - Preserve "Revalidated" dates (used by stale-knowledge-check.sh as alarm quieting)
           - Collapse multi-paragraph Discovery sections into key finding + rule

        5. Write candidate to .tad/active/dream-candidates/{filename}

      constraints:
        - "Safety keyword entries (MUST/MANDATORY/VIOLATION/BLOCKING in body) are EXCLUDED from auto-merge"
        - "Foundational section is byte-identical to original"
        - "Every merge produces a provenance note"
        - "No entry is silently deleted — stale removals are logged in step4"

    step4_validate_and_review:
      name: "Validate & Human Review"
      action: |
        For each candidate file:

        1. Run validator:
           `bash .tad/hooks/lib/dream-validator.sh {original} {candidate}`
           Display full output to user.

        2. Show diff summary:
           - Entries removed (with reason: stale / merged)
           - Entries merged (with provenance)
           - Entries compressed (line count before → after)
           - Safety entries preserved (count)

        3. Present to user via AskUserQuestion:
           question: "{filename}: {orig_entries} → {cand_entries} entries, {orig_lines} → {cand_lines} lines ({reduction}% reduction). Accept?"
           options:
             - "Accept this candidate"
             - "Show me the full diff first"
             - "Skip this file (keep original)"

        4. If "Show diff" → display `diff {original} {candidate}`, then re-ask accept/skip
        5. If accepted → mark for promotion
        6. After all files reviewed:
           - If --promote flag: execute promotion (step5)
           - Otherwise: "Candidates saved in .tad/active/dream-candidates/. Run *dream --promote to apply."

    step5_promote:
      name: "Promote Accepted Candidates"
      trigger: "*dream --promote OR user accepts during step4"
      action: |
        1. Create snapshot directory (with timestamp to prevent same-day overwrite):
           .tad/archive/knowledge-snapshots/{YYYY-MM-DD-HHMMSS}/
        2. For each accepted candidate:
           a. Copy original → snapshot directory (backup)
           b. Copy candidate → original path (replace)
        3. Remove .tad/active/dream-candidates/ contents (cleanup)
        4. Output: "✅ Promoted {N} files. Snapshot saved to .tad/archive/knowledge-snapshots/{date}/
           Run *dream --rollback to undo."

    step6_rollback:
      name: "Rollback from Snapshot"
      trigger: "*dream --rollback"
      action: |
        1. Find latest snapshot: `ls -d .tad/archive/knowledge-snapshots/*/ | sort -r | head -1`
        2. If no snapshots exist → "No snapshots found. Nothing to roll back."
        3. List snapshot contents with dates
        4. AskUserQuestion: "Restore from snapshot {date}? This will overwrite current knowledge files."
        5. If confirmed:
           a. Copy each file from snapshot → .tad/project-knowledge/
           b. Output: "✅ Rolled back to snapshot {date}."

  validator:
    script: ".tad/hooks/lib/dream-validator.sh"
    checks:
      - "Safety keyword count: candidate ≥ original"
      - "Entry count: candidate > 0"
      - "Foundational section: byte-identical"
      - "Grounded-in paths: existence check (advisory)"
    enforcement: "advisory — validator reports results, does not block promotion"

