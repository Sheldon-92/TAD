# Layer 2 Expert Review: code-reviewer
# Handoff: HANDOFF-20260503-cross-model-phase1-protocol
# Round: 1
# Verdict: FAIL — P0=2, P1=3, P2=4

## Overall: FAIL (P0 must fix before Gate 3)

## P0 Issues

### P0-1: research_depth/time_budget indentation drift under step2_5_notebook_check
Location: .claude/skills/alex/SKILL.md lines ~1526-1532
Problem: step2_5_notebook_check insertion causes research_depth/time_budget to be re-parented
Fix: Promote research_depth/time_budget to 2-space indent as siblings of step2_research

### P0-2: preflight `which notebooklm` fails on non-activated venv
Location: .claude/skills/research-notebook/SKILL.md preflight section
Problem: notebooklm binary is in venv (~/.tad-notebooklm-venv/bin/), not on PATH by default
Fix: Use absolute path ~/.tad-notebooklm-venv/bin/notebooklm in all invocations

## P1 Issues

### P1-1: No Python 3.10+ check in setup-notebooklm.sh
### P1-2: No post-export verification of storage_state.json
### P1-3: Placeholder URLs youtube_source_1/2/3 in REGISTRY.yaml

## P2 Issues (defer)
### P2-1: gemini_research has both verified:true and status:DEFER
### P2-2: code_review fallback chain has no secondary
### P2-3: Orphan names in fallback_chains (claude_websearch etc.) need comment
### P2-4: ShellCheck SC1091 on source

## AC Verification: All 10 PASS (literal)
