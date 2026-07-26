---
name: fill-triggers
description: >
  Build or regenerate .claude/engineering/agent-triggers.md — an explicit,
  version-controlled table mapping repo layers/paths to which specialized
  subagent (backend-architect, frontend-architect, security-engineer, etc.)
  should be delegated to, and under what condition. Derives the table from
  the real directory structure plus targeted questions, not guesses. Use
  after fill-context has already run, or whenever the developer wants
  deterministic (not per-turn-judgment) rules for when Claude delegates to a
  specialized agent.
trigger: /fill-triggers
version: "1.0.0"
---

# Fill Triggers

Make agent delegation **deterministic and inspectable** instead of a
per-turn judgment call. Produces one file, `.claude/engineering/agent-triggers.md`,
linked from `.claude/CLAUDE.md`, that states exactly which path/condition
maps to which subagent.

**Core principle:** derive triggers from the repo's real layers, not a
generic list of agent names. A path pattern that doesn't exist in this repo
gets no row.

---

## Phase 0 — Require context first

```bash
cat .claude/CLAUDE.md 2>/dev/null
```

- If missing or still template placeholders, stop and tell the developer to
  run `fill-context` first — this skill needs a real architecture overview
  and directory structure to map layers to agents meaningfully.
- If `.claude/engineering/agent-triggers.md` already exists, show it and ask:
  "Triggers already exist — regenerate everything, or add/adjust specific
  rows?"

---

## Phase 1 — Scan the repo structure

Run silently, collect data:

```bash
eza --tree --level=3 --ignore-glob="node_modules|.git|bin|obj|dist|build" 2>/dev/null \
  || find . -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/bin/*' -not -path '*/obj/*' -maxdepth 3 -type d
cat .claude/architecture/overview.md 2>/dev/null
```

From this, identify the distinct **layers/areas** actually present — e.g.
`src/Domain`, `src/Application`, `src/Infrastructure`, `src/Api`,
`apps/mobile`, `tests/`, CI/deploy config, database migrations. Only list
areas that exist in this repo.

---

## Phase 2 — List available agents

State the fixed set of specialized subagents available in this environment
(their names and one-line purpose — read from the current agent listing, do
not hardcode a stale list). Typical candidates relevant to backend/mobile
projects: `backend-architect`, `frontend-architect`, `system-architect`,
`security-engineer`, `refactoring-expert`, `performance-engineer`,
`tech-stack-researcher`.

---

## Phase 3 — Targeted grill

For each detected layer/area from Phase 1, ask the developer **one combined
question**, not one per layer:

> "For each of these areas, tell me if/when a specialized agent should be
> consulted instead of handling it inline — and which one:
> 1. `[area 1]` — e.g. new architectural design in this layer?
> 2. `[area 2]` — ...
> ...
> For any area, you can say 'never delegate, always inline' — that's a valid
> answer and will be recorded as such."

Also ask the two cross-cutting conditions that don't map to a single folder:
- Security-sensitive changes (auth, tokens, permissions, payment) — which
  agent, if any?
- Cross-layer/system-wide architecture decisions (touches backend + mobile +
  infra at once) — which agent, if any?

**Critical distinction to capture per row:** delegation should trigger on
**new design/decision work**, not on routine edits or bugfixes in that area.
Make sure each answer records this distinction explicitly (e.g. "new Command
handlers or schema changes → backend-architect; bugfixes stay inline").

Wait for answers before writing.

---

## Phase 4 — Generate the file

```markdown
# Agent Delegation Triggers

*Deterministic rules for when to delegate to a specialized subagent instead
of handling a change inline. Checked before starting non-trivial work in a
matching path. Routine edits and bugfixes stay inline regardless of path.*

| Path / Condition | Trigger (delegate when...) | Agent | Otherwise |
|---|---|---|---|
| `[path]` | [new design work / decision, from developer answer] | `[agent]` | handle inline |
| Security-sensitive (auth, tokens, payments) | [condition] | `[agent or "none"]` | handle inline |
| Cross-layer / system-wide decisions | [condition] | `[agent or "none"]` | handle inline |

## Notes
[Any caveat the developer gave — e.g. "only delegate if the change spans 3+ files"]
```

Show the draft to the developer before writing.

**Exit gate:** ask "Does this look right? Anything to adjust before I write?"
Wait for confirmation, then write the file.

---

## Phase 5 — Link it from CLAUDE.md

Add this line under the `## Engineering` section of `.claude/CLAUDE.md` (create
the section if `fill-context` hasn't run recently enough to have it):

```markdown
- [Agent Triggers](engineering/agent-triggers.md) — when to delegate to a specialized subagent
```

Print: "✅ Triggers written to `.claude/engineering/agent-triggers.md` and linked from CLAUDE.md."

---

## Rules

- NEVER invent a path/layer that isn't in the scanned structure.
- NEVER assign a delegation rule the developer didn't confirm — silence is
  not consent; if they skip a layer, record it as "no rule — inline by
  default", don't guess an agent for it.
- Ask all Phase 3 questions in one batch, not one round-trip per layer.
- If the repo has no distinct layers yet (e.g. `project-bootstrap` hasn't run
  and `src/` is empty), say so and suggest running `project-bootstrap` or
  `fill-context` first — there's nothing real to map yet.
- This file records **rules**, not a promise of mechanical enforcement —
  state plainly in the generated file's intro that these are read and
  applied by judgment each session, not hook-enforced.
