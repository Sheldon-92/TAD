# Component Specification — FlowPM Design System

## Atomic Design Hierarchy

### Atoms
Button, Input, Badge, StatusBadge, PriorityIcon, Avatar, Icon, Typography, Checkbox, Toggle

### Molecules
SearchBar (Input + Icon + Dropdown), FormField (Label + Input + ErrorMsg), AvatarStack, IssueCard, StatusBadge+Label

### Organisms
KanbanColumn, Header/Topbar, Sidebar, CommandPalette, IssueDetailPanel, TimelineBar, BulkActionBar, SettingsForm

---

## Component Specifications (15 components)

### 1. Button
- **Variants**: Primary (teal bg + white text), Secondary (white bg + border), Ghost (no bg/border), Danger (error bg)
- **Sizes**: sm (28px h, 12px text), md (36px h, 14px text), lg (44px h, 16px text)
- **States**: Default, Hover, Focus, Active, Disabled, Loading
- **A11y**: role="button", aria-disabled when disabled, aria-busy when loading, focus ring 2px offset
- **Rules**: Label = verb first ("Create Issue" not "Issue Creation"). Max 1 Primary per action group. Loading replaces label with spinner.
- **Do**: Use Primary for the single most important action.
- **Don't**: Don't use two Primary buttons side-by-side. Don't use Danger without confirmation modal.

### 2. Input
- **Variants**: Text, Password, Search, Textarea, Select
- **Sizes**: sm (32px h), md (40px h), lg (48px h)
- **States**: Default, Hover, Focused, Filled, Error, Disabled
- **A11y**: Always paired with <label> (visible or sr-only). aria-describedby for error messages. aria-invalid="true" on error.
- **Rules**: Label above input. Validate on blur (not on keystroke). Error message below input in error color. Placeholder is hint, never label replacement.
- **Do**: Show character count for limited fields. Use inline validation.
- **Don't**: Don't use placeholder as the only label. Don't validate while typing (wait for blur).

### 3. IssueCard (PM-specific)
- **Variants**: Compact (board card — title + meta), Expanded (list item — title + all fields), Selected (highlight bg)
- **Content**: ID badge, Title (1-2 lines, truncate), Priority icon, Assignee avatar, Labels (max 2 visible + "+N")
- **States**: Default, Hover (shadow lift), Focus (outline), Selected (primary-light bg), Dragging (shadow lg + slight scale), DropTarget (dashed border)
- **A11y**: role="article", aria-label with full issue description. Keyboard navigable with arrow keys. Draggable with "D" shortcut.
- **Rules**: Card height flexible by content but max 3 lines title. No shadow AND border together (use border by default, shadow on hover).
- **Do**: Show most critical info without clicking. Use priority icon colors for quick scanning.
- **Don't**: Don't show more than 2 labels inline. Don't auto-play any animation on cards.

### 4. KanbanColumn (PM-specific)
- **Variants**: Standard, Collapsed (icon + count only, 48px wide)
- **Content**: Column header (status name + count + add button), Card list (scrollable), Drop zone
- **States**: Default, DropTarget (highlighted), Empty (empty state message), Collapsed
- **A11y**: role="region" aria-label="[Status] column, [N] issues". Cards are a listbox within.
- **Rules**: Min-width 280px, max-width 360px. Sticky header on scroll. Column count updates on drag.
- **Do**: Show empty state with CTA when column has no cards.
- **Don't**: Don't allow more than 8 columns visible (horizontal scroll for rest).

### 5. StatusBadge (PM-specific)
- **Variants**: Todo (gray dot), InProgress (dark dot), InReview (medium dot), Done (light dot with check), Cancelled (strikethrough)
- **Sizes**: sm (dot only, 8px), md (dot + label, 24px h)
- **States**: Default only (status is not interactive in badge form)
- **A11y**: aria-label="Status: [value]". Dot color alone is not sufficient — always pair with text label for color-blind users.
- **Rules**: Color meanings: gray=todo, teal=in-progress, amber=review, green=done. Never rely on color alone.
- **Do**: Always show text label except in extremely space-constrained contexts (then use tooltip).
- **Don't**: Don't use more than 6 status values (cognitive overload).

### 6. PriorityIcon (PM-specific)
- **Variants**: Urgent (3 bars, error color), High (2 bars, dark), Medium (1 bar, mid), Low (empty bar, muted), None (no icon)
- **Sizes**: sm (14px), md (16px)
- **A11y**: aria-label="Priority: [value]". Title attribute as tooltip.
- **Rules**: Bar-based icon (not color-only). Urgent uses error color; others use grayscale.
- **Do**: Use consistent positioning (always before or always after title).
- **Don't**: Don't use emoji for priority. Don't use color as the only differentiator.

### 7. AvatarStack (PM-specific)
- **Variants**: Stack (overlapping, -8px margin), Inline (side by side, 4px gap)
- **Content**: Avatar circles with initials or image, +N overflow indicator
- **Sizes**: sm (20px), md (24px), lg (32px)
- **A11y**: Each avatar has aria-label with person name. Stack has aria-label "Assigned to: [names]". Overflow shows tooltip with full list.
- **Rules**: Max 3 visible in stack, then "+N" pill. Stacking order: left to right = most recent assignment first.
- **Do**: Use consistent colors for initials (deterministic hash from name).
- **Don't**: Don't show more than 5 avatars inline (use stack).

