---
name: sdd-verify
stacks: [all]
argument-hint: "[task-id or task description]"
description: >
  Validate an implementation against its spec and deliver a PASS/FAIL verdict,
  criterion by criterion, with file:line evidence for every failure. Report
  only — never fixes anything, never marks a task done. Use after implementing
  a task, when the user says "verify this", "does this match the spec",
  "sdd-verify", or asks whether an implementation satisfies its acceptance
  criteria.
---

# SDD Verify — Validate implementation against spec

## Trigger
`/sdd-verify [task-id or task description]`

## What this skill does
Compares the current implementation against the spec (requirements.md + design.md) and delivers a clear PASS or FAIL verdict with specifics. Report only — never auto-fix.

## Steps

### 1. Locate the spec
Find `tasks.md`, `requirements.md`, and `design.md` in `.kiro/specs/` or a user-provided path.

### 2. Find the task
Locate the task by ID or description. Show the user the exact task text and its acceptance criteria.

### 3. Identify changed files
Run `git diff --name-only HEAD` or `git status` to find files modified during implementation.
If nothing is staged/changed, ask the user which files to review.

### 4. Read the implementation
Read every changed file in full. Do not skim.

### 5. Verify criterion by criterion
For each acceptance criterion in `requirements.md`: does the implementation satisfy it?
For each design decision in `design.md`: was it followed?

### 6. Report verdict

```
PASS ✓  [task-id] — [task title]
  ✓ Criterion 1: [brief evidence]
  ✓ Criterion 2: [brief evidence]

FAIL ✗  [task-id] — [task title]
  ✓ Criterion 1: [brief evidence]
  ✗ Criterion 2: [what's missing — file:line]
  ✗ Design constraint X not followed: [specific deviation]
```

## Hard rules
- Never guess. If you cannot find the implementation, say so explicitly.
- FAIL findings must include file path and line number — no vague descriptions.
- Do NOT fix anything. Report only. The user decides what happens next.
- Do NOT mark the task as done. That is the user's decision.
