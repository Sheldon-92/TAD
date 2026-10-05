# verify-delta acceptance fixtures (TASK-20260910-VERIFY-DELTA)

Two Method-cell fixtures teach the legal/illegal boundary. Gate 3's
`Spec_Compliance_Verification.step2_classify` uses this grammar:

- `legal-grep-method.example.md` — LEGAL cell (runnable command in backticks).
- `illegal-prose-method.example.md` — ILLEGAL cell (prose-only, no command).

The ILLEGAL fixture uses the old `*bug` prose gist as a Method cell (without the
`- [ ]` checkbox prefix): that gist may appear ONLY here (and in gate-SKILL illegal examples), never in
the live `bug-path-protocol.md` mini template (AC2/AC13 grep that file for absence).
