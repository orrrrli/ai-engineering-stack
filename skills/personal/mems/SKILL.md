---
name: mems
description: Document decisions, bugs, learnings, and session summaries directly to Obsidian vault. Use /mems to save a note, /sum to close a session.
---

# Obsidian Documentation Skill

## Vault Location
`/Users/orla/Documents/Obsidian_Brain/`

## Project Structure
Each project lives at `~/Documents/Obsidian_Brain/Projects/[Project-Name]/` with these subdirectories:

| Content Type | Subdirectory | When to use |
|---|---|---|
| Architecture Decisions | `ADR/` | Design choices, patterns, why X over Y |
| Bug Fixes | `Bugs/` | Non-obvious fixes, root causes, gotchas |
| Technical Docs | `Docs/` | How-to guides, setup, integrations |
| Learnings | `Learnings/` | Discoveries, insights, edge cases, sessions |
| Features | `Features/` | New functionality, implementation notes |
| Config / Setup | `Config/` | Environment, tooling, dependencies |

---

## Commands

### `/mems` — Save a note to Obsidian

**Usage:**
```
/mems --title "..." --type bugfix --what "..." --why "..." --where "..."
```

**Arguments:**
- `--title` — Short, searchable title (verb + what). Required.
- `--type` — `bugfix | decision | architecture | discovery | pattern | config | preference`
- `--what` — One sentence: what was done or found
- `--why` — What motivated it or why it matters
- `--where` — Files, paths, or modules affected
- `--learned` — Gotchas, surprises, edge cases (optional)
- `--tags` — Comma-separated tags (optional)

**Workflow:**
1. Detect project from `git rev-parse --show-toplevel`
2. Map `--type` to subdirectory:
   - `bugfix` → `Bugs/`
   - `decision | architecture` → `ADR/`
   - `discovery | pattern | preference` → `Learnings/`
   - `config` → `Config/`
3. Ensure directory exists: `mkdir -p "$PROJECT_PATH/{ADR,Bugs,Docs,Learnings,Features,Config}"`
4. Write note with frontmatter to `~/Documents/Obsidian_Brain/Projects/[Project]/[Subdir]/[Title].md`
5. Update `Index.md` with a wikilink under the correct section header

**Note template:**
```markdown
---
type: {{type}}
project: {{project}}
created_at: {{ISO-8601 timestamp}}
tags: [{{type}}, {{tags}}]
---

**What**: {{what}}

**Why**: {{why}}

**Where**: {{where}}

**Learned**: {{learned}}
```

**Example:**
```
/mems --title "Fixed N+1 query in OrderList" --type bugfix --what "Added Include() for User in EF Core query" --why "Was making 100+ DB hits per request" --where "src/data/order-repository.ts" --learned "Always check EF Core generated SQL with logging enabled"
```

---

### `/sum` — Close a session and save summary to Obsidian

**Usage:**
```
/sum
```
Claude will ask for the session details interactively, or you can pass them inline:
```
/sum --goal "..." --accomplished "..." --discoveries "..." --next "..." --files "..."
```

**Arguments:**
- `--goal` — What we were working on
- `--accomplished` — Completed items (comma-separated)
- `--discoveries` — Technical findings, gotchas (comma-separated)
- `--next` — What remains (comma-separated)
- `--files` — Files changed (space-separated paths)
- `--tags` — Optional tags

**Workflow:**
1. Detect project from git
2. Generate session note at `~/Documents/Obsidian_Brain/Projects/[Project]/Learnings/Session - [YYYY-MM-DD].md`
3. Update `Index.md`

**Note template:**
```markdown
---
type: session_summary
project: {{project}}
date: {{YYYY-MM-DD}}
created_at: {{ISO-8601 timestamp}}
tags: ["session", {{tags}}]
---

## Goal
{{goal}}

## Accomplished
{{accomplished as bullet list}}

## Discoveries
{{discoveries as bullet list}}

## Next Steps
{{next as bullet list}}

## Files Changed
{{files as bullet list}}
```

---

## Index.md Update Rules

Always add the new note under the correct header in `Index.md`. Create the header if it doesn't exist:

```markdown
## 🏛️ Architecture Decision Records (ADR)
- [[Note Title]]

## 🐛 Bugs & Fixes
- [[Note Title]]

## 📚 Learnings
- [[Note Title]]

## 📝 Session Summaries
- [[Session - YYYY-MM-DD]]
```

If `Index.md` doesn't exist, create it with the project name as H1.

---

## When Claude Should Proactively Suggest `/mems`

After completing any of these, recommend running `/mems` (don't call it automatically):

- Architecture or design decision was made and confirmed
- A bug was fixed with a non-obvious root cause
- A pattern or convention was established
- A surprising discovery was made about the codebase
- A tool, library, or approach was chosen over alternatives
- A gotcha or edge case was found and handled
- A configuration or environment change was made

Phrasing to use: *"This is worth saving to Obsidian — want me to run `/mems`?"*
