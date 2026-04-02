# Area 4: 图表与可视化工具

## 工具评估矩阵

| 工具 | 类型 | Claude Code 兼容 | 输出质量 | 免费额度 | 安装难度 | 推荐度 |
|------|------|-----------------|---------|---------|---------|--------|
| Python matplotlib | CLI | ✅ 已安装 | 高 | 免费/无限 | 零 (已就绪) | ⭐⭐⭐ |
| Mermaid CLI (mmdc) | CLI | ⚠️ 需 Puppeteer/Chrome | 高 (10+ 图表类型) | 免费/无限 | 中 (npm + Chrome) | ⭐⭐ |
| D2 | CLI | ✅ brew install | 高 (现代架构图) | 免费 (TALA 布局付费) | 低 (brew) | ⭐⭐⭐ |
| Vega-Lite | CLI | ✅ pip/cargo | 高 (数据可视化) | 免费/无限 | 低 | ⭐⭐ |
| PlantUML | CLI | ⚠️ 需 Java + graphviz | 中 (UML 专精) | 免费/无限 | 中 | ⭐ |
| ASCII 图表 | 内置 | ✅ 零依赖 | 低 (纯文本) | 免费 | 零 | ⭐⭐ |

## 推荐工具

- **数据图表**: **Python matplotlib** — 已安装，直接可用，PNG+SVG 输出
- **架构/流程图**: **D2** — `brew install d2`，语法简洁，布局智能，视觉现代
- **流程图/时序/旅程**: **Mermaid CLI** — 覆盖最广，但需 Puppeteer (sandbox 环境可能受限)
- **快速示意**: **ASCII** — 零依赖，嵌入 Markdown 完美

## 实测记录

### Test: Python matplotlib → PNG + SVG
```bash
python3 -c "
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
# ... bar chart code ...
plt.savefig('chart.png', dpi=150)
plt.savefig('chart.svg')
"
# 结果: 34KB PNG + 27KB SVG 竞品对比图。秒级完成。
```

### Mermaid CLI 测试失败记录
```bash
npx @mermaid-js/mermaid-cli -i test.mmd -o test.svg
# Error: spawn Unknown system error -88
# 原因: Puppeteer 需要 Chrome，sandbox 环境不支持
# 解决: 需要本地安装 Chrome 或使用 mermaid.ink API (HTTP)
```

## 关键发现

- **Mermaid CLI 在 sandbox 环境受限** — 依赖 Puppeteer/Chrome，不适合所有环境
- 替代方案：`mermaid.ink` HTTP API (`https://mermaid.ink/img/<base64>`) 可绕过本地依赖
- D2 是纯 Go 二进制，无浏览器依赖，更适合 CLI 场景
