# Area 1: 设计与原型工具

## 工具评估矩阵

| 工具 | 类型 | Claude Code 兼容 | 输出质量 | 免费额度 | 安装难度 | 推荐度 |
|------|------|-----------------|---------|---------|---------|--------|
| Figma MCP (官方) | MCP | ✅ 双向读写 | 高 (原生 Figma) | 6 次/月 (Starter)；无限 (Dev $25/月) | 低 (1 行配置) | ⭐⭐⭐ |
| Frame0 MCP | MCP | ✅ 自然语言→线框图 | 中 (低保真 wireframe) | 免费核心；导出 HTML 付费 | 中 (需 Frame0 桌面 app + Node 22) | ⭐⭐ |
| MockFlow MCP | MCP | ✅ 输出是 URL 不是文件 | 中 | 需账户（免费层不明确）| 中 (npm + 登录) | ⭐ |
| Excalidraw CLI | CLI | ⚠️ 可用但粗糙 | 低 (手绘风格) | 免费 | 低 (npx) | ⭐ |

## 推荐工具

- **首选**: **Figma MCP** — 原生 Claude Code 集成，双向读写（创建帧、组件、变量），输出 React/Tailwind 代码。write-to-canvas 仍在 beta。限制：免费层仅 6 次/月。
- **备选**: **Frame0 MCP** — 真正的"文字→wireframe"，适合 TAD playground 快速探索。需 Frame0 桌面 app 常驻。

## 关键发现

- Figma MCP 是目前最成熟的设计工具 MCP，但免费额度极低
- 设计工具领域 MCP 生态仍在早期，大多数工具输出质量有限
- 对于不需要 Figma 的场景，HTML + CSS 原型（Claude 直接生成）可能是最实用的方案
