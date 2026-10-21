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
    Before every dispatch and after reading every result, rewrite the five lines under `## Run` in the Epic file (before she writes a `Dispatched:` line she runs `/bin/bash .tad/hooks/lib/cora-check.sh dispatches <the Epic>` (from the repo root) and journals its `count:`):
    Pointer: phase <N> | step <step name>
    Dispatched: <id> -> <output path>   (one per subagent in flight; "—" when none)
    Next: <next action, one line>
    Stopped: <question> | answer: (none yet)   ("—" when not stopped)
    Owner: <harness> <YYYY-MM-DD HH:MM>   ("—" when no session holds the run; absent reads as "—")
    Owner rule: on taking up a run (first dispatch or a resume) with Owner "—" or absent she writes her own token (harness name plus `date '+%Y-%m-%d %H:%M'`); she clears it to "—" in the same edit that writes `Stopped:` (or `IDLE`), as the last change of that edit; on the human's answer she takes up the run again under this rule. Before each write to `## Run` she re-reads Owner. If it names another session, or she cannot tell after a compaction, she is not the owner. A session that is not the owner writes nothing, says which session holds the run, and asks the human one question: is that session closed? On "yes" she writes her own token and continues; otherwise she stops. A "yes" continues the resume order (cora/SKILL.md Resume): present outputs routed, missing ones re-dispatched, without another question.
    Distillation pointer: `Pointer: phase <N> | step distill` while it is in flight (N = the Epic's last phase).
    Dispatch id: p<N>-<step>-<n>, e.g. p1-y5-1; the distillation uses `p<N>-distill-<n>` (N = the Epic's last phase); a spike uses `p<N>-y4-sp<k>` or `p<N>-y6-sp<k>`; a re-plan keeps its own ids (`p<N>-y4-<n>`, `p<N>-y6-rp<n>`). The counters `<m>` (premise files) and `<k>` (spikes) are independent of `<n>` and of each other. Wherever a step below says "write the pointer", this is the block it means.

  verdict_header: |
    Every review, verdict and gate file starts with the verdict header of .tad/templates/review-contract.md §1 (keys and self-consistency rule). Each reviewer, verifier and acceptor prompt says: "start your file with the verdict header".
    Cora routes on this header only, and on the spike and premise headers below. A file with no header, a header that breaks the contract's self-consistency rule, or a missing file, means the step did not return.
    What a P0 is, including AR-001 ("this P0 is not important" = VIOLATION), is defined once in .tad/templates/review-contract.md §3 (a defect touching credentials, destructive commands, the stop list or a SAFETY principle is a P0 with (a) alone); the writer applies it in its own file; Cora never reclassifies [A107][A118][A081].
    CONDITIONAL: no P0, with findings the next step must carry; routed like PASS, and the file's path goes into the next dispatch prompt.

  dispatch_id_rule: |
    Every dispatched output file (handoff and each revision, completion report, review, verdict, gate report, intake details, distillation output, premise file, spike file, look file) carries `dispatch_id: <id>` in its first lines: as a key inside the verdict header or frontmatter block where the file has one, otherwise as line 1. Each prompt that writes a file says: "put `dispatch_id: {id}` in your file's first lines".
    History rule: a dispatch that writes a file whose first lines already carry a `dispatch_id:` sets that line to its own id and adds the earlier id(s) to a `dispatch_history:` line directly below it (key inside the header or frontmatter where the file has one); `/bin/bash .tad/hooks/lib/cora-check.sh dispatches <Epic>` (from the repo root) counts the ids of both keys. On reading a rewritten file Cora also checks its `dispatch_history:` holds the id the pointer named before (a missing one: header broken, re-dispatch once).
    An output counts as the result of the recorded dispatch only if its dispatch_id equals the pointer's; otherwise it is "output not on disk". A re-dispatch takes the next <n>; a retry of a review-round id keeps the round (step_Y6 4b).
    The freshness check applies only to an output named on a current `Dispatched:` line; a result the pointer already records as read (its step is behind `Pointer:`/`Next:` and no `Dispatched:` line names it): its dispatch_id is not checked again and it is not a stop; its header is still re-read before routing.
    Premise file (a re-plan's first output, Y4 5c / Y6 4c): `phase{N}-premise-<m>.md`, header `---` / `dispatch_id: <id>` / `spike_needed: yes | no` / `---`, then `premise:` (one sentence the failed fixes share), `observation:` (one check whose result differs if the premise is false; it may include the round's empirical P0s), `observed:` (the result, or `(pending)`), and at Gate 2 `replaces: <mechanism> -> <replacement>` (the mechanism or rule set the failed fixes share, which the re-plan removes, and the structure that takes its place; `(pending)` for the replacement when `spike_needed: yes`, dispatch 2 states it in the handoff §1; a Gate 3 premise file has no `replaces:` line). `<m>` counts the re-plans of the phase; both dispatches of one re-plan use the same `<m>`.
    Look file (design dispatch, Y3 or a re-plan): `phase{N}-look.md`, line 1 `dispatch_id: <id>` (the design dispatch's id); not routed: Cora does not read it, the Gate 2 reviewers do.
    Spike file (Y4 5 / Y6 4): `phase{N}-spike-<k>.md`, header `---` / `dispatch_id: <id>` / `confirmed: <n>` / `refuted: <n>` / `unsettled: <n>` / `---`, then one entry per P0 labelled `empirical` and not `reproduced: yes` in each review file of the round (the same P0 in two review files is two entries): the run, `observed:`, `confirmed | refuted | unsettled`. `confirmed + refuted + unsettled` equals the sum of `empirical_p0 − reproduced_p0` over the round's review files, else the spike did not return (reason 1). An unsettled P0 (cap reached, or it needs a paid run) counts as confirmed for routing.

  questions_file: |
    A subagent that cannot go on without the human writes `.tad/evidence/yolo/{epic-slug}/phase{N}-questions.md`, one entry per question:
    `class: <1 | 2 | 3 | design>`  /  `question: <one sentence>`  /  `options: <the choices, if any>`.
    Class 1, 2, 3 are Cora's stop reasons. Class `design` is a technical decision for the designer, not for Cora or the human.
    Line 1 of the file is `dispatch_id: <id>` of the dispatch that wrote it; a questions file with another id is stale.

  evidence_structure:
    base: ".tad/evidence/yolo/{epic-slug}/"
    per_phase_files:
      - "phase{N}-grounding.md"
      - "phase{N}-look.md (only when the phase acts on a system outside the repo or on real data)"
      - "phase{N}-design-review-consistency.md"
      - "phase{N}-design-review-risk.md or phase{N}-design-review-fit.md (the second Gate 2 reviewer; fit when the handoff's risk_triggers is [none])"
      - "phase{N}-gate3-verdict.md (Gate 3 run reviewer)"
      - "phase{N}-impl-review-consistency.md"
      - "phase{N}-impl-review-domain.md (only when security, data or money is listed)"
      - "phase{N}-gate-report.md"
      - "phase{N}-gate4/ (the acceptor's evidence: screenshots, run logs, quoted lines)"
      - "phase{N}-premise-<m>.md (only after a re-plan)"
      - "phase{N}-spike-<k>.md (only after a spike)"
      - "phase{N}-questions.md (only when a subagent asked)"
    review_rounds: "Round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md` (e.g. `phase{N}-impl-review-consistency-r2.md`); no verdict file is overwritten. The pointer's `Dispatched:` line names the round's own path."
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
           f. Look first: when the phase's result acts on a system outside this repo or reads or writes real user or project data, do the read-only look of .agents/skills/alex/references/design-protocol.md step1_2_look_first before you design, and write .tad/evidence/yolo/{epic-slug}/phase{N}-look.md (`dispatch_id: {id}` in line 1); the handoff frontmatter carries `look_first: <that path>` or `look_first: "not-needed: <reason>"`.
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
      name: "Design Review — Gate 2 (Cora dispatches two reviewers with different lenses, middle tier)"
      action: |
        Note: reviewer type names and subagent_type/isolation parameters in this file are Claude Code examples; map them to your harness's own spawn facility.
        Gate 2 = two reviewers with different lenses: consistency plus one risk reviewer covering the handoff's risk_triggers, or fit when they are none (review contract §5, §8); never two of the same lens [A105][A132].
        1. Write the pointer with one id per reviewer, `p{N}-y4-r<k>-consistency` and `p{N}-y4-r<k>-risk` (k = round number; round 1 here: `p{N}-y4-r1-consistency`, `p{N}-y4-r1-risk`), and the review paths. The second reviewer writes `phase{N}-design-review-risk.md`, or `phase{N}-design-review-fit.md` when it finds `risk_triggers: [none]`: the pointer names both possible paths for that id, and the file whose `dispatch_id` matches is its result. Cora does not read the handoff; the reviewers do.
        2. Dispatch the consistency reviewer (MANDATORY; code-reviewer on Claude Code) [A106]:
           prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION) [A107]. Lens: consistency.
                   Object: {handoff_path}. Reference: {epic_path} ## Requirement and ## Result contract, and the handoff. Previous round: {same lens's file or none}. Earlier rounds: {every earlier review file of the phase, all lenses, or none}. Spike/premise: {file or none}.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-consistency.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3. Dispatch the risk-or-fit reviewer (the lens named in the contract mapping, e.g. security-auditor, product-expert):
           prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION) [A107]. Lens: risk for every entry of the handoff's risk_triggers, or fit when they are none.
                   Object: {handoff_path}. Reference: {epic_path} ## Requirement and ## Result contract, and the handoff. Previous round: {same lens's file or none}. Earlier rounds: {every earlier review file of the phase, all lenses, or none}. Spike/premise: {file or none}. Questions path (fit only): .tad/evidence/yolo/{epic-slug}/phase{N}-questions.md.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-risk.md (or phase{N}-design-review-fit.md when risk_triggers is none). Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        4. Each reviewer writes its own file. Cora reads the headers of the round's files from disk, not from memory or from the chat reply [A109][A131]; the current state of a lens is its latest file. A file with `lens: fit` that wrote the phase questions file (line 1 = its id): class 2 -> stop (reason 2); class `design` -> named in the next design-fix prompt.
        5. If ANY P0, FAIL or PARTIAL across the files (a CONDITIONAL's review file path goes into the next dispatch prompt): first read the header keys `fix_introduced_p0`, `repeat_class_p0` and `enumerate_p0` of the round's files (a no-patch trigger is any of them above 0) and test the round for shrinking (review contract §7, Gate 2). A no-patch trigger or a round that is not shrinking goes to 5c, never to 5a. Otherwise 0 (spike rule), then 5a.
           0. Empirical P0 spike (skipped when a re-plan trigger of 5c fires: a no-patch trigger or a round that is not shrinking; its empirical P0s go to the re-plan). If the round's sum of `empirical_p0 − reproduced_p0` over its review files is above 0, Cora first dispatches one Blake spike (middle tier) for the empirical P0s of the round that no reviewer reproduced: id `p{N}-y4-sp<k>`, pointer `step Y4 spike`, output `.tad/evidence/yolo/{epic-slug}/phase{N}-spike-<k>.md` (header in dispatch_id_rule). Blake spike prompt: "You are Blake, dispatched for one spike. Read the review files named ({review paths}, and the premise file if named). For each P0 labelled `empirical` and not marked `reproduced: yes`, settle it by the smallest run or measurement. Write {spike path}: `dispatch_id: {id}` in its first lines, the spike header (`confirmed`, `refuted`, `unsettled`), then one entry per such P0 per review file (the same P0 in two review files is two entries): the run, `observed:` and `confirmed | refuted | unsettled`. LIMITS: one dispatch, at most 60 tool calls; write only that file and scratch; no commit and no change to the work under review; no paid model run (a paid run is a stop, reason 3, before it happens, so write unsettled and say why); questions go to the phase questions file as in step_Y5; no verdict on any work; do not call any reviewer [A113]."
              Route on the spike header plus the review headers (a reproduced P0 routes as confirmed; with no spike dispatched the route is read from the review headers alone): `confirmed` or `unsettled` above 0, or `reproduced_p0` above 0, or `p0_count` above `empirical_p0` in any file -> 5a (design fix), its prompt naming the review files and the spike file. Otherwise (every P0 empirical, none reproduced, all refuted) -> 5b on the unchanged handoff. Either way the next round's reviewer prompts name the spike file: a `refuted` is a claim the independent reviewer re-checks, never a Blake verdict on a reviewer. A spike is not a review round: no `new_p0` effect and no round number; at most one per round; it counts toward the Budget estimate. A missing spike header or file: re-dispatch once, then stop (reason 1).
           a. Write the pointer first (design-fix id `p{N}-y4-<n>`, output {handoff_path}), then dispatch an Alex subagent with the review file paths. A P0 with origin introduced_by_fix is fixed as a class (review contract §3); at Gate 2 it never reaches this plain design fix, because it is a no-patch trigger and the class fix happens inside the 5c re-plan. Prompt opens: "You are Alex, dispatched by the conductor (Cora) for one step: design fix. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it." It fixes the handoff (writes v2 to {handoff_path}, with `dispatch_id: {id}` in its first lines and the earlier id(s) on a `dispatch_history:` line directly below it).
           b. Write the pointer first with the next round's reviewer ids (`p{N}-y4-r<k>-<lens>`; never equal to the design-fix id or an earlier round's) and the paths of the lenses re-dispatched (round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md`; no verdict file is overwritten), then re-dispatch on v2 only the lens(es) whose file had a P0, FAIL or PARTIAL (review contract §7), on the fix diff, the open P0 list and the sections the fix touches, with those ids as {id}. On resume only the current round's ids count: a review file whose `dispatch_id` is another round's is "output not on disk", so a round-1 FAIL at the same path is never read as the new result. A retry inside a round follows step_Y6 4b (same k, suffix `-t<m>`). From round 2 on, each reviewer prompt also names that lens's file from the round before and `Earlier rounds: {every earlier review file of the phase, all lenses}`: judge the current handoff first and form the findings, then use the old files only to label `repeat_of`, `new_p0` and `origin` (the same lens's previous file stays the base of `new_p0`; other lenses' files are never a source of findings). When a spike or premise file exists for the round, the prompts name it too.
           c. No-patch trigger or not shrinking, then upstream [A108]: when any file of the round has `fix_introduced_p0`, `repeat_class_p0` or `enumerate_p0` above 0 (a no-patch trigger), or the round is not shrinking (review contract §7, Gate 2: the sum of `p0_count` is not below the same lenses' previous sum; tested only for a round k ≥ 2 with a P0, never for the first round after a re-plan), the fault is above the patches: write the pointer, then dispatch an Alex subagent (design fix, next id `p{N}-y4-<n>`, with every review file of the phase) to find the root cause first and re-plan the design at that level on the existing handoff (same path, not from scratch). The re-plan starts with the premise file: dispatch 1 (the pointer's `Dispatched:` names `.tad/evidence/yolo/{epic-slug}/phase{N}-premise-<m>.md`) writes it first (header and `premise:`, `observation:`, `observed:`, `replaces:` per dispatch_id_rule; dispatch 1 always writes the mechanism in `replaces:`). If a read, grep or local command suffices (no model run) Alex makes the observation itself: `spike_needed: no`, `observed:` filled, and in the same dispatch it re-plans the handoff (same path, same `dispatch_id`, the earlier id(s) added to its `dispatch_history:` line, premise file cited in §1). If it needs a build or run: `spike_needed: yes`, `observed: (pending)`, no handoff change, return. Cora checks the premise file like any output (exists, header present, `dispatch_id` equals the pointer's; else re-dispatch once, then stop, reason 1) and reads its header only. `spike_needed: no` -> she checks the handoff's `dispatch_id` equals the same id (else "output not on disk"), then step b. `spike_needed: yes` -> pointer `step Y4 spike`, a spike as in step 0 with the premise file as its question, then dispatch 2: a re-plan with the next re-plan id, pointer naming {handoff_path}, prompt naming the premise and spike files; it writes the handoff only (its id and `dispatch_history:` per the history rule), citing both in §1 and stating the replacement of `replaces:`. No round spike is dispatched for a round in which this trigger fired. All these dispatches count toward the running total against the Budget estimate; a paid run is reason 3. The prompt says: the re-plan writes a class 2 question to the phase questions file (see questions_file) instead of re-planning, and that is a stop (reason 2), when (a) it would change the Epic's result or scope, (b) it cannot name a structure that replaces rather than adds (the replacement would be one more rule beside the old ones; in dispatch 2 when the spike was needed), or (c) an earlier premise file of the phase names the same mechanism in its `replaces:` line. The question's options: cut this item / narrow the scope / change the approach / withdraw; never "accept the risk and continue". The question wins over a `spike_needed: no` handoff change, which is then not made. The question rule applies to either dispatch. Otherwise the next round (step b) reviews the re-planned handoff; she reads the questions file after the re-plan returns. After a re-plan the next round is a new baseline and is not compared. A round count alone never ends a run; the run stops for the stop list, twice the Budget estimate (reason 2) or a step that cannot run (reason 1), reported as it is; a P0 that stays unfixed from round to round is bounded by the not shrinking test and that guard. A gate FAIL or PARTIAL is step_Y7 6c; [A104] and [A110] are a writer's own retries, not review rounds.
        6. No P0, no FAIL and no PARTIAL → proceed (a P1 is carried: CONDITIONAL).
        7. Write the pointer: step Y4.
        → Proceed to step_Y5.
      output: "2 review files on disk (consistency + risk or fit) + HANDOFF.md (v2 if fixed)"

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
      name: "Gate 3 review (Cora dispatches the run and consistency reviewers, plus domain when listed; middle tier)"
      action: |
        Gate 3 = run plus consistency, plus one domain reviewer when the risk_triggers header key of the phase's latest risk or fit design review file lists security, data or money (review contract §5, §8); they replace the two implementation reviewers and the separate verifier; never two of the same lens [A116][A132].
        1. Write the pointer, with the reviewer ids `p{N}-y6-r1-run`, `p{N}-y6-r1-consistency` (and `p{N}-y6-r1-domain` when listed) (round 1) and the review paths per evidence_structure. The reviewers read the completion report and the git diff; Cora reads their headers. A rubric AC: the judge first (gate skill Rubric Evaluation Protocol), its file named in the run prompt.
        2. Dispatch the run reviewer (MANDATORY; it writes the Gate 3 verdict):
           prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION) [A118]. Lens: run.
                   Object: the commits listed in {completion_path}. Reference: {epic_path} ## Requirement and ## Result contract, and {handoff_path} (§9.1 and real_paths). Previous round: {same lens's file or none}. Spike/premise: {file or none}.
                   Re-run every §9.1 row and real_path yourself, by hand, in one throwaway copy of the project (no script executes handoff commands), into `## AC runs`, `## Real paths` and `## Not run`; run `bash .tad/hooks/lib/gate3-check.sh {handoff_path} <your file>` before saving — it only checks that evidence (review contract §5 run).
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-gate3-verdict.md and set the completion report's gate3_verdict marker. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3. Dispatch the consistency reviewer (MANDATORY; code-reviewer on Claude Code) [A117]:
           prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION) [A118]. Lens: consistency.
                   Object: the commits listed in {completion_path}. Reference: {epic_path} ## Requirement and ## Result contract, and {handoff_path}. Previous round: {same lens's file or none}. Spike/premise: {file or none}.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-consistency.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
           3b. When listed, dispatch the domain reviewer (security-auditor, database-expert, backend-architect on Claude Code):
           prompt: "Load .tad/templates/review-contract.md and follow it; its P0 rule includes AR-001 ('this P0 is not important' = VIOLATION). Lens: domain (the security, data or money entries of the handoff's risk_triggers).
                   Object: the commits listed in {completion_path}. Reference: {epic_path} ## Requirement and ## Result contract, and {handoff_path}. Previous round: {same lens's file or none}. Spike/premise: {file or none}.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-domain.md. Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3c. A consistency file whose `risk_triggers:` header adds security, data or money not in the handoff's list: the domain lens runs in the next round, even with no P0 (routing, not a verdict).
        4. If ANY P0, FAIL or PARTIAL across the files (a PARTIAL whose `## Blocked` names friction a rework cannot fix, such as a dependency to install or an approval, is a stop, reason 1, reported as it is; a CONDITIONAL's review file path goes into the next dispatch prompt):
           0. Empirical P0 spike (skipped when the re-plan trigger of 4c fires: its empirical P0s go to the re-plan). If the round's sum of `empirical_p0 − reproduced_p0` over its review files is above 0, Cora first dispatches one Blake spike (middle tier) for the empirical P0s of the round that no reviewer reproduced: id `p{N}-y6-sp<k>`, pointer `step Y6 spike`, output `.tad/evidence/yolo/{epic-slug}/phase{N}-spike-<k>.md`, prompt and limits as in step_Y4 5.0. Route (a reproduced P0 routes as confirmed; with no spike dispatched the route is read from the review headers alone): `confirmed` or `unsettled` above 0, or `reproduced_p0` above 0, or `p0_count` above `empirical_p0` in any file -> 4a (rework), its prompt naming the review files and the spike file; otherwise (every P0 empirical, none reproduced, all refuted) -> 4b on the unchanged code. Either way the next round's reviewer prompts name the spike file. A spike is not a review round (no `new_p0` effect, no round number), at most one per round, counted toward the Budget estimate.
           a. Re-dispatch a Blake subagent with the handoff path and the review file path. Write the pointer first (id p{N}-y6-<n>, output {completion_path}). Prompt:
              "Read {handoff_path} for the original spec. Read the review files named ({review paths}) for the P0 findings. A P0 with origin introduced_by_fix is fixed as a class (review contract §3).
               Fix and re-commit. Then update {completion_path}: set its `dispatch_id:` line to `{id}`, add the earlier id to a `dispatch_history:` line directly below it, and add a `## Rework <n>` section listing the new commits and its own `Journal:` line. A rework forced by a review or gate verdict counts as a failed step: you write it in your journal. Cora's journal records only the routing line."
              (Both paths are file references — no inline content.) Cora never fixes code herself.
           b. Write the pointer first with the next round's reviewer ids (`p{N}-y6-r<k>-<lens>`, k = round number; never equal to the rework id or an earlier round's) and the paths of the lenses re-dispatched: only the lens(es) with an open P0, FAIL or PARTIAL, plus the run lens after every rework (review contract §7) (round 1 writes the path as named; round k ≥ 2 writes the same name with `-r<k>` before `.md`, e.g. `phase{N}-impl-review-consistency-r2.md`; no verdict file is overwritten), then re-dispatch those reviewers on the result with those ids as {id}. On resume only the current round's ids count: a review file whose `dispatch_id` is another round's is "output not on disk", so a round-1 file at the same path never satisfies the check. Rework output present and the pointer still names the rework: dispatch the reviewers. Pointer names the reviewers: apply the pointer rule (ids match: read the headers; otherwise ask whether the earlier session still runs). If the human answers "no" for a reviewer of round k, its retry keeps k and takes `p{N}-y6-r<k>-<lens>-t<m>`, m = 2, 3, …, written into the pointer before the retry is dispatched. A retry does not start a new round: 4c reads rounds, not retries. From round 2 on, each reviewer prompt names that lens's file from the round before: judge the current code first, then use the old file only to label `new_p0` in the header. When a spike or premise file exists for the round, the prompts name it too.
           c. Gate 3 (implementation) convergence, then upstream [A119]: when review round 3, counted from round 1 or from the last re-plan, still has an open P0 in any file (this contains the former trigger, two consecutive re-review rounds with `new_p0` above 0; `new_p0` stays in every review header), write the pointer, then dispatch an Alex subagent (design fix, id `p{N}-y6-rp<n>`, never equal to a rework or reviewer id, with the handoff and every review file of the phase) to find the root cause and re-plan the handoff at that level. The re-plan starts with the premise file (file mechanics as in step_Y4 5c, without `replaces:`; this Gate 3 (implementation) trigger is its own) with `phase{N}-premise-<m>.md` as `Dispatched:` output, pointer `step Y6 spike` for a needed spike, and dispatch 2 (next id `p{N}-y6-rp<n>`) writing the handoff only (its `dispatch_id` set to the new id, the earlier id(s) added to `dispatch_history:`); no round spike is dispatched for a round in which this trigger fired. The prompt says: a re-plan that would change the Epic's result or scope is written as a class 2 question to the phase questions file (see questions_file) instead, and that is a stop (reason 2); the question wins over a `spike_needed: no` handoff change. Otherwise a Blake rework on the re-planned handoff follows (4a), judged by the next round (4b); she reads the questions file after the re-plan returns. After a re-plan the count starts again: round 3 is counted from the re-plan. A round count alone never ends a run (round 3 with an open P0 triggers the re-plan); the run stops for the stop list, twice the Budget estimate (reason 2) or a step that cannot run (reason 1), reported as it is; a P0 that stays unfixed from round to round is bounded by that guard.
        5. Re-read the review files' headers from disk before routing (not from memory) [A120].
        6. Write the pointer: step Y6.
        → Proceed to step_Y7.
      output: "Gate 3 review files on disk: phase{N}-gate3-verdict.md (run, with its AC runs table), phase{N}-impl-review-consistency.md (+ phase{N}-impl-review-domain.md)"

    step_Y7:
      name: "Gate 4 (one independent dispatch; Cora writes no verdict)"
      action: |
        0. Before dispatching Gate 4, bring the books up to date: the Epic Phase Map row, her `NEXT.md` entry and her session-state block show the state after Y6.
        1. Gate 3 was settled in step_Y6: the run reviewer's phase{N}-gate3-verdict.md (latest round) with the consistency (and domain) files; Cora dispatches no separate verifier.
        2. Gate 4: dispatch an Alex subagent that took no part in this phase.
           prompt: "You are Alex, dispatched by the conductor (Cora) for one step: Gate 4 for Phase {N}. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it. Read {handoff_path}, {completion_path}, the design review files and the Gate 3 review files (phase{N}-gate3-verdict*.md, phase{N}-impl-review-*.md).
                   Act as the human (gate skill Acceptance_By_Real_Use): what he will do with the result, done once for real or in a browser (screenshots / run logs under .tad/evidence/yolo/{epic-slug}/phase{N}-gate4/), judged against {epic_path} ## Requirement, Result contract and Assumptions; run `gate3-check.sh {handoff_path} <latest gate3 verdict>`. Only a real device, a payment or his own account login goes to the human, with the reason. No browser tool: `not-run: no browser tool on <harness>`, verdict on what ran. A paid call or a browser-tool install: write a class 3 question to the phase questions file and stop. A release installs the release archive shape end to end into a throwaway project before the tag (gate skill, Gate 4 item 5) and honours `.tad/project-knowledge/rulings/human-rulings.md` if it exists. End with `## For the human`: the verdict and 3-5 evidence lines; a real run is reported as `real use: <evidence path under the gate4 dir> — <what it showed>` (the same pointer as its `#### Real use` row), and when at least one path the human will use did not run the section also carries `light acceptance: <reason>`.
                   A P0 states a failure scenario and what it blocks (verdict_header).
                   Record the gate4_delta (design intent vs. what was built, surprises, deviations) and the knowledge assessment.
                   The knowledge assessment must iterate three explicit checks: (a) did this acceptance reveal anything new, (b) is it already in project-knowledge, (c) where does it belong [A095].
                   Never default to 'no new knowledge' [A007][A088]; a gate report without a Knowledge Assessment section is incomplete [A007].
                   Check every gate row one by one; no paper acceptance [A005]. Every conclusion carries an evidence pointer; a self-report that disagrees with disk counts as failed [A037].
                   If a Blake PARTIAL is in play, recompute from the raw files before accepting it [A089].
                   Write no knowledge entry. In the gate report keep the Knowledge Assessment and list candidate discoveries under `## Knowledge candidates`.
                   Write .tad/evidence/yolo/{epic-slug}/phase{N}-gate-report.md (not the Epic). Put `dispatch_id: {id}` in your file's first lines and start your file with the verdict header."
        3. Cora reads the gate report header. A gate report with no Knowledge Assessment section, or with no `## For the human` section, is incomplete: re-dispatch the Gate 4 subagent, never fill it in herself [A007]. She also runs `/bin/bash .tad/hooks/lib/cora-check.sh gate4-record {gate report}` from the repo root: a report it flags (no `light acceptance:` reason and no `real use:` line whose path exists) is incomplete in the same way: re-dispatch the acceptor, never filled by Cora or the designer. A report with `not-run: no browser tool on <harness>`: one re-dispatch of the acceptor on a subagent type whose tool list has a browser when her harness offers one (routing, not a verdict), else relay it as it is.
        4. A step is not done without a completion report and its evidence files; never route forward on a step that lacks them [A020]. A Blake self-report that disagrees with the disk counts as failed [A037].
        5. Gate 4 PASS (or CONDITIONAL with no P0):
           a. Update Epic Phase status 🔄 Active → ✅ Done (both Phase Map table AND Phase Detail Block Status field)
           b. Update NEXT.md: mark the corresponding entry [x]. Handoff and completion files are archived once, in epic_completion.
           c. Announce: "✅ Phase {N} complete. Moving to Phase {N+1}." and go on.
        6. FAIL or PARTIAL:
           a. honest_partial_protocol: mark PARTIAL, do NOT fake PASS [A121]. PARTIAL is never routed as PASS, and Cora never upgrades a verdict [A121].
           b. Announce: "❌ Phase {N} Gate failed. Reason: {detail}"
           c. One rework dispatch: back to Y5 with the verdict file path, then Y6 and Y7 again. A second FAIL or PARTIAL → stop (reason 1), reported as it is; the question offers: accept the phase as is, or keep the run stopped. On "accept as is" she sets the phase's Phase Map row and Phase Detail Status to `✅ Closed — PARTIAL` in the same edit that records the answer in `Stopped:`, then goes on to Y8. An Epic whose phases are all ✅ Done or ✅ Closed — PARTIAL goes to epic_completion, and its queue line is marked `done`: the queue line says the run is finished, not that the Epic is Complete.
        7. Write the pointer: step Y7.
        → Proceed to step_Y8.
      output: "phase{N}-gate-report.md on disk"

    step_Y8:
      name: "Knowledge Assessment (done by the Gate 4 subagent) and next phase"
      action: |
        1. The Gate 4 subagent has recorded the knowledge assessment and its `## Knowledge candidates` in the gate report. Cora adds one line to her journal carrying the gate-report path, and goes on.
        2. Write the pointer: step Y8.
        → If more ⬚ Planned Phases exist → step_Y1 of the next phase, without asking.
        → If none → epic_completion.
      output: "journal line"

  epic_completion:
    trigger: "All phases ✅ Done or ✅ Closed — PARTIAL"
    action: |
      Per Epic:
      1. Write the final report: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md
         Include: per-Phase summary, total files changed, total commits, all review references
      2. Run .tad/hooks/lib/audit-yolo.sh {epic-slug} (skip if the script is not available)
      3. Assess pair testing: if any Phase involved UI/user-flow changes, suggest pair testing
      3b. Dispatch the distillation: an Alex subagent that did not conduct. Write the pointer first (`Pointer: phase <N> | step distill`, N = the Epic's last phase; id `p<N>-distill-<n>`; output `.tad/evidence/yolo/{epic-slug}/distillation-report.md`). Its inputs, named in the prompt: Blake's journals (selected only by every `Journal:` line in each completion report (a rework section adds its own)), Cora's journal (`.tad/evidence/journal/conductor-{epic-slug}-{date}.md`) the `## Knowledge candidates` of every `.tad/evidence/yolo/{epic-slug}/phase*-gate-report.md` and the escape-log lines dated since the last distillation (`.tad/evidence/escape-log.md`); it is the only writer of entries. Put `dispatch_id: {id}` in its output file's first lines. Prompt opens: "You are Alex, dispatched by the conductor (Cora) for one step: distillation. Read .agents/skills/alex/references/conductor-dispatch-mode.md and follow it."
          (alex/references/distillation-loop-protocol.md). Gaps it cannot fill are not answered by Cora: no entry is written, and the gaps are listed in her acceptance question.
      3c. Read the distillation report. In the same edit that records the distillation result, mark the Epic `done` in the queue block, clear its `Owner:` to "—", and move `current` to the next approved Epic. If an approved Epic is waiting, start it with no question.
      Queue-wide, when no Epic is waiting:
      4. Record the acceptance question in the `Stopped:` line of every Epic it covers and clear their `Owner:` to "—" (one edit per Epic file), then write `Conductor status: IDLE`, then ask acceptance alone: one question; each Epic of the queue listed with its result and each phase's `## For the human` block quoted with its pointer (relay, not a judgment), every phase closed PARTIAL and every open P0 named, distillation gaps listed.
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
- A must_call scenario means Cora dispatches the matching reviewer lens (review contract) [A019].
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
- Cross-model delegation is never used to bypass requirement clarification [A053].
- Friction (missing dependency, auth, approval, reviewer, setup) is never a skip reason; request the fix, and if unresolved mark BLOCKED [A054][A055].
- BLOCKED forbids a PASS route: the required step cannot proceed and a gate PASS is forbidden until it is resolved [A056].
- A self-review is never an equivalent substitute for a missing reviewer [A057].
- If the original mechanism is unavailable and no equivalent substitute exists, the step is BLOCKED: stop before PASS [A058].
- No hooks are registered for enforcement [A061].
- No settings edits are made for enforcement [A062].
- Decision 6 of EPIC-20261015-cora-reliability (2026-10-15) allows a mechanical check against skipped triage or dispatch without a grant. It was deferred, not adopted, as Alex's technical call in that phase's design (not the human's): follow-up FU-cora-predispatch-check (HANDOFF-2026-10-16-cora-reliability-phase2.md §11.1). [A061] and [A062] stand until that follow-up lands through its own review; the human's decision ranks above them (AGENTS.md, File authority order) and is recorded here as that conflict.
- Anti-rationalisation: "skipping a review" is a violation [A086].
- Anti-rationalisation: "defaulting to no new knowledge" in a Gate 4 is a violation [A088].
- Anti-rationalisation: "accepting a PARTIAL without the acceptor's recompute from the raw files" is a violation [A089].
- Anti-rationalisation: "auto-invoking an external CLI without the human's confirmation" is a violation [A090].
- File size change is not semantic impact. Before any edit over 20 lines to a SKILL.md, config or hook, list what contract changed; this governs later edits to the Cora skill too (AR-002) [A092].
- The Gate 4 dispatch prompt requires the three explicit knowledge checks of step_Y7 [A095].
