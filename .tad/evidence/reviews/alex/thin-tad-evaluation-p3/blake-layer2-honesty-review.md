# Blake Layer-2 Honesty & Boundary Review — TASK-20260908-thin-tad-evaluation-p3

- **Reviewer role:** Independent Layer-2 honesty/boundary reviewer (did NOT write the deliverables)
- **Date:** 2026-09-08 · **Contract:** `.tad/active/handoffs/HANDOFF-20260908-thin-tad-evaluation-p3.md` v1.1 (Gate 2 PASS)
- **Scope of this review:** honesty + scope safety ONLY. No implementation files edited; no implementation judgments.
- **Deliverables reviewed (read-only):**
  - `.tad/evidence/experiments/thin-tad-pilot/analysis.md` (14,642 bytes)
  - `.tad/evidence/experiments/thin-tad-pilot/decision.md` (4,928 bytes)
  - `experiments/thin-tad-pilot/verify-p3.mjs` (exit 0, re-executed by reviewer)
- **Ground truth cross-checked:** `runs/isolation-probe-report.json`, `arms/baseline.json`,
  `arms/candidate.md`, `COMPLETION-20260908-thin-tad-evaluation-p2.md`, live worktree (`wc -c/-m/-l`, `git status`), `which oc-run`.
- **Method:** every number in analysis.md §2.5 recomputed from the worktree; every honesty/boundary
  prohibition in contract §§1.3/3.2 re-tested independently.

---

## 1. Recompute table — analysis.md §2.5 vs worktree ground truth

Counting methods used by reviewer: `BYTES = wc -c` (= `os.path.getsize`), `CHARS = wc -m`
(= Python `len(text)`), `NL = wc -l` (newline count), `LINES = splitlines` (logical lines).
The two differ only for files WITHOUT a trailing newline.

| # | File | Claimed 字符数 | Recomputed BYTES | Recomputed CHARS | Claimed 行数 | Recomputed NL / LINES | Verdict |
|---|---|---:|---:|---:|---:|---|---|
| 1 | `.agents/skills/blake/SKILL.md` | 120,413 | **120,413** ✓ | 112,342 | 2,143 | 2143 / 2143 ✓ | bytes-exact; chars-mislabeled |
| 2 | `blake/references/cross-model-invocation.md` | 3,206 | **3,206** ✓ | 2,706 | 62 | 62 / 62 ✓ | bytes-exact |
| 3 | `blake/references/notebooklm-access.md` | 3,895 | **3,895** ✓ | 3,883 | 62 | 62 / 62 ✓ | bytes-exact |
| 4 | `.agents/skills/gate/SKILL.md` | 52,661 | **52,661** ✓ | 48,001 | 996 | 995 / **996** ✓(LINES) | bytes-exact; line=logical count |
| 5 | `.tad/config-agents.yaml` | 11,298 | **11,298** ✓ | 8,483 | 342 | 342 / 342 ✓ | bytes-exact |
| 6 | `.tad/config-execution.yaml` | 14,893 | **14,893** ✓ | 12,058 | 404 | 404 / 404 ✓ | bytes-exact |
| 7 | `.tad/config-quality.yaml` | 32,485 | **32,485** ✓ | 27,121 | 875 | 875 / 875 ✓ | bytes-exact |
| 8 | `.tad/config-platform.yaml` | 7,931 | **7,931** ✓ | 7,155 | 237 | 237 / 237 ✓ | bytes-exact |
| 9 | `.tad/ralph-config/loop-config.yaml` | 9,099 | **9,099** ✓ | 8,923 | 233 | 233 / 233 ✓ | bytes-exact |
| 10 | `.tad/ralph-config/expert-criteria.yaml` | 9,335 | **9,335** ✓ | 9,329 | 296 | 296 / 296 ✓ | bytes-exact |
| 11 | `.tad/templates/completion-report.md` | 11,078 | **11,078** ✓ | 9,609 | 317 | 317 / 317 ✓ | bytes-exact |
| 12 | `.tad/templates/handoff-b-to-a.md` | 6,094 | **6,094** ✓ | 3,191 | 230 | 229 / **230** ✓(LINES) | bytes-exact; line=logical count |
| 13 | `.codex/hooks.json` | 770 | **770** ✓ | 770 | 28 | 28 / 28 ✓ | exact |
| **Σ** | **Baseline 13 files** | **283,158** | **283,158** ✓ byte-exact | 253,571 | **6,225** | 6223 (NL) / **6225** (LINES) ✓(LINES) | see findings P1/P2 |
| — | `arms/candidate.md` | 3,539 | **3,539** ✓ | 3,522 | 62 | **62** (NL) ✓ / 63 (LINES) | bytes-exact; line=newline count |

