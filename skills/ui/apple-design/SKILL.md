---
name: apple-design
stacks: [ios]
description: Apple's design rules for iOS screens you can check in a static design file — translucent materials and depth, typography (text styles, weight, leading, Dynamic Type), accessibility variants (Reduce Transparency, Increase Contrast), and Apple's eight design principles with their tactical rules (feedback, wayfinding, grouping, labels). Use when designing or reviewing an iOS screen in a design tool such as pen.dev or Figma, or when asked whether a screen "feels like iOS". For motion and gestures in code use swiftui-motion.
---

# Apple Design (static iOS screens)

Apple's rules for how an iOS screen should look, limited to what a static frame can show. Motion,
gestures and haptics are behavior, not pixels: they live in `swiftui-motion`.

Each rule below is a check. When reviewing a screen, report the rule it breaks, where, and the fix.
When building one, apply them before showing it.

## 1. Materials and depth: translucency shows hierarchy

Apple uses translucent materials as a floating layer that adds structure without stealing focus.

- **Bars, toolbars and sheets float over content.** Content scrolls underneath a translucent layer;
  it does not stop at an opaque strip. Name the material on the layer so the build matches it:
  `ultraThinMaterial`, `thinMaterial`, `regularMaterial`, `thickMaterial`, `ultraThickMaterial`.
- **Material weight encodes hierarchy.** Heavier materials separate structural regions. Lighter ones
  draw attention to interactive elements.
- **Never stack a light translucent surface on another.** Legibility collapses.
- **Bigger surfaces read as thicker:** a heavier material and a deeper shadow than a small chip.
- **Dim to focus, separate to keep flow.** A modal task gets a dimming scrim and pushes the background
  back. A parallel, non-blocking panel uses translucency and offset without a scrim. Stacked sheets
  dim each parent a step further.
- **Text over a material uses vibrant or semantic colors**, not a flat gray picked by eye. Put brand
  color on a solid layer, not on the translucent one.
- **Scroll edge effects, not hard dividers.** Where content meets floating chrome, fade it. Draw a
  1pt separator only where the system draws one (list rows, grouped sections).

## 2. Typography: text styles, not font sizes

- **Use the system text styles** and name them in the design, so the build maps 1:1 to
  `.font(.headline)` and Dynamic Type works. Default (Large) sizes, size/leading in pt:

  | Style | Size / leading | Weight |
  | --- | --- | --- |
  | Large Title | 34 / 41 | Regular |
  | Title 1 | 28 / 34 | Regular |
  | Title 2 | 22 / 28 | Regular |
  | Title 3 | 20 / 25 | Regular |
  | Headline | 17 / 22 | Semibold |
  | Body | 17 / 22 | Regular |
  | Callout | 16 / 21 | Regular |
  | Subheadline | 15 / 20 | Regular |
  | Footnote | 13 / 18 | Regular |
  | Caption 1 | 12 / 16 | Regular |
  | Caption 2 | 11 / 13 | Regular |

- **Build hierarchy from weight + size + leading as a set**, not size alone. Emphasize with weight:
  it adds presence without taking space. One hierarchy lever at a time.
- **Tracking changes with size; never one value for every size.** SF applies it per size on its own.
  In a design tool, use Apple's tracking table from the HIG Typography page; never invent a value or
  copy one size's tracking to another.
- **Leading tracks size inversely:** tight on large titles, looser on body.
- **Default to SF Pro.** It ships optical sizing, tracking tables and legibility tuning. A custom face
  needs a reason, and still has to scale with Dynamic Type.
- **Design for Dynamic Type.** Check every screen at the largest accessibility size: rows grow, text
  wraps instead of truncating, horizontal layouts stack vertically.

## 3. Accessibility variants you can draw

Three system settings change how a screen looks. Each one is a frame variant, not an afterthought.

- **Reduce Transparency:** translucent surfaces become solid. Draw the bars and sheets opaque and check
  the screen still reads.
- **Increase Contrast:** near-solid backgrounds and defined borders. Check that separators and secondary
  text still clear contrast.
- **Contrast floor:** 4.5:1 for body text, 3:1 for large text (18pt+, or 14pt+ bold) and for icons
  and control boundaries, in both light and dark.
- **Touch targets are at least 44x44pt**, even when the visible glyph is smaller.
- **Light and dark from semantic colors** (`label`, `secondaryLabel`, `systemBackground`,
  `secondarySystemBackground`, `separator`). A hardcoded hex breaks one of the two modes.
- Avoid large brightness jumps between adjacent screens.

## 4. The eight principles

From *Principles of Great Design* (WWDC 2026). Use them as the names you reason with.

1. **Purpose.** Decide what not to build. Every element spends the user's time and attention.
2. **Agency.** Keep people in control. Easy undo for slips; a confirmation only for destructive,
   irreversible actions. Overusing confirmations trains people to tap through them.
3. **Responsibility.** Act in the user's interest. Ask for permissions at the moment they're needed,
   only for what's needed, and say why.
4. **Familiarity.** Build on what people know. Stock components, standard placement, SF Symbols with
   their usual meaning. Things that look the same behave the same. Break a pattern only with proof.
5. **Flexibility.** Design for every context and ability: Dynamic Type, VoiceOver order, one-handed
   reach, long localized strings.
6. **Simplicity, not minimalism.** Strip the unnecessary so the core purpose is obvious. Show the
   common path first, advanced options one level deeper. Sometimes adding context simplifies.
7. **Craft.** Every spacing, alignment and color is a value you can defend. Misaligned icons and
   off-grid spacing read as carelessness.
8. **Delight.** The result of getting the other seven right, not confetti on top.

Tactical rules that serve them:

- **Feedback comes in four kinds:** status, completion, warning, error. Draw each one: the loading
  state, the success state, the inline validation error (inline, not on submit), the empty state.
- **Wayfinding.** Every screen answers: Where am I? Where can I go? How do I get out? A screen with no
  title, no back and no close traps the user.
- **Grouping and mapping.** Proximity implies relationship. Put a control next to what it changes. If
  a control needs a label to explain what it affects, the mapping is weak.
- **Specific labels beat generic ones.** Name tabs and buttons for what they hold or do ("Payments",
  "Confirm attendance"), not "Home" or "OK".

## Output

When reviewing, one line per finding: screen, rule (section number and name), what is wrong, the fix.
Order by impact on the user, not by section. End with what already holds up, in one line.

## Source

Adapted from [emilkowalski/skills `apple-design`](https://github.com/emilkowalski/skills/tree/main/skills/apple-design)
(MIT, commit `e8a175d`, read 2026-10-09). Kept: materials, typography, accessibility, the eight
principles. Changed: CSS (`backdrop-filter`, `rem`, `@media`) replaced with iOS materials, text styles
and system settings; the text style table added. Moved out: sections 1-11 and 13 (response, gestures,
springs, momentum, rubber-banding, haptics) live in `swiftui-motion`, because a static frame can't
show them.
