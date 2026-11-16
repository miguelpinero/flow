---
name: review
description: Review the diff of the current branch before it ships. Several read-only reviewers look at the change at the same time, each with one focus, and every finding is checked against the source before it is reported. Use when the user asks to review a branch, a diff, or a change before a push or a pull request. Not for general questions about code, and not for reviewing a design.
---

# Review

Find the problems in this change that would hurt after it ships. Report each
one with the place, the effect, and a fix.

You do not edit anything. A reviewer that fixes what it finds hides the finding.

Load the `evidence` skill first and report with its four result words.

## What you need

| Input | Use |
|---|---|
| The diff: `git diff <base>...HEAD` plus uncommitted changes | Always available. This is what you review. |
| `.flow/house-rules.md` | The team's own review rules. Apply them if the file exists. |
| `.flow/runs/<id>/plan.md` | What the change is for. Compare the change with it if the file exists. |

With no plan, review for defects and risk only, and write this line in the
report: "No plan found. I did not check the change against its purpose."

## Lenses

Run each lens as its own read-only pass. If the tool has subagents, run them in
parallel, one lens each. Pick lenses by what the diff touches.

| Lens | Run it when | It asks |
|---|---|---|
| Correctness | Always | Does the code do what it claims? Wrong condition, missing case, wrong order, unhandled error. |
| Access and data | The diff touches a route, a query, a permission, or user data | Can a user reach or change what is not theirs? Is input checked on the server? Does a secret or personal data leak into a response or a log? |
| Tests | The diff changes behavior | Is the new behavior tested? Would the test fail if the behavior broke? |
| Fit | Always | Does the change follow `.flow/house-rules.md` and the patterns of the files around it? Does it contain changes that do not belong to it? |
| Purpose | A plan exists | Does the change do what the plan says, and nothing more? |

## How to check a finding

Do not report a suspicion. Read the code around it first.

- **Read the callee.** Before you call a guard missing, or call one wrong, read
  the function it protects. The callee may already handle the case.
- **Check the claim in the source.** Do not trust a comment, a ticket, or a
  name. Read the code, the schema, the history.
- **Follow the consumers.** A changed type or response also changes its
  callers, its tests, its fixtures, and its generated clients.
- **Think about the deploy.** What happens between the code deploy and the data
  migration?
- **Question code for impossible cases.** A check for a case that cannot happen
  misleads the next reader.

A finding you could not confirm goes in its own list, marked as not confirmed.

## Findings

Each finding has all of these:

- **Severity.** `blocker`: wrong result, data loss, or an access hole.
  `high`: a real defect on a likely path. `medium`: a defect on an unlikely
  path, or a missing test. `low`: style, naming, small cleanup.
- **Place.** `file:line`.
- **What happens.** A concrete case: this input or state leads to this wrong
  result. Not "this could be a problem".
- **Fix.** The smallest change that solves it.

## Result

| Result | Meaning |
|---|---|
| `passed` | Every selected lens ran and found no `blocker` or `high`. |
| `failed` | At least one `blocker` or `high` is open. |
| `could-not-run` | A lens could not run. Say which one and why. |
| `not-run` | You left a lens out. Say which one and why. |

Only the user can waive a finding.

Do not write a proof table of acceptance points here. A review reads code. It
does not prove behavior. If you ran something to confirm a finding, say what
you ran next to that finding.

## Report

```
## Review: <branch or change>
<result>. <n> blocker, <n> high, <n> medium, <n> low.
Lenses run: <list>. Lenses not run: <list and reason>.

### Findings
1. [blocker] src/notes.ts:42. Any logged-in user can delete another user's
   note: the handler loads the note by id and never compares the owner.
   Fix: return 404 when note.ownerId is not the session user.

### Not confirmed
- <suspicion and what you could not check>

### Not checked
- <purpose, house rules, or a lens, and why>
```