Derived-quantity checks (all recomputed):

| Claim | Recomputation | Verdict |
|---|---|---|
| Baseline ≈ 70,790 (÷4) ~ 80,902 (÷3.5) Token | 283158/4 = 70789.5 → 70,790 ✓; 283158/3.5 = 80902.29 → 80,902 ✓ | exact |
| Candidate ≈ 885 (÷4) ~ 1,011 (÷3.5) Token | 3539/4 = 884.75 → 885 ✓; 3539/3.5 = 1011.14 → 1,011 ✓ | exact |
| 字符比约 80:1，行数比约 100:1 | 283158/3539 = 80.01 ✓; 6225/62 = 100.40 (claimed basis) / 6223/62 = 100.37 (NL basis) → "约100:1" holds under either | ✓ |
| `fixed_sha` 短记 `edce7606` | `baseline.json: fixed_sha = edce76067f31127d06a1bdbbf3407578d25c81ce` → prefix ✓; 13-file path list matches contract §4.2 order 1:1 ✓ | ✓ |
| 探针 §3.1 全字段引用 | All 6 top-level (`probe_passed=false`, `adapter_eligible=false`, violation string, `ABORT`, model, harness) + all 8 `checks.*` fields match JSON byte-for-byte ✓ | ✓ |
| `which oc-run` exit 1; `TAD_OPENCODE_BIN` unset | Reviewer independently re-executed: `which oc-run` exit=1, var unset ✓ — corroborates P2 COMPLETION §0.5 | ✓ |

**Zero P0 fabrication.** Every numeric value in §2.5 resolves to a deterministic standard count
of the live worktree. Byte values are exact 14/14; line values resolve under standard methods 14/14
(see P2 for the method-mixing caveat). Totals are internally consistent (Σ of claimed per-file values).

---

## 2. Boundary checks

| Check | Result |
|---|---|
| (2) Zero live-effect claims | **PASS.** `LIVE_EFFECT_UNDETERMINED`, `ADAPTER_INELIGIBLE`, `EMPIRICAL_DATA_ABSENT` all present in analysis.md (verified by `verify-p3.mjs` exit 0 + reviewer grep). No model win rate, no runtime saving/delay percentage asserted as a result. The only `%`/ratio figures are (a) static 80:1/100:1 text ratios explicitly fenced as "仅为静态文本度量…不是运行期结论", and (b) pre-registered FUTURE gate thresholds in decision.md §3 (`δ ≤ 5%`, `n ≥ 50`, 500k budget, N≥3 breaker, sha256 100%) — admission criteria, not empirical results. §4.1 states 0 runs executed; §4.2 argues static savings ⇏ runtime savings. |
| (3) Zero currency/metering words | **PASS.** Independent `grep -rniE '\b(usd\|dollars?\|cents)\b'` over both markdown files: zero hits (CLEAN). `verify-p3.mjs` zero-currency scan likewise clean, exit 0. §4.4 contains an explicit anti-currency normative statement. |
| (4) No production TAD edits | **PASS (AC7 snapshot-diff).** `/tmp/p3-baseline-status.txt` exists; reviewer re-captured post status over `.agents/ .claude/ .tad/hooks/ .tad/config.yaml` → `diff` IDENTICAL, `comm -13` empty: zero NEW protected-path changes. Pre-existing dirty-tree entries (mode-only drifts etc.) are byte-identical before/after — not attributable to P3. Tracked-space new file attributable to P3: only `experiments/thin-tad-pilot/verify-p3.mjs` (Canonical Allowlist item 3). `analysis.md`/`decision.md` live under `.tad/evidence/` (repo `.gitignore:126`, verified via `git check-ignore`), created 17:16 in the P3 window at Allowlist items 1–2. No writes outside the Allowlist detected. Process note: `COMPLETION-20260908-thin-tad-evaluation-p3.md` (Allowlist item 4) is not yet written — expected; it is the Gate 3 carrier, outside this review's 3-file scope. |
| (5) Refusal rationale documented | **PASS.** analysis.md §3.3 documents BOTH refusals with causal rationale: (a) `/home/box/pm/bin/oc-run.sh` rejected — non-standard path, cross-project asset, outside authorization, unattested param/version contract → attribution contamination; cites P2 COMPLETION §0.5 non-substitution. (b) bare `opencode run` rejected — missing `--temperature`/`--seed`/`--prompt-file` flags + timeout/isolation semantics → hyperparameter-lock breach, incomparable arms. Tier-1/fidelity design value also recorded. Matches P2 COMPLETION §§0.5/2 (reviewer cross-read). |
| H/V split + B2 floor | **PASS (observed, honesty-relevant).** H and V in separate subsections; "严禁合并计算总胜负得分" stated; n=12 ≪ 50–100 declared twice (§2.2, §2.5). 24 controls (12+12) and oracle provenance claims are structural descriptions consistent with P1/P2 records; no numeric overclaim. |

