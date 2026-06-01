# Phase 2 Grounding — Pack registry desync fix + drift-check

**Conductor read at:** 2026-05-31 (YOLO Y2). Corrects the Epic Detail Block's imprecise framing.

## Actual state (verified firsthand)
- `.tad/capability-packs/` has **15 source packs**, ALL with `CAPABILITY.md` + `install.sh`:
  academic-research, ai-agent-architecture, ai-evaluation, ai-prompt-engineering, ai-tool-integration,
  code-security, **ml-training**, product-thinking, research-methodology, video-creation, web-backend,
  web-deployment, web-frontend, web-testing, web-ui-design.
- `pack-registry.yaml` lists **14** (`grep -c '^  - name:'` = 14), `last_scanned: 2026-05-15`.
- `scan-packs.sh` (`.tad/scripts/scan-packs.sh`) scans `"$PACKS_DIR"/*/CAPABILITY.md` and OVERWRITES the
  registry idempotently. So it indexes ONLY packs that have a `.tad/capability-packs/{name}/CAPABILITY.md`.

## Root causes (two distinct, NOT "phantom + invisible" as the audit guessed)
1. **Registry is STALE.** ml-training (built 2026-05-29) + ai-voice-production (2026-05-28) postdate the
   2026-05-15 scan. ml-training HAS a CAPABILITY.md → a fresh `scan-packs.sh` run indexes it (14→15).
2. **ai-voice-production breaks the source-dir convention.** It has `.claude/skills/ai-voice-production/SKILL.md`
   (Tier 2 loadable) but NO `.tad/capability-packs/ai-voice-production/` source dir → scan-packs structurally
   cannot index it → it is invisible to the registry-keyword matching in Alex step4_5 / step1_5b / Blake 1_5a.
   It is the LONE pack of 16 lacking the source-dir convention.
3. **ml-training is source-only** (CAPABILITY.md present, NO `.claude/skills/ml-training/SKILL.md`). After
   re-scan it enters the registry. step1_5b Tier 1 (CAPABILITY.md exists) can load it — so it is NOT a dead
   "phantom"; it is loadable as Tier 1. But the source/skill asymmetry is worth an advisory flag.

## ai-voice-production SKILL.md frontmatter (for the new CAPABILITY.md)
- name: ai-voice-production
- type: reference-based
- description: "AI voice production judgment for coding agents — TTS tool selection, voice cloning,
  audiobook/podcast/dubbing pipelines, Apple Silicon optimization, licensing safety"
- keywords: ["TTS","text-to-speech","语音合成","voice cloning","声音克隆","voice design","音色设计",
  "audiobook","有声书","podcast","播客","dubbing","配音","narration","旁白","audio production",
  "音频制作","voice acting","语音","朗读","prosody"]

## Fix design (for Y3 to spec, refined by Y4 review)
1. **Make ai-voice-production conform**: create `.tad/capability-packs/ai-voice-production/CAPABILITY.md`
   with frontmatter (name/description/type:reference-based/keywords above) + `**CONSUMES**:` / `**PRODUCES**:`
   lines (so scan-packs' extract_consumes/produces don't emit "Not specified"). Mirror an existing
   reference-based pack's CAPABILITY.md shape (e.g. `.tad/capability-packs/video-creation/CAPABILITY.md`).
   - install.sh for *sync portability: OPTIONAL this phase (mirror video-creation/install.sh). The references
     already live in `.claude/skills/ai-voice-production/references/`. Decide in design: minimal (CAPABILITY.md
     only, enough for registry indexing in THIS project) vs complete (+ install.sh + references move for *sync).
     Recommend minimal + a follow-up note for full source-pack-ification, to keep this phase tight.
2. **Re-run** `bash .tad/scripts/scan-packs.sh` → registry should become 16 packs (adds ai-voice-production +
   ml-training); `last_scanned` auto-bumps to today (script uses `date -u +%Y-%m-%d`).
3. **Drift-check** `.tad/hooks/lib/pack-registry-driftcheck.sh` (advisory, exit 1 on mismatch, NEVER blocks):
   - Set A = registry pack names (`grep '^  - name:'`).
   - Set B = installed capability-pack skills = `.claude/skills/*/SKILL.md` MINUS a framework-skill ALLOWLIST
     (alex, blake, gate, tad, tad-elicit, tad-handoff, tad-help, tad-init, tad-maintain, tad-parallel,
     tad-scenario, tad-status, tad-test-brief, playground, knowledge-audit, capability-upgrade, release-runbook,
     research-github, research-notebook).
   - Set C = source packs = `.tad/capability-packs/*/CAPABILITY.md` dirs.
   - Report: (a) C \ registry = source pack not indexed (should be empty post-scan); (b) B \ registry = installed
     skill not indexed (catches ai-voice-production-style invisibility); (c) registry \ (B ∪ C) = registry entry
     with neither source nor skill (true phantom); (d) advisory: C-without-skill (ml-training) + skill-without-C.
   - exit 0 if (a)(b)(c) empty; exit 1 + names otherwise. (d) is WARN-only, never changes exit.
4. **Wire** drift-check: add to release-runbook pre-flight checklist; optionally a SessionStart advisory line.
   ⚠️ NEVER fail-closed (single-user CLI lesson). Advisory only.

## BSD/portability + anti-self-trigger
- BSD grep/awk only; allowlist as a bracketed word-set or `grep -vxF` against a list.
- The drift-check writes pack NAMES to stdout — fine (not a parser-scanned artifact).
- Re-running scan-packs OVERWRITES pack-registry.yaml — verify the 14 existing entries are byte-stable except
  the 2 additions + last_scanned (idempotency check: run twice, diff = only date).
