# Publish Protocol (extracted from SKILL.md for progressive loading)
# Source: skills/alex/SKILL.md (platform tree)
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
            curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes

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

    step3b:
      name: "Skill Integrity Gate (.agents/skills structural — BLOCKING)"
      action: |
        Run the skill integrity gate (.agents/skills is the SOLE source of truth
        since v3.0.0; the dual-tree mirror gate was removed — single tree):
          bash .tad/hooks/lib/release-verify.sh structural "$PWD" "$PWD"

        Branch on exit code — exit 1 (DRIFT) and exit 2 (WIRING) handled SEPARATELY
        (same pattern as step3c/step3d):
        - exit 0 → proceed to step3c.
        - exit 2 (usage) → ALWAYS HARD BLOCK, regardless of release_type.
        - exit 1 (drift/omission detected) → STOP. Investigate the missing/differing
          path named by the script; do NOT proceed to step3c.

    step3c:
      name: "Self-Deriving Release Verification Gate (version — BLOCKING on minor+)"
      # NOT a settings.json hook — release-time only (single-user-CLI, architecture.md 2026-04-15)
      action: |
        Publish-side source-consistency = THIS step3c (version zero-stale)
        + scan-packs registry regen. structural is sync-only by design (no target exists at publish) —
        there is NO publish-time source-consistency hole.

        Version-surface derivation rule: the set of version literals to change is
        derived, never remembered from a prior release. Change surface =
        Must-Version Registry assertion surface ∪ state-surface check1–3 assertion
        surface ∪ any surface changed by the previous same-type release that the
        preceding assertion surfaces do not cover ∪ {`.tad/version.txt`, the AGENTS.md version
        marker line}. For every release, first run this version gate detect-only,
        triage every hit (live change / closeout backfill / exemption), and file the
        triage at `.tad/evidence/releases/<NEW>-version-triage.md`; a patch advisory
        pass is permitted only when that triage record is on disk.

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
            Minor/major triage gate: before the release may proceed, `.tad/evidence/releases/<NEW>-version-triage.md`
            must exist and cover 100% of this detect-only run's hits, with each hit assigned a category and
            basis (fields: path:line / hit text / category / basis or precedent pointer). Any unclassified hit
            is a HARD BLOCK at the same level as exit 2.
        - exit 1 (real drift) AND release_type == patch → advisory WARN, proceed to step4.
        On any non-zero, echo: GATE: release-verify version exit=<n>
        (so a fail-CLOSED usage error (exit 2) is distinguishable from a true stale-ref drift (exit 1) —
        exit 2 ALWAYS blocks; the warn branch keys off exit 1 only, never the combined `1 or 2`).
        Fail-CLOSED: exit 2 is treated as FAIL at this gate.
      blocking: true
      detect_only: true  # reads only — never edits version refs

    step3c2:
      name: "Version Sweep Gate (ALWAYS blocking)"
      action: |
        Run the full-repo version-sweep to detect stale identity markers and drift:
          bash .tad/hooks/lib/release-verify.sh version-sweep "$PWD" "$NEW"

        Branch on exit code:
        - exit 0 → proceed to step3d.
        - exit 2 (usage/wiring) → ALWAYS HARD BLOCK. Fix invocation and re-run *publish.
        - exit 1 (Layer 1 stale identity markers) → ALWAYS HARD BLOCK regardless of
          release_type (patch/minor/major). These are identity files that must never be stale.
          Fix the stale ref(s) and re-run *publish.
          Echo: GATE: release-verify version-sweep exit=<n>

        Note: Layer 2 hits (advisory drift) are printed for operator awareness but
        NEVER block. They are informational only — potential drift to investigate
        after the release, not a gate.
      blocking: true
      detect_only: true  # reads only — never edits files

    step3c3:
      name: "Validator Positive-Control Self-Check (ALWAYS BLOCKING)"
      action: |
        Governed set = every pack name listed in `.tad/capability-packs/pack-registry.yaml`,
        plus `alex` and `blake`. For each governed name, substitute that name for
        `<name>` and run exactly this two-argument form:

          bash .tad/scripts/capability-skill.sh validate "$PWD" <name>

        Every invocation must exit 0. Any non-zero result stops the release;
        do not proceed to step3d. This positive-control self-check applies to
        patch, minor, and major releases alike.
      blocking: true

    step3d:
      name: "Migration Manifest Gate (BLOCKING on minor+)"
      action: |
        Run the migration gate to detect unmanifested file deletions/renames between
        the previous tag and HEAD:
          bash .tad/hooks/lib/release-verify.sh migration "$PWD"

        Every release must ship `.tad/migrations/{prev}-to-{new}.yaml`; when the
        release has no delete/rename operations, use the empty-operation form
        (`delete: []` / `rename: []` plus a note), following the
        `2.43.0-to-2.43.1` precedent.

        Stock-repository genesis backfill: an existing fresh-installed repository's
        missing genesis manifest may be backfilled only from on-disk installation
        evidence (for example an install-checks report), in the same form, with
        `installed_version` taken from that evidence. With no evidence, do not
        backfill and do not fabricate a retrospective manifest. Backfill execution
        belongs to the downstream refresh surface, not the release-source change set.

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
        在船断言：PREV→NEW 的 hop 文件必须存在且良构（migration 子命令的在船断言，exit 1 且输出含 `MISSING HOP:`/`MALFORMED HOP:`）。
        - exit 1 with `MISSING HOP:` or `MALFORMED HOP:` → HARD BLOCK for every release type
          (patch included). Supply a well-formed `.tad/migrations/{prev}-to-{new}.yaml` and re-run *publish.
          Echo: GATE: release-verify migration missing/malformed hop
      blocking: true
      detect_only: true  # reads only — never edits manifests

    step3e:
      name: "State-Surface Closeout （机制 3 — TASK-20261004, ALWAYS blocking)"
      action: |
        发版收口三步（设计 §2.2 机制 3；状态面防再过期的收口挂钩）：
        1. 文件集断言：bump .tad/version.txt 的同一 release commit 必须同时含
           NEXT.md 与 ROADMAP.md 的头部行回填。断言执行者 = 发版执行者本人
           （收口人工步，不入检查脚本——脚本跑的是树、不是某个 commit）；
           执行命令：
             git show --name-only --format= <release-commit>
           核对 {.tad/version.txt, NEXT.md, ROADMAP.md} 三文件齐备，命令与输出
           记入本次发版收口记录；缺一 → 不许宣告发版完成。
        2. 状态面检查：运行
             bash .tad/hooks/lib/release-verify.sh state-surface
           （转调 .tad/hooks/lib/state-surface-check.sh，detect-only，只读只报）；
           非 0 → 不许宣告发版完成；纠偏由人/Alex 另行执行，收口流内不自动改文档。
        3. 下游台账刷新：重跑
             bash .tad/scripts/scan-downstream-versions.sh
           生成的台账 .tad/evidence/pm/downstream-versions.md 以 git add -f
           单文件例外随收口 commit 入主仓（Gate 2 载体裁定（乙））；
           台账是派生索引，禁止手改。
      blocking: true

    step3f:
      name: "Live Regression Transcripts (BLOCKING, graded)"
      action: |
        Runtime set (frozen in this text; membership changes require editing
        this step and a note in the release record): {codex, opencode, cursor}
        — the same runtime set as AGENTS.md Known Gaps P4.

        A live-regression transcript is one file per runtime per cycle at
        `.tad/evidence/live-regression/<runtime>-<YYYYMMDD>.md` with exactly
        six fields (missing any one = not a transcript):
          1. runtime
          2. harness name and version
          3. execution date
          4. chain type (full chain: activation → dispatch → Gate evidence →
             closeout, or the segment actually run, named as such)
          5. result (PASS/FAIL + one-line characterization)
          6. raw output pointer (in-repo evidence path)

        Currency rule: a transcript counts for this release only if its
        execution date is on or after the previous release's date (produced
        inside this release cycle; older stock does not count).

        Grading (HARD / ADVISORY): a runtime is in HARD state from the first
        release whose tree contains its first baseline transcript.
        - HARD runtime missing a current-cycle transcript → this step is RED;
          the release hard-stops.
        - ADVISORY runtime missing one → does not block the release, BUT the
          release record (the closeout note for this release) must register,
          per missing runtime, 「缺失＋补齐归属（Epic Phase 3 件 3.3）」;
          an unregistered absence is judged RED exactly like a missing
          transcript （未登记即红）.
        Fallback (written into this step): from the first minor release after
        Epic Phase 3 closes, all three runtimes are HARD regardless of the
        baseline rule above — whichever takes effect first governs.

        Adjudication ownership: the release executor checks field presence,
        currency, and pointer existence; Gate/closeout rechecks the pointers.
        Whether a transcript's chain was genuinely live is Phase 3's
        live-regression criterion, not this step's — this step judges only
        presence, completeness, and currency.

        Interface with Epic Phase 3: this step defines only the checklist
        entry and its adjudication. Transcript production and the live
        execution surface belong to Epic Phase 3 item 3.3; at Phase 3
        closeout all three baseline transcripts must exist (its ACs govern),
        and grading turns fully HARD from that point per the fallback above.
      blocking: true

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

