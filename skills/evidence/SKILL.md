---
name: evidence
description: The shared rules for reporting a result. Four result words, what does not count as a pass, and the proof table. Load this before you write any test result, check result, final report, or "done" claim. The other flow skills load it; you can also load it alone to make any report honest.
---

# Evidence

A result is a claim. This page says what you must show before you make one.

The goal is simple: a person who reads your report can trust each line without
running anything again. If a line says `passed`, the proof is next to it. If
you did not check something, the report says so.

## The four result words

Use one of these four words for every result. Do not use any other word, and do
not soften one ("mostly passed", "passed with notes").

| Word | Meaning | You must show |
|---|---|---|
| `passed` | You ran the check after the last change and saw the expected result. | What you ran, and the output that proves it. |
| `failed` | You ran the check and the result was wrong. | What you ran, what you expected, what you got. |
| `not-run` | You decided not to run the check. | The reason. |
| `could-not-run` | You tried to run the check and something stopped you. | What stopped you, and what would unblock it. |

The difference between the last two: `not-run` is your own choice. When the
user's rules or the environment do not permit a check, the result is
`could-not-run`, even if you never tried it. Say who or what ruled it out.

`not-run` and `could-not-run` are honest results. They are not failures to hide.
A report with three `passed` and one `could-not-run` is a good report. A report
with four `passed` where one was never run is a false report.

## What does not count as a pass

None of these is proof that the behavior works:

- The code compiles, type-checks, or passes lint. These are their own checks.
  Report them under their own name, not as proof of behavior.
- A test where the changed code is mocked or stubbed.
- A new test that nobody saw fail. A test that cannot fail proves nothing.
- You read the code and it looks correct.
- A check that ran before the last change. Run it again or mark it `not-run`.
- A success status with no look at the response body or the saved state.
- A check that covered part of the change, reported as if it covered all of it.
- A check against a stand-in that you built because the real thing was not
  available: a fake login service, a stub of another system. That is a mock.
  Report what it showed under its own name, and mark the real check
  `could-not-run`.
- A result you got after you changed the code you were asked to check. If you
  were asked to check a change and you fixed it first, the result for the
  change is still `failed`.
- "It should work."

When you are not sure a check counts, it does not count. Say what you ran and
let the reader decide.

## Failures that were there before

A check that already failed before the change is still `failed`. Do not hide it
and do not round it up. Report it in its own group, "failed before the change",
with the run from before the change as proof. Without a run from before the
change, you cannot claim that the failure is old.

## The proof table

A final report maps each acceptance point to its proof. One row for each point.
If the task has no written acceptance points, write them first in plain words
and mark them as yours, so the reader knows they did not come from the task.

| Acceptance point | Proof | Result |
|---|---|---|
| A user can archive a note | `POST /notes/7/archive` returned 204. `GET /notes` then omitted note 7. | `passed` |
| Another user cannot archive it | The same request as a second user returned 403. Note 7 was still in the owner's list. | `passed` |
| The archive button matches the design | No design file was available. Needs the design link. | `could-not-run` |

Rules for the table:

- A point with no row is a gap. Add the row and mark it `not-run`.
- The proof names the real thing that ran: the command, the request, the test
  name. A reader must be able to run it again.
- Keep proof short. Quote the one line of output that matters, not the full log.
- Never put a secret in proof. No tokens, passwords, connection strings, or
  personal data. Replace them with `<redacted>`.

## Before you say "done"

1. Every acceptance point has a row.
2. Every `passed` has proof that ran after the last change.
3. Everything you did not check is in the report, with one of the two words.
4. The first line of the report counts the acceptance points: for example
   "3 passed, 0 failed, 0 not-run, 1 could-not-run". If the report also lists
   other checks, such as lint or a review, a second line counts those. Failures
   from before the change are in neither count.

Then report. Do not round the result up.
