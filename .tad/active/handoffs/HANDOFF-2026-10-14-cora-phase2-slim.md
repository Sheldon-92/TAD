---
dispatch_id: D30
task_type: code
e2e_required: no
research_required: no
handoff_revision: slim-1
---

# Handoff for Blake — Cora, Phase 2 (slim): wiring into the framework

**From:** Alex (design subagent, D30) **To:** Blake **Date:** 2026-10-14
**Epic:** `.tad/active/epics/EPIC-20261013-cora-conductor-role.md` (Phase 2) **Base commit:** `ad6feb80` (branch `feat/cora-role`)
**Hard caps:** this file ≤ 200 lines; no new mechanism, file type, state table or script; acceptance = existing checks plus the commands in §8. Anything that does not fit is in §10.

## 1. What Phase 2 delivers

1. The one carried P1 from Phase 1, plus three cheap P2s in the same files (§3).
2. Cora reachable the way Alex and Blake are: phrases in `AGENTS.md`, installer hints, Codex adapter row (§4). The installer already ships her (§11).
3. Three-role wording where the framework states the rule: `config-agents.yaml`, `AGENTS.md`, the few texts that still make the human the only bridge or let a conductor write a verdict (§5); `principles.md` only as the human approves it (§6).
4. The provenance ledger regenerated, so `release-verify.sh provenance` is green (§7).
5. Proof on a fresh install, Claude Code and Codex, graded by an independent subagent (§8.2).

## 2. Files (nothing else is touched)

```
MODIFY .agents/skills/cora/references/conductor-protocol.md      §3 (Y6 4a, verdict header, questions file, Y7 wording)
MODIFY .agents/skills/cora/SKILL.md                              §3 (Intake pointer), §4 (description triggers)
MODIFY .agents/skills/alex/references/conductor-dispatch-mode.md §3 (questions file id; one clause, file stays ≤ 40 lines)
MODIFY AGENTS.md                                                 §4, §5
MODIFY tad.sh                                                    §4 (two echo lines only: 5508, 5953)
MODIFY .tad/codex/README.md                                      §4 (line 76 only)
MODIFY .tad/config-agents.yaml, .tad/config.yaml                 §5 (config.yaml: line 21 only)
MODIFY .agents/skills/alex/references/handoff-creation-protocol.md §5 (lines 693-695 only)
MODIFY .agents/skills/blake/SKILL.md                             §5 (lines 1723-1724 only)
MODIFY .agents/skills/gate/SKILL.md                              §5 (line 391 only)
MODIFY .tad/guides/nondev-execution-track.md                     §5 (line 189 only)
MODIFY .tad/templates/deliverable-completion.md                  §5 (lines 2-8, comment block only)
MODIFY .tad/hooks/post-write-sync.sh                             §5 (message strings at 311, 329 only)
MODIFY .tad/project-knowledge/principles.md                      §6, ONLY if the approval line is filled
MODIFY .tad/project-knowledge/patterns/gate-design.md            §6 (line 114, one phrase; with principles only)
REGEN  .tad/brain-index.md                                       §6 (`bash .tad/hooks/lib/brain-index-gen.sh`; with principles only)
REGEN  .tad/provenance/claude-legacy.tsv, MANIFEST.sha1          §7
MODIFY .tad/scripts/path-refs-allowlist.txt                      only rows `release-verify.sh path-refs .` asks for
```
**Must not be touched:** `README.md`, `INSTALLATION_GUIDE.md`, `docs/**`, `CHANGELOG.md`, `package.json`, `tad-intro*.html`, `.agents/skills/alex/SKILL.md`, `alex-lite`, `blake-lite`, other skills, other hooks, `.claude/`, `.codex/`, `.cursor/`, `.opencode/`. Already dirty, never commit: `NEXT.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`, `docs/pm/status.md`, `.tad/active/epics/**`, `.tad/memory/**`.
Before editing `post-write-sync.sh` read `.tad/project-knowledge/patterns/shell-portability.md` (`AGENTS.md` rule).

## 3. Commit 1 — the carried item and three P2s (conductor-protocol and friends)

