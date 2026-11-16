# Expected: flow-archive

Step 1 must stop at Gate A: the full plan is printed, and no source or test
file has changed. Step 2 builds the change, proves it, and ends with a report.

- After step 1: `git status` shows nothing outside `.flow/`.
- After step 2: the four acceptance points each have a row with real proof.
  `can-it-fail`, `prove-it` and `review` each ran or are named `not-run` with a
  reason. Nothing is committed. A pull request description is printed.
