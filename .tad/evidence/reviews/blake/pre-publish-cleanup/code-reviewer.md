# Code Reviewer Report — HANDOFF-20260427-pre-publish-cleanup

**Reviewer:** code-reviewer (Layer 2 / Gate 2 expert review)
**Date:** 2026-04-27
**Handoff:** `/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260427-pre-publish-cleanup.md`
**Scope:** Edit correctness, BSD/macOS portability, AC verification command validity
**Mode:** REVIEW only — no implementation changes proposed in code

---

## Summary

The handoff is structurally sound and data-flow correct. `.router.log` 5-tuple
format assumptions match the live file (verified: 606 rows, all 5 fields).
Process-substitution `diff <() <()`, BSD `grep` alternation `\|`, and BSD
`awk` range pattern `/A/,/^[[:space:]]*$/` all behave as the handoff
expects on macOS BSD.

However there are **3 P0 issues** Blake will hit immediately upon
implementation (one is a guaranteed bug, one is a guaranteed line-mismatch,
one is a portability + numeric-comparison bug in File 2). All three are
specific and have concrete fixes that do not change the handoff's design.

---

## Critical Issues (P0 — must fix before Blake starts)

### P0-1: Alex SKILL.md cited line numbers are off by ~1000 lines

**Handoff says** (§3.1 FR4, §5 MQ2 row, §7.3): `step7.generate_message`
PLAIN-LANGUAGE EXPLANATION block is "约 line 980-1050" in
`.claude/skills/alex/SKILL.md`.

**Actual location** (verified by `grep -n "generate_message" /Users/sheldonzhao/01-on progress programs/TAD/.claude/skills/alex/SKILL.md`):
- `step7.generate_message:` at **line 2009**
- `PLAIN-LANGUAGE EXPLANATION` at **line 2053**
- "Required content" list (insertion target) at **line 2067**

The handoff is **off by ~1030 lines**. Blake will Read at lines 980-1050
and find unrelated content (likely the *idea_path_protocol or similar
section), will not find a `step7.generate_message` block, and will either
(a) fail to locate the insertion target, or (b) insert the new prose into
the wrong section. Both create a silent hard fault.

**Fix recommendation**: Replace every "约 line 980-1050" with "约 line
2050-2105" in §3.1 FR4, §5 MQ2 (row 5), §6 Phase 4 step 1, and §7.3
"Grounded Against" line. Blake's anchor for Edit should be the literal
string `step7.generate_message: |` (line 2009) or the heading
`PLAIN-LANGUAGE EXPLANATION` (line 2053), not a line number.

Blake SKILL.md citation (line 1028 / step8 PLAIN-LANGUAGE at 1082) is
**accurate** — verified independently. Only the Alex side is wrong.

---

### P0-2: File 2 `_assert_match` references `$SCRIPT_DIR` but the file uses `$REPO_ROOT`

**Handoff §4.2 File 2 new code** (line ~304 of handoff):
```bash
local out log="${SCRIPT_DIR:-.}/../../../hooks/.router.log"
```

**Actual file** (`AC-P1.4-router-event-filter.sh` line 9):
```bash
REPO_ROOT="$(cd "$(dirname "$0")/../../../../" && pwd)"
HOOK="${REPO_ROOT}/.tad/hooks/userprompt-domain-router.sh"
```

The script defines `REPO_ROOT`, **not** `SCRIPT_DIR`. The handoff's
`${SCRIPT_DIR:-.}` will always fall back to `.` because `SCRIPT_DIR`
is unset. The relative path `./../../../hooks/.router.log` evaluates
relative to **cwd**, which is the user's working directory (likely repo
root) — meaning the path will resolve to `../../hooks/.router.log` from
repo root, which **does not exist**.

The acceptance test invocation pattern is `bash .tad/evidence/...sh` from
repo root → `cwd = repo_root`. The path `./../../../hooks/.router.log`
goes up 3 levels above repo root → broken.

**Fix recommendation**: Replace
```bash
local out log="${SCRIPT_DIR:-.}/../../../hooks/.router.log"
```
with
```bash
local out log="${REPO_ROOT}/.tad/hooks/.router.log"
```

