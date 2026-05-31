---
task_id: TASK-20260531-tad-lean-trustworthy-phase1
epic: EPIC-20260531-tad-lean-trustworthy
phase: 1/5
from: Blake (Agent B - Execution Master)
to: Conductor / Alex
date: 2026-05-31
handoff_ref: .tad/active/handoffs/HANDOFF-20260531-tad-lean-trustworthy-phase1.md
gate3_verdict: pass   # allowlist: pass | fail | partial — set per Layer 1 result
---

# COMPLETION — TAD Lean & Trustworthy Phase 1

Trace producer column-contract fix (header-aware `emit_decision_points()`) + purge of 6 rejected dead dream-candidate shells.

> Anti-self-trigger note (§10.1): this report deliberately contains NO `Decision Summary` heading and NO bare-pipe column-headed markdown table. All dry-run output is shown with the visible `<<SEP>>` separator inside fenced code blocks, which is NOT a markdown table the producer parser will scan.

---

## 1. Summary

`emit_decision_points()` in `.tad/hooks/post-write-sync.sh` was rewritten from hardcoded positional indices (the `a[3]/a[5]/a[6]` model) to column-NAME-aware binding: it scans the section header row, binds awk indices `di`/`ci`/`ri` by the column names (decision / chosen / rationale, case-insensitive, trimmed), then reads data rows by those bound indices. The 4-col layout that previously column-shifted (chosen carried the rationale text, rationale empty) is now correct; the 5-col layout is unchanged (no regression). The 6 rejected dead candidates were deleted; `dream-state.yaml` was NOT touched (counts = immutable scan history).

**Layer 1 result: PASS** (all AC checks green; zero retries needed beyond an apostrophe-in-awk-comment fix during authoring).

---

## 2. Rewritten `emit_decision_points()` function body

```bash
# FR4: parse §11 Decision Summary table → decision_point per row (override-aware).
# Column-NAME-aware since 2026-05-31: the header row is scanned for the Decision/Chosen/
# Rationale column names and awk indices di/ci/ri are bound by name (was hardcoded
# a[3]/a[5]/a[6] — those positions are correct only for the 5-col layout; 4-col tables
# written before this date are column-shifted in the historical trace, NOT repaired,
# append-only).
emit_decision_points() {
  local file="$1" slug="$2"
  [ -n "$slug" ] || return 0
  [ -f "$file" ] || return 0
  local rows
  rows=$(awk -v SEP=$'\x1e' '
    { if (incomment) { if ($0 ~ /-->/) incomment=0; next }
      if ($0 !~ /^##/ && $0 ~ /<!--/ && $0 ~ /-->/) next
      if ($0 !~ /^##/ && $0 ~ /<!--/) { incomment=1; next } }
    /^##[[:space:]]/ { insec = ($0 ~ /Decision Summary/) ? 1 : 0;
                       havehdr=0; di=0; ci=0; ri=0; next }   # reset header binding per section
    !insec { next }
    /^\|/ {
      if ($0 ~ /^\|[-: |]+\|[[:space:]]*$/) next   # separator row
      if (havehdr==0) {                            # header row: bind di/ci/ri by column name
        n=split($0, a, "|")
        for (i=1; i<=n; i++) {
          t=a[i]; gsub(/^[[:space:]]+|[[:space:]]+$/, "", t); lt=tolower(t)
          if (lt=="decision")  di=i
          if (lt=="chosen")    ci=i
          if (lt=="rationale") ri=i
        }
        if (di>0 && ci>0) havehdr=1
        next                                       # header / pre-header rows emit nothing
      }
      n=split($0, a, "|")                          # data row: read by bound indices
      d=a[di]; c=a[ci]; r=(ri>0 ? a[ri] : "")
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", d)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", c)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", r)
      # KEEP guard: case-insensitive header guard catches a second tables header arriving
      # as a data row (multi-table §11 — havehdr locked on first table, not re-bound) and
      # blank/separator residue. Removing it emits junk + triggers parser self-trigger.
      if (d=="" || c=="" || (tolower(d)=="decision" && tolower(c)=="chosen")) next
      printf "%s%s%s%s%s\n", d, SEP, c, SEP, r
    }
  ' "$file" 2>/dev/null)
  [ -n "$rows" ] || return 0
  printf '%s\n' "$rows" | while IFS=$'\x1e' read -r d c r; do
    [ -n "$d" ] && [ -n "$c" ] || continue
    d=$(printf '%s' "$d" | tr -d '\r\n' | cut -c1-200)
    c=$(printf '%s' "$c" | tr -d '\r\n' | cut -c1-200)
    r=$(printf '%s' "$r" | tr -d '\r\n' | cut -c1-200)
    actor=agent_inferred
    # Scan BOTH Chosen and Rationale columns for override markers (a marker can land in
    # either, e.g. "用户选 passport" in the Chosen cell).
    case "$c $r" in
      *用户选*|*"user chose"*|*"human override"*|*人类决策*) actor=human_overridden ;;
    esac
    trace_decision_point "$d" "$c" "$r" "$slug" "$actor" || true
  done
}
```

