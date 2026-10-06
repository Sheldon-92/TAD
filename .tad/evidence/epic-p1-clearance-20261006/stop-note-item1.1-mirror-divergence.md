# 停步记录 — 件 1.1 镜像契约撞写集外分歧（Phase 1 中途）

- 时点：2026-10-06，TASK-20261006-EPIC-P1-CLEARANCE 实施 Phase 1，件 1.1 改造后自验。
- 停步依据：HANDOFF §9.2 红线「基线不符、写集外发现、判据矛盾即停步报 PM，不许自行改判据」。

## 已完成且在盘（停步时点）

- Phase 0 全量冻结：`baseline.md` ＋ `baseline-validate-sweep.txt`（63 目录 PASS 22／FAIL 41＝MQ-1）／`baseline-driftcheck.txt`／`baseline-state-surface.txt`（check5 恰 4 FAIL＝MQ-4）／`baseline-session-state-index.txt`／`baseline-product-thinking.txt`／`baseline-hooks-json.txt`／`baseline-cap-statements.txt`／`baseline-install-fixture.log`／`baseline-upgrade-fixture.log`（chain gap REJECT 原文在案）／`baseline-fixture-checks.txt`／`baseline-brainindex-gen-fixture.log`／`fixture-path.txt`（`/tmp/epic-p1-fix0-VeLuem`）。
  - 件 1.9 核查点三结论：(i) 初装目标树 brain-index **缺失**；(ii) 目标 AGENTS.md L43 路由与实存不一致；(iii) 目标侧生成器手动可跑通（exit 0）→ 处置走「(i) 为缺」支。
  - 件 1.6 落点预判：tad.sh 三写点分属 install/upgrade/migrate 分支，仅 install 分支（L2673）为初装可达，genesis 挂此。
  - CF-3 盘清：`resolve_chain` 全仓仅一调用点（engine main L975）。
- 件 1.1 校验器改造已落 `.tad/scripts/capability-skill.sh`（双类契约＋usage 头注，`bash -n` PASS）：全集复跑 PASS 22（原 PASS 22 中治理候选件不变）＋登记面 22/25 PASS（原 0/25）。

## 停步事实（写集外分歧，`.tad/evidence/epic-p1-clearance-20261006/ac-validator-25-detail.txt`）

登记面余 4 FAIL：
1. product-thinking：缺 type/keywords——设计内既定，由 Phase 2 件 4.1 补行解决，非停步因。
2. **agent-orchestration、web-frontend、web-testing：投影 `.agents/skills/<name>/SKILL.md` 的 `keywords:` 行是源包 `.tad/capability-packs/<name>/CAPABILITY.md` 的严格超集**（type 两侧一致）。增补词例：
   - agent-orchestration：+"Microsoft Agent Framework"、"orchestrator-worker"、"fan-out"、"failure mode"、"MAST"、"失败模式"
   - web-frontend：+"visual edit"、"browser edit"、"UI polish"、"visual bridge"
   - web-testing：+"WCAG 2.2"、"target-size"、"Test Agents"、"Stryker"、"mutation testing"、"突变测试"、"flaky"、"Core Web Vitals"、"INP"
   
   即：投影侧曾被增补关键词、源包未回同步。设计 §4.1-3 的镜像判据（与 CAPABILITY 逐字全等）以此事实无法在现写集内满足 AC1；收敛任一侧都要动 §7 写集外文件（3 件投影 SKILL.md 或 3 件 CAPABILITY.md），且哪侧为权威属设计级裁断，Blake 不自判。

## 待 PM 裁断（三案，含 Blake 倾向）

- **案 A（Blake 倾向）投影为准、回同步 CAPABILITY**：把 3 件投影的 keywords 行逐字回写源包 CAPABILITY.md。理由：投影是活体消费面（driftcheck B 探针／scan-packs／AGENTS.md 指针表都读投影），增补词形态像有意扩充；回同步只动 3 个源包文件一行、零消费面变化。写集需增：3 件 CAPABILITY.md。
- 案 B CAPABILITY 为准、投影回退：删投影增补词。代价：指针表与 scan-packs 关键词覆盖缩水，且增补若属既往有意变更则系信息丢失。
- 案 C 改判据为子集关系（投影 ⊇ CAPABILITY 声明值）：属 Gate 2 已判设计的判据变更，非 Blake 权限。

裁断前其余件（1.2–1.11）未开工；校验器改动保留在盘、不回滚（其本身与设计 §4.1 一字不差，分歧在数据面不在校验器）。

---

## 续跑记录（2026-10-06，PM 裁断后）

- **PM 裁断：采案 A**——三包以现行投影 SKILL.md 为有效源，CAPABILITY.md 向投影回同步；写集扩三件 CAPABILITY.md（仅 keywords 行）；§4.1 镜像判据本身不变。HANDOFF §7 已加 WRITE-SET EXPANSION 注记（扩写后 HANDOFF 为 54,502 B／sha256 `5cc953955d03688d9dbaf07daa71c5937c42077dd173a027fcb55baea7ea64a6`）。
- 执行结果：三件 CAPABILITY.md 的 `keywords:` 行已逐字回同步为投影行（type 两侧本已一致、无 version 行分歧）；回同步后三件 validate exit 0；件 4.1 落地后受治集 27/27 全 PASS（AC1）。全批结果见 COMPLETION-2026-10-06-epic-p1-clearance.md。本停步记录至此关闭。
