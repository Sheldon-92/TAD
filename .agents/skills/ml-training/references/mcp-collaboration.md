# Human-AI Collaboration via Browser MCP

> Loaded on signal: browser automation, MCP, Colab操作, 人机协作.
> Drives Colab/Kaggle through the Chrome MCP extension while keeping the human in the loop for auth.

---

## PAUSE Protocol (the load-bearing safety rule)

The agent drives the browser to set up a notebook run, but MUST hand control back to the
human at sensitive boundaries.

**PAUSE triggers** — the agent MUST stop and ask the human to act:
- Any **login / OAuth / 2FA / CAPTCHA** screen.
- **Payment / billing** confirmation (RunPod credit, Colab Pro upgrade).
- **Google account chooser** / consent screens.

**Forbidden tools DURING a PAUSE** (do not read or scrape an auth page):
- No `get_page_text` / `read_page` on a login or payment page (would capture credentials).
- No `form_input` typing into password fields.
- No screenshot of an auth screen.

**Resume procedure**:
1. Human completes auth/payment manually.
2. Human says "done" / "continue".
3. Agent **navigates away** from the auth URL FIRST, confirms it's on the notebook page,
   THEN resumes reading/acting.

---

## Chrome MCP Tool Map (Colab automation)

| Task | Tool |
|---|---|
| Open / switch tabs | `tabs_create_mcp`, `tabs_context_mcp` |
| Go to a notebook URL | `navigate` |
| Click "Run all" / cells | `computer` |
| Read cell output (non-auth pages only) | `read_page`, `get_page_text` |
| Fill a non-secret form field | `form_input` |
| Check errors | `read_console_messages` |
| Confirm uploads | `file_upload` |

Load these via ToolSearch `select:...` before use (they are deferred tools).

---

## Security Rules

1. **Never read auth pages** — credentials must never enter the agent's context.
2. **Navigate away before resuming** — confirm the URL is the notebook, not the consent
   screen, before any read.
3. **No secrets on untrusted hosts** — never paste API keys into a Vast.ai pod
   (see `platform-selection.md` §Hidden Limitations gotcha 4).
4. **Checkpoint awareness** — Colab can disconnect mid-run (12-hr cap, idle timeout);
   instruct the notebook to save checkpoints to Drive so a disconnect is recoverable.

---

## Cross-references
- Colab/Kaggle quotas that force checkpointing → `platform-selection.md`
- What to train once the notebook is up → `lora-finetune.md`
