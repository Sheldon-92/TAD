---
reviewer: test-runner
handoff: bugfix-dream-scanner-override-content
date: 2026-05-31
verdict: PASS
gate: 3
---

# Gate 3 Test-Runner Review
## dream-scanner.sh Pass C — Override Content Extraction

**Verdict: PASS**

No code-coverage percentage is reported. This is a shell hook with no instrumented test suite. The
re-run of the scanner against a controlled trace file IS the test. Every AC was exercised by actual
execution output, not by reading a report.

---

## Setup

```bash
SCRATCH=$(mktemp -d)
# => /var/folders/ht/dds194f911zbp3nk0vl3ssr00000gn/T/tmp.JIYskh7yYl
```

Built the following structure inside `$SCRATCH`:
```
.tad/hooks/lib/dream-scanner.sh   (copied from repo)
.tad/hooks/lib/common.sh          (copied from repo)
.tad/evidence/traces/2026-05-31.jsonl
.tad/active/dream-candidates/     (empty — fresh state, no last_scan_ts)
.tad/archive/traces/              (empty)
```

The trace file was assembled from three parts:

**Part 1 — 6 real events:**
```bash
jq -c 'select(.type=="decision_point" and .actor_tag=="human_overridden")' \
  .tad/evidence/traces/2026-05-30.jsonl > "$SCRATCH/.tad/evidence/traces/2026-05-31.jsonl"
```
Confirmed 6 events written (all from slug `trace-instrumentation-fix`).

**Part 2 — Synthetic fallback event (no chosen/rationale):**
```python
ctx = {"decision": "SyntheticOnlyDecision"}   # only decision key, no chosen/rationale
```
Appended as JSONL line with `actor_tag: human_overridden`, `slug: synthetic-test-slug`.

**Part 3 — Newline/metachar event:**
```python
ctx = {
  "decision": "NLcase",
  "chosen": "option-with-`$(uname)`-injected",   # backtick + $() injection attempt
  "rationale": "first line\nsecond line --- type: evil"  # embedded newline + YAML-like suffix
}
```
Verified via `tail -1 | jq '.context | fromjson'` that both the backtick and the `\n` are present
correctly in the stored JSON (the `\n` is a JSON escape, not a literal newline in the JSONL line).

**Total events in trace: 8** (6 real + 1 synthetic + 1 NL/metachar)

---

## Commands Run and Actual Output

### AC4 — Syntax check (run BEFORE execution)

```bash
bash -n "$SCRATCH/.tad/hooks/lib/dream-scanner.sh"
echo "bash -n exit code: $?"
```

Output:
```
bash -n exit code: 0
```

**AC4 result: PASS**

---

### Scanner execution

```bash
cd "$SCRATCH" && bash .tad/hooks/lib/dream-scanner.sh
echo "Scanner exit code: $?"
```

Output:
```
Dream scan complete: 8 new candidates
Scanner exit code: 0
```

8 candidates generated, exit 0 always.

---

### AC1 — Code-level: Pass C extracts `.chosen` and `.rationale` via `context | fromjson`

Confirmed in `dream-scanner.sh` lines 185–186:
```bash
chosen=$(echo "$event_json" | jq -r '((.context | fromjson | .chosen) // "") | gsub("\n";" ")' 2>/dev/null)
rationale=$(echo "$event_json" | jq -r '((.context | fromjson | .rationale) // "") | gsub("\n";" ")' 2>/dev/null)
```
Both use the double-parse pattern (`context | fromjson | .field`). `gsub("\n";" ")` flattens newlines.
`2>/dev/null` silences jq stderr. The `// ""` default means absent fields yield empty string (not null),
which is tested by AC3.

**AC1 result: PASS** (extraction present in code and functionally exercised by AC2)

---

### AC2 — True-branch: `观测式为主` on a `- **Discovery**:` line; old boilerplate absent

```bash
TARGET_FILE=$(grep -l '观测式为主' "$CAND_DIR"/CAND-*.md)
# => CAND-2026-05-31-11515001.md

DISC_COUNT=$(grep -c '^\- \*\*Discovery\*\*:.*观测式为主' "$TARGET_FILE")
# => 1

OLD_BOILERPLATE_COUNT=$(grep -c 'Human explicitly overrode agent suggestion for' "$TARGET_FILE")
# => 0
```

