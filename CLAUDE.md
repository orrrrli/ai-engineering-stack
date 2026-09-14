# ai-engineering-stack

The Claude Code harness itself: skills, agents, and the init scripts that wire
them into a project. There is no application here — it is markdown and bash.

## Layout

```
skills/<category>/<name>/SKILL.md   42 skills across 7 categories
agents/<name>.md                    12 subagents
init-project.sh                     project setup, --stack aware
init-dotnet-project.sh              same, for .NET (defaults to --stack=dotnet)
global-rules.md                     engineering standards shipped to projects
```

`skills/` and `agents/` are symlinked into a target project as
`.claude/commands` and `.claude/agents` by the init scripts.

## Commands

```bash
./init-project.sh <dir> --stack=web|dotnet|android|all
./init-dotnet-project.sh <dir>
bash -n init-project.sh              # syntax check
```

There is no build, no test runner, and no package.json. To verify a change to
the init scripts, run them against a scratch directory and inspect the result —
they create real symlinks and a real Obsidian folder, so use a throwaway path
and clean up after.

## Conventions

**Every skill and agent declares `stacks:` in its frontmatter.** The init
scripts read it and link only what matches `--stack`, so a .NET project does
not receive `page-new`. Valid values: `all`, `web`, `dotnet`, `android`. `all`
is exclusive — never combine it with another value.

```yaml
---
name: my-skill
stacks: [web]
description: One line. This is what makes Claude load the skill, so say when to use it.
---
```

A skill with no `description` is never surfaced. A skill with no `stacks:` is
silently dropped from every filtered install.

**Claude Code only.** Support for Windsurf and OpenCode was removed; do not
reintroduce `.windsurf/`, `.opencode/` or their rules files.

**Category READMEs must match the directory.** `skills/misc/`, `personal/` and
`productivity/` each have a README listing their skills. Adding or removing a
skill means updating it in the same commit.

## Context

This repo has no `.claude/` context tree — `/fill-context` has never run here,
and for a repo this small the file you are reading is the whole context.

Project-level docs: `README.md` (installation and inventory),
`PERSISTENT-MEMORY.md` (claude-mem + Obsidian), `OBSIDIAN-INTEGRATION.md`.
