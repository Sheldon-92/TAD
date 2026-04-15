# Security Review — HANDOFF-20260415-layer2-audit

**Reviewer:** security-auditor (blue-team defensive)
**Date:** 2026-04-15
**Scope:** Design review of ~40-line bash audit utility + Alex SKILL step4c insertion
**Threat model:** Single-user CLI, local workstation. "Attacker" = accidentally or deliberately crafted handoff filename / evidence content. Not network-facing. Blake is trusted-but-verify.
**Out of scope by explicit handoff decision:** mechanical enforcement, HMAC chains, fail-closed semantics, hook registration. Any P0 attempting to re-introduce these is rejected by construction.

---

## 1. Critical Issues (P0)

**None.**

The proposed design is scope-proportionate for a smoke-alarm utility. No finding rises to P0 in this threat model. All residual risks are either defense-in-depth (P1) or accepted-by-design trade-offs (P2/noted).

---

## 2. Recommendations (P1)

### P1-1. Anchor the slug whitelist regex and reject leading `-`

**Issue:** The handoff states whitelist `[a-zA-Z0-9_-]+`. Two gaps in the written spec:

1. **Regex not anchored.** If Blake implements as `[[ "$slug" =~ [a-zA-Z0-9_-]+ ]]`, the slug `foo;rm -rf /` passes because the regex matches the `foo` substring. Must be anchored: `^[a-zA-Z0-9_-]+$`.
2. **Leading `-` is legal under the current whitelist** and creates argv-flag-injection surface for downstream tools. If the script ever does `find .tad/evidence/reviews/blake/$slug -name '*.md'` with `slug=-name`, the shell word-splits and `find` reinterprets the slug as a flag. Same risk with `stat`, `ls`, `grep` if added later.

**Fix:**

```bash
# Anchored whitelist + explicit leading-dash rejection
if ! [[ "$slug" =~ ^[a-zA-Z0-9_]([a-zA-Z0-9_-]*[a-zA-Z0-9_])?$ ]]; then
  printf 'ERROR: invalid slug\n' >&2
  exit 1
fi
```

This requires slug to start and end with alphanumeric/underscore, with optional hyphens only in interior positions. Blocks `-foo`, `foo-`, empty string, and `--`.

Additionally, **always pass constructed paths with `--` separator** to any tool that supports it:

```bash
find -- "$dir" -maxdepth 1 -name '*.md'   # -- prevents $dir starting with - being treated as flag
```

**Severity rationale:** Blake-authored handoff filenames are the slug source. Blake is trusted, but the bar for a 30-minute utility should still be "can't be trivially weaponized by a typo." Unanchored regex is a textbook bug class.

### P1-2. Sanitize stderr output — slug appears in error messages that flow back to Claude context

**Issue:** Exit-1 stderr messages per the spec include the slug ("`目录不存在: .tad/evidence/reviews/blake/${slug}/`"). This stderr is captured by Alex's tool call and re-enters Claude's reasoning context.

Even with the tightened whitelist from P1-1 (alphanumeric + underscore + interior hyphen only), the slug contains NO ANSI escapes, NO control characters, NO Unicode confusables — so direct injection is not possible. **Good.**

However, the script itself emits `\033[31m...\033[0m` ANSI sequences unconditionally if the TTY check passes. When Alex runs the script via Bash tool, stderr is captured as text, the TTY check `[ -t 2 ]` correctly returns false (tool pipes are not TTYs), so color is suppressed. **This is correct behavior and the handoff spec gets it right.**

**Recommendation (defense-in-depth):**

1. Explicitly test the `NO_COLOR` + `[ -t 2 ]` logic in the AC4 fixture with stderr redirected to a file — confirm no raw `\033` bytes land in captured output.
2. Add to AC2: slug echoed in error messages must be wrapped with a length cap, e.g. `${slug:0:64}`. Prevents a pathological 10KB slug (edge case where whitelist is bypassed by implementation bug) from flooding Alex's context.
3. When constructing error messages, use `printf '%s' "$slug"` not `echo "$slug"` — `echo` on some shells interprets backslash escapes in the argument.

