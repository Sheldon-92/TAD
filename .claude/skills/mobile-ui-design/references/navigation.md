# Mobile Navigation Architecture (Tab Bar / Stack / Drawer / Bottom Sheet)

## Workflow

### Layer 1 — Research navigation patterns
Search mobile navigation references (web search):
1. Navigation structure of 3+ comparable apps in the target domain
2. iOS Tab Bar / Navigation Stack / Modal Sheet specs
3. Material Bottom Navigation / Navigation Drawer specs

Example queries:
- `"{领域}" iOS app navigation pattern tab bar`
- `"{领域}" mobile app information architecture`

Output: `navigation-research.md`.

### Layer 2 — Analyze hierarchy and needs
1. **Page inventory** from requirements: `| 页面 | 使用频率 | 层级深度 | 需要 Tab？ |`
2. **Navigation mode selection:**
   - Tab Bar（≤5 项高频页面）→ iOS/Android 主导航
   - Stack Navigation（详情页、子页面）→ push/pop
   - Modal Sheet（快速操作、创建表单）→ iOS 半屏/全屏
   - Drawer（低频设置、辅助功能）→ Android 更常见
3. **Reachability analysis (Thumb Zone):**
   - 底部 Tab Bar 在拇指热区 ✅
   - 顶部导航栏在拇指冷区 → 避免放高频操作
   - FAB 在右下角拇指自然位置 ✅
4. **Deep Link design**: does every page have an independent URL/path?

Quality bar: Tab Bar ≤5 项; 高频操作在拇指热区; 层级 ≤3 层. Append to `navigation-research.md`.

### Layer 3 — Derive navigation structure
1. Tab Bar items (≤5) + icon + label per item
2. Stack structure under each Tab (Root → Detail → Sub-detail)
3. Modal trigger points (which actions use Sheet instead of Push)
4. Gesture navigation:
   - 左滑返回（iOS 系统级）
   - Tab 间滑动切换？（参考竞品决定）

Quality bar: navigation structure has a D2 diagram; Tab Bar item names are verbs or nouns. Output: `navigation-design.md`.

### Layer 4 — Generate diagrams (D2)
- Navigation flow diagram (Tab → Stack → Modal relationships): `navigation-flow.d2 → navigation-flow.svg`
- Mobile sitemap: `mobile-sitemap.d2 → mobile-sitemap.svg`

## Quality Criteria (pass/fail)
- Tab Bar ≤ 5 项
- 页面层级 ≤ 3 层（Root → Detail → Sub-detail）
- 高频操作在拇指热区（底部区域）
- 每个页面有 Deep Link 路径
- 有导航流程图（D2）
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