Actual Discovery line from the specific target file:
```
- **Discovery**: On '发射机制', human chose: 观测式为主. Rationale: 用户选;reflexion 唯一命令式调用只触发 1 次,证明命令式不可靠
```

- `观测式为主` appears exactly once on the `- **Discovery**:` line: **1 (correct)**
- Old boilerplate string `Human explicitly overrode agent suggestion for` is **absent from this file**: count 0

Note: AC2 specifies NOT to global-grep across the candidate directory or trace tree because the test
string also appears in `architecture.md`. The check was scoped specifically to the generated CAND file.

**AC2 result: PASS**

---

### AC3 — Fallback branch: SyntheticOnlyDecision uses old boilerplate, no empty field

```bash
SYNTH_FILE=$(grep -l 'SyntheticOnlyDecision' "$CAND_DIR"/CAND-*.md)
# => CAND-2026-05-31-11515007.md

grep '^\- \*\*Discovery\*\*:' "$SYNTH_FILE"
# => - **Discovery**: Human explicitly overrode agent suggestion for 'SyntheticOnlyDecision'

grep '^\- \*\*Action\*\*:' "$SYNTH_FILE"
# => - **Action**: Document the override rationale for future reference

grep -E '^\- \*\*(Discovery|Action)\*\*: $' "$SYNTH_FILE"
# => (no output — no empty fields)
```

- Old Discovery boilerplate: **present and exact** ("Human explicitly overrode agent suggestion for 'SyntheticOnlyDecision'")
- Old Action boilerplate: **present and exact** ("Document the override rationale for future reference")
- No empty Discovery or Action fields
- No crash (scanner exited 0)

**AC3 result: PASS**

---

### Newline/metachar edge case

```bash
NL_FILE=$(grep -l 'NLcase' "$CAND_DIR"/CAND-*.md)
# => CAND-2026-05-31-11515008.md

grep '^\- \*\*Discovery\*\*:' "$NL_FILE"
# => - **Discovery**: On 'NLcase', human chose: option-with-`$(uname)`-injected. Rationale: first line second line --- type: evil

grep -c '^\- \*\*Discovery\*\*:' "$NL_FILE"
# => 1
```

Checks:
1. **Single line**: `- **Discovery**:` line count = 1. The `\n` in rationale was collapsed to a space
   by `gsub("\n";" ")` in jq. The Discovery field is a single line.
