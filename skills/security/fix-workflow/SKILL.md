---
name: fix-workflow
description: Security fix workflow for axiriam-shop — runs vibe-security audit, triages findings by severity, fixes issues one by one, then verifies with lint + type-check + tests. Use when the user wants to fix security issues, run a security audit and patch everything found, or says "fix security", "run security audit and fix", or "fix the audit findings".
---

# Security Fix Workflow — axiriam-shop

Full security fix cycle: audit → triage → fix → verify → test.

## Step 1 — Audit

Check memory first: `mem_search "security audit"`. If a recent result exists, ask:
> "There's an audit from [date] with [N] open issues — use that or re-run vibe-security?"

If re-running (or no prior audit): invoke `/vibe-security` and collect the full findings.

## Step 2 — Triage

Group findings: **Critical → High → Medium → Low**.

For each issue state: file + line, vulnerability name, concrete attacker impact, fix complexity (trivial / moderate / involved).

Ask the user: "Fix all of them, or start with a specific severity?"

## Step 3 — Fix

Fix one issue at a time, severity order. For each:

1. Explain the root cause — not just the patch
2. Show before/after code
3. Apply the change
4. Name which vibe-security reference covers it

**Fix guidance by category:**

- **Headers (HSTS, CSP)** → add to `next.config.js` `headers()` config
- **Rate limiting** → use `infrastructure/redis.ts` + Upstash `Ratelimit`; NEVER in-memory Maps (violates project rule — see CONTEXT.md §4)
- **Env var guards** → add explicit `if (!process.env.X) throw` at the module level; never silent fallbacks
- **Auth gaps** → check `infrastructure/auth/` callbacks + `app/api/` route-level session guards

Confirm with user before moving to the next issue.

## Step 4 — Verify

After each severity group (or all fixes):

```bash
npm run lint        # must pass with zero warnings
npx tsc --noEmit    # must pass with zero errors
```

Fix any failures before continuing. Do not skip.

## Step 5 — Test

```bash
npm run test
```

Report pass/fail. If tests break, investigate and fix — do NOT proceed with broken tests.

## Step 6 — Summary

Report:
- Issues fixed (file, vulnerability, severity)
- Issues remaining (if partial run)
- Anything discovered during fixes that warrants a follow-up audit

---

## Last Known Findings (Audit: 2026-05-27, branch: feature/orlandocastaneda/sc-119)

7 issues, 0 critical — re-run audit if on a new branch or significant code has changed.

| # | File | Issue | Severity |
|---|------|-------|----------|
| 1 | `next.config.js` | Missing HSTS + CSP headers | HIGH |
| 2 | `app/api/user/password/route.ts` | No rate limiting on password change | MEDIUM |
| 3 | `app/api/shipping/rates/route.ts` | No rate limiting on Envia proxy | MEDIUM |
| 4 | `infrastructure/utils/shipping-token.ts:3` | SHIPPING_RATE_SECRET silently falls back to NEXTAUTH_SECRET | MEDIUM |
| 5 | `app/api/reviews/route.ts` | No rate limiting on review creation | LOW |
| 6 | Cloudinary dashboard | Unsigned upload preset publicly exposed | LOW |
| 7 | `middleware.ts:45-47` | Redis blacklist check fails open on Redis outage | LOW |
