---
name: mems
description: Unified memory protocol — save to Engram AND Obsidian with structured frontmatter. Use /mems to remember decisions, bugfixes, learnings. Use /sum to close sessions.
---

# Obsidian Vault

## Workflow Integrado (Engram + Obsidian)

> [!WARNING]
> This skill replaces `mem_save` workflow.

> [!IMPORTANT]
> **Always run `/sum` at the end of every work session.** A work session is a continuous period of collaboration — not necessarily a single prompt. Think of it as: *"I'm done with this task/feature/bug fix"*.

**Why:**
- Auto-triggered saves (AI calling `mem_save` automatically) only write to Engram, not Obsidian
- `/sum` ensures both systems have the complete context
- Run `/sum` after completing a feature, before switching tasks, or at the end of your coding session

Use this command instead of calling Engram's `mem_save` directly:

**`/mems`**:
- Calls Engram's `mem_save` via MCP
- Creates note in Obsidian automatically
- Updates project Index

**Usage**:
```
/mems --title "Fixed N+1 query in OrderList" --type bugfix --what "Added eager loading" --why "Query was loading 100+ records per order" --where "src/queries/orders.ts"
```

---

## Vault Location

`/Users/orla/Documents/Obsidian_Brain/`

## Project Structure

> [!IMPORTANT]
> Each project has its own directory at `~/Documents/Obsidian_Brain/Projects/[Project-Name]/`.

When managing notes, ALWAYS:
1.  **Detect current project** automatically.
2.  **Determine appropriate subdirectory** based on content type.
3.  **Save in the correct location** within the project structure.

---

## Automatic Project Detection

### Step 1: Find Current Project
```bash
# Detect project from current working directory
PROJECT_NAME=$(basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))
PROJECT_PATH="/Users/orla/Documents/Obsidian_Brain/Projects/$PROJECT_NAME"
```

### Step 2: Determine Content Type & Subdirectory

| Content Type | Subdirectory | Keywords |
| :--- | :--- | :--- |
| **Bugs / Issues** | `Bugs/` | bug, issue, problem, error, fix |
| **Architecture Decisions** | `ADR/` | decision, architecture, design, pattern, ADR |
| **Technical Documentation** | `Docs/` | documentation, guide, tutorial, how-to |
| **Learnings** | `Learnings/` | learning, insight, discovery, finding |
| **Features** | `Features/` | feature, functionality, enhancement |
| **Config / Setup** | `Config/` | config, setup, environment, tools |

### Step 3: Create Directory Structure if Needed
```bash
# Ensure project directory and subdirectories exist
mkdir -p "$PROJECT_PATH"/{ADR,Bugs,Docs,Learnings,Features,Config}
```

---

## Naming Conventions
- **Title Case** for all note names.
- **Descriptive names** that clearly indicate content type.
- **Project context**: Include project context in title when relevant.

## Linking
- **Wikilinks**: Use Obsidian `[[wikilinks]]` syntax: `[[Note Title]]`.
- **Dependencies**: Notes should link to dependencies or related notes at the bottom.
- **Index Update**: Always update the project's `Index.md` with new note links.
- **Cross-Project**: Use cross-project links when relevant: `[[Other Project/Note Title]]`.

---

## Workflows

### 1. /mem_save_after — Save to Both Engram AND Obsidian

> [!IMPORTANT]
> Use this instead of calling Engram's `mem_save` directly.

**Command**: `/mems [arguments]`

**Arguments**:
- `--title`: Short, searchable title (e.g., "Fixed N+1 query in OrderList")
- `--type`: bugfix | decision | architecture | discovery | pattern | config | preference
- `--what`: One sentence — what was done
- `--why`: What motivated it
- `--where`: Files or paths affected
- `--learned`: Gotchas, edge cases, surprises (optional)
- `--scope`: project | personal (default: project)
- `--tags`: Optional tags (comma-separated)
- `--aliases`: Optional aliases for search (comma-separated)

**Frontmatter Template**:
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
aliases: [{{aliases}}]
---

**What**: {{what}}

**Why**: {{why}}

**Where**: {{where}}

