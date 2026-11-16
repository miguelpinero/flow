# Flow

A small set of agent skills for shipping a change with proof.

Most agent workflows help you plan and build. Flow adds the step that is usually
missing: before the agent says "done", it has to show what it ran and what it
saw. If it could not check something, it says so.

The skills are plain markdown. Each one works alone, and `flow` runs them as a
chain.

## Status

Work in progress. Skills land one at a time.

| Skill | What it does | Status |
|---|---|---|
| `evidence` | The shared rules for reporting a result | ready |
| `prove-it` | Sends real requests to what the diff reaches | planned |
| `can-it-fail` | Shows that a new test can fail | planned |
| `review` | Parallel read-only review with a fix loop | planned |
| `explore` | Reads the ticket and the code before any plan | planned |
| `onboard` | Learns a repo on the first run | planned |
| `flow` | Runs the chain, with two human gates | planned |

## Install

Copy a skill folder from `skills/` into your agent's skills directory. For
Claude Code that is `.claude/skills/` in a repo, or `~/.claude/skills/` for all
repos.
