# Code Review: Phase 4 Runtime Freshness Loop

**Reviewer:** code-reviewer (shell correctness, fail-closed, release-verify regression, ledger accuracy)
**Date:** 2026-06-09
**Files reviewed:**
- `.tad/hooks/lib/runtime-freshness-verify.sh` (NEW)
- `.tad/hooks/lib/release-verify.sh` (MODIFIED -- freshness case + usage line)
- `.tad/runtime-compat/codex.md` (NEW)
- `.tad/runtime-compat/claude-code.md` (NEW)

**Cross-referenced against:**
- `.tad/evidence/designs/dual-platform-native-runtime-architecture.md` (Phase 1)
- `.tad/evidence/designs/codex-native-runtime-policy.md` (Phase 2)
- `.tad/active/handoffs/HANDOFF-20260609-runtime-freshness-loop.md` (sections 6, 9)

---

## Findings

| # | Severity | File | Line(s) | Finding | Impact | Fix |
|---|----------|------|---------|---------|--------|-----|
| F1 | P1 | runtime-freshness-verify.sh | 38-44 | `date -j -f` is macOS/BSD-only. GNU/Linux `date` does not support `-j`. No Linux fallback. If this script ever runs on Linux (CI, Codex Cloud container), `days_between` fails and exits 2 on every call. | Script is unusable on Linux. Codex Cloud containers are Linux-based. | Add platform detection: `if date -j ... 2>/dev/null; then ... elif date -d ... 2>/dev/null; then ...`. Alternatively, use pure-arithmetic YYYY-MM-DD difference (approximate but avoids platform dependency). |
| F2 | P1 | runtime-freshness-verify.sh | 97-147 | Double-counting: the age check (lines 100-130) increments `pass` or `blocks`, then the `next_review` check (lines 132-147) can increment `blocks` or `warns` again for the SAME entry. A single entry can appear in both `pass` AND `blocks`, or be counted as two BLOCKs. Verified empirically: a high-vol entry 8 days old with overdue `next_review` produces `PASS: 2, BLOCK: 1` for 2 total entries (sum=3 > total=2). A stale high-vol entry with overdue `next_review` produces 2 BLOCK increments for 1 problematic entry. | Counter totals are inconsistent. `pass + warn + block != total`. Misleading output for operators. Does not cause wrong exit codes (blocks > 0 still exits 1), so fail-closed behavior is preserved. | Move `next_review` check into an `else` branch or use a per-entry result variable that tracks the worst outcome. Increment counters once per entry. |
| F3 | P2 | release-verify.sh | 294 | `$FRESH_TODAY` is unquoted: `bash "$SCRIPT_DIR/runtime-freshness-verify.sh" "$FRESH_REPO" $FRESH_TODAY`. This is an intentional pattern (empty var disappears, non-empty date has no spaces), and the verifier's regex guard on line 21 catches malformed input. Not a functional bug, but violates the script's own convention of quoting all variable expansions (header line 82: "Quote all path expansions"). | Style inconsistency. ShellCheck would flag SC2086. No functional risk because dates contain no spaces and the verifier validates format. | Either quote with conditional: `${FRESH_TODAY:+"$FRESH_TODAY"}` or use an explicit if/else for the 1-arg vs 2-arg call. |
| F4 | P2 | runtime-freshness-verify.sh | 91-95 | `unknown_current_behavior` check only fires for safety surfaces. For non-safety surfaces with `status=unknown_current_behavior`, the entry silently falls through to the age check and may PASS. This is per-spec (handoff section 4.4 only lists 6 surfaces for fail-closed). However, the script does not emit any WARN for non-safety unknown surfaces -- the operator gets no signal that a surface has unknown behavior. | Operator may not notice that a non-safety surface has unknown behavior since the output shows PASS with no annotation. | Add a WARN (not BLOCK) for non-safety surfaces with `unknown_current_behavior` so operators are aware. |
| F5 | P2 | runtime-freshness-verify.sh | 59 | Header detection regex `'^\|[[:space:]]*surface[[:space:]]*\|.*owner'` is fragile -- it requires the header to start with `surface` in the first cell AND contain `owner` somewhere. If someone reorders columns, renames `owner`, or adds a different first column, the parser silently finds no table rows and reports 0 entries (total=0, PASS). | Ledger format is controlled by TAD (not arbitrary user input), so this is low risk in practice. But a silently empty parse is a fail-open on a structural defect. | Either assert `total > 0` after parsing (fail-closed on empty parse), or match more column names. |
| F6 | P2 | runtime-freshness-verify.sh | 14 | SAFETY_SURFACES list is a space-separated string, not an array. Works correctly with the `for sf in $SAFETY_SURFACES` iteration on line 48, but is fragile if a surface name ever contains a space. All current names use underscores so this is safe today. | No current risk. Theoretical fragility. | Minor: could use a bash array for robustness. Not urgent. |
| F7 | P2 | codex.md | 24 | `skill_loading` is marked `volatility: high` but Phase 1 capability matrix marks skill loading as `Medium (Codex skill loading heuristics may change)`. The ledger is more conservative than Phase 1's assessment. | Over-conservative: may cause unnecessary BLOCK after 30 days instead of WARN after 60 days. Errs on the safe side. | Align with Phase 1 assessment (medium) or document the rationale for the upgrade to high. |
| F8 | P2 | claude-code.md | -- | Claude Code ledger has 9 surfaces. The handoff section 4.3 lists exactly these 9 as required. Coverage is correct. No missing surfaces. | None. | None needed. |

