4 passed, 0 failed, 0 not-run, 0 could-not-run.

## Can it fail: `change/archive-clean`

Compared with `main`: four new tests. All passed before mutation. Seven independent mutations caused the intended assertion failures.

Each mutation used:
`bun test test/archive.test.ts --test-name-pattern "<test name>"`

| Test | Claims to prove | Break | Test after the break | Result |
|---|---|---|---|---|
| archives a note and removes it from the list | Owner receives `204`; note leaves list | Separately returned `200`, disabled archive write, removed list filter | Expected `204`, received `200`; both list mutations returned a note instead of `[]` | passed |
| returns 404 for an unknown note | Unknown ID returns `404` | Returned `204` for missing note | Expected `404`, received `204` | passed |
| adds the archived column to a database created before this change | Migration preserves existing note as unarchived | Changed migration default to `1` | Expected `archived: 0`, received `archived: 1` | passed |
| does not let another user archive the note | Non-owner receives `404`; owner's note remains listed | Separately removed owner guard and archived before returning `404` | Expected `404`, received `204`; expected list length `1`, received `0` | passed |

### Acceptance evidence

After restoration, `bun test` reported **8 pass, 0 fail**, with 12 assertions.

| Acceptance point | Proof from restored tests | Result |
|---|---|---|
| Owner archives and receives `204` | Owner archive test asserted `204` | passed |
| Archived note disappears from `GET /notes` | Owner archive test asserted empty list | passed |
| Another user receives `404`; note stays listed | Authorization test asserted `404` and owner's list length `1` | passed |
| Unknown ID returns `404` | Unknown-note test asserted `404` | passed |

### Weak tests

None found by these mutations.

### Also seen

Tests exercise the real handler and SQLite directly. Live HTTP smoke testing was **not-run**; no dev server was started.

Working tree restored: **yes**, checked after every mutation against the saved patch and status, with exact source bytes restored. Final working tree is clean. No commits or permanent edits were made.