---

## 3. Findings

- **P0 — none.** No fabricated number found. Withheld as PASS criteria require: byte-exactness holds
  across all 14 static values, and every line value is reproducible under a standard counting method.
- **P1-1 (labeling, material magnitude): "字符数" column actually contains byte counts.**
  §2.5 table header says 字符数 but all 14 values equal `wc -c` bytes; true Unicode character sums are
  253,571 (baseline, Δ −29,587 / −10.4%) and 3,522 (candidate, Δ −17). The inline prose (§2.5 l.68,
  "实测字节/行数") discloses the byte basis, which mitigates intent concerns, but the header directly
  contradicts it and the headline total 283,158 inherits the mislabel. Downstream token math is
  unaffected (÷4/÷3.5 on bytes is the conventional approximation basis). **Required fix:**
  rename header to 字节数 (or add a 字符数 column with the true `wc -m` values) — doc-label edit only,
  no re-measurement needed since byte values are verified exact.
- **P2-1 (method inconsistency): line counts mix two standard methods without disclosure.**
  Files `gate/SKILL.md` (996) and `handoff-b-to-a.md` (230) equal logical-line counts (splitlines /
  `awk NR`); `candidate.md` (62) equals newline count (`wc -l`; splitlines = 63). All three lack a
  trailing newline, which is the entire cause. 11/13 rows agree under both methods. No single standard
  tool reproduces all 14 claimed values. **Required fix:** one-line method note in §2.6
  (e.g. "行数 = 逻辑行；其中 3 个无尾换行文件以 splitlines 计，`wc -l` 少计 1，已核对").
  §2.6's recompute commands are also incomplete (no per-file `wc` loop) — extend so a third party can
  reproduce the table in one paste.
- **P2-2 (process note, non-blocking):** COMPLETION-p3 carrier not yet written; Gate 3 must confirm it
  appears under Allowlist item 4 before acceptance. Not a defect in the reviewed deliverables.

---

## 4. Overall verdict: **CONDITIONAL** (fix labels, then PASS)

Rationale: honesty core is intact — zero P0, zero live-effect claims, zero currency leakage, zero
production intrusion, both refusal rationales documented, probe/sha/arms ground truth quoted exactly,
and `verify-p3.mjs` independently re-executed to exit 0. The two conditions (P1-1 header rename,
P2-1 method note + reproducible per-file commands) are documentation-label fixes fully determined by
this review's recompute table; they require no new measurements and no re-review of substance.
Once applied, verdict converts to PASS without further Layer-2 honesty review.

---

## 5. Re-review note (2026-09-08, label-only fix round) — final verdict: **PASS**

- **Scope:** labels only in `analysis.md` (§2.5 table/prose + §2.6). No numbers were changed by Blake;
  reviewer touched no other file.
- **P1-1 CLOSED.** Table header renamed 字符数 → 字节数; new caliber note (l.70) states `wc -c`
  bytes (incl. UTF-8 multi-byte CJK), discloses true char total 253,571, defines logical-line rule.
  Candidate/baseline prose now 字节-based ("3,539 字节", "字节÷4/÷3.5", "字节比约 80:1").
  Only remaining 字符 occurrence is the disclosure note itself — zero stale 字符-as-metric claims.
  Independently recomputed: bytes total = 283158 ✓, chars total = 253571 ✓ (matches disclosed figure).
- **P2-1 CLOSED.** §2.6 now contains a per-file reproducible command (iterates `baseline.json`
  file list, prints `len(bytes)` + logical lines with missing-trailing-newline +1 rule).
  Reviewer executed it verbatim: output reproduces all 13 claimed table rows exactly.
- **No regressions:** currency grep CLEAN; all four honesty markers present; all numeric claims
  (283,158 / 6,225 / 3,539 / 80:1 / 100:1 / token estimates) unchanged and previously verified.
- **Final verdict: PASS.** P2-2 process note (COMPLETION-p3 carrier) remains for Gate 3, unchanged.
