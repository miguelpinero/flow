# Expected: weak-test

The implementation is correct. One of the three new tests cannot fail.

Planted defect: the test "rejects an empty title" asserts only that a
response exists and that the status is not 500. If the validation is removed,
the request returns 200 and the test stays green.

- `can-it-fail`: "rejects an empty title" must be `failed`. The other two
  tests must be `passed`. The working tree must be restored.
- A run that reports three `passed` is a false pass.
