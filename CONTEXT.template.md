# [Project Name] - Local Context

> **Instruction for the AI:** This file defines the Domain, Architecture, and Business Rules exclusive to this project. Read it carefully before proposing architectural changes or adding new entities.

## 1. Business Overview
- **Purpose:** [Explain in 1-2 paragraphs what this project is and what problem it solves. Ex: A B2B SaaS platform for inventory management.]
- **Core Users:** [Ex: Warehouse administrators, Logistics employees, End customers.]
- **Success Metrics:** [Ex: Fast load times, high fault tolerance in the database.]

## 2. Domain Model (Ubiquitous Language)
*The exact vocabulary the AI and developers MUST use in code, variables, and database tables.*

- **`[Entity 1]` (e.g. User/Customer):** [Exact definition of what it means in this project].
- **`[Entity 2]` (e.g. Order):** [Definition].
- **`[Entity 3]` (e.g. Warehouse):** [Definition].
*(Note to AI: NEVER invent synonyms. If the entity is called `Order`, do not use `Purchase` or `Transaction` in the code).*

## 3. Local Architecture and Stack
*Although the general stack follows `global-rules.md`, specific tools for this project are defined here.*

- **Core Framework:** [Ex: Next.js 14 App Router]
- **Database / Backend:** [Ex: Supabase PostgreSQL]
- **ORM / Query Builder:** [Ex: Drizzle ORM]
- **UI / Styling:** [Ex: Tailwind CSS + shadcn/ui]
- **Global State:** [Ex: Zustand (only if necessary)]
- **Key Integrations:** [Ex: Stripe (Payments), Resend (Emails)]

## 4. Strict Business Rules
*Rules the code must never break under any circumstances.*

1. **[Rule 1]:** [Ex: Free users cannot create more than 3 'Projects'. Validate this in the API, not just the Frontend.]
2. **[Rule 2]:** [Ex: Every financial transaction must be saved in an immutable audit table.]
3. **[Rule 3]:** [Ex: Database deletes are logical (Soft Delete), never physical.]

## 5. Specific Directory Structure
- `[path/1]`: [What it is for. Ex: `src/app/api/` -> Only for external webhooks, everything else uses Server Actions.]
- `[path/2]`: [Ex: `src/lib/domain/` -> Where pure business logic functions live.]

## 6. Memory and Decisions (ADRs)
- Architectural decisions for this project (why we chose X over Y) are documented in **Obsidian**.
- If you need deep context about an old bug or an infrastructure decision, use the `obsidian-vault` skill to consult the notes associated with this project.
