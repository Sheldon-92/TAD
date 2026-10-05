# Blake Layer 2 Spec-Compliance Review — TAD 精简实验 P3 (Gate 3)

- **Reviewer role:** Independent Layer 2 spec-compliance reviewer (did NOT write the deliverables; no implementation files edited)
- **Date:** 2026-09-08
- **Contract:** `.tad/active/handoffs/HANDOFF-20260908-thin-tad-evaluation-p3.md` (§3.1, §5.2 AC0–AC7, §6)
- **Deliverables under review:**
  - `.tad/evidence/experiments/thin-tad-pilot/analysis.md` (14,642 bytes)
  - `.tad/evidence/experiments/thin-tad-pilot/decision.md` (4,928 bytes)
  - `experiments/thin-tad-pilot/verify-p3.mjs` (exit-0 contract script)
- **Method:** Re-ran every literal §6 check independently in this session
  (`grep -qF` markers, currency regex on the two markdown files only,
  `node verify-p3.mjs` with and without `--baseline-status`,
  `comm -13` snapshot-diff of protected paths vs `/tmp/p3-baseline-status.txt`),
  plus traceability / no-merge / allowlist audits below.

---

## Per-AC verdict table

| AC | Verdict | Evidence (literal command output from this session) |
|----|---------|------------------------------------------------------|
| AC0 诚实状态正向断言 | **PASS** | `grep -qF 'LIVE_EFFECT_UNDETERMINED' analysis.md` → PASS; `grep -qF 'ADAPTER_INELIGIBLE' analysis.md` → PASS; `grep -qF 'EMPIRICAL_DATA_ABSENT' analysis.md` → PASS. All three appear in the header承重断言 (L7) and §4.1. No model win-rate or online-saving claim anywhere (fabrication scan: only hit for 胜率/节省比 is the explicit *denial* sentence at L7). |
| AC1 离线任务包剖析与 H/V 分表 | **PASS** | 6 families each present (`routine`/`sync`/`filter`/`rename`/`evidence`/`date`, §2.1 table). H and V in **separate sections**: `### H 校准集（6 例…）` (L36) vs `### V 留出集（6 例…）` (L47). Explicit no-merge statement at L34: "**严禁合并计算总胜负得分**" (+ §2.2 title "H 与 V 严禁合并"). §2.3 covers 24 bidirectional controls (12 correct + 12 error); §2.4 covers `oracles/approved.json` rigor. |
| AC2 双臂静态对比与 B2 底线 | **PASS** | Baseline 13-file table (chars/lines per file + totals 283,158 / 6,225) + token estimates (÷4 / ÷3.5) + Candidate contrast (62 lines, 3,539 chars) at L68–87. **All 13 per-file numbers re-verified byte-for-byte against worktree in this session: 0 mismatches** (e.g. blake SKILL.md 120413/2143, hooks.json 770/28). Candidate 62 lines / 3,539 chars confirmed via `wc`. Ratios 80:1 / 100:1 arithmetically correct (283158/3539≈80.01, 6225/62≈100.40; token bounds 70789.5/80902.3/884.75/1011.14 match). B2 floor stated twice (L34: n=12 ≪ n=50~100; L89 re-assertion + Power argument). Static≠dynamic dialectic present (§4.2, four mechanisms: clarification rounds, hallucination/Gate-rework, human time unmeasured). |
| AC3 探针审计与边界防御 | **PASS** | Probe top-level fields quoted verbatim (L105: `probe_passed=false`, `adapter_eligible=false`, violation string, `ABORT`, model/harness IDs) — **cross-checked against `runs/isolation-probe-report.json` in this session: exact match**. All 8 `checks.*` fields quoted (L106) — match JSON (`tier1_env_clean=true`, `tier1_no_symlink=true`, `baseline_file_count=13`, `arms_verified=true`, `candidate_present=true`, `harness_available=false`, `negative_blocked=null`, `positive_ok=null`). `which oc-run exit 1` recorded (L112). Both refusals documented with causal reasons: `/home/box/pm/bin/oc-run.sh` rejection (L117: non-standard path, attribution contamination) and bare `opencode run` rejection (L118: missing `--temperature`/`--seed`/`--prompt-file`, breaks hyperparameter lock). Tier-1/fidelity design value + `BASELINE_TRUNCATED` reservation (L119). |
| AC4 零货币记账（作用域净化） | **PASS** | `grep -ciE '\b(usd\|dollars?\|cents)\b'` → **0 hits in each file** (grep exit 1 = no match). Full §6 gate loop passes for both files. Scope is exactly the two markdown deliverables; script self-exempt per contract. §4.4 contains the normative no-fiat statement using compliant wording (字符/行数/静态预估 Token). |
| AC5 生产架构保留决策 | **PASS** | `grep -qF 'MAINTAIN_CURRENT_RULES' decision.md` → PASS (L14); `grep -qF 'NO_PRODUCTION_RULE_DELETION' decision.md` → PASS (L14). Bounded framing explicit (L15: neither approves nor permanently bans thinning — freezes as undecided). Reasons trace to missing 24-run evidence + static≠dynamic + n=12. |
| AC6 重开准入 5 前置条件 | **PASS** | All 6 markers present: `PREREQ-AUTH: HUMAN_MANDATE` (L48) + `PREREQ-1..5` with full suffixes `HARNESS_CERTIFICATION` / `HYPERPARAMETER_LOCK` / `BASELINE_13_FIDELITY` / `BUDGET_AND_BREAKER` / `NON_INFERIORITY_MARGIN` (L52–56). Quantifiers verified: sha256 100% byte-identity (PREREQ-3), 500,000-token single-arm cap + N≥3 consecutive-failure fuse (PREREQ-4), δ ≤ 5% + n ≥ 50 (PREREQ-5), `which oc-run exit 0` + probe gates (PREREQ-1), `--temperature 0` / `--seed 42` / 300s / workspace isolation (PREREQ-2). |
| AC7 生产零侵入（快照差围栏） | **PASS** | Baseline (136 lines, 2026-09-08 17:13) vs post (136 lines): `comm -13` → **empty output, exit 0** → `test -z` PASS. `verify-p3.mjs --baseline-status /tmp/p3-baseline-status.txt` → `ok: snapshot-diff fence: zero new protected-path changes` + `ALL CHECKS PASSED` (exit 0). Plain `node verify-p3.mjs` → exit 0 as well (all 20 content checks `ok`). |
| (a) 无编造 live-matrix 数字 | **PASS** | Only `%` numbers in deliverables: `100%` (PREREQ-3 sha criterion) and `5%` (PREREQ-5 δ margin) — both forward-looking protocol thresholds, not measured results. analysis.md contains zero `%` figures. 80:1/100:1/token bounds all traced to worktree (§2.6 recompute commands given; 13/13 re-verified). 25/25 single-test figure attributed to P2 tool leg with carrier path. Zero executed runs declared (0/24, manifest/pair-summary/run.json absent). |
| (b) H/V 分表 + 不合并声明 | **PASS** | Separate H § / V § + no-merge statement in analysis L34; reinforced in decision PREREQ-5 ("H 与 V 必须分表报告，严禁合并计分"). |
| (c) Canonical Write Allowlist | **PASS** | Deliverables live at allowlist items 1–3 (analysis.md, decision.md, verify-p3.mjs — the latter new untracked file `??`, correct for a CREATE item). No new protected-path changes (AC7). `experiments/thin-tad-pilot/README.md` diff is P2-era (mtime 13:13, predates 17:13 baseline), not a P3 write. This review file itself falls under allowlist item 5 (`reviews/alex/thin-tad-evaluation-p3/**`). |

