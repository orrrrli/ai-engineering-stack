# My AI Stack

Central AI stack for all engineering projects: global rules, specialized agents, and skills for autonomous, context-aware development in Claude Code.

**Claude Code only.** Support for Windsurf, OpenCode, and other editors was removed — everything here targets Claude Code's own conventions (`.claude/commands/`, `.claude/agents/`, root `CLAUDE.md`).

## Installation

Use the init script rather than symlinking by hand. It wires the symlinks, the
context tree, the gitignore entries, and the Obsidian bridge in one pass.

```bash
# Web / Next.js project
~/dev/ai-engineering-stack/init-project.sh ~/dev/my-app --stack=web

# .NET Clean Architecture project
~/dev/ai-engineering-stack/init-dotnet-project.sh ~/dev/my-api

# Android / Kotlin project
~/dev/ai-engineering-stack/init-project.sh ~/dev/my-app --stack=android
```

### `--stack` — install only what the project needs

Every skill and agent declares a `stacks:` field in its frontmatter, and the init
script links only the matching ones. An Android project has no use for
`page-new`, and a .NET project has none for `mobile-ui-expert`.

| `--stack` | skills | agents |
|-----------|--------|--------|
| `web`     | 39 | 11 |
| `dotnet`  | 30 | 10 |
| `android` | 30 | 10 |
| `all`     | 42 | 12 |

Omitting the flag installs everything (`all`); `init-dotnet-project.sh` defaults
to `dotnet`.

### After init

1. Open Claude Code in the project and run `/fill-context`. It scans the codebase,
   asks what the code cannot tell it, and writes the `.claude/` context tree with
   the root `CLAUDE.md` as its index.
2. Optionally run `/fill-triggers` to generate `.claude/engineering/agent-triggers.md` —
   an explicit table of which paths delegate to which agent.
3. For a brand-new project, `/project-bootstrap` scaffolds the skeleton plus one
   vertical slice end to end.

### What gets committed

The context tree is team-shared instructions, so it belongs in source control.
The generated `.gitignore` excludes only what is machine-local or a symlink
into this stack:

| Committed | Ignored |
|-----------|---------|
| `CLAUDE.md` | `.claude/commands` (symlink) |
| `.claude/business/`, `architecture/`, `domains/`, `engineering/` | `.claude/agents` (symlink) |
| `.claude/settings.json` | `.claude/settings.local.json` |
| | `docs/brain` (symlink to the Obsidian vault) |

> [!IMPORTANT]
> Projects initialized before this change have a bare `.claude/` line in their
> `.gitignore`, which keeps the whole tree out of git. The init script detects it
> and tells you, but cannot fix it — a `.gitignore` entry added later cannot
> override a broader one already there. Remove the `.claude/` line by hand, then
> `git add .claude`.

> The index lives in the root `CLAUDE.md`, not `.claude/CLAUDE.md`. Claude Code
> auto-loads a project CLAUDE.md from either location, so the rule is not about
> which one gets read — it is about keeping one file instead of two that drift
> apart. The root is the convention and the one visible on clone.
>
> The files it links to (`.claude/business/*.md`, etc.) are read on demand, when
> a task leads Claude to them.

## Tooling

Four tools sit around this stack. They solve different problems and none
replaces another.

| Tool | Version | What it does |
|------|---------|--------------|
| **rtk** | 0.47 | CLI proxy that filters and summarizes command output *before* it reaches the context. `git`, `ls`, `find`, `rg`, `docker`, `dotnet`, `pnpm` and friends get rewritten transparently by a hook. 60-90% fewer tokens on routine dev operations. |
| **headroom** | 0.37 | Context optimization layer for LLM applications — a proxy that compresses traffic to the model, plus stored memories and a savings dashboard (`headroom savings`, `headroom dashboard`). |
| **claude-mem** | — | Persistent memory across sessions, captured by hooks with nothing to call. Prior work is injected as context when a session opens. |
| **[graphify](https://github.com/Graphify-Labs/graphify)** | 0.8 | Turns a codebase into a queryable knowledge graph — tree-sitter AST parsing across 37 languages, plus docs, SQL and PDFs. Ask `graphify query "..."` instead of grepping; `path A B` traces how two things connect, `affected X` finds what a change breaks. |

`rtk` trims what the tools send; `headroom` trims what reaches the model;
`claude-mem` remembers across sessions; `graphify` answers questions the code
can already answer, so the context tree does not have to. See
`PERSISTENT-MEMORY.md` for how claude-mem pairs with Obsidian.

Graphify writes to `graphify-out/` (`graph.json`, `graph.html`, and a
`GRAPH_REPORT.md` naming the god nodes — the entities everything else touches).
Every edge is tagged `EXTRACTED` when it is explicit in the source or
`INFERRED` when graphify resolved it, so derived structure stays separable from
fact. It runs offline for code; LLM calls happen only for the semantic pass over
docs and media. Keep `graphify-out/` out of version control.

> [!IMPORTANT]
> claude-mem records what happened, not why you decided it. Run `/sum` at the
> end of each work session so the reasoning lands in Obsidian too.

## Skills

30 skills across 6 categories. Each category directory has its own README with
one-line descriptions.

### `engineering/` (15)
Layer audits per stack — **audit-layer-boundaries** (web), **dotnet-clean-architecture**,
**android-clean-architecture** — plus **sdd-apply**, **prd-to-github-backlog**,
**project-bootstrap**, **fill-context**, **fill-triggers**, **tdd**, **diagnose**,
**quality-review**, **grill-with-docs**, **improve-codebase-architecture**,
**prompt-rewrite**, **sdd-verify**.

### `api/` (3)
**api-new**, **api-protect**, **api-test**.

### `ui/` (4)
**component-new**, **component-adapt**, **page-new**, **responsive-audit**.

### `productivity/` (5)
**caveman**, **grill-me**, **handoff**, **project-workflows**, **write-a-skill**.

`ponytail` is no longer vendored here — it is installed as a Claude Code plugin.

### `misc/` (2), `personal/` (1)
See [misc/README.md](./skills/misc/README.md) and [personal/README.md](./skills/personal/README.md).

## Agents

Agents set the behavior, expertise, and mindset for a session. Invoke one when
the work calls for a specific engineering focus.

| Agent | Focus | Stacks |
|-------|-------|--------|
| **backend-architect** | Database design, API reliability, data integrity | dotnet, web |
| **frontend-architect** | UI/UX, React state management, component modularity | web |
| **mobile-ui-expert** | Mobile-first design, touch interfaces, mobile performance | android |
| **system-architect** | High-level system design, boundaries, long-term strategy | all |
| **security-engineer** | Vulnerabilities, sanitization, security policy | all |
| **performance-engineer** | Profiling, rendering, query and load-time optimization | all |
| **refactoring-expert** | Technical debt, SOLID, simplifying complex logic | all |
| **deep-research-agent** / **tech-stack-researcher** | Exhaustive research before writing code | all |
| **requirements-analyst** / **technical-writer** | PRDs, documentation, ADRs | all |
| **learning-guide** | Explains progressively instead of just writing the code | all |

## Key Files

| File | Purpose |
|------|---------|
| `init-project.sh` | Project setup, `--stack` aware |
| `init-dotnet-project.sh` | Same, for .NET Clean Architecture (defaults to `dotnet`) |
| `global-rules.md` | Global engineering standards |
| `PERSISTENT-MEMORY.md` | claude-mem + Obsidian memory guide |
| `OBSIDIAN-INTEGRATION.md` | Obsidian vault symlink bridge |
