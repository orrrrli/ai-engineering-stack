---
name: blind-pick
stacks: [all]
description: Make the options for a hard-to-reverse decision fight before picking one. One advocate sub-agent per option argues for it and attacks the others, then three judges who do not know which option was recommended score them on a rubric that weighs fit with the whole feature and long-term cost over the smallest diff. Use when the user says "blind-pick", "make the options fight", or doubts a recommended option; or right after options were presented for a schema, API contract or architecture decision (ask first in that case). Not for decisions that are cheap to reverse.
argument-hint: "[decision or options]"
---

# blind-pick

When Claude presents options A, B and C, the recommended one often wins because it is the smallest
diff for the current ticket, not because it fits the feature. This skill makes each option argue its
case and attack the others, then lets judges who do not know which was recommended pick the winner.

You are the orchestrator. You never advocate and you never judge.

What the user typed after `/blind-pick`: `$ARGUMENTS`. If it is blank, the decision is the most
recent set of options in this conversation.

## Step 0: is it worth it

Run it only when the decision is expensive to reverse: schema, data model, API contract,
module boundaries, a dependency, auth, infrastructure. If the decision is cheap to reverse, say so in
one line and stop. In that case the simple option is the right call.

- **The user asked for blind-pick**: say "N options, N+3 sub-agent calls" and start.
- **You are proposing it yourself** after presenting options: ask once, and wait for the answer.

You need 2 to 4 options. If there is only one real option, there is nothing to pick.

## Step 1: write the brief

Sub-agents cannot see this conversation. The brief is all they know. Write it to stand on its own:

- **Decision**: the question being decided, in one or two sentences.
- **Feature**: the whole feature or product goal the decision serves, beyond the current ticket.
  Include what is planned next, if the user or the spec says so.
- **Constraints**: everything the user stated: stack, deadline, team, what must not change.
- **Codebase**: absolute repo path and the absolute paths of the files that matter.
- **Options**: each one with a short neutral name and a description of the same length and detail.

Rules for the brief:
- Remove every hint of which option was recommended: the word "recommended", ordering by
  preference, adjectives like "simple" or "clean" on one option only.
- Do not add requirements the user never gave.
- Do not write your opinion into it.

## Step 2: advocates

Launch every advocate in ONE message, one Agent call per option:
- `subagent_type`: `Plan` (it cannot use Edit or Write)
- `description`: `blind-pick advocate <option name>`
- `prompt`: the advocate template below, filled in.

Wait for all of them.

If an advocate proposes a new option D, do not add it to the run. Show it to the user at the end.

## Step 3: judges

Launch three judges in ONE message:
- `subagent_type`: `Plan`
- `description`: `blind-pick judge <1|2|3>`
- `prompt`: the judge template below, filled in.

Every judge gets the same brief and every advocate report verbatim. Only the order of the options
changes:
- judge 1 sees the order from the brief,
- judge 2 sees it reversed,
- judge 3 sees it rotated by one.

Never summarize, trim or comment on an advocate report.

## Step 4: count and report

Count the votes. The winner needs at least 2 of 3. If all three judges pick a different option,
there is no winner: report the split and let the user decide. Never break a tie yourself.

Give the user:

1. **Winner** and the vote (for example "B, 3-0" or "A, 2-1").
2. **Compared with the recommendation**: whether the winner is the option that was recommended. If
   it is not, say in one or two lines what the recommendation missed, from the judges' reasons.
3. **Why it won**: the attacks it survived, as a short list.
4. **Its weak point**: the strongest attack still standing against the winner.
5. **Scores**: one line per option with the average total.
6. **Option D**, if an advocate proposed one.

Then ask if the user wants to go with the winner. Do not start implementing it.

## Rules for the orchestrator

- You do not argue, attack or judge. You do not change the result.
- Every sub-agent gets the same brief, byte for byte. Never add a hint for one agent.
- If a sub-agent fails, run it once more. If it fails again, report it and continue with what you
  have. A missing advocate report means that option was not defended.
- Sub-agents do not modify files. If one did, tell the user.

## Advocate template

```text
You are the advocate for one option in a decision. Other advocates are defending the other options, and three judges will score all of them. You do not know who the judges are or how they will lean.

=== THE BRIEF (identical for every advocate and judge) ===
{{brief}}
=== END OF THE BRIEF ===

You defend: {{option}}

Do this:
1. Read the code the brief points to. Every claim you make must be backed by the brief or by a file and line you actually read.
2. Make the strongest honest case for {{option}}. Focus on what the judges weigh most: how well it fits the whole feature beyond the current ticket, whether it is correct, and what it costs to maintain in six months.
3. Attack every other option. Give concrete flaws only: a scenario where it breaks, a stated requirement it misses, a cost that shows up later, something that is hard to undo. Quote file:line or the brief. Label each attack FATAL, MAJOR or MINOR. At most 5 per option, strongest first.
4. Name the weakest point of {{option}} yourself, and how to handle it. The judges will find it anyway.
5. If every option, yours included, fails a stated requirement, you may propose an option D in at most five lines.

Do not modify any file. Do not run commands that write to disk.

Reply in this format and nothing else:
CASE FOR {{option}}
<at most 15 lines>

WEAKEST POINT
<at most 3 lines>

ATTACKS
<option name> | FATAL|MAJOR|MINOR | <attack, with evidence>
(one line per attack)

OPTION D
<at most 5 lines, or "none">
```

## Judge template

```text
You are one of three judges in a decision between options. Advocates argued for each option and attacked the others. Score the options, not the advocates. Persuasive writing earns nothing.

=== THE BRIEF ===
{{brief}}
=== END OF THE BRIEF ===

=== ADVOCATE REPORTS ===
{{reports, in this judge's order}}
=== END OF THE REPORTS ===

How to judge:
1. Read the brief, then every report.
2. For each attack, check the code or the brief yourself and call it STANDS or FAILS. An attack without evidence fails. A claim with no evidence earns nothing.
3. Look for flaws the advocates missed.
4. Score each option from 0 to 10 on each criterion:
   - fit (weight 30): serves the whole feature and what is planned next, not only the current ticket. 10 = no rework needed for what is planned. 4 = the next planned step forces a rewrite. 0 = it solves a different problem.
   - correctness (weight 25): works as described, no bugs or false assumptions. 10 = verified sound. 4 = a real flaw. 0 = cannot work.
   - long_term (weight 20): cost to maintain and extend in six months. 10 = nothing to pay later. 4 = known debt that will need a migration. 0 = blocks growth.
   - reversibility (weight 15): how cheap it is to back out. 10 = a small revert. 4 = a data migration or a broken contract. 0 = effectively permanent.
   - cost_now (weight 10): effort to build it today. 10 = trivial. 0 = out of proportion to the feature.
   Use the whole scale. A 7 is not a default.
5. Total = (fit*30 + correctness*25 + long_term*20 + reversibility*15 + cost_now*10) / 10.
6. An option with a verified FATAL flaw cannot beat one without. On a tie, higher fit wins.

Do not modify any file. Do not run commands that write to disk.

Reply in this format and nothing else:
SCORES
<option name> | fit <n> | correctness <n> | long_term <n> | reversibility <n> | cost_now <n> | total <n> | fatal yes|no
(one line per option)

ATTACKS
<option name> | <attack, short> | STANDS|FAILS
(one line per attack)

WINNER <option name>
REASON <one sentence: the decisive difference>
```
