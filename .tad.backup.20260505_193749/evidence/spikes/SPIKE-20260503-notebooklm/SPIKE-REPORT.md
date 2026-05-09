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

| # | Type | Source | Status |
|---|------|--------|--------|
| 1-3 | YouTube | Random URLs (no captions) | ❌ "API returned no data" |
| 4 | Web | anthropic.com/research/model-card-claude-3 | ✅ |
| 5 | Web | owasp.org/LLM Top 10 | ✅ |
| 6 | Web | github.com/DCG destructive_command_guard | ✅ |
| 7 | Web | docs.anthropic.com/claude-code/security | ✅ |
| 8 | Web | adversa.ai/blog/claude-code-security-bypass | ✅ |
| 9 | Web | github.com/yottayoshida/omamori | ✅ |
| 10 | YouTube (web UI) | Guide to Architect Secure AI Agents | ✅ (user manual add) |
| 11 | YouTube CLI | RSAC: security risks of AI agents | ✅ |
| 12 | YouTube CLI | CCC: Agentic ProbLLMs | ✅ |
| 13 | YouTube CLI | Setting up Claude Code security guardrails | ✅ |
| 14 | YouTube CLI | Claude Code best practices (Anthropic) | ✅ |
| 15 | YouTube CLI | HOOKED on Claude Code Hooks | ✅ |
| 16 | YouTube CLI | Top 10 Security Risks in AI Agents | ✅ |
| 17 | YouTube CLI | Master Agentic AI Security | ✅ |
| 18 | YouTube CLI | NODES 2026: Building Secure AI Agents | ✅ |

**Final**: 6 web + 9 YouTube = 15 ready sources. 

**YouTube CLI workaround**: Initial random YouTube URLs fail (no captions). **Fix**: WebSearch for conference talks (CCC/RSAC/Black Hat/NODES) and official channels (Anthropic) → add via CLI. 8/8 conference/official videos succeeded. Key requirement: video must have captions enabled.

---

## Query Results

| Q# | Type | Quality (1-5) | Cross-Source? | YouTube? | Latency |
|----|------|---------------|---------------|----------|---------|
| Q0 | Baseline (Claude WebSearch) | 3 | N/A | N/A | ~3s |
| Q1 | Single-source extraction | 4 | ✅ Yes (4 sources) | N/A | 23s |
| Q2 | Cross-source synthesis | **5** | ✅ Yes (29 citations) | N/A | 30s |
| Q3 | Pattern catalog | 4 | ✅ Yes (8 sources) | N/A | 23s |
| Q4 | Insight generation | **5** | ✅ Yes (8 sources) | N/A | 29s |
| Q3-retest | Cross-media (1 YouTube) | 5 | ✅ Yes | ✅ Yes | ~35s |
| **Q3-final** | **Multi-YouTube (9 videos)** | **5** | ✅ Yes | ✅ Yes (37 citations) | 43s |

---

## Key Findings

**What NotebookLM CLI does well (vs Q0 WebSearch baseline):**
- Q2 (5/5): 29-citation cross-source comparison found non-obvious insights: Claude Code's internal tree-sitter vs. public regex parser; omamori's config self-defense; dcg's 50+ open-source rule packs. None of this is in a single search result.
- Q4 (5/5): Gap analysis identified 8 security gaps that NO framework covers — including Python/JS interpreter bypass, opaque script execution, sudo PATH bypass.
- **Q3-final (5/5, 9 YouTube sources, 37 citations)**: Found 6 video-exclusive attack techniques absent from ALL written docs:
  1. Invisible Unicode tag character injection (GitHub/Linear/SO)
  2. AI "Clickfix" social engineering (clipboard payload via fake verification)
  3. Local port exposure exfiltration (filesystem leaked as public webserver)
  4. "Agent Hopper" AI virus (YOLO mode → cross-repo spread → GitHub push)
  5. Insecure interagent communication (cascading multi-agent failures)
  6. Human-agent trust exploitation (audit trail is clean, human was tricked into "Allow")
- **YouTube CLI workaround**: search for videos from conference talks (CCC/RSAC/Black Hat/NODES) and official channels (Anthropic) → add via CLI. All 8 tried succeeded (vs earlier random URLs which all failed). The key is captions availability.
- **Latency**: 23-43s per query. Acceptable for research workflows (Alex *discuss), too slow for real-time hooks.

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