**Learned**: {{learned}}
```

**Workflow**:
1. Call Engram's `mem_save` with all arguments
2. Detect project from current working directory
3. Map `type` to Obsidian subdirectory:
   - bugfix → `Bugs/`
   - decision → `ADR/`
   - architecture → `ADR/`
   - discovery → `Learnings/`
   - pattern → `Learnings/`
   - config → `Config/`
   - preference → `Learnings/`
4. Generate frontmatter with auto-fields:
   - `id`: UUID (auto-generated)
   - `project`: Detected from git
   - `topic_key`: `${type}/${slug(title)}`
   - `session_id`: From Engram session
   - `created_at` / `updated_at`: Current timestamp
   - `tags`: Parsed from arguments (default: type)
   - `aliases`: Empty by default
5. Create note at `/Users/orla/Documents/Obsidian_Brain/Projects/[Project]/[Subdirectory]/[Title].md`
6. Update project's `Index.md` with wikilink

**Example**:
```
/mems --title "Added eager loading to OrderList" --type bugfix --what "Added Include() for User in orders query" --why "Was making N+1 queries" --where "src/data/order-repository.ts" --tags "ef-core,performance"
```

**Generated Note**:
```markdown
---
id: a1b2c3d4-e5f6-7890-abcd-ef1234567890
type: bugfix
project: engram
scope: project
topic_key: bug/added-eager-loading-to-orderlist
session_id: sess_abc123
created_at: 2026-05-03T14:30:00Z
updated_at: 2026-05-03T14:30:00Z
tags: ["bugfix", "ef-core", "performance"]
aliases: []
---

**What**: Added Include() for User in orders query

**Why**: Was making N+1 queries (100+ per request)

**Where**: src/data/order-repository.ts

**Learned**: Use Include() for eager loading in EF Core
```

### 2. /sum — Session Close to Both Engram AND Obsidian

**Command**: `/sum`

**Arguments**:
- `--goal`: What you were working on
- `--discoveries`: Technical findings, gotchas (comma-separated)
- `--accomplished`: Completed items with key details (comma-separated)
- `--next`: What remains to be done (comma-separated)
- `--files`: List of files changed (space-separated)
- `--tags`: Optional tags (comma-separated)

**Frontmatter Template**:
```markdown
---
id: {{uuid}}
type: session_summary
project: {{project}}
scope: project
topic_key: session/{{date}}
session_id: {{session-id}}
created_at: {{timestamp}}
updated_at: {{timestamp}}
tags: ["session", {{tags}}]
aliases: []
---

## Goal
{{goal}}

## Discoveries
{{discoveries}}

## Accomplished
{{accomplished}}

## Next Steps
{{next}}

## Relevant Files
{{files}}
```

**Workflow**:
1. Call Engram's `mem_session_summary` with all arguments
2. Detect project from current working directory
3. Generate frontmatter with auto-fields
4. Create note at `/Users/orla/Documents/Obsidian_Brain/Projects/[Project]/Learnings/Session - [Date].md`
5. Update project's `Index.md` with wikilink

**Example**:
```
/sum --goal "User authentication flow" --discoveries "NextAuth session handling, cookie config" --accomplished "Added auth middleware, configured providers" --next "Add logout, test OAuth flow" --files "src/middleware.ts src/auth/config.ts" --tags "auth,nextauth"
```

**Generated Note**:
```markdown
---
id: sess_20260503_1430
type: session_summary
project: engram
scope: project
topic_key: session/2026-05-03
session_id: sess_abc123
created_at: 2026-05-03T14:30:00Z
updated_at: 2026-05-03T14:30:00Z
tags: ["session", "auth", "nextauth"]
aliases: []
---

## Goal
User authentication flow

## Discoveries
- NextAuth session handling
- Cookie config in NextAuth v4

## Accomplished
- Added auth middleware
- Configured providers (Google, GitHub)

## Next Steps
- Add logout functionality
- Test OAuth flow

## Relevant Files
src/middleware.ts src/auth/config.ts
```

### 3. Search for Notes
```bash
# Search within current project
find "$PROJECT_PATH" -name "*.md" | grep -i "keyword"

# Search by content within project
grep -rl "keyword" "$PROJECT_PATH" --include="*.md"

