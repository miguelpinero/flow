---
name: flow
description: Take a ticket, story, bug, or small task from the request to a proven change, with two human gates. Runs explore, plan, build, prove, and report in order, and never reports success without proof. Use when the user invokes flow with a ticket id or a task description, or asks to take a task end to end.
argument-hint: "TICKET-123 | short description [autopilot]"
---

# Flow

You are the conductor. You start each stage, check what it produced, stop at
the gates, and talk to the user. Each stage does its own work and writes one
file. The next stage reads that file.

```
explore -> plan -> GATE A -> build -> prove -> report -> GATE B
                   you approve                          you commit
```

Copy this list into your first reply and keep it current:

```
- [ ] 0 workspace checked
- [ ] 1 explore   -> brief.md
- [ ] 2 plan      -> plan.md
- [ ] GATE A: plan approved by the user
- [ ] 3 build     -> the diff
- [ ] 4 prove     -> checks/*.md
- [ ] 5 report    -> report.md
- [ ] GATE B: the user reviews and commits
```

## Rules for you and for every agent you start

Give these rules, word for word, to each agent you start.

1. **No change before Gate A.** No code, test, or config edit until the user
   approves the plan.
2. **Stay on the task branch.** Never work on the base branch. Never switch,
   create, or delete a branch unless the user tells you to.
3. **Follow the commit preference** in `.flow/profile.md`. With no profile, the
   rule is: never commit and never push. The diff stays for the user.
4. **Report what ran.** Load the `evidence` skill. Use only `passed`, `failed`,
   `not-run`, `could-not-run`. Never call a check passed unless you ran it
   after the last change.
5. **Only the user waives a finding.**
6. **No secrets in any file or message.**

## Stop if you think one of these

- "The plan is obvious, I can start now." Gate A exists for this moment.
- "The proof mostly passed." A partial pass is not a pass.
- "It is easier to waive this finding." The user decides that.
- "This other problem is small, I will fix it too." It goes in the plan as a
  separate item, never silently into the change.

## Stage 0: workspace

Check the branch, check that the tree is clean, and check how far the branch is
from the base. If anything is off, stop and ask. If the repo has no `.flow/`
folder, offer to run `onboard` first. You can continue without it, but each
stage then has to find its own facts.

Create the run folder `.flow/runs/<id>/`. If Git does not ignore `.flow/runs/`,
add it to `.git/info/exclude`. That file is local, so no tracked file changes
and the run files do not show up in the user's diff. Use the ticket id, or a short slug of
the task. If the folder exists with valid files, resume after the last finished
stage. Do not repeat a finished stage.

## Stage 1: explore

Run the `explore` skill in a fresh agent. Output: `brief.md`.

## Stage 2: plan

Write `plan.md` yourself from the brief:

- **Slices.** Small steps that each leave the code working. If the change is
  too large to review in one sitting, split it and say so.
- **Per slice:** the files to change, the tests to write first, and the check
  that proves it.
- **Acceptance points** from the brief, each with the proof you will collect.
- **Options** when a real choice exists, with your recommendation.
- **Other problems found**, each marked: required, optional, or separate task.
- **Open decisions** for the user, each with your recommended answer. Then a
  plain "approved" covers every decision. A decision with no recommendation
  is not covered by it: ask again, or mark what depends on it `could-not-run`.

Then start one fresh agent as a challenger. It reads the brief and the plan and
looks for what is missing, what is too large, and what the plan assumes without
proof. Fix the plan or add the objection to the open decisions.

## Gate A

Print the full plan in the conversation. A file path is not enough. Stop.
Continue only on a clear yes.

## Stage 3: build

Before the first edit, run the checks you will use later (tests, lint, type
check) one time and save the result in `baseline.md`. A failure that is already
in the baseline did not come from this change, and the report keeps it apart.

Start a fresh agent with the brief and the plan. For a behavior change it
writes the test first. It runs lint and type check on what it touched. If new
evidence makes the plan wrong, it returns `BLOCKED: <reason>` and you take that
to the user.

## Stage 4: prove

Run the proof ladder from `.flow/proof.md`. With no ladder, use this one, and
skip a step only when it does not apply:

| Step | Skill | When |
|---|---|---|
| The new tests can fail | `can-it-fail` | The diff has new or changed tests |
| Real requests | `prove-it` | The diff reaches an endpoint |
| The page matches the design | `design-check` | The task has a design |
| Review | `review` | Always |
| A person tries it | `manual-test` | The user asks, or the plan says so |

Each skill writes its result to `checks/<skill>.md`. This also applies when you
run a check yourself in the main thread: write its file before you go on. Do
not start the report while a check that ran has no file. The report is only as
good as the files a reader can open.

**Fix loop.** A `failed` check or a `blocker` or `high` finding goes back to a
build agent with the result file. Then run the failed checks again. Three build
attempts at most, and the first build counts as one. After the third, stop and
give the open items to the user.

## Stage 5: report

Write `report.md`, titled "Evidence report", with the proof table from the
`evidence` skill: each
acceptance point, its proof, its result. First line: the count of each result
word for the acceptance points. Second line: the same count for the other
checks. Failures that are in `baseline.md` go in their own group, in neither
count. Then: what changed, what is still open, and what the user should look at
first.

Then follow the pull request preference. With `ask`, or with no profile, ask:
"Do you want a pull request description?" On yes, run `describe-pr`.

## Gate B

The user reviews the diff and the report. With the commit preference `never`,
you are done: the commit is theirs.

## Modes and sizes

- **`autopilot`.** After Gate A, run to the report without questions. Gate A
  still applies. Anything that needs the user becomes `could-not-run` in the
  report, with the reason.
- **`light`.** For a change of one or two files with no contract, schema, or
  access change, where the request fully describes the fix: no fresh agents, a
  short brief and plan in the conversation, the same Gate A, the same proof
  rules. Choose `light` yourself when all of that holds, and say that you did.
  A full run starts several agents and each one loads its own context, so it
  costs many times more. If you find more than you expected, switch to
  `standard` and tell the user.
- **`standard`** is the default for everything else. **`full`** runs every review lens and every
  proof step.

## Agents

Start each stage in a fresh agent when the tool has them. Give it: the rules
above, a short summary of the task, the files to read, the file to write, and
the instruction to return ten lines at most. If the tool has no agents, do the
stage in the main thread and keep the output short.

After each stage, read its file. If the file is missing or does not follow the
format, run the stage one more time with the gap named. If it fails again, stop
and tell the user.
