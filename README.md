# My AI Stack

This repository serves as the central AI stack for all engineering projects. It contains global rules, specialized AI personas, and advanced skills to enable highly autonomous, context-aware AI development across editors like Windsurf, Claude Code, and OpenCode.

## Installation

To install this stack into a new or existing project, you must create a symbolic link (symlink) from your project's AI configuration directory to this central repository. This ensures that any updates you make to the master stack are instantly reflected across all your projects.

1. Clone this repository to a central location on your machine (e.g., `~/dev/my-ai-stack`).
2. In your target project root, run the following commands to symlink the necessary directories:

```bash
# Example for a project using Claude Code / OpenCode / Windsurf
mkdir -p .agents
ln -s ~/dev/my-ai-stack/skills ./.agents/skills
ln -s ~/dev/my-ai-stack/personas ./.agents/personas
```

3. Copy the `CONTEXT.template.md` to your project root, rename it to `CONTEXT.md`, and fill in your project's specific business logic and domain model.
4. Update your project's local rules file (e.g., `.windsurf/rules.md` or `.cursorrules`) to include this instruction:
   `Always adhere to the global engineering standards defined in the symlinked AI stack, and read CONTEXT.md before proceeding.`
5. Configure persistent memory — Engram MCP + Obsidian (see `PERSISTENT-MEMORY.md` for full guide).

This stack combines two memory systems:
- **Engram MCP**: Automatic, session-persistent memory. AI retrieves context automatically.
- **Obsidian**: Structured documentation (ADRs, bug logs) via symlinks.

Use `/mems` to save observations, `/sum` to close sessions — both write to both systems.

> [!IMPORTANT]
> Auto-triggered saves (AI calling `mem_save` automatically) only write to Engram, not Obsidian. Always run `/sum` at the end of each work session to ensure complete documentation in both systems.

## Available Skills

Skills are modular instructions that the AI can execute to solve specific problems. The AI will automatically discover these when symlinked.

### API
- **api-new**: Create a new Next.js API route with validation, error handling, and TypeScript.
- **api-protect**: Add authentication, authorization, and security to API endpoints.
- **api-test**: Test API endpoints with automated test generation.

### Engineering
- **diagnose**: Disciplined diagnosis loop for hard bugs and performance regressions.
- **improve-codebase-architecture**: Find refactoring opportunities and consolidate tightly-coupled modules.
- **tdd**: Test-driven development with red-green-refactor loop.
- **triage / to-issues / to-prd**: Break down plans into executable issues, PRDs, and manage issue workflows.
- **grill-with-docs / zoom-out**: Challenge architectural plans against the existing domain model.

### Misc and UI
- **code-cleanup / code-optimize**: Refactor code following best practices and optimize for performance.
- **lint / setup-pre-commit**: Run linting, fix quality issues, and set up Git hooks.
- **component-new / page-new**: Create new React components or Next.js App Router pages with modern standards.

### Supabase
- **types-gen**: Generate TypeScript types from Supabase database schema.
- **edge-function-new**: Create a new Supabase Edge Function with Deno.

### Productivity and Personal
- **caveman**: Ultra-compressed communication mode. Cuts token usage by dropping pleasantries.
- **grill-me**: Interview the user relentlessly about a plan until reaching shared understanding.
- **mems**: Save, search, and retrieve persistent memory across sessions with Engram.

## Available Personas

Personas dictate the overarching behavior, expertise, and mindset of the AI during a session. Invoke them when you need a specific type of engineering focus.

- **backend-architect**: Focuses on database design, scalability, and robust API development.
- **frontend-architect**: Focuses on UI/UX, React/Next.js state management, and component modularity.
- **system-architect**: Designs high-level system interactions, infrastructure, and deployment strategies.
- **security-engineer**: Audits code for vulnerabilities, sanitization issues, and enforces strict security policies.
- **performance-engineer**: Profiles code, optimizes rendering, minimizes database queries, and improves load times.
- **refactoring-expert**: Cleans up technical debt, applies SOLID principles, and simplifies complex logic.
- **deep-research-agent / tech-stack-researcher**: Conducts exhaustive research on new technologies or complex implementation problems before writing code.
- **requirements-analyst / technical-writer**: Translates user requirements into structured PRDs, documentation, and ADRs.
- **learning-guide**: Acts as a mentor to explain complex topics progressively rather than just writing the code for you.
