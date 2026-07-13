# Phase 4 Design Review — code-reviewer

**Handoff:** HANDOFF-20260713-native-capability-adoption-phase4.md
**Reviewer:** code-reviewer (AC command runnability, self-leak, frontmatter/YAML, file completeness, design coherence)
**Date:** 2026-07-13
**Verdict:** CHANGES REQUESTED — 2 P0 (AC commands broken at baseline), 4 P1, 3 P2

All baseline claims in §2.2 independently re-verified and CONFIRMED (preview count 0, rules dir absent,
mirror IDENTICAL, merged_design anchor L146, source pattern file 123 lines, all 5 AC12 source keys present).
Frontmatter (task_type/e2e_required/research_required/git_tracked_dirs/skip_knowledge_assessment/gate4_delta)
all filled and coherent. File lists §7.1/§7.2 are complete for the stated design. The problems are in AC
command correctness — several ACs pass or fail at BASELINE regardless of implementation, which is exactly
the Validation-Theater failure mode the handoff itself warns against.

---

## P0 — Blocking

### P0-1: AC5 false-positives on `.jsonl` — FAILS at baseline with zero `.js` changes
`AC5` method: `git diff --stat | grep -c '\.js'`, expected `0`.

`.js` is an unanchored substring of `.jsonl`. The working tree already has 3 modified `.jsonl` files
(evidence traces/decisions), and this Epic produces more evidence writes. Verified live:

```
$ git diff --stat | grep -c '\.js'
3        # .tad/evidence/decisions/2026-07-12.jsonl, traces/2026-07-12.jsonl, traces/2026-07-13.jsonl
```

The AC returns ≥3 at baseline → Gate 3 marks AC5 FAIL even though NFR1 (zero code) is satisfied. This is a
false-negative on the single most important guardrail of track (a) ("no .js edits").

**Fix:** anchor to the filename, not a substring. Verified both work at baseline (return 0):
```
git diff --name-only | grep -c '\.js$'          # → 0  (recommended)
# or: git diff --stat | grep -cE '\.js[[:space:]]'
```

### P0-2: AC10 uses `import yaml` — module not installed; command errors regardless of file validity
`AC10` method: `python3 -c "import yaml,sys; yaml.safe_load(...)"`, expected `PARSE-OK`.

Verified live: the environment's `python3` (/opt/homebrew/bin/python3) has NO `yaml` module:
```
$ python3 -c "import yaml" → ModuleNotFoundError: No module named 'yaml'
```
AC10 will raise `ModuleNotFoundError` for ANY rule file — a valid frontmatter cannot pass. The rest of TAD
validates YAML with `yq` (see release-runbook SKILL.md L57 `yq . .tad/deprecation.yaml`), not pyyaml.

**Fix:** use a validator that exists in this env (both verified working live):
```
yq '.' <(sed -n '/^---$/,/^---$/p' .claude/rules/shell-portability.md | sed '1d;$d') >/dev/null && echo PARSE-OK
# or:
ruby -ryaml -e 'YAML.load(File.read(".claude/rules/shell-portability.md").split("---")[1]); puts "PARSE-OK"'
```
(The `MANDATORY READ` §步骤2 also tells Blake to "用 python3 yaml.safe_load 验证" — same broken instruction,
fix both.)

---

## P1 — Should Fix

### P1-1: AC3 does not discriminate — baseline already satisfies the `≥2` threshold
`AC3` method: `grep -cE 'preference|step1_5b' <file>`, expected `≥2`.

Verified live: baseline count is **5** — every hit is a pre-existing `step1_5b` reference (L17/18/20/124/158),
NONE related to the new named negative example FR1 requires. AC3 PASSES before Blake writes a single line, so
it cannot prove the negative example ("pack 选择 as named preference question") was actually added.

**Fix:** scope to the rule block or a discriminating token, e.g. require the co-occurrence inside the new
block: `grep -A15 'preview_usage_rule' <file> | grep -cE 'preference'` ≥ 1, or search for a phrase the
negative example must contain (e.g. `never_when.*preference` proximity). AC1's `never_when|multiSelect`
(baseline 0, threshold ≥2) IS a good discriminator — mirror that design.

### P1-2: AC12 greps the SOURCE file, not the RULE file — passes at baseline, verifies nothing about the deliverable
`AC12` method: `for k in ...; do grep -l "$k" .tad/project-knowledge/patterns/shell-portability.md ...`

The loop inspects `patterns/shell-portability.md` (the unchanged source), so all 5 lines print `SRC-OK` at
baseline (verified live). It proves the source contains the constraints — which was never in doubt — but does
NOT verify the new `.claude/rules/shell-portability.md` cites them. A rule file with zero of the 5 constraints
still passes AC12.

**Fix:** grep the RULE file for the 5 constraint markers:
`for k in 'grep -P' 'LC_ALL=C' 'ERR trap' 'GATE' 'bracket class'; do grep -q "$k" .claude/rules/shell-portability.md && echo "RULE-OK: $k"; done` expect 5. Keep the source-grep as a separate parity check if desired.

