# Phase 0 完工记录 — 证据载体恢复执行链（开链复算＋执行版清单冻结）

- 执行者：Blake（实施第一段，step_id `tad-evidence-recovery-impl-p01-01`）
- 日期：2026-10-04（复算时点 2026-10-04T23:51Z）
- 设计本体：`.tad/active/handoffs/HANDOFF-2026-10-04-evidence-carrier-recovery-execution.md`（Gate 2 PASS，增补后 61,816 B）
- 口径来源：S1 summary `.tad/evidence/research/maintainer-evidence-revival/inventory-summary.md`「复跑命令序列」逐字执行，未另创口径

## Step 0 路径断言（开工自检，全过）

- `git rev-parse --show-toplevel` ＝ `/home/hatch/workspace/yun-sync/TAD` ✓
- 当前分支 main；`maintainer-evidence` 本地尖 ＝ `8713ea4eb88b53f74f70f50477143a6fec05d22a`；`origin/maintainer-evidence` 同值 ✓
- `main` 尖 ＝ `5619b09556863b6d2587d6fa71b46e71bb8b1174` ✓
- `.gitignore` sha256 ＝ `3109c53025688cc5ad6d1d8f4b5b908b4f88d0c1db7358a1f96e58be0081bfab` ✓
- main 两树 tracked 例外恰 3 件（`.tad/archive/next/NEXT-completed-through-20261004.md`、`.tad/evidence/pm/downstream-versions.md`、`.tad/evidence/reviews/2026-09-15-gate4-acceptance-platform-adapters.md`）✓
- 本段零 git 写操作（仅 ls-tree／show／rev-parse／hash-object 只读形态与 status 类只读命令）

## 复算四锚（S1 值／复算值并列）

```
TOTAL_NOCARRIER=8754
TOTAL_STALE=5
TOTAL_CARRIED=4355
TOTAL_BRANCH_ONLY=16
```

| 锚 | S1（2026-10-04T22:16Z） | 本次复算 | 差 |
|---|---|---|---|
| TOTAL_NOCARRIER | 8706 | 8754 | ＋48 |
| TOTAL_STALE | 5 | 5 | 0 |
| TOTAL_CARRIED | 4355 | 4355 | 0 |
| TOTAL_BRANCH_ONLY | 16 | 16 | 0 |
| 盘上集 A（EXCL 后） | 13066 | 13114 | ＋48 |

- 自洽校验：8754＋5＋4355＝13114＝A ✓；交集＝4355＋5＝4360，与 S1 交集全等。
- 逐件复核（独立第二算）：母本 13,082 行逐行与复算分类比对——**类别迁移 0 件、盘上消失 0 件、branch-only 行异常 0 件**；差额全部来自盘上新增 48 件（下表逐件归因，无未解释差额）。

## 基线登记（Gate 2 增补 A7：AC8／AC10 以本记录登记值为准）

- AC8 父值基线：复算时点 `maintainer-evidence` 尖 ＝ `8713ea4eb88b53f74f70f50477143a6fec05d22a`（与设计时点钉值相同，无差异需归因）。
- AC10 基线：复算时点 `main` 尖 ＝ `5619b09556863b6d2587d6fa71b46e71bb8b1174`（与设计时点钉值相同）。工作树跟踪修改登记（A7 口径，如实登记、与设计步 §2.2 的「0」不同）：复算时点 `git status` 跟踪修改 **20 件，全部为本链开工前既存**——上游复活票 CLOSED 回写 1（`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`）、B 线迁档自 `.tad/active/handoffs/` 删除 12、KA 落盘修改 2（`patterns/ac-verification.md`、`patterns/shell-portability.md`）、收口保留集 5（`NEXT.md`、`docs/pm/{acceptance,auth,intent,now}.md`）；本链在 Phase 0／1 新增跟踪修改 **0**（本段全部产物落在忽略树内，经 `git check-ignore` 逐件确认）。Gate 3 执行 AC10 时以本登记为基线：判据＝main 尖不变＋跟踪修改集合不超出本登记 20 件。
- `.gitignore` 指纹与例外 3 件集合：与设计时点基线相同（见 Step 0）。

## 差额归因（＋48 件，全部 no-carrier，逐件列名）

### 本链自产（11 件，恢复执行链设计／Gate 2／增补产物）

- `.tad/evidence/activation-packages/tad-evidence-recovery-design-01.md`
- `.tad/evidence/activation-packages/tad-evidence-recovery-design-amend-01.md`
- `.tad/evidence/activation-packages/tad-evidence-recovery-gate2-fit-01.md`
- `.tad/evidence/activation-packages/tad-evidence-recovery-gate2-tech-01.md`
- `.tad/evidence/activation-packages/tad-evidence-recovery-impl-p01-01.md`
- `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-design-note.md`
- `.tad/evidence/completions/2026-10-04-tad-evidence-recovery-design-amend-note.md`
- `.tad/evidence/pm/2026-10-04-evidence-recovery-design-rulings.md`
- `.tad/evidence/pm/2026-10-04-evidence-recovery-gate2-merged-ruling.md`
- `.tad/evidence/reviews/2026-10-04-gate2-fit-review-evidence-carrier-recovery.md`
- `.tad/evidence/reviews/2026-10-04-gate2-tech-review-evidence-carrier-recovery.md`

### 上游链自产（18 件，证据复活链 S1 枚举后落盘的 S2–S4／C-T2／PM 验盘与裁定产物）

