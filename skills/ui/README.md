# UI

Design and motion skills for native iOS apps. Installed with `--stack=ios`.

- **[apple-design](./apple-design/SKILL.md)** — Apple's rules for static iOS screens: materials and depth, text styles and Dynamic Type, accessibility variants, and the eight design principles. For designing or reviewing a screen in a design tool.
- **[swiftui-motion](./swiftui-motion/SKILL.md)** — Build motion in SwiftUI (iOS 17+) in the order that decides whether it feels right: gate, purpose, API, spring, interruption, drag handoff, haptics, Reduce Motion.

## Sources

Both skills are adapted from [emilkowalski/skills](https://github.com/emilkowalski/skills)
(MIT, commit `e8a175d`, read 2026-10-09). Each file's Source section says what changed.

| Upstream skill | Taken | Left out, and why |
|----------------|-------|-------------------|
| `apple-design` | Sections 12, 14, 15, 16 into `apple-design`; sections 1-11 and 13 into `swiftui-motion` | Section 17 (process): advice, not a check. Every CSS and JS example: replaced with iOS equivalents |
| `animate` | Build sequence, gate tables, never-ship list into `swiftui-motion` | Tool table (CSS, WAAPI, Motion), cubic-bézier tokens, hover gating: web only. `RECIPES.md`: web components |
| `animate-expo`, `mobile-native`, `emil-design-eng`, the animation review and audit skills | Nothing | Built for React, React Native or the browser |