Preserved (FR4): separator-row skip, per-cell trim, override-marker scan (both columns), `tr -d '\r\n' | cut -c1-200`, every `|| true`, awk subshell `2>/dev/null`, `[ -n "$rows" ] || return 0`, and the call-site per-(slug,day) dedup gate at ~line 273 (untouched).

---

## 3. Raw Layer 1 outputs

### AC1.4c — `bash -n` syntax check

```
$ bash -n .tad/hooks/post-write-sync.sh; echo $?
0
```

### AC1.1 — header-aware flags present / old positional model gone

Positive grep (`di=i|ci=i|ri=i|havehdr` — must hit):
```
188:                       havehdr=0; di=0; ci=0; ri=0; next }   # reset header binding per section
192:      if (havehdr==0) {                            # header row: bind di/ci/ri by column name
196:          if (lt=="decision")  di=i
197:          if (lt=="chosen")    ci=i
198:          if (lt=="rationale") ri=i
200:        if (di>0 && ci>0) havehdr=1
209:      # as a data row (multi-table §11 — havehdr locked on first table, not re-bound) and
```

Negative grep (`d=a[3]|c=a[5]|r=a[6]` — must NOT hit):
```
$ grep -nE 'd=a\[3\]|c=a\[5\]|r=a\[6\]' .tad/hooks/post-write-sync.sh
(no match) → OK: old positional model removed
```

### AC1.4a — fail-open counts (function-scoped + file-wide)

```
$ awk '/^emit_decision_points\(\)/{f=1} f&&/^}/{print;exit} f' .tad/hooks/post-write-sync.sh | grep -c '|| true'
1                # baseline 1 → still 1 (≥1 OK)
$ grep -c '|| true' .tad/hooks/post-write-sync.sh
14               # baseline 14 → still 14 (≥14 OK)
```
awk subshell `2>/dev/null` and `[ -n "$rows" ] || return 0` both confirmed present (lines 214 / 215).

### AC1.2a — 4-col (research-engine-wire-phase4), NEW header-aware awk

The previously-shifted "Adoption (Phase 6)" row now lands correctly (chosen-position = the choice, rationale-position = the reason):
```
Adoption (Phase 6)<<SEP>>Right-moment trigger, not usage-count<<SEP>>Some projects legitimately don't need research
```
Full output (10 rows, all correctly split):
```
Triggering mechanism<<SEP>>Complexity-adaptive effort-scaling<<SEP>>Fixes 0/2 usage AND delivers Anthropic effort-scaling in one change
Quality gate (Phase 5)<<SEP>>Reuse Codex+Gemini, advisory<<SEP>>(Phase 5) reuse existing challenge infra; non-blocking per single-user CLI
Perspective (Phase 5)<<SEP>>Generate personas<<SEP>>Lightweight, no external corpus needed
Lifecycle mechanism<<SEP>>Non-blocking SessionStart hook<<SEP>>Only updates derived state; doesn't violate anti-mechanical-enforcement
Adoption (Phase 6)<<SEP>>Right-moment trigger, not usage-count<<SEP>>Some projects legitimately don't need research
Scope/rollout<<SEP>>TAD-main first + dogfood, then *sync<<SEP>>Don't push unvalidated changes to 14 projects
Dogfood target<<SEP>>Re-run stale tad-evolution-research<<SEP>>Validates + refreshes the 26-day-stale meta notebook
Deferred mechanisms<<SEP>>CRAG / citation pass / mind-map → future phase<<SEP>>Validate first 3 buckets before adding more
Challenge auto-run vs AR-001 SAFETY<<SEP>>**Option B — carve-out via DR-20260531** (human-authorized)<<SEP>>Dynamic seeds auto-fire (internal); challenge auto-runs only inside *research-plan with displayed+overridable classification
```

### AC1.2c — 4-col, OLD buggy positional awk (before/after contrast)