---

## Findings

- **P0: none.** No fabricated data, no production-path edit, no missing literal marker, no currency leak.
- **P1: none.** Every falsifiable criterion is literally satisfied with command-output evidence.
- **P2 (informational, non-blocking):**
  - P2-1: `COMPLETION-20260908-thin-tad-evaluation-p3.md` (allowlist item 4, Gate 3 delivery carrier per §7.2) does not exist yet at review time. Expected — it is the Gate 3 closure document this review feeds into, not a P3-implementation deliverable under §3.1/§5.2. Recommend Blake file it with the §6 command outputs before Gate 3 sign-off.
  - P2-2 (accepted blind spot, carried from Gate 2 Round 2 code-review): snapshot-diff compares `git status --porcelain` line sets, so a pre-existing dirty line replaced by an identical string would be invisible. No evidence of exploitation (136/136 lines identical, deliverable numbers independently re-verified); recorded for completeness only.

---

## Overall verdict: **PASS**

All AC0–AC7 literal checks pass with independently reproduced command output.
Traceability audit clean (13/13 static figures byte-exact; candidate.md exact;
probe JSON exact; ratios arithmetic-exact).
No-merge and honesty disciplines upheld.
Zero new protected-path changes; all writes within the Canonical Write Allowlist.
No P0/P1 findings. Recommend Gate 3 proceed once the P3 COMPLETION carrier (P2-1) is filed.
