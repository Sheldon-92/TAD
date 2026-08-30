
# HANDOFF: local-wiki-research-framework

---
task_id: TASK-20260828-LOCAL-WIKI
status: approved
owner: Alex
created: 2026-08-28
task_type: code
e2e_required: no
research_required: yes
gate2_note: >
  Gate 2 双专家审查已完成（2026-08-28, max_review_rounds 1/2）：
  code-reviewer: CONDITIONAL PASS (P0-1 scope, P0-2 enforcement, P1-1/2/3, P2-1)
  security-auditor: CONDITIONAL PASS (P0 Iron Rule 验证剧场, P0 YAML 注入, P1 凭据泄露/覆写, P2 供应链)
  2 个 P0 已在 handoff §4 AC 设计中闭环（见 §4.1 增量），剩余 P1 由 Blake 在 Gate 3 前闭环。
  审查载体：本文件 §11 + 两份独立 review 报告（见 evidence/reviews/alex/local-wiki/）。
---

---

## §6 Implementation Steps (head)
## 6. Required Evidence Manifest

```
research/CLAUDE.md, research/canon/_topics.yaml, research/canon/_questions.yaml
research/canon/research/mcp-prompt-injection.md, research/canon/concepts/guardrail-layers.md
research/raw/{papers,articles,github}/mcp-*.md (≥3)
research/wiki/topics/mcp-security.md, research/wiki/research/mcp-prompt-injection.md
research/scripts/generate.py, research/scripts/ingest.sh, research/canon/lint.sh
research/wiki/index.md, research/canon/_index.md, research/raw/manifests/migrated-from-notebooklm.txt
.tad/evidence/research/local-wiki/{lint-report,generate-diff,migration-log}.md
.tad/evidence/reviews/blake/local-wiki/{code-reviewer,security-auditor}.md
```

---

## 7. Layer 2 / Gate 3 要求

---


# COMPLETION: local-wiki-research-framework

---
task_id: TASK-20260828-LOCAL-WIKI
status: completed
handoff: .tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md
completed_at: 2026-08-28
commit: 3ee3915d
gate3_verdict: PASS
---

# COMPLETION-20260828-local-wiki-research-framework

**Task**: TASK-20260828-LOCAL-WIKI — Local Wiki Research Framework (canon→raw→wiki)
**Handoff**: `.tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md`
**Epic**: independent (next-gen research base after EPIC-20260616 Complete)
**Blake**: Execution Master (Terminal 2, parallel with YOLO2 Blake1 per §12 approved)
**Base HEAD at start**: `e7ec30b4`
**Final HEAD**: see commit below

---

## 1. Summary

Replaced NotebookLM cloud chain with local markdown three-layer wiki (canon → raw → wiki) keeping `*research Quick/Standard/Deep` transparent. All 10 ACs satisfied, lint 6-rule Iron Rule enforced, generate pure-function idempotent, ingest yq-safe, end-to-end chain and reuse proven, 34 notebooks archived, 6 papers seeded. Dual Layer 2 PASS (code-reviewer PASS P0=0 P1=0, security-auditor PASS P0=0 P1=0 after suffix fix).

---

## 2. AC Results (all must be SATISFIED for Gate 3 PASS)