`REPO_ROOT` is already defined at line 9 of the file, is used elsewhere
in the script (line 10, 11, 100), is cwd-independent, and is the
established convention. §4.2 "注意" callout claiming SCRIPT_DIR fallback
provides cwd-independence is wrong on two counts: SCRIPT_DIR doesn't
exist; the fallback to `.` only papers over the variable absence, not
cwd dependence.

---

### P0-3: `wc -l < missing_file 2>/dev/null | tr -d ' ' || echo 0` produces empty string, breaks `[ -gt ]`

**Handoff §4.2 File 2 new code** (line ~307, ~311):
```bash
pre_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ' || echo 0)
...
if [ "$post_count" -gt "$pre_count" ]; then
```

When `$log` does not exist, the bash pipeline behaves as follows on
BSD/macOS (verified empirically):

1. `wc -l < missing` → bash itself emits "no such file or directory"
   redirect error to stderr (suppressed by `2>/dev/null`), `wc` never runs,
   pipeline exit = redirection failure for the LHS but the pipe still
   runs `tr` with empty stdin.
2. `tr -d ' '` reads empty stdin, exits 0 with no output.
3. The `||` operator binds to the **last command in the pipeline** (`tr`),
   not the pipeline as a whole. Since `tr` exited 0, `echo 0` does
   **not** fire.
4. Result: `pre_count=""`.

Then `[ "$post_count" -gt "" ]` → bash emits
`integer expression expected` and the test exits non-zero, taking the
**else** branch silently. The `_assert_match` will then read
`last_pack="NO_LOG_DELTA"` and FAIL every case — a regression that masks
itself as "hook didn't write".

(The same pattern would be safe if `set -o pipefail` were active and the
right side picked up the error, but `set -uo pipefail` does NOT include
the `e` flag — see line 7 of the file — so individual command failures
inside `$(...)` substitution don't propagate, but pipefail also doesn't
make the LHS failure bubble through `tr`.)

**Fix recommendation**: Two equivalent options. Option A (prefer):
```bash
pre_count=$( [ -f "$log" ] && wc -l < "$log" | tr -d ' ' || echo 0 )
```
Option B (more defensive, handles the empty-string case at use site):
```bash
pre_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
pre_count="${pre_count:-0}"
...
post_count=$(wc -l < "$log" 2>/dev/null | tr -d ' ')
post_count="${post_count:-0}"
```

Option B is what I recommend because it survives both "file missing"
(empty string) and "wc returns whitespace" (numeric value).

The same fix is needed on the post_count line (~311).

---

## Recommendations (P1 — should address)

### P1-1: File 1 Python `log_path = ".tad/hooks/.router.log"` is cwd-dependent

The new Python code (handoff §4.2 File 1 line ~239) uses a relative path
hardcoded to `".tad/hooks/.router.log"`. This works only when the script
is invoked with cwd = repo root.

The wrapping bash defines `SCRIPT_DIR` at line 19 of the file but does
**not** pass it into the Python heredoc — argv only carries `HOOK`,
`TESTSET`, `RESULTS`, `QUIET`. Therefore Python cannot derive the path
from the script location.

**Fix recommendation**: Either (a) pass `SCRIPT_DIR` as a 5th argv to
Python:
```bash
python3 - "$HOOK" "$TESTSET" "$RESULTS" "$QUIET" "$SCRIPT_DIR" <<'PY'
...
hook, testset, results_path, quiet, script_dir = sys.argv[1], ... , sys.argv[5]
log_path = os.path.join(script_dir, ".router.log")
```
or (b) since the hook itself (`userprompt-domain-router.sh`) writes the
log to a path that is by construction next to the hook script, derive
`log_path` from `os.path.dirname(hook) + "/.router.log"`. Option (b) is
zero-change to the bash wrapper.

Severity P1 not P0 because the handoff's spec command in §6 Phase 1 step 3
runs from repo root, so the regression test will pass under the standard
invocation. But CI / different cwd → silent regression. Worth fixing now.

### P1-2: Backend-architect grep command in §6 Phase 6 step 5 will hit `.tad/active/handoffs/` of THIS handoff itself

The grep:
```bash
grep -rln "additionalContext\|hookSpecificOutput" .tad/ .claude/ 2>/dev/null \
  | grep -v "^\.tad/archive" \
  | grep -v "^\.tad/active/handoffs/"
```

