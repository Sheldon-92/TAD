# End-to-End Validation: Distillation Loop First Live Run

**Date**: 2026-06-22
**Epic**: EPIC-20260622-knowledge-recording-redesign (Phase 4)

---

### 1. Journal (Blake raw)

Source: `evidence/journal/knowledge-redesign-p4-2026-06-22.md`

Key passage for distillation (the meta-learning, paragraph 5):
> "The biggest meta-learning from the whole Epic: the distillation loop's value isn't
> the typed entry format — it's the `failure_mode` field specifically. When I was
> batch-adding failure_mode to 110 entries, about 70% of the time I could infer the
> naive default from the Discovery/Action text. But for the remaining ~30%, the entry
> just said 'do X' without explaining what a person would do WITHOUT this knowledge.
> Those are the entries where the distillation gap-handback would have caught the
> missing information at creation time instead of leaving it for a P4 bulk migration
> to mark as UNRESOLVABLE."

### 2. Distill attempt (Alex as stranger)

Typed entry draft — `failure_mode` field could NOT be filled:

```yaml
label: failure-mode-inferability-ratio
selector: >
  Triggers when: migrating legacy entries to add failure_mode; evaluating schema universality.
  Near-miss: NOT for new creation (distillation loop handles that).
value: >
  ~70% inferable from text, ~30% need doer context. [char budget: 500]
failure_mode: ??? — CANNOT FILL FROM JOURNAL
validator: >
  After migration, count UNRESOLVABLE entries. If >30%, texts too sparse.
read_only: false
```

**Gap identified**: `failure_mode` field. Journal describes the 70/30 observation but does
NOT state what a naive person would do WRONG without this knowledge.

### 3. Gap questions

🔍 Blake 需要回答:

1. **[failure_mode]** — 如果一个人不知道 70/30 规律,在 batch migration 时会犯什么
   具体错误?会假设 100% 都能填?会跳过困难的?会硬凑?

### 4. Blake answers

Blake (via human bridge):
> naive 默认是假设 100% 都能从原文推断——遇到填不出的就硬凑一个模糊的 failure_mode
> (比如"不这样做会出问题"),因为觉得留 UNRESOLVABLE 是承认失败。为什么错:硬凑的
> failure_mode 比 UNRESOLVABLE 更危险——它看起来填满了(lint 通过、schema 满足),但
> 内容是编造的,未来读者会信以为真按错误的 naive default 去防御,等于把知识诅咒从
> "省略"变成了"误导"。UNRESOLVABLE 至少诚实标记了缺口,留给有执行上下文的人来补。

### 5. Finalized entry

Written to `patterns/memory-and-learning.md`:

```
### Batch Migration failure_mode Inferability: ~70% Text-Inferable, ~30% Need Doer Context — 2026-06-22
- **Discovery**: ~70% of 110 legacy entries had enough text to infer failure_mode;
  ~30% needed doer context (curse of knowledge at write-time).
- **Action**: Budget for ~30% needing gap-handback. Do not force-fill vague placeholders.
- **failure_mode**: Naive default: assume 100% inferable, fabricate vague failure_mode
  when stuck ("not doing this causes problems"). Why wrong: fabricated failure_mode is
  worse than UNRESOLVABLE — looks complete but contains invented content future readers
  trust as authoritative, turning "omission" into "misinformation".
- **Grounded in**: EPIC-20260622-knowledge-recording-redesign P4 migration.
```

**Variabilize check**: `{entry-count}` replaces 110; `{percentage}` replaces 70/30; skeleton
holds across any schema migration. Invariants preserved: "failure_mode", "UNRESOLVABLE",
"gap-handback" (domain-stable terms). **Leak check**: no TAD-specific filenames/slugs remain.

### 6. Lint result

```
knowledge-lint: 0 warnings found
```

New entry clean. Only INFO-level MUST yellow-flags on pre-existing entries (expected).

### 7. Reconcile result

**Candidates reviewed** (top-5 from _index.md + memory-and-learning.md):
1. "Drift-Check and Staleness Detection" — not related (detection vs migration)
2. "Trace Instrumentation" — not related
3. "Parser Value Propagation" — slight overlap (info loss) but different mechanism (parser bug vs author omission)
4. "Scanner Content-Loss" — same as above
5. principles.md #15 "Knowledge Is Forged at Distill, Not Captured" — closest (same Epic), but L1 methodology vs L2 operational data

**Decision: ADD** — new entry is L2 operational data (70/30 ratio + "fabrication > omission" rule)
complementing L1 principle. No existing entry overlaps enough for UPDATE; none contradicted for DELETE.

---

### Schema gaps found

**None.** The schema's `failure_mode` field is universally applicable:
- 0 UNRESOLVABLE across 110 entries (L2 patterns all have inferrable naive defaults)
- The gap-handback mechanism worked as designed: `failure_mode` was the field Alex couldn't fill,
  Blake's answer was precise and non-obvious ("fabrication > omission")
- The variabilize test correctly passed (skeleton survives slot replacement)

**Tool gap (not schema gap)**: lint's file-level granularity false-passed 4 files (57 entries) —
documented in P3 as known limitation, now confirmed in the wild. Future improvement: per-entry lint.

**Mechanism validation**:
- ✅ Capture: Blake wrote raw journal (time-narrative, no schema)
- ✅ Distill: Alex read journal as stranger, identified gap in `failure_mode`
- ✅ Gap detection: unfillable field became a precise question (not "write more detail" but "what would a naive person do wrong")
- ✅ Cross-bridge hand-back: question → human → Blake → answer
- ✅ Finalize: answer filled in, variabilize + leak check passed
- ✅ Lint: 0 WARN
- ✅ Reconcile: ADD (no overlap with existing entries)