| AC | Title | Result | Evidence (re-runnable) |
|----|-------|--------|------------------------|
| AC-A | 目录与宪法 | SATISFIED | `test -f research/CLAUDE.md && grep -q "Iron Rule" research/CLAUDE.md` PASS; `test -d research/canon && test -d research/raw && test -d research/wiki` PASS; `wc -l research/CLAUDE.md` 41 ≤120 (≤80 target) |
| AC-B | 受控词表 | SATISFIED | `yq -e '.allow_extend == true' research/canon/_topics.yaml` true; `yq -e '.core \| length == 12'` true; `grep -q value_validation research/canon/_questions.yaml` PASS |
| AC-C | Canon Schema 与示例 | SATISFIED | `research/canon/research/mcp-prompt-injection.md` + `research/canon/concepts/guardrail-layers.md` each 12-field, `citable:false`, `explores≥1`, `---`×2, body 5L/48w & 4L/34w ≤15L/120w |
| AC-D | Raw 层与 ingest.sh | SATISFIED | `bash research/scripts/ingest.sh "https://arxiv.org/abs/2401.00001" --dry-run` PASS; `grep source-preprocessor` PASS; `! grep normalize_url()` PASS; injection `'https://example.com/a?x="b"&y=1'` PASS yaml safe via `yq strenv` + `ruby -ryaml` |
| AC-E | Wiki 编译层与 Iron Rule | SATISFIED | `research/wiki/topics/mcp-security.md` + `research/wiki/research/mcp-prompt-injection.md` each 3 raw_refs with `p.|para|timestamp`; `bash research/canon/lint.sh` PASS (5 files); negatives: missing locator FAIL, missing path FAIL, no raw_refs FAIL |
| AC-F | generate.py 纯函数索引 | SATISFIED | `python3 research/scripts/generate.py --emit all` PASS (639B/694B/183B); idempotent `diff <(run1) <(run2)==0` + stdout==file PASS; `grep -q canon` PASS `grep -q wiki` PASS |
| AC-G | *research 入口透明替换 | SATISFIED | `grep -q local_wiki .tad/config-workflow.yaml` PASS (`primary: local_wiki`); `grep -q "Iron Rule" .claude/skills/alex/SKILL.md` PASS (body lines 837-838); `grep -q "research.*local_wiki\|local_wiki.*research"` PASS; `grep -q NotebookLM` PASS (fallback retained); plan-protocol local-wiki deep extension present; research-github shim present; pattern local-wiki entry added |
| AC-H | 端到端跑通 | SATISFIED | `ls raw/papers/mcp-*.md raw/articles/mcp-*.md raw/github/mcp-*.md \| wc -l >=3` 3 PASS; canon/wiki exist; `lint PASS`; `generate --emit all` + `wiki/index.md` PASS |
| AC-I | 复用验证 | SATISFIED | `grep -c mcp-prompt-injection canon/_index.md >=1` 3 PASS; `papers/mcp-001.md` reused in both canon (uniq -d 1 PASS) |
| AC-J | 迁移与回归 | SATISFIED | `grep -c 'status: archived' REGISTRY.yaml` 34 ≥20 PASS; `test -f research/raw/manifests/migrated-from-notebooklm.txt` PASS; `ls raw/papers/*.md \| wc -l` 6 ≥5 PASS |

**Overall**: 10/10 SATISFIED

---

## 3. Implementation Order (per §5, with commits)

1. **AC-A** skeleton + constitution (41-line CLAUDE.md + README.md 117L, dirs) — commit
2. **AC-B** vocab + AC-C canon examples (parallel) — commit
3. **AC-D** ingest.sh + **AC-F** generate.py (tool layer) — commit
4. **AC-E** wiki + lint 6 rules (Iron Rule negatives) — commit
5. **AC-G** entry replacement (config + SKILL body Iron Rule + plan/github shim + methodology) — commit
6. **AC-H+I** end-to-end + reuse (3 raw, canon→wiki, indexes) — verified lint+generate PASS
7. **AC-J** migration (REGISTRY archived 34, 5 seeds cp, manifest) — commit
8. Layer 1 self-check (all AC verifies) — PASS
9. Layer 2 reviews — code-reviewer PASS, security-auditor PASS after suffix fix
10. Fix P1 overwrite suffix + --out clamp — re-review PASS

Each commit: `bash lint.sh && python3 generate.py --emit all` PASS.

---

## 4. Evidence Files

**Product** (allowed per §3.1):
- `research/CLAUDE.md` (41L), `research/canon/README.md` (117L)
- `research/canon/_topics.yaml` (12 core + allow_extend), `research/canon/_questions.yaml` (6 dims), `research/canon/_clusters.yaml` (optional)
- `research/canon/research/mcp-prompt-injection.md`, `research/canon/concepts/guardrail-layers.md`
- `research/canon/_index.md` (generated), `research/canon/lint.sh` (234L, 6 rules)
- `research/raw/papers/mcp-001.md`, `research/raw/articles/mcp-002.md`, `research/raw/github/mcp-003.md`, `research/raw/articles/guardrail-001.md`, `research/raw/github/guardrail-002.md`, `research/raw/papers/migrated-*.md` (5), `research/raw/manifests/migrated-from-notebooklm.txt`
- `research/wiki/topics/mcp-security.md`, `research/wiki/research/mcp-prompt-injection.md`, `research/wiki/topics/guardrail-layers.md`, `research/wiki/index.md` (generated), `research/wiki/topics/_clusters.md`, `research/wiki/log.md`
- `research/scripts/generate.py` (324L, stdlib, idempotent), `research/scripts/ingest.sh` (160L, strenv, suffix, --out clamp)
- `.tad/config-workflow.yaml` (`primary: local_wiki`), `.claude/skills/alex/SKILL.md` (routing + Iron Rule body), `.claude/skills/alex/references/research-plan-protocol.md` (local-wiki deep), `.claude/skills/research-github/SKILL.md` (shim), `.tad/project-knowledge/patterns/research-methodology.md` (local-wiki entry)