This handoff document itself lives in `.tad/active/handoffs/` and contains
many `additionalContext` / `hookSpecificOutput` mentions (in §3, §4, §10).
The `grep -v "^\.tad/active/handoffs/"` correctly filters this out **only
if the grep -rln output paths begin with `./.tad/...`** (or `.tad/...`).

`grep -rln` on macOS returns paths like `.tad/active/handoffs/HANDOFF-20260427-pre-publish-cleanup.md`
(no leading `./`) — verified the anchor `^\.tad/active/handoffs/` will match
correctly. **No fix needed**, just confirming the filter works.

However, the grep also leaves the `.tad/evidence/reviews/blake/pre-publish-cleanup/`
artifacts (this very file + Blake's Layer 2 reports) un-filtered. Once Blake
runs the grep post-implementation, this code-reviewer.md report itself will
appear as a hit. Suggest adding a 3rd filter:
```bash
| grep -v "^\.tad/evidence/reviews/blake/pre-publish-cleanup/"
```
or document in §10 that "review artifacts mentioning the strings are
expected hits".

### P1-3: AC10 `awk '/BUSINESS-VALUE-FIRST/,/^[[:space:]]*$/'` may capture different ranges depending on YAML indentation

Both Alex and Blake SKILL files are YAML. The PLAIN-LANGUAGE block lives
under heavily indented YAML keys (`step7.generate_message: |` literal
block at column 6). When the BUSINESS-VALUE-FIRST RULE is inserted,
the closing terminator `^[[:space:]]*$` matches the **first** blank line
(zero or more whitespace then EOL).

If the inserted block contains intentional blank lines inside (e.g.,
between "✅ 正例" and "❌ 反例", which the FR4 prose has), the awk range
will terminate prematurely, capturing only the part above the first
internal blank line. Then AC10's diff would compare incomplete ranges
on both sides → may pass even if the lower halves differ.

**Verification**: The FR4 prose block in §3.1 contains 3 internal blank
lines (between "✅ 正例", "❌ 反例", "原则:" sections). awk range will
stop at the first one.

**Fix recommendation**: Either (a) make the inserted block contain no
blank lines (use `———` separators or just newlines without blank
lines), or (b) change AC10's awk range terminator to a more specific
end marker like `/violation_plain_language/` (which is the next YAML
key after the PLAIN-LANGUAGE block in both files), or (c) use a fixed
line-count `head -50` shape per §8.2 already does:
```bash
diff <(awk '/BUSINESS-VALUE-FIRST/,/^[[:space:]]*$/' alex.md | head -100) \
     <(awk '/BUSINESS-VALUE-FIRST/,/^[[:space:]]*$/' blake.md | head -100)
```
But (a) is the cleanest. Note: §8.2 already uses `head -50` shape; §9.1
AC10 should mirror that with `head -100` to capture full block.

### P1-4: AC11 `git diff --name-only | wc -l = 5` will be 6+ if Blake updates this evidence dir

Blake will create reviewer artifacts in
`.tad/evidence/reviews/blake/pre-publish-cleanup/` (per Slug Contract).
These show up in `git status` but typically Blake commits with a
`.gitignore` exclusion or via the `.tad/active/handoffs/` opt-out
strategy in step3c.

**Verification needed**: Confirm that `.tad/evidence/reviews/blake/`
artifacts are committed alongside the implementation diff. If yes,
AC11 should be `5 implementation files + N evidence files`. If no
(common-case opt-out), AC11 stays at 5 — but Blake's commit hash AC
becomes "git status before commit" not "git diff --name-only".

This is a known TAD convention point, not a bug, but worth a sentence
in §10.2 clarifying which is which.

---

## Suggestions (P2 — nice to have)

### P2-1: §3.1 FR4 prose block uses Chinese double-quote `"` characters which differ from ASCII `"`

The FR4 example contains:
```
"after this lands, your [...] experience changes by [...]"
```
These look like ASCII `"` but might render as different characters
depending on editor input mode. AC10 byte-symmetric comparison is
strict — a single Chinese vs ASCII quote difference between Alex and
Blake will fail diff.

The handoff specifies "Blake 用 Read tool 复制 File 4 已写入的 prose"
(NFR3) which mitigates this risk. Just flagging that hand-typing the
Blake side would silently break.

### P2-2: File 1 Python "lines[-1].strip().split()" assumes exactly-5-field robustness

Verified all 606 rows in `.router.log` have exactly 5 space-separated
fields. Pack names are all hyphenated identifiers. Robustness check is
the `if len(last) < 5` guard which catches truncation. Fine as-is.

The only subtle case: if a future hook change appends a 6th field, the
new code's `last[2]` and `last[3]` access would silently still work
(extracts pack + ratio correctly), and `if len(last) < 5` would not
trigger. Forward-compatible ✓.

### P2-3: §6 Phase 6 step 6 commit message contains literal `人话版` Chinese

Bash heredoc with Chinese chars works on macOS (UTF-8 default), but if
locale is broken or `LANG` is not en_US.UTF-8, the heredoc could fail.
Low risk on standard developer machines. Suggest Blake test locale with
`echo $LANG` before commit.

### P2-4: AC13 dogfood instruction is well-designed, no issue

The §6 Phase 6 step 5 grep + the §10.1 critical warning + §11 Decision
#7 marking it "强制" form a 3-layer defense that explicitly cites the
"Pre-Handoff vs Post-Implementation Reviewer Scope Distinction" lesson.
Good adherence to the Phase 3 "Path Layering: Three Defenses" pattern
from architecture.md.

---

## Verification Matrix Summary

| Item | Cited Location | Actual | Status |
|------|----------------|--------|--------|
| `run_case` Python function | run-phase2b-tests.sh ~50-72 | line 51-70 | ✅ correct |
| `_assert_match` bash function | AC-P1.4-router-event-filter.sh ~38-46 | line 37-48 | ✅ correct |
| Phase 7 verify step 5-6 | release-runbook/SKILL.md ~295-305 | line 292-300 | ✅ correct (off by ~3) |
| `step7.generate_message` PLAIN-LANGUAGE | alex/SKILL.md ~980-1050 | **line 2009-2103** | ❌ **P0-1 wrong by ~1030 lines** |
| `step8_generate_message` PLAIN-LANGUAGE | blake/SKILL.md 1028-1140 | line 1028-1135 | ✅ correct |
| `.router.log` 5-tuple format | live file 606 rows | all 5 fields, no exceptions | ✅ confirmed |
| `_invoke_hook` returns empty in passive mode | passive (2.8.4) | confirmed empty stdout | ✅ confirms migration need |

| Verification command | Issue | Status |
|----------------------|-------|--------|
| BSD `grep -c "A\|B"` (no -E) | works as alternation in BSD basic regex | ✅ no fix |
| `awk '/X/,/^[[:space:]]*$/'` | terminates at FIRST blank line | ⚠ P1-3 |
| `diff <(...) <(...)` | bash + zsh both support | ✅ no fix |
| `wc -l < missing 2>/dev/null` | empty string, not "0" | ❌ **P0-3** |
| `tail -1 file 2>/dev/null \| grep -q` | fails gracefully → exit 1 → FAIL block ✓ | ✅ no fix |
| `bash hook >/dev/null` | exit code preserved | ✅ no fix |
| backend-architect grep | works; misses evidence dir self-filter | ⚠ P1-2 |

---

## Overall Assessment

**CONDITIONAL PASS**

The handoff's design is sound (data-flow analysis correct, FR/NFR
coverage complete, dogfood lessons properly anchored, AC structure
aligns with Phase 6-A `hard_requirement_distinct_reviewers`).
3 P0 blockers all have concrete one-line fixes that do not change the
design — Alex can patch the handoff in <10 minutes and reissue. Blake
should NOT begin implementation against the current draft because P0-1
(line numbers off by 1030) and P0-2 (wrong variable name) will cause
silent insertion failures or runtime path errors.

Once P0-1, P0-2, P0-3 are addressed, the handoff is ready for Blake.
P1 and P2 items can be deferred to in-implementation polish or
post-acceptance follow-up.

**Action for Alex**: Patch §3.1 FR4 line numbers (980-1050 → 2050-2105),
patch §4.2 File 2 new code (`SCRIPT_DIR` → `REPO_ROOT`), patch §4.2
File 2 `pre_count`/`post_count` extraction with `${var:-0}` fallback,
update §5 MQ2 row 5 line range, then reissue handoff.

---

**Reviewer signoff**: code-reviewer (Layer 2 expert, code correctness +
BSD/macOS portability + AC verification command validity scope)
**Date**: 2026-04-27