### P1-3: AC6 scope-lock is drowned by ~57 lines of pre-existing untracked noise
`AC6` method: `git status --porcelain | grep -vE '...' `, expected empty (or pre-existing items explained).

Verified live: the filter leaves **57 lines** at baseline — surplus-mode EPHEMERAL/HANDOFF files, archived
epics, modified evidence traces, NEXT.md. Requiring Blake to "逐条解释" 57 unrelated items makes the scope-lock
signal unusable; a real scope-creep line would hide in the noise. The AC as written cannot cleanly separate
"Blake touched an out-of-scope file" from "the repo was already dirty."

**Fix:** snapshot the pre-existing dirty set before implementation and diff against it, e.g.
`git status --porcelain > /tmp/before.txt` at start, then `comm -13 <(sort /tmp/before.txt) <(git status --porcelain | sort)` and assert every NEW line matches the allow-set. Alternatively scope AC6 to only the two
in-scope tracked files via `git diff --name-only`.

### P1-4: AC9 relies on the `\|`→`|` un-escape note; the literal command as written matches nothing
`AC9` method: `grep -E 'Verdict: (LOADED\|INERT)' ...`

Verified live: run verbatim, `Verdict: LOADED` does NOT match (the `\|` is a literal backslash-pipe in ERE).
It only works if the runner heeds the §9.1 pipe-escape note and hand-converts `\|`→`|`. Gate 3 "executes each
row" — a mechanical runner that pastes the cell verbatim gets a false FAIL. Same latent issue in AC1
(`never_when\|multiSelect`) and AC4/AC14 (those use `|` already un-escaped or single-alternation, so lower risk).

**Fix:** either pre-un-escape the pipes in the AC9/AC1 cells (they are single-file greps, no table-ambiguity
reason to escape), or make the pipe-escape note a HARD pre-step Gate 3 must apply. Prefer un-escaping in-cell.

---

## P2 — Nice to Have

### P2-1: AC2 `grep -A2 'example'` is formatting-brittle
`grep -n -A2 'example' <file> | grep -c 'preview'` requires `preview` to land within 2 lines of the literal
token `example`. A scripted 2-up markdown block can easily place option labels then `preview:` fields >2 lines
apart. Widen to `-A8`, or grep the block by its known heading, to avoid a false FAIL on valid content.

### P2-2: AC4 `sed` range terminator is fragile to insertion order
`sed -n '/Use the merged_design/,/skip_conditions/p'` relies on the FIRST `skip_conditions` (L150) appearing
after L146 and before the new preview block. Verified the range currently spans L146→L150 correctly. If Blake
inserts the preview_usage_rule block BETWEEN L146 and L150 (design says "after step1_5c, before step2" which is
after L150, so OK) the range stays valid — but the coupling is implicit. Consider anchoring the range end on a
stable marker like `skip_conditions:` scoped to step1_5c, or use a line-window.

### P2-3: `.claude/rules` is a per-repo untested harness feature — spike-gate is correct but flag the fire-test honesty ceiling louder
The handoff correctly gates B2/B3 on B1 and permits PENDING-REAL-EVENT for the fire test (§6.1 Micro-Task
Rules, AC15). This is sound. One tightening: AC14's `no-fire` section header matches the `fire` alternation
(`no-fire` contains `fire`), so the `≥4 sections` count can be satisfied by 4 headers that are all
fire-variants. Minor — add `parity` and `context` as required distinct tokens if strictness matters.

---

## Cross-cutting observations (not scored)

- **File completeness: COMPLETE.** §7.1 (4 create) + §7.2 (2 modify) cover the entire design. `.agents` mirror
  correctly included (A3); `.claude/rules` correctly excluded from mirroring with a documented rationale
  (§10.2). No missing files found.
- **Frontmatter: CORRECT.** task_type=mixed, e2e_required=no, research_required=yes (justified — frontmatter
  key syntax must be doc-verified), git_tracked_dirs=[.claude/rules], skip_knowledge_assessment=no,
  gate4_delta=[]. All coherent with the two-track design.
- **Design coherence: STRONG.** Requirements FR1–FR8 map cleanly to the technical design and micro-tasks; the
  spike-gate / degradation matrix (§10.2) is well-specified and replicates the validated Phase 2 precedent; the
  anti-Validation-Theater discipline (AC15) is explicit. The design is good — the defects are purely in the
  mechanical verifiability of the AC commands (P0/P1), which is precisely where a code-reviewer adds value.
- **self-leak:** No AC command matches the handoff file itself (all path-scoped to design-protocol.md / rules /
  phase4-evidence). AC6's `\.tad/active/` exclusion correctly filters the handoff's own directory. Clean.

## Recommended gate posture
Do NOT proceed to implementation until P0-1 and P0-2 are fixed (both cause guaranteed false Gate-3 results
independent of Blake's work). P1-1/P1-2 should be fixed so the ACs actually discriminate real completion from
baseline. P1-3/P1-4 make Gate 3 mechanically reliable.
