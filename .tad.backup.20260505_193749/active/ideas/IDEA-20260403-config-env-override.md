---
Title: Config Environment Variable Override
Date: 2026-04-03
Status: captured
Scope: medium
---

## Summary & Problem
TAD config 只有 YAML 文件层，无法通过环境变量覆盖。OpenHarness 支持 4 层优先级（default → file → env → CLI）。在 CI/CD 或容器化部署场景中，环境变量覆盖是标准做法。

## Open Questions
- TAD 是否有 CI/CD 部署场景？目前主要是本地 CLI 使用
- 命名约定：TAD_MODEL? TAD_CONFIG_PATH?
- 是否需要 CLI 参数层？

## Potential Scope
Medium — 需要改 config 加载逻辑 + 文档

## Source
OpenHarness §Config (config/settings.py: _apply_env_overrides)
