# Persistent Memory Guide

This stack uses a dual memory system that combines **Engram MCP** for automatic session-persistent memory with **Obsidian** for structured documentation. Together, they provide comprehensive context retention across sessions.

---

## Overview

| Layer | System | Purpose | Trigger |
|-------|--------|---------|---------|
| **Automatic** | Engram MCP | Remembers *"what we did last time"*, decisions, patterns | AI calls automatically via MCP |
| **Deliberate** | Obsidian | ADRs, bug logs, domain knowledge | Human creates via `/mems` or `/sum` |

**The flow**: When you use `/mems` or `/sum`, the AI writes to **both** systems simultaneously — Engram for automatic retrieval, Obsidian for structured reference.

---

## How They Complement Each Other

### Engram MCP
- **Automatic**: No manual setup needed after initial configuration
- **Semantic search**: AI retrieves relevant context based on meaning, not just keywords
- **Session-aware**: Remembers what was discussed in previous sessions
- **Fast**: Direct MCP integration, no file I/O

### Obsidian
- **Structured**: Notes organized in `ADR/`, `Bugs/`, `Learnings/`, etc.
- **Human-readable**: You can open Obsidian and read/write notes directly
- **Rich linking**: Wikilinks between notes, graphs, bidirectional references
- **Archival**: Long-term storage of architectural decisions

**Use both**: Engram captures context organically, Obsidian holds deliberate architectural documentation.

---

## Configuration

### 1. Engram MCP Setup

**Download:**
```bash
# macOS
brew install engram-cli

# Or download from https://github.com/getengram/engram/releases
```

**Configure in your editor:**

*Claude Code / OpenCode* — Add to `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "engram": {
      "command": "engram",
      "args": ["mcp"]
    }
  }
}
```

*Windsurf* — Add to `~/.windsurf/config.json`.

### 2. Obsidian Setup

**Create the vault structure:**
```bash
# Your master vault location
~/Documents/Obsidian_Brain/

# Per-project structure
~/Documents/Obsidian_Brain/Projects/[Project-Name]/
├── ADR/           # Architecture Decision Records
├── Bugs/          # Bug logs with root causes
├── Docs/          # Technical documentation
├── Learnings/     # Insights and discoveries
├── Features/      # Feature implementations
├── Config/        # Environment and tool configurations
└── Index.md       # Hub file with links to all notes
```

**Link to each project:**
```bash
cd /your/project
mkdir -p docs
ln -s ~/Documents/Obsidian_Brain/Projects/your-project ./docs/brain
```

**Add to `.gitignore`:**
```
docs/brain/
```

---

## Workflows

### `/mems` — Save Individual Observations

Used to record a specific learning, decision, or bugfix. Writes to **both** Engram and Obsidian.

**Command:**
```
/mems --title "Fixed N+1 query in OrderList" --type bugfix --what "Added eager loading" --why "Query was loading 100+ records per order" --where "src/queries/orders.ts" --tags "ef-core,performance"
```

**Arguments:**
| Arg | Required | Description |
|-----|----------|-------------|
| `--title` | Yes | Short, searchable title (e.g., "Fixed N+1 query in OrderList") |
| `--type` | Yes | bugfix, decision, architecture, discovery, pattern, config, preference |
| `--what` | Yes | One sentence — what was done |
| `--why` | Yes | What motivated it |
| `--where` | Yes | Files or paths affected |
| `--learned` | No | Gotchas, edge cases, surprises |
| `--scope` | No | project (default) or personal |
| `--tags` | No | Comma-separated tags |

**What happens:**
1. Sends data to Engram via `mem_save` MCP
2. Detects project from `git rev-parse --show-toplevel`
3. Maps type to Obsidian subdirectory:
   - bugfix → `Bugs/`
   - decision, architecture → `ADR/`
   - discovery, pattern, preference → `Learnings/`
   - config → `Config/`
4. Creates note with frontmatter at:
   ```
   ~/Documents/Obsidian_Brain/Projects/[Project]/[Subdirectory]/[Title].md
   ```
