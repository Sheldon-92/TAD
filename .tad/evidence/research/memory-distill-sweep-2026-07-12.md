# Memory Distillation Sweep — 2026-07-12

Scanner: distillation sweep over 35 memory files (`.tad/memory/*.md`, MEMORY.md excluded)
+ 7 findings from Blake's journal `.tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md`.
Variabilize test per `.tad/templates/knowledge-writing-rules.md` (the
`.tad/project-knowledge/knowledge-writing-rules.md` path named in the task does not exist;
the templates copy is the live rules file). Duplicate check against
`.tad/project-knowledge/patterns/*` (all 9 files read), `principles.md` (all 17 entry titles),
plus targeted greps of alex/blake/capability-upgrade/release-runbook SKILL text.

Verdict shorthand: **G** = GRADUATE-L2, **A** = ALREADY-CAPTURED, **E** = EPISODIC,
**U** = USER-PREF, **S** = STALE.

---

## 1. Summary Table

### Memory files (35)

| # | File | Bucket | One-line reason |
|---|------|--------|-----------------|
| 1 | feedback_alex-no-code-violation | A | Core rule lives in CLAUDE.md §4 Terminal 隔离 + §5 违规处理 ("禁止 Alex 写代码", applies to any session); memory keeps the recurrence narrative — behavioral guardrail correctly resident in memory layer |
| 2 | feedback_cli-first-tool-design | A | Superseded by richer pattern: pack-build-rules.md "Skill File vs MCP Tool Boundary — Judgment = Skill, Capability = MCP - 2026-06-23" (same substance + decision rules + conversion threshold) |
| 3 | feedback_execution-review-separation | **G** | Context-vs-constraint / persona-only-at-review passes variabilize; NOT in any pattern file or SKILL as a stated rule (only instantiated implicitly) → Entry E7 |
| 4 | feedback_no-sync-pull-based | U | User's process preference (*publish 后不推 *sync); belongs in memory. Note: release-runbook SKILL still describes Phase 5/6 sync phases — Alex may want to align runbook wording, but that is a doc fix, not knowledge |
| 5 | feedback_pick-generative-directions | U | Personal direction-selection preference ("don't repeat internal plumbing") — profiles the user, not the craft |
| 6 | feedback_plain-language-after-handoffs | A | Mandatory 人话版 section now in alex SKILL plain_language_rules + handoff-creation-protocol.md L696-720 (MANDATORY, VIOLATION-guarded) |
| 7 | feedback_plain-language-quality | A | handoff-creation-protocol.md L706 carries this memory's exact fix verbatim: "人话版质量规则 — 读者价值测试，不是结构合规检查" |
| 8 | feedback_research-before-upgrade | A | Systemic fix shipped per the memory itself (commit 257cbcc): pack-upgrade workflow Plan stage composes research-engine → cited report as foundation; cross-platform-standard assertions forbidden |
| 9 | feedback_research-methodology | A | NotebookLM methodology entries in patterns/research-methodology.md; GitHub-First sourcing + question quality (Q1 decision-question derivation) baked into the unified *research protocol (research-system-consolidation Epic, 2026-06-17) |
| 10 | feedback_share-mode-and-deflation | U | Interaction-style preference (thought partner not pipeline; deflated framing) — user profile material |
| 11 | feedback_tool-freshness | A | Operationalized in capability-upgrade SKILL L210 ("For each tool: install command, test command, key usage command") + research-first pack-upgrade workflow; domain.yaml context is retired |
| 12 | feedback_verify-before-delete | **G** | "Newer format ≠ newer content; verify lineage via git log before deleting duplicates" passes variabilize; not in patterns or tad-maintain → Entry E9 |
| 13 | feedback_yolo-epic-workflow-args | **G** | ac-verification.md covers only the milder 2026-06-08 symptom; the 2026-07-05 re-confirmation (args fail in BOTH named and scriptPath modes + hardcode-default workaround + Conductor-manual fallback) is uncaptured, and yolo-execution-protocol.md L33 still asserts args injection works → Entry E2 |
| 14 | project_academic-research-pack | E | Epic status + v0.2 gap list — project history |
| 15 | project_ai-native-reading-companion | E | Epic status; its distillable lesson already landed as ac-verification.md "A 'Real-Browser E2E Passed' Claim Is Confounded…" (2026-06-14) — the file says so itself |
| 16 | project_auto-evolve-epic | S | "How to apply: trace → dream-scanner (daily cron) → candidates" contradicted by repo: dream-scanner.sh absent from .tad/hooks/lib/, 0 "dream" refs in alex SKILL, retirement recorded in project_self-evolution-pruning + .tad/archive/proposals/NEGATIVE-RESULT.md. Surviving arch decisions (env-var convention, double-parse) already in shell-portability patterns |
| 17 | project_capability-packs | E | Pack inventory/status ledger; audit improvements already in principles.md YOLO 2026-05-15 SAFETY entry |
| 18 | project_co-thinking-workshop-seed | U | Explicit user boundary directive (keep seed OUTSIDE TAD, don't absorb) — preference/guard, must stay memory |
| 19 | project_codex-adapter-validation | E | Validation status + roadmap; codex CLI op gotchas family already has a home (research-methodology.md "Codex CLI Feasibility and Patterns"), stdin-blocking detail is codex-ops minutiae adequately held by memory |
| 20 | project_domain-pack-design | S | YAML Domain Pack architecture retired 2026-06-11 (archived at .tad/archive/domains/, confirmed present); capability packs + SKILL.md superseded the model. Its one enduring principle (做事不设限，审查设视角) graduates via #3/E7 |
| 21 | project_dynamic-workflow-epic | E | Epic status; 2 remaining P2s are backlog items, not knowledge |
| 22 | project_knowledge-recording-redesign | E | Epic status; the knowledge itself already lives as L1 principle "Knowledge Is Forged at Distill" + schema/rules templates + distill/maintain protocols |
| 23 | project_pack-quality-leveling-epic | E | Epic status; per its own text the lessons were distilled to pack-evaluation.md and dogfood-with-factcheck was folded into capability-upgrade |
| 24 | project_quality-chain-failure | S | "⚠️ P0 下次 session 必须优先修复" (2026-04-03) long resolved: principles.md "Judgment-Only Skill Files … AMENDED 2026-04-04" records root cause + v2.8.1 resolution; MEMORY.md index still carries the stale P0 flag |
| 25 | project_research-system-consolidation | E | Epic complete (2026-06-17); the 9→1 consolidation design is now live protocol |
| 26 | project_self-evolution-pruning | E | Epic status + negative-result record (valuable as history, correctly memory-resident) |
| 27 | project_surplus-burn-mode | **G** | File is mostly status, but its 3 structural findings (yolo-epic worktree false-FAIL ×3, "executed" ≠ review-PASS, round-2 review catches fix-introduced defects) pass variabilize and are in NO pattern/SKILL → Entry E1 |
| 28 | project_tad-brain-knowledge-search | **G** | "External tool's value = LLM features Claude already has → thin native wrapper beats importing the stack" is a reusable tool-adoption decision rule, uncaptured → Entry E8 |
| 29 | project_tad-evolution-directions | E | Superseded and kept for history per MEMORY.md index annotation |
| 30 | project_tad-next-direction | E | Strategic direction that has since been executed (packs rebuilt as SKILL-form capability packs); historical record |
| 31 | project_tad-universal-method | E | Pending product direction; nothing operational to distill yet |
| 32 | project_tier1-workflow-formalization | E | Epic status; its generalizable bits are already held elsewhere (sub-agents can't spawn/orchestrate → gate-design.md 2026-05-x Conductor entry; claims-need-carriers → gate-design) |
| 33 | project_yolo-audit-findings | A | principles.md "YOLO Epic Execution: Cross-Model Audit Findings - 2026-05-15" (SAFETY) carries the same 4 discoveries + 4 actions nearly verbatim |
| 34 | reference_claude-code-source | E | Pointer/reference card to external source tree — reference material, stays memory |
| 35 | user_agent-builder-goals | U | User profile |

### Journal findings (7) — memory-redirect-capture-layer-2026-07-12

| # | Finding | Bucket | One-line reason |
|---|---------|--------|-----------------|
| J1 | parity --fix mirrors gitignored local/ into tracked .agents tree | **G** | New failure CLASS for the deny-list family: ignore semantics are path-specific and do not survive mirroring (privacy leak, vs the L1 entries' omission/clobber classes) → Entry E6. Root fix (parity exclude local/) still OPEN — needs Alex bugfix handoff |
| J2 | parity is a race against concurrent terminals | **G** | "Global set-equality gates structurally can't PASS under concurrent mutation → scope-level evidence + quiet-point rerun" passes variabilize; combined with J3 → Entry E5 |
| J3 | git index is shared across terminals; pathspec-commit protects riders | **G** | `git commit -- <pathspec>` vs bare commit with staged riders; caught by reviewer, not doer; uncaptured → Entry E5 (combined with J2) |
| J4 | index/ledger files inherit max sensitivity of what they summarize | **G** | Clean variabilized skeleton (any auto-maintained index over mixed-sensitivity content); uncaptured → Entry E3 |
| J5 | mechanical credential grep = 4/4 false positives; email sweep = precise | A | Same smoke-alarm-vs-ground-truth substance as principles.md 2026-05-31 ("treat the count as a smoke alarm, the line-SET diff as ground truth") + 2026-04-15 ("smoke alarm not fire suppressor"); the journal adds an instance, not a new rule |
| J6 | git-index-reading ACs are vacuous pre-staging | **G** | "Index-derived verifier passes trivially on empty enumerated set" — new sub-pattern for ac-verification (not covered by dry-run discipline entries) → Entry E4 |
| J7 | SLUG derivation rule confirmed empirically; WARN path unexercised | E | One-off empirical confirmation of an existing script's behavior — session log |

---

## 2. GRADUATE-L2 Draft Entries (for Alex review)

9 draft entries (J2+J3 merged). Sources are cited; dates absolute per knowledge-writing-rules.

---

### E1. YOLO Worktree Isolation Produces False-FAIL Reviews — Reviewers Must Ground in the Tree the Implementer Wrote To - 2026-07-05
- **Suggested file**: `patterns/gate-design.md`
- **Discovery**: When a yolo-epic run executes the implement agent inside a git worktree (`.claude/worktrees/wf_*-N/`) but the impl reviewers inspect the main repo, every worktree-isolated task gets judged "implementation absent" — a false FAIL hit 3 separate times in the 2026-07-05 surplus burn (~6M tokens). The deliverables existed; they lived in the worktree, not the main tree. Two sibling failures from the same session: (a) surplus-execute counted a task "executed" whenever yolo-epic returned without error, ignoring `impl_review_p0_count` — "executed" ≠ "review PASS"; (b) round-2 review of P0 fixes caught NEW defects introduced by the fixes themselves (AC13 unit mismatch, sed recipe bug) — 2 independent reviewers converging = real defect, not review inflation.
- **Action**: Any review/verification step in a multi-agent pipeline must receive the working-tree PATH the implementer used (the worktree dir), never assume repo root. The Conductor must read the review VERDICT (P0 count), not the runner's exit status, before counting a task done. Merge worktree deliverables to main before dispatching follow-on tasks that assume main-tree state. Re-review fixes with the same independence as the original implementation.
- **failure_mode**: Naive default: dispatch impl reviewers with repo root as cwd and treat "workflow completed without error" as task success. Why wrong: worktree-isolated implementations are invisible at repo root, so reviewers report "implementation absent" (false FAIL — 3 occurrences in one session), and error-free execution can carry unresolved P0s — both misclassify the task's true state and either burn re-runs or ship unreviewed work.
- **Grounded in**: project_surplus-burn-mode.md (2026-07-05/06 findings 1-2), .tad/active/session-state.md QUEUE, .tad/evidence/surplus-burn-20260705/scripts/

### E2. Workflow `args` Are Not Injected in EITHER `name:` OR `scriptPath:` Mode — Hardcode a Default or Go Conductor-Manual - 2026-06-13, re-confirmed 2026-07-05
- **Suggested file**: `patterns/ac-verification.md` (extends the 2026-06-08 "Also surfaced: args did not propagate" note into a full entry)
- **Discovery**: `Workflow({name:'yolo-epic', args:{...}})` failed twice with instant 0-agent `{"error":"missing required args"}` (29ms/7ms) on 2026-06-13, regardless of args as string or object. On 2026-07-05 surplus-scan confirmed the `scriptPath` invocation ALSO fails to inject args — the script-side `args` global stays empty in both modes. Working workaround for few-scalar-args cases: Edit the persisted script to hardcode the required arg as a default (e.g., `if (!dateStamp) dateStamp = '2026-07-05'`), then re-run via scriptPath with no args — one-shot success (64 candidates, 4 agents). NOTE: `.claude/skills/alex/references/yolo-execution-protocol.md` L33 still instructs "args MUST be a JSON object, NOT a stringified JSON string" as if injection works — the protocol contradicts observed harness behavior and needs an Alex fix.
- **Action**: After 2 consecutive arg-injection failures, stop retrying the Workflow path. Few scalar args → hardcode defaults into the persisted script, re-run via scriptPath. Complex args (large arrays) → Conductor-manual fallback: spawn 1 implement sub-agent (general-purpose, run_in_background) per handoff → SendMessage for iterations → ≥2 independent reviewers → Conductor personally runs ACs for Gate 3.
- **failure_mode**: Naive default: keep re-invoking the Workflow with differently-shaped args (string vs object, name vs scriptPath) assuming a formatting mistake. Why wrong: args are not plumbed into the script global in either invocation mode in this harness — every retry fails identically at 0 agents; only hardcoded defaults or Conductor-manual orchestration makes progress.
- **Grounded in**: feedback_yolo-epic-workflow-args.md, surplus-scan run 2026-07-05, .claude/skills/alex/references/yolo-execution-protocol.md L20-40

### E3. Auto-Maintained Index/Ledger Files Inherit the MAX Sensitivity of What They Summarize - 2026-07-12
- **Suggested file**: `patterns/memory-and-learning.md`
- **Discovery**: MEMORY.md (the native auto-memory index) looked like plumbing, but its one-line hooks reproduced the substance of 3 SENSITIVE files in compressed form (user-profile summary, deliberately-parked seed idea, leaked-source-analysis reference) — and it keeps absorbing future one-liners with no re-triage. Sensitivity triage that classifies only content files leaves the summarizing index publishable, defeating the per-file protections.
- **Action**: When triaging files for publication/gitignore, include every auto-maintained index/ledger/summary file and assign it the maximum sensitivity of anything it summarizes — permanently, because it absorbs future entries without review. Gitignore the index alongside (or instead of) its sources.
- **failure_mode**: Naive default: sensitivity-triage only "content" files and wave through index/registry/summary files as harmless plumbing. Why wrong: a summarizing index reproduces its sources' substance in compressed form and keeps absorbing new entries with no re-triage — one `git add -A` publishes the compressed version of every sensitive file it indexes.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md finding 4

### E4. Verification Commands That Read the Git Index Are Vacuous Before Staging - 2026-07-12
- **Suggested file**: `patterns/ac-verification.md`
- **Discovery**: An AC ran a `git ls-files`-derived grep before anything was staged; the empty enumerated set made the grep scan nothing and the AC PASSed trivially. Re-run after `git add` (29 files in the index) produced the non-vacuous result; an independent direct 29-file scan corroborated. Generalizes: any verifier whose input set is enumerated from repo state (index, staged set, tag, branch diff) passes trivially when that state is empty or not yet populated.
- **Action**: For any AC built on `git ls-files`/index/diff-set enumeration: assert the enumerated set is NON-EMPTY first (e.g., `test $(git ls-files -- <paths> | wc -l) -gt 0`) or sequence the AC explicitly AFTER the populating step (git add/commit). Prefer verifiers that fail loudly on empty input sets.
- **failure_mode**: Naive default: run an index-derived verification command at whatever point is convenient and read PASS at face value. Why wrong: pre-staging, the enumerated set is empty, so the scan runs on nothing and PASSes vacuously — the check certifies nothing while looking green, exactly the false-green class Gate 3 exists to prevent.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md finding 6 (AC10)

### E5. Concurrent Terminals Share the Git Index and Source Trees: Pathspec-Scope Commits; Run Global Gates at Quiet Points - 2026-07-12
- **Suggested file**: `patterns/handoff-design.md`
- **Discovery**: While one terminal completed a handoff, the SHARED git index already held 2 pre-staged files from another terminal (post-write-sync.sh, detect-state-fixture.sh); a bare `git commit` would have swept those riders into the wrong commit. `git commit -- <pathspec>` committed only the 52 in-scope paths and left the riders staged for their owner — caught by the spec-compliance reviewer, not the doer, who had checked only the worktree. Same session: the global parity set-equality gate could not PASS while the other terminal kept mutating `.claude/skills` ("both sides have uncommitted changes — cannot determine direction / STOP"), and a `parity --fix` mid-flight mirrored the other workstream's half-built state; byte-level `cmp` of the in-scope mirror files was the honest scope-level substitute.
- **Action**: In any repo where multiple terminals/agents work concurrently: commit with an explicit pathspec (`git commit -- <your paths>`) and inspect STAGED entries (`git status`), not just worktree changes, before committing. Run global consistency gates (parity set-equality, `diff -r`) only at quiet points (e.g., pre-*publish); mid-flight, present scope-level evidence (cmp of in-scope files) and explicitly defer the global re-run — do not force `--fix`.
- **failure_mode**: Naive default: run bare `git commit` after checking only your own worktree edits, and treat a mid-flight global parity FAIL as your defect to force-fix. Why wrong: the index is shared state — a bare commit sweeps another terminal's staged riders into your commit; and a global set-equality gate structurally cannot PASS under concurrent mutation, so forcing `--fix` mirrors half-built alien state into the destination tree.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md findings 2-3

### E6. A Mirror/Parity `--fix` That Copies a Tree Wholesale Destroys the Source's Gitignore Semantics - 2026-07-12
- **Suggested file**: NEW theme `patterns/release-sync.md` (mirror/parity/install hazards; sibling of the L1 deny-list principles — this is a third failure class: privacy leak, alongside the L1 entries' omission and clobber)
- **Discovery**: `release-verify.sh parity --fix` rsyncs `.claude/skills` → `.agents/skills` wholesale. `.claude/skills/local/` is gitignored by contract (save-skill: local-only, never distributed), but the mirror copied it to `.agents/skills/local/`, where NO ignore rule existed — local-only content became git-visible in a PUBLIC repo. On 2026-07-12 only harmless scaffolds (`_example.md`/`_index.md`) leaked, but any real local skill would have been one `git add -A` from publication. Ignore rules are PATH-specific: they do not travel with mirrored content. Mitigation applied (rm + `.agents/skills/local/` added to .gitignore); ROOT FIX STILL OPEN — parity tool must exclude `local/` (needs an Alex bugfix handoff).
- **Action**: For every mirror/sync/parity tool, make the exclusion set include the source side's ignored-by-contract subtrees (e.g., rsync `--exclude local/`), AND add matching ignore rules on the destination side as defense-in-depth. Whenever a "never distribute" contract is attached to a path, sweep every mirror/copy loop that touches its parent tree — the same every-granularity discipline as the L1 deny-list principles (2026-06-01), extended to ignore semantics.
- **failure_mode**: Naive default: trust that gitignored content stays private because the source path is ignored, then mirror the parent tree wholesale. Why wrong: gitignore semantics are path-specific — the mirrored copy at the destination has no ignore rule, so private-by-contract content silently becomes trackable/publishable in the destination tree, converting an isolation contract into a publication vector.
- **Grounded in**: .tad/evidence/journal/memory-redirect-capture-layer-2026-07-12.md finding 1, .tad/hooks/lib/release-verify.sh (parity), .gitignore (`.agents/skills/local/` entry)

### E7. Execution Gets Context, Review Gets Persona — Domain Constraints Harm Doing but Sharpen Checking - 2026-04 (validated across Domain Pack → Capability Pack eras)
- **Suggested file**: `patterns/pack-build-rules.md`
- **Discovery**: A domain persona during EXECUTION ("you are a hardware expert, think only from the hardware perspective") narrows cross-domain creativity; the SAME narrowing during REVIEW ("check this design ONLY for safety issues") is the feature — an intentionally narrow lens catches what a generalist misses. The load-bearing distinction is context vs constraint: "this project involves PCB design" activates knowledge; "only think about hardware" restricts it. Role personas (Alex = Solution Lead, Blake = Execution Master) define who does what, not what to think about — they remain valid.
- **Action**: When designing agents, packs, or prompts: give the executing agent domain context + tools + standards, never a knowledge-scoping persona. Reserve specialized personas for gate/review steps, where adversarial narrowing adds value. Test: if a persona clause tells the agent what NOT to think about during execution, delete it.
- **failure_mode**: Naive default: assign a domain-expert persona to the executing agent to "raise quality". Why wrong: LLMs already hold broad domain knowledge — a scoping persona suppresses cross-domain solutions (e.g., a software fix to a "hardware" problem) while adding nothing that plain domain context wouldn't activate; the identical narrowing pays off only adversarially, at review time.
- **Grounded in**: feedback_execution-review-separation.md, project_domain-pack-design.md ("做事不设限，审查设视角", expert-review-validated 2026-04-01), current gate protocols (specialized reviewers exist only at Layer 2/Gates)

### E8. Evaluate External Tools by Whether Their Value Comes From LLM Features the Host Agent Already Has - 2026-07-03
- **Suggested file**: `patterns/pack-build-rules.md` (alongside "Skill File vs MCP Tool Boundary")
- **Discovery**: The gbrain knowledge-search POC scored 1/5 — its mechanical layer (BM25 without embeddings + entity graph over absent wikilinks) ≈ grep, while its real value lives in LLM-derived features (embeddings, think-style synthesis) that Claude natively provides. The rebuilt TAD-native design (a 250-line generated index file + a general-purpose agent as the semantic engine) scored 5/5 with zero external dependencies. The import step itself was flawless (2282 files, 50s, 0 errors) — a working install proved nothing about value.
- **Action**: Before importing an external knowledge/search/memory tool, split its value proposition into mechanical features vs LLM-derived features. If the LLM-derived part is what you want, build a thin wrapper around the host agent's native capabilities (index file + agent) instead of adopting the tool's stack. Gate the decision on a small pass/fail POC (~5 representative queries) with a pre-committed pivot threshold.
- **failure_mode**: Naive default: adopt the external tool wholesale because the demo is impressive and the install succeeds. Why wrong: when the tool's value is LLM features the host agent already has, you import only its mechanical residue (BM25 ≈ grep, empty entity graphs) plus dependency and maintenance cost — a thin native wrapper outperforms the full stack, as measured 1/5 vs 5/5.
- **Grounded in**: project_tad-brain-knowledge-search.md, .tad/evidence/poc/ (gbrain NEGATIVE-RESULT + TAD-native 5/5), .tad/hooks/lib/brain-index-gen.sh

### E9. Verify Content Lineage Before Deleting "Duplicates" — Newer Format ≠ Newer Content - 2026-04 (v2.7→v2.8 transition)
- **Suggested file**: `patterns/memory-and-learning.md` (file/knowledge maintenance, next to staleness detection)
- **Discovery**: During the v2.7→v2.8 transition, `skills/` had the NEWER format (frontmatter) but OLDER content (v2.7 slim versions missing the Quality Chain fixes), while `commands/` had the older format but NEWER content (the v2.8 fixes). Keeping the newer-format copy and deleting the other would have silently reverted 4 phases of critical quality-chain repairs. Format migrations and content updates travel on independent tracks.
- **Action**: Before deleting an apparent duplicate: check `git log` dates for BOTH files; when sizes differ significantly (e.g., 570 vs 3056 lines) investigate WHY instead of assuming the smaller is "refined"; read the evolution history (handoffs/commits) for the file pair. Verify content, not names or formats.
- **failure_mode**: Naive default: keep the file with the newer format/naming convention and delete the other as a stale duplicate. Why wrong: the newer-format copy can carry older content — format-based deletion silently reverts real fixes, and the loss surfaces only when the reverted behavior recurs.
- **Grounded in**: feedback_verify-before-delete.md, v2.7→v2.8.1 quality-chain repair history (principles.md "Judgment-Only Skill Files" 2026-04-04)

---

## 3. Bucket Totals

| Bucket | Memory files (35) | Journal findings (7) | Total (42) |
|--------|-------------------|----------------------|------------|
| GRADUATE-L2 | 5 | 5 | **10** (→ 9 draft entries; J2+J3 merged into E5) |
| ALREADY-CAPTURED | 8 | 1 | **9** |
| EPISODIC | 14 | 1 | **15** |
| USER-PREF | 5 | 0 | **5** |
| STALE | 3 | 0 | **3** |

STALE actions suggested for Alex: (16) auto-evolve-epic — mark "How to apply" superseded by self-evolution-pruning; (20) domain-pack-design — mark architecture retired, pointer to .tad/archive/domains/; (24) quality-chain-failure — clear the "⚠️ P0 next session" flag in the file and in MEMORY.md index (resolved since v2.8.1).

Open item carried from J1/E6: parity tool root fix (exclude `local/` from the rsync) is NOT done — needs an Alex bugfix handoff.

Side observation (not a bucket): MEMORY.md indexes `project_conductor-architecture.md`, but no such file exists in `.tad/memory/` — stale index row.
