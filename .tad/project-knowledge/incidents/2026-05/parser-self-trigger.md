# Parser Self-Trigger: Evidence Prose Documenting a Finding-Label Regex

**Date:** 2026-05-30
**Linked to:** L2 memory-and-learning "Observational > Imperative Trace Emission"

---

### Parser Self-Trigger: Evidence Prose Documenting a Finding-Label Regex Inflates Its Own Telemetry - 2026-05-30
- **Context**: trace-instrumentation-fix dogfood. The new expert_review_finding parser counts lines matching `^#+ *P0` or `| P0 |` in review files. Blake's own code-reviewer.md (which had ZERO real P0s) DOCUMENTED the parser by quoting the pipe-P-zero pattern in prose → the parser counted it → emitted a FALSE "1 P0 finding" event into the real trace. The same mechanism inflated P2 counts (section header + per-finding headings + a quoted verdict cell all counted).
- **Discovery**: This is the "AC Self-Leak from Removal Rationale" pattern (2026-04-27) recurring in the trace-emission domain: any artifact whose PROSE describes the very pattern a parser matches will self-trigger that parser. For label-counting parsers this is qualitatively worse than mere inflation when it fabricates a priority class that never existed (a false P0 misleads *evolve step9 P0-density). expert_review_finding has NO dedup (per FR3 spec), so re-writing the file to fix wording emits MORE events, not fewer — the first inflated emit is unrecoverable from append-only trace evidence.
- **Action**: (1) When writing evidence/review files a parser will scan, do NOT quote the parser's literal label patterns in prose — paraphrase (e.g. "a P-zero table cell") instead. (2) Consider tightening expert_finding counting to heading-form-only labels (`^#+ *P<n>-[0-9]`) to ignore prose mentions and verdict cells — tracked as a follow-up (out of this handoff's FR3 scope). (3) General rule: a parser and the documentation OF that parser must not share a namespace in artifacts the parser reads.
- **Grounded in**: .tad/evidence/traces/2026-05-30.jsonl (expert_review_finding events for trace-instrumentation-fix), code-reviewer P2-2
