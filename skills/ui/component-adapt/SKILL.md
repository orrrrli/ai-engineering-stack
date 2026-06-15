---
name: component-adapt
description: Replicate, adapt, and integrate UI components from Figma designs, external source files (.tsx), or images into the project. Use when the user wants to adapt an external component, copy a design, or integrate a downloaded component while respecting the project's architecture.
---

# Component Adapt

## Quick Start

When adapting an external component or design, first identify the source material (image, Figma export, or `.tsx` file) and analyze the project's current architecture (e.g., UI library, styling solution like Tailwind, state management).

## Workflow

1. **Analyze Source Material**:
   - If image/Figma: Identify layout, colors, typography, spacing, and interactive states.
   - If `.tsx` file: Review the code for external dependencies, non-standard styling, or incompatible patterns.

2. **Understand Project Architecture**:
   - Check the project's design system, styling framework (e.g., Tailwind CSS, styled-components), and existing UI components.
   - Categorize the component using the **Atomic Design pattern** (Atoms, Molecules, Organisms, Templates, Pages).
   - Identify where the new component belongs in the directory structure based on its atomic level.

3. **Adapt & Implement**:
   - Replace generic HTML/CSS with the project's specific UI components (e.g., replace `<button>` with `<Button variant="primary">`).
   - Standardize styling to use project tokens (colors, spacing, typography).
   - Ensure the component uses the project's conventions for props, TypeScript interfaces, and state management.

4. **Review & Refine**:
   - Check for mobile responsiveness and adaptive layouts.
   - Ensure accessibility standards (ARIA labels, keyboard navigation) are met.

## Guidelines
- **Always use the Atomic Design Pattern**. Break down complex components from Figma or external files into smaller, reusable pieces (Atoms, Molecules) before building the larger composite component (Organism/Template).
- Do not blindly copy-paste code; adapt it to the project's specific conventions.
- Prefer existing project components (e.g., typography, buttons, inputs) over creating new ones from scratch if they already exist.
- Strip out unused code or dependencies from downloaded components.
