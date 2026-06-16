---
name: fill-context
description: >
  Generate or regenerate .agents/CONTEXT.md by scanning the codebase and
  grilling the developer on what can't be inferred from code alone — domain
  purpose, users, and critical business rules. Use after init-project.sh,
  or any time CONTEXT.md is missing, stale, or full of placeholders.
version: "1.0.0"
modes: [architect]
---

# Fill Context

Generate a complete `.agents/CONTEXT.md` from real project data — not guesses, not placeholders.

**Core principle:** Derive everything possible from the codebase first. Only ask the developer for what the code cannot tell you.

---

## Phase 1 — Scan the Codebase

Run these scans silently. Do NOT report findings yet — just collect data.

### 1.1 Framework and stack
```bash
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat *.csproj 2>/dev/null | head -60
```

### 1.2 Directory structure
```bash
eza --tree --level=3 --ignore-glob="node_modules|.git|.next|dist|build|coverage" 2>/dev/null || find . -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.next/*' -maxdepth 3 -type d
```

### 1.3 Database schema (entities and vocabulary)
```bash
cat prisma/schema.prisma 2>/dev/null
cat src/Domain/**/*.cs 2>/dev/null | head -200
find . -name "*.sql" -not -path '*/node_modules/*' | head -5 | xargs cat 2>/dev/null | head -100
```

### 1.4 Existing README
```bash
cat README.md 2>/dev/null | head -80
```

### 1.5 Existing CONTEXT.md (check if stub or placeholder)
```bash
cat .agents/CONTEXT.md 2>/dev/null
```

From the scan, derive:
- **Framework** (Next.js, .NET, etc.) and version
- **Database** and ORM
- **Key integrations** (Stripe, Resend, Supabase, etc.)
- **Entity names** and their rough definitions from schema model names
- **Directory conventions** and architecture pattern
- **App name** from package.json or README

---

## Phase 2 — Targeted Grill

Only ask about what Phase 1 could NOT determine. Never ask for something the code already told you.

Say exactly this to the developer:

> "I've scanned the codebase. I can see it's a **[detected stack]** project with **[detected entities]**. I need 3 answers to complete your CONTEXT.md — the code can't tell me these:"

Then ask ONLY these questions (all at once, numbered):

1. **Business purpose** — What problem does this project solve, and who uses it? (2-3 sentences max)
2. **Critical business rules** — What are the 2-3 rules that the code must NEVER break? Think: "if this fails, the business breaks." (e.g., "Users cannot access data from other accounts", "Orders cannot be placed with 0-stock items")
3. **Domain vocabulary** — Is there any entity or concept in the code whose name is misleading or doesn't match how the business talks about it? (e.g., "`User` in code = `Client` in business speak")

Wait for the developer's answers before proceeding to Phase 3.

---

## Phase 3 — Generate CONTEXT.md

Using the scan data (Phase 1) + developer answers (Phase 2), write `.agents/CONTEXT.md`.

Use this exact structure. Fill every section with real data — no brackets, no placeholders:

```markdown
# [Project Name] - Local Context

> **Instruction for the AI:** This file defines the Domain, Architecture, and Business Rules for this project. Read it before proposing architectural changes, adding entities, or modifying business logic.

## 1. Business Overview
- **Purpose:** [From developer answer #1]
- **Core Users:** [From developer answer #1]
- **Critical Invariants:** [From developer answer #2 — these are non-negotiable]

## 2. Domain Model (Ubiquitous Language)
*The exact vocabulary the AI and developers MUST use in code, variables, and database tables.*

[List every entity found in Phase 1, with a one-line definition each.
Apply any vocabulary corrections from developer answer #3.
Add a warning if the code name differs from the business name.]

*(Note to AI: NEVER invent synonyms. If the entity is called `Order`, do not use `Purchase`.)*

## 3. Local Architecture and Stack
- **Core Framework:** [from scan]
- **Database / ORM:** [from scan]
- **UI / Styling:** [from scan]
- **Key Integrations:** [from scan — only what's actually in package.json/deps]
- **Auth:** [from scan]
- **Architecture Pattern:** [from scan — e.g., "App Router with server actions", "Clean Arch CQRS"]

## 4. Strict Business Rules
[Numbered list from developer answer #2.
Be specific: what triggers the rule, what the consequence is, where it must be enforced.]

## 5. Directory Structure
[From Phase 1 scan — explain what each key directory is for, using the project's actual paths]

## 6. Memory and Decisions (ADRs)
- Architectural decisions (why X over Y) are documented in **Obsidian** under `docs/brain/ADR/`.
- For deep context on past bugs or infrastructure decisions, use the `obsidian-vault` skill.
```

---

## Phase 4 — Confirm and Write

Before writing the file:
1. Show the generated CONTEXT.md to the developer
2. Ask: "Does this look right? Anything to correct before I write it?"
3. Wait for confirmation
4. Write to `.agents/CONTEXT.md`
5. Print: "✅ CONTEXT.md generated. Your AI now has domain context for this project."

---

## Rules

- NEVER write a placeholder like `[Entity 1]` or `[Ex: ...]` in the output. If you don't know something, say so and ask.
- NEVER skip Phase 1. Asking for information the code already has is lazy and wastes the developer's time.
- NEVER write more than 3 questions in Phase 2. The grill is focused, not exhaustive.
- If `.agents/CONTEXT.md` already exists with real content (not placeholders), show it first and ask: "This already has content — do you want to regenerate it or update a specific section?"
- If the project has no `package.json` and no recognized structure, say so and ask the developer what stack they're using before scanning further.