---

## Verification Results

### Awk Field Numbering (Review Focus 1)

Verified by parsing the header row with `awk -F'|'`:

```
field 1: []  (leading empty from initial pipe)
field 2: [surface]
field 3: [owner]
field 4: [current_behavior]
field 5: [source]
field 6: [runtime_version]
field 7: [last_verified]
field 8: [volatility]
field 9: [next_review]
field 10: [regression_required]
field 11: [fallback_behavior]
field 12: [status]
field 13: [] (trailing empty)
```

Script extracts: `surface=$2, vol=$8, last_ver=$7, next_rev=$9, status=$12`. All correct.

All data rows in both ledgers have exactly 12 pipe characters (correct for 11 columns). No embedded pipe characters in cell content (e.g., MCP row uses `STDIO + Streamable HTTP` not `STDIO | Streamable HTTP`).

**RESULT: PASS**

### macOS date -j (Review Focus 2)

`date -j -f "%Y-%m-%d" "2026-06-09" "+%s"` works correctly on macOS (tested, returns epoch). No Linux fallback exists. See F1.

**RESULT: P1 (Linux incompatibility)**

### release-verify Regression (Review Focus 3)

Tested:
- `release-verify.sh version . 2.26.0` -- exits 0 (PASS, unchanged behavior)
- `release-verify.sh freshness . 2026-06-09` -- exits 0 (PASS, correctly delegates to verifier)
- `release-verify.sh freshness .` (no date) -- exits 0 (PASS, verifier uses default date)
- `structural` mode: not retested (no code changes to structural case)
- Usage line updated correctly (line 92)

The freshness case (lines 290-295) correctly delegates to the standalone verifier. No existing mode behavior is altered.

**RESULT: PASS**

### Safety Surfaces (Review Focus 4)

Handoff section 4.4 specifies 6 safety surfaces:
1. `hooks` -- in list
2. `ask_user_question_hook` -- in list
3. `sandbox_approval_permissions` -- in list
4. `trace_evidence_capture` -- in list
5. `subagents_custom_agents` -- in list
6. `context_compaction` -- in list

All 6 present in `SAFETY_SURFACES` on line 14.

**RESULT: PASS**

### Ledger Accuracy vs Phase 1/2 (Review Focus 5)

| Surface | Ledger Claim | Phase 1/2 Evidence | Match? |
|---------|-------------|-------------------|--------|
| ask_user_question_hook | `accepted_limitation` | Phase 1 V20: `unknown_current_behavior`; handoff section 4.7 explicitly directs to use `accepted_limitation` with fallback | Correct (follows handoff guidance) |
| trace_evidence_capture | `verified_partial` | Phase 1 V17: `verified_partial` | Exact match |
| hooks | `verified`, 10 events | Phase 1 V3: confirmed 10 events, verified | Match |
| subagents_custom_agents | `verified` | Phase 1 V4: confirmed built-in + custom agents | Match |
| sandbox_approval_permissions | `verified` | Phase 1 V10: confirmed permission profiles | Match |
| context_compaction | `verified`, medium volatility | Phase 1 V6: confirmed auto-compact | Match |
| skill_loading | `verified`, high volatility | Phase 1 matrix: medium volatility (see F7) | Minor discrepancy |
| config_toml | `verified`, medium | Phase 1 V9 + D3: confirmed, medium volatility | Match |
| codex_cloud | `verified`, high | Phase 1 V7: confirmed, `High (cloud features actively evolving)` | Match |

**RESULT: PASS (1 minor discrepancy noted in F7)**

---

## Fail-Closed Behavior Verification