### P1-3. `find` / `stat` argv hygiene even with whitelist

**Issue:** Defense-in-depth. Even with P1-1's tightened slug, the script constructs `dir=".tad/evidence/reviews/blake/${slug}/"`. If AC2's whitelist check is ever refactored or a bug slips in, downstream commands should fail safe.

**Fix pattern for the whole script:**

```bash
dir=".tad/evidence/reviews/blake/${slug}"
# Canonicalize + verify still under expected prefix
case "$dir" in
  .tad/evidence/reviews/blake/*) : ;;
  *) printf 'ERROR: path escaped expected prefix\n' >&2; exit 1 ;;
esac

# All tool invocations use -- separator
find -- "$dir" -maxdepth 1 -type f -name '*.md' -print0 2>/dev/null
stat -f%z -- "$file" 2>/dev/null || stat -c%s -- "$file" 2>/dev/null
```

The case-pattern prefix guard is a belt-and-suspenders check that catches any future slug-construction refactor.

### P1-4. Slug extraction regex anchoring in SKILL.md (separate from shell script)

**Issue:** Handoff §2.3 specifies extraction regex `^(HANDOFF|COMPLETION)-\d{8}-(.+)\.md$`. Two concerns:

1. **`.+` is greedy and un-validated.** A filename like `HANDOFF-20260415-foo; rm -rf ~.md` technically matches, and Alex would extract slug = `foo; rm -rf ~`. The shell script would then reject it via the whitelist — **so the layered defense works** — but the SKILL should pre-validate before handing off to the script, so the audit trail records "slug unresolvable" not "script rejected slug".
2. **Unicode.** A filename using a fullwidth digit `HANDOFF-２０２６０４１５-foo.md` won't match `\d{8}` (PCRE `\d` is ASCII-only in most regex engines the SKILL interpreter would use). The SKILL should fall through to "N/A: non-standard filename" as specified — but this case should be explicitly listed in AC.

**Fix:** Add to SKILL step4c the pattern `^(HANDOFF|COMPLETION)-[0-9]{8}-([a-zA-Z0-9_][a-zA-Z0-9_-]*[a-zA-Z0-9_])\.md$` which matches the shell's whitelist. Symmetric validation at both layers prevents "SKILL extracts something shell rejects" ambiguity.

### P1-5. Add empty-directory and symlink cases to fixtures

**Issue:** AC4 lists 3 negative fixtures: "dir missing / no md / md <500 bytes". Two edge cases worth adding (5 minutes of work):

1. **Symlinked md file pointing to `/etc/passwd`-size file.** Does `stat` follow the symlink? macOS `stat -f%z` follows by default; `stat -f%z -L` forces follow, `-f%z` on a symlink reports the LINK size (usually <500 bytes). This is probably fine ("symlinks fail the size check") but should be documented as "tested and expected behavior: symlinks to arbitrary files not counted."
2. **Directory with only a dotfile `.review.md`.** Does `find -name '*.md'` match `.review.md`? Yes on both BSD and GNU find. Is that intended? Probably yes, but confirm.

**Fix:** Expand AC4 fixtures from 3 to 5 cases. Cost: 2 extra `touch` commands and 2 extra TSV rows.

---

## 3. Suggestions (P2)

### P2-1. 500-byte threshold circumvention — accepted trade-off, document it

The user correctly anticipated this: Blake can pad a stub review with 500 bytes of whitespace. For a smoke alarm, this is the right trade-off — escalating to content-quality checks (heuristics on reviewer markers, structured headings, etc.) would be scope creep and fragile.

**Suggestion:** Add one line to the script's warning message: "Note: size check is smoke-alarm only, does not validate content quality." So the human verifier is primed to read the artifact, not just trust the size.

### P2-2. Log slug + exit code to a small audit-trail file

