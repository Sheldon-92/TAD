# Code Review: HANDOFF-20260415-layer2-audit (Express)

**Reviewer**: code-reviewer (sub-agent)
**Date**: 2026-04-15
**Scope**: ~40-line shell utility + ~30-line SKILL.md edit. Manual-invocation audit helper, NOT hook infrastructure.
**Review posture**: Proportionate to scope. Not inflating a 40-line script into production hardening.

---

## 1. Critical Issues (P0 — must fix before Blake starts)

### P0-1. AC6 "dogfood" claim is not actually testable as written

Handoff §3 AC6 says: "本 handoff 归档时 Alex 走新 step4c 流程，验证有/无 Blake reviewer artifacts 两种路径的行为正确".

Two problems:
- **Self-fulfilling**: Blake himself will produce the reviewer artifact that his own script then looks for. The PASS branch is guaranteed by Blake's normal Layer 2 workflow — it doesn't prove the script detects anything, only that Blake produced an artifact.
- **FAIL branch is untestable during this handoff's own *accept**: you can't both (a) have Blake produce `reviews/blake/layer2-audit/code-reviewer.md ≥500B` (required by §4 evidence manifest) AND (b) observe the FAIL path on the same slug during Alex's Gate 4.

**Fix**: Rewrite AC6 to reference the fixture-based test in AC3/AC4 (which already exercises both paths) and drop the "dogfood during own acceptance" framing, OR split into:
  - AC6a: PASS-path demo on the real slug during *accept (naturally covered by the reviewer artifact existing)
  - AC6b: FAIL-path demo via a throwaway slug (`fake-slug-for-fail-demo`) run during acceptance, captured in test-results.tsv

### P0-2. Slug extraction regex misses `-accept` / Phase suffix convention

Handoff §2.3 specifies `^(HANDOFF|COMPLETION)-\d{8}-(.+)\.md$` with slug = $2.

Problem: this project's prior handoffs use suffixes like `-phase1c`, `-phase2a`, `-accept`, and the `reviews/blake/<slug>/` directory convention is NOT guaranteed to include the full suffix. Example from recent history:
- Handoff filename: `HANDOFF-20260407-domain-pack-hook-phase2b.md`
- Reviews directory actually used: `reviews/blake/domain-pack-hook-phase2b/` OR `reviews/blake/domain-pack-hook/` — **not specified by handoff**.

Handoff §2.1 step 2 checks `.tad/evidence/reviews/blake/${slug}/` but never defines the convention Blake is expected to write to. If Blake's side of the convention differs from Alex's extracted slug by even one character, the audit will false-FAIL.

**Fix (choose one)**:
- (a) Add explicit AC: "Blake reviewer artifacts MUST be written to `reviews/blake/<exact-slug-as-extracted-from-handoff-filename>/`" — make the contract symmetric and greppable.
- (b) Have the audit script try slug AND slug-with-trailing-`-phaseN`-stripped AND slug-up-to-last-dash as fallbacks, documented in script comments.
- (c) Accept directory-not-found as WARN (amber) rather than FAIL (red) since slug convention divergence is the likeliest cause.

Recommend (a) — it's one line of handoff text and removes the entire ambiguity class.

---

## 2. Recommendations (P1)

### P1-1. 500-byte threshold rationale unstated; too easy to game, maybe too strict on short valid reviews

A reviewer note that says "Reviewed. No issues found. All ACs look correct. Approving." is ~70 bytes and a legitimate output for a trivial change. 500 bytes roughly = 8-10 lines. Meanwhile, any adversary-minded Blake can `yes | head -c 500` it.

The threshold is doing **shape detection** ("did someone write a review at all?") not **quality detection**. That's fine, but:
- Recommend dropping threshold to **200 bytes** — still catches empty/1-line placeholders, less likely to reject a legitimate terse review.
- Document in the script header comment: "500B is a shape heuristic, not a quality gate. Quality is judged by human reading the referenced file, not byte count."

Not P0 because: for this audit's purpose (catch "Blake skipped Layer 2 entirely"), even 100 bytes would work. Exact number is calibration, not correctness.

### P1-2. Missing AC: script must not pollute stderr on PASS path

The handoff spec says PASS → stdout PASS message. It doesn't explicitly say PASS path has **empty** stderr. If the script accidentally echoes portability-detection noise ("stat: illegal option -- c") to stderr during PASS, Alex's acceptance-report rendering may show spurious red text on a passing audit.

**Fix**: Add AC: "On PASS path, stderr is empty (redirect stat fallback errors to /dev/null)."

### P1-3. `[ -t 2 ]` + `NO_COLOR` covers 95% of cases but misses CI environments with TERM=dumb

