# Mini-Handoff: v2.7 Hook Live Verification

**From:** Alex | **To:** Blake | **Date:** 2026-04-01
**Type:** Verification (no new code, only testing)

---

## Task

验证 v2.7 两个未测试的 hook 行为。用 self-test agent 方式，不手动开 terminal。

## Test 6: PostToolUse async additionalContext 送达

**步骤**:
1. Write 工具写入一个测试文件 `.tad/active/handoffs/HANDOFF-test-posttool.md`（应触发 post-write-sync.sh）
2. 检查模型是否收到 additionalContext（应包含 "Handoff detected" 或类似提醒）
3. 删除测试文件

**PASS**: 写入 HANDOFF-*.md 后，模型可见 hook 注入的提醒信息
**FAIL**: 写入后无任何 hook 响应 → async 送达不工作

## Test 7: PreToolUse Haiku hook 触发 + 延迟

**步骤**:
1. 记录当前时间
2. Write 工具写入一个测试文件（任意路径）
3. 记录完成时间
4. 计算延迟（应在 2-5 秒内）
5. 检查 Haiku hook 是否触发（如果配置了 matcher 对所有 Write 生效）
6. 删除测试文件

**注意**: 检查 .claude/settings.json 的 PreToolUse 配置 — 如果 matcher 只对特定路径生效，需要写入匹配的路径来触发。

**PASS**: PreToolUse 触发，延迟 <10 秒
**FAIL**: 不触发 或 延迟 >10 秒

## Acceptance Criteria

- [ ] AC1: Test 6 执行并记录结果（PASS/FAIL + 证据）
- [ ] AC2: Test 7 执行并记录结果（PASS/FAIL + 延迟数据）
- [ ] AC3: 结果追加到 `.tad/tests/test-domain-pack.md` 或单独输出
- [ ] AC4: 如果任何 test FAIL，记录原因和建议修复方案

---

**Handoff Created By**: Alex
