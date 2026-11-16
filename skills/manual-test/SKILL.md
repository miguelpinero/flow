---
name: manual-test
description: Prepare a change so a person can try it by hand, or drive the browser yourself and report what you saw. Sets up the data, the logins, and the open page, then gives a short script of what to try. Use when the user says "let me test it", "set up a manual test", "I want to try it", or when a flow plan calls for a hands-on check.
---

# Manual test

Some things need a person's eyes. Your job is to remove everything between the
person and the first click: the data, the login, the right page.

The person should only test. They should not set up.

## Two modes

| Mode | Who acts | Result you may report |
|---|---|---|
| `hands` (default) | The user clicks. You prepare and take notes. | Only what the user tells you. |
| `drive` | You act through a browser tool. | Only what you saw in the browser. |

Use `drive` only when the user asks for it and a browser tool is available. If
no tool is available, say so. Do not install one.

## What you need

| Input | Use |
|---|---|
| Something to test | `.flow/runs/<id>/plan.md` acceptance points. Else the diff shows which screens and endpoints changed. Else ask one question: "What do you want to test?" |
| How to start the app and log in | `.flow/proof.md`. Else ask, or suggest `onboard`. |

## Steps

1. **Write the script.** A short numbered list. Each step is one action and
   what the user should see. Cover each acceptance point, plus the one case
   most likely to break.

2. **Prepare the state.** Seed exactly the data the script needs, from a clean
   state. No filler records. Write down each record you create.

3. **Check the servers.** Do not start or stop a server unless the user or
   `.flow/proof.md` allows it. If a server must restart to load the change, ask.

4. **Open the door.** Give the address, the test user to log in as, and the
   first screen. In `drive` mode, log in and open it yourself.

5. **Run.** In `hands` mode, wait. Ask the user for the result of each step
   and write down their words. In `drive` mode, do each step and record what
   the page showed.

6. **Clean up.** Remove what you seeded, or tell the user how.

## Rules

- Load the `evidence` skill and use its four result words.
- In `hands` mode, a step is `passed` only when the user says it passed. A step
  the user did not try is `not-run`. Your setup working is not a result.
- In `drive` mode, a step is `passed` only when you saw the expected state on
  the page. A click with no error is not enough.
- Never print a password or a token. Say which test user to use, and where its
  password is kept.
- Local or development targets only.

## Output

Write `.flow/runs/<id>/checks/manual-test.md` if a run folder exists, and print
it.

```
## Manual test: <change>
Mode: hands | drive
<n> passed, <n> failed, <n> not-run, <n> could-not-run

### Ready state
- Address: <address>
- Log in as: <test user>
- Data seeded: <records>

### Script and results
| # | Do this | You should see | Result | Note |

### Cleanup
- <what was removed, or how to remove it>
```