The handoff correctly cites `NO_COLOR` and `[ -t 2 ]`. One realistic miss: some CI runners (GitHub Actions, some docker-exec contexts) have `[ -t 2 ]` TRUE but render ANSI escapes as literal `\033[31m` text because the log viewer doesn't interpret ANSI.

Minor; the intended use case is Alex's interactive terminal, where TTY check is correct. Note for the script header: "color detection targets Alex interactive use; CI-rendered output may show raw escapes, acceptable given Alex is the only intended caller."

### P1-4. Portability test is implicit; add AC for it

Handoff §6 Phase C says reviewer should focus on "macOS/Linux stat" — good — but no AC actually requires the script to be **tested** on both or to use a **detection pattern** rather than hardcoding.

**Fix**: Add AC: "Script uses runtime detection (e.g., `if stat -f%z /dev/null >/dev/null 2>&1; then ... else ... fi`) or `stat --version` probe — NOT hardcoded to one flavor. Verified by inspection + one smoke run on the development host (macOS)."

---

## 3. Suggestions (P2)

### P2-1. Slug whitelist `[a-zA-Z0-9_-]+` is correct for shell-injection/path-traversal purposes

Analysis for the P0-focused question in the brief:
- `..` blocked by `-` alone not being enough — but `..` contains only `.`, which is NOT in the whitelist, so it's rejected. ✓
- `/` not in whitelist. ✓
- Shell metacharacters (`$`, `` ` ``, `;`, `|`, `&`, `(`, `)`, `<`, `>`, whitespace, `*`, `?`, `[`, `]`, `{`, `}`, `'`, `"`, `\`) all not in whitelist. ✓
- Unicode / control chars: not in whitelist (matcher should be POSIX class `[[:alnum:]_-]` or explicit ASCII `[A-Za-z0-9_-]`, either is safe). ✓
- Leading `-`: if slug starts with `-`, it could be mistaken for a flag by downstream commands. The script only interpolates slug into a **path** (`.tad/evidence/reviews/blake/${slug}/`), not as a flag to another tool, so this is a non-issue for current usage. Still, belt-and-suspenders: require first char to be alphanumeric: `^[A-Za-z0-9][A-Za-z0-9_-]*$`. Low priority.

**Verdict on P0 Focus #1**: whitelist is sufficient. No bypass identified given current usage.

### P2-2. Nice-to-have: emit machine-readable output line alongside human message

For eventual automation (future Alex acceptance-report templating), consider a final stdout line like:
```
LAYER2_AUDIT_RESULT: status=pass file_count=3 slug=layer2-audit
```
This lets Alex's acceptance-report rendering parse structured data rather than scraping stdout. Not required for MVP.

### P2-3. Document the manual-invocation contract in script header

Three-line header comment:
```
# Manual Alex Gate 4 audit helper. NOT a PreToolUse hook. NOT registered to settings.json.
# Invoked by Alex acceptance_protocol step4c. Exits 0/1; does not block Alex's acceptance flow.
# See HANDOFF-20260415-layer2-audit.md for design rationale.
```
Prevents future misunderstanding that leads someone to try registering it as a hook.

---

## 4. Answers to Brief's Focus Questions (condensed)

1. **Slug whitelist**: Sufficient. See P2-1. No bypass found.
2. **stat portability**: Handoff mentions portability in §2.1 and §6 Phase C but no AC enforces runtime detection. See P1-4.
3. **ANSI handling**: `NO_COLOR + [ -t 2 ]` covers ~95%. Edge case (TERM=dumb CI) is out of intended-use scope. See P1-3.
4. **500-byte threshold**: Works as shape detector; recommend 200B for fewer false-FAILs. See P1-1.
5. **Slug extraction regex**: Base pattern is fine; the REAL risk is convention divergence between Alex-extracted slug and Blake's chosen review directory name. See P0-2.
6. **AC6 dogfood claim**: Self-fulfilling as written. See P0-1.
7. **Missing ACs**: (a) stderr-clean-on-PASS (P1-2), (b) runtime portability detection (P1-4), (c) Blake-Alex slug convention symmetry (P0-2).

---

## 5. Overall Assessment

**CONDITIONAL PASS**

Scope is correctly small and the architectural pivot (manual audit, not hook) is sound. The script's core logic is straightforward and the security surface (slug whitelist) is adequately defended for its interpolation context.

Blake can start Phase A in parallel with P0 resolution IF Alex confirms P0-2 resolution direction before Phase C (Blake's own Layer 2 review). P0-1 (AC6 rewrite) must be fixed before Alex runs Gate 4 or the AC will be un-verifiable.

**P0 count**: 2
**P1 count**: 4
**P2 count**: 3