**Suggestion (optional, low priority):** Append one line to `.tad/logs/layer2-audit.log` per invocation: `ISO_TIMESTAMP\tslug\texit_code`. Zero bytes of security benefit, but useful for "did Alex actually run this on the last 5 handoffs?" retrospective checks. Single-user CLI so no log-tampering concern; just operational visibility.

**Reject variant:** Do NOT add HMAC/signature chains to the log. That was cut for the right reasons.

### P2-3. Document the `set -euo pipefail` posture

**Suggestion:** Script should begin with `set -euo pipefail` + `IFS=$'\n\t'`. Standard bash hygiene. If omitted, an unset variable in a future edit silently expands to empty string and breaks the whitelist check. Cost: 2 lines.

### P2-4. Missing defenses considered and rejected (explicit)

To close the "what else" question with explicit reasoning:

| Defense | Verdict | Why |
|---|---|---|
| HMAC-signed evidence files | REJECT | Explicitly cut; single-user threat model |
| PreToolUse hook registration | REJECT | Dogfood paradox; explicitly cut |
| Fail-closed on script error | REJECT | "Smoke alarm not fire suppressor"; Alex continues |
| File content heuristic scoring | REJECT | Scope creep; human-in-the-loop judges quality |
| Per-reviewer file naming convention | DEFER | Could add "must have code-reviewer.md" but widens scope; leave for v2 if needed |
| Redact slug in stderr | PARTIAL ACCEPT | Length cap (P1-2) yes; full redaction no (slug is needed in message to be useful) |
| Cryptographic directory hash | REJECT | Out of threat model for single-user CLI |

---

## 4. Overall Assessment

**CONDITIONAL PASS**

The handoff design is sound and appropriately scoped. No P0 security issues. Recommended conditions for final PASS:

1. **P1-1 MUST be addressed in Blake's implementation** — anchored regex + leading-dash rejection. This is textbook shell injection prevention and costs ~3 lines of code. Without it, the whitelist is a paper guard.
2. **P1-2 partial fix: add length cap** on slug in error messages (`${slug:0:64}`). Other P1-2 items are already correct in the spec.
3. **P1-3 recommended:** prefix-guard + `--` separator on all tool invocations. Defense-in-depth.
4. **P1-4 should be addressed in SKILL.md edit:** symmetric regex between SKILL extraction and shell whitelist.
5. **P1-5 nice-to-have:** expand fixtures to cover symlink + dotfile edge cases.
6. **P2-3 MUST be addressed:** `set -euo pipefail` at script top. Bash hygiene for any script that takes untrusted input.

Total additional implementation cost: ~10 minutes, keeps script within 40-50 line budget.

**None of the above re-introduces mechanical enforcement, HMAC, fail-closed, or hook registration.** All are implementation-hardening of the already-agreed "smoke alarm" design.

The explicit rejections in §3 P2-4 confirm that the scope-proportionality contract is preserved. Blake may proceed to Phase A with the P1 fixes incorporated.

---

## 5. Summary Table

| # | Finding | Severity | Must-Fix? |
|---|---|---|---|
| P1-1 | Anchor slug regex + reject leading `-` | P1 | Yes |
| P1-2 | Length-cap slug in stderr messages | P1 | Partial (length cap only) |
| P1-3 | `--` separator + prefix guard | P1 | Recommended |
| P1-4 | Symmetric regex in SKILL.md | P1 | Yes |
| P1-5 | Symlink + dotfile fixtures | P1 | Nice-to-have |
| P2-1 | Document size-check caveat in warning | P2 | Suggested |
| P2-2 | Append-only audit log | P2 | Optional |
| P2-3 | `set -euo pipefail` header | P2 | Yes (hygiene) |
| P2-4 | Rejection rationale for scope creep | P2 | Documented |

**Verdict:** CONDITIONAL PASS — approve with P1-1, P1-2 (length cap), P1-4, P2-3 as mandatory fixes in Blake's Phase A implementation.