- **Carried P1 (Y6 step 4a, `conductor-protocol.md:197-200`).** Before the prompt: "Write the pointer (id p{N}-y6-<n>, output {completion_path})." Prompt becomes: "Read {handoff_path} for the original spec. Read {impl-review-cr.md} for the P0 findings. Fix and re-commit. Then update {completion_path}: set its `dispatch_id:` line to `{id}` and add a `## Rework <n>` section listing the new commits." Keep line 197 ("a. Re-dispatch a Blake subagent with the handoff path and the review file path:"), "Cora never fixes code herself." and any existing tags (AC-1 below reads between those two lines).
- **C1.** `verdict_header` block (`:25-32`): add `dispatch_id: <id>` as the first key inside the `---` block, so the shown header has four keys. `questions_file` (`:38-41`): add "Line 1 of the file is `dispatch_id: <id>` of the dispatch that wrote it; a questions file with another id is stale." Same clause in `conductor-dispatch-mode.md`, section Questions: "line 1 is `dispatch_id: <id>` from your prompt."
- **C3.** `cora/SKILL.md:29` (Intake): before the Phase Details dispatch she writes the pointer: `Pointer: intake | phase details`, `Dispatched: intake-<n> -> .tad/evidence/yolo/{epic-slug}/intake-details.md`. One clause, no new state.
- **C4.** `conductor-protocol.md:223`: "...phase{N}-gate-report.md (not the Epic) put..." → "...phase{N}-gate-report.md (not the Epic). Put...".
- Run `phase1-slim-ac.sh AC-1 AC-2 AC-5` after this commit (tags must survive).

## 4. Commit 2 — Cora reachable

- **`AGENTS.md` Role Switching** (`:25-36`). Add a table row: `| "当 Cora" / "Cora 模式" / "you are Cora" / "你是 Cora" / "$cora" / "/cora" | Cora (Conductor) |`. Extend line 27: `$cora` / `/cora` beside the Alex and Blake forms. Under the table, one sentence: "If a phrase above did not load the skill by itself, read `.agents/skills/<role>/SKILL.md` and follow it." Replace lines 34-36 with three lines: Cora is the human's entry point and runs approved Epics by dispatching subagents; Alex is the Solution Lead (technical design, handoffs, Gate 4); Blake is the Execution Master (implementation, Ralph Loop, Gate 3). Then: "Cora is additive: `/alex` and `/blake` stay the default for single handoffs, bugs and technical discussion. Claude Code and Codex: measured in this phase (§8.2). Cursor and OpenCode: same method, not yet run."
- **`cora/SKILL.md` frontmatter description:** trigger phrases become `/cora, $cora, "当 Cora", "Cora 模式", "you are Cora"`. No other body change (AC-1 caps stay).
- **`tad.sh`** `:5508` → `"  /cora, /alex, /blake, /gate - Default (Cora: entry point and Epic conductor)"`; `:5953` → add `${CYAN}/cora${NC},` before `/alex`. Nothing else in `tad.sh`: the skill set is name-driven (`claude_skill_set`, `:3373-3392`) and the `alex` sentinel checks (`:4092-4101`, `tad-update.sh:131`) decide "TAD installed / projected", which stays true with Alex present. Changing them is not needed.
- **`.tad/codex/README.md:76`:** `` `AGENTS.md` → `$cora` / `$alex` / `$blake` ``.
- **Knowledge Ingress (`AGENTS.md:43-59`):** one line, conditional so check6 does not require the file: "- If `.tad/project-knowledge/rulings/human-rulings.md` exists, Cora reads it at activation." (check6 skips lines containing " If ").

## 5. Commit 3 — three-role wording where the rule is stated

