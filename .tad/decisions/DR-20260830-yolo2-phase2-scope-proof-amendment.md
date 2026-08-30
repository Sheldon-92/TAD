# DR-20260830 — YOLO2 Phase-2 并行历史下的范围证明修正

**Date**: 2026-08-30  
**Decider**: Sheldon（human, Value Guardian）  
**Decision provenance**: Alex Gate-4 预验收发现 AC-B 将正确的范围隔离目标绑定为
`96bbfada..main HEAD` 的连续历史假设；人类确认“可以”采用窄幅修正。  
**Applies to**: `TASK-20260827-YOLO2-P2-COMPLETION` 的 AC-B，以及依赖它的 AC-J。  
**Supersedes only**: `HANDOFF-20260827-yolo2-phase2-completion.md` AC-B 中
“直接以共享 main HEAD 作为唯一范围证明终点”的部分。其他 AC、allowlist、Gate 3
阈值和 Layer 2 要求不变。

## 1. Problem classification

`f967276f`（Local Wiki）是合法的并行提交，但位于 Phase-2 frozen base
`96bbfada` 与当前 main HEAD 之间。因而 `git diff 96bbfada..HEAD` 同时包含两个
工作流的路径，AC-B 即使面对零 YOLO 越界也会失败。这是 **Alex AC false-negative
设计缺陷**，不是 Blake 实现失败。

禁止用以下方式“修复”：

- 不得把 `PHASE2_SCOPE_BASE` 移到 `f967276f` 或任何更晚提交；这会漏证此前的
  Phase-2 修改。
