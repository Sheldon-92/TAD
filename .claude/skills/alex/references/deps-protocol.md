# Dependency Registry Protocols

> Progressive-loaded reference for *deps, *deps init, *deps add commands.
> Loaded when: Alex receives a *deps* command or user asks about dependency tracking.

## deps_show_protocol

Display the project's dependency registry in a readable table.

### Steps
1. Read `.tad/dependencies/REGISTRY.yaml`
   - If not found: suggest running `*deps init` to create one
2. Format as table:
   ```
   📦 Dependency Registry ({N} dependencies)

   | Name | Type | Version | Safety | Last Checked | Limitations |
   |------|------|---------|--------|-------------|-------------|
   | {name} | {type} | {current_version} | {safety_tier} ({days}d) | {last_checked} | {count} known |
   ```
   Safety tier days: L1=7d, L2=14d, L3=30d
3. If any dependency has `last_checked` older than its safety tier window:
   Flag with warning: "⚠️ {name} last checked {date} — overdue by {N} days"

## deps_init_protocol

Semi-automatic initialization of the dependency registry from project files.

### Steps
1. **Scan project files** for dependency declarations:
   - `package.json` → dependencies + devDependencies
   - `requirements.txt` / `pyproject.toml` → Python packages
   - `.env.example` → API service references
   - `docker-compose.yml` → service images
   - `Brewfile` / shell scripts → CLI tools

2. **Filter to key dependencies** (LLM judgment):
   - INCLUDE: platforms, frameworks, APIs, major tools
   - INCLUDE: any package critical to the project's core function
   - EXCLUDE: utility packages (lodash, uuid, chalk, etc.)
   - EXCLUDE: dev-only tools unless they're frameworks (exclude prettier, include vitest)
   - When in doubt: include and let user remove during confirmation

3. **Present candidate list** via AskUserQuestion:
   ```
   question: "Found {N} key dependencies. Confirm which to register:"
   options: multiSelect with each dependency as an option
   ```

4. **Per-dependency enrichment** (for each confirmed dependency):
   Use AskUserQuestion for type and safety_tier with sensible defaults:
   - Default type: detect from context (npm package → library/framework, CLI → tool, etc.)
   - Default safety_tier: platform→L2, framework→L3, api→L1, tool→L1, library→L3

   Then ask for enrichment (can be conversational, not all via AskUserQuestion):
   - `capabilities_used`: "What specific capabilities/APIs do you use from {name}?"
   - `known_limitations`: "Any workarounds you maintain for {name}?"
   - `upstream.repo`: auto-detect from npm/pypi registry if possible

5. **Write REGISTRY.yaml**:
   - Copy template from `.tad/templates/deps-registry-template.yaml`
   - Populate with enriched entries
   - Set `last_updated` and `last_checked` to today
   - Set `version_pinned_at` to today (first registration)

### Constraints
- Interactive flow should complete in ≤5 minutes for 10 dependencies
- REGISTRY.yaml must be valid YAML (parseable by yq)
- Each entry must have ≥1 capabilities_used and ≥1 files_depending

## deps_add_protocol

Manually register a single new dependency to an existing registry.

### Steps
1. **Check registry exists**: Read `.tad/dependencies/REGISTRY.yaml`
   - If not found: suggest `*deps init` first

2. **Ask for name** via AskUserQuestion or conversation

3. **Auto-detect** from project files:
   - Search package.json, requirements.txt, etc. for the named dependency
   - If found: pre-fill version, suggest type
   - If not found: ask for version and type manually

4. **Enrichment flow** (same as deps_init per-dependency):
   - type + safety_tier (with defaults)
   - capabilities_used
   - known_limitations
   - upstream.repo

5. **Append to REGISTRY.yaml**:
   - Add new entry to the dependencies array
   - Update `last_updated` to today
   - Validate the full file is still valid YAML

### Constraints
- Must not overwrite existing entries with the same name
- If dependency already exists: ask user if they want to update instead