- `.tad/evidence/activation-packages/tad-evidence-revival-ct2-01.md`
- `.tad/evidence/activation-packages/tad-evidence-revival-s2-01.md`
- `.tad/evidence/activation-packages/tad-evidence-revival-s3-01.md`
- `.tad/evidence/activation-packages/tad-evidence-revival-s4-01.md`
- `.tad/evidence/completions/2026-10-04-tad-evidence-revival-ct2-note.md`
- `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s1-note.md`（S1 完工说明，summary 已预告为枚举后新增）
- `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s2-note.md`
- `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s3-note.md`
- `.tad/evidence/completions/2026-10-04-tad-evidence-revival-s4-note.md`
- `.tad/evidence/completions/COMPLETION-2026-10-04-maintainer-evidence-revival.md`
- `.tad/evidence/pm/2026-10-04-evidence-revival-carrier-ruling.md`
- `.tad/evidence/pm/2026-10-04-evidence-revival-ct2-pm-verify.md`
- `.tad/evidence/pm/2026-10-04-evidence-revival-s1-pm-verify.md`
- `.tad/evidence/pm/2026-10-04-evidence-revival-s2-pm-verify.md`
- `.tad/evidence/pm/2026-10-04-evidence-revival-s3-pm-verify.md`
- `.tad/evidence/research/maintainer-evidence-revival/decision-brief.md`
- `.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md`
- `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md`

### 他链新增（19 件：B 线自家欠账迁档 14＋PM 当日件 5）

迁档 14 件（已收口链 HANDOFF／COMPLETION 自 `.tad/active/handoffs/` 迁入 `.tad/archive/handoffs/`）：

- `.tad/archive/handoffs/COMPLETION-2026-10-04-claude-removal.md`
- `.tad/archive/handoffs/COMPLETION-2026-10-04-tad-state-surface-closeout.md`
- `.tad/archive/handoffs/COMPLETION-20260915-notebooklm-deprecation.md`
- `.tad/archive/handoffs/COMPLETION-20260915-tad-research-mechanism.md`
- `.tad/archive/handoffs/EPIC-20260816-framework-health/COMPLETION-2026-09-15-platform-adapters-p1p3.md`
- `.tad/archive/handoffs/EPIC-20260816-framework-health/COMPLETION-20260816-phase2-partial-p0-fix.md`
- `.tad/archive/handoffs/EPIC-20260816-framework-health/HANDOFF-2026-09-15-platform-adapters-p1p3.md`
- `.tad/archive/handoffs/HANDOFF-2026-09-15-claude-decouple-design.md`
- `.tad/archive/handoffs/HANDOFF-2026-09-15-claude-removal-plan-codex.md`
- `.tad/archive/handoffs/HANDOFF-2026-09-15-claude-removal-plan.md`
- `.tad/archive/handoffs/HANDOFF-2026-09-15-notebooklm-deprecation.md`
- `.tad/archive/handoffs/HANDOFF-2026-09-15-tad-research-mechanism.md`
- `.tad/archive/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`
- `.tad/archive/handoffs/HANDOFF-2026-10-04-tad-state-surface-closeout.md`

PM 当日件 5 件：

- `.tad/evidence/activation-packages/tad-housekeeping-survey-01.md`
- `.tad/evidence/pm/2026-10-04-claude-removal-closeout-verification.md`
- `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`
- `.tad/evidence/pm/2026-10-04-gm-inputs-judgment.md`
- `.tad/evidence/pm/2026-10-04-housekeeping-survey.md`

## 瞬时读数注记（如实记录，非冻结口径）

首轮逐字复跑曾读得 TOTAL_NOCARRIER=8773（盘上原始枚举 13,135 件），比稳定快照多 19 件。其后三次连续枚举（2026-10-04T23:47Z、23:49Z、其后 60 秒）结果逐字全等（原始 13,116 件、集合差 0），故冻结采稳定快照读数（8754）。多出的 19 件在稳定快照中已不存在、无清单可归因，成因未定（疑为枚举瞬间盘面瞬时文件），已在完工说明中报 PM；冻结清单与四锚均建立在三次全等的稳定快照上，不依赖该瞬时读数。

## 执行版清单（C1，冻结）

- 路径：`.tad/evidence/research/maintainer-evidence-revival/execution-manifest.jsonl`
- 行数 13,130 ＝ 母本 13,082 全量带入 ＋ Phase 0 追加 48 行（行内注 `appended_at_phase0: true`）；每行补 `outcome=pending`、`sha=null`、`commit=null`（synced 后回填）。
- 字节数 3,426,326；sha256 `afba59ddbacea32b9d6ff80a46c1e2fdeb7afd8c8fbd0b08d21cf5023a73ed5f`。
- 分类计数与复算四锚全等：no-carrier 8754／stale-content 5／carried 4355／branch-only 16。
- 同步队列（冻结时点）＝ no-carrier＋stale-content ＝ **8,759 件**（outcome=pending）。
- AC1 自验：设计 §9.1 AC1 命令 exit 0（13130／48／True）。
- 母本 `inventory-manifest.jsonl` 只读未改；EXCL 2 件（盘点产物）未入清单、未入队列（增补 A3）。
- 冻结口径：自此 Phase 1–5 只回写 outcome／sha／commit，不增删行（§4.7 同名改写 carve-out 除外）。

## Phase 0 验证

- AC1：PASS（自跑，见上）。
- AC2：本记录即其载体——含复算四锚锚行、S1 基线对照（8706 等）与差额归因表。
