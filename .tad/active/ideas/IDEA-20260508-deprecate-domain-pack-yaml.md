# Idea: Deprecate Domain Pack YAML Format

**Date:** 2026-05-08
**Status:** captured
**Scope:** large
**Source:** *discuss session — video-creation AI asset generation research

---

## Summary & Problem

Domain Pack YAML (.tad/domains/*.yaml) is a transitional format that has been superseded by Capability Pack (SKILL.md + references/*.md). The YAML format is too shallow to be a Capability Pack and too heavy to be a prompt hint. 20 Domain Packs exist, 8 have been rebuilt as Capability Packs. The remaining 12 are mostly unused or only superficially referenced by agents.

The insight: Capability Packs built with research-methodology pack produce higher-quality judgment rules than YAML quality_criteria ever did. The research→pack pipeline (Plan→Source→Curate→Analyze→Output→references/*.md) replaces the YAML's role entirely.

## Rationale

- Domain Pack YAML = "food ingredient list" (informational)
- Capability Pack SKILL.md = "recipe" (action-ready)
- Agents follow recipes, not ingredient lists
- research-methodology pack is the factory that produces recipes on demand

## Open Questions

- Deprecation strategy: delete all YAML? archive? keep as seed material?
- What happens to keywords.yaml hook routing? Capability Packs have their own trigger keywords in SKILL.md frontmatter.
- What about the 4 existing domain-pack-related ideas (IDEA-20260401-domain-pack-framework, IDEA-20260402-domain-pack-monthly-refresh, IDEA-20260402-self-evolving-domain-pack, IDEA-20260427-domain-pack-taxonomy-reorg)? All become obsolete if Domain Pack format is deprecated.
- Should the 12 un-rebuilt packs be rebuilt as Capability Packs, or just deleted (rebuild on-demand when a real project needs them)?

## Promoted To

(not yet promoted)
