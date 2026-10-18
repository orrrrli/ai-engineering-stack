# Artifact Report Format

The architecture review is one self-contained HTML page published with the Artifact tool. The `artifact-design` skill owns the page contract (title, color tokens, dark mode, allowed CDNs, phone width). This file owns the content: what each candidate card shows and how to draw it.

Title: `Architecture review` plus the repo name, e.g. `Locker architecture review`. Icon: `diagram`.

## Scripts

Mermaid is the only script the report needs. Pin an exact version:

```html
<script type="module">
  import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11.4.1/dist/mermaid.esm.min.mjs";
  const dark = matchMedia("(prefers-color-scheme: dark)").matches;
  mermaid.initialize({ startOnLoad: true, theme: dark ? "dark" : "neutral" });
</script>
```

No other app code, no interactivity beyond Mermaid's own rendering.

## Page structure

1. Header: repo name, date, the scope you explored (hot-spot paths or the user's direction).
2. One card per candidate, ordered by recommendation strength.
3. **Top recommendation**: one larger card. Candidate name, one sentence on why, anchor link to its card.

## Candidate card

The diagrams carry the weight. Prose is sparse, plain, and uses the glossary terms without ceremony.

Each candidate is one `<article>` with an `id` for the anchor link:

- **Title**: short, names the deepening (e.g. "Collapse the Match attendance pipeline").
- **Badge row**: recommendation strength (`Strong` = green, `Worth exploring` = amber, `Speculative` = neutral), plus a tag for the dependency category from [DEEPENING.md](DEEPENING.md) (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files**: monospaced list.
- **Before / After diagram**: the centrepiece. Two columns side by side; stacked on phone width.
- **Problem**: one sentence. What hurts.
- **Solution**: one sentence. What changes.
- **Wins**: bullets, 6 words or fewer each. e.g. "Tests hit one interface", "Fee math stops leaking", "Delete 4 shallow wrappers".
- **Decision callout** (if applicable): one line in an amber-tinted box naming the decision or past rejection it contradicts, and why reopening is worth it.

No paragraphs of explanation. If the diagram needs a paragraph to be understood, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Mix them; variety is part of the point.

- **Mermaid graph** (dependencies, call flow): a `flowchart` when the point is "X calls Y calls Z, and look at the mess." Color leakage edges red with `classDef`, the deep module with the accent. Sequence diagrams work for "before: 6 round-trips; after: 1."
- **Boxes and arrows** (when Mermaid's layout fights you): modules as bordered `<div>`s, arrows as inline SVG over a relative container. Use it when the "after" should read as one thick-bordered deep module with faded internals.
- **Cross-section** (layered shallowness): stacked horizontal bands for the layers a call passes through. Before: 6 thin bands each doing nothing. After: 1 thick band labelled with the consolidated responsibility.
- **Mass diagram** (interface as wide as the implementation): two rectangles per module, interface and implementation. Before: nearly the same height (shallow). After: short interface, tall implementation (deep).
- **Call-graph collapse**: before, a tree of calls as nested boxes; after, the same tree as one box with the now-internal calls faded inside.

Keep diagrams around 320px tall so before and after sit side by side without scrolling. Module labels inside diagrams in small uppercase, so they read as schematic, not UI. One accent color, plus red for leakage and amber for warnings.

## Tone

**Use exactly:** module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

**Never substitute:** component, service, unit (for module) · API, signature (for interface) · boundary (for seam) · layer, wrapper (for module, when you mean module).

Phrasings that fit:

- "Match attendance module is shallow: interface nearly matches the implementation."
- "Fee math leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: Postgres in prod, in-memory in tests."

**Wins** name the gain in glossary terms: "locality: bugs concentrate in one module", "leverage: one interface, N call sites". Never "easier to maintain" or "cleaner code".

No hedging, no throat-clearing. If a sentence could be a bullet, make it a bullet. If a bullet could be cut, cut it.
