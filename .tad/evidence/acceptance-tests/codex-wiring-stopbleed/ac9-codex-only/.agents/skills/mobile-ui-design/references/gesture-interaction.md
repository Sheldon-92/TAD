# Gesture Interaction Design (Swipe / Long-Press / Pinch / Pull / Edge)

## Workflow

### Layer 1 — Research gesture practices
Web search:
1. Comparable apps' gesture interactions
2. iOS/Android system-level gestures (不可覆盖)
3. Solutions for gesture discoverability

Example queries:
- `"mobile gesture interaction" design pattern best practices`
- `"iOS swipe gesture" "long press" design guidelines`

Output: `gesture-research.md`.

### Layer 2 — Define the full gesture catalog
Table: `| 手势 | 触发条件 | 动作 | 平台差异 | 反馈 |`

**System-level gestures (MUST NOT be overridden):**
- iOS: 左边缘右滑 = 返回，底部上滑 = Home
- Android: 系统返回手势/按钮

**Custom gesture specs (concrete trigger values):**
- 左滑删除：滑动距离 ≥ 50pt 触发，显示红色删除按钮
- 长按菜单：≥ 500ms 触发，Haptic 反馈（medium impact）
- 下拉刷新：下拉 ≥ 60pt 触发，显示加载指示器
- 捏合缩放：最小缩放 0.5x，最大 3x
- 边缘手势：识别区域 20pt 从屏幕边缘

**Animation timing:**
- 微交互：150–300ms
- 页面转场：300–350ms
- 弹簧动画：iOS 默认 `.spring(response: 0.5, dampingFraction: 0.8)`
- 退出动画 = 进入动画 × 60–70%

Quality bar: every gesture has trigger conditions (pt/ms) and platform-difference notes; system gestures are excluded from customization. Append to `gesture-research.md`.

### Layer 3 — Derive the gesture spec
1. **Per-page gesture list**: `| 页面 | 手势 | 目标元素 | 动作 | Haptic |`
2. **Gesture conflict detection:**
   - 左滑删除 vs 左边缘返回 → 滑动起始区域区分
   - 长按菜单 vs 拖拽排序 → 状态机区分
3. **Discoverability plan:**
   - 首次使用提示（Tooltip/Coach Mark）
   - 视觉暗示（列表项微微露出删除按钮边缘）
   - 操作撤销（误操作后 Toast + Undo）
4. **Accessibility alternatives:**
   - 每个手势都有非手势替代（按钮/菜单）
   - VoiceOver/TalkBack 用户不依赖手势

Quality bar: conflicts identified AND resolved; every gesture has an accessibility alternative. Output: `gesture-spec.md`.

### Layer 4 — Generate artifacts
- D2 gesture state diagram (长按: idle → pressing → menu_shown → action_selected): `gesture-states.d2 → gesture-states.svg`
- Gesture interaction spec PDF (Typst): `gesture-interaction.pdf`

## Quality Criteria (pass/fail)
- 系统级手势已识别且不被覆盖
- 每个自定义手势有触发条件（pt/ms 数值）
- 手势冲突已检测并解决
- 每个手势有无障碍替代
- 有手势可发现性方案
- 编造数据 = FAIL。不确定标注 [ASSUMPTION]。
