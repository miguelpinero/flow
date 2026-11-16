---
name: prove-it
description: Smoke test a backend change with real HTTP requests. Reads the branch diff, finds the endpoints the change reaches, and calls them on the running local server as a real logged-in user. Use when the user says "prove it", "smoke test", "smoke test this", "test it with curl", "does the endpoint work", or before you call a backend change ready. Not a unit test and not a build check.
---

# Prove it

Answer one question with proof: does the code on this branch work when a real
client calls it?

Start from the diff, not from an endpoint. Find what changed, find what that
change can reach, and call exactly those paths over HTTP.

Load the `evidence` skill first and report with its four result words:
`passed`, `failed`, `not-run`, `could-not-run`.

## The one rule

**A pass means a real request ran the real changed code as a real user, and you
checked the real response. Nothing else is a pass.**

These are not a pass:

- The server boots, or the route list shows the endpoint.
- A `401` or `403` that stopped the request before it reached the changed code.
- A unit test, or any test with the changed code mocked.
- A `200` where you did not look at the body or the saved state.
- One request. One request proves one case, not the change.
- A request that passed against a stand-in you built for something you could
  not reach, such as a fake login service. That is a mock. List what it showed
  under "Also seen", and mark the case `could-not-run`.

If you cannot log in, or the server is not reachable, the result is
`could-not-run`. Say what blocked you and stop. Do not build a green report from
smaller signals. A false pass is worse than no result, because it ships a bug
with an approval on it.

## You do not change the code

You test the branch as it is. You do not edit a source file or a test.

When a case fails, the result is `failed`. Do not fix the code and run again.
The first line of your report counts the results for the branch as you found
it. A fix belongs to a separate step: inside `flow` it goes back to build, and
alone you describe the fix and stop. A report that says "all passed, after I
fixed it" hides the one thing the reader needed to know.

## What you need

| Input | Where it comes from |
|---|---|
| The diff | `git diff <base>...HEAD`, plus uncommitted changes. Always available. |
| How to reach the server and log in | `.flow/proof.md` if it exists. Else find it in the repo: config, scripts, README, existing tests. |
| What the change is for | `.flow/runs/<id>/plan.md` or the user. Optional. |

Without a stated purpose, prove that the changed paths have no errors, and say
that you did not check the purpose.

## Steps

1. **Map the impact.** For each changed file, find the endpoints that reach it.
   A changed service: find its callers. A changed schema or model: every
   endpoint that reads or writes it. Write a short map:
   `changed file -> endpoint -> what can break`. List only what the diff reaches.

2. **Check the server.** Find the address. Check that it answers. Check that it
   runs the code of this branch: a server that started before the change tests
   old code. See "The server" below.

3. **Log in as a real user.** Use the recipe in `.flow/proof.md`, or the login
   path that the repo's own tests use. If the endpoints are scoped to a user,
   get a second user too.

4. **Write the cases.** One table: case, request, expected. Cover what applies:
   - **The change itself.** The cases that exist only because of this diff.
     Never drop these.
   - **Happy path** with real data. Seed the data if it is missing.
   - **Validation.** Missing field, wrong type, empty value.
   - **Access.** No login. A second user on a resource they do not own.
   - **Edges** that the code suggests: empty list, missing optional field,
     unknown id.

   If you run inside `flow`, or the user said to continue without stops, go to
   step 5. Otherwise show the table once and wait for a yes.

5. **Run them.** Send each request. Check the status, the body, and the saved
   state when the request writes something. Record the real values.

6. **Report.** Use the format below.

## Rules that keep the result true

- **Check a negative only after a success.** "The response has no `password`
  field" is also true for an error body. Assert it only on a 2xx.
- **A 2xx from a producer does not prove the consumer ran.** For a queue or a
  background job, check the effect.
- **Never skip a case because data is missing.** Seed the data. Mark a case
  `could-not-run` only when you cannot create what it needs.
- **When every writing case returns 500**, rule out these in order before you
  call it a bug: a migration that is not applied, a stale server, a missing
  environment value.

## The server

- Do not stop or restart a server that you did not start. Ask the user.
- If no server runs, ask the user to start it. If the user or `.flow/proof.md`
  says you may start it, start it on a free port and stop it when you finish.
- Local and development targets only. Never a shared or production environment,
  unless the user names it and confirms.

## Safety

- Never print a token, a password, or a connection string. Read them from the
  environment and show `<redacted>`.
- Write down each row you seed, and remove it at the end or tell the user how.
- Put scripts in a temporary directory, never in the repo.

## Report

```
## Prove it: <branch or change>
<n> passed, <n> failed, <n> not-run, <n> could-not-run

### Impact
- <changed file> -> <VERB /path> -> <what can break>

### Results
| # | Case | Request | Expected | Actual | Result |

### Failures
- <case>: expected <x>, got <y>. Likely cause: <cause>. Next step: <step>.

### Purpose
<met / not met / not checked, and why>

### Also seen (not counted)
<boot, lint, or other signals, kept apart from the results>
```

If the tool has subagents, do the reading and the requests there and keep only
the tables in the main thread. If it does not, do the work in the main thread
and keep the output short.
