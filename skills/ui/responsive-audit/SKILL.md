---
name: responsive-audit
description: Review and audit UI components for mobile responsiveness and adaptive behavior
---

# Responsive & Mobile Audit

This skill performs a deep review of a UI component or page to ensure it follows mobile-first principles and works perfectly across all breakpoints.

## Audit Checklist

### 1. Layout & Viewport
- **Overflow Issues**: Check for horizontal scrolling on small viewports.
- **Flex/Grid Adaptation**: Ensure layouts stack correctly on mobile (e.g., `flex-col` on small screens).
- **Width/Height**: Avoid fixed pixel widths; use relative units (`%`, `vw`, `rem`) or max-widths.
- **Padding/Margins**: Ensure adequate spacing on small screens without wasting screen real estate.

### 2. Touch Interactivity
- **Touch Targets**: Minimum 44x44px for all clickable elements (buttons, links).
- **Spacing**: Sufficient gap between interactive elements to prevent accidental clicks.
- **Hover States**: Ensure functionality isn't dependent on hover (since mobile has no hover).
- **Focus States**: Check visibility for keyboard/assistive navigation.

### 3. Typography
- **Readability**: Minimum 16px for body text to avoid auto-zoom on iOS inputs.
- **Scaling**: Headers should scale down appropriately for small screens.
- **Line Height**: Adequate leading for readability on narrow columns.

### 4. Images & Media
- **Adaptability**: Images should use `max-width: 100%` and `height: auto`.
- **Loading**: Check if large images are being served to mobile (recommend `srcset` or optimized formats).
- **Aspect Ratio**: Ensure media doesn't break or distort on narrow viewports.

### 5. Mobile-Specific UX
- **Navigation**: Check if menus collapse into a "hamburger" or bottom bar on mobile.
- **Form Inputs**: Use correct `inputmode` (numeric, email, tel) to trigger the right mobile keyboard.
- **Modals/Drawers**: Ensure modals are usable on mobile (recommend drawers/sheets for mobile UX).

## Audit Report Format

When using this skill, generate a report with:
1. **Critical Issues**: (e.g., horizontal overflow, tiny buttons).
2. **UX Improvements**: (e.g., better typography scaling, better mobile patterns).
3. **Suggested Code Fixes**: Provide the specific CSS/Tailwind classes to fix the issues.
4. **Verification**: How to test the fix (breakpoints to check).
