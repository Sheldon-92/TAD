# Publish Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

publish_protocol:
  description: "GitHub publish workflow with version consistency checks"
  trigger: "User types *publish"

  prerequisite:
    # Guard 1: TAD-main-only check (CRITICAL — prevents wrong-repo push in downstream projects)
    tad_main_guard:
      check: |
        Run bash command: git config --get remote.origin.url 2>/dev/null || echo "none"
        If output contains "Sheldon-92/TAD" → PASS (this IS the TAD source repo)
        Else → FAIL (this is a downstream project that only USES TAD)
      on_fail:
        behavior: "REFUSE to proceed. Do not run ANY publish step. Exit to standby."
        message: |
          ❌ *publish is a TAD framework release command, not a project command.

          Current directory: {basename of cwd}
          Git origin:        {the origin url or 'none'}

          This command ONLY runs in the TAD source repository
          (github.com/Sheldon-92/TAD). In any other project it would:
          - Push to the wrong repo (your project's origin, not TAD's)
          - Create TAD version tags in a non-TAD namespace
          - Potentially corrupt your project's release history

          To update the TAD framework installed in this project:
            curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash

          To release your own project, use your project's own release workflow —
          not *publish.
      blocking: true

    # Guard 2: Mandatory runbook read (prevents recurring release bugs)
    mandatory_read: ".claude/skills/release-runbook/SKILL.md"
    action: |
      ⚠️ BEFORE executing any *publish step, Read the release runbook.
      It contains the exhaustive version-bump file list (14 strings across 6 files),
      known jq gotchas, deprecation mechanics, and post-flight verification.
      Past releases shipped with stale versions because this step was skipped.
    blocking: true

  execution:
    step1:
      name: "Version Consistency Check"
      action: |
        Read and compare version strings from these files:
        1. .tad/version.txt (uses MAJOR.MINOR format, e.g., "2.3")
        2. .tad/config.yaml → version field (uses MAJOR.MINOR.PATCH, e.g., "2.3.0")
        3. tad.sh → TARGET_VERSION (uses MAJOR.MINOR format, e.g., "2.3")
        4. INSTALLATION_GUIDE.md → version references
        5. .claude/skills/tad-help/SKILL.md → version references

        Consistency rule: extract MAJOR.MINOR from all sources; they must match.
        (config.yaml's ".0" patch suffix is expected and not a mismatch)

        Display comparison table:
        | File | Format | Version Found | MAJOR.MINOR | Status |
        |------|--------|--------------|-------------|--------|

        If ANY MAJOR.MINOR mismatch → list them and ask user to fix before continuing.
        Alex does NOT fix version numbers directly (Alex doesn't code).

    step2:
      name: "CHANGELOG Check"
      action: |
        Read CHANGELOG.md.
        Check if there's an entry for the current version.
        If missing → warn: "CHANGELOG.md has no entry for v{version}. Add one before publishing."
        If exists → show the entry summary.

    step3:
      name: "Git Status Check"
      action: |
        Display git status summary:
        - Uncommitted changes?
        - Unpushed commits?
        - Current branch?
        If uncommitted changes → warn and ask user to commit first.

    step3c:
      name: "Self-Deriving Release Verification Gate (version — BLOCKING on minor+)"
      # NOT a settings.json hook — release-time only (single-user-CLI, architecture.md 2026-04-15)
      action: |
        Publish-side source-consistency = THIS step3c (version zero-stale)
        + scan-packs registry regen. structural is sync-only by design (no target exists at publish) —
        there is NO publish-time source-consistency hole.

        FIRST, unconditionally emit the derived synced-set REPORT (AC8 — every run, not only on failure,
        so a newly-included framework dir is auditable at gate time per bias-to-sync):
          bash .tad/hooks/lib/derive-sync-set.sh --report

        THEN run the version zero-stale gate (at publish there is NO target ⇒ version mode only):
          bash .tad/hooks/lib/release-verify.sh version "$PWD" "$NEW" "$OLD"

        Branch on exit code — exit 1 (DRIFT) and exit 2 (WIRING) are handled SEPARATELY
        (cr-P1-3 / arch-P1-2 fix; TAD_RELEASE_GATE=warn downgrades ONLY drift, never a wiring bug):
        - exit 0 → proceed to step4.
        - exit 2 (usage/wiring/parse error) → ALWAYS HARD BLOCK, regardless of TAD_RELEASE_GATE and
          release_type. A wiring bug is NOT drift; warn must not mask it (the shadow run is exactly
          when the wiring is least battle-tested). Fix the invocation and re-run *publish.
        - exit 1 (real stale-ref drift) AND release_type in {minor, major}:
          → HARD BLOCK. Do not proceed to Confirm & Execute. Fix the stale ref(s) and re-run *publish.
            (Shadow cutover graduated 2026-06-10: 14/14 projects validated. TAD_RELEASE_GATE=warn no longer used.)
        - exit 1 (real drift) AND release_type == patch → advisory WARN, proceed to step4.
        On any non-zero, echo: GATE: release-verify version exit=<n>
        (so a fail-CLOSED usage error (exit 2) is distinguishable from a true stale-ref drift (exit 1) —
        exit 2 ALWAYS blocks; the warn branch keys off exit 1 only, never the combined `1 or 2`).
        Fail-CLOSED: exit 2 is treated as FAIL at this gate.
      blocking: true
      detect_only: true  # reads only — never edits version refs

    step3d:
      name: "Migration Manifest Gate (BLOCKING on minor+)"
      action: |
        Run the migration gate to detect unmanifested file deletions/renames between
        the previous tag and HEAD:
          bash .tad/hooks/lib/release-verify.sh migration "$PWD"

        Branch on exit code — same pattern as step3c (exit 1 vs exit 2 handled separately):
        - exit 0 → proceed to step4.
        - exit 2 (usage/wiring/parse error) → ALWAYS HARD BLOCK, regardless of TAD_RELEASE_GATE.
          Fix the invocation and re-run *publish.
          Echo: GATE: release-verify migration exit=2
        - exit 1 (unmanifested D/R drift) AND release_type in {minor, major}:
          → HARD BLOCK. Create the missing manifest(s) and re-run *publish.
            (Shadow cutover graduated 2026-06-10: 14/14 projects validated. TAD_RELEASE_GATE=warn no longer used.)
          Echo: GATE: release-verify migration exit=1
        - exit 1 AND release_type == patch → advisory WARN, proceed to step4.
        Fail-CLOSED: exit 2 is treated as FAIL at this gate.
      blocking: true
      detect_only: true  # reads only — never edits manifests

    step4:
      name: "Confirm & Execute"
      action: |
        Use AskUserQuestion:
        "Pre-publish checks complete. Ready to publish?"
        Options:
        - "Push + Tag" → execute git push && git tag v{version} && git push --tags
        - "Push only" → git push (no tag)
        - "Abort" → cancel

        EXCEPTION TO "ALEX DOESN'T CODE":
        Git push/tag are one-way publish operations with no design ambiguity.
        Human confirms before each command via AskUserQuestion.
        This exception does NOT extend to: code changes, build scripts,
        configuration file edits, or any implementation work.

    step5:
      name: "Post-Publish"
      action: |
        After successful push:
        1. Display confirmation with commit hash and tag
        2. Suggest: "Run *sync to update registered projects"
        Return to standby.

