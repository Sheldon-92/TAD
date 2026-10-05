# Design: KEEP11 Knife 1 — CLI refresh (`code-security` + `web-deployment`)

**Mode:** Alex `*analyze` → `*design` → `*handoff` · **Status:** READY_FOR_GATE2 (no Blake until human)  
**Channel:** cursor · **Model:** cursor-grok-4.6-medium · **No Gemini**  
**Prior discuss:** `.tad/evidence/designs/2026-09-11-keep-pointer-11-content-refresh.md`  
**Human locks (discuss 5Qs 2,1,2,1,1):** CLI verify + retrieval/`Verified against` date line · sequential knives, no Epic · P0 set = both packs this knife · done bar = dry-run + dated banner · start `*analyze` this dispatch.

`verify:` Gate 3 runs `.tad/evidence/acceptance-tests/keep11-knife1/verify.py` (Alex-owned; not in Blake impl commit).

Pack pointer (max 2, human-named escalate for this knife): `code-security` — wrong CLI is worse than a stale essay. `web-deployment` — example SHAs rot. Do not load other KEEP packs. Frozen 14 stay frozen.

---

## Gate 1 (locked Socratic — not re-asked)

| Item | Record |
|---|---|
| Problem | When a KEEP pack is escalated, documented CLIs / example SHAs can fail closed-wrong (`gitleaks protect/detect`; `actions/checkout@b4ffde65…` no longer the peeled v4.1.7 SHA). |
| User | TAD agents + maintainer who trusts the pointer as “still current.” ICP: TAD-internal (skip re-ask; discuss lock). |
| Scope | Only `code-security` + `web-deployment` skill trees + capability-packs mirrors. |
| Out | Frozen 14, other KEEP 9, loader, experiment-path, push/tag/release, OWASP/platform essay rewrite, discriminative eval re-run, Epic wrapper. |
| AC | Every documented command dry-run or docs-pin; each CLI-bearing file has `Verified against {ver} on {date}`; example SHAs re-resolved. |

**Complexity:** medium · **Depth:** Standard TAD (human asked design + handoff + Gate 2) · **Epic:** no (lock Q2=1).

---

## Architecture (what changes)

```
inventory (documented CLIs) 
  → PATH dry-run (--help/--version) OR official-docs pin if ABSENT
  → edit command strings if subcommands moved
  → HTML banner "Verified against {tool} {ver} on {date}"
  → bump retrieval dates on versioned claims in the same files
  → re-pin web-deployment example SHAs via scripts/find-action-sha.sh
  → copy byte-identical to .agents twins; copy matching files in .tad/capability-packs/
```

**SSOT for skill body:** `.claude/skills/{pack}/` then mirror.  
**SSOT for install source:** `.tad/capability-packs/{pack}/` (CAPABILITY.md + `references/`; no SKILL.md / scripts there today — do not invent them).

Do not run `install.sh`.

---

## Components

1. **Inventory** — Blake lists unique `{tool} {subcommand}` from both pack trees (fenced commands + table cells). Evidence file, not impl commit.
2. **Dry-run** — `{tool} --version` and `{tool} --help` (or documented `-h`) must contain each documented subcommand. Full scans (`nuclei -u`, `semgrep ci` against this repo) are **out** (would be a different knife / live DAST).
3. **ABSENT tools** — this design host: gitleaks/semgrep/nuclei/checkov/trufflehog/osv-scanner/grype/trivy all **ABSENT**; `git` and `gh` present (`gh` here is 2.46.0 Debian, not upstream 2.97). Friction: install if cheap **or** WebSearch official CLI docs (no Gemini) and write `Verified against {ver} on {date} via docs {url}`. Record ABSENT vs CLI in the inventory. Missing PATH is not a skip of the banner.
4. **SHA re-pin** — Alex step1d: `find-action-sha.sh actions/checkout v4.1.7` → `692973e3d937129bcbf40652eb9f2f61becf3332`. Pack still cites `b4ffde65…`. Keep tag **v4.1.7** if it still exists; replace SHA everywhere it is offered as the good pin. Keep `@v4` / `@latest` as the **anti-pattern** in CI2 prose.
5. **CI6** — Quick Rule Index currently says `actions/cache@v4` (teaches a tag pin while CI2 forbids it). Reword to “actions/cache, pin current v4-line SHA” without `@v4` in that row. CI11 may still name major `v4` as the living major vs dead v3.
6. **Example deadline** — `vulnerability-triage-rules.md` table cell `2026-05-20` is a stale calendar example, not a live SLA. Replace with a relative example (`P0: 24h from detect`) or a date ≥ this knife’s verify day.
7. **Parity** — `.claude` ↔ `.agents` `diff -q` on every modified relative path. capability-packs files that exist get the same reference/CAPABILITY edits.
8. **Essay freeze** — do not rewrite OWASP/SSVC/platform-selection theory. Allowed hunks: command lines, version tokens, HTML banners, SHA pins, `retrieved YYYY-MM-DD` on versioned claims, CI6 wording, 2026-05-20 example.

---

## Data flow

Agent escalate → Read SKILL/reference → copy CLI/SHA → must match PATH or dated docs pin.

---

## Decisions (human already locked)

| ID | Decision | Choice |
|---|---|---|
| D1 | Refresh depth | CLI verify + retrieval / Verified-against line |
| D2 | Slice | Sequential knives; this handoff = Knife 1 both P0 packs; no Epic |
| D3 | Done bar | Dry-run + `Verified against {ver} on {date}` |
| D4 | Eval | Do **not** re-run discriminative fixtures (lock Q4=1) |
| D5 | Cross-model | No Gemini. Codex not required. CLI/docs primary. |

Rejected: mass 11-pack rewrite; structural split of web-ui-design (later knife); dump vs pointer (already shipped).

---

## Alex step1d notes (2026-09-11)

- `Verified against` count in the two `.claude` trees: **1** (gitleaks 8.30.1 / 2026-08-16 only).
- Scanner CLIs: all ABSENT on this host.
- checkout v4.1.7 peeled SHA: `692973e3…` ≠ `b4ffde65…`.
- Wiki query: no pack-freshness page (mcp-security false neighbor). Notebooks: 0 active.
