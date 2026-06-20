# Backlog manifest schema

`manifest.json` is the single source of truth. You author it from the PRD; the
scripts (`render_docs.py`, `create_issues.py`) consume it. Never hand-edit the
derived docs or GitHub — change the manifest and re-run.

## Top level

```jsonc
{
  "repo": "owner/name",            // required — where issues are created
  "owner": "login",                // required — repo/project owner login
  "owner_type": "user",            // "user" (default) or "organization"
  "project_owner": "login",        // optional — defaults to owner
  "project_number": 3,             // required — from setup_project.py
  "assignee": "login",             // optional — issue assignee (usually owner)
  "project_title": "Acme Backlog", // optional — used in doc header
  "backlog_url": "https://...",    // optional — link printed in epic bodies
  "screens": ["ON-1", "HM-1"],     // optional — if set, render asserts every
                                   //   screen is owned by some story.screens
  "epics": [ /* see below */ ]
}
```

## Epic

```jsonc
{
  "id": "EPIC-AUTH",          // required, unique. Convention: EPIC-<SLUG>
  "title": "Authentication",  // required
  "fr": "FR-1",               // optional — "FR-1", "FR-3/4", "Phase 0", etc.
  "phase": 0,                 // optional int — release phase (drives phase:N label)
  "size": "L",                // XS|S|M|L|XL — T-shirt for the epic
  "sprint": 2,                // int — sprint/iteration number (1..N)
  "summary": "One-line epic description.",
  "stories": [ /* see below */ ]
}
```

## Story

```jsonc
{
  "id": "BE-AUTH-1",          // required, unique. Convention: <AREA>-<EPIC>-<n>
  "area": "backend",          // backend|frontend|design|qa|security|devops|data|mobile
  "estimate": "M",            // XS|S|M|L|XL (mapped to points S=2,M=3,L=5,XS=1,XL=8)
  "title": "As a user, I want ... so that ...",   // user-story sentence
  "acceptance_criteria": ["Given ..., When ..., Then ..."],
  "screens": ["ON-3", "ON-4"],   // optional — UX screen IDs this delivers
  "depends_on": ["BE-FOUND-2"],  // optional — story ids
  "tasks": ["Configure provider", "handle_new_user trigger"]  // list[str]
}
```

Tasks are plain strings; `create_issues.py`/`render_docs.py` auto-assign task
ids `<story-id>-T<k>` and inherit the story's area + the epic's sprint.

## Conventions that make a good backlog

- **Epics by feature / FR**, each tagged with its phase.
- Every feature epic carries **backend + frontend** stories; add **design (UX/UI),
  QA, and security** where there's real work, and **devops** on the foundation +
  launch epics.
- Acceptance criteria use **Given / When / Then**.
- Sizes/points are relative; sprints follow phase + dependency order.
- If you have a UX screen inventory, set top-level `screens` so coverage is
  enforced: every screen must appear in at least one `design` story's `screens`.
