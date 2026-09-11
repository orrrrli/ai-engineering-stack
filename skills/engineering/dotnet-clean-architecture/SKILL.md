---
name: dotnet-clean-architecture
description: Scan a .NET Clean Architecture solution for the five violations that break the dependency rule — Domain referencing EF Core, handlers touching DbContext directly, Application referencing Infrastructure, controllers bypassing MediatR, and exceptions used for expected business errors. Use when adding a feature, after a large refactor, or whenever project references have drifted.
stacks: [dotnet]
---

# Audit .NET Clean Architecture Boundaries

Scan for violations of the dependency rule. Dependencies point INWARD only:

```
API / Web          ← composition root — MediatR only, no DbContext, no repositories
    ↓
Application        ← handlers, DTOs, validators — DEFINES interfaces, implements none
    ↓
Domain             ← entities, value objects, domain errors — ZERO project/package refs
    ↑
Infrastructure     ← EF Core, external clients — IMPLEMENTS Application's interfaces
```

`Infrastructure` points UP at `Application`, never the reverse. `Domain` points at nothing.
`API` references `Infrastructure` for DI registration ONLY — never to call it.

---

## The Five Patterns to Find

### Pattern 1 — Domain references anything

`Domain.csproj` has a `PackageReference` or `ProjectReference`. Most common offender: `Microsoft.EntityFrameworkCore`, added so an entity can carry a `[Key]` attribute or a navigation property configured inline.

**Why it breaks things:** The moment Domain knows about EF Core, your business rules are welded to a persistence library. You can't unit-test an entity without dragging in a DbContext, and swapping the ORM becomes a rewrite instead of a config change.

**Fix:** Remove the reference. Move the mapping into `Infrastructure/Persistence/Configurations/<Entity>Configuration.cs` using `IEntityTypeConfiguration<T>`. Fluent API expresses everything attributes do, and it lives in the layer that owns persistence.

---

### Pattern 2 — Handler depends on the concrete DbContext

A handler in `Application/**` has `using` of `Infrastructure.*`, or injects `ApplicationDbContext` instead of an abstraction.

**Why it breaks things:** Application is supposed to declare what it needs and let Infrastructure satisfy it. A handler bound to the concrete context can't be tested without a real database, and the dependency arrow now points outward — the exact thing Clean Architecture exists to prevent.

**Fix:**
1. Declare `IApplicationDbContext` in `Application/Common/Interfaces/` exposing only the `DbSet<T>` properties handlers actually use, plus `SaveChangesAsync`.
2. Have `ApplicationDbContext : DbContext, IApplicationDbContext` in Infrastructure.
3. Register it: `services.AddScoped<IApplicationDbContext>(p => p.GetRequiredService<ApplicationDbContext>());`
4. Inject the interface in the handler.

Note: `IApplicationDbContext` is a legitimate abstraction, not a leaky one — it names the data the layer needs without naming the provider behind it. A full repository per aggregate is also fine; pick one and stay consistent.

---

### Pattern 3 — Application references Infrastructure

`Application.csproj` has `<ProjectReference Include="..\Infrastructure\Infrastructure.csproj" />`.

**Why it breaks things:** This inverts the whole architecture. Everything inside Application can now reach EF Core, HTTP clients, and third-party SDKs, and the compiler stops protecting the boundary. Pattern 2 becomes invisible because nothing flags it any more.

**Fix:** Delete the reference and fix whatever breaks — each break is a real violation the reference was hiding. Interfaces move to `Application/Common/Interfaces/`, implementations stay in Infrastructure, and `API` wires them together in DI.

---

### Pattern 4 — Controller bypasses MediatR

A controller in `API/**` injects a repository, `IApplicationDbContext`, or a service directly, instead of sending a Command or Query.

**Why it breaks things:** The controller becomes a second place where business flows live. Pipeline behaviours — validation, logging, transactions — attach to MediatR, so anything bypassing it silently skips all of them. Your `ValidationBehavior` doesn't run and invalid input reaches the database.

**Fix:** Move the logic into a Command or Query handler in Application. The controller keeps exactly three jobs: bind the request, `await _sender.Send(command)`, map the result to an HTTP status.

---

### Pattern 5 — Exceptions for expected business errors

A handler throws (`NotFoundException`, `InsufficientBalanceException`) for an outcome that is a normal, predictable branch of the business flow.

**Why it breaks things:** Exceptions are for the unexpected. Using them for "the email is already taken" makes an ordinary path cost a stack-trace capture, hides the outcome from the method signature, and pushes control flow into middleware where it can't be tested. The caller can't tell from `Task<User>` that three business failures are possible.

**Fix:** Return `ErrorOr<T>`. Declare the failures as `static Error` on the domain type, return them, and let the endpoint map errors to status codes via `Problem(errors)`.

```csharp
// before
if (user is null) throw new NotFoundException(nameof(User), id);

// after
if (user is null) return UserErrors.NotFound;
```

Genuinely exceptional cases — the database is unreachable, a required config key is missing — still throw. The test is whether the outcome is part of the business flow, not whether it is a failure.

---

## Process

### 1. Scan

```bash
# Pattern 1: Domain must have zero references
rg "PackageReference|ProjectReference" --glob "**/Domain*.csproj"

# Pattern 3: Application must not reference Infrastructure
rg "Infrastructure" --glob "**/Application*.csproj"

# Pattern 2: handlers reaching into Infrastructure or the concrete context
rg "using .*Infrastructure|ApplicationDbContext" --glob "src/Application/**/*.cs"

# Pattern 4: controllers injecting anything other than ISender/IMediator
rg "private readonly I\w+" --glob "src/**/Controllers/*.cs"

# Pattern 5: throws inside handlers
rg "throw new \w+Exception" --glob "src/Application/**/*.cs" --context 3
```

Pattern 4 needs a second look by hand: a controller injecting `ISender`, `IMapper`, or `ILogger` is fine. Anything domain- or data-shaped is the violation.

### 2. Report

Group by pattern. For each violation give:
- **File + line**
- **What it does** (one sentence)
- **Which fix applies**

Do NOT fix automatically. Show the list and ask: "Which violations do you want me to fix?"

### 3. Fix

Work one pattern at a time, in this order — **3 → 1 → 2 → 4 → 5**. Pattern 3 first because the project reference masks every other violation; once it's gone the compiler finds the rest for you.

After each pattern: `dotnet build` then `dotnet test`. Confirm green before moving to the next.

### 4. Commit

One commit per pattern. Prefix: `fix(arch):`.