- **`AGENTS.md`.** Lines 3-7: "TAD uses three roles:" with a Cora bullet (the human's entry point and conductor: agrees the result, writes the Epic, dispatches Alex, Blake and reviewers as subagents; writes no implementation, edits no handoff, gives no verdict), then the Alex and Blake bullets unchanged; line 7 "All three roles operate under..." and one sentence: "Independence of judgment is the rule: no one judges their own work. Separate terminals with the human as the bridge are one way; a fresh subagent dispatched by Cora is another." Role separation (`:70-71`): add "Cora writes no implementation, edits no handoff and gives no verdict; dispatching a subagent inside an approved Epic is not a role switch." Post-compact self-check (`:75-76`): add "Cora: do I know the current Epic's `## Run` pointer?" Default Behavior line 123: add "'当 Cora' to discuss direction or run an Epic".
- **`.tad/config-agents.yaml`** `triangle.terminal_isolation` (`:36-75`): `blocking: false`; `description:` → "判断独立是规则：没有人评判自己的工作。分开的 Terminal、人类做桥梁是一种做法（手动 /alex → /blake）；Cora 派发的全新上下文 subagent 是另一种。"; `rule:` → two lines: manual path (Alex stops after the handoff, the human passes it to Blake, Alex never calls /blake in his own terminal) and conducted path (Cora dispatches Alex, Blake and reviewers as fresh subagents; each verdict is written by a party that did not do the work). Keep `workflow`, `violation`, `principle` (they describe the manual path). `forbidden_actions` last item → "Alex 或 Blake 试图绕过人类或 Cora 直接与另一个 Agent 通信". `human.responsibilities` "在 Alex 和 Blake 之间传递信息" → "手动路径中在 Alex 和 Blake 之间传递信息；或把 Epic 交给 Cora". Add after `agent_b` (≤ 8 lines): `agent_c: {name: Cora, role: Conductor, forbidden_actions: [写实现代码, 修改 handoff 或代码, 写 gate 结论], skill: .agents/skills/cora/SKILL.md}` in the file's block style. `agent_teams.terminal_isolation.rule` (`:300`) → "Agent Teams MUST NOT cross role boundaries". `.tad/config.yaml:21` → `triangle (terminal_isolation, agent_a, agent_b, agent_c, human)`.
- **Human-as-only-bridge lines** (manual-path messages keep their meaning): `handoff-creation-protocol.md:695` → "手动路径：由人类把这封信转给 Blake。Cora 运行的 Epic 里由 Cora 派发 Blake。"; `blake/SKILL.md:1724` → "手动路径：由人类把这封信转给 Alex。Cora 运行的 Epic 里由 Cora 派发验收。" Lines 693 and 1723 (`我不会在这个 Terminal 调用 /blake|/alex`) and `handoff-creation-protocol.md:726` stay: an agent still never switches roles itself.
- **Conductor writing a verdict** (C11): `gate/SKILL.md:391` → "rubric AC under a Conductor/Epic lane → the Gate 3 executor writes it; when Cora conducts, that is the Gate 3 verifier she dispatches, never Cora." `nondev-execution-track.md:189` "the Conductor edits" → "the Gate 3 executor (the session that spawned the judge; under Cora, her Gate 3 verifier, never Cora) edits". `deliverable-completion.md:2,5,8`: "filled by the CONDUCTOR (the Gate 3 judge-orchestrator ...)" → "filled by the Gate 3 judge-orchestrator (under Cora: the Gate 3 verifier she dispatches, never Cora) ..."; ":5 the Conductor Edits this" → "the judge-orchestrator edits this"; ":8 Conductor-performed" → "performed by the Gate 3 executor".
- **Hook reminders** (`post-write-sync.sh`): append to the `:311` string " (Alex dispatched by Cora: stop here; Cora dispatches the reviewers.)"; to the `:329` string " (Blake dispatched by Cora: leave gate3_verdict empty; Cora dispatches an independent Gate 3 verifier.)". Strings only; `bash -n` must pass.

## 6. Commit 4 — the principle (human-gated)

Apply **only** if the last line of `.tad/evidence/yolo/cora-conductor-role/phase2-principle-before-after.md` reads `Approved: yes — "<the human's words>" (<date>)` (Cora writes that line; you never do). Then copy the approved "After" text of both entries into `principles.md` exactly, change `gate-design.md:114` "principles.md Two-Agent failure_mode" → "principles.md Three Roles failure_mode", run `bash .tad/hooks/lib/brain-index-gen.sh`, commit those three files. If the line still reads `(none yet)` or asks for changes: do not touch the three files; report "principle: NOT APPLIED, awaiting approval" in the completion report. Every other part of the phase goes on regardless.

## 7. Commit 5 — provenance ledger

After commits 1-3 are in (skills unchanged from then on): `bash .tad/scripts/gen-claude-provenance.sh`, then commit `.tad/provenance/claude-legacy.tsv` and `.tad/provenance/MANIFEST.sha1` alone. `release-verify.sh provenance .` must then exit 0 (check 6 requires the ledger committed). If a later fix touches any file under `.agents/skills/`, regenerate and commit again.

## 8. Acceptance

### 8.1 Commands (run from the repo root, in bash; record each exit code and last line in the completion report)

| AC | Command | Pass | Today (dry-run, ad6feb80 + this design) |
|---|---|---|---|
| AC-1 carried + P2 | `F=.agents/skills/cora/references/conductor-protocol.md; awk '/Re-dispatch a Blake subagent with the handoff path/,/Cora never fixes code herself/' $F \| grep -c dispatch_id; awk '/verdict_header:/,/dispatch_id_rule:/' $F \| grep -c 'dispatch_id:'; awk '/questions_file:/,/evidence_structure:/' $F \| grep -c dispatch_id; grep -c '(not the Epic) put' $F; grep -c 'Pointer: intake' .agents/skills/cora/SKILL.md; grep -c dispatch_id .agents/skills/alex/references/conductor-dispatch-mode.md` | ≥1, ≥1, ≥1, 0, ≥1, ≥1 | 0, 0, 0, 1, 0, 0 |
| AC-2 reachable | `grep -c -E '当 Cora\|\$cora\|/cora\|you are Cora' AGENTS.md; grep -c '/cora' tad.sh; grep -c 'cora' .tad/codex/README.md; grep -c 'rulings/human-rulings.md' AGENTS.md` | ≥2, 2, ≥1, 1 | 0, 0, 0, 0 |
| AC-3 wording | §8.3 grep | 0 hits | 13 hits |
| AC-4 principle | `grep -c '^### Three Roles, Independent Judgment' .tad/project-knowledge/principles.md; grep -c 'terminal isolation is an ASSET' .tad/project-knowledge/principles.md` | 1, 0 if approved; else 0, 1 and reported NOT APPLIED | 0, 1 |
| AC-5 repo checks | `bash .tad/hooks/lib/skill-body-verify.sh`; `bash .tad/hooks/lib/state-surface-check.sh`; `bash .tad/hooks/lib/release-verify.sh` with `path-refs .`, `freshness .`, `installer-destructive-guard .`, `version-sweep . 3.3.0`, `provenance .` | all exit 0 | all 0 except provenance exit 1 ("12 index entries not in the ledger") |
| AC-6 Phase 1 still holds | `bash .tad/evidence/yolo/cora-conductor-role/phase1-slim-ac.sh AC-1 AC-2 AC-3 AC-4 AC-5 AC-7 AC-8 AC-9` | exit 0 | exit 0, 8 PASS |
| AC-7 no model names | `git diff ad6feb80 HEAD -U0 \| grep '^+' \| grep -ciE 'opus\|sonnet\|haiku\|gpt-[0-9]\|gemini'` | 0 | 0 |
| AC-8 scope | `git diff --name-only ad6feb80 HEAD` | every path in §2 | (empty) |
| AC-9 fresh install | §8.2 steps 1-2 | both installs exit 0; `.agents/skills/cora/SKILL.md` present in both; `.claude/skills/cora -> ../../.agents/skills/cora` in claude-code; `structural` prints `✅ .agents/skills identical` and its only ❌ is `.tad/migrations` (`genesis.yaml`, a fresh-install file) | as stated, on the current tree |
| AC-10 activation | §8.2 step 3, graded by an independent subagent | judge file `verdict: PASS` | not run (no sessions in design) |

Not used: `release-verify.sh migration` (fails on the untouched tree: "missing hop manifest 3.3.0-to-3.3.0", a release-time check, Phase 4). `phase1-slim-ac.sh` AC-6 and AC-10 are Phase 1's scope list and Phase 1's judge bound to the Phase 1 skill; they go stale by design here and are replaced by AC-8 and AC-10.

### 8.2 Fresh install and activation (after commit 5; in bash; `OUT=.tad/evidence/yolo/cora-conductor-role/phase2-activation`)

1. For `p` in `claude-code codex`: `D=$(mktemp -d)/fi-$p; mkdir -p $D; (cd $D && git init -q && bash "$SRC/tad.sh" --source "$SRC" --platform $p --yes) > $OUT/install-$p.log 2>&1` (`SRC` = repo root), then `(cd $D && git add -A && git -c user.name=t -c user.email=t@t commit -qm base)`.
2. `bash .tad/hooks/lib/release-verify.sh structural "$SRC" "$D" > $OUT/structural-$p.txt 2>&1`.
3. Four headless sessions, one prompt each, `Q='you are Cora — who are you and what are your five actions?'`:
   - `claude-bare`: `(cd $D && claude -p "$Q" --permission-mode acceptEdits --tools "Read,Glob,Grep,Skill" < /dev/null)`
   - `claude-slash`: same with `"/cora $Q"`
   - `codex-bare`: `(cd $D && codex exec --sandbox workspace-write "$Q" < /dev/null)`
   - `codex-dollar`: same with `"\$cora $Q"`
   Each to `$OUT/transcript-<name>.md`, followed by `### harness exit: <rc>` and the output of `(cd $D && git status --porcelain)` under `### files changed`. A harness that cannot run (login, usage limit, sandbox): `$OUT/<harness>-not-run.md`, line 1 the reason, then the error text. That is NOT RUN, never PASS.
4. You do not grade. Cora dispatches an independent subagent (not you, not a Phase 2 reviewer) that writes `.tad/evidence/yolo/cora-conductor-role/phase2-activation-judge.md` (verdict header, then one row per transcript). Rubric per transcript: (a) she says she is Cora, the human's entry point and the conductor of approved Epics; (b) she names the five actions Intake, Dispatch, Read, Route, Record; (c) she says she writes no implementation and gives no verdict; (d) `### files changed` is empty. All four PASS → PASS. The judge also writes one paragraph "What the bare phrase does" for each harness (closes C9).
5. A bare-phrase FAIL is fixed once in the `AGENTS.md` wording (§4), committed, ledger step §7 if a skill file changed, and the four sessions run again. A second FAIL is reported as it is.

### 8.3 The wording grep (AC-3)

```
P='AGENTS.md .tad/config.yaml .tad/config-agents.yaml .tad/project-knowledge/principles.md .agents/skills/alex .agents/skills/blake .agents/skills/cora .agents/skills/gate .tad/guides .tad/templates .tad/hooks'
git grep -n -E "唯一的?信息桥梁|only bridge|必须在不同 ?Terminal|MUST NOT cross terminal|terminal isolation is an ASSET" -- $P
grep -A3 '^  terminal_isolation:' .tad/config-agents.yaml | grep 'blocking: true'
git grep -n -E "Conductor = Alex|Alex 可自动驱动|Alex 自己设计 → 审查|filled by the CONDUCTOR|the Conductor edits|the Conductor Edits|Conductor/judge-orchestrator writes it|two specialized roles|Both roles operate" -- $P
```
Today: 13 hits (`handoff-creation-protocol.md:695`, `blake/SKILL.md:1724`, `config-agents.yaml:40,41,46,300`, `principles.md:116`, `nondev-execution-track.md:189`, `deliverable-completion.md:2,5`, `gate/SKILL.md:391`, `AGENTS.md:3,7`). Pass: 0 hits, except `principles.md:116` while §6 is NOT APPLIED. Allowed outside the grep's scope, on purpose: `README.md`, `INSTALLATION_GUIDE.md`, `docs/**` (Phase 4), `CHANGELOG.md` and `.tad/archive/**`, `.tad/evidence/**`, `.tad/memory/**` (history), `alex-lite`/`blake-lite` (frozen), `.tad/references/openharness-architecture.md` (comparison notes). The phrases "Terminal 2" and "我不会在这个 Terminal 调用" stay: they describe the manual path, not a rule that it is the only one.

## 9. Order and evidence

1. `git status --short`: only the dirty files listed in §2 are dirty. 2. Commits 1-3 (explicit pathspecs, `git add -- <paths>`, `git commit -- <paths>`, never `-A`, no push, no tag). 3. Commit 4 only if approved. 4. Commit 5. 5. §8.1 AC-1…AC-9. 6. §8.2 sessions (background). 7. Completion report `.tad/active/handoffs/COMPLETION-2026-10-14-cora-phase2-slim.md`: `dispatch_id` from your prompt in the first lines, the commit shas, every §8.1 command with exit code and last line, the transcript list, principle APPLIED / NOT APPLIED, and anything you could not do. Leave `gate3_verdict:` empty.

## 10. Left out on purpose

- `README.md`, `INSTALLATION_GUIDE.md`, `docs/MULTI-PLATFORM.md`, `docs/CODEX-USER-GUIDE.md`, `docs/value-proposition.md`, `tad-intro*.html`, `package.json` / `config.yaml:4` taglines ("Two-Agent Quality Framework"), `tad-help`/`tad`/`tad-init`/`tad-scenario` help texts, `.tad/README.md`, `CHANGELOG.md`: Phase 4 (public wording).
- `.tad/project-knowledge/architecture.md` "Two-Agent System" copy: Phase 4, with the README.
- A `command_module_binding` entry for Cora: not planned. Her skill loads no config module; an unread binding was removed for `tad-gate` for that reason (`config.yaml:108-111`).
- `/cora` command projection for OpenCode: not planned here; same deferral as `/alex` (`AGENTS.md` C-5).
- Changing the `alex` sentinel in `tad.sh` / `tad-update.sh`: not needed (§4).
- Carry-forward C2 (distillation inputs at Epic close), C6 (thin stop text), C7 (freshness on an already-read step), C8 (written dispatch statement from a real run), C10 (queue of two Epics): Phase 3, the real run exercises them. C5 (cosmetic tags), C12 (dispatch log, evidence outside git): not planned.
- `.tad/guides/anti-rationalization-tables.md` "Terminal Isolation Bypass": its three rows are about Alex not coding and the human seeing the handoff; still true. Not planned.
- Any script, AC file or new check for Phase 2: the commands above are the acceptance.

## 11. Grounding and dry-run (2026-10-14, at `ad6feb80`, working tree clean for skills)

**Read:** Epic (result contract, Phase 2, Decisions); `phase1-gate-report.md` (carried P1, C1–C12); `cora/SKILL.md` (whole); `conductor-protocol.md:15-45, 155-230`; the Phase 1 slim handoff; grounding-B `E`, `D`, `G`, `H` re-checked against today's lines (`tad.sh:1610-1660, 3373-3392, 4086-4101, 5504-5509, 5951-5953`; `tad-update.sh:131`; `AGENTS.md:1-125`; `config-agents.yaml:1-160, 285-342`; `config.yaml:15-25, 99-130`; `principles.md:1-140`; `state-surface-check.sh:246-280`; `release-verify.sh` provenance block; `gen-claude-provenance.sh` header; `phase1-slim-ac.sh:153-264`).
**Dry-run:** `tad.sh --source <repo> --platform claude-code|codex --yes` into empty scratch dirs: both exit 0, both contain `.agents/skills/cora/SKILL.md`, claude-code has `.claude/skills/cora -> ../../.agents/skills/cora`, installed `AGENTS.md` is byte-identical to the repo's (so §4 ships by itself); source tree unchanged afterwards. `structural` on each: `.agents/skills identical`, one ❌ `.tad/migrations` (`genesis.yaml`). Every §8.1 row was run; results are in the "Today" column. 79 `v*` tags present (generator needs ≥ 78). No harness session was run by the designer.

## 12. Known limits

- The activation check is four sessions, one run each; it shows activation and self-description, not a conducted run (Phase 3).
- Cursor and OpenCode are not run; they are described as "same method, not yet run".
- The provenance ledger turns red again whenever a later phase changes a skill file; Phase 4 regenerates it before the release.
