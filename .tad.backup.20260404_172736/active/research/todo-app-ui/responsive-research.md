# Responsive Design Research — Todo App

## 1. Device Distribution [ASSUMPTION]
Based on general web usage patterns for productivity apps:
- Mobile (375px): ~55% of users — primary device for quick task capture
- Tablet (768px): ~10% — occasional use
- Desktop (1024-1440px): ~35% — extended task management sessions

[ASSUMPTION] These ratios are estimated based on general mobile-first trends for consumer productivity apps. Actual analytics would be needed for a production app.

## 2. Breakpoint Strategy

| Breakpoint | Name | Device | Nav Pattern |
|-----------|------|--------|-------------|
| 375px | sm | Phone portrait | Bottom tab bar (2-3 items) |
| 768px | md | Tablet portrait | Top header nav + sidebar toggle |
| 1024px | lg | Small desktop / tablet landscape | Persistent sidebar + content |
| 1440px | xl | Standard desktop | Sidebar + content (max-width container) |

## 3. Layout Shifts Per Page

### Task List Page
| Element | sm (375) | md (768) | lg (1024) | xl (1440) |
|---------|----------|----------|-----------|-----------|
| Navigation | Bottom tabs | Top header | Sidebar (240px) | Sidebar (240px) |
| Filter tabs | Horizontal scroll | Full width | Full width | Full width |
| Task list | Full width, 16px padding | 600px centered | Content area (fill) | Content area (max 720px) |
| FAB | Bottom-right, 48px | Bottom-right, 48px | Hidden (inline add bar) | Hidden (inline add bar) |
| Add task | FAB → slide-up input | FAB → slide-up input | Persistent top input | Persistent top input |
| Task item | Compact (checkbox + text) | Standard (+ meta) | Standard (+ actions visible) | Standard (+ actions visible) |

### Settings Page
| Element | sm (375) | md (768) | lg (1024) | xl (1440) |
|---------|----------|----------|-----------|-----------|
| Navigation | Bottom tabs | Top header | Sidebar | Sidebar |
| Settings list | Full width, stacked | 600px centered | 600px within content | 600px within content |
| Section headers | Standard | Standard | Standard | Standard |

## 4. Responsive Rules

### Spacing Rules
- sm: 16px page padding, 8px element gap
- md: 24px page padding, 12px element gap
- lg+: 32px page padding, 16px element gap

### Typography Rules
- sm: Base 16px (mandatory — prevents iOS auto-zoom), headings 20px
- md: Base 16px, headings 24px
- lg+: Base 16px, headings 24-32px

### Touch/Click Targets
- sm/md: Minimum 44x44pt touch targets on all interactive elements
- lg+: Minimum 32x32px click targets, hover states visible

### Navigation Switch
- <768px: Bottom tab bar (Tasks, Search, Settings)
- >=768px: Sidebar or top bar navigation

### Content Constraints
- Line width: max 65ch (mobile) / max 75ch (desktop) for readability
- Container max-width: 1200px on xl screens, centered

### Safety
- Use `env(safe-area-inset-*)` for notch/bottom bar on mobile
- Use `dvh` instead of `100vh` for mobile full-height layouts