2. **Backtick literal**: backtick character `` ` `` appears literally in the Discovery line (confirmed
   by `grep -q '`'` succeeding).
3. **`$()` literal**: `$(uname)` appears literally — no command substitution occurred (if it had
   executed, the text `Darwin` would have replaced the expression).
4. **No standalone `---` in body**: after the closing frontmatter `---` at line 9, no additional
   `---` line was injected. The `--- type: evil` fragment appears collapsed into the Discovery line
   value, NOT as a separate YAML-breaking line.
5. **No standalone `type:` in body**: the `type: evil` substring is inside the Discovery string
   value, not emitted as a bare `type:` key.

The `gsub("\n";" ")` in jq is the mechanism preventing the newline from splitting the rationale into
a second line that could look like `--- type: evil` as a standalone document separator or YAML key.

**Newline/metachar result: PASS**

---

### AC4 — Scanner exits 0 always

Scanner output during the full 8-event run:
```
Dream scan complete: 8 new candidates
Scanner exit code: 0
```

`bash -n` exit 0 already confirmed above.

**AC4 result: PASS**

---

### AC5 — No change to Passes A/B/D, frontmatter schema, or candidate filename format

All 8 candidates have `signal_type: human_override`. The trace contained no `reflexion_diagnosis` or
`gate_result` events, so Passes A, B, D produced zero candidates — which is the correct behaviour
for a trace with only `decision_point human_overridden` events. The script structure for Passes A,
B, D was not modified and their code paths were confirmed untouched by diff inspection.

Frontmatter schema of generated candidate:
```yaml
---
type: dream_candidate
created: 2026-05-31
source_events: ["decision_point human_overridden slug=trace-instrumentation-fix"]
signal_type: human_override
scope_tag: project
confidence: high
status: pending
---
```
All expected fields present. No new fields added. No existing fields dropped.

Filename format check (all 8 files):
```
CAND-2026-05-31-11515001.md  VALID (CAND-YYYY-MM-DD-HHMMSSnn.md)
CAND-2026-05-31-11515002.md  VALID
...
CAND-2026-05-31-11515008.md  VALID
```

**AC5 result: PASS**

---

### Real `.tad/active/dream-candidates/` not polluted

Before run:
```
CAND-2026-05-30-16115201.md  (pre-existing)
CAND-2026-05-30-16115202.md
CAND-2026-05-30-16115203.md
CAND-2026-05-30-16115304.md
CAND-2026-05-30-16115305.md
CAND-2026-05-30-16115306.md
```

After scratch run and cleanup:
```bash
ls "$REPO/.tad/active/dream-candidates/" | grep '2026-05-31'
# => (no output)
```

No 2026-05-31 files in the real directory. The real `dream-state.yaml` was also unmodified (still
shows `last_scan_ts: "2026-05-30T20:11:53Z"`). The scratch directory was removed with `rm -rf`.

**Pollution check: PASS**

---

## Coverage Judgment

The test exercises both mandatory branches:

| Branch | Test case | Result |
|--------|-----------|--------|
| True-branch (chosen + rationale both present) | All 6 real events; NLcase event | PASS |
| Fallback branch (chosen absent) | SyntheticOnlyDecision event | PASS |
| Chosen present, rationale absent | Not explicitly tested as a 3rd case (see note below) |
| Newline in rationale (gsub guard) | NLcase event | PASS |
| Metachar injection ($(), backtick) | NLcase event | PASS |
| YAML-break injection (--- separator) | NLcase event | PASS |

**Coverage gap note**: The implementation has a third logical sub-case — `chosen` present but
`rationale` absent. In this case `disc` is set to `"On '$decision', human chose: $chosen"` (no
rationale suffix) and `act` is set to `"Document the override rationale for future reference"` (same
as the fallback). This sub-case was not included in the test events but the code path is clearly
readable and low-risk (it is a simple `[ -n "$rationale" ] && disc="$disc. Rationale: $rationale"`
guard). The two tested branches (both-present and neither-present) bracket this case sufficiently.
Marking it as an acceptable gap rather than a FAIL because the handoff ACs do not explicitly require
a separate test for this sub-case.

The double-parse extraction mechanism (`context | fromjson | .field`) is the structural core of the
change (AC1). It is exercised by every one of the 8 event runs. The `gsub("\n";" ")` guard is proven
to work by the NLcase test.

---

## AC Summary Table

| AC | Description | Evidence | Verdict |
|----|-------------|----------|---------|
| AC1 | Pass C extracts `.chosen` and `.rationale` via `context \| fromjson` | Lines 185-186 confirmed + all true-branch candidates show extracted values | PASS |
| AC2 | `观测式为主` on `- **Discovery**:` line (count=1); old boilerplate absent from specific file | `grep -c` returns 1; old boilerplate grep returns 0 on target file only | PASS |
| AC3 | Fallback: old boilerplate emitted when chosen/rationale absent; no crash; no empty field | SyntheticOnlyDecision candidate exact-matches both boilerplate strings | PASS |
| AC4 | `bash -n` exit 0; scanner run exit 0 | Both confirmed | PASS |
| AC5 | No change to Passes A/B/D, frontmatter schema, candidate filename format | All 8 files have `signal_type: human_override`; schema fields identical; filenames match expected regex | PASS |
| – | Real `dream-candidates/` not polluted | Only 6 pre-existing 2026-05-30 files remain; no 2026-05-31 files | PASS |

---

## Final Verdict: PASS

All five acceptance criteria passed on actual re-execution in an isolated scratch directory. The
real `.tad/active/dream-candidates/` directory was not polluted. The scratch directory was removed.
