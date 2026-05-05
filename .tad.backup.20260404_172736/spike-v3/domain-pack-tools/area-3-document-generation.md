# Area 3: 文档生成与转换工具

## 工具评估矩阵

| 工具 | 类型 | Claude Code 兼容 | 输出质量 | 免费额度 | 安装难度 | 推荐度 |
|------|------|-----------------|---------|---------|---------|--------|
| Pandoc + Typst | CLI | ✅ 已安装 | 高 (类 LaTeX) | 免费/无限 | 零 (已就绪) | ⭐⭐⭐ |
| Typst 直接 | CLI | ✅ 已安装 | 高 (精美排版) | 免费/无限 | 零 (已就绪) | ⭐⭐⭐ |
| Pandoc → DOCX/HTML | CLI | ✅ 已安装 | 中-高 | 免费/无限 | 零 (已就绪) | ⭐⭐⭐ |
| Slidev | CLI | ✅ via npx | 高 (Vue 渲染) | 免费/无限 | 中 (Node.js ≥20) | ⭐⭐ |
| Pandoc + reveal.js | CLI | ✅ 已安装 | 中 | 免费/无限 | 零 (已就绪) | ⭐⭐ |
| Gamma MCP | Cloud MCP | ✅ 需 OAuth | 高 (AI 演示) | Freemium | 低 (OAuth) | ⭐⭐ |
| Canva MCP | Cloud MCP | ✅ 需 OAuth | 高 (专业设计) | Freemium | 低 (OAuth) | ⭐⭐ |
| wkhtmltopdf | CLI | ⚠️ 已停止维护 | 低 | 免费 | 低 | ⭐ |

## 推荐工具

- **日常文档/报告**: `pandoc doc.md --pdf-engine=typst -o doc.pdf` — 零额外安装，快速高质量
- **专业排版**: `typst compile doc.typ` — 更精细控制（表格、样式、页眉）
- **演示文稿**: Gamma MCP (AI 生成) 或 Slidev (开发者)
- **品牌材料**: Canva MCP (海报、社交媒体图)

## 实测记录

### Test 1: Typst → PDF (专业报告)
```bash
typst compile competitive-report.typ competitive-report.pdf
# 结果: 39KB PDF，含表格、标题、样式。速度 <1s。质量优秀。
```

### Test 2: Pandoc → DOCX + HTML
```bash
pandoc test.md -o test.docx   # 11KB DOCX
pandoc test.md -t html -s -o test.html  # 4KB HTML
# 两者均成功，秒级完成。
```

### Test 3: Pandoc → reveal.js 幻灯片
```bash
pandoc test.md -t revealjs -s -o slides.html -V revealjs-url=https://unpkg.com/reveal.js
# 结果: 7KB HTML 幻灯片，浏览器可直接打开。
```
