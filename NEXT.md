# 下一步行动

## 已完成 (2026-01-06)

### TAD v1.4 发布
- [x] MQ6 强制技术搜索 - 所有技术决策触发搜索，深度自动判断
- [x] Research Phase - 过程中按需搜索 + 最终技术回顾
- [x] Skills 知识库系统 - `.claude/skills/` 自动发现
- [x] Learn 记忆系统 - `/tad-learn` 框架级建议记录
- [x] 内置 Skills - ui-design.md, skill-creator.md
- [x] 更新 install.sh 安装脚本
- [x] 创建 upgrade-to-v1.4.sh 升级脚本
- [x] 更新版本号和配置文件

## 今天

- [ ] 测试 v1.4 安装脚本在新项目中的效果
- [ ] 测试 v1.3 → v1.4 升级脚本
- [ ] 提交 v1.4 代码到 GitHub

## 本周

- [ ] 在实际项目中测试 MQ6 和 Research Phase
- [ ] 收集使用反馈，优化 Skills 内容
- [ ] 考虑添加更多内置 Skills（如 api-design.md）

## 待定

- [ ] 根据使用反馈优化 /tad-learn 工作流
- [ ] 考虑 Skills 的版本管理机制
- [ ] 探索 MQ6 搜索结果的缓存/复用

## 阻塞/等待

（无）

---

## v1.4 变更摘要

| 模块 | 文件 | 说明 |
|------|------|------|
| MQ6 | `.tad/config.yaml` | 新增 MQ6_technical_research 配置 |
| Research Phase | `.tad/config.yaml` | 新增 research_phase 配置 |
| Skills System | `.tad/config.yaml` | 新增 skills_system 配置 |
| Learn System | `.tad/config.yaml` | 新增 learn_system 配置 |
| /tad-learn | `.claude/commands/tad-learn.md` | 新命令 |
| ui-design | `.claude/skills/ui-design.md` | 内置 Skill |
| skill-creator | `.claude/skills/skill-creator.md` | 元技能 |
| install.sh | `install.sh` | 更新到 v1.4 |
| upgrade | `upgrade-to-v1.4.sh` | 新升级脚本 |
