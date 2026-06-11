# Project Context - TAD Framework

## Current State
- **Version**: 2.27.0 (24 capability packs + dual-platform native runtime + SKILL progressive loading)
- **Last Updated**: 2026-06-09
- **Framework**: TAD v2.27.0 + Self-Evolving + 24 Capability Packs + Dual-Platform (Claude Code + Codex) + Self-Deriving Release/Sync (deny-list) + NotebookLM Research Engine + Compact Recovery

## Active Work (parked epics — open phases, not zombies)
- ~~EPIC: Self-Evolution Pruning~~ — **COMPLETE + ARCHIVED 2026-06-10** (3/3 phases same-day). dream/evolve/optimize/skillify retired by measurement; 3-tier skill formalization live (T1 ceremony dogfooded in Colin, T2 skill-library ×2 refs, T3 via *harvest collisions); Alex SKILL -1872 lines; layer2-audit fail-closed. L2: "Claims Need Carriers".
- **EPIC: Upgrade Lifecycle System** (20260609) — **Phase 1/6 ✅ accepted 2026-06-09** (Migration Manifest Schema v1 + 3 DRs + example manifest, commit eab1fd8, Gate 4 15/15). Phase 2 next: migration-engine.sh + fixture harness. Goal: 远程升级无垃圾、不误删、深入骨髓.
- **EPIC: Goal-Driven Research Director** (20260504) — P1/P2/P4/P5 done; **P3 Research-Decision Loop** (⬚ Planned, `--caller` flag) + **P6.3 *sync to 14 projects** (deferred, outward-facing) outstanding
- **EPIC: Security Domain Pack Chain** (20260403) — 2/5 (paused; needs real-project security audit to validate value)
- **EPIC: ml-training Pack** (20260529) — parked
- 16 capability packs active; behavioral eval (lean-trustworthy P5) verified 2, web-backend held pending, 13 packs' eval is a follow-up

## Recently Completed

- **EPIC: Pack Collision Detection** (2026-05-31, 2/2 phases) — detects when 2 co-loaded packs issue contradicting directives; cross-category auto-resolve by precedence (security>correctness>a11y>performance>style) + visible log, same-category escalate. `scan-collisions.sh` + `pack-collisions.yaml` + guide + 3 fixtures + Alex step4_5/Blake 1_5a surfacing. 3 real collisions found (Inter font / APCA-vs-WCAG / testing-pyramid). Anti-theater spot-check caught its own CJK-comm false positive. Commits d296374→532b200.

- **EPIC: Lean & Trustworthy TAD** (2026-05-31, 5/5 phases) — trace §11 parser fix · pack registry desync + drift-check (registry 14→16) · progressive disclosure (9 protocols→references, constraint count 131 held) · advisory AC-command linter (surfaced 34 latent ERE-pipe bugs) · pack behavioral eval (discriminative gate). Commits 85fe0a9→8448c7d.

- **Release v2.19.0 + v2.19.1 PUBLISHED + SYNCED to 14 projects** (2026-05-30) — V2 trace hooks (6 emit fns) to all 14; tad.sh --yes flag unblocked non-TTY sync.

- **video-creation Pack ViMax Upgrade** (2026-05-27)
  - 4 ViMax patterns + Photo-to-Beat-Sync integration (309 lines, 77% of 400 cap)
  - Pre/post upgrade behavioral comparison: AI correctly classifies montage intent + applies first/last frame decomposition
  - Research notebook `79b4c4a9` (38 sources: 9 TAD pack + 29 ViMax)
  - Commit 0cc4d8b; Gate 4 PASS with 3 gate4_delta (AC grep-count + verification command bugs caught + Layer 2 reviewer naming drift)

- **v2.15.1 — Capability Pack Auto-Awareness** (2026-05-14)
  - *sync auto-installs 8 packs to 14 downstream projects
  - Alex step4_5 pack scan across all 6 modes
  - Blake 1_5a auto-detection in *develop

- **v2.15.0 — *dream Knowledge Consolidation** (2026-05-14)
  - architecture.md: 1125→262 lines (76% reduction)
  - dream-validator.sh, candidate-only model, --promote/--rollback

- **v2.14.1 — Research Adversarial Challenge** (2026-05-14)
  - 3 challenge points with Codex+Gemini dual-model review

- **v2.14.0 — YOLO Mode + LSP Code Understanding** (2026-05-14)
  - Auto-conductor for Epic execution; 12-language LSP plugin map

- **8 Capability Packs built** (2026-05-07~08)
  - web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology

- **EPIC: Cross-Model Orchestration — ALL 4/4 PHASES** (archived 2026-05-14)

## Recent Decisions
- Self-evolution loops retired by measurement: dream/optimize/evolve yielded 1 accepted from 18 machine proposals (5.6%) while every effective upgrade was human-pain-driven — automated value-DISCOVERY contradicts TAD's own thesis (humans guard value); KA-gate capture (skillify) kept but rebuilt as 3-tier formalization: T1 project-local default / T2 skill-library reference shelf (never distributed) / T3 ≥2-project promotion (2026-06-10)
- Migration schema v1: path safety = allow-list (destructive ops fail-closed) while sync sets stay deny-list — opposite tools for opposite problems. User-modified files: Always Backup before delete (DR-2). deprecation.yaml absorbed by migration manifests, frozen at v2.26.0 (DR-3). Backfill from v2.19.0 (DR-1) (2026-06-09)
- Parallel dual-Alex Epics in one repo: two YOLO Conductors can run concurrently with zero conflict via scoped `git add <explicit paths>` (never `-A`) + file-disjoint work (new-files-only or additive-only); verify no shared-file sweep at every commit. Beats worktree when files don't overlap (2026-05-31)
- Pack conflict resolution: precedence resolves CROSS-category collisions (security>correctness>a11y>performance>style, lower band wins) with a VISIBLE log; SAME-category collisions ESCALATE (no silent pick). Apply the anti-theater hand-re-derivation to the detector's OWN bonus findings — those are the likeliest false positives (2026-05-31)
- Capability Pack Reference Files: Patterns borrowed from external repos must be grounded by NotebookLM source verification (38 sources for ViMax) not WebFetch README skimming — README-only analysis missed 3 of 4 key patterns (2026-05-27)
- (older decisions archived to docs/DECISIONS.md)

## Known Issues
- Agent Teams: Experimental, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
- Security Domain Pack Chain: paused — needs real-project validation
- ~17 active research notebooks (registry; 1 archived, 16 have notebook_id) — run *research-review to consolidate

## Next Direction
- **PUSH decision**: 41 commits ahead of origin (both Alexes' work) — outward-facing, confirm before pushing
- Scout-identified optimization directions (evidence-backed, non-colliding): ~~(B) fix self-evolution loop 0% close-rate~~ → RESOLVED differently 2026-06-10: loops retired by EPIC self-evolution-pruning (measured-yield decision), not fixed; (C) architecture.md leanness — consolidate May surge via Supersedes: pattern (~5-7K tokens/session saved); (D/E/F) safety bundle — Blake distinct-reviewer false-PASS + research-source provenance + trace TRACE_DETAIL truncation bug
- Behavioral eval remaining 13 capability packs (lean-trustworthy P5 follow-up)
- Goal-Driven Research P3 (Research-Decision Loop) + P6.3 *sync (deferred)
- Pack collision follow-up: escalate-form one-liner should also carry loser quote; new packs may add licensing/cost collision categories
