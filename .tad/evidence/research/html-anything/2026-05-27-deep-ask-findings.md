---
notebook_id: d7022a6e-8de5-4e52-8f7c-1518cd4f6d76
topic: html-anything — Agentic HTML Editor Architecture & Patterns
created: 2026-05-27
sources: 19 (README + AGENTS.md + CONTRIBUTING.md + 6 agent files + 6 skill files + 3 API routes + 1 export component)
ask_rounds: 4
---

# Deep Research: html-anything Architecture Analysis

## Round 1: Agent Invocation Pipeline

### Pipeline Flow
```
User ⌘+Enter → POST /api/convert (SSE) → buildArgv(agent) → spawn(bin, argv)
  → stdin.write(prompt) → stdout JSON-line → parseLine() → SSE events → iframe srcdoc
```

### Key Findings
1. **3 invocation protocols**: stdin (Claude/Codex/Cursor/Gemini), argv (DeepSeek positional args), argv-message (OpenClaw --message flag). ACP + pi-rpc detected but not implemented.
2. **Claude Code flags**: `-p --output-format stream-json --verbose --include-partial-messages --permission-mode bypassPermissions`
3. **Codex flags**: `exec --json --skip-git-repo-check --sandbox workspace-write -c sandbox_workspace_write.network_access=true`
4. **HTML Rescue**: `rescueHtmlFromToolUse` intercepts tool_use blocks matching write/create_file — prevents "I have saved the file" rendering in iframe
5. **Dedup flag**: `sawStreamEventText` in ParseState prevents double-rendering when agents emit both streaming deltas AND final assembled message
6. **320ms debounce** on iframe srcdoc update prevents browser freeze during streaming
7. **Abort handling**: AbortController → child.kill("SIGTERM") on frontend request cancel

## Round 2: Skill System & Marketplace

### Skill Architecture
- **Built-in**: `src/lib/templates/skills/` (75 skills, checked into repo)
- **Installed**: `~/.html-anything/skills/` (marketplace, survives git clean)
- **Namespace**: `pkg-<owner>__<repo>--<originalId>` prevents collision
- **SkillMeta type**: frontmatter fields + body (prompt constraints)

### SKILL.md Frontmatter Schema
| Field | Type | Purpose |
|-------|------|---------|
| name | string | Skill ID |
| zh_name / en_name | string | Display names |
| emoji | string | Icon |
| description | string | One-line description |
| category | string | Grouping (article/deck/card/frame/etc.) |
| scenario | string | Use case (marketing/engineering/etc.) |
| aspect_hint | string | Expected output dimensions |
| featured / recommended | number | Ranking in picker |
| tags | string[] | Search keywords |
| example_* | string | Example preview metadata |

### Marketplace Security (3-layer)
1. **Gzip bomb defense**: 32MB compressed / 96MB decompressed hard caps
2. **Tarball preflight**: Parse every 512-byte header, reject symlinks/hardlinks/absolute paths/`..` segments
3. **Atomic swap**: fs.rename for consistent installation state

### Host Guard (DNS rebinding protection)
- `isHostAllowed(req)` on all marketplace API routes
- Prevents malicious websites from querying local server to leak package manifests

## Round 3: Export System

| Target | Technique | Library |
|--------|-----------|---------|
| WeChat | CSS inlining → paste into rich editor | `juice` |
| PNG | DOM→high-DPI 2× PNG blob | `modern-screenshot` |
| HTML download | Self-contained single-file | Native |
| Twitter/X/社交 | PNG to clipboard (ClipboardItem) | `modern-screenshot` |
| Vercel deploy | HTML wrapped in HTML5 envelope → Vercel API | Custom `deployToVercel()` |
| Zhihu | juice CSS inline + LaTeX math | `juice` + custom |
| Markdown export | NOT supported (philosophy: HTML is final form) | — |

