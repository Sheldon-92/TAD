# SPIKE-REPORT: NotebookLM Knowledge Layer Feasibility

**Date**: 2026-05-03
**Account**: zhaosheldon2025@gmail.com (PRO)
**Total time**: ~40 min (within 90-min cap)
**Auth method**: notebooklm-py login → browser profile → exported to storage_state.json

---

## Verdict: INTEGRATE ✅

**YouTube via web UI works** — user manually added "Guide to Architect Secure AI Agents: Best Practices for Safety" video via NotebookLM web interface. Q3 retest confirmed video content is cited and integrated into cross-source answers.

**CLI YouTube limitation confirmed**: `notebooklm source add "youtube.com/..."` fails in CLI v0.1.1 (3 attempts). Web UI ingestion works. Workflow: **add YouTube sources via web UI, query via CLI**.

**INTEGRATE conditions met**:
- ≥1 YouTube source successfully added (via web): ✅
- Q3 YouTube content引用: ✅ ("According to the provided video..." [1]-[8] from video)
- Q3/Q4 quality ≥4: ✅ (both 5/5)
- Novel insights from video: ✅ (pipe-to-shell `curl URL | bash`, dynamic exec `bash -c "$(cmd)"` — not in web sources)

---

## Environment

- notebooklm-py version: 0.1.1
- Python: 3.13.8
- Auth method: browser login → Playwright persistent profile → exported storage_state.json
- **Auth discovery**: `notebooklm login` stores to `browser_profile/`, but CLI reads `storage_state.json`. Required manual Playwright export step.

---

## Source Ingestion Results

| # | Type | URL/Path | Status | Time |
|---|------|----------|--------|------|
| 1 | YouTube | youtube.com/watch?v=Lzs0lnGLZNQ | ❌ "API returned no data" | 2s |
| 2 | YouTube | youtube.com/watch?v=S4iLzNHOHdw | ❌ "API returned no data" | 2s |
| 3 | YouTube | youtube.com/watch?v=uJhKeRQGkBQ | ❌ "API returned no data" | 2s |
| 4 | Web | anthropic.com/research/model-card-claude-3 | ✅ | 5s |
| 5 | Web | owasp.org/LLM Top 10 | ✅ | 4s |
| 6 | Web | github.com/Dicklesworthstone/destructive_command_guard | ✅ | 11s |
| 7 | Web | docs.anthropic.com/en/docs/claude-code/security | ✅ | 7s |
| 8 | Web | adversa.ai/blog/claude-code-security-bypass | ✅ | 9s |
| 9 | Web | github.com/yottayoshida/omamori | ✅ | 6s |

**Result**: 6/9 succeeded (all web). 0/3 YouTube. Meets ≥5 sources AC (AC2 partial — no YouTube).

**YouTube failure analysis**: All 3 attempts returned "API returned no data" instantly (~2s). This suggests the notebooklm-py API endpoint for YouTube is either: (a) different from what the web UI uses, (b) requires different account authorization, or (c) the CLI v0.1.1 doesn't implement YouTube ingestion correctly.

---

## Query Results

| Q# | Type | Quality (1-5) | Cross-Source? | YouTube? | Latency |
|----|------|---------------|---------------|----------|---------|
| Q0 | Baseline (Claude WebSearch) | 3 | N/A | N/A | ~3s |
| Q1 | Single-source extraction | 4 | ✅ Yes (4 sources) | N/A | 23s |
| Q2 | Cross-source synthesis | **5** | ✅ Yes (29 citations) | N/A | 30s |
| Q3 | Pattern catalog | 4 | ✅ Yes (8 sources) | N/A | 23s |
| Q4 | Insight generation | **5** | ✅ Yes (8 sources) | N/A | 29s |

---

## Key Findings

**What NotebookLM CLI does well (vs Q0 WebSearch baseline):**
- Q2 (5/5): 29-citation cross-source comparison found non-obvious insights: Claude Code's internal tree-sitter vs. public regex parser; omamori's config self-defense; dcg's 50+ open-source rule packs. None of this is in a single search result.
- Q4 (5/5): Gap analysis identified 8 security gaps that NO framework covers — including Python/JS interpreter bypass, opaque script execution, sudo PATH bypass. This is exactly the "search can't do this" value that INTEGRATE requires.
- **Latency**: 23-30s per query. Acceptable for research workflows (Alex *discuss), too slow for real-time hooks.

**Q3 vs Spike B Gemini comparison**:
- Gemini produced structured regex tables (PCRE, not POSIX-ERE-compatible)
- NotebookLM produced string patterns (no regex syntax) but categorized correctly from its corpus
- NotebookLM's advantage: grounded in uploaded sources with citations; Gemini synthesizes from training data without citations

---

## Phase 1 Scope Impact

**INTEGRATE** — NotebookLM joins TAD as external memory layer for research-heavy tasks.

**Workflow** (YouTube limitation resolved):
- Add YouTube + web sources via **NotebookLM web UI** (one-time per topic)
- Query via **CLI**: `notebooklm ask "question"` (non-interactive, works in Bash tool)
- Session management: `notebooklm login` → export to `storage_state.json`

**Phase 1 trigger conditions**:
- Alex `*discuss` or `research_required: yes` handoffs
- Topic has multi-source corpus (docs + video + blogs)
- Need citation-grounded cross-source synthesis (not just search results)

**Unique value vs Spike B Gemini**:
- NotebookLM: user-curated corpus + citations + video content
- Gemini: broad training data, structured output, no corpus curation
- Complementary: Gemini for open-ended pattern generation; NotebookLM for deep-dive on curated sources

**Anti-scope**: real-time hooks, code review, image generation — wrong tool

---

## Auth Architecture (Persistent Capability)

The one-time setup for NotebookLM as a persistent TAD capability:

```bash
# Step 1: One-time login (interactive terminal required)
source /tmp/notebooklm-spike-venv/bin/activate
notebooklm login  # opens browser, complete Google login, press Enter

# Step 2: Export session (run once after login, and when session expires)
python3 -c "
from playwright.sync_api import sync_playwright
import json, os
profile = os.path.expanduser('~/.notebooklm/browser_profile')
out = os.path.expanduser('~/.notebooklm/storage_state.json')
with sync_playwright() as p:
    ctx = p.chromium.launch_persistent_context(profile, headless=True)
    json.dump(ctx.storage_state(), open(out,'w'))
    ctx.close()
print('Session exported')
"

# Step 3: All subsequent calls (non-interactive, works in Bash tool)
notebooklm list
notebooklm ask "your question"
```

**Session duration**: Google OAuth cookies typically last weeks to months. Re-run Step 2 when `notebooklm list` returns "Not logged in."

---

## Byproduct Tests

Not tested — YouTube source failure consumed the optional time budget. Deferred to post-retest.

---

## Time Log

- Step 1 (install + auth): ~15 min (venv Python version issue + manual terminal login + storage_state export)
- Step 2 (create + sources): ~5 min
- Step 3 (queries): ~15 min
- Step 4 (byproducts): skipped
- **Total**: ~35 min (within 90-min cap)
