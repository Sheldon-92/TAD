# Trial Index Routing — Wing → Room → Drawer

## Wing: ac-verification

### Room: grep-count-commands

- ac-verification-command-bug — grep -ocE, sort -u; -c pipeline always returns 1, use grep -oE alone to count unique matches.
- ac-grep-count-reference-pack — grep -c, vimax-patterns.md; Reference filenames appear twice in SKILL.md, so expect =2 not =1.

### Room: region-marker-extraction

- section-9-1-region-marker — ### 9.1, verify-ac-commands.sh; Section 9.1 is 3-hash not 2-hash, so wrong-depth matcher scans empty.

## Wing: gate-design

### Room: reviewer-blind-spots

- expert-reviewer-premise-check — notebooklm ask, Raw CLI; Reviewers confuse raw CLI calls with *research-notebook SKILL invocations.
- layer2-audit-reviewer-name-drift — layer2-audit.sh, DISTINCT_COUNT=0; -review.md names miss KNOWN_REVIEWERS, Tier 1 needs 2+ distinct.

## Wing: memory-and-learning

### Room: self-triggering-parsers

- parser-self-trigger — expert_review_finding, P0 regex; Prose quoting the P0 pattern self-triggers the parser and fabricates a P0.

## Wing: pack-build-rules

### Room: parity-checks

- codex-edition-parity — grep -c, allowlist, 3-layer; Use || true not || echo 0, which doubles the 0 output in bash.
- cross-agent-parity-check — research_complexity, step4_5; Source-condition Layer 3 markers or alex-only markers fail the blake edition.

### Room: skill-migration

- scienceclaw-skill-decoupling — plugin-sdk, PRISMA 27-item; 0/285 ScienceClaw skills import runtime, so skills port as standalone files.

## Wing: pack-evaluation

### Room: pack-value-measurement

- pack-value-non-monotonic — WITH vs CONTROL, Sonnet delta; Rich-pack delta peaks at Sonnet, haiku cannot reliably apply 50KB packs.
- pack-value-cross-vendor — codex exec, gemini -p; Packs add value cross-vendor with delta 6-12, CONTROL stays 0-5 for all models.

### Room: quality-and-rubric-review

- scoring-rubrics-need-methodology-review — ux-expert-reviewer, 0-5 scale; Rubrics need methodology review, code review misses overlapping scores.
- academic-research-pack-pilot — ScholarEval 0.626, 20 calls; Pilot did 17 under 20 calls unenforced and lacked Tier 1-4 evidence labels.

### Room: collision-detection

- pack-collision-detection — scan-collisions.sh, APCA vs WCAG; Cross-category precedence resolves, same-category collisions must escalate.

## Wing: principles-linked

### Room: copy-set-deny-list

- derived-copy-set-dotfiles — cp -R src/., .gitkeep; Bare star glob drops dotfiles, leaving .gitkeep-only dirs empty on copy.
- embedded-copy-drift-check — ZERO_TOUCH, TRANSIENT, comm -23; Drift check rebuilds deny-list from lib via awk, compares sorted sets.

### Room: role-and-extraction-discipline

- alex-role-decay-direct-execution — mv/rm, 14 projects, 25312 files; Alex bypassed handoff and ran destructive quarantine directly.
- progressive-disclosure-extract — constraint count 131, col-0 keys; Extract only 0-token blocks descending, keeping the count at 131.

### Room: audit-validation-theater

- ad-hoc-dead-code-audit — DEAD, git status, emit_*; Ad-hoc scanner falsely flagged about 20 live functions DEAD without spot-checks.

## Wing: research-methodology

### Room: cli-orchestration-constraints

- codex-agents-md-auto-load — AGENTS.md, 8 trigger phrases; Codex auto-loads AGENTS.md like CLAUDE.md, needs Default Behavior guard.
- gemini-cli-constraints — gemini -p, grep -E; Gemini CLI hangs without -p, -p is read-only, PCRE regex needs BSD grep validation.

### Room: source-import-quality

- chattts-consistency-pattern — ChatTTS, manual_seed(42), spk_emb; Reset seed 42 per segment and save narrator.pt for consistent voice.

## Wing: shell-portability

### Room: sed-path-normalization

- anchorless-tad-sed — sed, ls -d, .tad/; Unanchored .tad/ sed mangles relative paths, anchor on a preceding slash.
- line-anchored-blockquote-sed — CONSUMES, PRODUCES, scan-packs; Single-line blockquote yields one col-0 marker, split markers apart.

### Room: routing-label-grep

- claude-md-routing-label-conflicts — grep count, CLAUDE.md routing; Routing keyword reused as note prefix makes grep return 2 not 1.
