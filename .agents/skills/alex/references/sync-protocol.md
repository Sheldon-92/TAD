# Sync Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

sync_protocol:
  description: "Sync TAD framework files to registered projects"
  trigger: "User types *sync"

  prerequisite:
    # Guard 1: TAD-main-only check (CRITICAL — prevents wrong-source sync in downstream projects)
    tad_main_guard:
      check: |
        Run bash command: git config --get remote.origin.url 2>/dev/null || echo "none"
        If output contains "Sheldon-92/TAD" → PASS (this IS the TAD source repo)
        Else → FAIL (this is a downstream project that only USES TAD)
      on_fail:
        behavior: "REFUSE to proceed. Do not run ANY sync step. Exit to standby."
        message: |
          ❌ *sync is a TAD framework distribution command, not a project command.

          Current directory: {basename of cwd}
          Git origin:        {the origin url or 'none'}

          This command ONLY runs in the TAD source repository
          (github.com/Sheldon-92/TAD). In any other project it would:
          - Read sync-registry.yaml (which points to TAD's registered projects)
          - Treat the CURRENT project as the "source of truth"
          - Push the current project's files TO the 10 registered projects
          - This can silently corrupt OTHER projects with files from this one

          To update the TAD framework installed in this project:
            curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes

          To sync TAD updates to all your registered projects, switch to the
          TAD source repo first, then run *sync there.
      blocking: true

    # Guard 2: Mandatory runbook read (prevents recurring sync bugs)
    mandatory_read: ".claude/skills/release-runbook/SKILL.md"
    action: |
      ⚠️ BEFORE executing any *sync step, Read the release runbook.
      It contains the mixed-strategy sync matrix (incremental / full-refresh /
      merge / strict-delete / zero-touch), jq flag compatibility notes, the
      deprecation-cleanup gotcha (tad.sh historically missed it), CLAUDE.md
      marker handling, and mandatory post-flight verification per project.
      Past syncs left 18 deprecated files behind on 10 projects because
      this step was skipped.
    blocking: true

  execution:
    step1:
      name: "Load Registry"
      action: |
        Check if .tad/sync-registry.yaml exists.
        If missing → "Registry not found. Use *sync-add to register a project first." → standby.
        Read .tad/sync-registry.yaml.
        If projects list is empty → "No projects registered. Use *sync-add to register one." → standby.
        Display project table:
        | # | Project | Last Synced | Current | Status |

    step2:
      name: "Select Scope"
      action: |
        Use AskUserQuestion:
        "Which projects to sync?"
        Options:
        - "All outdated projects" → sync all where last_synced < current
        - "Select specific" → show numbered list, user picks
        - "Cancel" → standby

    step3:
      name: "Execute Sync (per project)"
      action: |
        For each selected project, execute in order:

        0. PATH VALIDATION:
           - Check target path exists
           - Check .tad/ directory exists at target
           - If validation fails → mark as SKIPPED, log error, continue to next project

        <!-- Claude Code: CLAUDE.md / Codex: AGENTS.md -->
        a. CLAUDE.md — based on claude_md_strategy:
           - "overwrite": copy TAD source CLAUDE.md directly
           - "merge":
             1. Read target CLAUDE.md
             2. Find first occurrence of `<!-- TAD:PROJECT-CONTENT-BELOW -->`
             3. If marker found: replace everything ABOVE the marker with TAD source CLAUDE.md content, preserve marker + everything below
             4. If marker NOT found: WARN user "Merge marker not found in {project}. Overwrite or skip?"
                → AskUserQuestion: "Overwrite" / "Skip this project"
           - After merge: backup original to CLAUDE.md.bak before writing

        b. Framework files — copy from TAD source (mirror tad.sh copy_framework_files):
           Top-level .tad/ config & metadata:
           - .tad/*.yaml, .tad/*.md, .tad/*.txt (all top-level files)
           # SYNC-MIRROR: must match tad.sh copy_framework_files() dir list (line 115)
           Framework subdirectories (full recursive copy):
           - .tad/agents/
           - .tad/data/
           - .tad/gates/
           - .tad/guides/
           - .tad/hooks/
           - .tad/ralph-config/
           - .tad/references/
           - .tad/schemas/
           - .tad/skills/
           - .tad/sub-agents/
           - .tad/tasks/
           - .tad/templates/
           - .tad/workflows/
           .claude/ framework files (platform-aware):
           - Read target project's platform from sync-registry.yaml entry
           - If platform == "codex":
               Copy skills to .agents/skills/ (not .claude/skills/)
               Skip .claude/settings.json (use hooks.json instead)
               Skip .claude/workflows/
           - If platform == "claude-code" (default):
               Copy skills to .claude/skills/ (unchanged)
               Copy .claude/settings.json
               Copy .claude/workflows/*.workflow.js
           - .claude/skills/**/SKILL.md (target: $skill_dir per platform)
           - .claude/skills/doc-organization.md (target: $skill_dir per platform)
           Root-level files:
           - tad.sh
           - docs/MULTI-PLATFORM.md
           - README.md, INSTALLATION_GUIDE.md, CHANGELOG.md
           Capability Pack registry (index only — pack source dirs are NOT synced):
           - .tad/capability-packs/pack-registry.yaml

        b2. Capability Pack installation:
            Pre-check: verify {target_project_path}/.claude/ exists.
              If missing: WARN "Skipping pack install for {project_name}: .claude/ not found" and skip to step c.
            
            For each pack directory in {TAD_SOURCE}/.tad/capability-packs/*/ that contains install.sh:
              1. Execute as a SEPARATE Bash tool call (NOT chained with && — one pack's failure must not prevent others):
                 cd {target_project_path} && bash {TAD_SOURCE}/.tad/capability-packs/{pack_name}/install.sh --force; echo "EXIT:$?"
              2. If exit code non-zero: WARN "{pack_name} install failed on {project_name}: exit {code}" and continue to next pack
              3. Post-install validation: verify the installed SKILL.md has YAML frontmatter
                 head -3 {target_project_path}/.claude/skills/{pack_name}/SKILL.md | grep -q "^name:"
                 If grep fails: WARN "{pack_name} installed but SKILL.md lacks frontmatter — skill may not activate" and increment fail counter
            
            Output: "📦 {N} capability packs installed ({success} success, {fail} failed)"
            Note: install.sh uses CWD for .claude/ detection, so cd is required.
            Note: --force ensures packs are updated on each sync (idempotent).
            Note: Each install.sh runs in its own Bash call to prevent set -euo pipefail propagation.

        b3. Migration engine (post-copy, per-project):
            Pre-condition: old_version captured from step 1 (target's version.txt BEFORE copy).

            Call: bash {TAD_SOURCE}/.tad/hooks/lib/migration-engine.sh \
              --from {old_version} --to {current_version} \
              --target {target_project_path} --source {TAD_SOURCE}

            Exit code handling (same as tad.sh):
            - exit 0 → migration applied (or no manifests for this version range); continue
            - exit 2 → WARN "Migration skipped for {project_name}: manifest invalid or chain gap"
                       Do NOT block sync — the copy already landed. Continue to step c.
            - exit 1 → WARN "Migration had execution errors for {project_name}"
                       Backup exists at {target}/.tad-backup/; continue to step c.

            Note: The engine is the SOLE executor of migration logic. Alex MUST NOT
            inline any delete/rename operations for migration — that is FR5 (zero
            dual-implementation). If the engine lacks a needed capability, file it
            as a Phase 4+ enhancement, don't work around it in sync-protocol.

        c. Deprecation cleanup:
           Read .tad/deprecation.yaml (if missing → skip silently, no deprecations to apply).
           Version comparison rules (semver):
           - Compare major.minor.patch numerically (2.10.0 > 2.3.0)
           - Apply deprecations where: last_synced_version < deprecation_version <= current_version
           - If deprecation.yaml has no entries for the version range → skip silently
           - Ignore entries for versions > current_version (future deprecations)
           For each matching deprecation: delete listed files/directories, log each deletion.

        d. Verification:
           - Check version.txt in target matches current TAD version
           - Check CLAUDE.md exists and is readable
           - If merge: verify project-specific content still present (check marker exists)

        d2. Self-Deriving Release Verification Gate (structural — BLOCKING on minor+):
           # NOT a settings.json hook — release-time only (single-user-CLI, architecture.md 2026-04-15)
           This runs AFTER the verbatim cp -R copy above ⇒ source==target byte-identity is the correct
           equality test (install.sh edition transforms are a P2/tad.sh concern, out of this gate's scope).

           FIRST, unconditionally emit the derived synced-set REPORT (AC8 — every run, so a newly-included
           framework dir is auditable):
             bash {TAD_SOURCE}/.tad/hooks/lib/derive-sync-set.sh --report {TAD_SOURCE}

           THEN run the structural source-vs-target gate for this project:
             bash {TAD_SOURCE}/.tad/hooks/lib/release-verify.sh structural "{TAD_SOURCE}" "{target_project_path}"

           Branch on exit code — exit 1 (DRIFT) and exit 2 (WIRING) are handled SEPARATELY
           (cr-P1-3 / arch-P1-2 fix; TAD_RELEASE_GATE=warn downgrades ONLY drift, never a wiring bug):
           - exit 0 → mark project synced, continue.
           - exit 2 (usage/wiring/parse error) → ALWAYS HARD BLOCK this project, regardless of
             TAD_RELEASE_GATE and release_type. A wiring bug is NOT drift; warn must not mask it. Do NOT
             mark synced. Fix the invocation and re-run.
           - exit 1 (real omission/drift) AND release_type in {minor, major}:
             → HARD BLOCK this project. Do NOT mark it synced. Report the named omitted/differing path.
               (Shadow cutover graduated 2026-06-10: 14/14 projects validated. TAD_RELEASE_GATE=warn no longer used.)
           - exit 1 (real drift) AND release_type == patch → advisory WARN, proceed.
           On any non-zero, echo: GATE: release-verify structural exit=<n>
           (distinguish exit 1 real omission from exit 2 usage/wiring error — exit 2 ALWAYS blocks; the warn
           branch keys off exit 1 only, never the combined `1 or 2`).
           Fail-CLOSED: exit 2 is treated as FAIL.

        e. Platform-skills parity check (after all skill copy/install writes):
           bash .tad/hooks/lib/release-verify.sh platform-skills "$SOURCE_ROOT" "$project"
           Same exit-code handling as structural: exit 0 = proceed; exit 1 = FAIL (drift/missing);
           exit 2 = ALWAYS HARD BLOCK. This verifies .claude/skills and .agents/skills are
           byte-symmetric for all framework-owned skills. Local-only skills are INFO.

        f. Update registry:
           - Set last_synced_version and last_synced_date

        PRESERVE (never touch):
        - .tad/project-knowledge/
        - .tad/active/ (handoffs, epics, ideas)
        - .tad/archive/
        - .tad/evidence/
        - .tad/pair-testing/
        - .tad/decisions/
        - .tad/capability-packs/ (source dirs NOT synced — packs installed via step b2's install.sh during *sync)
        - .tad-backup/ (migration engine backups — per-version, target-side only)
        - PROJECT_CONTEXT.md, NEXT.md

    step3_commit:
      name: "Auto-Commit (optional)"
      trigger: "After all projects synced in step3"
      action: |
        Use AskUserQuestion:
        "Sync complete. Commit TAD files in each project?"
        Options:
        - "Commit all" → for each synced project with .git directory:
            git add -- .tad/*.yaml .tad/*.md .tad/*.txt \
              .tad/agents/ .tad/data/ .tad/gates/ .tad/guides/ \
              .tad/hooks/ .tad/ralph-config/ .tad/references/ .tad/schemas/ \
              .tad/skills/ .tad/sub-agents/ .tad/tasks/ \
              .tad/templates/ .tad/workflows/ \
              .tad/capability-packs/pack-registry.yaml \
              .claude/skills/ .claude/settings.json .claude/workflows/ \
              CLAUDE.md tad.sh README.md INSTALLATION_GUIDE.md CHANGELOG.md \
              docs/MULTI-PLATFORM.md 2>/dev/null
            git commit -m "chore: sync TAD v{version} to {project_name}"
        - "Commit + Push" → same as above, then git push for projects with remote
            (confirm before push if current branch is main/master)
        - "Skip" → leave uncommitted
      note: "Only runs on projects with .git directory. No-git projects skipped silently.
             git add paths MUST match sync scope exactly — do NOT use broad .tad/ or docs/."

    step4:
      name: "Summary"
      action: |
        Display sync summary:
        | Project | Version | Files Updated | Files Deleted | Committed | Status |

        Return to standby.

