# Mobile Accessibility Testing (VoiceOver / TalkBack)

VoiceOver (iOS) / TalkBack (Android) 无障碍合规测试。v1.0 以 iOS/VoiceOver 为主线，TalkBack 为扩展方向。

## Strategy: Two-Layer Coverage

1. **自动化层（覆盖 30-40%）**：
   - `eslint-plugin-react-native-a11y`（静态检查）
   - RNTL 的 `getByRole`/`getByLabelText` 查询（组件测试隐含 a11y 检查）
2. **手动层（覆盖剩余 60-70%）**：
   - VoiceOver 完整导航（所有页面逐元素检查）
   - 触控目标审计（≥44pt）
   - 动态字体测试（最大字号下布局不崩溃）
3. **WCAG 2.2 AA 对标**：
   - 对比度 ≥ 4.5:1
   - 触控目标 ≥ 44×44pt
   - 所有可交互元素有 `accessibilityLabel`
   - 表单有关联的 `accessibilityHint`

Quality bar: 自动化 + 手动双层覆盖，WCAG AA 标准对标。

## Static Checks

```
npx eslint src/ --ext .tsx,.ts --rule 'react-native-a11y/has-accessibility-props: error'
```

检查: 缺少 accessibilityLabel、缺少 accessibilityRole、Touchable 无 a11y 属性。

## VoiceOver Manual Checklist

每个页面检查（表格列: 页面 | 元素 | accessibilityLabel | 焦点顺序 | 操作提示 | PASS/FAIL）：
- 所有文本有合理朗读内容？
- 图片有描述性 label？
- 按钮 label 描述操作（"保存菜单"而非"按钮"）？
- 焦点顺序符合视觉逻辑？
- 自定义组件有正确的 accessibilityRole？

## Report

综合为可访问性报告（PDF），含 lint 结果 + 手动清单 + 修复建议。

## Quality Criteria (pass/fail)

- eslint-plugin-react-native-a11y 零 error
- 所有可交互元素有 accessibilityLabel
- 触控目标 ≥ 44×44pt
- 对比度 ≥ 4.5:1
- VoiceOver 手动测试清单已完成
- Fabricated accessibility results = FAIL
