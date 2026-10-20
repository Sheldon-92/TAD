# Review contract
Loaded by every review, verification and acceptance dispatch in TAD: Gate 2 design reviewers, Gate 3 reviewers (Cora's runs, the simple tier, direct /blake Layer 2, *express and *bug), the rubric judge and the Gate 4 acceptor. Part A is for the reviewer; Part B is for whoever dispatches (Cora, Alex, Blake).

## Part A — for the reviewer

### 0. The prompt
A dispatch prompt names only: the lens; the object (a path, or `commit:<sha>` / a commit range); the reference; the same lens's previous-round file (or none); a spike or premise file (or none); the output path; the questions path (lens fit only, where it may write a question); the `dispatch_id`. The dispatcher adds no ad-hoc questions or focus lines: anything a reviewer should look at is written in the Epic or the handoff, where the reviewer reads it.

### 1. Verdict header
Every review, verdict and gate file starts with:
```
---
dispatch_id: <id>
verdict: PASS | CONDITIONAL | FAIL | PARTIAL
p0_count: <number>
judged: <path of the file judged, or commit:<sha> for code>
lens: consistency | risk | fit | run | domain | judge | acceptor
risk_triggers: <the handoff's list, copied from its frontmatter; every review file that reads a handoff>
new_p0: <number>   (review files only, not gate or acceptor files. Round 1: equal to p0_count. Round k ≥ 2: the P0s not already in the same lens's round k-1 file. A review file of round k ≥ 2 without it reads as new_p0 = p0_count.)
empirical_p0: <number>   (review files only, ≤ p0_count; absent reads 0: how many of the P0s a run or measurement settles)
model: harness=<…> | model=<self-reported id> | route=<host|native|unknown>   (direct /alex and /blake reviews; missing = provenance-incomplete, never blocking)
---
```
Self-consistency rule (the writer checks it before saving; the dispatcher checks it on reading):
- PASS or CONDITIONAL ⇒ `p0_count: 0`.
- FAIL ⇒ `p0_count` ≥ 1 (a fail names what it blocks).
- PARTIAL ⇒ a `## Blocked` section says what could not be judged and why.
- `empirical_p0` ≤ `p0_count`; `new_p0` ≤ `p0_count`.
- `lens: fit` ⇒ PASS or CONDITIONAL.
- `lens: run` ⇒ the pasted `gate3-check.sh` output (§5 run) has no MISSING or UNEXPLAINED line, else the verdict is FAIL with one P0 per missing or unexplained item (blocks: that path's AC / Result-contract deliverable); a BLOCKED line ⇒ the verdict is at most PARTIAL with that item under `## Blocked` (§6).
A file whose header breaks a rule counts as not returned: the dispatcher re-dispatches that writer once (same round), then stops (Cora: reason 1; direct /alex or /blake: tells the human). Nobody reads the body to reinterpret a header.
CONDITIONAL: no P0, with findings the next step must carry; routed like PASS, and the file's path goes into the next dispatch prompt.

### 2. A finding
Each P0 and P1 carries:
- `location`: file:line, or the command
- `scenario`: input or situation -> wrong result
- `blocks`: what it blocks (§3)
- `checked`: the lines read or the command run, with its result; a P0 without `checked` is not a P0
- `kind: empirical | design`
- `origin: introduced_by_fix | missed_earlier | preexisting` (required from round 2; in round 1 only `preexisting` is marked: the defect was there before the change)
Read the object and the reference first and form your own judgment; read the author's own account (completion report, handoff rationale) after.
Empty review allowed: "no P0, no P1" is a valid result. There is no minimum number of findings; do not pad.

### 3. What a P0 is
For every file with `p0_count`, a P0 states (a) a concrete failure scenario (input or situation -> wrong result) and (b) what it blocks: a Result-contract deliverable, an AC, a SAFETY principle, a stop-list rule or a security constraint (simple tier: the verification on the journal line, or the plan item it breaks). A defect touching credentials, destructive commands, the stop list or a SAFETY principle is a P0 with (a) alone. Review files add (c) the label `empirical` (a run or measurement settles it) or `design`; a P0 that a spike file named in the reviewer's prompt already tested is labelled `design`. A finding the reviewer cannot write (a) and (b) for goes in its own file section as a P1; a file with no other P0 is then at most CONDITIONAL. This defines a P0; it is not a licence to discount one: a finding that meets it is a P0, and "this P0 is not important" stays a VIOLATION (AR-001). The writer applies it in its own file; no dispatcher reclassifies a finding.
A P0 with `origin: introduced_by_fix` is fixed as a class: the next fix covers every place the earlier fix made the same change.

### 4. The reference
Judge against the Epic's `## Requirement` and `## Result contract` plus the handoff (Epic and handoff tiers); the handoff's §1.5 Requirement and §9 (direct /alex without an Epic); the journal line (simple tier: request, blocks, verification, `risk_triggers`). A finding that the change departs from the requirement names the requirement line.

### 5. Lenses
`risk_triggers` closed list: security | data | money | ui | platform | domain, or none.
- **consistency** (Gate 2 and Gate 3; always): contradictions between the change and unchanged rules, code and other files, and every consumer of a changed line (grep). At Gate 2 it runs every §9.1 acceptance command on the baseline, before the change, and records that each post-implementation command fails there for the right reason (one that already passes is a vacuous AC). It checks the handoff's `risk_triggers` against the change: a missing or wrong trigger is a finding. At Gate 3 it also checks them against the diff (a security, data or money change under `[none]` is a finding that raises the list, and the domain lens then runs), and reads the changed code for defects the real paths do not reach (simple tier and `*bug`, which have no Gate 2, rely on this check). A change to repository-tracked files also gets a check of what enters the release archive (`git archive` of the commit, honouring `.gitattributes` export-ignore): a file the change needs that the archive leaves out, or a file that should not ship that it puts in, is a finding (rule stated here in full; origin: the 2026-10-16 ruling in `.tad/project-knowledge/rulings/human-rulings.md`, if it exists).
- **risk** (Gate 2, when `risk_triggers` lists any): one reviewer applies every listed lens, one section each — security: auth, secrets and credentials, permissions, untrusted input, hook and sandbox trust; data: user or project data written, migrated, synced or deleted (installers and sync included); money: payments, paid API or model calls, billing; ui: what a person sees or clicks; platform: install, OS, shell and harness differences; domain: correctness of a field rule outside code.
- **fit** (Gate 2, only when `risk_triggers: [none]`): is this what the requirement asks (list the readings of the Result contract and which one the handoff builds), is the size proportionate, does the premise hold. It yields questions or P1, never P0: a question that would change the result or scope is written to the phase questions file as class 2 (Cora's run) or, in direct /alex, goes to the human through Alex; anything else is a P1.
- **run** (Gate 3; always; writes the Gate 3 verdict file): re-runs every §9.1 row itself, by hand, in one throwaway copy of the project (a git worktree or clone in scratch, deleted after; no script executes handoff commands), and compares every row with Expected Evidence, into a `## AC runs` table `| row | command | exit | result |` (a row it does not run: `not-run` in the result cell and a `## Not run` line with the reason); runs every `real_path` (§6; simple tier: the verification on the journal line) as a real run, into a `## Real paths` table `| id | what was run | output pointer | result |` and a `## Not run` list (`- <id> not-run: <reason>`); before saving runs `bash .tad/hooks/lib/gate3-check.sh <handoff> <its own file>` (it executes nothing; it checks the AC table, the real paths and that every not-run has a reason) and pastes the output (simple tier: the journal-line verification, one row each: command, output, result; it also writes `## For the human`, a verdict line plus 3-5 evidence lines with pointers, for Cora to relay); runs the project's test suite when the handoff names one or the repo has one; states in one line whether the verification matches the request line it came from; checks the Gate 3 rows that need no design judgment (completion report present, Knowledge Assessment present, commit recorded); writes the completion report's `gate3_verdict:` marker. A rubric row is decided by the judge's file named in the prompt.
- **domain** (Gate 3, only when `risk_triggers` lists security, data or money): one reviewer applies those lenses to the built change and runs what it needs.
- **judge** (rubric ACs): the gate skill's Rubric Evaluation Protocol. **acceptor** (Gate 4): the gate skill and the acceptance protocol.

### 6. A real run
- One real use of each path: the install, build, command or call a user makes. Never a batch, a loop or a measurement.
- In a scratch or temp location; never change the work under review. The run reviewer runs a handoff's §9.1 commands in one throwaway copy of the project, never in the working tree; it reads each command before running it and does not run one that reaches outward (network, push, publish) or outside the copy — that row is `not-run` with the reason. §9.1 commands are read-only and repo-relative (any scratch write through `mktemp -d`); a command that writes into the repo is a design defect (consistency lens at Gate 2).
- Protocol or prompt text: walk a named scenario through the changed text, quoting file:line at each step, and say where it ends.
- `not-run: <reason>` under `## Not run` for a path whose run is paid, touches production or makes an outward post or push, needs the human's own account or a real device, or needs a capability this harness does not have (a browser tool the harness or subagent lacks is such a capability). It is a recorded item, never a silent skip and never a PASS for that path; it goes to Gate 4 and to the human. Anything paid is asked first (Cora: stop reason 3).
- Friction (a missing tool or dependency that could be installed, an approval) is not `not-run`: ask for the fix; unresolved, the file is PARTIAL with the item under `## Blocked` (BLOCKED never routes as PASS). Installing a browser tool is a new dependency the human is asked about, never a precondition for the verdict.

## Part B — for the dispatcher

### 7. Rounds and blocking
- Only a P0, a FAIL or a PARTIAL blocks. A P1 is carried: the file is CONDITIONAL, its path goes into the next dispatch, the completion report (or handoff §10) lists it, and Gate 4 lists open P1s to the human. No cap on P1 or P2 counts.
- Cora's simple tier is stricter: a P0 after its one rework retriages it as a handoff (cora/SKILL.md Triage).
- Round 1: every lens of the stage. Round k ≥ 2: only the lens(es) whose round k-1 file had a P0, FAIL or PARTIAL, given the fix diff, the open P0 list with full reasons and every section or file the fix touches; at Gate 3 the run lens also re-runs in every round after a rework (its verdict must judge the final commit). Each reviewer judges the current version first, then labels `new_p0` and `origin` from its own lens's previous file.
- Round 3, counted from round 1 or from the last re-plan, still has an open P0: stop reviewing and look upstream. Cora: the root-cause re-plan with the premise file (conductor protocol step_Y4 5c / step_Y6 4c). Direct /alex: Alex writes the premise (one sentence the failed fixes share, one observation that differs if it is false), checks it by a read, grep or local command and re-plans the handoff once; a second time, or a re-plan that would change the result or scope, goes to the human (narrow the scope, change the approach, withdraw) — there is no "accept the risk and continue". Direct /blake: Blake stops and escalates to Alex with the review files. There is no round 4 without a re-plan.
- A fix that changes `risk_triggers` re-dispatches the risk lens in the next round, whatever its previous verdict. Cora reads `risk_triggers:` from the risk or fit file of the latest round that wrote one.
- A round count alone never stops a Cora run (her runaway guard is twice the Budget estimate).

### 8. Who reviews what
| Stage | Reviewers (fresh subagents; none is the builder) | Files |
|---|---|---|
| Gate 2 — a handoff was written (Cora handoff and Epic phases, /alex *handoff, *express, spike, *experiment) | consistency + risk (every listed trigger), or fit when `none` | design-review-consistency, design-review-risk or design-review-fit |
| Gate 3 — the change was built (every path) | run + consistency, + domain when security, data or money is listed | gate3-verdict (run), impl-review-consistency, impl-review-domain |
| Simple tier, *bug mini-handoff | no Gate 2 (no design choice: the change is named by the request or the diagnosis); Gate 3 as above ("two light reviewers": same lenses, small object) | as the path names them |
| Gate 4 — every path | the acceptor: an Alex subagent that took no part; acts as the human (real use or a browser), judges against `## Requirement` + Result contract, ends with `## For the human` (gate skill Gate 4, acceptance-protocol step3) | gate report (+ `gate4/` evidence) |
Never two reviewers with the same lens; a self-review never counts. Two reviewers is the floor at Gate 2 and Gate 3 (Gate 4 keeps one acceptor; principle "Express Handoff is NOT Review-Exemption": at least one independent reviewer).
Paths: Cora's runs `.tad/evidence/yolo/{epic-slug}/phase{N}-<file>.md`; simple tier `.tad/evidence/simple/{YYYY-MM-DD}-{slug}-review-<lens>.md`; direct /alex `.tad/evidence/reviews/alex/<slug>/design-review-<lens>.md`; direct /blake `.tad/evidence/reviews/blake/<slug>/gate3-verdict.md`, `consistency-review.md`, `domain-review.md` (the AC runs are a section of the run verdict file, not a separate file). Round k ≥ 2 adds `-r<k>` before `.md`; no verdict file is overwritten.
Who dispatches: Cora in her runs; Alex for Gate 2 in direct /alex; Blake for Gate 3 (Layer 2) in direct /blake; a rubric judge is dispatched by the same party before the run reviewer. The Gate 4 acceptor: Cora in her runs, the designing Alex at direct `*accept` (never himself). Reviewers dispatch no one.

### 9. Harness mapping and cross-model
Claude Code examples: consistency → code-reviewer; run → general-purpose (test-runner for a test suite); risk and domain → security-auditor (security), database-expert or backend-architect (data, money), ux-expert-reviewer (ui), devops-engineer (platform), product-expert or general-purpose (domain, fit). Other harnesses: any fresh subagent given the lens.
Cross-model is an optional slot, off by default: a lens may be held by another model family only on the human's confirmation, under the existing cross-model rules (conductor protocol, NOT_via_alex_auto).
