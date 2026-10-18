---
name: improve-codebase-architecture
stacks: [all]
description: Scan a codebase for deepening opportunities, informed by the project's .claude/ context tree and past decisions in engram, present them as a claude.ai Artifact report, then grill through whichever one the user picks.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point: don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module**: anything with an interface and an implementation (function, class, package, slice).
- **Interface**: everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation**: the code inside.
- **Depth**: leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam**: where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter**: a concrete thing satisfying an interface at a seam.
- **Leverage**: what callers get from depth.
- **Locality**: what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

## Where the project's knowledge lives

This skill is _informed_ by the project's domain model and past decisions. Read them before exploring:

- **Domain language**: the root `CLAUDE.md` indexes the `.claude/` context tree. Read `.claude/business/glossary.md` and the `.claude/domains/*.md` files for the area you're touching. Domain terms name good seams.
- **Decisions not to re-litigate**: `.claude/business/rules.md`, `.claude/architecture/overview.md`, and any spec the root `CLAUDE.md` links (e.g. `.claude/spec/design.md`). Never propose a candidate that resolves an item listed as an open design decision; flag it as blocked on that decision instead.
- **Rejected candidates**: run engram `mem_search` for `rejected deepening` plus the area's name. A past rejection with a load-bearing reason means: don't re-suggest it unless the friction has clearly grown since.

No `.claude/` tree? Say so in one line, suggest `/fill-context`, and continue using the code's own names.

## Process

### 1. Explore

**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so weight the parts of the codebase that change most. Decide _where_ to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it and skip the inference below.
- Otherwise, walk back a good stretch of commit history (`git log --name-only`) to find hot spots: the files and directories that keep coming up. Let those paths pull your attention first. If changes are scattered with no clear hot spot, widen the net.

Then use the Agent tool with `subagent_type=Explore` to walk the scoped area. Put the glossary terms and the hot-spot paths in its prompt. Don't follow rigid heuristics; explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates as an Artifact

Load the `artifact-design` skill, write the report as one HTML file in the session's scratchpad directory (never in the repo), and publish it with the Artifact tool. Follow [REPORT.md](REPORT.md) for the card layout and diagram patterns. Give the user the link.

If the Artifact tool is not available in this session, present the same candidates as a numbered list in chat instead (Files, Problem, Solution, Benefits, Strength per candidate) and skip the diagrams.

For each candidate:

- **Files**: which files/modules are involved
- **Problem**: why the current architecture is causing friction
- **Solution**: plain English description of what would change
- **Benefits**: explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram**: illustrating the shallowness and the deepening
- **Recommendation strength**: one of `Strong`, `Worth exploring`, `Speculative`

End with a **Top recommendation**: which candidate you'd tackle first and why.

**Use the project glossary for the domain, and [LANGUAGE.md](LANGUAGE.md) for the architecture.** If the glossary defines "Match," talk about "the Match attendance module," not "the AttendanceHandler," and not "the Match service."

**Decision conflicts**: if a candidate contradicts a recorded decision or a past rejection, only surface it when the friction is real enough to warrant revisiting it. Mark it clearly in the card (e.g. _"contradicts the decision in design.md, but worth reopening because…"_). Don't list every theoretical refactor a decision forbids.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, invoke the `grill-me` skill to walk the design tree with them: constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive. See [DEEPENING.md](DEEPENING.md) for how dependency categories shape the deepened module.

Side effects happen as decisions crystallize. Propose each one, then write it only after the user confirms:

- **Naming a deepened module after a concept not in the glossary?** Propose the new row for `.claude/business/glossary.md`, matching its existing table format.
- **Sharpening a fuzzy term during the conversation?** Propose the edit to the glossary row right there.
- **User rejects the candidate with a load-bearing reason?** Offer: _"Want me to save this to engram so future architecture reviews don't re-suggest it?"_ On yes, call `mem_save` with type `decision`, a title starting `Rejected deepening:` plus the candidate name, and the files, the reason, and what would make it worth reopening. Only offer when a future explorer would need the reason to avoid re-suggesting it; skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

The grilling loop ends with a shared understanding, not with code. Implementation is a separate task the user starts.
