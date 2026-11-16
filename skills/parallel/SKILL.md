---
name: parallel
description: Run several flow tasks at the same time, each in its own worktree and branch, and bring back one combined status. Use when the user gives two or more tickets or tasks and asks to run them in parallel or at the same time. Needs the flow skill and a tool that can run sessions or agents in parallel.
argument-hint: "TICKET-1 TICKET-2 TICKET-3 [autopilot]"
---

# Parallel

Run one `flow` for each task, at the same time, without letting them touch each
other.

You are a coordinator. You do not explore, plan, build, or review. You set up
the lanes, start the runs, and report where each one stands.

## Before you start

Check each of these. If one fails, say so and stop. Do not fall back to running
the tasks in one working tree.

- The tool can run sessions or agents in parallel, each with its own working
  directory.
- `git worktree` is available and the main tree is clean.
- The tasks are independent. If two tasks change the same files, tell the user
  and offer to run those two in sequence.
- Each run can have its own ports, database, and other local resources. Read
  `.flow/proof.md` for how. If the runs must share one server or one database,
  the proof steps cannot run in parallel: say so before you start.

Three tasks at a time is the default limit. More than that is hard for one
person to review.

## Steps

1. **Make the lanes.** For each task: one branch from the base branch, one
   worktree in a sibling folder, one set of ports. Print the table:
   `task | branch | folder | ports`.

2. **Explore and plan every task first.** Start `flow` in each lane and let it
   stop at Gate A.

3. **One gate round.** Show all the plans together, each in full. The user
   approves, changes, or drops each one. A plan that is not approved does not
   build. Approval of one plan is not approval of another.

4. **Build and prove.** Continue each approved run. With `autopilot`, each run
   goes to its report without questions.

5. **Report.** One table for all tasks, then a link to each run's report.

## Rules

- Every rule of `flow` applies in every lane, including the commit preference.
- Never merge one lane into another. Never rebase or push a lane. The user
  decides the order in which the work lands.
- Never share a run folder. Each lane has its own `.flow/runs/<id>/`.
- A lane that fails does not stop the others. Report it as it is.
- Do not remove a worktree that has uncommitted work. List it and let the user
  decide.
- Use the four result words from the `evidence` skill. The status of a lane is
  the status its own report gives. Do not summarize three reports as "all
  good" unless every row in every report is `passed`.

## Report

```
## Parallel: <n> tasks

| Task | Branch | Stage | passed | failed | not-run | could-not-run | Report |

### Needs you
- <task>: <the decision or the failure>

### Lanes left in place
- <folder>: <why it was not removed>
```