5. Updates project's `Index.md` with wikilink

---

### `/sum` — Session Close Protocol

Used at the end of a session to capture the full context. Writes to **both** Engram and Obsidian.

**Command:**
```
/sum --goal "User authentication flow" --discoveries "NextAuth session handling, cookie config" --accomplished "Added auth middleware, configured providers" --next "Add logout, test OAuth flow" --files "src/middleware.ts src/auth/config.ts" --tags "auth,nextauth"
```

**Arguments:**
| Arg | Required | Description |
|-----|----------|-------------|
| `--goal` | Yes | What you were working on |
| `--discoveries` | Yes | Technical findings, gotchas (comma-separated) |
| `--accomplished` | Yes | Completed items with key details (comma-separated) |
| `--next` | Yes | What remains to be done (comma-separated) |
| `--files` | Yes | List of files changed (space-separated) |
| `--tags` | No | Optional tags |

**What happens:**
1. Sends summary to Engram via `mem_session_summary` MCP
2. Creates note at:
   ```
   ~/Documents/Obsidian_Brain/Projects/[Project]/Learnings/Session - [Date].md
   ```
3. Updates project's `Index.md`

---

## Auto-Triggered Saves (Engram Only)

> [!IMPORTANT]
> Auto-triggered saves via `mem_save` write **only to Engram**, not to Obsidian. This is because they're triggered automatically during conversation flow.

The AI is instructed to call `mem_save` automatically after these events:

### Decision & Architecture
- Architecture or design decision made
- Team convention documented or established
- Tool or library choice made with tradeoffs
- API contract or interface change
- Database schema change

### Bug Fixes
- Bug fix completed (include root cause)
- Non-obvious error discovered
- Edge case found and handled

### Code & Patterns
- Pattern established (naming, structure, convention)
- Feature implemented with non-obvious approach
- Refactoring that improves maintainability

### Discovery & Learning
- Non-obvious discovery about the codebase
- Gotcha or unexpected behavior found

---

## Searching Memory

### Engram (Automatic)
The AI automatically searches Engram when you ask questions like:
- *"What did we work on last time?"*
- *"What decisions were made about authentication?"*

### Obsidian (Manual)
Search using the `obsidian-vault` skill or directly:
```bash
# Search within current project
grep -rl "keyword" "$PROJECT_PATH" --include="*.md"

# Search across all projects
grep -rl "keyword" "/Users/orla/Obsidian_Brain/" --include="*.md"
```

---

## Obsidian Frontmatter Template

All notes created via `/mems` or `/sum` follow this structure:

```markdown
---
id: {{uuid}}
type: {{type}}
project: {{project}}
scope: {{scope}}
topic_key: {{type}}/{{slugified-title}}
session_id: {{session-id}}
created_at: {{timestamp}}
updated_at: {{timestamp}}
tags: [{{tags}}]
aliases: []
---

**What**: ...

**Why**: ...

**Where**: ...

**Learned**: ...
```

---

## Best Practices

### Always run `/sum` at the end of every work session

A "work session" is a continuous period of collaboration — not necessarily a single prompt. Think of it as: *"I'm done with this task/feature/bug fix"*.

**When to run `/sum`:**
- After completing a feature or significant code change
- Before switching to a different task or context
- At the end of your coding session, even if you didn't finish
- Before ending the conversation or closing the editor

**Why this matters:**
- Auto-triggered saves only go to Engram (not Obsidian)
- `/sum` ensures both systems have the full context
- Future sessions can retrieve the complete picture via Engram semantic search
- Obsidian provides archival reference for long-term context

**Recommended frequency**: At least once per feature/task, not just once per day.

---

## Key Files

| File | Purpose |
|------|---------|
| `skills/personal/mems/SKILL.md` | Full skill definition with all workflows |
| `OBSIDIAN-INTEGRATION.md` | Legacy Obsidian setup guide |
| `global-rules.md` | Global rules including memory protocol |