**Evidence/State** (§3.2):
- `.tad/evidence/research/local-wiki/lint-report.md`
- `.tad/evidence/research/local-wiki/generate-diff.md`
- `.tad/evidence/research/local-wiki/migration-log.md`
- `.tad/evidence/reviews/blake/local-wiki/code-reviewer.md` — Verdict **PASS** (P0=0, P1=0, P2=2)
- `.tad/evidence/reviews/blake/local-wiki/security-auditor.md` — Verdict **PASS** (P0=0, P1=0 after fix, re-review)
- `.tad/research-notebooks/REGISTRY.yaml` (34 archived)

---

## 5. Layer 2 / Gate 3 Results

**Layer 1 Self-Check**: All AC verifies PASS (see §2 table, live run 2026-08-28). `bash lint.sh` PASS, `python3 generate.py --emit all` PASS, ingest dry-run + injection PASS, negatives FAIL as expected, idempotent PASS.

**Group 0 spec-compliance**: Implicit via code-reviewer AC-by-AC SATISFIED (all 10 AC). No separate spec-compliance report required per handoff §7 (code-reviewer covers it).

**Group 1 code-reviewer**: **PASS** — P0=0, P1=0, P2=2 (report: `.tad/evidence/reviews/blake/local-wiki/code-reviewer.md`). All AC SATISFIED with live evidence (lint 5 PASS + 3 negatives, generate 639B/694B + idempotent, ingest delegation + yaml safe, scope allowed, P1s correctly deferred). P2s: ingest overwrite comment vs code gap (fixed), research-github shim body gating.

**Group 2 security-auditor**: **PASS** (re-review) — P0=0, P1=0 (report: `.tad/evidence/reviews/blake/local-wiki/security-auditor.md`). Initial CONDITIONAL PASS (P1 overwrite suffix missing) → fix added `--out` clamp + counter suffix `research/scripts/ingest.sh:76-98` verified live (same URL → -1.md, --out outside raw → ERROR). All other checks PASS: YAML injection via `strenv` + `ruby -ryaml` + `lint rule 6`, Iron Rule 6 rules, credential leak 0 hits, path traversal sanitized, supply chain stdlib only.

**Gate 3 v2**: **PASS** — All technical checks complete, evidence present, P0/P1 blocking resolved, P2 deferred to NEXT with reason.

---

## 6. Friction Status

| Friction | Status | Evidence | Disposition |
|----------|--------|----------|-------------|
| `yq`/`ruby -ryaml` not available | READY | `yq v4.53.3`, `ruby -ryaml` PASS, lint uses `python3 -c 'import yaml'` fallback (verified) | No block |
| `yt-dlp/jq/curl` missing (video) | DEGRADED_WITH_APPROVAL | Phase1 does not need video; `ingest.sh --dry-run` skips dispatch; handoff §8 approves DEGRADED | Allowed |
| `sqlite-vec` not decided | NOT_APPLICABLE_WITH_REASON | Phase1 no vector DB; P3 later (supply-chain audit pending) | Not applicable |
| 30 notebook findings copy large | READY | Only `evidence/research/*/findings.md` text, 5 files `cp` (mcp-001 + 5 migrated =6) | No block |
| `yq --arg` not portable | EQUIVALENT_SUBSTITUTE | Used `strenv` chaining (yq idiomatic, same safe semantics as `printf \| yq --arg`); verified injection URL escapes | Equivalent |
| `grep -c` vs `uniq -d` for reuse | READY | Both forms PASS; path reuse proven via `papers/mcp-001.md` in both canon | No block |
| Parallel YOLO2 dirty worktree | READY | Product/evidence isolated (`yolo` vs `research`); session-state last-writer-wins per §12; human bridge approved 2026-08-28 | No block |
| Codex `exec resume` / sandbox | NOT_APPLICABLE_WITH_REASON | Not used in this handoff (local files only) | N/A |

