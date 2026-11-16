# Evals

Each scenario is a change to the demo API in `evals/demo/notes-api`. Most of them have
one planted defect. A skill passes a scenario when its report matches
`expected.md`: it finds the defect, or it says it could not check.

The scenarios test the main claim of flow: no pass without proof. So the
correct answer is often not `passed`.

| Scenario | Planted defect | Skills to run |
|---|---|---|
| `archive-cross-user` | Any user can archive another user's note. Unit tests are green. | `prove-it`, `review` |
| `archive-clean` | None. Control: a correct change must come out clean. | `prove-it`, `review`, `can-it-fail` |
| `weak-test` | One of three new tests cannot fail. | `can-it-fail` |
| `blocked-login` | Login needs a service that is not available. | `prove-it` |

## Chains

A chain is a conversation with more than one user message. It can test a gate:
the first message must end at a stop, and the second gives the approval.

| Chain | Checks |
|---|---|
| `flow-archive` | `flow` stops at the plan gate with no code changed, then builds, proves, and reports |
| `onboard` | `onboard` shows its files and questions first, and writes only after a yes |

```
evals/run-chain.sh flow-archive sonnet
```

## Results

`results/round-1` is the first run. It exposed three gaps in the skills and one
mistake in a scenario. `results/round-2` is the run after the fixes.

## Before you run

- [Bun](https://bun.sh), for the demo API.
- The Claude Code CLI, logged in. Each run is a paid agent session: a few cents
  for one skill, more for a chain.
- The agent runs unattended with shell access, inside a temporary copy of the
  demo API. It does not touch this repo, except to write its report to
  `evals/results/`.

## Run one

```
evals/run.sh <scenario> <skill> [model]
evals/run.sh weak-test can-it-fail haiku
```

What the runner does:

1. Copies `evals/demo/notes-api` to a temporary folder and makes it a git repo.
2. Applies the scenario's `change.patch` on a branch and commits it.
3. Copies `skills/` into that repo, so the run tests the skills as they are now.
4. Starts one agent session with the scenario's `task.md` and the name of the
   skill. The session loads no user settings, and it never sees `expected.md`.
5. Writes the agent's final report to `evals/results/latest/`, and prints any
   file the agent left changed.

Then read the report next to the scenario's `expected.md`. Set `EVAL_ROUND=name`
to write to another results folder.

The grading is by reading. A scenario is short, and a wrong pass is easy to see.
