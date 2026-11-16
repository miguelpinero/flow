---
name: describe-pr
description: Write a pull request title and description from the real diff and commits of the current branch. Nothing is invented, and a test result appears only if a check really ran. Use when the user asks for a PR description, PR text, a PR body, or "describe this PR". Flow runs it at the end when the team uses pull requests.
---

# Describe PR

Write the text a reviewer needs to understand this change in two minutes.

Every sentence comes from something you read: the diff, the commits, the
ticket, a result file. If you did not read it, do not write it.

## What you need

| Input | Use |
|---|---|
| `git diff <base>...HEAD` and `git log <base>..HEAD` | Always available. The only source for what changed. |
| The ticket or task | For the "why". Take the id from the branch name if there is one. |
| `.flow/runs/<id>/report.md` | The proof table. Use it if it exists. |
| A pull request template in the repo | If the repo has one, use its sections, not the ones below. |
| `.flow/local/voice.md` | How the author writes. Follow it if it exists. |

## What to write

- **Title.** Follow the repo's convention. Look at the last ten merged titles.
- **What and why.** Two to four sentences. What the change does for a user or
  a caller, and why it was needed.
- **How.** The decisions a reviewer should know: an approach you chose over
  another, a trade, a thing that looks odd and is on purpose. Not a tour of the
  files. The diff already shows the lines.
- **Proof.** What was checked and the result, with the four result words from
  the `evidence` skill.
- **Not done.** What is left out on purpose, and follow-up work.

## Rules

- **Never invent a result.** If no result file exists and you did not run a
  check yourself, write "Not verified in this description" in the proof
  section. Do not write "tested locally".
- **Never invent a reason.** If the ticket is not available, describe what
  changed and say the reason was not available.
- Short sentences. Plain words. No praise for the change.
- No secret, no personal data, no customer name.
- Print the text in the conversation. Do not open, edit, or comment on a pull
  request unless the user asks you to.

## Output

Write `.flow/runs/<id>/pr.md` if a run folder exists, and print it in a code
block so the user can copy it.

```
<title>

## What and why
...

## How
- ...

## Proof
| Check | Result |
|---|---|

## Not done
- ...
```