- 不得把 Local Wiki、`.claude/**`、research/**、config 或 hooks 加入 YOLO
  allowlist。
- 不得回滚、隐藏或重写 Local Wiki 工作。
- 不得仅凭 summary/commit message 判断 commit 归属。

## 2. Amended proof model

AC-B 改为同时证明 **phase ownership** 与 **main integration equivalence**：

1. **Frozen base remains exact**: `96bbfada1e6c757b7b9dec0d38d69eb8dc2e3aa7`。
2. **Closed commit inventory, not a self-selected list**: verifier 从固定的
   `BASE_SHA..MAIN_HEAD_SHA` 对每个非 merge commit 重算 first-parent diff，要求 manifest
   对该闭集中的每个 commit **恰好分类一次**：`included` 或 `excluded`。included commit
   的所有 changed paths 必须落入原 Phase-1 archive allowlist、20260827 handoff
   §3.1/§3.2，或本 DR 这个 Alex-authored design carrier。excluded 不是 manifest 可自选
   的理由字段：本 DR 只批准下述一个固定 exclusion，verifier 必须从 Git object 重算并
   与全部固定值一致：

   ```text
   source_sha: f967276fc3b8e1fbc5acce5bc1fe7cfbfa121e5f
   parents: [e7ec30b48f445a997b11408ea3aa5b699e55da06]
   first_parent_binary_diff_sha256: 70de6e15357c582a89fa0a155ffec79596fa87cd3a57feb09758a3248bf3cbdf
   sorted_changed_paths_sha256: 35413b708507ecf4e79ac4ce602496386910fe00d10a314a4e120e62b848b65f
   reason: parallel-local-wiki
   shared_phase2_path_exemptions: []
   ```

   manifest 中仍须展开完整 changed-path list，并验证其 sorted-list hash；该提交当前不与
   Phase-2 owned paths 相交。任何未知 excluded SHA、字段/路径集不等、或未来新增并行
   exclusion 都 → exit 2，必须先由人类签署新的 amendment entry。included/excluded
   混合归属 commit、merge commit 或无法唯一分类的 commit同样 exit 2，先拆分/裁定，
   禁止猜测。
   每个 inventory item 至少含 source commit 全 SHA、完整 parents 数组、source tree、
   first-parent binary diff SHA-256、stable patch-id、changed paths、classification 与理由；
   patch-id 仅作辅助，verifier 必须自己从 Git object 重算所有字段。
3. **Isolated candidate replay**: 在从 frozen base 创建的独立 validation
   worktree/branch 中，只重放 manifest 中的 Phase-2 commits，形成
   `PHASE2_CANDIDATE_HEAD`。`git diff 96bbfada..PHASE2_CANDIDATE_HEAD` 必须零越界，
   且五个 §3.1 product paths 全部出现。
4. **Pinned main and main equivalence**: invocation 必须传入完整
   `MAIN_HEAD_SHA`，并在开始/结束都断言 `refs/heads/main` 仍等于该 SHA；变化 → exit 2。
   candidate 与该 Git object（不是可变工作树）对五个 Phase-2 product paths 做逐文件
   Git blob + SHA-256 等价检查；对显式枚举的 Phase-2 immutable evidence roots 做
   tree SHA 等价。main 工作树只对 Phase-2 owned paths 要求 clean；无关并行 dirty paths
   记录但不阻塞，避免重造本 DR 要消除的 false FAIL。

   共享控制面不做模糊“marker 存在”检查。`main-equivalence.json` 必须为每项记录
   `{path, selector, expected_value, canonical_subdocument_sha256, source_commit}`，最终至少
   绑定：handoff frontmatter 的 `scope_proof_amendment` 精确路径、completion frontmatter
   的 `gate3_verdict: pass`、`gate3-verdict.md` 的 candidate HEAD 与 PASS verdict。
   candidate 与 pinned main 均重新抽取并核对；相同 marker 文本但错误值/hash 必须 FAIL。
5. **Acceptance target**: Group-0、Layer 2 与 Gate 3 针对
   `PHASE2_CANDIDATE_HEAD` 执行；同时绑定 main-equivalence manifest。两者缺一不可。
6. **Dogfood reuse rule**: 不以“五个 product files”或 mechanism 名称猜测复用资格。
   新建 canonical `dogfood-input-manifest.json`，至少绑定 dogfood 实际读取的三份机制文件
   （recovery、reference-runner、pair-driver）；`dataset_inputs` 必须含
   `dataset-index.json` blob SHA-256，以及按 pair_id/task_id 排序的每个
   `pairs/<task>/task.json` blob SHA-256（不得用包含 DONE/结果输出的整个 `pairs/` tree
   代替）；另绑定 canonical policy、approval blob、generator/harness CLI version、judge
   binary/model/family/version、model settings 与 canonicalization version。verifier 必须从
   最终 run 的 raw manifest、content-addressed raw inputs 与 candidate Git blobs 重算该
   input manifest；与 run
   `a6fe746c2ff351dff3c99e1fff584a171f5ee3d37b58417f131fb24a55a82f35`
   的输入逐项全等才可复用。只改 scope verifier/test/evidence 不触发 dogfood；任一
   dogfood input 改变则既有 run 失效，按 AC-J 新 namespace 全量重跑。若旧证据不能
   无歧义重建 input manifest，也必须重跑。旧 run 的任何输入若只能从可变 filesystem
   path 读取、不能绑定已提交 Git blob/tree 或 immutable content SHA，则直接判定不可重建。

7. **Single verifier and recomputation command**: 唯一权威入口为：

   ```text
   node .tad/scripts/yolo-recovery.test.mjs --case phase2-scope-proof \
     --base <full-sha> --main <full-sha> --candidate <full-sha> \
     --manifest <path> --evidence-dir <path>
   ```

   命令必须从 candidate validation worktree 执行；verifier 路径必须是 Git regular blob，
   拒绝 symlink。执行前后都验证工作树文件 SHA-256 等于
   `candidate:.tad/scripts/yolo-recovery.test.mjs` 的 Git blob 内容 SHA-256，并确认所有
   Phase-2 owned paths clean。Gate 4 必须重新运行该命令；carrier 的存在、记录正确的
   blob SHA 或手写 `RESULT=PASS` 都不是验收证据。

## 3. Required evidence

写入 `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/`：

```text
phase2-commit-manifest.json
candidate-tree.json
main-equivalence.json
dogfood-input-manifest.json
scope-proof.log
```

所有 JSON 使用 `format: yolo2-phase2-scope-proof-v1`，并共同绑定
`base_sha`、`main_sha`、`candidate_sha`、candidate tree SHA、verifier Git blob SHA-256、
完整 invocation、输入 carrier SHA-256 与 source→replay SHA mapping。`scope-proof.log`
记录 pre/post refs、verifier exit code 和其余 JSON 的 SHA-256；JSON schema 与 canonical
serialization 由 verifier 固定，Gate 4 从 Git objects/raw inputs 重算，禁止信任自报字段。

并更新既有 `scope-fixtures.txt`，证明以下红/绿/错误状态：

fixture 必须在临时 Git repo/worktree 中创建真实 commits 并走同一 verifier，不能只把
字符串追加到内存数组。至少覆盖：

1. main 含合法并行 Local Wiki commit，candidate 未包含它 → PASS；
2. manifest 或 candidate 含一个禁止路径 → FAIL；
3. 漏掉 product commit → FAIL；漏掉仅 evidence/control-plane commit → FAIL；
4. 先写禁止路径、后续 commit 回滚最终 tree → 仍 FAIL；
5. 将 frozen base 偷移到 `f967276f` → FAIL；
6. manifest diff SHA/patch-id/source SHA 被篡改 → FAIL；
7. main ref 在验证期间变化，或 Phase-2 owned path 有未提交修改 → exit 2；
8. marker 文本存在但 expected value/subdocument hash 错误 → FAIL。
9. 未经 DR 固定的 commit 被标为 excluded，或固定 exclusion 的 path-set/diff/parent
   任一漂移 → exit 2；固定 Local Wiki exclusion 正确存在 → PASS。

verifier 末行/退出码契约固定为：`RESULT=PASS`/0、`RESULT=FAIL`/1、
`RESULT=ERROR`/2；不得用 exit 0 承载 warning 或未执行状态。

## 4. Gate consequences

- AC-B 只有上述 ownership proof 与 equivalence proof 同时 PASS 才满足。
- AC-J 仍要求最终 Group-0 `NOT_SATISFIED=0, PARTIALLY_SATISFIED<=3`，随后
  code-reviewer 与 test-runner PASS，P0=0、P1=0。
- Group-0、code-reviewer、test-runner 三份最终报告必须绑定同一 tuple：
  `{candidate_sha, main_sha, scope_manifest_sha256, main_equivalence_sha256,
  product_tree_sha256, immutable_evidence_tree_sha256, verifier_output_sha256}`。
  任一报告缺字段或 tuple 不同，Layer 2 不成立。
- 当前 `HONEST_PARTIAL` 保持有效，直到新证明和 reviews 完成；本 DR 不预先把 Gate 3
  改成 PASS。
- 本修正不授权 Blake 修改 20260825 handoff、20260827 handoff或本 DR；若发现契约
  仍互斥，停止并回报 Alex。
- Blake 开工第一步须删除/重做当前未提交的 `PHASE2_SCOPE_BASE=f967276f` 尝试，使
  verifier 回到 frozen base；不得把该旧尝试提交为修复。随后在隔离 validation
  worktree 实现本 DR，不覆盖共享工作区的其他未提交文件。

## 5. Grounding

- `.tad/project-knowledge/patterns/handoff-design.md`：并行终端共享 Git 状态时，全局 gate
  在非安静点可能结构性失败，应使用 path-scoped evidence，且提交必须显式 pathspec。
- 同文件的 worktree grounding 规则：validation branch 的 base 是执行前提，不只是引用。
- `.tad/project-knowledge/patterns/gate-design.md`：Gate 数字与范围必须从原始 evidence
  重算，不能信 completion summary。
