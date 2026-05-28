# Idea: Capability Pack Behavioral Examples

**ID:** IDEA-20260527-pack-behavioral-examples
**Date:** 2026-05-27
**Status:** promoted
**Scope:** medium

---

## Summary & Problem

每个 Capability Pack 加 `examples/` 目录，包含 2-3 个 scenario input + expected output 对，作为 pack 的 behavioral eval fixture。解决的问题：当前 pack 修改后无法证明"agent 行为真的变好了"——只能验证文件结构和规则存在，不能验证规则生效。ViMax 升级中 product-expert 和 YOLO audit（Codex + Gemini）独立指出同一缺口。

灵感来源：html-anything 的 `example.html` 模式——每个 skill 自带 ground truth 输出，验收时对比即可。

## Open Questions

- Example 格式：`{scenario}-input.md` + `{scenario}-expected-output.md` 对？还是单文件 fixture（含 input + expected markers）？
- 验证方式：subagent 跑 input 然后 grep expected markers（类似 ViMax AC15）？还是 LLM 判断相似度？
- 每个 pack 最少几个 example？2 个 minimum？3 个？
- 已有的 13 个 pack 是否需要回填 example？还是只要求新 pack / 新 capability 必须带？
- install.sh 是否需要改动来处理 examples/ 目录？

## Notes

- 研究来源：html-anything deep research notebook `d7022a6e-8de5-4e52-8f7c-1518cd4f6d76` (19 sources, 4 ask rounds)
- 研究发现：`.tad/evidence/research/html-anything/2026-05-27-deep-ask-findings.md`
- 已有先例：ViMax upgrade 的 pre/post output 对比（Step 0 + Step 7.5）就是手动版 behavioral eval
- YOLO audit 建议（architecture.md）："Add mandatory behavioral eval per pack: 3-5 before/after task comparisons with fixed rubric before marking accepted"
- html-anything 的 example.html 是 skill 的一部分（checked into repo），不是事后补的 fixture

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: Handoff (via *analyze — 2026-05-27)
