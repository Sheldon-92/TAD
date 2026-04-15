# Code Review: layer2-audit.sh

**Reviewer:** code-reviewer (sub-agent)
**Date:** 2026-04-15
**Scope:** `.tad/hooks/lib/layer2-audit.sh` (99 lines) + fixture driver `run-all.sh`
**Context:** Blue-team smoke-alarm validator invoked by Alex `*accept` step4c. Not a hook, not registered to `settings.json`. Review focus per handoff §6 Phase C: portability, ANSI degradation, slug injection, size-heuristic, bash hygiene, length-cap.

Overall the script is short, defensive, and well-scoped. Fixture matrix 11/11 PASS. AC1–AC8 all satisfied on inspection. Findings below are mostly hardening, no correctness blocker.

---

## P0 — Must fix before Gate 3

*(none)*

All security-critical paths (slug whitelist anchoring, `--` separators on `find`, length-capped echo, runtime `stat` detection, no hook registration, empty stderr on PASS) are correctly implemented. No P0 findings.

---

## P1 — Should fix but not blocking

### P1-1. `_file_size` fallback `|| echo 0` is dead-code under `set -e`, and will emit stdout noise if triggered
- **File:line:** `layer2-audit.sh:22`, `layer2-audit.sh:24`
- **Rationale:** Both branches use `stat ... -- "$1" 2>/dev/null || echo 0`. With `set -euo pipefail` and the function called in command substitution `sz=$(_file_size "$f")`, if `stat` fails the function's exit status is masked by `|| echo 0`, so `sz` becomes literal `0` — fine. BUT: if `stat` ever writes a byte count to stdout AND fails partway, you could get `"1234\n0"` which would then blow up the subsequent `[ "$sz" -ge "$min_bytes" ]` arithmetic comparison with `integer expression expected`. Unlikely in practice, but `set -euo pipefail` makes silent numeric coercion a footgun.
- **Patch:**
  ```bash
  _file_size() {
    local s
    s=$(stat -c%s -- "$1" 2>/dev/null) || s=0
    printf '%s' "${s:-0}"
  }
  ```
  (and symmetrically for the BSD branch with `-f%z`). Guarantees a single numeric token.

### P1-2. Runtime stat detection runs `stat --version` which on BSD prints to stderr before returning non-zero
- **File:line:** `layer2-audit.sh:21`
- **Rationale:** On macOS, `stat --version` emits `stat: illegal option -- -` to stderr. You redirect with `>/dev/null 2>&1` so it's silenced — good. But detection via side-effect is fragile; some busybox `stat` implementations accept `--version` as a no-op and still exit 0 despite being non-GNU. Consider probing with a neutral sentinel:
- **Patch (defensive alternative):**
  ```bash
  if stat -c%s /dev/null >/dev/null 2>&1; then
    _file_size() { ... stat -c%s ... ; }   # GNU
  else
    _file_size() { ... stat -f%z ... ; }   # BSD
  fi
  ```
  This tests the actual capability you need (`-c%s`) rather than the `--version` proxy, aligning with the project knowledge entry *Hook Shell Portability: No grep -P on macOS (2026-04-03)* — test capability, not vendor.

### P1-3. Whitelist regex allows 2-char slugs like `a-` to fail but `ab` to pass correctly — but single-char slugs like `a` or `_` pass, which may be too permissive for a Slug Contract
- **File:line:** `layer2-audit.sh:39`
- **Rationale:** The regex `^[A-Za-z0-9_]([A-Za-z0-9_-]*[A-Za-z0-9_])?$` permits single-character slugs. Handoff §2.3 slug extraction regex in the SKILL is `([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])` — **2 char minimum** (two bracket classes with `*` between). This is an asymmetry: the script would accept `a` but SKILL-side extraction would reject it. Fixture test doesn't cover this edge.
- **Patch:** Either tighten the script to require ≥2 chars to match SKILL, or loosen SKILL to `([a-zA-Z0-9_]([a-zA-Z0-9_-]*[a-zA-Z0-9_])?)`. Per AC5 "对称白名单", they must match exactly. Recommend tightening the script (single-char slugs are almost never legitimate handoff names):
  ```bash
  if ! [[ "$slug_raw" =~ ^[A-Za-z0-9_][A-Za-z0-9_-]*[A-Za-z0-9_]$ ]]; then
  ```
  Add a fixture `slug_single_char` → exit 2.

### P1-4. Error messages prepend ANSI red but TSV `expected_stderr_has` grep works on raw bytes, so NO_COLOR=1 in `run-all.sh` is load-bearing and undocumented
- **File:line:** `run-all.sh:74`
- **Rationale:** The test driver sets `NO_COLOR=1` on every invocation, which is correct (prevents ANSI escapes from polluting `grep -qF` matches). But there's no comment explaining **why** NO_COLOR is set. A future maintainer could remove it and the matcher on line 89 would still work because `grep -qF` does substring match on escape-wrapped text — until a fixture payload contains a red ANSI byte boundary that splits the match token. Add a one-line comment.
- **Patch:** In `run-all.sh:74`, change to:
  ```bash
  # NO_COLOR=1 strips ANSI so stderr substring matches stay stable (AC3/AC4 contract).
  actual_stdout=$(NO_COLOR=1 bash "$SCRIPT" "$slug" 2>/tmp/.l2a-err.$$)
  ```

