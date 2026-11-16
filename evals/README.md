# Evals

Each scenario is a change to the demo API in `demo/notes-api`. Most of them have
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

## Run one

```
evals/run.sh <scenario> <skill> [model]
evals/run.sh weak-test can-it-fail haiku
```

The runner copies the demo API to a temporary repo, applies the change on a
branch, installs the skills, and starts an unattended agent session that loads
no user settings. The agent never sees `expected.md`. The report is written to
`evals/results/`. Read it next to `expected.md`.

The grading is by reading. A scenario is short, and a wrong pass is easy to see.
