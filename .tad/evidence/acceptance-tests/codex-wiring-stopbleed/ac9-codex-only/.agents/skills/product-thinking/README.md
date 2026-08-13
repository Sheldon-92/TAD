# Product Thinking

Three deep skills that turn any AI agent into a product decision partner. Not templates. Not a PM toolkit. A thinking engine that searches real data, challenges assumptions, and forces decisions.

---

## The Three Skills

```
/pressure-test → /shotgun → /define
```

### `/pressure-test`
Adversarial idea diagnosis. 6 forcing rounds with real data search. Default stance: this probably won't work. You must prove otherwise with evidence.

Produces: BUILD / PIVOT / KILL verdict with confidence score, fatal flaws, and 2-week validation plan.

### `/shotgun`
Generate 4-6 fundamentally different business model variants. Not UI variants — business model variants. Anti-convergence enforced: no two variants may share revenue model + customer segment + distribution channel.

Produces: Side-by-side comparison with 4-perspective review (EXPAND / SELECTIVE / HOLD / REDUCE) per variant.

### `/define`
Turn your selected variant into an executable definition. 80% auto-filled from /pressure-test and /shotgun data. Type-specific output for all 6 product types.

Produces: Tech handoff (software), product listing + supplier plan (ecommerce), BOM + crowdfunding brief (hardware), service package + client plan (service), content calendar (content), supply/demand strategy (marketplace).

---

## What Makes This Different

| Other PM tools | Product Thinking |
|---------------|-----------------|
| Fill-in-the-blank templates | AI searches real data for you |
| Supportive coaching | Adversarial by default ("prove it") |
| Software-only | 6 product types: software, hardware, ecommerce, service, content, marketplace |
| Documents | Decisions |
| Best practices | Forcing questions + evidence |

---

## Installation

### Claude Code

```bash
git clone https://github.com/your-username/product-thinking.git
cd product-thinking
bash install.sh
```

The installer copies the skills to `.claude/skills/product-thinking/`.

**Options:**
```bash
bash install.sh --dry-run    # See what will be installed without doing it
bash install.sh --force      # Overwrite existing installation
bash install.sh --global     # Install to ~/.claude/skills/ (available in all projects)
```

---

## Product Types Supported

| Type | Primary Data Sources | MVP |
|------|---------------------|-----|
| Software | Reddit/HN/GitHub (last30days), App Store (aso-skills), Product Hunt | 2-week deployable |
| Hardware | Kickstarter, YouTube, WebSearch | 3D print + crowdfund page |
| Ecommerce | Amazon BSR/Keepa, Alibaba, reviews | 10-unit test sell |
| Service | Upwork/LinkedIn, WebSearch | 5 manual clients |
| Content | YouTube/TikTok (last30days), newsletters | 10 posts for engagement |
| Marketplace | Reddit, competitor analysis, manual transaction | One side first (Airtable) |

---

## Skills Degrade Gracefully

Every search step has a WebSearch fallback. You don't need any API keys to get value — specialized tools (aso-skills, Keepa, Amazon SP-API) enhance the analysis when available but are not required.

See `tools/tool-registry.md` for the full availability matrix.

---

## Session Persistence

Skills share data through `~/.product-thinking/session.json`. Run /pressure-test first, then /shotgun reads its verdict automatically, then /define pre-fills 80% of the output from both.

Each skill also works standalone — if no session exists, it collects context manually.

---

## What This Is Not

- Not a project management tool
- Not a requirements document generator
- Not an investor deck builder
- Not a "best practices" guide

This is a thinking partner that assumes you might be wrong and forces you to prove otherwise.

---

## License

MIT — use freely, attribution appreciated.

Attribution required for derived works from:
- GStack skills (Apache 2.0) — see `LICENSE-ATTRIBUTION.md`
- pm-skills (Apache 2.0) — see `LICENSE-ATTRIBUTION.md`