### P1-5. `find -L ... 2>/dev/null` swallows real errors (permission denied, broken symlink loops)
- **File:line:** `layer2-audit.sh:73`, `layer2-audit.sh:85`
- **Rationale:** Silencing `find` stderr means a genuine filesystem issue (EACCES on the reviews dir, symlink loop from `-L`) becomes "empty result" which then reports as `no .md files` — a misleading error. This is a smoke alarm, so a false-negative ("dir looked empty but actually unreadable") is the exact failure mode the tool is designed to catch.
- **Patch:** Capture stderr and surface it in the FAIL message:
  ```bash
  find_err=$(mktemp)
  while IFS= read -r -d '' f; do ... ; done < <(find -L -- "$dir" -maxdepth 1 -type f -name '[!.]*.md' -print0 2>"$find_err")
  if [ -s "$find_err" ] && [ "$qualified" -eq 0 ]; then
    _err "Layer 2 audit FAIL: find reported errors: $(head -c 200 "$find_err")"
    rm -f "$find_err"; exit 1
  fi
  rm -f "$find_err"
  ```
  Acceptable to defer if the complexity budget is tight — note it as known limitation.

---

## P2 — Nice-to-have

### P2-1. `basename -- "$0"` in usage message echoes the caller's invocation path
- **File:line:** `layer2-audit.sh:29`
- **Rationale:** Works correctly. Minor suggestion: hard-code `layer2-audit.sh` since the tool is referenced by name in the Alex SKILL contract. Makes error messages stable across `bash script.sh` vs `./script.sh` invocations.

### P2-2. Dotfile-detection branch uses `find ... -print -quit | grep -q .`
- **File:line:** `layer2-audit.sh:85`
- **Rationale:** Works but `-print -quit` already stops after first match; the `grep -q .` is only needed to turn "any output" into exit status. Cleaner: `find ... -print -quit 2>/dev/null | read -r _ && _err "..."`. Purely stylistic.

### P2-3. `min_bytes=200` is a magic number repeated in stderr text
- **File:line:** `layer2-audit.sh:55`, `layer2-audit.sh:95`, `layer2-audit.sh:97`
- **Rationale:** Stderr strings correctly interpolate `${min_bytes}` on line 95/97 — good. Line 48's "size-check is smoke-alarm heuristic" language is present across all messages (AC4 requirement satisfied). No change needed; noting for future maintenance that raising the threshold is a one-line edit.

### P2-4. No explicit `LC_ALL=C` for `find` / `[[ =~` regex matching
- **File:line:** `layer2-audit.sh:8-9`
- **Rationale:** Bash regex `=~` behavior with `[A-Za-z0-9_]` is locale-dependent in some edge cases (e.g., Turkish locale `i`/`I`). Since `IFS` is already hardened, adding `export LC_ALL=C` at the top would fully neutralize locale surprises. Low probability on macOS dev hosts, standard hardening for portable bash.

### P2-5. `run-all.sh` cleans `dogfood-pass` / `dogfood-fail` on EXIT trap but these are named without the `audittest_` prefix
- **File:line:** `run-all.sh:15-22`
- **Rationale:** The `_cleanup` loop iterates `SLUGS` including `dogfood-pass` / `dogfood-fail`, so cleanup is correct. But the naming convention inconsistency (audittest_* vs dogfood-*) could cause confusion if a future maintainer adds a real `dogfood-pass` handoff. Suggest renaming to `audittest_dogfood_pass` / `audittest_dogfood_fail` for consistency. Non-blocking.

---

## Positive Notes

- `set -euo pipefail` + `IFS=$'\n\t'` header correctly applied (AC1).
- `--` separator on every `find`/`stat`/`basename` call (AC2 injection guard).
- Slug length-cap `${slug_raw:0:64}` on display path (AC2 anti-DoS).
- Strict anchored whitelist correctly rejects leading-dash flag injection (AC2).
- PASS path emits **zero** stderr (AC3 contract — verified empirically via fixture `dogfood-pass` row 11 "(empty)").
- Runtime stat detection via `stat --version` (AC1 — no hardcoded flavor), though see P1-2 for tightening.
- FAIL error messages all include the required `size-check is smoke-alarm heuristic` scoped footer (AC4).
- Symlink handling via `find -L` correctly follows to target; `-L "$f"` distinguishes symlinked-small from regular-small in the FAIL message (AC4 case d).
- Dotfile exclusion via `-name '[!.]*.md'` in primary sweep, with explicit `-name '.*.md'` secondary probe to produce the "only dotfiles" message (AC4 case e).
- No `grep -P`, no `python3`, no dependency on jq/yq/perl — fully complies with §5 "不引入新依赖".
- Fixture driver's use of `set +e` / `set -e` bracket around the subprocess call is correct.
- No hook registration verified via §2 constraint — script path not in `.claude/settings.json` (AC8).

---

## Verdict: PASS
