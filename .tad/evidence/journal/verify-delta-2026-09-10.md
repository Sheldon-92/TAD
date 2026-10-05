# Journal: verify-delta implementation (Blake, 2026-09-10)

- AC self-leak discipline is load-bearing in both directions: the forbidden checkbox sentence
  must be absent from bug-path-protocol.md (AC2/AC13) while its prose gist must be present as a
  Method cell in the ILLEGAL fixture (AC12). A README describing the fixture as "quoting verbatim"
  overclaims and could confuse a future grep audit — fixed to "prose gist as Method cell".
- Handoff §7 CREATE list omitted `legal-grep-method.example.md` although the evidence manifest,
  AC12, and §5 step 12 all require it. Implementation created it anyway (manifest wins over the
  file list). Lesson for Alex: when manifest and §7 diverge, §7 CREATE is the checklist Blake ticks —
  keep them in sync at authoring time.
- No other surprises. All 23 §9.1 rows passed Layer 1 literally on first full run; dual Layer 2 PASS.
