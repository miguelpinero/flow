---
name: can-it-fail
description: Prove that a new or changed test can fail. Breaks the code under test in one small way, runs the test, and checks that it goes red, then restores the code exactly. Use when the user asks "can it fail", "does this test prove anything", "check the new tests", or after tests are written for a change and before you trust them.
---

# Can it fail

A test that cannot fail proves nothing. It only adds a green line to the report.

For each new or changed test, break the behavior it claims to protect and run
it. If the test stays green, the test is not doing its job.

Load the `evidence` skill first and report with its four result words.

## What you need

- The diff, with at least one new or changed test. Always available.
- The command that runs one test. Take it from `.flow/profile.md`, or find it
  in the repo.

If the diff has no new or changed test, say so and stop. That is a finding, not
a pass.

## Steps

1. **List the tests.** From the diff, list each new or changed test and the one
   behavior it claims to prove. Use the test name and its assertions, not the
   file name.

2. **Save the starting point.** Record the working tree so you can prove later
   that you restored it:
   `git diff > "$TMPDIR/can-it-fail-before.patch"` and `git status --short`.

3. **Run the test.** It must pass now. If it fails before you touch anything,
   report `failed` for that test and continue with the next one.

4. **Break the behavior.** Change the code under test, not the test. Make the
   smallest change that removes the behavior: flip the condition, return early,
   drop the line, change the value. One change at a time.

5. **Run the same test again.**
   - It fails on an assertion about that behavior: the test works.
   - It still passes: the test cannot see the behavior. Result `failed`.
   - It fails for another reason, for example a compile error: that is not
     proof. Make a different break and run it again.

6. **Restore.** Undo your change. Then compare with step 2:
   `git diff` must equal the saved patch, and `git status --short` must match.
   Do this after each test, not once at the end.

## Result for each test

| Result | Meaning |
|---|---|
| `passed` | You broke the behavior and the test went red on an assertion. |
| `failed` | You broke the behavior and the test stayed green, or the test was red before you started. |
| `could-not-run` | You could not run the test, or could not find code to break. Say why. |
| `not-run` | You left this test out. Say why. |

## What does not count

- The test passes. That is where you start, not the proof.
- The test would fail "in theory". Run it.
- A red test caused by a syntax error in your break.
- A break in the test file itself.

## Rules

- Never leave a break in the code. If the restore check does not match, stop
  and tell the user exactly which file differs.
- Do not fix a weak test here. Report it with the reason: what you broke, and
  what the test asserts instead. The fix is a separate step.
- The breaks are the only edits you make, and you undo each one. Do not fix a
  defect, add a test, or improve the code, even when you see how. Write what
  you saw under "Also seen" and leave it.
- Do not commit anything.

## Report

```
## Can it fail: <branch or change>
<n> passed, <n> failed, <n> not-run, <n> could-not-run

| Test | Claims to prove | Break | Test after the break | Result |

### Weak tests
- <test>: I <break>. The test still passed because it asserts <what>.
  It needs an assertion on <what>.

### Also seen
- <a defect or a missing test you noticed and did not touch>

Working tree restored: yes, checked against the saved patch.
```
