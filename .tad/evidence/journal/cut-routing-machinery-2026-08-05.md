# Journal: cut-routing-machinery (2026-08-05)

- **多文件机械变换脚本的"整行 vs 子串"断言纪律（本单实现层的验证）**：apply-changes.py 对每个锚做唯一性断言（fail-fast），但**遗漏检查"我是否覆盖了契约的全部删除项"**——§3.2 Reviewer 档位规则子节（28 行×2 文件）没写进脚本，AC1/AC1b/AC3 全绿（它们冻结的是 untouched 内容），只有 AC2 的负向锚抓到残留（RouteDecision/强档/REVIEWER-TIER-DEGRADED 等 token）。教训：**多变换脚本的完整性要靠"AC 负向锚全量"来兜**，不是靠脚本作者逐条对照规格——AC2 在这里从"验证细节"升级为"抓住实现遗漏的哨兵"。AC4 的字符带（44-47K）是第二道哨兵：合计 48,938 超上限，与"少删 2×28 行"的差量吻合。Repair Round 1 用 fix-reviewer-tier.py 补上，边界与契约实测 28 行一致。

- **修复类 AC 的判别力需要"旧实现负向控制"（延续 pricing-gate-scan-fix 的手法）**：code-reviewer 在 /tmp 副本复演 v1 逃逸（掏空 Forbidden + 换哨兵）→ 正向锚归 0、md5 变，两条攻击路径被 AC2/AC3 抓住。加上 pre-impl 的 AC2/AC3/AC4 FAIL 记录，判别力链条 = 预实现 FAIL（机器还在）+ 攻击复演 FAIL（掏空被抓）+ 实现后 PASS（删干净了）。

- **版本横幅豁免的显式化优于沉默**（契约 §2 的做法）：README/CHANGELOG/INSTALLATION_GUIDE L3 等的版本串是发布史记录不是行为承诺，契约显式豁免 → 下个 reviewer 不必重扫。与「把不该删的当该删」的静默假设形成对比：**在砍除单里，显式列出"不删什么"和列出"删什么"同等重要**。
