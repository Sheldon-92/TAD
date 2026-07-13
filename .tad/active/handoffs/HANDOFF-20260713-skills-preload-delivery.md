---
handoff_id: HANDOFF-20260713-skills-preload-delivery
date: 2026-07-13
from: Alex (Terminal 1)
to: Blake (Terminal 2) / YOLO workflow agent (user-approved this session)
express: false
epic: none (standalone follow-up of archived EPIC-20260712-native-capability-adoption P2 FR5)
priority: P2 (small, unblocked capability delivery)
scope_estimate: "2 files created/modified + evidence; ~30-45 min"
git_tracked_dirs: [".claude/agents", ".tad/evidence/spikes/subagent-frontmatter-2026-07"]
supersedes: none
feedback_required: false
---

# HANDOFF: Skills-Preload Delivery — security-auditor ← code-security (P2 FR5 static pairing)

> **STATUS 2026-07-13 PM: BLOCKED at §5 AC1a-FAIL row (pre-authorized branch).**
> AC1a headless preload probe FAIL 5/5 (implementer) + 1/1 (Conductor independent) — the
> morning re-spike PASS(provisional) was refuted; confound mechanism identified (`Skill` tool
> not in probe ban list + `--disallowedTools` variadic mis-parse). Def staged UNTRACKED in
> `.claude/agents/` solely to enable **AC1b next fresh session — now the DECISIVE test**
> (interactive-harness spawn path ≠ headless path). AC1b PASS → resume merge per handoff;
> AC1b FAIL → strip `skills:` key / drop def, VERDICT-skills stays FAIL, close as
> BLOCKED-UNTIL-CLI-support. Evidence: fr5-delivery-evidence.md + spike-report.md ADDENDUM #2.

## 1. Context & Intent

### 1.1 Why now
EPIC-20260712-native-capability-adoption Phase 2 designed FR5 (static skills pairing) but the
spike proved the `skills` subagent-frontmatter field **INERT on CLI 2.1.172** → FR5 was NOT
delivered (sanctioned degradation, spike-report.md). On 2026-07-13 the CLI was upgraded to
**2.1.207** and the re-spike flipped the verdict: **VERDICT-skills: PASS (provisional)** —
with tools banned, the spike agent quoted 3 rules verbatim-authentic to
`.claude/skills/code-security/SKILL.md` (grep-verified: "72% of organizations" ×1, "exit 183" ×2).
The re-spike explicitly instructed: "queue as small handoff, do NOT ad-hoc" (spike-report.md
RE-SPIKE ADDENDUM, commit b50ad42).

### 1.2 Intent statement
Deliver the already-designed, already-expert-reviewed P2 FR5: a project-level
`.claude/agents/security-auditor.md` def that statically preloads the `code-security`
capability pack via the `skills:` frontmatter field, so the security review lens spawns with
the pack's judgment rules already in context (no Read round-trip, no dependence on handoff
transcription for this stable pairing).

### 1.3 Design authority (do not re-litigate)
All design decisions inherit from the archived, Gate-2-passed
`HANDOFF-20260713-native-capability-adoption-phase2.md` (§FR5, §11):
- **Static pairing ONLY**: `security-auditor ← code-security`. Dynamic per-task pack loading
  stays with Blake SKILL 1_5a — **zero changes to Blake SKILL** (P2 AC9 carried over as AC6 here).
- **Body-copy strategy** (shadowing PASS branch): user-level `~/.claude/agents/security-auditor.md`
  body copied verbatim into the project def (self-contained, git-reviewable; duplication accepted —
  precision > DRY, P2 §11). **User approved public-repo copy 2026-07-13** (content is a generic
  OWASP review persona; no personal info — security reviewer re-confirms in Gate 2).
- **NO `memory:` key**: field still inert on 2.1.207 (re-spike). A dead key = config theater (ban).
- **Budget note lives in the DEF BODY**, not Blake SKILL (P2 arch P2-2): frontmatter preload is
  invisible to Blake 1_5a's pack≤2 accounting → two independent budgets, this agent's effective
  cap becomes 1+≤2. Documented tradeoff, not an oversight.

## 2. Functional Requirements

### FR1 — Project-level def `.claude/agents/security-auditor.md`
Exact assembly order:
1. **Frontmatter**:
   ```yaml
   ---
   name: security-auditor
   description: <verbatim copy of user-level description line>
   model: opus            # preserve source model
   skills:
     - code-security      # list form — the exact form spike-verified on 2.1.207
   ---
   ```
   NO `memory:` key. No other keys.
