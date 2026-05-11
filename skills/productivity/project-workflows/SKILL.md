---
name: project-workflows
description: Generate a project-specific WORKFLOWS.md that maps named slash-command chains to personas and skills, tailored to the project's stack, domain, and conventions. Use when user wants to define workflows for a project, set up a new project's AI tooling, or asks "how do I apply these skills to my project".
---

# Project Workflows

Generates a `WORKFLOWS.md` inside the target project's `.claude/` folder with named, domain-aware workflow chains built from available personas and skills.

## Quick start

```
/project-workflows pay-tracker
/project-workflows /Users/orla/dev/axiriam-shop
/project-workflows          ← uses current working directory
```

## Process

### 1. Resolve the target project

- If `$ARGUMENTS` is a path → use it directly
- If `$ARGUMENTS` is a name → search `~/dev/` for a matching directory
- If empty → use the current working directory

### 2. Read project context (in order, stop when enough is known)

```
.claude/CLAUDE.md       ← conventions, stack overrides, rules
.agents/CONTEXT.md      ← domain model, business rules, architecture
package.json            ← JS/TS stack (Next.js, Supabase, Prisma, Stripe…)
*.csproj / *.sln        ← .NET stack
pubspec.yaml            ← Flutter/Dart
Cargo.toml              ← Rust
```

If none exist, ask the user: "What's the stack and main domain of this project?"

### 3. Map stack → personas + skills

Use the table in [STACK-MAP.md](./STACK-MAP.md) to decide which skills apply.
When a project has both frontend and backend, include both tracks.

### 4. Identify the project's domain nouns

Extract 3–5 core entities from CONTEXT.md or package.json scripts/folder names.
These become the workflow names (e.g. `/new-invoice`, `/audit-stripe`, not `/new-feature`).

### 5. Generate 4–6 workflows

Follow the format in [WORKFLOWS-FORMAT.md](./WORKFLOWS-FORMAT.md).

Rules:
- Name each workflow after a domain action, not a generic verb
- Each workflow = trigger name + persona(s) + ordered skill chain + 1-line domain note
- Include at least: one feature workflow, one security/quality workflow, one UI or mobile workflow
- Skip skills that don't apply to this stack (no `/responsive-audit` for a pure API project)

### 6. Write the output

Write to `{project}/.claude/WORKFLOWS.md`.
If `.claude/` doesn't exist, create it.
Print a summary of what was generated.

## What NOT to do

- Don't generate generic workflow names (`/new-feature`, `/fix-bug`) — use domain language
- Don't include every available skill — curate the 4–6 that matter for this project
- Don't skip step 2 — always read context before generating
- Don't overwrite an existing `WORKFLOWS.md` without showing a diff and asking first