### 8. TimelineBar (PM-specific)
- **Variants**: Standard (horizontal bar), Milestone (diamond marker), Dependency (arrow between bars)
- **Content**: Colored bar spanning date range, label on bar or tooltip
- **States**: Default, Hover (tooltip with dates + details), Selected (thicker bar + highlight), Overdue (error color)
- **A11y**: aria-label="[Issue title], [start date] to [end date], [status]". Keyboard navigable.
- **Rules**: Minimum bar width 20px (even for 1-day tasks). Overdue bars show in error color. Today line as dashed vertical.
- **Do**: Show dependencies as arrows between related bars.
- **Don't**: Don't render more than 50 bars without virtualization.

### 9. Modal
- **Variants**: Confirm (title + message + actions), Form (title + form fields + actions), Alert (title + message, no cancel)
- **Sizes**: sm (400px), md (520px), lg (640px)
- **States**: Opening (200ms scale+opacity), Open (focus trapped), Closing (140ms reverse)
- **A11y**: role="dialog", aria-modal="true", aria-labelledby pointing to title. Focus trap (Tab cycles within modal). Close on Escape. Return focus to trigger on close.
- **Rules**: Always have close affordance (X button + Escape + Cancel). Destructive actions use Danger button. Max 1 modal visible at a time (no stacking).
- **Do**: Auto-focus first interactive element on open.
- **Don't**: Don't use modal for content that needs to reference the page behind it (use side panel instead).

### 10. CommandPalette
- **Variants**: Search mode (default), Command mode (> prefix), Filter mode (in: project: etc.)
- **Content**: Search input, result sections (Recent / Issues / Projects / Commands), keyboard hints
- **States**: Closed, Open (200ms), Typing (results update at 200ms debounce), Selected (highlighted result)
- **A11y**: role="dialog", aria-label="Command palette". Input has role="combobox". Results are role="listbox" with aria-activedescendant. Arrow keys navigate, Enter selects.
- **Rules**: Max 10 results per section. Show keyboard shortcut hints (Cmd+K to open, arrows to navigate). Persist recent searches.
- **Do**: Show "No results" state with suggestion to broaden search.
- **Don't**: Don't close on blur if user is still interacting with results.

### 11. Toast/Notification
- **Variants**: Success (green icon), Error (red icon, persistent), Warning (amber icon), Info (blue icon)
- **Content**: Icon + message + optional action button ("Undo", "Retry")
- **States**: Entering (300ms slide up), Visible (5s for non-error), Dismissing (200ms slide out)
- **A11y**: role="alert" for errors, role="status" for success/info. aria-live="polite" for non-urgent, "assertive" for errors.
- **Rules**: Auto-dismiss at 5s (success/info/warning). Error toasts persist until dismissed. Max 3 visible at once (stack). Destructive action toasts MUST have Undo (8s window).
- **Do**: Include action button for recoverable operations.
- **Don't**: Don't use toast for critical info that requires user decision (use modal).

### 12. Sidebar Navigation
- **Variants**: Expanded (220px), Collapsed (48px, icon-only), Mobile (overlay from left)
- **Content**: Workspace name, nav items with icons, project tree, settings at bottom
- **States**: Expanded (default desktop), Collapsed (toggle), Mobile-open (overlay with backdrop)
- **A11y**: nav role="navigation" aria-label="Main". Expandable items use aria-expanded. Active item has aria-current="page".
- **Rules**: Max 7 top-level items. Active item visually distinct (bg highlight + font weight). Bottom-pinned: Settings.
- **Do**: Show badge counts for items with updates (Inbox).
- **Don't**: Don't nest more than 2 levels deep.

### 13. Table/List
- **Variants**: Default (full table), Compact (reduced padding), Selectable (checkboxes)
- **Content**: Sticky header, sortable columns (click header), row hover highlight
- **States**: Default, Row hover (bg lighter), Row selected (primary-light bg), Column sorting (arrow icon)
- **A11y**: Proper <table> markup or role="table". Sortable headers: aria-sort="ascending/descending/none". Row selection: aria-selected.
- **Rules**: Sticky header on scroll. Numbers right-aligned. Text left-aligned. Sortable columns show direction arrow.
- **Do**: Show empty state when no data. Support Shift+click for range select.
- **Don't**: Don't wrap text in table cells (truncate with tooltip).

### 14. Dropdown/Select
- **Variants**: Single select, Multi select (checkboxes), Command (with search input)
- **Content**: Trigger button, dropdown panel with items, optional search
- **States**: Closed, Open (below trigger, 200ms), Item hover, Item selected (check icon)
- **A11y**: Trigger: aria-haspopup="listbox", aria-expanded. Listbox: role="listbox". Items: role="option", aria-selected. Type-ahead search.
- **Rules**: Max 7 visible items without scroll. Destructive options (Delete) in red at bottom. Searchable when >7 options.
- **Do**: Show selected value in trigger. Support keyboard (arrows, Enter, Escape).
- **Don't**: Don't use dropdown for 2-3 options (use radio or segmented control).

### 15. Empty State
- **Variants**: First-use (welcome message + setup CTA), No results (search yielded nothing), Error (failed to load)
- **Content**: Illustration placeholder (64px icon), Title (16px), Description (14px), CTA button
- **States**: Default only
- **A11y**: Descriptive text readable by screen readers. CTA is focusable.
- **Rules**: Positive framing ("No issues yet — create your first!" not "Nothing here"). Single CTA. Illustration is decorative (aria-hidden).
- **Do**: Guide user to the next action.
- **Don't**: Don't show empty state for momentary loading (show skeleton instead).
