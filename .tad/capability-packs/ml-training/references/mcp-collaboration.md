# MCP Collaboration — Human-AI Colab Workflow

> Judgment rules for browser-automated cloud GPU training via Chrome MCP tools. Covers the handoff protocol between agent (automated steps) and human (auth/security steps).

---

## Workflow Overview

```
Agent Automated              🔄 PAUSE (Human)              Agent Resumes
─────────────────           ──────────────────           ─────────────────
Open Colab URL        →     User logs in Google     →    Upload notebook
                            User authorizes Drive        Execute cells
                                                         Monitor training
                            User confirms download  ←    Download results
```

The agent drives Google Colab through Chrome browser automation, pausing at authentication/security points for the user, then resuming automation for notebook execution and result retrieval.

> Source: Colin声音项目 HANDOFF-20260529-colab-browser.md §4.1

---

## Chrome MCP Tools

| Operation | MCP Tool | Notes |
|-----------|----------|-------|
| Open Colab | `tabs_create_mcp` | Create new browser tab |
| Navigate | `navigate` | Go to URL |
| Read page state | `read_page` / `get_page_text` | Check current page content |
| Click UI elements | `computer` (click) | Buttons, menus, cell run buttons |
| Input text | `form_input` | Text fields, search boxes |
| Find elements | `find` | Locate page elements by text/selector |
| Upload files | `file_upload` | Upload notebooks, data files |
| Execute JS | `javascript_tool` | Check cell execution status |
| Record actions | `gif_creator` | Visual recording of workflow |
| Read console | `read_console_messages` | Check execution logs |

> Source: Colin声音项目 HANDOFF-20260529-colab-browser.md §4.2

---

## PAUSE Protocol

### Triggers — Agent MUST stop and ask user when encountering:

| Trigger | Agent Message |
|---------|--------------|
| Google login page | "🔐 请登录你的 Google 账号。完成后告诉我。" |
| "Authorize Drive access" popup | "🔐 请授权 Colab 访问 Google Drive。完成后告诉我。" |
| CAPTCHA / verification | "🔐 请完成验证码。完成后告诉我。" |
| GPU runtime selection confirmation | "⚙️ 请确认使用 T4 GPU runtime。确认后告诉我。" |
| Any payment/upgrade prompt | "⚠️ 遇到付费提示，请查看并决定。告诉我怎么做。" |
| Training complete, download needed | "📥 训练完成！模型文件在 Drive 里。要我帮你下载吗？" |

> Source: Colin声音项目 HANDOFF-20260529-colab-browser.md §4.3

### Cell Timeout Rule
If no new output after 10 minutes → PAUSE and report "Cell 可能卡住了" to user.

### Page Load Check
After each `navigate`, use `read_page` to verify page loaded successfully. If 503/error/quota page → PAUSE and report.

> Source: Colin声音项目 HANDOFF-20260529-colab-browser.md §6

---

## Security Rules

### During PAUSE — Forbidden Tools ⚠️ CRITICAL

**While user is handling auth (between PAUSE trigger and user saying "完成了"), agent MUST NOT call:**

| Forbidden Tool | Reason |
|---------------|--------|
| `read_page` / `get_page_text` | Login page may contain auth tokens |
| `javascript_tool` | Can read session tokens from DOM |
| `read_console_messages` | May contain OAuth authorization codes |
| `read_network_requests` | May contain Authorization headers |
| `gif_creator` / `upload_image` | May capture password input fields |

> Source: Colin声音项目 HANDOFF-20260529-colab-browser.md §4.3b

### Resume Procedure (after user confirms auth complete)

1. `navigate` to target Colab notebook URL — **leave the auth page first**
2. Wait 3 seconds for page load
3. Only THEN call `read_page` to verify notebook is loaded

**Rationale**: PAUSE prevents agent from typing passwords, but if agent calls `read_page` on the auth page, it may capture access tokens, session cookies, or OAuth codes from the page content. Must navigate away from auth page before reading.

> Source: Colin声音项目 HANDOFF-20260529-colab-browser.md §4.3b

---

## Colab-Specific Automation Notes

### Environment Variable for VoxCPM2
Set `TORCHDYNAMO_DISABLE=1` — `torch.compile` hangs on Colab.

> Source: Colin dogfood 2026-05-29, deep-ask-findings.md

### Training Progress Monitoring
Between each cell execution: read output, check for errors. If error → screenshot + report to user.

### Drive Mounting
If >10,000 items in Drive root, mounting may fail. Use subdirectories (e.g., `colin-voice/`).

> Source: Round 2, deep-ask-findings.md