Same file, OLD `a[3]/a[5]/a[6]` program: the choice-position carries the RATIONALE text and the rationale-position is EMPTY — the documented column-shift bug. Compare the "Adoption (Phase 6)" row:
```
Adoption (Phase 6)<<SEP>>Some projects legitimately don't need research<<SEP>>
```
(The real choice "Right-moment trigger, not usage-count" was silently dropped, and the rationale field is empty.) Full OLD output:
```
Triggering mechanism<<SEP>>Fixes 0/2 usage AND delivers Anthropic effort-scaling in one change<<SEP>>
Quality gate (Phase 5)<<SEP>>(Phase 5) reuse existing challenge infra; non-blocking per single-user CLI<<SEP>>
Perspective (Phase 5)<<SEP>>Lightweight, no external corpus needed<<SEP>>
Lifecycle mechanism<<SEP>>Only updates derived state; doesn't violate anti-mechanical-enforcement<<SEP>>
Adoption (Phase 6)<<SEP>>Some projects legitimately don't need research<<SEP>>
Scope/rollout<<SEP>>Don't push unvalidated changes to 14 projects<<SEP>>
Dogfood target<<SEP>>Validates + refreshes the 26-day-stale meta notebook<<SEP>>
Deferred mechanisms<<SEP>>Validate first 3 buckets before adding more<<SEP>>
Challenge auto-run vs AR-001 SAFETY<<SEP>>Dynamic seeds auto-fire (internal); challenge auto-runs only inside *research-plan with displayed+overridable classification<<SEP>>
```
The before→after diff IS the swap-back evidence: NEW restores the choice to the choice-position and fills the rationale-position; OLD has rationale-text-in-choice + empty-rationale.

### AC1.2b — 5-col (trace-instrumentation-fix), NEW awk, no regression

Choice and rationale stay in their correct positions (identical to pre-fix behavior for the 5-col layout):
```
发射机制<<SEP>>观测式为主<<SEP>>用户选;reflexion 唯一命令式调用只触发 1 次,证明命令式不可靠
gate/reflexion 信号源<<SEP>>结构化标记(Blake 写)<<SEP>>两位审查员:散文脆弱;gate3-verdict.md 仅 2/76;`.router.log` 教训=被消费产物要稳定契约
Schema 不一致<<SEP>>改分析器兼容(且更正:分析器本来基本对)<<SEP>>用户选;避免 breaking change;真实 bug 只在 4907 行
Gate 观测范围<<SEP>>MVP 仅 Gate 3 + N=0 skip guard<<SEP>>用户选;Gate 3 标记可靠;guard 防 *evolve 误报 Gate 2/4 0%
reflexion 可观测<<SEP>>Blake 写块→解析,**删命令式**<<SEP>>用户选;删命令式避免双发污染 dream-scanner
降级策略<<SEP>>静默跳过<<SEP>>用户选;不造假事件
去重粒度<<SEP>>每 slug 每天一次<<SEP>>用户选;PostToolUse 难分 create/edit;TOCTOU 接受
```

### AC1.2d — multi-table §11 (phase5-evolve-data-capture), NEW awk, zero junk header rows