### Deploy Flow
1. `ensureFullHtmlDocument(html)` wraps bare markup in HTML5 envelope
2. Validate provider == "vercel" (only provider implemented)
3. `readDeployConfig("vercel")` → retrieve token → `deployToVercel()`

## Round 4: Architecture Decisions & Limitations

### Philosophy: "HTML is final form"
- Markdown = input format, never output format
- Unidirectional: (Markdown/CSV/JSON) → AI agent → HTML → platform export
- No Markdown export button exists by design

### Zero API Key Model
- Spawn local CLI binaries via child_process → inherit terminal auth
- PATH scanning includes non-obvious dirs (~/.local/bin, ~/.npm-global/bin, Scoop paths, Volta, asdf, Cargo, pnpm)
- Each agent's existing `login` command provides credentials

### Security Model (3 layers compose)
1. **Iframe sandbox** (allow-scripts + allow-same-origin) — AI output quarantined from host app
2. **Host guard** — DNS rebinding protection on local API routes
3. **Tarball preflight** — supply chain attack prevention for marketplace skills

### Scalability Design (75 → 500+ skills)
- Frontmatter-only metadata cache (heavy body excluded from picker payload)
- Two-axis grouping: mode × scenario
- External namespace for marketplace skills

### Limitations / Weak Points
1. **Parser fragility**: stateful parsers per agent CLI — any upstream JSON schema change breaks output
2. **Token limits on diff-edit**: injects full old HTML + old content + new content into prompt → blows context window on large documents
3. **Memory-bound tarball extraction**: Buffer.from(await res.arrayBuffer()) — 32MB cap will fail on heavy skill packs
4. **Iframe refresh stutter**: 320ms debounce mitigates but doesn't solve heavy asset reload
5. **Cross-platform spawn quirks**: Windows requires shell:true → shell injection surface

## Comparison with TAD Capability Pack Architecture

| Dimension | html-anything SKILL.md | TAD Capability Pack SKILL.md |
|-----------|----------------------|------------------------------|
| Frontmatter | Rich (13+ fields: emoji, category, scenario, aspect_hint, featured, tags, example_*) | Minimal (2 fields: name, description + optional keywords, version, type) |
| Body | Visual layout constraints (fonts, spacing, colors) | Judgment rules (decision trees, anti-patterns, cross-references) |
| Example | `example.html` as ground truth output | No example output — rules describe what to produce |
| Distribution | GitHub tarball → ~/.html-anything/skills/ | install.sh → .claude/skills/ |
| Security | Tarball preflight + host guard + iframe sandbox | Permission-level trust (no sandbox) |
| Grouping | category × scenario (2D grid) | Single keyword list + pack-registry.yaml |
| Scale mechanism | Metadata cache + two-axis filter | Max 2 packs per session (context budget) |

### What TAD Can Learn
1. **Example as acceptance**: html-anything's `example.html` is a concrete acceptance criterion. TAD packs lack this — rules describe behavior but don't show expected output.
2. **Rich frontmatter for discovery**: 13-field schema enables filtering, ranking, and visual browsing. TAD's 2-field frontmatter only enables name lookup.
3. **Marketplace model**: GitHub-based skill distribution with security preflight. TAD's pack distribution is manual (install.sh).
4. **Metadata/body separation**: Only load frontmatter for browsing, load body on-demand. TAD loads entire SKILL.md every time.

### What html-anything Can Learn from TAD
1. **Cross-reference graph**: TAD skills reference each other (CONSUMES/PRODUCES chain). html-anything skills are isolated.
2. **Quality gates**: TAD has 4-gate quality process. html-anything has no quality verification beyond example visual match.
3. **Expert review on skill changes**: TAD requires ≥2 expert reviews before any pack modification. html-anything skills are added without review.
4. **Anti-slop metrics**: TAD has explicit anti-AI-slop rules (specific numbers > generic advice). html-anything skills don't have this meta-quality layer.
