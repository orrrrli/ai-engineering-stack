# Stack → Skills Map

Used by the `project-workflows` skill to decide which skills and personas to include.

## Detection signals

| Signal | Stack identified |
|--------|-----------------|
| `next` in package.json dependencies | Next.js (App Router assumed if version >= 13) |
| `@prisma/client` | Prisma ORM |
| `@supabase/supabase-js` | Supabase |
| `stripe` | Stripe payments |
| `next-auth` | NextAuth.js |
| `react-hook-form` + `zod` | RHF + Zod validation |
| `*.csproj` / `*.sln` present | .NET / C# |
| `MediatR` in `.csproj` | CQRS / Clean Architecture |
| `pubspec.yaml` | Flutter |
| `react-native` | React Native |
| `tailwindcss` | Tailwind CSS |
| `framer-motion` / `gsap` | Animation-heavy UI |

---

## Skill inclusion rules

### Always include
- `/grill-me` → feature definition
- `/diagnose` + `/tdd` → bug fixing
- `[requirements-analyst]` → before any feature

### Include when: Next.js detected
- `/page-new`, `/component-new` → UI scaffolding
- `/api-new` → route scaffolding
- `/responsive-audit` → UI quality
- `[frontend-architect]` persona
- `[mobile-ui-expert]` persona

### Include when: Supabase detected
- `supabase:types-gen` → after any schema change
- `supabase:edge-function-new` → for serverless logic
- `[backend-architect]` persona for RLS policies

### Include when: Prisma detected
- DB workflow: schema change → `prisma generate` → `/api-test`
- `[backend-architect]` persona for migration reviews

### Include when: Stripe detected
- `/audit-{payment-entity}` workflow is mandatory — always include
- `/api-protect` → webhook signature validation
- `/vibe-security` → payment flow audit

### Include when: NextAuth detected
- `/api-protect` → session/JWT hardening
- `[security-engineer]` persona in auth-related workflows

### Include when: .NET / C# detected
- `[backend-architect]` persona for CQRS/MediatR patterns
- `[system-architect]` persona for Clean Architecture layer boundaries
- No `/page-new`, `/component-new`, `/responsive-audit` unless a React frontend is also detected

### Include when: Tailwind + animation libs detected
- `/responsive-audit` → breakpoint review
- `[mobile-ui-expert]` → touch and motion considerations

### Include when: React Native or Flutter detected
- `[mobile-ui-expert]` as primary UI persona
- `/responsive-audit` adapted for screen sizes, not breakpoints

---

## Workflow count rules

| Project type | Min workflows | Max workflows |
|---|---|---|
| Full-stack (frontend + backend + DB) | 5 | 6 |
| Frontend only | 3 | 4 |
| Backend / API only | 3 | 4 |
| Mobile | 4 | 5 |

Never pad with generic workflows to hit a count — fewer sharp workflows beat many vague ones.
