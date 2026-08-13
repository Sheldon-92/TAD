# SkillOpt-Sleep Integration (SI1–SI3)

> Practical guide to integrating SkillOpt's sleep cycle into Claude Code, Codex, and other agent platforms.

---

### SI1: Claude Code Plugin — Install, Configure, Run

SkillOpt-Sleep integrates with Claude Code as a plugin. Setup:

**1. Install the plugin**:
```bash
pip install skillopt  # or: pip install -e /path/to/SkillOpt (from source)
# In Claude Code:
/plugin marketplace add skillopt-sleep
```

**2. Configure the sleep cycle** (`sleep-config.yaml`):
```yaml
# Minimal viable config
skill_path: ".claude/skills/my-agent/SKILL.md"      # the skill to evolve
training_set: ".claude/skills/my-agent/examples/"    # training tasks
held_out_set: ".claude/skills/my-agent/validation/"  # validation tasks (NEVER used for training)
gate_metric: "mixed"                                  # VG2: mixed is most stable
num_epochs: 3                                         # ES2: 2-4 epochs sufficient
lr_scheduler: "cosine"                                # ES2: cosine > constant
recall_k: 10                                          # OC4: recall 10 most-similar past tasks
dream_factor: 0                                       # OC5: start without dreaming
staging_dir: ".claude/skills/my-agent/.staging/"       # OC6: nothing live changes
```

**3. Schedule the sleep cycle** (cron):
```bash
bash scripts/install-cron.sh  # SkillOpt-Sleep ships this
# Default schedule: 3:17 AM daily (off-peak, avoids midnight cron pile-up)
# Equivalent crontab entry: 17 3 * * * cd /path/to/project && python -m skillopt_sleep run
```

**4. Mock backend for testing**: Before using a real LLM backend, test with the mock backend (zero API cost):
```bash
python -m skillopt_sleep run --backend mock
# Mock backend returns deterministic responses — useful for verifying the pipeline plumbing.
# Expected: exit code 0 (success), staging/ contains candidate skill.
```

> Source: SkillOpt-Sleep `plugins/claude_code/`, `scripts/install-cron.sh`, `backend.py` `MockBackend`.

---

### SI2: Cross-Platform Plugin Shells — One Engine, Thin Adapters

SkillOpt-Sleep uses a single optimization engine (`skillopt_sleep/cycle.py`) with thin platform-specific adapter shells:

| Platform | Adapter | What it does |
|----------|---------|-------------|
| Claude Code | `plugins/claude_code/` | Reads `.claude/` skill paths, wraps `claude` CLI for rollouts |
| Codex (OpenAI) | `plugins/codex/` | Reads `.agents/skills/` paths, wraps `codex exec` for rollouts |
| Copilot | `plugins/copilot/` | Reads `.github/copilot-instructions.md`, wraps Copilot CLI |
| OpenClaw | `plugins/openclaw/` | Reads agent configs, wraps the OpenClaw harness |

**Architecture principle**: The engine (`run_sleep_cycle`) is platform-agnostic. The adapter provides: (a) where to find the skill file, (b) how to run a rollout, (c) where to write staging output. Nothing else — the training loop, gate, and consolidation logic are shared.

**When building a new adapter**: Implement the `Backend` interface from `backend.py` (~3 methods: `mine_tasks`, `run_rollout`, `run_reflection`). The rest of the pipeline is inherited.

> Source: SkillOpt-Sleep `plugins/` directory; `backend.py` abstract `Backend` class.

---

### SI3: Safety Contract — Harvest Read-Only, Nothing Live, Staging + Adopt

The integration's safety contract across all platforms:

1. **Harvest is read-only** (OC2): The sleep cycle reads transcripts/logs but never writes to them.
2. **Nothing live changes during the cycle** (OC6): The cycle writes candidate skills to `staging/` only. The live skill file is untouched until the user runs `adopt`.
3. **Human adopts explicitly**: The `adopt` step is a separate CLI command (`python -m skillopt_sleep adopt`). It diffs staging vs current, shows the changes, and requires confirmation.
4. **Backup before adopt**: The current live skill is backed up to `.prev.md` before the staged version replaces it. Rollback is `cp .prev.md SKILL.md`.

**What can go wrong if you skip this**:
- No read-only harvest: The cycle accidentally truncates a transcript file mid-read (OS-level file descriptor issue) — all future harvests lose that day's data.
- No staging: A bad skill edit goes live immediately. If the gate had a false positive (held-out set didn't cover the regression), users see degraded behavior before anyone notices.
- No human adopt: The cycle runs at 3 AM, promotes a skill that passes the gate but reads poorly to humans (technically correct but confusingly worded). Morning users are confused.

> Source: SkillOpt-Sleep `cycle.py` (harvest + staging); `docs/sleep/ARCHITECTURE.md` (safety contract).
