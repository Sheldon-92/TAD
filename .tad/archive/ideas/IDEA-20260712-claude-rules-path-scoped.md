# IDEA: .claude/rules/ 路径作用域规则承载部分 L2 注入
**Date**: 2026-07-12 | **Status**: promoted | **Scope**: exploratory | **Source**: S2b chain
.claude/rules/ 支持 path-scoping + frontmatter,按路径条件加载。候选: 把"碰 .tad/hooks/**
才需要的 shell-portability 约束"类内容从全量 @import 挪到 path-scoped rule。
先小样试点一个文件,量 context 差异再说。细节在 notebook b07a6598 可追问。

**Promoted To**: Epic (via *analyze — 2026-07-12, native-capability-adoption)
