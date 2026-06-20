---
name: prompt-rewrite
description: >
  Rewrites, audits, or designs prompts and system instructions using context
  engineering principles — optimizing signal-to-noise ratio, altitude calibration,
  tool guidance clarity, and retrieval strategy selection. Use this skill whenever
  the user asks to "improve a prompt", "rewrite a system prompt", "audit my
  CLAUDE.md", "make this prompt more token-efficient", "fix my agent instructions",
  or anything related to optimizing LLM instructions for quality or cost. Also
  trigger when the user shares a prompt and asks why an AI is misbehaving or
  producing low-quality output — context rot and prompt design are likely culprits.
---

# Prompt Rewrite Skill

Rewrites and audits prompts using context engineering principles. The goal is always
the same: **find the smallest possible set of high-signal tokens that maximize the
likelihood of the desired outcome**.

---

## Step 1 — Diagnose Before Rewriting

Before touching anything, identify which failure mode(s) apply:

| Failure Mode | Symptoms |
|---|---|
| **Too prescriptive** | Hardcoded if-else logic, brittle conditions, high maintenance |
| **Too vague** | High-level guidance with no concrete signals, assumes shared context |
| **Context rot** | Long prompt with stale history, repeated instructions, redundant tool results |
| **Bloated tool set** | Overlapping tools, ambiguous when to use which |
| **Exhaustive examples** | Edge-case laundry list instead of diverse canonical examples |
| **Wrong retrieval strategy** | Pre-loading data that should be fetched just-in-time (or vice versa) |
| **Narrated plans** | Instructions that describe process instead of encoding behavior |

Ask the user for the current prompt/instructions if not already provided. Ask for
one or two examples of failure outputs if diagnosis is unclear.

---

## Step 2 — Classify the Prompt Type

Identify what kind of artifact is being rewritten so the output format is correct:

- **System prompt / agent instructions** — governs overall agent behavior
- **CLAUDE.md / project instructions** — operational rules for Claude Code or similar
- **Tool description** — governs when and how a tool is selected and called
- **Few-shot examples block** — examples passed in context for behavior shaping
- **RAG / retrieval prompt** — instructions for surfacing and using retrieved context
- **User-turn prompt** — a single query or task sent by the user

---

## Step 3 — Apply the Right Altitude

Every rewrite must land in the **Goldilocks Zone**:

```
Too Prescriptive <————————[ Just Right ]————————> Too Vague

"If X then Y else Z"        "When handling X,         "Be helpful
"Always respond in          prefer Y because Z.        and accurate."
 exactly 3 bullets"         Use judgment for
"Never use the word..."      edge cases."
```

**Just Right means:**
- Specific enough to guide behavior with concrete signals
- Flexible enough to apply heuristics across novel situations
- Minimum information that fully outlines expected behavior
- No logic the model should be figuring out itself

---

## Step 4 — Rewrite Rules by Artifact Type

### System Prompts & Agent Instructions

- Use clear section headers: `## Background`, `## Instructions`, `## Tool Guidance`, `## Output Format`
- XML tags for discrete blocks: `<constraints>`, `<examples>`, `<persona>`
- Start minimal — add sections only where failure modes exist
- Remove any procedural narration ("First, read the file. Then check if...")
- Replace brittle conditions with outcome-oriented heuristics

### Tool Descriptions

Each tool description must be **self-contained and unambiguous**. Apply this checklist:

- [ ] Single, clear purpose — one tool, one job
- [ ] When to use it stated explicitly
- [ ] When NOT to use it stated if there's overlap risk
- [ ] Parameters named descriptively (`user_id` not `id`, `source_file_path` not `path`)
- [ ] Return value described (what shape, what fields matter)
- [ ] No overlap with another tool — if two tools could apply, the description must resolve it

> **Test**: If a human engineer can't definitively pick this tool over others in a given
> scenario, rewrite until they can.

### Few-Shot Examples

- Curate **diverse and canonical** — not exhaustive and edge-case-heavy
- Each example should illustrate a different class of behavior
- Think "picture worth a thousand words" — one clear example beats five similar ones
- Remove examples that only differ by surface variation (same pattern, different names)
- Max 3–5 examples unless the task has genuinely high variance

### CLAUDE.md / Project Instructions

- Organize by: Context -> Conventions -> Workflow -> Constraints
- No redundancy with what the model already knows (don't explain Git, don't define JSON)
- State team-specific conventions, not universal best practices
- Prefer declarative rules over procedural steps
- Flag non-obvious decisions with a one-line rationale

---

## Step 5 — Apply Context Retrieval Strategy

If the prompt involves loading external data, recommend the right strategy:

| Scenario | Strategy |
|---|---|
| Static reference content (docs, schemas, policies) | Pre-inference retrieval (RAG) |
| Dynamic exploration, unknown file structure | Just-in-time (agent fetches at runtime) |
| Both stable and exploratory content | Hybrid: load stable upfront, explore dynamically |
| Long multi-turn task approaching context limit | Compaction: summarize + reinitiate |
| Iterative dev with checkpoints | Structured note-taking (NOTES.md, todo lists) |
| Deep research subtask | Sub-agent with clean context window |

Flag if the current prompt is pre-loading data that should be fetched just-in-time,
or deferring data that should be pre-loaded.

---

## Step 6 — Token Efficiency Pass

After structural rewrite, do a compression pass:

1. **Remove redundancy** — delete repeated instructions, restatements of the obvious
2. **Collapse verbose conditions** — "If the user asks about X or Y or Z" -> enumerate the pattern
3. **Cut preamble** — the model doesn't need to be thanked or oriented
4. **Trim examples** — keep the minimum set that covers behavioral diversity
5. **Prune stale tool calls** — in long conversations, old results are noise
6. **Use structure, not prose** — a bullet beats two sentences

Target: remove 20-40% of tokens without losing signal.

---

## Step 7 — Output Format

Deliver the rewrite as:

```
## Diagnosis
[2-4 bullet points identifying the specific failure modes found]

## Rewritten Prompt
[The full rewritten artifact, ready to copy-paste]

## What Changed and Why
[3-6 bullet points explaining the non-obvious decisions]
```

If the original prompt was already well-structured, say so and make targeted edits
only. Don't rewrite for the sake of rewriting.

---

## Anti-Patterns Reference

Never introduce these into a rewritten prompt:

- Hardcoded if-else chains the model should resolve with judgment
- Exhaustive edge-case lists (use diverse canonical examples instead)
- Pre-loaded context that bloats every request (move to just-in-time)
- Overlapping tool definitions with ambiguous selection criteria
- Procedural narration of what the model should "do next"
- Instructions that assume larger context windows solve attention problems
- Redundant constraints repeated across multiple sections
