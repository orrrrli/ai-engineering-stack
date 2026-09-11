#!/bin/bash

# Resolves the absolute path to the directory containing this script
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTNET_SKILLS_DIR="$HOME/dev/dotnet-clean-architecture-skills"
# Parse args: optional target dir, plus --stack=all|web|dotnet|android
STACK="dotnet"
POSITIONAL=()
for arg in "$@"; do
    case "$arg" in
        --stack=*) STACK="${arg#--stack=}" ;;
        -h|--help)
            echo "usage: init-dotnet-project.sh [target-dir] [--stack=all|web|dotnet|android]"
            exit 0 ;;
        *) POSITIONAL+=("$arg") ;;
    esac
done
case "$STACK" in
    all|web|dotnet|android) ;;
    *) echo "❌ Unknown stack '$STACK'. Use: all, web, dotnet, android"; exit 1 ;;
esac

TARGET_DIR="${POSITIONAL[0]:-$(pwd)}"
PROJECT_NAME="$(basename "$TARGET_DIR")"

# --- stack filtering -------------------------------------------------------
# Returns 0 if the file's `stacks:` frontmatter includes $STACK (or "all").
stack_match() {
    [ "$STACK" = "all" ] && return 0
    local line
    # -a: some SKILL.md files contain stray control bytes, and without it grep
    # answers "Binary file ... matches" instead of the line.
    line="$(grep -a -m1 '^stacks: \[' "$1")" || return 1
    case "$line" in
        *all*|*"$STACK"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Symlinks every matching skill into $1, keeping the category/ nesting so
# slash-command names stay <category>:<skill>.
link_stack_skills() {
    local dest="$1" cat skill
    LINKED_SKILLS=0
    mkdir -p "$dest"
    for cat in "$STACK_DIR/skills"/*/; do
        for skill in "$cat"*/; do
            [ -f "${skill}SKILL.md" ] || continue
            stack_match "${skill}SKILL.md" || continue
            mkdir -p "$dest/$(basename "$cat")"
            ln -sfn "${skill%/}" "$dest/$(basename "$cat")/$(basename "$skill")"
            LINKED_SKILLS=$((LINKED_SKILLS + 1))
        done
    done
}

link_stack_agents() {
    local dest="$1" f
    LINKED_AGENTS=0
    mkdir -p "$dest"
    for f in "$STACK_DIR/agents"/*.md; do
        stack_match "$f" || continue
        ln -sfn "$f" "$dest/$(basename "$f")"
        LINKED_AGENTS=$((LINKED_AGENTS + 1))
    done
}


echo "Initializing .NET AI Stack for project: $PROJECT_NAME at $TARGET_DIR"

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || { echo "Failed to cd to $TARGET_DIR"; exit 1; }

# 1. Setup Claude Code symlinks
mkdir -p .claude .agents

# Remove old links, including names used before the Claude-Code-only migration
rm -rf .claude/commands .claude/agents .agents/skills
rm -f .claude/skills .claude/personas .claude/recipes
rm -f .agents/personas .agents/agents .agents/recipes

link_stack_skills ".claude/commands"
link_stack_agents  ".claude/agents"

# The external .NET skills repo carries no stacks: frontmatter — it is all .NET
# by definition, so it links wholesale.
ln -s "$DOTNET_SKILLS_DIR/skills"  ".claude/commands/dotnet"
ln -s "$DOTNET_SKILLS_DIR/recipes" ".claude/recipes"
echo "✅ Linked $LINKED_SKILLS skills and $LINKED_AGENTS agents for stack '$STACK', plus the .NET skills repo"

# 2. Setup CONTEXT.md in .agents
if [ ! -f ".agents/CONTEXT.md" ]; then
    cp "$STACK_DIR/CONTEXT.template.md" ".agents/CONTEXT.md"
    # Mac OS requires an empty string for the backup extension in sed -i
    sed -i '' "s/\[Project Name\]/$PROJECT_NAME/g" ".agents/CONTEXT.md"
    echo "✅ Created .agents/CONTEXT.md"
else
    echo "⚠️ .agents/CONTEXT.md already exists, skipping."
fi

# 3. Setup Obsidian Persistent Memory
OBSIDIAN_BASE="$HOME/Documents/Obsidian_Brain/Projects"
mkdir -p "$OBSIDIAN_BASE"
OBSIDIAN_PROJ="$OBSIDIAN_BASE/$PROJECT_NAME"

mkdir -p "$OBSIDIAN_PROJ/ADR"
mkdir -p "$OBSIDIAN_PROJ/Bugs"

if [ ! -f "$OBSIDIAN_PROJ/Index.md" ]; then
    cat > "$OBSIDIAN_PROJ/Index.md" <<EOF
# $PROJECT_NAME - Index

Welcome to the Obsidian Brain for **$PROJECT_NAME**. This space contains all persistent memory, architectural decisions, and deep context for the project.

## 🏛️ Architecture Decision Records (ADR)
*(Add links to ADRs here)*

## 📚 Technical Documentation
*(Add technical docs here)*

## 🐛 Bugs & Learnings
*(Create new notes here when tricky bugs are resolved)*

---
*Note for AI Agents: Always use \`[[wikilinks]]\` when creating new documents to link them back to this Index.*
EOF
    echo "✅ Created Obsidian Index.md"
else
    echo "⚠️ Obsidian Index.md already exists, skipping."
fi

# 4. Setup docs/brain symlink
mkdir -p docs
rm -f docs/brain
ln -s "$OBSIDIAN_PROJ" docs/brain
echo "✅ Setup docs/brain symlink"

# 5. Gitignore
GITIGNORE_ENTRIES=(
    ".agents/"
    ".claude/"
    "docs/brain/"
    "docs/brain"
)

if [ ! -f ".gitignore" ]; then
    touch ".gitignore"
    echo "✅ Created .gitignore"
fi

# Add header only if it doesn't exist
HEADER="# AI Engineering Stack & Obsidian Brain"
if ! grep -q "$HEADER" ".gitignore"; then
    echo -e "\n$HEADER" >> ".gitignore"
fi

for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if ! grep -q "^$entry" ".gitignore"; then
        echo "$entry" >> ".gitignore"
        echo "✅ Added $entry to .gitignore"
    else
        echo "⚠️ $entry already in .gitignore, skipping."
    fi
done
# Clean up potential double newlines
sed -i '' '/^$/N;/^\n$/D' ".gitignore" 2>/dev/null || true

# 6. Global & Editor Rules
RULE_CONTENT="Always adhere to the global engineering standards defined in the symlinked AI stack, and read .agents/CONTEXT.md before proceeding. For deep architectural context, check docs/brain/Index.md. Note: This project uses .NET Clean Architecture skills and recipes."

# General Agents Rules
if [ -d ".agents" ] && [ ! -f ".agents/rules.md" ]; then
    echo "$RULE_CONTENT" > ".agents/rules.md"
    echo "✅ Created .agents/rules.md"
fi

# 7. Setup root CLAUDE.md
# Claude Code auto-loads the repo-root CLAUDE.md into every session — nothing
# inside .claude/ gets that treatment, so this must live at the repo root.
if [ ! -f "CLAUDE.md" ]; then
    cat > "CLAUDE.md" <<EOF
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **IMPORTANT**: For architecture rules, layer boundaries, and business logic, you MUST read \`.agents/CONTEXT.md\`. For deeper architectural context, checkout flows, and auth details, read the notes in \`docs/brain\` using the \`obsidian-vault\` skill.
> **.NET Clean Architecture**: Refer to \`.claude/recipes\` for backend workflows.

---

## Commands

\`\`\`bash
dotnet build         # Build project
dotnet test          # Run tests
\`\`\`
EOF
    echo "✅ Created CLAUDE.md"
else
    echo "⚠️ CLAUDE.md already exists, skipping."
fi

echo "🎉 .NET Initialization complete for $PROJECT_NAME!"
