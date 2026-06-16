#!/bin/bash

# Resolves the absolute path to the directory containing this script
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"
PROJECT_NAME="$(basename "$TARGET_DIR")"

echo "Initializing AI Stack for project: $PROJECT_NAME at $TARGET_DIR"

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR" || { echo "Failed to cd to $TARGET_DIR"; exit 1; }

# 1. Setup dot directories and symlinks
for agent_dir in .agents .claude .opencode .windsurf; do
    mkdir -p "$agent_dir"
    
    # Remove old symlinks if they exist
    rm -f "$agent_dir/skills" "$agent_dir/personas" "$agent_dir/commands" "$agent_dir/agents"
    
    if [ "$agent_dir" = ".claude" ]; then
        ln -s "$STACK_DIR/skills" "$agent_dir/commands"
        ln -s "$STACK_DIR/personas" "$agent_dir/agents"
    elif [ "$agent_dir" = ".windsurf" ]; then
        ln -s "$STACK_DIR/skills" "$agent_dir/skills"
        ln -s "$STACK_DIR/personas" "$agent_dir/personas"
        
        # Create workflows directory for Windsurf slash commands
        mkdir -p "$agent_dir/workflows"
        find "$STACK_DIR/skills" -type f -name "SKILL.md" | while read -r skill_file; do
            skill_dir=$(dirname "$skill_file")
            skill_name=$(basename "$skill_dir")
            rm -f "$agent_dir/workflows/$skill_name.md"
            ln -s "$skill_file" "$agent_dir/workflows/$skill_name.md"
        done
    else
        ln -s "$STACK_DIR/skills" "$agent_dir/skills"
        ln -s "$STACK_DIR/personas" "$agent_dir/personas"
    fi
    echo "✅ Setup symlinks in $agent_dir"
done

# 2. Setup CONTEXT.md stub in .agents
if [ ! -f ".agents/CONTEXT.md" ]; then
    cat > ".agents/CONTEXT.md" <<EOF
# $PROJECT_NAME - Local Context

> **CONTEXT NOT YET GENERATED.**
> Run \`/fill-context\` in Claude Code to generate this file automatically.
> The AI will scan the codebase and ask 3 targeted questions to complete it.
EOF
    echo "✅ Created .agents/CONTEXT.md stub"
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
    ".opencode/"
    ".windsurf/"
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
RULE_CONTENT="Always adhere to the global engineering standards defined in the symlinked AI stack, and read .agents/CONTEXT.md before proceeding. For deep architectural context, check docs/brain/Index.md."

# Windsurf
if [ -d ".windsurf" ] && [ ! -f ".windsurf/rules.md" ]; then
    echo "$RULE_CONTENT" > ".windsurf/rules.md"
    echo "✅ Created .windsurf/rules.md"
fi

# OpenCode Specific Rules
if [ -d ".opencode" ] && [ ! -f ".opencode/rules.md" ]; then
    echo "$RULE_CONTENT" > ".opencode/rules.md"
    echo "✅ Created .opencode/rules.md"
fi

# General Agents Rules
if [ -d ".agents" ] && [ ! -f ".agents/rules.md" ]; then
    echo "$RULE_CONTENT" > ".agents/rules.md"
    echo "✅ Created .agents/rules.md"
fi


# 7. Setup CLAUDE.md
if [ ! -f ".claude/CLAUDE.md" ]; then
    cat > ".claude/CLAUDE.md" <<EOF
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **IMPORTANT**: For architecture rules, layer boundaries, and business logic, you MUST read \`.agents/CONTEXT.md\`. For deeper architectural context, checkout flows, and auth details, read the notes in \`docs/brain\` using the \`obsidian-vault\` skill.

---

## Commands

\`\`\`bash
npm run dev          # Dev server
npm run lint         # ESLint
npm run test         # Unit tests
\`\`\`
EOF
    echo "✅ Created .claude/CLAUDE.md"
fi

echo ""
echo "🎉 Initialization complete for $PROJECT_NAME!"
echo ""
echo "👉 Next step: open Claude Code in this project and run:"
echo "   /fill-context"
echo "   The AI will scan the codebase and ask 3 questions to generate your CONTEXT.md."