| Test Case | Expected | Actual | Status |
|-----------|----------|--------|--------|
| Missing ledger file | exit 2 | exit 2 | PASS |
| Malformed date in `last_verified` | exit 2 | exit 2 | PASS |
| Invalid volatility value | exit 2 | exit 2 (tested via code inspection; `*` case on line 126) | PASS |
| Missing required field (empty surface/vol/last_ver/status) | exit 2 | exit 2 (lines 79-83) | PASS |
| `unknown_current_behavior` on safety surface (`hooks`) | exit 1 BLOCK | exit 1 BLOCK | PASS |
| `unknown_current_behavior` on non-safety surface (`skill_loading`) | PASS (per spec) | exit 0 PASS | PASS |
| High-volatility stale (45 days > 30) | exit 1 BLOCK | exit 1 BLOCK | PASS |
| Medium-volatility stale (>60 days) | exit 0 WARN | Confirmed by code path (line 111) | PASS |
| Low-volatility stale (>180 days) | exit 0 WARN | Confirmed by code path (line 119) | PASS |
| High-vol overdue next_review | BLOCK | BLOCK | PASS |
| Medium/low overdue next_review | WARN | WARN | PASS |
| Invalid TODAY date format | exit 2 | exit 2 (line 24) | PASS |
| Current ledgers (all fresh) | exit 0 PASS | exit 0 PASS, 21 entries | PASS |

---

## Summary Counts

| Severity | Count | Blocking? |
|----------|-------|-----------|
| P0 | 0 | -- |
| P1 | 2 | Yes (F1: Linux compat, F2: double-counting) |
| P2 | 5 | No |

---

## Verdict: FAIL (P1=2)

Two P1 findings require resolution before acceptance:

**F1 (Linux date):** The `date -j -f` call is macOS-only. While the handoff says "BSD/macOS compatible shell" and the current repo runs on macOS, the handoff also covers Codex which runs on Linux containers (Codex Cloud). The script header (line 4) claims "BSD/macOS safe" which is true but incomplete -- it should also work on Linux for forward compatibility. This is blocking because the script is part of a release gate that may need to run in CI or Codex Cloud contexts.

**F2 (Double-counting):** Counter inconsistency where `pass + warn + block` exceeds `total`. The exit code logic is correct (blocks > 0 triggers exit 1), so fail-closed behavior is preserved. However, the misleading counter output would confuse operators during release gate reviews. Blocking because operator trust in gate output is a quality-chain requirement.

### Recommended Fix for F1

```bash
days_between() {
  local d1="$1" d2="$2"
  local s1 s2
  if date -j -f "%Y-%m-%d" "$d1" "+%s" >/dev/null 2>&1; then
    # macOS/BSD
    s1=$(date -j -f "%Y-%m-%d" "$d1" "+%s")
    s2=$(date -j -f "%Y-%m-%d" "$d2" "+%s")
  elif date -d "$d1" "+%s" >/dev/null 2>&1; then
    # GNU/Linux
    s1=$(date -d "$d1" "+%s")
    s2=$(date -d "$d2" "+%s")
  else
    echo "ERROR: cannot parse date '$d1' (neither BSD nor GNU date available)" >&2
    echo "GATE: runtime-freshness exit=2"
    exit 2
  fi
  echo $(( (s2 - s1) / 86400 ))
}
```

### Recommended Fix for F2

Track per-entry worst result instead of incrementing multiple counters:

```bash
    # After the age check (lines 100-130), store the result:
    local entry_result="pass"  # default from age check

    # In the age case blocks, set entry_result="block" instead of blocks++
    # In the age case warns, set entry_result="warn"

    # Then in the next_review check (lines 132-147):
    # Upgrade entry_result if the next_review finding is more severe
    # e.g., if entry_result="pass" and next_review says block, upgrade to block

    # After both checks, increment exactly one counter based on entry_result
    case "$entry_result" in
      block) blocks=$((blocks + 1)) ;;
      warn)  warns=$((warns + 1)) ;;
      pass)  pass=$((pass + 1)) ;;
    esac
```

---

## Positive Observations

1. **Solid table parsing**: The awk-based field extraction with `awk -F'|'` and whitespace trimming correctly handles the 11-column Markdown table. Field numbering is verified correct.

2. **Comprehensive fail-closed**: Every malformed input path (missing file, bad date, empty field, invalid volatility) exits 2 with a descriptive error message and the `GATE:` tag for machine parsing.

3. **Clean exit-code contract**: exit 0 (pass/warn), exit 1 (freshness block), exit 2 (wiring/malformed) -- consistent with release-verify.sh's existing contract.

4. **Ledger content quality**: Both ledgers include all required surfaces, drift response policies, and source references. The `ask_user_question_hook` treatment as `accepted_limitation` (not `unknown_current_behavior`) correctly follows the handoff guidance and avoids a false BLOCK while honestly documenting the gap.

5. **release-verify integration is minimal and correct**: Only 6 lines added (usage line + freshness case). Delegation to standalone script avoids polluting the existing release-verify.sh logic. Existing structural and version modes are completely untouched.

6. **No validation theater**: The verifier actually parses dates, computes age, classifies volatility thresholds, and checks safety surfaces -- not just grepping for keywords.
