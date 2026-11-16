---
name: onboard
description: Set up flow in a repo for the first time. Reads the repo, records the facts the other flow skills need (base branch, commands, how to run and log in), asks the team's preferences one time, and writes them to a .flow folder. Use when the user says "onboard this repo", "set up flow here", or when flow runs in a repo that has no .flow folder.
---

# Onboard

Learn this repo one time, so the other skills do not have to learn it again on
every run.

You write a small folder of plain markdown. A person can read it and correct
it. That folder is the difference between a generic agent and one that knows
how this team works.

## What you write

```
.flow/
  profile.md     facts and preferences        commit this
  proof.md       how to prove a change here   commit this
  local/         personal settings            do not commit
  runs/          one folder for each task     do not commit
```

Add `.flow/local/` and `.flow/runs/` to `.gitignore`.

## Steps

1. **Read the repo.** Look at the manifest and lock files, the scripts, the CI
   config, the README, the contributor guide, any agent instruction file, and
   two or three existing tests. Do not read the whole tree.

2. **Record facts.** A fact is something the repo shows. Write each one with
   its source, so a reader can check it.

3. **Ask preferences.** A preference is something the repo cannot show. Ask
   all of them in one message, with your recommended answer first. Ask one
   time. Do not ask again on later runs.

4. **Show before you write.** Print both files in the conversation. Write them
   after the user says yes.

## Facts to find

| Fact | Where to look |
|---|---|
| Base branch | The default branch of the remote, the CI triggers |
| Package manager and runtime | Lock file, manifest |
| Commands: install, lint, type check, test, one test, build, run | Manifest scripts, CI config, Makefile |
| Layout: apps, packages, where tests live | The tree, the workspace config |
| How the server starts and on which address | Run script, config files |
| How a test user logs in | Existing tests, seed scripts, README |
| Glossary or domain document | Docs folder, root files |
| Rules the team wrote for agents or contributors | Agent instruction files, contributor guide |

If you cannot find a fact, write `unknown` and ask. Do not guess a command.

## Preferences to ask

| Preference | Options | Default |
|---|---|---|
| Commits | `never` (the user commits) / `ask` (commit after a yes) / `auto` | `never` |
| Pull request text | `ask` / `always` / `never` | `ask` |
| May flow start and stop the dev server? | `no` / `yes, on a free port` | `no` |
| Guidance level | `short` (contracts only) / `full` (step-by-step guides) | `short` |
| Run size | `light` / `standard` / `full` | `standard` |

## What must never go in these files

- A secret: no token, password, key, or connection string. Write where the
  value lives ("the `API_TOKEN` variable in your local env file"), not the
  value. Do not open or copy an env file.
- A person's name, handle, or email.
- Customer data or real records.

Personal settings, such as your writing voice or a private login recipe, go in
`.flow/local/`, which is not committed.

## Output format

`profile.md`:

```
# Profile

## Facts
- Base branch: main (source: remote default branch)
- Runtime: Bun 1.x (source: bun.lock)
- Test: `bun test` (source: package.json scripts)
- One test: `bun test <file> -t "<name>"` (source: package.json, checked)
- Lint: `bun run lint` (source: package.json scripts)

## Preferences
- Commits: never
- Pull request text: ask
- Start the dev server: no
- Guidance: short
- Run size: standard
```

`proof.md`:

```
# Proof

## Ladder
The checks that prove a change here, cheapest first:
1. Type check and lint: `<command>`
2. Unit tests for the touched area: `<command>`
3. Real requests to the running server (prove-it)

## Server
- Start: `<command>` (source: ...)
- Address: `<address>`
- Is it this branch's code? <how to tell>

## Login
- <the steps a test uses to get a session, without any secret value>
```

## Later runs

Run `onboard` again when the repo changes its tools. Update the facts, show the
change as a diff, and keep the preferences as they are.
