---
name: explore
description: Scope a ticket, story, or bug before any plan or code. Reads the request and the code it touches, maps what the change will affect, names the one risky assumption, and tests that assumption on the real system. Read-only on the repo. Use when the user hands you a ticket or a task description to scope, or as the first stage of flow. Not for a general "look around the code" request.
---

# Explore

Turn a raw request into a brief that a plan can stand on.

Most tasks depend on one assumption. Which id does the API use? Does the delete
cascade? What does the other service return? If that assumption is wrong, the
whole plan aims at the wrong target. Find it and settle it before anyone writes
code.

You do not change the repo. You do not write a plan. You stop at the brief.

## What you need

- A ticket, a story, or one sentence from the user.
- `.flow/profile.md` if it exists. Without it, read more of the repo first.

## Steps

1. **Normalize the request.** Write the problem, the expected behavior, and the
   acceptance points. Mark each point `given` if it is in the request, or
   `inferred` if you added it. List what is unknown and what is out of scope.
   Ask the user only when a gap changes the contract, the data, the access
   rules, or the scope.

2. **Trace the path.** Find where the behavior starts: the endpoint, the event,
   the job, the screen. Follow it to its last effect. Cite `file:line`.
   Existing code shows what happens now. It does not prove that it is correct.

3. **Map the impact.** List what the change touches, by level:
   `direct` (must change), `indirect` (calls or is called by what changes),
   `possible` (may break, needs a check).

4. **Name the risky assumption.** State the one assumption that breaks the
   work if it is false, and what would go wrong. If the task is internal logic
   with nothing to test from outside, say so and skip step 5.

5. **Probe it.** Design the smallest test on the real system that settles the
   assumption, with real status codes and real output.
   - Anything that writes is a stop: starting a service, seeding data, creating
     a record, calling a third party. Show the user what the probe starts, what
     it writes, and what it leaves behind. Wait for a yes.
   - Use a local or sandbox target. Do not guess which one is safe. Ask.
   - Use throwaway data with a unique name. Remove what you create.
   - Read secrets from the environment. Never print them.
   - Put scripts in a temporary directory, never in the repo.

6. **Write the brief.**

## Rules

- Read-only on the repo. No edit, no migration, no commit.
- Report what you ran, not what you expect. An assumption is `proven`,
  `refuted`, `not-probed`, or `could-not-probe`, with the reason.
- Split what you found from what you think: evidence, reading of it, proposal.

## Output

Write `.flow/runs/<id>/brief.md` if a run folder exists. Else print it.

```
# Brief: <id or short name>

## Request
<problem and expected behavior, 3 to 5 lines>

## Acceptance points
1. <point> (given | inferred)

## How it works today
- <step> (file:line)

## Impact
- direct: <file or module>: <why>
- indirect: ...
- possible: ...

## Risky assumption
<the assumption>. If false: <what breaks>.
Status: proven | refuted | not-probed | could-not-probe
Proof: <what ran and what came back>

## Open questions for the user
- <only what the user must decide>

## Out of scope
- <item>
```
