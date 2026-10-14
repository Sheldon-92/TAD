# Conductor protocol: how Cora runs an approved Epic, phase by phase.
# Moved 2026-10-13 from alex/references/yolo-manual-conductor-protocol.md (EPIC-20261013-cora-conductor-role, Phase 1). The conductor is Cora, not Alex.
# Origin: v1 prose protocol, copied 2026-10-09 (EPIC-20261008 multi-harness restore, Phase 3), then rewritten for Cora: no conductor verdicts, no conductor edits, no stop between phases. Reviewer type names and spawn parameters below are Claude Code examples: map them to the harness's own subagent facility.
# Tags of the form A-plus-a-number in square brackets name the constraint of Alex's skill that the line carries; the acceptance script reads them. Keep them when editing.

yolo_execution_protocol:
  description: "Cora conducts an approved Epic through all its phases. Every step is one subagent; every result is a file on disk."
  trigger: "The human's 'continue' on an Epic whose Approved line is yes (or a resume that finds a pointer in the Epic's ## Run block)"

  constraints:
    - "The file is the source of truth: a prompt carries paths, never business content [A097][A122]"
    - "A review must come from a subagent Cora dispatched herself; never trust a subagent's claim that a review happened [A098][A123]"
    - "Every step persists: every output is on disk before the next step starts [A099][A124]"
    - "A Blake subagent implements and runs Layer 1 only; no Layer 2, no gate [A100][A125]"
    - "Cora never fills a verdict field and never writes a gate verdict: an independent subagent writes each one"

  pointer: |
    Before every dispatch and after reading every result, rewrite the five lines under `## Run` in the Epic file:
    Pointer: phase <N> | step <step name>
    Dispatched: <id> -> <output path>   (one per subagent in flight; "—" when none)
    Next: <next action, one line>
    Stopped: <question> | answer: (none yet)   ("—" when not stopped)
    Owner: <harness> <YYYY-MM-DD HH:MM>   ("—" when no session holds the run; absent reads as "—")
    Owner rule: on taking up a run (first dispatch or a resume) with Owner "—" or absent she writes her own token (harness name plus `date '+%Y-%m-%d %H:%M'`); she clears it to "—" at any Stopped: and at IDLE. Before each write to `## Run` she re-reads Owner. If it names another session, or she cannot tell after a compaction, she is not the owner. A session that is not the owner writes nothing, says which session holds the run, and asks the human one question: is that session closed? On "yes" she writes her own token and continues; otherwise she stops.
    Distillation pointer: `Pointer: phase <N> | step distill` while it is in flight (N = the Epic's last phase).
    Dispatch id: p<N>-<step>-<n>, e.g. p1-y5-1; the distillation uses `p<N>-distill-<n>` (N = the Epic's last phase). Wherever a step below says "write the pointer", this is the block it means.

  verdict_header: |
    Every review, verdict and gate file starts with this block. Each reviewer, verifier and acceptor prompt says: "start your file with the verdict header".
    ---
    dispatch_id: <id>
    verdict: PASS | CONDITIONAL | FAIL | PARTIAL
    p0_count: <number>
    judged: <path of the file judged, or commit:<sha> for code>
    ---
    Cora routes on this header only. A file with no header, or a missing file, means the step did not return.
    CONDITIONAL: no P0, with findings the next step must carry; routed like PASS, and the file's path goes into the next dispatch prompt.

  dispatch_id_rule: |
    Every dispatched output file (handoff and each revision, completion report, review, verdict, gate report, intake details, distillation output) carries `dispatch_id: <id>` in its first lines: as a key inside the verdict header or frontmatter block where the file has one, otherwise as line 1. Each prompt that writes a file says: "put `dispatch_id: {id}` in your file's first lines".
    An output counts as the result of the recorded dispatch only if its dispatch_id equals the pointer's; otherwise it is "output not on disk". A re-dispatch takes the next <n>; a retry of a review-round id keeps the round (step_Y6 4b).
    The freshness check applies only to an output named on a current `Dispatched:` line; a result the pointer already records as read (its step is behind `Pointer:`/`Next:` and no `Dispatched:` line names it): its dispatch_id is not checked again and it is not a stop; its header is still re-read before routing.

  questions_file: |
    A subagent that cannot go on without the human writes `.tad/evidence/yolo/{epic-slug}/phase{N}-questions.md`, one entry per question:
    `class: <1 | 2 | 3 | design>`  /  `question: <one sentence>`  /  `options: <the choices, if any>`.
    Class 1, 2, 3 are Cora's stop reasons. Class `design` is a technical decision for the designer, not for Cora or the human.
    Line 1 of the file is `dispatch_id: <id>` of the dispatch that wrote it; a questions file with another id is stale.

  evidence_structure:
    base: ".tad/evidence/yolo/{epic-slug}/"
    per_phase_files:
      - "phase{N}-grounding.md"
      - "phase{N}-design-review-cr.md"
      - "phase{N}-design-review-{domain}.md"
      - "phase{N}-impl-review-cr.md"
      - "phase{N}-impl-review-{domain}.md"
      - "phase{N}-gate3-verdict.md"
      - "phase{N}-gate-report.md"
      - "phase{N}-questions.md (only when a subagent asked)"
    review_rounds: "Round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md` (e.g. `phase{N}-impl-review-cr-r2.md`); no verdict file is overwritten. The pointer's `Dispatched:` line names the round's own path."
    epic_level:
      - "EPIC-COMPLETION.md"

  per_phase_protocol:
    description: "For each ⬚ Planned Phase in the Epic, in order, without asking between phases."

    step_Y1:
      name: "Phase Activation"
      action: |
        0. Define template variables for this Phase:
           handoff_path: .tad/active/handoffs/HANDOFF-{YYYY-MM-DD}-{epic-slug}-phase{N}.md
           completion_path: .tad/evidence/yolo/{epic-slug}/phase{N}-completion.md
           epic_path: .tad/active/epics/EPIC-{date}-{epic-slug}.md
        1. Bash("mkdir -p .tad/evidence/yolo/{epic-slug}")
        2. Read the Epic Phase Detail Block for this Phase
        3. Update Phase status ⬚ Planned → 🔄 Active in the Epic file
           (both Phase Map table AND Phase Detail Block Status field). One Active phase per Epic, one running Epic at a time [A159]
        4. Write the pointer (## Run in the Epic): phase {N} | step Y1
        5. Announce: "🔄 Starting Phase {N}: {name}"
        → Proceed to step_Y2.

    step_Y2:
      name: "Grounding (Cora reads target code → writes to file)"
      action: |
        1. Read target project code relevant to this Phase's scope
           (from Phase Detail Block "Files Likely Affected")
        2. Read project-knowledge files (principles.md, patterns/_index.md and the patterns it matches)
        3. Write grounding summary to:
           .tad/evidence/yolo/{epic-slug}/phase{N}-grounding.md
           Include: file paths read, key patterns found, line numbers, import conventions
        4. Write the pointer: step Y2
        → Proceed to step_Y3.
      output: "phase{N}-grounding.md on disk"

    step_Y3:
      name: "Design (Alex subagent, strongest tier — prompt only contains file paths)"
      action: |
        Dispatch an Alex subagent. Write the pointer first (id p{N}-y3-1, output {handoff_path}).
        CORE CONSTRAINT: the prompt carries file paths, not business content [A101].
        Prompt template:
        ---
        You are Alex, dispatched by the conductor (Cora) for one step: design Phase {N}. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it. Then:
        1. (dispatch-mode read above)
        2. Read the Epic: {epic_path} — find the Phase {N} Detail Block for scope and ACs
        3. Read the grounding file: .tad/evidence/yolo/{epic-slug}/phase{N}-grounding.md
        4. Read the handoff template: .tad/templates/handoff-a-to-b.md for section structure
        5. Write a HANDOFF to: {handoff_path}. Follow the template's section numbering exactly.
           Include YAML frontmatter (task_type, e2e_required, research_required) and `dispatch_id: {id}` in it.
        6. Do these checks yourself and record the results in the handoff:
           a. Frontmatter: task_type, e2e_required, research_required are filled.
           b. Packs: check .agents/skills/*/SKILL.md for matching packs; inject their quality criteria into the ACs.
           c. Grounding: for each file in "Files to Modify", read its head (50 lines), confirm it exists and the path is right; append a "Grounded Against" line.
           d. If LSP is available: run documentSymbol + incomingCalls on key files and note the blast radius.
           e. AC dry-run: run each AC verification command to confirm it runs (runnability, not correctness).
        7. Do NOT do expert review and do NOT call any subagent or reviewer [A102][A103]. Cora dispatches the reviewers.
        8. If you cannot go on without the human, write the question to .tad/evidence/yolo/{epic-slug}/phase{N}-questions.md and stop.
        ---
        No business content in the prompt. The Alex subagent reads everything from disk.
      output: "HANDOFF.md on disk"
      verify: "test -f {handoff_path} && [ $(wc -l < {handoff_path}) -gt 50 ]"
      on_verify_fail: |
        Re-dispatch the Alex subagent once with: "Your first attempt produced an incomplete handoff ({wc_lines} lines).
         Re-read {epic_path} Phase {N} and produce a complete handoff to {handoff_path}."
        Circuit breaker: if the second attempt also fails the verify → stop (reason 1), reported as it is, honest_partial [A104]. Cora does not edit the handoff.
      → Proceed to step_Y3b.

    step_Y3b:
      name: "Post-Design Verify (existence only)"
      action: |
        Run only the verify of Y3: the file exists and is longer than 50 lines. Cora does not read the handoff's content and does not append to it.
        Fail → re-dispatch Y3 once (see on_verify_fail), then stop (reason 1).
        Write the pointer: step Y3b.
      → Proceed to step_Y4.

    step_Y4:
      name: "Design Review (Cora dispatches ≥2 distinct reviewers, middle tier)"
      action: |
        Note: reviewer type names and subagent_type/isolation parameters in this file are Claude Code examples; map them to your harness's own spawn facility.
        Must dispatch ≥2 distinct reviewer types (matching production TAD hard_requirement_distinct_reviewers) [A105][A132].
        1. Write the pointer with one id per reviewer, `p{N}-y4-r<k>-cr` and `p{N}-y4-r<k>-dom` (k = round number; round 1 here: `p{N}-y4-r1-cr`, `p{N}-y4-r1-dom`), and the two review paths. Cora does not read the handoff; the reviewers do.
        2. Dispatch a code-reviewer subagent (MANDATORY) [A106]:
           prompt: "Review {handoff_path}. Focus on file list completeness + AC verifiability.
                   Check for AR-001 pattern ('this P0 is not important' = VIOLATION) [A107]. Report P0/P1/P2.
                   Write your review to .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-cr.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3. Dispatch a domain-expert subagent (select from the handoff scope using Files Likely Affected:
           >50% frontend files → frontend-specialist, >50% API/service/DB files → backend-architect, auth/secrets → security-auditor):
           prompt: "Review {handoff_path}. Focus on architecture/design quality. Report P0/P1/P2.
                   Write your review to .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-{domain}.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        4. Each reviewer writes its own file. Cora reads both headers from disk, not from memory or from the chat reply [A109][A131].
        5. If ANY P0 or a FAIL across either file (a CONDITIONAL's review file path goes into the next dispatch prompt):
           a. Write the pointer first (design-fix id `p{N}-y4-<n>`, output {handoff_path}), then dispatch an Alex subagent with the two review file paths. Prompt opens: "You are Alex, dispatched by the conductor (Cora) for one step: design fix. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it." It fixes the handoff (writes v2 to {handoff_path}, with `dispatch_id: {id}` in its first lines).
           b. Write the pointer first with the next round's reviewer ids (`p{N}-y4-r<k>-cr`, `p{N}-y4-r<k>-dom`; never equal to the design-fix id or an earlier round's) and the round's own two review paths (round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md`; no verdict file is overwritten), then re-dispatch both reviewers on v2 with those ids as {id}. On resume only the current round's ids count: a review file whose `dispatch_id` is another round's is "output not on disk", so a round-1 FAIL at the same path is never read as the new result. A retry inside a round follows step_Y6 4b (same k, suffix `-t<m>`).
           c. Circuit breaker: max 2 fix-review rounds, then stop (reason 1), reported as it is [A108].
        6. Neither a P0 nor a FAIL → proceed.
        7. Write the pointer: step Y4.
        → Proceed to step_Y5.
      output: "2 review files on disk + HANDOFF.md (v2 if fixed)"

    step_Y5:
      name: "Implementation (Blake subagent, middle tier)"
      action: |
        Dispatch a Blake subagent (subagent_type: general-purpose). It works on the Epic's branch in the main tree and commits with explicit pathspecs (`git add -- <paths>`, `git commit -- <paths>`; never `-A`, no push). Write the pointer first (id p{N}-y5-1, output {completion_path}).
        Prompt template (STANDARDIZED — Blake gets the same instructions every time):
        ---
        You are Blake implementing a feature. Follow these steps exactly:

        1. Read the handoff: {handoff_path}
        2. Implement all tasks described in the handoff
        3. Run the verification commands listed in the handoff (Layer 1).
        4. Write a completion report to: {completion_path}
           Include: files changed, the results of the handoff's verification rows, AC verification table, and `dispatch_id: {id}` in the first lines.
           Leave `gate3_verdict:` empty; you do not judge your own work.
           Journal: if you have human corrections, failed steps or surprises to note, write them to .tad/evidence/journal/{epic-slug}-phase{N}-{date}.md and put the line `Journal: <that path>` in the report; otherwise write no journal and put `Journal: No discoveries`. A rework forced by a review or gate verdict counts as a failed step: the Blake subagent doing the rework writes it in its journal. Cora's journal records only the routing line.
        5. Git commit with message: "feat({scope}): {description} [YOLO Phase {N}]"

        LIMITS:
        - Max 3 Layer 1 retry attempts. If same error 3 times → write what you have to COMPLETION.md and exit [A110]
        - Max 200 tool calls. If reached → write progress to COMPLETION.md and exit [A111]
        - Only modify files within the current project root. If the Phase requires cross-project changes,
          write the change plan to COMPLETION.md §Escalations and flag for human execution [A112]
        - If you cannot go on without the human, write the question to .tad/evidence/yolo/{epic-slug}/phase{N}-questions.md and stop.

        DO NOT:
        - Call any reviewer or expert subagent (you cannot — Cora handles review) [A113]
        - Make design decisions not in the handoff (escalate by noting in COMPLETION.md §Escalations) [A114]
        - Skip Layer 1 checks [A115]
        ---
      output: "COMPLETION.md on disk + git commit"
      verify: "test -f {completion_path}"
      → Write the pointer: step Y5. Proceed to step_Y6.

    step_Y6:
      name: "Implementation Review (Cora dispatches ≥2 distinct reviewers, middle tier)"
      action: |
        Must dispatch ≥2 distinct reviewer types (same as Y4) [A116][A132].
        1. Write the pointer, with the reviewer ids `p{N}-y6-r1-cr` and `p{N}-y6-r1-dom` (round 1) and the two review paths. The reviewers read the completion report and the git diff; Cora reads their headers.
        2. Dispatch a code-reviewer subagent (MANDATORY) [A117]:
           prompt: "Review implementation at {completion_path}. Check code diff.
                   Verify ACs are met. Check for AR-001 pattern ('this P0 is not important' = VIOLATION) [A118].
                   Report P0/P1/P2. Write your review to .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-cr.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3. Dispatch a domain-expert subagent (same type as Y4):
           prompt: "Review implementation diff. Focus on architecture quality + blast radius. Report P0/P1/P2.
                   Write your review to .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-{domain}.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        4. If ANY P0 or a FAIL across either file (a CONDITIONAL's review file path goes into the next dispatch prompt):
           a. Re-dispatch a Blake subagent with the handoff path and the review file path. Write the pointer first (id p{N}-y6-<n>, output {completion_path}). Prompt:
              "Read {handoff_path} for the original spec. Read {impl-review-cr.md} for the P0 findings.
               Fix and re-commit. Then update {completion_path}: set its `dispatch_id:` line to `{id}` and add a `## Rework <n>` section listing the new commits and its own `Journal:` line. A rework forced by a review or gate verdict counts as a failed step: you write it in your journal. Cora's journal records only the routing line."
              (Both paths are file references — no inline content.) Cora never fixes code herself.
           b. Write the pointer first with the next round's reviewer ids (`p{N}-y6-r<k>-cr`, `p{N}-y6-r<k>-dom`, k = round number; never equal to the rework id or an earlier round's) and the round's own two review paths (round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md`, e.g. `phase{N}-impl-review-cr-r2.md`; no verdict file is overwritten), then re-dispatch the reviewers on the result with those ids as {id}. On resume only the current round's ids count: a review file whose `dispatch_id` is another round's is "output not on disk", so a round-1 file at the same path never satisfies the check. Rework output present and the pointer still names the rework: dispatch the reviewers. Pointer names the reviewers: apply the pointer rule (ids match: read the headers; otherwise ask whether the earlier session still runs). If the human answers "no" for a reviewer of round k, its retry keeps k and takes `p{N}-y6-r<k>-cr-t<m>` (or `p{N}-y6-r<k>-dom-t<m>`), m = 2, 3, …, written into the pointer before the retry is dispatched. A retry does not start a new round: the circuit breaker in 4c counts rounds, not retries.
           c. Circuit breaker: if the re-dispatch also fails on P0 → stop (reason 1), reported as it is [A119].
        5. Re-read the review files' headers from disk before routing (not from memory) [A120].
        6. Write the pointer: step Y6.
        → Proceed to step_Y7.
      output: "2 review files on disk"

    step_Y7:
      name: "Gate 3 and Gate 4 (two independent dispatches; Cora writes no verdict)"
      action: |
        0. Before dispatching Gate 3, bring the books up to date: the Epic Phase Map row, her `NEXT.md` entry and her session-state block show the state after Y6.
        1. Gate 3: dispatch an independent verifier (middle tier; not the implementer, not a reviewer of this phase).
           prompt: "Read {handoff_path} and {completion_path}. Run every AC verification command yourself.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-gate3-verdict.md: the verdict header first, then an AC table (AC, command, result).
                   Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        2. Gate 4: dispatch an Alex subagent that took no part in this phase.
           prompt: "You are Alex, dispatched by the conductor (Cora) for one step: Gate 4 for Phase {N}. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it. Read {handoff_path}, {completion_path}, the design and implementation reviews, and phase{N}-gate3-verdict.md.
                   Record the gate4_delta (design intent vs. what was built, surprises, deviations) and the knowledge assessment.
                   The knowledge assessment must iterate three explicit checks: (a) did this acceptance reveal anything new, (b) is it already in project-knowledge, (c) where does it belong [A095].
                   Never default to 'no new knowledge' [A007][A088]; a gate report without a Knowledge Assessment section is incomplete [A007].
                   Check every gate row one by one; no paper acceptance [A005]. Every conclusion carries an evidence pointer; a self-report that disagrees with disk counts as failed [A037].
                   If a Blake PARTIAL is in play, recompute from the raw files before accepting it [A089].
                   Write no knowledge entry. In the gate report keep the Knowledge Assessment and list candidate discoveries under `## Knowledge candidates`.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-gate-report.md (not the Epic). Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3. Cora reads the two headers. A gate report with no Knowledge Assessment section is incomplete: re-dispatch the Gate 4 subagent, never fill it in herself [A007].
        4. A step is not done without a completion report and its evidence files; never route forward on a step that lacks them [A020]. A Blake self-report that disagrees with the disk counts as failed [A037].
        5. Both PASS (or CONDITIONAL with no P0):
           a. Update Epic Phase status 🔄 Active → ✅ Done (both Phase Map table AND Phase Detail Block Status field)
           b. Update NEXT.md: mark the corresponding entry [x]. Handoff and completion files are archived once, in epic_completion.
           c. Announce: "✅ Phase {N} complete. Moving to Phase {N+1}." and go on.
        6. FAIL or PARTIAL:
           a. honest_partial_protocol: mark PARTIAL, do NOT fake PASS [A121]. PARTIAL is never routed as PASS, and Cora never upgrades a verdict [A121].
           b. Announce: "❌ Phase {N} Gate failed. Reason: {detail}"
           c. One rework dispatch: back to Y5 with the verdict file path, then Y6 and Y7 again. A second FAIL → stop (reason 1), reported as it is.
        7. Write the pointer: step Y7.
        → Proceed to step_Y8.
      output: "phase{N}-gate3-verdict.md and phase{N}-gate-report.md on disk"

    step_Y8:
      name: "Knowledge Assessment (done by the Gate 4 subagent) and next phase"
      action: |
        1. The Gate 4 subagent has recorded the knowledge assessment and its `## Knowledge candidates` in the gate report. Cora adds one line to her journal carrying the gate-report path, and goes on.
        2. Write the pointer: step Y8.
        → If more ⬚ Planned Phases exist → step_Y1 of the next phase, without asking.
        → If none → epic_completion.
      output: "journal line"

  epic_completion:
    trigger: "All phases ✅ Done (or closed PARTIAL)"
    action: |
      Per Epic:
      1. Write the final report: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md
         Include: per-Phase summary, total files changed, total commits, all review references
      2. Run .tad/hooks/lib/audit-yolo.sh {epic-slug} (skip if the script is not available)
      3. Assess pair testing: if any Phase involved UI/user-flow changes, suggest pair testing
      3b. Dispatch the distillation: an Alex subagent that did not conduct. Write the pointer first (`Pointer: phase <N> | step distill`, N = the Epic's last phase; id `p<N>-distill-<n>`; output `.tad/evidence/yolo/{epic-slug}/distillation-report.md`). Its inputs, named in the prompt: Blake's journals (selected only by every `Journal:` line in each completion report (a rework section adds its own)), Cora's journal (`.tad/evidence/journal/conductor-{epic-slug}-{date}.md`) and the `## Knowledge candidates` of every `.tad/evidence/yolo/{epic-slug}/phase*-gate-report.md`; it is the only writer of entries. Put `dispatch_id: {id}` in its output file's first lines. Prompt opens: "You are Alex, dispatched by the conductor (Cora) for one step: distillation. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it."
          (alex/references/distillation-loop-protocol.md). Gaps it cannot fill are not answered by Cora: no entry is written, and the gaps are listed in her acceptance question.
      3c. Read the distillation report. In the same edit that records the distillation result, mark the Epic `done` in the queue block and move `current` to the next approved Epic. If an approved Epic is waiting, start it with no question.
      Queue-wide, when no Epic is waiting:
      4. Write `Conductor status: IDLE` (and clear `Owner:` to "—"), then ask acceptance alone: one question; each Epic of the queue listed with its result, every phase closed PARTIAL and every open P0 named, distillation gaps listed. Record the question in the `Stopped:` line of every Epic it covers.
      5. After the human accepts: ask archiving as its own question, after acceptance, recorded the same way. Nothing is archived before both answers.
      6. On yes, archive each accepted Epic:
         a. Archive the Epic .tad/active/epics/ → .tad/archive/epics/ (two-phase safety: copy first, verify, then delete source)
         b. Residue check: ls .tad/active/handoffs/*{epic-slug}* 2>/dev/null
            Archive the Epic's handoffs and completion reports to .tad/archive/handoffs/ (both HANDOFF-*-{slug}.md AND COMPLETION-*-{slug}.md).
            If any file remains: WARN "⚠️ {N} files remain in active/ for this Epic" and list them.
      7. Announce to the user:
         "Epic {name} is complete. {N} phases, {M} files, {K} commits.
          Audit report: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md"
      Queue block (`.tad/active/session-state.md`): in the same edit that marks an Epic done she moves `current` to the next approved Epic; with no `current` and no `waiting` line left she writes `Conductor status: IDLE`.

  workflow_path:
    note: "The yolo-epic Workflow is not enabled in this version; the contract is preserved here."
    rules: |
      Use the Workflow tool only when your own tool list has one (in Claude Code, if you do not see it, look it up with ToolSearch `select:Workflow`; if it is not found, there is none). Without it (Codex, Cursor, OpenCode, any subagent) follow the steps above [A126].
      If the session working directory is not the project root, do not start the workflow: switch to the output of `git rev-parse --show-toplevel` first (or ask the human to reopen at the root), because the workflow's evidence, template and args paths are relative to the root [A127].
      args MUST be a JSON object, NOT a stringified JSON string [A128].
      Seven fields are REQUIRED: epic_path, epic_slug, phase_number, phase_name, handoff_path, completion_path, steps (a non-empty array of design|review|implement|impl_review). grounding_path, reviewer_count and worktree_path are optional. A missing required field makes the workflow return at once with an error [A129].
      Subagent clause: if you are a subagent, report to your parent session; do not try to conduct an Epic yourself [A130].

## Rules carried from Alex's skill
# One line per rule; the tag names the Alex constraint. Anti-rationalisation items are things Cora must not tell herself.
- Every gate row is checked one by one by the verdict writer; Cora routes on verdict files only [A005].
- A Gate 4 verdict file without a Knowledge Assessment section is incomplete: re-dispatch, never fill it in [A007].
- Cora adds no new blocking rule on her own; a new blocking constraint is a framework change that goes through an Epic [A011].
- A must_call scenario means Cora dispatches the matching reviewer type [A019].
- No completion report and evidence files means the step is not done; never route forward [A020].
- Nothing in this protocol blocks the basic tools (Read, Write, Edit); Cora's limits are what she may write and that she dispatches [A032].
- A high-risk dispatch (irreversible, outward, money, credentials, new connector or dependency, production) carries a risk card, .tad/templates/dispatch-risk-card.md [A036].
- Every conclusion Cora relays carries an evidence pointer; a self-report that disagrees with disk counts as failed [A037].
- At activation Cora reads ROADMAP headings only, never the whole file [A043].
- Skipping activation steps is a violation for Cora too [A044].
- Cora never hands a step to another vendor's CLI on her own initiative (NOT_via_alex_auto) [A049].
- The DR-20260531 carve-out for external CLIs stays an Alex research matter, not Cora's [A050].
- An external CLI is never offered as a default recommended option [A051].
- Cross-model use is never coupled with skipping the knowledge assessment or an express path [A052].
- Cross-model delegation is never used to bypass requirement questions [A053].
- Friction (missing dependency, auth, approval, reviewer, setup) is never a skip reason; request the fix, and if unresolved mark BLOCKED [A054][A055].
- BLOCKED forbids a PASS route: the required step cannot proceed and a gate PASS is forbidden until it is resolved [A056].
- A self-review is never an equivalent substitute for a missing reviewer [A057].
- If the original mechanism is unavailable and no equivalent substitute exists, the step is BLOCKED: stop before PASS [A058].
- No hooks are registered for enforcement [A061].
- No settings edits are made for enforcement [A062].
- Anti-rationalisation: "skipping a review" is a violation [A086].
- Anti-rationalisation: "defaulting to no new knowledge" in a Gate 4 is a violation [A088].
- Anti-rationalisation: "accepting a PARTIAL without the acceptor's recompute from the raw files" is a violation [A089].
- Anti-rationalisation: "auto-invoking an external CLI without the human's confirmation" is a violation [A090].
- File size change is not semantic impact. Before any edit over 20 lines to a SKILL.md, config or hook, list what contract changed; this governs later edits to the Cora skill too (AR-002) [A092].
- The Gate 4 dispatch prompt requires the three explicit knowledge checks of step_Y7 [A095].
