# DRYRUN — stale absorb index / pointer inventory

Task: TASK-20261001-TAD-HYGIENE-FORGET-INDEX-DRYRUN-P0
role: Alex (Solution Lead)
mode: discuss / inventory only
candidate_count: 3 (distinct files; only the named stale clauses)

| path | kind (index/pointer/stamp/seg/ops note) | why stale | proposed action (forget pointer / archive note / leave) | risk if wrong |
|---|---|---|---|---|
| `docs/pm/segment-status/seg-20261001-mech-absorb-scan.md:5`–`:6` | seg | Current-facing index says absorb gaps remain open and MECH-DOCS-ABSORB is still only a candidate, unimplemented. The later absorb STATUS records six FILTER yes rows absorbed and PASS; its matching segment is closed. | forget pointer — recommendation only: retire the present-tense “仍只是候选建议，未实施” clause; qualify the gap statement as the scan-time result and point to the completed absorb STATUS. Preserve CONDITIONAL as this scan's historical verdict, its evidence link and done state. | Treating six absorbed yes rows as closure of every gap would erase defer/hand-GM work. Do not promote the historical scan verdict or claim all TAD mechanisms closed. |
| `docs/pm/segment-status/seg-20261001-mech-notes-portfolio-scan.md:6`–`:7` | seg | Duplicates MECH-DOCS-ABSORB as the next candidate “未授权实施” despite its later named execution and PASS. FILTER's recommendation remains valid history, but the segment gives no successor-completion qualification. | forget pointer — recommendation only: retire the live-next/unauthorized framing and link to the completed absorb STATUS and its reasoned HOLD; retain FILTER/RECOMMEND as scan-time evidence. | Rewriting FILTER or RECOMMEND would alter original recommendation/provenance; carrying the old candidate forward could dispatch the same completed knife again. |
| `docs/pm/segment-status/seg-20261001-tad-hygiene-skill-p0.md:7` | seg | Repeats MECH-DOCS-ABSORB as a candidate requiring separate naming after the successor has completed. Line 6's “未实施吸收候选” can truthfully describe what the hygiene knife itself did; that historical boundary is not a forget target. | forget pointer — recommendation only: retire the obsolete next-candidate framing or mark it explicitly as the historical recommendation, pointing to successor PASS/HOLD. Keep the hygiene PASS, drafts and scope boundary. | Removing the historical non-implementation boundary could imply hygiene performed absorb; deleting the entire segment would lose traceability. |

“forget pointer” here proposes only retiring stale current-facing wording in a separately authorized knife. It does not mean deleting a file, moving evidence, removing original evidence links, or executing any forget now. No archive-note candidate was found.

## Checked and left

- `docs/pm/now.md` and this dry-run's segment are correctly in-flight before PM closeout; not stale candidates. The completed absorb segment is correctly closed with HOLD.
- Full `docs/pm/` filename/text scan found no absorb-related `gm-copy` / voided-copy reference, no PM reference to `.tad/archive/handoffs/`, and no closed absorb knife labeled 在途. Open-run cards, restates and stamps retain historical start-time statements; they are not current dispatch instructions.
- No absorb evidence INDEX exists on the enumerated `docs/pm/` and `.tad/evidence/pm/` surfaces. The three `last-*.POINTER.md` files are runtime snapshots; their quoted prompts/tails are not active absorb recommendations. Leave all three.
- `docs/pm/ops-knowledge.md` has no stale absorb pointer. `docs/pm/status.md` has older unrelated framework summaries, outside this absorb inventory.
- `NEXT.md` absorb hits concern earlier version/release scope boundaries, not Oct-1 mech absorb in flight. No NEXT candidate; no NEXT rewrite.
- Oct-1 STATUS/GAPS/FILTER/RECOMMEND and other evidence are retained as dated records even where they reflect pre-absorb findings. They are not candidates merely because the successor completed.

Verification method: local filename enumeration and `rg` text scans, then direct comparison of the five segment files and required PM documents with hygiene/absorb STATUS and the dated scan recommendations. Conclusions are limited to local disk; no private-brain, chat, external runtime or deleted-file reconstruction claim.
