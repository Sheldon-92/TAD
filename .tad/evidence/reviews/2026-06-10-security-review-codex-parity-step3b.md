# Gate 4 Security Audit — codex-parity-step3b (parity --fix surface)

**Date**: 2026-06-10 | **Reviewer**: security-auditor sub-agent (Alex Gate 4)
**Verdict**: FAIL (one latent P0)

- P0 (latent, reproduced): filename-with-space → sed [^ ]* parse failure → path skipped → DIRECTION stays default claude-newer → rsync -a --delete DESTROYS directly-edited mirror file (reproduced: "web design/SKILL.md" agents-side committed edit destroyed, FIX-PASS exit 0). The sole load-bearing defense fails OPEN; CONTRACT "biased to STOP" is false for the Files…differ branch. No spaced names exist today (latent), enforcement is convention-only; ebe92cf "fixed" with a comment.
  Remediation: invert default to agents-newer (STOP); promote to claude-newer only when EVERY differing path positively proven. Optionally NUL-safe enumeration instead of diff-text parsing.
- P1: mixed-commit blind spot (agents-newer detection fires only for agents-isolated commits / dirty tree) — document or fix via default inversion.
- P1: $REPO not canonicalized → symlinked/non-canonical path makes git pathspec guards silently pass. Fix: REPO="$(cd "$2" && pwd -P)".
- P2: no check that .agents/skills isn't a symlink escaping the repo (rsync --delete at link target).
- Verified correct: trailing-slash rsync semantics; quoting throughout; --fix arg shift under set -u; no || true on rsync; REFUSE/FIX-FAIL exit honestly; "Only in" branch survives spaces; TOCTOU immaterial for single-user release tool.

## Closure Addendum (Gate 4 rounds 2-3)

- Round 2 (post 238a56d): re-audit FAIL — default inversion landed but `[ -z "$apath" ] && continue`
  skipped unparseable paths without flipping all_claude_newer → vacuous promotion → original spaced-
  filename repro still destroyed mirror content. pwd -P canonicalization verified landed.
- Round 3 (post e82704f): parse failure now sets all_claude_newer=false + break (undecidable → STOP).
  Independent re-test 10/10 PASS: SEC-P0b repro STOPs, --fix REFUSES, mirror content survives;
  vacuous multi-path variant STOPs; AC5 claude-newer promotion unaffected.
- Final security verdict: PASS (closed by e82704f).