# Search across all projects
find "/Users/orla/Documents/Obsidian_Brain/" -name "*.md" | grep -i "keyword"
```

### 2. Create a New Note (Automated)
1.  **Detect project** from current working directory.
2.  **Analyze content** to determine the correct subdirectory.
3.  **Path**: `~/Documents/Obsidian_Brain/Projects/[Project]/[Subdirectory]/[Note Title].md`.
4.  **Content**: Write as a unit of learning.
5.  **Links**: Add wikilinks to related notes at the bottom.
6.  **Index**: Update the project's `Index.md`.

### 3. Update Project Index
Always add new notes to the project's `Index.md` under the appropriate header:

```markdown
## 🏛️ Architecture Decision Records (ADR)
- [[New Decision Note]]

## 📚 Technical Documentation  
- [[New Documentation Note]]

## 🐛 Bugs & Learnings
- [[New Bug Note]]
```

### 4. Find Related Notes
```bash
# Within current project
grep -rl "\\[\\[Note Title\\]\\]" "$PROJECT_PATH"

# Across all projects
grep -rl "\\[\\[Note Title\\]\\]" "/Users/orla/Documents/Obsidian_Brain/"
```

### 5. Find Project Indexes
```bash
find "/Users/orla/Documents/Obsidian_Brain/Projects/" -name "Index.md"
```

---

## Persistent Memory Protocol (Engram Format)

### mem_save — Save Individual Observations

**Command**: `mem_save`

**Format**:
```markdown
---
title: [Verb + What] — short, searchable (e.g., "Fixed N+1 query in OrderList")
type: bugfix | decision | architecture | discovery | pattern | config | preference
scope: project | personal
topic_key: stable key (e.g., architecture/auth-model)
---

**What**: One sentence — what was done

**Why**: What motivated it

**Where**: Files or paths affected

**Learned**: Gotchas, edge cases, surprises (omit if none)
```

**Triggers** (CALL IMMEDIATELY after any of these):

### Decision & Architecture
- Architecture or design decision made
- Team convention documented or established
- Tool or library choice made with tradeoffs
- API contract or interface change
- Database schema change
- Authentication/authorization change

### Bug Fixes
- Bug fix completed (include root cause)
- Non-obvious error discovered
- Edge case found and handled
- Race condition or concurrency issue fixed
- Memory leak or performance issue resolved

### Code & Patterns
- Pattern established (naming, structure, convention)
- Feature implemented with non-obvious approach
- Refactoring that improves maintainability
- New component or module created
- State management change
- Third-party integration added

### Configuration & Environment
- Configuration change or environment setup done
- New environment variable added
- Build/deploy process change
- Dependency version upgrade

### Discovery & Learning
- Non-obvious discovery about the codebase
- Something learned about how the system works
- Gotcha or unexpected behavior found
- Documentation gap identified
- Test coverage gap found

### User & Preferences
- User preference or constraint learned
- Requirement clarification from user
- Feedback received and incorporated
- Scope change or priority adjustment

### mem_session_summary — Session Close Protocol

**Command**: `mem_session_summary`

**Format**:
```markdown
Goal
[What we were working on]

Discoveries
[Technical findings, gotchas, non-obvious learnings]

Accomplished
[Completed items with key details]

Next Steps
[What remains to be done]

Relevant Files
path/to/file — [what changed]
```

---

## Example Usage

**Scenario A: "Save this bug about the navbar"**
1.  **Detect project**: `ram-landing`
2.  **Determine type**: "bug" → `Bugs/`
3.  **Create**: `~/Documents/Obsidian_Brain/Projects/ram-landing/Bugs/Navbar Bug.md`
4.  **Update**: `~/Documents/Obsidian_Brain/Projects/ram-landing/Index.md`

**Scenario B: "Document this architecture decision"**
1.  **Detect project**: `ram-landing`
2.  **Determine type**: "architecture decision" → `ADR/`
3.  **Create**: `~/Documents/Obsidian_Brain/Projects/ram-landing/ADR/Architecture Decision.md`
4.  **Update**: `~/Documents/Obsidian_Brain/Projects/ram-landing/Index.md`