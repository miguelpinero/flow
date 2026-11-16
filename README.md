# Flow

A small set of agent skills for shipping a change with proof.

Most agent workflows help you plan and build. Flow adds the step that is usually
missing: before the agent says "done", it has to show what it ran and what it
saw. If it could not check something, it says so.

The skills are plain markdown. Each one works alone, and `flow` runs them as a
chain.

## Skills

| Skill | What it does | Tested |
|---|---|---|
| `flow` | Runs the chain, with two human gates | one chain run |
| `onboard` | Learns a repo on the first run and writes `.flow/` | one chain run |
| `explore` | Reads the ticket and the code before any plan | inside `flow` only |
| `can-it-fail` | Shows that a new test can fail | yes |
| `prove-it` | Sends real requests to what the diff reaches | yes |
| `review` | Read-only review of the branch diff | yes |
| `evidence` | The shared rules for reporting a result | through the others |
| `describe-pr` | Pull request text from the real diff | inside `flow` only |
| `manual-test` | Prepares a hands-on test, or drives the browser | not yet |
| `design-check` | Measures a page against its design | not yet |
| `house-rules` | Builds review rules from merged pull requests | not yet |
| `parallel` | Runs several tasks at the same time | not yet |

"Tested" means the skill ran on the scenarios in [`evals/`](evals/README.md),
in a clean session, and its report matched the expected result. The scenarios
are small and each ran once or twice. Treat the skills as early.

## Install

Copy a skill folder from `skills/` into your agent's skills directory. For
Claude Code that is `.claude/skills/` in a repo, or `~/.claude/skills/` for all
repos.