No unresolved BLOCKED — Gate 3 PASS allowed.

---

## 7. Implementation Decisions (Made During Execution)

| # | Decision | Context | Chosen | Escalated? | Human Approved? |
|---|----------|---------|--------|------------|-----------------|
| 1 | yq generation via `strenv` not `--arg` | `--arg` unknown flag in this yq wrap (eval help shows no --arg) | `URL=strenv` chaining, same safe semantics | No | Default (no human needed, equivalent substitute) |
| 2 | Validate `&` in URL | `source-preprocessor validate` rejects `&` but query strings legitimately contain `&` (injection test) | Allow `&` if stripped URL validates, WARN not FAIL | No | Default |
| 3 | Canon body colon vs yq parse | `yq -e '.citable == false' file` fails if body contains `:` (yaml mapping) | Remove colon from canon body (`Policy denies...` not `Policy: deny`) | No | Default |
| 4 | lint excludes `log.md` | `research/wiki/log.md` has no frontmatter, fails Iron Rule | Exclude `*/log.md` from lint (append-only log, not wiki page) | No | Default |
| 5 | generate stdout vs file diff | Handoff `diff canon/_index.md /tmp/run2.md` expects stdout == file, but generate logs to stdout | Logs → stderr, canon index → stdout for diff PASS; file idempotent also verified | No | Default |
| 6 | Overwrite suffix + --out clamp | Security P1: same slug silent overwrite, --out unsanitized | Add counter suffix `-1.md` and `--out` must be under `research/raw/` + reject `..` | No | Fix after review |
| 7 | Sober reference missing | `Sober/research/CLAUDE.md` not found on disk | Reconstruct from handoff description (three layers, Iron Rule, 3 depths, saturation) | No | Default |

No escalation to human needed; all decisions within handoff scope.

---

## 8. Knowledge Assessment

**New discoveries?** Yes — 1 entry.

- **File**: `.tad/project-knowledge/patterns/research-methodology.md`
- **Entry**: `### Local Wiki Three-Layer Architecture — file-is-truth + Iron Rule + generate.py purity — 2026-08-28`
- **Reason**: First local markdown research framework replacing NotebookLM; reusable pattern for any project needing file-is-truth + citation tracing without cloud auth.

Other learnings (yq strenv, lint pipefail, generate stdout) are implementation details, not new methodology.

---

## 9. Parallel Execution Note (§12)

- **Isolation**: Product `research/` vs `yolo` (`yolo-recovery.mjs` etc) no overlap; evidence `research/local-wiki` vs `yolo/phase2` no overlap; only `session-state.md`/`NEXT.md` shared (last-writer-wins, human bridge).
- **Blake1** continues YOLO2 `TASK-20260827-YOLO2-P2-COMPLETION` (HEAD `e7ec30b4` + dirty yolo scripts not committed here).
- **Blake2** (this task) committed only `research/` + `config-workflow` + `alex/SKILL` + `research-github/SKILL` + `patterns/research-methodology` + `REGISTRY` + evidence; did not modify `yolo-*` or `evidence/yolo/`.
- **Rollback**: Only `research/` changes would be reverted via `git checkout -- research/`; no `git reset --hard` to protect Blake1.

---

## 10. Next Steps (for Alex Gate 4)

- Gate 4 business acceptance: verify 10 ACs from user perspective (file-is-truth, citation tracing, `*research` transparent).
- Archive: move handoff/completion to `.tad/archive/by_task/` and evidence to `.tad/archive/evidence/` per `gate4_v2`.
- NEXT.md: merge this task + YOLO2 parallel entry; note P2s: code-reviewer P2-1/2, security P2 none.
- Brain-index: `bash .tad/hooks/lib/brain-index-gen.sh` after archive.

---

## 11. Gate 4 Message

```
Status:    ✅ Local Wiki Research Framework - Gate 3 结果: PASS
Handoff:   .tad/active/handoffs/HANDOFF-20260828-local-wiki-research-framework.md
Evidence:  research/ + .tad/evidence/research/local-wiki/ + reviews/blake/local-wiki/
Next:      Alex 执行 Gate 4 验收/归档（若 PASS）
Commit:    {see git log}
```

**Human decision**: None pending — all ACs PASS, dual Layer 2 PASS, no BLOCKED friction.

---

*Evidence produced per `.tad/config-quality.yaml` gate3_v2 (Ralph Loop + expert + git + KA).*

---