2. **Provenance line** (immediately after closing `---`; **exactly ONE line, no blank line
   before or after it** — AC3's `sed -n '2,$p'` drops precisely this line):
   `<!-- shadowed-from: ~/.claude/agents/security-auditor.md md5=99b98017ac28c4e68ef7afb8cc1a51ca date=2026-07-13 (frozen project copy; source may drift, this copy is authoritative for TAD Gate 3) -->`
   (md5 recomputed at copy time via `md5 -q ~/.claude/agents/security-auditor.md`; the value
   above is the 2026-07-13 11:xx reading — if it differs at implementation time, use the fresh
   value and note the drift in evidence.)
3. **Body**: byte-verbatim copy of the user-level def's body (everything after its closing `---`).
4. **Appended section** (after the copied body, separated by a blank line):
   ```markdown
   ## Preloaded Pack Budget (TAD)

   This def statically preloads the `code-security` capability pack via the `skills:`
   frontmatter field (verified via headless probe on Claude Code 2.1.207; direct-spawn
   confirmation AC1b pending — see fr5-delivery-evidence.md; INERT on ≤2.1.172).
   - This preload is INVISIBLE to Blake SKILL 1_5a's pack≤2 accounting — two independent
     budgets. This agent's effective pack cap is therefore 1 (static) + ≤2 (dynamic 1_5a).
     Recorded tradeoff per P2 arch review P2-2, not an oversight.
   - NO `memory:` frontmatter key: the field is inert as of CLI 2.1.207 (spike-report.md
     RE-SPIKE ADDENDUM). Do not add it until a future re-spike flips VERDICT-memory.
   ```

### FR2 — Delivery evidence file
`.tad/evidence/spikes/subagent-frontmatter-2026-07/fr5-delivery-evidence.md` containing:
raw outputs of every AC below (commands + verbatim output), the AC1b PENDING record, and a
side-effect cleanliness section (AC7).

### FR3 — Bookkeeping (Conductor/Alex post-merge, NOT the implementer)
NEXT.md queue item updated; completion report; commit. **MUST enqueue NEXT.md item
`AC1b-direct-spawn-confirm` (next fresh session, Alex direct Agent-tool spawn) — this item
blocks full-Done status; until it records PASS the delivery status is
DONE-PROVISIONAL(headless-verified).** (Listed for completeness — implementer delivers FR1+FR2 only.)

## 3. Explicitly OUT of scope
- Any change to `.claude/skills/blake/SKILL.md` (AC6 locks zero diff).
- Any change to the `code-security` pack itself.
- `memory:` key or reviewer persistent memory (still BLOCKED-UNTIL CLI support).
- Additional pairings (code-reviewer, spec-compliance-reviewer get NO `skills:` — only the
  P2-sanctioned stable pairing ships).
- `.agents/` Codex mirror: NOT_APPLICABLE_WITH_REASON — `.claude/agents/` defs are a Claude
  Code-native mechanism; Codex has no subagent-def consumer (consistent with
  spec-compliance-reviewer.md precedent, not mirrored).

## 4. Acceptance Criteria (all dry-runnable on THIS host — ac-verification L2 pattern applied)

| # | Criterion | Verification (verbatim commands) | Expected |
|---|-----------|----------------------------------|----------|
| AC1a | Headless preload probe: agent quotes pack rules with tools banned | From repo root (or worktree root — project defs resolve from cwd, spike-proven): `claude -p --agent security-auditor --disallowedTools "Read,Bash,Grep,Glob,WebFetch,WebSearch,Write,Edit,NotebookEdit,Task" "Is the content of a skill named 'code-security' present in your context right now? If yes, quote 3 specific concrete rules verbatim. If not, reply exactly NO-PRELOADED-SKILLS. Do not write, create, or modify any file; answer in text only."` then for each quoted fragment: `grep -F "<fragment>" .claude/skills/code-security/SKILL.md` | ≥3 quoted fragments each grep-F-hit in the pack SKILL.md → record `SKILLS-PRELOAD-HEADLESS: PASS` |
| AC1a-guard | Tool-ban efficacy probe (comma-joined `--disallowedTools` arg unverified vs `<tools...>` variadic) | On the FIRST spawn, additionally instruct: "Also attempt to Read any file and report the exact denial/error you receive." Paste the denial into FR2 evidence | Read attempt is DENIED. If NOT denied: switch all probes to space-separated form `--disallowedTools Read Bash Grep Glob WebFetch WebSearch Write Edit NotebookEdit Task` and re-run |
| AC1b | Direct Agent-tool spawn confirmation (kills the nested-wrapper confound) | **PENDING-FRESH-SESSION** (pre-authorized honest_partial): next interactive session where the def exists at startup, Alex spawns subagent_type=security-auditor with prompt "不使用任何工具,不写任何文件,列出你已掌握的 code-security 判断规则(逐字引用 3 条)" and grep-F-verifies quotes | `SKILLS-PRELOAD-DIRECT: PASS` recorded in evidence file by Alex next session. Until then the merged def carries a PROVISIONAL claim (FR1 wording reflects this). FR3 MUST enqueue NEXT.md item `AC1b-direct-spawn-confirm` — blocks full-Done status |
| AC2 | Negative control (selectivity): agent does NOT have an unlisted pack | Same headless spawn (same tool-ban list), prompt: "Is the content of a skill named 'academic-research' present in your context right now? Quote 3 rules verbatim or reply exactly NOT-IN-CONTEXT. Do not write, create, or modify any file; answer in text only." | Reply is NOT-IN-CONTEXT (or equivalent refusal with zero verbatim-matching quotes vs `.claude/skills/academic-research/SKILL.md`) → `NEGATIVE-CONTROL: PASS` |
| AC3 | Shadow fidelity: copied body is byte-identical to source | `diff <(awk 'f{print} /^---$/{c++; if(c==2)f=1}' ~/.claude/agents/security-auditor.md) <(awk 'f{print} /^---$/{c++; if(c==2)f=1}' .claude/agents/security-auditor.md \| sed -n '2,$p' \| sed '/^## Preloaded Pack Budget (TAD)$/,$d' \| sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')` — implementer MAY substitute an equivalent extraction (e.g. line-count arithmetic) but MUST show the diff is empty | Empty diff (copied region byte-identical; provenance line + appended section excluded from comparison) |
| AC4 | No config theater | `grep -c '^memory:' .claude/agents/security-auditor.md \|\| true` (compare STDOUT to `0`; do not gate on exit code — grep -c exits 1 on zero matches) | stdout `0` |
| AC5 | Frontmatter lint | `bash .tad/evidence/spikes/subagent-frontmatter-2026-07/fm-lint.sh` | `FM-OK (2 files)` (spec-compliance-reviewer.md + new def) |
| AC6 | Blake SKILL untouched | `git diff --stat HEAD -- .claude/skills/blake/SKILL.md` | Empty output |
| AC7 | Headless side-effect cleanliness — WHOLE-TREE (ground truth #6: `claude -p` fires repo lifecycle hooks; precedent: re-spike agent once wrote a stray marker into `.tad/memory/`) | `git status --porcelain \| grep -vE '\.claude/agents/security-auditor\.md$\|fr5-delivery-evidence\.md$'` captured BEFORE first and AFTER last headless spawn; diff the two captures. Explicitly eyeball `.tad/memory/`, `.tad/github-registry/REGISTRY.yaml`, `.tad/evidence/traces/` in the diff | The two captures identical EXCEPT append-only trace lines (acceptable IF noted). REGISTRY flip or any `.tad/memory/` write is NOT acceptable → §5 branch |
| AC8 | Provenance md5 honest | `md5 -q ~/.claude/agents/security-auditor.md` vs md5 value inside the provenance line | Equal |

## 5. Degradation matrix (pre-authorized branches)
| Outcome | Action |
|---------|--------|
| AC1a FAIL (NO-PRELOADED-SKILLS despite def) | **BLOCKED — do not merge.** The re-spike PASS was provisional (nested-wrapper confound); a FAIL here means the confound was real. Escalate with raw output; def is NOT committed with a false capability claim. |
| AC2 FAIL (unlisted pack also quotable) | Field semantics = "all skills leak" not "selective preload" → deliver def anyway (preload still real) but REWRITE the Preloaded Pack Budget section to state non-selectivity; escalate finding to spike-report addendum. |
| AC7 REGISTRY flip or `.tad/memory/` write detected | Revert the flip (`git checkout -- .tad/github-registry/REGISTRY.yaml`) / delete the stray memory file, note in evidence (precedents: P3 REGISTRY rollback; re-spike memory-marker cleanup). |
| AC1b FAIL next session (direct spawn shows NO preload) | The nested-wrapper confound was real → strip the def's preload claim (rewrite Preloaded Pack Budget section to "headless-only evidence, direct-spawn REFUTED") or quarantine the `skills:` key; escalate to spike-report addendum. Def body-copy itself stays (shadowing is independently proven). |
| AC3 FAIL (body not byte-identical) | Re-copy the body via the awk extraction; do NOT hand-edit the diff away. |
| fm-lint FAIL | Fix frontmatter before any AC re-run; lint is cheap and prior. |

## 6. Files to Modify / Create
| File | Action |
|------|--------|
| `.claude/agents/security-auditor.md` | CREATE (FR1) |
| `.tad/evidence/spikes/subagent-frontmatter-2026-07/fr5-delivery-evidence.md` | CREATE (FR2) |

(NEXT.md / completion report / spike-report cross-ref line = Conductor bookkeeping, not implementer scope.)

## 7. §8.4 Friction Preflight
- `claude` CLI 2.1.207 on PATH — VERIFIED 2026-07-13 (`claude --version`).
- `~/.claude/agents/security-auditor.md` exists, 74 lines, md5 `99b98017ac28c4e68ef7afb8cc1a51ca` — VERIFIED.
- `.claude/skills/code-security/SKILL.md` exists — VERIFIED.
- `.claude/skills/academic-research/SKILL.md` exists (negative-control target) — VERIFIED (pack listed).
- `fm-lint.sh` at `.tad/evidence/spikes/subagent-frontmatter-2026-07/fm-lint.sh` — VERIFIED (bash 3.2/BSD-safe, stdlib only).
- No gh/network/pyyaml dependency anywhere in the ACs.
- Headless spawns cost ~1 short session each (3 total: AC1a, AC2, and one retry allowance).

## 8. Layer 1 (implementer self-check before review)
- Assembly order of FR1 exactly as specified (frontmatter → provenance → body → appended section).
- Run AC3/AC4/AC5/AC8 locally before requesting review (file-level checks, no spawns needed).
- Run AC1a/AC2/AC7 once; paste RAW outputs into FR2 evidence (no paraphrase).

## 9. Review requirements (Gate 3)
- ≥2 distinct reviewers: (1) spec-compliance row-by-row on §4 table; (2) code-reviewer or
  security lens on def content fidelity + public-repo sensitivity of the copied body.
- Any FAIL without a §5 sanctioned branch = block merge.

## 10. Decision Summary
| Decision | Source | Status |
|----------|--------|--------|
| Static pairing only; 1_5a untouched | P2 handoff §11 (Gate 2 passed) | Inherited |
| Body-copy w/ provenance md5 | P2 handoff §FR2/§259 | Inherited |
| Public-repo copy of user-level persona | User AskUserQuestion 2026-07-13 | ✅ Approved |
| YOLO this session; AC1b honest-partial next session | User AskUserQuestion 2026-07-13 | ✅ Approved |
| Negative-control pack = academic-research | This handoff (new) | Content-distinctive, security-unrelated |
| No `.agents` mirror | This handoff §3 | NOT_APPLICABLE_WITH_REASON |

## 11. Audit Trail (Gate 2 expert review record)

| Reviewer | Lens | Verdict | Findings | Resolution |
|----------|------|---------|----------|------------|
| code-reviewer (2026-07-13) | Correctness + AC runnability; dry-ran AC3/4/5/6/8 live on host incl. mock-target discrimination test | NEEDS-FIXES (0 P0, 2 P1, 4 P2) | P1: AC1b no FAIL branch/tracking; P1: FR1 "verified working" overclaim; P2: tool-ban arg form unverified, AC4 exit-code trap, AC3 provenance-offset coupling, AC3/AC8 missing §5 rows | ALL integrated: §5 AC1b-FAIL + AC3-FAIL rows, FR3 NEXT.md enqueue mandate, FR1 wording → "headless probe…AC1b pending", AC1a-guard row added, AC4 `\|\| true` + stdout note, FR1 step2 one-line constraint |
| security-auditor (2026-07-13) | Public-repo sensitivity scan (line-by-line, full 74 lines) + pollution surface + gitignore | NEEDS-FIXES (0 P0, 1 P1, 4 P2); **SENSITIVITY-SCAN: CLEAN** | P1: probe spawns retain write tools + AC7 scope misses `.tad/memory/` (prior incident class); P2: frozen-copy provenance note | ALL integrated: disallowedTools += Write,Edit,NotebookEdit,Task; no-write clause in both probe prompts; AC7 → whole-tree porcelain diff + explicit `.tad/memory/` eyeball; provenance frozen-copy annotation |

Gate 2 check (2026-07-13): expert review ≥2 distinct ✅ · P0 = 0 ✅ · all P1 integrated ✅ ·
design completeness (FR assembly order / AC table / degradation matrix / friction preflight) ✅ ·
user approvals recorded (§10) ✅ → **GATE 2: PASS**