The phase5 §11 section holds two consecutive choice-tables (11.1 binds the header on the first; 11.2's header arrives as a data row) plus an unrelated disposition table (11.3). The KEEP guard suppresses the second table's header (choice-column value == the literal "Chosen" word) so NO junk header row leaks:
```
$ awk -f /tmp/eda.awk <phase5> | awk -F'<<SEP>>' '$1=="Decision"||$2=="Chosen"{...} END{...}'
OK: zero Decision/Chosen junk header rows
```
All 7 data rows of table 11.2 parse correctly (count = 7). The lone `Item<<SEP>>Notes<<SEP>>` line is an artifact of the unrelated 11.3 disposition table and is IDENTICAL pre-existing behavior — the OLD positional awk emits the same line — so it is not a new regression and is outside this guard's specified scope (the guard targets a second `Decision`/`Chosen`-headed table, per backend-architect Y4 P0).

### AC1.4b — malformed table (header lacks Chosen) → graceful skip

```
--- input /tmp/malformed.md (a Decision Summary section whose header omits the choice column) ---
--- output ---
[stdout begin][stdout end]
exit code: 0
```
Empty stdout + exit 0 = graceful skip (havehdr never set → no emit).

### AC1.3a — 6 files deleted

```
$ ls .tad/active/dream-candidates/CAND-2026-05-30-16115*.md 2>&1
no matches found: .tad/active/dream-candidates/CAND-2026-05-30-16115*.md
```

### AC1.3b — only 6 deletions, pending untouched

```
$ git status --porcelain .tad/active/dream-candidates/
 D .tad/active/dream-candidates/CAND-2026-05-30-16115201.md
 D .tad/active/dream-candidates/CAND-2026-05-30-16115202.md
 D .tad/active/dream-candidates/CAND-2026-05-30-16115203.md
 D .tad/active/dream-candidates/CAND-2026-05-30-16115304.md
 D .tad/active/dream-candidates/CAND-2026-05-30-16115305.md
 D .tad/active/dream-candidates/CAND-2026-05-30-16115306.md
```

### AC1.3c — dream-state.yaml NOT modified

```
$ git status --porcelain .tad/active/dream-state.yaml
(empty) → unchanged
```

---

## 4. AC verification table

| AC | Result | Evidence |
|----|--------|----------|
| AC1.1 — header-aware dynamic mapping + graceful skip | PASS | positive grep hits di/ci/ri/havehdr; negative grep finds no `a[3]/a[5]/a[6]` |
| AC1.2a — 4-col corrected | PASS | "Adoption (Phase 6)" row: choice="Right-moment trigger, not usage-count", rationale="Some projects legitimately don't need research" |
| AC1.2b — 5-col no regression | PASS | choice/rationale correctly positioned, identical to pre-fix |
| AC1.2c — before/after contrast | PASS | OLD awk shows rationale-text-in-choice + empty-rationale; NEW swaps back |
| AC1.2d — multi-table zero junk | PASS | zero junk header rows (no row whose choice-cell equals the literal choice-column word); 7 table-11.2 data rows parse; `Item/Notes` = pre-existing OLD behavior, out of scope |
| AC1.3a — 6 files deleted | PASS | `ls` → no matches |
| AC1.3b — pending untouched | PASS | git status = only 6 `D` lines |
| AC1.3c — dream-state.yaml unchanged | PASS | git status empty |
| AC1.4a — fail-open preserved (fn ≥1, file ≥14) | PASS | function-scoped=1, file-wide=14; awk `2>/dev/null` + `[ -n "$rows" ] || return 0` present |
| AC1.4b — malformed graceful skip | PASS | empty stdout, exit 0 |
| AC1.4c — bash syntax | PASS | `bash -n` exit 0 |

---

## 5. Sibling parser safety affirmation (backend-architect Y4 P2)

`emit_expert_findings` and `emit_reflexions` were inspected and confirmed positional-SAFE — neither uses a column-index model, so the column-contract bug fixed here does not apply to them:

- `emit_expert_findings`: counts review-file findings via `grep -cE` on heading-form label patterns (line-count model); no `split($0,a,"|")`, no `a[N]` indexing.
- `emit_reflexions`: extracts fields via `val()` key:value matching (`what_failed:`, `root_cause_hypothesis:`, `revised_approach:`, `confidence:`); no column model.

No changes were made to either function (per Intent Statement NOT-in-scope list).

---

## 6. Files changed

Modified:
- `.tad/hooks/post-write-sync.sh` — `emit_decision_points()` rewritten header-aware; line ~172 comment updated to header-aware cutoff (described as a[3]/a[5]/a[6], no literal table per §10.1).

Deleted:
- `.tad/active/dream-candidates/CAND-2026-05-30-16115201.md`
- `.tad/active/dream-candidates/CAND-2026-05-30-16115202.md`
- `.tad/active/dream-candidates/CAND-2026-05-30-16115203.md`
- `.tad/active/dream-candidates/CAND-2026-05-30-16115304.md`
- `.tad/active/dream-candidates/CAND-2026-05-30-16115305.md`
- `.tad/active/dream-candidates/CAND-2026-05-30-16115306.md`

Evidence created:
- `.tad/evidence/acceptance-tests/tad-lean-trustworthy-phase1/dryrun-4col.txt`
- `.tad/evidence/acceptance-tests/tad-lean-trustworthy-phase1/dryrun-5col.txt`
- `.tad/evidence/acceptance-tests/tad-lean-trustworthy-phase1/malformed-skip.txt`
- `.tad/active/handoffs/COMPLETION-20260531-tad-lean-trustworthy-phase1.md` (this file)

NOT modified (per constraints):
- `.tad/active/dream-state.yaml` (counts = immutable scan history)
- call-site per-(slug,day) dedup gate (~line 273), `dream-scanner.sh` Pass C, `trace_decision_point` signature.

---

## Escalations

None. Single authoring hiccup (an apostrophe inside an awk comment closed the single-quoted awk string and broke `bash -n`) was self-resolved by removing the apostrophe; no design decision or scope change required.
